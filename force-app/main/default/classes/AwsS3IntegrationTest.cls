@isTest
public With Sharing class AwsS3IntegrationTest {

    @isTest
    static void testGetBuckets_With_Positive_Response(){
            Test.setMock(HttpCalloutMock.class, new AwsS3IntegrationCalloutMock('BucketsSuccess')); 
        	test.startTest();
        	List<String> buckets = AwsS3Integration.getBuckets('access', 'secretKey', 'north-1');
        	test.stopTest();
        	system.assertEquals(2, buckets.size());
    }
    
    @isTest
    static void testGetBuckets_With_Negative_Response(){
        
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new AwsS3IntegrationCalloutMock('BucketsError')); 
        	List<String> buckets = AwsS3Integration.getBuckets('access', 'secretKey', 'north-1');
        test.stopTest();
        	system.assertEquals(0, buckets.size());
    }
    
    @isTest
    static void testGetFiles(){
        Test.setMock(HttpCalloutMock.class, new AwsS3IntegrationCalloutMock('Files')); 
        	test.startTest();
        	List<String> files = AwsS3Integration.getFiles('access', 'secretKey', 'north-1','bucket');
        	test.stopTest();
      
        	system.assertEquals(2, files.size());
    }
    
     @isTest
    static void testGetFile(){
        
        test.startTest();
        	Test.setMock(HttpCalloutMock.class, new AwsS3IntegrationCalloutMock('File')); 
        	String fileData = AwsS3Integration.getFile('access', 'secretKey', 'north-1','bucket','test.txt');
        test.stopTest();
        system.assertEquals(blob.valueOf('test Data'),EncodingUtil.base64Decode(fileData));
    }
 
    @isTest
    static void testFilePUT() {
            
       test.starttest();
        Test.setMock(HttpCalloutMock.class, new AwsS3IntegrationCalloutMock('filePut'));
        string result = awsS3Integration.filePUT('test.txt','access', 'secretKey', 'north-1','bucket',blob.valueOf('testData'));
       test.stoptest();
        system.assertEquals('success', result);

    }
}