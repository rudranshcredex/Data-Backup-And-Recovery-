public class BatchApex {

    public static void retreiveData(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://https://credex-e-dev-ed.my.salesforce.com/services/data/v54.0/jobs/ingest');
        request.setMethod('POST');
        String accessToken = '00D5j000001uCc3!ARkAQOpJSI_R0NAt7Vy.b9ybuSFqNcy2O0t0TlxvOx7SrnsqAiCdEYtoJEQv_zb4exsZypOgRuXgvLiTmY7kO0quIwBBjOZQ';
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        
        String body = '{"operation": "query", "object": "Account", "contentType": "CSV"}';
        request.setBody(body);
        
        HttpResponse response = new Http().send(request);
        
        if (response.getStatusCode() == 201) {
            String jobId = response.getHeader('Location').substringAfterLast('/');
            System.debug('Job ID: ' + jobId);
            system.debug(response);
            // Now you need to create batches and check their status
            // Once the batch is completed, you can download results
        } else {
            System.debug('Job creation failed with status code: ' + response.getStatusCode());
            System.debug('Response: ' + response.getBody());
        }
        
            }
}