/*
 		@Developer Name => Nikhil Garg
		@description => This Schedule class use to schedule calls of Metadata Backup
*/

Public With sharing class ScheduleMetadataBackup implements Schedulable{
        
    //constants
        private string AsyncResultId;
        Private String Creds;
    	private String ContextType;
   		private List<String> metadataTypes;
    
    // This constructor is use to take inputs to pass to every calls based on context Type
        Public ScheduleMetadataBackup(String AsyncId, String Credentials,String Context){
            AsyncResultId = AsyncId;
            Creds = Credentials;
            ContextType = context;
        }
    
    // This constructor is use to take inputs to pass to every calls based on context Type
        Public ScheduleMetadataBackup(List<String> metadataType,String credentials,String Context){
                metadataTypes = metadataType;
                Creds = Credentials;
                ContextType = context;
            }
    
    
    /*
@description => This method will excute the schedule class for different contexts
*/
        Public  void execute(SchedulableContext sc){
            if(ContextType =='schedule Backup'){
                MetadataBackup.retrieveMetadata(metadataTypes,Creds);
            }
            if(ContextType =='retrieveStatus'){
                MetadataBackup.CheckRetrieveStatus(AsyncResultId,Creds);
            }
        }
    }