<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ItemStackingWindow" version="1.0" date="12/19/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA item stacking window." />
        <Dependencies>
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_Cursor" />
        </Dependencies>
        <Files>
            <File name="Source/ItemStackingWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="ItemStackingWindow" show="false" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
