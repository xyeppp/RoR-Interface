----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
local Version = "1.3a"
local Filter_Type = 0 -- 0 is all, 1 is by class

local Is_StateMachine_Running = false
local SEND_BEGIN = 1
local SEND_FINISH = 2
local IsQuedSolo,IsQuedGroup,GroupQueue = false,false,false

local Qualified_Colors = {["Rank"]={["true"]={r=255, g=75, b=75},["false"]={r=255,g=255,b=255}},["Other"]={["true"]={r=125, g=125, b=125},["false"]={r=255,g=255,b=255}}}
 local StatFlags = {
				[1]={
				[Button.ButtonState.NORMAL]={126,0},
				[Button.ButtonState.HIGHLIGHTED]={125,113},
				[Button.ButtonState.PRESSED]={126,226},
				[Button.ButtonState.PRESSED_HIGHLIGHTED]={126,226}	
			
			},
				[2]={
				[Button.ButtonState.NORMAL]={0,226},
				[Button.ButtonState.HIGHLIGHTED]={-1,113},
				[Button.ButtonState.PRESSED]={0,0},			
				[Button.ButtonState.PRESSED_HIGHLIGHTED]={0,0}		
			}
			}

local RulesetText = {
[1]=L"Ranked is a 6v6 scenario deathmatch that has two modes, Solo and Group. In Ranked Solo you can only queue up solo, but the match itself is still played as a group and coordinating with your team is highly encouraged. Each team will have 2 tanks, 2 DPS and 2 healers. In Ranked Group you can queue up with a team of 6 players with any setup of your choice.\n\nEach kill gives 50 points. After one team gets 10 kills they have won the match. If the other team surrenders there is a flag in the middle that can be captured to win the match. Capturing the flag takes one minute and is interrupted if any player in the scenario engages in combat. If none of the above happens during 10 minutes the winner is declared based on the score, or is declared a draw if both teams scores are equal.",
[2]=L"The system will match both order and destruction players into mixed teams and attempt to make them close to each other in rating. Each team will have at least one tank with a single target knockback and one DPS with access to an incoming heal debuff. It is up to the players to spec it on classes that have those tools available.",
[3]=L"At the start of each season all players start with a rating of 0. Winning matches will increase the rating over the course of the season.\nPlayers with a rating of 0 can only be matched with players up to a rating of 700.For players above 0 rating the maximum bracket size is 1200. The bracket size shrinks the more games are ongoing.",
[4]=L"To queue for Ranked Solo you need to have an average item level above 52 on your equipped gear, and have talismans slotted in all gear. It is highly advised to use the full range of consumables.",
[5]=L"After a season ends the top 100 players receive up to 1000 Triumphant Emblems based on their leaderboard position. In addition the top 4 players of each class also receive up to 1000 Triumphant Emblems.\n\nThere are also unique trophies and titles available for players who ranked between 1st and 10th position within each class. Some of these rewards are unique to those who placed 1st within their class.",
[6]=L"To improve team organisation and communication the community has set up a discord server at <LINK data=\"URL:7\" text=\"https://discord.gg/NPWzhJuBZj \" color=\"255,25,25\">",
[7]=L"After each season a ranked finals game is organized by the community between the top six players of each realm. See the community discord for details.",
[8]=L"Between each season there is a few weeks of pre-season. The point of the pre-season is to get the class balance patch out and test it for a few weeks, fix bugs and balance things that didn't go as planned. Then, when it's done, the next season launches and the meta stays unchanged for its full duration."
}

RulesetTopic = {[1]=L"About",[2]=L"Matchmaking System",[3]=L"MMR Brackets",[4]=L"Gear Requirements",[5]=L"Seasonal Rewards",[6]=L"Community discord",[7]=L"Ranked Final",[8]=L"Pre-Season"}

local Task_Texture = {["true"]="CircleDone",["false"]="CircleNotDone"}

local Row_Colors = {[1]={r=12, g=47, b=158,a=0.3},[2]={r=158, g=12, b=13,a=0.3}}
local Rating_Color = {[0]=DefaultColor.LIGHT_GRAY,[1]=DefaultColor.GOLD}
local Tier_Title = {[0]=L"Silver",[1]=L"Gold"}

local RowColors = {[0]={r=255, g=255, b=255,a=0.07},[1]={r=0, g=0, b=0,a=0.4}}
--local Guild_Colors = {[1]={r=25, g=25, b=155,a=0.2},[2]={r=155, g=25, b=25,a=1}}
local Guild_Colors = {[1]={r=100, g=100, b=255,a=1},[2]={r=255, g=100, b=100,a=1}}
local queuedScenarioData
local DoSearch = false
local FindMe = false
local JoinDisabled = false

local Career_Icon= {["Ironbreaker"]=1,["Slayer"]=2,["RunePriest"]=3,["Engineer"]=4,["BlackOrc"]=5,["Choppa"]=6,["Shaman"]=7,["SquigHerder"]=8,["WitchHunter"]=9,["Knight"]=10,["BrightWizard"]=11,["WarriorPriest"]=12,["Chosen"]=13,["Marauder"]=14,["Zealot"]=15,["Magus"]=16,["Swordmaster"]=17,["ShadowWarrior"]=18,["WhiteLion"]=19,["Archmage"]=20,["Blackguard"]=21,["WitchElf"]=22,["Disciple"]=23,["Sorcerer"]=24}
local SelectedPage = 1
local SelectedSeason = 0
local selectedType = 1
local Max_Pages = 12
local CurrentSeason = 0
local PlayerName = wstring.sub(GameData.Player.name,1,-3)
local SelectedTab = 0
LBEventTasks = {}

RoR_RankedLeaderboard = {}
RoR_RankedLeaderboard.Guilds = {}
RoR_RankedLeaderboard.sortData = {"Rank","Career","Name","Renown","Wins","Losses","Draws","Total","Rate","Guild","Rating"}
RoR_RankedLeaderboard.StateTimer = 5 --Update Timer

-- Sorting Parameters for the Player List
RoR_RankedLeaderboard.playersData = nil
RoR_RankedLeaderboard.playerListOrder = {}


-- Keeps tabs on the currently selected player
RoR_RankedLeaderboard.SelectedPlayerDataIndex	= 0
RoR_RankedLeaderboard.SelectedPlayerWindow		= ""
RoR_RankedLeaderboard.SelectedPlayerInListIndex = 0


function RoR_RankedLeaderboard_LabelFormat(windowName,TextLabel,TextValue)
WindowSetDimensions( windowName.."Dott", 300, 25 ) --reset the Dott label

LabelSetText(windowName.."Label",towstring(TextLabel))
LabelSetText(windowName.."Value",towstring(TextValue))	
local LabelW1,_ = LabelGetTextDimensions(windowName.."Label")
local LabelW2,_ = LabelGetTextDimensions(windowName.."Value")

WindowSetDimensions( windowName.."Dott", 300-(LabelW1+LabelW2), 25 )	
--LabelSetText(windowName.."Dott", L"............................................................................................................................................................" )
return
end

function RoR_RankedLeaderboard_LabelFormat2(windowName,TextLabel,TextValue,StringWidth)
WindowSetDimensions( windowName, 400, 25 ) --reset the Label label
WindowSetDimensions( windowName.."Dott", 400, 25 ) --reset the Dott label
WindowSetDimensions( windowName.."Label", 400, 25 ) --reset the Label label
LabelSetText(windowName.."Label",towstring(TextLabel))
LabelSetText(windowName.."Value",towstring(TextValue))	
local LabelW1,_ = LabelGetTextDimensions(windowName.."Label")
local LabelW2,_ = LabelGetTextDimensions(windowName.."Value")
local Str_Width = StringWidth or 300

WindowSetDimensions( windowName.."Dott", Str_Width-(LabelW1+LabelW2), 25 )	
return
end



local function FilterPlayerList()	

    RoR_RankedLeaderboard.playerListOrder = {}
    if( RoR_RankedLeaderboard.playersData == nil ) then
        return
    end

    for dataIndex, data in ipairs( RoR_RankedLeaderboard.playersData ) do
        table.insert(RoR_RankedLeaderboard.playerListOrder, dataIndex)
    end

end

local function UpdatePlayerList()

    -- Sort, and Update
    FilterPlayerList()
    ListBoxSetDisplayOrder( "RoR_RankedLeaderboardListPlayerList", RoR_RankedLeaderboard.playerListOrder )
end

