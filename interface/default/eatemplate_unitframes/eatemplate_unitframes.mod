<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EATemplate_UnitFrames" version="1.0" date="11/15/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains templates for all of our standard unit frames." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_TargetInfo" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EA_PlayerMenu" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_TempTargets_d3.xml" />
            <File name="Textures/EA_BuffFrames01.xml" />
            <File name="Source/Templates_UnitFrames.xml" />
        </Files>
        <OnInitialize>
            <CallFunction name="UnitFrames.InitializeProxy" /> 
        </OnInitialize>  
        <OnUpdate>
            <CallFunction name="UnitFrames.UpdateProxy" />
        </OnUpdate>
        <OnShutdown>
            <CallFunction name="UnitFrames.ShutdownProxy" />
        </OnShutdown>   
    </UiMod>
    
</ModuleFile>    