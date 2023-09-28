public with sharing class Amazon_s3 {

    Private static List<String> Buckets=new List<String>();
    Public static void makeCallToAws(){
     
        Http http=new Http();
        HttpRequest request=new HttpRequest();
        request.setEndpoint('callout:s3/');
        request.setMethod('GET');
        request.setHeader('Content-Type','application/xml');
        HttpResponse response=http.send(request);
        system.debug(response.getstatusCode());
        system.debug(response.getStatus());
        system.debug('response >>>>>>>>>>>>>>>>>>>>>'+response.getbody());
        system.debug('after success');
        if(response.getStatusCode() ==200){
            system.debug('response >>>>>>>>>>>>>>>>>>>>>'+response.getbody());
            system.debug(response.getStatus());
            system.debug(response.getStatusCode());
            
            
            Dom.Document doc = new Dom.Document();
            doc.load(response.getbody());
            
            Dom.XmlNode rootNode = doc.getRootElement();
          //  Dom.XmlNode bucketNodes = rootNode.getChildElements('Buckets', 'http://s3.amazonaws.com/doc/2006-03-01/');
            
          /*  for (Dom.XmlNode bucketNode : bucketNodes) {
                Dom.XmlNode nameNode = bucketNode.getChildElement('Name', 'http://s3.amazonaws.com/doc/2006-03-01/');
                String name = nameNode.getText();
                System.debug('Bucket Name: ' + name);
            
                Dom.XmlNode creationDateNode = bucketNode.getChildElement('CreationDate', 'http://s3.amazonaws.com/doc/2006-03-01/');
                String creationDate = creationDateNode.getText();
                System.debug('Creation Date: ' + creationDate);
            }*/
            
            for(Dom.XmlNode childElement:rootNode.getChildElements()){
                for(Dom.XmlNode detailElement:childElement.getChildElements()){
                for(Dom.XmlNode detailElement1:detailElement.getChildElements()){
                    if(detailElement1.getName()=='Name'){
                        Buckets.add(detailElement1.getText());
                    }
                }
                }
            }
            system.debug('Buckets'+Buckets);
        }
    }

}