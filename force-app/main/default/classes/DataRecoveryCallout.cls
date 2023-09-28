/*
@Developer Name => Nikhil Garg
@description => This class is use to perform Data Recovery request using Bulk Api.
*/

public With sharing class DataRecoveryCallout {
    
    //Constants
    Private static Final String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v58.0/jobs/ingest';
    
    
    /*
@description => This method is use to create Insert request using Bulk API and fetching JobIds
*/
    @future(callout=true)
    public static void createInsertJob(Map<String,Blob> objectWithData) {
        try{
            List<DataRecovery.ObjectsJobIdCSVWrapper> ObjectsJobIdCSVWrapperList = new List<DataRecovery.ObjectsJobIdCSVWrapper>();
            List<String> objectApiNames = new List<String>(objectWithData.keyset());
            for(String objectApiName:objectApiNames)
            {
                String endpoint = endpointURL;
                String requestBody = JSON.serialize(getJobRequestForInsert(objectApiName));
                
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                request.setHeader('Content-Type', 'application/json');
                request.setBody(requestBody);
                HttpResponse response = new Http().send(request);
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201)
                {
                    Map<String, Object> jobResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    
                    DataRecovery.ObjectsJobIdCSVWrapper objWrapper = new DataRecovery.ObjectsJobIdCSVWrapper();
                    objWrapper.objectName = objectApiName;
                    objWrapper.jobId = (String)jobResponse.get('id');
                    objWrapper.csvData = objectWithData.get(objectApiName);
                    objWrapper.DmlType ='insert';
                    ObjectsJobIdCSVWrapperList.add(objWrapper);
                }
                else{
                    system.debug('Fault response');
                    system.debug(response);
                    system.debug(response.getBody());
                }
            }
            
            if(ObjectsJobIdCSVWrapperList.size()>0){
                system.enqueueJob(new QueueableRecovery(ObjectsJobIdCSVWrapperList,'UploadData'));
            }  
            
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
    
    /*
@description => This method is use to create Upsert request using Bulk API and fetching JobIds
*/
    public static void createUpsertJob(List<DataRecovery.ObjectsExternalIdCSVWrapper> objectsWithExternalIdAndCsv) {
        
        try{
            List<DataRecovery.ObjectsJobIdCSVWrapper> ObjectsJobIdCSVWrapperList = new List<DataRecovery.ObjectsJobIdCSVWrapper>();
            
            for(DataRecovery.ObjectsExternalIdCSVWrapper objects:objectsWithExternalIdAndCsv)
            {
                String endpoint = endpointURL;
                String requestBody = JSON.serialize(getJobRequestForUpsert(objects.objectName,objects.ExternalId));
                
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                request.setHeader('Content-Type', 'application/json');
                request.setBody(requestBody);
                HttpResponse response = new Http().send(request);
                
                
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201)
                {
                    Map<String, Object> jobResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    
                    DataRecovery.ObjectsJobIdCSVWrapper objWrapper = new DataRecovery.ObjectsJobIdCSVWrapper();
                    objWrapper.objectName = objects.objectName;
                    objWrapper.jobId = (String)jobResponse.get('id');
                    objWrapper.csvData = objects.csvData;
                    objWrapper.DmlType = 'upsert';
                    ObjectsJobIdCSVWrapperList.add(objWrapper);
                    
                }
                else{
                    system.debug('Fault response');
                    system.debug(response);
                    system.debug(response.getBody());
                }
            }
            
            if(ObjectsJobIdCSVWrapperList.size()>0 ){
                system.enqueueJob(new QueueableRecovery(ObjectsJobIdCSVWrapperList,'UploadData'));
            }     
            
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
    
    
    
    /*
@description => This method is use to upload data to recover based on jobIds
*/
    public static void UploadJobData(List<DataRecovery.ObjectsJobIdCSVWrapper> objectsWithJobIdsAndcsv) {
        
        try{
            List<DataRecovery.objectsWithJobIdsDmlTypesWrapper> objectsWithJobIdsList = new List<DataRecovery.objectsWithJobIdsDmlTypesWrapper>();
            set<Id> LinkedIds= new set<Id>();
            
            for(DataRecovery.ObjectsJobIdCSVWrapper objWrapper : objectsWithJobIdsAndcsv)
            {
                String endpoint = endpointURL+'/' + objWrapper.jobId + '/batches';
                
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('PUT');
                request.setHeader('Authorization', 'Bearer ' + userinfo.getSessionId());
                request.setHeader('Content-Type', 'text/csv');
                request.setBodyAsBlob(objWrapper.csvData);
                HttpResponse response = new Http().send(request);
                
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201)
                {                   
                    
                    DataRecovery.objectsWithJobIdsDmlTypesWrapper JobIdWrapper = new DataRecovery.objectsWithJobIdsDmlTypesWrapper();
                    JobIdWrapper.jobId = objWrapper.jobId;
                    JobIdWrapper.objectName = objWrapper.objectName;
                    JobIdWrapper.DmlType =  objWrapper.DmlType;
                    objectsWithJobIdsList.add(JobIdWrapper);
                }
                else{
                    system.debug('error');
                    system.debug('unExpected');
                }
            }
            
            if(objectsWithJobIdsList.size()>0){
                closeOrAbortJob(JSON.serialize(objectsWithJobIdsList));
            }
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
    
    
    /*
@description => This method is use to mark a job as completed or Aborted.
*/
    @future(Callout=true)
    public static void closeOrAbortJob(String objectsWithJobIds) {
        
        try{
            List<DataRecovery.objectsWithJobIdsDmlTypesWrapper> objectsWithJobIdsWithDml = (List<DataRecovery.objectsWithJobIdsDmlTypesWrapper>) JSON.deserialize(objectsWithJobIds, List<DataRecovery.objectsWithJobIdsDmlTypesWrapper>.class);
            system.debug('inside close abort');
            List<DataRecovery.objectsWithJobIdsDmlTypesWrapper> objectsWithDmlTypes = new List<DataRecovery.objectsWithJobIdsDmlTypesWrapper>();
            
            for(DataRecovery.objectsWithJobIdsDmlTypesWrapper objects:objectsWithJobIdsWithDml)
            {
                
                String endpoint = endpointURL+'/' + objects.jobId;
                
                string body = '{"state":"UploadComplete"}';
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('PATCH');
                request.setHeader('Content-Type', 'application/json; charset=UTF-8');
                request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                request.setBody(body);
                HttpResponse response = new Http().send(request);
                if(response.getStatusCode()==201 || response.getStatusCode()==200){
                    DataRecovery.objectsWithJobIdsDmlTypesWrapper JobIdWrapper = new DataRecovery.objectsWithJobIdsDmlTypesWrapper();
                    JobIdWrapper.jobId = objects.jobId;
                    JobIdWrapper.objectName = objects.objectName;
                    JobIdWrapper.DmlType =  objects.DmlType;
                    objectsWithDmlTypes.add(JobIdWrapper);
                }
                else{
                    system.debug(response);
                    system.debug('error');
                    system.debug(response.getBody());
                }
            }
            
            if(objectsWithDmlTypes.size()>0){
                system.enqueueJob(new QueueableRecovery(JSON.serialize(objectsWithDmlTypes),'checkBatchStatus'));
            }
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
    
    /*
@description => This method is use to check status of the jobs proceessed whether it's completed or not
*/
    @future(Callout=true)
    public static void checkBatchStatus(String objectsWithJobIds) {
        system.debug('inside check status');
        system.debug(objectsWithJobIds);
        try 
        {   String csvContent = 'objectName,numberRecordsProcessed,numberRecordsFailed,DmlType\n';
         List<DataRecovery.objectsWithJobIdsDmlTypesWrapper> objectsWithJobIdsWithDml = (List<DataRecovery.objectsWithJobIdsDmlTypesWrapper>) JSON.deserialize(objectsWithJobIds, List<DataRecovery.objectsWithJobIdsDmlTypesWrapper>.class);
         
         for(DataRecovery.objectsWithJobIdsDmlTypesWrapper objects:objectsWithJobIdsWithDml)
         {
             String endpoint = endpointURL+'/' +  objects.jobId;
             
             HttpRequest request = new HttpRequest();
             request.setEndpoint(endpoint);
             request.setMethod('GET');
             request.setHeader('Content-Type', 'application/json; charset=UTF-8');
             request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
             
             HttpResponse response = new Http().send(request);
             
             if(response.getStatusCode()==201 || response.getStatusCode()==200)
             {  
                 Map<String,object> responseResult = (Map<String,object>)JSON.deserializeUntyped(response.getBody());
                 
                 csvContent+= objects.objectName +','+responseResult.get('numberRecordsProcessed')+','+responseResult.get('numberRecordsFailed')+','+objects.DmlType+'\n'; 
             }
             else{
                 system.debug('error');
                 system.debug(response);
                 system.debug(response.getBody());
             }
         }
         system.debug(csvContent);
         ContentVersion newContentVersion = new ContentVersion();
         newContentVersion.Title = 'Data recovery'; // Set the file title
         newContentVersion.PathOnClient = 'Datarecovery.csv'; // Set the file name
         newContentVersion.VersionData = Blob.valueOf(csvContent);
         Database.SaveResult  result = Database.insert(newContentVersion);
        }
        catch(Exception ex)
        {
            system.debug(ex.getmessage()+' at '+ex.getLineNumber());
        }
    }
    
    
    /*
@description => This method is creating Job request for Insert Jobs
*/
    
    Private static Map<String, Object> getJobRequestForInsert(String objectApiName)
    {
        Map<String, Object> jobRequest = new Map<String, Object>{
            'operation' => 'insert',
                'object' => objectApiName,
                'contentType' => 'CSV',
                'lineEnding'=> 'LF'
                };
                    return jobRequest;
    }
    
    
    /*
@description => This method is creating Job request for Upsert Jobs
*/
    Private static Map<String, Object> getJobRequestForUpsert(String objectApiName,String ExternalIdField)
    {
        Map<String, Object> jobRequest = new Map<String, Object>{
            'operation' => 'upsert',
                'object' => objectApiName,
                'externalIdFieldName' => ExternalIdField,
                'contentType' => 'CSV',
                'lineEnding'=> 'LF'
                };
                    system.debug('jobRequest');
        system.debug(jobRequest);
        return jobRequest;
    }
}