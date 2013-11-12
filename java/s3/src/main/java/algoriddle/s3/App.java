package algoriddle.s3;

import com.amazonaws.services.s3.*;
import com.amazonaws.services.s3.model.*;
import java.io.*;
import java.net.URISyntaxException;
import java.nio.file.*;
import java.nio.file.attribute.*;
import java.security.*;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.bind.DatatypeConverter;

public class App {

    public static void main(String[] args) throws IOException, URISyntaxException {
        File pf = new File("s3.properties");
        Properties props = new Properties();
        try (InputStream is = new FileInputStream(pf)) {
            props.load(is);
        }
        props.list(System.out);
        switch (args[0]) {
            case "gendb": generateLocalFileList(props.getProperty("base"), props.getProperty("scope"), props.getProperty("db"));
                break;
        }
//        ;
        /*        AmazonS3 s3 = new AmazonS3Client();
         ListObjectsRequest listObjectsRequest = new ListObjectsRequest().withBucketName(args[0]);
         ObjectListing objectListing;
         do {
         objectListing = s3.listObjects(listObjectsRequest);
         for (S3ObjectSummary summary : objectListing.getObjectSummaries()) {
         System.out.printf("%-30s %10d %s\n", summary.getKey(), summary.getSize(), summary.getStorageClass());
         }
         listObjectsRequest.setMarker(objectListing.getNextMarker());
         } while (objectListing.isTruncated());*/
    }

    static void generateLocalFileList(String basePath, String scopePath, String outputFile) throws IOException {
        final Path base = Paths.get(basePath).toAbsolutePath().normalize();
        try (FileOutputStream fs = new FileOutputStream(outputFile);
                PrintStream out = new PrintStream(fs);) {
            Files.walkFileTree(Paths.get(scopePath).toAbsolutePath().normalize(), new SimpleFileVisitor<Path>() {
                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs)
                        throws IOException {
                    try {
                        out.println(calculateHash(file.toFile()) + "," + base.relativize(file));
                    } catch (NoSuchAlgorithmException ex) {
                        Logger.getLogger(App.class.getName()).log(Level.SEVERE, null, ex);
                    }
                    return FileVisitResult.CONTINUE;
                }
            }
            );
        }
    }
    
    static String calculateHash(File file) throws NoSuchAlgorithmException, IOException {
        MessageDigest algorithm = MessageDigest.getInstance("SHA1");
        try (FileInputStream fis = new FileInputStream(file);
                BufferedInputStream bis = new BufferedInputStream(fis);
                DigestInputStream dis = new DigestInputStream(bis, algorithm)) {
            while (dis.read() != -1) ;
        }
        return DatatypeConverter.printHexBinary(algorithm.digest());
    }
}
