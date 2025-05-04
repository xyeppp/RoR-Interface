<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_CharacterWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all the information needed to make action bars." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_Cursor" />
            <Dependency name="EA_ModifyItem" />
            <Dependency name="EA_TomeOfKnowledge" />
            <Dependency name="EA_GuildWindow" />
        </Dependencies>
        <Files>        
            <File name="Source/CharacterWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="CharacterWindow" show="false" />
        </OnInitialize>
        <OnUpdate>
            <CallFunction name="CharacterWindow.OnUpdate" />
        </OnUpdate>   
    </UiMod>
    
</ModuleFile>    