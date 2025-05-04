<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_GuildWindow" version="2.0" date="1/13/2009" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all of the Guild Related windows." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_TargetInfo" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_SocialWindow" />
            <Dependency name="EA_LiveEvents" optional="true" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_Guild01_d5.xml" />
            <File name="Source/GuildTacticsList.xml" />
            <File name="Source/Templates_GuildWindow.xml" />
            <File name="Source/GuildWindowTabProfile.xml" />

            <File name="Source/GuildRespecTacticsList.xml" />

            <File name="Source/Calendar.xml" />

            <File name="Source/GuildWindowTabCalendar.xml" />
            <File name="Source/GuildWindowTabRoster.xml" />
            <File name="Source/GuildWindowTabAlliance.xml" />
            <File name="Source/GuildWindowTabBanner.xml" />
            <File name="Source/GuildWindowTabRewards.xml" />
            <File name="Source/GuildWindowTabAdmin.xml" />
            <File name="Source/GuildWindowTabRecruitProfile.xml" />
            <File name="Source/GuildWindowTabRecruitSearch.xml" />
            <File name="Source/GuildWindowTabRecruit.xml" />

            <File name="Source/HeraldryEditor.xml" />
            <File name="Source/ColorPicker.xml" />

            <File name="Source/GuildWindow.xml" />
        </Files>
        <OnInitialize>                      
            <CreateWindow name="GuildWindow" show="false" />
            <CreateWindow name="HeraldryEditor" show="false" />
            <CreateWindow name="ColorPicker" show="false" />
            <CreateWindow name="GuildTacticsList" show="false" />
            <CreateWindow name="GuildRespecTacticsList" show="false" />
            <CreateWindow name="TransferGuildConfirmationWindow" show="false" />          
        </OnInitialize>
      <SavedVariables>
            <SavedVariable name="GuildWindow.SavedSettings" />
            <SavedVariable name="GuildWindowTabRecruit.Settings" />
      </SavedVariables>
    </UiMod>
    
</ModuleFile>    
