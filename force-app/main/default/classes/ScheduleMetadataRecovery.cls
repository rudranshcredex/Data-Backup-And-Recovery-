/*
 		@Developer Name => Nikhil Garg
		@description => This Schedule class is use to call CheckDeployStatus after certain period of time
*/
public With Sharing class ScheduleMetadataRecovery implements schedulable{
    
    Private String AsyncId;
    Public ScheduleMetadataRecovery(String AsyncResultId){
        AsyncId = AsyncResultId;
    }
    Public void execute(SchedulableContext sc){
        //system.debug(AsyncId);
        MetadataRecovery.CheckDeployStatus(AsyncId);
    }
}