public class MetadataRecoveryResponseGenerator implements HttpCalloutMock {

    Private static string requestContext;
    
    Public MetadataRecoveryResponseGenerator(String Context){
        requestContext = context;
    }
    Public HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        if(requestContext == 'deploy'){
            res.setBody(generateDeployResponse());
        }
        else if(requestContext == 'checkDeployStatus'){
            res.setBody(generateCheckDeployStatusResponse());
        }
        res.setStatusCode(200);
        return res;
    }
    
    private static String generateDeployResponse(){
        return '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
                    + '<soapenv:Body>'
                    + '<deployResponse>'
                    + '<result>'
                    + '<done>false</done>'
                    + '<id>0Af5i00000hcNw1CAE</id>' 
                    + '<state>Queued</state>'
                    + '</result>'
                    + '</deployResponse>'
                    + '</soapenv:Body>'
                    + '</soapenv:Envelope>';
    }
    private static String generateCheckDeployStatusResponse(){
        return '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
                    + '<soapenv:Body>'
                    + '<checkDeployStatusResponse>'
                    + '<result>'
                    +'<checkOnly>false</checkOnly>'
                    +'<completedDate>2023-09-11T06:38:05.000Z</completedDate>'
                    +'<createdBy>0055i00000Bc1pj</createdBy>'
                    +'<createdByName>Credex Backup</createdByName>'
                    +'<createdDate>2023-09-11T06:38:04.000Z</createdDate>'
                    +'<details>'
                    +'<componentSuccesses>'
                    +'<changed>true</changed>'
                    +'<componentType></componentType>'
                    +'<created>false</created>'
                    +'<createdDate>2023-09-11T06:38:04.000Z</createdDate>'
                    +'<deleted>false</deleted>'
                    +'<fileName>package.xml</fileName>'
                    +'<fullName>package.xml</fullName>'
                    +'<success>true</success>'
                    +'</componentSuccesses>'
                    +'</details>'
                    + '<done>true</done>'
                    +'<id>0Af5i00000hcNw1CAE</id>'
                    +'<ignoreWarnings>false</ignoreWarnings>'
                    +'<lastModifiedDate>2023-09-11T06:38:05.000Z</lastModifiedDate>'
                    +'<numberComponentErrors>0</numberComponentErrors>'
                    +'<numberComponentsDeployed>2</numberComponentsDeployed>'
                    +'<numberComponentsTotal>2</numberComponentsTotal>'
                    +'<numberTestErrors>0</numberTestErrors>'
                    +'<numberTestsCompleted>0</numberTestsCompleted>'
                    +'<numberTestsTotal>0</numberTestsTotal>'
                    +'<rollbackOnError>false</rollbackOnError>'
                    +'<runTestsEnabled>false</runTestsEnabled>'
                    +'<startDate>2023-09-11T06:38:04.000Z</startDate>'
                    +'<status>Succeeded</status>'
                    +'<success>true</success>'
                    + '</result>'
                    + '</checkDeployStatusResponse>'
                    + '</soapenv:Body>'
                    + '</soapenv:Envelope>';
    }
}