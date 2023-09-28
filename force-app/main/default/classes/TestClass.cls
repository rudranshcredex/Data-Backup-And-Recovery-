public class TestClass {

    @AuraEnabled(cacheable=true)
    Public static void method(string data){
        system.debug('dataa>>>>>>>>>>');
        system.debug(data);
        Blob blobData = EncodingUtil.base64Decode(data);
        system.debug('blobData>>>>>>>>');
        system.debug(blobData);
    }
}