public class MetadataRecovery {
    
    private static final String API_VERSION = '58.0';
    private static final String SESSION_ID = userinfo.getSessionId();
    private static final String CLIENT = '3MVG9wt4IL4O5wvIiww2WidIEJ_eHlPjiXXrcZ9hY2nUndUIVTld0uOUAYvDU79PGiiKdXnuvDjEz19hgCEXC';
    Private static final String ENDPOINT_URL = URL.getOrgDomainUrl().toExternalForm();
    
 
    
    Private static String generateEnvelopeForDeployCall(String base64ZipContent){
        return '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'+
            '<soapenv:Header>'+
            '<met:CallOptions>'+
            /*'<met:client>'+CLIENT+'</met:client>'+*/
            '</met:CallOptions>'+
            '<met:SessionHeader>'+
            '<met:sessionId>'+SESSION_ID+'</met:sessionId>'+
            '</met:SessionHeader>'+
            '</soapenv:Header>'+
            '<soapenv:Body>'+
            '<met:deploy>'+
            + '<met:ZipFile>'+base64ZipContent+'</met:ZipFile>'+
            '<met:DeployOptions>'+
            
            '<met:singlePackage>true</met:singlePackage>'+
            '<met:testLevel>NoTestRun</met:testLevel>'+
            '</met:DeployOptions>'+
            
            '</met:deploy>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>';
    }
   
    Private static String generateEnvelopeForCheckDeployStatus(String asyncResultId){
        return '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
            + '<soapenv:Header>'
            + '<met:CallOptions>'
            /*+ '<met:client>' + CLIENT + '</met:client>'*/
            + '</met:CallOptions>'
            + '<met:SessionHeader>'
            + '<met:sessionId>' +SESSION_ID+ '</met:sessionId>'
            + '</met:SessionHeader>'
            + '</soapenv:Header>'
            + '<soapenv:Body>'
            + '<met:checkDeployStatus>'
            +'<met:asyncProcessId>'+asyncResultId+'</met:asyncProcessId>'
            + '<met:includeDetails>true</met:includeDetails>'
            +'</met:checkDeployStatus>'
            + '</soapenv:Body>'
            + '</soapenv:Envelope>';
    }
        
    @AuraEnabled(cacheable=true)
    Public static void deployMetadata(String zipContent){
        deploy(zipContent);
    }
    
    @future(callout=true)
    Public static void deploy(String zipContent){
        String AsyncResultId;
        Http http = new Http();
        HttpRequest request = createJobRequest();
        request.setBody(generateEnvelopeForDeployCall(zipContent));
        HttpResponse response = new http().send(request);
        system.debug(response.getBody());
        
        if(response.getStatusCode()==200 || response.getStatusCode()==201)
        {
            AsyncResultId = fetchAsyncId(response.getBody());
        }
        system.debug(AsyncResultId);
        
         Datetime sysTime = System.now().addminutes(1);
         String CRON_EXPRESSION = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
         System.schedule('Schedule Metadata Recovery'+system.now().addminutes(2), CRON_EXPRESSION, new ScheduleMetadataRecovery(AsyncResultId));
    }
     
    @future(callout=true)
    public static void CheckDeployStatus(String asyncResultId){
        RecoveryResponse responseOfRecovery;
        Http http = new Http();
        HttpRequest request = createJobRequest();
        request.setBody(generateEnvelopeForCheckDeployStatus(asyncResultId));
        HttpResponse response = http.send(request);
        system.debug(response);
        system.debug(response.getBody());
        
        if(response.getStatusCode()==200 || response.getStatusCode()==201){
            responseOfRecovery = fetchDelpoyResult(response.getBody());
        }
    }
    
