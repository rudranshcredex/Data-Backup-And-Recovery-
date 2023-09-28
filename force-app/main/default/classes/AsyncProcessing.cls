public class AsyncProcessing {

   // public static void
    //Public static Map<String,List<Map<String, object>>> MetadataMapByType = new Map<String,List<Map<String, object>>>();
    //Public static Map<String, List<String>> metadataByType = new Map<String, List<String>>();
    Public static  Map<String,List<Map<String, object>>> MetadataMapByTypeToVf = new Map<String,List<Map<String, object>>>();
   
    @future(callout=true)
    Public static void processMetadata(String serializeBatch){
        
        Map<String,List<Map<String, object>>> MetadataMapByType = new Map<String,List<Map<String, object>>>();
        Map<String, List<String>> metadataByType = new Map<String, List<String>>();
        
        	MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
        
        MetadataService.ListMetadataQuery[] batch = (MetadataService.ListMetadataQuery[]) JSON.deserialize(serializeBatch, List<MetadataService.ListMetadataQuery>.class);
        
        MetadataService.FileProperties[] fileProperties2 = service.listMetadata(batch,(Double) 58.0);
           
          for (MetadataService.FileProperties fileProperty : fileProperties2) {
              
                String componentType = fileProperty.type_x;
                String componentName = fileProperty.fullName;
              
                if (!metadataByType.containsKey(componentType)) {
                    metadataByType.put(componentType, new List<String>());
                }
                metadataByType.get(componentType).add(fileProperty.fullName);
              
                MetadataService.Metadata metadata = service.readMetadata(componentType, new List<String>{componentName}).getRecords()[0];
                
                string jsonString=JSON.serialize(metadata);
                Blob xmlBlob = Blob.valueOf(jsonString);
                
                Map<String, Object> metadataMap = new Map<String, Object>();
                metadataMap.put('componentName', componentName);
                metadataMap.put('xmlBlob', EncodingUtil.base64Encode(xmlBlob));
              
                  if(MetadataMapByType.containsKey(componentType)){
                      List<Map<String, object>> tempMetadata =new List<Map<String, object>>();
                      tempMetadata = MetadataMapByType.get(componentType);
                      tempMetadata.add(metadataMap);
                      MetadataMapByType.put(componentType, tempMetadata);
                  }else{
                      List<Map<String, object>> tempMetadata = new List<Map<String, object>>{metadataMap};
                      MetadataMapByType.put(componentType, tempMetadata);                      
                  }

            }
        system.debug('metadataByType>>>>>>');
        system.debug(metadataByType);
        
        system.debug('MetadataMapByType>>>>>>>>>>>');
        system.debug(MetadataMapByType);
		//MetadataMapByTypeToVf = MetadataMapByType;
	
        
        
        /*MetadataRetriever.asyncVariable.add(MetadataMapByType);
        system.debug('MetadataRetriever.asyncVariable>>>>>>>>>>');
        system.debug(MetadataRetriever.asyncVariable);*/



        Metadata_Retrieval__e evt=new Metadata_Retrieval__e();
        evt.test__C='Yes';
        Database.SaveResult[] results = EventBus.publish(new List<Metadata_Retrieval__e>{evt});
        
        system.debug(results);
        system.debug('EventBus>>>>>'+results);
          }
   
}