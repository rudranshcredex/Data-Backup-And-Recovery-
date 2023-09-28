/******************************************************************************
  Date: 23 June 2023
* Descpription: AWS Service for uploading file

*/
public class AWSFileService {
    
    public static string ContentType(string fileType)
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
    
  /*  public void UploadDocuments(string recordId)
    {
        Set<Id> ids=new Set<Id>();
        for(ContentDocumentLink link:[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId=:recordId])
        {
            ids.add(link.ContentDocumentId);
        }
        if(ids.isEmpty())
        {
            system.debug('error at 63');
        }
        
        List<ContentVersion> versions=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId = :ids AND IsLatest = true];
        
        //Get Named Credential - get configured s3 url
       // NamedCredential named=[SELECT id,DeveloperName, Endpoint FROM NamedCredential where DeveloperName='AWSSignature'];
        
        for(ContentVersion attach:versions)
        {
            try
            { 
                //system.debug(typeof(attach.VersionData));
            
                String attachmentBody = EncodingUtil.base64Encode(attach.VersionData);
              //  system.debug('type'+type(attach.VersionData));
                String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
                string contentType=ContentType(attach.FileExtension); 
                HttpRequest req = new HttpRequest(); 
                req.setMethod('PUT');
                req.setEndpoint('callout:AWSSignature'+'/'+attach.Title.toLowerCase()+ '.'+attach.FileExtension.toLowerCase());   
                req.setHeader('Content-type', contentType);
             // req.setEndpoint('callout:AWSSignature +/+attach.Title.replaceAll([^a-zA-Z0-9\\s+],-).toLowerCase()+ .+attach.FileExtension.toLowerCase());
                Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
              //  system.debug('type'+type(pdfBlob));
                req.setBodyAsBlob(pdfBlob);
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                
                if (res.getStatusCode() == 200 || res.getStatusCode()==201) 
                {
                   system.debug('successfull');
                }
            }
            catch(Exception ex)
            {
                //throw new BaseException(ex);
                system.debug(ex.getMessage()+' at '+ex.getLineNumber());
            }
        }
    }*/
    
   // @auraEnabled(cacheable=true)
    //public static void uploadCSV(String csvString, String apiName){
     @auraEnabled(cacheable=true)
    public static String uploadCSV(String ZipData){
        String responseMessage;
        //system.debug('csv string'+csvString);
            try
            {    
            	//system.debug('csv string');
                //system.debug(csvString);
                blob blobData=EncodingUtil.base64Decode(ZipData);
                String attachmentBody = EncodingUtil.base64Encode(blobData);
                //blob blobData=EncodingUtil.base64Decode(ZipData);
                system.debug('blobdata>>>>>>>>');
                system.debug(blobData);
                system.debug(ZipData);
                system.debug('zipdata>>>>>>>>'+Blob.valueOf(ZipData));
                 //String attachmentBody = EncodingUtil.base64Encode(Blob.valueOf(ZipData));
                system.debug('attachmentBody>>>>>>>>>>');
                system.debug(attachmentBody);
                String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
               
                HttpRequest req = new HttpRequest(); 
                req.setMethod('PUT');
                req.setEndpoint('callout:AWSSignature'+'/'+'testData4'+'.zip');   
                req.setHeader('Content-type', 'application/zip');
             // req.setEndpoint('callout:AWSSignature +/+attach.Title.replaceAll([^a-zA-Z0-9\\s+],-).toLowerCase()+ .+attach.FileExtension.toLowerCase());
                Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
              //  system.debug('type'+type(pdfBlob));
              	system.debug('pdfblob'+pdfBlob);
                req.setBodyAsBlob(pdfBlob);
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                system.debug('response>>>>');
                system.debug(res);
                
                if (res.getStatusCode() == 200 || res.getStatusCode()==201) 
                {
                    responseMessage = 'Your Data is Successfully Uploaded to s3 Account';
                   system.debug('successfull');
                    system.debug(res.getBody());
                }
            }
            catch(Exception ex)
            {
                //throw new BaseException(ex);
                system.debug(ex.getMessage()+' at '+ex.getLineNumber());
            }
        
        return responseMessage;
    }
      /* public static void getNamedCredentials(){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        
        //List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>{new MetadataService.ListMetadataQuery{type_x = 'NamedCredential'}};
           MetadataService.ListMetadataQuery query =new MetadataService.ListMetadataQuery(type_x = 'NamedCredential');
           List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
           queries.add(query);
           //query.type_x=
        List<MetadataService.FileProperties> filePropsList = service.listMetadata(queries, 54.0).getFileProperties();
        
        if (filePropsList != null && !filePropsList.isEmpty()) {
            String namedCredentialFullName = filePropsList[0].fullName;
        
            MetadataService.Metadata[] metadata = service.readMetadata('NamedCredential', new String[] { namedCredentialFullName }).getRecords();
        
            if (metadata != null && !metadata.isEmpty()) {
                MetadataService.NamedCredential namedCredentialMetadata = (MetadataService.NamedCredential)metadata[0];
        
                String awsAccessKeyId = namedCredentialMetadata.awsKeyId;
                String awsAccessSecret = namedCredentialMetadata.awsSecretAccessKey;
        
                System.debug('AWS Access Key ID: ' + awsAccessKeyId);
                System.debug('AWS Access Secret: ' + awsAccessSecret);
            }
        }

    }*/
}