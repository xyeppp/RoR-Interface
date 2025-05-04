<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EASystem_LayoutEditor" version="1.1" date="7/22/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains a Layout Editor for the HUD." />
        <Dependencies>        
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EA_UiDebugTools" />            
            <Dependency name="EASystem_Strings" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_ContextMenu" />
        </Dependencies>
        <Files>                
            <File name="Source/LayoutFrameTemplates.xml" />
            <File name="Source/LayoutEditorWindowBrowser.xml" />
            <File name="Source/LayoutEditorOptions.xml" />
            <File name="Source/LayoutEditor.xml" />
            <File name="Source/LayoutControlFrame.lua" />            
            <File name="Source/LayoutFrame.lua" />              
            <File name="Source/LayoutSnapFrame.lua" />   
            <File name="Source/LayoutEditor.lua" />  
            <File name="Source/LayoutEditorUtils.lua" />                       
            <File name="Source/LayoutEditorWindowBrowser.lua" /> 
            <File name="Source/LayoutEditorOptions.lua" /> 
        </Files>
        <OnInitialize>
            <CallFunction name="LayoutEditor.Initialize" />
        </OnInitialize>    
        <OnShutdown>        
            <CallFunction name="LayoutEditor.Shutdown" />
        </OnShutdown>       
        <SavedVariables>
            <SavedVariable name="LayoutEditor.Settings" />
        </SavedVariables>     
    </UiMod>
    
</ModuleFile>    
