package algoriddle.s3;

import com.amazonaws.AmazonClientException;
import com.amazonaws.AmazonServiceException;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3EncryptionClient;
import com.amazonaws.services.s3.model.EncryptionMaterials;
import com.amazonaws.services.s3.model.ListObjectsRequest;
import com.amazonaws.services.s3.model.ObjectListing;
import com.amazonaws.services.s3.model.S3ObjectSummary;
import com.amazonaws.services.s3.transfer.Download;
import com.amazonaws.services.s3.transfer.TransferManager;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;
import javax.xml.bind.DatatypeConverter;
import java.io.*;
import java.net.URISyntaxException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.security.*;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Properties;
import java.util.logging.*;

public class App {

    private static final EntityManagerFactory factory
            = Persistence.createEntityManagerFactory("algoriddle_s3");
    private static final Logger logger = Logger.getLogger(App.class.getName());

    public static void main(String[] args)
            throws IOException, URISyntaxException, SQLException,
            InterruptedException, GeneralSecurityException {
        if (args.length == 0) {
            return;
        }

        File pf = new File("s3.properties");
        Properties props = new Properties();
        try (InputStream is = new FileInputStream(pf)) {
            props.load(is);
        }
        props.list(System.out);

        Handler fh = new FileHandler("s3.log");
        fh.setFormatter(new SimpleFormatter());
        logger.addHandler(fh);

        logger.info("getProps");
        String access = "", secret = "", bucket = "",
                base = props.getProperty("base"),
                scope = props.getProperty("scope"),
                pattern = props.getProperty("pattern"),
                password = props.getProperty("password"),
                dupermfolder = props.getProperty("dupermfolder"),
                dupekeepfolder = props.getProperty("dupekeepfolder");

        boolean newPassword = false;
        if (password == null) {
            password = generatePassword();
            newPassword = true;
        }

        access = decodeProperty(props, "access", password);
        secret = decodeProperty(props, "secret", password);
        bucket = decodeProperty(props, "bucket", password);

        if (newPassword) {
            props.setProperty("password", password);
            try (OutputStream os = new FileOutputStream(pf)) {
                props.store(os, null);
            }
        }

        switch (args[0]) {
            case "scanclient":
                if (base == null || scope == null || pattern == null) {
                    return;
                }
                cleanLocalFileList(base, pattern);
                generateLocalFileList(base, scope, pattern);
                removeDuplicateFiles(dupermfolder, dupekeepfolder);
                compareClientToServer();
                break;
            case "scanserver":
                getServerListing(access, secret, password, bucket);
                break;
            case "upload":
                upload(base, access, secret, password, bucket);
                break;
            case "download":
                download(args[1], access, secret, password, bucket, args[2]);
                break;
            case "encode":
                String cipherText = encode(createSecretKey(password, ""), "");
                props.setProperty("", cipherText);
                try (OutputStream os = new FileOutputStream(pf)) {
                    props.store(os, null);
                }
                break;
        }
        System.exit(0);
    }

