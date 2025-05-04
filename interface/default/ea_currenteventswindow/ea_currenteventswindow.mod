<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_CurrentEventsWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module the current events window" />
        <Dependencies>
            <Dependency name="EATemplate_ParchmentWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
        </Dependencies>
        <Files>        
            <File name="Source/CurrentEventsWindow.xml" />
            <File name="Source/CurrentEventDefs.lua" />
            <File name="Source/CurrentEventsWindow.lua" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_CurrentEvents" show="false"/>
        </OnInitialize>
        <SavedVariables>
            <SavedVariable name="EA_Window_CurrentEvents.Settings" />
        </SavedVariables>
    </UiMod>

</ModuleFile>    