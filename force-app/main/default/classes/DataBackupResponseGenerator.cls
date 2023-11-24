public class DataBackupResponseGenerator implements httpCalloutMock {
    
    String responseContext;
    public DataBackupResponseGenerator(String responseType){
        responseContext = responseType;
    }
    public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            if(responseContext == 'getJobId'){
                res.setBody(generateResponseForJobId()); 
            }
            if(responseContext == 'getResult'){
                res.setBody(generateResponseForJobResult());
            }
            return res;
        }
    
    Public static String generateResponseForJobId(){
        return '{"id":"7505i00000Lkbu7AAB","operation":"query","object":"Account","createdById":"0055i00000Bc1pjAAB","createdDate":"2023-09-12T09:54:54.000+0000","systemModstamp":"2023-09-12T09:54:54.000+0000","state":"UploadComplete","concurrencyMode":"Parallel","contentType":"CSV","apiVersion":58.0,"lineEnding":"LF","columnDelimiter":"COMMA"}';
    }
	
    Public static String generateResponseForJobResult(){
        return 'Email,Phone'+'\n'+'abc@gmail.com,1111';
    }
}