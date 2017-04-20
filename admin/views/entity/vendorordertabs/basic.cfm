<cfimport prefix="swa" taglib="../../../../tags" />
<cfimport prefix="hb" taglib="../../../../org/Hibachi/HibachiTags" />

<cfparam name="rc.vendorOrder" type="any" />
<cfparam name="rc.edit" type="boolean" />

<cfoutput>
	<hb:HibachiPropertyRow>
		<hb:HibachiPropertyList>
			<cfif rc.vendorOrder.isNew()>
				<hb:HibachiPropertyDisplay object="#rc.vendorOrder#" property="currencyCode" edit="true">
			<cfelse>
				<hb:HibachiPropertyDisplay object="#rc.vendorOrder#" property="vendorOrderStatusType">	
			</cfif>
			<hb:HibachiPropertyDisplay object="#rc.vendorOrder#" property="vendor" autocompletePropertyIdentifiers="vendorName,vendorWebsite,accountNumber,primaryEmailAddress.emailAddress" fieldtype="textautocomplete" edit="#rc.vendorOrder.isNew()#">
			<hb:HibachiPropertyDisplay object="#rc.vendorOrder#" property="vendorOrderNumber" edit="#rc.vendorOrder.isNew()#">
			<hb:HibachiPropertyDisplay object="#rc.vendorOrder#" property="estimatedReceivalDateTime" edit="#rc.edit#">
			<swa:SlatwallLocationTypeahead property="#rc.vendorOrder.getBillToLocation()#" locationPropertyName="billToLocation.locationID" locationLabelText="#rc.$.slatwall.rbKey('entity.vendororder.billtolocation')#" edit="#rc.edit#" showActiveLocationsFlag="true"></swa:SlatwallLocationTypeahead>
 		</hb:HibachiPropertyList>
 	</hb:HibachiPropertyRow>
 </cfoutput> 