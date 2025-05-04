----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------


RoRGroupScoreboard = {}

-- Sorting Parameters for the Player List
RoRGroupScoreboard.playersData = nil
RoRGroupScoreboard.playerListOrder = {}
RoRGroupScoreboard.playersDataRaw = {}

RoRGroupScoreboard.SORT_ORDER_UP			= 1
RoRGroupScoreboard.SORT_ORDER_DOWN			= 2

RoRGroupScoreboard.ArchTypeIcons = {165,106,157,160}

function NewSortData( param_label, param_varName, param_title, param_desc )
    return { label=param_label, variable=param_varName, title=param_title, desc=param_desc }
end

RoRGroupScoreboard.SORT_TYPE_NAME = 1

RoRGroupScoreboard.sortData = {}
RoRGroupScoreboard.sortData[1] = NewSortData( "Name",         "name",         GetString(StringTables.Default.LABEL_PLAYER),        GetString(StringTables.Default.TEXT_SORTBY_PLAYER_GROUP) )
RoRGroupScoreboard.sortData[2] = NewSortData( "GroupKills",   "groupkills",   GetString(StringTables.Default.LABEL_TOTAL_KILLS),   GetString(StringTables.Default.TEXT_SORTBY_KILLS) )
RoRGroupScoreboard.sortData[3] = NewSortData( "Deaths",       "deaths",       GetString(StringTables.Default.LABEL_DEATHS),        GetString(StringTables.Default.TEXT_SORTBY_DEATHS) )
RoRGroupScoreboard.sortData[4] = NewSortData( "DeathBlows",   "deathblows",   GetString(StringTables.Default.LABEL_DEATH_BLOWS),   GetString(StringTables.Default.TEXT_SORTBY_DEATH_BLOWS) )
RoRGroupScoreboard.sortData[5] = NewSortData( "DamageDealt",  "damagedealt",  GetString(StringTables.Default.LABEL_DAMAGE_DEALT),  GetString(StringTables.Default.TEXT_SORTBY_DAMAGE_DEALT) )
RoRGroupScoreboard.sortData[6] = NewSortData( "HealingDealt", "healingdealt", GetString(StringTables.Default.LABEL_HEALING_DEALT), GetString(StringTables.Default.TEXT_SORTBY_HEALING_DEALT) )
RoRGroupScoreboard.sortData[7] = NewSortData( "Protection",   "protection",   GetString(StringTables.Default.LABEL_PROTECTION),    GetString(StringTables.Default.TEXT_SORTBY_PROTECTION) )
RoRGroupScoreboard.sortData[8] = NewSortData( "Career",       "career",       GetString(StringTables.Default.LABEL_CAREER),        GetString(StringTables.Default.TEXT_SORTBY_CAREER_GROUP) )

RoRGroupScoreboard.NUM_SORT_TYPES = 8

-- Keeps tabs on the currently selected player
RoRGroupScoreboard.SelectedPlayerDataIndex	= 0
RoRGroupScoreboard.SelectedPlayerWindow		= ""
RoRGroupScoreboard.SelectedPlayerInListIndex = 0

RoRGroupScoreboard.display = { type=RoRGroupScoreboard.SORT_TYPE_NAME,
                                  order=RoRGroupScoreboard.SORT_ORDER_UP }