    private static void cleanLocalFileList(String basePath, String pattern)
            throws SQLException {
        logger.info("cleanLocalFileList");
        final Path base = Paths.get(basePath).toAbsolutePath().normalize();
        final PathMatcher matcher = FileSystems.getDefault()
                .getPathMatcher("glob:" + pattern);
        EntityManager em = factory.createEntityManager();
        em.getTransaction().begin();
        Connection connection = em.unwrap(java.sql.Connection.class);
        try (Statement stmt = connection.createStatement(
                ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
             ResultSet rs
                     = stmt.executeQuery("SELECT name, uploaded FROM FileDescriptor")) {
            while (rs.next()) {
                String name = rs.getString(1);
                Path path = base.resolve(name);
                if (matcher.matches(path.getFileName())
                        && path.toFile().exists()) {
                    rs.updateInt(2, 0);
                    rs.updateRow();
                } else {
                    logger.log(Level.INFO, "DELETE: {0}", name);
                    rs.deleteRow();
                }
            }
        }
        em.getTransaction().commit();
        em.close();
    }

    private static void generateLocalFileList(String basePath,
                                              String scopePath, String pattern) throws IOException {
        logger.info("generateLocalFileList");
        final Path base = Paths.get(basePath).toAbsolutePath().normalize();
        final Path scope = Paths.get(scopePath).toAbsolutePath().normalize();
        final EntityManager em = factory.createEntityManager();
        final Query query = em.createQuery(
                "SELECT f FROM FileDescriptor f WHERE f.name = :name");
        final PathMatcher matcher = FileSystems.getDefault()
                .getPathMatcher("glob:" + pattern);
        Files.walkFileTree(scope, new SimpleFileVisitor<Path>() {
            @Override
            public FileVisitResult visitFile(Path path,
                                             BasicFileAttributes attrs) throws IOException {
                try {
                    if (!matcher.matches(path.getFileName())) {
                        return FileVisitResult.CONTINUE;
                    }

                    File file = path.toFile();
                    String name = base.relativize(path).toString().replace("\\", "/");
                    long modified = file.lastModified();

                    em.getTransaction().begin();
                    query.setParameter("name", name);
                    List<FileDescriptor> files = query.getResultList();
                    FileDescriptor fd;
                    if (files.isEmpty()) {
                        fd = new FileDescriptor();
                        logger.log(Level.INFO, "CREATE: {0}", name);
                    } else {
                        fd = files.get(0);
                        if (fd.modified == modified) {
                            em.getTransaction().rollback();
                            return FileVisitResult.CONTINUE;
                        } else {
                            logger.log(Level.INFO, "UPDATE: {0}", name);
                        }
                    }
                    fd.name = name;
                    fd.sha1 = calculateHash(file);
                    fd.modified = modified;
                    em.persist(fd);
                    em.getTransaction().commit();
                } catch (NoSuchAlgorithmException ex) {
                    logger.log(Level.SEVERE, null, ex);
                }
                return FileVisitResult.CONTINUE;
            }
        });
        em.close();
    }

    private static void removeDuplicateFiles(String dupeRmFolder, String dupeKeepFolder) throws IOException {
        logger.info("OP: removeDuplicateFiles");

        EntityManager em = factory.createEntityManager();
        Query dupeQuery = em.createQuery(
                "SELECT f.sha1, COUNT(f) FROM FileDescriptor f "
                        + "GROUP BY f.sha1 HAVING COUNT(f) > 1");
        Query hashQuery = em.createQuery(
                "SELECT f FROM FileDescriptor f WHERE f.sha1 = :sha1");
        em.getTransaction().begin();
        List<Object[]> dupes = dupeQuery.getResultList();
        try (BufferedWriter df = Files.newBufferedWriter(Paths.get("dupes.sh"), Charset.forName("UTF-8"))) {
            for (Object[] dupe : dupes) {
                String hash = (String) dupe[0];
                logger.log(Level.WARNING, "DUPLICATE: {0}", hash);
                hashQuery.setParameter("sha1", hash);
                List<FileDescriptor> files = hashQuery.getResultList();
                boolean first = true;
                int dc = 1;
                for (FileDescriptor file : files) {
                    logger.log(Level.WARNING, "FILE: {0}", file.name);
                    if (!first) {
                        em.remove(file);
                    }
                    first = false;
                    if ((dupeRmFolder != null 
                                && file.name.startsWith(dupeRmFolder)) 
                            || (dupeKeepFolder != null 
                                && !file.name.startsWith(dupeKeepFolder)) 
                            && dc < files.size()) {
                        df.write("rm \"" + file.name + "\"\n");
                        dc++;
                    }
                }
            }
        }
        em.getTransaction().commit();
        em.close();
    }

    private static String calculateHash(File file)
            throws NoSuchAlgorithmException, IOException {
        MessageDigest algorithm = MessageDigest.getInstance("SHA1");
        try (DigestInputStream dis
                = new DigestInputStream(
                new BufferedInputStream(
                new FileInputStream(file)), algorithm)) {
            while (dis.read() != -1) ;
        }
        return DatatypeConverter.printHexBinary(algorithm.digest());
    }

    private static void compareClientToServer() throws IOException, SQLException {
        logger.info("OP: compareClientToServer");
        EntityManager em = factory.createEntityManager();
        Query hashQuery = em.createQuery(
                "SELECT f FROM FileDescriptor f WHERE f.sha1 = :sha1");
        Query nameQuery = em.createQuery(
                "SELECT f FROM FileDescriptor f WHERE UPPER(f.name) = :name");
        em.getTransaction().begin();
        try (BufferedReader reader = Files.newBufferedReader(Paths.get("s3.lst"), Charset.forName("UTF-8"))) {
            String line = null;
            while ((line = reader.readLine()) != null) {
                String[] s3d = line.split(":");
                if (s3d.length != 3) {
                    throw new RuntimeException();
                }
                int sp = s3d[0].lastIndexOf('.');
                String name = s3d[0].substring(0, sp);
                String hash = s3d[0].substring(sp + 1);
                hashQuery.setParameter("sha1", hash);
                List<FileDescriptor> files;
                files = hashQuery.getResultList();
                if (files.size() > 1) {
                    throw new RuntimeException();
                }
                if (!files.isEmpty()) {
                    FileDescriptor file = files.get(0);
                    if (!file.name.equalsIgnoreCase(name)) {
                        logger.log(Level.INFO, "EXISTS ON SERVER: {0}", file.name);
                        logger.log(Level.WARNING, "DIFFERENT NAME: {0}", name);
                    }
                    file.uploaded = 1;
                    em.persist(file);
                } else {
                    nameQuery.setParameter("name", name.toUpperCase(Locale.ENGLISH));
                    files = nameQuery.getResultList();
                    if (!files.isEmpty()) {
                        FileDescriptor file = files.get(0);
                        logger.log(Level.INFO, "EXISTS ON SERVER: {0}", file.name);
                        logger.log(Level.WARNING, "DIFFERENT HASH: {0}", name);
                    }
                }
            }
        }
        em.getTransaction().commit();

        em.getTransaction().begin();
        Connection connection = em.unwrap(java.sql.Connection.class);
        try (Statement stmt = connection.createStatement(
                ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY);
             ResultSet rs = stmt.executeQuery(
                     "SELECT name FROM FileDescriptor WHERE uploaded = 0")) {
            while (rs.next()) {
                String name = rs.getString(1);
                logger.log(Level.INFO, "UPLOAD: {0}", name);
            }
        }
        em.getTransaction().commit();
        em.close();
    }

    private static void upload(
            String basePath, String accessKey, String secretKey,
            String password, String bucket)
            throws SQLException, GeneralSecurityException,
            AmazonClientException, AmazonServiceException,
            InterruptedException {
        logger.info("OP: upload");
        AWSCredentials credentials
                = new BasicAWSCredentials(accessKey, secretKey);
        Path base = Paths.get(basePath).toAbsolutePath().normalize();
        EntityManager em = factory.createEntityManager();
        em.getTransaction().begin();
        Connection connection = em.unwrap(java.sql.Connection.class);
        try (Statement stmt = connection.createStatement(
                ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
             ResultSet rs = stmt.executeQuery(
                     "SELECT name, sha1, uploaded FROM FileDescriptor "
                             + "WHERE uploaded = 0")) {
            while (rs.next()) {
                String name = rs.getString(1);
                Path path = base.resolve(name);
                name = name.toLowerCase(Locale.ENGLISH) + "." + rs.getString(2); // add hash
                logger.log(Level.INFO, "UPLOAD BEGIN: {0}", name);
                SecretKey aesKey = createSecretKey(password, name);
                AmazonS3 s3 = new AmazonS3EncryptionClient(credentials,
                        new EncryptionMaterials(aesKey));
                s3.putObject(bucket, name, path.toFile());
                rs.updateInt(3, 1); // uploaded = 1
                rs.updateRow();
                logger.log(Level.INFO, "UPLOAD END: {0}", name);
            }
        }
        em.getTransaction().commit();
        em.close();
    }

    private static void download(
            String basePath, String accessKey, String secretKey,
            String password, String bucket, String objectKey)
            throws AmazonClientException, AmazonServiceException,
            InterruptedException, GeneralSecurityException {
        AWSCredentials credentials
                = new BasicAWSCredentials(accessKey, secretKey);
        SecretKey aesKey = createSecretKey(password, objectKey);
        AmazonS3 s3 = new AmazonS3EncryptionClient(credentials,
                new EncryptionMaterials(aesKey));
        TransferManager tm = new TransferManager(s3);
        String fileName = objectKey.substring(0, objectKey.lastIndexOf('.'));
        File file
                = Paths.get(basePath).toAbsolutePath().normalize()
                .resolve(fileName).toFile();
        Download download = tm.download(bucket, objectKey, file);
        download.waitForCompletion();
        tm.shutdownNow();
    }

    private static SecretKey createSecretKey(
            String password, String salt)
            throws GeneralSecurityException {
        byte[] sb = salt.getBytes(StandardCharsets.UTF_8);
        PBEKeySpec keySpec
                = new PBEKeySpec(password.toCharArray(), sb, 65536, 256);
        SecretKeyFactory skf
                = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
        SecretKey sk = skf.generateSecret(keySpec);
        return new SecretKeySpec(sk.getEncoded(), "AES");
    }

    private static String encode(SecretKey key, String plaintext)
            throws GeneralSecurityException, UnsupportedEncodingException {
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, key);
        AlgorithmParameters params = cipher.getParameters();
        byte[] iv = params.getParameterSpec(IvParameterSpec.class).getIV();
        if (iv.length != 16) {
            throw new RuntimeException();
        }
        byte[] ciphertext = cipher.doFinal(plaintext.getBytes("UTF-8"));
        byte[] combined = Arrays.copyOf(iv, 16 + ciphertext.length);
        System.arraycopy(ciphertext, 0, combined, 16, ciphertext.length);
        return DatatypeConverter.printBase64Binary(combined);
    }

    private static String decode(SecretKey key, String ciphertext)
            throws GeneralSecurityException, UnsupportedEncodingException {
        byte[] combined = DatatypeConverter.parseBase64Binary(ciphertext);
        byte[] iv = Arrays.copyOf(combined, 16);
        int cl = combined.length - 16;
        byte[] ct = new byte[cl];
        System.arraycopy(combined, 16, ct, 0, cl);
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, key, new IvParameterSpec(iv));
        return new String(cipher.doFinal(ct), "UTF-8");
    }

