<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_MoraleWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default Morale Window." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />            
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EA_Cursor" />
            <Dependency name="EA_ActionBars" />
            <Dependency name="EASystem_AdvancedWindowManager" />
        </Dependencies>
        <Files>
            <File name="Textures/MoraleWindowAnimationTextures.xml" />
            <File name="Source/MoraleWindow.xml" />
        </Files>
        <OnInitialize>
            <CallFunction name="MoraleSystem.Initialize" />
        </OnInitialize>
        <OnShutdown>
            <CallFunction name="MoraleSystem.Shutdown" />
        </OnShutdown>
        <OnUpdate>
            <CallFunction name="MoraleSystem.Update" />
        </OnUpdate>        
    </UiMod>
    
</ModuleFile>    