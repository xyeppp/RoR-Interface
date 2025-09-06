if not RoR_SoR then RoR_SoR= {} end
local version = 127
local ZoneLockTimer = 10
local RoR_Window_Scale

local c_DEFAULT_HIDE_TIMER = 1.0
local c_DEFAULT_FADEIN_TIMER = 0.3
local c_DEFAULT_FADEOUT_TIMER = 0.3

local KEEP_STATE_SAFE = 1
local KEEP_STATE_OUTER = 2
local KEEP_STATE_INNER = 3
local KEEP_STATE_LORD = 4

local SEND_BEGIN = 1
local SEND_FINISH = 2

local HasReloaded = false

local PopConvert = {["Scouts"]=L"0-9",["Parties"]=L"10-24",["Warbands"]=L"25-99",["Vanguard"]=L"100-199",["Battlehost"]=L"200-299",["Warhost"]=L"300+"}

Popper = {m_HideCountdown = c_DEFAULT_HIDE_TIMER, m_IsShowing = false,}
SiegeWeaponGolfFireWindow.KeepInfo = {}

RoR_SoR.StateTimer = 2
RoR_SoR.DebugKeep = false
RoR_SoR.DebugBO = false
RoR_SoR.RealmColors = {{r=155,g=155,b=155},{r=107,g=191,b=255},{r=255,g=105,b=105},{r=75,g=75,b=255},{r=255,g=25,b=25}}
RoR_SoR.FortColors = {{r=155,g=155,b=155},{r=75,g=75,b=255},{r=255,g=25,b=25}}
RoR_SoR.InvFortColors = {{r=155,g=155,b=155},{r=255,g=25,b=25},{r=75,g=75,b=255}}
RoR_SoR.CappingRealmColors = {{r=255,g=255,b=255},{r=255,g=105,b=105},{r=107,g=191,b=255}}
RoR_SoR.T4_ActiveZones = {[3]=1,[5]=2,[9]=3,[103]=1,[105]=2,[109]=3,[209]=3,[205]=2,[203]=1}
RoR_SoR.Forts = {[4]=2,[10]=1,[104]=2,[110]=1,[204]=2,[210]=1}
RoR_SoR.FortBG = {{10,4},{110,104},{210,204}}
RoR_SoR.City = {[161]=2,[162]=1}
RoR_SoR.CityCampaign = {[161]=4,[162]=3}
RoR_SoR.Ram = {[1] = "RamOrder",[2] = "RamDestruction"}
RoR_SoR.KeepLord = {[1] = "SoR_LordIcon",[2] = "SoR_LordIcon"}
RoR_SoR.FortLord = {[1] = "Lord_1",[2] = "Lord_2"}
RoR_SoR.ZoneNames = {[1]={1,7},[2]={2,8},[3]={3,3},[4]={4,4},[5]={5,5},[6]={6,11},[7]={1,7},[8]={2,8},[9]={9,9},[10]={10,10},[11]={6,11},[100]={100,106},[101]={107,101},[102]={102,108},[103]={103,103},[104]={104,108},[105]={105,105},[106]={100,106},[107]={107,101},[108]={102,108},[109]={109,109},[110]={110,110},[200]={200,206},[201]={207,201},[202]={202,208},[203]={203,203},[204]={204,204},[205]={205,205},[206]={200,206},[207]={207,201},[208]={202,208},[209]={209,209},[210]={210,210}}
RoR_SoR.TierNames = {[1]={006,011,100,106,200,206},[2]={001,007,101,107,201,207},[3]={002,008,102,108,202,208},[4]={003,005,009,103,105,109,209,205,203}}
RoR_SoR.ParingPortrait = {[1] = "PairingElvesSelected",[2] = "PairingEvCSelected",[3]="PairingGvDSelected"}
RoR_SoR.KeepStatus = {}
RoR_SoR.InvolvedGuilds = {}

RoR_SoR.KeepHealth = {}
RoR_SoR.ZoneStatus = {}
RoR_SoR.KeepProgress = {[1]={},[2]={}}
RoR_SoR.Pairings = {[1]={},[2]={},[3]={},[161]={},[162]={}}
RoR_SoR.NumberWindows = {}
--Number_Window_Template


if not RoR_SoR.City_Status then RoR_SoR.City_Status = {} end

RoR_SoR.SafeKeep = {}


RoR_SoR.TextLock = towstring(GetStringFromTable("MapSystem", StringTables.MapSystem.TEXT_CAMPAIGN_PAIRING_LOCKED ) )
RoR_SoR.TextZoneLocked =	towstring(GetStringFromTable("Hardcoded", 1268))
RoR_SoR.TextTaken = towstring(GetStringFromTable("Hardcoded", 274))

RoR_SoR.TextNeutral = towstring(GetStringFromTable("Default", StringTables.Default.LABEL_UNCONTROLLED ) )
RoR_SoR.TextOrder = towstring(GetStringFromTable("Default", StringTables.Default.LABEL_UNCONTROLLED ) )
RoR_SoR.TextDestro = towstring(GetStringFromTable("Default", StringTables.Default.LABEL_ORDER_CONTROLLED ) )


RoR_SoR.PairingIconSliceNames = {}
RoR_SoR.PairingIconSliceNames[GameData.Pairing.GREENSKIN_DWARVES] = {}
RoR_SoR.PairingIconSliceNames[GameData.Pairing.GREENSKIN_DWARVES][GameData.Realm.ORDER] = "Order-Dwarf"
RoR_SoR.PairingIconSliceNames[GameData.Pairing.GREENSKIN_DWARVES][GameData.Realm.DESTRUCTION] = "Dest-Greenskin"
RoR_SoR.PairingIconSliceNames[GameData.Pairing.GREENSKIN_DWARVES][GameData.Realm.NONE] = "CONTESTED"
RoR_SoR.PairingIconSliceNames[GameData.Pairing.EMPIRE_CHAOS] = {}
RoR_SoR.PairingIconSliceNames[GameData.Pairing.EMPIRE_CHAOS][GameData.Realm.ORDER] = "Order-Empire"
RoR_SoR.PairingIconSliceNames[GameData.Pairing.EMPIRE_CHAOS][GameData.Realm.DESTRUCTION] = "Dest-Chaos"
RoR_SoR.PairingIconSliceNames[GameData.Pairing.EMPIRE_CHAOS][GameData.Realm.NONE] = "CONTESTED"
RoR_SoR.PairingIconSliceNames[GameData.Pairing.ELVES_DARKELVES] = {}
RoR_SoR.PairingIconSliceNames[GameData.Pairing.ELVES_DARKELVES][GameData.Realm.ORDER] = "Order-HighElf"
RoR_SoR.PairingIconSliceNames[GameData.Pairing.ELVES_DARKELVES][GameData.Realm.DESTRUCTION] = "Dest-DarkElf"
RoR_SoR.PairingIconSliceNames[GameData.Pairing.ELVES_DARKELVES][GameData.Realm.NONE] = "CONTESTED"

local function title_case_helper(first, rest)
  return first:upper()..rest:lower()
end

function title_case(text)
    -- gsub returns multiple values, we just want the first.
    local result = string.gsub(text, "(%a)([%w_']*)", title_case_helper)
    return result
end

function RoR_SoR.OnInitialize()


RoR_SoR.CITY_MESSAGE = {[1]=L"No Siege Active",[2]=L"city siege about to start",[3]=L"Signup for sieges",[4]=L"DEFENDED",[5]=L"ATTACKERS WIN",[8]=L"Sieges active, signup closed",[10]=L"Siege fully ended"}

CreateWindow("RoR_SoR_Main_Window", false)
CreateWindow("RoR_SoR_Opacity", false)
CreateWindow("RoR_SoR_Scale", false)
CreateWindow("RoR_SoR_Offset", false)
CreateWindow("RoR_SoR_Popper", false)
CreateWindow("RoR_SoR_Button", true)
CreateWindow("RoR_SoR_DoorPercentage", false)
WindowSetParent("RoR_SoR_DoorPercentage", "SiegeWeaponInfoWindow")



WindowSetDrawWhenInterfaceHidden("RoR_SoR_DoorPercentage",true)
StatusBarSetMaximumValue( "RoR_SoR_DoorPercentageHealthPercentBar", 100 )

    local color = SiegeWeaponControlWindow.HEALTH_BAR_COLOR
    StatusBarSetForegroundTint ("RoR_SoR_DoorPercentageHealthPercentBar", color.r, color.g, color.b)
    color = SiegeWeaponControlWindow.TIMER_BAR_BG_COLOR
    StatusBarSetBackgroundTint ("RoR_SoR_DoorPercentageHealthPercentBar", color.r, color.g, color.b)



LayoutEditor.RegisterWindow( "RoR_SoR_Main_Window", L"SoR Anchor Window", L"SoR Anchor Window", true, true, true, nil )
LayoutEditor.RegisterWindow( "RoR_SoR_Button", L"SoR Toggle Button", L"SoR Toggle Button", false, false, false, nil )

TextLogAddEntry("Chat", 0, L"<icon00057> RoR_SoR "..towstring(version)..L" Loaded.")
LabelSetText("RoR_SoR_PopperLabel",L"State of Realm")

RoR_Window_Scale = (tonumber(WindowGetScale("RoR_SoR_Main_Window")))
RoR_Window_Alpha = (tonumber(WindowGetAlpha("RoR_SoR_Main_Window")))

RoR_SoR.Timers = {}
RoR_SoR.OpenZones = {}
RoR_SoR.ZoneTimer = {}
RoR_SoR.BO_States = {}
RoR_SoR.BO_IDs = {}
RoR_SoR.KEEP_States = {}
RoR_SoR.KEEP_IDs = {}
RoR_SoR.HideChannel(65)
RoR_SoR.Fort = {}

if not RoR_SoR.Settings then RoR_SoR.DefaultSettings() end

if (not RoR_SoR.Settings.Version) or (RoR_SoR.Settings.Version < version) then RoR_SoR.DefaultSettings() end

	if (LibSlash ~= nil) then
	LibSlash.RegisterSlashCmd("soroffset", function(input) RoR_SoR.Offset(input) end)
	end

WindowSetScale("RoR_SoR_Popper",RoR_Window_Scale)
WindowSetShowing("RoR_SoR_ButtonCombat",false)

RoR_SoR.HideChannel(65)
local siegeWindow = "SiegeWeaponGeneralFireWindowChatLogDisplay"
LogDisplaySetFilterState(siegeWindow, "Chat", 65, false)

if(GameData.Player.career.line>0)
  then
    RoR_SoR:RegisterSelfEvents()
  else
    RegisterEventHandler(SystemData.Events.LOADING_END,"RoR_SoR.OnLoadingEnd")
  end

RoR_SoR.stateMachineName = "RoR_SoR"
RoR_SoR.state = {[SEND_BEGIN] = { handler=nil,time=RoR_SoR.StateTimer,nextState=SEND_FINISH } , [SEND_FINISH] = { handler=RoR_SoR.CheckCampaign,time=RoR_SoR.StateTimer,nextState=SEND_BEGIN, } , }
RoR_SoR.StartMachine()

--if the RoR_CitySiege table can't be found due to a reloadui, load the current city-rating timer from the backup save and set flag HasRealoded (will persist untill it get response from valid RoR_CitySiege table)
if RoR_CitySiege.GetCity(GameData.CityId.EMPIRE) == nil or RoR_CitySiege.GetCity(GameData.CityId.CHAOS) == nil then
	RoR_SoR.Pairings[162].Timer = RoR_SoR.City_Status[GameData.CityId.EMPIRE].ratingTimer
	RoR_SoR.Pairings[161].Timer = RoR_SoR.City_Status[GameData.CityId.CHAOS].ratingTimer

	RoR_SoR.Pairings[162].Timer2 = RoR_SoR.City_Status[GameData.CityId.EMPIRE].timeLeft
	RoR_SoR.Pairings[161].Timer2 = RoR_SoR.City_Status[GameData.CityId.CHAOS].timeLeft

	HasReloaded = true
end

RoR_SoR.Restack()
end

function RoR_SoR:RegisterSelfEvents()
RegisterEventHandler( SystemData.Events.ENTER_WORLD, "RoR_SoR.Enable" )
RegisterEventHandler( SystemData.Events.INTERFACE_RELOADED, "RoR_SoR.Enable" )
RegisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED, "RoR_SoR.Enable")
RegisterEventHandler(SystemData.Events.WORLD_MAP_POINTS_LOADED, "RoR_SoR.Enable")

RegisterEventHandler(SystemData.Events.SCENARIO_END, "RoR_SoR.OnScenario")
RegisterEventHandler(SystemData.Events.SCENARIO_BEGIN, "RoR_SoR.OnScenario")

RegisterEventHandler(  SystemData.Events.PUBLIC_QUEST_ADDED,   "RoR_SoR.UpdateObjectives")
RegisterEventHandler(  SystemData.Events.PUBLIC_QUEST_UPDATED, "RoR_SoR.UpdateObjectives")
RegisterEventHandler(  SystemData.Events.PUBLIC_QUEST_INFO_UPDATED, "RoR_SoR.UpdateObjectives")
RegisterEventHandler(  SystemData.Events.PUBLIC_QUEST_REMOVED, "RoR_SoR.UpdateObjectives")

--RegisterEventHandler( SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "RoR_SoR.OnCombat" )


--RegisterEventHandler(TextLogGetUpdateEventId("Chat"), "RoR_SoR.OnChatLogUpdated")
ror_PacketHandling.Register("SOR_STATUS",RoR_SoR.Packet)
ror_PacketHandling.Register("SOR_F",RoR_SoR.Packet)
RoR_SoR.Enable()

end

function RoR_SoR.Packet(text)
if string.find(text,"SOR_STATUS:") then
local text = string.gsub(text,"SOR_STATUS:","")
local SoRtable = json.decode(text)
RoR_SoR.SET_KEEP(SoRtable)
elseif string.find(text,"SOR_F:") and RoR_SoR.Settings.ShowForts == true then
local text = string.gsub(text,"SOR_F:","")
local SoRtable = json.decode(text)
RoR_SoR.SET_FORT(SoRtable)
end

end


function RoR_SoR:OnLoadingEnd()
  --register events
  RoR_SoR:RegisterSelfEvents()
  UnregisterEventHandler(SystemData.Events.LOADING_END,"RoR_SoR.OnLoadingEnd")
end

function RoR_SoR.StartMachine()
	local stateMachine = TimedStateMachine.New( RoR_SoR.state,SEND_BEGIN)
	TimedStateMachineManager.AddStateMachine( RoR_SoR.stateMachineName, stateMachine )
end

function RoR_SoR.CheckCampaign()
--if WindowGetShowing("RoR_SoR_Main_Window") or RoR_SoR.Settings.Enabled == false then return end

if RoR_SoR.Settings.ShowPairings == true then
	for k,v in pairs(RoR_SoR.Forts) do
	local CampaignData = GetCampaignZoneData(k)
		if CampaignData.controllingRealm ~= 0 and CampaignData.controllingRealm ~= CampaignData.initialRealm then
		RoR_SoR.SET_PAIRINGS("SoR_:"..tostring(CampaignData.pairingId)..":"..tostring(CampaignData.controllingRealm))
		end
	end
end


if RoR_SoR.Settings.ShowCity == true then --contested City siege
	--/script RoR_SoR.SET_CITY(StringSplit(tostring("SoR_C:162:1:10:8:2:100:3"),":"))
	local SiegedRealm = 0
	local cityData = {}
	cityData[GameData.CityId.EMPIRE] = GetCampaignCityData(GameData.CityId.EMPIRE)
	cityData[GameData.CityId.CHAOS] = GetCampaignCityData(GameData.CityId.CHAOS)
	if cityData[GameData.CityId.EMPIRE].controllingRealm ~= cityData[GameData.CityId.EMPIRE].initialRealm then
		local SiegeData = RoR_SoR.City_Status[GameData.CityId.EMPIRE]
		local CityRank = GetCityRatingForCityId(GameData.CityId.EMPIRE)
		if SiegeData ~= nil then

		local SoR_CITY_SPLIT_TEXT_STREAM = StringSplit(tostring("SoR_C:162:"..tostring(cityData[GameData.CityId.EMPIRE].cityState)..":"..tostring(SiegeData.instanceCount)..":"..tostring(SiegeData.destroWins)..":"..tostring(SiegeData.orderWins)..":"..tostring(SiegeData.timeLeft))..":"..tostring(CityRank), ":")
		RoR_SoR.SET_CITY(SoR_CITY_SPLIT_TEXT_STREAM)
		SiegedRealm = 1
		end
		end
	--if cityData[GameData.CityId.CHAOS].controllingRealm == 0 then
	if cityData[GameData.CityId.CHAOS].controllingRealm ~= cityData[GameData.CityId.CHAOS].initialRealm then
		local SiegeData = RoR_SoR.City_Status[GameData.CityId.CHAOS]
		local CityRank = GetCityRatingForCityId(GameData.CityId.CHAOS)
		if SiegeData ~= nil then

		local SoR_CITY_SPLIT_TEXT_STREAM = StringSplit(tostring("SoR_C:161:"..tostring(cityData[GameData.CityId.CHAOS].cityState)..":"..tostring(SiegeData.instanceCount)..":"..tostring(SiegeData.destroWins)..":"..tostring(SiegeData.orderWins)..":"..tostring(SiegeData.timeLeft))..":"..tostring(CityRank), ":")
		RoR_SoR.SET_CITY(SoR_CITY_SPLIT_TEXT_STREAM)
		SiegedRealm = 2
		end
		end

end
	--Normal city status:
	--Map_ID,Realm_ID,City_ID
	if not DoesWindowExist("SoR_161") and  RoR_SoR.Settings.ShowCity_Status then
		RoR_SoR.SET_CAMPAIGN("SoR_:161:2:4")
	end

	if not DoesWindowExist("SoR_162") and RoR_SoR.Settings.ShowCity_Status then
		RoR_SoR.SET_CAMPAIGN("SoR_:162:1:3")
	end


end

function RoR_SoR.OnShutdown()

UnregisterEventHandler(TextLogGetUpdateEventId("Chat"), "RoR_SoR.OnChatLogUpdated")
UnregisterEventHandler( SystemData.Events.ENTER_WORLD, "RoR_SoR.Enable" )
UnregisterEventHandler( SystemData.Events.INTERFACE_RELOADED, "RoR_SoR.Enable" )

UnregisterEventHandler(SystemData.Events.SCENARIO_END, "RoR_SoR.OnScenario")
UnregisterEventHandler(SystemData.Events.SCENARIO_BEGIN, "RoR_SoR.OnScenario")

UnregisterEventHandler(  SystemData.Events.PUBLIC_QUEST_ADDED,   "RoR_SoR.UpdateObjectives")
UnregisterEventHandler(  SystemData.Events.PUBLIC_QUEST_UPDATED, "RoR_SoR.UpdateObjectives")
UnregisterEventHandler(  SystemData.Events.PUBLIC_QUEST_INFO_UPDATED, "RoR_SoR.UpdateObjectives")
UnregisterEventHandler(  SystemData.Events.PUBLIC_QUEST_REMOVED, "RoR_SoR.UpdateObjectives")

end

function RoR_SoR.OnChatLogUpdated(updateType, filterType)
	if WindowGetShowing("RoR_SoR_Main_Window") == true then
		if( updateType == SystemData.TextLogUpdate.ADDED ) then
			if filterType == SystemData.ChatLogFilters.CHANNEL_9 then
				local _, filterId, text = TextLogGetEntry( "Chat", TextLogGetNumEntries("Chat") - 1 )
				RoR_SoR.Text_Stream_Fetch(text)
			end
		end
	end
end

function RoR_SoR.GetBanner()
	if RoR_SoR.Settings.DrawBanner then return -3 else return 6 end
end

function RoR_SoR.GetParing(zone)
local zone = tonumber(zone)
	if (zone/200 >= 1) then
		return 1
	elseif (zone/100 >= 1) then
		return 2
	else
		return 3
	end
return false
end

function RoR_SoR.Enable()

if RoR_SoR.Settings.Enabled == true then

local ShowT1 = L""
local ShowT4 = L""
local ShowForts = L""
if RoR_SoR.Settings.ShowT1 == true then ShowT1 = L" T1" end
if RoR_SoR.Settings.ShowT4 == true then ShowT4 = L" T4" end
if RoR_SoR.Settings.ShowForts == true then ShowForts = L" Forts" end

SendChatText(L"]sorenable"..ShowT1..ShowT4..ShowForts,ChatSettings.Channels[0].serverCmd)
RoR_SoR.Restack()
elseif RoR_SoR.Settings.Enabled == false then

SendChatText(L"]sordisable",ChatSettings.Channels[0].serverCmd)
RoR_SoR.Restack()
end

end

function RoR_SoR.Disable()
local HideT1 = L""
local HideT4 = L""
local HideForts = L""
if RoR_SoR.Settings.ShowT1 == false then HideT1 = L" T1" end
if RoR_SoR.Settings.ShowT4 == false then HideT4 = L" T4" end
if RoR_SoR.Settings.ShowForts == false then HideForts = L" Forts" end
SendChatText(L"]sordisable"..HideT1..HideT4..HideForts,ChatSettings.Channels[0].serverCmd)
RoR_SoR.Restack()
return
end


