public With sharing class RetrieveTesting {

    private static final String API_VERSION = '58.0';
    Private static final String ENDPOINT_URL = url.getOrgDomainUrl().toExternalForm();
    private static final String SESSION_ID = userinfo.getSessionId();
    private static final String CLIENT = '3MVG9wt4IL4O5wvIiww2WidIEJ_eHlPjiXXrcZ9hY2nUndUIVTld0uOUAYvDU79PGiiKdXnuvDjEz19hgCEXC';

    public static void retrieveMetadata(List<String> metadataTypes){
       
      	Http http = new Http();
        HttpRequest request = createJobRequest();
        request.setBody(generateEnvelopeForRetrieve(metadataTypes));
    	HttpResponse response = http.send(request);
        system.debug(response);
        system.debug(response.getBody());
        
    }
    
    public static void CheckRetrieveStatus(String asyncResultId){
        Http http = new Http();
        HttpRequest request = createJobRequest();
        request.setBody(generateEnvelopeForCheckRetrieveStatus(asyncResultId));
    	HttpResponse response = http.send(request);
        system.debug(response);
        system.debug(response.getBody());
        
        
        String zipFileXPath = '//metadata:zipFile';
        String xmlString = response.getBody();
        
        // Define the start and end tags of the zipFile element
        String zipFileStartTag = '<zipFile>';
        String zipFileEndTag = '</zipFile>';
        
        // Find the start and end positions of the zipFile element
        Integer startIndex = xmlString.indexOf(zipFileStartTag);
        Integer endIndex = xmlString.indexOf(zipFileEndTag);
        
        // Extract the zipFile data
        String zipFileData = xmlString.substring(startIndex + zipFileStartTag.length(), endIndex);
                system.debug(zipFileData);
        
        Attachment attachment = new Attachment();
        attachment.Body = (EncodingUtil.base64Decode(zipFileData));
        attachment.ParentId = '0015i00000oYvsvAAC'; 
        attachment.Name = 'retrieve Testing11-09-23';
                insert attachment;
    }
    
    Public static void getMetadataTypes(){
        Http http = new Http();
        HttpRequest request = createJobRequest();
        request.setBody(generateEnvelopeForMetadataTypes());
    	HttpResponse response = http.send(request);
        system.debug(response);
        system.debug(response.getBody());
        
        List<String> xmlNames = new List<String>();
        Dom.Document doc = new Dom.Document();
        doc.load(response.getBody());
        
        /*Dom.XmlNode rootNode = doc.getRootElement();
        
        for(Dom.XmlNode detailElement:rootNode.getChildElements())
            {
                system.debug(detailElement.getName());
                for(Dom.XmlNode detailElement1:detailElement.getChildElements())
                {
                    system.debug(detailElement1.getName());
                    for(Dom.XmlNode detailElement2:detailElement1.getChildElements())
                    {
                        system.debug(detailElement2.getName());
                        for(Dom.XmlNode detailElement3:detailElement2.getChildElements())
                        {
                            system.debug(detailElement3.getName());
                            for(Dom.XmlNode metadataObjectNode:detailElement3.getChildren()){
                               /* if(metadataObjectNode.getName()=='xmlName'){
                                    xmlNames.add(xmlNameNode.getText());
                                }
                                system.debug('metadataObjectNode');
                                system.debug(metadataObjectNode);
                            }
                        }
                	}
                }
            }*/
        Dom.XmlNode rootNode = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
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
        }
        system.debug('xmlNames');
        system.debug(xmlNames);
    }
    
    Private static String generateEnvelopeForMetadataTypes(){
        String soapEnvelope = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
        + '<soapenv:Header>'
        + '<met:CallOptions>'
        /*+ '<met:client>' + CLIENT + '</met:client>'*/
        + '</met:CallOptions>'
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
}