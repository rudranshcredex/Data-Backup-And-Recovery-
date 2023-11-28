public class CloudStorageIntegration {
    //API Secret Key
    private static string key = '265722275114-fh5k0qt9fvsu47l5mnut0o40oc875ctm.apps.googleusercontent.com';
    //API Secret
    private Static string secert = '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';
    //API Redirect. Use your Lightning Tab or Lightning community URL
    ////'https://vagminecodexone-developer-edition.ap15.force.com/fitness/s/'; 
    private Static string redirect_uri = 'https://login.salesforce.com/';
    private static string authUrl='https://accounts.google.com/o/oauth2/v2/auth';
    private static string scope= 'https://www.googleapis.com/auth/cloud-platform'; //https://www.googleapis.com/auth/cloud-platform
    private static string AccesstokenUrl='https://accounts.google.com/o/oauth2/token';
    
   
    @AuraEnabled
    public static void createAuthURL() {
        String key = EncodingUtil.urlEncode(key,'UTF-8');
        String uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');
        String authuri = '';
        authuri = authUrl+'?'+
            'client_id='+key+
            '&response_type=code'+
            '&scope='+scope+
            '&redirect_uri='+uri+
            '&access_type=offline'+
           	'&prompt=consent';
     //   system.debug(authuri);
        getAccessToken(authuri);
      //  return authuri;
    }
    
    @AuraEnabled
    public static boolean getAccessToken(String code)
    {
        //Getting access token from google
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(AccesstokenUrl);
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        
        String messageBody ='code='+code+'&client_id='+key+
            '&client_secret='+secert+
            '&redirect_uri='+redirect_uri+
            '&grant_type=Authorization_Code';
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setTimeout(60*1000);
       	//system.debug('messageBody:'+messageBody);
        
        Http callout = new Http();
        String responseText;
        HttpResponse response = callout.send(req);
        system.debug(response);
        responseText = response.getBody();
        system.debug('responseText:'+responseText);
       /* Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(responseText) ;  
        String token =  String.valueOf(responseMap.get('access_token'));
        system.debug('token:'+token);*/
        
        //Update token in custom metadata 
       // MetadataService.UpdateCustomMetadata(token);
        return true;
    }
}