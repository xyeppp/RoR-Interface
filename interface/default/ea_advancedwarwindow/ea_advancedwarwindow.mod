<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_AdvancedWarWindow" version="2.1" date="2/13/2012" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default Advanced War Window." />
        <Dependencies>           
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_Cursor" />
        </Dependencies>
        <Files>        
            <File name="Source/AdvancedWarWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_AdvancedWar" show="false" />
	    </OnInitialize>             
    </UiMod>
    
</ModuleFile>    