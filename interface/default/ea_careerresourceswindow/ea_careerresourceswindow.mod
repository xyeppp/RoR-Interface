<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_CareerResourcesWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA Default CareerResources Window." />
        <Dependencies>
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EA_ActionBars" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_Career_Textures.xml" />
            
            <File name="Source/CareerResourceData.lua" />
            <File name="Source/CareerResourceFrame.lua" />
            <File name="Source/CareerResourceWindow.lua" />
            
            <File name="Source/CareerResourceTemplate.xml" />
            <File name="Source/PetWindow.xml" />
            <File name="Source/Archmage.xml" />
            <File name="Source/BrightWizard.xml" />
            <File name="Source/BlackGuard.xml" />
            <File name="Source/BlackOrc.xml" />
            <File name="Source/Choppa.xml" />
            <File name="Source/Disciple.xml" />
            <File name="Source/Engineer.lua" />
            <File name="Source/IronBreaker.xml" />
            <File name="Source/Magus.lua" />
            <File name="Source/Shaman.xml" />
            <File name="Source/Slayer.xml" />
            <File name="Source/Sorceress.xml" />
            <File name="Source/SquigHerder.lua" />
            <File name="Source/Swordmaster.xml" />
            <File name="Source/WarriorPriest.xml" />
            <File name="Source/WhiteLion.lua" />
            <File name="Source/WitchHunter.xml" />
            <File name="Source/WitchElf.xml" />
        </Files>
        <OnInitialize>
            <CallFunction name="CareerResource.Initialize" />
        </OnInitialize>
        <OnShutdown>
            <CallFunction name="CareerResource.Shutdown" />
        </OnShutdown>
        <OnUpdate>
            <CallFunction name="CareerResource.Update" />
        </OnUpdate>
    </UiMod>
</ModuleFile>
