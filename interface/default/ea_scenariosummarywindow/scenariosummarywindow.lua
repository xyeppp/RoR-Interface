----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------


ScenarioSummaryWindow = {}

-- Sorting Parameters for the Player List
ScenarioSummaryWindow.playersData = nil
ScenarioSummaryWindow.playerListOrder = {}

ScenarioSummaryWindow.SORT_ORDER_UP				= 1
ScenarioSummaryWindow.SORT_ORDER_DOWN			= 2

ScenarioSummaryWindow.FILTER_REALM_ORDER_ONLY	= 1
ScenarioSummaryWindow.FILTER_REALM_DESTR_ONLY	= 2
ScenarioSummaryWindow.FILTER_REALM_SHOW_ALL		= 3
ScenarioSummaryWindow.NUM_FILTER_TYPES			= 3

ScenarioSummaryWindow.ArchetypeIcons = {165,106,157,160}
                
            
function NewSortData( param_label, param_varName, param_title, param_desc )
    return { label=param_label, variable=param_varName, title=param_title, desc=param_desc }
end
            
ScenarioSummaryWindow.SORT_TYPE_NAME = 1
            
ScenarioSummaryWindow.sortData = {}	
ScenarioSummaryWindow.sortData[1] = NewSortData( "Name",        "name",         GetString(StringTables.Default.LABEL_PLAYER),        GetString(StringTables.Default.TEXT_SORTBY_PLAYER) )
ScenarioSummaryWindow.sortData[2] = NewSortData( "GroupKills",  "groupkills",   GetString(StringTables.Default.LABEL_TOTAL_KILLS),         GetString(StringTables.Default.TEXT_SORTBY_KILLS) )
ScenarioSummaryWindow.sortData[3] = NewSortData( "Deaths",      "deaths",       GetString(StringTables.Default.LABEL_DEATHS),        GetString(StringTables.Default.TEXT_SORTBY_DEATHS) )
ScenarioSummaryWindow.sortData[4] = NewSortData( "DeathBlows",  "deathblows",   GetString(StringTables.Default.LABEL_DEATH_BLOWS),   GetString(StringTables.Default.TEXT_SORTBY_DEATH_BLOWS) )
ScenarioSummaryWindow.sortData[5] = NewSortData( "DamageDealt", "damagedealt",  GetString(StringTables.Default.LABEL_DAMAGE_DEALT),  GetString(StringTables.Default.TEXT_SORTBY_DAMAGE_DEALT) )
ScenarioSummaryWindow.sortData[6] = NewSortData( "KillDamageDealt",         "killdamagedealt",          GetString(StringTables.Default.LABEL_KILL_DAMAGE_DEALT),           GetString(StringTables.Default.TEXT_SORTBY_KILL_DAMAGE_DEALT)) 
ScenarioSummaryWindow.sortData[7] = NewSortData( "HealingDealt", "healingdealt", GetString(StringTables.Default.LABEL_HEALING_DEALT), GetString(StringTables.Default.TEXT_SORTBY_HEALING_DEALT) )
ScenarioSummaryWindow.sortData[8] = NewSortData( "Protection",   "protection",    GetString(StringTables.Default.LABEL_PROTECTION),    GetString(StringTables.Default.TEXT_SORTBY_PROTECTION) )
ScenarioSummaryWindow.sortData[9] = NewSortData( "Career",      "career",       GetString(StringTables.Default.LABEL_CAREER),        GetString(StringTables.Default.TEXT_SORTBY_CAREER) )
ScenarioSummaryWindow.sortData[10] = NewSortData( "Rank",        "rank",         GetString(StringTables.Default.LABEL_RANK),          GetString(StringTables.Default.TEXT_SORTBY_RANK) )
ScenarioSummaryWindow.sortData[11] = NewSortData( "ObjectiveScore",  "objectivescore",   GetString(StringTables.Default.LABEL_OBJECTIVESCORE),          GetString(StringTables.Default.TEXT_SORTBY_OBJECTIVESCORE)) 

ScenarioSummaryWindow.NUM_SORT_TYPES = 11

                                
-- Keeps tabs on the currently selected player
ScenarioSummaryWindow.SelectedPlayerDataIndex	= 0
ScenarioSummaryWindow.SelectedPlayerWindow		= ""
ScenarioSummaryWindow.SelectedPlayerInListIndex = 0

ScenarioSummaryWindow.display = { type=ScenarioSummaryWindow.SORT_TYPE_NAME, 
                                  order=ScenarioSummaryWindow.SORT_ORDER_UP, 
                                  filter=ScenarioSummaryWindow.FILTER_REALM_SHOW_ALL }
                                  

ScenarioSummaryWindow.MODE_IN_PROGRESS    = 1
ScenarioSummaryWindow.MODE_POST_MODE      = 2
ScenarioSummaryWindow.MODE_LOADING_SCREEN = 3
ScenarioSummaryWindow.currentMode = ScenarioSummaryWindow.MODE_IN_PROGRESS

ScenarioSummaryWindow.scenarioMaxDuration = 0
ScenarioSummaryWindow.lastTimeLeft = 0
                                   
