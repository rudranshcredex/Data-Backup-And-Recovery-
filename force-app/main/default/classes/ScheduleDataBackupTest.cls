@isTest
public With sharing class ScheduleDataBackupTest {

    private static final String CronExpression ='0 0 * * * ?';
    
    @isTest
    Static void testScheduleDataBackup(){
        test.startTest();
        String jobId = System.schedule('testSchedule',CronExpression,new ScheduleDataBackup(new List<String>{'Account'},'credentials',null,null,'ScheduleDataBackup'));
        system.debug(jobId);
        test.stopTest();
    }
}