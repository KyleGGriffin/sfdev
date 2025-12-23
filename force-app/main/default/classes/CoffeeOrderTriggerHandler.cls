public without sharing class CoffeeOrderTriggerHandler 
{
	public List<Coffee_Order__c> coffeeOrders;
	public List<Coffee_Order__c> oldCoffeeOrders;

	public CoffeeOrderTriggerHandler(){}

	public CoffeeOrderTriggerHandler(List<Coffee_Order__c> coffeeOrders,
		List<Coffee_Order__c> oldCoffeeOrders)
	{
		this.coffeeOrders = coffeeOrders;
		this.oldCoffeeOrders = oldCoffeeOrders;
	}

	public void run()
	{
		// Avoid running in the after context
		if (Trigger.isAfter != null && Trigger.isAfter)
		{
			return;
		}

		List<Coffee_Order__c> coffeeOrders = this.coffeeOrders;
		Integer coffeeOrdersSize = coffeeOrders.size();
		for (Integer i = 0, j = coffeeOrdersSize; i < j; i++)
		{
			Coffee_Order__c coffeeOrder = this.coffeeOrders[i];
			Coffee_Order__c oldCoffeeOrder = this.oldCoffeeOrders == null ? null : this.oldCoffeeOrders[i];
			coffeeOrder = this.receiveOrderTotal(coffeeOrder, oldCoffeeOrder);
		}
	}

	public Coffee_Order__c receiveOrderTotal(Coffee_Order__c coffeeOrder, 
		Coffee_Order__c oldCoffeeOrder)
	{
		// In the scenario of a record insert, oldCoffeeOrder will be null
		// because there is no old version of the record, so stub in an 
		// empty record to allow the below condition to evaluate correctly.
		if (oldCoffeeOrder == null)
			oldCoffeeOrder = new Coffee_Order__c();

		if (coffeeOrder.Received_Order_Total__c == null
			&& coffeeOrder.Order_Total__c != null
			&& oldCoffeeOrder.Order_Total__c == null)
		{
			coffeeOrder.Received_Order_Total__c = Datetime.now();
		}

		return coffeeOrder;
	}
}