-- This function is used as the comparison function for
-- table.sort() on the player display order
local function ComparePlayers( index1, index2 )

    if( index1== nil or index2 == nil ) then
        return false
    end


    local player1 = RoRGroupScoreboard.playersData[index1]
    local player2 = RoRGroupScoreboard.playersData[index2]

    local sortType = RoRGroupScoreboard.display.type
    local order = RoRGroupScoreboard.display.order

    -- Sorting By Name
    if( sortType == RoRGroupScoreboard.SORT_TYPE_NAME ) then
        if( order == RoRGroupScoreboard.SORT_ORDER_UP ) then
            return ( WStringsCompare(towstring(player1.name), towstring(player2.name)) < 0 )
        else
            return ( WStringsCompare(towstring(player1.name), towstring(player2.name)) > 0 )
        end
    end

    -- Sorting By A Numerical Value - When tied, sort by name
    local key = RoRGroupScoreboard.sortData[sortType].variable

    local dataType = type( player1[key] )
    if( order == RoRGroupScoreboard.SORT_ORDER_UP ) then

        if( player1[key] == player2[key] ) then
            return ( WStringsCompare(towstring(player1.name), towstring(player2.name)) < 0 )
        else
            if( dataType == "wstring" ) then
                return ( WStringsCompare(towstring(player1[key]), towstring(player2[key])) < 0 )
            elseif( dataType == "number" ) then
                return ( player1[key] < player2[key] )
            end
        end
    else
        if( player1[key] == player2[key] ) then
            return ( WStringsCompare(towstring(player1.name), towstring(player2.name)) < 0 )
        else
            if( dataType == "wstring" ) then
                return ( WStringsCompare(towstring(player1[key]), towstring(player2[key])) > 0 )
            elseif( dataType == "number" ) then
                    if( player1[key]== nil or player2[key] == nil ) then
						return false
					end
				return ( player1[key] > player2[key] )
            end
        end
    end

end

local function SortPlayerList()

    local type = RoRGroupScoreboard.display.type
    local order = RoRGroupScoreboard.display.order

    table.sort( RoRGroupScoreboard.playerListOrder, ComparePlayers )

end

local function FilterPlayerList()	
	RoRGroupScoreboard.playersData = {}
    RoRGroupScoreboard.playerListOrder = {}
    if( RoRGroupScoreboard.playersDataRaw == nil ) then
        return
    end
	local i=1
    for dataIndex, data in pairs( RoRGroupScoreboard.playersDataRaw ) do
        table.insert(RoRGroupScoreboard.playerListOrder, i)
		table.insert(RoRGroupScoreboard.playersData,data)
		i=i+1
    end

end

local function UpdatePlayerList()

    -- Sort, and Update
    FilterPlayerList()
    SortPlayerList()
    ListBoxSetDisplayOrder( "RoRGroupScoreboardPlayerList", RoRGroupScoreboard.playerListOrder )

end

-- The format is: GRP_STATS=<charid>:<stat1value>;<stat2value>;<stat3value>;<stat4value>|<charid>:<stat1value>;<stat2value>;<stat3value>;<stat4value>
local function UpdatePlayerData()

	if RoRGroupScoreboard.playersDataString == nil then return end
	
	local v = RoRGroupScoreboard.playersDataString.scoreboard
	local charId = RoRGroupScoreboard.playersDataString.characterId

	if v == nil or v.name == nil then
		d(L"removed")
		RoRGroupScoreboard.playersDataRaw[charId] = nil	
		UpdatePlayerList()
		return
	end

	--d(v)
	--RoRGroupScoreboard.playersData = {}

	--for charId,v in pairs(RoRGroupScoreboard.playersDataString.entries) do

        RoRGroupScoreboard.playersDataRaw[charId] = {}
        RoRGroupScoreboard.playersDataRaw[charId].name = towstring(v.name)
        RoRGroupScoreboard.playersDataRaw[charId].careerIcon = Icons.GetCareerIconIDFromCareerLine(tonumber(v.career))
        RoRGroupScoreboard.playersDataRaw[charId].archtype = tonumber(v.archetype)
        RoRGroupScoreboard.playersDataRaw[charId].career = v.career
        RoRGroupScoreboard.playersDataRaw[charId].groupkills= tonumber(v.kills)
        RoRGroupScoreboard.playersDataRaw[charId].deaths = tonumber(v.deaths)
        RoRGroupScoreboard.playersDataRaw[charId].deathblows = tonumber(v.deathBlows)
        RoRGroupScoreboard.playersDataRaw[charId].damagedealt = tonumber(v.damage)
        RoRGroupScoreboard.playersDataRaw[charId].healingdealt = tonumber(v.healing)
        RoRGroupScoreboard.playersDataRaw[charId].protection = tonumber(v.protection)
		RoRGroupScoreboard.playersDataRaw[charId].charId = tonumber(charId)


        RoRGroupScoreboard.playersDataRaw[charId].killsSolo = tonumber(v.killsSolo)
		RoRGroupScoreboard.playersDataRaw[charId].killDamage = tonumber(v.killDamage)
		RoRGroupScoreboard.playersDataRaw[charId].healingSelf = tonumber(v.healingSelf)
		RoRGroupScoreboard.playersDataRaw[charId].healingOthers = tonumber(v.healingOthers)
		RoRGroupScoreboard.playersDataRaw[charId].protectionSelf = tonumber(v.protectionSelf)
		RoRGroupScoreboard.playersDataRaw[charId].protectionOthers = tonumber(v.protectionOthers)
		RoRGroupScoreboard.playersDataRaw[charId].damageReceived = tonumber(v.damageReceived)
		RoRGroupScoreboard.playersDataRaw[charId].resurrectionsDone = tonumber(v.resurrectionsDone)		
		RoRGroupScoreboard.playersDataRaw[charId].healingReceived = tonumber(v.healingReceived)		
		RoRGroupScoreboard.playersDataRaw[charId].protectionReceived = tonumber(v.protectionReceived)				
	--end

    UpdatePlayerList()
