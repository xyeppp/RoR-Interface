<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_CastTimerWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA Cast and item use timer." />
        <Dependencies>        
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />            
        </Dependencies>
        <Files>        
            <File name="Source/LayerTimerWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="LayerTimerWindow" show="true" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    