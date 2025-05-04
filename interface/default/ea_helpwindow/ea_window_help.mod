<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_Window_Help" version="2.0" date="8/8/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all of the Help Related windows." />
        <Dependencies>
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_ChatSystem" />
            <Dependency name="EA_HelpTips" />
            <Dependency name="EATemplate_ParchmentWindowSkin" />
            <Dependency name="EA_InteractionWindow" />
        </Dependencies>
        <Files>
            <File name="Textures/EA_Help01_32b.xml" />
            <File name="Textures/EA_Help_Tutorial_TexDefs.xml" />
            <File name="Source/Templates_EA_Window_Help.xml" />
            <File name="Source/Templates_Appeals.xml" />
            <File name="Source/EA_Window_Help.xml" />
            <File name="Source/EA_Window_Appeal.xml" />
            <File name="Source/BugReportWindow.xml" />
            <File name="Source/EA_Window_Feedback.xml" />
            <File name="Source/ManualWindow.xml" />
            <File name="Source/FAQWindow.xml" />
            <File name="Source/EditAppealWindow.xml" />            
            
            <File name="Source/Tutorials/TutorialWindowTemplates.xml" />
            <File name="Source/Tutorials/TutorialWindowTabBasicControls1.xml" />
            <File name="Source/Tutorials/TutorialWindowTabBasicControls2.xml" />
            <File name="Source/Tutorials/TutorialWindowTabQuests1.xml" />
            <File name="Source/Tutorials/TutorialWindowTabCombat1.xml" />
            <File name="Source/Tutorials/TutorialWindowTabInventory1.xml" />
            <File name="Source/Tutorials/TutorialWindowTabTraining1.xml" />
            <File name="Source/Tutorials/TutorialWindowTabGrouping1.xml" />
            <File name="Source/Tutorials/TutorialWindowTabGrouping2.xml" />
            <File name="Source/Tutorials/TutorialWindowTabTOK1.xml" />
            <File name="Source/Tutorials/TutorialWindowTabScenario1.xml" />
            <File name="Source/Tutorials/TutorialWindowTabWarCamp1.xml" />
            <File name="Source/Tutorials/TutorialWindowTabPQ1.xml" />
            <File name="Source/Tutorials/TutorialWindowTabRenown1.xml" />
            <File name="Source/TutorialWindow.xml" />
            
            <File name="Source/TipsWindow.xml" />   
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_Help" show="false" />
            <CreateWindow name="EA_Window_Appeal" show="false" />
            <CreateWindow name="BugReportWindow" show="false" />
            <CreateWindow name="EA_Window_Feedback" show="false" />
            <CreateWindow name="ManualWindow" show="false" />
            <CreateWindow name="FAQWindow" show="false" />
            <CreateWindow name="EditAppealWindow" show="false" />
            <CreateWindow name="TipsWindow" show="false" />
            <CreateWindow name="TutorialWindow" show="false" />
        </OnInitialize>
        <SavedVariables>
            <SavedVariable name="TutorialWindow.Settings" />
        </SavedVariables>
    </UiMod>

</ModuleFile>