end

----------------------------------------------------------------
-- RoRGroupScoreboard Functions
----------------------------------------------------------------

-- OnInitialize Handler
function RoRGroupScoreboard.Initialize()
	ror_PacketHandling.Register("GRP_STATS",RoRGroupScoreboard.Packet)
    WindowRegisterEventHandler( "RoRGroupScoreboard", SystemData.Events.TOGGLE_SCENARIO_SUMMARY_WINDOW, "RoRGroupScoreboard.ToggleShowing" )
    if LibSlash then LibSlash.RegisterSlashCmd("GroupScoreboard", function() RoRGroupScoreboard.ToggleShowing() end) end

    -- Set sort button flags
    for index = 2, RoRGroupScoreboard.NUM_SORT_TYPES do
        local window = "RoRGroupScoreboardPlayerListHeader"..RoRGroupScoreboard.sortData[index].label
        ButtonSetStayDownFlag( window, true )
    end

    -- Column text headings
    ButtonSetText("RoRGroupScoreboardPlayerListHeaderName", GetString(StringTables.Default.LABEL_NAME) )
    ButtonSetText("RoRGroupScoreboardPlayerListHeaderCareer", GetString(StringTables.Default.LABEL_CAREER) )
    ButtonSetText("RoRGroupScoreboardPlayerListHeaderGroupKillsText", GetString(StringTables.Default.LABEL_KILLS) )
    ButtonSetText("RoRGroupScoreboardPlayerListHeaderDeathsText", GetString(StringTables.Default.LABEL_DEATHS) )
    ButtonSetText("RoRGroupScoreboardPlayerListHeaderDeathBlowsText", GetString(StringTables.Default.LABEL_DEATH_BLOWS_SHORT) )
    ButtonSetText("RoRGroupScoreboardPlayerListHeaderDamageDealtText", GetString(StringTables.Default.LABEL_DAMAGE) )
    ButtonSetText("RoRGroupScoreboardPlayerListHeaderHealingDealtText", GetString(StringTables.Default.LABEL_HEALING_DEALT_SHORT) )
    ButtonSetText("RoRGroupScoreboardPlayerListHeaderProtectionText", GetString(StringTables.Default.LABEL_PROTECTION_SHORT) )

    -- Leave now button
    ButtonSetText("RoRGroupScoreboardResetButton", L"Reset")

	RoRGroupScoreboard.playersData = {}

    -- First Update the player list
    RoRGroupScoreboard.OnPlayerListUpdated()

    RoRGroupScoreboard.UpdateSortButtons()
	
