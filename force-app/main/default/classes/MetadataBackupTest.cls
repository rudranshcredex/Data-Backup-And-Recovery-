@isTest
public With Sharing class MetadataBackupTest {
 
    @isTest
    static void testScheduleMetaDataBackup(){
        
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MetadataBackupResponseGenerator('retrieve'));
            MetadataBackup.ScheduleMetaDataBackup(new List<String>{'CustomLabel'},'credentials','2024-09-27T10:15:00.000Z');
        test.stopTest();
    }
    
    @isTest
    static void testRetrieveMetadata(){
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MetadataBackupResponseGenerator('retrieve'));
            MetadataBackup.retrieveMetadata(new List<String>{'CustomLabel'},'credentials');
        test.stopTest();
    }
    
    @isTest
    static void testCheckRetrieveStatus_For_Local(){
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MetadataBackupResponseGenerator('checkRetrieveStatus'));
            MetadataBackup.CheckRetrieveStatus('AsyncResultId',getCredentials(true,false));
        test.stopTest();
    }
    
    @isTest
    static void testCheckRetrieveStatus_For_Aws(){
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MetadataBackupResponseGenerator('checkRetrieveStatus'));
        	Test.setMock(HttpCalloutMock.class, new AwsS3IntegrationCalloutMock('filePut'));
            MetadataBackup.CheckRetrieveStatus('AsyncResultId',getCredentials(false,true));
        test.stopTest();
    }
    
    @isTest
    static void testGetMetaDataTypes(){
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MetadataBackupResponseGenerator('getMetadataTypes'));
            List<MetadataBackup.MetadataWrapper> metadataTypes = MetadataBackup.getMetaDataTypes();
        test.stopTest();
        system.assertEquals(2, metadataTypes.size());
    }
    
    
    private static string getCredentials(boolean backupToLocal, boolean backupToS3){
        return '{ "accessKey": "abc", "SecretKey": "abc", "Bucket": "abc", "awsRegion": "abc", "backupTos3":'+backupToS3+', "backupToLocal":'+backupToLocal+'}';
    }
    
}