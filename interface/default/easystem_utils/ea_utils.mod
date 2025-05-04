<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EASystem_Utils" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all of the data utility code and functions used across the EA Default Ui for Warhammer." />
        <Dependencies>
            <Dependency name="EA_UiDebugTools" />            
            <Dependency name="EASystem_Strings" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
        </Dependencies>
        <Files>                
            <File name="Source/GameDefs.lua" />
            <File name="Source/DataUtils.lua" />
            <File name="Source/QuestUtils.lua" />
            <File name="Source/SoundUtils.lua" />
            <File name="Source/TimeUtils.lua" />
            <File name="Source/Player.lua" />
            <File name="Source/IdGenerator.lua" />
            <File name="Source/TimedStateMachine.lua" />
            <File name="Source/IconButtonUtils.lua" />
            <File name="Source/KeyUtils.lua" />
            <File name="Source/Queue.lua" />
            <File name="Source/MapUtils.lua" />
            <File name="Source/PublicQuestStates.lua" />
            <File name="Source/MailUtils.lua" />
            <File name="Source/FileUtils.lua" />
            <File name="Source/PartyUtils.lua" />
            <File name="Source/CraftingUtils.lua" />
            <File name="Source/FriendSuggester.lua" />
            <File name="Source/ItemUtils.lua" />
            <File name="Source/HelpUtils.lua" />
            <File name="Source/BindOptionsDlg.xml" />
        </Files>
        <SavedVariables>
            <SavedVariable name="FriendSuggester.Data" />
        </SavedVariables>
        <OnInitialize>
            <CallFunction name="DataUtils.Initialize" />
            <CallFunction name="Player.Initialize" />
            <CallFunction name="PQData.Initialize" />
            <CallFunction name="MailUtils.Initialize" />
            <CallFunction name="PartyUtils.Initialize" />
            <CallFunction name="FriendSuggester.Initialize" />
            <CallFunction name="ItemUtils.Initialize" />
        </OnInitialize>    
        <OnUpdate>
            <CallFunction name="DataUtils.Update" />
            <CallFunction name="TimedStateMachineManager.Update" />
            <CallFunction name="PQData.OnUpdate" />
            <CallFunction name="FriendSuggester.Update" />
        </OnUpdate>   
        <OnShutdown>        
            <CallFunction name="DataUtils.Shutdown" />
            <CallFunction name="Player.Shutdown" />
            <CallFunction name="PQData.Shutdown" />
            <CallFunction name="MailUtils.Shutdown" />
            <CallFunction name="PartyUtils.Shutdown" />
            <CallFunction name="ItemUtils.Shutdown" />
        </OnShutdown>            
    </UiMod>
    
</ModuleFile>    