function RoR_SoR.Text_Stream_Fetch(text)
local text = towstring(text)

	if text:find(L"SoR_") and (not text:find(L"SoR_F")) then
		--Check For BO stream
		if text:match( L"SoR_+[^%.]+_BO:([^%.]+).") then
		local SoR_BO_SPLIT_TEXT_STREAM = StringSplit(tostring(text), ":")
		if SoR_BO_SPLIT_TEXT_STREAM[15] == nil then return end -- check and exit if short string
		--Create window if not exist
			local Window_Name = tostring(SoR_BO_SPLIT_TEXT_STREAM[2])

			--Setup Tier 4 BO zone stuff
			if (SoR_BO_SPLIT_TEXT_STREAM[1] == "SoR_T4_BO") and (RoR_SoR.Settings.ShowT4 == true) then
				local Fetch_Active_Zone = tonumber(SoR_BO_SPLIT_TEXT_STREAM[22])
					if (not DoesWindowExist("SoR_"..Window_Name)) then
						CreateWindowFromTemplate("SoR_"..Window_Name, "RoR_SoR_RealmTemplate", "Root")
							RoR_SoR.BO_States[Window_Name] = {}
							RoR_SoR.KEEP_States[Window_Name] = {}
							RoR_SoR.KeepHealth[Window_Name] = {[1]=0,[2]=0}
							local ZoneData = GetCampaignZoneData(tonumber(Window_Name))
							RoR_SoR.OpenZones[Window_Name] =  tonumber(ZoneData.tierId)
						LabelSetText("SoR_"..Window_Name.."_BannerLabel",towstring(GetZoneName(tonumber(Window_Name))))
						LabelSetText("SoR_"..Window_Name.."_BannerLabel_BG",towstring(GetZoneName(tonumber(Window_Name))))
						LabelSetTextColor("SoR_"..Window_Name.."_BannerLabel",255,255,255)
						local BannerW,_ = LabelGetTextDimensions("SoR_"..Window_Name.."_BannerLabel")
						WindowSetDimensions( "SoR_"..Window_Name.."BannerMid", BannerW, 40 )
					end
			--Setup Tier 1 BO zone stuff
			elseif	(SoR_BO_SPLIT_TEXT_STREAM[1] == "SoR_T1_BO") and (RoR_SoR.Settings.ShowT1 == true) then
				if (not DoesWindowExist("SoR_"..Window_Name)) then
					CreateWindowFromTemplate("SoR_"..Window_Name, "RoR_SoR_RealmTemplate", "Root")
					RoR_SoR.BO_States[Window_Name] = {}
					local ZoneData = GetCampaignZoneData(tonumber(Window_Name))
					RoR_SoR.OpenZones[Window_Name] =  tonumber(ZoneData.tierId)
					LabelSetText("SoR_"..Window_Name.."_BannerLabel",towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][1]))..L" � "..towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][2])))
					LabelSetText("SoR_"..Window_Name.."_BannerLabel_BG",towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][1]))..L" � "..towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][2])))
					LabelSetTextColor("SoR_"..Window_Name.."_BannerLabel",255,255,255)
					local BannerW,_ = LabelGetTextDimensions("SoR_"..Window_Name.."_BannerLabel")
					WindowSetDimensions( "SoR_"..Window_Name.."BannerMid", BannerW, 40 )
				end
				RoR_SoR.T1_UPDATE(Window_Name,SoR_BO_SPLIT_TEXT_STREAM)
			--Setup Tier 2-3 BO zone stuff
			elseif((SoR_BO_SPLIT_TEXT_STREAM[1] == "SoR_T2_BO") or (SoR_BO_SPLIT_TEXT_STREAM[1] == "SoR_T3_BO")) and (RoR_SoR.Settings.ShowT4 == true) then --Setup Tier 2 and 3 BO zone stuff
				if (not DoesWindowExist("SoR_"..Window_Name)) then
					CreateWindowFromTemplate("SoR_"..Window_Name, "RoR_SoR_RealmTemplate", "Root")
					RoR_SoR.BO_States[Window_Name] = {}
					local ZoneData = GetCampaignZoneData(tonumber(Window_Name))
					RoR_SoR.OpenZones[Window_Name] =  tonumber(ZoneData.tierId)
					RoR_SoR.KEEP_States[Window_Name] = {}
					LabelSetText("SoR_"..Window_Name.."_BannerLabel",towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][1]))..L" � "..towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][2])))
					LabelSetText("SoR_"..Window_Name.."_BannerLabel_BG",towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][1]))..L" � "..towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][2])))
					LabelSetTextColor("SoR_"..Window_Name.."_BannerLabel",255,255,255)
					local BannerW,_ = LabelGetTextDimensions("SoR_"..Window_Name.."_BannerLabel")
					WindowSetDimensions( "SoR_"..Window_Name.."BannerMid", BannerW, 40 )
				end
			end
			if RoR_SoR.DebugBO == true then
				if SoR_BO_SPLIT_TEXT_STREAM[1] == "SoR_T4_BO" or SoR_BO_SPLIT_TEXT_STREAM[1] == "SoR_T3_BO" then
					d(SoR_BO_SPLIT_TEXT_STREAM)
				else
					d(SoR_BO_SPLIT_TEXT_STREAM)
				end
			end
		RoR_SoR.SET_BO(SoR_BO_SPLIT_TEXT_STREAM)

		--Check for KEEP stream
		elseif text:match( L"SoR_+[^%.]+_Keep:([^%.]+).") then
			local SoR_KEEP_SPLIT_TEXT_STREAM = StringSplit(tostring(text), ":")
			--if SoR_KEEP_SPLIT_TEXT_STREAM[10] == nil then return end
				if RoR_SoR.DebugKeep == true then
						d(SoR_KEEP_SPLIT_TEXT_STREAM)
				end
			RoR_SoR.SET_KEEP(SoR_KEEP_SPLIT_TEXT_STREAM)
		end
	end

		--Check for Fort stream
		if text:find(L"SoR_F") and RoR_SoR.Settings.ShowForts == true  then
		local SoR_FORT_SPLIT_TEXT_STREAM = StringSplit(tostring(text), ":")
			if RoR_SoR.DebugKeep == true then
					d(SoR_FORT_SPLIT_TEXT_STREAM)
			end
			RoR_SoR.SET_FORT(SoR_FORT_SPLIT_TEXT_STREAM)
		end

		if text:find(L"SoR_C") and RoR_SoR.Settings.ShowForts == true  then
		local SoR_FORT_SPLIT_TEXT_STREAM = StringSplit(tostring(text), ":")
			if RoR_SoR.DebugKeep == true then
					d(SoR_FORT_SPLIT_TEXT_STREAM)

			end
			RoR_SoR.SET_CITY(SoR_FORT_SPLIT_TEXT_STREAM)
			end

end


function RoR_SoR.SET_CAMPAIGN(Input)
	local SoR_CAMPAIGN_SPLIT_TEXT_STREAM = Input

	if type(SoR_CAMPAIGN_SPLIT_TEXT_STREAM)~= "table" then
		SoR_CAMPAIGN_SPLIT_TEXT_STREAM = StringSplit(SoR_CAMPAIGN_SPLIT_TEXT_STREAM,":")
	end

	local Window_Name = "P_"..tostring(SoR_CAMPAIGN_SPLIT_TEXT_STREAM[2])
	local Pairing_ID = tonumber(SoR_CAMPAIGN_SPLIT_TEXT_STREAM[2])
	local Realm_ID = tonumber(SoR_CAMPAIGN_SPLIT_TEXT_STREAM[3])
	local City_ID = tonumber(SoR_CAMPAIGN_SPLIT_TEXT_STREAM[4])

--28800 max timer

	--check for valid RoR_CitySiege table
	if RoR_CitySiege.GetCity(City_ID) ~= nil then
			RoR_SoR.City_Status[City_ID] = RoR_CitySiege.GetCity(City_ID)
			RoR_SoR.Pairings[Pairing_ID].Timer = RoR_SoR.City_Status[City_ID].ratingTimer


			RoR_SoR.Pairings[Pairing_ID].Timer2 = RoR_SoR.City_Status[City_ID].timeLeft
			--HasReloaded = false
	else

	end

	if DoesWindowExist("SoR_"..Window_Name) then

	RoR_SoR.ZoneTimer[Window_Name] = ZoneLockTimer

	WindowClearAnchors("SoR_"..Window_Name.."Banner")
	WindowAddAnchor("SoR_"..Window_Name.."Banner","top", "SoR_"..Window_Name, "top", 0,RoR_SoR.GetBanner())

	LabelSetText("SoR_"..Window_Name.."_BannerLabel",towstring(GetCityName(City_ID)))
	LabelSetText("SoR_"..Window_Name.."_BannerLabel_BG",towstring(GetCityName(City_ID)))

	local Color = RoR_SoR.RealmColors[Realm_ID+1]
	local Sizes = {[true]=15,[false]=0}

	LabelSetText("SoR_"..Window_Name.."Lock_STATUS",TimeUtils.FormatTimeCondensed(RoR_SoR.Pairings[Pairing_ID].Timer))
	LabelSetText("SoR_"..Window_Name.."Lock_STATUS_BG",TimeUtils.FormatTimeCondensed(RoR_SoR.Pairings[Pairing_ID].Timer))

	LabelSetText("SoR_"..Window_Name.."_TIMER",TimeUtils.FormatTimeCondensed(RoR_SoR.Pairings[Pairing_ID].Timer))
	LabelSetText("SoR_"..Window_Name.."_TIMER_BG",TimeUtils.FormatTimeCondensed(RoR_SoR.Pairings[Pairing_ID].Timer))


	MapUtils.UpdateCityRatingWindow( City_ID, "SoR_"..Window_Name.."CityRating")

	WindowSetShowing("SoR_"..Window_Name.."Lock",RoR_SoR.Pairings[Pairing_ID].Timer2 > 0)
	WindowSetShowing("SoR_"..Window_Name.."_TIMER",RoR_SoR.Pairings[Pairing_ID].Timer > 0)
	WindowSetShowing("SoR_"..Window_Name.."_TIMER_BG",RoR_SoR.Pairings[Pairing_ID].Timer > 0)

	--WindowSetDimensions( "SoR_"..Window_Name, 300, 85+Sizes[RoR_SoR.Pairings[Pairing_ID].Timer2 > 0])
	WindowSetDimensions( "SoR_"..Window_Name, 300, 85)

	local BannerW,_ = LabelGetTextDimensions("SoR_"..Window_Name.."_BannerLabel")
	WindowSetDimensions( "SoR_"..Window_Name.."BannerMid", BannerW, 40 )

	DynamicImageSetTexture( "SoR_"..Window_Name.."BG", "City_"..Pairing_ID, 300, 105 )

		--WindowSetTintColor("SoR_"..Window_Name.."Background2Border",Color.r,Color.g,Color.b)
		WindowSetTintColor("SoR_"..Window_Name.."Background2Background2",Color.r,Color.g,Color.b)
		LabelSetTextColor("SoR_"..Window_Name.."_BannerLabel",255,228,65)
	else
	CreateWindowFromTemplate("SoR_"..Window_Name, "RoR_SoR_City_Status_Template", "Root")
	RoR_SoR.OpenZones[Window_Name] =  tonumber(16)
	RoR_SoR.Timers[Window_Name] = {}
	RoR_SoR.SET_CAMPAIGN(SoR_CAMPAIGN_SPLIT_TEXT_STREAM)
	end
	RoR_SoR.Restack()
end




function RoR_SoR.SET_PAIRINGS(Input)
	local SoR_PAIRING_SPLIT_TEXT_STREAM = Input

	if type(SoR_PAIRING_SPLIT_TEXT_STREAM)~= "table" then
		SoR_PAIRING_SPLIT_TEXT_STREAM = StringSplit(SoR_PAIRING_SPLIT_TEXT_STREAM,":")
	end

	local Window_Name = "P_"..tostring(SoR_PAIRING_SPLIT_TEXT_STREAM[2])
	local Pairing_ID = tonumber(SoR_PAIRING_SPLIT_TEXT_STREAM[2])
	local Owning_Realm = tonumber(SoR_PAIRING_SPLIT_TEXT_STREAM[3])
	local Pairing_Data = GetCampaignPairingData(Pairing_ID)

--28800 max timer
	RoR_SoR.Pairings[Pairing_ID].Timer = Pairing_Data.captureTimeRemaining


	if DoesWindowExist("SoR_"..Window_Name) then

	local UnlockTimer = RoR_SoR.Pairings[Pairing_ID].Timer
	RoR_SoR.ZoneTimer[Window_Name] = ZoneLockTimer

	WindowClearAnchors("SoR_"..Window_Name.."Banner")
	WindowAddAnchor("SoR_"..Window_Name.."Banner","top", "SoR_"..Window_Name, "top", 0,RoR_SoR.GetBanner())

	LabelSetText("SoR_"..Window_Name.."_BannerLabel",towstring(GetStringFromTable("MapSystem",Pairing_ID-1)))
	LabelSetText("SoR_"..Window_Name.."_BannerLabel_BG",towstring(GetStringFromTable("MapSystem",Pairing_ID-1)))

	local Color = RoR_SoR.RealmColors[Owning_Realm+1]

	LabelSetText("SoR_"..Window_Name.."_STATUS",L"Pairing Controlled By: "..towstring(CreateHyperLink(L"0",towstring(GetRealmName(Owning_Realm)), {Color.r,Color.g,Color.b}, {} )))
	LabelSetText("SoR_"..Window_Name.."_STATUS_BG",L"Pairing Controlled By: "..towstring(GetRealmName(Owning_Realm)))

	WindowSetShowing("SoR_"..Window_Name.."_TIMER",UnlockTimer > 0)
	WindowSetShowing("SoR_"..Window_Name.."_TIMER_BG",UnlockTimer > 0)
	WindowSetShowing("SoR_"..Window_Name.."_SmallLock",UnlockTimer > 0)


	LabelSetText("SoR_"..Window_Name.."_TIMER",TimeUtils.FormatClock(UnlockTimer))
	LabelSetText("SoR_"..Window_Name.."_TIMER_BG",TimeUtils.FormatClock(UnlockTimer))

	local BannerW,_ = LabelGetTextDimensions("SoR_"..Window_Name.."_BannerLabel")
	WindowSetDimensions( "SoR_"..Window_Name.."BannerMid", BannerW, 40 )

	for i=1,3 do
		DynamicImageSetTextureSlice("SoR_"..Window_Name.."InfoZone"..i,"Zone-"..tostring(RoR_SoR.PairingIconSliceNames[Pairing_ID][Owning_Realm]))
	end
		DynamicImageSetTextureSlice("SoR_"..Window_Name.."InfoFort1","Fort-"..tostring(RoR_SoR.PairingIconSliceNames[Pairing_ID][Owning_Realm]))
		DynamicImageSetTextureSlice("SoR_"..Window_Name.."InfoFort2","Fort-"..tostring(RoR_SoR.PairingIconSliceNames[Pairing_ID][Owning_Realm]))
		DynamicImageSetTexture( "SoR_"..Window_Name.."BG", "Fort_"..RoR_SoR.FortBG[Pairing_ID][Owning_Realm],0,0 )
		--WindowSetTintColor("SoR_"..Window_Name.."Background2Border",Color.r,Color.g,Color.b)
		WindowSetTintColor("SoR_"..Window_Name.."Background2Background2",Color.r,Color.g,Color.b)
	else
	CreateWindowFromTemplate("SoR_"..Window_Name, "RoR_SoR_PairingTemplate", "Root")
	RoR_SoR.OpenZones[Window_Name] =  tonumber(6)
	RoR_SoR.Timers[Window_Name] = {}
	RoR_SoR.SET_PAIRINGS(SoR_PAIRING_SPLIT_TEXT_STREAM)
	end
	RoR_SoR.Restack()
end


function RoR_SoR.SET_CITY(Input)
--SoR_F:10:2:85:BO 1:1:BO 2:2:BO 3:1:BO 4:2:BO 5:2:100
--SoR_F:10:2:85:BO 1:1:BO 2:2:BO 3:1:BO 4:2:BO 5:2:100:100:100:25:25:10:10
--SoR_C:10:3:100:100:100:100:25:25:10:10
--attackers:defenders:reserved_A:reserved_B:wait_A:wait_B
	local SoR_FORT_SPLIT_TEXT_STREAM = Input
	local Window_Name = tostring(SoR_FORT_SPLIT_TEXT_STREAM[2])
	local C_Stage = tonumber(SoR_FORT_SPLIT_TEXT_STREAM[3])
	local C_Instances = tonumber(SoR_FORT_SPLIT_TEXT_STREAM[4])
	local C_DestroWins = tonumber(SoR_FORT_SPLIT_TEXT_STREAM[5])
	local C_OrderWins = tonumber(SoR_FORT_SPLIT_TEXT_STREAM[6])
	local C_Timer = tonumber(SoR_FORT_SPLIT_TEXT_STREAM[7])
	local C_Rank =  tonumber(SoR_FORT_SPLIT_TEXT_STREAM[8])
	local City_ID = RoR_SoR.CityCampaign[tonumber(SoR_FORT_SPLIT_TEXT_STREAM[2])]


	if RoR_CitySiege.GetCity(City_ID) ~= nil then
			RoR_SoR.City_Status[City_ID] = RoR_CitySiege.GetCity(City_ID)
			RoR_SoR.Pairings[tonumber(Window_Name)].Timer = RoR_SoR.City_Status[City_ID].ratingTimer
			RoR_SoR.Pairings[tonumber(Window_Name)].Timer2 = RoR_SoR.City_Status[City_ID].timeLeft

			--HasReloaded = false
	else
		--if the RoR_CitySiege table can't be found due to a reloadui, save the current rating timer into the backup save

	end


	if DoesWindowExist("SoR_"..Window_Name) then

	DynamicImageSetTextureOrientation ("SoR_"..Window_Name.."Flames", Window_Name == "162")

	WindowClearAnchors("SoR_"..Window_Name.."Banner")
	WindowAddAnchor("SoR_"..Window_Name.."Banner","top", "SoR_"..Window_Name, "top", 0,RoR_SoR.GetBanner())

	DynamicImageSetTextureSlice("SoR_"..Window_Name.."CITY_RANK", "KeepDifficulty-"..C_Rank.."-star" )


	LabelSetText("SoR_"..Window_Name.."_BannerLabel",towstring(GetZoneName(tonumber(Window_Name))))
	LabelSetText("SoR_"..Window_Name.."_BannerLabel_BG",towstring(GetZoneName(tonumber(Window_Name))))

--	LabelSetText("SoR_"..Window_Name.."_STAGE",L"State: "..towstring(C_Stage))
--	LabelSetText("SoR_"..Window_Name.."_STAGE_BG",L"State: "..towstring(C_Stage))

	WindowSetShowing("SoR_"..Window_Name.."_HEALTH", C_Stage>3)
	WindowSetShowing("SoR_"..Window_Name.."_HEALTH_BG", C_Stage>3)
	WindowSetShowing("SoR_"..Window_Name.."Destro_Wins", C_Stage>3)
	WindowSetShowing("SoR_"..Window_Name.."Destro_Wins_BG", C_Stage>3)
	WindowSetShowing("SoR_"..Window_Name.."Order_Wins", C_Stage>3)
	WindowSetShowing("SoR_"..Window_Name.."Order_Wins_BG", C_Stage>3)
	WindowSetShowing("SoR_"..Window_Name.."Order_Wins_BG", C_Stage>3)
	WindowSetShowing("SoR_"..Window_Name.."Order-Symbol", C_Stage>3)
	WindowSetShowing("SoR_"..Window_Name.."Destro-Symbol", C_Stage>3)



	LabelSetText("SoR_"..Window_Name.."_STAGE_INFO",towstring(RoR_SoR.CITY_MESSAGE[C_Stage]))
	LabelSetText("SoR_"..Window_Name.."_STAGE_INFO_BG",towstring(RoR_SoR.CITY_MESSAGE[C_Stage]))


	WindowSetShowing("SoR_"..Window_Name.."_TIMER",C_Timer>0.1)
	WindowSetShowing("SoR_"..Window_Name.."_TIMER_BG",C_Timer>0.1)


	LabelSetText("SoR_"..Window_Name.."_HEALTH",towstring(C_Instances))
	LabelSetText("SoR_"..Window_Name.."_HEALTH_BG",towstring(C_Instances))

	LabelSetTextColor("SoR_"..Window_Name.."_BannerLabel",255,225,100)
	local BannerW,_ = LabelGetTextDimensions("SoR_"..Window_Name.."_BannerLabel")
	WindowSetDimensions( "SoR_"..Window_Name.."BannerMid", BannerW, 40 )
	DynamicImageSetTexture( "SoR_"..Window_Name.."BG", "Fort_"..Window_Name,0,0 )

	WindowSetTintColor("SoR_"..Window_Name.."Background2Background2",180,0,255)

		RoR_SoR.ZoneTimer[Window_Name] = ZoneLockTimer
		RoR_SoR.Timers[Window_Name][1] = tonumber(C_Timer)

		if (Window_Name == "162") then
            DynamicImageSetTexture( "SoR_"..Window_Name.."VictorBanner", "scenario_widgets", 115, 149 )
        else
            DynamicImageSetTexture( "SoR_"..Window_Name.."VictorBanner", "scenario_widgets", 185, 149 )
        end

		local Attck_Color = RoR_SoR.RealmColors[4-RoR_SoR.City[tonumber(Window_Name)]]
		local Defend_Color = RoR_SoR.RealmColors[RoR_SoR.City[tonumber(Window_Name)]+1]


		LabelSetText("SoR_"..Window_Name.."Destro_Wins",towstring(C_DestroWins))
		LabelSetText("SoR_"..Window_Name.."Destro_Wins_BG",towstring(C_DestroWins))

		LabelSetText("SoR_"..Window_Name.."Order_Wins",towstring(C_OrderWins))
		LabelSetText("SoR_"..Window_Name.."Order_Wins_BG",towstring(C_OrderWins))

	else
	CreateWindowFromTemplate("SoR_"..Window_Name, "RoR_SoR_CityTemplate", "Root")
	RoR_SoR.OpenZones[Window_Name] =  tonumber(5)
	RoR_SoR.Timers[Window_Name] = {}
	RoR_SoR.City[Window_Name] = {BO={},Owner={},Stage=0,Health=L""}
	RoR_SoR.SET_CITY(SoR_FORT_SPLIT_TEXT_STREAM)
	WindowStartAlphaAnimation( "SoR_"..Window_Name.."Flames", Window.AnimationType.LOOP, 1.0, 0.2, 0.5, false, 0.0, 0 ) --start the Burning BO pulse
	end
	RoR_SoR.Restack()
end


