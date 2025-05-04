<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_PlayerMenu" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default Player Menu Window Lobby." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_TargetInfo" />
            <Dependency name="EA_ContextMenu" />

            <!-- The mod does actually depend on the Group, Battlegroup, and Guild Data, but this results in circular dependencies.
             None of the code that uses thess mods is used durring initialization, only at run time. The real solution here is to move the data to a centra
             location in DataUtils and query that information directly -->
            
            <!--
            <Dependency name="EA_GuildWindow" />
            <Dependency name="EA_GroupWindow" />
            <Dependency name="EA_BattlegroupWindow" />
            <Dependency name="EA_TradeWindow" />
            -->
        </Dependencies>
        <Files>
            <File name="Source/PlayerMenuWindow.lua" />
        </Files>
        <OnInitialize>
            <CallFunction name="PlayerMenuWindow.Initialize" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
