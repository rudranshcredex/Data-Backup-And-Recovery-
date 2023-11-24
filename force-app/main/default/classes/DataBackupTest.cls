@isTest
private class DataBackupTest{
    
    Private static String credentials = 'AWS_Credentials';
    
    
    @isTest
    static void testGetObjectApiNames() {
        List<DataBackup.objectWrapper> objectApiNames;
        
        Test.startTest();
        objectApiNames = DataBackup.getObjectApiNames();
        Test.stopTest();
        
        list<string> objectsNames = new List<string>();
        FOR(schema.SObjectType obj:Schema.getGlobalDescribe().values())
        {
            Schema.DescribeSObjectResult objResult = obj.getDescribe();
            if (objResult.isCreateable() && objResult.isupdateable() && objResult.isqueryable()) {
                objectsNames.add(objResult.getName());
            }
        }
        System.assertEquals(objectsNames.size(),objectApiNames.size());
        
    }
    
    @isTest
    static void testScheduleDataBackup() {
        
        String ScheduleDate = '2024-09-28T09:53:00.000Z';
        Test.startTest();
        DataBackup.ScheduleDataBackup(new List<String>{'Account'}, credentials, null, null, ScheduleDate); 
        Test.stopTest();  
        string name = 'Schedule Data Backup'+system.now().addminutes(2);
        List<CronTrigger> cronJobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name=:name Limit 1];
        system.assertEquals(1, cronJobs.size());
    }
    
    @isTest
    static void testCreateDataBackup_For_less_than_hundered_objects() {
        
        Test.startTest();
        String result = DataBackup.createDataBackup(new List<String>{'Account'}, credentials, null,null);
        Test.stopTest();
        
        system.assertEquals('DataBackupSuccessfullyCreated', result);
    }
    
    @isTest
    static void testCreateDataBackup_For_more_than_hundered_objects (){
        
        try{
            list<string> objectsNames = new List<string>();
            FOR(schema.SObjectType obj:Schema.getGlobalDescribe().values())
            {
                Schema.DescribeSObjectResult objResult = obj.getDescribe();
                if (objResult.isCreateable() && objResult.isupdateable() && objResult.isqueryable()) {
                    objectsNames.add(objResult.getName());
                }
            }
            Test.startTest();
            String result = DataBackup.createDataBackup(objectsNames, credentials, null, null);
            Test.stopTest();
            system.assertEquals('DataBackupSuccessfullyCreated', result);
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
    }
}