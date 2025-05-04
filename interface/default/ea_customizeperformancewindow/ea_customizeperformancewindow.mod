<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_CustomizePerformanceWindow" version="1.0" date="8/5/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module is used to customize performance settings" />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Strings" />
            <Dependency name="EASystem_Tooltips" />
        </Dependencies>
        <Files>        
            <File name="Source/EA_CustomizePerformanceWindow.xml" />
        </Files>

        <OnInitialize>
            <CreateWindow name="EA_Window_CustomizePerformance" show="false" />
        </OnInitialize>
        
    </UiMod>
    
</ModuleFile>    