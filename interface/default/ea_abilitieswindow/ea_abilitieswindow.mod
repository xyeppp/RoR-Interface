<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_AbilitiesWindow" version="1.01" date="01/08/2009" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA Abilities window." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_Cursor" />
            <Dependency name="EA_TacticsWindow" />
            <Dependency name="EA_MoraleWindow" />
            <Dependency name="EA_CraftingSystem" />
            <Dependency name="EA_ContextMenu" />
            <Dependency name="EA_ChatWindow" />
        </Dependencies>
        <Files>        
            <File name="Textures/AbilitiesWindowTextures.xml" />
            <File name="Source/AbilitiesWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="AbilitiesWindow" show="false" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    