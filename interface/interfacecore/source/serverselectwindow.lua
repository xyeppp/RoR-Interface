----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

ServerSelectWindow =
{
    SORT_ASCENDING   = true,
    SORT_DESCENDING  = false,
    currentSort      = 2,
    gotServerList    = false,
}

ServerSelectWindow.BOTH_REALM_OPTIONS = 1
ServerSelectWindow.ORDER_ONLY = 2
ServerSelectWindow.DESTRUCTION_ONLY = 3

ServerSelectWindow.serverList = {}
ServerSelectWindow.selectedServer = 1
ServerSelectWindow.preselectedServer = 1
ServerSelectWindow.preselectedServerRealm = ServerSelectWindow.ORDER_ONLY
ServerSelectWindow.popBonusServer = nil
ServerSelectWindow.trialPlayerServer = nil
ServerSelectWindow.showLegacyServers = false

ServerSelectWindow.autoLoggedIn = false       -- used to determine if we need to display the welcome text during character creation

ServerSelectWindow.trialPlayer = false
ServerSelectWindow.buddiedPlayer = false
ServerSelectWindow.hasCharacters = false    -- does the player have any characters on any server?

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
local PopulationDensityLow = 0
local PopulationDensityMed = 1
local PopulationDensityHigh = 2
local PopulationDensityFull = 3        -- this is a high density server that also has a queue
local ImbalanceLookup =
{
    [PopulationDensityLow] =
    {
        [PopulationDensityLow] = 7,
        [PopulationDensityMed] = 8,
        [PopulationDensityHigh] = 9,
        [PopulationDensityFull] = 10,
    },
    [PopulationDensityMed] =
    {
        [PopulationDensityLow] = 8,
        [PopulationDensityMed] = 4,
        [PopulationDensityHigh] = 5,
        [PopulationDensityFull] = 6,
    },
    [PopulationDensityHigh] =
    {
        [PopulationDensityLow] = 9,
        [PopulationDensityMed] = 5,
        [PopulationDensityHigh] = 2,
        [PopulationDensityFull] = 3,
    },
    [PopulationDensityFull] =
    {
        [PopulationDensityLow] = 10,
        [PopulationDensityMed] = 6,
        [PopulationDensityHigh] = 3,
        [PopulationDensityFull] = 1,
    },
}

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------
local function GetAdjustedPopulationDensity( populationDensity, populationQueue )
    -- A high density server with a queue is considered "full density"
    if ( ( populationDensity >= PopulationDensityHigh ) and ( populationQueue > 0 ) )
    then
        return PopulationDensityFull
    -- Otherwise, just sanity-check the density we were given and then return it
    elseif ( populationDensity >= PopulationDensityHigh )
    then
        return PopulationDensityHigh
    elseif ( populationDensity <= PopulationDensityLow )
    then
        return PopulationDensityLow
    else
        return populationDensity
    end
end

local function GetRuleSetStringIndex( serverData )
    if ( serverData.rulesetCore )
    then
        return StringTables.Pregame.LABEL_RULESET_CORE
    elseif ( serverData.rulesetRolePlaying and serverData.rulesetOpenRvR )
    then
        return StringTables.Pregame.LABEL_RULESET_OPEN_RVR_RP
    elseif ( serverData.rulesetOpenRvR )
    then
        return StringTables.Pregame.LABEL_RULESET_OPEN_RVR
    elseif ( serverData.rulesetRolePlaying )
    then
        return StringTables.Pregame.LABEL_RULESET_ROLE_PLAY
    else
        return nil
    end
end

----------------------------------------------------------------
-- Sorting Functions
----------------------------------------------------------------
local function AlphabeticalSort(a, b)
    return (WStringsCompare(a, b) < 0)
end

local function NumericalSort(a, b)
    return a > b        -- sorts the higher above the lower number
end

local function ServerSort(a, b)
    return AlphabeticalSort(a.name, b.name)
end

local function RuleSetSort(a, b)
    local aRuleSetStringIndex = GetRuleSetStringIndex( a )
    local bRuleSetStringIndex = GetRuleSetStringIndex( b )

    -- if both servers have the same ruleset then we need to use the next step in the sorting heirarchey
    if (aRuleSetStringIndex == bRuleSetStringIndex)
    then
        return ServerSort(a, b)
    else
        local aRuleSetString = GetPregameString( aRuleSetStringIndex )
        local bRuleSetString = GetPregameString( bRuleSetStringIndex )
        return AlphabeticalSort( aRuleSetString, bRuleSetString )
    end
end

local function LocSort(a, b)
    -- if the location distance is the same we need to use the next step in the sort heirarchey,
    -- the rule set
    if (a.localeDistance == b.localeDistance)
    then
        return RuleSetSort(a, b)
    else
        -- need to sort the lower number first so need to swap these here
        return NumericalSort(b.localeDistance, a.localeDistance)
    end