    Private Static RecoveryResponse fetchDelpoyResult(String responseBody){
        List<Dom.XmlNode> componentSuccesses =new List<Dom.XmlNode>();
        
        RecoveryResponse recoveryData = new RecoveryResponse();
        system.debug(responseBody);
        Dom.Document doc = new Dom.Document();
        doc.load(responseBody);
        Dom.XmlNode rootNode = doc.getRootElement();
        
        for(Dom.XmlNode childElement:rootNode.getChildElements())
        {
            for(Dom.XmlNode detailElement:childElement.getChildElements())
            {
                system.debug(detailElement.getName());
                for(Dom.XmlNode detailElement1:detailElement.getChildElements()){
                    
                    system.debug(detailElement1.getName());
                    for(Dom.XmlNode detailElement2:detailElement1.getChildElements())
                    {
                        
                        if(detailElement2.getName()=='details'){
                            system.debug(detailElement2.getChildElements());
                            for(Dom.XmlNode detailElement3:detailElement2.getChildElements()){
                                componentSuccesses.add(detailElement3);
                            }
                            
                        }
                        else if(detailElement2.getName()=='numberComponentErrors'){
                            recoveryData.numberComponentErrors = detailElement2.getText();
                        }
                        else if(detailElement2.getName()=='numberComponentsDeployed'){
                            recoveryData.numberComponentsDeployed = detailElement2.getText();
                        }
                        else if(detailElement2.getName()=='numberComponentsTotal'){
                            recoveryData.numberComponentsTotal = detailElement2.getText();
                        }
                        else if(detailElement2.getName()=='numberTestErrors'){
                            recoveryData.numberTestErrors = detailElement2.getText();
                        }
                        else if(detailElement2.getName()=='numberTestsCompleted'){
                           recoveryData.numberTestsCompleted = detailElement2.getText();
                        }
                        else if(detailElement2.getName()=='numberTestsTotal'){
                             recoveryData.numberTestsTotal = detailElement2.getText();
                        }
                        else if(detailElement2.getName()=='success'){
                           recoveryData.isSuccess = detailElement2.getText();
                        }
                        
                    }
                }
            }
        }
        for (Dom.XmlNode componentSuccess : componentSuccesses) 
        {
                String Success;
                String CompType;
                String FullName;
           // system.debug(componentSuccess);
            for(Dom.XmlNode detailComponent:componentSuccess.getChildElements()){
               
                //system.debug(detailComponent);
                if(detailComponent.getName()=='componentType'){
                    CompType = detailComponent.getText();
                }
                if(detailComponent.getName()=='fullName'){
                    FullName = detailComponent.getText();
                    system.debug('test');
                    system.debug(FullName);
                }
                if(detailComponent.getName()=='success'){
                    Success = detailComponent.getText();
                }
                system.debug(Success);
                system.debug(CompType);
                system.debug(FullName);
            }
            // Access individual child elements within componentSuccess
            /*Dom.XmlNode success = componentSuccess.getChildElement('success', null);
            Dom.XmlNode componentType = componentSuccess.getChildElement('componentType', null);
            Dom.XmlNode fullName = componentSuccess.getChildElement('fullName', null);
        
            // Extract data from child elements
            Boolean isSuccess = success.getText() == 'true';
            String type = componentType.getText();
            String name = fullName.getText();
        
            // Process the data as needed
            System.debug('Is Success: ' + isSuccess);
            System.debug('Component Type: ' + type);
            System.debug('Full Name: ' + name);*/
			}
       
       
        
        String result = EmailAndNotification.sendMetadataRecoveryResultEmail(JSON.serialize(recoveryData));
        system.debug(result);
        if(result =='Success'){
            EmailAndNotification.sendCustomNotification('MetadataRecovery', 'test');
        }
        
        return recoveryData;
    }
    
    Private static String fetchAsyncId(String responseBody){
        system.debug('test  ');
        
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
    
    Private static HttpRequest createJobRequest(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT_URL+'/services/Soap/m/' + API_VERSION);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml');
        request.setHeader('SOAPAction', '""');
        return request;
    }
    
    Public class RecoveryResponse{
         Public  String numberComponentsTotal;
         Public  String numberComponentErrors;
         Public  String numberComponentsDeployed;
         Public  String numberTestErrors;
         Public  String numberTestsCompleted;
         Public String numberTestsTotal;
         Public String isSuccess;
    }
}