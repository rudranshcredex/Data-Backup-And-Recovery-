public class MetadataBackupResponseGenerator implements HttpCalloutMock {

    Private static string requestContext;
    
    Public MetadataBackupResponseGenerator(String Context){
        requestContext = context;
    }
    Public HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setStatusCode(200);
        
        if(requestContext == 'retrieve'){
            res.setBody(generateRetrieveResponse());
        }
        else if(requestContext == 'checkRetrieveStatus'){
            res.setBody(generateCheckRetrieveStatusResponse());
        }
        else if(requestContext == 'getMetadataTypes'){
            res.setBody(generateResponseForMetadataTypes());
        }
        return res;
    }
    
    private static String generateRetrieveResponse(){
        return '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
                    + '<soapenv:Body>'
                    + '<retrieveResponse>'
                    + '<result>'
                    + '<done>false</done>'
                    + '<id>09S5i00000DWAScEAP</id>' 
                    + '<state>Queued</state>'
                    + '</result>'
                    + '</retrieveResponse>'
                    + '</soapenv:Body>'
                    + '</soapenv:Envelope>';
    }
    
    private static String generateCheckRetrieveStatusResponse(){
        return '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
                    + '<soapenv:Body>'
                    + '<checkRetrieveStatusResponse>'
                    + '<result>'
                    +'<done>true</done>'
            		+'<fileProperties>'
            		+'<createdById>0055i00000Bc1pjAAB</createdById>'
            		+'<createdByName>Credex Backup</createdByName>'
            		+'<createdDate>2023-09-12T09:02:21.046Z</createdDate>'
            		+'<fileName>labels/CustomLabels.labels</fileName>'	
            		+'<fullName>CustomLabels</fullName>'
            		+'<id>000000000000000AAA</id>'
            		+'<lastModifiedById>0055i00000Bc1pjAAB</lastModifiedById>'
            		+'<lastModifiedByName>Credex Backup</lastModifiedByName>'
            		+'<lastModifiedDate>2023-09-12T09:02:21.046Z</lastModifiedDate>'
            		+'<type>CustomLabels</type>'
            		+'</fileProperties>'
            		+'<fileProperties>'
            		+'<createdById>0055i00000Bc1pjAAB</createdById>'
            		+'<createdByName>Credex Backup</createdByName>'
            		+'<createdDate>2023-09-12T09:02:21.109Z</createdDate>'
            		+'<fileName>package.xml</fileName>'
            		+'<fullName>package.xml</fullName>'
            		+'<id></id>'
            		+'<lastModifiedById>0055i00000Bc1pjAAB</lastModifiedById>'
            		+'<lastModifiedByName>Credex Backup</lastModifiedByName>'
            		+'<lastModifiedDate>2023-09-12T09:02:21.109Z</lastModifiedDate>'
            		+'<manageableState>unmanaged</manageableState>'
            		+'<type>Package</type>'
            		+'</fileProperties>'
            		+'<id>09S5i00000DWAScEAP</id>'
            		+'<status>Succeeded</status>'
            		+'<success>true</success>'
            		+'<zipFile>'
            		+'UEsDBBQACAgIAEpILFcAAAAAAAAAAAAAAAAaAAAAbGFiZWxzL0N1c3RvbUxhYmVscy5sYWJlbHNlUEFqwzAQvPsVQvd4nVBCKbJyaCk9lF6anIMibxyDpDXSKvT5MXYbFbK3mZ3ZYVbtfrwTV4xpoNDKdd1IgcFSN4S+lYf9++pZ7nSlXnNi8p/mhC6JyRJSKy/M4wtAIjPW6UzRYm3Jw6ZpttA8gUc2nWEjdSWmUW42L2Amztm5L+NR7zHxcb6t4E4WnTOhz6ZHjeF4+FZwx0UyRmK0jJ3mmFFBwUWTLhT5DZONw8hT2zlW/MY+LIvvalxG/YHOkYIFLIXgr5GC/+/R1Q1QSwcI1nW3HswAAABVAQAAUEsDBBQACAgIAEpILFcAAAAAAAAAAAAAAAALAAAAcGFja2FnZS54bWxNTssKwjAQvPcrQo6C2SgqRbbpQfDkwYN+QJqutdgkpYmif2/pA53TzO4wM5i/bcNe1IXau4yvhOSMnPFl7aqMXy/HZcpzleBZm4euiPVuFzJ+j7HdAwSvWxFuvjMkjLewlnIHcgOWoi511FwlrAfGT0th5IO2ZIu+Ui0QZvp7Om1JHZ4henvSBTUIw2VMgr8onGarbSokwqwShGmtSr5QSwcIwf2QO58AAADfAAAAUEsBAhQAFAAICAgASkgsV9Z1tx7MAAAAVQEAABoAAAAAAAAAAAAAAAAAAAAAAGxhYmVscy9DdXN0b21MYWJlbHMubGFiZWxzUEsBAhQAFAAICAgASkgsV8H9kDufAAAA3wAAAAsAAAAAAAAAAAAAAAAAFAEAAHBhY2thZ2UueG1sUEsFBgAAAAACAAIAgQAAAOwBAAAAAA=='
            		+'</zipFile>'
                    + '</result>'
                    + '</checkRetrieveStatusResponse>'
                    + '</soapenv:Body>'
                    + '</soapenv:Envelope>';
    }
    
    private static String generateResponseForMetadataTypes(){
         return '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
                    + '<soapenv:Body>'
                    + '<describeMetadataResponse>'
                    + '<result>'
                    +'<metadataObjects>'
             		+'<directoryName>installedPackages</directoryName>'
             		+'<inFolder>false</inFolder>'
             		+'<metaFile>false</metaFile>'
             		+'<suffix>installedPackage</suffix>'
             		+'<xmlName>InstalledPackage</xmlName>'
             		+'</metadataObjects>'
             		+'<metadataObjects>'
             		+'<directoryName>Classes</directoryName>'
             		+'<inFolder>false</inFolder>'
             		+'<metaFile>false</metaFile>'
             		+'<suffix>ApexClass</suffix>'
             		+'<xmlName>ApexClass</xmlName>'
             		+'</metadataObjects>'
                    + '</result>'
                    + '</describeMetadataResponse>'
                    + '</soapenv:Body>'
                    + '</soapenv:Envelope>';
    }
}