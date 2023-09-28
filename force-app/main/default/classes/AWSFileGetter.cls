// Apex class to access AWS S3 using Named Credentials
public class AWSFileGetter {

    // Method to list all files in the S3 bucket
    public static List<String> listFilesInBucket(String bucketName) {
        List<String> fileList = new List<String>();
        
        // Replace 'MyNamedCredential' with the API name of your Named Credential
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:s3WithMetadataType/');
        req.setMethod('GET');
        
        // Perform the HTTP request
        HttpResponse res = new Http().send(req);
        system.debug('response>>>');
        system.debug(res);
        //system.debug(res.getBody());
        // Parse the response and extract the file names
         
       if (res.getStatusCode() == 200) {
            Dom.Document doc = res.getBodyDocument();
            Dom.XmlNode rootNode = doc.getRootElement();
            List<Dom.XmlNode> contentsNodes = rootNode.getChildElements();
            
            for (Dom.XmlNode contentsNode : contentsNodes) {
                if (contentsNode.getName() == 'Contents' && contentsNode.getNamespace() == 'http://s3.amazonaws.com/doc/2006-03-01/') {
                Dom.XmlNode keyNode = contentsNode.getChildElement('Key', 'http://s3.amazonaws.com/doc/2006-03-01/');
                if (keyNode != null) {
                    fileList.add(keyNode.getText());
                }
                }
               // contentsNode = contentsNode.getNextElement(); // Move to the next <Contents> node
            }
        } else {
            // Handle error response
            System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getStatus());
        }        
        system.debug('fileList');
        system.debug(fileList);
        system.debug(fileList.size());
        return fileList;
    }
    
    @RemoteAction
    Public static blob getFileData(String bucketName, String FileKey){
        string base64Data;
        blob blobdata;
        HttpRequest req = new HttpRequest();
        // Replace 'MyNamedCredential' with the API name of your Named Credential
        req.setEndpoint('callout:AWSSignature/' + EncodingUtil.urlEncode(fileKey, 'UTF-8'));
        req.setMethod('GET');
       // req.setHeader('Content-type', 'application/zip');
        // Perform the HTTP request
        HttpResponse res = new Http().send(req);
        system.debug('response>>>>>>>'+res);
         if (res.getStatusCode() == 200) {
             //system.debug(res.getBody());
             //system.debug(res.getHeaderKeys());
             //system.debug(res.getHeader('Content-type'));
             blobdata=res.getBodyAsBlob();
             //system.debug('data as blob'+blobdata);
           //  Blob blobData = (res.getBody());
           //system.debug(JSON.serialize(res.getBody()));
             Blob zipFileBlob=Blob.valueOf(res.getBody());
             system.debug('zipFileBlob>>>>>>>>>>>>>>>'+zipFileBlob);
         	 base64Data = EncodingUtil.base64Encode(zipFileBlob);
             //system.debug(base64Data);
            // system.debug(blobData);
           // return res.getBody();
        } else {
            // Handle error response
            System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getStatus());
            //return null;
        }
        
        
        try{
        Zippex myzip= new Zippex(blobdata);
        
        for(String fileName: myzip.getFileNames()){
            //system.debug('file fileName>>>>'+fileName);
            
            
            String fileData= myzip.getFile(fileName).toString();
            system.debug('filenames>>>>>'+ fileName);
            system.debug('file data>>>>'+fileData);
        }
        } catch(exception e){
            system.debug('error '+ e.getMessage());
        }
       

      
        

		return blobData;
    }
}