end

local function CharsSort(a, b)
    -- if the character count is the same we will go to the next step in the sorting heirarchey, 
    -- the server location in relation to the player
    if (a.characterCount == b.characterCount)
    then
        return LocSort(a, b)
    else
        return NumericalSort(a.characterCount, b.characterCount)
    end
end

local function LanguageSort(a, b)
    -- if the language is the same we will go to the next step in the sorting heirarchey, 
    if (a.language == b.language)
    then
        return ServerSort(a, b)
    else
        local aLanguageString = GetStringFromTable("ServerLanguage", a.language)
        local bLanguageString = GetStringFromTable("ServerLanguage", b.language)
        return AlphabeticalSort(aLanguageString, bLanguageString)
    end
end

local function OrderBonusSort(a, b)
    -- if the servers have the same order population density we need to use the next sort in the heirarchey,
    -- the server name
    if (a.orderBonus == b.orderBonus)
    then
        return ServerSort(a, b)
    else
        return NumericalSort(a.orderBonus, b.orderBonus)
    end
end

local function DestructionBonusSort(a, b)
    -- if the servers have the same destruction population density we need to use the next sort in the heirarchey,
    -- the server name
    if (a.destructionBonus == b.destructionBonus)
    then
        return ServerSort(a, b)
    else
        return NumericalSort(a.destructionBonus, b.destructionBonus)
    end
end

ServerSelectWindow.sortButtonData =
{
    { label = StringTables.Pregame.LABEL_BUTTON_SERVER_SELECT_NAME,                      direction = ServerSelectWindow.SORT_ASCENDING,      sortFunc = ServerSort },
    { label = StringTables.Pregame.LABEL_BUTTON_SERVER_SELECT_CHARACTER_COUNT,           direction = ServerSelectWindow.SORT_ASCENDING,      sortFunc = CharsSort },
    { label = StringTables.Pregame.LABEL_BUTTON_SERVER_SELECT_TYPE,                      direction = ServerSelectWindow.SORT_ASCENDING,      sortFunc = RuleSetSort },
    { label = StringTables.Pregame.LABEL_BUTTON_SERVER_SELECT_LOCATION,                  direction = ServerSelectWindow.SORT_ASCENDING,      sortFunc = LocSort },
    { label = StringTables.Pregame.LABEL_BUTTON_SERVER_SELECT_LANGUAGE,                  direction = ServerSelectWindow.SORT_ASCENDING,      sortFunc = LanguageSort },
    { label = "RealmBonus-Order",                                                        direction = ServerSelectWindow.SORT_ASCENDING,      sortFunc = OrderBonusSort },
    { label = "RealmBonus-Destruction",                                                  direction = ServerSelectWindow.SORT_ASCENDING,      sortFunc = DestructionBonusSort },
}

----------------------------------------------------------------
-- Functions
----------------------------------------------------------------

-- OnInitialize Handler
function ServerSelectWindow.Initialize()
    -- initialize the auto logged in boolean
    ServerSelectWindow.autoLoggedIn = false

    WindowRegisterEventHandler( "ServerSelectWindow", SystemData.Events.PLAYER_DATA_RESPONSE, "ServerSelectWindow.RefreshPlayerData")
    WindowRegisterEventHandler( "ServerSelectWindow", SystemData.Events.SERVER_LIST_RESPONSE, "ServerSelectWindow.ServerListResponse")
    WindowRegisterEventHandler( "ServerSelectWindow", SystemData.Events.INTERFACE_RELOADED,   "ServerSelectWindow.RefreshList")

    LabelSetText("ServerSelectWindowLoadingLabel", GetPregameString( StringTables.Pregame.LABEL_LOADING_SERVER_LIST ) )

    ButtonSetCheckButtonFlag( "ServerSelectWindowShowLegacy", true )
    ButtonSetText( "ServerSelectWindowShowLegacy", GetPregameString( StringTables.Pregame.LABEL_MORE ) )

    ServerSelectWindow.gotServerList = false
    ServerSelectWindow.InitializeButtons()
    ServerSelectWindow.RefreshPlayerData()
    ServerSelectWindow.RefreshList()
    ServerSelectWindow.VerifyServer()
    ServerSelectWindow.ManageProgressWindow()

    -- if the player is on a trial we want to push them to the trial user servers
    if ( ServerSelectWindow.ShouldSendToTrialUserServer() )
    then
        -- sense we are going to a trial server we'll hide the preselected window
        WindowSetShowing("ServerSelectWindowPreSelectedWindow", false)
        ServerSelectWindow.SelectTrialUserServer()
    -- if there are servers that have a population bonus we always want to offer them to the user
    elseif ( ServerSelectWindow.ShouldSendToPopBonusServer() )
    then
        -- sense we are showing the population bonus server we will hide the pre-selected window
        WindowSetShowing("ServerSelectWindowPreSelectedWindow", false)
        ServerSelectWindow.SelectPopBonusServer()
    elseif ( ServerSelectWindow.ShouldShowPreSelectWindow() )
    then
        ServerSelectWindow.InitPreSelect()
    else
        WindowSetShowing("ServerSelectWindowPreSelectedWindow", false)
    end
    
    -- If the select list is showing, we're not connected to a server, so hide the server name label
    if ( DoesWindowExist( "LobbyBackground" ) )
    then
        LobbyBackground.HideServerName()
    end