-- This function is used as the comparison function for 
-- table.sort() on the player display order
local function ComparePlayers( index1, index2 )

    if( index2 == nil ) then
        return false
    end

    
    local player1 = ScenarioSummaryWindow.playersData[index1]
    local player2 = ScenarioSummaryWindow.playersData[index2]

    local sortType = ScenarioSummaryWindow.display.type
    local order = ScenarioSummaryWindow.display.order

    -- Sorting By Name
    if( sortType == ScenarioSummaryWindow.SORT_TYPE_NAME ) then
        if( order == ScenarioSummaryWindow.SORT_ORDER_UP ) then
            return ( WStringsCompare(player1.name, player2.name) < 0 )
        else
            return ( WStringsCompare(player1.name, player2.name) > 0 )
        end		
    end
    
    -- Sorting By A Numerical Value - When tied, sort by name
    local key = ScenarioSummaryWindow.sortData[sortType].variable
    
    local dataType = type( player1[key] )   
    if( order == ScenarioSummaryWindow.SORT_ORDER_UP ) then			
        
        if( player1[key] == player2[key] ) then
            return ( WStringsCompare(player1.name, player2.name) < 0 )
        else
            if( dataType == "wstring" ) then
                return ( WStringsCompare(player1[key], player2[key]) < 0 )		       
            elseif( dataType == "number" ) then		
                return ( player1[key] < player2[key] )
            end
        end
    else
        if( player1[key] == player2[key] ) then
            return ( WStringsCompare(player1.name, player2.name) < 0 )
        else		
            if( dataType == "wstring" ) then
                return ( WStringsCompare(player1[key], player2[key]) > 0 )		       
            elseif( dataType == "number" ) then		
                return ( player1[key] > player2[key] )
            end
        end
    end	
    
end
    
local function SortPlayerList()	

    local type = ScenarioSummaryWindow.display.type
    local order = ScenarioSummaryWindow.display.order
    
    table.sort( ScenarioSummaryWindow.playerListOrder, ComparePlayers )
    
end

local function FilterPlayerList()	

    ScenarioSummaryWindow.playerListOrder = {}	
    if( ScenarioSummaryWindow.playersData == nil ) then
        return
    end

    local filter = ScenarioSummaryWindow.display.filter

    for dataIndex, data in ipairs( ScenarioSummaryWindow.playersData ) do	
        if( data.name ~= L"" and ( filter == ScenarioSummaryWindow.FILTER_REALM_SHOW_ALL or filter == data.realm ) )then
            table.insert(ScenarioSummaryWindow.playerListOrder, dataIndex)
        end
    end
    
end

local function UpdatePlayerList()

    -- Filter, Sort, and Update
    FilterPlayerList()
    SortPlayerList()
    ListBoxSetDisplayOrder( "ScenarioSummaryWindowPlayerList", ScenarioSummaryWindow.playerListOrder )	
    
end

local function UpdatePlayerData()   
    ScenarioSummaryWindow.playersData = {}
    
    local interimPlayerData = GameData.GetScenarioPlayers()
    if( interimPlayerData ~= nil ) then
        
        for key, value in ipairs( interimPlayerData ) do
            ScenarioSummaryWindow.playersData[key] = {}
            ScenarioSummaryWindow.playersData[key].name = value.name
            ScenarioSummaryWindow.playersData[key].career = value.career
            ScenarioSummaryWindow.playersData[key].archetype = tonumber(string.sub(value.experiencebonus, -1))
            ScenarioSummaryWindow.playersData[key].rank = value.rank
            ScenarioSummaryWindow.playersData[key].realm = value.realm
            ScenarioSummaryWindow.playersData[key].protection = value.solokills
            ScenarioSummaryWindow.playersData[key].groupkills= value.groupkills
            ScenarioSummaryWindow.playersData[key].renown = value.renown
            ScenarioSummaryWindow.playersData[key].deaths = value.deaths
            ScenarioSummaryWindow.playersData[key].damagedealt = value.damagedealt
            ScenarioSummaryWindow.playersData[key].deathblows = value.deathblows
            ScenarioSummaryWindow.playersData[key].healingdealt = value.healingdealt
            ScenarioSummaryWindow.playersData[key].renownbonus = value.renown
            ScenarioSummaryWindow.playersData[key].experience = value.experience
            ScenarioSummaryWindow.playersData[key].experiencebonus = value.experience
            ScenarioSummaryWindow.playersData[key].isplayer = value.isplayer
            ScenarioSummaryWindow.playersData[key].careerIcon = Icons.GetCareerIconIDFromCareerNamesID(value.careerId)
			ScenarioSummaryWindow.playersData[key].objectivescore = tonumber(string.sub(value.experiencebonus, 1, -2))
			ScenarioSummaryWindow.playersData[key].killdamagedealt = value.renownbonus
        end
    end

    UpdatePlayerList()
    
end

