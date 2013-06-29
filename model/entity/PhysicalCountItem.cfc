/*

    Slatwall - An e-commerce plugin for Mura CMS
    Copyright (C) 2011 ten24, LLC

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
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

*/
component entityname="SlatwallPhysicalCountItem" table="SwPhysicalCountItem" persistent="true" accessors="true" extends="HibachiEntity" cacheuse="transactional" hb_serviceName="physicalService" hb_permission="this" {
	
	// Persistent Properties
	property name="physicalCountItemID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="quantity" ormtype="integer";
	property name="skuCode" ormtype="string";
	property name="countPostDateTime" ormtype="timestamp";
	 
	// Calculated Properties

	// Related Object Properties (many-to-one)
	property name="physicalCount" cfc="PhysicalCount" fieldtype="many-to-one" fkcolumn="physicalCountID";
	property name="stock" cfc="Stock" fieldtype="many-to-one" fkcolumn="stockID";
	
	// Related Object Properties (one-to-many)
	
	// Related Object Properties (many-to-many - owner)

	// Related Object Properties (many-to-many - inverse)
	
	// Remote Properties
	property name="remoteID" ormtype="string";
	
	// Audit Properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	// Non-Persistent Properties 
	property name="physicalStatusTypeSystemCode" persistent="false";
	property name="sku" cfc="Sku" fieldtype="many-to-one" fkcolumn="skuID" persistent="false";
	

	
	// ============ START: Non-Persistent Property Methods =================
	
	public string function getPhysicalStatusTypeSystemCode() {
		return getPhysicalCount().getPhysicalStatusTypeSystemCode();
	}
	
	// ============  END:  Non-Persistent Property Methods =================
		
	// ============= START: Bidirectional Helper Methods ===================
	
	// Phyiscal Count (many-to-one)
	public void function setPhysicalCount(required any physicalCount) {
		variables.physicalCount = arguments.physicalCount;
		if(isNew() or !arguments.physicalCount.hasPhysicalCountItem( this )) {
			arrayAppend(arguments.physicalCount.getPhysicalCountItems(), this);
		}
	}
	public void function removePhysicalCount(any physicalCount) {
		if(!structKeyExists(arguments, "physicalCount")) {
			arguments.physicalCount = variables.physicalCount;
		}
		var index = arrayFind(arguments.physicalCount.getPhysicalCountItems(), this);
		if(index > 0) {
			arrayDeleteAt(arguments.physicalCount.getPhysicalCountItems(), index);
		}
		structDelete(variables, "physicalCount");
	}
	
	// =============  END:  Bidirectional Helper Methods ===================

	// =============== START: Custom Validation Methods ====================
	
	// ===============  END: Custom Validation Methods =====================
	
	// =============== START: Custom Formatting Methods ====================
	
	// ===============  END: Custom Formatting Methods =====================
	
	// ============== START: Overridden Implicet Getters ===================
	
	public any function getSku() {
		if(structKeyExists(variables, "sku")) {
			return variables.sku;
		}
		if(!isNull(getStock())) {
			return getStock().getSku();
		}
	}
	
	public string function getSkuCode() {
		if(!isNull(getSku())) {
			return getSku().getSkuCode();
		}
		if(structKeyExists(variables, "skuCode")) {
			return variables.skuCode;
		}
	}
	
	// ==============  END: Overridden Implicet Getters ====================

	// ================== START: Overridden Methods ========================
	public string function getSimpleRepresentationPropertyName() {
		return "skuCode";
	}
	
	// ==================  END:  Overridden Methods ========================
	
	// =================== START: ORM Event Hooks  =========================
	
	// ===================  END:  ORM Event Hooks  =========================
	
	// ================== START: Deprecated Methods ========================
	
	// ==================  END:  Deprecated Methods ========================
}