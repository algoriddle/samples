package algoriddle.s3;

import com.amazonaws.services.s3.*;
import com.amazonaws.services.s3.model.*;
import java.io.*;
import java.net.URISyntaxException;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.security.*;
import java.sql.*;
import java.util.List;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.persistence.*;
import javax.xml.bind.DatatypeConverter;

public class App {
    
    private static EntityManagerFactory factory = Persistence.createEntityManagerFactory("algoriddle_s3");
    private static Logger logger = Logger.getLogger(App.class.getName());
        
    public static void main(String[] args) throws IOException, URISyntaxException, SQLException {
        File pf = new File("s3.properties");
        Properties props = new Properties();
        try (InputStream is = new FileInputStream(pf)) {
            props.load(is);
        }
        props.list(System.out);
        String base = props.getProperty("base"),
                scope = props.getProperty("scope");
        switch (args[0]) {
            case "gendb": 
                cleanLocalFileList(base);
                generateLocalFileList(base, scope);
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

    private static void generateLocalFileList(String basePath, String scopePath) throws IOException {
        logger.info("generateLocalFileList");
        final Path base = Paths.get(basePath).toAbsolutePath().normalize();
        final EntityManager em = factory.createEntityManager();
        final Query query = em.createQuery("SELECT f FROM FileDescriptor f WHERE f.name = :name");
        Files.walkFileTree(Paths.get(scopePath).toAbsolutePath().normalize(), new SimpleFileVisitor<Path>() {
            @Override
            public FileVisitResult visitFile(Path path, BasicFileAttributes attrs)
                    throws IOException {
                try {
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
    
    private static String calculateHash(File file) throws NoSuchAlgorithmException, IOException {
        MessageDigest algorithm = MessageDigest.getInstance("SHA1");
        try (FileInputStream fis = new FileInputStream(file);
                BufferedInputStream bis = new BufferedInputStream(fis);
                DigestInputStream dis = new DigestInputStream(bis, algorithm)) {
            while (dis.read() != -1) ;
        }
        return DatatypeConverter.printHexBinary(algorithm.digest());
    }

    private static void cleanLocalFileList(String basePath) throws SQLException {
        logger.info("cleanLocalFileList");
        final Path base = Paths.get(basePath).toAbsolutePath().normalize();
        EntityManager em = factory.createEntityManager();
        em.getTransaction().begin();
        Connection connection = em.unwrap(java.sql.Connection.class);
        try (Statement stmt = connection.createStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
                ResultSet rs = stmt.executeQuery("SELECT name FROM FileDescriptor")) {
            while (rs.next()) {
                String name = rs.getString(1);
                if (!base.resolve(name).toFile().exists()) {
                    logger.log(Level.INFO, "DELETE: {0}", name);
                    rs.deleteRow();
                }
            }
        }
        em.getTransaction().commit();
        em.close();
    }
}
