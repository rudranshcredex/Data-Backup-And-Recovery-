public with sharing class MetadataBackupGit 
{
	private static final Integer METADATA_API_VERSION = 
		Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));

	public List<SelectOption> MetaDataTypes {get; set;}
	public String MetaDataType {get; set;}		
	public List<SelectOption> MetaDataItems {get; set;}
	public String MetaDataFolder {get; set;} 
	public String MetaDataItem {get; set;}	
	public String MetadataFileName {get; set;}
	public String MetadataFileData {get; set;}
	public MetadataService.AsyncResult AsyncResult {get; private set;}
	public String MetaDataRetrieveZip { get; private set; }	
	public List<MetadataFile> MetadataFiles { get; set; }		
	
	public void init()
	{
		// List available Metadata Types via the 'describeMetadata' API call
		MetadataService.MetadataPort service = createService();					
		MetadataService.DescribeMetadataResult describeResult = service.describeMetadata(METADATA_API_VERSION);
		List<String> metadataTypeNames = new List<String>();
        system.debug('describeResult.metadataObjects');
        system.debug(describeResult.metadataObjects);
		for(MetadataService.DescribeMetadataObject metadataObject : describeResult.metadataObjects)
		{
            system.debug('metadataObject.xmlName  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
            system.debug(metadataObject.xmlName);
			metadataTypeNames.add(metadataObject.xmlName);
			// Include child Metadata Types (such as CustomField, ValidationRule etc..)
			if(metadataObject.childXmlNames!=null)
                system.debug('metadataObject.childXmlNames>>>>>>>>>>>>>>>>>>>>>>>>>>>');
            	system.debug(metadataObject.childXmlNames);
				for(String childXmlName : metadataObject.childXmlNames)
					if(childXmlName!=null)
						metadataTypeNames.add(childXmlName);
		}	

		// Sort Metadata Types
		metadataTypeNames.sort();
		MetaDataTypes = new List<SelectOption>();				
		for(String metadataTypeName : metadataTypeNames)
			MetaDataTypes.add(new SelectOption(metadataTypeName, metadataTypeName));
					
		// Default to first Metadata Type returned	
		MetaDataType = MetaDataTypes[0].getValue();		
        system.debug('MetaDataType>>>>>>>>>>>>>>>>>');
        system.debug(MetaDataType);
        
        
        
        system.debug('MetadataTypes>>>>>>>>>>>>>>>');
        system.debug(MetaDataTypes);
		// Retrieve Metadata items for the selected Metadata Type
		listMetadataItems();		
		
	}
	
	public void listMetadataItems()
	{
		// List Metadata items for the selected Metadata Type
		MetaDataItems = new List<SelectOption>();		
		MetadataService.MetadataPort service = createService();				
		List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();		
		MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
		if(MetaDataFolder!=null && MetaDataFolder.length()>0)
			queryLayout.folder = MetaDataFolder;
		queryLayout.type_x = MetaDataType;
		queries.add(queryLayout);		
		MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, METADATA_API_VERSION);
		
		// Sort
		List<String> fullNames = new List<String>();
		if(fileProperties!=null)
		{
			for(MetadataService.FileProperties fileProperty : fileProperties)
				fullNames.add(fileProperty.fullName);
			fullNames.sort();
			for(String fullName : fullNames)
				MetaDataItems.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));
		}

	
	}
	
	public void retrieveMetadataItem()
	{		
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Retrieving metadata...'));
		
		// Reset state from any previous requests
		MetaDataRetrieveZip = null;
		MetadataFiles = null;
		 
		// Construct unmanaged package with list of desired components to retrieve in zip
		MetadataService.MetadataPort service = createService();				
		MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
		retrieveRequest.apiVersion = METADATA_API_VERSION;
		retrieveRequest.packageNames = null;
		retrieveRequest.singlePackage = true;
		retrieveRequest.specificFiles = null;
		retrieveRequest.unpackaged = new MetadataService.Package_x();
		retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
		MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
		packageType.name = MetaDataType; 
		packageType.members = new String[] { MetadataFolder, MetaDataItem };
		retrieveRequest.unpackaged.types.add(packageType);
		AsyncResult = service.retrieve(retrieveRequest);
						
		
	}
	
	public void checkAsyncRequest()
	{
		// Check the status of the retrieve request
		MetadataService.MetadataPort service = createService();
		MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(AsyncResult.Id, true);
		if(retrieveResult.done)
		{
			// Errors?
			if(retrieveResult.status != 'Succeeded')
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, retrieveResult.errorMessage));
				AsyncResult = null;				
			}
			else
			{
				// Place Base64 encoded zip data onto the page for the JSZip library to handle
				MetaDataRetrieveZip = retrieveResult.zipFile;
				MetadataFiles = new List<MetadataFile>();
			//	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding...'));
				AsyncResult = null;
			}
		}
		else
		{
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Retrieving metadata...'));
		}	

		
	}
	
	public void receiveMetadataZipFile()
	{
		// In this example the retrieved metadata is stored in viewstate in production cases you would probably use a custom object / attachment
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding ' + MetaDataFileName + '...'));
		MetadataFile metaDataFile = new MetadataFile();
		metaDataFile.fullName = MetaDataFileName;
		metaDataFile.content = MetaDataFileData;
		MetadataFiles.add(metaDataFile);
		
	}
	
	public void receiveComplete()
	{
		// Completed, cleared Base64 encoded zip data from viewstate
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Metadata retrieve completed'));
		MetaDataRetrieveZip = null;		
		
	}
	
	private static MetadataService.MetadataPort createService()
	{ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
	}	
	
	/**
	 * Simple container class for retrieve metadata file, may as well leverage the Metadata API class for this
	 **/
	public class MetadataFile extends MetadataService.MetadataWithContent
	{
		public String getFullname()
		{
			return fullName;
		}
		
		public String getContent()
		{
			return content;
		}
	}
}