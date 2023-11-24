public class DataRecoveryResponseGenerator implements HttpCalloutMock{
    
    String contextType;
    public DataRecoveryResponseGenerator(String context){
        contextType = context;
    }
    Public HttpResponse respond(HttpRequest req){
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        if(contextType =='CreateInsert'){
            response.setBody(generateInsertResponse());
        }
        if(contextType =='CreateUpsert'){
            response.setBody(generateUpsertResponse());
        }
        
        if(contextType =='CheckInsert'){
            response.setBody(generateCheckBatchStatusResposne_For_Insert());
        }
        
        return response;
            
    }
    
    private String generateInsertResponse(){
        return '{"id":"7505i00000LlN6kAAF","operation":"insert","object":"Account","createdById":"0055i00000Bc1pjAAB","createdDate":"2023-09-18T06:20:51.000+0000","systemModstamp":"2023-09-18T06:20:51.000+0000","state":"Open","concurrencyMode":"Parallel","contentType":"CSV","apiVersion":58.0,"contentUrl":"services/data/v58.0/jobs/ingest/7505i00000LlN6kAAF/batches","lineEnding":"LF","columnDelimiter":"COMMA"}';
    } 
    
    private String generateUpsertResponse(){
        return '{"id":"7505i00000Llfk3AAB","operation":"upsert","object":"test_obj_with_external_Id__c","createdById":"0055i00000Bc1pjAAB","createdDate":"2023-09-20T07:19:58.000+0000","systemModstamp":"2023-09-20T07:19:58.000+0000","state":"Open","externalIdFieldName":"Email_field__c","concurrencyMode":"Parallel","contentType":"CSV","apiVersion":58.0,"contentUrl":"services/data/v58.0/jobs/ingest/7505i00000Llfk3AAB/batches","lineEnding":"LF","columnDelimiter":"COMMA"}';
    } 
    
    private String generateCheckBatchStatusResposne_For_Insert(){
        return '{"id":"7505i00000LlN6kAAF","operation":"insert","object":"Account","createdById":"0055i00000Bc1pjAAB","createdDate":"2023-09-18T06:20:51.000+0000","systemModstamp":"2023-09-18T06:20:52.000+0000","state":"JobComplete","concurrencyMode":"Parallel","contentType":"CSV","apiVersion":58.0,"jobType":"V2Ingest","lineEnding":"LF","columnDelimiter":"COMMA","numberRecordsProcessed":0,"numberRecordsFailed":0,"retries":0,"totalProcessingTime":0,"apiActiveProcessingTime":0,"apexProcessingTime":0}';
    }
}