----------------------------------------------------------------
-- ScenarioSummaryWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function ScenarioSummaryWindow.Initialize()

    WindowRegisterEventHandler( "ScenarioSummaryWindow", SystemData.Events.SCENARIO_BEGIN, "ScenarioSummaryWindow.OnScenarioBegin")
    WindowRegisterEventHandler( "ScenarioSummaryWindow", SystemData.Events.LOADING_END,  "ScenarioSummaryWindow.OnLoadingEnd" )
    WindowRegisterEventHandler( "ScenarioSummaryWindow", SystemData.Events.SCENARIO_UPDATE_POINTS, "ScenarioSummaryWindow.OnUpdateScenarioPoints")
    WindowRegisterEventHandler( "ScenarioSummaryWindow", SystemData.Events.CITY_SCENARIO_UPDATE_POINTS, "ScenarioSummaryWindow.OnUpdateScenarioPoints")
    WindowRegisterEventHandler( "ScenarioSummaryWindow", SystemData.Events.SCENARIO_PLAYERS_LIST_UPDATED, "ScenarioSummaryWindow.OnPlayerListUpdated")
    WindowRegisterEventHandler( "ScenarioSummaryWindow", SystemData.Events.SCENARIO_PLAYERS_LIST_STATS_UPDATED, "ScenarioSummaryWindow.OnPlayerListStatsUpdated")
    WindowRegisterEventHandler( "ScenarioSummaryWindow", SystemData.Events.SCENARIO_POST_MODE, "ScenarioSummaryWindow.ShowIfInPostMode" )
    WindowRegisterEventHandler( "ScenarioSummaryWindow", SystemData.Events.TOGGLE_SCENARIO_SUMMARY_WINDOW,  "ScenarioSummaryWindow.ToggleShowing" )
    
        
    LabelSetText("ScenarioSummaryWindowBonusXPLabel", GetString(StringTables.Default.LABEL_XP_EARNED ) )
    LabelSetText("ScenarioSummaryWindowBonusRenownLabel", GetString(StringTables.Default.LABEL_RENOWN_EARNED ) )
    
    LabelSetText("ScenarioSummaryWindowOrderLabel", wstring.upper(GetString(StringTables.Default.LABEL_ORDER )) )
    LabelSetText("ScenarioSummaryWindowDestructionLabel", wstring.upper(GetString(StringTables.Default.LABEL_DESTRUCTION )) )

    -- Set the correct realm colors for the realm labels
    local color = DataUtils.GetRealmColor (GameData.Realm.ORDER)
    LabelSetTextColor ("ScenarioSummaryWindowOrderLabel", color.r, color.g, color.b)	
    
    color = DataUtils.GetRealmColor (GameData.Realm.DESTRUCTION)
    LabelSetTextColor ("ScenarioSummaryWindowDestructionLabel", color.r, color.g, color.b)
    
    -- Filter Combo	
    ComboBoxAddMenuItem( "ScenarioSummaryWindowPlayerListHeaderFilterCombo", GetString( StringTables.Default.LABEL_ORDER ) )
    ComboBoxAddMenuItem( "ScenarioSummaryWindowPlayerListHeaderFilterCombo", GetString( StringTables.Default.LABEL_DESTRUCTION ) )
    ComboBoxAddMenuItem( "ScenarioSummaryWindowPlayerListHeaderFilterCombo", GetString( StringTables.Default.LABEL_ALL_PLAYERS ) )
    ComboBoxSetSelectedMenuItem( "ScenarioSummaryWindowPlayerListHeaderFilterCombo", ScenarioSummaryWindow.FILTER_REALM_SHOW_ALL )
    
            
    -- Set sort button flags
    for index = 2, ScenarioSummaryWindow.NUM_SORT_TYPES do
        local window = "ScenarioSummaryWindowPlayerListHeader"..ScenarioSummaryWindow.sortData[index].label
        ButtonSetStayDownFlag( window, true )
    end
    
    -- Column text headings
    ButtonSetText("ScenarioSummaryWindowPlayerListHeaderName", GetString(StringTables.Default.LABEL_NAME) )
    ButtonSetText("ScenarioSummaryWindowPlayerListHeaderCareer", GetString(StringTables.Default.LABEL_CAREER) )
    ButtonSetText("ScenarioSummaryWindowPlayerListHeaderRankText", GetString(StringTables.Default.LABEL_RANK) )
    ButtonSetText("ScenarioSummaryWindowPlayerListHeaderGroupKillsText", GetString(StringTables.Default.LABEL_KILLS) )
    ButtonSetText("ScenarioSummaryWindowPlayerListHeaderDeathsText", GetString(StringTables.Default.LABEL_DEATHS) )
    ButtonSetText("ScenarioSummaryWindowPlayerListHeaderDeathBlowsText", GetString(StringTables.Default.LABEL_DEATH_BLOWS_SHORT) )
    ButtonSetText("ScenarioSummaryWindowPlayerListHeaderDamageDealtText", GetString(StringTables.Default.LABEL_DAMAGE) )
    ButtonSetText("ScenarioSummaryWindowPlayerListHeaderKillDamageDealtText", GetString(StringTables.Default.LABEL_KILL_DAMAGE) )
    ButtonSetText("ScenarioSummaryWindowPlayerListHeaderHealingDealtText", GetString(StringTables.Default.LABEL_HEALING_DEALT_SHORT) )
    ButtonSetText("ScenarioSummaryWindowPlayerListHeaderProtectionText", GetString(StringTables.Default.LABEL_PROTECTION_SHORT) )
    ButtonSetText("ScenarioSummaryWindowPlayerListHeaderObjectiveScoreText", GetString(StringTables.Default.LABEL_OBJECTIVESCORE) )  
	
    -- Leave now button
    ButtonSetText("ScenarioSummaryWindowLeaveNowButton", GetString(StringTables.Default.LABEL_LEAVE_NOW))
        
    -- First Update the player list
    ScenarioSummaryWindow.OnPlayerListUpdated()
        
    ScenarioSummaryWindow.UpdateScenarioInfo()
    ScenarioSummaryWindow.OnUpdateScenarioPoints()
    ScenarioSummaryWindow.UpdateBonusInfo(false)
    ScenarioSummaryWindow.HideVictorInfo()
    ScenarioSummaryWindow.UpdateSortButtons()
    
    ScenarioSummaryWindow.SetDisplayMode( ScenarioSummaryWindow.MODE_IN_PROGRESS )
    
    ScenarioSummaryWindow.ShowIfInPostMode()

