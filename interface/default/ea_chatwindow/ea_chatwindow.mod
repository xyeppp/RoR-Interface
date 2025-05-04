<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ChatWindow" version="1.2" date="12/2/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA Default Chat Window Window" />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_TargetInfo" />
            <Dependency name="EA_ContextMenu" />
            <Dependency name="EA_InteractionWindow" />
            <Dependency name="EA_TomeOfKnowledge" />
            <Dependency name="EA_GuildWindow" />
        </Dependencies>
        <Files>
            <File name="Source/ChatSettings.lua" />
            <File name="Source/ChatOptionsWindow.xml" />
            <File name="Source/ChatFiltersWindow.xml" />
            <File name="Source/ChatWindowVerticalScroll.xml" />
            <File name="Source/ChatWindow.xml" />
            <File name="Source/ChatHyperLinkingTemplates.xml" />
        </Files>
        <OnInitialize>
            <CallFunction name="EA_ChatWindow.Initialize" />
            <CreateWindow name="ChatOptionsWindow" show="false" />
            <CreateWindow name="ChatFiltersWindow" show="false" />
        </OnInitialize>
        <SavedVariables>
            <SavedVariable name="ChatSettings.ChannelColors" />
            <SavedVariable name="EA_ChatWindow.Settings" />
        </SavedVariables>
    </UiMod>

</ModuleFile>
