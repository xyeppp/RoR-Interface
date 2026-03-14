<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_TomeOfKnowledge" version="1.2" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all of the code and data for the Tome Of Knowledge window." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EATemplate_ParchmentWindowSkin" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EA_ContextMenu" />
            <Dependency name="EASystem_GlyphDisplay" />
            <Dependency name="EA_TomeAlertWindow" />
        </Dependencies>
        <Files>
            <File name="Source/TomeWindow_CoreDefs.xml" />
            <File name="Source/TomeWindow_TitlePage.xml" />
            <File name="Source/TomeWindow_WarJournal.xml" />
            <File name="Source/TomeWindow_QuestJournal.xml" />
            <File name="Source/TomeWindow_Rewards.xml" />
            <File name="Source/TomeWindow_Achievements.xml" />
            <File name="Source/TomeWindow_Bestiary.xml" />
            <File name="Source/TomeWindow_NoteworthyPersons.xml" />
            <File name="Source/TomeWindow_HistoryAndLore.xml" />
            <File name="Source/TomeWindow_OldWorldArmory.xml" />
            <File name="Source/TomeWindow_OldWorldArmory_Sigils.xml" />
            <File name="Source/TomeWindow_Sigils.xml" />
            <File name="Source/TomeWindow_LiveEvent.xml" />
            <File name="Source/TomeWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="TomeWindow" show="false" />
        </OnInitialize>
        <SavedVariables>
            <SavedVariable name="TomeWindow.LiveEventSettings" />
        </SavedVariables>
    </UiMod>
    
</ModuleFile>    