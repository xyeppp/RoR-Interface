<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EASystem_DialogManager" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default Dialog System." />
         <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
        </Dependencies>
        <Files>
            <File name="Source/OneButtonDlg.xml" />
            <File name="Source/TwoButtonDlg.xml" />
            <File name="Source/ThreeButtonDlg.xml" />
            <File name="Source/TextEntryDlg.xml" />
            <File name="Source/Dialogs.lua" />
            <File name="Source/DialogManager.lua" />
        </Files>
        <OnInitialize>
            <CallFunction name="DialogManager.Initialize"/>
        </OnInitialize> 
        <OnUpdate>
            <CallFunction name="DialogManager.Update"/>
        </OnUpdate>         
    </UiMod>
    
</ModuleFile>    