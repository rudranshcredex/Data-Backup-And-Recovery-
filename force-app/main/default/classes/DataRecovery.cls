/*
 		@Developer Name => Nikhil Garg
		@description => This class is use to create Data Recovery request.
*/

public With Sharing class DataRecovery {
    
    Public class objectsDataWrapper{
        @AuraEnabled
        Public String objectName{get;set;}
        @AuraEnabled
        Public List<String> ExternalIdField{get;set;}
        @AuraEnabled
        Public String csvData{get;set;}
    }
   
    Public class ObjectsJobIdCSVWrapper{
        Public String objectName;
        Public String jobId;
        Public Blob csvData;  
        Public String DmlType;
    }
    
    Public class ObjectsExternalIdCSVWrapper{
        Public String objectName;
        Public String ExternalId;
        Public Blob csvData;  
    }
    
    Public class objectsWithJobIdsDmlTypesWrapper{
        @AuraEnabled
        Public String objectName{get;set;}
        @AuraEnabled
        Public String DmlType{get;set;}
        @AuraEnabled
        Public String jobId{get;set;} 
    }
    
    
     /*
@description => This method is use to upload file and returnig objects to perform Insert or upsert
*/
    @auraEnabled
    Public static List<objectsDataWrapper> uploadZipFile(String FileData)
    {
        
        List<String> objectsInZip = new List<String>();
        Map<String,String> objectsWithCsvData = new Map<String,String>();
        List<objectsDataWrapper> objectDataWrapperList = new List<objectsDataWrapper>();   
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe(); 
        
        Zippex myzip= new Zippex(EncodingUtil.base64Decode(FileData));
        
        for(String fileName: myzip.getFileNames())
        {
            List<string> objectName = fileName.split('\\.');            
            objectsInZip.add(objectName[0]);
            objectsWithCsvData.put(objectName[0],myzip.getFile(fileName).toString());
        }
        
        for(String objectApiname: objectsInZip)
        {            
            objectsDataWrapper objectData = new objectsDataWrapper();
            
            List<String> ExternalIdFields = new List<String>();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectApiname).getDescribe().fields.getMap();
            
            
            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                if (fieldDescribe.isExternalId()) { 
                    ExternalIdFields.add(fieldName);                   
                }
            }
            if(ExternalIdFields.size()==0){
                objectData.objectName = objectApiname;
                objectData.ExternalIdField = new List<String>{''};
                    objectData.csvData = objectsWithCsvData.get(objectApiname);
                
            }
            else{
                objectData.objectName = objectApiname;
                objectData.ExternalIdField = ExternalIdFields;
                objectData.csvData = objectsWithCsvData.get(objectApiname);
            }
            objectDataWrapperList.add(objectData);
        }
        return objectDataWrapperList;
    }
    
    
       /*
@description => This method is use to create Insert request using Bulk API
*/
    @auraEnabled
    Public static String performInsert(String objectsToInsert){
        try{
            List<Object> objectsList = (List<Object>)JSON.deserializeUntyped(objectsToInsert);
            
            for(integer i=0;i<objectsList.size();i=i+100)
            {                
                Map<String,Blob> objectsWithData = new Map<String,Blob>();
                for(integer j=i;j<100+i && j<objectsList.size();j++)
                { 
                    Map<String,object> objectdata = (Map<string,object>)objectsList[j];
                    objectsWithData.put((String)objectdata.get('objectName'),blob.valueOf((String)objectdata.get('CsvData')));
                }
                system.debug('objectWithData');
                system.debug(objectsWithData);
                DataRecoveryCallout.createInsertJob(objectsWithData);
            }    
            
            Datetime sysTime;
            if(objectsList.size()<=10){
                sysTime = System.now().addminutes(2);
            }
            else if(objectsList.size()<100){
                sysTime = System.now().addminutes(10);
            }
            else if(objectsList.size()>100){
                sysTime = System.now().addminutes(20);
            }
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            system.schedule('Salesforce Data Recovery(Insert)'+System.now(), chronExpression, new scheduleDataRecovery()); 
            
        }
        catch(Exception ex){
            throw new  AuraHandledException(ex.getmessage());
        }
        return 'insert Operation created Successfully';
    }
    
    
     /*
@description => This method is use to create Upsert request using Bulk API
*/
    @auraEnabled
    Public static String performUpsert(String objectsToUpsert)
    {
        system.debug(objectsToUpsert);
        List<ObjectsExternalIdCSVWrapper> ObjectsExternalIdCSVWrapperList = new List<ObjectsExternalIdCSVWrapper>();
        List<Object> objectsList = (List<Object>)JSON.deserializeUntyped(objectsToUpsert);
        
        for(integer i=0;i<objectsList.size();i=i+100)
        {                
            for(integer j=i;j<100+i && j<objectsList.size();j++)
            { 
                Map<String,object> objectdata = (Map<string,object>)objectsList[j];
                ObjectsExternalIdCSVWrapper objectsDataWrapper = new ObjectsExternalIdCSVWrapper();
                objectsDataWrapper.objectName = (String)objectdata.get('objectName');
                objectsDataWrapper.ExternalId = (String)objectdata.get('externalId');
                objectsDataWrapper.csvData = blob.valueOf((String)objectdata.get('csvData'));
                ObjectsExternalIdCSVWrapperList.add(objectsDataWrapper);
            }
            if(ObjectsExternalIdCSVWrapperList.size()>0){
                system.enqueueJob(new QueueableRecovery(ObjectsExternalIdCSVWrapperList,'createUpsertJob'));
            }
        }    
        
        Datetime sysTime = System.now().addSeconds( 60 );
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
       system.schedule('Salesforce Data Recovery(Upsert)'+System.now(), chronExpression, new scheduleDataRecovery());   
        return 'upsert Operation created Successfully';
    }
}