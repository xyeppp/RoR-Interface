----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_ScenarioLobby = {}

EA_Window_ScenarioLobby.MAX_SCENARIOS  = 10

EA_Window_ScenarioLobby.TOOLTIP_ANCHOR = { Point = "topright",   RelativeTo = "EA_Window_ScenarioLobby", RelativePoint = "topleft",   XOffset=5, YOffset=75 }

EA_Window_ScenarioLobby.ITEM_WIDTH = 375
EA_Window_ScenarioLobby.WINDOW_WIDTH = 400
EA_Window_ScenarioLobby.WINDOW_HEADER_HEIGHT = 100
EA_Window_ScenarioLobby.ITEM_HEIGHT = 85

EA_Window_ScenarioLobby.AUTO_CANCEL_TIME = 60 -- Seconds
EA_Window_ScenarioLobby.JOIN_WAIT_TIME = 59
EA_Window_ScenarioLobby.NEED_REJOIN_TIME = 60
EA_Window_ScenarioLobby.AUTO_CANCEL_TIME_CITY_JOIN = 240 -- auto cancel for city join window
EA_Window_ScenarioLobby.WAIT_TIME_CITY_JOIN = 60

EA_Window_ScenarioLobby.INSTANCETYPE_SCENARIO = 3
EA_Window_ScenarioLobby.INSTANCETYPE_CITY = 4

EA_Window_ScenarioLobby.autoCancelTime = 0
EA_Window_ScenarioLobby.waitTime	   = 0
EA_Window_ScenarioLobby.startTime	   = 0
EA_Window_ScenarioLobby.autoCancelCityInstance = 0
EA_Window_ScenarioLobby.cityInstanceWait = 0
EA_Window_ScenarioLobby.fightFlagPressed = false
EA_Window_ScenarioLobby.isLowLevel = false

EA_Window_ScenarioLobby.selectedQueue    = 1
EA_Window_ScenarioLobby.AllQueue    = 0
EA_Window_ScenarioLobby.AllData    = {}

EA_Window_ScenarioLobby.JOIN_MODE_SOLO  = 1
EA_Window_ScenarioLobby.JOIN_MODE_GROUP = 2
EA_Window_ScenarioLobby.NUM_JOIN_MODES  = 2

EA_Window_ScenarioLobby.ENABLED = 1
EA_Window_ScenarioLobby.WEEKEND_WARFRONT = 2
EA_Window_ScenarioLobby.ALLOW_GROUP_QUEUE = 4
EA_Window_ScenarioLobby.CHALLENGE_MODE = 8
EA_Window_ScenarioLobby.HEALER_INCENTIVE = 16
EA_Window_ScenarioLobby.TANK_INCENTIVE = 32
EA_Window_ScenarioLobby.DPS_INCENTIVE = 64

EA_Window_ScenarioLobby.MAX_BLACKLIST_COUNT = 10

EA_Window_ScenarioLobby.joinModes = {}
EA_Window_ScenarioLobby.joinModes[ EA_Window_ScenarioLobby.JOIN_MODE_SOLO ] = { text=GetString( StringTables.Default.LABEL_JOIN_SOLO),      joinSingleEvent=SystemData.Events.INTERACT_JOIN_SCENARIO_QUEUE,         joinAllEvent=SystemData.Events.INTERACT_JOIN_SCENARIO_QUEUE_ALL  }
EA_Window_ScenarioLobby.joinModes[ EA_Window_ScenarioLobby.JOIN_MODE_GROUP ] = { text=GetString( StringTables.Default.LABEL_JOIN_GROUP),    joinSingleEvent=SystemData.Events.INTERACT_GROUP_JOIN_SCENARIO_QUEUE,   joinAllEvent=SystemData.Events.INTERACT_GROUP_JOIN_SCENARIO_QUEUE_ALL  }


EA_Window_ScenarioLobby.joinMode        = EA_Window_ScenarioLobby.JOIN_MODE_SOLO

EA_Window_ScenarioLobby.playerActiveQueues = nil    -- List of scenarios for which the player is actively queued.

local Selected_Scenario = 0
local Insentive_Labels = {["MDps"]=L"DPS <icon45>+50% Renown",["Tank"]=L"Tanks <icon45>+50% Renown",["Healer"]=L"Healer <icon45>+50% Renown"}
local Insentive_Id = {[1]="DpsIncentive",[2]="TankIncentive",[3]="HealerIncentive"}
local Bool_Convert = {["true"] = L"1",["false"]= L"0"}
local Preferences_Icon = {["true"] = "City-Rating-Star",["false"]= "City-Rating-Star-Slot"}



----------------------------------------------------------------
----------------------------------------------------------------
-- EA_Window_ScenarioLobby Functions

-- OnInitialize Handler
function EA_Window_ScenarioLobby.Initialize()
    EA_Window_ScenarioLobby.SC_queue_Data = {}
	CreateWindow("EA_Window_BlacklistWindow", false )	
	
	-- Lobby Window
    LabelSetText( "EA_Window_ScenarioLobbyTitleBarText", GetString( StringTables.Default.LABEL_SCENARIO_LOBBY) )               
               
    for mode = 1, EA_Window_ScenarioLobby.NUM_JOIN_MODES do
        local text = EA_Window_ScenarioLobby.joinModes[mode].text
        ButtonSetText("EA_Window_ScenarioLobbyJoinMode"..mode.."Button", text )
    end
 

