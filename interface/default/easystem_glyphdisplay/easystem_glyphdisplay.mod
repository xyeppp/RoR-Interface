<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

   <UiMod name="EASystem_GlyphDisplay" version="1.0" date="4/28/2009" >
        <Author name="EAMythic" email="" />
        <Description text="Provides various auto-updating display elements for various war journal entries' glyph sets." />
        <Dependencies>        
            <Dependency name="EASystem_Utils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EASystem_Tooltips" />
        </Dependencies>
        <Files>
            <File name="Source/GlyphDisplay.xml" />
        </Files>        
        <OnInitialize>
            <CreateWindow name="EA_Window_GlyphTracker" show="true" />
            <CallFunction name="GlyphDisplay.Initialize" />
        </OnInitialize>   
        <OnShutdown>
            <CallFunction name="GlyphDisplay.Shutdown" />
        </OnShutdown>
    </UiMod>
</ModuleFile>    