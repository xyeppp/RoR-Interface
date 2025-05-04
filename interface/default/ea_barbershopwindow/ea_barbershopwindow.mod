<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_BarbershopWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the Barbershop Window." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_Strings" />
            <Dependency name="EASystem_DialogManager" />
            <Dependency name="EASystem_ResourceFrames" />
        </Dependencies>
        <Files>
            <File name="Textures/BaseTextures.xml" />
            <File name="Source/BarbershopWindow.xml" />
        </Files>
        <OnInitialize>
            <CallFunction name="BarbershopWindow.RegisterShowEvent" />
        </OnInitialize>
        <OnShutdown>
            <CallFunction name="BarbershopWindow.UnregisterShowEvent" />
        </OnShutdown>
    </UiMod>

</ModuleFile>
