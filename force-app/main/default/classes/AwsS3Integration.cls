/******************************************************************************
* Author: Nikhil Garg
* Date: June 21, 2023
* Descpription: AWS Service for uploading and fetching files & buckets Data
*/
public WITH SHARING class AwsS3Integration {
    
    private static String awsKey {get;set;}
    private static String awsSecret {get;set;}
    private static String bucketName {get;set;}
    private static String methodName {get;set;}
    private static String hostName = 's3.amazonaws.com';
    private static String algorithm='AWS4-HMAC-SHA256';
    private static String service='s3';
    Private static String regionName {get;set;}
    Private static List<String> buckets=new List<String>();
    Private static List<String> Files=new List<String>();
    
    
    /*
@description => This method is use to create Auth header to fetch the Buckets and files
*/
    private static string CreateAuthHeader(String type,String formattedDateString,String longDate,String dateStamp )
    {
        String canonicalRequest;
        if(type=='Buckets'){
            canonicalRequest = methodName +'\n' + '/'+'\n\n'+'date:'+ longDate + '\n' +'host:'+'s3'+'.'+regionName+'.amazonaws.com' + '\n' +'x-amz-content-sha256:UNSIGNED-PAYLOAD'+'\n'+'x-amz-date:'+formattedDateString +'\n\n'+'date;host;x-amz-content-sha256;x-amz-date'+'\n'+'UNSIGNED-PAYLOAD';
        }
        if(type=='Files'){
            canonicalRequest = methodName +'\n' + '/'+ '\n\n'+'date:'+ longDate + '\n' +'host:'+ bucketName+'.s3'+'.'+RegionName+'.amazonaws.com' + '\n' +'x-amz-content-sha256:UNSIGNED-PAYLOAD'+'\n'+'x-amz-date:'+formattedDateString +'\n\n'+'date;host;x-amz-content-sha256;x-amz-date'+'\n'+'UNSIGNED-PAYLOAD';
        }
        system.debug(canonicalRequest);
        
        Blob canonicalHash = Crypto.generateDigest('SHA-256', Blob.valueof(canonicalRequest));
        String canonicalHashString = EncodingUtil.convertToHex(canonicalHash);
        
        String stringToSign = algorithm + '\n' + formattedDateString + '\n' + dateStamp + '/' + regionName + '/'+ service + '/aws4_request\n' + canonicalHashString;
        
        String kSecret = 'AWS4' + awsSecret;
        Blob kDate = Crypto.generateMac('HmacSHA256', Blob.valueOf(dateStamp), Blob.valueOf(kSecret));
        Blob kRegion = Crypto.generateMac('HmacSHA256', Blob.valueOf(regionName), kDate);
        Blob kService = Crypto.generateMac('HmacSHA256', Blob.valueOf(service), kRegion);
        Blob kSigning = Crypto.generateMac('HmacSHA256', Blob.valueOf('aws4_request'), kService);
        Blob blobSignature  = Crypto.generateMac('HmacSHA256', Blob.valueOf(stringToSign), kSigning);
        
        string signature=EncodingUtil.convertToHex(blobSignature );
        string headersInSignature='date;host;x-amz-content-sha256;x-amz-date';
        system.debug('CreateAuthHeader return --->'+(algorithm + ' Credential=' + awsKey + '/' + dateStamp + '/' + regionName + '/' + service + '/aws4_request, SignedHeaders='+headersInSignature+', Signature=' + signature));
        return (algorithm + ' Credential=' + awsKey + '/' + dateStamp + '/' + regionName + '/' + service + '/aws4_request, SignedHeaders='+headersInSignature+', Signature=' + signature);
    }
    
    
    /*
@description => This method is use to create Auth header to fetch the data of given file
*/
    private static string CreateAuthHeaderForFileKey(String fileKey, String formattedDateString, String longDate,String dateStamp )
    {
        String canonicalRequest = methodName + '\n/' + fileKey+'\n\n'+'date:'+ longDate + '\n' +'host:'+ bucketName+'.s3'+'.'+RegionName+'.amazonaws.com' + '\n' +'x-amz-content-sha256:UNSIGNED-PAYLOAD'+'\n'+'x-amz-date:'+formattedDateString +'\n\n'+'date;host;x-amz-content-sha256;x-amz-date'+'\n'+'UNSIGNED-PAYLOAD';
        Blob canonicalHash = Crypto.generateDigest('SHA-256', Blob.valueof(canonicalRequest));
        String canonicalHashString = EncodingUtil.convertToHex(canonicalHash);
        
        String stringToSign = algorithm + '\n' + formattedDateString + '\n' + dateStamp + '/' + regionName + '/' + service + '/aws4_request\n' + canonicalHashString;
        
        String kSecret = 'AWS4' + awsSecret;
        Blob kDate = Crypto.generateMac('HmacSHA256', Blob.valueOf(dateStamp), Blob.valueOf(kSecret));
        
        Blob kRegion = Crypto.generateMac('HmacSHA256', Blob.valueOf(regionName), kDate);
        Blob kService = Crypto.generateMac('HmacSHA256', Blob.valueOf(service), kRegion);
        Blob kSigning = Crypto.generateMac('HmacSHA256', Blob.valueOf('aws4_request'), kService);
        Blob blobSignature  = Crypto.generateMac('HmacSHA256', Blob.valueOf(stringToSign), kSigning);
        
        string signature=EncodingUtil.convertToHex(blobSignature );
        string headersInSignature='date;host;x-amz-content-sha256;x-amz-date';
        return (algorithm + ' Credential=' + awsKey + '/' + dateStamp + '/' + regionName + '/' + service + '/aws4_request, SignedHeaders='+headersInSignature+', Signature=' + signature);
    }
    
    /*
@description => This method is use to create Auth header to upload data 
*/
    Private static string CreateAuthHeaderForPUT(String contentType,String filename, String formattedDateString,String longDate,string fileExtension,blob content,String dateStamp )
    {
        Blob  contentHash = Crypto.generateDigest('SHA-256', content);
        String hashedPaylod = EncodingUtil.convertToHex(contentHash);
        String canonicalRequest = methodName + '\n/' + filename.toLowerCase() + '.' + fileExtension.toLowerCase() +'\n\n'+'date:'+ longDate + '\n' +'host:'+ bucketName+'.s3'+'.'+RegionName+'.amazonaws.com' + '\n' +'x-amz-content-sha256:'+hashedPaylod+'\n'+'x-amz-date:'+formattedDateString +'\n\n'+'date;host;x-amz-content-sha256;x-amz-date'+'\n'+hashedPaylod;
        
        Blob canonicalHash = Crypto.generateDigest('SHA-256', Blob.valueof(canonicalRequest));
        String canonicalHashString = EncodingUtil.convertToHex(canonicalHash);        
        String stringToSign = algorithm + '\n' + formattedDateString + '\n' + dateStamp + '/' + regionName + '/' + service + '/aws4_request\n' + canonicalHashString;
        
        String kSecret = 'AWS4' + awsSecret;
        Blob kDate = Crypto.generateMac('HmacSHA256', Blob.valueOf(dateStamp), Blob.valueOf(kSecret));
        Blob kRegion = Crypto.generateMac('HmacSHA256', Blob.valueOf(regionName), kDate);
        Blob kService = Crypto.generateMac('HmacSHA256', Blob.valueOf(service), kRegion);
        Blob kSigning = Crypto.generateMac('HmacSHA256', Blob.valueOf('aws4_request'), kService);
        Blob blobSignature  = Crypto.generateMac('HmacSHA256', Blob.valueOf(stringToSign), kSigning);
        
        string signature=EncodingUtil.convertToHex(blobSignature );
        string headersInSignature='date;host;x-amz-content-sha256;x-amz-date';                     
        
        return (algorithm + ' Credential=' + awsKey + '/' + dateStamp + '/' + regionName + '/' + service + '/aws4_request, SignedHeaders='+headersInSignature+', Signature=' + signature);
    }
    
    
    /*
@description => This method is use to fetch buckets of Aws s3
*/
    @auraEnabled(cacheable=true)
    public static List<String> getBuckets(string accessKey, String secretKey,String awsRegion)
    {
        awsKey = accessKey;
        awsSecret = secretKey;
        regionName = awsRegion;
        methodName = 'GET';
        String remoteSiteSettingName ='AwsBucket';
        String exceptionMessage ='Exception';
        try
        {
            String longDate = Datetime.now().formatGMT('E, dd MMM yyyy HH:mm:ss z');                
            String formattedDateString = Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');              
            String dateStamp = Datetime.now().formatGMT('yyyyMMdd');
            
            string fileUrl='https://'+'s3.'+regionName+'.amazonaws.com/';
            
            MetadataCreation.createRemoteSiteSetting(remoteSiteSettingName,fileUrl);
            HttpRequest req = new HttpRequest();
            req.setMethod(methodName);
            req.setEndpoint(fileurl);
            
            req.setHeader('host', 's3.'+regionName+'.amazonaws.com');
            req.setHeader('content-type', 'application/xml');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('date', longDate);
            req.setHeader('x-amz-date', formattedDateString);
            req.setHeader('x-amz-content-sha256','UNSIGNED-PAYLOAD');
            req.setHeader('Authorization',CreateAuthHeader('Buckets',formattedDateString,longDate,dateStamp));
            
            Http http = new Http();
            
            HTTPResponse response = http.send(req);
            
            if (response.getStatusCode() == 200 || response.getStatusCode()==201) 
            {
                Dom.Document doc = new Dom.Document();
                doc.load(response.getbody());
                Dom.XmlNode rootNode = doc.getRootElement();
                
                for(Dom.XmlNode childElement:rootNode.getChildElements())
                {
                    for(Dom.XmlNode detailElement:childElement.getChildElements())
                    {
                        for(Dom.XmlNode detailElement1:detailElement.getChildElements()){
                            if(detailElement1.getName()=='Name'){
                                Buckets.add(detailElement1.getText());
                            }
                        }
                    }
                }
            }
            else if(response.getStatusCode() == 403){
                Dom.Document doc = new Dom.Document();
                doc.load(response.getbody());
                Dom.XmlNode rootNode = doc.getRootElement();
                for(Dom.XmlNode childElement:rootNode.getChildElements()){
                    if(childElement.getName()=='Code'){
                        exceptionMessage =childElement.getText();
                        throw new AuraHandledException(childElement.getText());
                    }
                    
                }
            }
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
            throw new AuraHandledException(exceptionMessage);
        }
        MetadataCreation.deleteRemoteSiteSetting(remoteSiteSettingName); 
        
        return Buckets;
    }
    
    /*
@description => This method is use to fetch files for a given Bucket of Aws s3
*/
    @auraEnabled
    public static List<String> getFiles(string accessKey, String secretKey,String awsRegion, String bucket)
    {
        awsKey = accessKey;
        awsSecret = secretKey;
        regionName = awsRegion;
        bucketName = bucket;
        methodName = 'GET';
        
        String remoteSiteSettingName = 'AwsFiles';
        
        try
        {
            
            String longDate = Datetime.now().formatGMT('E, dd MMM yyyy HH:mm:ss z');                
            String formattedDateString = Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');              
            String dateStamp = Datetime.now().formatGMT('yyyyMMdd');
            
            string fileUrl='https://' + bucketName + '.' +hostName;
            MetadataCreation.createRemoteSiteSetting(remoteSiteSettingName,fileUrl);
            HttpRequest req = new HttpRequest();
            req.setMethod(methodName);
            req.setEndpoint(fileurl);
            
            req.setHeader('host',bucketName+'.s3'+'.'+regionName+'.amazonaws.com');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('date', longDate);
            req.setHeader('x-amz-date', formattedDateString);
            req.setHeader('x-amz-content-sha256','UNSIGNED-PAYLOAD');
            req.setHeader('Authorization',CreateAuthHeader( 'Files', formattedDateString,longDate,dateStamp));
            system.debug(req);
            Http http = new Http();
            
            HTTPResponse response = http.send(req);
            system.debug('res'+response);
            system.debug(response.getBody());
            
            if (response.getStatusCode() == 200 || response.getStatusCode()==201) 
            {
                
                Dom.Document doc = new Dom.Document();
                doc.load(response.getbody());
                
                Dom.XmlNode rootNode = doc.getRootElement();
                for(Dom.XmlNode childElement:rootNode.getChildElements())
                {
                    for(Dom.XmlNode detailElement:childElement.getChildElements())
                    {
                        
                        if(detailElement.getName()=='Key'){
                            Files.add(detailElement.getText());
                        }
                        
                    }
                }
            }
        }
        catch(Exception ex)
        {
            //throw new BaseException(ex);
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
        
        MetadataCreation.deleteRemoteSiteSetting(remoteSiteSettingName); 
        return Files;
    }
    
    /*
@description => This method is use to fetch file data based on file key
*/
    @auraEnabled
    public static String getFile(string accessKey, String secretKey,String awsRegion, String bucket,String FileKey){
        awsKey = accessKey;
        awsSecret = secretKey;
        regionName = awsRegion;
        bucketName = bucket;
        methodName = 'GET';
        String remoteSiteSettingName = 'AwsFile';
        String FileData;
        
        try
        {
            
            String longDate = Datetime.now().formatGMT('E, dd MMM yyyy HH:mm:ss z');                
            String formattedDateString = Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');              
            String dateStamp = Datetime.now().formatGMT('yyyyMMdd');
            
            string fileUrl='https://' + bucketName + '.' + hostName + '/' +FileKey;
            MetadataCreation.createRemoteSiteSetting(remoteSiteSettingName,fileUrl);
            
            HttpRequest req = new HttpRequest();
            req.setMethod(methodName);
            req.setEndpoint(fileurl);
            
            //Headers for the request
            req.setHeader('host',bucketName+'.s3'+'.'+regionName+'.amazonaws.com');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('date', longDate);
            req.setHeader('content-type', 'application/x-zip-compressed');
            req.setHeader('x-amz-date', formattedDateString);
            req.setHeader('x-amz-content-sha256','UNSIGNED-PAYLOAD');
            req.setHeader('Authorization',CreateAuthHeaderForFileKey( FileKey, formattedDateString,longDate,dateStamp));
            
            Http http = new Http();
            
            HTTPResponse res = http.send(req);
            
            if (res.getStatusCode() == 200 || res.getStatusCode()==201) 
            {
                blob blobData = res.getBodyAsBlob();
                FileData = EncodingUtil.base64Encode(blobData);
            }
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
        MetadataCreation.deleteRemoteSiteSetting(remoteSiteSettingName);
        
        return FileData;
    }    
    
    
    /*
@description => This method is use to upload files to s3 account
*/
    public static String filePUT(String fileName, string accessKey, String secretKey,String awsRegion, String bucket,blob zipData) {
        
        String remoteSiteSettingName = 'uploadFile';
        awsKey = accessKey;
        awsSecret = secretKey;
        regionName = awsRegion;
        bucketName = bucket;
        methodName = 'PUT';
        
        String messageToReturn;
        try
        {
            
            String attachmentBody = EncodingUtil.base64Encode(zipData);
            String longDate = Datetime.now().formatGMT('E, dd MMM yyyy HH:mm:ss z');  
            String formattedDateString = Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
            String dateStamp = Datetime.now().formatGMT('yyyyMMdd');
            
            string fileUrl='https://' + bucketName + '.' + hostName + '/' + filename.toLowerCase()+ '.'+'zip';
            MetadataCreation.createRemoteSiteSetting(remoteSiteSettingName,fileUrl);
            
            HttpRequest req = new HttpRequest();
            req.setMethod(methodName);
            req.setEndpoint(fileurl);
            
            
            req.setHeader('host', bucketName+'.s3'+'.'+regionName+'.amazonaws.com');
            req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));                
            req.setHeader('Content-Encoding', 'UTF-8');
            req.setHeader('Content-type', 'application/zip');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('date', longDate);
            req.setHeader('x-amz-date', formattedDateString);
            
            Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
            req.setBodyAsBlob(pdfBlob); 
            
            String contentHash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', pdfBlob));
            req.setHeader('x-amz-content-sha256',contentHash);
            req.setHeader('Authorization',CreateAuthHeaderForPUT('application/zip', filename, formattedDateString,longDate,'zip',pdfBlob,dateStamp));
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            if (res.getStatusCode() == 200 || res.getStatusCode()==201) 
            {
                messageToReturn = 'success';
            }
            else{
                messageToReturn = 'Error With Code '+res.getStatusCode();
            }
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
            messageToReturn = 'Exception in Code : '+ex.getMessage()+' at '+ex.getLineNumber();
        }
        
        MetadataCreation.deleteRemoteSiteSetting(remoteSiteSettingName); 
        return messageToReturn;
    }
}