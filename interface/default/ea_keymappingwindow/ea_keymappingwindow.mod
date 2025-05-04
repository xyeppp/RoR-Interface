<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_KeyMappingWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all of the EA Default Keybindings window." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EATemplate_DefaultWindowSkin" />  
            <Dependency name="EASystem_Tooltips" />
        </Dependencies>
        <Files>        
            <File name="Source/KeyMappingWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="KeyMappingWindow" show="false" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    