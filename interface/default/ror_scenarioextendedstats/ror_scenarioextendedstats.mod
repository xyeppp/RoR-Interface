<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="RoR_ScenarioExtendedStats" version="0.1" date="25/09/2016" >
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="ReturnOfReckoning" email="" />
		<Description text="This module contains the RoR Extended Scenario Stats." />
		<Dependencies>
			<Dependency name="EA_ChatWindow" />
        </Dependencies>
		<Files>
			<File name="Source/ScenarioExtendedStats.lua" />
		</Files>
		<OnInitialize>
			<CallFunction name="RoR_ScenarioExtendedStats.OnInitialize" /> 
		</OnInitialize>
		<OnUpdate>
    	</OnUpdate>
        <OnShutdown>
        </OnShutdown>
	</UiMod>
</ModuleFile>