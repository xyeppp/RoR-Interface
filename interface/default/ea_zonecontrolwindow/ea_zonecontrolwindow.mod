<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ZoneControlWindow" version="1.1" date="8/12/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This window displays the RvR Control status for the player's current zone." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EATemplate_ParchmentWindowSkin" />
            <Dependency name="EASystem_AdvancedWindowManager" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_ThreePartBar" />
        </Dependencies>
        <Files>
            <File name="Source/ZoneControlWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_ZoneControl" show="true" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