RegisterEventHandler( SystemData.Events.GROUP_UPDATED, "RoRGroupScoreboard.GROUP_UPDATED")
RegisterEventHandler( SystemData.Events.BATTLEGROUP_UPDATED, "RoRGroupScoreboard.GROUP_UPDATED")
RoRGroupScoreboard.IsInParty = PartyUtils.IsPartyActive() or IsWarBandActive()	
end


function RoRGroupScoreboard.GROUP_UPDATED(...)
if RoRGroupScoreboard.IsInParty == false then
		if PartyUtils.IsPartyActive() or IsWarBandActive() then
			RoRGroupScoreboard.playersDataRaw = {}
			UpdatePlayerList()
		end
end

RoRGroupScoreboard.IsInParty = PartyUtils.IsPartyActive() or IsWarBandActive()
UpdatePlayerList()
end

function RoRGroupScoreboard.Packet(text)
local text = string.gsub(text,"GRP_STATS:","")
local RoRGroupScoreboardTable = json.decode(text)

		RoRGroupScoreboard.playersDataString = RoRGroupScoreboardTable
		--RoRGroupScoreboard.playersData = nil
      --  if ( WindowGetShowing( "RoRGroupScoreboard" )) then
            UpdatePlayerData()
        --end
end

function RoRGroupScoreboard.ToggleShowing()
    if ( not GameData.Player.isInScenario) and (not GameData.Player.isInSiege) and RoRGroupScoreboard.playersDataString ~= nil and ( not WindowGetShowing("ScenarioSummaryWindow")) then
        WindowUtils.ToggleShowing( "RoRGroupScoreboard" )
    else
        WindowSetShowing("RoRGroupScoreboard", false)
    end
end

function RoRGroupScoreboard.OnShown()
    WindowUtils.OnShown()
    UpdatePlayerData()
end

function RoRGroupScoreboard.OnHidden()
    WindowUtils.OnHidden()
end

function RoRGroupScoreboard.OnPlayerListUpdated()
    UpdatePlayerData()
end

function RoRGroupScoreboard.OnPlayerListStatsUpdated()
    UpdatePlayerData()
end

-- Callback from the <List> that updates a single row.
function RoRGroupScoreboard.UpdatePlayerIcon(rowFrame, memberData)

    if memberData.careerIcon ~= nil and memberData.careerIcon ~=0 then
        local texture, x, y = GetIconData(memberData.careerIcon)
        DynamicImageSetTexture(rowFrame.."CareerIcon", texture, x, y)
        WindowSetShowing(rowFrame.."CareerIcon", true)
        
        local ATIcon = memberData.archtype
        if ATIcon > 0 then
            WindowSetShowing(rowFrame.."ArchType",true)
        local texture2, x2, y2 = GetIconData(RoRGroupScoreboard.ArchTypeIcons[ATIcon])
            DynamicImageSetTexture(rowFrame.."ArchType", texture2, x2, y2)    
        else
            WindowSetShowing(rowFrame.."ArchType",false)
        end
    else
        WindowSetShowing(rowFrame.."ArchType",false)
        WindowSetShowing(rowFrame.."CareerIcon", false)
    end
end

