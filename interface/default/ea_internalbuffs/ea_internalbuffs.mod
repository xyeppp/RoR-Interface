<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_InternalBuffs" version="1.0" date="1/3/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This mod is for internal use" />
        <Dependencies>        
            <Dependency name="EA_PlayerStatusWindow" />
            <Dependency name="EATemplate_UnitFrames" />
            <Dependency name="EATemplate_Icons" />
        </Dependencies>
        <Files>        
            <File name="Source/EA_InternalBuffs.xml" />
        </Files>

        <OnInitialize>
            <CreateWindow name="EA_Window_InternalBuffs" show="true" />
        </OnInitialize>
        
    </UiMod>
    
</ModuleFile>    