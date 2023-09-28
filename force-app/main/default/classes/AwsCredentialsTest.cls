@isTest
public with sharing class AwsCredentialsTest {

      @isTest
    static void testSaveCreds(){
        test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MetadataMockGenerator('Metadata'));
            AwsCredentials.saveCred('AccessKey', 'SecretKey', 'RegionName','test Metadata');
        test.stopTest();
    }
    
    
    @isTest
    static void testGetCredentials(){
        test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MetadataMockGenerator('Metadata'));
        	MetadataCreation.createCustomMetadata('test Metadata', 'AccessKey', 'SecretKey', 'RegionName');
        	List<AwsCredential__mdt> awsCreds = AwsCredentials.getCredentails();
        test.stopTest();
    }
    
    @isTest
    static void testGetCredentialsOnName(){
        test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MetadataMockGenerator('Metadata'));
        	MetadataCreation.createCustomMetadata('metadata', 'AccessKey', 'SecretKey', 'RegionName');
        system.debug([select id,developerName from AwsCredential__mdt where developerName='metadata']);
        	AwsCredential__mdt awsCreds = AwsCredentials.getCredentailsOnName('metadata');
        test.stopTest();
        system.debug(awsCreds);
    }
    
}