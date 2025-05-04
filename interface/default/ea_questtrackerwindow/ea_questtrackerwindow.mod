<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_QuestTrackerWindow" version="2.0" date="8/12/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA Default Quest Tracker." />
        <Dependencies>
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EA_TomeOfKnowledge" />
            <Dependency name="EA_ContextMenu" />
            <Dependency name="EA_ChatWindow" />
            <!-- <Dependency name="EA_OverheadMapWindow" /> This causes a stack overflow?  Eh? -->
        </Dependencies>
        <Files>
            <File name="Source/Templates_QuestTrackerWindow.xml" />
            <File name="Source/QuestTrackerWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_QuestTrackerNub"          show="true" />
            <CreateWindow name="EA_Window_QuestTracker"             show="true" />
            <CreateWindow name="EA_Window_SetQuestTrackerOpacity"   show="false" />
        </OnInitialize>
        <SavedVariables>
            <SavedVariable name="EA_Window_QuestTracker.Settings" />
        </SavedVariables>
    </UiMod>

</ModuleFile>
