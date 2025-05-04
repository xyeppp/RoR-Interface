<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_MacroWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the Macros window." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
        </Dependencies>
        <Files>
            <File name="Source/MacroWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="MacroIconSelectionWindow" show="false" />
            <CreateWindow name="EA_Window_Macro" show="false" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
