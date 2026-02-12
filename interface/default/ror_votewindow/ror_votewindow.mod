<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="ror_votewindow" version="0.1" date="20/01/2026">
        <Author name="ReturnOfReckoning" email="" />
        <Description text="This module contains the RoR Default Ready Check." />

		<Dependencies>  
			<Dependency name="EA_ChatWindow" />
			<Dependency name="EA_ScenarioGroupWindow" />
			<Dependency name="EASystem_LayoutEditor" />						
			<Dependency name="ror_PacketHandling" />
			<Dependency name="LibSlash" optional="true"/>
		</Dependencies>             	
        <Files>
            <File name="Source/ror_votewindow.lua" />           
            <File name="Source/ror_votewindow.xml" />    			
		</Files>
	   <OnInitialize>
            <CallFunction name="ror_votewindow.Initialize" />
        </OnInitialize>
		<SavedVariables>
		<CallFunction name="ror_votewindow.Update" />			
		</SavedVariables>  
    </UiMod>
</ModuleFile>