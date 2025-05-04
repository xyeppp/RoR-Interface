<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_UiModWindow" version="3.0" date="12/8/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default Ui Mod Settings Window." />
        <Dependencies>        
            <Dependency name="EATemplate_DefaultWindowSkin" />     
            <Dependency name="EASystem_WindowUtils" />        
        </Dependencies>
        <Files>
            <File name="Source/UiModInfoTemplate.xml" />
            <File name="Source/UiModWindow.xml" />
            <File name="Source/UiModAdvancedWindow.xml" />
            <File name="Source/VersionMismatchWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="UiModWindow" show="false" />
            <CreateWindow name="UiModAdvancedWindow" show="false" />
            <CreateWindow name="UiModVersionMismatchWindow" show="false" />
        </OnInitialize>
        <SavedVariables>
            <SavedVariable name="UiModWindow.Settings" />
        </SavedVariables>            
    </UiMod>
    
</ModuleFile>    