<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_OpenPartyWindow" version="1.3" date="4/22/2009" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA Open Party window." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EATemplate_Icons" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_GroupWindow" />
            <Dependency name="EA_PlayerStatusWindow" />
            <Dependency name="EA_PlayerMenu" />
            <Dependency name="EA_ContextMenu" />
        </Dependencies>
        <Files>
            <File name="Source/OpenPartyWindowCommon.xml" />
            <File name="Source/OpenPartyWindowTabNearby.xml" />
            <File name="Source/OpenPartyWindowTabWorld.xml" />
            <File name="Source/OpenPartyWindowTabLootRollOptions.xml" />
            <File name="Source/OpenPartyWindowTabManage.xml" />
            <File name="Source/OpenPartyWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_OpenPartyFlyOutAnchor" show="false" />
            <CreateWindow name="EA_Window_OpenPartyFlyOut" show="true" />
            <CreateWindow name="EA_Window_OpenParty" show="false" />
        </OnInitialize>
        <SavedVariables>
            <SavedVariable name="EA_Window_OpenPartyWorld.Settings" />
            <SavedVariable name="EA_Window_OpenPartyLootRollOptions.Settings" />
        </SavedVariables>
    </UiMod>
    
</ModuleFile>    