ButtonSetText("EA_Window_ScenarioLobbyPreferencesButton", L"Preferences" ) 
ButtonSetText("EA_Window_ScenarioLobbyScenarioTabButton", L"Scenarios" )
ButtonSetText("EA_Window_ScenarioLobbyDungeonTabButton", L"Dungeons" )	   
ButtonSetText("EA_Window_ScenarioLobbyLeaveButton", GetString( StringTables.Default.LABEL_LEAVE ) )	
ButtonSetPressedFlag("EA_Window_ScenarioLobbyScenarioTabButton",true)	   
ButtonSetStayDownFlag("EA_Window_ScenarioLobbyScenarioTabButton",true)
ButtonSetDisabledFlag("EA_Window_ScenarioLobbyDungeonTabButton",true)	
	   
    --ButtonSetText("EA_Window_ScenarioLobbyCancelButton", GetString( StringTables.Default.LABEL_CANCEL ) )
    ButtonSetText("EA_Window_ScenarioLobbyJoinButton", GetString( StringTables.Default.LABEL_SCENARIO_JOIN ) )	
    --ButtonSetText("EA_Window_ScenarioLobbyJoinAllButton", GetString( StringTables.Default.LABEL_SCENARIO_JOIN_ALL ) )	
	ButtonSetText("EA_Window_ScenarioLobbyJoinAllButton", L"Join Selected" )	
	WindowSetShowing("EA_Window_ScenarioLobbyJoinButton",false)
	WindowSetShowing("EA_Window_ScenarioLobbyJoinAllButton",false)

	
	CreateMapInstance( "EA_Window_ScenarioLobbyScenarioMap", SystemData.MapTypes.NORMAL )
    EA_Window_ScenarioLobby.SelectJoinMode( EA_Window_ScenarioLobby.JOIN_MODE_SOLO ) 
    EA_Window_ScenarioLobby.OnGroupUpdated()

	LabelSetText( "EA_Window_BlacklistWindowTitle", L"Scenario Blacklist" )               

	-- In-Queue Window
	CreateWindow("EA_Window_InScenarioQueue", false )
	ButtonSetText("EA_Window_InScenarioQueueLeaveButton", GetString( StringTables.Default.LABEL_LEAVE ) )	
	WindowSetAlpha("EA_Window_InScenarioQueue", 0.75)
	
	-- Join-Instance Window
	CreateWindow("EA_Window_ScenarioJoinPrompt", false )
	LabelSetText("EA_Window_ScenarioJoinPromptBoxTitleBarText", GetString( StringTables.Default.TEXT_SCENARIO_LAUNCHING ) )
	LabelSetText("EA_Window_ScenarioJoinPromptBoxText", GetString( StringTables.Default.TEXT_SCENARIO_JOIN_PROMPT ) )
	ButtonSetText("EA_Window_ScenarioJoinPromptBoxJoinNowButton", GetString( StringTables.Default.TEXT_JOIN_SCENARIO_NOW ) )
	ButtonSetText("EA_Window_ScenarioJoinPromptBoxJoinWaitButton", GetString( StringTables.Default.TEXT_JOIN_SCENARIO_WAIT ) )
	ButtonSetText("EA_Window_ScenarioJoinPromptBoxJoinCancelButton", GetString( StringTables.Default.TEXT_JOIN_SCENARIO_CANCEL ) )
	LabelSetText("EA_Window_ScenarioJoinPromptBoxInCombatText", GetString( StringTables.Default.TEXT_SCENARIO_JOIN_IN_COMBAT ) )
	DefaultColor.SetLabelColor( "EA_Window_ScenarioJoinPromptBoxInCombatText", DefaultColor.RED )
	
	-- Scenario Starting Window
	CreateWindow("EA_Window_ScenarioStarting", false )
	WindowSetAlpha("EA_Window_ScenarioStarting", 0.75)
    ButtonSetText("EA_Window_ScenarioStartingJoinNowButton", GetString( StringTables.Default.LABEL_JOIN ) )	
    ButtonSetText("EA_Window_ScenarioStartingJoinCancelButton", GetString( StringTables.Default.LABEL_LEAVE ) )	
    LabelSetText("EA_Window_ScenarioStartingInCombatText", GetString( StringTables.Default.TEXT_SCENARIO_JOIN_IN_COMBAT ) )
	DefaultColor.SetLabelColor( "EA_Window_ScenarioStartingInCombatText", DefaultColor.RED )
	
	EA_Window_ScenarioLobby.UpdateStartingScenario()
	
	-- City Join-Instance Window
	CreateWindow("EA_Window_CityCaptureJoinPromptWindow", false )
    LabelSetText("EA_Window_CityCaptureJoinPromptWindowBoxTitleBarText", GetString( StringTables.Default.LABEL_CITY_CAPTURE_LAUNCHING ) )
	LabelSetText("EA_Window_CityCaptureJoinPromptWindowBoxText", GetString( StringTables.Default.LABEL_JOIN_CITY_CAPTURE ) )
    ButtonSetText("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton", GetString( StringTables.Default.LABEL_YES_I_WANT_TO_PARTICIPATE ) )
    ButtonSetText("EA_Window_CityCaptureJoinPromptWindowBoxJoinWaitButton", GetString( StringTables.Default.LABEL_WAIT_NEED_MORE_TIME ) )
	ButtonSetText("EA_Window_CityCaptureJoinPromptWindowBoxJoinCancelButton", GetString( StringTables.Default.LABEL_NO_I_DO_NOT_WANT_TO_PARTICIPATE ) )       
    LabelSetText("EA_Window_CityCaptureJoinPromptWindowBoxLowLevel", GetString( StringTables.Default.TEXT_CITY_JOIN_LOW_LEVEL ) )
    DefaultColor.SetLabelColor( "EA_Window_CityCaptureJoinPromptWindowBoxLowLevel", DefaultColor.RED )
    WindowSetShowing( "EA_Window_CityCaptureJoinPromptWindowBoxLowLevel", false )
    
    CreateWindow("EA_Window_CityInstanceWait", false )
    WindowSetShowing("EA_Window_CityInstanceWait", false)   

    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.INTERACT_UPDATED_SCENARIO_QUEUE_LIST, "EA_Window_ScenarioLobby.UpdateSCList")
	  
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.INTERACT_SHOW_SCENARIO_QUEUE_LIST, "EA_Window_ScenarioLobby.UpdateQueueList")
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.SCENARIO_ACTIVE_QUEUE_UPDATED, "EA_Window_ScenarioLobby.OnPlayerActiveQueuesUpdated" )
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.SCENARIO_SHOW_JOIN_PROMPT, "EA_Window_ScenarioLobby.ShowJoinPrompt" )
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "EA_Window_ScenarioLobby.OnPlayerCombatFlagUpdated" ) 
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.PLAYER_IS_BEING_THROWN, "EA_Window_ScenarioLobby.OnPlayerCombatFlagUpdated" )      
    
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.SCENARIO_STARTING_SCENARIO_UPDATED, "EA_Window_ScenarioLobby.UpdateStartingScenario" )        
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.GROUP_UPDATED, "EA_Window_ScenarioLobby.OnGroupUpdated")
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.BATTLEGROUP_UPDATED, "EA_Window_ScenarioLobby.OnGroupUpdated")
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.SCENARIO_SHOW_LEVELED_OUT_OF_BRACKETS, "EA_Window_ScenarioLobby.OnLeveledOutOfBrackets")
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.SCENARIO_SHOW_LEVELED_NEED_REJOIN_BRACKET, "EA_Window_ScenarioLobby.OnLevelNeedRejoinQueue")
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.CITY_CAPTURE_SHOW_JOIN_PROMPT, "EA_Window_ScenarioLobby.ShowCityCaptureJoinPrompt" )
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.LOADING_BEGIN, "EA_Window_ScenarioLobby.HideCityCapturePrompt" )
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.CITY_SCENARIO_INSTANCE_ID_SELECTED, "EA_Window_ScenarioLobby.HasInstanceEnableButton" )
    WindowRegisterEventHandler( "EA_Window_ScenarioLobby", SystemData.Events.CITY_CAPTURE_SHOW_LOW_LEVEL_JOIN_PROMPT, "EA_Window_ScenarioLobby.ShowCityCaptureLowLevelJoinPrompt" )
    
    
    EA_Window_ScenarioLobby.OnPlayerActiveQueuesUpdated()
     
	 --Saved Blacklists
	if (EA_Window_ScenarioLobby.BlackList == nil) then
		EA_Window_ScenarioLobby.BlackList = {}
	end	
	 
    --DEBUG(L"Initialization Complete...")
    --EA_Window_ScenarioLobby.ShowCityCaptureJoinPrompt()
    
	WindowRegisterCoreEventHandler( "EA_Window_ScenarioLobbyScenarioMap", "OnShown", "EA_Window_ScenarioLobby.OnGroupUpdated" )
	ror_PacketHandling.Register("SC_QUEUE:",EA_Window_ScenarioLobby.PacketUpdate)	

	
--	EA_Window_ScenarioLobby.PopulateListData()
--	EA_Window_ScenarioLobby.UpdateStuffs()
end

-- OnShutdown Handler
function EA_Window_ScenarioLobby.Shutdown()
    RemoveMapInstance( "EA_Window_ScenarioLobbyScenarioMap" )
end

function EA_Window_ScenarioLobby.Hide()
	WindowSetShowing( "EA_Window_ScenarioLobby", false )
	WindowSetShowing( "EA_Window_BlacklistWindow", false )
end

function EA_Window_ScenarioLobby.UpdateQueueList()
	
	WindowSetShowing("EA_Window_ScenarioLobby", GameData.ScenarioQueueData[1].id ~= 0 )
	
	EA_Window_ScenarioLobby.ShowScenario( 1 )

	EA_Window_ScenarioLobby.PopulateListData()
	EA_Window_ScenarioLobby.UpdateStuffs()
end

--Info comming from Packethandler
function EA_Window_ScenarioLobby.PacketUpdate(text)

