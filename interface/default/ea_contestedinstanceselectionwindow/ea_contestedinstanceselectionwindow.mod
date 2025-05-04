<?xml version="1.0" encoding="utf-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ContestedInstanceSelectionWindow" version="1.0" date="03/02/2009">
        <Author name="EAMythic" email="" />
        <Description text="This module contains the Contested Instance Selection Screen." />
        <Dependencies>
            <Dependency name="EASystem_Strings" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
        </Dependencies>
        <Files>
            <File name="Source/ContestedInstanceSelectionWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="ContestedInstanceSelectionWindow" show="false" />
        </OnInitialize>
    </UiMod>
</ModuleFile>
