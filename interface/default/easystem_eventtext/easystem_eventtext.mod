<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EASystem_EventText" version="1.0" date="3/24/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the system for display text near monsters or players in the world. This is currently used for damage text, combat event text, and xp, renown, influence display." />
        <Dependencies>
            <Dependency name="EASystem_Utils" />
        </Dependencies>
        <Files>
            <File name="Source/Templates_EventText.xml" />
            <File name="Source/System_EventText.xml" />
            <File name="Source/System_EventText.lua" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_EventTextContainer" show="true" />
            <CallFunction name="EA_System_EventText.Initialize" />
        </OnInitialize>
        <OnUpdate>
            <CallFunction name="EA_System_EventText.Update" />
        </OnUpdate>
        <OnShutdown>
            <CallFunction name="EA_System_EventText.Shutdown" />
        </OnShutdown>
    </UiMod>

</ModuleFile>
