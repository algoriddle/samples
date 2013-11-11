package algoriddle.helloaws;

import com.amazonaws.services.s3.*;
import com.amazonaws.services.s3.model.*;

public class App {
    public static void main(String[] args) {
        AmazonS3 s3 = new AmazonS3Client();
        ListObjectsRequest listObjectsRequest = new ListObjectsRequest().withBucketName(args[0]);
        ObjectListing objectListing;
        do {
            objectListing = s3.listObjects(listObjectsRequest);
            for (S3ObjectSummary summary : objectListing.getObjectSummaries())
                System.out.printf("%-30s %10d %s\n", summary.getKey(), summary.getSize(), summary.getStorageClass());
            listObjectsRequest.setMarker(objectListing.getNextMarker());
        } while (objectListing.isTruncated());
    }
}
