/******************************************************************************
* Author: Nikhil Garg
* Date: June 21, 2023
* Descpription: AWS Service for uploading file

*/
public with sharing class Puts3 {
    
    public string awsKey {get;set;}
    public string awsSecret {get;set;}
    public string bucketName {get;set;}
    public string methodName {get;set;}
    public string hostName {get;set;}
    Public String algorithm='AWS4-HMAC-SHA256';
    Public String service='s3';
    Public String regionName {get;set;}
    
    public Puts3(string key, string secret, string bucket, String region, string method, string host)
    {
        awsKey=key;
        awsSecret=secret;
        bucketName=bucket;
        regionName=region;
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
    
    public string CreateAuthHeader(String contentType,String filename, String formattedDateString,String longDate,string fileExtension,blob content,String dateStamp )
    {
		Blob  contentHash = Crypto.generateDigest('SHA-256', content);
        String hashedPaylod = EncodingUtil.convertToHex(contentHash);
        String canonicalRequest = this.methodName + '\n/' + filename.toLowerCase() + '.' + fileExtension.toLowerCase() +'\n\n'+'date:'+ longDate + '\n' +'host:'+ this.bucketName+'.s3'+'.'+this.RegionName+'.amazonaws.com' + '\n' +'x-amz-content-sha256:'+hashedPaylod+'\n'+'x-amz-date:'+formattedDateString +'\n\n'+'date;host;x-amz-content-sha256;x-amz-date'+'\n'+hashedPaylod;
        
        Blob canonicalHash = Crypto.generateDigest('SHA-256', Blob.valueof(canonicalRequest));
    	String canonicalHashString = EncodingUtil.convertToHex(canonicalHash);        
        String stringToSign = this.algorithm + '\n' + formattedDateString + '\n' + dateStamp + '/' + this.regionName + '/' + this.service + '/aws4_request\n' + canonicalHashString;
       
        String kSecret = 'AWS4' + this.awsSecret;
        Blob kDate = Crypto.generateMac('HmacSHA256', Blob.valueOf(dateStamp), Blob.valueOf(kSecret));
        Blob kRegion = Crypto.generateMac('HmacSHA256', Blob.valueOf(this.regionName), kDate);
        Blob kService = Crypto.generateMac('HmacSHA256', Blob.valueOf(this.service), kRegion);
        Blob kSigning = Crypto.generateMac('HmacSHA256', Blob.valueOf('aws4_request'), kService);
        Blob blobSignature  = Crypto.generateMac('HmacSHA256', Blob.valueOf(stringToSign), kSigning);
        
        string signature=EncodingUtil.convertToHex(blobSignature );
		string headersInSignature='date;host;x-amz-content-sha256;x-amz-date';                     
        
        return (this.algorithm + ' Credential=' + this.awsKey + '/' + dateStamp + '/' + this.regionName + '/' + this.service + '/aws4_request, SignedHeaders='+headersInSignature+', Signature=' + signature);
     }
    
    
    public void UploadDocuments(string recordId)
    {
        if(string.isBlank(this.awsSecret) || string.isBlank(this.awsKey) || string.isBlank(this.bucketName) || string.isBlank(this.hostName))
        {
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
                
                String longDate = Datetime.now().formatGMT('E, dd MMM yyyy HH:mm:ss z');  
                String formattedDateString = Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
                String dateStamp = Datetime.now().formatGMT('yyyyMMdd');
                    
                String filename = attach.Title;
                string contentType=ContentType(attach.FileExtension);
                system.debug('contentType:'+contentType);
                
                string fileUrl='https://' + this.bucketName + '.' + this.hostName + '/' + filename.toLowerCase()+ '.'+attach.FileExtension.toLowerCase();
                system.debug('fileurl'+fileurl);
                
                 
                
                HttpRequest req = new HttpRequest();
                req.setMethod(this.methodName);
                req.setEndpoint(fileurl);
               
             
                req.setHeader('host',this.bucketName+'.s3'+'.'+this.regionName+'.amazonaws.com');
                req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));                
                req.setHeader('Content-Encoding', 'UTF-8');
                req.setHeader('Content-type', contentType);
                req.setHeader('Connection', 'keep-alive');
				req.setHeader('date', longDate);
                req.setHeader('x-amz-date', formattedDateString);
                
                Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
            	req.setBodyAsBlob(pdfBlob); 
                
                String contentHash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', pdfBlob));
				req.setHeader('x-amz-content-sha256',contentHash);
                req.setHeader('Authorization',CreateAuthHeader(contentType, filename, formattedDateString,longDate,attach.FileExtension,pdfBlob,dateStamp));
              
                system.debug('request'+req);
                
                Http http = new Http();
                
                HTTPResponse res = http.send(req);
                system.debug('res'+res);
                system.debug('response body'+res.getBody());
                system.debug('response code'+res.getStatusCode());
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