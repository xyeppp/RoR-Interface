<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_PlayerAssist" version="1.0" date="10/17/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA assist mod window." />
        <Dependencies>        
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />            
        </Dependencies>
        <Files>        
            <File name="Source/EA_PlayerAssist.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_AssistWindow" />
            <CallFunction name="EA_PlayerAssist.Initialize"/>
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    