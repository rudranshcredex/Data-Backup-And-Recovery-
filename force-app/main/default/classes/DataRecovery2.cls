public with sharing class DataRecovery2 {

    public static void recoverData(){
        List<ContentVersion> ContentVersionData=[select id,VersionData,FileExtension,Title from ContentVersion];
        for(ContentVersion version:ContentVersionData){
            system.debug(version);
            String attachBody=EncodingUtil.base64Encode(version.VersionData);
            system.debug('attach body'+attachBody);
            Blob pdfBlob = EncodingUtil.base64Decode(attachBody);
            system.debug('blob'+pdfBlob);
        }
    }
}