-- The format is: GRP_STATS=<charid>:<stat1value>;<stat2value>;<stat3value>;<stat4value>|<charid>:<stat1value>;<stat2value>;<stat3value>;<stat4value>
local function UpdateLeaderBoardData(text)
GuildWindowTabRecruit.SearchForGuilds()

	if text == nil then return end
	local LIST_INFO
	local LIST_INFO_RANGE
	local LIST_DATA
	local LIST_HEADER
	local LIST_SPLIT_TEXT
	local LIST_CAREER	
	
	if text:find(L"LB_LIST_CAREER") then
	Filter_Type = 1
	LIST_INFO = text:match(L"LB_LIST_CAREER=(.+):.")
		if LIST_INFO == nil or LIST_INFO == L"" then  
			ListBoxSetDisplayOrder( "RoR_RankedLeaderboardListPlayerList", {})		
		return
		end	
	LIST_INFO_RANGE = wstring.len(LIST_INFO)+wstring.len(L"LB_LIST_CAREER=")
	LIST_DATA = wstring.sub(text,LIST_INFO_RANGE,-1)
	LIST_HEADER = StringSplit(tostring(LIST_INFO), ";")
	LIST_SPLIT_TEXT = StringSplit(tostring(LIST_DATA), "|")	
	
	else
	Filter_Type = 0
	LIST_INFO = text:match(L"LB_LIST=(.+):.")
		if LIST_INFO == nil or LIST_INFO == L"" then  
			ListBoxSetDisplayOrder( "RoR_RankedLeaderboardListPlayerList", {})		
		return
		end		
	LIST_INFO_RANGE = wstring.len(LIST_INFO)+wstring.len(L"LB_LIST=")
	LIST_DATA = wstring.sub(text,LIST_INFO_RANGE,-1)
	LIST_HEADER = StringSplit(tostring(LIST_INFO), ";")
	LIST_SPLIT_TEXT = StringSplit(tostring(LIST_DATA), "|")
	end
RoR_RankedLeaderboard.Ranked_List_Header = {
page=tonumber(LIST_HEADER[1]),
page_count=tonumber(LIST_HEADER[2]),
season_id=tonumber(LIST_HEADER[3]),
rating_type=tonumber(LIST_HEADER[4]),
}


WindowAssignFocus("SocialWindowTabSearchEditBoxCareerName", false)
RoR_RankedLeaderboard.playersData = {}
--RoR_Ranked.Ranked_List = {}
	for k,v in ipairs(LIST_SPLIT_TEXT) do
	local Data_Split = StringSplit(tostring(v), ";")
		RoR_RankedLeaderboard.playersData[k] = {
			ratingtype=tonumber(Data_Split[1]),
			season_id=tonumber(Data_Split[2]),
			rank=tonumber(Data_Split[3]),
			rating=tonumber(Data_Split[4]),
			character_id=tonumber(Data_Split[5]),
			character_name=towstring(Data_Split[6]),
			renown_rank=tonumber(Data_Split[7]),
			career=Icons.GetCareerIconIDFromCareerLine(tonumber(Data_Split[8])),
			realm=tonumber(Data_Split[9]),
			guild_id=tonumber(Data_Split[10]),
			guild_name=towstring(Data_Split[11]),		
			wins=tonumber(Data_Split[12]),
			losses=tonumber(Data_Split[13]),
			draws=tonumber(Data_Split[14]),
			match_needed=tonumber(Data_Split[15]),
			class_rank=tonumber(Data_Split[16])
		}
		RoR_RankedLeaderboard.playersData[k].total_matches = RoR_RankedLeaderboard.playersData[k].wins + RoR_RankedLeaderboard.playersData[k].draws + RoR_RankedLeaderboard.playersData[k].losses
		
		
		if (RoR_RankedLeaderboard.playersData[k].wins + RoR_RankedLeaderboard.playersData[k].losses) > 0 then
			RoR_RankedLeaderboard.playersData[k].win_rate = (RoR_RankedLeaderboard.playersData[k].wins/(RoR_RankedLeaderboard.playersData[k].wins + RoR_RankedLeaderboard.playersData[k].losses))*100
		else
			RoR_RankedLeaderboard.playersData[k].win_rate = 0
		end
				
		
		if DoSearch == true then			
			if FindMe == false then
			local TextBoxText = TextEditBoxGetText("RoR_RankedLeaderboardListSearchBox")						
			if RoR_RankedLeaderboard.playersData[k].character_name == TextBoxText then
				RoR_RankedLeaderboard.SelectedPlayerWindow = k				
			end
			else
			if RoR_RankedLeaderboard.playersData[k].character_name == PlayerName then
				RoR_RankedLeaderboard.SelectedPlayerWindow = k		
				FindMe = false
			end
			end
		end


		if Filter_Type == 1 then
			RoR_RankedLeaderboard.playersData[k].rank = ((RoR_RankedLeaderboard.Ranked_List_Header.page-1)*15)+k
		end

	local _Colors = Guild_Colors[RoR_RankedLeaderboard.playersData[k].realm]

		if RoR_RankedLeaderboard.Guilds[tostring(RoR_RankedLeaderboard.playersData[k].guild_name)] == true then
			RoR_RankedLeaderboard.playersData[k].guild_name = CreateHyperLink(L"GUILD:"..towstring(RoR_RankedLeaderboard.playersData[k].guild_id),towstring(RoR_RankedLeaderboard.playersData[k].guild_name), {_Colors.r,_Colors.g,_Colors.b}, {} )
		else
			RoR_RankedLeaderboard.playersData[k].guild_name = CreateHyperLink(L"GUILD:"..towstring(RoR_RankedLeaderboard.playersData[k].guild_id),towstring(RoR_RankedLeaderboard.playersData[k].guild_name), {125,125,125}, {} )
		end

	end

    UpdatePlayerList()	
	

	--update Page Combobox:
	ComboBoxClearMenuItems("RoR_RankedLeaderboardListPageCombo")
	Max_Pages = RoR_RankedLeaderboard.Ranked_List_Header.page_count
	for i=1,Max_Pages do
		ComboBoxAddMenuItem("RoR_RankedLeaderboardListPageCombo",towstring(i))
	end
		
		
	WindowSetShowing("RoR_RankedLeaderboardListPrevButton",RoR_RankedLeaderboard.Ranked_List_Header.page>1)
	WindowSetShowing("RoR_RankedLeaderboardListPagePrev",RoR_RankedLeaderboard.Ranked_List_Header.page>1)
	
	WindowSetShowing("RoR_RankedLeaderboardListNextButton",RoR_RankedLeaderboard.Ranked_List_Header.page<RoR_RankedLeaderboard.Ranked_List_Header.page_count)	
	WindowSetShowing("RoR_RankedLeaderboardListPageNext",RoR_RankedLeaderboard.Ranked_List_Header.page<RoR_RankedLeaderboard.Ranked_List_Header.page_count)	
	WindowSetAlpha("RoR_RankedLeaderboardListPlayerListHeaderImage",0.1)
		
	if DoSearch == false then
		ComboBoxSetSelectedMenuItem("RoR_RankedLeaderboardListPageCombo",SelectedPage)

		RoR_RankedLeaderboard.SelectedPlayerDataIndex	= 0
		RoR_RankedLeaderboard.SelectedPlayerWindow		= ""
		RoR_RankedLeaderboard.SelectedPlayerInListIndex = 0
	
	else
		ComboBoxSetSelectedMenuItem("RoR_RankedLeaderboardListCareerCombo",1)
		ComboBoxSetSelectedMenuItem("RoR_RankedLeaderboardListPageCombo",RoR_RankedLeaderboard.Ranked_List_Header.page)
		RoR_RankedLeaderboard.HighlightPlayerInList( RoR_RankedLeaderboard.SelectedPlayerWindow, true, false )				
		DoSearch = false
	end
	DoSearch = false
	FindMe = false
end

local function UpdateSeasonData(text)

	local LIST_INFO
	local LIST_SPLIT_TEXT
	if text:find(L"LB_SEASONS") then
	LIST_INFO = text:match(L"LB_SEASONS=(.+)")
	LIST_SPLIT_TEXT = StringSplit(tostring(LIST_INFO), "|")	
	end

RoR_RankedLeaderboard.SeasonData = {}

for k,v in ipairs(LIST_SPLIT_TEXT) do
local Data_Split = StringSplit(tostring(v), ";")
RoR_RankedLeaderboard.SeasonData[k] = {
season_id=tonumber(Data_Split[1]),
season_name=towstring(Data_Split[2]),
season_startweek=tonumber(Data_Split[3]),	
season_endweek=tonumber(Data_Split[4]),	
season_ismainseason=towstring(Data_Split[5]),
season_startdate=towstring(Data_Split[6]),
season_enddate=towstring(Data_Split[7]),
season_number = tonumber(Data_Split[2]:match(".(%d)"))
}
end
ComboBoxClearMenuItems("RoR_RankedLeaderboardListSeasonCombo")
--select the latest season
	SelectedSeason = #RoR_RankedLeaderboard.SeasonData
	for i=1,#RoR_RankedLeaderboard.SeasonData do
		ComboBoxAddMenuItem("RoR_RankedLeaderboardListSeasonCombo",towstring(RoR_RankedLeaderboard.SeasonData[i].season_name))
	end
ComboBoxSetSelectedMenuItem( "RoR_RankedLeaderboardListSeasonCombo", SelectedSeason )

CurrentSeason = #RoR_RankedLeaderboard.SeasonData

	RoR_RankedLeaderboard.SelectedPlayerDataIndex	= 0
	RoR_RankedLeaderboard.SelectedPlayerWindow		= ""
	RoR_RankedLeaderboard.SelectedPlayerInListIndex = 0
	
	SendChatText(L"]ranked playerstats "..towstring(CurrentSeason) , L"")
	SelectedTab = 2
	RoR_RankedLeaderboard.ToggleLeaderboards()
	
	--ButtonSetTextColor("RoR_RankedLeaderboardTab2",Button.ButtonState.PRESSED,DefaultColor.GOLD.r,DefaultColor.GOLD.g,DefaultColor.GOLD.b)
	--ButtonSetText("RoR_RankedLeaderboardTab2",L"Ranked\n"..towstring(RoR_RankedLeaderboard.SeasonData[CurrentSeason].season_name))
