<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ActionBars" version="1.22" date="10/10/2008" autoenabled="true">
        <Author name="EAMythic" email="" />
        <Description text="The default Hotbar system" />
        <Dependencies>        
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EA_KeyMappingWindow" />
            <Dependency name="EA_Cursor" />
            <Dependency name="EA_UiDebugTools" />
        </Dependencies>
        <Files>
            <File name="Textures/ActionBarEndCapTextures.xml" />
            <File name="Textures/ActionBarAnimationTextures.xml" />
            <File name="Source/ActionBars.xml" />
            <File name="Source/ActionBarConstants.lua" />
            <File name="Source/ActionButton.lua" />
            <File name="Source/ActionBars.lua" />            
            <File name="Source/StanceButton.lua" />
            <File name="Source/StanceBar.lua" />
            <File name="Source/StanceSwaps.lua" />
        </Files>
        <SavedVariables>
            <SavedVariable name="EA_ActionBars_DataCache" />
            <SavedVariable name="EA_ActionBars_Settings" />
        </SavedVariables>
        <OnInitialize>
            <CallFunction name="ActionBars.Initialize" />
            <CallFunction name="ActionBarStanceSwaps.Initialize" />
            <CallFunction name="StanceBar.Initialize" />
        </OnInitialize>
        <OnShutdown>
            <CallFunction name="ActionBars.Shutdown" />
            <CallFunction name="ActionBarStanceSwaps.Shutdown" />
            <CallFunction name="StanceBar.Shutdown" />
        </OnShutdown>
        <OnUpdate>
            <CallFunction name="ActionBars.UpdateProxy" />
        </OnUpdate>
    </UiMod>
</ModuleFile>    