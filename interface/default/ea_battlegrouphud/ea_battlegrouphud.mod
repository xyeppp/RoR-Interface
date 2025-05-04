<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_BattlegroupHUD" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA Abilities window." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_GroupWindow" />
            <Dependency name="EA_PlayerMenu" />
        </Dependencies>
        <Files>        
            <File name="Source/BattlegroupHUD.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="BattlegroupHUDGroup1LayoutWindow" show="true" />
            <CreateWindow name="BattlegroupHUDGroup2LayoutWindow" show="true" />
            <CreateWindow name="BattlegroupHUDGroup3LayoutWindow" show="true" />
            <CreateWindow name="BattlegroupHUDGroup4LayoutWindow" show="true" />
            <CallFunction name="BattlegroupHUD.Initialize" />
        </OnInitialize>
        <OnShutdown>
            <CallFunction name="BattlegroupHUD.Shutdown" />
        </OnShutdown>
        <SavedVariables>
            <SavedVariable name="BattlegroupHUD.WindowSettings" />
        </SavedVariables>
    </UiMod>
    
</ModuleFile>    