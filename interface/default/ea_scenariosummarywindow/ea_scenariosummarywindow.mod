<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ScenarioSummaryWindow" version="1.1" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the Scenario Summary Screen." />
        <Dependencies>
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_Tooltips" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_ScenarioSummary01_d8.xml" />
            <File name="ScenarioSummaryWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="ScenarioSummaryWindow" show="false" />
        </OnInitialize>    
    </UiMod>
    
</ModuleFile>    