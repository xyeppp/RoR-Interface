<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_DeathWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default Death Window." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_Death01_d5.xml" />
            <File name="Source/DeathWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="DeathWindow" show="false" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    