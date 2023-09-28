/******************************************************************************
* Author: Nikhil Garg
* Date: June 21, 2023
* Descpription: AWS Service for uploading file

*/
public WITH SHARING class AwsAllFiles {
    
    public string awsKey {get;set;}
    public string awsSecret {get;set;}
    public string bucketName {get;set;}
    public string methodName {get;set;}
    public string hostName {get;set;}
    Public String algorithm='AWS4-HMAC-SHA256';
    Public String service='s3';
    Public String regionName {get;set;}
     Public static List<String> Files=new List<String>();
    
    public AwsAllFiles(string key, string secret, string bucket, String region, string method, string host)
    {
        awsKey=key;
        awsSecret=secret;
        bucketName=bucket;
        regionName=region;
        methodName=method;
        hostName=host; // value pattern =>     {bucketName}.S3.{regionName}.amazonaws.com
    }
    
    private string CreateAuthHeader(String fileKey, String formattedDateString,String longDate,String dateStamp )
    {
        //'\n/' + fileKey+
        String canonicalRequest = this.methodName +'\n' + '/'+ '\n\n'+'date:'+ longDate + '\n' +'host:'+ this.bucketName+'.s3'+'.'+this.RegionName+'.amazonaws.com' + '\n' +'x-amz-content-sha256:UNSIGNED-PAYLOAD'+'\n'+'x-amz-date:'+formattedDateString +'\n\n'+'date;host;x-amz-content-sha256;x-amz-date'+'\n'+'UNSIGNED-PAYLOAD';
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
       
        try
            {
                
                String longDate = Datetime.now().formatGMT('E, dd MMM yyyy HH:mm:ss z');                
                String formattedDateString = Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');              
                String dateStamp = Datetime.now().formatGMT('yyyyMMdd');
 
               	string fileUrl='https://' + this.bucketName + '.' + this.hostName;
                
                HttpRequest req = new HttpRequest();
                req.setMethod(this.methodName);
                req.setEndpoint(fileurl);
                
                req.setHeader('host',this.bucketName+'.s3'+'.'+this.regionName+'.amazonaws.com');
                req.setHeader('Connection', 'keep-alive');
				req.setHeader('date', longDate);
                req.setHeader('x-amz-date', formattedDateString);
                req.setHeader('x-amz-content-sha256','UNSIGNED-PAYLOAD');
                req.setHeader('Authorization',CreateAuthHeader( 'signature.jpg', formattedDateString,longDate,dateStamp));
                
                Http http = new Http();
                
                HTTPResponse res = http.send(req);
                system.debug('res'+res);
              
                if (res.getStatusCode() == 200 || res.getStatusCode()==201) 
                {
                   
                    system.debug('response'+res.getBody());
                    Dom.Document doc = new Dom.Document();
                     doc.load(res.getbody());
                    Dom.XmlNode rootNode = doc.getRootElement();
                    for(Dom.XmlNode childElement:rootNode.getChildElements()){
                        for(Dom.XmlNode detailElement:childElement.getChildElements()){
                       
                            if(detailElement.getName()=='Key'){
                                Files.add(detailElement.getText());
                            }
                        
                        }
            }
                    system.debug('Files>>>>>>>>>>>>>>>'+Files);
                }
            }
            catch(Exception ex)
            {
               //throw new BaseException(ex);
               system.debug(ex.getMessage()+' at '+ex.getLineNumber());
            }
        
    }
    
}