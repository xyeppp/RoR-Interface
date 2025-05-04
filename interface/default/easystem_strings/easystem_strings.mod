<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EASystem_Strings" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all of the data utility code and functions used across the EA Default Ui for Warhammer." />
        <Dependencies>
            <Dependency name="EA_UiDebugTools" />
        </Dependencies>
        <Files>
            <File name="Source/DataConverter.lua" />
            <File name="Source/StringUtils.lua" />
        </Files>
        <OnInitialize>
            <CallFunction name="StringUtils.Initialize" />
        </OnInitialize>    
        <OnShutdown>        
            <CallFunction name="StringUtils.Shutdown" />        
        </OnShutdown>            
    </UiMod>
    
</ModuleFile>    
