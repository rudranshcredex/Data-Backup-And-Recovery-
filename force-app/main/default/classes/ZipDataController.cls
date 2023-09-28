public WITH SHARING class ZipDataController {
	
    Public static Map<String,object> csvContent{get;set;}
    public static string cont;
    public  String content='no content';
    public string name='nikhil';
    public string getName(){
        return name;
    }
    
    public String getContent(){
        return content;
    }
    
    public void setContent(){
        content=cont;
    }
    @AuraEnabled
    Public static void getcsvContent(String csvContents){
        cont=csvContents;
        system.debug(csvContents);
        //setContent(csvContents);
        system.debug('csv content>>>>>>>>>>');
        system.debug(csvContents);
       List<Object> contents=(List<Object>)JSON.deserializeUntyped(csvContents);
        for(object content:contents){
           system.debug(content);
            Map<String,object> maos=(Map<String,object>)content;
            system.debug('content>>>>>>>>>>>>>');
            system.debug((String)maos.get('Account'));
            
        }
    }
}