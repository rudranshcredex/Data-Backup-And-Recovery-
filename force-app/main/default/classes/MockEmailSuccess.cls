public class MockEmailSuccess implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
       
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(200);
        res.setBody('Success'); 
        return res;
    }
}