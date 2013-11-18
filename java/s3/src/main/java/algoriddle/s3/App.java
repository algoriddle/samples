package algoriddle.s3;

import com.amazonaws.AmazonClientException;
import com.amazonaws.AmazonServiceException;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.transfer.Download;
import com.amazonaws.services.s3.transfer.TransferManager;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URISyntaxException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.PathMatcher;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.security.AlgorithmParameters;
import java.security.DigestInputStream;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Properties;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
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

public class App 
{

    private static final EntityManagerFactory factory
            = Persistence.createEntityManagerFactory("algoriddle_s3");
    private static final Logger logger = Logger.getLogger(App.class.getName());
    private static final String questionsFileName = "questions.txt";
    
    public static void main(String[] args)
            throws IOException, URISyntaxException, SQLException, 
                InterruptedException, GeneralSecurityException 
    {
        if (args.length == 0)
            return;

        File pf = new File("s3.properties");
        Properties props = new Properties();
        try (InputStream is = new FileInputStream(pf)) {
            props.load(is);
        }
        props.list(System.out);
        
        String access = "", secret = "", bucket = "",
                base = props.getProperty("base"),
                scope = props.getProperty("scope"),
                pattern = props.getProperty("pattern"),
                password = props.getProperty("password");
        
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
            case "scan":
                if (base == null || scope == null || pattern == null)
                    return;
                cleanLocalFileList(base, pattern);
                generateLocalFileList(base, scope, pattern);
                break;
            case "encode":
                String cipherText = encode(createSecretKey(password, ""), "");
                props.setProperty("", cipherText);
                try (OutputStream os = new FileOutputStream(pf)) {
                    props.store(os, null);
                }
                break;
        }
//        ;
        /*        AmazonS3 s3 = new AmazonS3Client();
         ListObjectsRequest listObjectsRequest = new ListObjectsRequest().withBucketName(args[0]);
         ObjectListing objectListing;
         do {
         objectListing = s3.listObjects(listObjectsRequest);
         for (S3ObjectSummary sha1 : objectListing.getObjectSummaries()) {
         System.out.printf("%-30s %10d %s\n", sha1.getKey(), sha1.getSize(), sha1.getStorageClass());
         }
         listObjectsRequest.setMarker(objectListing.getNextMarker());
         } while (objectListing.isTruncated());*/
        System.exit(0);
    }

    private static void generateLocalFileList(String basePath,
            String scopePath, String pattern) throws IOException 
    {
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
                    String name = base.relativize(path).toString();
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

    private static String calculateHash(File file)
            throws NoSuchAlgorithmException, IOException 
    {
        MessageDigest algorithm = MessageDigest.getInstance("SHA1");
        try (DigestInputStream dis = 
                new DigestInputStream(
                new BufferedInputStream(
                new FileInputStream(file)), algorithm)) 
        {
            while (dis.read() != -1) ;
        }
        return DatatypeConverter.printHexBinary(algorithm.digest());
    }

    private static void cleanLocalFileList(String basePath, String pattern)
            throws SQLException 
    {
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
                = stmt.executeQuery("SELECT name FROM FileDescriptor")) {
            while (rs.next()) {
                String name = rs.getString(1);
                Path path = base.resolve(name);
                if (!matcher.matches(path.getFileName())
                        || !path.toFile().exists()) {
                    logger.log(Level.INFO, "DELETE: {0}", name);
                    rs.deleteRow();
                }
            }
        }
        em.getTransaction().commit();
        em.close();
    }

    private static SecretKey createSecretKey(
            String password, String salt)
            throws NoSuchAlgorithmException, InvalidKeySpecException 
    {    
        byte[] sb = salt.getBytes(StandardCharsets.UTF_8);
        PBEKeySpec keySpec
                = new PBEKeySpec(password.toCharArray(), sb, 65536, 256);
        SecretKeyFactory skf = 
                SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
        SecretKey sk = skf.generateSecret(keySpec);
        return new SecretKeySpec(sk.getEncoded(), "AES");
    }

    private static String encode(SecretKey key, String plaintext) 
            throws GeneralSecurityException, UnsupportedEncodingException 
    {
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, key);
        AlgorithmParameters params = cipher.getParameters();
        byte[] iv = params.getParameterSpec(IvParameterSpec.class).getIV();
        if (iv.length != 16)
            throw new SecurityException();
        byte[] ciphertext = cipher.doFinal(plaintext.getBytes("UTF-8"));
        byte[] combined = Arrays.copyOf(iv, 16 + ciphertext.length);
        System.arraycopy(ciphertext, 0, combined, 16, ciphertext.length);
        return DatatypeConverter.printBase64Binary(combined);
    }
    
    private static String decode(SecretKey key, String ciphertext) 
            throws GeneralSecurityException, UnsupportedEncodingException
    {
        byte[] combined = DatatypeConverter.parseBase64Binary(ciphertext);
        byte[] iv = Arrays.copyOf(combined, 16);
        int cl = combined.length - 16;
        byte[] ct = new byte[cl];
        System.arraycopy(combined, 16, ct, 0, cl);
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, key, new IvParameterSpec(iv));
        return new String(cipher.doFinal(ct), "UTF-8");
    }
    
    private static void downloadPublic(
            String bucketName, String objectKey, File file) 
            throws AmazonClientException, AmazonServiceException, 
                    InterruptedException 
    {
        AmazonS3Client client = new AmazonS3Client();
        TransferManager tm = new TransferManager(client);
        Download download = tm.download(bucketName, objectKey, file);
        download.waitForCompletion();
        tm.shutdownNow();
    }

    private static String generatePassword() throws IOException {
        List<String> questions
                = Files.readAllLines(Paths.get(questionsFileName), 
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
            throws GeneralSecurityException, UnsupportedEncodingException
    {
        return decode(createSecretKey(password, propertyName), 
                props.getProperty(propertyName));
    }
}