function RoR_SoR.SET_FORT(Input)
local Input = Input
local Attackers = Input.attackers
local Defenders = Input.defenders
local Objectives = Input.objectives
local Doors = Input.doors[1]

	local Window_Name = tostring(Input.zoneId)
	local F_Stage = tonumber(Input.stage)


	if DoesWindowExist("SoR_"..Window_Name) then

	WindowClearAnchors("SoR_"..Window_Name.."Banner")
	WindowAddAnchor("SoR_"..Window_Name.."Banner","top", "SoR_"..Window_Name, "top", 0,RoR_SoR.GetBanner())
	WindowSetTintColor("SoR_"..Window_Name.."Background2Background2",217,164,10)

			local F_attackers = 0
			local F_defenders = 0
			local F_reserved_A = 0
			local F_reserved_D = 0
			local F_wait_A = 0
			local F_wait_D = 0

	LabelSetText("SoR_"..Window_Name.."_BannerLabel",towstring(GetZoneName(tonumber(Window_Name))))
	LabelSetText("SoR_"..Window_Name.."_BannerLabel_BG",towstring(GetZoneName(tonumber(Window_Name))))

	LabelSetText("SoR_"..Window_Name.."_STAGE",L"Stage: "..towstring(F_Stage))
	LabelSetText("SoR_"..Window_Name.."_STAGE_BG",L"Stage: "..towstring(F_Stage))

	WindowSetShowing("SoR_"..Window_Name.."LORD",F_Stage == 3)

	LabelSetTextColor("SoR_"..Window_Name.."_BannerLabel",255,225,100)
	local BannerW,_ = LabelGetTextDimensions("SoR_"..Window_Name.."_BannerLabel")
	WindowSetDimensions( "SoR_"..Window_Name.."BannerMid", BannerW, 40 )
	DynamicImageSetTexture( "SoR_"..Window_Name.."KEEP1KEEPICON", RoR_SoR.GetKeepTexture(RoR_SoR.Forts[tonumber(Window_Name)],1),42,42 )
	DynamicImageSetTexture( "SoR_"..Window_Name.."BG", "Fort_"..Window_Name,0,0 )
	RoR_SoR.Fort[Window_Name]["Status"] = {Attackers=Attackers.count,Defenders=Defenders.count,Reserved_A=Attackers.reservations,Reserved_D=Defenders.reservations}

		if F_Stage == 1 then
			local F_Timer = tonumber(Input.timeRemaining)

			F_attackers = tonumber(Attackers.count) or 0
			F_defenders = tonumber(Defenders.count) or 0
			F_reserved_A = tonumber(Attackers.reservations) or 0
			F_reserved_D = tonumber(Defenders.reservations) or 0
			F_wait_A = tonumber(Attackers.queued) or 0
			F_wait_D = tonumber(Defenders.queued) or 0


			WindowSetShowing( "SoR_"..Window_Name.."_TIMER",true)
			WindowSetShowing( "SoR_"..Window_Name.."_HEALTH",false)
			WindowSetShowing( "SoR_"..Window_Name.."_HEALTH_BG",false)
			--WindowSetShowing( "SoR_"..Window_Name.."KEEP1LORD_ICON",false)
			WindowSetShowing( "SoR_"..Window_Name.."KEEP1KEEPDOOR1",true)

			RoR_SoR.Timers[Window_Name][1] = F_Timer
			for i=1,5 do
				WindowSetShowing( "SoR_"..Window_Name.."BO"..i,false)
				WindowSetShowing( "SoR_"..Window_Name.."BO"..i,false)
			end

		elseif 	F_Stage == 2 then
			local F_Timer = tonumber(Input.timeRemaining)

			F_attackers = tonumber(Attackers.count) or 0
			F_defenders = tonumber(Defenders.count) or 0
			F_reserved_A = tonumber(Attackers.reservations) or 0
			F_reserved_D = tonumber(Defenders.reservations) or 0
			F_wait_A = tonumber(Attackers.queued) or 0
			F_wait_D = tonumber(Defenders.queued) or 0

			WindowSetShowing( "SoR_"..Window_Name.."_TIMER",true)
			WindowSetShowing( "SoR_"..Window_Name.."_HEALTH",true)
			WindowSetShowing( "SoR_"..Window_Name.."_HEALTH_BG",true)
			--WindowSetShowing( "SoR_"..Window_Name.."KEEP1LORD_ICON",false)
			WindowSetShowing( "SoR_"..Window_Name.."KEEP1KEEPDOOR1",true)
			LabelSetText("SoR_"..Window_Name.."_HEALTH",towstring(Doors.pctHealth)..L"%")
			LabelSetText("SoR_"..Window_Name.."_HEALTH_BG",towstring(Doors.pctHealth)..L"%")
			RoR_SoR.Fort[Window_Name].Health = towstring(Doors.pctHealth)..L"%"
			RoR_SoR.Fort[Window_Name].Stage = 2
			RoR_SoR.Timers[Window_Name][1] = F_Timer

			for i=1,5 do
				WindowSetShowing( "SoR_"..Window_Name.."BO"..i,true)
				WindowSetShowing( "SoR_"..Window_Name.."BO"..i,true)

				DynamicImageSetTexture( "SoR_"..Window_Name.."BO"..i.."FlagBG", RoR_SoR.GetFlag(Objectives[i].realm,0),31,31 )
				RoR_SoR.Fort[Window_Name].BO[i] = towstring(GetObjectiveName(Objectives[i].id))
				RoR_SoR.Fort[Window_Name].Owner[i] = tonumber(Objectives[i].realm)


				local ShortBOName = L""
					if RoR_SoR.Settings.ShowBONames	then
						local	RealmColor = RoR_SoR.RealmColors[RoR_SoR.Fort[Window_Name].Owner[i]+1]
						LabelSetTextColor("SoR_"..Window_Name.."BO"..i.."TIMER",RealmColor.r,RealmColor.g,RealmColor.b)
						ShortBOName = wstring.match(wstring.gsub(wstring.gsub(wstring.gsub(wstring.gsub(towstring(RoR_SoR.Fort[Window_Name].BO[tonumber(i)]),L" of ", L""), L"%s",L""), L"%l*", L""), L"'", L""), L"([^^]+)^?.*") or L"" --This is for Shortening Guildnames
					end
				LabelSetText("SoR_"..Window_Name.."BO"..i.."TIMER",ShortBOName)
				LabelSetText("SoR_"..Window_Name.."BO"..i.."TIMER_BG",ShortBOName)

			end

		elseif 	F_Stage == 3 then
			local F_Timer = tonumber(Input.timeRemaining)

			F_attackers = tonumber(Attackers.count) or 0
			F_defenders = tonumber(Defenders.count) or 0
			F_reserved_A = tonumber(Attackers.reservations) or 0
			F_reserved_D = tonumber(Defenders.reservations) or 0
			F_wait_A = tonumber(Attackers.queued) or 0
			F_wait_D = tonumber(Defenders.queued) or 0

			WindowSetShowing( "SoR_"..Window_Name.."_TIMER",true)
			WindowSetShowing( "SoR_"..Window_Name.."_HEALTH",true)
			WindowSetShowing( "SoR_"..Window_Name.."_HEALTH_BG",true)
			--WindowSetShowing( "SoR_"..Window_Name.."KEEP1LORD_ICON",true)
			WindowSetShowing( "SoR_"..Window_Name.."KEEP1KEEPDOOR1",false)
			LabelSetText("SoR_"..Window_Name.."_HEALTH",towstring(Input.lordPctHealth)..L"%")
			LabelSetText("SoR_"..Window_Name.."_HEALTH_BG",towstring(Input.lordPctHealth)..L"%")
			RoR_SoR.Timers[Window_Name][1] = F_Timer
			RoR_SoR.Fort[Window_Name].Health = towstring(Input.lordPctHealth)..L"%"
			RoR_SoR.Fort[Window_Name].Stage = 3

			DynamicImageSetTexture("SoR_"..Window_Name.."LORDBanner",RoR_SoR.FortLord[RoR_SoR.Forts[tonumber(Window_Name)]],256,48)

			local	RealmColor = RoR_SoR.RealmColors[RoR_SoR.Forts[tonumber(Window_Name)]+1]
			StatusBarSetMaximumValue("SoR_"..Window_Name.."LORDLEFTBAR",100)
			StatusBarSetForegroundTint("SoR_"..Window_Name.."LORDLEFTBAR",RealmColor.r,RealmColor.g,RealmColor.b)
			StatusBarSetCurrentValue("SoR_"..Window_Name.."LORDLEFTBAR", tonumber(Input.lordPctHealth) )

			StatusBarSetMaximumValue("SoR_"..Window_Name.."LORDRIGHTBAR",100)
			StatusBarSetForegroundTint("SoR_"..Window_Name.."LORDRIGHTBAR",RealmColor.r,RealmColor.g,RealmColor.b)
			StatusBarSetCurrentValue("SoR_"..Window_Name.."LORDRIGHTBAR", tonumber(Input.lordPctHealth) )


			for i=1,5 do
				WindowSetShowing( "SoR_"..Window_Name.."BO"..i,false)
				WindowSetShowing( "SoR_"..Window_Name.."BO"..i,false)
			end

		end
		RoR_SoR.ZoneTimer[Window_Name] = ZoneLockTimer

		local Attck_Color = RoR_SoR.RealmColors[4-RoR_SoR.Forts[tonumber(Window_Name)]]
		local Defend_Color = RoR_SoR.RealmColors[RoR_SoR.Forts[tonumber(Window_Name)]+1]

		LabelSetText("SoR_"..Window_Name.."POP_INFO_ATTACK_Label_Attack",towstring(F_attackers+F_reserved_A))
		LabelSetText("SoR_"..Window_Name.."POP_INFO_ATTACK_Label_AttackBG",towstring(LabelGetText("SoR_"..Window_Name.."POP_INFO_ATTACK_Label_Attack")))
		LabelSetText("SoR_"..Window_Name.."POP_INFO_ATTACK_Label_Defend",towstring(F_defenders+F_reserved_D))
		LabelSetText("SoR_"..Window_Name.."POP_INFO_ATTACK_Label_DefendBG",towstring(LabelGetText("SoR_"..Window_Name.."POP_INFO_ATTACK_Label_Defend")))
		LabelSetTextColor("SoR_"..Window_Name.."POP_INFO_ATTACK_Label_Attack",Attck_Color.r,Attck_Color.g,Attck_Color.b)
		LabelSetTextColor("SoR_"..Window_Name.."POP_INFO_ATTACK_Label_Defend",Defend_Color.r,Defend_Color.g,Defend_Color.b)

		LabelSetText("SoR_"..Window_Name.."POP_INFO_WAIT_Label_Attack",towstring(F_wait_A))
		LabelSetText("SoR_"..Window_Name.."POP_INFO_WAIT_Label_AttackBG",towstring(LabelGetText("SoR_"..Window_Name.."POP_INFO_WAIT_Label_Attack")))
		LabelSetText("SoR_"..Window_Name.."POP_INFO_WAIT_Label_Defend",towstring(F_wait_D))
		LabelSetText("SoR_"..Window_Name.."POP_INFO_WAIT_Label_DefendBG",towstring(LabelGetText("SoR_"..Window_Name.."POP_INFO_WAIT_Label_Defend")))
		LabelSetTextColor("SoR_"..Window_Name.."POP_INFO_WAIT_Label_Attack",Attck_Color.r,Attck_Color.g,Attck_Color.b)
		LabelSetTextColor("SoR_"..Window_Name.."POP_INFO_WAIT_Label_Defend",Defend_Color.r,Defend_Color.g,Defend_Color.b)
		--RoR_SoR.Forts = {[4]=2,[10]=1,[104]=2,[110]=1,[204]=2,[210]=1}

					RoR_SoR.ZoneStatus[Window_Name]	= {}
					RoR_SoR.ZoneStatus[Window_Name].Attackers_Pop = tonumber(F_attackers+F_reserved_A) or 0
					RoR_SoR.ZoneStatus[Window_Name].Defenders_Pop = tonumber(F_defenders+F_reserved_D) or 0
					RoR_SoR.ZoneStatus[Window_Name].A_Wait_Pop = tonumber(F_wait_A) or 0
					RoR_SoR.ZoneStatus[Window_Name].D_Wait_Pop = tonumber(F_wait_D) or 0

	else
	CreateWindowFromTemplate("SoR_"..Window_Name, "RoR_SoR_FortTemplate", "Root")
	RoR_SoR.OpenZones[Window_Name] =  tonumber(5)
	RoR_SoR.Timers[Window_Name] = {}
	RoR_SoR.Fort[Window_Name] = {BO={},Owner={},Stage=0,Health=L""}
	RoR_SoR.SET_FORT(Input)
	end
	RoR_SoR.Restack()
end




local function CompareEntry(entryA, entryB)
	return (entryA.Tier > entryB.Tier)
end

function  RoR_SoR.Restack()
		RoR_Window_Scale = (tonumber(WindowGetScale("RoR_SoR_Main_Window")))
		WindowSetScale("RoR_SoR_Popper",RoR_Window_Scale)
		local uiScale = InterfaceCore.GetScale()
		local ResolutionScale = InterfaceCore.GetResolutionScale()
		local Inteface_Scale = SystemData.Settings.Interface.globalUiScale
		RoR_SoR.StackSort = {};

		for k,v in pairs(RoR_SoR.OpenZones) do
		WindowSetScale("SoR_"..k,WindowGetScale("RoR_SoR_Main_Window"))
			table.insert(RoR_SoR.StackSort,{Zone=k,Tier=v})
			table.sort(RoR_SoR.StackSort, CompareEntry)
		end

		local TotalHeight = 0
		for k,v in ipairs(RoR_SoR.StackSort) do
		local width,height = WindowGetDimensions( "SoR_"..v.Zone)
		local WndScale = WindowGetScale("SoR_"..v.Zone)
		width = width*WndScale
		height = ((height+RoR_SoR.Settings.Offset)*WndScale)/Inteface_Scale
		TotalHeight = TotalHeight + height
			WindowClearAnchors( "SoR_"..v.Zone )
			if RoR_SoR.Settings.StackDir == 1 then
			WindowAddAnchor( "SoR_"..v.Zone , "bottom", "RoR_SoR_Main_Window", "top", 0,(0-(height))+(TotalHeight))
			--	WindowAddAnchor( "SoR_"..v.Zone , "bottom", "RoR_SoR_Main_Window", "top", 0,((175*tonumber(k-1))*RoR_Window_Scale)/(uiScale/ResolutionScale/Inteface_Scale))
			elseif  RoR_SoR.Settings.StackDir == 2 then
			WindowAddAnchor( "SoR_"..v.Zone , "top", "RoR_SoR_Main_Window", "bottom", 0,height-(TotalHeight))
			--	WindowAddAnchor( "SoR_"..v.Zone , "top", "RoR_SoR_Main_Window", "bottom", 0,0-((((175*tonumber(k-1)))*RoR_Window_Scale)/(uiScale/ResolutionScale/Inteface_Scale)))
			end
		end

	if RoR_SoR.Settings.Enabled then
		WindowSetTintColor("RoR_SoR_ButtonBtn",255,255,255)
	else
		WindowSetTintColor("RoR_SoR_ButtonBtn",125,125,125)
	end

return
end


function RoR_SoR.SET_BO(Input)
	local Input = Input
	local Window_Name = tostring(Input.zoneId)

	if DoesWindowExist("SoR_"..Window_Name) then
		RoR_SoR.Timers[Window_Name] = {}
		WindowSetScale("SoR_"..Window_Name,WindowGetScale("RoR_SoR_Main_Window"))
		DynamicImageSetTextureSlice("SoR_"..Window_Name.."BG", RoR_SoR.ParingPortrait[RoR_SoR.GetParing(Window_Name)])
		RoR_SoR.ZoneTimer[Window_Name] = ZoneLockTimer
		RoR_SoR.BO_IDs[Window_Name] = {}

		local Num_Bo = 0
		local Lock_Counter = 0

		if Input.zoneId == 100 or Input.zoneId == 106 then Num_Bo = 3; Lock_Counter = 1 else Num_Bo = 4 ; Lock_Counter = 0 end

		RoR_SoR.Restack()

		for i=1,Num_Bo do
			local BO_State = tonumber(Input.objectives[i].state)
			local BO_Owner = tonumber(Input.objectives[i].realm)
			--local BO_State = tonumber(SoR_BO_SPLIT_TEXT_STREAM[1+(4*i)])
			--local BO_Owner = tonumber(SoR_BO_SPLIT_TEXT_STREAM[(4*i)])

			RoR_SoR.BO_IDs[Window_Name][i] = {}
			RoR_SoR.BO_IDs[Window_Name][i].ID = Input.objectives[i].id
			RoR_SoR.BO_IDs[Window_Name][i].Owner = Input.objectives[i].realm


			local RealmColor = nil
			if BO_State == 4 then
				if RoR_SoR.BO_States[Window_Name][i] ~= 4 then
					WindowStartAlphaAnimation( "SoR_"..Window_Name.."BO"..i.."Flag", Window.AnimationType.LOOP, 1.0, 0.2, 0.5, false, 0.0, 0 ) --start the Burning BO pulse
					RoR_SoR.BO_States[Window_Name][i] = 4
				end
				RealmColor = RoR_SoR.CappingRealmColors[BO_Owner+1]
				WindowSetDimensions("SoR_"..Window_Name.."BO"..i.."Flag",31,31)
			else
				RoR_SoR.BO_States[Window_Name][i] = nil
				RealmColor = RoR_SoR.RealmColors[BO_Owner+1]
				WindowStopAlphaAnimation("SoR_"..Window_Name.."BO"..i.."Flag")
			end

			LabelSetTextColor("SoR_"..Window_Name.."BO"..i.."TIMER",RealmColor.r,RealmColor.g,RealmColor.b)

			local OB_Name = L""
			local ShortBOName = L""

		if RoR_SoR.Settings.ShowBONames	then
			if tonumber(RoR_SoR.BO_IDs[Window_Name][i].ID) ~= 0 then
				OB_Name = towstring(GetObjectiveName(tonumber(RoR_SoR.BO_IDs[Window_Name][i].ID)))
				ShortBOName = wstring.match(wstring.gsub(wstring.gsub(wstring.gsub(wstring.gsub(towstring(OB_Name),L" of ", L""), L"%s",L""), L"%l*", L""), L"'", L""), L"([^^]+)^?.*") or L"" --This is for Shortening Guildnames
			end
		end

			LabelSetText("SoR_"..Window_Name.."BO"..i.."TIMER",ShortBOName)
			LabelSetText("SoR_"..Window_Name.."BO"..i.."TIMER_BG",ShortBOName)
			DynamicImageSetTexture( "SoR_"..Window_Name.."BO"..i.."Flag", RoR_SoR.GetFlag(BO_Owner,BO_State),31,31 )
			DynamicImageSetTexture( "SoR_"..Window_Name.."BO"..i.."FlagBG", RoR_SoR.GetFlag2(BO_Owner,BO_State),31,31 )
			RoR_SoR.BO_States[Window_Name][i] = BO_State

			if tonumber(Input.objectives[i].timer) > 0 and tonumber(Input.objectives[i].timer) < 300 then
				RoR_SoR.Timers[Window_Name][i] = tonumber(Input.objectives[i].timer)
			--	LabelSetText("SoR_"..Window_Name.."BO"..i.."TIMER",towstring(SoR_BO_SPLIT_TEXT_STREAM[2+(4*i)]))
			end
			if (BO_State == 6) or (BO_State == 9) then Lock_Counter = Lock_Counter+1 end



		end

		--Zonelock
		if Lock_Counter == 4 then LabelSetText("SoR_"..Window_Name.."LockedText",towstring(GetStringFromTable("Hardcoded", 1268)))end
			WindowSetShowing("SoR_"..Window_Name.."LockTint",(Lock_Counter==4))

		else
			RoR_SoR.Timers[Window_Name] = nil
		end
end

--Hide Keepstuff for T1
function RoR_SoR.T1_UPDATE(Window_Name,Input)
local Window_Name = tostring(Window_Name)
local Input = Input
local AAO = Input.aaoRealm
local Multip = Input.aaoMultiplier
			if AAO > 0 then
			local ClaimColor = RoR_SoR.RealmColors[AAO+1]
			LabelSetTextColor("SoR_"..Window_Name.."AAO",ClaimColor.r,ClaimColor.g,ClaimColor.b)
			LabelSetText("SoR_"..Window_Name.."AAO",towstring(Multip)..L"%")
			LabelSetText("SoR_"..Window_Name.."AAO_BG",towstring(Multip)..L"%")
			WindowSetShowing("SoR_"..Window_Name.."AAO",tonumber(Multip)>0)
			WindowSetShowing("SoR_"..Window_Name.."AAO_BG",tonumber(Multip)>0)
			else
			WindowSetShowing("SoR_"..Window_Name.."AAO",false)
			WindowSetShowing("SoR_"..Window_Name.."AAO_BG",false)
			end


	if DoesWindowExist("SoR_"..Window_Name) then


		WindowClearAnchors("SoR_"..Window_Name.."Banner")
		WindowAddAnchor("SoR_"..Window_Name.."Banner","top", "SoR_"..Window_Name, "top", 0,RoR_SoR.GetBanner())

		WindowSetShowing("SoR_"..Window_Name.."KEEP1",false)
		WindowSetShowing("SoR_"..Window_Name.."KEEP2",false)
		WindowSetShowing("SoR_"..Window_Name.."CLAIM_WINDOW1",false)
		WindowSetShowing("SoR_"..Window_Name.."CLAIM_WINDOW2",false)
		WindowSetShowing("SoR_"..Window_Name.."POP",true)
		RoR_SoR.ZoneTimer[Window_Name] = ZoneLockTimer




	local Order_Pop
	local Destro_Pop

			if RoR_SoR.Settings.AAONumbers == true then
				Order_Pop = PopConvert[tostring(Input.orderPopulation)] or Input.orderPopulation
				Destro_Pop = PopConvert[tostring(Input.destructionPopulation)] or Input.destructionPopulation
			else
				Order_Pop = Input.orderPopulation
				Destro_Pop = Input.destructionPopulation
			end

		RoR_SoR.ZoneStatus[Window_Name]	= {}
		RoR_SoR.ZoneStatus[Window_Name].Order_Pop = Order_Pop
		RoR_SoR.ZoneStatus[Window_Name].Destro_Pop = Destro_Pop
		RoR_SoR.ZoneStatus[Window_Name].AAO = Input.aaoRealm
		RoR_SoR.ZoneStatus[Window_Name].AAOMulti = Input.aaoMultiplier
		RoR_SoR.ZoneStatus[Window_Name].Tier = 1


				LabelSetText("SoR_"..Window_Name.."POPOrder",towstring(Order_Pop))
				LabelSetText("SoR_"..Window_Name.."POPOrder_BG",towstring(Order_Pop))
				LabelSetText("SoR_"..Window_Name.."POPDestro",towstring(Destro_Pop))
				LabelSetText("SoR_"..Window_Name.."POPDestro_BG",towstring(Destro_Pop))



	local ZoneVP
		if Window_Name == "106" or Window_Name == "100" then
			WindowSetShowing("SoR_"..Window_Name.."BO4",false) -- Hide the 4:th BO of Nordland
			DynamicImageSetTexture ("SoR_"..Window_Name.."VPBanner", "Realm2", 296,128)
			ZoneVP = GetCampaignZoneData(106 )
		elseif Window_Name == "206" or Window_Name == "200" then
			DynamicImageSetTexture ("SoR_"..Window_Name.."VPBanner", "Realm3", 296,128)
			ZoneVP = GetCampaignZoneData(200 )
		else
			DynamicImageSetTexture ("SoR_"..Window_Name.."VPBanner", "Realm1", 296,128)
			ZoneVP = GetCampaignZoneData(6 )
		end
