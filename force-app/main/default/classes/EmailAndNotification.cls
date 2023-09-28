public With sharing class EmailAndNotification {
    
    Public static String sendEmailToCurrentUser(blob attachmentBody,String AttachmentType){
        
        system.debug('inside email container');
        
        String response;
        String currentDateTime = DateTime.now().format('yyyy/MM/dd hh:mm:ss');
        String Filename;
        try{
            
            if(AttachmentType == 'Data Recovery'){
                Filename = 'DataRecovery Result.csv';
            }
            if(AttachmentType=='Data'){
                Filename = 'Salesforce Data('+currentDateTime+')'+'.zip';
            }
            if(AttachmentType=='MetaData')
            {
                FileName = 'Salesforce Metadata('+currentDateTime+')'+'.zip';
            }
            
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            
            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setFileName(FileName);
            emailAttachment.setBody(attachmentBody);
            
            attachments.add(emailAttachment);
            
            
            Messaging.SingleEmailMessage emailMessage =new Messaging.SingleEmailMessage();
            
            emailMessage.setToAddresses(new List<String>{userinfo.getUserEmail()});
            
            if(AttachmentType=='MetaData'){
                EmailTemplate emailTemplate = [select id,name from EmailTemplate where name='MetadataBackup' LIMIT 1];
                emailMessage.setTemplateId(emailTemplate.id);
            }
            if(AttachmentType=='Data Recovery'){
                emailMessage.setPlainTextBody('Hi '+userinfo.getName()+','+'\n\n'+'Please find the attached file contains result of the Data Recovery as Requested'+'\n\n'+'Thanks \nTeamCredex');
                emailMessage.setSubject('Data Recovery');
            }
            
            if(AttachmentType=='Data'){
                EmailTemplate emailTemplate = [select id,name from EmailTemplate where name='data_backup' LIMIT 1];
                system.debug(emailTemplate);
                system.debug('emailTemplate');
                emailMessage.setTemplateId(emailTemplate.id);
            }
            system.debug('inside email user id '+userinfo.getUserId());
            system.debug(userinfo.getUserEmail());
            emailMessage.setFileAttachments(attachments);
            emailMessage.targetobjectid = userinfo.getUserId();
            emailMessage.setSaveAsActivity(false);
            List<Messaging.sendEmailResult> emailResult = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMessage});
            system.debug(emailResult);
            for(Messaging.sendEmailResult result:emailResult){
                
                if(result.isSuccess()){
                    system.debug('Email sent Successfully');
                    response = 'Success';
                }
                else{  
                    response = 'Error';
                    for(Messaging.sendEmailError error: result.getErrors()){
                        response = error.getMessage();
                        system.debug(error.getMessage());
                        system.debug(error.getStatusCode());
                    }
                }
            }
        } 
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        
        return response;
    }
    
    Public static String sendMetadataRecoveryResultEmail(String resultBody){
        System.debug(resultBody);
        String response;
        Map<String,object> recoveryResponse = (Map<String,object>)JSON.deserializeUntyped(resultBody);
        
        Messaging.SingleEmailMessage emailMessage =new Messaging.SingleEmailMessage();
        
        emailMessage.setToAddresses(new List<String>{userinfo.getUserEmail()});
        emailMessage.setSubject('Credex Metadata Recovery');
        
        String Body = 'Hi '+userinfo.getName()+'\n\n'
            +'Please find the Deatils about Recovery of Metadata  :'+'\n\n'
            +'Total Number of Components : '+recoveryResponse.get('numberComponentsTotal')+'\n'
            +'Number of Components Deployed : '+recoveryResponse.get('numberComponentsDeployed')+'\n'
            +'Number of Components Errors : '+recoveryResponse.get('numberComponentErrors')+'\n'
            +'Number of Test Errors : '+recoveryResponse.get('numberTestErrors')+'\n'
            +'Number of Test Completed : '+recoveryResponse.get('numberTestsCompleted')+'\n'
            +'Success : '+recoveryResponse.get('isSuccess')+'\n\n'
            +'Best regards,'+'\n'
            +'Team credex';
        
        emailMessage.setPlainTextBody(Body);
        List<Messaging.sendEmailResult> emailResult = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMessage});
        
        for(Messaging.sendEmailResult result:emailResult){
            
            if(result.isSuccess()){
                system.debug('Email sent Successfully');
                response = 'Success';
            }
            else{  
                response = 'Error';
                for(Messaging.sendEmailError error: result.getErrors()){
                    system.debug(error.getMessage());
                    system.debug(error.getStatusCode());
                }
            }
        }
        system.debug('response'+response);
        return response;
    }
    
    Public static void sendCustomNotification(String NotificationType,String service){
        CustomNotificationtype customNotification = [SELECT ID FROM CustomNotificationtype WHERE DeveloperName='BackupNotification' LIMIT 1];
        Messaging.CustomNotification cstmNotifn = new Messaging.CustomNotification();
        if(NotificationType == 'Data'){
            if(service == 'Local'){
                cstmNotifn.setTitle('Your Data Backup is successfully completed and sent to your Email.');
            }
            if(service == 'Aws'){
                cstmNotifn.setTitle('Your Data Backup is successfully completed Kindly check your AWS Account.');
            }
            
        }
        if(NotificationType == 'MetaData'){
            if(service == 'Local'){
                cstmNotifn.setTitle('Your MetaData Backup is successfully completed and  sent to your Email.');
            }
            if(service == 'Aws'){
                cstmNotifn.setTitle('Your Data Backup is successfully completed Kindly check your AWS Account.');
            }
        }
        
        if(NotificationType == 'MetadataRecovery'){
            cstmNotifn.setTitle('Your MetaData is Recovered Successfully and results are successfully sent over Email');
        }
        
        cstmNotifn.setNotificationTypeId(customNotification.id);
        cstmNotifn.setBody('Backup Successfull');
        cstmNotifn.setTargetId('0015i00000oYvsvAAC');
        //cstmNotifn.setTargetId(targetId);
        try{
            cstmNotifn.send(new Set<String>{userinfo.getUserId()});
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
}