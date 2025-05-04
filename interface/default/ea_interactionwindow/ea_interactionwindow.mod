<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_InteractionWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all of the screens for the Default EA Interaction Window." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_Strings" />
            <Dependency name="EASystem_DialogManager" />
            <Dependency name="EASystem_ResourceFrames" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EA_ContextMenu" />
            <Dependency name="EA_GuildWindow" />
            <Dependency name="EA_TomeOfKnowledge" />
            <Dependency name="EA_WorldMapWindow" />
            <Dependency name="EASystem_AdvancedWindowManager" />
        </Dependencies>
        <Files>
            <File name="Textures/TrainingTextures.xml" />
            <File name="Textures/BaseTextures.xml" />

            <File name="Source/Templates_InteractionVerticalScrollbar.xml" />
            <File name="Source/Templates_InteractionBase.xml" />
            <File name="Source/Templates_InteractionQuest.xml" />
            <File name="Source/Templates_InteractionFlightMaster.xml" />
            <File name="Source/Templates_InteractionTraining.xml" />

            <File name="Source/InteractionUtils.lua" />
            <File name="Source/InteractionBase.xml" />
            <File name="Source/InteractionHealerWindow.xml" />
            <File name="Source/InteractionQuestWindow.xml" />
            <File name="Source/InteractionInfluenceRewards.xml" />
            <File name="Source/InteractionEventRewards.xml" />
            <File name="Source/InteractionFlightMaster.xml" />
            <File name="Source/InteractionTraining.lua" />
            <File name="Source/InteractionCoreTraining.xml" />
            <File name="Source/InteractionSpecialtyTraining.xml" />
            <File name="Source/InteractionRenownTraining.xml" />
            <File name="Source/InteractionTomeTraining.xml" />
            <File name="Source/InteractionTradeskills.lua" />
            <File name="Source/InteractionWindowGuildCreateForm.xml" />
            <File name="Source/InteractionWindowGuildRename.xml" />
            <File name="Source/InteractionWindowStore.xml" />
            <File name="Source/InteractionWindowAltCurrency.xml" />
            <File name="Source/InteractionWindowLibrarian.xml" />
            <File name="Source/InteractionWindowLastName.xml" />
            <File name="Source/InteractionKeepUpgrades.xml" />
            <File name="Source/InteractionAltar.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_InteractionBase" show="false" />
            <CreateWindow name="EA_Window_InteractionHealer" show="false" />
            <CreateWindow name="EA_Window_InteractionQuest" show="false" />
            <CreateWindow name="EA_Window_InteractionInfluenceRewards" show="false" />
            <CreateWindow name="EA_Window_InteractionEventRewards" show="false" />
            <CreateWindow name="EA_Window_InteractionCoreTraining" show="false" />
            <CreateWindow name="EA_Window_InteractionSpecialtyTraining" show="false" />
            <CreateWindow name="EA_Window_InteractionRenownTraining" show="false" />
            <CreateWindow name="EA_Window_InteractionTomeTraining" show="false" />
            <CreateWindow name="EA_Window_InteractionKeepUpgrades" show="false" />
            <CreateWindow name="EA_Window_InteractionAltar" show="false" />
            <CreateWindow name="EA_InteractionFlightMasterWindow" show="false" />

            <CreateWindow name="InteractionWindowGuildCreateForm" show="false" />
            <CreateWindow name="InteractionWindowGuildRename" show="false" />
            <CreateWindow name="EA_Window_InteractionStore" show="false" />
            <CreateWindow name="EA_Window_InteractionAltCurrency" show="false" />
            <CreateWindow name="EA_Window_InteractionLibrarianStore" show="false" />
            <CreateWindow name="EA_Window_InteractionLastName" show="false" />
            
            <CallFunction name="EA_Window_InteractionTraining.Initialize" />
        </OnInitialize>
        <OnShutdown>
            <CallFunction name="EA_Window_InteractionTraining.Shutdown" />
        </OnShutdown>
        <SavedVariables>
            <SavedVariable name="EA_Window_InteractionCoreTraining.Settings" />
            <SavedVariable name="EA_Window_InteractionTomeTraining.Settings" />
        </SavedVariables>
    </UiMod>

</ModuleFile>