--Update the "progressbars" in the zone pairings
--local Width_Zone1_Order = ( ( ZoneVP.controlPoints[1] / 100 ) * 147 )
--WindowSetDimensions( "SoR_"..Window_Name.."VPORDER", Width_Zone1_Order+2, 4 )
			StatusBarSetMaximumValue("SoR_"..Window_Name.."VPORDERBAR",100)
			StatusBarSetForegroundTint("SoR_"..Window_Name.."VPORDERBAR",RoR_SoR.RealmColors[2].r,RoR_SoR.RealmColors[2].g,RoR_SoR.RealmColors[2].b)
			StatusBarSetCurrentValue("SoR_"..Window_Name.."VPORDERBAR", tonumber(ZoneVP.controlPoints[1]))


--local Width_Zone1_Destro = ( ( ZoneVP.controlPoints[2] / 100 ) * 147 )
--WindowSetDimensions( "SoR_"..Window_Name.."VPDESTRO", Width_Zone1_Destro+2, 4 )
			StatusBarSetMaximumValue("SoR_"..Window_Name.."VPDESTROBAR",100)
			StatusBarSetForegroundTint("SoR_"..Window_Name.."VPDESTROBAR",RoR_SoR.RealmColors[3].r,RoR_SoR.RealmColors[3].g,RoR_SoR.RealmColors[3].b)
			StatusBarSetCurrentValue("SoR_"..Window_Name.."VPDESTROBAR", tonumber(ZoneVP.controlPoints[2]))

		LabelSetText("SoR_"..Window_Name.."VPPERCENT_ORDER",towstring((ZoneVP.controlPoints[1])*2)..L"%")
		LabelSetText("SoR_"..Window_Name.."VPPERCENT_ORDER_BG",towstring((ZoneVP.controlPoints[1])*2)..L"%")

		LabelSetText("SoR_"..Window_Name.."VPPERCENT_DESTRO",towstring((ZoneVP.controlPoints[2])*2)..L"%")
		LabelSetText("SoR_"..Window_Name.."VPPERCENT_DESTRO_BG",towstring((ZoneVP.controlPoints[2])*2)..L"%")

	end
end

function RoR_SoR.SET_KEEP(Input)
local Input = Input
--	local SoR_KEEP_SPLIT_TEXT_STREAM = Input
--	local Window_Name = tostring(SoR_KEEP_SPLIT_TEXT_STREAM[2])
local Window_Name = tostring(Input.zoneId)
			if (Input.tier == 4) and (RoR_SoR.Settings.ShowT4 == true) then

					if (not DoesWindowExist("SoR_"..Window_Name)) then
							CreateWindowFromTemplate("SoR_"..Window_Name, "RoR_SoR_RealmTemplate", "Root")
							RoR_SoR.BO_States[Window_Name] = {}
							RoR_SoR.KEEP_States[Window_Name] = {}
							RoR_SoR.KeepHealth[Window_Name] = {[1]=0,[2]=0}
							local ZoneData = GetCampaignZoneData(tonumber(Window_Name))
							RoR_SoR.OpenZones[Window_Name] =  tonumber(ZoneData.tierId)
						LabelSetText("SoR_"..Window_Name.."_BannerLabel",towstring(GetZoneName(tonumber(Window_Name))))
						LabelSetText("SoR_"..Window_Name.."_BannerLabel_BG",towstring(GetZoneName(tonumber(Window_Name))))
						LabelSetTextColor("SoR_"..Window_Name.."_BannerLabel",255,255,255)
						local BannerW,_ = LabelGetTextDimensions("SoR_"..Window_Name.."_BannerLabel")
						WindowSetDimensions( "SoR_"..Window_Name.."BannerMid", BannerW, 40 )
					end
					RoR_SoR.SET_BO(Input)
			elseif((Input.tier == 2) or (Input.tier == 3)) and (RoR_SoR.Settings.ShowT4 == true) then --Setup Tier 2 and 3 BO zone stuff
				--if Input.zoneId == RoR_SoR.ZoneNames[Input.zoneId][1] then return end	--Ugly fix for dublettes
				if (not DoesWindowExist("SoR_"..Window_Name)) then
					CreateWindowFromTemplate("SoR_"..Window_Name, "RoR_SoR_RealmTemplate", "Root")
					RoR_SoR.BO_States[Window_Name] = {}
					local ZoneData = GetCampaignZoneData(tonumber(Window_Name))
					RoR_SoR.OpenZones[Window_Name] =  tonumber(ZoneData.tierId)
					RoR_SoR.KEEP_States[Window_Name] = {}
					LabelSetText("SoR_"..Window_Name.."_BannerLabel",towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][1]))..L" � "..towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][2])))
					LabelSetText("SoR_"..Window_Name.."_BannerLabel_BG",towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][1]))..L" � "..towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][2])))
					LabelSetTextColor("SoR_"..Window_Name.."_BannerLabel",255,255,255)
					local BannerW,_ = LabelGetTextDimensions("SoR_"..Window_Name.."_BannerLabel")
					WindowSetDimensions( "SoR_"..Window_Name.."BannerMid", BannerW, 40 )
				end
				RoR_SoR.SET_BO(Input)
			elseif	(Input.tier == 1) and (RoR_SoR.Settings.ShowT1 == true) then
				--if Input.zoneId == RoR_SoR.ZoneNames[Input.zoneId][1] then return end	--Ugly fix for dublettes
				if (not DoesWindowExist("SoR_"..Window_Name)) then
					CreateWindowFromTemplate("SoR_"..Window_Name, "RoR_SoR_RealmTemplate", "Root")
					RoR_SoR.BO_States[Window_Name] = {}
					local ZoneData = GetCampaignZoneData(tonumber(Window_Name))
					RoR_SoR.OpenZones[Window_Name] =  tonumber(ZoneData.tierId)
					LabelSetText("SoR_"..Window_Name.."_BannerLabel",towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][1]))..L" � "..towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][2])))
					LabelSetText("SoR_"..Window_Name.."_BannerLabel_BG",towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][1]))..L" � "..towstring(GetZoneName(RoR_SoR.ZoneNames[tonumber(Window_Name)][2])))
					LabelSetTextColor("SoR_"..Window_Name.."_BannerLabel",255,255,255)
					local BannerW,_ = LabelGetTextDimensions("SoR_"..Window_Name.."_BannerLabel")
					WindowSetDimensions( "SoR_"..Window_Name.."BannerMid", BannerW, 40 )
				end
				RoR_SoR.T1_UPDATE(Window_Name,Input)
				RoR_SoR.SET_BO(Input)
				return
			end


--check if Fort Data:
	if RoR_SoR.Forts[tonumber(Input.zoneId)] ~= nil then
		if DoesWindowExist("SoR_"..Window_Name) then
		local F_ZoneID = Input.zoneId
		local F_AAOMULTI = Input.aaoMultiplier
		local F_AAO = Input.aaoRealm
		local F_Order_Pop = Input.orderPopulation
		local F_Destro_Pop = Input.destructionPopulation

		LabelSetText("SoR_"..Window_Name.."POPAAO",towstring(F_AAOMULTI)..L"%")
		LabelSetText("SoR_"..Window_Name.."POPAAO_BG",towstring(F_AAOMULTI)..L"%")

		LabelSetText("SoR_"..Window_Name.."POPOrder",towstring(F_Order_Pop))
		LabelSetText("SoR_"..Window_Name.."POPOrder_BG",towstring(F_Order_Pop))

		LabelSetText("SoR_"..Window_Name.."POPDestro",towstring(F_Destro_Pop))
		LabelSetText("SoR_"..Window_Name.."POPDestro_BG",towstring(F_Destro_Pop))

			local ClaimColor = RoR_SoR.RealmColors[F_AAO+1]
			LabelSetTextColor("SoR_"..Window_Name.."POPAAO",ClaimColor.r,ClaimColor.g,ClaimColor.b)

		WindowSetShowing("SoR_"..Window_Name.."POPAAO",tonumber(F_AAOMULTI)>0)
		WindowSetShowing("SoR_"..Window_Name.."POPAAO_BG",tonumber(F_AAOMULTI)>0)

				RoR_SoR.ZoneStatus[Window_Name]	= {}
					RoR_SoR.ZoneStatus[Window_Name].Order_Pop = tonumber(F_Order_Pop) or 0
					RoR_SoR.ZoneStatus[Window_Name].Destro_Pop = tonumber(F_Destro_Pop) or 0
					RoR_SoR.ZoneStatus[Window_Name].AAO = F_AAOMULTI
					RoR_SoR.ZoneStatus[Window_Name].Tier = 4
		end



	else
	--check if Keep data:
		if DoesWindowExist("SoR_"..Window_Name) then
				if not RoR_SoR.KeepHealth[Window_Name] then RoR_SoR.KeepHealth[Window_Name] = {[1]=0,[2]=0} end

				local Zone = tonumber(Input.zoneId)
				local KEEP1_ID = tonumber(Input.keeps[1].id)
				local KEEP2_ID = tonumber(Input.keeps[2].id)
				local KEEP1_State = tonumber(Input.keeps[1].status)
				local KEEP1_SafeTimer = tonumber(Input.keeps[1].safeTimer)
				local KEEP1_Owner = tonumber(Input.keeps[1].realm)
				local KEEP2_State = tonumber(Input.keeps[2].status)
				local KEEP2_SafeTimer = tonumber(Input.keeps[2].safeTimer)
				local KEEP2_Owner = tonumber(Input.keeps[2].realm)

				local KEEP1_Door1 = tonumber(Input.keeps[1].innerPercentage)
				local KEEP1_Door2 = tonumber(Input.keeps[1].outerPercentage)
				local KEEP1_Lord = tonumber(Input.keeps[1].keepLordPercentage)

				local KEEP2_Door1 = tonumber(Input.keeps[2].innerPercentage)
				local KEEP2_Door2 = tonumber(Input.keeps[2].outerPercentage)
				local KEEP2_Lord = tonumber(Input.keeps[2].keepLordPercentage)

				local KEEP1_CLAIM = Input.keeps[1].claimedByGuild
				local KEEP2_CLAIM = Input.keeps[2].claimedByGuild

				if type(KEEP1_CLAIM) == "table" then KEEP1_CLAIM = "0" else KEEP1_CLAIM = Input.keeps[1].claimedByGuild end
				if type(KEEP2_CLAIM) == "table" then KEEP2_CLAIM = "0" else KEEP2_CLAIM = Input.keeps[2].claimedByGuild end

				local KEEP1_Rank = tonumber(Input.keeps[1].rank)
				local KEEP2_Rank = tonumber(Input.keeps[2].rank)

				local KEEP1_Progress = tonumber(Input.keeps[1].currentResourcePercent)
				local KEEP2_Progress = tonumber(Input.keeps[2].currentResourcePercent)

				local InvolvedGuilds = Input.guilds

	--Door %

			SiegeWeaponGolfFireWindow.KeepInfo[Zone] = {}

			SiegeWeaponGolfFireWindow.KeepInfo[Zone][KEEP2_Owner] = {[KEEP_STATE_OUTER]=KEEP1_Door2,[KEEP_STATE_INNER]=KEEP1_Door1,[KEEP_STATE_LORD]=KEEP1_Lord}
			SiegeWeaponGolfFireWindow.KeepInfo[Zone][KEEP2_Owner].State = KEEP1_State
			SiegeWeaponGolfFireWindow.KeepInfo[Zone][KEEP1_Owner] = {[KEEP_STATE_OUTER]=KEEP2_Door2,[KEEP_STATE_INNER]=KEEP2_Door1,[KEEP_STATE_LORD]=KEEP2_Lord}
			SiegeWeaponGolfFireWindow.KeepInfo[Zone][KEEP1_Owner].State = KEEP2_State


				WindowClearAnchors("SoR_"..Window_Name.."Banner")
				WindowAddAnchor("SoR_"..Window_Name.."Banner","top", "SoR_"..Window_Name, "top", 0,RoR_SoR.GetBanner())

				WindowSetTintColor("SoR_"..Window_Name.."Background2Background2",175,175,175)


				if not RoR_SoR.KeepProgress[1][Window_Name] then RoR_SoR.KeepProgress[1][Window_Name] = 0 end
				if not RoR_SoR.KeepProgress[2][Window_Name] then RoR_SoR.KeepProgress[2][Window_Name] = 0 end



				if KEEP1_Progress ~= nil then
					WindowSetShowing("SoR_"..Window_Name.."KEEP1PROGRESS",true)
					WindowSetShowing("SoR_"..Window_Name.."KEEP1PROGRESSBAR",(tonumber(KEEP1_Progress) > 0))

					if  tonumber(RoR_SoR.KeepProgress[1][Window_Name]) < (tonumber(KEEP1_Progress)) then
						WindowStartAlphaAnimation("SoR_"..Window_Name.."KEEP1PROGRESSBLINK", 1, 1.0, 0.0, 1.5, true, 0.0, 0 ) --start the Door2 pulse
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP1PROGRESS")
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"+"..towstring(tonumber(KEEP1_Progress)-tonumber(RoR_SoR.KeepProgress[1][Window_Name])))
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"+"..towstring(tonumber(KEEP1_Progress)-tonumber(RoR_SoR.KeepProgress[1][Window_Name])))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
					end

					local BarWidth,BarHeight = WindowGetDimensions( "SoR_"..Window_Name.."KEEP1PROGRESS")
					local TotalSize = BarWidth / 100
					WindowSetDimensions( "SoR_"..Window_Name.."KEEP1PROGRESSBAR", math.abs(tonumber(KEEP1_Progress)*TotalSize), BarHeight )
					RoR_SoR.KeepProgress[1][Window_Name] = KEEP1_Progress
				else
					WindowSetShowing("SoR_"..Window_Name.."KEEP1PROGRESS",false)
				end

				if KEEP2_Progress ~= nil then
					WindowSetShowing("SoR_"..Window_Name.."KEEP2PROGRESS",true)
					WindowSetShowing("SoR_"..Window_Name.."KEEP2PROGRESSBAR",(tonumber(KEEP2_Progress) > 0))


					if  tonumber(RoR_SoR.KeepProgress[2][Window_Name]) < (tonumber(KEEP2_Progress)) then
						WindowStartAlphaAnimation("SoR_"..Window_Name.."KEEP2PROGRESSBLINK", 1, 1.0, 0.0, 1.5, true, 0.0, 0 ) --start the Door2 pulse
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP2PROGRESS")
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"+"..towstring(tonumber(KEEP2_Progress)-tonumber(RoR_SoR.KeepProgress[2][Window_Name])))
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"+"..towstring(tonumber(KEEP2_Progress)-tonumber(RoR_SoR.KeepProgress[2][Window_Name])))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
					end

					local BarWidth,BarHeight = WindowGetDimensions( "SoR_"..Window_Name.."KEEP2PROGRESS")
					local TotalSize = BarWidth / 100
					WindowSetDimensions( "SoR_"..Window_Name.."KEEP2PROGRESSBAR",math.abs(tonumber(KEEP2_Progress)*TotalSize), BarHeight )
					RoR_SoR.KeepProgress[2][Window_Name] = KEEP2_Progress
				else
					WindowSetShowing("SoR_"..Window_Name.."KEEP2PROGRESS",false)
				end



--Safe Timer
			--	local KEEP1_Special = StringSplit(tostring(KEEP1_Extra), ",")
			--	local KEEP2_Special = StringSplit(tostring(KEEP2_Extra), ",")
                local KEEP1_Special = tonumber(KEEP1_SafeTimer)
                local KEEP2_Special = tonumber(KEEP2_SafeTimer)

                if KEEP1_Special > 0 then LabelSetText("SoR_"..Window_Name.."KEEP1SAFETIMER",TimeUtils.FormatTimeCondensed(KEEP1_Special));LabelSetText("SoR_"..Window_Name.."KEEP1SAFETIMERBG",LabelGetText("SoR_"..Window_Name.."KEEP1SAFETIMER")) end
                if KEEP2_Special > 0 then LabelSetText("SoR_"..Window_Name.."KEEP2SAFETIMER",TimeUtils.FormatTimeCondensed(KEEP2_Special));LabelSetText("SoR_"..Window_Name.."KEEP2SAFETIMERBG",LabelGetText("SoR_"..Window_Name.."KEEP2SAFETIMER")) end

                RoR_SoR.SafeKeep[Window_Name] = {[1]=KEEP1_Special,[2]=KEEP2_Special}

                WindowSetShowing("SoR_"..Window_Name.."KEEP1SAFE",KEEP1_Special > 0)
                WindowSetShowing("SoR_"..Window_Name.."KEEP2SAFE",KEEP2_Special > 0)

				local perc1 = KEEP1_Special/60
				local perc2 = KEEP2_Special/60
					local FillStart = 90
					local FillEnd = 360
					--local startFill = 280 * (1 - (MoralePerC / GetMoralePercentForLevel(q)))
					CircleImageSetFillParams("SoR_"..Window_Name.."KEEP1SAFECircle", FillStart,   FillEnd-(perc1 * 36))
					CircleImageSetFillParams("SoR_"..Window_Name.."KEEP2SAFECircle", FillStart,   FillEnd-(perc2 * 36))

		---


		RoR_SoR.KEEP_IDs[Window_Name] = {
			[1]={
				ID=KEEP1_ID,
				Owner=KEEP1_Owner,
				Rank=KEEP1_Rank,
				State=KEEP1_State,
				Claim=KEEP1_CLAIM,
				Supply=KEEP1_Progress
			},
			[2]={
				ID=KEEP2_ID,
				Owner=KEEP2_Owner,
				Rank=KEEP2_Rank,
				State=KEEP2_State,
				Claim=KEEP2_CLAIM,
				Supply=KEEP2_Progress
			}
		}
				RoR_SoR.KeepStatus[Window_Name] = {[1]=L"",[2]=L""}
				RoR_SoR.ZoneStatus[Window_Name]	= {}

	--involved guilds:
	if type(InvolvedGuilds) == "table" and #InvolvedGuilds > 0 then
	RoR_SoR.InvolvedGuilds[Window_Name] = {}
		for k,v in pairs(InvolvedGuilds) do
			table.insert(RoR_SoR.InvolvedGuilds[Window_Name],v)
		end
	else
	RoR_SoR.InvolvedGuilds[Window_Name] = nil
	end

	--Claim button and text
			local Claimed_Keep_1 = RoR_SoR.GetKeepClaim2(KEEP1_ID)
			local Claimed_Keep_2 = RoR_SoR.GetKeepClaim2(KEEP2_ID)

			local Can_Claim = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.CLAIM_KEEP, GuildWindowTabAdmin.GetLocalMemberTitleNumber())
			local Guild_Name = towstring(GameData.Guild.m_GuildName) or L""
			local Claimed_Keep_1_Name = ((towstring(KEEP1_CLAIM) == Guild_Name) and Can_Claim) or false
			local Claimed_Keep_2_Name = ((towstring(KEEP2_CLAIM) == Guild_Name) and Can_Claim) or false

			WindowSetShowing("SoR_"..Window_Name.."CLAIM_WINDOW1BUTTON",Claimed_Keep_1)
			WindowSetShowing("SoR_"..Window_Name.."CLAIM_WINDOW2BUTTON",Claimed_Keep_2)
			WindowSetShowing("SoR_"..Window_Name.."CLAIM_WINDOW1TEXT",not Claimed_Keep_1 and not Claimed_Keep_1_Name)
			WindowSetShowing("SoR_"..Window_Name.."CLAIM_WINDOW2TEXT",not Claimed_Keep_2 and not Claimed_Keep_2_Name)
			WindowSetShowing("SoR_"..Window_Name.."CLAIM_WINDOW1TEXT_BG",not Claimed_Keep_1 and not Claimed_Keep_1_Name)
			WindowSetShowing("SoR_"..Window_Name.."CLAIM_WINDOW2TEXT_BG",not Claimed_Keep_2 and not Claimed_Keep_2_Name)

			WindowSetShowing("SoR_"..Window_Name.."CLAIM_WINDOW1BUTTON2",Claimed_Keep_1_Name)
			WindowSetShowing("SoR_"..Window_Name.."CLAIM_WINDOW2BUTTON2",Claimed_Keep_2_Name)


			ButtonSetText("SoR_"..Window_Name.."CLAIM_WINDOW1BUTTON",L"[CLAIM KEEP]")
			ButtonSetText("SoR_"..Window_Name.."CLAIM_WINDOW2BUTTON",L"[CLAIM KEEP]")

			WindowSetId("SoR_"..Window_Name.."CLAIM_WINDOW1BUTTON2",KEEP1_ID)
			WindowSetId("SoR_"..Window_Name.."CLAIM_WINDOW2BUTTON2",KEEP2_ID)

			ButtonSetText("SoR_"..Window_Name.."CLAIM_WINDOW1BUTTON2",L"[RELEASE KEEP]")
			ButtonSetText("SoR_"..Window_Name.."CLAIM_WINDOW2BUTTON2",L"[RELEASE KEEP]")


--GameData.Guild.m_GuildName

	--Calculate and show AAO and Population
	local Order_Pop
	local Destro_Pop

if RoR_SoR.Settings.AAONumbers == true then
	Order_Pop = PopConvert[tostring(Input.orderPopulation)] or Input.orderPopulation
	Destro_Pop = PopConvert[tostring(Input.destructionPopulation)] or Input.destructionPopulation
else
	Order_Pop = Input.orderPopulation
	Destro_Pop = Input.destructionPopulation
