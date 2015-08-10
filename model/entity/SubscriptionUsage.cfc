/*

    Slatwall - An Open Source eCommerce Platform
    Copyright (C) ten24, LLC
	
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
	
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
	
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this program statically or dynamically with other modules is
    making a combined work based on this program.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
	
    As a special exception, the copyright holders of this program give you
    permission to combine this program with independent modules and your 
    custom code, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting program under terms 
    of your choice, provided that you follow these specific guidelines: 

	- You also meet the terms and conditions of the license of each 
	  independent module 
	- You must not alter the default display of the Slatwall name or logo from  
	  any part of the application 
	- Your custom code must not alter or create any files inside Slatwall, 
	  except in the following directories:
		/integrationServices/

	You may copy and distribute the modified version of this program that meets 
	the above guidelines as a combined work under the terms of GPL for this program, 
	provided that you include the source code of that other code when and as the 
	GNU GPL requires distribution of source code.
    
    If you modify this program, you may extend this exception to your version 
    of the program, but you are not obligated to do so.

Notes:

*/
component entityname="SlatwallSubscriptionUsage" table="SwSubsUsage" persistent="true" accessors="true" extends="HibachiEntity" cacheuse="transactional" hb_serviceName="subscriptionService" hb_permission="this" hb_processContexts="addUsageBenefit,cancel,renew,sendRenewalReminder,updateStatus" {
	
	// Persistent Properties
	property name="subscriptionUsageID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="allowProrateFlag" ormtype="boolean" hb_formatType="yesno";
	property name="renewalPrice" ormtype="big_decimal" hb_formatType="currency";
	property name="currencyCode" ormtype="string" length="3";
	property name="autoRenewFlag" ormtype="boolean" hb_formatType="yesno";
	property name="autoPayFlag" ormtype="boolean" hb_formatType="yesno";
	property name="nextBillDate" ormtype="timestamp" hb_formatType="date" hb_formFieldType="date";
	property name="nextReminderEmailDate" ormtype="timestamp" hb_formatType="date" hb_formFieldType="date";
	property name="expirationDate" ormtype="timestamp" hb_formatType="date" hb_formFieldType="date";
	property name="emailAddress" hb_populateEnabled="public" ormtype="string";
	
	// Related Object Properties (many-to-one)
	property name="account" cfc="Account" fieldtype="many-to-one" fkcolumn="accountID";
	property name="accountPaymentMethod" cfc="AccountPaymentMethod" fieldtype="many-to-one" fkcolumn="accountPaymentMethodID";
	property name="gracePeriodTerm" cfc="Term" fieldtype="many-to-one" fkcolumn="gracePeriodTermID";
	property name="initialTerm" cfc="Term" fieldtype="many-to-one" fkcolumn="initialTermID";
	property name="renewalTerm" cfc="Term" fieldtype="many-to-one" fkcolumn="renewalTermID";
	property name="subscriptionTerm" cfc="SubscriptionTerm" fieldtype="many-to-one" fkcolumn="subscriptionTermID";
	
	property name="shippingAccountAddress" hb_populateEnabled="public" cfc="AccountAddress" fieldtype="many-to-one" fkcolumn="shippingAccountAddressID";
	property name="shippingAddress" hb_populateEnabled="public" cfc="Address" fieldtype="many-to-one" fkcolumn="shippingAddressID";
	property name="shippingMethod" hb_populateEnabled="public" cfc="ShippingMethod" fieldtype="many-to-one" fkcolumn="shippingMethodID";
	
	// Related Object Properties (one-to-many)
	property name="subscriptionUsageBenefits" singularname="subscriptionUsageBenefit" cfc="SubscriptionUsageBenefit" type="array" fieldtype="one-to-many" fkcolumn="subscriptionUsageID" cascade="all-delete-orphan";
	property name="subscriptionOrderItems" singularname="subscriptionOrderItem" cfc="SubscriptionOrderItem" type="array" fieldtype="one-to-many" fkcolumn="subscriptionUsageID" cascade="all-delete-orphan" inverse="true";
	property name="subscriptionStatus" singularname="subscriptionStatus"  cfc="SubscriptionStatus" type="array" fieldtype="one-to-many" fkcolumn="subscriptionUsageID" cascade="all-delete-orphan" inverse="true";
	property name="renewalSubscriptionUsageBenefits" singularname="renewalSubscriptionUsageBenefit" cfc="SubscriptionUsageBenefit" type="array" fieldtype="one-to-many" fkcolumn="renewalSubscriptionUsageID" cascade="all-delete-orphan";
				   
	// Related Object Properties (many-to-many)
	
	// Remote Properties
	property name="remoteID" ormtype="string";
	
	// Audit Properties
	property name="createdDateTime" hb_populateEnabled="false" ormtype="timestamp";
	property name="createdByAccountID" hb_populateEnabled="false" ormtype="string";
	property name="modifiedDateTime" hb_populateEnabled="false" ormtype="timestamp";
	property name="modifiedByAccountID" hb_populateEnabled="false" ormtype="string";
	
	// Non-Persistent Properties
	property name="currentStatus" persistent="false";
	property name="currentStatusCode" persistent="false";
	property name="currentStatusType" persistent="false";
	property name="subscriptionOrderItemName" persistent="false";
	property name="initialSubscriptionOrderItem" persistant="false";
	property name="initialOrderItem" persistant="false";
	property name="initialOrder" persistant="false";
	property name="initialSku" persistant="false";
	property name="initialProduct" persistant="false";
	property name="mostRecentSubscriptionOrderItem" persistant="false";
	property name="mostRecentOrderItem" persistant="false";
	property name="mostRecentOrder" persistant="false";
	property name="totalNumberOfSubscriptionOrderItems" persistant="false";
	
	public boolean function isActive() {
		if(!isNull(getCurrentStatus())) {
			return getCurrentStatus().getSubscriptionStatusType().getSystemCode() == 'sstActive';
		} else {
			return false;
		}
	}
	
	public void function setFirstReminderEmailDateBasedOnNextBillDate() {
		// Setup the next Reminder email 
		if( len(this.setting('subscriptionUsageRenewalReminderDays')) ) {
			// Find the first reminder day
			var firstReminder = listFirst(this.setting('subscriptionUsageRenewalReminderDays'));
			// Make sure it is numeric
			if(isNumeric(firstReminder)) {
				// Setup teh next reminder emailDate
				this.setNextReminderEmailDate( dateAdd("d", firstReminder, this.getNextBillDate()) );	
			} else {
				this.setNextReminderEmailDate( javaCast("null", "") );
			}
		}
	}
	
	public array function getUniquePreviousSubscriptionOrderPayments() {
		return getService("subscriptionService").getUniquePreviousSubscriptionOrderPayments( getSubscriptionUsageID() );
	}
	
	public void function copyOrderItemInfo(required any orderItem) {
		var currencyCode = arguments.orderItem.getCurrencyCode();
		var renewalPrice = arguments.orderItem.getSku().getRenewalPriceByCurrencyCode( currencyCode );
		setRenewalPrice( renewalPrice );
		setCurrencyCode( arguments.orderItem.getCurrencyCode() );
		
		// Copy all the info from subscription term
		var subscriptionTerm = orderItem.getSku().getSubscriptionTerm();
		setSubscriptionTerm( subscriptionTerm );
		setInitialTerm( subscriptionTerm.getInitialTerm() );
		setRenewalTerm( subscriptionTerm.getRenewalTerm() );
		setGracePeriodTerm( subscriptionTerm.getGracePeriodTerm() );
		setAllowProrateFlag( subscriptionTerm.getAllowProrateFlag() );
		setAutoRenewFlag( subscriptionTerm.getAutoRenewFlag() );
		setAutoPayFlag( subscriptionTerm.getAutoPayFlag() );
		
		//Copy the shipping information from order fulfillment.
		var orderFulfillment = orderItem.getOrderFulfillment();
		if (!isNull(orderFulfillment)){
			setEmailAddress( orderFulfillment.getEmailAddress() );
			setShippingAddress( orderFulfillment.getShippingAddress() );
			setShippingAccountAddress( orderFulfillment.getAccountAddress() );
			setShippingMethod( orderFulfillment.getShippingMethod() );
		}
	}
	
	// ============ START: Non-Persistent Property Helper Methods =================
	
	public any function getCurrentStatus() {
		return getService("subscriptionService").getSubscriptionCurrentStatus( variables.subscriptionUsageID );
	}
	
	public string function getCurrentStatusCode() {
		if(!isNull(getCurrentStatus())) {
			return getCurrentStatus().getSubscriptionStatusType().getSystemCode();
		}
		return "";
	}
	
	public string function getCurrentStatusType() {
		if(!isNull( getCurrentStatus() )) {
			return getCurrentStatus().getSubscriptionStatusType().getTypeName();
		}
		return "";
	}
	
	public any function getSubscriptionOrderItemName() {
		if( hasSubscriptionOrderItems() ) {
			if( !isnull( getInitialProduct() ) ){
				return getInitialProduct().getProductName();
			}
		}
		return "";
	}
	
	public any function hasSubscriptionOrderItems(){
		if ( arrayLen( getSubscriptionOrderItems( ) ) ) {
			return true;
		}
		return false;
	}
	
	public any function getInitialSubscriptionOrderItem(){
		if( hasSubscriptionOrderItems() ){
			var subscriptionSmartList = getService('SubscriptionService').getSubscriptionUsageSmartList();
			subscriptionSmartList.addFilter(propertyIdentifier="subscriptionOrderItem.subscriptionOrderItemType.systemCode", value="soitInitial");
			return subscriptionSmartList.getRecords();
		}
	}
	
	public any function getInitialOrderItem(){
		if( hasSubscriptionOrderItems() ){
			return getInitialSubscriptionOrderItem().getOrderItem();
		}
	}
	
	public any function getInitialSku(){
		if( hasSubscriptionOrderItems() ){
			return getInitialOrderItem().getSku();
		}
	}
	
	public any function getInitialProduct(){
		if( hasSubscriptionOrderItems() ){
			return getInitialSku().getProduct();
		}
	}
	
	public any function getInitialOrder(){
		if( hasSubscriptionOrderItems() ){
			return getInitialOrderItem().getOrder();
		}
		
	}
	
	public any function getMostRecentSubscriptionOrderItem(){
		if( hasSubscriptionOrderItems() ){
			var subscriptionSmartList = getService('SubscriptionService').getSubscriptionUsageSmartList();
			subscriptionSmartList.addOrder("createdDateTime|DESC");
			return subscriptionSmartList.getRecords();
		}
	}

	public any function getMostRecentOrderItem(){
		if( hasSubscriptionOrderItems() && getTotalNumberOfSubscriptionOrderItems() > 1){
			return getMostRecentSubscriptionOrderItem().getOrderItem();
		}
	}
	
	public any function getMostRecentOrder(){
		if( hasSubscriptionOrderItems() && getTotalNumberOfSubscriptionOrderItems() > 1){
			return getMostRecentOrderItem().getOrder();
		}
	}
	
	public any function getTotalNumberOfSubscriptionOrderItems(){
		if( hasSubscriptionOrderItems() ){
			return arrayLen( getSubscriptionOrderItems() );
		}
	}
	
	// ============  END:  Non-Persistent Property Methods =================
		
	// ============= START: Bidirectional Helper Methods ===================
	
	// Account (many-to-one)    
	public void function setAccount(required any account) {    
		variables.account = arguments.account;    
		if(isNew() or !arguments.account.hasSubscriptionUsage( this )) {    
			arrayAppend(arguments.account.getSubscriptionUsages(), this);    
		}    
	}    
	public void function removeAccount(any account) {    
		if(!structKeyExists(arguments, "account")) {    
			arguments.account = variables.account;    
		}    
		var index = arrayFind(arguments.account.getSubscriptionUsages(), this);    
		if(index > 0) {    
			arrayDeleteAt(arguments.account.getSubscriptionUsages(), index);    
		}    
		structDelete(variables, "account");    
	}
	
	// subscriptionUsageBenefits (one-to-many)    
	public void function addSubscriptionUsageBenefit(required any subscriptionUsageBenefit) {    
		arguments.subscriptionUsageBenefit.setSubscriptionUsage( this );    
	}    
	public void function removeSubscriptionUsageBenefit(required any subscriptionUsageBenefit) {    
		arguments.subscriptionUsageBenefit.removeSubscriptionUsage( this );    
	}
	
	// Renewal Subscription Usage Benefit (one-to-many)    
	public void function addRenewalSubscriptionUsageBenefit(required any renewalSubscriptionUsageBenefit) {    
		arguments.renewalSubscriptionUsageBenefit.setRenewalSubscriptionUsage( this );    
	}    
	public void function removeRenewalSubscriptionUsageBenefit(required any renewalSubscriptionUsageBenefit) {    
		arguments.renewalSubscriptionUsageBenefit.removeRenewalSubscriptionUsage( this );    
	}
	
	// Subscription Order Items (one-to-many)    
	public void function addSubscriptionOrderItem(required any subscriptionOrderItem) {    
		arguments.subscriptionOrderItem.setSubscriptionUsage( this );    
	}    
	public void function removeSubscriptionOrderItem(required any subscriptionOrderItem) {    
		arguments.subscriptionOrderItem.removeSubscriptionUsage( this );    
	}
	
	// Subscription Status (one-to-many)    
	public void function addSubscriptionStatus(required any subscriptionStatus) {    
		arguments.subscriptionStatus.setSubscriptionUsage( this );    
	}    
	public void function removeSubscriptionStatus(required any subscriptionStatus) {    
		arguments.subscriptionStatus.removeSubscriptionUsage( this );    
	}
	// =============  END:  Bidirectional Helper Methods ===================

	// ================== START: Overridden Methods ========================
	
    public any function getAccountPaymentMethodOptions() {
		if(!structKeyExists(variables, "accountPaymentMethodOptions")) {
			variables.accountPaymentMethodOptions = [];
			var smartList = getService("accountService").getAccountPaymentMethodSmartList();
			smartList.addFilter(propertyIdentifier="account.accountID", value=getAccount().getAccountID());
			smartList.addOrder("accountPaymentMethodName|ASC");
			for(var apm in smartList.getRecords()) {
				arrayAppend(variables.accountPaymentMethodOptions,{name=apm.getSimpleRepresentation(),value=apm.getAccountPaymentMethodID()});
			}
		}
		return variables.accountPaymentMethodOptions;
    }
    
	public string function getSimpleRepresentation() {
		return getSubscriptionOrderItemName();
	}
	
	public any function getShippingAddress() {
		if(structKeyExists(variables, "shippingAddress")) {
			return variables.shippingAddress;
		} else if (!isNull(getShippingAccountAddress())) {
			setShippingAddress( getShippingAccountAddress().getAddress().copyAddress( true ) );
			return variables.shippingAddress;
		}
		return getService("addressService").newAddress();
	}
	// ==================  END:  Overridden Methods ========================
	
	// =================== START: ORM Event Hooks  =========================
	
	// ===================  END:  ORM Event Hooks  =========================
}