local Season_Info = RoR_RankedLeaderboard.SeasonData[CurrentSeason].season_ismainseason
local normal = StatFlags[tonumber(Season_Info)+1][Button.ButtonState.NORMAL]
local highlighted = StatFlags[tonumber(Season_Info)+1][Button.ButtonState.HIGHLIGHTED]
local pressed = StatFlags[tonumber(Season_Info)+1][Button.ButtonState.PRESSED]
local pressedhighlighted = StatFlags[tonumber(Season_Info)+1][Button.ButtonState.PRESSED_HIGHLIGHTED]

ButtonSetTexture("RoR_RankedLeaderboardTab2", Button.ButtonState.NORMAL, "Stats_Flag", normal[1],normal[2]);
ButtonSetTexture("RoR_RankedLeaderboardTab2", Button.ButtonState.HIGHLIGHTED, "Stats_Flag",highlighted[1],highlighted[2]);
ButtonSetTexture("RoR_RankedLeaderboardTab2", Button.ButtonState.PRESSED, "Stats_Flag", pressed[1],pressed[2]);
ButtonSetTexture("RoR_RankedLeaderboardTab2", Button.ButtonState.PRESSED_HIGHLIGHTED, "Stats_Flag", pressedhighlighted[1],pressedhighlighted[2]);
--ButtonSetText("RoR_RankedLeaderboardTab2",L"\n"..towstring(RoR_RankedLeaderboard.SeasonData[CurrentSeason].season_number))
LabelSetText("RoR_RankedLeaderboardTab2Label",towstring(RoR_RankedLeaderboard.SeasonData[CurrentSeason].season_number))
end

local function UpdatePlayerData(text)

	local LIST_INFO
	local LIST_SPLIT_TEXT = {}
	if text:find(L"LB_PLAYERSTATS") then
	LIST_INFO = text:match(L"LB_PLAYERSTATS=(.+)")
	LIST_INFO =StringSplit(tostring(LIST_INFO),"|")
	
	for i=1,2 do
	LIST_SPLIT_TEXT[i] = StringSplit(tostring(LIST_INFO[i]), ";")	
	end
	end

--<ratingtype>;<season_id>;<rank>;<rating>;<character_id>;<character_name>;<renown_rank>;<career>;<realm>;<guild_id>;<guild_name>;<wins>;<losses>;<draws>
RoR_RankedLeaderboard.PlayerStatsData = {}
for i=1,2 do
RoR_RankedLeaderboard.PlayerStatsData[i] = {
ratingtype=tonumber(LIST_SPLIT_TEXT[i][1]),
season_id=tonumber(LIST_SPLIT_TEXT[i][2]),
rank=tonumber(LIST_SPLIT_TEXT[i][3]),	
rating=tonumber(LIST_SPLIT_TEXT[i][4]),	
character_id=tonumber(LIST_SPLIT_TEXT[i][5]),
character_name=towstring(LIST_SPLIT_TEXT[i][6]),
renown_rank=tonumber(LIST_SPLIT_TEXT[i][7]),
career=towstring(LIST_SPLIT_TEXT[i][8]),
realm=tonumber(LIST_SPLIT_TEXT[i][9]),
guild_id=tonumber(LIST_SPLIT_TEXT[i][10]),
guild_name=towstring(LIST_SPLIT_TEXT[i][11]),
wins=tonumber(LIST_SPLIT_TEXT[i][12]),
losses=tonumber(LIST_SPLIT_TEXT[i][13]),
draws=tonumber(LIST_SPLIT_TEXT[i][14]),
match_needed=tonumber(LIST_SPLIT_TEXT[i][15]),
page=tonumber(LIST_SPLIT_TEXT[i][16])
}
end

	LabelSetText("RoR_RankedLeaderboardStatsTitle",towstring(RoR_RankedLeaderboard.PlayerStatsData[1].rating)..L" MMR      Rank "..towstring(RoR_RankedLeaderboard.PlayerStatsData[1].rank))
	LabelSetText("RoR_RankedLeaderboardStatsTitle2",towstring(RoR_RankedLeaderboard.PlayerStatsData[2].rating)..L" MMR      Rank "..towstring(RoR_RankedLeaderboard.PlayerStatsData[2].rank))

	--LabelSetText("RoR_RankedLeaderboardStatsTier",L"~"..Tier_Title[RoR_RankedLeaderboard.RankedTier.solo_tier]..L" Tier~")


	--RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsClass0",L"Rank",towstring(RoR_RankedLeaderboard.PlayerStatsData[1].rank))
	--RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsClass1",L"MMR",towstring(RoR_RankedLeaderboard.PlayerStatsData[1].rating))	
	RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsClass0",L"Matches",towstring(RoR_RankedLeaderboard.PlayerStatsData[1].losses+RoR_RankedLeaderboard.PlayerStatsData[1].wins+RoR_RankedLeaderboard.PlayerStatsData[1].draws))	
	RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsClass1",L"Wins",towstring(RoR_RankedLeaderboard.PlayerStatsData[1].wins))		
	RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsClass2",L"Losses",towstring(RoR_RankedLeaderboard.PlayerStatsData[1].losses))	
	RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsClass3",L"Draws",towstring(RoR_RankedLeaderboard.PlayerStatsData[1].draws))

if (RoR_RankedLeaderboard.PlayerStatsData[1].wins + RoR_RankedLeaderboard.PlayerStatsData[1].losses) > 0 then
	RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsClass4",L"Win %",towstring((RoR_RankedLeaderboard.PlayerStatsData[1].wins/(RoR_RankedLeaderboard.PlayerStatsData[1].wins + RoR_RankedLeaderboard.PlayerStatsData[1].losses))*100)..L"%")
else
	RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsClass4",L"Win %",L"0%")
end
	--RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsClass4",L"Matches Needed",towstring(RoR_RankedLeaderboard.PlayerStatsData[1].match_needed))

	--RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsGroup0",L"Rank",towstring(RoR_RankedLeaderboard.PlayerStatsData[2].rank))
	--RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsGroup1",L"MMR",towstring(RoR_RankedLeaderboard.PlayerStatsData[2].rating))	
	RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsGroup0",L"Matches",towstring(RoR_RankedLeaderboard.PlayerStatsData[2].losses+RoR_RankedLeaderboard.PlayerStatsData[2].wins+RoR_RankedLeaderboard.PlayerStatsData[2].draws))	
	RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsGroup1",L"Wins",towstring(RoR_RankedLeaderboard.PlayerStatsData[2].wins))		
	RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsGroup2",L"Losses",towstring(RoR_RankedLeaderboard.PlayerStatsData[2].losses))	
	RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsGroup3",L"Draws",towstring(RoR_RankedLeaderboard.PlayerStatsData[2].draws))

if (RoR_RankedLeaderboard.PlayerStatsData[2].wins + RoR_RankedLeaderboard.PlayerStatsData[2].losses) > 0 then
	RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsGroup4",L"Win %",towstring((RoR_RankedLeaderboard.PlayerStatsData[2].wins/(RoR_RankedLeaderboard.PlayerStatsData[2].wins + RoR_RankedLeaderboard.PlayerStatsData[2].losses))*100)..L"%")
else
	RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsGroup4",L"Win %",L"0%")
end
	--RoR_RankedLeaderboard_LabelFormat("RoR_RankedLeaderboardStatsGroup4",L"Matches Needed",towstring(RoR_RankedLeaderboard.PlayerStatsData[2].match_needed))


--	LabelSetText("RoR_RankedLeaderboardStats_BG_Text",L"Ranked")
--	LabelSetText("RoR_RankedLeaderboardStats_BG_Text2",towstring(RoR_RankedLeaderboard.SeasonData[RoR_RankedLeaderboard.PlayerStatsData[1].season_id].season_name))
	
	RoR_RankedLeaderboard.SelectedPlayerDataIndex	= 0
	RoR_RankedLeaderboard.SelectedPlayerWindow		= ""
	RoR_RankedLeaderboard.SelectedPlayerInListIndex = 0
	
	RoR_RankedLeaderboard.OnRButtonUp()
end

function RoR_RankedLeaderboard.OnChatLogUpdated(updateType, filterType)
	if updateType ~= SystemData.TextLogUpdate.ADDED then return end
	if filterType ~= SystemData.ChatLogFilters.CHANNEL_9 then return end

	local _, filterId, text = TextLogGetEntry( "Chat", TextLogGetNumEntries("Chat") - 1 )

	if text:find(L"LB_LIST") then
		RoR_RankedLeaderboard.LeaderBoardDataString = text
		RoR_RankedLeaderboard.playersData = nil
            UpdateLeaderBoardData(text)
	elseif text:find(L"LB_SEASONS") then
	RoR_RankedLeaderboard.SeasonDataString = text
		UpdateSeasonData(text)	
	elseif text:find(L"LB_PLAYERSTATS") then
	RoR_RankedLeaderboard.PlayerDataString = text
		UpdatePlayerData(text)		
	elseif text:find(L"SCPlayers") then 
			RoR_RankedLeaderboard.Text_Stream_Fetch(text)
	elseif text:find(L"LB_SEARCH=0") then
			RoR_RankedLeaderboard.ResetBoard()
	end