end


					RoR_SoR.ZoneStatus[Window_Name].Order_Pop = Order_Pop
					RoR_SoR.ZoneStatus[Window_Name].Destro_Pop = Destro_Pop

					RoR_SoR.ZoneStatus[Window_Name].AAO = Input.aaoRealm
					RoR_SoR.ZoneStatus[Window_Name].AAOMulti = Input.aaoMultiplier
					RoR_SoR.ZoneStatus[Window_Name].Tier = Input.tier

				for k,v in pairs(RoR_SoR.TierNames[4]) do
					if tostring(v) == tostring(Window_Name) then

					if RoR_SoR.Settings.AAONumbers == true then
							Order_Pop = PopConvert[tostring(Input.orderPopulation)] or Input.orderPopulation
							Destro_Pop = PopConvert[tostring(Input.destructionPopulation)] or Input.destructionPopulation
					else
							Order_Pop = Input.orderPopulation
							Destro_Pop = Input.destructionPopulation
					end

						--RoR_SoR.ZoneStatus[Window_Name].AAO = StringSplit(tostring(SoR_KEEP_SPLIT_TEXT_STREAM[22]), ",")

						RoR_SoR.ZoneStatus[Window_Name].Order_Pop = Order_Pop
						RoR_SoR.ZoneStatus[Window_Name].Destro_Pop = Destro_Pop


						break
					end
				end

				if RoR_SoR.ZoneStatus[Window_Name].AAO ~= 0 then
				local ClaimColor = RoR_SoR.RealmColors[RoR_SoR.ZoneStatus[Window_Name].AAO+1]
				LabelSetTextColor("SoR_"..Window_Name.."AAO",ClaimColor.r,ClaimColor.g,ClaimColor.b)
				LabelSetText("SoR_"..Window_Name.."AAO",towstring(RoR_SoR.ZoneStatus[Window_Name].AAOMulti)..L"%")
				LabelSetText("SoR_"..Window_Name.."AAO_BG",towstring(RoR_SoR.ZoneStatus[Window_Name].AAOMulti)..L"%")
				WindowSetShowing("SoR_"..Window_Name.."AAO",tonumber(RoR_SoR.ZoneStatus[Window_Name].AAOMulti)>0) -- Hide T1 Stuff
				WindowSetShowing("SoR_"..Window_Name.."AAO_BG",tonumber(RoR_SoR.ZoneStatus[Window_Name].AAOMulti)>0) -- Hide T1 Stuff
				else
				WindowSetShowing("SoR_"..Window_Name.."AAO",false) -- Hide T1 Stuff
				WindowSetShowing("SoR_"..Window_Name.."AAO_BG",false) -- Hide T1 Stuff
				end





				WindowSetShowing("SoR_"..Window_Name.."VP",false) -- Hide T1 Stuff
				WindowSetShowing("SoR_"..Window_Name.."CLAIM_WINDOW1TEXTPROXY",false)
				WindowSetShowing("SoR_"..Window_Name.."CLAIM_WINDOW2TEXTPROXY",false)
				DynamicImageSetTexture( "SoR_"..Window_Name.."KEEP1KEEPICON", RoR_SoR.GetKeepTexture(KEEP1_Owner,KEEP1_State),42,42 )
				DynamicImageSetTexture( "SoR_"..Window_Name.."KEEP2KEEPICON", RoR_SoR.GetKeepTexture(KEEP2_Owner,KEEP2_State),42,42 )

				DynamicImageSetTexture( "SoR_"..Window_Name.."KEEP1LORD_ICON", RoR_SoR.KeepLord[KEEP1_Owner],22,22 )
				DynamicImageSetTexture( "SoR_"..Window_Name.."KEEP2LORD_ICON", RoR_SoR.KeepLord[KEEP2_Owner],22,22 )
	--			DynamicImageSetTextureSlice( "SoR_"..Window_Name.."KEEP1LORD_ICON", RoR_SoR.KeepLord[KEEP1_Owner] )
	--			DynamicImageSetTextureSlice( "SoR_"..Window_Name.."KEEP2LORD_ICON", RoR_SoR.KeepLord[KEEP2_Owner] )

				LabelSetText("SoR_"..Window_Name.."POPOrder",towstring(RoR_SoR.ZoneStatus[Window_Name].Order_Pop))
				LabelSetText("SoR_"..Window_Name.."POPOrder_BG",towstring(RoR_SoR.ZoneStatus[Window_Name].Order_Pop))
				LabelSetText("SoR_"..Window_Name.."POPDestro",towstring(RoR_SoR.ZoneStatus[Window_Name].Destro_Pop))
				LabelSetText("SoR_"..Window_Name.."POPDestro_BG",towstring(RoR_SoR.ZoneStatus[Window_Name].Destro_Pop))
	--Check if keeps are claimed and do the keep branding





	if type(KEEP1_CLAIM) == "string" and KEEP1_CLAIM ~= "0" then
	local ClaimColor = RoR_SoR.RealmColors[KEEP1_Owner+1]
	LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW1TEXTPROXY",L"<"..towstring(KEEP1_CLAIM)..L">")
	local Width,Height = LabelGetTextDimensions("SoR_"..Window_Name.."CLAIM_WINDOW1TEXTPROXY")
	if Width < 110 then
	LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW1TEXT",L"<"..towstring(KEEP1_CLAIM)..L">")
	LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW1TEXT_BG",L"<"..towstring(KEEP1_CLAIM)..L">")
	else

	local ShortGName = towstring(title_case(KEEP1_CLAIM))
	ShortGName = wstring.gsub(ShortGName, L" of ", L"O")
	ShortGName = wstring.gsub(ShortGName, L"%s", L"")
	ShortGName = wstring.gsub(ShortGName, L"%l*", L"")
	ShortGName = towstring(wstring.match(towstring(ShortGName), L"([^^]+)^?.*"))
	--local ShortGName = wstring.match(wstring.gsub(wstring.gsub(wstring.gsub(towstring(KEEP1_CLAIM),L" of ", L"O"), L"%s",L""), L"%l*", L""), L"([^^]+)^?.*")  --This is for Shortening Guildnames
	LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW1TEXT",L"<"..towstring(ShortGName)..L">")
	LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW1TEXT_BG",L"<"..towstring(ShortGName)..L">")
	end

	LabelSetTextColor("SoR_"..Window_Name.."CLAIM_WINDOW1TEXT",ClaimColor.r,ClaimColor.g,ClaimColor.b)
	WindowSetShowing("SoR_"..Window_Name.."KEEP1KEEPGLOW",true)
	else
	local ClaimColor = RoR_SoR.RealmColors[1]

	if RoR_SoR.Settings.ShowUnclaimed then
		local Keep_Name = L""

		if RoR_SoR.Settings.ShowBONames then
			Keep_Name = towstring(GetKeepName(tonumber(KEEP1_ID)))
		else
			Keep_Name = L"UnClaimed"
		end

		LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW1TEXT",Keep_Name) --unclaimed
		LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW1TEXT_BG",Keep_Name) --unclaimed
	else
		LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW1TEXT",L"") --unclaimed
		LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW1TEXT_BG",L"") --unclaimed
	end

	LabelSetTextColor("SoR_"..Window_Name.."CLAIM_WINDOW1TEXT",ClaimColor.r,ClaimColor.g,ClaimColor.b)
	WindowSetShowing("SoR_"..Window_Name.."KEEP1KEEPGLOW",false)
	end



	if type(KEEP2_CLAIM) == "string" and KEEP2_CLAIM ~= "0" then
	local ClaimColor = RoR_SoR.RealmColors[KEEP2_Owner+1]
	LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW2TEXTPROXY",L"<"..towstring(KEEP2_CLAIM)..L">")
	local Width,Height = LabelGetTextDimensions("SoR_"..Window_Name.."CLAIM_WINDOW2TEXTPROXY")
	if Width < 110 then
	LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW2TEXT",L"<"..towstring(KEEP2_CLAIM)..L">")
	LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW2TEXT_BG",L"<"..towstring(KEEP2_CLAIM)..L">")
	else
	local ShortGName = towstring(title_case(KEEP2_CLAIM))
	ShortGName = wstring.gsub(ShortGName, L" of ", L"O")
	ShortGName = wstring.gsub(ShortGName, L"%s", L"")
	ShortGName = wstring.gsub(ShortGName, L"%l*", L"")
	ShortGName = towstring(wstring.match(towstring(ShortGName), L"([^^]+)^?.*"))
	LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW2TEXT",L"<"..towstring(ShortGName)..L">")
	LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW2TEXT_BG",L"<"..towstring(ShortGName)..L">")
	end

	LabelSetTextColor("SoR_"..Window_Name.."CLAIM_WINDOW2TEXT",ClaimColor.r,ClaimColor.g,ClaimColor.b)
	WindowSetShowing("SoR_"..Window_Name.."KEEP2KEEPGLOW",true)
	else
	local ClaimColor = RoR_SoR.RealmColors[1]

	if RoR_SoR.Settings.ShowUnclaimed then
		local Keep_Name = L""

		if RoR_SoR.Settings.ShowBONames then
			Keep_Name = towstring(GetKeepName(tonumber(KEEP2_ID)))
		else
			Keep_Name = L"UnClaimed"
		end

		LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW2TEXT",Keep_Name)--unclaimed
		LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW2TEXT_BG",Keep_Name)--unclaimed
	else
		LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW2TEXT",L"")--unclaimed
		LabelSetText("SoR_"..Window_Name.."CLAIM_WINDOW2TEXT_BG",L"")--unclaimed
	end

	LabelSetTextColor("SoR_"..Window_Name.."CLAIM_WINDOW2TEXT",ClaimColor.r,ClaimColor.g,ClaimColor.b)
	WindowSetShowing("SoR_"..Window_Name.."KEEP2KEEPGLOW",false)
	end



				WindowSetShowing("SoR_"..Window_Name.."KEEP1LORD_ICON",(KEEP1_State == 4))
				WindowSetShowing("SoR_"..Window_Name.."KEEP2LORD_ICON",(KEEP2_State == 4))

		--Set the different Keep states
		--KEEP 1
	WindowSetShowing("SoR_"..Window_Name.."KEEP1HPBAR",false)

		local BarWidth,BarHeight = WindowGetDimensions( "SoR_"..Window_Name.."KEEP1HPBAR")
		local TotalSize = BarWidth / 100

	local Keep1SiegeData = GetKeepData(KEEP1_ID)
	if Keep1SiegeData.siege then
		DynamicImageSetTextureSlice("SoR_"..Window_Name.."KEEP1RAM",RoR_SoR.Ram[KEEP1_Owner])
		WindowSetShowing("SoR_"..Window_Name.."KEEP1RAM",Keep1SiegeData.siege[1].current>0)
	else
		WindowSetShowing("SoR_"..Window_Name.."KEEP1RAM",false)
	end

	local LabelText = L""
		if KEEP1_State == 1	then	--Safe
		LabelSetText("SoR_"..Window_Name.."KEEP1HEALTH",L"")
		LabelSetText("SoR_"..Window_Name.."KEEP1HEALTH_BG",L"")
		WindowStopAlphaAnimation( "SoR_"..Window_Name.."KEEP1KEEPDOOR1")
		WindowStopAlphaAnimation( "SoR_"..Window_Name.."KEEP1KEEPDOOR2")
		WindowStopAlphaAnimation( "SoR_"..Window_Name.."KEEP1LORD_ICON")
		RoR_SoR.KEEP_States[Window_Name][1] = 1
		WindowSetShowing("SoR_"..Window_Name.."KEEP1HPBAR",false)
		elseif KEEP1_State == 2	then	--OuterDoor attacked
			if KEEP1_Door2 > 0 then LabelText = towstring(KEEP1_Door2)..L"%" else LabelText = L"" end
			if RoR_SoR.KEEP_States[Window_Name][1] ~= 2 then
				RoR_SoR.KEEP_States[Window_Name][1] = 2
				WindowStartAlphaAnimation( "SoR_"..Window_Name.."KEEP1KEEPDOOR2", Window.AnimationType.LOOP, 1.0, 0.0, 0.5, false, 0.0, 0 ) --start the Door2 pulse
			end

			LabelSetText("SoR_"..Window_Name.."KEEP1HEALTH",LabelText)
			LabelSetText("SoR_"..Window_Name.."KEEP1HEALTH_BG",LabelText)
			RoR_SoR.KeepStatus[Window_Name][1] = LabelText
			WindowSetShowing("SoR_"..Window_Name.."KEEP1HPBAR",LabelText ~= L"")
			WindowSetDimensions( "SoR_"..Window_Name.."KEEP1HPBARBAR", math.abs(tonumber(KEEP1_Door2)*TotalSize), BarHeight )

			if KEEP1_Door2 < RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner] then
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP1HEALTH")
						WindowSetOffsetFromParent("SoR_Number_Window"..Number_Randomizer,0,-25)
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"-"..towstring(RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner]-KEEP1_Door2))
						LabelSetTextColor("SoR_Number_Window"..Number_Randomizer.."Label",DefaultColor.ORANGE.r,DefaultColor.ORANGE.g,DefaultColor.ORANGE.b)
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"-"..towstring(RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner]-KEEP1_Door2))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
			elseif KEEP1_Door2 > RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner] then
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP1HEALTH")
						WindowSetOffsetFromParent("SoR_Number_Window"..Number_Randomizer,0,-25)
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"+"..towstring(KEEP1_Door2 - RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner]))
						LabelSetTextColor("SoR_Number_Window"..Number_Randomizer.."Label",DefaultColor.GREEN.r,DefaultColor.GREEN.g,DefaultColor.GREEN.b)
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"+"..towstring(KEEP1_Door2 - RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner]))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
			end

			RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner] = KEEP1_Door2

		elseif KEEP1_State == 3	then	--InnerDoor attacked
			if KEEP1_Door1 > 0 then LabelText = towstring(KEEP1_Door1)..L"%" else LabelText = L"" end
			if RoR_SoR.KEEP_States[Window_Name][1] ~= 3 then
				RoR_SoR.KEEP_States[Window_Name][1] = 3
				WindowStartAlphaAnimation( "SoR_"..Window_Name.."KEEP1KEEPDOOR1", Window.AnimationType.LOOP, 1.0, 0.0, 0.5, false, 0.0, 0 ) --start the Door1 pulse
			end


			LabelSetText("SoR_"..Window_Name.."KEEP1HEALTH",LabelText)
			LabelSetText("SoR_"..Window_Name.."KEEP1HEALTH_BG",LabelText)
			RoR_SoR.KeepStatus[Window_Name][1] = LabelText
			WindowSetShowing("SoR_"..Window_Name.."KEEP1HPBAR", LabelText ~= L"")
			WindowSetDimensions( "SoR_"..Window_Name.."KEEP1HPBARBAR", math.abs(tonumber(KEEP1_Door1)*TotalSize), BarHeight )

			if KEEP1_Door1 < RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner] then
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP1HEALTH")
						WindowSetOffsetFromParent("SoR_Number_Window"..Number_Randomizer,0,-25)
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"-"..towstring(RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner]-KEEP1_Door1))
						LabelSetTextColor("SoR_Number_Window"..Number_Randomizer.."Label",DefaultColor.ORANGE.r,DefaultColor.ORANGE.g,DefaultColor.ORANGE.b)
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"-"..towstring(RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner]-KEEP1_Door1))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
			elseif KEEP1_Door1 > RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner] then
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP1HEALTH")
						WindowSetOffsetFromParent("SoR_Number_Window"..Number_Randomizer,0,-25)
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"+"..towstring(KEEP1_Door1 - RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner]))
						LabelSetTextColor("SoR_Number_Window"..Number_Randomizer.."Label",DefaultColor.GREEN.r,DefaultColor.GREEN.g,DefaultColor.GREEN.b)
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"+"..towstring(KEEP1_Door1 - RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner]))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
			end



			RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner] = KEEP1_Door1
		elseif KEEP1_State == 4 then	--Lord Attacked



		LabelSetText("SoR_"..Window_Name.."KEEP1HEALTH",towstring(KEEP1_Lord)..L"%")
		LabelSetText("SoR_"..Window_Name.."KEEP1HEALTH_BG",towstring(KEEP1_Lord)..L"%")
		RoR_SoR.KeepStatus[Window_Name][1] = towstring(KEEP1_Lord)..L"%"
		WindowSetShowing("SoR_"..Window_Name.."KEEP1HPBAR",LabelGetText("SoR_"..Window_Name.."KEEP1HEALTH") ~= L"")
		WindowSetDimensions( "SoR_"..Window_Name.."KEEP1HPBARBAR", math.abs(tonumber(KEEP1_Lord)*TotalSize), BarHeight )
			if RoR_SoR.KEEP_States[Window_Name][1] ~= 4 then
				RoR_SoR.KEEP_States[Window_Name][1] = 4
				WindowStartAlphaAnimation( "SoR_"..Window_Name.."KEEP1LORD_ICON", Window.AnimationType.LOOP, 1.0, 0.0, 0.5, false, 0.0, 0 ) --start the Lord pulse
			end

			if KEEP1_Lord < RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner] then
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP1HEALTH")
						WindowSetOffsetFromParent("SoR_Number_Window"..Number_Randomizer,0,-25)
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"-"..towstring(RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner]-KEEP1_Lord))
						LabelSetTextColor("SoR_Number_Window"..Number_Randomizer.."Label",DefaultColor.ORANGE.r,DefaultColor.ORANGE.g,DefaultColor.ORANGE.b)
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"-"..towstring(RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner]-KEEP1_Lord))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
			elseif KEEP1_Lord > RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner] then
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP1HEALTH")
						WindowSetOffsetFromParent("SoR_Number_Window"..Number_Randomizer,0,-25)
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"+"..towstring(KEEP1_Lord - RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner]))
						LabelSetTextColor("SoR_Number_Window"..Number_Randomizer.."Label",DefaultColor.GREEN.r,DefaultColor.GREEN.g,DefaultColor.GREEN.b)
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"+"..towstring(KEEP1_Lord - RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner]))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
			end

		RoR_SoR.KeepHealth[Window_Name][KEEP1_Owner] = KEEP1_Lord
		elseif KEEP1_State == 5	then	--Captured
			RoR_SoR.KEEP_States[Window_Name][1] = 5
			LabelSetText("SoR_"..Window_Name.."KEEP1HEALTH",L"Captured")
			LabelSetText("SoR_"..Window_Name.."KEEP1HEALTH_BG",L"Captured")
			WindowSetShowing("SoR_"..Window_Name.."KEEP1HPBAR",false)
		elseif KEEP1_State == 6	then	--Locked
			RoR_SoR.KEEP_States[Window_Name][1] = 6
			LabelSetText("SoR_"..Window_Name.."KEEP1HEALTH",L"Locked")
			LabelSetText("SoR_"..Window_Name.."KEEP1HEALTH_BG",L"Locked")
			WindowSetShowing("SoR_"..Window_Name.."KEEP1HPBAR",false)
		end


	local Keep2SiegeData = GetKeepData(KEEP2_ID)
	if Keep2SiegeData.siege then
		DynamicImageSetTextureSlice("SoR_"..Window_Name.."KEEP2RAM",RoR_SoR.Ram[KEEP2_Owner])
		WindowSetShowing("SoR_"..Window_Name.."KEEP2RAM",Keep2SiegeData.siege[1].current>0)
	else
		WindowSetShowing("SoR_"..Window_Name.."KEEP2RAM",false)
	end
		--KEEP 2
		WindowSetShowing("SoR_"..Window_Name.."KEEP2HPBAR",false)

		local BarWidth2,BarHeight2 = WindowGetDimensions( "SoR_"..Window_Name.."KEEP2HPBAR")
		local TotalSize2 = BarWidth2 / 100

		if KEEP2_State == 1	then	--Safe
		LabelSetText("SoR_"..Window_Name.."KEEP2HEALTH",L"")
		LabelSetText("SoR_"..Window_Name.."KEEP2HEALTH_BG",L"")
		WindowStopAlphaAnimation( "SoR_"..Window_Name.."KEEP2KEEPDOOR1")
		WindowStopAlphaAnimation( "SoR_"..Window_Name.."KEEP2KEEPDOOR2")
		WindowStopAlphaAnimation( "SoR_"..Window_Name.."KEEP2LORD_ICON")
		RoR_SoR.KEEP_States[Window_Name][2] = 1
		WindowSetShowing("SoR_"..Window_Name.."KEEP2HPBAR",false)
		elseif KEEP2_State == 2	then	--OuterDoor attacked
			if KEEP2_Door2 > 0 then LabelText = towstring(KEEP2_Door2)..L"%" else LabelText = L"" end
			if RoR_SoR.KEEP_States[Window_Name][2] ~= 2 then
				RoR_SoR.KEEP_States[Window_Name][2] = 2
				WindowStartAlphaAnimation( "SoR_"..Window_Name.."KEEP2KEEPDOOR2", Window.AnimationType.LOOP, 1.0, 0.0, 0.5, false, 0.0, 0 ) --start the Door2 pulse
			end


			LabelSetText("SoR_"..Window_Name.."KEEP2HEALTH",LabelText)
			LabelSetText("SoR_"..Window_Name.."KEEP2HEALTH_BG",LabelText)
			RoR_SoR.KeepStatus[Window_Name][2] = LabelText
			WindowSetShowing("SoR_"..Window_Name.."KEEP2HPBAR",LabelText ~= L"")
			WindowSetDimensions( "SoR_"..Window_Name.."KEEP2HPBARBAR", math.abs(tonumber(KEEP2_Door2)*TotalSize2), BarHeight2 )

			if KEEP2_Door2 < RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner] then
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP2HEALTH")
						WindowSetOffsetFromParent("SoR_Number_Window"..Number_Randomizer,0,-25)
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"-"..towstring(RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner]-KEEP2_Door2))
						LabelSetTextColor("SoR_Number_Window"..Number_Randomizer.."Label",DefaultColor.ORANGE.r,DefaultColor.ORANGE.g,DefaultColor.ORANGE.b)
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"-"..towstring(RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner]-KEEP2_Door2))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
			elseif KEEP2_Door2 > RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner] then
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP2HEALTH")
						WindowSetOffsetFromParent("SoR_Number_Window"..Number_Randomizer,0,-25)
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"+"..towstring(KEEP2_Door2 - RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner]))
						LabelSetTextColor("SoR_Number_Window"..Number_Randomizer.."Label",DefaultColor.GREEN.r,DefaultColor.GREEN.g,DefaultColor.GREEN.b)
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"+"..towstring(KEEP2_Door2 - RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner]))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
			end


			RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner] = KEEP2_Door2
		elseif KEEP2_State == 3	then	--InnerDoor attacked
			if KEEP2_Door1 > 0 then LabelText = towstring(KEEP2_Door1)..L"%" else LabelText = L"" end
			if RoR_SoR.KEEP_States[Window_Name][2] ~= 3 then
				RoR_SoR.KEEP_States[Window_Name][2] = 3
				WindowStartAlphaAnimation( "SoR_"..Window_Name.."KEEP2KEEPDOOR1", Window.AnimationType.LOOP, 1.0, 0.0, 0.5, false, 0.0, 0 ) --start the Door1 pulse
			end


			LabelSetText("SoR_"..Window_Name.."KEEP2HEALTH",LabelText)
			LabelSetText("SoR_"..Window_Name.."KEEP2HEALTH_BG",LabelText)
			WindowSetShowing("SoR_"..Window_Name.."KEEP2HPBAR",LabelText ~= L"")
			WindowSetDimensions( "SoR_"..Window_Name.."KEEP2HPBARBAR", math.abs(tonumber(KEEP2_Door1)*TotalSize2), BarHeight2 )
			RoR_SoR.KeepStatus[Window_Name][2] = LabelText

			if KEEP2_Door1 < RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner] then
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP2HEALTH")
						WindowSetOffsetFromParent("SoR_Number_Window"..Number_Randomizer,0,-25)
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"-"..towstring(RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner]-KEEP2_Door1))
						LabelSetTextColor("SoR_Number_Window"..Number_Randomizer.."Label",DefaultColor.ORANGE.r,DefaultColor.ORANGE.g,DefaultColor.ORANGE.b)
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"-"..towstring(RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner]-KEEP2_Door1))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
			elseif KEEP2_Door1 > RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner] then
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP2HEALTH")
						WindowSetOffsetFromParent("SoR_Number_Window"..Number_Randomizer,0,-25)
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"+"..towstring(KEEP2_Door1 - RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner]))
						LabelSetTextColor("SoR_Number_Window"..Number_Randomizer.."Label",DefaultColor.GREEN.r,DefaultColor.GREEN.g,DefaultColor.GREEN.b)
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"+"..towstring(KEEP2_Door1 - RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner]))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
			end

			RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner] = KEEP2_Door1
		elseif KEEP2_State == 4 then	--Lord Attacked
		LabelSetText("SoR_"..Window_Name.."KEEP2HEALTH",towstring(KEEP2_Lord)..L"%")
		LabelSetText("SoR_"..Window_Name.."KEEP2HEALTH_BG",towstring(KEEP2_Lord)..L"%")
		RoR_SoR.KeepStatus[Window_Name][2] = towstring(KEEP2_Lord)..L"%"
		WindowSetShowing("SoR_"..Window_Name.."KEEP2HPBAR",LabelGetText("SoR_"..Window_Name.."KEEP2HEALTH") ~= L"")
		WindowSetDimensions( "SoR_"..Window_Name.."KEEP2HPBARBAR", math.abs(tonumber(KEEP2_Lord)*TotalSize2), BarHeight2 )

			if RoR_SoR.KEEP_States[Window_Name][2] ~= 4 then
				RoR_SoR.KEEP_States[Window_Name][2] = 4
				WindowStartAlphaAnimation( "SoR_"..Window_Name.."KEEP2LORD_ICON", Window.AnimationType.LOOP, 1.0, 0.0, 0.5, false, 0.0, 0 ) --start the Lord pulse
			end

			if KEEP2_Lord < RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner] then
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP2HEALTH")
						WindowSetOffsetFromParent("SoR_Number_Window"..Number_Randomizer,0,-25)
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"-"..towstring(RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner]-KEEP2_Lord))
						LabelSetTextColor("SoR_Number_Window"..Number_Randomizer.."Label",DefaultColor.ORANGE.r,DefaultColor.ORANGE.g,DefaultColor.ORANGE.b)
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"-"..towstring(RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner]-KEEP2_Lord))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
			elseif KEEP2_Lord > RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner] then
						local Number_Randomizer = math.random(999)
						RoR_SoR.NumberWindows[Number_Randomizer] = {timer=2.5}
						CreateWindowFromTemplate("SoR_Number_Window"..Number_Randomizer, "Number_Window_Template", "SoR_"..Window_Name.."KEEP2HEALTH")
						WindowSetOffsetFromParent("SoR_Number_Window"..Number_Randomizer,0,-25)
						WindowStartAlphaAnimation("SoR_Number_Window"..Number_Randomizer, 1, 1.0, 0.0, 1.5, true, 1.5, 0 ) --start the Door2 pulse
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."Label",L"+"..towstring(KEEP2_Lord - RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner]))
						LabelSetTextColor("SoR_Number_Window"..Number_Randomizer.."Label",DefaultColor.GREEN.r,DefaultColor.GREEN.g,DefaultColor.GREEN.b)
						LabelSetText("SoR_Number_Window"..Number_Randomizer.."LabelBG",L"+"..towstring(KEEP2_Lord - RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner]))
						WindowSetScale("SoR_Number_Window"..Number_Randomizer,WindowGetScale("RoR_SoR_Main_Window"))
			end

		RoR_SoR.KeepHealth[Window_Name][KEEP2_Owner] = KEEP2_Lord
		elseif KEEP2_State == 5	then	--Captured
			RoR_SoR.KEEP_States[Window_Name][2] = 5
			LabelSetText("SoR_"..Window_Name.."KEEP2HEALTH",L"Captured")
			LabelSetText("SoR_"..Window_Name.."KEEP2HEALTH_BG",L"Captured")
			WindowSetShowing("SoR_"..Window_Name.."KEEP2HPBAR",false)
		elseif KEEP2_State == 6	then	--Locked
			RoR_SoR.KEEP_States[Window_Name][2] = 6
			LabelSetText("SoR_"..Window_Name.."KEEP2HEALTH",L"Locked")
			LabelSetText("SoR_"..Window_Name.."KEEP2HEALTH_BG",L"Locked")
			WindowSetShowing("SoR_"..Window_Name.."KEEP2HPBAR",false)
		end



				if KEEP1_Rank > 0 then
					DynamicImageSetTextureSlice("SoR_"..Window_Name.."KEEP1KEEPRANK", "KeepDifficulty-"..KEEP1_Rank.."-star" )
				else
					DynamicImageSetTextureSlice("SoR_"..Window_Name.."KEEP1KEEPRANK", "KeepDifficulty-1-star" )
				end

				if KEEP2_Rank > 0 then
					DynamicImageSetTextureSlice("SoR_"..Window_Name.."KEEP2KEEPRANK", "KeepDifficulty-"..KEEP2_Rank.."-star" )
				else
					DynamicImageSetTextureSlice("SoR_"..Window_Name.."KEEP2KEEPRANK", "KeepDifficulty-1-star" )
				end
				WindowSetShowing("SoR_"..Window_Name.."KEEP1KEEPRANK",KEEP1_Rank>0)
				WindowSetShowing("SoR_"..Window_Name.."KEEP2KEEPRANK",KEEP2_Rank>0)

				WindowSetShowing("SoR_"..Window_Name.."KEEP1KEEPDOOR1",KEEP1_Door1>0)
				WindowSetShowing("SoR_"..Window_Name.."KEEP1KEEPDOOR2",KEEP1_Door2>0)

				WindowSetShowing("SoR_"..Window_Name.."KEEP2KEEPDOOR1",KEEP2_Door1>0)
				WindowSetShowing("SoR_"..Window_Name.."KEEP2KEEPDOOR2",KEEP2_Door2>0)

				if KEEP1_Door2>0 then
					WindowClearAnchors("SoR_"..Window_Name.."KEEP1KEEPDOOR1")
					WindowAddAnchor( "SoR_"..Window_Name.."KEEP1KEEPDOOR1", "topleft", "SoR_"..Window_Name.."KEEP1", "topleft",10,28 )
				else
					WindowClearAnchors("SoR_"..Window_Name.."KEEP1KEEPDOOR1")
					WindowAddAnchor( "SoR_"..Window_Name.."KEEP1KEEPDOOR1", "topleft", "SoR_"..Window_Name.."KEEP1", "topleft",20,28 )
				end


				if KEEP2_Door2>0 then
					WindowClearAnchors("SoR_"..Window_Name.."KEEP2KEEPDOOR1")
					WindowAddAnchor( "SoR_"..Window_Name.."KEEP2KEEPDOOR1", "topleft", "SoR_"..Window_Name.."KEEP2", "topleft",10,28 )
				else
					WindowClearAnchors("SoR_"..Window_Name.."KEEP2KEEPDOOR1")
					WindowAddAnchor( "SoR_"..Window_Name.."KEEP2KEEPDOOR1", "topleft", "SoR_"..Window_Name.."KEEP2", "topleft",20,28 )
				end

		end
	end
