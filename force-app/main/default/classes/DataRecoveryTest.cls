/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-26-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public With Sharing class DataRecoveryTest {
    
    @testSetup
    static void createTestData(){
        
        try{
            List<Account> accounts = new List<Account>();
            for (Integer i = 0; i < 5; i++)
            {
                Account acc = new Account(Name = 'Test Account ' + i);
                accounts.add(acc);
            }
            insert accounts;
            
            		ContentVersion newContentVersion = new ContentVersion();
                    newContentVersion.Title = 'Data recovery'; // Set the file title
                    newContentVersion.PathOnClient = 'Datarecovery.csv'; // Set the file name
                    newContentVersion.VersionData = Blob.valueOf('testdata');
         			Database.SaveResult  result = Database.insert(newContentVersion);
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        
    }
    @isTest
    static void testUploadZipFile_WithoutExternalId(){
        test.startTest();
        List<DataRecovery.objectsDataWrapper>  responseWrapper=	DataRecovery.uploadZipFile(encodingUtil.base64Encode(createZipDataWithoutExternalIdField()));
        
        test.stopTest();    
        
        system.assertEquals('Account',responseWrapper[0].objectName);
        system.assertEquals(1,responseWrapper[0].ExternalIdField.size());
        
    }
    
    @isTest
    static void testUploadZipFile_WithExternalId(){
        test.startTest();
        List<DataRecovery.objectsDataWrapper>  responseWrapper=	DataRecovery.uploadZipFile(encodingUtil.base64Encode(createZipDataWithExternalIdField()));
        test.stopTest();    
        
        system.assertEquals('CBAR__test_obj_with_external_Id__c',responseWrapper[0].objectName);
        system.assertEquals(1,responseWrapper[0].ExternalIdField.size());
        system.assertEquals('CBAR__email_field__c',responseWrapper[0].ExternalIdField[0]);
    }
    
    @isTest
    static void testPerformInsert(){
        String result;
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new DataRecoveryResponseGenerator('CreateInsert'));
        Map<String,string> objectsToInsert = new Map<String,string>();
        objectsToInsert.put('objectName','Account');
        objectsToInsert.put('CsvData',encodingUtil.base64Encode(createZipDataWithoutExternalIdField()));
        
        result = DataRecovery.performInsert(JSON.serialize(new List<Map<String,string>>{objectsToInsert}));
        
        test.stopTest();
        
        system.debug(result);
        system.assertEquals('insert Operation created Successfully', result);
    }
    
    @isTest
    static void testPerformUpsert(){
        String result;
        test.startTest();
        
        Map<String,string> objectsToUpsert = new Map<String,string>();
        objectsToUpsert.put('objectName','CBAR__test_obj_with_external_Id__c');
        objectsToUpsert.put('csvData',encodingUtil.base64Encode(createZipDataWithExternalIdField()));
        objectsToUpsert.put('externalId','CBAR__Email_field__c');
        
        Test.setMock(HttpCalloutMock.class, new DataRecoveryResponseGenerator('CreateUpsert'));
        result = DataRecovery.performUpsert(JSON.serialize(new List<Map<String,String>>{objectsToUpsert}));
        
        test.stopTest();
        system.assertEquals('upsert Operation created Successfully', result);
    }
    
    private static blob createZipDataWithoutExternalIdField(){
        List<Account> accounts = [select id,name from account limit 5];
        String csvData = 'Name\n';
        for (Account acc : accounts) {
            csvData += acc.Name + '\n';
        }
        
        Zippex sampleZip = new Zippex();
        Blob fileData = Blob.valueOf(csvData);
        sampleZip.addFile('Account.csv', fileData, null);
        Blob zipData = sampleZip.getZipArchive();
        return zipData;
    }
    
    private static blob createZipDataWithExternalIdField(){
        
        Blob zipData ;
        try{
            List<test_obj_with_external_Id__c> objectsWithExternalIDS = new List<test_obj_with_external_Id__c>();
            for (Integer i = 0; i < 5; i++)
            {
                test_obj_with_external_Id__c acc = new test_obj_with_external_Id__c(Name = 'Test Account ' + i);
                objectsWithExternalIDS.add(acc);
            }
            insert objectsWithExternalIDS;
            
           // List<test_obj_with_external_Id__c> accounts = [select id,name from test_obj_with_external_Id__c limit 5];
            String csvData = 'Name\n';
            for (test_obj_with_external_Id__c obj : objectsWithExternalIDS) {
                csvData += obj.Name + '\n';
            }
            
            Zippex sampleZip = new Zippex();
            Blob fileData = Blob.valueOf(csvData);
            sampleZip.addFile('CBAR__test_obj_with_external_Id__c.csv', fileData, null);
            zipData = sampleZip.getZipArchive();
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        
        
        return zipData;
    }
}