end

function ScenarioSummaryWindow.UpdateBonusInfo(shouldShow)

    if ( shouldShow ) then
        local xpBonus = 0
        local renownBonus = 0
        if ( ScenarioSummaryWindow.playersData ) then
            for index, player in ipairs( ScenarioSummaryWindow.playersData ) do
                if ( player.isplayer ) then
                    xpBonus = player.experiencebonus
                    renownBonus = player.renownbonus
                    break
                end
            end
        end
    
        LabelSetText( "ScenarioSummaryWindowBonusXPValue", StringUtils.FormatNumberWString( xpBonus ) )
        LabelSetText( "ScenarioSummaryWindowBonusRenownValue", StringUtils.FormatNumberWString( renownBonus ) )
    end
    
    WindowSetShowing( "ScenarioSummaryWindowBonusXPLabel", shouldShow )
    WindowSetShowing( "ScenarioSummaryWindowBonusXPValue", shouldShow )
    WindowSetShowing( "ScenarioSummaryWindowBonusRenownLabel", shouldShow )
    WindowSetShowing( "ScenarioSummaryWindowBonusRenownValue", shouldShow )
end

function ScenarioSummaryWindow.ToggleShowing()
    if ( ( GameData.Player.isInScenario or GameData.Player.isInSiege ) or WindowGetShowing("ScenarioSummaryWindow") ) then
        if ( ScenarioSummaryWindow.currentMode == ScenarioSummaryWindow.MODE_IN_PROGRESS ) then
            WindowUtils.ToggleShowing( "ScenarioSummaryWindow" )
        end
    end
end

function ScenarioSummaryWindow.OnShown()
    WindowUtils.OnShown()
    BroadcastEvent( SystemData.Events.SCENARIO_START_UPDATING_PLAYERS_STATS)
    UpdatePlayerData()
end

function ScenarioSummaryWindow.OnHidden()
    WindowUtils.OnHidden()
    BroadcastEvent( SystemData.Events.SCENARIO_STOP_UPDATING_PLAYERS_STATS )
end

function ScenarioSummaryWindow.OnScenarioBegin()
    ScenarioSummaryWindow.scenarioMaxDuration = GameData.ScenarioData.maxTimer
    
    ScenarioSummaryWindow.UpdateScenarioInfo()
    ScenarioSummaryWindow.UpdateBonusInfo(false)
    ScenarioSummaryWindow.HideVictorInfo()
    ScenarioSummaryWindow.ShowOrHideLeaveNowButton()
end

function ScenarioSummaryWindow.OnLoadingEnd()
    -- Because the CITY_SCENARIO_BEGIN event is not sent reliably, use LoadingEnd as the equivalent of OnScenarioBegin for city scenarios
    if ( GameData.Player.isInSiege )
    then
        ScenarioSummaryWindow.OnScenarioBegin()
    end
end

function ScenarioSummaryWindow.UpdateScenarioInfo()
    if ( GameData.Player.isInSiege )
    then
        local cityName = GetZoneName( GameData.Player.zone )
        local instanceIdData = GetCityInstanceId()
        LabelSetText( "ScenarioSummaryWindowScenarioName", GetStringFormat( StringTables.Default.TEXT_CITY_INSTANCE_LABEL, { cityName, instanceIdData.instanceId } ) )
        
        WindowSetShowing( "ScenarioSummaryWindowTimeLabel", false )
        WindowSetShowing( "ScenarioSummaryWindowClockImage", false )
    elseif ( GameData.Player.isInScenario )
    then
        LabelSetText( "ScenarioSummaryWindowScenarioName", GetScenarioName( GameData.ScenarioData.id  ) )
        
        WindowSetShowing( "ScenarioSummaryWindowTimeLabel", true )
        WindowSetShowing( "ScenarioSummaryWindowClockImage", true )
    end
end

function ScenarioSummaryWindow.OnUpdate()

    -- Update the scenario timer or leave now timer depending on current mode
    if ( not GameData.Player.isInSiege )
    then
        if (GameData.ScenarioData.mode == GameData.ScenarioMode.PRE_MODE) then
            local timeText = TimeUtils.FormatClock( GameData.ScenarioData.timeLeft )
            local text = GetStringFormat( StringTables.Default.LABEL_TIME_UNTIL_START, { timeText } )
            LabelSetText( "ScenarioSummaryWindowTimeLabel", text )
        elseif (GameData.ScenarioData.mode == GameData.ScenarioMode.RUNNING) then
            local timeText = TimeUtils.FormatClock( GameData.ScenarioData.timeLeft )
            local text = GetStringFormat( StringTables.Default.LABEL_TIME_REMAINING, { timeText } )
            LabelSetText( "ScenarioSummaryWindowTimeLabel", text )
        
            ScenarioSummaryWindow.lastTimeLeft = GameData.ScenarioData.timeLeft
        elseif (GameData.ScenarioData.mode == GameData.ScenarioMode.POST_MODE) then
            if (ScenarioSummaryWindow.currentMode == ScenarioSummaryWindow.MODE_POST_MODE) then
                LabelSetText( "ScenarioSummaryWindowLeaveNowTimer", TimeUtils.FormatClock( GameData.ScenarioData.timeLeft ) )
            end
        end
    end
end

function ScenarioSummaryWindow.ShowIfInPostMode()
    if ( ( GameData.ScenarioData.mode == GameData.ScenarioMode.POST_MODE ) and not GameData.Player.isInSiege ) then
        WindowSetShowing("ScenarioSummaryWindow", true)
        ScenarioSummaryWindow.SetDisplayMode(ScenarioSummaryWindow.MODE_POST_MODE)
    end
