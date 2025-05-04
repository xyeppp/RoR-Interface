<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_LiveEvents" version="1.0" date="10/10/2008" autoenabled="true">
        <Author name="Mythic Entertainment" email="" />
        <Description text="Adds Live-Events to the Guild Calendar"/>
        <Dependencies>        
            <Dependency name="EASystem_WindowUtils" />
        </Dependencies>
        <Files>
          <File name="LiveEvents.lua" />
        </Files>
        <SavedVariables>
            <SavedVariable name="LiveEvents.savedVariables" />
        </SavedVariables>
        <OnInitialize>
            <CallFunction name="LiveEvents.Initialize" />
        </OnInitialize>
        <OnShutdown>
            <CallFunction name="LiveEvents.Shutdown" />
        </OnShutdown>
        <OnUpdate>
        </OnUpdate>
    </UiMod>
    
</ModuleFile>    