<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ObjectiveTrackers" version="1.7" date="11/11/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA public quest, scenario, battlefield, and keep objective tracker and alert system." />
        <Dependencies>
            <Dependency name="EASystem_AdvancedWindowManager" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EA_OverheadMapWindow" />
            <Dependency name="EA_TomeOfKnowledge" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
        </Dependencies>
        <Files>
            <File name="Source/Templates_ObjectiveTrackers.xml" />
            <File name="Source/TrackerUtils.lua" />
            <File name="Source/PublicQuestTrackerWindow.xml" />
            <File name="Source/BattlefieldObjectiveTracker.xml" />
            <File name="Source/KeepObjectiveTracker.xml" />
            <File name="Source/ScenarioTrackerWindow.xml" />
            <File name="Source/CityTrackerWindow.xml" />
            <File name="Source/PublicQuestResults.xml" />
            <File name="Source/WinOMeterWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_PublicQuestTracker"               show="true" />
            <CreateWindow name="EA_Window_BattlefieldObjectiveTracker"      show="true" />
            <CreateWindow name="EA_Window_KeepObjectiveTracker"             show="true" />
            <CreateWindow name="EA_Window_CityTracker"                      show="true" />
            <CreateWindow name="EA_Window_ScenarioTracker"                  show="true" />
            <CreateWindow name="EA_Window_PublicQuestResults"               show="false" />
            <CreateWindow name="EA_Window_WinOMeter"                        show="true" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
