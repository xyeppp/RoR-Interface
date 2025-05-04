<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_LootWindow" version="2.2" date="9/2/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default Loot Windows." />
        <Dependencies>           
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_Cursor" />
            <Dependency name="EA_OpenPartyWindow" />
        </Dependencies>
        <Files>        
            <File name="Source/LootWindow.xml" />
            <File name="Source/ChooseOneLootWindow.xml" />
            <File name="Source/LootRollWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_Loot" show="false" />
            <CreateWindow name="EA_Window_LootRoll" show="false" />
            <CreateWindow name="EA_Window_ChooseOneLoot" show="false" />
	</OnInitialize>             
    </UiMod>
    
</ModuleFile>    