end

function ServerSelectWindow.RefreshPlayerData()
    ServerSelectWindow.trialPlayer, ServerSelectWindow.buddiedPlayer = GetAccountData()
end

function ServerSelectWindow.RefreshList()
    -- Just in case we are trying to auto-log someone into a server that is down or goes down we want
    -- the server list to be shown so they don't have to shut down and restart the game
    if ( not WindowGetShowing( "ServerSelectWindow" ) )
    then
        WindowSetShowing( "ServerSelectWindow", true )
    end
    
    local tempList = GetServerList()
    ServerSelectWindow.serverList = {}

    for _, data in ipairs(tempList)
    do
        -- show the server if it is not a legacy server and not a retired server
        -- or if it is not retired, and is a legacy server, and we are set to showLegacyServers
        -- or if the server is legacy or retired, but we have a character on it
        if( ( not data.legacy and not data.retired) or 
            ( not data.retired and data.legacy and ServerSelectWindow.showLegacyServers ) or 
            ( data.characterCount ~= 0 )  )
        then
            table.insert(ServerSelectWindow.serverList, data)
        end
    end

    if ( ServerSelectWindow.gotServerList and (#ServerSelectWindow.serverList == 0) )
    then
        LabelSetText("ServerSelectWindowLoadingLabel", GetPregameString( StringTables.Pregame.LABEL_EMPTY_SERVER_LIST ) )
        WindowSetShowing("ServerSelectWindowLoadingLabel", true)
    else
        WindowSetShowing("ServerSelectWindowLoadingLabel", false)
    end
    
    table.sort(ServerSelectWindow.serverList, ServerSelectWindow.FlexibleSort)

    local imbalanceServers = {}
    local popBonusServers = {}
    local trialUserServers = {}
    local highestImbalance = 0

    local displayOrder = {}
    local trialUserIndex = 1
    ServerSelectWindow.hasCharacters = false
    for index, data in ipairs(ServerSelectWindow.serverList)
    do
        local trialServerInserted = false
        
        if (data.characterCount > 0)
        then
            ServerSelectWindow.hasCharacters = true
        end
        
        if (data.sameLanguage and data.online and data.rulesetCore)
        then
            local orderDensity = GetAdjustedPopulationDensity( data.orderPopulationDensity, data.orderPopulationQueue )
            local destructionDensity = GetAdjustedPopulationDensity( data.destructionPopulationDensity, data.destructionPopulationQueue )
            local imbalance = ImbalanceLookup[orderDensity][destructionDensity]
            if ( imbalance > highestImbalance )
            then
                -- This server has a higher imbalance than any server we've found so far. Throw away all of those servers and start over with this one.
                highestImbalance = imbalance
                imbalanceServers = { index }
            elseif ( imbalance == highestImbalance )
            then
                -- This server has equal imbalance to other servers we've found so far. Add this to the existing list.
                table.insert( imbalanceServers, index )
            end
        end
        
        -- if we are supposed to redirect players to this server and the server is "local" add it to the list
        -- adding check so that we only redirect you to a server with the same language as you
        -- only add the server if it's online
        if (data.redirect and (data.localeDistance == 0) and data.sameLanguage and data.online)
        then
            table.insert(popBonusServers, index)
        end
        
        -- this is a list for servers that the trial users are sent to
        -- this is potentially a duplicate list to the pop bonus server list but I want to be able to easily seperate them
        if (data.redirect and data.trialServer and (data.localeDistance == 0) and data.sameLanguage)
        then
            table.insert(trialUserServers, index)

            -- If the player is a trial player but not a buddied player insert the
            -- server to the top of the list
            if( ServerSelectWindow.trialPlayer and not ServerSelectWindow.buddiedPlayer )
            then
                table.insert(displayOrder, trialUserIndex, index)
                trialUserIndex = trialUserIndex + 1
                trialServerInserted = true
            end
        end
        
        -- Insert the server index if the player is not a trial player or they are a buddied trial player
        if( not trialServerInserted )
        then
            table.insert(displayOrder, index)
        end
    end
    
    local function GetRandomValueFromArray( baseArray )
        if ( next(baseArray) ~= nil )
        then
            local randIndex = math.random( 1, #baseArray )
            return baseArray[randIndex]
        else
            return nil
        end
    end
    
    ServerSelectWindow.preselectedServer = GetRandomValueFromArray( imbalanceServers )
    ServerSelectWindow.popBonusServer = GetRandomValueFromArray( popBonusServers )
    ServerSelectWindow.trialPlayerServer = GetRandomValueFromArray( trialUserServers )
    
    ListBoxSetDisplayOrder("ServerSelectWindowList", displayOrder)
end

function ServerSelectWindow.ServerListResponse()
    ServerSelectWindow.gotServerList = true
    ServerSelectWindow.RefreshList()

    -- no reason for these buttons to be showing if we are still getting updates.
    if (DoesWindowExist("LoginProgressWindow")) then
        LoginProgressWindow.HideErrorButtons()
    end
end

function ServerSelectWindow.InitializeButtons()
    ButtonSetText( "ServerSelectWindowSelectButton", GetPregameString( StringTables.Pregame.LABEL_BUTTON_PRELOGIN_SERVER_SELECT ) )

    for index, data in ipairs(ServerSelectWindow.sortButtonData)
    do
        local buttonName = "ServerSelectWindowSortButton"..index
        
        -- If the label is a string, it is an icon. If it is a number, it is the string table index of the label.
        if ( type( data.label ) == "string" )
        then
            WindowSetShowing( buttonName.."IconBase", true )
            DynamicImageSetTextureSlice( buttonName.."IconBase", data.label )
        else
            WindowSetShowing( buttonName.."IconBase", false )
            ButtonSetText( buttonName, GetPregameString( data.label ) )
        end
        
        local isEnabled = (ServerSelectWindow.currentSort == index)
        local isUp      = (data.direction == ServerSelectWindow.SORT_DESCENDING)
        WindowSetShowing( buttonName.."UpArrow",   isEnabled and isUp )
        WindowSetShowing( buttonName.."DownArrow", isEnabled and not isUp )
    end
end

function ServerSelectWindow.PopulateList()

    -- Post-process any conditional formatting
    for row, data in ipairs(ServerSelectWindowList.PopulatorIndices)
    do
        local serverData = ServerSelectWindow.serverList[data]
        local rowFrame   = "ServerSelectWindowListRow"..row

        local isSelectedRow = (ServerSelectWindow.selectedServer == data)

        LabelSetText(rowFrame.."Name",           serverData.name)
        
        -- If the player has characters of only one realm, label the number characters with that realm. Otherwise just show the number of characters.
        if ( serverData.orderChars and not serverData.destructionChars )
        then
            local charsLabel = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_SERVER_SELECT_NUMBER_OF_CHARS, { towstring(serverData.characterCount), GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_NUMBER_OF_CHARS_ORDER ) } )
            LabelSetText(rowFrame.."CharacterCount", charsLabel)
        elseif ( serverData.destructionChars and not serverData.orderChars )
        then
            local charsLabel = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_SERVER_SELECT_NUMBER_OF_CHARS, { towstring(serverData.characterCount), GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_NUMBER_OF_CHARS_DESTRUCTION ) } )
            LabelSetText(rowFrame.."CharacterCount", charsLabel)
        else
            LabelSetText(rowFrame.."CharacterCount", towstring(serverData.characterCount))
        end

        LabelSetText(rowFrame.."Type",           GetPregameString( GetRuleSetStringIndex( serverData ) ) )
        LabelSetText(rowFrame.."Location",       GetStringFromTable( "ServerLocation", StringTables.ServerLocation[serverData.region]) )
        LabelSetText(rowFrame.."Language",       GetStringFromTable( "ServerLanguage", serverData.language) )

        WindowSetShowing(rowFrame.."OrderIconBase", (serverData.orderBonus ~= 0))
        WindowSetShowing(rowFrame.."DestructionIconBase", (serverData.destructionBonus ~= 0))

        local isOnline = serverData.online

        local serverDisallowTrialPlayer = ServerSelectWindow.trialPlayer and
                                          not ServerSelectWindow.buddiedPlayer and
                                          not serverData.trialServer and
                                          serverData.characterCount == 0
                                               
        -- if the player is a trial player, not a buddied player, and this is not a trial server, and the account has no characters on it then
        -- we will need to grey out all the text
        if ( serverDisallowTrialPlayer )
        then
            DefaultColor.LabelSetTextColor(rowFrame.."Name", DefaultColor.MEDIUM_GRAY)
            DefaultColor.LabelSetTextColor(rowFrame.."CharacterCount", DefaultColor.MEDIUM_GRAY)
            DefaultColor.LabelSetTextColor(rowFrame.."Type", DefaultColor.MEDIUM_GRAY)
            DefaultColor.LabelSetTextColor(rowFrame.."Location", DefaultColor.MEDIUM_GRAY)
        else
            if ( isOnline )
            then
                DefaultColor.LabelSetTextColor(rowFrame.."Name", DefaultColor.WHITE)
            else
                DefaultColor.LabelSetTextColor(rowFrame.."Name", DefaultColor.MEDIUM_GRAY)
            end
            DefaultColor.LabelSetTextColor(rowFrame.."CharacterCount", DefaultColor.WHITE)
            DefaultColor.LabelSetTextColor(rowFrame.."Type", DefaultColor.WHITE)
            DefaultColor.LabelSetTextColor(rowFrame.."Location", DefaultColor.WHITE)
        end

        ButtonSetStayDownFlag( rowFrame, true )
        ButtonSetPressedFlag( rowFrame, isSelectedRow and isOnline )
        ButtonSetDisabledFlag( rowFrame, not isOnline or serverDisallowTrialPlayer)
    end

