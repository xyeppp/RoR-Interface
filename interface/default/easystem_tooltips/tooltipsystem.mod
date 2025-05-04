<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EASystem_Tooltips" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the tooltip management system." />
        <Dependencies>
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EATemplate_ParchmentWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_ResourceFrames" />
        </Dependencies>
        <Files>
            <File name="Source/Tooltips.xml" />
            <File name="Source/AbilityTooltips.xml" />
            <File name="Source/ItemTooltips.xml" />
            <File name="Source/MapTooltips.xml" />
            <File name="Source/TomeTooltips.xml" />
            <File name="Source/CareerTooltips.xml" />
            <File name="Source/Tooltips.lua" />
            <File name="Source/MapTooltips.lua" />
            <File name="Source/ItemTooltips.lua" />
            <File name="Source/AbilityTooltips.lua" />
            <File name="Source/TomeTooltips.lua" />
            <File name="Source/CareerTooltips.lua" />
        </Files>
        <OnInitialize>
            <CallFunction name="Tooltips.Initialize"/>
        </OnInitialize>
        <OnUpdate>
            <CallFunction name="Tooltips.Update"/>
        </OnUpdate>
    </UiMod>

</ModuleFile>
