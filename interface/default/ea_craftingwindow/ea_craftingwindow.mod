<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_CraftingSystem" version="1.1" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default Crafting Window." />
        <Dependencies>
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EA_CastTimerWindow" />
            <Dependency name="EA_ContextMenu" />
            <Dependency name="EA_BackpackWindow" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_CraftingWindow_Textures.xml" />
            <File name="Source/CraftingWindowTemplates.xml" />
            <File name="Source/ApothecaryWindow.xml" />
            <File name="Source/SalvagingWindow.xml" />
            <File name="Source/TalismanMakingWindow.xml" />
            <File name="Source/EquipmentUpgradeWindow.xml" />
            <File name="Source/CraftingWindow.lua" />
        </Files>
        <OnInitialize>
            <CreateWindow name="ApothecaryWindow" show="false" />
            <CreateWindow name="SalvagingWindow" show="false" />
            <CreateWindow name="TalismanMakingWindow" show="false" />
            <CreateWindow name="EquipmentUpgradeWindow" show="false" />
            <CallFunction name="CraftingSystem.Initialize" />
        </OnInitialize>
        <OnShutdown>
            <CallFunction name="CraftingSystem.Shutdown" />
        </OnShutdown>
    </UiMod>

</ModuleFile>
