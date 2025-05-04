<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ScenarioLobbyWindow" version="1.2" date="9/4/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default Scenario Lobby." />
        <Dependencies>   
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_ContextMenu" />
        </Dependencies>
        <Files>        
            <File name="Source/ScenarioLobbyWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_ScenarioLobby" show="false" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    