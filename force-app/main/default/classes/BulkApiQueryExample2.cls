public class BulkApiQueryExample2 {

    
    
    @future(callout=true)
    public static void createBulkJob(String objectApiName) {
        String endpoint = 'https://credextechnology13-dev-ed.develop.my.salesforce.com/services/data/v58.0/jobs/ingest';
        Map<String, Object> jobRequest = new Map<String, Object>{
            'operation' => 'insert',
            'object' => objectApiName,
            //'externalIdFieldName' => 'Id', // Specify 'Id' as the external ID field
            'contentType' => 'CSV',
            'lineEnding'=> 'LF'
        };
        
        String requestBody = JSON.serialize(jobRequest);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);
        
        
        HttpResponse response = new Http().send(request);
        system.debug('response>>>>>>>>>>>>>>>'+response);
        system.debug(response.getBody());
      /*  Map<String, Object> jobResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        system.debug('jobResponse>>>>>>>>>>>>>');
        system.debug(jobResponse);*/
        //return (String) jobResponse.get('id');
    }
    
    public static void UploadJobData(String jobId, String csvData) {
        
        set<Id> LinkedIds= new set<Id>();
        for(ContentDocumentLink link: [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId=:userinfo.getUserId()]){
                LinkedIds.add(link.ContentDocumentId);
        }
        
        ContentVersion versions=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId = :LinkedIds and Title='batch 0.zip' limit 1];
       // ContentVersion versions=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId = :LinkedIds and Title='ContactCopy2' limit 1];
       // List<String> IdsToDelete = new List<String>();
       Zippex myzip= new Zippex(versions.VersionData);
        
        blob data;
        for(String fileName: myzip.getFileNames())
        { 	data = myzip.getFile(fileName);
         system.debug(data.toString());
         system.debug(data);
         system.debug(fileName);
            
        }
       // system.debug(versions.VersionData);
        //blob testData = versions.VersionData;
        //system.debug(testData.toString());
        String endpoint = 'https://credextechnology13-dev-ed.develop.my.salesforce.com/services/data/v58.0/jobs/ingest/' + jobId + '/batches';
        
        
        String vfContent =Page.getSessionId.getContent().toString();
         Integer startPosition = vfContent.indexOf('Start') + 'Start'.length();
         Integer endPosition = vfContent.indexOf('End');
         String sSessionId = vfContent.substring(startPosition, endPosition);
         //service.SessionHeader.sessionId = sSessionId;
        
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('PUT');
        request.setHeader('Authorization', 'Bearer ' + userinfo.getSessionId());
        request.setHeader('Content-Type', 'text/csv');
        //request.setBody(csvData);
        request.setBodyAsBlob(data);
        HttpResponse response = new Http().send(request);
        system.debug('response>>>>>>>>>>>>>>>');
        system.debug(response);
        /*system.debug('body');
        system.debug(response.getBody());*/
        /*String locationHeader = response.getHeader('Location');
    	String batchId = locationHeader.substringAfterLast('/'); // Extract the last part of the URL
		system.debug('batchId>>>>>>>>>>>>');
        system.debug(batchId);*/
        // Handle response as needed
    }
    
    public static void closeOrAbortJob(String jobId) {
        String endpoint = 'https://credextechnology13-dev-ed.develop.my.salesforce.com/services/data/v58.0/jobs/ingest/' + jobId;
        string body = '{"state":"UploadComplete"}';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('PATCH');
        request.setHeader('Content-Type', 'application/json; charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setBody(body);
        HttpResponse response = new Http().send(request);
        String responseBody = response.getBody();
        system.debug('response>>>>>>');
        system.debug(response);
       /* system.debug(response);
        system.debug(response.getBody());*/
        // Process the batch status response as needed
    }
    
    public static void checkBatchStatus(String jobId) {
        String endpoint = 'https://credextechnology13-dev-ed.develop.my.salesforce.com/services/data/v58.0/jobs/ingest/' + jobId;
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json; charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        
        HttpResponse response = new Http().send(request);
        String responseBody = response.getBody();
        system.debug('response>>>>>>');
        system.debug(response);
        system.debug(response.getBody());
        // Process the batch status response as needed
    }
    
    public static void getSuccessFullRecords(String jobId) {
        String endpoint = 'https://credextechnology13-dev-ed.develop.my.salesforce.com/services/data/v58.0/jobs/ingest/' + jobId+'/successfulResults';
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json; charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        
        HttpResponse response = new Http().send(request);
        String responseBody = response.getBody();
        system.debug('response>>>>>>');
        system.debug(response);
        system.debug(response.getBody());
        // Process the batch status response as needed
    }
    
    public static void getFailedRecords(String jobId) {
        String endpoint = 'https://credextechnology13-dev-ed.develop.my.salesforce.com/services/data/v58.0/jobs/ingest/' + jobId+'/failedResults';
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json; charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        
        HttpResponse response = new Http().send(request);
        String responseBody = response.getBody();
        system.debug('response>>>>>>');
        system.debug(response);
        system.debug(response.getBody());
    }
    
    public static void getUnprocessedRecords(String jobId) {
        String endpoint = 'https://credextechnology13-dev-ed.develop.my.salesforce.com/services/data/v58.0/jobs/ingest/' + jobId+'/unprocessedrecords';
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json; charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        
        HttpResponse response = new Http().send(request);
        String responseBody = response.getBody();
        system.debug('response>>>>>>');
        system.debug(response);
        system.debug(response.getBody());
    }
}