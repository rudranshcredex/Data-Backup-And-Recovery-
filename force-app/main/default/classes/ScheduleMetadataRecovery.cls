public With Sharing class ScheduleMetadataRecovery implements schedulable{
    
    Private static String AsyncId;
    Public ScheduleMetadataRecovery(String AsyncResultId){
        AsyncId = AsyncResultId;
    }
    Public static void execute(SchedulableContext sc){
        MetadataRecovery.CheckDeployStatus(AsyncId);
    }
}