end

----------------------------------------------------------------
-- Event handlers
----------------------------------------------------------------
function ServerSelectWindow.ClickServerButton()
    local index = WindowGetId(SystemData.ActiveWindow.name)
    
    local dataIndex = ListBoxGetDataIndex("ServerSelectWindowList", index)
    if ( not ButtonGetDisabledFlag(SystemData.ActiveWindow.name) )
    then
        if ( ServerSelectWindow.selectedServer ~= dataIndex )
        then
            ServerSelectWindow.selectedServer = dataIndex
            
            -- Update the highlight around the selected row
            for row = 1, ServerSelectWindowList.numVisibleRows
            do
                ButtonSetPressedFlag( "ServerSelectWindowListRow"..row, ( row == index ) )
            end
        end
    -- if we are a non-buddied trial player we want to popup a window directing the player to upgrade his account to get to the server
    elseif ( ServerSelectWindow.trialPlayer and
             ( not ServerSelectWindow.buddiedPlayer ) and
             ( not ServerSelectWindow.serverList[dataIndex].trialServer ) )

    then
        ServerSelectWindow.ShowUpgradeOption()
    end
    ServerSelectWindow.VerifyServer()
end

-- need to move the button press up a level so that I can add extra popups!
-- removed extra popups but I'll keep it at this level just in case we want to add them back in later
function ServerSelectWindow.SelectServerButton()
    -- if the button is disabled we don't want to do anything
    if (ButtonGetDisabledFlag("ServerSelectWindowSelectButton"))
    then
        return
    end
    ServerSelectWindow.SelectServer()
