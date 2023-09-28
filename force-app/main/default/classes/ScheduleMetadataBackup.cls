public with sharing class ScheduleMetadataBackup implements Schedulable {

    Private  List<String> metadataTypesToBackup=new List<String>();
    Private  String creds;
    /*public ScheduleMetadataBackup(List<String> metadataTypes){
        metadataTypesToBackup = metadataTypes;
       	
    }*/
    Public ScheduleMetadataBackup(List<String> metadataTypes,String credentials){
        this.metadataTypesToBackup = metadataTypes;
        this.creds = credentials;
        system.debug('in const');
        system.debug(this.creds);
    }
    
    public void execute(SchedulableContext sc){
        system.debug('execute');
        system.debug(this.creds);
        MetadataRetriever.callRetrieveMethod(this.metadataTypesToBackup,this.creds);
    }
}