<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_CultivationWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA Cultivation window." />
        <Dependencies>
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_ContextMenu" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_Cultivating01_d5.xml" />
            <File name="Source/CultivationWindowTemplates.xml" />
            <File name="Source/CultivationWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="CultivationWindow" show="false" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