end

function ServerSelectWindow.SelectServer()
    local serverData = ServerSelectWindow.serverList[ServerSelectWindow.selectedServer]
    -- if the server is retired, we do not let them login, we instead show a popup
    if ( serverData.retired )
    then
        EA_Window_TransferPopup.Show( EA_Window_TransferPopup.RETIRED_SERVER )
    -- if the rule set is role playing and/or open RvR they need to agree to the appropriate agreements before they can play
    elseif ( serverData.rulesetRolePlaying or serverData.rulesetOpenRvR )
    then
        EA_Window_RuleSetPopup.Show( serverData )
    -- otherwise send them into the server
    else
        -- set the pre-selected server to both realms
        PregameSetPreSelectedServerRealm(ServerSelectWindow.BOTH_REALM_OPTIONS)
        SelectServer(serverData.id)
    end
end

-- if we need the user to agree to an addendum we need a way to send them to the server after wards
-- well lucky us... here it is!
function ServerSelectWindow.SelectServerAddendumAccepted()
    local serverData = ServerSelectWindow.serverList[ServerSelectWindow.selectedServer]
    -- set the pre-selected server to both realms
    PregameSetPreSelectedServerRealm(ServerSelectWindow.BOTH_REALM_OPTIONS)
    SelectServer(serverData.id)
end

----------------------------------------------------------------
-- Sorting
----------------------------------------------------------------
function ServerSelectWindow.ChangeSorting()
    local buttonIndex = WindowGetId( SystemData.ActiveWindow.name )
    
    local data = ServerSelectWindow.sortButtonData[buttonIndex]
    local buttonName = "ServerSelectWindowSortButton"..buttonIndex
    
    if (buttonIndex == ServerSelectWindow.currentSort)
    then
        -- Just toggling the direction of the current sort
        data.direction = not data.direction
    else
        -- Changing the active sort. Hide the old one first.
        local oldButtonName = "ServerSelectWindowSortButton"..ServerSelectWindow.currentSort
        WindowSetShowing( oldButtonName.."UpArrow",   false )
        WindowSetShowing( oldButtonName.."DownArrow", false )
        
        ServerSelectWindow.currentSort = buttonIndex
    end
    
    -- Show/update the current sort's buttons as appropriate
    local isUp       = (data.direction == ServerSelectWindow.SORT_DESCENDING)
    WindowSetShowing( buttonName.."UpArrow",   isUp )
    WindowSetShowing( buttonName.."DownArrow", not isUp )
    
    ServerSelectWindow.RefreshList()
