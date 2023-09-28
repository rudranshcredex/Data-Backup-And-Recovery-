public with sharing class UploadCSVFileController {
 /* @AuraEnabled
  public static void uploadCSVFile(String fileContent) {
    system.debug('file content>>>>>>>>>>>>>>');
    system.debug(fileContent);
    List<String> csvLines = fileContent.split('\n');
    system.debug('csv lines>>>>>>'+csvLines);
    List<Sobject> recordsToInsert = new List<Sobject>();
      
      
      
	SObjectType objectType = Schema.getGlobalDescribe().get('Account');
    System.debug('objectType: ' + objectType);
    
     Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
     system.debug('fieldMap>>>>>>>>>>>>>');
     system.debug(fieldMap);
      
      
      system.debug('size '+csvLines.size());
      system.debug(csvLines[0]);
      //system.debug(csvLines[0]);
    // Skip the header row (if applicable)
    for (Integer i = 1; i < csvLines.size(); i++) {
        
        SObject newRecord = objectType.newSObject();
        
        String[] csvValues = csvLines[i].split(',');
        
        system.debug('csv values'+csvValues);
        
         /*if (fieldMap.containsKey(fieldName) && fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                        SObjectField field = fieldMap.get(fieldName);
                        Schema.DisplayType fieldType = field.getDescribe().getType();
                        System.debug('field: ' + field);
                        System.debug('fieldType: ' + fieldType);
        

      // Map CSV values to custom object fields
      Account obj = new Account();
      obj.Id = csvValues[0];
      obj.Name = csvValues[1];
      // Assign other fields accordingly
      
      recordsToInsert.add(obj);
    }

      system.debug('records to upsert'+recordsToInsert);
    // Insert the records
    upsert recordsToInsert;
  }*/
    
    Private static Integer totalRecords=0;
    Private static Integer updatedRecords=0;
    Private static Integer createdRecords=0;
    Private static Integer recordsNotProcessed=0;
    Private static String  objectName;
    Private static Map<String,Integer> recordProcessed=new Map<String,Integer>() ;
    
    @AuraEnabled
    public static void processCSVFile(String csvContent) {
        system.debug('csv content');
        system.debug(csvContent);
        //BulkApiQueryExample.addBatchToJob('7505i00000KbJUBAA3',csvContent);
       // system.debug('csvContent>>>>>>>>>>>>>>>>');
        //system.debug(csvContent);
        List<Object> objects=(List<Object>)JSON.deserializeUntyped(csvContent);
        for(Object obj:objects){
            
            //system.debug('objects Map>>>>>>>>>');
            //system.debug((Map<String,object>)obj);
          Map<String,object> Datta=(Map<String,object>)obj;
          for(String objectNames:Datta.keySet()){
            objectName=objectNames;
            List<Id> recordIds=new List<Id>();
            
            List<sobject> sobjectRecords=Database.query('SELECT ID FROM '+objectName+' LIMIT 500000');
    
            for (sobject record:sobjectRecords){
                recordIds.add(record.id);
            }
              
          //  system.debug('csvContent>>>>  '+csvContent);
            SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            system.debug('fieldsMap>>>>>>>>>>>>>>>>>>  ');
            system.debug(fieldMap);
            /*system.debug('csvContent>>>>>>>>>>>>'); //should be commented
            system.debug(csvContent);*/
              String csvData = (String)Datta.get(objectNames);
            List<String> csvLines = csvData.split('\n');
            //system.debug('csvLines>>>>>>>>>');
            system.debug(csvLines);
            String[] headers = csvLines[0].split(',');
            system.debug('headers>>>>>>');
            //system.debug(headers);
    
            List<SObject> recordsToUpsert = new List<SObject>();
    
            for (Integer i = 1; i < csvLines.size(); i++) {
                String[] fields = csvLines[i].split(',');
    
                if (fields.size() == headers.size()) {
                    
                    sObject newRecord = Schema.getGlobalDescribe().get(objectName).newSObject() ; 
    
                for (Integer j = 0; j < headers.size(); j++) {
                    String header = headers[j];
                    String field = fields[j];
                    if(field!=null && field.startsWith('"') && field.endsWith('"'))
                    {
                       field=field.substring(1,field.length()-1);
                    }
                    system.debug('header'+header);
                    system.debug('field'+field);
                    
                    if(header=='id'){
                        system.debug('header ID'+header);
                        system.debug('id field'+field);
                        if(field!=null){
                            if(recordIds.contains(field)){
                                system.debug('nd');
                                newrecord.put(header,field);
                            }    
                        }
                        else{
                            newrecord.put(header,null);
                        }
                        
                    }
                   
                    if(fieldMap.containsKey(header) && fieldMap.get(header).getDescribe().isUpdateable()){
                        SObjectField fiel = fieldMap.get(header);
                        Schema.DisplayType fieldType = fiel.getDescribe().getType();
                        System.debug('field: ' + fiel);
                        System.debug('fieldType: ' + fieldType);
                        
                        if(fieldType==Schema.DisplayType.boolean){
                            system.debug('boolean>>'+fieldtype);
                            newRecord.put(header,boolean.valueOf(field));
                        }
                        
                        else if(fieldType == Schema.DisplayType.PERCENT){
                            Decimal decimalValue;
                            if(field.equals('""')){
                                decimalValue=null;
                            }
                            else{
                                if(String.isNotBlank(field)){
                                    decimalValue=decimal.valueOf(field);
                                    //system.debug(decimalVa);
                                }
                                else{
                                    decimalValue=null;
                                }
                                system.debug('Percent>>'+fieldtype); 
                            }
                            
                            newRecord.put(header,decimalValue);
                        }
                        else if(fieldType==Schema.DisplayType.Currency){
                            Decimal decimalValue;
                            if(field.equals('""')){
                                decimalValue=null;
                            }
                            else{
                                if(String.isNotBlank(field)){
                                    decimalValue=decimal.valueOf(field);
                                    //system.debug(decimalVa);
                                }
                                else{
                                    decimalValue=null;
                                }
                                system.debug('currency>>'+fieldtype); 
                            }
                            
                            newRecord.put(header,decimalValue);
                        } 
                        else if(fieldType==Schema.DisplayType.double){
                            Decimal decimalValue;
                            if(field.equals('""')){
                                decimalValue=null;
                            }
                            else{
                                if(String.isNotBlank(field)){
                                    decimalValue=decimal.valueOf(field);
                                    //system.debug(decimalVa);
                                }
                                else{
                                    decimalValue=null;
                                }
                                system.debug('double>>'+fieldtype); 
                            }
                            
                            newRecord.put(header,decimalValue);
                        }
                        
                        else if(fieldType==Schema.DisplayType.Integer){
                            if(field.equals('""')){
                                newRecord.put(header,null);
                            }
                            else{
                                if(String.isNotBlank(field)){
                                    newRecord.put(header,Integer.valueOf(field));
                                }
                                else{
                                    newRecord.put(header,null);
                                }
                            }
                        }
                        else if(fieldType==Schema.DisplayType.REFERENCE){
                            Id referenceId;
                            if(field.equals('""')){
                                referenceId=null;
                            }
                            else{
                                if(field !=null && field.startsWith('"') && field.endsWith('"')){
                                    field=field.substring(1,field.length()-1);
                                }
                                if(String.isNotBlank(field) ){
                                    system.debug('reference is not blank');
                                    system.debug(field);
                                    referenceId=Id.valueOf(field);
                                }
                                else{
                                    referenceId=null;
                                }
                            }
                            newRecord.put(header,referenceId);
                        }
                        else if(fieldType==Schema.DisplayType.Date){
                            
                            if(String.isNotBlank(field)){
                                system.debug('fieldType   '+fieldType);
                                String dateString = String.valueof(field);
                                String[] dateParts = dateString.split('/');
                                system.debug('dateparts  '+dateparts);
                                system.debug('size>>>>>>'+dateParts.size());
                                system.debug('parts'+dateParts[0]);
                                if(dateParts.size()>1){
                                    system.debug(dateParts[0]+' '+dateParts[1]+' '+dateParts[2]);
                                    Integer month = Integer.valueOf(dateParts[0]);
                                    Integer day = Integer.valueOf(dateParts[1]);
                                    Integer year = Integer.valueOf(dateParts[2]);
                                    system.debug(month+'  '+day+'   '+year);
                                  //  String formattedDateString = String.format('%04d-%02d-%02d', year, month, day);
                                    Date convertedDate = Date.valueOf(year+'-'+month+'-'+day);
                                    //date mydate=Date.valueOf('2001-01-01');
                                    //Date convertedDate = Date.valueOf(field.replace('/', '-'));
                                   /* system.debug('DateValue  '+field);
                                     Date dateValue = Date.valueOf(field);       //  should be commented
                                        system.debug('datevalue   '+dateValue);*/
                                   // newRecord.put(header,convertedDate);
                                    newRecord.put(header,convertedDate);
                                }
                                if(dateParts.size()==1){
                                     newRecord.put(header,date.valueOf(field));
                                }
                            }
                            else{
                                newRecord.put(header,null);
                            }
                        }
                        else{
                            if(field!=null){
                                newRecord.put(header,field);
                            }
                            else{
                                newRecord.put(header,null);
                            }
                            
                        }
                    }
                }
                
    
                recordsToUpsert.add(newRecord);
                }
            }
    
            if (!recordsToUpsert.isEmpty()) {
                    system.debug('recordsToUpsert>>>>>>>>>');
                    system.debug(recordsToUpsert);
                //Schema.SObjectField ftoken = Account.Fields.Account_Unique_Number__c;
                    Database.upsertResult[] upsertResults = Database.upsert(recordsToUpsert,false);
                
                system.debug('size'+upsertResults.size());
                    totalRecords=upsertResults.size();
                    for (Database.upsertResult result : upsertResults) {
                    if (result.isSuccess()) {
                    
                        if(result.isCreated()){
                            system.debug('created');
                            createdRecords = createdRecords+1;
                        }
                        else{
                            system.debug('updated');
                            updatedRecords = updatedRecords+1;
                        }
                        // Handle successful upsert
                        //system.debug(result.getId());
                        system.debug('success');
                    } else {
                        for (Database.Error error : result.getErrors()) {
                            system.debug('error'+error.getMessage());
                            recordsNotProcessed = recordsNotProcessed+1;
                        }
                    }
                }
                recordProcessed.put('totalRecords',totalRecords);
                recordProcessed.put('updatedRecords',updatedRecords);
                recordProcessed.put('createdRecords',createdRecords);
                recordProcessed.put('recordsNotProcessed',recordsNotProcessed);
            }
            system.debug('created>>>>>'+createdRecords);
            system.debug('updated>>>>>>>>>>'+updatedRecords);
            system.debug('Total>>>>.'+totalRecords);
            system.debug('Map>>>>');
            system.debug(recordProcessed);
           // return recordProcessed;
    }
        }
}
       
}