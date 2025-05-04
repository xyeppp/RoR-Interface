<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_RvRTracker" version="1.0" date="10/6/2010" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default RvR Tracker window." />
        <Dependencies>
            <!-- Dependency name="EASystem_GlyphDisplay" / !-->
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_Utils" />
        </Dependencies>
        <Files>
            <File name="Source/RvRTracker.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_RvRTracker" show="true" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
