/*
    @description => This class is use to Retrive and send Metadata zip
    */
public With Sharing class MetadataRetriever {
    
    Public static Map<String, Blob> xmlBlobData {get;set;}
    
    Public static List<Map<String,List<Map<String, object>>>> asyncVariable=new List<Map<String,List<Map<String, object>>>>();
    
    
    
        /*
         @description => This method is used to fetch all the Metadata Types of Current Org
    */
    @auraEnabled(cacheable=true)
    Public static List<MetadataWrapper> getMetaDataTypes(){ 
        system.debug('inisde get types');
        List<String> metadataTypes = new List<String>();
        List<MetadataWrapper> metadataComponentWrraper = new List<MetadataWrapper>();
        Integer objectIndex = 1;
        try{
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = getSessionId();
            //service.SessionHeader.sessionId = userinfo.getSessionId();
            MetadataService.DescribeMetadataResult describeMetadataResult = service.describeMetadata((double)58.0);
            //system.debug('describeMetadataResult');
           // system.debug(describeMetadataResult);
           system.debug('result of metadata');
            system.debug(describeMetadataResult.metadataObjects);
            for (MetadataService.DescribeMetadataObject objects : describeMetadataResult.metadataObjects)
            {
                system.debug('object');
                system.debug(objects);
                metadataTypes.add(objects.xmlName);
            }
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
        List<String> metadataComponents = new List<String>(metadataTypes);
        metadataComponents.sort();
        for(String metadata:metadataComponents)
        {
            MetadataWrapper metadataComponent = new MetadataWrapper();
            metadataComponent.metadataType = metadata;
            metadataComponent.isSelected = false;
            metadataComponent.objectId = objectIndex;
            objectIndex++;
            
            metadataComponentWrraper.add(metadataComponent);
        }
        return metadataComponentWrraper;
        
    }
    
        /*
    	  @description => This method is used to schedule Metadata backup Process at given date
    */
    @auraEnabled(cacheable=true)
    Public static void ScheduleMetaDataBackup(List<String> metadataTypes,String credentials,String scheduleDate){
        Datetime dateTimeValue = Datetime.newInstanceGmt(Integer.valueOf(scheduleDate.substring(0, 4)), Integer.valueOf(scheduleDate.substring(5, 7)), Integer.valueOf(scheduleDate.substring(8, 10)),
                                                         Integer.valueOf(scheduleDate.substring(11, 13)), Integer.valueOf(scheduleDate.substring(14, 16)), Integer.valueOf(scheduleDate.substring(17, 19)));
        //System.debug(dateTimeValue);
        integer scheduleDay = dateTimeValue.day();
        integer scheduleMonth = dateTimeValue.month();
        integer scheduleYear = dateTimeValue.year();
        integer scheduleHour = dateTimeValue.hour();
        integer scheduleMinute = dateTimeValue.minute();
        
        String CRON_EXPRESSION = '0 '+scheduleMinute+' '+scheduleHour+' '+scheduleDay+' '+scheduleMonth+' ? '+scheduleYear;   
        system.debug(CRON_EXPRESSION);
        system.debug('creds');
        system.debug(credentials);
        //System.schedule('Scheduled MetaData Backup'+system.now(), CRON_EXPRESSION, new ScheduleMetadataBackup(metadataTypes, credentials));
    }
    
    
    /*
    		@description => This method is used to call retrieve method and execute from schedular class when Schedule Metadata Backup is called
    */
    @future(callout=true)
    Public static void callRetrieveMethod(List<String> metadataTypes,string credentials){
        retreive(metadataTypes,credentials);
    }
    
    /*
    		@description => This method is used to make a call of retrieve() and fetch asyncJobId and schedule call to checkRetrieveStatus() Method by calling scheduleMetadataRetrieveStatus class
    */
    @auraEnabled
    public static String retreive(List<String> metadataTypes,string credentials){
        String response;
        String asyncRequestId;
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = getSessionId();
        MetadataService.RetrieveRequest request = new MetadataService.RetrieveRequest();
        request.apiVersion = 58.0; 
        request.singlePackage = true; 
        request.unpackaged = new MetadataService.Package_x();
        
        List<MetadataService.PackageTypeMembers> typeMembersList = new List<MetadataService.PackageTypeMembers>();
        
        for(String metadataType:metadataTypes){
            MetadataService.PackageTypeMembers objectMember = new MetadataService.PackageTypeMembers();
            if(metadataType =='CustomObject'){
                continue;
            }
            objectMember.name = metadataType;
            objectMember.members = new String[] { '*' };
                typeMembersList.add(objectMember);
        }
        if(metadataTypes.contains('CustomObject')){
            for(String objectName : getObjectNames()) 
            {
                MetadataService.PackageTypeMembers objectMember = new MetadataService.PackageTypeMembers();
                objectMember.name = 'CustomObject';
                objectMember.members = new String[] { objectName };
                    typeMembersList.add(objectMember);
            }
        }
        request.unpackaged.types = typeMembersList;  
        try{
            
            MetadataService.AsyncResult result = service.retrieve(request);
            asyncRequestId = result.id;
            string asyncResultId =result.id;
            if(result.id!=null){
                response ='Success';
            }
             Datetime sysTime;
            if(metadataTypes.size()<10){
             sysTime = System.now().addminutes( 1 ); 
            }
            if(metadataTypes.size()>10){
             sysTime = System.now().addminutes( 7 ); 
            }
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            
            system.schedule('MetadataRetreiveCheckStatus '+System.now(), chronExpression, new scheduleMetadataRetrieveStatus(asyncRequestId,credentials));
            if (result.done) {
                system.debug('done');
                
            } else {
                system.debug('Retrieve is still in progress, you can check result.status to track progress');
            }
            
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getmessage());
        }
        return response;
    }
    
    
    /*
    		@description => This method is used to make a call to checkRetrieveStatus() and called from  scheduleMetadataRetrieveStatus class
    */
    @future(callout=true)
    public static void checkRetrieveStatus(string asyncResultId,String credentials){
        
        Map<String,Object> creds=(Map<String,Object>)JSON.deserializeUntyped(credentials);
        string accessKey = (String)creds.get('accessKey');
        String SecretKey = (String)creds.get('SecretKey');
        String Bucket = (String)creds.get('Bucket');
        String awsRegion = (String)creds.get('awsRegion');
        boolean backupTos3 = (boolean)creds.get('backupTos3');
        boolean backupToLocal = (boolean)creds.get('backupToLocal');
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = userinfo.getSessionId();
        Map<String,String> responseMessage = new Map<String,String>();
        
        string response;
        MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(asyncResultId, true);
        if(retrieveResult.done){
            if (retrieveResult.success)
            {
                blob zipBlob = EncodingUtil.base64Decode(retrieveResult.zipFile);
                string zipLength = retrieveResult.zipFile; 
                String currentDateTime = DateTime.now().format('yyyy/MM/dd hh:mm:ss');
                DateTime now = DateTime.now();
                Date currentDate = now.date();
                String formattedDate = currentDate.year() + '-' +
                      String.valueOf(currentDate.month()).leftPad(2, '0') + '-' +
                      String.valueOf(currentDate.day()).leftPad(2, '0');
                if(backupTos3){
                    if(accessKey!=null && SecretKey!=null && Bucket!=null && awsRegion!=null){
                        String AwsResponse = AwsS3Integration.filePUT('SalesforceMetaData_'+formattedDate, accessKey, secretKey, awsRegion, Bucket, zipBlob);
                        if(AwsResponse =='success')
                        {
                            EmailAndNotification.sendCustomNotification('Metadata','Aws');
                        }
                    }
                }
                if(backupToLocal){
                    String EmailStatus = EmailAndNotification.sendEmailToCurrentUser(zipBlob, 'MetaData');
                    if(EmailStatus =='Success'){
                        EmailAndNotification.sendCustomNotification('Metadata','Local');
                    }   
                }
                
                
                Attachment attachment = new Attachment();
                attachment.ParentId = '0015i00000oYvsvAAC'; 
                attachment.Name = 'Salesforce Metadata('+currentDateTime+')'+'.zip'; 
                attachment.Body = zipBlob;
                try {
                    insert attachment;
                    System.debug('Attachment created successfully.');
                    response='success';
                    responseMessage.put('success',retrieveResult.zipFile);
                    
                } catch (Exception ex) {
                    response='error';
                    responseMessage.put('error',ex.getMessage()+' at '+ex.getLineNumber());
                    System.debug('Error creating attachment: ' + ex.getMessage());
                }                        
            } else {                        
                String errorMessage = retrieveResult.errorMessage;  
                response = 'not yet';
                responseMessage.put('not yet retrieved','no data yet');
            }
        }
    }
    
    /*
    		@description => This method is fetch object names from using Metadata service class
    */
    Private static List<String> getObjectNames()
    {
        List<String> objectNames = new List<String>();
        for (Schema.SObjectType objectType : Schema.getGlobalDescribe().values()) {
            objectNames.add(objectType.getDescribe().getName());
        }
        return objectNames;
    }
    
    /*
    		@description => Wrraper class use to make response for LWC Component
    */
    public class MetadataWrapper{
        @AuraEnabled
        public Boolean isSelected;
        @AuraEnabled
        public String metadataType;
        @AuraEnabled
        public Integer objectId;    
    }
    
    /*
    		@description => This method is use to fetch session Id from vf page as in LWC Component we can't use userinfo.getSessionId()
    */
    Private static String getSessionId(){
        String vfContent =Page.getSessionId.getContent().toString(); 
        Integer startPosition = vfContent.indexOf('Start') + 'Start'.length();
        Integer endPosition = vfContent.indexOf('End');
        String SessionId = vfContent.substring(startPosition, endPosition);
        return SessionId;
    }
}