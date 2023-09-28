@isTest
public With sharing class DataRecoveryCalloutTest {
    
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
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        
    }
    
    
    @isTest
    static void testCreateInsertJob(){
        
            Map<String,blob> objectsToInsert = new Map<String,blob>();
            objectsToInsert.put('Account',createZipData());
            
            test.startTest();
            
            Test.setMock(HttpCalloutMock.class,new DataRecoveryResponseGenerator('CreateInsert'));
            DataRecoveryCallout.createInsertJob(objectsToInsert);
            
            test.stopTest();
    }
    
    @isTest
    static void testCreateUpsertJob(){
        
        test.startTest();
        
        DataRecovery.ObjectsExternalIdCSVWrapper obj= new DataRecovery.ObjectsExternalIdCSVWrapper();
        obj.objectName= 'test_obj_with_external_Id';
        obj.ExternalId = 'email_field__c';
        obj.csvData = blob.valueOf('test');
        Test.setMock(HttpCalloutMock.class,new DataRecoveryResponseGenerator('CreateUpsert'));
        DataRecoveryCallout.createUpsertJob(new List<DataRecovery.ObjectsExternalIdCSVWrapper>{obj});
        
        test.stopTest();
    }
    
    
    @isTest
    Static void testcheckBatchStatus(){
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class,new DataRecoveryResponseGenerator('CheckInsert'));
        DataRecoveryCallout.checkBatchStatus(create_Data_For_CheckStatus_Insert());
        
        test.stopTest();
    }
    
   
    
    private static blob createZipData(){
        List<Account> accounts = [select id,name from account limit 10];
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
    
    private static String create_Data_For_CheckStatus_Insert(){
        Map<String,String> testData = new Map<String,String>{'objectName'=>'Obj_with_externalId__c','DmlType'=>'insert','jobId'=>'7505i00000LliOUAAZ'};
        return JSON.serialize(new List<Map<String,String>>{testData});
    }
}