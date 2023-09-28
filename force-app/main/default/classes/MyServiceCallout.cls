public with sharing class MyServiceCallout {
    @AuraEnabled(cacheable=true)
    public static List<Object> getData(){
        //system.debug('test1');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://dummy.restapiexample.com/api/v1/employees');
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        

        List<Object> responseList = new List<Object>();
        List<Object> listobject = new List<Object>();
        
        Map<String,Object> responseMap=new Map<String,Object>();
        
        if(response.getStatusCode()==200 && response.getBody() != null){
            String responseBody = response.getBody(); 
            
            responseMap =  (Map<String,Object>) JSON.deserializeUntyped(responseBody);
            listobject = (List<Object>) responseMap.get('data');
            
            
            //responseList =  (List<Object>) JSON.deserializeUntyped(responseBody);
            //system.debug(responseList);
            
            for(Object obj:listobject){
                Map<String, Object> dataMap = (Map<String, Object>) obj;
                // String name= (String)dataMap.get('employee_name');
                // responseList.add(name);

                responseList.add(dataMap);
            }
        }
        else {
            System.debug('API callout failed with status code: ' + response.getStatusCode());
        }
        return responseList;
    }
}