<cfparam name="attributes.hibachiScope" type="any" default="#request.context.fw.getHibachiScope()#" />
<cfparam name="attributes.object" type="any" default="" />
<cfparam name="attributes.allowComments" type="boolean" default="false">
<cfparam name="attributes.allowCustomAttributes" type="boolean" default="false">
<cfparam name="attributes.subsystem" type="string" default="#request.context.fw.getSubsystem( request.context[ request.context.fw.getAction() ])#">
<cfparam name="attributes.section" type="string" default="#request.context.fw.getSection( request.context[ request.context.fw.getAction() ])#">

<cfif (not isObject(attributes.object) || not attributes.object.isNew()) and (not structKeyExists(request.context, "modal") or not request.context.modal)>
	<cfif thisTag.executionMode is "end">
		
			<cfparam name="thistag.tabs" default="#arrayNew(1)#" />
			<cfparam name="activeTab" default="tabSystem" />
			
			
			<cfloop array="#thistag.tabs#" index="tab">
				<!--- Make sure there is a view --->
				<cfif not len(tab.view) and len(tab.property)>
					<cfset tab.view = "#attributes.subsystem#:#attributes.section#/#lcase(attributes.object.getClassName())#tabs/#tab.property#" />
					
					<cfset propertyMetaData = attributes.object.getPropertyMetaData( tab.property ) />
					
					<cfif not len(tab.text)>
						<cfset tab.text = attributes.hibachiScope.rbKey('entity.#attributes.object.getClassName()#.#tab.property#') />
					</cfif>
					
					<cfif structKeyExists(propertyMetaData, "fieldtype") and listFindNoCase("many-to-one,one-to-many,many-to-many", propertyMetaData.fieldtype)>
						<cfset tab.count = attributes.object.getPropertyCount( tab.property ) />
					</cfif>
				</cfif>
				
				<!--- Make sure there is a tabid --->
				<cfif not len(tab.tabid)>
					<cfset tab.tabid = "tab" & listLast(tab.view, '/') />
				</cfif>
				
				<!--- Make sure there is text for the tab name --->
				<cfif not len(tab.text)>
					<cfset tab.text = attributes.hibachiScope.rbKey( replace( replace(tab.view, '/', '.', 'all') ,':','.','all' ) ) />
				</cfif>
				
				<cfif not len(tab.tabcontent)>
					<cfif fileExists(expandPath(request.context.fw.parseViewOrLayoutPath(tab.view, 'view')))>
						<cfset tab.tabcontent = request.context.fw.view(tab.view, {rc=request.context, params=tab.params}) />
					<cfelseif len(tab.property)>
						<cfsavecontent variable="tab.tabcontent">
							<cf_HibachiPropertyDisplay object="#attributes.object#" property="#tab.property#" edit="#request.context.edit#" displaytype="plain" />
						</cfsavecontent>
					</cfif>
				</cfif>
			</cfloop>
						
			<cfif arrayLen(thistag.tabs)>
				<cfset activeTab = thistag.tabs[1].tabid />
			</cfif>
			
			<div class="tabbable tabs-left row-fluid">
				<div class="tabsLeft">
					<ul class="nav nav-tabs">
						<cfloop array="#thistag.tabs#" index="tab">
							<cfoutput><li <cfif activeTab eq tab.tabid>class="active"</cfif>><a href="###tab.tabid#" data-toggle="tab">#tab.text#<cfif tab.count> <span class="badge">#tab.count#</span></cfif></a></li></cfoutput>
						</cfloop>
						<!---
						<cfif isObject(attributes.object) && attributes.allowCustomAttributes>
							<cfloop array="#attributes.object.getAssignedAttributeSetSmartList().getRecords()#" index="attributeSet">
								<cfoutput><li><a href="##tab#lcase(attributeSet.getAttributeSetCode())#" data-toggle="tab">#attributeSet.getAttributeSetName()#</a></li></cfoutput>
							</cfloop>
						</cfif>
						--->
						<cfif isObject(attributes.object)>
							<cfoutput><li><a href="##tabSystem" data-toggle="tab">#attributes.hibachiScope.rbKey('define.system')#</a></li></cfoutput>
						</cfif>
					</ul>
				</div>
				<div class="tabsRight">
					<div class="tab-content">
						<cfloop array="#thistag.tabs#" index="tab">
							<cfoutput>
								<div <cfif activeTab eq tab.tabid>class="tab-pane active"<cfelse>class="tab-pane"</cfif> id="#tab.tabid#">
									<div class="row-fluid">
										#tab.tabcontent#
									</div>
								</div>
							</cfoutput>
						</cfloop>
						<!---
						<cfif isObject(attributes.object) && attributes.allowCustomAttributes>
							<cfloop array="#attributes.object.getAssignedAttributeSetSmartList().getRecords()#" index="attributeSet">
								<cfoutput>
									<div class="tab-pane" id="tab#lcase(attributeSet.getAttributeSetCode())#">
										<div class="row-fluid">
											<cf_HibachiAttributeSetDisplay attributeSet="#attributeSet#" entity="#attributes.object#" edit="#request.context.edit#" />
										</div>
									</div>
								</cfoutput>
							</cfloop>
						</cfif>
						--->
						<cfif isObject(attributes.object)>
							<div <cfif arrayLen(thistag.tabs)>class="tab-pane"<cfelse>class="tab-pane active"</cfif> id="tabSystem">
								<div class="row-fluid">
									<cf_HibachiPropertyList> 
										<cf_HibachiPropertyDisplay object="#attributes.object#" property="#attributes.object.getPrimaryIDPropertyName()#" />
										<cfif attributes.object.hasProperty('remoteID')>
											<cf_HibachiPropertyDisplay object="#attributes.object#" property="remoteID" edit="#iif(request.context.edit && attributes.hibachiScope.setting('globalRemoteIDEditFlag'), true, false)#" />
										</cfif>
										<cfif attributes.object.hasProperty('createdDateTime')>
											<cf_HibachiPropertyDisplay object="#attributes.object#" property="createdDateTime" />
										</cfif>
										<cfif attributes.object.hasProperty('createdByAccount')>
											<cf_HibachiPropertyDisplay object="#attributes.object#" property="createdByAccount" />
										</cfif>
										<cfif attributes.object.hasProperty('modifiedDateTime')>
											<cf_HibachiPropertyDisplay object="#attributes.object#" property="modifiedDateTime" />
										</cfif>
										<cfif attributes.object.hasProperty('modifiedByAccount')>
											<cf_HibachiPropertyDisplay object="#attributes.object#" property="modifiedByAccount" />
										</cfif>
									</cf_HibachiPropertyList>
								</div>
							</div>
						</cfif>
					</div>
				</div>
			</div>
	</cfif>
</cfif>