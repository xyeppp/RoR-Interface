<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="RoR_MapExtension" version="0.2" date="14/06/2020" >
        <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
        <Author name="Sullemunk"/>
        <Description text="RoR Map Extension" />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_TargetInfo" />
            <Dependency name="EA_ContextMenu" />
            <Dependency name="EA_ChatWindow" />
            <Dependency name="EA_ChatSystem" />
            <Dependency name="EA_WorldMapWindow" /> 
            <Dependency name="EA_TargetWindow" /> 	
            <Dependency name="EA_PlayerMenu" /> 							
        </Dependencies>
        <Files>
            <File name="mapextension.lua" />
            <File name="mapextension.xml" />
        </Files>
        <OnInitialize>
        <CallFunction name="RoR_MapExtension.OnInitialize" /> 
        </OnInitialize>
        <OnShutdown>
        </OnShutdown>		
	</UiMod>
</ModuleFile>