end

function ScenarioSummaryWindow.OnUpdateScenarioPoints()	

    local orderPoints = 0
    local destructionPoints = 0
    if ( GameData.Player.isInSiege )
    then
        orderPoints = StringUtils.FormatNumberWString( GameData.CityScenarioData.orderPoints )
        destructionPoints = StringUtils.FormatNumberWString( GameData.CityScenarioData.destructionPoints )
    else
        orderPoints = StringUtils.FormatNumberWString( GameData.ScenarioData.orderPoints )
        destructionPoints = StringUtils.FormatNumberWString( GameData.ScenarioData.destructionPoints )
    end
    
    LabelSetText( "ScenarioSummaryWindowOrderPoints", orderPoints )
    LabelSetText( "ScenarioSummaryWindowDestructionPoints", destructionPoints )
    
end

function ScenarioSummaryWindow.OnPlayerListUpdated()
    UpdatePlayerData()
end

function ScenarioSummaryWindow.OnPlayerListStatsUpdated()
    UpdatePlayerData()
end

-- Callback from the <List> that updates a single row.
function ScenarioSummaryWindow.UpdatePlayerIcon(rowFrame, memberData)

    if memberData.careerIcon ~= nil and memberData.careerIcon ~=0 then
        local texture, x, y = GetIconData(memberData.careerIcon)
        DynamicImageSetTexture(rowFrame.."CareerIcon", texture, x, y)
        WindowSetShowing(rowFrame.."CareerIcon", true)

        local ATIcon = memberData.archetype
        if ATIcon > 0 then
            WindowSetShowing(rowFrame.."Archetype",true)
            local texture2, x2, y2 = GetIconData(ScenarioSummaryWindow.ArchetypeIcons[ATIcon])
            DynamicImageSetTexture(rowFrame.."Archetype", texture2, x2, y2)    
        else
            WindowSetShowing(rowFrame.."Archetype",false)
        end
    else
        WindowSetShowing(rowFrame.."Archetype",false)
        WindowSetShowing(rowFrame.."CareerIcon", false)
    end
end

function ScenarioSummaryWindow.UpdatePlayerRow()

    if (ScenarioSummaryWindowPlayerList.PopulatorIndices ~= nil) then				
        for rowIndex, dataIndex in ipairs (ScenarioSummaryWindowPlayerList.PopulatorIndices) do
            local playerData = ScenarioSummaryWindow.playersData[ dataIndex ]
            local rowFrame = "ScenarioSummaryWindowPlayerListRow"..rowIndex
            ScenarioSummaryWindow.UpdatePlayerIcon(rowFrame, playerData)
            local row_mod = math.mod (rowIndex, 2)
            local text_color = DefaultColor.WHITE			
            local labelName = "ScenarioSummaryWindowPlayerListRow"..rowIndex.."Name"
            local row_color
            if( playerData.realm == GameData.Realm.ORDER ) then
                row_color = {r=12, g=47, b=158}
            else
                row_color = {r=158, g=12, b=13}
            end
            
            for columnIndex, sortData in ipairs (ScenarioSummaryWindow.sortData) do
                local name = sortData.label
                WindowSetTintColor("ScenarioSummaryWindowPlayerListRow"..rowIndex.."Background"..name, row_color.r, row_color.g, row_color.b)
                WindowSetAlpha("ScenarioSummaryWindowPlayerListRow"..rowIndex.."Background"..name, 0.2)
                LabelSetTextColor("ScenarioSummaryWindowPlayerListRow"..rowIndex..name, text_color.r,text_color.g, text_color.b)
            end
            
            SetSelectedColumnColor( rowIndex, "ScenarioSummaryWindowPlayerListRow"..rowIndex, ScenarioSummaryWindow.display.type )
            
            if (dataIndex == ScenarioSummaryWindow.SelectedPlayerDataIndex) then
                ScenarioSummaryWindow.HighlightPlayerInList( rowIndex, true, false)
            else				
                ScenarioSummaryWindow.HighlightPlayerInList( rowIndex, false, false)
            end      
        end
    end  
    
end

-- Sets the color for the selected column
function SetSelectedColumnColor( rowIndex, rowName, sortType )

    if (ScenarioSummaryWindow.display.type == ScenarioSummaryWindow.SORT_TYPE_NAME) then
        return
    end

    local row_mod = math.mod (rowIndex, 2)
    local windowName = "Background"..ScenarioSummaryWindow.sortData[ sortType ].label
    
    local color = GameDefs.RowColorHighlighted
    if (row_mod == 0) then
        color = DataUtils.GetAlternatingRowColor(0)
    end
    
    WindowSetTintColor(rowName..windowName, color.r, color.g, color.b)
    WindowSetAlpha(rowName..windowName, color.a)
    
end

-- Callback for the filter combo box
function ScenarioSummaryWindow.OnFilterSelChanged()

    local filterType = ComboBoxGetSelectedMenuItem("ScenarioSummaryWindowPlayerListHeaderFilterCombo" )
    ScenarioSummaryWindow.display.filter = filterType
    UpdatePlayerList()
end

