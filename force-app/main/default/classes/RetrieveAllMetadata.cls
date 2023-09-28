public class RetrieveAllMetadata  {
   // @RemoteAction
    public static Map<String, List<Map<String, Object>>> retrieveAllMetadata() {
        Map<String, List<Map<String, Object>>> MetadataMapByType = new Map<String, List<Map<String, Object>>>();

        try {
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();

            // Call listMetadata() method to retrieve all metadata types
            MetadataService.ListMetadataQuery query = new MetadataService.ListMetadataQuery();
            MetadataService.FileProperties[] fileProperties = service.listMetadata(new MetadataService.ListMetadataQuery[] { query }, (Double) 58.0);

            for (MetadataService.FileProperties fileProperty : fileProperties) {
                String componentType = fileProperty.type_x;
                String componentName = fileProperty.fullName;

                // Retrieve metadata details using the readMetadata() method
                MetadataService.Metadata metadata = service.readMetadata(componentType, new List<String>{componentName}).getRecords()[0];
                String jsonString = JSON.serialize(metadata);
                Blob xmlBlob = Blob.valueOf(jsonString);

                // Store the metadata details in the map
                Map<String, Object> metadataMap = new Map<String, Object>();
                metadataMap.put('componentName', componentName);
                metadataMap.put('xmlBlob', EncodingUtil.base64Encode(xmlBlob));

                if (MetadataMapByType.containsKey(componentType)) {
                    List<Map<String, Object>> tempMetadata = MetadataMapByType.get(componentType);
                    tempMetadata.add(metadataMap);
                    MetadataMapByType.put(componentType, tempMetadata);
                } else {
                    List<Map<String, Object>> tempMetadata = new List<Map<String, Object>>{metadataMap};
                    MetadataMapByType.put(componentType, tempMetadata);
                }
            }
        } catch (Exception e) {
            // Handle exception
            System.debug('Error: ' + e.getMessage() + ' at ' + e.getLineNumber());
        }

        system.debug('Metadata component >>>>>>>>>>>>>>>>>');
        system.debug(MetadataMapByType);
        return MetadataMapByType;
    }
}