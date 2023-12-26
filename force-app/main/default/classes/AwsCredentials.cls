/*
@description => This class is use to save and fetch the Aws credentials to custom settings.
*/
public With Sharing class AwsCredentials {
    
    /*
@description => This method is called from LWC Component and call future method to save aws creds
*/
    @AuraEnabled(cacheable=true)
    public static void saveCred(String AccessKey, String SecretKey, String RegionName, String credName){
        MetadataCreation.createCustomMetadata(credName,AccessKey,SecretKey,RegionName);
    }
    
    /*
@description => This method is use to fetch saved creds based from custom Metadata
*/
    @AuraEnabled
    Public static List<AwsCredential__mdt> getCredentails(){
        return  [SELECT Id,DeveloperName,label,AccessKey__c,SecretKey__c,Region_Name__c FROM AwsCredential__mdt WHERE Active__c = true WITH SECURITY_ENFORCED Limit 1000];
    }
    
    /*
@description => This method is use to fetch saved creds based from custom metadata based on name
*/
    @AuraEnabled(cacheable=true)
    Public static AwsCredential__mdt getCredentailsOnName(String name){
        AwsCredential__mdt CustomMetadata ;
        try{
            
            CustomMetadata =  [SELECT Id,DeveloperName,AccessKey__c,SecretKey__c,Region_Name__c FROM AwsCredential__mdt Where DeveloperName=:name AND Active__c = true WITH SECURITY_ENFORCED Limit 1];
        }
        catch(Exception ex){
            //system.debug(ex.getMessage());
        }
        return CustomMetadata;
    }
}