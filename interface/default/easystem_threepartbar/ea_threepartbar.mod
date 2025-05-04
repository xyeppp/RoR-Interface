<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

   <UiMod name="EA_ThreePartBar" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default Three Part Bar used for representing the progress of the opposing sides in Warhammer." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_VictoryPoints01_32b.xml" />
            <File name="Source/EA_ThreePartBar.xml" />
        </Files>        
        <OnInitialize>
            <CallFunction name="ThreePartBar.Initialize" />
        </OnInitialize>   
        <OnShutdown>
            <CallFunction name="ThreePartBar.Shutdown" />
        </OnShutdown>
    </UiMod>
</ModuleFile>    