
EA_Window_OpenParty = {}

EA_Window_OpenParty.TAB_NEARBY = 1
EA_Window_OpenParty.TAB_WORLD = 2
EA_Window_OpenParty.LOOT_ROLL_OPTIONS = 3
EA_Window_OpenParty.TAB_MANAGE = 4
EA_Window_OpenParty.TabData = {
    [EA_Window_OpenParty.TAB_NEARBY]        = { tabName = "TabNearby",          windowName = "Nearby",          scenarioAllow = false },
    [EA_Window_OpenParty.TAB_WORLD]         = { tabName = "TabWorld",           windowName = "World",           scenarioAllow = false },
    [EA_Window_OpenParty.LOOT_ROLL_OPTIONS] = { tabName = "TabLootRollOptions", windowName = "LootRollOptions", scenarioAllow = true },
    [EA_Window_OpenParty.TAB_MANAGE]        = { tabName = "TabManage",          windowName = "Manage",          scenarioAllow = false }
}
-- populated in Initialize based on the above data
local TabsAllowedWithinScenario = {}

EA_Window_OpenParty.InterestTypes = {
    [GameData.OpenPartyInterest.NOT_SET] = GetStringFromTable( "SocialStrings", StringTables.Social.PARTY_INTEREST_ANY ),
    [GameData.OpenPartyInterest.PVE] = GetStringFromTable( "SocialStrings", StringTables.Social.PARTY_INTEREST_PVE ),
    [GameData.OpenPartyInterest.RVR] = GetStringFromTable( "SocialStrings", StringTables.Social.PARTY_INTEREST_RVR ),
    [GameData.OpenPartyInterest.PQ] = GetStringFromTable( "SocialStrings", StringTables.Social.PARTY_INTEREST_PQ ),
    [GameData.OpenPartyInterest.SCENARIO] = GetStringFromTable( "SocialStrings", StringTables.Social.PARTY_INTEREST_SCENARIO ),
    [GameData.OpenPartyInterest.DUNGEON] = GetStringFromTable( "SocialStrings", StringTables.Social.PARTY_INTEREST_DUNGEON )
}
EA_Window_OpenParty.InterestTypeColors = {
    [GameData.OpenPartyInterest.NOT_SET] = { r=255,g=255,b=255 },
    [GameData.OpenPartyInterest.PVE] = { r=255,g=204,b=102 },
    [GameData.OpenPartyInterest.RVR] = { r=255,g=0,b=0 },
    [GameData.OpenPartyInterest.PQ] = { r=102,g=102,b=255 },
    [GameData.OpenPartyInterest.SCENARIO] = { r=0,g=166,b=80 },
    [GameData.OpenPartyInterest.DUNGEON] = { r=160,g=65,b=13 }
}

EA_Window_OpenParty.PartyTextColor = {
    r=253,
    g=253,
    b=253,
}
EA_Window_OpenParty.WarbandTextColor = {
    r=178,
    b=255,
    g=116,
}

EA_Window_OpenParty.ICON_ALLIANCE   = 65
EA_Window_OpenParty.ICON_FRIEND     = 66
EA_Window_OpenParty.ICON_GUILD      = 67
EA_Window_OpenParty.ICON_IGNORE     = 68

EA_Window_OpenParty.TOTAL_NUM_GROUP_MEMBERS = 6
EA_Window_OpenParty.TOTAL_NUM_WARBAND_MEMBERS = 24
-- Used to fade the window out
EA_Window_OpenParty.fadeOutDelay = 0

local PARENT_WINDOW = "EA_Window_OpenParty"
local FLY_OUT_WINDOW = "EA_Window_OpenPartyFlyOut"
local TOOLTIP_BORDER_OFFSET = 10
local FADE_OUT_DELAY = 3
local TOTAL_NUM_NOTIFY_MEMBERS = 3

local function PrintScenarioError()
    if EA_ChatWindow
    then
        local errorMsg = GetStringFromTable( "Default", StringTables.Default.TEXT_FEATURE_NOT_AVAILABLE_IN_SCENARIO )
        EA_ChatWindow.Print( errorMsg, SystemData.ChatLogFilters.USER_ERROR )
    end
end

