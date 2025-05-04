<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ScenarioGroupWindow" version="1.1" date="9/16/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default scenario grouping interface components." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EATemplate_DefaultWindowSkin"  />
            <Dependency name="EASystem_Tooltips" />
			<Dependency name="EASystem_ResourceFrames" />   
			<Dependency name="EASystem_Strings" />   
			<Dependency name="EA_AlertTextWindow" />
			<Dependency name="EA_BattlegroupHUD" />
			<Dependency name="EA_GroupWindow" />
        </Dependencies>
        <Files>        
            <File name="Source/ScenarioGroupWindow.lua" />
            <File name="Source/ScenarioGroupWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="ScenarioGroupWindow" show="false" />
        </OnInitialize>         
        <SavedVariables>
            <SavedVariable name="ScenarioGroupWindow.GroupWindowSettings" />
        </SavedVariables>
    </UiMod>
    
</ModuleFile>    