local text = string.gsub(text,"SC_QUEUE:","")
local SCList = json.decode(text)

EA_Window_ScenarioLobby.BuildQueueList(SCList)
end

--Builds List from Packethandler
function EA_Window_ScenarioLobby.BuildQueueList(data)
local SCList = data

EA_Window_ScenarioLobby.SC_queue_Data[SCList.queueId] = {
name = GetScenarioName( SCList.queueId ) or L"?",
Enabled = EA_Window_ScenarioLobby.GetFlag(SCList.flags, EA_Window_ScenarioLobby.ENABLED) or false,
WeekendWarfront = EA_Window_ScenarioLobby.GetFlag(SCList.flags, EA_Window_ScenarioLobby.WEEKEND_WARFRONT ) or false,
AllowGroupQueue = EA_Window_ScenarioLobby.GetFlag(SCList.flags, EA_Window_ScenarioLobby.ALLOW_GROUP_QUEUE ) or false,
ChallengeMode = EA_Window_ScenarioLobby.GetFlag(SCList.flags, EA_Window_ScenarioLobby.CHALLENGE_MODE ) or false,
HealerIncentive = EA_Window_ScenarioLobby.GetFlag(SCList.flags, EA_Window_ScenarioLobby.HEALER_INCENTIVE ) or false,
TankIncentive = EA_Window_ScenarioLobby.GetFlag(SCList.flags, EA_Window_ScenarioLobby.TANK_INCENTIVE ) or false,
DpsIncentive = EA_Window_ScenarioLobby.GetFlag(SCList.flags, EA_Window_ScenarioLobby.DPS_INCENTIVE ) or false,
blacklistCount = SCList.blacklistCount or 0,
blacklist = SCList.blacklist or {},
iconId = SCList.iconId or 130,
aQT = SCList.averageQueueTime or 0,
stats = SCList.stats or {tanks=0,healers=0,dps=0}
}

d(SCList)
EA_Window_ScenarioLobby.PopulateBlackList()
EA_Window_ScenarioLobby.UpdateListData()
end

function EA_Window_ScenarioLobby.fakelist(ScenarioId)
if ScenarioId == nil then ScenarioId = 100 end
EA_Window_ScenarioLobby.SC_queue_Data[ScenarioId].blacklistCount = 3
table.insert(EA_Window_ScenarioLobby.SC_queue_Data[ScenarioId].blacklist,{["scenarioId"]=2100,["blocked"]=false})
table.insert(EA_Window_ScenarioLobby.SC_queue_Data[ScenarioId].blacklist,{["scenarioId"]=2000,["blocked"]=true})
table.insert(EA_Window_ScenarioLobby.SC_queue_Data[ScenarioId].blacklist,{["scenarioId"]=2401,["blocked"]=false})
table.insert(EA_Window_ScenarioLobby.SC_queue_Data[ScenarioId].blacklist,{["scenarioId"]=2105,["blocked"]=true})
table.insert(EA_Window_ScenarioLobby.SC_queue_Data[ScenarioId].blacklist,{["scenarioId"]=2107,["blocked"]=false})
table.insert(EA_Window_ScenarioLobby.SC_queue_Data[ScenarioId].blacklist,{["scenarioId"]=2108,["blocked"]=false})
table.insert(EA_Window_ScenarioLobby.SC_queue_Data[ScenarioId].blacklist,{["scenarioId"]=2103,["blocked"]=false})
EA_Window_ScenarioLobby.PopulateBlackList()
end

--Update if and when scenarios are added / removed
function EA_Window_ScenarioLobby.UpdateSCList()
EA_Window_ScenarioLobby.selectedQueue = 1
EA_Window_ScenarioLobby.ShowScenario( EA_Window_ScenarioLobby.selectedQueue )
EA_Window_ScenarioLobby.PopulateListData()
EA_Window_ScenarioLobby.UpdateStuffs()
EA_Window_ScenarioLobby.UpdateListData()
EA_Window_ScenarioLobby.UpdateStuffs()
end

--updates the ListData with ScenarioData
function EA_Window_ScenarioLobby.PopulateListData()
EA_Window_ScenarioLobby.ListData = {}
   
    for row, data in ipairs(GameData.ScenarioQueueData) 
    do
	if (data ~= nil) and (data.id ~= nil) and (data.id ~= 0) then

		EA_Window_ScenarioLobby.ListData[row] = data
		EA_Window_ScenarioLobby.ListData[row].name = GetScenarioName(data.id)
end
end
return
end

--Populates the Blacklists in the Preferences window
function EA_Window_ScenarioLobby.PopulateBlackList()  

local scenarioId = GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id
if EA_Window_ScenarioLobby.SC_queue_Data[scenarioId] == nil or EA_Window_ScenarioLobby.SC_queue_Data[scenarioId].blacklist[1] == nil then 
WindowSetShowing("EA_Window_BlacklistWindow",false)
return 
end

EA_Window_ScenarioLobby.BlackList = {}
local blacklistnumber = 0
local allowedblacklists = EA_Window_ScenarioLobby.SC_queue_Data[scenarioId].blacklistCount

EA_Window_ScenarioLobby.BlackList = EA_Window_ScenarioLobby.SC_queue_Data[scenarioId].blacklist

