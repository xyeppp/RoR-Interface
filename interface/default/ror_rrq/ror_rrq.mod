<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="RoR_RRQ" version="0.4" date="06/03/2022">
        <Author name="RoR" />
        <Description text="RoR RRQ handler" />
        <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
 
        <Dependencies>
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EA_ThreePartBar" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EATemplate_ParchmentWindowSkin" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EA_ScreenFlashWindow" />
            <Dependency name="EASystem_Strings" />
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EASystem_RRQ" />
            <Dependency name="EASystem_GlyphDisplay" />
			<Dependency name="EA_WorldMapWindow" />			
        </Dependencies>
 
		<!--Files to include in the addon -->
        <Files>
		    <File name="textures/ror_rrq_textures.xml" />
            <File name="source/ror_rrq.lua" />
			<File name="source/ror_rrq.xml" />
			
        </Files>
		
		<!-- this function will run when the addon loads -->
        <OnInitialize>
            <CallFunction name="ror_rrq.OnInitialize" />
			<CreateWindow name="EA_Window_ROR_RRQTracker" show="true" />
			<CreateWindow name="EA_Window_WorldMapRRQ_RORContainer" show="true" />			
        </OnInitialize>

		<!-- this function will run on update (every frame) -->
		<OnUpdate>
    	</OnUpdate>

		<!-- this function will run when the addon exits -->		
        <OnShutdown>
			<CallFunction name="ror_rrq.OnShutdown" />
		</OnShutdown>
    </UiMod>
</ModuleFile>