@isTest
private class DataBackupCalloutTest {
    
	@isTest
    static void testGetQueryJobIds_With_Null_Dates(){
        integer futureInvocation;
		 test.startTest();
             Test.setMock(HttpCalloutMock.class,new DataBackupResponseGenerator('getJobId'));
            DataBackupCallout.getQueryJobIds(new List<String>{'Account'}, 'Batch0', null, null);
        futureInvocation = limits.getFutureCalls();
         test.stopTest();
       system.assertEquals(1, futureInvocation,'Number of Future Invocation should be 1');
    } 
    
    
	@isTest
    static void testGetQueryJobIds_With_Dates(){
        integer futureInvocation;
        test.startTest();
            Test.setMock(HttpCalloutMock.class,new DataBackupResponseGenerator('getJobId'));
            DataBackupCallout.getQueryJobIds(new List<String>{'Account'}, 'testBatch', '2023-09-30', '2023-10-23');
            futureInvocation = limits.getFutureCalls();
        test.stopTest();
        system.assertEquals(1, futureInvocation,'Number of Future Invocation should be 1');        
    } 
    
    @isTest
    static void testGetJobResults() {
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new DataBackupResponseGenerator('getResult'));
        DataBackupCallout.getJobResults(new Map<String, String>{'Account'=>'7505i00000Lkbu7AAB'}, 'testBatch');
        
        Test.stopTest();
        
        
        Integer result = [select count() from contentversion where title = 'testBatch'];
       
        system.assertEquals(1,result);
    }
    
    @isTest
    static void testReadZipFiles_For_Local() {
             
        integer futureInvocation;
        Test.startTest();
        
           createTestFile();
           DataBackupCallout.readZipFiles(new List<String>{'testBatch'}, getCredentials(false,true));
          futureInvocation = limits.getFutureCalls();
        Test.stopTest();
        system.assertEquals(1, futureInvocation,'Number of Future Invocation should be 1');        
    }
    
        @isTest
    static void testReadZipFiles_For_s3() {
            
        integer futureInvocation;
        Test.startTest(); 
        
           Test.setMock(HttpCalloutMock.class, new AwsS3IntegrationCalloutMock('filePut'));
           createTestFile();
           DataBackupCallout.readZipFiles(new List<String>{'testBatch'}, getCredentials(true,false));
           futureInvocation = limits.getFutureCalls();
        Test.stopTest();
        system.assertEquals(1, futureInvocation,'Number of Future Invocation should be 1');  
    }
    
    
    Private static String getCredentials(boolean BackupTos3,boolean BackupToLocal){
         Map<String, Object> testCredentials = new Map<String, Object>{
        'accessKey' => 'AccessKey',
        'SecretKey' => 'SecretKey',
        'Bucket' => 'Bucket',
        'awsRegion' => 'AwsRegion',
        'backupTos3' => BackupTos3,
        'backupToLocal' => BackupToLocal
    };
        return JSON.serialize(testCredentials);
    }
    
    private static void createTestFile(){
        try{
            ContentVersion contentVersion = new ContentVersion(
                    Title = 'testBatch',
                    VersionData = blob.valueOf('testData'),
                    PathOnClient = '/' + 'testBatch'+'.zip'
               );
            insert  contentVersion;
        }
        catch(Exception ex){
            //system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
}