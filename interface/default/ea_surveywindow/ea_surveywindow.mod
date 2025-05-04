<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_SurveyWindow" version="1.2" date="9/5/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the Macros window." />
        <Dependencies>                
            <Dependency name="EATemplate_DefaultWindowSkin" /> 
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
        </Dependencies>
        <Files>        
            <File name="Source/SurveyWindow.xml" />
            <File name="Source/SurveyPopupWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_Survey" show="false" />
            <CreateWindow name="EA_Window_SurveyPopup" show="false" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    