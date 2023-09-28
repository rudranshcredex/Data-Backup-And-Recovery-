public WITH SHARING class MetadataDeploy2 {

    public static void test(string zip){
        //string zipcontent=zip;
        //deploy(zip);
        deploy();
    }
    Public static void deploy(){
       /* Set<Id> ids=new Set<Id>();
        for(ContentDocumentLink link:[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId='0015i00000oYvsvAAC'])
        {
            ids.add(link.ContentDocumentId);
        }
        
        List<ContentVersion> versions=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId = :ids AND IsLatest = true];*/
        
        List<Attachment> attach=[Select id,name,body from attachment where id='00P5i00000RMIHKEA5'];
        String zipFileContent=EncodingUtil.base64Encode(attach[0].body);
       // String zipFileContent=EncodingUtil.base64Encode(versions[0].VersionData);
        
		system.debug('zipFileContent>>>>>>>>>>>>>>>>>>>');
		//system.debug(ZipContent);
        system.debug('file length during deployment');
        system.debug(zipFileContent.length());
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        
        MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();

        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = false;
        deployOptions.singlePackage = true;
        deployOptions.testLevel = 'NoTestRun';
        
        
        system.debug(deployOptions.allowMissingFiles);
        system.debug(deployOptions.autoUpdatePackage);
        system.debug(deployOptions.checkOnly);
        system.debug(deployOptions.singlePackage);
        system.debug(deployOptions.performRetrieve);
        system.debug(deployOptions.rollbackOnError);
        
        try {
        system.debug('inside deploy');
        system.debug(deployOptions);
        MetadataService.AsyncResult result = service.deploy(zipFileContent, deployOptions);
		system.debug('result>>>>>>>>>>>>>>>');
        system.debug(result);
        //checkDeployStatus(result.id);	
        } catch (Exception ex) {
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
            // Handle exceptions
        }
    }
    
     public static void checkDeployStatus(String asyncResultId) {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        
        try {
            MetadataService.DeployResult result = service.checkDeployStatus(asyncResultId,true);
            //return result;
            system.debug(result);
            if(result.done){
                if(result.details!=null && result.details.componentFailures!=null){
                    for(MetadataService.DeployMessage deployMessage : result.details.componentFailures){
                    if(deployMessage.problem!=null){
                        system.debug(deployMessage.fileName);
                        system.debug(deployMessage.lineNumber);
                        system.debug(deployMessage.problem);
                    }
            }
            }
						
                system.debug('done');
                system.debug(result.createdByName);
                system.debug(result.errorMessage);
                system.debug('numberComponentsDeployed>>>>>'+result.numberComponentsDeployed);
                system.debug('numberComponentsTotal>>>>>>>>>>'+result.numberComponentsTotal);
                if(result.numberComponentErrors>0){
                    system.debug('errors>>>>>>'+result.numberComponentErrors);
                }
                
            }
            else{
                system.debug('not completed');
            }
        } catch (Exception e) {
            System.debug('An error occurred while checking deployment status: ' + e.getMessage());
            //return null;
        }
    }
}