end

function ServerSelectWindow.FlexibleSort(a, b)
    local function sortWrapper( sortFunc, a, b )
        -- Always sort offline servers at bottom (or top if direction is flipped)
        if ( a.online and not b.online )
        then
            return true
        elseif ( b.online and not a.online )
        then
            return false
        else
            return sortFunc( a, b )
        end
    end
    
    local data = ServerSelectWindow.sortButtonData[ServerSelectWindow.currentSort]
    if ( data.direction )
    then
        return sortWrapper( data.sortFunc, a, b )
    else
        return sortWrapper( data.sortFunc, b, a )
    end
end

function ServerSelectWindow.ManageProgressWindow()
    if (DoesWindowExist("LoginProgressWindow")) then
        WindowSetShowing("LoginProgressWindow", true)
        LoginProgressWindow.StartLobbyLogin()
        LoginProgressWindow.HideErrorButtons()
    end
end

function ServerSelectWindow.ShouldShowPreSelectWindow()
    return ( ( ServerSelectWindow.preselectedServer ~= nil ) and GameData.Account.CharacterCreation.ShowPerSelectServer and not ServerSelectWindow.hasCharacters )
end

function ServerSelectWindow.InitPreSelect()
    ButtonSetText("ServerSelectWindowPreSelectedWindowAcceptButton", GetPregameString( StringTables.Pregame.LABEL_PRESELECT_ACCEPT ))
    ButtonSetText("ServerSelectWindowPreSelectedWindowDeclineButton", GetPregameString( StringTables.Pregame.LABEL_PRESELECT_DECLINE ))
    
    local server = ServerSelectWindow.serverList[ServerSelectWindow.preselectedServer]
    
    -- Figure out which realm to pre-select
    local orderDensity = GetAdjustedPopulationDensity( server.orderPopulationDensity, server.orderPopulationQueue )
    local destructionDensity = GetAdjustedPopulationDensity( server.destructionPopulationDensity, server.destructionPopulationQueue )
    if ( orderDensity < destructionDensity )
    then
        ServerSelectWindow.preselectedServerRealm = ServerSelectWindow.ORDER_ONLY
    elseif ( destructionDensity < orderDensity )
    then
        ServerSelectWindow.preselectedServerRealm = ServerSelectWindow.DESTRUCTION_ONLY
    -- else we have the same pop density so we'll randomly choose between the 2
    else
        randRealmIndex = math.random(1, 2)
        if ( randRealmIndex == 1 )
        then
            ServerSelectWindow.preselectedServerRealm = ServerSelectWindow.ORDER_ONLY
        else
            ServerSelectWindow.preselectedServerRealm = ServerSelectWindow.DESTRUCTION_ONLY
        end
    end    
    
    local realmText = L""
    if ( ServerSelectWindow.preselectedServerRealm == ServerSelectWindow.ORDER_ONLY )
    then
        realmText = GetPregameString( StringTables.Pregame.LABEL_ORDER )
    elseif ( ServerSelectWindow.preselectedServerRealm == ServerSelectWindow.DESTRUCTION_ONLY )
    then
        realmText = GetPregameString( StringTables.Pregame.LABEL_CHAOS )
    end
    local labelText = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_PRESELECT_MESSAGE, { realmText, server.name } )
    LabelSetText("ServerSelectWindowPreSelectedWindowLabel", labelText )

    -- we only want to show the pre-select window if we meet the criteria the first time we come to the server screen
    GameData.Account.CharacterCreation.ShowPerSelectServer = false
end

function ServerSelectWindow.CancelPreSelect()
    WindowSetShowing("ServerSelectWindowPreSelectedWindow", false)
end

function ServerSelectWindow.SelectPreSelectedServer()
    WindowSetShowing("ServerSelectWindowPreSelectedWindow", false)
    
    PregameSetPreSelectedServerRealm(ServerSelectWindow.preselectedServerRealm)
    SelectServer(ServerSelectWindow.serverList[ServerSelectWindow.preselectedServer].id)
end

