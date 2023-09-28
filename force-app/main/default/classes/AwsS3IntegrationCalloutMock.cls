@isTest
Public class AwsS3IntegrationCalloutMock implements HttpCalloutMock {
    Private string scenario;
    
    Public AwsS3IntegrationCalloutMock(String Context){
        this.scenario = Context;
    } 
    
    Public HttpResponse respond(HTTPRequest request) {
        
        HttpResponse response = new HttpResponse(); 
        response.setHeader('Content-Type', 'application/xml');
        response.setStatusCode(200);
        
        if(scenario == 'BucketsSuccess'){
            
            response.setBody(getPositiveBucketResponse());
            
        }
        if(scenario == 'BucketsError'){
            
            response.setBody(getNegativeBucketResponse());
            response.setStatusCode(403);
        }
        
        if(scenario == 'Files'){
            
            response.setBody(generateResposneForFiles());
        }
        
        if(scenario == 'File'){
            
            response.setBody('test Data');
        }
        
        return response;
    }
    
    private static string getPositiveBucketResponse(){
        return '<ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><Buckets><Bucket><Name>buctest143</Name><CreationDate>2023-05-25T09:30:23.000Z</CreationDate></Bucket><Bucket><Name>createtestbuk</Name><CreationDate>2023-06-20T10:40:30.000Z</CreationDate></Bucket></Buckets></ListAllMyBucketsResult>';
    }
    
    private static string getNegativeBucketResponse(){
        return 	'<Error>'
            +'<Code>InvalidAccessKeyId</Code>'
            +'<Message>The AWS Access Key Id you provided does not exist in our records.</Message>'
            +'<AWSAccessKeyId>AKIAXBC2OOIM4NKWKX4</AWSAccessKeyId>'
            +'<RequestId>10WKRWWNSA3FSB5E</RequestId>'
            +'<HostId>2K27DwA+Be1k+qzIFUZ5nkxkjujuycIgpb55miGdOVr5O3g5Y+2UtXaGDpWVIURJ+lbvMji/zCs=</HostId>'
            +'</Error>';
    }
    
    private static String generateResposneForFiles(){
        return '<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">'
            +'<Name>buctest143</Name>'
            +'<IsTruncated>false</IsTruncated>'
            +'<Contents>'
            +'<Key>AccountData.csv</Key>'
            +'</Contents>'
            +'<Contents>'
            +'<Key>AccountData2.csv</Key>'
            +'</Contents>'
            +'</ListBucketResult>';
    }
}