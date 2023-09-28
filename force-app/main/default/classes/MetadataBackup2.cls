public class MetadataBackup2 {

    public static void retrieveMetaData(){
        Map<String, List<String>> metadataByType = new Map<String, List<String>>();
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        
        MetadataService.ListMetadataQuery queryDocumentFolder = new MetadataService.ListMetadataQuery();
        queryDocumentFolder.type_x = 'Tabs';
        queryDocumentFolder.folder = 'tabs';
        
        queries.add(queryDocumentFolder);       
        
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries,58);
        system.debug('fileProperties>>>>>>>>>>>>> outside loop'+fileProperties);
        List<String> folderNames = new List<String>();
        for(MetadataService.FileProperties fileProperty : fileProperties)
        {
            system.debug('fileProperties>>>>>>>');
        	system.debug(fileProperty);
            String componentType = fileProperty.type_x;
            String componentName = fileProperty.fullName;
            //folderNames.add(fileProperty.fileName.replace('documents/', ''));
            if (!metadataByType.containsKey(componentType)) {
                    metadataByType.put(componentType, new List<String>());
                }
                metadataByType.get(componentType).add(fileProperty.fullName);
                MetadataService.Metadata metadata = service.readMetadata(componentType, new List<String>{componentName}).getRecords()[0];
                System.debug('Metadata component full name: ' + fileProperty.fullName);
                System.debug('Metadata component type: ' + fileProperty.type_x);
            	system.debug('metadata>>>>>>>>>>>>>>>>>>>>>'+metadata);
        }
        
        List<MetadataService.DocumentFolder> folder = 
            (List<MetadataService.DocumentFolder>) 
                service.readMetadata('DocumentFolder', folderNames).getRecords();
            }
}