local startindex = 1
local endindex = math.min(#EA_Window_ScenarioLobby.BlackList,EA_Window_ScenarioLobby.MAX_BLACKLIST_COUNT+1)

local displayOrder = {}
for i=startindex,endindex do
table.insert(displayOrder, i)
end


ListBoxSetVisibleRowCount("EA_Window_BlacklistWindowList", endindex) 
WindowSetDimensions("EA_Window_BlacklistWindow",250,55 +(40*endindex))


    for row, data in ipairs(EA_Window_ScenarioLobby.SC_queue_Data[scenarioId].blacklist)  do
	local rowName = "EA_Window_BlacklistWindowListRow"..row
	if (data ~= nil) and (data.scenarioId ~= nil) and (data.scenarioId ~= 0) then
		EA_Window_ScenarioLobby.SC_queue_Data[scenarioId].blacklist[row].name = GetScenarioName(data.scenarioId)
		if DoesWindowExist(rowName) then
		ButtonSetPressedFlag(rowName.."Blacklist",EA_Window_ScenarioLobby.SC_queue_Data[scenarioId].blacklist[row].blocked)
			if data.blocked == true then
				LabelSetTextColor(rowName.."Name",155,55,55)
				blacklistnumber = blacklistnumber +1
			else
				LabelSetTextColor(rowName.."Name",200,200,200)
			end
		end	
	end
end

LabelSetText("EA_Window_BlacklistWindowCounter",towstring(blacklistnumber).. L"/" ..towstring(allowedblacklists) .. L" selected")
ListBoxSetDisplayOrder("EA_Window_BlacklistWindowList", displayOrder )
end


--Send your value and a flag to test, return true if flag is in range of value
function EA_Window_ScenarioLobby.GetFlag(set, flag)
  return set % (2*flag) >= flag
  --[[ Flags:
            Enabled = 1,
            WeekendWarfront = 2,
            AllowGroupQueue = 4,
            ChallengeMode = 8,
            HealerIncentive = 16,
            TankIncentive = 32,
            DpsIncentive = 64,
--]]
end


function EA_Window_ScenarioLobby.UpdateListData()
local QueueData = GetScenarioQueueData()

--Run throu the main listings
for i=1,math.min(#EA_Window_ScenarioLobby.ListData,6) do	
	local rowName   = "EA_Window_ScenarioLobbyScenarioListRow"..i
	local RowNumber = 	ListBoxGetDataIndex("EA_Window_ScenarioLobbyScenarioList",i)
	local SCData = EA_Window_ScenarioLobby.SC_queue_Data[EA_Window_ScenarioLobby.ListData[RowNumber].id]
	--if EA_Window_ScenarioLobby.SC_queue_Data[EA_Window_ScenarioLobby.ListData[RowNumber].id] == nil then return end
	if EA_Window_ScenarioLobby.SC_queue_Data[EA_Window_ScenarioLobby.ListData[RowNumber].id] == nil then EA_Window_ScenarioLobby.BuildQueueList({queueId=EA_Window_ScenarioLobby.ListData[RowNumber].id,flags=5}) end

	AnimatedImageStartAnimation( rowName.."Loading", 0, true, false, 0.0 )
	AnimatedImageStartAnimation( rowName.."IconActive", 0, true, false, 0.0 )
	
	WindowSetShowing(rowName.."IconActive",false)
	WindowSetShowing(rowName.."Loading",false)
	ButtonSetPressedFlag(rowName,false)

	CircleImageSetTexture(rowName.."_MDpsIcon","icon022657", 31,31)
	CircleImageSetTexture(rowName.."_TankIcon","icon022724", 31,31)
	CircleImageSetTexture(rowName.."_HealerIcon","icon022706", 31,31)	
--check if insentives are met
	if SCData ~= nil then
		WindowSetShowing(rowName.."_MDpsInsentive",EA_Window_ScenarioLobby.SC_queue_Data[EA_Window_ScenarioLobby.ListData[RowNumber].id].DpsIncentive or false)
		WindowSetShowing(rowName.."_TankInsentive",EA_Window_ScenarioLobby.SC_queue_Data[EA_Window_ScenarioLobby.ListData[RowNumber].id].TankIncentive or false)
		WindowSetShowing(rowName.."_HealerInsentive",EA_Window_ScenarioLobby.SC_queue_Data[EA_Window_ScenarioLobby.ListData[RowNumber].id].HealerIncentive or false)

		LabelSetText(rowName.."_MDps_Text",towstring(SCData.stats.dps))
		LabelSetText(rowName.."_Tank_Text",towstring(SCData.stats.tanks))
		LabelSetText(rowName.."_Healer_Text",towstring(SCData.stats.healers))
		
		WindowSetShowing(rowName.."Weekend",EA_Window_ScenarioLobby.SC_queue_Data[EA_Window_ScenarioLobby.ListData[RowNumber].id].WeekendWarfront or false)
	end
	
	
	WindowSetFontAlpha(rowName.."Name",1)
	WindowSetAlpha(rowName,1)
	WindowSetTintColor(rowName, 255,255,255)
	WindowSetTintColor(rowName.."Background", 0,0,0)
	LabelSetTextColor( rowName.."Name", 255,255,255 )
--set icon
	EA_Window_ScenarioLobby.ListData[RowNumber].iconNum = EA_Window_ScenarioLobby.SC_queue_Data[EA_Window_ScenarioLobby.ListData[RowNumber].id].iconId

--check if Weekend warfront
	if EA_Window_ScenarioLobby.SC_queue_Data[EA_Window_ScenarioLobby.ListData[RowNumber].id].WeekendWarfront == true then
		LabelSetText( rowName.."WF",L"<icon49>Weekend Warfront")
	else
		LabelSetText( rowName.."WF",L"")	
	end

--check if scenario is disabled
	if EA_Window_ScenarioLobby.SC_queue_Data[EA_Window_ScenarioLobby.ListData[RowNumber].id].Enabled == false then
		WindowSetAlpha(rowName,0.65)
		WindowSetTintColor(rowName, 200,100,100)
		WindowSetTintColor(rowName.."Background", 0,0,0)
		WindowSetFontAlpha(rowName.."Name",0.55)
		LabelSetTextColor( rowName.."Name", 255,155,155 )
	end

--check if selected
	if EA_Window_ScenarioLobby.selectedQueue == RowNumber then
		ButtonSetPressedFlag(rowName,true)		
		LabelSetTextColor( rowName.."Name", 255,204,102 )
		WindowSetTintColor(rowName.."Background", 25,25,0)
	end

--check if scenario has Preferences
	DynamicImageSetTextureSlice(rowName.."Preferences",Preferences_Icon[tostring(EA_Window_ScenarioLobby.SC_queue_Data[EA_Window_ScenarioLobby.ListData[RowNumber].id].blacklistCount > 0)])	

		
--check if queuing for the scenario and display the loading icon	
	if QueueData ~= nil then
	for k,v in ipairs(QueueData) do
		if v.id == EA_Window_ScenarioLobby.ListData[RowNumber].id then
			WindowSetShowing(rowName.."Loading",true)
			WindowSetShowing(rowName.."IconActive",true)
		end
		
	end
	end
	
end

--sets all other stuff thats not bound to a listing (buttons and whatnot)
local SelectedScenario = EA_Window_ScenarioLobby.SC_queue_Data[GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id]
WindowSetShowing("EA_Window_ScenarioLobbyJoinMode2Button",(SelectedScenario.AllowGroupQueue) and SelectedScenario.Enabled)


	if SelectedScenario.Enabled then
		LabelSetTextColor( "EA_Window_ScenarioLobbyQT", 255,204,102 )
		--WindowSetShowing("EA_Window_ScenarioLobbyQT", EA_Window_ScenarioLobby.SC_queue_Data[GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id].aQT ~= 0)
		
		if(SelectedScenario.aQT ~= 0) then
			LabelSetText("EA_Window_ScenarioLobbyQT",L"Average Queue Time: "..towstring(TimeUtils.FormatClock(SelectedScenario.aQT)))
		else
			LabelSetText("EA_Window_ScenarioLobbyQT",L"")
		end

	else
		LabelSetTextColor( "EA_Window_ScenarioLobbyQT", 255,55,55 )
		LabelSetText("EA_Window_ScenarioLobbyQT",L"You are ineligable to join this scenario.")
	end

--EA_Window_ScenarioLobby.IsPlayerInQueue( GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id, (EA_Window_ScenarioLobby.joinMode == EA_Window_ScenarioLobby.JOIN_MODE_GROUP) )
--ButtonSetDisabledFlag("EA_Window_ScenarioLobbyPreferencesButton",#EA_Window_ScenarioLobby.SC_queue_Data[GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id].blacklist == 0 or (not EA_Window_ScenarioLobby.IsPlayerInQueue( GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id)))
WindowSetShowing("EA_Window_ScenarioLobbyLeave",EA_Window_ScenarioLobby.IsPlayerInQueue( GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id, (EA_Window_ScenarioLobby.joinMode == EA_Window_ScenarioLobby.JOIN_MODE_GROUP)))
WindowSetShowing("EA_Window_ScenarioLobbyJoinMode1",(not EA_Window_ScenarioLobby.IsPlayerInQueue( GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id, (EA_Window_ScenarioLobby.joinMode == EA_Window_ScenarioLobby.JOIN_MODE_GROUP))) and SelectedScenario.Enabled)

	if (SelectedScenario.blacklistCount == 0) or
	(#SelectedScenario.blacklist == 0) or
	(EA_Window_ScenarioLobby.IsPlayerInQueue( GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id)) then
		ButtonSetDisabledFlag("EA_Window_ScenarioLobbyPreferencesButton",true)
	else
		ButtonSetDisabledFlag("EA_Window_ScenarioLobbyPreferencesButton",false)
	end
	
	if EA_Window_ScenarioLobby.IsPlayerInQueue( GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id) then
		WindowSetShowing("EA_Window_BlacklistWindow",false)
	end

end

function EA_Window_ScenarioLobby.UpdateStuffs()

local startindex = 1
local endindex = 0
	for k,v in pairs(EA_Window_ScenarioLobby.ListData) do
		if v.id ~= 0 then
			endindex = endindex+1
		end
	end


local displayOrder = {}
for i=startindex,endindex do
table.insert(displayOrder, i)
end
ListBoxSetDisplayOrder("EA_Window_ScenarioLobbyScenarioList", displayOrder )
end

function EA_Window_ScenarioLobby.SelectScenario()
local Scenarionumber = ListBoxGetDataIndex("EA_Window_ScenarioLobbyScenarioList" ,WindowGetId(SystemData.MouseOverWindow.name))
local _listData = EA_Window_ScenarioLobby.ListData[Scenarionumber]
EA_Window_ScenarioLobby.ShowScenario( Scenarionumber )
EA_Window_ScenarioLobby.PopulateBlackList()  
EA_Window_ScenarioLobby.UpdateListData()
end

function EA_Window_ScenarioLobby.List_Join()
local Scenarionumber = ListBoxGetDataIndex("EA_Window_ScenarioLobbyScenarioList" ,WindowGetId(SystemData.MouseOverWindow.name))
local _listData = EA_Window_ScenarioLobby.ListData[Scenarionumber]
EA_Window_ScenarioLobby.ShowScenario( Scenarionumber )
	GameData.ScenarioQueueData.selectedId = _listData.id   
    local joinSingleEvent = EA_Window_ScenarioLobby.joinModes[ EA_Window_ScenarioLobby.joinMode ].joinSingleEvent    
    BroadcastEvent( joinSingleEvent )   
	EA_Window_ScenarioLobby.UpdateListData()
end

function EA_Window_ScenarioLobby.toggleButton()
local Scenarionumber = ListBoxGetDataIndex("EA_Window_BlacklistWindowList" ,WindowGetId(SystemData.MouseOverWindow.name))
local SelectedSCQ = GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id
local _listData = EA_Window_ScenarioLobby.SC_queue_Data[SelectedSCQ]
local allowedblacklists = _listData.blacklistCount
local blacklistnumber = 0

for k,v in pairs(_listData.blacklist) do 
	if v.blocked == true then
		blacklistnumber = blacklistnumber +1
	end
end

if EA_Window_ScenarioLobby.SC_queue_Data[SelectedSCQ].blacklist[Scenarionumber].blocked == false and blacklistnumber >= allowedblacklists then
	d(L"Maximum Blacklists met")
	return
end

EA_Window_ScenarioLobby.SC_queue_Data[SelectedSCQ].blacklist[Scenarionumber].blocked = not EA_Window_ScenarioLobby.SC_queue_Data[SelectedSCQ].blacklist[Scenarionumber].blocked

TextLogAddEntry("Chat", 0, L"]scenario blacklist "..towstring(SelectedSCQ)..L" "..towstring(EA_Window_ScenarioLobby.SC_queue_Data[SelectedSCQ].blacklist[Scenarionumber].scenarioId)..L" "..Bool_Convert[tostring(EA_Window_ScenarioLobby.SC_queue_Data[SelectedSCQ].blacklist[Scenarionumber].blocked)] )
--SendChatText(L"]scenario blacklist "..towstring(SelectedSCQ)..L" "..towstring(EA_Window_ScenarioLobby.SC_queue_Data[SelectedSCQ].blacklist[Scenarionumber].scenarioId)..L" "..Bool_Convert[tostring(EA_Window_ScenarioLobby.SC_queue_Data[SelectedSCQ].blacklist[Scenarionumber].blocked)] ,L"/s")

EA_Window_ScenarioLobby.PopulateBlackList()
end

function EA_Window_ScenarioLobby.ShowScenario( index )

    EA_Window_ScenarioLobby.selectedQueue    = nil

    local queueData = GameData.ScenarioQueueData[index]
    if( queueData == nil ) then
        return
    end
    EA_Window_ScenarioLobby.selectedQueue = index
    

	local name = GetScenarioName( queueData.id )
	if( name == L"" ) then
		name = L"Scenario #"..queueData.id 
	end
								
	LabelSetText( "EA_Window_ScenarioLobbyScenarioName", name)
	LabelSetText( "EA_Window_ScenarioLobbyScenarioDesc", GetScenarioLobbyDesc( queueData.id ) )

    MapSetMapView( "EA_Window_ScenarioLobbyScenarioMap", GameDefs.MapLevel.ZONE_MAP, queueData.zone )
        
    EA_Window_ScenarioLobby.UpdateLobbyJoinButtons() 
    
end

function EA_Window_ScenarioLobby.UpdateLobbyJoinButtons()
   
   local inLeadershipPosition = GameData.Player.isGroupLeader or GameData.Player.isWarbandAssistant   
   
   local scenarioId = GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id
   local withGroup  = (EA_Window_ScenarioLobby.joinMode == EA_Window_ScenarioLobby.JOIN_MODE_GROUP)

   local playerQueuedForThisScenario = EA_Window_ScenarioLobby.IsPlayerInQueue( scenarioId, withGroup )
   local playerQueuedForAllScenarios = EA_Window_ScenarioLobby.IsPlayerInAllQueues( withGroup )
   
   --ButtonSetDisabledFlag("EA_Window_ScenarioLobbyJoinButton", playerQueuedForThisScenario )
   --ButtonSetDisabledFlag("EA_Window_ScenarioLobbyJoinAllButton", playerQueuedForAllScenarios )
   
   
   ButtonSetDisabledFlag("EA_Window_ScenarioLobbyJoinMode1Button", playerQueuedForThisScenario )
   ButtonSetDisabledFlag("EA_Window_ScenarioLobbyJoinMode2Button", (playerQueuedForThisScenario) or (not inLeadershipPosition) )
	--ButtonSetDisabledFlag("EA_Window_ScenarioLobbyJoinMode2Button",not inLeadershipPosition )

EA_Window_ScenarioLobby.UpdateListData()
end


function EA_Window_ScenarioLobby.OnMouseOverMapPoint()
    Tooltips.CreateMapPointTooltip( "EA_Window_ScenarioLobbyScenarioMap", EA_Window_ScenarioLobbyScenarioMap.MouseoverPoints, Tooltips.ANCHOR_CURSOR, Tooltips.MAP_TYPE_OTHER )   
end

function EA_Window_ScenarioLobby.SelectJoinMode( mode ) 
    EA_Window_ScenarioLobby.joinMode = mode    
    for mode = 1, EA_Window_ScenarioLobby.NUM_JOIN_MODES do
        local pressed = mode == EA_Window_ScenarioLobby.joinMode
        --ButtonSetPressedFlag("EA_Window_ScenarioLobbyJoinMode"..mode.."Button", pressed )
    end
end

function EA_Window_ScenarioLobby.OnSelectJoinMode()    
    local mode = WindowGetId( SystemData.ActiveWindow.name )
    
    if( ButtonGetDisabledFlag("EA_Window_ScenarioLobbyJoinMode"..mode.."Button" ) ) then
        return
    end
    
    EA_Window_ScenarioLobby.SelectJoinMode( mode )
    EA_Window_ScenarioLobby.UpdateLobbyJoinButtons()
end

function EA_Window_ScenarioLobby.OnQueueAsPartyMouseOver()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, GetString(StringTables.Default.TEXT_MUST_BE_LEADER_TO_QUEUE_PARTY) )
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end


function EA_Window_ScenarioLobby.InsentiveTooltip()
	local HasIncentive = (WindowGetShowing(SystemData.MouseOverWindow.name.."Insentive") == true)

	if HasIncentive then
		local ArchType = string.match(SystemData.MouseOverWindow.name,"Row%d_(.+)")
		Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
		Tooltips.SetTooltipText( 1, 1, Insentive_Labels[ArchType] )
		Tooltips.Finalize()
		Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
	end
end

function EA_Window_ScenarioLobby.BlacklistTooltip()
    local rowName   = SystemData.MouseOverWindow.name
	local Scenarionumber = ListBoxGetDataIndex("EA_Window_BlacklistWindowList" ,WindowGetId(SystemData.MouseOverWindow.name))

	local ScenarioID = EA_Window_ScenarioLobby.SC_queue_Data[GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id].blacklist[Scenarionumber].scenarioId

	Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name )
    Tooltips.SetTooltipText( 1, 1, GetScenarioLobbyDesc( ScenarioID ))
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end


function EA_Window_ScenarioLobby.OnGroupUpdated()
    local inLeadershipPosition = GameData.Player.isGroupLeader or GameData.Player.isWarbandAssistant
    -- Disable the join selections option when the player is not grouped or is not the group leader/assistant.
    for mode = 2, EA_Window_ScenarioLobby.NUM_JOIN_MODES do
        ButtonSetDisabledFlag("EA_Window_ScenarioLobbyJoinMode"..mode.."Button", not inLeadershipPosition )
    end
    -- If they had group selected but now only solo is enabled, then forceably select solo
    if (EA_Window_ScenarioLobby.joinMode == EA_Window_ScenarioLobby.JOIN_MODE_GROUP and not inLeadershipPosition) then
        EA_Window_ScenarioLobby.SelectJoinMode( EA_Window_ScenarioLobby.JOIN_MODE_SOLO ) 
        EA_Window_ScenarioLobby.UpdateLobbyJoinButtons()
    end
	EA_Window_ScenarioLobby.PopulateListData()
	EA_Window_ScenarioLobby.UpdateStuffs()	
end

	-- Pressing Preferences bnutton
function EA_Window_ScenarioLobby.OnPreferences()
    if (EA_Window_ScenarioLobby.SC_queue_Data[GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id].blacklistCount == 0) or
	(#EA_Window_ScenarioLobby.SC_queue_Data[GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id].blacklist == 0) or
	(EA_Window_ScenarioLobby.IsPlayerInQueue( GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id))
	then
		return
	end
	
	WindowSetShowing("EA_Window_BlacklistWindow", not WindowGetShowing("EA_Window_BlacklistWindow"))
	EA_Window_ScenarioLobby.PopulateBlackList()	
end

function EA_Window_ScenarioLobby.OnCancel()
    -- Just close the window
    WindowSetShowing("EA_Window_ScenarioLobby", false )
	WindowSetShowing( "EA_Window_BlacklistWindow", false )
end

function EA_Window_ScenarioLobby.OnHidden()
WindowUtils.OnHidden()
WindowSetShowing( "EA_Window_BlacklistWindow", false )
end

--Join as Solo
function EA_Window_ScenarioLobby.OnJoinSingleQueue()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end

	EA_Window_ScenarioLobby.joinMode = 1

    -- Join the Queue for this scenario
	local index = EA_Window_ScenarioLobby.selectedQueue
	GameData.ScenarioQueueData.selectedId = GameData.ScenarioQueueData[index].id
    
    local joinSingleEvent = EA_Window_ScenarioLobby.joinModes[ EA_Window_ScenarioLobby.joinMode ].joinSingleEvent
    
    BroadcastEvent( joinSingleEvent )   
    --WindowSetShowing("EA_Window_ScenarioLobby", false)
	EA_Window_ScenarioLobby.UpdateListData()
end

--Join as Party
function EA_Window_ScenarioLobby.OnJoinMultiQueue()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end

	EA_Window_ScenarioLobby.joinMode = 2

    -- Join the Queue for this scenario
	local index = EA_Window_ScenarioLobby.selectedQueue
	GameData.ScenarioQueueData.selectedId = GameData.ScenarioQueueData[index].id
    
    local joinSingleEvent = EA_Window_ScenarioLobby.joinModes[ EA_Window_ScenarioLobby.joinMode ].joinSingleEvent
    
    BroadcastEvent( joinSingleEvent )   
    --WindowSetShowing("EA_Window_ScenarioLobby", false)
	EA_Window_ScenarioLobby.UpdateListData()
end


function EA_Window_ScenarioLobby.OnJoinAllQueues()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) )
    then
        return
    end 
	EA_Window_ScenarioLobby.AllData    = {}
	
	for _, availQueueData in ipairs( GameData.ScenarioQueueData )
    do  
        if( availQueueData.id ~= 0)
        then
			table.insert(EA_Window_ScenarioLobby.AllData,availQueueData.id)
        end  
    end
end

function EA_Window_ScenarioLobby.OnLeaveQueue()
	GameData.ScenarioQueueData.selectedId = GameData.ScenarioQueueData[EA_Window_ScenarioLobby.selectedQueue].id
	BroadcastEvent( SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE ) 	
end

function EA_Window_ScenarioLobby.OnLeaveActiveQueue()
	GameData.ScenarioQueueData.selectedId = GameData.ScenarioData.activeQueue
    BroadcastEvent( SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE ) 	
end

function EA_Window_ScenarioLobby.OnLeaveActiveQueueFromLobby()
    -- A cancel request initiated from the lobby window
	EA_Window_ScenarioLobby.OnLeaveActiveQueue()    
    WindowSetShowing("EA_Window_ScenarioJoinPrompt", false)
    WindowSetShowing("EA_Window_ScenarioStarting", false)		
end

-- In-Queue Window

function EA_Window_ScenarioLobby.OnPlayerActiveQueuesUpdated()	

    EA_Window_ScenarioLobby.playerActiveQueues = GetScenarioQueueData()    

    -- If the Lobby Window is showing, update the join buttons
    if( WindowGetShowing("EA_Window_ScenarioLobby") )
    then
         EA_Window_ScenarioLobby.UpdateLobbyJoinButtons()
    end
	
	WindowSetShowing("EA_Window_ScenarioJoinPrompt", false)
end

function EA_Window_ScenarioLobby.UpdateWaitTime( timePassed )
	if(EA_Window_ScenarioLobby.waitTime > 0 ) then		
		EA_Window_ScenarioLobby.waitTime = EA_Window_ScenarioLobby.waitTime - timePassed
		if( EA_Window_ScenarioLobby.waitTime <= 0 ) then
			EA_Window_ScenarioLobby.waitTime = 0					
			LabelSetText( "EA_Window_InScenarioQueueTimer", GetString( StringTables.Default.TEXT_WAITING_ON_PLAYERS ))
		else
			local time = TimeUtils.FormatClock( EA_Window_ScenarioLobby.waitTime )
			local text = GetStringFormat( StringTables.Default.TEXT_JOIN_WAIT_TIME, { time } )
			LabelSetText( "EA_Window_InScenarioQueueTimer", text )	
		end				
	end	
end


-- Join Window
function EA_Window_ScenarioLobby.ShowJoinPrompt()
EA_Window_ScenarioLobby.Hide()
d(L"Join prompt")
	local name = GetScenarioName( GameData.ScenarioData.startingScenario )
	if( name == L"" ) then
		name = L"Scenario #"..GameData.ScenarioData.startingScenario
	end		
	LabelSetText("EA_Window_ScenarioJoinPromptBoxName", name )
	
	WindowSetShowing("EA_Window_ScenarioJoinPrompt", true)
	EA_Window_ScenarioLobby.UpdateLaunchingJoinButtons()		
	
	EA_Window_ScenarioLobby.autoCancelTime = EA_Window_ScenarioLobby.AUTO_CANCEL_TIME
	
	Sound.Play(Sound.SCENARIO_INVITE)
end


function EA_Window_ScenarioLobby.OnPlayerCombatFlagUpdated()

    -- If the Join Prompt windw is showing, update the buttons
    if( WindowGetShowing("EA_Window_ScenarioJoinPrompt" ) or WindowGetShowing("EA_Window_ScenarioStarting" ))
    then
        EA_Window_ScenarioLobby.UpdateLaunchingJoinButtons()
    end

end

function EA_Window_ScenarioLobby.UpdateLaunchingJoinButtons()

	-- Disable the 'Join Now' Button if the player is in combat & Show the description text.
	local flagValue = false
	if( GameData.Player.inCombat == true)
	then
	    flagValue = true
	end
	
	ButtonSetDisabledFlag("EA_Window_ScenarioJoinPromptBoxJoinNowButton", flagValue )
    ButtonSetDisabledFlag("EA_Window_ScenarioStartingJoinNowButton", flagValue )
    
    WindowSetShowing("EA_Window_ScenarioStartingInCombatText", flagValue )
    WindowSetShowing("EA_Window_ScenarioJoinPromptBoxInCombatText", flagValue )

end


function EA_Window_ScenarioLobby.UpdateAutoCancelTime( timePassed ) 
	if(EA_Window_ScenarioLobby.autoCancelTime > 0 ) then		
		EA_Window_ScenarioLobby.autoCancelTime = EA_Window_ScenarioLobby.autoCancelTime - timePassed
		if( EA_Window_ScenarioLobby.autoCancelTime <= 0 ) then
			EA_Window_ScenarioLobby.autoCancelTime = 0
			 EA_Window_ScenarioLobby.OnJoinInstanceCancel()
		end	
		
		local time = TimeUtils.FormatClock( EA_Window_ScenarioLobby.autoCancelTime )
		local text = GetStringFormat( StringTables.Default.TEXT_JOIN_SCENARIO_RESPOND_TIME, { time } )
		LabelSetText("EA_Window_ScenarioJoinPromptBoxRespondTime", text )		
	end	
end

function EA_Window_ScenarioLobby.OnJoinInstanceNow()
    
    if( ButtonGetDisabledFlag("EA_Window_ScenarioJoinPromptBoxJoinNowButton" ) )
    then
        return
    end

    BroadcastEvent( SystemData.Events.SCENARIO_INSTANCE_JOIN_NOW )    
    WindowSetShowing("EA_Window_ScenarioJoinPrompt", false)
    LabelSetText( "EA_Window_InScenarioQueueTimer", GetString( StringTables.Default.TEXT_WAITING_ON_PLAYERS ))
	EA_Window_ScenarioLobby.startTime = 0.1
	WindowSetShowing( "EA_Window_ScenarioStarting", true )    

end

function EA_Window_ScenarioLobby.OnJoinInstanceWait()
    BroadcastEvent( SystemData.Events.SCENARIO_INSTANCE_JOIN_WAIT ) 
    WindowSetShowing("EA_Window_ScenarioJoinPrompt", false)       
    EA_Window_ScenarioLobby.startTime = EA_Window_ScenarioLobby.JOIN_WAIT_TIME
    WindowSetShowing( "EA_Window_ScenarioStarting", true )
    EA_Window_ScenarioLobby.UpdateLaunchingJoinButtons()
end

function EA_Window_ScenarioLobby.OnJoinInstanceCancel()
    BroadcastEvent( SystemData.Events.SCENARIO_INSTANCE_CANCEL )  
    WindowSetShowing("EA_Window_ScenarioJoinPrompt", false)  
end

-- City Capture Join Window
function EA_Window_ScenarioLobby.ShowCityCaptureJoinPrompt()
	-- We should check whether or not the player is in a group and/or whether or not 
	-- the group leader has selected an instance or not
	-- if not => disable the "Fight" button
	-- if he has, enable the "Fight" button	
	
	if( EA_Window_ScenarioLobby.autoCancelCityInstance > 0 ) then
	    --
	    WindowSetShowing("EA_Window_CityCaptureJoinPromptWindow", true)
	    WindowSetShowing("EA_Window_CityInstanceWait", false)
	    ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinWaitButton", true)
	else
		EA_Window_ScenarioLobby.autoCancelCityInstance = EA_Window_ScenarioLobby.AUTO_CANCEL_TIME_CITY_JOIN
	    WindowSetShowing("EA_Window_CityCaptureJoinPromptWindow", true)
	end
end

function EA_Window_ScenarioLobby.ShowCityCaptureLowLevelJoinPrompt()
    WindowSetShowing( "EA_Window_CityCaptureJoinPromptWindowBoxLowLevel", true )    
		
    if( EA_Window_ScenarioLobby.autoCancelCityInstance > 0 ) then
	    --
	    WindowSetShowing("EA_Window_CityCaptureJoinPromptWindow", true)
	    WindowSetShowing("EA_Window_CityInstanceWait", false)
	    ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinWaitButton", true)
	    ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton", true)
	else
		EA_Window_ScenarioLobby.autoCancelCityInstance = EA_Window_ScenarioLobby.AUTO_CANCEL_TIME_CITY_JOIN
	    WindowSetShowing("EA_Window_CityCaptureJoinPromptWindow", true)
	    ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton", true)
	    EA_Window_ScenarioLobby.isLowLevel = true
	end
end

function EA_Window_ScenarioLobby.UpdateCityAutoCancelTime( timePassed )
    --
    if(EA_Window_ScenarioLobby.autoCancelCityInstance > 0 ) then		
		EA_Window_ScenarioLobby.autoCancelCityInstance = EA_Window_ScenarioLobby.autoCancelCityInstance - timePassed
		if( not EA_Window_ScenarioLobby.isLowLevel) then
		    EA_Window_ScenarioLobby.CheckFightPressedFlag()
		end
		if( EA_Window_ScenarioLobby.autoCancelCityInstance <= 0 ) then
			EA_Window_ScenarioLobby.autoCancelCityInstance = 0
			 EA_Window_ScenarioLobby.OnLeaveCityCapture()
		end	
		
		local time = TimeUtils.FormatClock( EA_Window_ScenarioLobby.autoCancelCityInstance )
		local text = GetStringFormat( StringTables.Default.TEXT_JOIN_SCENARIO_RESPOND_TIME, { time } )
		LabelSetText("EA_Window_CityCaptureJoinPromptWindowBoxRespondTime", text )		
	end	
    
end

function EA_Window_ScenarioLobby.OnJoinCityCapture()
    local buttonDisabled = ButtonGetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton")
    if( buttonDisabled ) then
    -- button is disabled, do nothing
    else
        local groupdata = GetNumGroupmates()
        local isPlayerSolo = IsPlayerSolo()
        --d(isPlayerSolo)

            if( GameData.Player.isGroupLeader == true ) then
                --DEBUG(L"Group Leader has clicked")
                --DEBUG(L"Sending Instance List request to server...")
                BroadcastEvent( SystemData.Events.CITY_CAPTURE_REQUEST_INSTANCE_DATA )
                --DEBUG(L"Closing Prompt")   
                EA_Window_ScenarioLobby.HideCityCapturePrompt()        
            else
                if( isPlayerSolo == 1 ) then
                    --DEBUG(L"Not IN a group")
                    --DEBUG(L"Sending Instance List request to server...")
                    BroadcastEvent( SystemData.Events.CITY_CAPTURE_REQUEST_INSTANCE_DATA )
                    --DEBUG(L"Closing Prompt")      
                    EA_Window_ScenarioLobby.HideCityCapturePrompt()
                else
                    --DEBUG(L"Non Leader has clicked")
                    --DEBUG(L"Sending Instance List request to server...")
                    BroadcastEvent( SystemData.Events.CITY_CAPTURE_REQUEST_INSTANCE_DATA )   
                    EA_Window_ScenarioLobby.fightFlagPressed = true
                end 
            end
    end
    --d(EA_Window_ScenarioLobby.fightFlagPressed)
end

function EA_Window_ScenarioLobby.OnLeaveCityCapture()
    BroadcastEvent( SystemData.Events.CITY_CAPTURE_FLEE )
    EA_Window_ScenarioLobby.HideCityCapturePrompt()
end

function EA_Window_ScenarioLobby.OnWaitCityCapture()
    --
    local buttonDisabled = ButtonGetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinWaitButton")
    if( buttonDisabled ) then
    --
        --DEBUG(L"Button Disabled")
    else
        --DEBUG(L"Clicked Wait...")
        EA_Window_ScenarioLobby.cityInstanceWait = EA_Window_ScenarioLobby.WAIT_TIME_CITY_JOIN
        WindowSetShowing("EA_Window_CityInstanceWait", true)
        WindowSetShowing("EA_Window_CityCaptureJoinPromptWindow", false)
    end
end

function EA_Window_ScenarioLobby.UpdateCityCaptureWaitTime( timePassed )
    --
    if(EA_Window_ScenarioLobby.cityInstanceWait > 0 ) then		
		EA_Window_ScenarioLobby.cityInstanceWait = EA_Window_ScenarioLobby.cityInstanceWait - timePassed
		if( EA_Window_ScenarioLobby.cityInstanceWait <= 0 ) then
			EA_Window_ScenarioLobby.cityInstanceWait = 0
			if( EA_Window_ScenarioLobby.isLowLevel ) then
			    EA_Window_ScenarioLobby.ShowCityCaptureLowLevelJoinPrompt()
			else
			    EA_Window_ScenarioLobby.ShowCityCaptureJoinPrompt()
	        end
		end		
	end	
end

function EA_Window_ScenarioLobby.HideCityCapturePrompt()
    --DEBUG(L"Hiding City Capture Join Prompt")
    -- reset all window elements to their natural state
    WindowSetShowing( "EA_Window_CityCaptureJoinPromptWindowBoxLowLevel", false )
    ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton", false)
    ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinWaitButton", false)
    WindowSetShowing("EA_Window_CityCaptureJoinPromptWindow", false)        
    -- reset all the vars used
    EA_Window_ScenarioLobby.autoCancelCityInstance = 0
    EA_Window_ScenarioLobby.cityInstanceWait = 0
    EA_Window_ScenarioLobby.fightFlagPressed = false
    EA_Window_ScenarioLobby.isLowLevel = false
end


-- Scenario Starting Window
function EA_Window_ScenarioLobby.UpdateStartingScenario()

	local name = GetScenarioName( GameData.ScenarioData.startingScenario )
	if( name == L"" ) then
		name = L"Scenario #"..GameData.ScenarioData.startingScenario
	end		
	local text = GetStringFormat( StringTables.Default.TEXT_SCENARIO_STARTING, { name } )

	LabelSetText( "EA_Window_ScenarioStartingName", text )
	LabelSetText( "EA_Window_ScenarioStartingTimer", GetString( StringTables.Default.TEXT_SCENARIO_WAIT_TIME ) )		
	
	if( GameData.ScenarioData.startingScenario == 0 ) then
	    WindowSetShowing( "EA_Window_ScenarioStarting", false ) 
	    EA_Window_ScenarioLobby.startTime = 0
	elseif( EA_Window_ScenarioLobby.startTime > 0 ) then
	    WindowSetShowing( "EA_Window_ScenarioStarting", true ) 
	end
end

function EA_Window_ScenarioLobby.UpdateStartTime( timePassed )

	if(EA_Window_ScenarioLobby.startTime > 0 ) then		
		EA_Window_ScenarioLobby.startTime = EA_Window_ScenarioLobby.startTime - timePassed
		if( EA_Window_ScenarioLobby.startTime <= 0 ) then
			EA_Window_ScenarioLobby.startTime = 0					
            WindowSetShowing( "EA_Window_ScenarioStarting", false ) 
		else
			local time = TimeUtils.FormatClock( EA_Window_ScenarioLobby.startTime )
			local text = GetStringFormat( StringTables.Default.TEXT_JOIN_WAIT_TIME, { time } )
			LabelSetText( "EA_Window_ScenarioStartingTimer", text )	
		end				
	end	
end

function EA_Window_ScenarioLobby.OnLeveledOutOfBrackets( scenarioId )
    
    -- The player has leveled out of all avaiable brackets for this scenario.
    local name = GetScenarioName( scenarioId )
	if( name == L"" ) then
		name = L"#"..scenarioId
	end	
	
    local text = GetStringFormat( StringTables.Default.TEXT_SCENARIO_LEVELED_OUT_OF_ALL_BRACKETS, { name } )
    DialogManager.MakeOneButtonDialog( text, GetString( StringTables.Default.LABEL_OKAY ), nil )

end


function EA_Window_ScenarioLobby.OnLevelNeedRejoinQueue( scenarioId )
 
    -- The player has leveled out their current bracket and must rejoin.
    local name = GetScenarioName( scenarioId )
	if( name == L"" ) then
		name = L"#"..scenarioId
	end	
    
    local text = GetStringFormat( StringTables.Default.TEXT_SCENARIO_LEVELED_OUT_OF_BRACKET, { name } )
    
    local DoRejoinQueue = function()
        GameData.ScenarioQueueData.selectedId = scenarioId
        BroadcastEvent( SystemData.Events.INTERACT_JOIN_SCENARIO_QUEUE )
    end
    
    DialogManager.MakeTwoButtonDialog( text, GetString( StringTables.Default.LABEL_YES ), DoRejoinQueue, GetString( StringTables.Default.LABEL_NO ), nil )
end

function EA_Window_ScenarioLobby.OnRButtonUp()
    EA_Window_ContextMenu.CreateDefaultContextMenu( "EA_Window_ScenarioLobby" )
end

function EA_Window_ScenarioLobby.CheckFightPressedFlag()    
    if( EA_Window_ScenarioLobby.fightFlagPressed ) then
        -- button has been pressed, disable the button
        ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton", true)
    else
        -- the flag has been reset, could be because an instance has been selected, enable the button
        ButtonSetDisabledFlag("EA_Window_CityCaptureJoinPromptWindowBoxJoinNowButton", false)
    end
end

function EA_Window_ScenarioLobby.HasInstanceEnableButton()
    EA_Window_ScenarioLobby.fightFlagPressed = false
end

-------------------------------------------------------------
-- Util Functions
-------------------------------------------------------------


function EA_Window_ScenarioLobby.IsPlayerInQueue( scenarioId, withGroup )

    if( EA_Window_ScenarioLobby.playerActiveQueues == nil )
    then
        return false
    end

    for index, activeQueueData in ipairs( EA_Window_ScenarioLobby.playerActiveQueues )
    do
        -- Player can queue for a scenario as a group even if already queued solo, but not the reverse.
        if( activeQueueData.id == scenarioId and (activeQueueData.grouped == withGroup or not withGroup) )
        then
            return true
        end    
    end

    return false
end


function EA_Window_ScenarioLobby.IsPlayerInAllQueues( withGroup )
if Is_StateMachine_Running == true then return true end
      
    for _, availQueueData in ipairs( GameData.ScenarioQueueData )
    do
        -- The Available Queue List contains 0 entries at the end        
        if( availQueueData.id ~= 0 and availQueueData.id ~= 3000 and availQueueData.id ~= 3001)
        then
             if( not EA_Window_ScenarioLobby.IsPlayerInQueue( availQueueData.id, withGroup ) )
             then
                return false
             end
        end
    
    end  
    return true
end
