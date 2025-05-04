<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="RoR_GroupScoreboard" version="1.1" date="5/4/2021" >
        <Author name="Return of Reckoning" email="" />
        <Description text="This module contains the Group Scoreboard Screen." />
        <Dependencies>
            <Dependency name="EATemplate_Icons" />				
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="ror_PacketHandling" />
            <Dependency name="json" />
        </Dependencies>
        <Files>
            <File name="Textures/RoR_GroupScoreboard01_d8.xml" />
            <File name="RoRGroupScoreboard.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="RoRGroupScoreboard" show="false" />
        </OnInitialize>
    </UiMod>
    
</ModuleFile>    