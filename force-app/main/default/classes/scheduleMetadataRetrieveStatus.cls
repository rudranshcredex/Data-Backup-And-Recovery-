Public with sharing class scheduleMetadataRetrieveStatus implements schedulable{

    Private  string asyncResultId;
    Private  String creds;
   
   	public scheduleMetadataRetrieveStatus(String asyncId,String credentials){
        asyncResultId = asyncId;
       	creds = credentials;
    }
    
    Public void execute(SchedulableContext sc){
        system.debug('asyncId inside schedule retrieve status class ?>>');
        system.debug(this.asyncResultId);
        MetadataRetriever.checkRetrieveStatus(this.asyncResultId,this.creds);
    }
}