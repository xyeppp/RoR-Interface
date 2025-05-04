<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_XpBarWindow" version="1.0" date="2/12/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the window that displays the player's experience." />
        <Dependencies>        
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EASystem_AdvancedWindowManager" />
        </Dependencies>
        <Files>        
            <File name="Source/XpBarWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="XpBarWindow" show="true" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    