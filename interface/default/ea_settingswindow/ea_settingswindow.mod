<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_SettingsWindow" version="1.1" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default User Settings Window." />
        <Dependencies>        
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_ActionBarClusterManager" optional="true" />
            <Dependency name="EASystem_AdvancedWindowManager" optional="true"/>
            <Dependency name="EA_Window_Help" optional="true"/>
        </Dependencies>
        <Files>
            <File name="Textures/SettingsWindowTextures.xml" />
            
            <File name="Source/Templates_SettingsWindowTabbed.xml" />
            
            <File name="Source/SettingsWindowTabGeneral.xml" />
            <File name="Source/SettingsWindowTabVideo.xml" />
            <File name="Source/SettingsWindowTabSound.xml" />
            <File name="Source/SettingsWindowTabChat.xml" />
            <File name="Source/SettingsWindowTabTargetting.xml" />
            <File name="Source/SettingsWindowTabInterface.xml" />
            <File name="Source/SettingsWindowTabServer.xml" />			
            
            <File name="Source/SettingsWindowTabbed.xml" />
        </Files>
        <SavedVariables>
            <SavedVariable name="SettingsWindowTabInterface.SavedMessageSettings" />
            <SavedVariable name="SettingsWindowTabServer.SavedSettings" />			
        </SavedVariables>
        <OnInitialize>
            <CreateWindow name="SettingsWindowTabbed" show="false" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    