    private static String generatePassword() throws IOException {
        List<String> questions
                = Files.readAllLines(Paths.get("questions.txt"),
                Charset.forName("UTF-8"));
        String password = "";
        BufferedReader input
                = new BufferedReader(new InputStreamReader(System.in));
        for (String question : questions) {
            System.out.println(question);
            password += input.readLine();
        }
        return password;
    }

    private static String decodeProperty(
            Properties props, String propertyName, String password)
            throws GeneralSecurityException, UnsupportedEncodingException {
        return decode(createSecretKey(password, propertyName),
                props.getProperty(propertyName));
    }

    private static void getServerListing(
            String accessKey, String secretKey, String password, String bucket)
            throws GeneralSecurityException, IOException {
        logger.info("OP: getServerListing");
        AWSCredentials credentials
                = new BasicAWSCredentials(accessKey, secretKey);
        SecretKey aesKey = createSecretKey(password, bucket);
        AmazonS3 s3 = new AmazonS3EncryptionClient(credentials,
                new EncryptionMaterials(aesKey));
        ListObjectsRequest listObjectsRequest
                = new ListObjectsRequest().withBucketName(bucket);
        try (BufferedWriter writer
                     = Files.newBufferedWriter(Paths.get("s3.lst"),
                Charset.forName("UTF-8"))) {
            ObjectListing listing;
            do {
                listing = s3.listObjects(listObjectsRequest);
                for (S3ObjectSummary s3os : listing.getObjectSummaries()) {
                    writer.write(s3os.getKey() + ":" + s3os.getSize()
                            + ":" + s3os.getStorageClass() + "\n");
                }
                listObjectsRequest.setMarker(listing.getNextMarker());
            } while (listing.isTruncated());
        }
    }
}