end

----------------------------------------------------------------
-- RoR_RankedLeaderboard Functions
----------------------------------------------------------------
function RoR_RankedLeaderboard.GuildResults(resultsTable)
local GuildResult = resultsTable
for k,v in pairs(GuildResult) do
	RoR_RankedLeaderboard.Guilds[tostring(v.name)] = true
 end
end


-- OnInitialize Handler
function RoR_RankedLeaderboard.Initialize()

 if RoR_RankedLeaderboard.Hasinit == nil or RoR_RankedLeaderboard.Hasinit == false then
 RoR_RankedLeaderboard.Hasinit = true
 --WindowSetScale("RoR_RankedLeaderboard",1)
 end
 

    RegisterEventHandler(TextLogGetUpdateEventId("Chat"), "RoR_RankedLeaderboard.OnChatLogUpdated")
	RegisterEventHandler( SystemData.Events.SCENARIO_ACTIVE_QUEUE_UPDATED,  "RoR_RankedLeaderboard.UpdateScenarioQueueData" )
	RegisterEventHandler( SystemData.Events.GUILD_RECRUITMENT_SEARCH_RESULTS_UPDATED, "RoR_RankedLeaderboard.GuildResults") 

  RegisterEventHandler( SystemData.Events.GROUP_UPDATED, "RoR_RankedLeaderboard.UpdateQue")
  RegisterEventHandler( SystemData.Events.BATTLEGROUP_UPDATED, "RoR_RankedLeaderboard.UpdateQue")
	RegisterEventHandler( SystemData.Events.GROUP_PLAYER_ADDED,"RoR_RankedLeaderboard.UpdateQue" )
	
	CreateWindow("RewardInfoLegends",false)
	CreateWindow("RoR_RankedLeaderboard_Toggler",true)
	LayoutEditor.RegisterWindow( "RoR_RankedLeaderboard_Toggler", L"LeaderBoard", L"LeaderBoard", false, false, true, nil )
	LayoutEditor.RegisterWindow( "RoR_RankedLeaderboard", L"RankedLeaderboard", L"LeaderBoard", false, false, true, nil )	
	ListBoxSetDisplayOrder( "RoR_RankedLeaderboardListPlayerList", {})
	    
    if LibSlash then LibSlash.RegisterSlashCmd("Leaderboard", function() RoR_RankedLeaderboard.ToggleShowing() end) end

	PlayerName = wstring.sub(GameData.Player.name,1,-3)
	WindowSetShowing("EA_Window_OverheadMapAdvWarButton",false)

	--Creating a StateMachine for updates instead of manual timers (saves me the hassel to have onUpdate that runs every frame)
	RoR_RankedLeaderboard.stateMachineName = "RoR_RankedLeaderboardStatsPop_Window"
	RoR_RankedLeaderboard.state = {[SEND_BEGIN] = { handler=nil,time=RoR_RankedLeaderboard.StateTimer,nextState=SEND_FINISH } , [SEND_FINISH] = { handler=RoR_RankedLeaderboard.OnRButtonUp,time=0,nextState=SEND_BEGIN, } , }
	Is_StateMachine_Running = false
	
	
    -- Column text headings
    ButtonSetText("RoR_RankedLeaderboardListPlayerListHeaderName", GetString(StringTables.Default.LABEL_NAME) )
    ButtonSetText("RoR_RankedLeaderboardListPlayerListHeaderCareer", GetString(StringTables.Default.LABEL_CAREER) )
    ButtonSetText("RoR_RankedLeaderboardListPlayerListHeaderRank", L"Rank" )
    ButtonSetText("RoR_RankedLeaderboardListPlayerListHeaderRenown",L"Renown" )
    ButtonSetText("RoR_RankedLeaderboardListPlayerListHeaderWins", L"Wins" )
    ButtonSetText("RoR_RankedLeaderboardListPlayerListHeaderLosses", L"Losses" )
    ButtonSetText("RoR_RankedLeaderboardListPlayerListHeaderDraws", L"Draws" )    
	ButtonSetText("RoR_RankedLeaderboardListPlayerListHeaderTotal", L"Matches" )    
	ButtonSetText("RoR_RankedLeaderboardListPlayerListHeaderRate", L"Win %" )    
	ButtonSetText("RoR_RankedLeaderboardListPlayerListHeaderGuild", L"Guild" )  
	ButtonSetText("RoR_RankedLeaderboardListPlayerListHeaderRating", L"Rating" )    

	ButtonSetText("RoR_RankedLeaderboardRewardsInfo", L"Reward Info" )    
	--ButtonSetText("RoR_RankedLeaderboardStatsInfo", L"Tier Info" )    
	ButtonSetText("RoR_RankedLeaderboardLeaveButton", L"Leave queue" )    

ButtonSetText("RoR_RankedLeaderboardListFindMe", L"Find "..towstring(PlayerName) )



--	ButtonSetText("RoR_RankedLeaderboardStatsJoinSoloButton", L"Join Solo" )    
--	ButtonSetText("RoR_RankedLeaderboardStatsJoinGroupButton", L"Join Group" ) 

	--ButtonSetText("RoR_RankedLeaderboardTab4", L"Ruleset" ) 


	ComboBoxAddMenuItem("RoR_RankedLeaderboardListCareerCombo",L"All Careers")
	for i=1,24 do
		ComboBoxAddMenuItem("RoR_RankedLeaderboardListCareerCombo",L"<icon"..towstring(Icons.GetCareerIconIDFromCareerLine(i))..L"> "..towstring(GetCareerLine(i)))
	end
	ComboBoxSetSelectedMenuItem("RoR_RankedLeaderboardListCareerCombo",1)

	--Combo for the Page	
	for i=1,12 do
		ComboBoxAddMenuItem("RoR_RankedLeaderboardListPageCombo",towstring(i))
	end
	ComboBoxSetSelectedMenuItem("RoR_RankedLeaderboardListPageCombo",SelectedPage)

	--Type Combo
	ComboBoxAddMenuItem("RoR_RankedLeaderboardListTypeCombo",L"Solo")
	ComboBoxAddMenuItem("RoR_RankedLeaderboardListTypeCombo",L"Group")
	ComboBoxSetSelectedMenuItem("RoR_RankedLeaderboardListTypeCombo",1)

      
--	CircleImageSetTexture("RoR_RankedLeaderboardHowToCareer_Window_TankIcon","icon022724", 31,31)
--	CircleImageSetTexture("RoR_RankedLeaderboardHowToCareer_Window_MDpsIcon","icon022657", 31,31)
--	CircleImageSetTexture("RoR_RankedLeaderboardHowToCareer_Window_RDpsIcon","icon022675", 31,31)
--	CircleImageSetTexture("RoR_RankedLeaderboardHowToCareer_Window_HealersIcon","icon022706", 31,31)
ButtonSetText("RoR_RankedLeaderboardHowToCareer_WindowTopic1", RulesetTopic[1] ) 
ButtonSetText("RoR_RankedLeaderboardHowToCareer_WindowTopic2", RulesetTopic[2] ) 
ButtonSetText("RoR_RankedLeaderboardHowToCareer_WindowTopic3", RulesetTopic[3] ) 
ButtonSetText("RoR_RankedLeaderboardHowToCareer_WindowTopic4", RulesetTopic[4] ) 
ButtonSetText("RoR_RankedLeaderboardHowToCareer_WindowTopic5", RulesetTopic[5] ) 
ButtonSetText("RoR_RankedLeaderboardHowToCareer_WindowTopic6", RulesetTopic[6] ) 
ButtonSetText("RoR_RankedLeaderboardHowToCareer_WindowTopic7", RulesetTopic[7] ) 
ButtonSetText("RoR_RankedLeaderboardHowToCareer_WindowTopic8", RulesetTopic[8] ) 



LabelSetText("RoR_RankedLeaderboardHowToInfoText",RulesetText[1])
LabelSetText("RoR_RankedLeaderboardHowToLabel",RulesetTopic[1])
ButtonSetPressedFlag("RoR_RankedLeaderboardHowToCareer_WindowTopic1",true)
	--WindowSetShowing("RoR_RankedLeaderboardTab4",false)

	LabelSetText("RoR_RankedLeaderboardListInputText",L"Search by Name")
	LabelSetText("RoR_RankedLeaderboardTitleBarText",L"Ranked")
	LabelSetText("RoR_RankedLeaderboardGroupQueueLabel", L"AS GROUP")	
    -- First Update the player list
    RoR_RankedLeaderboard.OnPlayerListUpdated()
	UpdatePlayerList()
	RoR_RankedLeaderboard.UpdateScenarioQueueData()
	UpdateLeaderBoardData()
	RoR_RankedLeaderboard.ToggleLeaderboards()	    
end

	--Create the Statemachine
