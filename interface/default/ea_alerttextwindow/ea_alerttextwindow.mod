<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_AlertTextWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module constauins the AlertText system for proving pop up text in the middle of the screen.." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin"/>
            <Dependency name="EASystem_Utils"/>
        </Dependencies>
        <Files>
            <File name="Source/AlertTextWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="AlertTextContainerWindow" show="true" />
            <CallFunction name="AlertTextWindow.Initialize"/>
        </OnInitialize>
        <OnUpdate>
            <CallFunction name="AlertTextWindow.Update"/>
        </OnUpdate>
        <OnShutdown>
            <CallFunction name="AlertTextWindow.Shutdown"/>
        </OnShutdown>
    </UiMod>

</ModuleFile>
