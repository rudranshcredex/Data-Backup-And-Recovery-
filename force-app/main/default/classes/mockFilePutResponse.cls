public class mockFilePutResponse implements httpCalloutMock{
    public httpresponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
         req.setHeader('Content-type', 'application/zip');
        res.setStatusCode(200);
        return res;    
    }
}