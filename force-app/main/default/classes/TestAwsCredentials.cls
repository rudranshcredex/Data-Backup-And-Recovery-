@isTest
private class TestAwsCredentials {

    @isTest
    public static void testSaveCredentialsToCustomSetting() {
        String AccessKey = 'xxxxxxxxx';
        String SecretKey = 'yyyyyyyyy';
        String RegionName = 'eu-north-1';
        String credName = 'abc';

        Test.startTest();
        AwsCredentials.saveCredentialsToCustomSetting(AccessKey, SecretKey, RegionName, credName);
        Test.stopTest();

        List<Aws_Credentials__c> credList = [SELECT Id, Name__c, AccessKey__c, SecretKey__c, Region_Name__c FROM Aws_Credentials__c WHERE Name__c = :credName];
        System.assertEquals(1, credList.size(), 'Credentials record not inserted successfully');
    }

    @isTest
    private static void testSaveCred() {
        String AccessKey = 'xxxxxxxxxxxx';
        String SecretKey = 'yyyyyyyyyy';
        String RegionName = 'zzzzzzzzzzz';
        String credName = 'xyz';

        Test.startTest();
        AwsCredentials.saveCred(AccessKey, SecretKey, RegionName, credName);
        Test.stopTest();

        List<Aws_Credentials__c> credList = [SELECT Id FROM Aws_Credentials__c];
        System.assertEquals(1, credList.size(), 'Credentials record not inserted successfully');
    }

    @isTest
    public static void testGetCredentails() {
        Aws_Credentials__c creds = new Aws_Credentials__c(Name__c = 'TestCreds', AccessKey__c = 'TestAccessKey', SecretKey__c = 'TestSecretKey', Region_Name__c = 'TestRegion');
        insert creds;

        Test.startTest();
        List<Aws_Credentials__c> response = AwsCredentials.getCredentails();
        Test.stopTest();

        System.assertNotEquals(null, response, 'getCredentails returned null');
        System.assertEquals(1, response.size(), 'Incorrect number of credentials returned');
    }

    @isTest
    public static void testGetCredentailsOnName() {
        Aws_Credentials__c creds = new Aws_Credentials__c(Name__c = 'TestCreds', AccessKey__c = 'TestAccessKey', SecretKey__c = 'TestSecretKey', Region_Name__c = 'TestRegion');
        insert creds;

        String name = 'TestCreds';

        Test.startTest();
        Aws_Credentials__c response = AwsCredentials.getCredentailsOnName(name);
        Test.stopTest();

        System.assertNotEquals(null, response, 'getCredentailsOnName returned null');
        System.assertEquals(name, response.Name__c, 'Incorrect credential name returned');
    }
}