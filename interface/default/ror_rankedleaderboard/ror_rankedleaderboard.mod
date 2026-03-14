<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="RoR_RankedLeaderboard" version="1.5" date="16/12/2021" >
        <Author name="Return of Reckoning" email="" />
        <Description text="This module contains the Ranked Scoreboard Screen." />
        <Dependencies>
            <Dependency name="EATemplate_Icons" />				
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_Tooltips" />
			<Dependency name="EA_TomeOfKnowledge" />
			<Dependency name="LibSlash" optional="true"/>	
			
        </Dependencies>
        <Files>
            <File name="ror_rankedleaderboard.xml" />		
        </Files>
		<OnUpdate>
		<CallFunction name="RoR_RankedLeaderboard.Editbox_Update" />
    	</OnUpdate>
		
		
		<SavedVariables>
			<SavedVariable name="RoR_RankedLeaderboard.Hasinit" />
		</SavedVariables>
        <OnInitialize>
            <CreateWindow name="RoR_RankedLeaderboard" show="false" />
        </OnInitialize>
    </UiMod>
    
</ModuleFile>    