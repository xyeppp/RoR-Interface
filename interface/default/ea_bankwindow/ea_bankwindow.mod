<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_BankWindow" version="0.2" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="Your character's bank." />
        <Dependencies>
            <Dependency name="EASystem_ResourceFrames" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EATemplate_Icons" />

            <Dependency name="EA_ItemStackingWindow" />
        </Dependencies>
        <Files>
            <File name="Source/BankWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="BankWindow" show="false" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
