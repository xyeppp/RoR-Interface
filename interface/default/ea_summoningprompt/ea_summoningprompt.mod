<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_SummoningPrompt" version="1.0" date="06/23/2009" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA summoning prompt." />
        <Dependencies>                
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
        </Dependencies>
        <Files>        
            <File name="Source/SummoningPrompt.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_SummoningAcceptPrompt" show="false" />
            <CallFunction name="EA_SummoningAcceptPrompt.Initialize" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    