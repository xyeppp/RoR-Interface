<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ItemEnhancementWindow" version="1.01" date="12/1/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This is the EA default window for enhancing items." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_Cursor" />
            <Dependency name="EA_LegacyTemplates" />
        </Dependencies>
        <Files>
            <File name="Source/ItemEnhancementWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="ItemEnhancementWindow" show="false" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
