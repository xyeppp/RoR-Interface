<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ScenarioLobbyWindow" version="1.4" date="9/4/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default Scenario Lobby." />
        <Dependencies>   
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_ContextMenu" />
            <Dependency name="EA_ActionBars" />			
			<Dependency name="EA_TrialAlertWindow" />						
            <Dependency name="ror_PacketHandling" />			
        </Dependencies>
        <Files>        
            <File name="Source/ScenarioLobbyWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_ScenarioLobby" show="false" />
        </OnInitialize>             
    <SavedVariables>
			<SavedVariable name="EA_Window_ScenarioLobby.BlackList"/>
	</SavedVariables>
	</UiMod>
    
</ModuleFile>    