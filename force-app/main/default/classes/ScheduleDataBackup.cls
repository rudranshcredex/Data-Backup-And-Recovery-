/*
 		@Developer Name => Nikhil Garg
		@description => This class is use to Schedule Calls for Data Backup
*/
public class ScheduleDataBackup implements schedulable {
    
    Private Map<String,String> objectWithJobIds;
    Private String batch;
    Private List<String> batchNames;
    Private String contexts;
    Private String Creds;
    Private String fromDate;
    Private String toDate;
    Private List<String> objects;
    Private List<String> metadatas;
    
    // This constructor is use to take inputs to pass to every calls based on context Type
    Public ScheduleDataBackup(List<String> ObjectApiNames,String credentials,String fromDate, String toDate,String context){
        objects = ObjectApiNames;
        fromDate = fromDate;
        toDate = toDate;
        creds = credentials;
        contexts = context;
    }
    
    
     // This constructor is use to take inputs to pass to every calls based on context Type
    public ScheduleDataBackup(Map<String,String> objectsWithId,String batchName,String context){
        system.debug('inside schedule');
        system.debug(batchName);
        system.debug(objectsWithId);
        objectWithJobIds = objectsWithId;
        batch = batchName;
        contexts = Context;
    }
    
     // This constructor is use to take inputs to pass to every calls based on context Type
    public ScheduleDataBackup(List<String> batches,String Context,String Credentials){
       batchNames = batches;
       contexts = Context;
       Creds = Credentials;
    }

       
    /*
@description => This method will excute the schedule class for different contexts
*/
    Public void execute(SchedulableContext sc){
        
        if(contexts == 'ScheduleDataBackup'){
            DataBackup.createDataBackup(objects,creds,fromDate,toDate);
        }
        if(contexts=='ReadData'){
            DataBackupCallout.readZipFiles(batchNames,Creds);
        }
        
        if(contexts=='getJobResults'){
            DataBackupCallout.getJobResults(objectWithJobIds,batch);
        }
        
                	
     }
    
}