function RoR_RankedLeaderboard.StartMachine()
	local stateMachine = TimedStateMachine.New( RoR_RankedLeaderboard.state,SEND_BEGIN)
	TimedStateMachineManager.AddStateMachine( RoR_RankedLeaderboard.stateMachineName, stateMachine )
end

function RoR_RankedLeaderboard.Text_Stream_Fetch(text)
	local text = towstring(text)
	local Rank_SPLIT_TEXT = StringSplit(tostring(text), ":")
	local WindowName= "RoR_RankedLeaderboardStatsPop_Window"

	-- SCPlayers : MapID : Order_Tanks : Order_DPS : Order_Healers : Destro_Tanks : Destro_DPS : Destro_Healers : #Solo_Matches_running : Order_Mdps : Order_Rdps : Destro_Mdps : Destro_Rdps : #Group_Matches_running
		
	LabelSetText(WindowName.."Head",L"SOLO")
--	LabelSetText(WindowName.."Tank_Label",L"<icon22680>")
--	LabelSetText(WindowName.."MDps_Label",L"<icon22679>")
--	LabelSetText(WindowName.."RDps_Label",L"<icon22675>")
--	LabelSetText(WindowName.."Healers_Label",L"<icon22684>")
	
     --local texture, x, y = GetIconData( 22724 )        
	CircleImageSetTexture(WindowName.."_TankIcon","icon022724", 31,31)
	CircleImageSetTexture(WindowName.."_MDpsIcon","icon022657", 31,31)
	CircleImageSetTexture(WindowName.."_RDpsIcon","icon022675", 31,31)
	CircleImageSetTexture(WindowName.."_HealersIcon","icon022706", 31,31)
	
	
	LabelSetText(WindowName.."_GroupHead",L"GROUP")

	LabelSetText(WindowName.."_Order_TankText",towstring(Rank_SPLIT_TEXT[3]))
	LabelSetText(WindowName.."_Destro_TankText",towstring(Rank_SPLIT_TEXT[6]))

	LabelSetText(WindowName.."_Order_MDpsText",towstring(Rank_SPLIT_TEXT[10]))
	LabelSetText(WindowName.."_Destro_MDpsText",towstring(Rank_SPLIT_TEXT[12]))
	
	LabelSetText(WindowName.."_Order_RDpsText",towstring(Rank_SPLIT_TEXT[11]))
	LabelSetText(WindowName.."_Destro_RDpsText",towstring(Rank_SPLIT_TEXT[13]))
	
	LabelSetText(WindowName.."_Order_HealersText",towstring(Rank_SPLIT_TEXT[5]))
	LabelSetText(WindowName.."_Destro_HealersText",towstring(Rank_SPLIT_TEXT[8]))


	LabelSetText(WindowName.."_Group_OrderText",towstring(Rank_SPLIT_TEXT[15]) or L"0" ) 
	LabelSetText(WindowName.."_Group_DestroText",towstring(Rank_SPLIT_TEXT[16])or L"0" )

	LabelSetText(WindowName.."SC",L"Ongoing Matches: "..towstring(Rank_SPLIT_TEXT[9]))
	LabelSetText(WindowName.."_GroupSC",L"Ongoing Matches: "..towstring(Rank_SPLIT_TEXT[14]))

for i=0,4 do
   local row_mod = math.mod (i, 2)
   local row_color = RowColors[row_mod]
   WindowSetTintColor("RoR_RankedLeaderboardStatsClass"..i.."Image", row_color.r, row_color.g, row_color.b)
   WindowSetAlpha("RoR_RankedLeaderboardStatsClass"..i.."Image", row_color.a)
   
   
   WindowSetTintColor("RoR_RankedLeaderboardStatsGroup"..i.."Image", row_color.r, row_color.g, row_color.b)
   WindowSetAlpha("RoR_RankedLeaderboardStatsGroup"..i.."Image", row_color.a)
end
end

function RoR_RankedLeaderboard.OnRButtonUp()	
	SendChatText(L"]uisc", L"")

	--Start the automatic Updates, (Run this only once)
	if Is_StateMachine_Running == false then
		RoR_RankedLeaderboard.StartMachine()
		Is_StateMachine_Running = true
	end
end

function RoR_RankedLeaderboard.ToggleShowing()
    
WindowUtils.ToggleShowing( "RoR_RankedLeaderboard" )
--update the season list
if SelectedSeason == 0 then
	--SendChatText(L"]ranked listseasons", L"")
	--SendChatText(L"]ranked GetPlayerStatus", L"")
	
end
SendChatText(L"]ranked GetPlayerStatus", L"")
RoR_RankedLeaderboard.ToggleLeaderboards()
RoR_RankedLeaderboard.UpdateReward()
end

function RoR_RankedLeaderboard.OnShown()
if SelectedSeason == 0 then
	--SendChatText(L"]ranked listseasons", L"")
	SendChatText(L"]ranked GetPlayerStatus", L"")
end
 
if GameData.Player.level < 40 then
JoinDisabled = true
else
JoinDisabled = false
end
 
 WindowAssignFocus("RoR_RankedLeaderboardListSearchBox",false)
TextEditBoxSetText("RoR_RankedLeaderboardListSearchBox",L"" )

    WindowUtils.OnShown()
    UpdateLeaderBoardData()
	RoR_RankedLeaderboard.ToggleLeaderboards()
end

function RoR_RankedLeaderboard.OnHidden()
    WindowUtils.OnHidden()
end

function RoR_RankedLeaderboard.OnPlayerListUpdated()
    UpdateLeaderBoardData()
end

function RoR_RankedLeaderboard.OnPlayerListStatsUpdated()
    UpdateLeaderBoardData()
end

function RoR_RankedLeaderboard.UpdatePlayerRow()

    if (RoR_RankedLeaderboardListPlayerList.PopulatorIndices ~= nil) then
        for rowIndex, dataIndex in ipairs (RoR_RankedLeaderboardListPlayerList.PopulatorIndices) do
            local playerData = RoR_RankedLeaderboard.playersData[ dataIndex ]
            local rowFrame = "RoR_RankedLeaderboardListPlayerListRow"..rowIndex
            --RoR_RankedLeaderboard.UpdatePlayerIcon(rowFrame, playerData)
         --   local row_mod = math.mod (rowIndex, 2)
            local text_color = DefaultColor.WHITE
            local labelName = "RoR_RankedLeaderboardListPlayerListRow"..rowIndex.."Name"
			local row_color = Row_Colors[playerData.realm] or GameDefs.RowColorInvalid
			
			if RoR_RankedLeaderboard.playersData[dataIndex].character_name == PlayerName then
				row_color = {r=225, g=225, b=50,a=0.3}
			end
						
         --   local row_color = GameDefs.RowColors[row_mod]
            for columnIndex, sortData in ipairs (RoR_RankedLeaderboard.sortData) do
                local name = tostring(sortData)
                --WindowSetTintColor("RoR_RankedLeaderboardListPlayerListRow"..rowIndex.."Background"..name, row_color.r, row_color.g, row_color.b)
                --WindowSetAlpha("RoR_RankedLeaderboardListPlayerListRow"..rowIndex.."Background"..name, row_color.a)
                WindowSetTintColor("RoR_RankedLeaderboardListPlayerListRow"..rowIndex.."Bookark", row_color.r, row_color.g, row_color.b)
                WindowSetAlpha("RoR_RankedLeaderboardListPlayerListRow"..rowIndex.."Bookark", row_color.a)
				
				
				
				--LabelSetTextColor("RoR_RankedLeaderboardPlayerListRow"..rowIndex..name, text_color.r,text_color.g, text_color.b)

            end
            if (dataIndex == RoR_RankedLeaderboard.SelectedPlayerDataIndex) then
                RoR_RankedLeaderboard.HighlightPlayerInList( rowIndex, true, false)
            else
                RoR_RankedLeaderboard.HighlightPlayerInList( rowIndex, false, false)
            end
			
			local percent = RoR_RankedLeaderboard.playersData[dataIndex].win_rate/100
			--local tint = math.min(percent, 0.5) * 2
			--LabelSetTextColor("RoR_RankedLeaderboardListPlayerListRow"..rowIndex.."Rate",255*tint, 255*(1-tint), 0)
			--LabelSetTextColor( "RoR_RankedLeaderboardListPlayerListRow"..rowIndex.."Rate",255*(1-percent),255*percent,0)
			LabelSetTextColor( "RoR_RankedLeaderboardListPlayerListRow"..rowIndex.."Rate",255,255*percent,0)
		
		end
    end

end

-- Handles the Left Button click on a player row
function RoR_RankedLeaderboard.OnLButtonUpPlayerRow()

    local row = WindowGetId( SystemData.ActiveWindow.name )
    RoR_RankedLeaderboard.HighlightPlayerInList(row, true, true)

end

-- Handles the Right Button click on a player row
function RoR_RankedLeaderboard.OnRButtonUpPlayerRow()

    local row = WindowGetId( SystemData.ActiveWindow.name )
    RoR_RankedLeaderboard.HighlightPlayerInList( row, false, false )
    RoR_RankedLeaderboard.SelectedPlayerDataIndex = 0

end


