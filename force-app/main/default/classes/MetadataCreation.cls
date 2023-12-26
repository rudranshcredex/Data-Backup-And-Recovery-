/*
    @Developer Name => Nikhil Garg
    @description => This  class is use to Create Custom Metadata and Remote site settings
*/

public with sharing class MetadataCreation {
    
    Public static final string endpointUrl = URL.getOrgDomainUrl().toExternalForm();
      /*
@description => This method is use to create Custom Metadata to store Aws S3 creds
*/
    @future(callout=true)
    Public static void createCustomMetadata(String Name, String AccessKey,String SecretKey,String RegionName){
        try{
            HttpRequest req = createRequest('create');  
            req.setBody(generateEnvelopForCustomMetadata( Name,  AccessKey, SecretKey, RegionName));
            
            HttpResponse response = new Http().send(req);
        }
        catch(Exception ex){
            throw new AurahandledException(ex.getMessage());
        }
    }
    
      /*
@description => This method is use to create remote site setting for White Listing the url
*/
    public static void createRemoteSiteSetting(String fullName, String url) {
        system.debug('endpointUrl'+ endpointUrl);
        system.debug('fullName'+ fullName);
        system.debug('url'+ url);
        HttpRequest req = createRequest('create'); 
        req.setBody(generateEnvelopForCreateRemoteSiteSetting(fullName,url));
        
        HttpResponse res = new Http().send(req);
        System.debug('response: '+res.getBody());
    }
    
     /*
@description => This method is use to delete  remote site setting 
*/
    public static void deleteRemoteSiteSetting(String fullName) {
        
        HttpRequest req = createRequest('delete');
        req.setBody(generateEnvelopForDeleteRemoteSiteSetting(fullName));
        
        HttpResponse res = new Http().send(req);
        System.debug('res------>'+res);
    }
    
    Public static String getSession(){
        String vfContent =Page.getSessionId.getContent().toString(); 
        Integer startPosition = vfContent.indexOf('Start') + 'Start'.length();
        Integer endPosition = vfContent.indexOf('End');
        String SessionId = vfContent.substring(startPosition, endPosition);
        return SessionId;
    }
    
     /*
@description => This method is use to generate Soap Envelop to create Remote Site setting
*/
private static String generateEnvelopForCreateRemoteSiteSetting(String fullName, String Url){
        string SessionId;
        if(Test.isRunningTest()){
            SessionId = userinfo.getSessionId();
        }
        else{
            SessionId = getSession();
        }
        return '<?xml version="1.0" encoding="UTF-8"?>'
            + '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            + '    <env:Header>'
            + '        <urn:SessionHeader xmlns:urn="http://soap.sforce.com/2006/04/metadata">'
            + '            <urn:sessionId>' + SessionId  + '</urn:sessionId>'
            + '        </urn:SessionHeader>'
            + '    </env:Header>'
            + '    <env:Body>'
            + '        <createMetadata xmlns="http://soap.sforce.com/2006/04/metadata">'
            + '            <metadata xsi:type="RemoteSiteSetting" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
            + '                <fullName>'+fullName+'</fullName>' 
            + '                <url>'+Url+'</url>' 
            + '                <isActive>true</isActive>' 
            + '            </metadata>'
            + '        </createMetadata>'
            + '    </env:Body>'
            + '</env:Envelope>';
    }
    
      /*
@description => This method is use to generate Soap Envelop to delete Remote Site setting
*/
    private static String generateEnvelopForDeleteRemoteSiteSetting(String fullName){
        string SessionId;
        if(Test.isRunningTest()){
            SessionId = userinfo.getSessionId();
        }
        else{
            SessionId = getSession();
        }
        return '<?xml version="1.0" encoding="UTF-8"?>'
            + '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            + '    <env:Header>'
            + '        <urn:SessionHeader xmlns:urn="http://soap.sforce.com/2006/04/metadata">'
            + '            <urn:sessionId>' + SessionId + '</urn:sessionId>'
            + '        </urn:SessionHeader>'
            + '    </env:Header>'
            + '    <env:Body>'
            + '        <deleteMetadata xmlns="http://soap.sforce.com/2006/04/metadata">'
            + '				   <type>RemoteSiteSetting</type>'
            + '                <fullName>' + fullName + '</fullName>' 
            + '        </deleteMetadata>'
            + '    </env:Body>'
            + '</env:Envelope>';
    }
    
      /*
@description => This method is use to generate Soap Envelop to create Custom Metadata 
*/
    private static String generateEnvelopForCustomMetadata(String Name, String AccessKey,String SecretKey,String RegionName){
        
        return '<?xml version="1.0" encoding="UTF-8"?>'
            + '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            + '    <env:Header>'
            + '        <urn:SessionHeader xmlns:urn="http://soap.sforce.com/2006/04/metadata">'
            + '            <urn:sessionId>' + UserInfo.getSessionId() + '</urn:sessionId>'
            + '        </urn:SessionHeader>'
            + '    </env:Header>'
            + '    <env:Body>'
            + '        <createMetadata xmlns="http://soap.sforce.com/2006/04/metadata">'
            + '            <metadata xsi:type="CustomMetadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
            + '                <fullName>' + 'CBAR__AwsCredential__mdt.'+Name+'</fullName>' 
            + '                <label>' + Name+ '</label>' 
            + '                <protected>false</protected>' 
            + '                <values>'
            + '                    <field>' + 'CBAR__AccessKey' + '__c</field>' 
            + '                    <value>' + AccessKey + '</value>'
            + '                </values>'
            + '                <values>'
            + '                    <field>' + 'CBAR__Region_Name' + '__c</field>' 
            + '                    <value>' + RegionName + '</value>' 
            + '                </values>'
            + '                <values>'
            + '                    <field>' + 'CBAR__SecretKey' + '__c</field>' 
            + '                    <value>' + SecretKey + '</value>' 
            + '                </values>'
            + '            </metadata>'
            + '        </createMetadata>'
            + '    </env:Body>'
            + '</env:Envelope>';
    }
    
/*
@description => This method is use to create Metadata request
*/
    private static HttpRequest createRequest(string ActionType){
		System.debug('endpointUrl: '+endpointUrl);        
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpointUrl + '/services/Soap/m/' + '58.0');
        request.setHeader('Content-Type', 'text/xml');
        if(ActionType=='create'){
            request.setHeader('SOAPAction', 'createMetadata');
        }
        if(ActionType=='delete'){
            request.setHeader('SOAPAction', 'deleteMetadata');
        }
        
        return request;
    }
}