public class FakeResponse {
    public static httpresponse makeGetRequest() {
    HttpRequest request = new HttpRequest();
    request.setEndpoint('https://dummyjson.com/carts');
    request.setMethod('GET');
    
    Http http = new Http();
    HttpResponse response = http.send(request);
    
    if (response.getStatusCode() == 200) {
        system.debug(response.getBody());
        return response;
    } else{
        System.debug('HTTP Request Failed with status code: ' + response.getStatusCode());
        return null;
    }
}
}