-- Button Callback for the Header Sort Buttons
function ScenarioSummaryWindow.OnSortPlayerList()
    
    local type = WindowGetId( SystemData.ActiveWindow.name )
    
    -- If we are already using this sort type, toggle the order.
    if( type == ScenarioSummaryWindow.display.type ) then
        if( ScenarioSummaryWindow.display.order == ScenarioSummaryWindow.SORT_ORDER_UP ) then
            ScenarioSummaryWindow.display.order = ScenarioSummaryWindow.SORT_ORDER_DOWN
        else
            ScenarioSummaryWindow.display.order = ScenarioSummaryWindow.SORT_ORDER_UP
        end
        
    -- Otherwise change the type and use the up order.	
    else
        ScenarioSummaryWindow.display.type = type
        ScenarioSummaryWindow.display.order = ScenarioSummaryWindow.SORT_ORDER_DOWN
    end

    UpdatePlayerList()
    
    if( ScenarioSummaryWindowPlayerList.PopulatorIndices ) then
        for rowIndex, dataIndex in ipairs (ScenarioSummaryWindowPlayerList.PopulatorIndices) do    
            SetSelectedColumnColor( rowIndex, "ScenarioSummaryWindowPlayerListRow"..rowIndex, ScenarioSummaryWindow.display.type )
        end   	
    end
    
    ScenarioSummaryWindow.UpdateSortButtons()
    
end

-- Displays the clicked sort button as pressed down and positions an arrow above it
function ScenarioSummaryWindow.UpdateSortButtons()

    local type = ScenarioSummaryWindow.display.type
    local order = ScenarioSummaryWindow.display.order

    for index = 2, ScenarioSummaryWindow.NUM_SORT_TYPES do
        local window = "ScenarioSummaryWindowPlayerListHeader"..ScenarioSummaryWindow.sortData[index].label
        ButtonSetPressedFlag( window, index == ScenarioSummaryWindow.display.type )
    end
    
    -- Only move the arrow around for sorting on everything but the name
    if (type > ScenarioSummaryWindow.SORT_TYPE_NAME ) then
        WindowSetShowing( "ScenarioSummaryWindowPlayerListHeaderUpArrow", order == ScenarioSummaryWindow.SORT_ORDER_UP )
        WindowSetShowing( "ScenarioSummaryWindowPlayerListHeaderDownArrow", order == ScenarioSummaryWindow.SORT_ORDER_DOWN )
                
        local window = "ScenarioSummaryWindowPlayerListHeader"..ScenarioSummaryWindow.sortData[type].label
    
        if( order == ScenarioSummaryWindow.SORT_ORDER_UP ) then		
            WindowClearAnchors( "ScenarioSummaryWindowPlayerListHeaderUpArrow" )
            WindowAddAnchor("ScenarioSummaryWindowPlayerListHeaderUpArrow", "top", window, "top", 0, -28 )
            
        else
            WindowClearAnchors( "ScenarioSummaryWindowPlayerListHeaderDownArrow" )
            WindowAddAnchor("ScenarioSummaryWindowPlayerListHeaderDownArrow", "top", window, "top", 0, -28 )
            
        end
    else
        WindowSetShowing( "ScenarioSummaryWindowPlayerListHeaderUpArrow", false )
        WindowSetShowing( "ScenarioSummaryWindowPlayerListHeaderDownArrow", false )
        
    end

end

-- Displays a tooltip with information on the type of sort being hovered over
function ScenarioSummaryWindow.OnMouseOverSortButton()

    local windowName	= SystemData.ActiveWindow.name
    local windowIndex	= WindowGetId (windowName)
    
    local titleText = ScenarioSummaryWindow.sortData[windowIndex].title
    local descText = ScenarioSummaryWindow.sortData[windowIndex].desc
    
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
function ScenarioSummaryWindow.OnLButtonUpPlayerRow()

    local row = WindowGetId( SystemData.ActiveWindow.name )
    ScenarioSummaryWindow.HighlightPlayerInList(row, true, true)
    
end

-- Handles the Right Button click on a player row
function ScenarioSummaryWindow.OnRButtonUpPlayerRow()

    local row = WindowGetId( SystemData.ActiveWindow.name )
    ScenarioSummaryWindow.HighlightPlayerInList( row, false, false )
    ScenarioSummaryWindow.SelectedPlayerDataIndex = 0
    
end

-- Highlights the specified player data in its list
--		TODO: Eventually we will need to isolate player by name *and* server! (gnelson 4/17/07)
function ScenarioSummaryWindow.HighlightPlayerInList( rowIndex, bVisible, bFromLButtonEvent )
 
    local dataIndex = ScenarioSummaryWindowPlayerList.PopulatorIndices[rowIndex]
    local playerData = ScenarioSummaryWindow.playersData[ dataIndex ]
 
    -- Get the player's indexed data from the GameData list and update the lower fields
    if (bFromLButtonEvent) then
        ScenarioSummaryWindow.SelectedPlayerDataIndex = dataIndex
    end
    
    -- Clear selected player info from both lists
    if (bFromLButtonEvent) then
        ScenarioSummaryWindow.UpdatePlayerRow ()
    end
        
    -- Determine the text c olor
    local color
    if (bVisible) then	
        color = { r=255, g=204, b=102 }
    else
        color = DefaultColor.WHITE
    end
    
    for columnIndex, sortData in ipairs (ScenarioSummaryWindow.sortData) do
        local name = sortData.label	
        LabelSetTextColor("ScenarioSummaryWindowPlayerListRow"..rowIndex..name, color.r, color.g, color.b);	
    end
    
    -- Show the border box around the selected player
    WindowSetShowing("ScenarioSummaryWindowPlayerListRow"..rowIndex.."SelectionBorder", bVisible)
    
end