function RoR_RankedLeaderboard.HighlightPlayerInList( rowIndex, bVisible, bFromLButtonEvent )

    local dataIndex = RoR_RankedLeaderboardListPlayerList.PopulatorIndices[rowIndex]
    local playerData = RoR_RankedLeaderboard.playersData[ dataIndex ]

    -- Get the player's indexed data from the GameData list and update the lower fields
    if (bFromLButtonEvent) then
        RoR_RankedLeaderboard.SelectedPlayerDataIndex = dataIndex
    end

    -- Clear selected player info from both lists
    if (bFromLButtonEvent) then
        RoR_RankedLeaderboard.UpdatePlayerRow ()
    end

    -- Determine the text c olor
    local color
	local _Colors
    if (bVisible) then
        color = { r=255, g=204, b=102 }
    else
        color = Qualified_Colors["Other"][tostring(RoR_RankedLeaderboard.playersData[dataIndex].match_needed>0)]
    end

    for columnIndex, sortData in ipairs (RoR_RankedLeaderboard.sortData) do
        local name = sortData
        LabelSetTextColor("RoR_RankedLeaderboardListPlayerListRow"..rowIndex..name, color.r, color.g, color.b);
    end


	
				local Q_Colors = Qualified_Colors["Rank"][tostring(RoR_RankedLeaderboard.playersData[dataIndex].match_needed>0)]
				LabelSetTextColor("RoR_RankedLeaderboardListPlayerListRow"..rowIndex.."Rank", Q_Colors.r,Q_Colors.g, Q_Colors.b)
				--_Colors = Guild_Colors[RoR_RankedLeaderboard.playersData[dataIndex].realm]
				
				
	if playerData.match_needed > 0 then
		_Colors = {r=125,g=125,b=125}		
	else
		_Colors = Guild_Colors[RoR_RankedLeaderboard.playersData[dataIndex].realm]
	end
	
				
				LabelSetLinkColor ("RoR_RankedLeaderboardListPlayerListRow"..rowIndex.."Guild", _Colors.r, _Colors.g, _Colors.b)

	WindowSetShowing("RoR_RankedLeaderboardListPlayerListRow"..rowIndex.."QualifyIcon", playerData.match_needed > 0)
    -- Show the border box around the selected player
    WindowSetShowing("RoR_RankedLeaderboardListPlayerListRow"..rowIndex.."SelectionBorder", bVisible)

end

function RoR_RankedLeaderboard.OnVertScrollLButtonUp()
    -- dummy LButtonUp handler for the scrollbars to stop them from
    -- failing to handle for lack of a LUA script event handler
end

function RoR_RankedLeaderboard.OnMouseOverPlayerRow()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)	
	local WindowName = SystemData.MouseOverWindow.name
	
	--local windowName	= SystemData.ActiveWindow.name
    local rowIndex	    = WindowGetId (WindowName)
    local playerData = RoR_RankedLeaderboard.playersData[ rowIndex ]

if playerData.match_needed ~= 0 then

    Tooltips.CreateTextOnlyTooltip (WindowName, nil)
 
        Tooltips.SetTooltipText (1, 1,L"Matches Needed:")        
        Tooltips.SetTooltipText (2, 1,towstring(playerData.match_needed))

    Tooltips.Finalize ()

    local anchor = { Point="top", RelativeTo=WindowName, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end
end

function RoR_RankedLeaderboard.ToolTips()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)	
	local WindowName = SystemData.MouseOverWindow.name
	local DoFinalize = false
	--local windowName	= SystemData.ActiveWindow.name

if string.find(tostring(WindowName),"Window_Healers") then	
	Tooltips.CreateTextOnlyTooltip (WindowName, nil)
        Tooltips.SetTooltipText (1, 1,L"Healers")  
		DoFinalize = true
elseif string.find(tostring(WindowName),"NotEligible") then		
		if JoinDisabled == true then
			Tooltips.CreateTextOnlyTooltip (WindowName, nil)
			Tooltips.SetTooltipText (1, 1,L"You need to be level 40 to queue for Ranked")  		
			DoFinalize = true		
		else
			return
		end
        --Tooltips.SetTooltipText (2, 1,towstring(playerData.match_needed))
elseif string.find(tostring(WindowName),"Window_RDps") then
	Tooltips.CreateTextOnlyTooltip (WindowName, nil)
		 Tooltips.SetTooltipText (1, 1,L"Range Damage Dealers") 
		 DoFinalize = true
elseif string.find(tostring(WindowName),"Window_MDps") then
	Tooltips.CreateTextOnlyTooltip (WindowName, nil)
		 Tooltips.SetTooltipText (1, 1,L"Melee Damage Dealers") 		 
		 DoFinalize = true
elseif string.find(tostring(WindowName),"Window_Tank") then
	Tooltips.CreateTextOnlyTooltip (WindowName, nil)
		 Tooltips.SetTooltipText (1, 1,L"Tanks") 		 
		 DoFinalize = true
elseif string.find(tostring(WindowName),"Tab2") then
	Tooltips.CreateTextOnlyTooltip (WindowName, nil)
		 Tooltips.SetTooltipText (1, 1,towstring(RoR_RankedLeaderboard.SeasonData[CurrentSeason].season_name)) 
		 Tooltips.SetTooltipText (2, 1,L"Starting Date: ")
		Tooltips.SetTooltipText (2, 3,towstring(RoR_RankedLeaderboard.SeasonData[CurrentSeason].season_startdate)) 		 
		 Tooltips.SetTooltipText (3, 1,L"Ending Date: ")
		Tooltips.SetTooltipText (3, 3,towstring(RoR_RankedLeaderboard.SeasonData[CurrentSeason].season_enddate)) 
		DoFinalize = true
elseif string.find(tostring(WindowName),"RewardsInfo") then

   Tooltips.CreateCustomTooltip( WindowName, "RewardInfoLegends" )		
   DoFinalize = false
elseif string.find(tostring(WindowName),"NextButton") then
	Tooltips.CreateTextOnlyTooltip (WindowName, nil)
		 Tooltips.SetTooltipText (1, 1,L"Next Page") 
		 Tooltips.SetTooltipText (2, 1,L"(Shift + click to jump to last page)")		 
		DoFinalize = true   
elseif string.find(tostring(WindowName),"PrevButton") then
	Tooltips.CreateTextOnlyTooltip (WindowName, nil)
		 Tooltips.SetTooltipText (1, 1,L"Previous Page") 
		 Tooltips.SetTooltipText (2, 1,L"(Shift + click to jump to firts page)")
		DoFinalize = true   		
end


    if DoFinalize == true then Tooltips.Finalize () end
    local anchor = { Point="top", RelativeTo=WindowName, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)

end


function RoR_RankedLeaderboard.CareerSelect(idx)
PlaySound(313)
	if idx == 1 then 
	-- <season_id> <rating_type> <page_num> (<career>)
		SendChatText(L"]ranked leaderboard "..SelectedSeason..L" "..selectedType..L" 1", L"")
	else
		SendChatText(L"]ranked leaderboardcareer "..SelectedSeason..L" "..selectedType..L" 1 "..towstring(idx-1), L"")
	end
	SelectedPage = 1
	ComboBoxSetSelectedMenuItem( "RoR_RankedLeaderboardListPageCombo", 1 )
end

function RoR_RankedLeaderboard.TypeSelect(idx)
selectedType = idx
ComboBoxSetSelectedMenuItem( "RoR_RankedLeaderboardListTypeCombo", selectedType )
RoR_RankedLeaderboard.UpdatePage()
end

function RoR_RankedLeaderboard.SeasonSelect(idx)
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)	
	local WindowName = SystemData.MouseOverWindow.name
if WinParent == "RoR_RankedLeaderboardListSeasonComboMenu" then
	SelectedSeason = idx
	SelectedPage = 1
	ComboBoxSetSelectedMenuItem( "RoR_RankedLeaderboardListPageCombo", SelectedPage )
	RoR_RankedLeaderboard.UpdatePage()
end
end

function RoR_RankedLeaderboard.OnUpdatePageCombo(idx)
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)	
	local WindowName = SystemData.MouseOverWindow.name
if WinParent == "RoR_RankedLeaderboardListPageComboMenu" then
	SelectedPage = idx
	RoR_RankedLeaderboard.UpdatePage()
end
end

function RoR_RankedLeaderboard.OnPrevNextCombo(flags, x, y)

	local activeWindow = SystemData.ActiveWindow.name
	local settingName = string.sub(activeWindow, -4)
	local index = ComboBoxGetSelectedMenuItem("RoR_RankedLeaderboardListPageCombo")
	local Button_id = WindowGetId (SystemData.ActiveWindow.name)
	
	--SelectedPage


	if ( Button_id == 1 and index > 1) then
		if flags == 4 then
			index = 1
		else
			index = index - 1		
		end
	elseif ( Button_id == 2 and index < Max_Pages) then 
		if flags == 4 then
			index = Max_Pages
		else
			index = index + 1
		end
	end

	

	SelectedPage = index
	ComboBoxSetSelectedMenuItem( "RoR_RankedLeaderboardListPageCombo", SelectedPage )
	RoR_RankedLeaderboard.UpdatePage()
	
end

