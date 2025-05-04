<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ClaimWindow" version="2.1" date="1/4/2011" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default Claim Window." />
        <Dependencies>           
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_Cursor" />
            <Dependency name="EA_OpenPartyWindow" />
        </Dependencies>
        <Files>        
            <File name="Source/ClaimWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_Claim" show="false" />
	    </OnInitialize>             
    </UiMod>
    
</ModuleFile>    