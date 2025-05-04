<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ChatSystem" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA Default Chat System. This provides chat bubbles and conversation windows between players." />
        <Dependencies>
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_ChatWindow" />
        </Dependencies>
        <Files>
            <File name="Source/ConversationWindow.xml" />
            <File name="Source/ChatManager.lua" />
        </Files>
        <OnInitialize>
            <CallFunction name="ChatManager.Initialize" />
        </OnInitialize>
        <OnUpdate>
            <CallFunction name="ChatManager.Update" />
        </OnUpdate>
        <OnShutdown>
            <CallFunction name="ChatManager.Shutdown" />
        </OnShutdown>
    </UiMod>

</ModuleFile>
