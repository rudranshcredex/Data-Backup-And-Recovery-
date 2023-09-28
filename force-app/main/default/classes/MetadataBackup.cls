/*
@Developer Name => Nikhil Garg
@description => This  class is use to Create  Request for Metadata Backup
*/
public With sharing class MetadataBackup {
    
    //constants
    private static final String API_VERSION = '58.0';
    Private static final String ENDPOINT_URL = url.getOrgDomainUrl().toExternalForm();
    private static final String SESSION_ID = userinfo.getSessionId();
    
    
    
    /*
@description => This method is use to Schedule Metadata Backup at schedule time chosen by the user
*/
    @auraEnabled(cacheable=true)
    Public static void ScheduleMetaDataBackup(List<String> metadataTypes,String credentials,String scheduleDate){
        
        Datetime dateTimeValue = Datetime.newInstanceGmt(Integer.valueOf(scheduleDate.substring(0, 4)), Integer.valueOf(scheduleDate.substring(5, 7)), Integer.valueOf(scheduleDate.substring(8, 10)),
                                                         Integer.valueOf(scheduleDate.substring(11, 13)), Integer.valueOf(scheduleDate.substring(14, 16)), Integer.valueOf(scheduleDate.substring(17, 19)));
        integer scheduleDay = dateTimeValue.day();
        integer scheduleMonth = dateTimeValue.month();
        integer scheduleYear = dateTimeValue.year();
        integer scheduleHour = dateTimeValue.hour();
        integer scheduleMinute = dateTimeValue.minute();
        
        String CRON_EXPRESSION = '0 '+scheduleMinute+' '+scheduleHour+' '+scheduleDay+' '+scheduleMonth+' ? '+scheduleYear;   
        System.schedule('Scheduled MetaData Backup'+system.now(), CRON_EXPRESSION, new ScheduleMetadataBackup(metadataTypes, credentials,'schedule Backup'));
    }
    
    
    
    /*
@description => This method is called by Lwc component which is then making a retrieve method.
*/
    @AuraEnabled(Cacheable=true)
    Public static void retrieveMetadata(List<String> metadataTypes,String credentials){
        retrieve(metadataTypes,Credentials);
    }
    
    
    /*
@description => This method is use to make a retrieve call to Metadata Api.
*/
    @future(callout=true)
    public static void retrieve(List<String> metadataTypes,String Credentials){
        string AsyncResultId  =null;
        try{
            Http http = new Http();
            HttpRequest request = createJobRequest();
            request.setBody(generateEnvelopeForRetrieve(metadataTypes));
            HttpResponse response = http.send(request);
            if(response.getStatusCode()==200 || response.getStatusCode()==201){
                AsyncResultId = fetchAsyncId(response.getBody());
                system.debug(AsyncResultId);
                
                if(AsyncResultId!=null){
                    system.debug(metadataTypes.size());
                    Datetime sysTime = System.now().addminutes( 3 );
                    String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                    system.debug(chronExpression);
                    system.schedule('MetadataRetreiveCheckStatus '+System.now(), chronExpression, new ScheduleMetadataBackup(AsyncResultId,credentials,'retrieveStatus'));
                }
            }
            else{
                system.debug(response);
                system.debug(response.getBody());
            }
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    
    /*
@description => This method is use to fetch Async Id from the response Body of retrieve call from Metdata api
*/
    Private static String fetchAsyncId(String responseBody){
        String AsyncResultId;
        Dom.Document doc = new Dom.Document();
        doc.load(responseBody);
        Dom.XmlNode rootNode = doc.getRootElement();
        for(Dom.XmlNode childElement:rootNode.getChildElements())
        {  
            for(Dom.XmlNode detailElement:childElement.getChildElements())
            {
                for(Dom.XmlNode detailElement1:detailElement.getChildElements())
                {
                    for(Dom.XmlNode detailElement2:detailElement1.getChildElements())
                    {
                        if(detailElement2.getName()=='id'){
                            AsyncResultId = detailElement2.getText();
                        }
                    }
                }
            }
        }  
        return AsyncResultId;
    }
    
    
    /*
@description => This method is use to check status of retrieve call on basis of Async Id
*/
    @future(callout=true)
    public static void CheckRetrieveStatus(String asyncResultId,String credentials){
        String ZipContent;
        try{
            
            Http http = new Http();
            HttpRequest request = createJobRequest();
            request.setBody(generateEnvelopeForCheckRetrieveStatus(asyncResultId));
            HttpResponse response = http.send(request);
            system.debug(response);
            system.debug(response.getBody());
            ZipContent = getZipFile(response.getBody());
            if(ZipContent!=null)
            {
                system.debug('inside zip');
                system.debug(ZipContent);
                sendZipData(ZipContent,Credentials);
            }
            
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    
    /*
@description => This method is use to send zip data to Emails or AWS
*/
    Private static void sendZipData(String ZipContent,string Credentials){
        
        try{
            Map<String,Object> creds=(Map<String,Object>)JSON.deserializeUntyped(credentials);
            string accessKey = (String)creds.get('accessKey');
            String SecretKey = (String)creds.get('SecretKey');
            String Bucket = (String)creds.get('Bucket');
            String awsRegion = (String)creds.get('awsRegion');
            boolean backupTos3 = (boolean)creds.get('backupTos3');
            boolean backupToLocal = (boolean)creds.get('backupToLocal');
            
            system.debug(backupToLocal);
            system.debug(accessKey);
            blob zipBlob = EncodingUtil.base64Decode(ZipContent);
            
            if(backupTos3){
                if(accessKey!=null && SecretKey!=null && Bucket!=null && awsRegion!=null){
                    String AwsResponse = AwsS3Integration.filePUT('SalesforceMetaData_'+fetchCurrentFormattedDate(), accessKey, secretKey, awsRegion, Bucket, zipBlob);
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
            
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
    }
    
    
    /*
@description => This method is use to fetch the current date to for the name of files of AWS
*/
    Private static String fetchCurrentFormattedDate(){
        DateTime now = DateTime.now();
        Date currentDate = now.date();
        String formattedDate = currentDate.year() + '-' +
            String.valueOf(currentDate.month()).leftPad(2, '0') + '-' +
            String.valueOf(currentDate.day()).leftPad(2, '0');
        return formattedDate;
    }
    
    
    /*
@description => This method is use to get zip file from final response from SF in CheckRetrieveStatus call
*/
    Private static String getZipFile(String responseBody){
        String zipFileData;
        try{
            String zipFileXPath = '//metadata:zipFile';
            String xmlString = responseBody;
            
            // Define the start and end tags of the zipFile element
            String zipFileStartTag = '<zipFile>';
            String zipFileEndTag = '</zipFile>';
            
            // Find the start and end positions of the zipFile element
            Integer startIndex = xmlString.indexOf(zipFileStartTag);
            Integer endIndex = xmlString.indexOf(zipFileEndTag);
            
            // Extract the zipFile data
            zipFileData = xmlString.substring(startIndex + zipFileStartTag.length(), endIndex);
            system.debug(zipFileData);
            
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        return zipFileData;
    }
    
    
    /*
@description => This method is use to get names of All metdata tyes
*/
    @AuraEnabled(cacheable=true)
    Public static List<MetadataWrapper> getMetaDataTypes(){
        
        List<MetadataWrapper> metadataComponentWrraper = new List<MetadataWrapper>();
        Integer objectIndex = 1;
        Http http = new Http();
        HttpRequest request = createJobRequest();
        request.setBody(generateEnvelopeForMetadataTypes());
        HttpResponse response = http.send(request);
        
        
        List<String> metadataComponents =  fetchMetadataNames(response.getBody());
        
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
@description => This method is use to fetch names of metadata Types using response Body
*/
    Private static List<String> fetchMetadataNames(String responseBody){
        List<String> xmlNames = new List<String>();
        Dom.Document doc = new Dom.Document();
        doc.load(responseBody);
        
        Dom.XmlNode rootNode = doc.getRootElement();
        
        for(Dom.XmlNode detailElement:rootNode.getChildElements())
        {
            //  system.debug('detailElement');
            // system.debug(detailElement.getName());
            for(Dom.XmlNode detailElement1:detailElement.getChildElements())
            {
                // system.debug('detailElement1');
                //  system.debug(detailElement1.getName());
                for(Dom.XmlNode detailElement2:detailElement1.getChildElements())
                {
                    // system.debug('detailElement2');
                    //  system.debug(detailElement2.getName());
                    for(Dom.XmlNode detailElement3:detailElement2.getChildElements())
                    {
                        // system.debug('detailElement3');
                        // system.debug(detailElement3.getName());
                        for(Dom.XmlNode metadataObjectNode:detailElement3.getChildren()){
                            // system.debug(metadataObjectNode.getName());
                            if(metadataObjectNode.getName()=='xmlName'){
                                xmlNames.add(metadataObjectNode.getText());
                            }
                            /* system.debug('xmlNames');
system.debug(xmlNames);*/
                        }
                    }
                }
            }
        }
        /*Dom.XmlNode rootNode = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
system.debug(rootNode);
Dom.XmlNode describeMetadataResponseNode = rootNode.getChildElement('describeMetadataResponse', 'http://soap.sforce.com/2006/04/metadata');
system.debug(describeMetadataResponseNode);
Dom.XmlNode resultNode = describeMetadataResponseNode.getChildElement('result', 'http://soap.sforce.com/2006/04/metadata');
system.debug(resultNode);
Dom.XmlNode metadataObjectsNode = resultNode.getChildElement('metadataObjects', 'http://soap.sforce.com/2006/04/metadata');
system.debug(metadataObjectsNode);

for (Dom.XmlNode metadataObjectNode : metadataObjectsNode.getChildren()) {
Dom.XmlNode xmlNameNode = metadataObjectNode.getChildElement('xmlName', 'http://soap.sforce.com/2006/04/metadata');
if (xmlNameNode != null) {
xmlNames.add(xmlNameNode.getText());
}
}*/
        /*system.debug('xmlNames');
system.debug(xmlNames);**/
        /* for(String st:xmlNames){
system.debug(st);
}*/
        xmlNames.sort();
        return xmlNames;
    }
    
    /*
@description => This method is use to generate Soap Envelop for Metadata Types
*/
    Private static String generateEnvelopeForMetadataTypes(){
        string SessionId;
        if(Test.isRunningTest()){
            SessionId = userinfo.getSessionId();
        }
        else{
            SessionId = getSessionId();
        }
        String soapEnvelope = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
            + '<soapenv:Header>'
            + '<met:SessionHeader>'
            + '<met:sessionId>' + SessionId + '</met:sessionId>'
            + '</met:SessionHeader>'
            + '</soapenv:Header>'
            + '<soapenv:Body>'
            + '<met:describeMetadata>'
            + '</met:describeMetadata>'
            + '</soapenv:Body>'
            + '</soapenv:Envelope>';
        return soapEnvelope;
    }
    
    /*
@description => This method is use to generate Soap Envelop for retrieve call of Metadta Api
*/
    Private static String generateEnvelopeForRetrieve(List<String> metadatatypes){
        String soapEnvelope = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
            + '<soapenv:Header>'
            + '<met:CallOptions>'
            + '</met:CallOptions>'
            + '<met:SessionHeader>'
            + '<met:sessionId>' +SESSION_ID+ '</met:sessionId>'
            + '</met:SessionHeader>'
            + '</soapenv:Header>'
            + '<soapenv:Body>'
            + '<met:retrieve>'
            + '<met:retrieveRequest>'
            + '<met:apiVersion>' + API_VERSION+'</met:apiVersion>'
            +'<met:singlePackage>true</met:singlePackage>'
            +'<met:unpackaged>';
        for (String metadataType : metadataTypes) {
            soapEnvelope += '<met:types>'
                + '<met:members>*</met:members>'
                + '<met:name>' + metadataType + '</met:name>'
                + '</met:types>';
        }
        soapEnvelope+= '</met:unpackaged>'
            + '</met:retrieveRequest>'
            + '</met:retrieve>'
            + '</soapenv:Body>'
            + '</soapenv:Envelope>';
        return soapEnvelope;
    }
    
    /*
@description => This method is use to generate Soap Envelop for CheckRetrieveStatus call of Metadta Api
*/
    Private static String generateEnvelopeForCheckRetrieveStatus(String asyncResultId){
        String soapEnvelope = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
            + '<soapenv:Header>'
            + '<met:CallOptions>'
            + '</met:CallOptions>'
            + '<met:SessionHeader>'
            + '<met:sessionId>' +SESSION_ID+ '</met:sessionId>'
            + '</met:SessionHeader>'
            + '</soapenv:Header>'
            + '<soapenv:Body>'
            + '<met:checkRetrieveStatus>'
            +'<met:asyncProcessId>'+asyncResultId+'</met:asyncProcessId>'
            +'<met:includeZip>true</met:includeZip>'
            +'</met:checkRetrieveStatus>'
            + '</soapenv:Body>'
            + '</soapenv:Envelope>';
        return soapEnvelope;
    }
    
    
    /*
@description => This method is use to create the Job Request for Metadata Api
*/
    Private static HttpRequest createJobRequest(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT_URL+'/services/Soap/m/' + API_VERSION);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml');
        request.setHeader('SOAPAction', '""');
        return request;
    }
    
    
    /*
@description => Wrapper class use to return Metadata Types based on Index
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
@description => This method is use fetch Session Id using Vf page
*/
    Private static String getSessionId(){
        String vfContent =Page.getSessionId.getContent().toString(); 
        Integer startPosition = vfContent.indexOf('Start') + 'Start'.length();
        Integer endPosition = vfContent.indexOf('End');
        String SessionId = vfContent.substring(startPosition, endPosition);
        return SessionId;
    }
}