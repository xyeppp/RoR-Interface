<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_Cursor" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default cursor management system." />
        <Dependencies>
            <Dependency name="EASystem_Utils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_DialogManager" />
        </Dependencies>
        <Files>
            <File name="Source/Cursor.lua" />
        </Files>
        <OnInitialize>
            <CreateWindow name="CursorWindow" show="false" />
            <CallFunction name="Cursor.Initialize" />
        </OnInitialize>
        <OnUpdate>
            <CallFunction name="Cursor.Update" />
        </OnUpdate>
        <OnShutdown>
            <CallFunction name="Cursor.Shutdown" />
        </OnShutdown>
    </UiMod>

</ModuleFile>
