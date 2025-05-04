<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_TradeWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default player trading window." />
        <Dependencies>        
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_ResourceFrames" />
            <Dependency name="EA_Cursor" />
        </Dependencies>
        <Files>
            <File name="Source/TradeWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_Trade" show="false" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