function ScenarioSummaryWindow.ShowOrHideLeaveNowButton()
    local shouldShow = GameData.ScenarioData.mode == GameData.ScenarioMode.POST_MODE and ScenarioSummaryWindow.currentMode == ScenarioSummaryWindow.MODE_POST_MODE and not GameData.Player.isInSiege
    
    if (shouldShow) then
        LabelSetText( "ScenarioSummaryWindowLeaveNowTimer", TimeUtils.FormatClock( GameData.ScenarioData.timeLeft ) )
    end
    
    WindowSetShowing( "ScenarioSummaryWindowLeaveNowButton", shouldShow )
    WindowSetShowing( "ScenarioSummaryWindowLeaveNowTimer", shouldShow )
end

function ScenarioSummaryWindow.OnLeaveNowClicked()
    BroadcastEvent( SystemData.Events.SCENARIO_FINAL_SCOREBOARD_CLOSED )
end

function ScenarioSummaryWindow.OnVertScrollLButtonUp()
    -- dummy LButtonUp handler for the scrollbars to stop them from
    -- failing to handle for lack of a LUA script event handler
end

function ScenarioSummaryWindow.HideVictorInfo()
    -- Set listbox to full height
    width, _ = WindowGetDimensions( "ScenarioSummaryWindowPlayerList" )
    WindowSetDimensions( "ScenarioSummaryWindowPlayerList", width, 650 )
    ListBoxSetVisibleRowCount( "ScenarioSummaryWindowPlayerList", 23 )
    
    -- Hide victor info
    WindowSetShowing( "ScenarioSummaryWindowVictorBanner", false )
    WindowSetShowing( "ScenarioSummaryWindowVictorText", false )
end

function ScenarioSummaryWindow.ShowVictorInfo(victorRealm)
    -- Set listbox to partial height, so we have room to show victor info
    width, _ = WindowGetDimensions( "ScenarioSummaryWindowPlayerList" )
    WindowSetDimensions( "ScenarioSummaryWindowPlayerList", width, 550 )
    ListBoxSetVisibleRowCount( "ScenarioSummaryWindowPlayerList", 19 )
    
    -- Show victor info
    if (victorRealm ~= GameData.Realm.NONE) then
        -- There is a winner
        DefaultColor.LabelSetTextColor( "ScenarioSummaryWindowVictorText", DataUtils.GetRealmColor( victorRealm ) )
        LabelSetText( "ScenarioSummaryWindowVictorText", GetStringFormat( StringTables.Default.TEXT_SCENARIO_WIN, { GetRealmName(victorRealm) } ) )
        WindowSetShowing( "ScenarioSummaryWindowVictorText", true )
        
        if (victorRealm == GameData.Realm.ORDER) then
            DynamicImageSetTexture( "ScenarioSummaryWindowVictorBanner", "scenario_widgets", 112, 149 )
        else
            DynamicImageSetTexture( "ScenarioSummaryWindowVictorBanner", "scenario_widgets", 185, 149 )
        end
        WindowSetShowing( "ScenarioSummaryWindowVictorBanner", true )
    else
        -- It's a tie
        DefaultColor.LabelSetTextColor( "ScenarioSummaryWindowVictorText", DataUtils.GetRealmColor( GameData.Realm.NONE ) )
        LabelSetText( "ScenarioSummaryWindowVictorText", GetString( StringTables.Default.TEXT_SCENARIO_TIE ) )
        WindowSetShowing( "ScenarioSummaryWindowVictorText", true )
        
        WindowSetShowing( "ScenarioSummaryWindowVictorBanner", false )
    end
end

-- Hides the background and window frames to show the SummaryScreen overtop the loading screen.
function ScenarioSummaryWindow.SetDisplayMode( mode ) 

    ScenarioSummaryWindow.currentMode = mode

    local isFinished = ScenarioSummaryWindow.currentMode ~= ScenarioSummaryWindow.MODE_IN_PROGRESS
    local inLoadingMode = ScenarioSummaryWindow.currentMode == ScenarioSummaryWindow.MODE_LOADING_SCREEN
    
    -- Close button is only visible if scenario is running
    WindowSetShowing( "ScenarioSummaryWindowClose", not isFinished )
    
    -- Alpha the backgrounds
    if( inLoadingMode ) then
        WindowSetAlpha( "ScenarioSummaryWindowScoreBackground", 0.5 )
        WindowSetAlpha( "ScenarioSummaryWindowPlayerListBackground", 0.75 )                
    else
        WindowSetAlpha( "ScenarioSummaryWindowScoreBackground", 1.0 )
        WindowSetAlpha( "ScenarioSummaryWindowPlayerListBackground", 1.0 )        
    end
    
    
    -- Show the 'Time Elapsed' text when scenario ends
    if( isFinished ) then
        local timeText = TimeUtils.FormatClock( ScenarioSummaryWindow.scenarioMaxDuration - ScenarioSummaryWindow.lastTimeLeft )
        local text = GetStringFormat( StringTables.Default.LABEL_TIME_ELAPSED, { timeText } )
        LabelSetText( "ScenarioSummaryWindowTimeLabel", text )
    end
    
    -- When scenario ends, show finished scenario elements (bonuses, victor, leave now)
    if( isFinished ) then
        ScenarioSummaryWindow.UpdateBonusInfo(true)
        
        if (GameData.ScenarioData.orderPoints > GameData.ScenarioData.destructionPoints) then
            ScenarioSummaryWindow.ShowVictorInfo(GameData.Realm.ORDER)
        elseif (GameData.ScenarioData.orderPoints < GameData.ScenarioData.destructionPoints) then
            ScenarioSummaryWindow.ShowVictorInfo(GameData.Realm.DESTRUCTION)
        else
            ScenarioSummaryWindow.ShowVictorInfo(GameData.Realm.NONE)
        end
    end
    
    ScenarioSummaryWindow.ShowOrHideLeaveNowButton()
    
    if( isFinished ) then
        -- Remove the Window from the open list so it can't be closed with escape
        WindowUtils.RemoveFromOpenList( "ScenarioSummaryWindow" )
    else
        if WindowGetShowing("ScenarioSummaryWindow")
        then
            -- Add the Window to the OpenList so it can be closed with escape
            WindowUtils.AddToOpenList( "ScenarioSummaryWindow", nil, nil )
        end
    end
    
    -- Move the window to the overlay layer when in loading mode
    if( inLoadingMode ) then
        WindowSetLayer("ScenarioSummaryWindow", Window.Layers.OVERLAY )
        WindowSetMovable("ScenarioSummaryWindow", false )
        WindowClearAnchors("ScenarioSummaryWindow" )        
        WindowAddAnchor("ScenarioSummaryWindow", "top", "Root", "top", 0, 100 )        
    else
        WindowSetLayer("ScenarioSummaryWindow", Window.Layers.SECONDARY )
        WindowSetMovable("ScenarioSummaryWindow", true )
    end 

