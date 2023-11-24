@isTest
public With sharing class MetadataRecoveryTest{
	
    Private static String AsyncResultId = '0Af5i00000hcNw1CAE';
    
    @isTest
    static void testDeploy(){
        integer futureInvocation;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class,new MetadataRecoveryResponseGenerator('deploy'));
        MetadataRecovery.deployMetadata('testContent');
        futureInvocation = Limits.getFutureCalls();
        
        Test.stopTest();
        
        system.assertEquals(1, futureInvocation,'Number of Future Invocation should be 1');
    }
    
    @isTest
    static void testCheckDeployStatus(){
        integer futureInvocation;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class,new MetadataRecoveryResponseGenerator('checkDeployStatus'));
        MetadataRecovery.CheckDeployStatus(AsyncResultId);
        futureInvocation = Limits.getFutureCalls();
        
        Test.stopTest();
        system.assertEquals(1, futureInvocation,'Number of Future Invocation should be 1');
       
    }
    
}