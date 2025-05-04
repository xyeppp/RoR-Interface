<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_OverheadMapWindow" version="2.3" date="8/12/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA Default Overhead Map (MiniMap) Window" />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_WorldMapWindow" />
            <Dependency name="EA_ScenarioSummaryWindow" />
            <Dependency name="EA_ZoneControlWindow" />
            <Dependency name="EASystem_AdvancedWindowManager" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_Scenario01_32b.xml" />
            <File name="Source/Templates_OverheadMap.xml" />
            <File name="Source/OverheadMapWindow.xml" />
        </Files>
        <OnInitialize>            
            <CreateWindow name="EA_Window_OverheadMapPinFilterMenu" show="false" />
            <CreateWindow name="EA_Window_OverheadMap"              show="true" />
        </OnInitialize>
        <SavedVariables>
            <SavedVariable name="EA_Window_OverheadMap.Settings" />
        </SavedVariables>
    </UiMod>

</ModuleFile>
