<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_ContextMenu" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the template for a creating a right click context menu." />
        <Dependencies>   
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
        </Dependencies>
        <Files>        
            <File name="Source/ContextMenu.xml" />
        </Files>
        <OnInitialize>
            <CallFunction name="EA_Window_ContextMenu.Initialize" />
        </OnInitialize>             
    </UiMod>

</ModuleFile>    