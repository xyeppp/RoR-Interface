<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_WorldMapWindow" version="1.6" date="8/9/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA Battle Group window." />
        <Dependencies>
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EA_ThreePartBar" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EATemplate_ParchmentWindowSkin" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EA_ScreenFlashWindow" />
            <Dependency name="EASystem_Strings" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EASystem_RRQ" />
            <Dependency name="EASystem_GlyphDisplay" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_WorldMapWindow_Textures.xml" />          
            <File name="Source/MapIconTemplates.xml" />            
            <File name="Source/WorldMapWindowTemplates.xml" />
            <File name="Source/CampaignViewTemplates.xml" />
            <File name="Source/ZoneViewTemplates.xml" />
            <File name="Source/PairingViewTemplates.xml" />
            <File name="Source/WorldViewTemplates.xml" />
            <File name="Source/WorldMapWindow.xml" />
            <File name="Source/WorldMapWindow.lua" />
            <File name="Source/MapDefs.lua" />
            <File name="Source/MapIconTemplates.lua" />
            <File name="Source/CampaignView.lua" />
            <File name="Source/PairingView.lua" />
            <File name="Source/WorldView.lua" />
            <File name="Source/ZoneView.lua" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_WorldMap" show="false" />
            <CreateWindow name="EA_Window_CampaignMap" show="true" />
            <CreateWindow name="EA_Window_RRQTracker" show="true" />
        </OnInitialize>
        <SavedVariables>
            <SavedVariable name="EA_Window_WorldMap.Settings" />
        </SavedVariables>
    </UiMod>

</ModuleFile>
