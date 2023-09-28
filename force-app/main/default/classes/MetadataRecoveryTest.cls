@isTest
public With sharing class MetadataRecoveryTest{
	
    Private static String AsyncResultId = '0Af5i00000hcNw1CAE';
    
    @isTest
    static void testDeploy(){
        Test.setMock(HttpCalloutMock.class,new MetadataRecoveryResponseGenerator('deploy'));
        MetadataRecovery.deployMetadata('testContent');
    }
    
    @isTest
    static void testCheckDeployStatus(){
        Test.setMock(HttpCalloutMock.class,new MetadataRecoveryResponseGenerator('checkDeployStatus'));
        MetadataRecovery.CheckDeployStatus(AsyncResultId);
        /*MetadataRecovery.RecoveryResponse  response= MetadataRecovery.CheckDeployStatus(AsyncResultId);
        system.debug(response);
        System.assertEquals('2', response.numberComponentsDeployed, 'Number of components Deployed should be 2');
        System.assertEquals('2', response.numberComponentsTotal, 'Total Number of components should be 2');
        system.assertEquals('true',response.isSuccess,'Success Should be true');*/
        
    }
    
}