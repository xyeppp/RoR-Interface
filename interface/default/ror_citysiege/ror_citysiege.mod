<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="RoR_CitySiege" version="0.2" date="24/04/2024" >
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="ReturnOfReckoning" email="" />
		<Description text="This module contains the RoR Default City Siege System." />
		<Dependencies>
			<Dependency name="EA_ChatWindow" />
			<Dependency name="json" />
			<Dependency name="ror_PacketHandling" />
        </Dependencies>
		<Files>
			<File name="Source/CitySiege.lua" />
		</Files>
        <SavedVariables>
            <SavedVariable name="RoR_CitySiege.Data" />
        </SavedVariables>
		<OnInitialize>
			<CallFunction name="RoR_CitySiege.OnInitialize" /> 
		</OnInitialize>
		<OnUpdate>
			<CallFunction name="RoR_CitySiege.Update" /> 
    	</OnUpdate>
        <OnShutdown>
        </OnShutdown>
	</UiMod>
</ModuleFile>