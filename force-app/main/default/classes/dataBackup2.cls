Public with sharing class dataBackup2 {

    //public static List<EntityDefnition> objectsApiNames;
   private static List<String> objectsNames=new List<String>();
    
    /**
       *@description:  This method is use to fetch all the Api names of objects in salesforce For both Setup and NonSetup
		
		**/
     @auraEnabled(cacheable=true)
    public static List<String>  getObjectsApiNamesBySearch(String textKey){
        List<String> objects=new List<String>();
        system.debug('data');
        textKey='%' + textKey +'%';
        List<EntityDefinition> objectsApiNames=[SELECT ID,QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName Like:textKey];
        //system.debug(objectsApiNames);
        //
        for(EntityDefinition entity:objectsApiNames){
            objects.add(entity.QualifiedApiName);
        }
        return objects;
    }
    
    @auraEnabled(cacheable=true)
    public static List<objectWrapper> getObjectsApiNames2(){
        
        List<objectWrapper> objectNames = new List<objectWrapper>();
    	Integer objectIndex = 1;
        
        List<String> objects = new List<String>();
        
         for(schema.SObjectType obj:Schema.getGlobalDescribe().values())
         {
             Schema.DescribeSObjectResult objResult = obj.getDescribe();
             if (objResult.isCreateable() && objResult.isupdateable() && objResult.isqueryable()){
                 objects.add(objResult.getName());
             }
             
         }
        //objectsList = objectsList.sort();
        List<String> objectsList = new List<String>(objects);
        objectsList.sort();
        for(String obj:objectsList){
            objectWrapper objectData = new objectWrapper();
            	objectData.objectName = obj;
                objectData.isSelected = false;
              	objectData.objectId = objectIndex;
                objectIndex++;
            objectNames.add(objectData);
        }
      /*  for(schema.SObjectType obj:Schema.getGlobalDescribe().values())
        {
              Schema.DescribeSObjectResult objResult = obj.getDescribe();
              objectWrapper objectData = new objectWrapper();
              
             
                //if (objResult.isCreateable() && objResult.isupdateable() && objResult.isqueryable()) {
                    objectData.objectName = objResult.getName();
                    objectData.isSelected = false;
              		objectData.objectId = objectIndex;
                    objectIndex++;
                //}
              
              objectNames.add(objectData);
              
        }
        system.debug(objectNames);*/
        return objectNames;
    }
        
    @auraEnabled(cacheable=true)
    public static List<String>  getObjectsApiNames(){
        system.debug('data');
        /*List<EntityDefinition> objectsApiNames=[SELECT ID,QualifiedApiName FROM EntityDefinition where IsQueryable=true and IsEverCreatable=true and IsEverUpdatable=true ORDER BY QualifiedApiName];
        //system.debug(objectsApiNames);
        for(EntityDefinition entity:objectsApiNames){
            objectsNames.add(entity.QualifiedApiName);
        }*/
        //return objectsNames;
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        FOR(schema.SObjectType obj:Schema.getGlobalDescribe().values())
        {
            Schema.DescribeSObjectResult objResult = obj.getDescribe();
            system.debug( 'Sobject: ' + objResult );
            system.debug( 'Sobject API Name: ' + objResult.getName() );
            system.debug( 'Sobject Label Name: ' + objResult.getLabel() );
            if (objResult.isCreateable() && objResult.isupdateable() && objResult.isqueryable()) {
                objectsNames.add(objResult.getName());
            }
        }
        List<String> objectList=new List<String>(objectsNames);
        objectList.sort();
        system.debug(objectList.size());
        for(string s:objectList){
            system.debug(s);
        }
        return objectList;
        
	        
    }
    
   /* @auraEnabled(cacheable=true)
    public static List<Account> getRecords(String objectName,String fromDate, String toDate){
        system.debug('fromDate'+fromDate);
        system.debug('toDate'+toDate);
        system.debug('object'+objectName);
        
       Map<String, Schema.SObjectField> fieldMap = account.sObjectType.getDescribe().fields.getMap();        
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
        //system.debug(lstFieldNames);
        // Dynamic Query String.
        List<Account> lstAccounts = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM '+objectName);
       // system.debug('SELECT ' + String.join(lstFieldNames, ',') + ' FROM '+objectName);
       //List<Account> lstAccounts = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM '+objectName+' WHERE CreatedDate>=:toDate AND CreatedDate<=:fromDate);
       system.debug(lstAccounts);
        return lstAccounts;
    }*/
    
    @auraEnabled(cacheable=true)
   //@RemoteAction
    Public static Map<String,list<Sobject>> getRecordsByObject(List<String> objectNames,String fromDate, String toDate){
      /*  fromDate+='T00:00:00Z';
        toDate+='T00:00:00Z';
        toDate = toDate.remove('\'');
        fromDate = fromDate.remove('\'');
        system.debug('dates');
        system.debug(fromDate);
        system.debug(toDate);*/
        system.debug(fromDate);
        system.debug(toDate);
        
        if(fromDate!=null && toDate!=null){
            fromDate+='T00:00:00Z';
            toDate+='T00:00:00Z';
            toDate = toDate.remove('\'');
        	fromDate = fromDate.remove('\'');
        }
        Map<String,list<Sobject>> ObjectsData=new Map<String,list<Sobject>>();
        system.debug('objectNames'+objectNames);
            List<list<Sobject>> recordsToBackup=new List<list<Sobject>>();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        
            for(string objectName:objectNames){
                List<Sobject> objectRecords=new List<Sobject>();
                Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
                Set<String> fields=fieldMap.keySet();
                List<String> FieldNames = new List<String>(fields);
                objectRecords=Database.query('SELECT ' + String.join(FieldNames, ',') + ' FROM '+objectName);
               /* if(fromDate==null && toDate==null){
                    objectRecords=Database.query('SELECT ' + String.join(FieldNames, ',') + ' FROM '+objectName);
                }
                else{
                	objectRecords=Database.query('SELECT ' + String.join(FieldNames, ',') + ' FROM '+objectName+'  WHERE CreatedDate>=:'+toDate+' AND CreatedDate<=:'+fromDate);
                }*/
               // system.debug(objectRecords);
                recordsToBackup.add(objectRecords);
                ObjectsData.put(objectName,objectRecords);
            }
        
        system.debug('DataMap'+ObjectsData);
                
               // return recordsToBackup;
               return ObjectsData;
       
    }
    
    @RemoteAction	
    Public static string getObj(){
        system.debug('fromDate');
        return 'string';
    }
    
    @auraEnabled
    Public static void getObjects(String jsonString){
        List<String> objects = new List<String>();
        system.debug('Objects>>>>>>>>>>');
        system.debug(jsonString);
        List<Object> objectList = (List<Object>)JSON.deserializeUntyped(jsonString);
        for(object obj:objectList){
            Map<String,object> objectMap =(Map<String,object>)obj;
            system.debug(objectMap.get('objectName'));
            objects.add((String)objectMap.get('objectName'));
        } 
         PageReference vfPage = Page.DataZip;
         vfPage.getParameters().put('csvData', 'csvString');
        //String vfPageUrl = '/apex/DataZip?csvData=Account';
        //
        system.debug('vfPage>>>>>>>>>>>');
        system.debug(vfPage);
        ApexPages.PageReference pageRef = vfPage;
        system.debug('pageRef');
        system.debug(pageRef);
        pageRef.setRedirect(true);
    }
    
    public class objectWrapper{
        @AuraEnabled
        public Boolean isSelected;
        @AuraEnabled
        public String objectName;
        @AuraEnabled
        public Integer objectId;    
  }
}