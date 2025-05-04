<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_UiProfilesWindow" version="1.1" date="4/19/2009" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the UI Profile Management Windows." />
        <Dependencies>        
            <Dependency name="EATemplate_DefaultWindowSkin" />    
            <Dependency name="EASystem_WindowUtils" />    
        </Dependencies>
        <Files>        
            <File name="Source/ManageUiProfilesWindow.xml" />
            <File name="Source/ImportUiProfileWindow.xml" />
            <File name="Source/CreateUiProfileWindow.xml" />
            <File name="Source/DeleteUiProfileWindow.xml" />
            <File name="Source/RenameUiProfileWindow.xml" />
            <File name="Source/PopupDialogUiProfileWindow.xml" />
            <File name="Source/IntroDialogUiProfileWindow.xml" />
            <File name="Source/ExportUiProfileWindow.xml" />
            <File name="Source/CharacterDeletedHandler.lua" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_ManageUiProfiles" show="false" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    