local function ChooseAvailableTab()
    -- use nearby as default unless disabled, then use first allowed
    if ButtonGetDisabledFlag( PARENT_WINDOW..EA_Window_OpenParty.TabData[EA_Window_OpenParty.TAB_NEARBY].tabName )
    then
        return TabsAllowedWithinScenario[1]
    else
        return EA_Window_OpenParty.TAB_NEARBY
    end
end

function EA_Window_OpenParty.Initialize()
    -- Title Bar
    LabelSetText( PARENT_WINDOW.."TitleBarText", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPENPARTY_TITLE) )

    -- Tabs
    ButtonSetText( PARENT_WINDOW.."TabNearby", GetStringFromTable("SocialStrings", StringTables.Social.TAB_LABEL_NEARBY) )
    ButtonSetText( PARENT_WINDOW.."TabWorld", GetStringFromTable("SocialStrings", StringTables.Social.TAB_LABEL_WORLD) )
    ButtonSetText( PARENT_WINDOW.."TabLootRollOptions", GetStringFromTable("SocialStrings", StringTables.Social.TAB_LABEL_LOOT_ROLL_OPTIONS) )
    ButtonSetText( PARENT_WINDOW.."TabManage", GetStringFromTable("SocialStrings", StringTables.Social.TAB_LABEL_MANAGE) )
    
    -- Event Handlers
    WindowRegisterEventHandler( FLY_OUT_WINDOW, SystemData.Events.SOCIAL_OPENPARTY_NOTIFY,  "EA_Window_OpenParty.OnOpenPartyNotification" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.TOGGLE_BATTLEGROUP_WINDOW, "EA_Window_OpenParty.ToggleManageShowing" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.SCENARIO_BEGIN,            "EA_Window_OpenParty.OnScenarioBegin" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.CITY_SCENARIO_BEGIN,       "EA_Window_OpenParty.OnScenarioBegin" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.SCENARIO_END,              "EA_Window_OpenParty.OnScenarioEnd" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.CITY_SCENARIO_END,         "EA_Window_OpenParty.OnScenarioEnd" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.BATTLEGROUP_UPDATED,       "EA_Window_OpenParty.UpdateManageTabDisable" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.GROUP_UPDATED,             "EA_Window_OpenParty.UpdateManageTabDisable" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.OPEN_LFM_WINDOW,           "EA_Window_OpenParty.OpenToWorldTab" )
    
    -- Hide the flyout window
    WindowSetShowing( FLY_OUT_WINDOW, false )
    -- Register flyout's anchor with the layout editor
    LayoutEditor.RegisterWindow( FLY_OUT_WINDOW.."Anchor",
                            GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_OP_NOTIFICATION_FLYOUT_NAME ),
                            GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_OP_NOTIFICATION_FLYOUT_DESC ),
                            false, false,
                            true, nil )
    
    -- Initialize child tab windows
    EA_Window_OpenPartyNearby.Initialize()
    EA_Window_OpenPartyWorld.Initialize()
    EA_Window_OpenPartyLootRollOptions.Initialize()
    EA_Window_OpenPartyManage.Initialize()
    
    -- Init tooltip windows
    CreateWindow( "EA_Tooltip_OpenParty", false )
    CreateWindow( "EA_Tooltip_OpenPartyWorld", false )
    
    for tabId, tabData in pairs( EA_Window_OpenParty.TabData )
    do
        if tabData.scenarioAllow
        then
            table.insert( TabsAllowedWithinScenario, tabId )
        end
    end

    EA_Window_OpenParty.SelectTab( EA_Window_OpenParty.TAB_NEARBY )
    EA_Window_OpenParty.UpdateInScenarioTabDisable()
end

function EA_Window_OpenParty.OnScenarioBegin()
    WindowSetShowing( PARENT_WINDOW, false )
    EA_Window_OpenParty.UpdateInScenarioTabDisable()
end

function EA_Window_OpenParty.OnScenarioEnd()
    EA_Window_OpenParty.UpdateInScenarioTabDisable()
end

-- TAB FUNCTIONS
function EA_Window_OpenParty.OnClickTab()
    local tabId = WindowGetId( SystemData.ActiveWindow.name )
    EA_Window_OpenParty.SelectTab( tabId )
