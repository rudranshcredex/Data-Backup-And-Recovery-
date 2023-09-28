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
    }

    @isTest
    static void testCreateDataBackup_For_less_than_hundered_objects() {
        
          Test.startTest();
            DataBackup.createDataBackup(new List<String>{'Account'}, credentials, null,null);
          Test.stopTest();
    }

    @isTest
    static void testCreateDataBackup_For_more_than_hundered_objects (){
        
        list<string> objectsNames = new List<string>();
        FOR(schema.SObjectType obj:Schema.getGlobalDescribe().values())
        {
            Schema.DescribeSObjectResult objResult = obj.getDescribe();
            if (objResult.isCreateable() && objResult.isupdateable() && objResult.isqueryable()) {
                objectsNames.add(objResult.getName());
            }
        }
    	Test.startTest();
    	DataBackup.createDataBackup(objectsNames, credentials, null, null);
    	Test.stopTest();
    }
}