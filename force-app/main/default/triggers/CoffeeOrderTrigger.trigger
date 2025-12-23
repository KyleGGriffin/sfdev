trigger CoffeeOrderTrigger on Coffee_Order__c (
	before insert, 
	before update,
	after insert,
	after update) 
{
	new CoffeeOrderTriggerHandler(Trigger.new, Trigger.old).run();
}