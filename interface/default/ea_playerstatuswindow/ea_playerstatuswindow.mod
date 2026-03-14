<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_PlayerStatusWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default player Player Status window." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EATemplate_UnitFrames" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EA_TacticsWindow" />
        </Dependencies>
        <Files>     
            <File name="Textures/EA_ScenarioSummary01_d5.xml" />
            <File name="Source/PlayerWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="PlayerWindow" show="true" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    