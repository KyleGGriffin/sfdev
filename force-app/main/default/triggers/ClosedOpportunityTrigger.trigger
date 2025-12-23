trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {
   //If Opportunity is 'Closed Won', create a new Task
    List<Task> closedOppTasks = new List<Task>();
    
    [SELECT Id, StageName FROM Opportunity WHERE Id IN :Trigger.new AND StageName = 'Closed Won'];
  
   For (Opportunity opp : ClosedOppTasks) {
     //create the new task
     ClosedOppTasks.add(new Task (
        Subject = 'Follow Up Test Task',
        WhatId = Trigger.new[0].Id,
        OwnerId = UserInfo.getUserId(),
        Status = 'Not Started',
        Priority = 'Normal'));
    } 
    if (ClosedOppTasks.size() > 0) {
    try {
        insert ClosedOppTasks;
    } catch (Exception e){
        System.debug('Error: ' + e.getMessage());
    }
    }
}