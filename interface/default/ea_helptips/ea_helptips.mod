<?xml version="1.0" encoding="utf-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_HelpTips" version="1.1" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the Help Tips system for new players" />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin"/>            
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_LayoutEditor" />            
            <Dependency name="EASystem_ActionBarClusterManager" />
            <Dependency name="EASystem_Utils"/>
            <Dependency name="EA_ActionBars" />
            <Dependency name="EA_MenuBarWindow" />            
            <Dependency name="EA_MouseOverTargetWindow"/>
            <Dependency name="EATemplate_ParchmentWindowSkin" />
            <Dependency name="EA_InteractionWindow" />
        </Dependencies>
        <Files>
            <File name="Source/HelpTips.xml" />
            <File name="Source/HelpTipsReferences.lua" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_HelpTipsContainerWindow" show="true" />
            <CallFunction name="HelpTips.Initialize"/>
        </OnInitialize>
        <OnShutdown>
            <CallFunction name="HelpTips.Shutdown"/>
        </OnShutdown>
    </UiMod>

</ModuleFile>