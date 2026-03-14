<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="RoR_ScenarioSurrenderWindow" version="1.2" date="26/12/2019">
        <Author name="ReturnOfReckoning" email="" />
        <Description text="This module contains the RoR Default Scenario Surrender." />

		<Dependencies>  
			<Dependency name="EA_ChatWindow" />
			<Dependency name="EA_ScenarioGroupWindow" />
			<Dependency name="EASystem_LayoutEditor" />						
		</Dependencies>             	
        <Files>
            <File name="Source/ScenarioSurrenderWindow.lua" />           
            <File name="Source/ScenarioSurrenderWindow.xml" />    			
		</Files>
	   <OnInitialize>
            <CallFunction name="RoR_Window_ScenarioSurrender.Initialize" />
        </OnInitialize>
		<SavedVariables>
			<SavedVariable name="RoR_Window_ScenarioSurrender.ShowEmpty"/>			
		</SavedVariables>  
    </UiMod>
</ModuleFile>