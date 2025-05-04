<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_PQLootWindow" version="1.1" date="29/8/2008" f2pusable="false">
        <Author name="EAMythic" email="" />
        <Description text="This module contains the EA Default PQLoot Window." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin"  />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_ResourceFrames" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_PQLoot.xml" />
            <File name="Textures/EA_Anim_Tumblers_d1.xml" />
            <File name="Source/PQLootWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="PQLootWindow" show="false" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
