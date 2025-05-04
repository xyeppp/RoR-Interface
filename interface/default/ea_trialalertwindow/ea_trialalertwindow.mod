<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_TrialAlertWindow" version="1.0" date="2/3/2009" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Trial Alert Window." />
        <Dependencies>        
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_TrialAlertTextures.xml" />
            <File name="Source/EA_TrialAlertWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_TrialAlertWindow" show="false" />
        </OnInitialize>
        <SavedVariables>
            <SavedVariable name="EA_TrialAlertWindow.IsFirstRun" />
        </SavedVariables>
    </UiMod>
    
</ModuleFile>    