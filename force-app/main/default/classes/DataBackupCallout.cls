/*
 		@Developer Name => Nikhil Garg
		@description => This class is use to making a call to Bulk API for dataBackup
*/
public With Sharing class DataBackupCallout {
    
    	//Constants
    Private static Final String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v58.0/jobs/query';
    
    /*
@description => This method will create Bulk query job and return Job Id for every object
*/
    @future(callout=true)
    public static void getQueryJobIds(List<String> ObjectApiNames,String batchName,String fromDate, String ToDate){
      
        String query;
        Map<String,String> jobIdsWithApiNames = new Map<String,String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        try
        { 
            for(String objectApiname: ObjectApiNames)
            {            
                List<String> queryableFieldNames = new List<String>();
                Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectApiname).getDescribe().fields.getMap();
                
                //fields those are accessible in during recovery of records
                for (String fieldName : fieldMap.keySet()) {
                    Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                    if(fieldDescribe.isCreateable() && fieldDescribe.isUpdateable() && fieldDescribe.isAccessible()) {
                        queryableFieldNames.add(fieldName);
                    }             
                }
                if(fromDate!=null && toDate!=null){ 
                    query = 'SELECT ' + String.join(queryableFieldNames, ',') + ' FROM '+objectApiname+' WHERE (DAY_ONLY(CreatedDate)>=\''+fromDate+'\''+' OR DAY_ONLY(CreatedDate) <=\''+ToDate+'\')' ; 
                }
                else{
                    query = 'SELECT ' + String.join(queryableFieldNames, ',') + ' FROM '+objectApiname;
                }
                
                HttpRequest request =  CreateHttpRequest('POST');
                request.setEndpoint(endpointURL);
                request.setBody(JSON.serialize(getJobRequest(query)));
                
                HttpResponse response = new Http().send(request); 
               
                
                if(response.getstatusCode()==200 || response.getstatusCode()==201)
                {
                    Map<String,Object> responseMap = (Map<String,object>)Json.deserializeUntyped(response.getBody());
                    jobIdsWithApiNames.put(objectApiname,(String)responseMap.get('id'));
                }
                else{
                    //system.debug(response.getStatus());
                    //system.debug(response.getStatusCode());
                    //system.debug('faulty Code');
                }     
            }
            
            if(jobIdsWithApiNames.size()>0)
            {
                Datetime sysTime = System.now().addseconds( 10 );
                String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                system.schedule('Salesforce Data Backup'+System.now().addMinutes(1), chronExpression, new ScheduleDataBackup(jobIdsWithApiNames,batchName,'getJobResults'));
            }
        }
        catch(Exception ex){
            //system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
    
    /*
@description => This method fetch the results based on jobIds and store result as a batches in content Version of Salesforce
*/    
    @future(callout=true)
    Public static void getJobResults(Map<String,String> objectWithJobIds,String batchName){
        try
        {
            Zippex sampleZip = new Zippex();
            
            for(string objects:objectWithJobIds.keySet())
            {
                String endpoint = endpointURL+'/'+objectWithJobIds.get(objects)+'/results';
                
                HttpRequest request =  CreateHttpRequest('GET');
                request.setEndpoint(endpoint);
             
                HttpResponse response = new Http().send(request);

                if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                   
                    Blob fileData = Blob.valueOf(response.getBody());
                    sampleZip.addFile(objects+'.csv', fileData, null);
                }
                else{
                    //system.debug('error at 128 with code');
                    //system.debug(response);
                }   
            }  
            Blob zipData = sampleZip.getZipArchive();
            ContentVersion contentVersion = new ContentVersion(
                Title = batchName,
                VersionData = zipData,
                PathOnClient = '/' + batchName+'.zip'
            );
            if (Schema.sObjectType.ContentVersion.isCreateable() && Schema.sObjectType.ContentVersion.isAccessible()) {
            insert contentVersion;
            }else{
                throw new AuraHandledException('Insufficient permissions.');
            }
        }
        catch(Exception ex){
            //system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
    /*
@description => This method is use to fetch zip files from different content versions and create one Zip file  to send the data to AWS or Email as required, also send custom Notification after confirmation 
*/
    @future(callout=true)
    Public static void readZipFiles(List<String> fileNames,String Credentials){
        
        try{
            Map<String,Object> creds = (Map<String,Object>)JSON.deserializeUntyped(credentials);
            string accessKey = (String)creds.get('accessKey');
            String SecretKey = (String)creds.get('SecretKey');
            String Bucket = (String)creds.get('Bucket');
            String awsRegion = (String)creds.get('awsRegion');
            boolean backupTos3 = (boolean)creds.get('backupTos3');
            boolean backupToLocal = (boolean)creds.get('backupToLocal');
            
            Zippex zip= new Zippex();
            
            set<Id> LinkedIds = new set<Id>();
            for(ContentDocumentLink link: [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId=:userinfo.getUserId() WITH SECURITY_ENFORCED LIMIT 10000]){
                LinkedIds.add(link.ContentDocumentId);
            }
         
            List<ContentVersion> versions=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId = :LinkedIds and Title In:fileNames WITH SECURITY_ENFORCED LIMIT 10000];
            List<String> ContentDocumentIdsToDelete = new List<String>();
            for(ContentVersion version: versions)
            {
                
                ContentDocumentIdsToDelete.add(version.ContentDocumentId);
                Zippex myzip= new Zippex(version.VersionData);
                
                for(String fileName: myzip.getFileNames())
                {
                    String fileData= myzip.getFile(fileName).toString();
                    zip.addFile(fileName, myzip.getFile(fileName), null);
                }
            }

            List<contentDocument> ContentDocumentIds= [select id from contentDocument where id In:ContentDocumentIdsToDelete WITH SECURITY_ENFORCED LIMIT 10000];
            if(backupTos3){
                
                String response = AwsS3Integration.filePUT('SalesforceData_'+fetchCurrentFormattedDate(), accessKey, secretKey, awsRegion, Bucket, zip.getZipArchive());
                if(response =='success'){
                    EmailAndNotification.sendCustomNotification('Data','Aws');
                    if(ContentDocumentIds.size()>0){
                        if(Schema.sObjectType.ContentDocument.isAccessible() && Schema.sObjectType.ContentDocument.isDeletable()){
                        	delete contentDocumentIds;
                        }
                    }
                }
            }
            if(backupToLocal){
                if(ContentDocumentIds.size()>0)
                {
                    if(Schema.sObjectType.ContentDocument.isAccessible() && Schema.sObjectType.ContentDocument.isDeletable()){
                        	delete contentDocumentIds;
                        }
                }
                String EmailStatus = EmailAndNotification.sendEmailToCurrentUser(zip.getZipArchive(), 'Data');
                if(EmailStatus == 'Success'){
                    EmailAndNotification.sendCustomNotification('Data','Local');   
                }
            }
        }
        catch(Exception ex){
            //system.debug(ex.getMessage()+'at '+ex.getLineNumber());
        }
    }
    
    /*
@description => This method is use to create job request for Bulk api
*/
    Private static Map<String, Object> getJobRequest(String query){
        Map<String, Object> jobRequest = new Map<String, Object>{
            'operation' => 'query',
                'query' => query
                };
                    return jobRequest;
    }
    
      /*
@description => This method is use to create Http request for Bulk api
*/
    private static HttpRequest CreateHttpRequest(String method){
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setHeader('Authorization', 'Bearer ' + userinfo.getSessionId());
        request.setHeader('Content-Type', 'application/json');
        //    request.setBody(requestBody);
        
        return request;
    }
    
    
      /*
@description => This method is use fetch current Date format to Upload files at Aws S3
*/
    Private static String fetchCurrentFormattedDate(){
        DateTime now = DateTime.now();
        Date currentDate = now.date();
        String formattedDate = currentDate.year() + '-' +
        String.valueOf(currentDate.month()).leftPad(2, '0') + '-' +
        String.valueOf(currentDate.day()).leftPad(2, '0');
        formattedDate+= 'T'+now.hour()+'h.'+now.minute()+'m.'+now.second()+'s';
        return formattedDate;
    }
    
}