global class CSVImportBatchJob implements Database.Batchable<SObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext context) {
         system.debug('in start');
        return Database.getQueryLocator('SELECT Id, Name, Body FROM Document WHERE Name = \'Account Data\'');
       
    }
    
    global void execute(Database.BatchableContext context, List<SObject> records) {	
        system.debug('inside execute');
        // Cast the first record as a Document object
        Document theDocument = (Document)records.get(0);
        System.debug('theDocument: ' + theDocument);
        // Read the document's body as CSV records
        List<List<String>> csvRecords =  CSVReader.doParse(theDocument.Body);
        System.debug('csvRecords: ' + csvRecords);        
        import(csvRecords, 'Account');
    } 
    
    global void finish(Database.BatchableContext context) {

    }
    
    global void execute(SchedulableContext context) {
        Database.executeBatch(this, 1);
    }    
    
    global static void import(List<List<String>> csvRecords, String objectName) {        
        List<String> fieldNames = csvRecords.remove(0);  
        import(csvRecords, objectName, fieldNames);
    }
    
     global static void import(List<List<String>> csvRecords, String objectName, List<String> fieldNames) {        
        SObjectType objectType =Schema.getGlobalDescribe().get(objectName);        
        import(csvRecords, objectType, fieldNames);
    }
    
    global static void import(List<List<String>> csvRecords, SObjectType objectType, List<String> fieldNames) {
        System.debug('csvRecords: ' + csvRecords);
        System.debug('objectType: ' + objectType);
        System.debug('fieldNames: ' + fieldNames);        
        // Initialize the list of records to insert
        List<SObject> newRecords = new List<SObject>();
        // Read each row and parse the row as value to insert
        while (csvRecords.size() > 0) {
            // Initialize the new record
            SObject newRecord = objectType.newSObject();
            // Read the CSV values
            List<String> values = csvRecords.remove(0);
            // Read each value, matching it up to the correct field
            // based on the position of the value in the row
            if (values.size() > 0) {
                for (Integer i = 0; i < fieldNames.size(); i++) {
                    String fieldName = fieldNames.get(i);
                    String fieldValue = values.get(i);
                    newRecord.put(fieldName, fieldValue);
                }
                newRecords.add(newRecord);
            }
        }        
        insert newRecords;
        system.debug('newRecords'+newRecords);
    }
 }