end

function EA_Window_OpenParty.SelectTab( tab )
    if( EA_Window_OpenParty.TabData[tab] == nil )
    then
        tab = ChooseAvailableTab()
    end
    
    -- Don't switch tabs if it's disabled
    if( ButtonGetDisabledFlag( PARENT_WINDOW..EA_Window_OpenParty.TabData[tab].tabName ) )
    then
        return
    end
    
    for tabId, tabData in pairs( EA_Window_OpenParty.TabData )
    do
        local activeTab = (tabId == tab)
        WindowSetShowing( PARENT_WINDOW..tabData.windowName, activeTab )
        ButtonSetPressedFlag( PARENT_WINDOW..tabData.tabName, activeTab )
    end
end

function EA_Window_OpenParty.IsTabSelected( tab )
    if( EA_Window_OpenParty.TabData[tab] == nil )
    then
        return false
    end
    local windowName = EA_Window_OpenParty.TabData[tab].windowName
    return WindowGetShowing( PARENT_WINDOW..windowName )
end

local manageDisableDelay = 0
function EA_Window_OpenParty.OnUpdate( timePassed ) -- we can get rid of this handler once the temp solution described below is no longer needed
    if( manageDisableDelay > 0 )
    then
        manageDisableDelay = manageDisableDelay - timePassed
        if( manageDisableDelay <= 0 )
        then
            if( EA_Window_OpenParty.IsTabSelected( EA_Window_OpenParty.TAB_MANAGE ) )
            then
                EA_Window_OpenParty.SelectTab( ChooseAvailableTab() )
            end
            ButtonSetDisabledFlag( PARENT_WINDOW..EA_Window_OpenParty.TabData[EA_Window_OpenParty.TAB_MANAGE].tabName, true )
        end
    end
end

function EA_Window_OpenParty.DisableTab( tab )

    -- Temporary! currently we don't know the difference between leaving and moving
    -- warband groups, thus when the local player moves himself to another group,
    -- we think he's solo and disable the manage tab, so we'll just delay the
    -- disable for a few seconds to allow enough time for the re-add to happen
    if( tab == EA_Window_OpenParty.TAB_MANAGE )
    then
        manageDisableDelay = 2
        return
    end
    

    -- if the tab we're disabling is currently selected, switch to something else
    if( EA_Window_OpenParty.IsTabSelected( tab ) )
    then
        EA_Window_OpenParty.SelectTab( ChooseAvailableTab() )
    end
    
    ButtonSetDisabledFlag( PARENT_WINDOW..EA_Window_OpenParty.TabData[tab].tabName, true )
end

function EA_Window_OpenParty.EnableTab( tab )
    if( tab == EA_Window_OpenParty.TAB_MANAGE ) -- this statement can be removed once the solution above is no longer needed
    then
        manageDisableDelay = 0
    end

    ButtonSetDisabledFlag( PARENT_WINDOW..EA_Window_OpenParty.TabData[tab].tabName, false )
end

function EA_Window_OpenParty.OpenToWorldTab()
    if ( GameData.Player.isInScenario or GameData.Player.isInSiege )
    then
        PrintScenarioError()
        return
    end
    EA_Window_OpenParty.SelectTab( EA_Window_OpenParty.TAB_WORLD )
    WindowSetShowing( PARENT_WINDOW, true )
end

function EA_Window_OpenParty.OpenToManageTab()
    if ( GameData.Player.isInScenario or GameData.Player.isInSiege )
    then
        PrintScenarioError()
        return
    end
    EA_Window_OpenParty.SelectTab( EA_Window_OpenParty.TAB_MANAGE )
    WindowSetShowing( PARENT_WINDOW, true )
end

function EA_Window_OpenParty.ToggleManageShowing()
    if( ButtonGetDisabledFlag( PARENT_WINDOW..EA_Window_OpenParty.TabData[EA_Window_OpenParty.TAB_MANAGE].tabName ) )
    then
        return
    end

    local openPartyWindowShowing = WindowGetShowing( PARENT_WINDOW )
    local manageTabSelected = EA_Window_OpenParty.IsTabSelected( EA_Window_OpenParty.TAB_MANAGE )

    if( openPartyWindowShowing and manageTabSelected )
    then
        EA_Window_OpenParty.ToggleFullWindow()
    else
        EA_Window_OpenParty.OpenToManageTab()
    end