end

function ScenarioSummaryWindow.GetExtendedStat(playerName, statId)

    if RoR_ScenarioExtendedStats == nil then return L"0" end
    if RoR_ScenarioExtendedStats.playersData == nil then return L"0" end
    if RoR_ScenarioExtendedStats.playersData[playerName] == nil then return L"0" end
    if RoR_ScenarioExtendedStats.playersData[playerName][statId] == nil then return L"0" end

    return RoR_ScenarioExtendedStats.playersData[playerName][statId]

end

-- Displays a tooltip with information on the type of sort being hovered over
function ScenarioSummaryWindow.OnMouseOverPlayerRow()
    if RoR_ScenarioExtendedStats == nil then return end
    -- Parse values if we have no cached version
    if RoR_ScenarioExtendedStats.playersData == nil then RoR_ScenarioExtendedStats.UpdatePlayerData() end

    local windowName	= SystemData.ActiveWindow.name
    local rowIndex	    = WindowGetId (windowName)
    local playerIndex   = ListBoxGetDataIndex( "ScenarioSummaryWindowPlayerList", rowIndex )
    local categoryName  = windowName:gsub("ScenarioSummaryWindowPlayerListRow%d+", "")
    local playerName    = wstring.sub(ScenarioSummaryWindow.playersData[playerIndex].name, 1, -3)

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    if categoryName == "GroupKills" then
        Tooltips.SetTooltipText (1, 1, GetString(StringTables.Default.LABEL_KILLS))
        Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
        Tooltips.SetTooltipText (2, 1, GetString(StringTables.Default.LABEL_SOLO_KILLS)..L": "..ScenarioSummaryWindow.GetExtendedStat(playerName, 1))
    elseif categoryName == "Deaths" then
        Tooltips.SetTooltipText (1, 1, GetString(StringTables.Default.LABEL_DEATHS))
        Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
        Tooltips.SetTooltipText (2, 1, GetString(StringTables.Default.LABEL_DAMAGE_RECEIVED)..L": "..ScenarioSummaryWindow.GetExtendedStat(playerName, 7))
        Tooltips.SetTooltipText (3, 1, GetString(StringTables.Default.LABEL_HEALING_RECEIVED)..L": "..ScenarioSummaryWindow.GetExtendedStat(playerName, 9))
        Tooltips.SetTooltipText (4, 1, GetString(StringTables.Default.LABEL_PROTECTION_RECEIVED)..L": "..ScenarioSummaryWindow.GetExtendedStat(playerName, 10))
    elseif categoryName == "HealingDealt" then
        Tooltips.SetTooltipText (1, 1, GetString(StringTables.Default.LABEL_HEALING_DEALT_SHORT))
        Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
        Tooltips.SetTooltipText (2, 1, GetString(StringTables.Default.LABEL_HEALING_SELF)..L": "..ScenarioSummaryWindow.GetExtendedStat(playerName, 3))
        Tooltips.SetTooltipText (3, 1, GetString(StringTables.Default.LABEL_HEALING_OTHERS)..L": "..ScenarioSummaryWindow.GetExtendedStat(playerName, 4))
        Tooltips.SetTooltipText (4, 1, GetString(StringTables.Default.LABEL_RESURRECTIONS)..L": "..ScenarioSummaryWindow.GetExtendedStat(playerName, 8))
    elseif categoryName == "Protection" then
        Tooltips.SetTooltipText (1, 1, GetString(StringTables.Default.LABEL_PROTECTION_SHORT))
        Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
        Tooltips.SetTooltipText (2, 1, GetString(StringTables.Default.LABEL_PROTECTION_SELF)..L": "..ScenarioSummaryWindow.GetExtendedStat(playerName, 5))
        Tooltips.SetTooltipText (3, 1, GetString(StringTables.Default.LABEL_PROTECTION_OTHERS)..L": "..ScenarioSummaryWindow.GetExtendedStat(playerName, 6))
    end
    Tooltips.Finalize ()
    
    local anchor = { Point="top", RelativeTo=windowName, RelativePoint="bottom", XOffset=0, YOffset=-10 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)

end
