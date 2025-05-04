<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_MenuBarWindow" version="1.1" date="1/28/2009" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default Menu Bar" />
        <Dependencies>        
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EA_LoadingScreen" />
        </Dependencies>
        <Files>        
            <File name="Textures/MenuBarTextures.xml" />
            <File name="Source/MenuBarTemplates.xml" />
            <File name="Source/MenuBarWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="MenuBarWindow" show="true" />
            <CreateWindow name="StreamingIndicator" show="false" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    