end

function EA_Window_OpenParty.ToggleFullWindow()
    WindowSetShowing( PARENT_WINDOW, not WindowGetShowing( PARENT_WINDOW ) )
end

function EA_Window_OpenParty.OnShown()
    WindowUtils.OnShown()
    
    -- make sure we don't open to a disabled tab
    for tabId, tabData in pairs( EA_Window_OpenParty.TabData )
    do
        if EA_Window_OpenParty.IsTabSelected( tabId )
        then
            if ButtonGetDisabledFlag( PARENT_WINDOW..EA_Window_OpenParty.TabData[tabId].tabName )
            then
                EA_Window_OpenParty.SelectTab( ChooseAvailableTab() )
            end
            break
        end
    end
end

function EA_Window_OpenParty.OnHidden()
    WindowUtils.OnHidden()
end


function EA_Window_OpenParty.UpdateManageTabDisable()
    if( IsWarBandActive() or PartyUtils.IsPartyActive() )
    then
        if( GameData.Player.isInScenario or GameData.Player.isInSiege )
        then
            EA_Window_OpenParty.DisableTab( EA_Window_OpenParty.TAB_MANAGE )
            return
        end
        EA_Window_OpenParty.EnableTab( EA_Window_OpenParty.TAB_MANAGE )
        
    else
        EA_Window_OpenParty.DisableTab( EA_Window_OpenParty.TAB_MANAGE )
    end
end

function EA_Window_OpenParty.UpdateInScenarioTabDisable()
    for tabId, tabData in pairs( EA_Window_OpenParty.TabData )
    do
        if  (GameData.Player.isInScenario or GameData.Player.isInSiege)
            and not tabData.scenarioAllow
        then
            EA_Window_OpenParty.DisableTab( tabId )
        else
            EA_Window_OpenParty.EnableTab( tabId )
        end
    end
    EA_Window_OpenParty.UpdateManageTabDisable()
end



function EA_Window_OpenParty.GetLocationTypeColor( locationIdx )
    if( EA_Window_OpenParty.InterestTypeColors[locationIdx] == nil )
    then
        -- Default to PVE
        locationIdx = GameData.OpenPartyInterest.PVE
    end
    return EA_Window_OpenParty.InterestTypeColors[locationIdx]
end

function EA_Window_OpenParty.GetLocationTypeName( locationIdx )
    if( EA_Window_OpenParty.InterestTypes[locationIdx] == nil )
    then
        -- Default to PVE
        locationIdx = GameData.OpenPartyInterest.PVE
    end
    return EA_Window_OpenParty.InterestTypes[locationIdx]
end

function EA_Window_OpenParty.OnUpdateForFlyOut( timePassed )
    if( EA_Window_OpenParty.fadeOutDelay > 0 )
    then
        EA_Window_OpenParty.fadeOutDelay = EA_Window_OpenParty.fadeOutDelay - timePassed
        if( EA_Window_OpenParty.fadeOutDelay < 0 )
        then
            EA_Window_OpenParty.FadeOutFlyoutWindow()
            EA_Window_OpenParty.fadeOutDelay = 0
        end
    end
end

function EA_Window_OpenParty.OnMouseOverSearchButton()
    if( WindowGetShowing( PARENT_WINDOW ) == true )
    then
        Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name, GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_SEARCHBUTTON_HIDE) )
    else
        Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name, GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_SEARCHBUTTON) )
    end
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP )
end

function EA_Window_OpenParty.FadeOutFlyoutWindow()
    WindowStartAlphaAnimation( FLY_OUT_WINDOW, Window.AnimationType.SINGLE_NO_RESET, 1.0, 0.0, 1.0, false, 0, 0 )
end