function RoRGroupScoreboard.UpdatePlayerRow()

    if (RoRGroupScoreboardPlayerList.PopulatorIndices ~= nil) then
        for rowIndex, dataIndex in ipairs (RoRGroupScoreboardPlayerList.PopulatorIndices) do
            local playerData = RoRGroupScoreboard.playersData[ dataIndex ]
            local rowFrame = "RoRGroupScoreboardPlayerListRow"..rowIndex
            RoRGroupScoreboard.UpdatePlayerIcon(rowFrame, playerData)
            local row_mod = math.mod (rowIndex, 2)
            local text_color = DefaultColor.WHITE
            local labelName = "RoRGroupScoreboardPlayerListRow"..rowIndex.."Name"
            local row_color = GameDefs.RowColors[row_mod]

            for columnIndex, sortData in ipairs (RoRGroupScoreboard.sortData) do
                local name = sortData.label
                WindowSetTintColor("RoRGroupScoreboardPlayerListRow"..rowIndex.."Background"..name, row_color.r, row_color.g, row_color.b)
                WindowSetAlpha("RoRGroupScoreboardPlayerListRow"..rowIndex.."Background"..name, row_color.a)
                LabelSetTextColor("RoRGroupScoreboardPlayerListRow"..rowIndex..name, text_color.r,text_color.g, text_color.b)
            end

            SetSelectedColumnColor( rowIndex, "RoRGroupScoreboardPlayerListRow"..rowIndex, RoRGroupScoreboard.display.type )

            if (dataIndex == RoRGroupScoreboard.SelectedPlayerDataIndex) then
                RoRGroupScoreboard.HighlightPlayerInList( rowIndex, true, false)
            else
                RoRGroupScoreboard.HighlightPlayerInList( rowIndex, false, false)
            end
        end
    end

end

-- Sets the color for the selected column
function SetSelectedColumnColor( rowIndex, rowName, sortType )

    if (RoRGroupScoreboard.display.type == RoRGroupScoreboard.SORT_TYPE_NAME) then
        return
    end

    local row_mod = math.mod (rowIndex, 2)
    local windowName = "Background"..RoRGroupScoreboard.sortData[ sortType ].label

    local color = GameDefs.RowColorHighlighted
    if (row_mod == 0) then
        color = DataUtils.GetAlternatingRowColor(0)
    end

    WindowSetTintColor(rowName..windowName, color.r, color.g, color.b)
    WindowSetAlpha(rowName..windowName, color.a)

end

-- Button Callback for the Header Sort Buttons
function RoRGroupScoreboard.OnSortPlayerList()

    local type = WindowGetId( SystemData.ActiveWindow.name )

    -- If we are already using this sort type, toggle the order.
    if( type == RoRGroupScoreboard.display.type ) then
        if( RoRGroupScoreboard.display.order == RoRGroupScoreboard.SORT_ORDER_UP ) then
            RoRGroupScoreboard.display.order = RoRGroupScoreboard.SORT_ORDER_DOWN
        else
            RoRGroupScoreboard.display.order = RoRGroupScoreboard.SORT_ORDER_UP
        end

    -- Otherwise change the type and use the up order.
    else
        RoRGroupScoreboard.display.type = type
        RoRGroupScoreboard.display.order = RoRGroupScoreboard.SORT_ORDER_DOWN
    end

    UpdatePlayerList()

    if( RoRGroupScoreboardPlayerList.PopulatorIndices ) then
        for rowIndex, dataIndex in ipairs (RoRGroupScoreboardPlayerList.PopulatorIndices) do
            SetSelectedColumnColor( rowIndex, "RoRGroupScoreboardPlayerListRow"..rowIndex, RoRGroupScoreboard.display.type )
        end
    end

    RoRGroupScoreboard.UpdateSortButtons()

end

-- Displays the clicked sort button as pressed down and positions an arrow above it
function RoRGroupScoreboard.UpdateSortButtons()

    local type = RoRGroupScoreboard.display.type
    local order = RoRGroupScoreboard.display.order

    for index = 2, RoRGroupScoreboard.NUM_SORT_TYPES do
        local window = "RoRGroupScoreboardPlayerListHeader"..RoRGroupScoreboard.sortData[index].label
        ButtonSetPressedFlag( window, index == RoRGroupScoreboard.display.type )
    end

    -- Only move the arrow around for sorting on everything but the name
    if (type > RoRGroupScoreboard.SORT_TYPE_NAME ) then
        WindowSetShowing( "RoRGroupScoreboardPlayerListHeaderUpArrow", order == RoRGroupScoreboard.SORT_ORDER_UP )
        WindowSetShowing( "RoRGroupScoreboardPlayerListHeaderDownArrow", order == RoRGroupScoreboard.SORT_ORDER_DOWN )

        local window = "RoRGroupScoreboardPlayerListHeader"..RoRGroupScoreboard.sortData[type].label

        if( order == RoRGroupScoreboard.SORT_ORDER_UP ) then
            WindowClearAnchors( "RoRGroupScoreboardPlayerListHeaderUpArrow" )
            WindowAddAnchor("RoRGroupScoreboardPlayerListHeaderUpArrow", "top", window, "top", 0, -28 )

        else
            WindowClearAnchors( "RoRGroupScoreboardPlayerListHeaderDownArrow" )
            WindowAddAnchor("RoRGroupScoreboardPlayerListHeaderDownArrow", "top", window, "top", 0, -28 )

        end
    else
        WindowSetShowing( "RoRGroupScoreboardPlayerListHeaderUpArrow", false )
        WindowSetShowing( "RoRGroupScoreboardPlayerListHeaderDownArrow", false )

    end

