@isTest
public With Sharing class MetadataRetrieverTest {

    @isTest
    Public static void testGetMetaDataTypes(){
        try{
            test.startTest();
             Test.setMock(WebServiceMock.class, new MetadataRetrieveMock());
        	 MetadataRetriever.getMetaDataTypes();
        	test.stopTest();
        }
        catch(Exception ex){
            system.debug(ex.getmessage()+' at '+ex.getLineNumber());
        }   
    }
}