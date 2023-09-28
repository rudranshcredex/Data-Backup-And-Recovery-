/******************************************************************************
* Author: Dhanik Lal Sahni
* Date: Oct 8, 2019
* Descpription: AWS Service for uploading file

*/
public with sharing class AWSService {
    
    public string awsKey {get;set;}
    public string awsSecret {get;set;}
    public string bucketName {get;set;}
    public string methodName {get;set;}
    public string hostName {get;set;}
    
    public AWSService(string key, string secret, string bucket, string method, string host)
    {
        awsKey=key;
        awsSecret=secret;
        bucketName=bucket;
        methodName=method;
        hostName=host; // value pattern =>     {bucketName}.S3.{regionName}.amazonaws.com
    }
    
    public string ContentType(string fileType)
    {
        switch on fileType.toLowerCase()
        {
            when 'docx'
            {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'csv'
            {
                return 'application/vnd.ms-excel';
            }
            when 'wav'
            {
                return 'audio/wav';
            }
            when 'wmv'
            {
                return 'video/x-ms-wmv';
            }
            when 'mp3'
            {
                return 'audio/mpeg';
            }
            when 'mp4'
            {
                return 'video/mp4';
            }
            when 'png'
            {
                return 'image/png';
                
            }
            when 'pdf'
            {
                return 'application/pdf';
                
            }
            when else {
                return 'image/jpeg';
            }
        }
    }
    
    public string CreateAuthHeader(String contentType,
                                   String filename, String formattedDateString,string fileExtension){
                                       string auth;
                                       //String stringToSign = this.methodName+'\n\n\n'+formattedDateString+'\n/'+this.bucketName+'/'+filename.toLowerCase()+ '.'+fileExtension.toLowerCase();
                                       String stringToSign = this.methodName+'\n\n'+contentType+'\n'+formattedDateString+'\n/'+this.bucketName+'/'+filename.toLowerCase()+ '.'+fileExtension.toLowerCase();
                                      // String stringToSign = this.methodName+'\n\n'+formattedDateString+'\n/'+this.bucketName+'/'+filename.toLowerCase()+ '.'+fileExtension.toLowerCase();
                                       Blob mac = Crypto.generateMac('AWS4-HMAC-SHA256', blob.valueof(stringToSign),blob.valueof(this.awsSecret));
                                       String sig = EncodingUtil.base64Encode(mac);
                                       auth = 'AWS' + ' ' + this.awsKey + ':' + sig;
                                      // auth = 'AWS' + this.awsKey + ':' + sig;
                                       return auth;
                                       //HMAC-SHA256
                                       //HMACSHA1
                                       //AWS4-HMAC-SHA256
                                   }
    
    
    public void UploadDocuments(string recordId)
    {
        if(string.isBlank(this.awsSecret) || string.isBlank(this.awsKey) || string.isBlank(this.bucketName) || string.isBlank(this.hostName))
        {
           // throw new BaseException('Set AWS credential');
           //system.debug(ex.getMessage()+' at '+ex.getLineNumber());
           system.debug('error at 85');
        }
        List<ContentDocumentLink> links=[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId=:recordId];
        Set<Id> ids=new Set<Id>();
        for(ContentDocumentLink link:links)
        {
            ids.add(link.ContentDocumentId);
        }
        List<ContentVersion> versions=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId = :ids AND IsLatest = true];
        
        for(ContentVersion attach:versions)
        {
            try
            {
                system.debug('content version'+attach);
                //File Content
                String attachmentBody = EncodingUtil.base64Encode(attach.VersionData);
                system.debug('version data '+attach.VersionData);
                String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
              //  String formattedDateString = Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
               // String dateStamp = formattedDateString.substring(0,8);
                    
                String filename = attach.Title;
                string contentType=ContentType(attach.FileExtension);
                system.debug('contentType:'+contentType);
                
                string fileUrl='https://' + this.bucketName + '.' + this.hostName + '/' + filename.toLowerCase()+ '.'+attach.FileExtension.toLowerCase();
                	
                HttpRequest req = new HttpRequest();
                req.setMethod(this.methodName);
                req.setEndpoint(fileurl);
               // req.setHeader('Host', this.bucketName + '.' + this.hostName);
                req.setHeader('Host',this.hostName);
                req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
                req.setHeader('Content-Encoding', 'UTF-8');
                //req.setHeader('Content-Encoding', 'base64');
                req.setHeader('Content-type', contentType);
                req.setHeader('Connection', 'keep-alive');
                
                //extra headers
                req.setHeader('x-amz-acl', 'public-read');
				req.setHeader('x-amz-storage-class', 'STANDARD_IA');
                //req.setHeader('X-Amz-Algorithm','AWS4-HMAC-SHA256');
                
                
                req.setHeader('Date', formattedDateString);
               // req.setHeader('ACL', 'public-read-write');
                Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
            	req.setBodyAsBlob(pdfBlob);
                   
                req.setHeader('Authorization',CreateAuthHeader(contentType, filename, formattedDateString,attach.FileExtension));
                req.setHeader('signatureVersion','V4');
                system.debug('auth header'+CreateAuthHeader(contentType, filename, formattedDateString,attach.FileExtension));
                system.debug('request'+req);
                Http http = new Http();
                
                HTTPResponse res = http.send(req);
                system.debug('res'+res);
                system.debug('response body'+res.getBody());
                if (res.getStatusCode() == 200 || res.getStatusCode()==201) 
                {
                   
                    system.debug('response'+res.getBody());
                }
            }
            catch(Exception ex)
            {
               //throw new BaseException(ex);
               system.debug(ex.getMessage()+' at '+ex.getLineNumber());
            }
        }
    }
    
}