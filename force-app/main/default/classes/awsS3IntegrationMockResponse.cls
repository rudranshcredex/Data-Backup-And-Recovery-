public class awsS3IntegrationMockResponse implements httpCalloutMock {
	public httpResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
      
        res.setBody('{"buctest143", "buctest1453", "createtestbuk", "testsfbucket2"}');
     	res.setStatusCode(200);
        res.setHeader('x-amz-server-side-encryption', 'AES256');
        
        return res;       
    }    
    
}