-- Get the list of available parties in this area.  This function is called when the user enters the area where
-- Open Parties exist.
function EA_Window_OpenParty.OnOpenPartyNotification()

    local openPartyAvailable = GetOpenPartyNotificationList()
    local x,y, width, height

    -- If there's nothing in the list, tell the user nothing was found
    if( #openPartyAvailable <= 0  )
    then
        LabelSetText( FLY_OUT_WINDOW.."Header", GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_HEADER_NOOPENPARTY ) )
        x, y = WindowGetOffsetFromParent( FLY_OUT_WINDOW.."Header" )
        width, height = WindowGetDimensions( FLY_OUT_WINDOW.."Header" )
        width = width + x + TOOLTIP_BORDER_OFFSET
        height = height + y + TOOLTIP_BORDER_OFFSET
        WindowSetDimensions( FLY_OUT_WINDOW, width, height )

        for idx=1, TOTAL_NUM_NOTIFY_MEMBERS
        do
            WindowSetShowing( FLY_OUT_WINDOW.."Leader"..idx.."Text", false )
            WindowSetShowing( FLY_OUT_WINDOW.."Leader"..idx.."RatioText", false )
        end
        
    else
        LabelSetText( FLY_OUT_WINDOW.."Header", GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_HEADER_OPENPARTY ) )
        x, y = WindowGetOffsetFromParent( FLY_OUT_WINDOW.."Header" )
        width, height = WindowGetDimensions( FLY_OUT_WINDOW.."Header" )
        width = width + x
        height = y + height

        -- Loop over all possible entries
        for index, partyData in ipairs( openPartyAvailable )
        do
            -- Only show a few
            if( index > TOTAL_NUM_NOTIFY_MEMBERS )
            then
                break
            end
        
            LabelSetText( FLY_OUT_WINDOW.."Leader"..index.."Text", partyData.leaderName )
            
            local maxGroupMembers = EA_Window_OpenParty.TOTAL_NUM_GROUP_MEMBERS
            local color = EA_Window_OpenParty.PartyTextColor
            if( partyData.isWarband )
            then
                maxGroupMembers = EA_Window_OpenParty.TOTAL_NUM_WARBAND_MEMBERS
                color = EA_Window_OpenParty.WarbandTextColor
            end
            LabelSetTextColor( FLY_OUT_WINDOW.."Leader"..index.."Text", color.r, color.b, color.g )
            LabelSetText( FLY_OUT_WINDOW.."Leader"..index.."RatioText", L"("..partyData.numGroupMembers..L"/"..maxGroupMembers..L")" )
            LabelSetTextColor( FLY_OUT_WINDOW.."Leader"..index.."RatioText", EA_Window_OpenParty.PartyTextColor.r, EA_Window_OpenParty.PartyTextColor.g, EA_Window_OpenParty.PartyTextColor.b )
            
            WindowSetShowing( FLY_OUT_WINDOW.."Leader"..index.."Text", true )
            WindowSetShowing( FLY_OUT_WINDOW.."Leader"..index.."RatioText", true )
            
            local x, _ = WindowGetOffsetFromParent( FLY_OUT_WINDOW.."Leader"..index.."RatioText" )
            local _, _, _, _, y = WindowGetAnchor( FLY_OUT_WINDOW.."Leader"..index.."Text", 1 )
            local sizeX, sizeY = WindowGetDimensions( FLY_OUT_WINDOW.."Leader"..index.."RatioText" )
            width = math.max( width, x + sizeX )
            height = height + sizeY + y
        end

        height = height + TOOLTIP_BORDER_OFFSET
        width = width + TOOLTIP_BORDER_OFFSET
        WindowSetDimensions( FLY_OUT_WINDOW, width, height )


        -- Hide any listings we're not using
        for idx=#openPartyAvailable+1, TOTAL_NUM_NOTIFY_MEMBERS do
            WindowSetShowing( FLY_OUT_WINDOW.."Leader"..idx.."Text", false )
            WindowSetShowing( FLY_OUT_WINDOW.."Leader"..idx.."RatioText", false )
        end

    end
    
    WindowSetShowing( FLY_OUT_WINDOW, true )
    WindowStartAlphaAnimation ( FLY_OUT_WINDOW, Window.AnimationType.SINGLE_NO_RESET, 0.0, 1.0, 0.5, false, 0, 0 )
    EA_Window_OpenParty.fadeOutDelay = FADE_OUT_DELAY
end