end

-- Displays a tooltip with information on the type of sort being hovered over
function RoRGroupScoreboard.OnMouseOverSortButton()

    local windowName	= SystemData.ActiveWindow.name
    local windowIndex	= WindowGetId (windowName)

    local titleText = RoRGroupScoreboard.sortData[windowIndex].title
    local descText = RoRGroupScoreboard.sortData[windowIndex].desc

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, titleText)
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
    Tooltips.SetTooltipText (2, 1, descText)
    Tooltips.SetTooltipActionText (GetString (StringTables.Default.TEXT_SORT_DIRECTIONS))
    Tooltips.Finalize ()

    local anchor = { Point="topleft", RelativeTo=windowName, RelativePoint="center", XOffset=0, YOffset=-70 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)

end

-- Handles the Left Button click on a player row
function RoRGroupScoreboard.OnLButtonUpPlayerRow()

    local row = WindowGetId( SystemData.ActiveWindow.name )
    RoRGroupScoreboard.HighlightPlayerInList(row, true, true)

end

-- Handles the Right Button click on a player row
function RoRGroupScoreboard.OnRButtonUpPlayerRow()

    local row = WindowGetId( SystemData.ActiveWindow.name )
    RoRGroupScoreboard.HighlightPlayerInList( row, false, false )
    RoRGroupScoreboard.SelectedPlayerDataIndex = 0

end

-- Highlights the specified player data in its list
--		TODO: Eventually we will need to isolate player by name *and* server! (gnelson 4/17/07)
function RoRGroupScoreboard.HighlightPlayerInList( rowIndex, bVisible, bFromLButtonEvent )

    local dataIndex = RoRGroupScoreboardPlayerList.PopulatorIndices[rowIndex]
    local playerData = RoRGroupScoreboard.playersData[ dataIndex ]

    -- Get the player's indexed data from the GameData list and update the lower fields
    if (bFromLButtonEvent) then
        RoRGroupScoreboard.SelectedPlayerDataIndex = dataIndex
    end

    -- Clear selected player info from both lists
    if (bFromLButtonEvent) then
        RoRGroupScoreboard.UpdatePlayerRow ()
    end

    -- Determine the text c olor
    local color
    if (bVisible) then
        color = { r=255, g=204, b=102 }
    else
        color = DefaultColor.WHITE
    end

    for columnIndex, sortData in ipairs (RoRGroupScoreboard.sortData) do
        local name = sortData.label
        LabelSetTextColor("RoRGroupScoreboardPlayerListRow"..rowIndex..name, color.r, color.g, color.b);
    end

    -- Show the border box around the selected player
    WindowSetShowing("RoRGroupScoreboardPlayerListRow"..rowIndex.."SelectionBorder", bVisible)

end

function RoRGroupScoreboard.OnResetClicked()
    SendChatText(L"]groupscoreboardreset", ChatSettings.Channels[0].serverCmd)
end

function RoRGroupScoreboard.OnVertScrollLButtonUp()
    -- dummy LButtonUp handler for the scrollbars to stop them from
    -- failing to handle for lack of a LUA script event handler
