<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="RoR_MatchMakingRaiting" version="0.1" date="25/09/2016" >
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="ReturnOfReckoning" email="" />
		<Description text="This module contains the RoR Default Matchmaking Raiting System." />
		    <Dependencies>
            <Dependency name="EA_TomeOfKnowledge" />
			<Dependency name="EA_ChatWindow" />
        </Dependencies>
		<Files>
		<File name="Source/MatchMakingRaiting.lua" />
		</Files>
		<OnInitialize>
		<CallFunction name="RoR_MatchMakingRaiting.OnInitialize" /> 
		</OnInitialize>
		<OnUpdate>
    	</OnUpdate>
        <OnShutdown>
        </OnShutdown>
	</UiMod>
</ModuleFile>