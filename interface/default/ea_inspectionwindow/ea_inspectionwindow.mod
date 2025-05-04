<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_InspectionWindow" version="1.1" date="3/14/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all the information needed to make an inspection window." />
        <Dependencies>
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_Cursor" />
            <Dependency name="EA_TomeOfKnowledge" />
        </Dependencies>
        <Files>
            <File name="Source/InspectionWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_Inspection" show="false" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
