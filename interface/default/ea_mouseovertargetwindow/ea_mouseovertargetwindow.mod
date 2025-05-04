<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_MouseOverTargetWindow" version="2.2" date="12/12/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default player MouseOverTarget window." />
        <Dependencies>        
            <Dependency name="EATemplate_DefaultWindowSkin" />            
            <Dependency name="EATemplate_UnitFrames" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_LayoutEditor" />            
            <Dependency name="EASystem_Tooltips" />            
        </Dependencies>
        <Files>        
            <File name="Source/MouseOverTargetWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="MouseOverTargetWindow" show="true" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>       