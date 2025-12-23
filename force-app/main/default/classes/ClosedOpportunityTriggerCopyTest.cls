@isTest
private class ClosedOpportunityTriggerCopyTest {

    @isTest static void testInsertCreatesTaskWhenClosedWon() {
        // Create an Opportunity that is already Closed Won at insert
        Opportunity opp = new Opportunity(Name='InsertClosedWon', StageName='Closed Won', CloseDate=Date.today());
        insert opp;

        // Query for tasks related to the opportunity
        List<Task> tasks = [SELECT Id, Subject, WhatId FROM Task WHERE WhatId = :opp.Id];
        System.assertEquals(1, tasks.size(), 'A follow-up task should be created on insert when StageName is Closed Won');
        System.assertEquals('Follow Up Test TaskCopy', tasks[0].Subject);
    }

    @isTest static void testUpdateCreatesTaskWhenStageChangesToClosedWon() {
        // Insert an opportunity in a non-Closed Won stage
        Opportunity opp = new Opportunity(Name='ChangeToClosedWon', StageName='Prospecting', CloseDate=Date.today());
        insert opp;

        // Change stage to Closed Won and update - should create one task
        opp.StageName = 'Closed Won';
        Test.startTest();
        update opp;
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject, WhatId FROM Task WHERE WhatId = :opp.Id];
        System.assertEquals(1, tasks.size(), 'A follow-up task should be created when stage changes to Closed Won');
        System.assertEquals('Follow Up Test TaskCopy', tasks[0].Subject);
    }
}
