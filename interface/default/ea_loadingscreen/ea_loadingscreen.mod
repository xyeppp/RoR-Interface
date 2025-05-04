<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_LoadingScreen" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the loading screen system." />
         <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EATemplate_ParchmentWindowSkin" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EA_ScenarioSummaryWindow" />
        </Dependencies>
        <Files>
            <File name="Textures/Textures.xml" />
            <File name="Source/GeneralLoadingScreenTemplates.xml" />
            <File name="Source/StandardLoadingScreenTemplate.xml" />
            <File name="Source/ScenarioEnterLoadingScreenTemplate.xml" />
            <File name="Source/ScenarioExitLoadingScreenTemplate.xml" />
            <File name="Source/NoDataLoadingScreenTemplate.xml" />
            <File name="Source/PatchNotesLoadingScreenTemplate.xml" />
            <File name="Source/LoadingScreen.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_LoadingScreen" show="false" />
        </OnInitialize>   
    </UiMod>
    
</ModuleFile>    