function RoR_RankedLeaderboard.UpdatePage()
	local CareerComboNumber = ComboBoxGetSelectedMenuItem("RoR_RankedLeaderboardListCareerCombo")	
	if CareerComboNumber == 1 then
		SendChatText(L"]ranked leaderboard "..SelectedSeason..L" "..selectedType..L" "..SelectedPage, L"")
	else
		SendChatText(L"]ranked leaderboardcareer "..SelectedSeason..L" "..selectedType..L" "..SelectedPage..L" "..towstring(CareerComboNumber-1), L"")
	end
	PlaySound(313)
end

function RoR_RankedLeaderboard.OnTabLBU()
WindowAssignFocus("RoR_RankedLeaderboardListSearchBox",false)
local Button_id = WindowGetId (SystemData.ActiveWindow.name)
SelectedTab = Button_id
if Button_id == 1 then
RoR_RankedLeaderboard.UpdatePage()
elseif  Button_id == 2 then
SendChatText(L"]ranked playerstats "..towstring(CurrentSeason) , L"")
elseif  Button_id == 3 then
RoR_RankedLeaderboard.UpdateReward()
end
RoR_RankedLeaderboard.ToggleLeaderboards()
end

function RoR_RankedLeaderboard.OnInfoLBU()
local Button_id = WindowGetId (SystemData.ActiveWindow.name)
LabelSetText("RoR_RankedLeaderboardHowToInfoText",RulesetText[Button_id])
LabelSetText("RoR_RankedLeaderboardHowToLabel",RulesetTopic[Button_id])

for i=1,8 do
ButtonSetPressedFlag("RoR_RankedLeaderboardHowToCareer_WindowTopic"..i,false)
end
ButtonSetPressedFlag("RoR_RankedLeaderboardHowToCareer_WindowTopic"..Button_id,true)
end


function RoR_RankedLeaderboard.JumpToCurrent()
	DoSearch = true
	FindMe = true
SendChatText(L"]ranked leaderboardplayer "..SelectedSeason..L" "..selectedType..L" "..towstring(PlayerName), L"")
end

function RoR_RankedLeaderboard.ToggleLeaderboards()
WindowSetShowing("RoR_RankedLeaderboardList",SelectedTab == 1)
WindowSetShowing("RoR_RankedLeaderboardStats",SelectedTab == 2)
WindowSetShowing("RoR_RankedLeaderboardRewards",SelectedTab == 3)
WindowSetShowing("RoR_RankedLeaderboardHowTo",SelectedTab == 4)

ButtonSetDisabledFlag("RoR_RankedLeaderboardTab1",SelectedTab == 1)
ButtonSetPressedFlag("RoR_RankedLeaderboardTab2",SelectedTab == 2)
ButtonSetDisabledFlag("RoR_RankedLeaderboardTab3",SelectedTab == 3)
ButtonSetDisabledFlag("RoR_RankedLeaderboardTab4",SelectedTab == 4)

	RoR_RankedLeaderboard.SelectedPlayerDataIndex	= 0
	RoR_RankedLeaderboard.SelectedPlayerWindow		= ""
	RoR_RankedLeaderboard.SelectedPlayerInListIndex = 0

WindowSetShowing("RoR_RankedLeaderboardNotEligible",JoinDisabled)

end

function RoR_RankedLeaderboard.OnSearch()
local TextBoxText = TextEditBoxGetText("RoR_RankedLeaderboardListSearchBox")
WindowAssignFocus("RoR_RankedLeaderboardListSearchBox",false)
	if TextBoxText ~= L"" then
		DoSearch = true
		
			local firstChar = wstring.upper( wstring.sub( TextBoxText, 1, 1 ) )
			local remaining = L""
			if( wstring.len(TextBoxText) > 1 ) then
				remaining = wstring.lower( wstring.sub( TextBoxText, 2,wstring.len(TextBoxText) ) )
			end
			TextBoxText = firstChar..remaining
			TextEditBoxSetText("RoR_RankedLeaderboardListSearchBox",TextBoxText ) 
			
			
		SendChatText(L"]ranked leaderboardplayer "..SelectedSeason..L" "..selectedType..L" "..towstring(TextBoxText), L"")
	else
	DoSearch = false
	RoR_RankedLeaderboard.UpdatePage()
	RoR_RankedLeaderboard.ToggleLeaderboards()	
	end
end

function RoR_RankedLeaderboard.ResetBoard()
ComboBoxClearMenuItems("RoR_RankedLeaderboardListPageCombo")
ComboBoxSetSelectedMenuItem("RoR_RankedLeaderboardListCareerCombo",1)
ComboBoxSetSelectedMenuItem("RoR_RankedLeaderboardListPageCombo",1)
SelectedPage = 1
ListBoxSetDisplayOrder( "RoR_RankedLeaderboardListPlayerList", {})
DoSearch = false
end


function RoR_RankedLeaderboard.JoinButton()


if JoinDisabled == false then
local Button_id = WindowGetId( SystemData.ActiveWindow.name )
	if (Button_id == 1) and (GroupQueue == false) then
		if IsQuedSolo == false then
			SendChatText(L"]ranked queuesolo", L"")
		else
	--	GameData.ScenarioQueueData.selectedId = 3000
	--		BroadcastEvent( SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE )
		end
	elseif 	(Button_id == 1) and (GroupQueue == true) then
		if IsQuedGroup == false then
			SendChatText(L"]ranked queuegroup", L"")
		else
			GameData.ScenarioQueueData.selectedId = 3001
			BroadcastEvent( SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE )
		end
		elseif 	Button_id == 3 then
		if IsQuedSolo == true then
			GameData.ScenarioQueueData.selectedId = 3000
		elseif IsQuedGroup == true then
			GameData.ScenarioQueueData.selectedId = 3001
		end		
			BroadcastEvent( SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE )
	end
		RoR_RankedLeaderboard.UpdateGroupQ()
	end
end

function RoR_RankedLeaderboard.UpdateScenarioQueueData()
	queuedScenarioData = GetScenarioQueueData()

	if queuedScenarioData then
		for k,v in ipairs(queuedScenarioData) do
			if v.id == 3000 then
--			ButtonSetText("RoR_RankedLeaderboardStatsJoinSoloButton", L"Leave Solo" ) 
			IsQuedSolo = true   
			RoR_RankedLeaderboard.UpdateQue()
			WindowSetShowing("RoR_RankedLeaderboardLeaveButton",true)
			RoR_RankedLeaderboard.UpdateGroupQ()
			return
			elseif v.id == 3001 then
--			ButtonSetText("RoR_RankedLeaderboardStatsJoinGroupButton", L"Leave Group" ) 
			IsQuedGroup = true   
			RoR_RankedLeaderboard.UpdateQue()
			WindowSetShowing("RoR_RankedLeaderboardLeaveButton",true)
			RoR_RankedLeaderboard.UpdateGroupQ()
			return
			end
		end
	end
	IsQuedSolo = false
	IsQuedGroup = false  
	WindowSetShowing("RoR_RankedLeaderboardLeaveButton",false)	
--	ButtonSetText("RoR_RankedLeaderboardStatsJoinSoloButton", L"Join Solo" )    
--	ButtonSetText("RoR_RankedLeaderboardStatsJoinGroupButton", L"Join Group")  
	RoR_RankedLeaderboard.UpdateQue()	
end

function RoR_RankedLeaderboard.UpdateQue()

ButtonSetDisabledFlag("RoR_RankedLeaderboardJoinButton",(IsQuedSolo) or (IsQuedGroup))
--WindowSetShowing("RoR_RankedLeaderboardWait",(IsQuedSolo) or (IsQuedGroup))
RoR_RankedLeaderboard.UpdateGroupQ()
end

function RoR_RankedLeaderboard.UpdateGroupQ()
-- ButtonSetDisabledFlag("RoR_RankedLeaderboardJoinButton",(IsQuedSolo) or (IsQuedGroup))
WindowSetShowing("RoR_RankedLeaderboardGroupQueue",false)
	if PartyUtils.IsPartyActive() then
		if GameData.Player.isGroupLeader then
			if (IsQuedGroup == false) and (IsQuedSolo == false) then
				WindowSetShowing("RoR_RankedLeaderboardGroupQueue",true)
			end
		else
			GroupQueue = false
		end
	else
		GroupQueue = false
	end
end

function RoR_RankedLeaderboard.UpdateGroupButton()
GroupQueue = not GroupQueue
ButtonSetPressedFlag("RoR_RankedLeaderboardGroupQueue",GroupQueue)
end


function RoR_RankedLeaderboard.UpdateReward()


local CurrentEvents = GetLiveEventList()
local ActiveEvent = nil
local EventData = nil
local texture, x, y = GetIconData( 208 )        
local PARENT_WINDOW = "RoR_RankedLeaderboardRewards"

