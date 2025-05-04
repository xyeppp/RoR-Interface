<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_GroupWindow" version="1.2" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA Group window." />
        <Dependencies>                
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EA_PlayerStatusWindow" />
            <Dependency name="EA_PlayerMenu" />
        </Dependencies>
        <Files>        
            <File name="Source/GroupWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="GroupWindow" show="true" />
            <CallFunction name="GroupWindow.Initialize" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    