/*
 		@Developer Name => Nikhil Garg
		@description => This class is use to perform Data Backup using Bulk API
*/
public with sharing class DataBackup {

	//Constants
    private static final String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
    private static final String endpointURL = baseURL+'/services/data/v58.0/jobs/query';
    private static List<String> objectsNames=new List<String>();
    
    /*
		@description => This method is used to schedule backup Process at given date
	*/
  	@auraEnabled(cacheable=true)
    Public static void ScheduleDataBackup(List<String> ObjectApiNames, String credentials, String fromDate, String toDate,String scheduleDate){
     
		Datetime dateTimeValue = Datetime.newInstanceGmt(Integer.valueOf(scheduleDate.substring(0, 4)), Integer.valueOf(scheduleDate.substring(5, 7)), Integer.valueOf(scheduleDate.substring(8, 10)),
                                                 Integer.valueOf(scheduleDate.substring(11, 13)), Integer.valueOf(scheduleDate.substring(14, 16)), Integer.valueOf(scheduleDate.substring(17, 19)));
        integer scheduleDay = dateTimeValue.day();
        integer scheduleMonth = dateTimeValue.month();
        integer scheduleYear = dateTimeValue.year();
        integer scheduleHour = dateTimeValue.hour();
        integer scheduleMinute = dateTimeValue.minute();
              
        String CRON_EXPRESSION = '0 '+scheduleMinute+' '+scheduleHour+' '+scheduleDay+' '+scheduleMonth+' ? '+scheduleYear;   
        System.schedule('Schedule Data Backup'+system.now().addminutes(2), CRON_EXPRESSION, new ScheduleDataBackup(ObjectApiNames, credentials, fromDate,  toDate,'ScheduleDataBackup'));
    }
    
    
    /*
		@description => This method will take object names and creds(if Service is AWS) and backup the data at service selected by user 
	*/
    
    @auraEnabled(cacheable=true)
    Public static void createDataBackup(List<String> ObjectApiNames,String credentials,String fromDate, String toDate){
   		
        try{     
            List<String> batches = new List<String>();
            if(ObjectApiNames.size()>100)
            {    
                double batchresult = (double)(ObjectApiNames.size())/100;
                double decimalPart = batchresult - (integer)batchresult;
                integer batchSize = (integer)batchresult;
                
                if(decimalpart>0){
                    batchSize++;
                }
                for(integer i=0;i<=ObjectApiNames.size();i+=100){
                    List<String> objectBatch = new List<String>();
                    for(integer j=i;j<100+i && j<ObjectApiNames.size();j++)
                    {
                        objectBatch.add(ObjectApiNames[j]);
                    }
                    batches.add('batch'+batchSize);
                    DataBackupCallout.getQueryJobIds(objectBatch,'batch'+batchSize,fromDate,toDate); 
                    batchSize-=1;
                }
             }
             else
             {
                batches.add('batch 0');
                DataBackupCallout.getQueryJobIds(ObjectApiNames,'batch 0',fromDate,toDate);
             }
            Datetime sysTime;
            if(ObjectApiNames.size()<=20){
               sysTime = System.now().addminutes(2);
            }
            else{
                sysTime = System.now().addminutes( 7 );
            }
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            system.schedule('Salesforce Data Backup'+System.now(), chronExpression, new ScheduleDataBackup(batches,'ReadData',credentials));
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }      
    
    
    /*
		@description => This method returns objectAPINames of the Salesforce Org to backup the records
	*/
    
     @auraEnabled(cacheable=true)
    public static List<objectWrapper> getObjectApiNames(){
        
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
      
        return objectNames;
    }
    
     /*
		@description => This Wrapper class will use in returning objectApiNames
	*/
    public class objectWrapper{
        @AuraEnabled
        public Boolean isSelected;
        @AuraEnabled
        public String objectName;
        @AuraEnabled
        public Integer objectId;    
  }
}