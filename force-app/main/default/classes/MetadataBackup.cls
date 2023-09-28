public With sharing class MetadataBackup {
    
    private static final String API_VERSION = '58.0';
    Private static final String ENDPOINT_URL = url.getOrgDomainUrl().toExternalForm();
    private static final String SESSION_ID = userinfo.getSessionId();
    
    
    @AuraEnabled(Cacheable=true)
    Public static void retrieveMetadata(List<String> metadataTypes,String Credentials){
        retrieve(metadataTypes,Credentials);
    }
    
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
                    
                    Datetime sysTime;
                    if(metadataTypes.size()<10){
                        sysTime = System.now().addminutes( 1 ); 
                    }
                    else if(metadataTypes.size()>10){
                        sysTime = System.now().addminutes( 7 ); 
                    }
                    String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                    system.schedule('MetadataRetreiveCheckStatus '+System.now(), chronExpression, new ScheduleMetadataBackup(AsyncResultId,credentials));
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
    
    Private static String fetchCurrentFormattedDate(){
        DateTime now = DateTime.now();
        Date currentDate = now.date();
        String formattedDate = currentDate.year() + '-' +
        String.valueOf(currentDate.month()).leftPad(2, '0') + '-' +
        String.valueOf(currentDate.day()).leftPad(2, '0');
        return formattedDate;
    }
    
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
    
    @AuraEnabled(cacheable=true)
    Public static List<String> getMetaDataTypes(){
        Http http = new Http();
        HttpRequest request = createJobRequest();
        request.setBody(generateEnvelopeForMetadataTypes());
        HttpResponse response = http.send(request);
        system.debug(response);
        system.debug('response Body');
        system.debug(response.getBody());
       
        return fetchMetadataNames(response.getBody());
    }
    
    Private static List<String> fetchMetadataNames(String responseBody){
        system.debug('inside fetchMetadataNames');
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
    
    Private static String generateEnvelopeForMetadataTypes(){
        String soapEnvelope = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
            + '<soapenv:Header>'
            + '<met:SessionHeader>'
            + '<met:sessionId>' + SESSION_ID + '</met:sessionId>'
            + '</met:SessionHeader>'
            + '</soapenv:Header>'
            + '<soapenv:Body>'
            + '<met:describeMetadata>'
            + '</met:describeMetadata>'
            + '</soapenv:Body>'
            + '</soapenv:Envelope>';
        return soapEnvelope;
    }
    
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
    
    Private static HttpRequest createJobRequest(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT_URL+'/services/Soap/m/' + API_VERSION);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml');
        request.setHeader('SOAPAction', '""');
        return request;
    }
    
    Public class ScheduleMetadataBackup implements Schedulable{
        
        private string AsyncResultId;
        Private String Creds;
        Public ScheduleMetadataBackup(String AsyncId, String Credentials){
            AsyncResultId = AsyncId;
            Creds = Credentials;
        }
        Public  void execute(SchedulableContext sc){
            CheckRetrieveStatus(AsyncResultId,Creds);
        }
    }
}