public class MetadataRetriever2 {

    public static List<String> describeAllMetadata() {
        List<String> metadataTypes = new List<String>();
        
        try {
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            
            MetadataService.DescribeMetadataResult result = service.describeMetadata((double)58.0); // Use appropriate API version
            
            if (result != null && result.metadataObjects != null) {
                for (MetadataService.DescribeMetadataObject obj : result.metadataObjects) {
                    metadataTypes.add(obj.xmlName);
                }
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + ' at ' + e.getLineNumber());
        }
        system.debug(metadataTypes);
        system.debug(metadataTypes.size());
        return metadataTypes;
    }
}