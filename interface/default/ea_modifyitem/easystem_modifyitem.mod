<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >
    <UiMod name="EA_ModifyItem" version="1.0" date="3/19/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all of the item modification windows and scripts." />
        <Dependencies>
            <Dependency name="EA_Cursor" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_DialogManager" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
        </Dependencies>
        <Files>
            <File name="Source/EA_DyeWindow.xml" />
            <File name="Source/UseItemTargeting.lua" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_DyeWindow" show="false" />
        </OnInitialize>
        <OnUpdate>
        </OnUpdate>
        <OnShutdown>
        </OnShutdown>
    </UiMod>
</ModuleFile>
