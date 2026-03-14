<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="RoR_MultiSpec" version="0.5" date="19/02/2021">
        <Author name="RoR" />
        <Description text="Multi spec" />
 
        <Dependencies>
            <Dependency name="EASystem_Strings" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_TargetInfo" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EATemplate_UnitFrames" />
            <Dependency name="EA_InteractionWindow" />	  
        </Dependencies>
 
        <Files>
            <File name="MultiSpec.lua" />
			<File name="MultiSpec.xml" />
        </Files>
		
        <OnInitialize>
			<CreateWindow name="MultiSpec_Window" show="false" />
            <CallFunction name="MultiSpec.OnInitialize" />

        </OnInitialize>

		<OnUpdate>
    	</OnUpdate>
	    <SavedVariables>
			<SavedVariable name="MultiSpec.Name"/>
	    </SavedVariables>
        <OnShutdown>
			<CallFunction name="MultiSpec.OnShutdown" />
		</OnShutdown>
    </UiMod>
</ModuleFile>