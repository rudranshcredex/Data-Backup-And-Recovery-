public class CSVDataImporter {
    public static void insertCSVRecords(List<List<String>> csvRecords, String objectName) {
        // Get the SObjectType dynamically
        system.debug('csvRecords');
        system.debug(csvRecords);
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        System.debug('objectType: ' + objectType);
        
        if (objectType != null) {
            // Create a list to hold the new records
            List<SObject> recordsToInsert = new List<SObject>();
            
            // Get the field describe information for the object
            Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            system.debug('fieldMap>>>>>>>>>>>>>');
            system.debug(fieldMap);
            // Iterate through each CSV record
            for (List<String> csvRecord : csvRecords) {
                System.debug('csvRecord: ' + csvRecord);
                // Create a new instance of the object
                SObject newRecord = objectType.newSObject();
                System.debug('csv records 1st index: ' + csvRecord[0]);
                
                // Iterate through each field in the CSV record
                for (Integer i = 0; i < csvRecord.size(); i++) {
                    String fieldName = csvRecords[0][i]; // Assuming the first row contains the field names
                    String fieldValue = csvRecord[i];
                    
                   /* system.debug('field values and names'+fieldName);
                    system.debug(fieldValue);*/
                    
                    // Check if the field exists on the object and is editable
                    if (fieldMap.containsKey(fieldName) && fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                        SObjectField field = fieldMap.get(fieldName);
                        Schema.DisplayType fieldType = field.getDescribe().getType();
                       /* System.debug('field: ' + field);
                        System.debug('fieldType: ' + fieldType);*/
                        
                        // Set the field value on the new record based on the field type
                        if (fieldType == Schema.DisplayType.Boolean) {
                           // system.debug('inside boolean');
                            // Handle boolean fields
                            Boolean boolValue = Boolean.valueOf(fieldValue);
                            newRecord.put(field, boolValue);
                        } else if (fieldType == Schema.DisplayType.Integer) {
                            //system.debug('inside integer');
                            // Handle integer fields
                            Integer intValue = Integer.valueOf(fieldValue);
                            newRecord.put(field, intValue);
                        } else {
                            system.debug('inside other');
                            // Handle other fields
                            system.debug(field);
                            newRecord.put(field, fieldValue);
                            //system.debug('during assign'+newRecord.put(field, fieldValue));
                        }
                    }
                }
                
                // Add the new record to the list
                recordsToInsert.add(newRecord);
            }
            
            // Insert the records
            if (!recordsToInsert.isEmpty()) {
                Database.upsert(recordsToInsert);
            }
        }
    }
}