end
-- Tooltip function
function RoR_SoR.OnMouseOverStart()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)
	local WindowName = tostring(SystemData.MouseOverWindow.name)
	local Line1,Line2,Line3,Line4,Line5,Line6 = L"",L"",L"",nil,L"",L""
	local Owner,State = 0,nil
	local ClaimColor = RoR_SoR.RealmColors[1]
	local IsFort = false
	local F_Stage,F_Health = 0,L""
	RoR_SoR.Lines = {}

	--Fort Tooltips
	if RoR_SoR.Forts[tonumber(string.match( WindowName,"SoR_(%d+)."))] ~= nil then
	IsFort = true
		if WindowName:match("SoR_+[^%.]+BO.") then

			local BoId = string.match( WindowName,"SoR_(%d+)BO.")
			local Number = string.match( WindowName,"BO(%d+)")

			if tonumber(RoR_SoR.Fort[BoId].Stage) ~= 2 then return end

			Owner = RoR_SoR.Fort[BoId].Owner[tonumber(Number)]

			Line1 = towstring(RoR_SoR.Fort[BoId].BO[tonumber(Number)])
			Line2 = L""
			Line3 = RoR_SoR.GetTooltipIcon(Owner,16)

		elseif WindowName:match("SoR_+[^%.]+KEEP.") then
			local KeepId = string.match( WindowName,"SoR_(%d+)KEEP.")
			local Number = string.match( WindowName,"KEEP(%d+)")

			F_Stage = tonumber(RoR_SoR.Fort[KeepId].Stage)+1
			F_Health = RoR_SoR.Fort[KeepId].Health
			Owner = RoR_SoR.Forts[tonumber(KeepId)]

			Line1 = towstring(GetZoneName(tonumber(KeepId)))
			Line2 = L""
			Line3 = RoR_SoR.GetKeepIcon(Owner,16)..L"Fort"
			Line5 = towstring(RoR_SoR.GetKeepIcon2(Owner,F_Stage))..towstring(F_Health)
			Line6 = L""

	elseif WindowName:match("SoR_+[^%.]+POP") then
		local KeepId = string.match( WindowName,"SoR_(%d+)POP")
			Owner = 0

			Line1 = towstring(GetZoneName(tonumber(KeepId)))
			Line2 = L"Attackers: "..towstring(RoR_SoR.Fort[KeepId]["Status"].Attackers)..L"<br>".. L"Defenders: "..towstring(RoR_SoR.Fort[KeepId]["Status"].Defenders)
			Line3 = L""
			Line4 = L""
			Line5 = L""
			Line6 = L""

		end
	end

	--Normal Zones Tooltips
	if IsFort == false then
		if WindowName:match("SoR_+[^%.]+BO.") then
			local BoId = string.match( WindowName,"SoR_(%d+)BO.")
			local Number = string.match( WindowName,"BO(%d+)")
			local Final = RoR_SoR.BO_IDs[tostring(BoId)][tonumber(Number)].ID
			Owner = RoR_SoR.BO_IDs[tostring(BoId)][tonumber(Number)].Owner
			State = RoR_SoR.BO_States[tostring(BoId)][tonumber(Number)]
			Line6 = L""

		Line1 = towstring(GetObjectiveName(tonumber(Final)))
		if (RoR_SoR.Timers[tostring(BoId)][tonumber(Number)] ~= nil) and (RoR_SoR.Timers[tostring(BoId)][tonumber(Number)] > 0) then Line2 = L"<icon29979>"..towstring(TimeUtils.FormatClock(RoR_SoR.Timers[tostring(BoId)][tonumber(Number)])) else Line2 = L"" end
		Line3 =RoR_SoR.GetTooltipIcon(Owner,State)


		elseif WindowName:match("SoR_+[^%.]+KEEP.") then
			local KeepId = string.match( WindowName,"SoR_(%d+)KEEP.")
			local Number = string.match( WindowName,"KEEP(%d+)")
			local KEEP_DATA = RoR_SoR.KEEP_IDs[tostring(KeepId)][tonumber(Number)]
			local Final = KEEP_DATA.ID

			Owner = KEEP_DATA.Owner
			State = KEEP_DATA.State

		Line1 = towstring(GetKeepName(tonumber(Final)))
		Line2 = RoR_SoR.GetKeepRank(KEEP_DATA.Rank)
		Line3 =RoR_SoR.GetKeepIcon(Owner,State)
		Line6 = KEEP_DATA.Supply
		if State ~= 1 then
		Line5 = towstring(RoR_SoR.GetKeepIcon2(Owner,State))..towstring(RoR_SoR.KeepStatus[tostring(KeepId)][tonumber(Number)])
		end

			if KEEP_DATA.Claim ~= "0" then
					Line4 = L"<"..towstring(KEEP_DATA.Claim)..L">"
					ClaimColor = RoR_SoR.RealmColors[Owner+1] or 1
				else
					Line4 = L"UnClaimed" --unclaimed
					ClaimColor = RoR_SoR.RealmColors[1]	or 1
			end

	elseif WindowName:match("SoR_+[^%.]+POP") then
		Owner = 0
		local ZoneId = string.match( WindowName,"SoR_(%d+)POP")
		if RoR_SoR.InvolvedGuilds[tostring(ZoneId)] ~= nil and #RoR_SoR.InvolvedGuilds[tostring(ZoneId)] > 0 then
			Line1 = towstring(L"Involved Guilds:")
			local GuildNumber = 2
				for k,v in pairs(RoR_SoR.InvolvedGuilds[ZoneId]) do
					Line3 = Line3..L"<icon20204> "..towstring(v)..L"<br>"
				end
		else
			Line1 = towstring(L"No Guilds Involved")
		end

	end
end
	--creates the tooltip from the info above
		Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name,nil)
		Tooltips.SetTooltipText( 1, 1, Line1)
		Tooltips.SetTooltipColorDef( 1, 1, Tooltips.MAP_DESC_TEXT_COLOR )
			if Line2 ~= L""	then
				Tooltips.SetTooltipText( 3, 1,towstring(Line3))
				Tooltips.SetTooltipText( 3, 3,towstring(Line2))
			else
				Tooltips.SetTooltipText( 3, 1,towstring(Line3))
			end
		if Line4 ~= nil then
			Tooltips.SetTooltipText( 2, 2,Line4)
			Tooltips.SetTooltipColorDef( 2, 2, ClaimColor)
		end
		Tooltips.SetTooltipColorDef( 3, 1, RoR_SoR.RealmColors[Owner+1] or 1 )

		if Line5 ~= L"" then
			Tooltips.SetTooltipText( 4, 1,towstring(Line5))
			Tooltips.SetTooltipColorDef( 4, 1, Tooltips.COLOR_BODY)
		end
		if Line6 ~= L"" then
			Tooltips.SetTooltipText( 5, 1, towstring("<icon00046> Supply: "..Line6.."%"))
		end







		Tooltips.Finalize()
		Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP )

		RoR_SoR.Lines[1] = Line1
		RoR_SoR.Lines[2] = Line2
		RoR_SoR.Lines[3] = Line3
		RoR_SoR.Lines[4] = Line4
		RoR_SoR.Lines[5] = Line5
		RoR_SoR.Lines[6] = Line6


end

function RoR_SoR.MainTooltip()
		Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name,nil)
		Tooltips.SetTooltipText( 1, 1, L"State Of Realm")
		Tooltips.SetTooltipColorDef( 1, 1, Tooltips.MAP_DESC_TEXT_COLOR )
		Tooltips.SetTooltipText( 1, 3, towstring(version))
		Tooltips.SetTooltipText( 3, 1, L"LMB: Toggle Show/Hide<br>RMB: RoR Menu")
		Tooltips.Finalize()
		Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP )
	return
end


function RoR_SoR.TIMER_UPDATE(elapsedTime)
	if RoR_SoR.Timers ~= nil then
		for k,v in pairs(RoR_SoR.Timers) do
			if v ~= nil then
				for a,b in pairs(v) do
	--			k - Area id , v - bonumber, a-bonumber, b-value
				RoR_SoR.Timers[tostring(k)][a] = b-elapsedTime

					if DoesWindowExist("SoR_"..k) then
						if RoR_SoR.Fort[tostring(k)] == nil and RoR_SoR.City[tostring(k)] == nil then
							LabelSetText("SoR_"..k.."BO"..a.."TIMER",towstring(towstring(TimeUtils.FormatClock(RoR_SoR.Timers[tostring(k)][a]))))
							LabelSetText("SoR_"..k.."BO"..a.."TIMER_BG",towstring(towstring(TimeUtils.FormatClock(RoR_SoR.Timers[tostring(k)][a]))))
							if RoR_SoR.BO_States[k][a] ~= 4 then
								local Builer = 31 - (tonumber(RoR_SoR.Timers[tostring(k)][a])/1.34)
								if (Builer >= 0) and (RoR_SoR.Timers[tostring(k)][a] >= 0) then
									WindowSetDimensions("SoR_"..k.."BO"..a.."Flag",31,Builer)
								else
									WindowSetDimensions("SoR_"..k.."BO"..a.."Flag",31,31)
								end
							end
						else
							LabelSetText("SoR_"..k.."_TIMER",towstring(towstring(TimeUtils.FormatClock(RoR_SoR.Timers[tostring(k)][a])))..L"<icon29979>")
							LabelSetText("SoR_"..k.."_TIMER_BG",towstring(towstring(TimeUtils.FormatClock(RoR_SoR.Timers[tostring(k)][a])))..L"<icon29979>")
						end
					end
				end
			end
		WindowSetAlpha("SoR_"..k.."Background2",WindowGetAlpha("RoR_SoR_Main_Window"))
		--WindowSetShowing("SoR_"..k.."Background2",RoR_SoR.Settings.DrawBackground or false)
		WindowSetShowing("SoR_"..k.."Banner",RoR_SoR.Settings.DrawBanner or false)
			if DoesWindowExist("SoR_"..k.."BG") then
				WindowSetAlpha("SoR_"..k.."BG",0.3*(WindowGetAlpha("RoR_SoR_Main_Window")))
				WindowSetShowing("SoR_"..k.."BG",RoR_SoR.Settings.DrawBackground)
			end
		end



				local windowName  = SystemData.MouseOverWindow.name
				if DoesWindowExist(windowName) then
					if (windowName:find("SoR_") or WindowGetParent (windowName) == "RoR_SoR_Main_Window" or (Popper.m_IsShowing ==true and WindowGetShowing("EA_Window_ContextMenu1") == true))then
						RoR_SoR.ShowPopper()
					else
						RoR_SoR.HidePopper ()
					end
				end


	end

	if RoR_SoR.Settings.OnlyActive == true then
		if RoR_SoR.ZoneNames[GameData.Player.zone] ~= nil and (RoR_SoR.OpenZones[tostring(RoR_SoR.ZoneNames[GameData.Player.zone][1])] ~= nil or RoR_SoR.OpenZones[tostring(RoR_SoR.ZoneNames[GameData.Player.zone][2])] ~= nil) then
			for k,v in pairs(RoR_SoR.OpenZones) do
				local Window_Name = tostring(k)
				if (RoR_SoR.ZoneNames[GameData.Player.zone][1] ~= tonumber(Window_Name)) and (RoR_SoR.ZoneNames[GameData.Player.zone][2] ~= tonumber(Window_Name)) then
					RoR_SoR.RemoveWindow(k)
				end
			end

		end
	end


	RoR_SoR.OnScenario()



	if RoR_SoR.ZoneTimer ~= nil then
		for k,v in pairs(RoR_SoR.ZoneTimer) do
			if DoesWindowExist("SoR_"..k) then
				if v > 0 then
				RoR_SoR.ZoneTimer[k] = RoR_SoR.ZoneTimer[k] - elapsedTime
				else
				RoR_SoR.RemoveWindow(k)
				RoR_SoR.ZoneTimer[k] = nil
				end
			else
			RoR_SoR.ZoneTimer[k] = nil
			end
		end
			RoR_SoR.Restack()
	end


	if RoR_SoR.Pairings ~= nil then
		for k,v in pairs(RoR_SoR.Pairings) do
			if DoesWindowExist("SoR_P_"..k) then
				local Window_Name = "P_"..tostring(k)
				if RoR_SoR.Pairings[k].Timer and RoR_SoR.Pairings[k].Timer > 0 then

						RoR_SoR.Pairings[k].Timer = RoR_SoR.Pairings[k].Timer - elapsedTime
						LabelSetText("SoR_"..Window_Name.."_TIMER",TimeUtils.FormatTimeCondensed(RoR_SoR.Pairings[k].Timer))
						LabelSetText("SoR_"..Window_Name.."_TIMER_BG",TimeUtils.FormatTimeCondensed(RoR_SoR.Pairings[k].Timer))
				end

				if RoR_SoR.Pairings[k].Timer2 and RoR_SoR.Pairings[k].Timer2 > 0 then

						RoR_SoR.Pairings[k].Timer2 = RoR_SoR.Pairings[k].Timer2 - elapsedTime
						LabelSetText("SoR_"..Window_Name.."Lock_STATUS",TimeUtils.FormatTimeCondensed(RoR_SoR.Pairings[k].Timer2))
						LabelSetText("SoR_"..Window_Name.."Lock_STATUS_BG",TimeUtils.FormatTimeCondensed(RoR_SoR.Pairings[k].Timer2))
				end
			else
			--RoR_SoR.ZoneTimer[k] = nil
			end
		end
	end


	for k,v in pairs(RoR_SoR.SafeKeep) do
					local FillStart = 90
					local FillEnd = 360
			if DoesWindowExist("SoR_"..k) then
				if RoR_SoR.SafeKeep[k][1] > 0 and 600 > RoR_SoR.SafeKeep[k][1] then
					RoR_SoR.SafeKeep[k][1] = RoR_SoR.SafeKeep[k][1] - elapsedTime
					LabelSetText("SoR_"..k.."KEEP1SAFETIMER",TimeUtils.FormatTimeCondensed(RoR_SoR.SafeKeep[k][1]))
					LabelSetText("SoR_"..k.."KEEP1SAFETIMERBG",LabelGetText("SoR_"..k.."KEEP1SAFETIMER"))
					local perc1 = RoR_SoR.SafeKeep[k][1]/60
					CircleImageSetFillParams("SoR_"..k.."KEEP1SAFECircle", FillStart,   FillEnd-(perc1 * 36))

				end

				if RoR_SoR.SafeKeep[k][2] > 0 and 600 > RoR_SoR.SafeKeep[k][2] then
					RoR_SoR.SafeKeep[k][2] = RoR_SoR.SafeKeep[k][2] - elapsedTime
					LabelSetText("SoR_"..k.."KEEP2SAFETIMER",TimeUtils.FormatTimeCondensed(RoR_SoR.SafeKeep[k][2]))
					LabelSetText("SoR_"..k.."KEEP2SAFETIMERBG",LabelGetText("SoR_"..k.."KEEP2SAFETIMER"))
					local perc2 = RoR_SoR.SafeKeep[k][2]/60
					CircleImageSetFillParams("SoR_"..k.."KEEP2SAFECircle", FillStart,   FillEnd-(perc2 * 36))
				end
					end
	end

	if RoR_Window_Scale ~= WindowGetScale("RoR_SoR_Main_Window") then
		RoR_SoR.OnSizeUpdated()
		RoR_Window_Scale = WindowGetScale("RoR_SoR_Main_Window")
	end


	if HasReloaded == true then
		--if the RoR_CitySiege table can't be found due to a reloadui, use the Backup table untill official table is present again
		RoR_SoR.City_Status[GameData.CityId.CHAOS].ratingTimer = RoR_SoR.Pairings[161].Timer
		RoR_SoR.City_Status[GameData.CityId.EMPIRE].ratingTimer = RoR_SoR.Pairings[162].Timer


		RoR_SoR.City_Status[GameData.CityId.CHAOS].timeLeft = RoR_SoR.Pairings[161].Timer2
		RoR_SoR.City_Status[GameData.CityId.EMPIRE].timeLeft = RoR_SoR.Pairings[162].Timer2

	else
		--While the RoR_CitySiege table is present, save it into the backup table incase of an reloadui
		if RoR_SoR.Pairings ~= nil then
		RoR_SoR.City_Status[GameData.CityId.CHAOS] = RoR_CitySiege.GetCity(GameData.CityId.CHAOS)
		RoR_SoR.Pairings[161].Timer = RoR_SoR.City_Status[GameData.CityId.CHAOS].ratingTimer
		RoR_SoR.Pairings[161].Timer2 = RoR_SoR.City_Status[GameData.CityId.CHAOS].timeLeft

		RoR_SoR.City_Status[GameData.CityId.EMPIRE] = RoR_CitySiege.GetCity(GameData.CityId.EMPIRE)
		RoR_SoR.Pairings[162].Timer = RoR_SoR.City_Status[GameData.CityId.EMPIRE].ratingTimer
		RoR_SoR.Pairings[162].Timer2 = RoR_SoR.City_Status[GameData.CityId.EMPIRE].timeLeft
		end
	end

	if RoR_SoR.NumberWindows ~= nil then
		for k,v in pairs(RoR_SoR.NumberWindows) do
		if DoesWindowExist("SoR_Number_Window"..k) then
			if v.timer > 0 then
			RoR_SoR.NumberWindows[k].timer = v.timer - elapsedTime
			else
			DestroyWindow("SoR_Number_Window"..k)
			RoR_SoR.NumberWindows[k] = nil
			end
			else
			RoR_SoR.NumberWindows[k] = nil
		end
		end
	end

	--Door% in ram
	if GameData.SiegeWeapon.fireMode == GameData.SiegeFireMode.GOLF and GameData.SiegeWeapon.worldObjNum ~= 0 then


	local Zone
	if RoR_SoR.ZoneNames[GameData.Player.zone] == nil or RoR_SoR.ZoneNames[GameData.Player.zone][2] == nil then
		Zone = GameData.Player.zone
	else
		Zone = RoR_SoR.ZoneNames[GameData.Player.zone][2]
	end

	if SiegeWeaponGolfFireWindow.KeepInfo[Zone] ~= nil and SiegeWeaponGolfFireWindow.KeepInfo[Zone][GameData.Player.realm] ~= nil then
	local CurrentKeepInfo = SiegeWeaponGolfFireWindow.KeepInfo[Zone][GameData.Player.realm]
	if CurrentKeepInfo ~= nil then
		local State = CurrentKeepInfo.State
		if CurrentKeepInfo[State] ~= nil then
			LabelSetText( "RoR_SoR_DoorPercentageLabel", L"<icon29980>Door: "..towstring(CurrentKeepInfo[State])..L"%" or L"" )
			StatusBarSetCurrentValue( "RoR_SoR_DoorPercentageHealthPercentBar", tonumber(CurrentKeepInfo[State]) )
		end
	end
	end
		WindowSetShowing("RoR_SoR_DoorPercentage",SiegeWeaponGolfFireWindow.KeepInfo[Zone][GameData.Player.realm].State > 0)
	else
		WindowSetShowing("RoR_SoR_DoorPercentage",false)
	end