end

function RoRGroupScoreboard.GetExtendedStat(playerName, statId)

    if RoRGroupScoreboard.playersData == nil then return L"0" end
    if RoRGroupScoreboard.playersData[playerName] == nil then return L"0" end
    if RoRGroupScoreboard.playersData[playerName][statId] == nil then return L"0" end

    return RoR_ScenarioExtendedStats.playersData[playerName][statId]

end

-- Displays a tooltip with information on the type of sort being hovered over
function RoRGroupScoreboard.OnMouseOverPlayerRow()
    if RoR_ScenarioExtendedStats == nil then return end
    -- Parse values if we have no cached version
    if RoR_ScenarioExtendedStats.playersData == nil then UpdatePlayerData() end

    local windowName	= SystemData.ActiveWindow.name
    local rowIndex	    = WindowGetId (windowName)
    local playerIndex   = ListBoxGetDataIndex( "RoRGroupScoreboardPlayerList", rowIndex )
    local categoryName  = windowName:gsub("RoRGroupScoreboardPlayerListRow%d+", "")
    local extendedStats = RoRGroupScoreboard.playersData[playerIndex]

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    if categoryName == "GroupKills" then
        Tooltips.SetTooltipText (1, 1, GetString(StringTables.Default.LABEL_KILLS))
        Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
        Tooltips.SetTooltipText (2, 1, GetString(StringTables.Default.LABEL_SOLO_KILLS)..L": "..towstring(extendedStats.killsSolo))
    elseif categoryName == "Deaths" then
        Tooltips.SetTooltipText (1, 1, GetString(StringTables.Default.LABEL_DEATHS))
        Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
        Tooltips.SetTooltipText (2, 1, GetString(StringTables.Default.LABEL_DAMAGE_RECEIVED)..L": "..towstring(extendedStats.damageReceived))
        Tooltips.SetTooltipText (3, 1, GetString(StringTables.Default.LABEL_HEALING_RECEIVED)..L": "..towstring(extendedStats.healingReceived))
        Tooltips.SetTooltipText (4, 1, GetString(StringTables.Default.LABEL_PROTECTION_RECEIVED)..L": "..towstring(extendedStats.protectionReceived))
    elseif categoryName == "DamageDealt" then
        Tooltips.SetTooltipText (1, 1, GetString(StringTables.Default.LABEL_DAMAGE))
        Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
        Tooltips.SetTooltipText (2, 1, GetString(StringTables.Default.LABEL_DAMAGE_KILLS)..L": "..towstring(extendedStats.killDamage))
    elseif categoryName == "HealingDealt" then
        Tooltips.SetTooltipText (1, 1, GetString(StringTables.Default.LABEL_HEALING_DEALT_SHORT))
        Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
        Tooltips.SetTooltipText (2, 1, GetString(StringTables.Default.LABEL_HEALING_SELF)..L": "..towstring(extendedStats.healingSelf))
        Tooltips.SetTooltipText (3, 1, GetString(StringTables.Default.LABEL_HEALING_OTHERS)..L": "..towstring(extendedStats.healingOthers))
        Tooltips.SetTooltipText (4, 1, GetString(StringTables.Default.LABEL_RESURRECTIONS)..L": "..towstring(extendedStats.resurrectionsDone))
    elseif categoryName == "Protection" then
        Tooltips.SetTooltipText (1, 1, GetString(StringTables.Default.LABEL_PROTECTION_SHORT))
        Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
        Tooltips.SetTooltipText (2, 1, GetString(StringTables.Default.LABEL_PROTECTION_SELF)..L": "..towstring(extendedStats.protectionSelf))
        Tooltips.SetTooltipText (3, 1, GetString(StringTables.Default.LABEL_PROTECTION_OTHERS)..L": "..towstring(extendedStats.protectionOthers))
    end
    Tooltips.Finalize ()

    local anchor = { Point="top", RelativeTo=windowName, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)

end