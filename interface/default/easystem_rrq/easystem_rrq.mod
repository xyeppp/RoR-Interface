<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

   <UiMod name="EASystem_RRQ" version="1.1" date="4/1/2009" >
        <Author name="EAMythic" email="" />
        <Description text="Realm Resource Quest utils and display bars." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_TombToggle01_32b.xml" />
            <File name="Source/RRQProgressBar.xml" />
        </Files>        
        <OnInitialize>
            <CallFunction name="RRQProgressBar.Initialize" />
        </OnInitialize>   
        <OnShutdown>
            <CallFunction name="RRQProgressBar.Shutdown" />
        </OnShutdown>
    </UiMod>
</ModuleFile>    