end

function RoR_SoR.OnSizeUpdated()
	RoR_SoR.Restack()
	return
end

function RoR_SoR.RemoveWindow(Number)
	if Number == nil then return end
	if DoesWindowExist("SoR_"..Number) then
		DestroyWindow("SoR_"..Number)

		RoR_SoR.OpenZones[Number] = nil
		RoR_SoR.BO_States[Number] = nil
		RoR_SoR.KEEP_States[Number] = nil
		RoR_SoR.ZoneTimer[Number] = nil
		RoR_SoR.BO_IDs[Number] = nil
		RoR_SoR.KEEP_IDs[Number] = nil
		RoR_SoR.Timers[tostring(Number)] = nil
		RoR_SoR.Fort[tostring(Number)] = nil
	end
	return
end

function RoR_SoR.ClearTier(Number)
local Number = Number
if RoR_SoR.StackSort == nil then return end
		for k,v in ipairs(RoR_SoR.StackSort) do
			if Number == 0 then
				RoR_SoR.RemoveWindow(v.Zone)
			elseif Number == 1 then
				if v.Tier == 1 then
				RoR_SoR.RemoveWindow(v.Zone)
				end
			elseif Number == 2 then
				if (v.Tier == 2) or (v.Tier == 3) or (v.Tier == 4) then
				RoR_SoR.RemoveWindow(v.Zone)
				end
			elseif Number == 3 then
				if (v.Tier == 5) then
				RoR_SoR.RemoveWindow(v.Zone)
				end
			end
		end
		RoR_SoR.Restack()
return
end

function RoR_SoR.GetFlag(BO_OWNER,BO_STATE)
	local Owner = tonumber(BO_OWNER)
	local State = tonumber(BO_STATE)

	if State == 0 then
		if Owner == 0 then return "SoR_Neutral" end
		if Owner == 1 then return "SoR_Order" end
		if Owner == 2 then return "SoR_Destro" end
	elseif State == 4 then
		if Owner == 0 then return "SoR_Neutral-Burning" end
		if Owner == 1 then return "SoR_Order-Burning" end
		if Owner == 2 then return "SoR_Destro-Burning" end
	elseif State == 8 then
		if Owner == 0 then return "SoR_Neutral-Locked" end
		if Owner == 1 then return "SoR_Order-Locked" end
		if Owner == 2 then return "SoR_Destro-Locked" end
	elseif State == 9 then
		if Owner == 0 then return "SoR_Neutral-Locked" end
		if Owner == 1 then return "SoR_Order-Locked" end
		if Owner == 2 then return "SoR_Destro-Locked" end
	elseif State == 10 then
		if Owner == 0 then return "SoR_Neutral" end
		if Owner == 1 then return "SoR_Order-Locked" end
		if Owner == 2 then return "SoR_Destro-Locked" end
	elseif State == 16 then
		if Owner == 0 then return "SoR_Neutral-Glowing" end
		if Owner == 1 then return "SoR_Order-Glowing" end
		if Owner == 2 then return "SoR_Destro-Glowing" end
	else
		if Owner == 0 then return "SoR_Neutral" end
		if Owner == 1 then return "SoR_Order" end
		if Owner == 2 then return "SoR_Destro" end
	end

end

function RoR_SoR.GetFlag2(BO_OWNER,BO_STATE)
	local Owner = tonumber(BO_OWNER)
	local State = tonumber(BO_STATE)

	if State == 0 then
		if Owner == 0 then return "SoR_Neutral" end
		if Owner == 1 then return "SoR_Order" end
		if Owner == 2 then return "SoR_Destro" end
	elseif State == 4 then
		if Owner == 0 then return "" end
		if Owner == 1 then return "" end
		if Owner == 2 then return "" end
	elseif State == 8 then
		if Owner == 0 then return "SoR_Neutral-Locked" end
		if Owner == 1 then return "SoR_Order-Locked" end
		if Owner == 2 then return "SoR_Destro-Locked" end
	elseif State == 9 then
		if Owner == 0 then return "SoR_Neutral-Locked" end
		if Owner == 1 then return "SoR_Order-Locked" end
		if Owner == 2 then return "SoR_Destro-Locked" end
	elseif State == 10 then
		if Owner == 0 then return "SoR_Neutral" end
		if Owner == 1 then return "SoR_Order-Locked" end
		if Owner == 2 then return "SoR_Destro-Locked" end
	elseif State == 16 then
		if Owner == 0 then return "SoR_Neutral-Glowing" end
		if Owner == 1 then return "SoR_Order" end
		if Owner == 2 then return "SoR_Destro" end
	else
		if Owner == 0 then return "SoR_Neutral" end
		if Owner == 1 then return "SoR_Order" end
		if Owner == 2 then return "SoR_Destro" end
	end

end

function RoR_SoR.GetKeepTexture(KEEP_OWNER,KEEP_STATE)
	local Owner = tonumber(KEEP_OWNER)
	local State = tonumber(KEEP_STATE)

	if State == 1 then
		if Owner == 0 then return "SoR_Keep_Neutral" end
		if Owner == 1 then return "SoR_Keep_Order" end
		if Owner == 2 then return "SoR_Keep_Destro" end
	elseif State == 2 then
		if Owner == 0 then return "FlagNeutral-Burning" end
		if Owner == 1 then return "SoR_Keep_Order-Attacked" end
		if Owner == 2 then return "SoR_Keep_Destro-Attacked" end
	elseif State == 3 then
		if Owner == 0 then return "FlagNeutral-Burning" end
		if Owner == 1 then return "SoR_Keep_Order-Attacked" end
		if Owner == 2 then return "SoR_Keep_Destro-Attacked" end
	elseif State == 4 then
		if Owner == 0 then return "BombNeutral" end
		if Owner == 1 then return "SoR_Keep_Order-Attacked" end
		if Owner == 2 then return "SoR_Keep_Destro-Attacked" end
	elseif State == 5 then
		if Owner == 0 then return "FlagNeutral-Burning" end
		if Owner == 1 then return "SoR_Keep_Order" end
		if Owner == 2 then return "SoR_Keep_Destro" end
	elseif State == 6 then
		if Owner == 0 then return "FlagNeutral-Burning" end
		if Owner == 1 then return "SoR_Keep_Order" end
		if Owner == 2 then return "SoR_Keep_Destro" end
	else
		if Owner == 0 then return "SoR_Keep_Neutral" end
		if Owner == 1 then return "SoR_Keep_Order" end
		if Owner == 2 then return "SoR_Keep_Destro" end
	end
end

function RoR_SoR.GetTooltipIcon(BO_OWNER,BO_STATE)
local Owner = tonumber(BO_OWNER)
local State = tonumber(BO_STATE)

if State == 0 then
	if Owner == 0 then return L"<icon29982> "..towstring(RoR_SoR.TextNeutral) end --neutral
	if Owner == 1 then return L"<icon29990> "..towstring(RoR_SoR.TextDestro) end
	if Owner == 2 then return L"<icon29985> "..towstring(RoR_SoR.TextOrder) end
elseif State == 2 then
	if Owner == 0 then return L"<icon29982> Abandoned" end
	if Owner == 1 then return L"<icon29990> Order Abandoned" end
	if Owner == 2 then return L"<icon29985> Destro Abandoned" end
elseif State == 4 then
	if Owner == 0 then return L"<icon29984> Capping" end
	if Owner == 1 then return L"<icon29992> Destro Capping" end
	if Owner == 2 then return L"<icon29987> Order Capping" end
elseif State == 8 then
	if Owner == 0 then return L"<icon29983> Unlocking" end
	if Owner == 1 then return L"<icon29991> Order "..towstring(RoR_SoR.TextLock) end
	if Owner == 2 then return L"<icon29986> Destro "..towstring(RoR_SoR.TextLock) end
elseif State == 9 then
	if Owner == 0 then return L"<icon29983> "..towstring(RoR_SoR.TextLock) end
	if Owner == 1 then return L"<icon29991> Order "..towstring(RoR_SoR.TextLock) end
	if Owner == 2 then return L"<icon29986> Destro "..towstring(RoR_SoR.TextLock) end
elseif State == 10 then
	if Owner == 0 then return L"<icon29982> Neutral "..towstring(RoR_SoR.TextLock) end--neutral
	if Owner == 1 then return L"<icon29991> Order "..towstring(RoR_SoR.TextLock) end
	if Owner == 2 then return L"<icon29986> Destro "..towstring(RoR_SoR.TextLock) end
elseif State == 16 then
	if Owner == 0 then return L"<icon29982> Securing" end
	if Owner == 1 then return L"<icon29993> Order securing" end -- securing / holding
	if Owner == 2 then return L"<icon29988> Destro securing" end
else
	if Owner == 0 then return L"<icon29982> Neutral" end--neutral
	if Owner == 1 then return L"<icon29990> Order" end
	if Owner == 2 then return L"<icon29985> Destro" end
end

end

function RoR_SoR.GetKeepIcon(KEEP_OWNER,KEEP_STATE)
local Owner = tonumber(KEEP_OWNER)
local State = tonumber(KEEP_STATE)

if State == 1 then
	if Owner == 0 then return L"<icon29995> Neutral Keep" end
	if Owner == 1 then return L"<icon29998> Order Keep" end
	if Owner == 2 then return L"<icon29996> Destro Keep" end
elseif State == 2 then
	if Owner == 0 then return L"<icon29995> Under Attack" end
	if Owner == 1 then return L"<icon29999> Under Attack" end
	if Owner == 2 then return L"<icon29997> Under Attack" end
elseif State == 3 then
	if Owner == 0 then return L"<icon29995> Under Attack" end
	if Owner == 1 then return L"<icon29999> Under Attack" end
	if Owner == 2 then return L"<icon29997> Under Attack" end
elseif State == 4 then
	if Owner == 0 then return L"<icon29995> Under Attack" end
	if Owner == 1 then return L"<icon29999> Under Attack" end
	if Owner == 2 then return L"<icon29997> Under Attack" end
elseif State == 5 then
	if Owner == 0 then return L"<icon29995> Neutral Keep" end
	if Owner == 1 then return L"<icon29998> Order Keep" end
	if Owner == 2 then return L"<icon29996> Destro Keep" end
elseif State == 6 then
	if Owner == 0 then return L"<icon29995> Neutral Keep" end
	if Owner == 1 then return L"<icon29998> Order Keep" end
	if Owner == 2 then return L"<icon29996> Destro Keep" end
elseif State == 16 then
	if Owner == 0 then return L"<icon29995> Neutral " end
	if Owner == 1 then return L"<icon29998> Order " end
	if Owner == 2 then return L"<icon29996> Destro " end
else
	if Owner == 0 then return L"<icon29995> Neutral Keep" end
	if Owner == 1 then return L"<icon29998> Order Keep" end
	if Owner == 2 then return L"<icon29996> Destro Keep" end
end
end

function RoR_SoR.GetKeepIcon2(KEEP_OWNER,KEEP_STATE)
local Owner = tonumber(KEEP_OWNER)
local State = tonumber(KEEP_STATE)

if State == 1 then
	if Owner == 0 then return L"" end
	if Owner == 1 then return L"" end
	if Owner == 2 then return L"" end
elseif State == 2 then
	if Owner == 0 then return L"<icon29980> Outer Door: " end
	if Owner == 1 then return L"<icon29980> Outer Door: " end
	if Owner == 2 then return L"<icon29980> Outer Door: " end
elseif State == 3 then
	if Owner == 0 then return L"<icon29980> Inner Door: " end
	if Owner == 1 then return L"<icon29980> Inner Door: " end
	if Owner == 2 then return L"<icon29980> Inner Door: " end
elseif State == 4 then
	if Owner == 0 then return L"<icon29981> Lord: " end
	if Owner == 1 then return L"<icon29981> Lord: " end
	if Owner == 2 then return L"<icon29981> Lord: " end
elseif State == 5 then
	if Owner == 0 then return L"5,0" end
	if Owner == 1 then return L"Captured, Order Controlled" end
	if Owner == 2 then return L"Captured, Destro Controlled" end
elseif State == 6 then
	if Owner == 0 then return towstring(RoR_SoR.TextLock) end
	if Owner == 1 then return towstring(RoR_SoR.TextLock) end
	if Owner == 2 then return towstring(RoR_SoR.TextLock) end
else
	if Owner == 0 then return L"7,0" end
	if Owner == 1 then return L"7,1" end
	if Owner == 2 then return L"7,2" end
end
end


function RoR_SoR.GetKeepRank(KeepRank)
local Rank = tonumber(KeepRank)

if Rank == 1 then return L"1 <icon43>"
elseif Rank == 2 then return L"2 <icon43><icon43>"
elseif Rank == 3 then return L"3 <icon43><icon43><icon43>"
elseif Rank == 4 then return L"4 <icon43><icon43><icon43><icon43>"
elseif Rank == 5 then return L"5 <icon43><icon43><icon43><icon43><icon43>"
else return L""

end
end

function RoR_SoR.AnswerDialog(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,SelectedChannel,Type)
local TypeName = {"/say ","/party ","/warband ","/2 ","/t4 "}

	if Type == 1 then
			SendChatText(towstring(TypeName[SelectedChannel])..towstring(LineWord1)..L": "..towstring(LineWord3)..L" � "..towstring(LineWord2)..L" � "..towstring(LineWord4)..L" � "..towstring(LineWord5), L"")
	elseif Type == 2 then
			SendChatText(towstring(TypeName[SelectedChannel])..L"Declaring Attack on: "..towstring(LineWord1), L"")
	elseif Type == 3 then
			SendChatText(towstring(TypeName[SelectedChannel])..L"Declaring Defence on: "..towstring(LineWord1), L"")
	elseif Type == 4 then
			SendChatText(towstring(TypeName[SelectedChannel])..L"Relocate to: "..towstring(LineWord1), L"")
	elseif Type == 5 then
			SendChatText(towstring(TypeName[SelectedChannel])..towstring(LineWord1)..L" RvR Population: "..towstring(LineWord2)..L" � "..towstring(LineWord3)..towstring(LineWord4), L"")
	end
end


function RoR_SoR.Toggle()

RoR_SoR.Settings.Enabled = not RoR_SoR.Settings.Enabled

	RoR_SoR.SetWindowShow()
RoR_SoR.Enable()
end

function RoR_SoR.SetWindowShow()
	WindowSetShowing("RoR_SoR_Main_Window",RoR_SoR.Settings.Enabled)
	WindowSetShowing("RoR_SoR_Popper",RoR_SoR.Settings.Enabled)
	for k,v in pairs(RoR_SoR.Timers) do
		WindowSetShowing("SoR_"..k,RoR_SoR.Settings.Enabled)
	end
return
end

function RoR_SoR.OnCombat()
	if RoR_SoR.Settings.HideCombat == true then
		if GameData.Player.inCombat == true then
			WindowSetShowing("RoR_SoR_ButtonCombat",true)
			WindowSetShowing("RoR_SoR_Main_Window",false)
			WindowSetShowing("RoR_SoR_Popper",false)
			for k,v in pairs(RoR_SoR.Timers) do
			WindowSetShowing("SoR_"..k,false)
			end
		else
		WindowSetShowing("RoR_SoR_ButtonCombat",false)
		RoR_SoR.SetWindowShow()
		end
	else
	RoR_SoR.SetWindowShow()
	end
end


function RoR_SoR.OnScenario()
	if RoR_SoR.Settings.HideCombat == true then
		if (GameData.Player.isInScenario) == true then
			WindowSetShowing("RoR_SoR_ButtonCombat",true)
			WindowSetShowing("RoR_SoR_Main_Window",false)
			WindowSetShowing("RoR_SoR_Popper",false)
			for k,v in pairs(RoR_SoR.Timers) do
			WindowSetShowing("SoR_"..k,false)
			end
		else
		WindowSetShowing("RoR_SoR_ButtonCombat",false)
		RoR_SoR.SetWindowShow()
		end
	else
	WindowSetShowing("RoR_SoR_ButtonCombat",false)
	RoR_SoR.SetWindowShow()
	end
end



function RoR_SoR.BroadCastOption()
local LineWord1 = towstring(RoR_SoR.Lines[1])
local LineWord2 = towstring(RoR_SoR.Lines[2])
local LineWord3 = towstring(RoR_SoR.Lines[3])
local LineWord4 = towstring(RoR_SoR.Lines[4])
local LineWord5 = towstring(RoR_SoR.Lines[5])

local function MakeCallBack( SelectedOption1,SelectedOption2 )
		    return function() RoR_SoR.AnswerDialog(SelectedOption1,SelectedOption2) end
		end

local function MakeCallBack2( LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,SelectedType )
		    return function() RoR_SoR.ContextMenu1(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,SelectedType ) end
		end

    EA_Window_ContextMenu.CreateContextMenu( "BroadCast Selection", EA_Window_ContextMenu.CONTEXT_MENU_1, LineWord1 )
    EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )
	EA_Window_ContextMenu.AddCascadingMenuItem( L"<icon29962>BroadCast Status", MakeCallBack2(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,1 ), false, 1 )
	EA_Window_ContextMenu.AddCascadingMenuItem( L"<icon29960>Declare Attack", MakeCallBack2(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,2 ), false, 1 )
	EA_Window_ContextMenu.AddCascadingMenuItem( L"<icon29961>Declare Defence", MakeCallBack2(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,3 ), false, 1 )
	EA_Window_ContextMenu.AddCascadingMenuItem( L"<icon29963>Relocating", MakeCallBack2(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,4 ), false, 1 )
    EA_Window_ContextMenu.Finalize()

end

function RoR_SoR.POPOption()
local WindowName = tostring(SystemData.MouseOverWindow.name)
local Zone_Id = string.match( WindowName,"SoR_(%d+)POP")
local Line1 = towstring(GetZoneName(tonumber(Zone_Id)))
LineWord1,LineWord2,LineWord3,LineWord4,LineWord5 = L""

if RoR_SoR.Forts[tonumber(Zone_Id)] ~= nil then
local Color_A = RoR_SoR.InvFortColors[(RoR_SoR.Forts[tonumber(Zone_Id)])+1]
local Color_D = RoR_SoR.FortColors[(RoR_SoR.Forts[tonumber(Zone_Id)])+1]