-- Tooltip functions --
function ServerSelectWindow.CreateTooltip(window, text)
    Tooltips.CreateTextOnlyTooltip( window, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end

function ServerSelectWindow.ShowLocationTooltip(flags, x, y)
    local windowName = SystemData.ActiveWindow.name
    local slot = WindowGetId( windowName )
    local tableIndex = ListBoxGetDataIndex("ServerSelectWindowList", slot)
    local tooltipString = L""
    
    if ("STR_REGION_NORTHAMERICA" == ServerSelectWindow.serverList[tableIndex].region)
    then
        tooltipString = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_SERVER_SELECT_LOCATION_TOOLTIP, { GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_LOCATION_NORTH_AMERICA ) } )
    elseif ("STR_REGION_OCEANIC" == ServerSelectWindow.serverList[tableIndex].region)
    then
        tooltipString = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_SERVER_SELECT_LOCATION_TOOLTIP, { GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_LOCATION_OCEANIC ) } )
    elseif ("STR_REGION_OCEANIC2" == ServerSelectWindow.serverList[tableIndex].region)
    then
        tooltipString = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_SERVER_SELECT_LOCATION_TOOLTIP, { GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_LOCATION_OCEANIC2 ) } )
    elseif ("STR_REGION_RUSSIA" == ServerSelectWindow.serverList[tableIndex].region)
    then
        tooltipString = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_SERVER_SELECT_LOCATION_TOOLTIP, { GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_LOCATION_RUSSIA ) } )
    elseif ("STR_REGION_TAIWAN" == ServerSelectWindow.serverList[tableIndex].region)
    then
        tooltipString = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_SERVER_SELECT_LOCATION_TOOLTIP, { GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_LOCATION_TAIWAN ) } )
    else
        return
    end

    ServerSelectWindow.CreateTooltip(windowName, tooltipString)
end

function ServerSelectWindow.ShowLanguageTooltip(flags, x, y)
    local windowName = SystemData.ActiveWindow.name
    local slot = WindowGetId( windowName )
    local tableIndex = ListBoxGetDataIndex("ServerSelectWindowList", slot)
    local tooltipString = L""
    
    tooltipString = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_SERVER_SELECT_LANGUAGE_TOOLTIP, { GetStringFromTable( "ServerLanguage", ServerSelectWindow.serverList[tableIndex].language) } )

    ServerSelectWindow.CreateTooltip(windowName, tooltipString)
end

function ServerSelectWindow.ShowRuleSetTooltip(flags, x, y)
    local windowName = SystemData.ActiveWindow.name
    local slot = WindowGetId( windowName )
    local tableIndex = ListBoxGetDataIndex("ServerSelectWindowList", slot)
    local tooltipString = L""
    
    if (ServerSelectWindow.serverList[tableIndex].rulesetCore)
    then
        tooltipString = GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_RULE_SET_CORE_TOOLTIP )
    elseif (ServerSelectWindow.serverList[tableIndex].rulesetOpenRvR) and (ServerSelectWindow.serverList[tableIndex].rulesetRolePlaying)
    then
        tooltipString = GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_RULE_SET_OPEN_RVR_RP_TOOLTIP )
    elseif (ServerSelectWindow.serverList[tableIndex].rulesetOpenRvR)
    then
        tooltipString = GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_RULE_SET_OPEN_RVR_TOOLTIP )
    elseif (ServerSelectWindow.serverList[tableIndex].rulesetRolePlaying)
    then
        tooltipString = GetPregameString( StringTables.Pregame.LABEL_SERVER_SELECT_RULE_SET_ROLE_PLAY_TOOLTIP )
    else
        return
    end

    ServerSelectWindow.CreateTooltip(windowName, tooltipString)
end

function ServerSelectWindow.ShowOrderIconButtonTooltip(flags, x, y)
    local windowName = SystemData.ActiveWindow.name
    local slot = WindowGetId( windowName )
    local tooltipString = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_POPULATION_BONUS_BUTTON_TOOLTIP, { GetPregameString( StringTables.Pregame.LABEL_ORDER ) } )
    ServerSelectWindow.CreateTooltip(windowName, tooltipString)
end

function ServerSelectWindow.ShowDestructionIconButtonTooltip(flags, x, y)
    local windowName = SystemData.ActiveWindow.name
    local slot = WindowGetId( windowName )
    local tooltipString = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_POPULATION_BONUS_BUTTON_TOOLTIP, { GetPregameString( StringTables.Pregame.LABEL_CHAOS ) } )
    ServerSelectWindow.CreateTooltip(windowName, tooltipString)
end

function ServerSelectWindow.ShowOrderIconTooltip(flags, x, y)
    local windowName = SystemData.ActiveWindow.name
    local slot = WindowGetId( windowName )
    local tableIndex = ListBoxGetDataIndex("ServerSelectWindowList", slot)

    if ServerSelectWindow.serverList[tableIndex].orderBonus ~= 0
    then
        local tooltipString = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_POPULATION_BONUS_TOOLTIP, { GetPregameString( StringTables.Pregame.LABEL_ORDER ) } )
        ServerSelectWindow.CreateTooltip(windowName, tooltipString)
    end
end