LabelSetText("RewardInfoLegendsTitle",L"Ranked SC Earnings:")
LabelSetText("RewardInfoLegendsRow1Label",L"Win:")
LabelSetText("RewardInfoLegendsRow1Value",L"x20")
LabelSetText("RewardInfoLegendsRow2Label",L"Loss:")
LabelSetText("RewardInfoLegendsRow2Value",L"x5")
LabelSetText("RewardInfoLegendsRow3Label",L"Draw:")
LabelSetText("RewardInfoLegendsRow3Value",L"x10")
LabelSetText("RewardInfoLegendsRow4Label",L"Draw (w/o points):")
LabelSetText("RewardInfoLegendsRow4Value",L"x5")
DynamicImageSetTexture("RewardInfoLegendsRow1Icon",texture,x,y)
DynamicImageSetTexture("RewardInfoLegendsRow2Icon",texture,x,y)
DynamicImageSetTexture("RewardInfoLegendsRow3Icon",texture,x,y)
DynamicImageSetTexture("RewardInfoLegendsRow4Icon",texture,x,y)

if RoR_RankedLeaderboard.SeasonData ~= nil and tonumber(RoR_RankedLeaderboard.SeasonData[CurrentSeason].season_ismainseason) == 1 then
local texture2, x, y = GetIconData( 25015 )
LabelSetText("RewardInfoLegendsRow5Label",L"Win Group Match:") 
LabelSetText("RewardInfoLegendsRow5Value",L"x1")
LabelSetText("RewardInfoLegendsRow6Label",L"Win (700+ MMR):") 
LabelSetText("RewardInfoLegendsRow6Value",L"x1")
DynamicImageSetTexture("RewardInfoLegendsRow5Icon",texture2,x,y)
DynamicImageSetTexture("RewardInfoLegendsRow6Icon",texture2,x,y)
WindowSetShowing("RewardInfoLegendsRow5",true)
WindowSetShowing("RewardInfoLegendsRow6",true)
WindowSetDimensions( "RewardInfoLegends", 250, 185 )
else
WindowSetDimensions( "RewardInfoLegends", 250, 135 )
WindowSetShowing("RewardInfoLegendsRow5",false)
WindowSetShowing("RewardInfoLegendsRow6",false)
end


for k,v in pairs (CurrentEvents) do
	if string.find(tostring(v.title),"Ranked Week") then
		if v.ended == false then
			ActiveEvent = v.id
		end
	end
end

	if ActiveEvent ~= nil then
		LBEventTasks = GetLiveEventTasks(ActiveEvent)
		
		for k,v in ipairs(LBEventTasks) do

			if v.name ~= nil then
				RoR_RankedLeaderboard_LabelFormat2("RoR_RankedLeaderboardRewardsTasksClass"..(k),L"     "..towstring(v.name),towstring(v.currentValue)..L"/"..towstring(v.maxValue),400)						
			  local row_mod = math.mod (k, 2)
			  local row_color = RowColors[row_mod]
			  local IsTaskDone = v.currentValue == v.maxValue
			   WindowSetTintColor("RoR_RankedLeaderboardRewardsTasksClass"..k.."Image", row_color.r, row_color.g, row_color.b)
			   WindowSetAlpha("RoR_RankedLeaderboardRewardsTasksClass"..k.."Image", row_color.a)
			  DynamicImageSetTextureSlice("RoR_RankedLeaderboardRewardsTasksIcon"..k,Task_Texture[tostring(IsTaskDone)])
			   
			   
			end
		end
	EventData = GetLiveEventData(ActiveEvent)
	
	LabelSetText("RoR_RankedLeaderboardRewardsTitle",towstring(EventData.title))
	LabelSetText("RoR_RankedLeaderboardRewardsSubTitle",towstring(EventData.subTitle))
	
	LabelSetText("RoR_RankedLeaderboardRewardsLabel",towstring(EventData.loreText))
	--d(GetLiveEventData(ActiveEvent))
	
--d(GetLiveEventTasks( 120))

--Update Rewards

   if ( not LBEventTasks.eligible )
    then
        WindowSetShowing( PARENT_WINDOW.."Progress", false )
--        WindowSetShowing( PARENT_WINDOW.."IneligibleText", true )
    elseif ( LBEventTasks.rewards[1] ~= nil )
    then
        for level = 1, TomeWindow.NUM_REWARD_LEVELS
        do
            if (LBEventTasks.rewards[level] ~= nil)
            then
                ButtonSetStayDownFlag( PARENT_WINDOW.."ProgressBarCheck"..level, true )
                ButtonSetDisabledFlag( PARENT_WINDOW.."ProgressBarCheck"..level, true )

                for reward = 1, TomeWindow.MAX_REWARDS_PER_LEVEL
                do
                    if( LBEventTasks.rewards[level].items[reward] ~= nil )
                    then
                        local texture, x, y = GetIconData( LBEventTasks.rewards[level].items[reward].iconNum )
                        CircleImageSetTexture( PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward.."IconBase", texture, 31, 31 )						
                        WindowSetShowing( PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward, true )
						if( LBEventTasks.rewards[level].items[reward].stackCount > 1 )
						then
							WindowSetShowing( PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward.."Text", true )
							LabelSetText(PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward.."Text", L""..LBEventTasks.rewards[level].items[reward].stackCount )
						else
						    WindowSetShowing( PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward.."Text", false )
						end
                    else
                        WindowSetShowing( PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward, false )
                    end					
                end
                
                local xOffset = 0
                if (#LBEventTasks.rewards[level].items > 2)
                then
                    xOffset = -32
                end
                WindowClearAnchors( PARENT_WINDOW.."ProgressLevel"..level.."Reward1" )
                WindowAddAnchor( PARENT_WINDOW.."ProgressLevel"..level.."Reward1", "bottom", PARENT_WINDOW.."ProgressLevel"..level.."Label", "top", xOffset, 0 )
			else
                for reward = 1, TomeWindow.MAX_REWARDS_PER_LEVEL
                do
                    WindowSetShowing( PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward, false )				
                end
            end
        end
        StatusBarSetMaximumValue( PARENT_WINDOW.."ProgressBarStatus", 1.0 )
        WindowSetShowing( PARENT_WINDOW.."Progress", true )
       --WindowSetShowing( PARENT_WINDOW.."IneligibleText", false )
    else
        WindowSetShowing( PARENT_WINDOW.."Progress", false )
        --WindowSetShowing( PARENT_WINDOW.."IneligibleText", false )
    end

--update Progress
  if ( LBEventTasks.eligible and ( LBEventTasks.rewards[1] ~= nil ) )
    then
        local lastLevelThreshold = 0
        local statusBarPercent = 0
        
        for level = 1, TomeWindow.NUM_REWARD_LEVELS
        do
            if (LBEventTasks.rewards[level] ~= nil)
            then
                local levelPercent = 0
                if( LBEventTasks.rewards[level].threshold - lastLevelThreshold > 0 )
                then
                    levelPercent = ( LBEventTasks.overallCurrentValue - lastLevelThreshold ) / ( LBEventTasks.rewards[level].threshold - lastLevelThreshold )
                end
                if( levelPercent > 1.0 )
                then
                    statusBarPercent = statusBarPercent + ( 1.0 / TomeWindow.NUM_REWARD_LEVELS )
                elseif( levelPercent > 0 )
                then
                    statusBarPercent = statusBarPercent + ( 1.0 / TomeWindow.NUM_REWARD_LEVELS ) * levelPercent
                end
                lastLevelThreshold = LBEventTasks.rewards[level].threshold

                local checked = LBEventTasks.overallCurrentValue >= LBEventTasks.rewards[level].threshold
                ButtonSetPressedFlag( PARENT_WINDOW.."ProgressBarCheck"..level, checked )
            end
        end
        StatusBarSetCurrentValue( PARENT_WINDOW.."ProgressBarStatus", statusBarPercent )
    end

else
end -- ende
WindowSetShowing(PARENT_WINDOW.."Tasks",ActiveEvent ~= nil)
WindowSetShowing(PARENT_WINDOW.."Progress",ActiveEvent ~= nil)
end

local function OnMouseOverReward(level)
    local levelData = LBEventTasks.rewards[level]
    if( levelData ~= nil )
    then
        local reward = WindowGetId( SystemData.ActiveWindow.name )
        local itemData = levelData.items[reward]
        if( itemData ~= nil and itemData.id ~= nil )
        then
            Tooltips.CreateItemTooltip( itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_RIGHT )
        end
    end
end


function RoR_RankedLeaderboard.OnMouseOverReward1()
    OnMouseOverReward( 1 )
end
function RoR_RankedLeaderboard.OnMouseOverReward2()
    OnMouseOverReward( 2 )
end
function RoR_RankedLeaderboard.OnMouseOverReward3()
    OnMouseOverReward( 3 )
end

function RoR_RankedLeaderboard.Editbox_Update(timeElapsed)
if WindowGetShowing("RoR_RankedLeaderboard") == true and SelectedTab == 1 then
if TextEditBoxGetText("RoR_RankedLeaderboardListSearchBox") == L"" then
WindowSetShowing("RoR_RankedLeaderboardListInputText",true)
else
WindowSetShowing("RoR_RankedLeaderboardListInputText",false)
end
--end
end
end

function RoR_RankedLeaderboard.ToggleAdvancedWarWindow()
    RoR_RankedLeaderboard.ToggleShowing()
end

function RoR_RankedLeaderboard.OnMouseoverAdvancedWarBtn()
    WindowUtils.OnMouseOverButton( L"Ranked Leaderboards", nil, nil, Tooltips.ANCHOR_WINDOW_TOP )
end

