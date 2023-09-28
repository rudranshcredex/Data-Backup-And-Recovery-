/*
 		@Developer Name => Nikhil Garg
		@description => This Schedule class is use to send Emails of data recovery to the users
*/

public With Sharing class scheduleDataRecovery implements Schedulable{

    
    /*
@description => This method is use to send Emails to the users for the Data Recovery
*/
    Public static void execute(system.SchedulableContext sc){
        ContentVersion versionDatas = [select id,Title,ContentDocumentId,versionData from ContentVersion where title='Data recovery' Limit 1];
        String response =  EmailAndNotification.sendEmailToCurrentUser(versionDatas.versionData, 'Data Recovery');
        if(response =='Success'){
            delete (new ContentDocument(Id=versionDatas.ContentDocumentId));
        }
    }
}