LineWord1 = towstring(Line1)
LineWord2 = towstring(CreateHyperLink(L"0",L"Attackers: "..towstring(RoR_SoR.ZoneStatus[tostring(Zone_Id)].Attackers_Pop), {Color_A.r,Color_A.g,Color_A.b}, {} ))
LineWord3 = towstring(CreateHyperLink(L"0",L"Defenders: "..towstring(RoR_SoR.ZoneStatus[tostring(Zone_Id)].Defenders_Pop), {Color_D.r,Color_D.g,Color_D.b}, {} ))
LineWord4 = L""
LineWord5 = L"5"
else
LineWord1 = towstring(Line1)
LineWord2 = towstring(CreateHyperLink(L"0",L"Order: "..towstring(RoR_SoR.ZoneStatus[tostring(Zone_Id)].Order_Pop), {75,75,255}, {} ))
LineWord3 = towstring(CreateHyperLink(L"0",L"Destro: "..towstring(RoR_SoR.ZoneStatus[tostring(Zone_Id)].Destro_Pop), {255,25,25}, {} ))
LineWord4 = L""
	if RoR_SoR.ZoneStatus[tostring(Zone_Id)].AAO > 0 then
		local Color = RoR_SoR.RealmColors[(RoR_SoR.ZoneStatus[tostring(Zone_Id)].AAO)+3]
		LineWord4 = L" � AAO: "..towstring(CreateHyperLink(L"0",towstring(GetRealmName(tonumber(RoR_SoR.ZoneStatus[tostring(Zone_Id)].AAO)))..L" "..towstring(RoR_SoR.ZoneStatus[tostring(Zone_Id)].AAOMulti)..L"%", {Color.r,Color.g,Color.b}, {} ))
	end
 LineWord5 = L"5"
end


local function MakeCallBack( SelectedOption1,SelectedOption2 )
		    return function() RoR_SoR.AnswerDialog(SelectedOption1,SelectedOption2) end
		end

local function MakeCallBack2( LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,SelectedType )
		    return function() RoR_SoR.ContextMenu1(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,SelectedType ) end
		end

local function MakeCallBack3()
		    return function() RoR_SoR.InvolveDialog() end
		end

    EA_Window_ContextMenu.CreateContextMenu( "BroadCast Selection", EA_Window_ContextMenu.CONTEXT_MENU_1, LineWord1 )
    EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )
	EA_Window_ContextMenu.AddCascadingMenuItem( L"<icon29962>BroadCast Population", MakeCallBack2(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,5 ), false, 1 )
    if GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.CLAIM_KEEP, GuildWindowTabAdmin.GetLocalMemberTitleNumber()) and (GameData.Player.zone == tonumber(Zone_Id)) and (RoR_SoR.ZoneStatus[tostring(Zone_Id)].Tier > 1)then
		EA_Window_ContextMenu.AddMenuItem( L"<icon20204>+Involve Guild", MakeCallBack3(), false, true, 1)
	end

	EA_Window_ContextMenu.Finalize()

end

function RoR_SoR.ContextMenu1(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,SelectedType)
local function MakeCallBack( LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,SelectedChannel,Type)
		    return function() RoR_SoR.AnswerDialog(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,SelectedChannel,Type) end
		end
local TypeName = {"<icon29962>BroadCast Status","<icon29960>Declare Attack","<icon29961>Declare Defence","<icon29963>Relocate","<icon29963>BroadCast Population"}

    EA_Window_ContextMenu.CreateContextMenu( tostring(TypeName[SelectedType]), EA_Window_ContextMenu.CONTEXT_MENU_2,towstring(TypeName[SelectedType]) )
    EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_2 )
	EA_Window_ContextMenu.AddMenuItem( L"/Say", MakeCallBack(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,1,SelectedType ), false, true, EA_Window_ContextMenu.CONTEXT_MENU_2 )
	EA_Window_ContextMenu.AddMenuItem( L"/Party", MakeCallBack(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,2,SelectedType ), (not PartyUtils.IsPartyActive()), true, EA_Window_ContextMenu.CONTEXT_MENU_2 )
	EA_Window_ContextMenu.AddMenuItem( L"/Warband", MakeCallBack(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,3,SelectedType ), (not IsWarBandActive()), true, EA_Window_ContextMenu.CONTEXT_MENU_2 )
	EA_Window_ContextMenu.AddMenuItem( L"/Region", MakeCallBack(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,4,SelectedType ), (not GameData.Player.rvrZoneFlagged), true, EA_Window_ContextMenu.CONTEXT_MENU_2 )
	EA_Window_ContextMenu.AddMenuItem( L"/RvR", MakeCallBack(LineWord1,LineWord2,LineWord3,LineWord4,LineWord5,5,SelectedType ), false, true, EA_Window_ContextMenu.CONTEXT_MENU_2 )
	EA_Window_ContextMenu.Finalize(2, nil)

end



function RoR_SoR.OnTabRBU()
local function MakeCallBack( SelectedOption )
		    return function() RoR_SoR.ToggleShow(SelectedOption) end
		end

  EA_Window_ContextMenu.CreateContextMenu( SystemData.MouseOverWindow.name, EA_Window_ContextMenu.CONTEXT_MENU_1,L"SoR Options")
  EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )
  if RoR_SoR.Settings.ShowT1 == true then
  EA_Window_ContextMenu.AddMenuItem( L"<icon00057> Tier 1" , MakeCallBack(1), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem( L"<icon00058> Tier 1" , MakeCallBack(1), false, true )
 end

  if RoR_SoR.Settings.ShowT4 == true then
  EA_Window_ContextMenu.AddMenuItem( L"<icon00057> Tier 4" , MakeCallBack(2), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem( L"<icon00058> Tier 4" ,MakeCallBack(2), false, true )
 end

 if RoR_SoR.Settings.ShowForts == true then
  EA_Window_ContextMenu.AddMenuItem( L"<icon00057> Forts" , MakeCallBack(6), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem( L"<icon00058> Forts" ,MakeCallBack(6), false, true )
 end

  if RoR_SoR.Settings.ShowCity == true then
	EA_Window_ContextMenu.AddMenuItem( L"<icon00057> City sieges" , MakeCallBack(12), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem( L"<icon00058> City sieges" ,MakeCallBack(12), false, true )
 end

  if RoR_SoR.Settings.ShowCity_Status == true then
	EA_Window_ContextMenu.AddMenuItem( L"<icon00057> City Status" , MakeCallBack(14), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem( L"<icon00058> City Status" ,MakeCallBack(14), false, true )
 end

  if RoR_SoR.Settings.ShowPairings == true then
	EA_Window_ContextMenu.AddMenuItem( L"<icon00057> Locked Pairings" , MakeCallBack(13), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem( L"<icon00058> Locked Pairings" ,MakeCallBack(13), false, true )
 end

    if RoR_SoR.Settings.OnlyActive == true then
  EA_Window_ContextMenu.AddMenuItem( L"<icon00057> Only Your Zone" , MakeCallBack(9), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem(L"<icon00058> Only Your Zone" ,MakeCallBack(9), false, true )
   end

 	if RoR_SoR.Settings.StackDir == 1 then
	  EA_Window_ContextMenu.AddMenuItem( L"Set Stack up" , MakeCallBack(3), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem( L"Set Stack down" ,MakeCallBack(4), false, true )
 end
   if RoR_SoR.Settings.HideCombat == true then
  EA_Window_ContextMenu.AddMenuItem( L"<icon00057> Hide In Scenario" , MakeCallBack(5), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem(L"<icon00058> Hide In Scenario" ,MakeCallBack(5), false, true )
   end

  if RoR_SoR.Settings.DrawBackground == true then
  EA_Window_ContextMenu.AddMenuItem( L"<icon00057> Show Background" , MakeCallBack(7), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem(L"<icon00058> Show Background" ,MakeCallBack(7), false, true )
   end

   if RoR_SoR.Settings.DrawBanner == true then
  EA_Window_ContextMenu.AddMenuItem( L"<icon00057> Show Banners" , MakeCallBack(8), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem(L"<icon00058> Show Banners" ,MakeCallBack(8), false, true )
   end

   if RoR_SoR.Settings.ShowBONames == true then
  EA_Window_ContextMenu.AddMenuItem( L"<icon00057> Show BO Names" , MakeCallBack(10), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem(L"<icon00058> Show BO Names" ,MakeCallBack(10), false, true )
   end

   if RoR_SoR.Settings.ShowUnclaimed == true then
  EA_Window_ContextMenu.AddMenuItem( L"<icon00057> Show Unclaimed Label" , MakeCallBack(11), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem(L"<icon00058> Show Unclaimed Label" ,MakeCallBack(11), false, true )
   end

    if RoR_SoR.Settings.AAONumbers == true then
  EA_Window_ContextMenu.AddMenuItem( L"Show AAO Labels" , MakeCallBack(15), false, true )
  else
   EA_Window_ContextMenu.AddMenuItem(L"Show AAO Numbers" ,MakeCallBack(15), false, true )
   end


	--EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_SET_OPACITY ), EA_Window_ContextMenu.OnWindowOptionsSetAlpha, false, true )
EA_Window_ContextMenu.AddMenuItem( L"Set Alpha...", RoR_SoR.OnWindowOptionsSetOpacity, false, true )
	EA_Window_ContextMenu.AddMenuItem(L"Set Scale...", RoR_SoR.OnWindowOptionsSetScale, false, true )
	EA_Window_ContextMenu.AddMenuItem(L"Set Offset...", RoR_SoR.OnWindowOptionsSetOffset, false, true )

	EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )
	EA_Window_ContextMenu.AddMenuItem(L"Reset SoR Settings..." ,RoR_SoR.ResetDialog, false, true )
	EA_Window_ContextMenu.Finalize()
end

function RoR_SoR.ToggleShow(SelectedOption)
	if SelectedOption == 1 then RoR_SoR.Settings.ShowT1 = not RoR_SoR.Settings.ShowT1 ; RoR_SoR.ClearTier(1)
	elseif SelectedOption == 2 then RoR_SoR.Settings.ShowT4 = not RoR_SoR.Settings.ShowT4  ; RoR_SoR.ClearTier(2)
	elseif SelectedOption == 3 then RoR_SoR.Settings.StackDir = 2
	elseif SelectedOption == 4 then RoR_SoR.Settings.StackDir = 1
	elseif SelectedOption == 5 then RoR_SoR.Settings.HideCombat = not RoR_SoR.Settings.HideCombat ; RoR_SoR.OnCombat()
	elseif SelectedOption == 6 then RoR_SoR.Settings.ShowForts = not RoR_SoR.Settings.ShowForts	; RoR_SoR.ClearTier(3)
	elseif SelectedOption == 7 then RoR_SoR.Settings.DrawBackground	 = not RoR_SoR.Settings.DrawBackground
	elseif SelectedOption == 8 then RoR_SoR.Settings.DrawBanner	 = not RoR_SoR.Settings.DrawBanner
	elseif SelectedOption == 9 then RoR_SoR.Settings.OnlyActive	 = not RoR_SoR.Settings.OnlyActive ; RoR_SoR.ClearTier(0)
	elseif SelectedOption == 10 then RoR_SoR.Settings.ShowBONames	 = not RoR_SoR.Settings.ShowBONames
	elseif SelectedOption == 11 then RoR_SoR.Settings.ShowUnclaimed	 = not RoR_SoR.Settings.ShowUnclaimed
	elseif SelectedOption == 12 then RoR_SoR.Settings.ShowCity	 = not RoR_SoR.Settings.ShowCity
	elseif SelectedOption == 13 then RoR_SoR.Settings.ShowPairings	 = not RoR_SoR.Settings.ShowPairings
	elseif SelectedOption == 14 then RoR_SoR.Settings.ShowCity_Status = not RoR_SoR.Settings.ShowCity_Status; RoR_SoR.ZoneTimer["P_161"] = 0.1;RoR_SoR.ZoneTimer["P_162"] = 0.1
	elseif SelectedOption == 15 then RoR_SoR.Settings.AAONumbers	 = not RoR_SoR.Settings.AAONumbers
	end
	RoR_SoR.Enable()
	return
end

function RoR_SoR.ShowPopper ()
	if WindowGetAlpha("RoR_SoR_Popper") < 1 then
		WindowStartAlphaAnimation("RoR_SoR_Popper", Window.AnimationType.SINGLE_NO_RESET, WindowGetAlpha("RoR_SoR_Popper"), 1, c_DEFAULT_FADEIN_TIMER, false, 0, 0)
	end
    WindowSetShowing ("RoR_SoR_Popper", true)
    Popper.m_IsShowing      = true
    Popper.m_HideCountdown  = c_DEFAULT_HIDE_TIMER
return
end

function RoR_SoR.HidePopper ()
	if WindowGetAlpha("RoR_SoR_Popper") > 0 then
		WindowStartAlphaAnimation("RoR_SoR_Popper", Window.AnimationType.SINGLE_NO_RESET_HIDE, WindowGetAlpha("RoR_SoR_Popper"), 0, c_DEFAULT_FADEOUT_TIMER, false, 0, 0)
	end
    Popper.m_IsShowing      = false;
    Popper.m_HideCountdown  = c_DEFAULT_HIDE_TIMER
end

function RoR_SoR.HideChannel(channelId)
	for _, wndGroup in ipairs(EA_ChatWindowGroups) do
		if wndGroup.used == true then
			for tabId, tab in ipairs(wndGroup.Tabs) do
				local tabName = EA_ChatTabManager.GetTabName( tab.tabManagerId )
				if tabName then
					if tab.tabText ~= L"Debug" then
						LogDisplaySetFilterState(tabName.."TextLog", "Chat", channelId, false)
					else
						LogDisplaySetFilterState(tabName.."TextLog", "Chat", channelId, true)
						LogDisplaySetFilterColor(tabName.."TextLog", "Chat", channelId, 168, 187, 160 )
					end
				end
			end
		end
	end
end


function RoR_SoR.GetKeepClaim2(KeepId)
local Zone
local Keep_Number
if RoR_SoR.ZoneNames[GameData.Player.zone] == nil then
--d("Player Zone")
Zone = GameData.Player.zone
else
--d("Zone name")
Zone = RoR_SoR.ZoneNames[GameData.Player.zone][1]
end


if not DoesWindowExist("SoR_"..Zone) then return false end
--d("Window Exist")

if RoR_SoR.KEEP_IDs[tostring(Zone)] ~= nil then
	for i=1,2 do
		if KeepId == RoR_SoR.KEEP_IDs[tostring(Zone)][i].ID then
			Keep_Number = i
			break
		end
	end


if RoR_SoR.KEEP_IDs[tostring(Zone)][Keep_Number] == nil then return false end
--d("Keep Id exist")

local ObjectData = GetActiveObjectivesData()
local Keep_Data = RoR_SoR.KEEP_IDs[tostring(Zone)][Keep_Number]
--if Keep_Data.ID == nil then return false end

local KEEP_ID,KEEP_CLAIM,KEEP_OWNER,KEEP_STATE = nil,nil,nil,nil

	if ObjectData ~= nil and ObjectData[1] ~= nil then
	--d(L"Is Keep Claimed? "..towstring(RoR_SoR_T2.KeepClaim[T2ComboZone[GameData.Player.zone]][KEEP_ID]))
		if ObjectData[1].isKeep then
--d("in a keep")
							--search what ID the keep has
					if tostring(GetKeepName(tonumber(KeepId))) == tostring(ObjectData[1].name) then
						KEEP_ID = Keep_Data.ID
						KEEP_CLAIM = Keep_Data.Claim
						KEEP_OWNER = Keep_Data.Owner
						KEEP_STATE = Keep_Data.State
--d(L"Keep ID: "..towstring(KEEP_ID))
					else
					return false
					end
			if KEEP_CLAIM == "0" then
		--	d("Unclaimed")
				if (tonumber(ObjectData[1].controllingRealm) == tonumber(GameData.Player.realm)) then
		--		d("Your Realm Keep")
					if KEEP_STATE == 1 then
				--	d("Safe")
						if GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.CLAIM_KEEP, GuildWindowTabAdmin.GetLocalMemberTitleNumber()) then
				--		d("Have Claim Rights")
						return true
						else
				--		d("NO Claim Rights")
						return false
						end
					else
				--	d("Unsafe")
					return false
					end
				else
			--	d("Enemy keep")
				return false
				end
			else
			--d("Claimed")
			return false
			end
		return false
		end
	return false
	end
end
return false

end

function RoR_SoR.UpdateObjectives()
local Zone
if (GameData.Player.isInScenario) == true or (GameData.Player.isInSiege) == true then return end
if RoR_SoR.ZoneNames[GameData.Player.zone] == nil or RoR_SoR.ZoneNames[GameData.Player.zone][2] == nil then
--d("Player Zone")
Zone = GameData.Player.zone
else
--d("Zone name")
Zone = RoR_SoR.ZoneNames[GameData.Player.zone][2]
end

if DoesWindowExist("SoR_"..Zone) then

local BO_IDS = RoR_SoR.BO_IDs[tostring(Zone)]
local ObjectData = GetActiveObjectivesData()
if BO_IDS ~= nil then
		for k,v in pairs(BO_IDS) do
			if #ObjectData > 0 then
				if tonumber(v.ID) == tonumber(ObjectData[1].id) then
				WindowSetAlpha("SoR_"..Zone.."BO"..k.."Location",1)
				else
				WindowSetAlpha("SoR_"..Zone.."BO"..k.."Location",0)
				end
			else
				WindowSetAlpha("SoR_"..Zone.."BO"..k.."Location",0)
			end
		end
else
	return
end
end

end



function RoR_SoR.InvolveDialog()
local function MakeCallBack()
		    return function() SendChatText(L"]campaign join", L"") end
		end
DialogManager.MakeTwoButtonDialog( L"Involve your guild in the Warfront?", GetString(StringTables.Default.LABEL_YES),MakeCallBack(),GetString(StringTables.Default.LABEL_NO),nil )
end

function RoR_SoR.KeepClaimDialog()
local function MakeCallBack()
		    return function() SendChatText(L"]campaign keep claim", L"") end
		end
DialogManager.MakeTwoButtonDialog( L"Claim Keep?", GetString(StringTables.Default.LABEL_YES),MakeCallBack(),GetString(StringTables.Default.LABEL_NO),nil )
end



function RoR_SoR.KeepUnClaimDialog()
local KeepNumber = WindowGetId (SystemData.ActiveWindow.name)

local function MakeCallBack()
		    return function() SendChatText(L"/guildreleasekeep "..towstring(KeepNumber), L"") end
		end
DialogManager.MakeTwoButtonDialog( L"Release Keep?", GetString(StringTables.Default.LABEL_YES),MakeCallBack(),GetString(StringTables.Default.LABEL_NO),nil )
end


 function RoR_SoR.Offset(input)
 local input = tonumber(input)
 RoR_SoR.Settings.Offset = input
 EA_ChatWindow.Print(L"Offset is set to:"..towstring(input))
 end


function RoR_SoR.ResetDialog()
DialogManager.MakeTwoButtonDialog( L"Are you sure you want to reset SoR settings?", GetString(StringTables.Default.LABEL_YES),RoR_SoR.DefaultSettings,GetString(StringTables.Default.LABEL_NO),nil )
end


function RoR_SoR.OnWindowOptionsSetOpacity()
LabelSetText("RoR_SoR_OpacityTitleBarText",L"Alpha")
    local alpha = WindowGetAlpha( "RoR_SoR_Main_Window" )
    SliderBarSetCurrentPosition("RoR_SoR_OpacitySlider", alpha )

    WindowClearAnchors( "RoR_SoR_Opacity" )
    WindowAddAnchor( "RoR_SoR_Opacity", "center", EA_Window_ContextMenu.activeWindow, "center", 0 , 0 )

    WindowSetShowing( "RoR_SoR_Opacity", true )
end

function RoR_SoR.OnSlideWindowOptionsOpacity( slidePos )
    local alpha = slidePos

    -- Requirements call for 10%-100% range, not 0% to 100%.
    if (alpha < 0.01) then
        alpha = 0.01
    end
    if (EA_Window_ContextMenu.activeWindow ~= nil) then
        WindowSetAlpha( "RoR_SoR_Main_Window", alpha )
    end
end

function RoR_SoR.CloseSetOpacityWindow()
    WindowSetShowing( "RoR_SoR_Opacity", false )
end

function RoR_SoR.OnWindowOptionsSetScale()
  LabelSetText("RoR_SoR_ScaleTitleBarText",L"Scale")
	local uiScale = InterfaceCore.GetScale()
    local scale = WindowGetScale("RoR_SoR_Main_Window" )
    SliderBarSetCurrentPosition("RoR_SoR_ScaleSlider", scale/1.5 )

   WindowClearAnchors( "RoR_SoR_Scale" )
   WindowAddAnchor( "RoR_SoR_Scale", "topleft", "Root", "topleft", SystemData.MousePosition.x/uiScale,SystemData.MousePosition.y/uiScale )
    WindowSetShowing( "RoR_SoR_Scale", true )

end

function RoR_SoR.OnSlideWindowOptionsScale( slidePos )
    local scale = slidePos*1.5

    if (scale < 0.3) then
        scale = 0.3
    end
    if (EA_Window_ContextMenu.activeWindow ~= nil) then
        WindowSetScale("RoR_SoR_Main_Window" , scale )
    end
end

function RoR_SoR.CloseSetScaleWindow()
    WindowSetShowing( "RoR_SoR_Scale", false )
end


function RoR_SoR.OnWindowOptionsSetOffset()
  LabelSetText("RoR_SoR_OffsetTitleBarText",L"Offset")
    local offset = RoR_SoR.Settings.Offset
    SliderBarSetCurrentPosition("RoR_SoR_OffsetSlider",(0.5)+(offset/100))

   WindowClearAnchors( "RoR_SoR_Offset" )
   WindowAddAnchor( "RoR_SoR_Offset", "center", EA_Window_ContextMenu.activeWindow, "center", 0 , 0 )

    WindowSetShowing( "RoR_SoR_Offset", true )
end

function RoR_SoR.OnSlideWindowOptionsOffset( slidePos )
    local offset = slidePos*100

    if (EA_Window_ContextMenu.activeWindow ~= nil) then
        RoR_SoR.Settings.Offset = (-50)+offset
    end
	RoR_SoR.Restack()
end

function RoR_SoR.CloseSetOffsetWindow()
    WindowSetShowing( "RoR_SoR_Offset", false )
end

 function RoR_SoR.Calc_Difference(value1,value2)
 if value1 > value2 then
	return L"-"..towstring(value2-value1)
else
	return L"+"..towstring(value1-value2)
end
end


function RoR_SoR.DefaultSettings()
RoR_SoR.Settings ={
ShowT1 = true,
ShowT4 = false,
StackDir = 1,
Offset = 1,
Enabled = false,
HideCombat = false,
AAONumbers = false,
HideScenario = false,
ShowForts = false,
DrawBackground = true,
DrawBanner = true,
OnlyActive = false,
ShowBONames = true,
ShowUnclaimed = true,
ShowPairings = true,
ShowCity = false,
ShowCity_Status = false,
Version = version
}
WindowSetScale("RoR_SoR_Main_Window",0.753)
WindowClearAnchors("RoR_SoR_Main_Window")
WindowAddAnchor("RoR_SoR_Main_Window","top", "Root","top", 350,100)
WindowSetOffsetFromParent("RoR_SoR_Main_Window",350,100)

EA_ChatWindow.Print(L"State of Realm has been resetted to default settings")
end
