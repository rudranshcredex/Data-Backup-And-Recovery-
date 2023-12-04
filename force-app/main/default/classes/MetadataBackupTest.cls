@isTest
public With Sharing class MetadataBackupTest {
 
    @isTest
    static void testScheduleMetaDataBackup(){
        String JobId;
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MetadataBackupResponseGenerator('retrieve'));
           MetadataBackup.ScheduleMetaDataBackup(new List<String>{'CustomLabel'},'credentials','2024-09-27T10:15:00.000Z');
        test.stopTest();
        string name = 'Scheduled MetaData Backup'+system.now();
        List<CronTrigger> cronJobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name=:name Limit 1];
        system.assertEquals(1, cronJobs.size());
    }
    @isTest
    static void testRetrieveMetadata(){
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MetadataBackupResponseGenerator('retrieve'));
            MetadataBackup.retrieveMetadata(new List<String>{'CustomObject'},'credentials');
        system.debug(Limits.getCallouts());
        test.stopTest();
        string name ='MetadataRetreiveCheckStatus '+System.now();
         List<CronTrigger> cronJobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name=:name Limit 1];
        system.assertEquals(1, cronJobs.size());
    }
    
    @isTest
    static void testCheckRetrieveStatus_For_Local(){
        integer futureInvocation;
test.startTest();
    Test.setMock(HttpCalloutMock.class, new MetadataBackupResponseGenerator('checkRetrieveStatus'));
    MetadataBackup.CheckRetrieveStatus('AsyncResultId', getCredentials(true, false));
    futureInvocation = Limits.getFutureCalls();
test.stopTest();
system.assertEquals(1, futureInvocation,'Number of Future Invocation should be 1');
    }
    
    @isTest
    static void testCheckRetrieveStatus_For_Aws(){
          integer futureInvocation;
        test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new MetadataBackupResponseGenerator('checkRetrieveStatus'));
        	Test.setMock(HttpCalloutMock.class, new AwsS3IntegrationCalloutMock('filePut'));
            MetadataBackup.CheckRetrieveStatus('AsyncResultId',getCredentials(false,true));
        	futureInvocation = Limits.getFutureCalls();
        
        test.stopTest();
        system.assertEquals(1, futureInvocation,'Number of Future Invocation should be 1');
    }
    
    @isTest
    static void testGetMetaDataTypes(){
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MetadataBackupResponseGenerator('getMetadataTypes'));
            List<MetadataBackup.MetadataWrapper> metadataTypes = MetadataBackup.getMetaDataTypes();
        test.stopTest();
        system.assertEquals(2, metadataTypes.size());
    }
    
    @isTest
    static void testGetObjectNames(){
        test.startTest();
        List<String> customObjects = MetadataBackup.getObjectNames();
        test.stopTest();
        system.Assert(customObjects.size()>0);
    }
    
    
    private static string getCredentials(boolean backupToLocal, boolean backupToS3){
        return '{ "accessKey": "abc", "SecretKey": "abc", "Bucket": "abc", "awsRegion": "abc", "backupTos3":'+backupToS3+', "backupToLocal":'+backupToLocal+'}';
    }
    
}