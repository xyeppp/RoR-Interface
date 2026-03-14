<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_MailWindow" version="3.1" date="7/23/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all of the screens for the Default EA Mail Window." />
        <Dependencies>
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_ResourceFrames" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EA_ContextMenu" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_MailWindow01_32b.xml" />
            <File name="Source/Templates_MailWindow.xml" />
          
            <File name="Source/MailWindowUtils.lua" />
          
            <File name="Source/MailWindowTabInbox.xml" />
            <File name="Source/MailWindowTabAuction.xml" />
            <File name="Source/MailWindowTabSend.xml" />
            <File name="Source/MailWindowTabMessage.xml" />
            <File name="Source/MailWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="MailWindow" show="false" />
            <CreateWindow name="MailWindowTabMessage" show="false" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