function ServerSelectWindow.ShowDestructionIconTooltip(flags, x, y)
    local windowName = SystemData.ActiveWindow.name
    local slot = WindowGetId( windowName )
    local tableIndex = ListBoxGetDataIndex("ServerSelectWindowList", slot)

    if ServerSelectWindow.serverList[tableIndex].destructionBonus ~= 0
    then
        local tooltipString = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_POPULATION_BONUS_TOOLTIP, { GetPregameString( StringTables.Pregame.LABEL_CHAOS ) } )
        ServerSelectWindow.CreateTooltip(windowName, tooltipString)
    end
end

function ServerSelectWindow.ShouldSendToPopBonusServer()
    return ( ( ServerSelectWindow.popBonusServer ~= nil ) and GameData.Account.CharacterCreation.ShowPerSelectServer and not ServerSelectWindow.hasCharacters )
end

function ServerSelectWindow.SelectPopBonusServer()
    -- we will hide the server select window because we don't want the new user seeing it while they are being redirected
    WindowSetShowing("ServerSelectWindow", false)
    
    local server = ServerSelectWindow.serverList[ServerSelectWindow.popBonusServer]
    
    -- if one specific realm has a bonus but not the other realm, direct users to that realm
    if ( ( server.destructionBonus ~= 0 ) and ( server.orderBonus == 0 ) )
    then
        PregameSetPreSelectedServerRealm( ServerSelectWindow.DESTRUCTION_ONLY )
    elseif ( ( server.orderBonus ~= 0 ) and ( server.destructionBonus == 0 ) )
    then
        PregameSetPreSelectedServerRealm( ServerSelectWindow.ORDER_ONLY )
    else
        PregameSetPreSelectedServerRealm( ServerSelectWindow.BOTH_REALM_OPTIONS )
    end

    -- we need to notify the character select state that we have been auto logged in so we will set it here
    ServerSelectWindow.autoLoggedIn = true

    -- we will set the selected server to this server now that it has been accepted and send it back through the logic
    -- this is to assure all the proper popups are seen
    ServerSelectWindow.selectedServer = ServerSelectWindow.popBonusServer
    -- set the realm bonus values for the server
    PregameSetServerRealmBonuses( server.orderBonus, server.destructionBonus )
    -- and act as if this was the server that was choosen from the server select originally
    ServerSelectWindow.SelectServerButton()
    -- we only want to show the pre-select window if we meet the criteria the first time we come to the server screen
    GameData.Account.CharacterCreation.ShowPerSelectServer = false
end

-- this function is used to determine if the player is allowed to connect to the server they selected
function ServerSelectWindow.VerifyServer()
    local server = ServerSelectWindow.serverList[ServerSelectWindow.selectedServer]
    if ( server )
    then
        if ( (server.legacy or server.retired ) and ( server.characterCount == 0 ) )
        then
            ButtonSetDisabledFlag( "ServerSelectWindowSelectButton", true )
        else
            ButtonSetDisabledFlag( "ServerSelectWindowSelectButton", false )
        end
    end
end

function ServerSelectWindow.OnToggleLegacy()
    ServerSelectWindow.showLegacyServers = not ServerSelectWindow.showLegacyServers
    ButtonSetPressedFlag( "ServerSelectWindowShowLegacy", ServerSelectWindow.showLegacyServers )
    ServerSelectWindow.RefreshList()
end

-- this is where we determine if we want to send the user to a trial server or not
function ServerSelectWindow.ShouldSendToTrialUserServer()
    return ( ServerSelectWindow.trialPlayer and not ServerSelectWindow.buddiedPlayer and ( ServerSelectWindow.trialPlayerServer ~= nil ) and GameData.Account.CharacterCreation.ShowPerSelectServer and not ServerSelectWindow.hasCharacters )
end    

function ServerSelectWindow.SelectTrialUserServer()
    -- we will hide the server select window because we don't want the new user seeing it while they are being redirected
    WindowSetShowing("ServerSelectWindow", false)

    -- we will set the selected server to this server now that it has been accepted and send it back through the logic
    -- this is to assure all the proper popups are seen
    ServerSelectWindow.selectedServer = ServerSelectWindow.trialPlayerServer
    local server = ServerSelectWindow.serverList[ServerSelectWindow.trialPlayerServer]
    -- set the realm bonus values for the server
    PregameSetServerRealmBonuses( server.orderBonus, server.destructionBonus )
    -- and act as if this was the server that was choosen from the server select originally
    ServerSelectWindow.SelectServerButton()
    -- only push a trial player to the trial servers once a session
    GameData.Account.CharacterCreation.ShowPerSelectServer = false
end

function ServerSelectWindow.ShowUpgradeOption()
    EA_TrialAlertWindow.Show(SystemData.TrialAlert.ALERT_SERVER)
end
