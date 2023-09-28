public with sharing class MetadataMockGenerator implements HttpCalloutMock{

    private static string context;
    public MetadataMockGenerator(string contextType){
        context = contextType;
    }
    Public HttpResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        if(context =='Metadata'){
            response.setBody(generateResponseForCustomMetadata());
        }
        return response;
    }
    
    private static String generateResponseForCustomMetadata(){
        return '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="http://soap.sforce.com/2006/04/metadata">'
            +'<soapenv:Body>'
            +'<createMetadataResponse>'
            +'<result>'
            +'<fullName>AwsCredential__mdt.metadata</fullName>'
            +'<success>true</success></result>'+
            +'</createMetadataResponse>'
            +'</soapenv:Body>'
            +'</soapenv:Envelope>';
    }
    
}