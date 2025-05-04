<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_TomeAlertWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This is the EA default window for announcing new tome unlocks." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EATemplate_ParchmentWindowSkin" />
            <Dependency name="EASystem_AdvancedWindowManager" />
        </Dependencies>
        <Files>        
            <File name="Source/TomeAlertWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="TomeAlertWindow" show="false" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    