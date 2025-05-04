<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_TargetWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default player Target window." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EATemplate_UnitFrames" />
            <Dependency name="EA_PlayerStatusWindow" />
        </Dependencies>
        <Files>        
            <File name="Source/TargetWindow.xml" />
            <File name="Source/TargetWindow.lua" />
        </Files>
        <OnInitialize>
            <CreateWindow name="PrimaryTargetLayoutWindow" show="true" />
            <CreateWindow name="SecondaryTargetLayoutWindow" show="true" />
            <CallFunction name="TargetWindow.Initialize" />
        </OnInitialize>
    </UiMod>
    
</ModuleFile>    