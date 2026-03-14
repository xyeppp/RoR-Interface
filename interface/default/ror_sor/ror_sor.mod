<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="RoR_SoR" version="1.2.7" date="24/04/2024" >
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="Return of Reckoning"/>
		<Description text="State of Realm, a warfront battle tracker" />
		 <Dependencies>                
			<Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_ChatWindow" />
            <Dependency name="EATemplate_ParchmentWindowSkin" />			
			<Dependency name="EA_SiegeWeaponWindow" />
		    <Dependency name="RoR_CitySiege" />
		    <Dependency name="ror_PacketHandling" />
			<Dependency name="json" />
		  <Dependency name="LibSlash" optional="true"/>		  
        </Dependencies>	
		<Files>
		<File name="RoR_SoR.lua" />		
 <File name="RoR_SoR.xml" />
		</Files>
		<OnInitialize>
		<CallFunction name="RoR_SoR.OnInitialize" /> 	
		</OnInitialize>
			<SavedVariables>
			<SavedVariable name="RoR_SoR.Settings" global="false"/>
			<SavedVariable name="RoR_SoR.City_Status" global="false"/>									
			</SavedVariables>
		<OnUpdate>
		<CallFunction name="RoR_SoR.TIMER_UPDATE" />
    	</OnUpdate>
        <OnShutdown>
		<CallFunction name="RoR_SoR.OnShutdown" /> 	
        </OnShutdown>
		
		
	</UiMod>
</ModuleFile>
	