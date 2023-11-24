@isTest(seealldata = true)
public with sharing class AwsCredentialsTest {
    
    @isTest
    static void testSaveCreds(){
        Integer futureInvocation;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetadataMockGenerator('Metadata'));
        AwsCredentials.saveCred('AccessKey', 'SecretKey', 'RegionName','test Metadata');
        futureInvocation = Limits.getFutureCalls();
        test.stopTest();
        system.assertEquals(1, futureInvocation,'Number of Future Invocation should be 1');
    }
    
    
    @isTest
    static void testGetCredentials(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetadataMockGenerator('Metadata'));
        MetadataCreation.createCustomMetadata('test Metadata', 'AccessKey', 'SecretKey', 'RegionName');
        List<AwsCredential__mdt> awsCreds = AwsCredentials.getCredentails();
        test.stopTest();
        system.assert(awsCreds.size()>0);
    }
    
    @isTest
    static void testGetCredentialsOnName(){
        test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MetadataMockGenerator('CredexCreds'));
        //MetadataCreation.createCustomMetadata('metadata', 'AccessKey', 'SecretKey', 'RegionName');
           //[select id,developerName from AwsCredential__mdt]);

        AwsCredential__mdt awsCreds = AwsCredentials.getCredentailsOnName('CredexCreds');
        test.stopTest();
        System.assertNotEquals(null, awsCreds, 'AwsCredential__mdt object should not be null');
        System.assertEquals('CredexCreds', awsCreds.developerName, 'Developer name should match');
        //System.assertEquals('AccessKey', awsCreds.AccessKey__c, 'AccessKey should match');
        //System.assertEquals('SecretKey', awsCreds.SecretKey__c, 'SecretKey should match');
        //System.assertEquals('RegionName', awsCreds.Region_Name__c, 'RegionName should match');
    }
}