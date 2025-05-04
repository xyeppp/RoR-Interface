
EA_Window_OpenPartyManage = {}
EA_Window_OpenPartyManage.warbandParties = {} -- only used to populate list boxes (ListBox needs a global table)

local PARENT_WINDOW = "EA_Window_OpenPartyManage"
local draggedWindow = nil

--
-- RowId conversion functions.
--
-- RowIds are a unique identifier for each row,
-- e.g. group 1 is 1 thru 6, group 2 is 7 thru 12...
--

local function GetRowId( partyIndex, rowIndex )
    return ((partyIndex - 1) * 6) + rowIndex
end

local function GetPartyByRowId( rowId )
    return math.ceil( rowId / 6 )
end

local function GetRowIndexByRowId( rowId )
    return math.mod( rowId + 5, 6 ) + 1
end

local function GetPartyWindowName( partyIndex )
    return PARENT_WINDOW.."Warband"..partyIndex
end

local function GetRowWindowName( partyIndex, rowIndex )
    local partyWindow = GetPartyWindowName( partyIndex )
    return partyWindow.."ListRow"..rowIndex
end

--
-- Misc window name functions
--

local function GetRowWindowNameById( rowId )
    local partyIndex = GetPartyByRowId( rowId )
    local memberIndex = GetRowIndexByRowId( rowId )
    return GetRowWindowName( partyIndex, memberIndex )
end

local function GetPartyIndexByWindowName( window )
    for partyIndex = 1, PartyUtils.PARTIES_PER_WARBAND do
        -- Compare substrings to take non-parent windows into account
        -- NOTE: This won't work if we ever put more than 9 groups in the window, which is very unlikely but who knows!
        local partyWindow = GetPartyWindowName( partyIndex )
        local partyWindowNameLen = string.len( partyWindow )
        if ( string.len(window) >= partyWindowNameLen and string.sub(window, 1, partyWindowNameLen) == partyWindow ) then
            return partyIndex
        end
    end
    return 0
end

local function GetRowIdByWindowName( window )
    local partyIndex = GetPartyIndexByWindowName( window )
    if ( partyIndex == 0 ) then
        return 0
    end
    for rowIndex = 1, PartyUtils.PLAYERS_PER_PARTY do
        -- Compare substrings to take non-parent windows into account
        local rowWindowName = GetRowWindowName( partyIndex, rowIndex )
        local rowWindowNameLen = string.len( rowWindowName )
        if ( string.len(window) >= rowWindowNameLen and string.sub(window, 1, rowWindowNameLen) == rowWindowName ) then
            return GetRowId( partyIndex, rowIndex )
        end
    end
    return 0
end

--------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS
--------------------------------------------------------------------------------

function EA_Window_OpenPartyManage.Initialize()
    RegisterEventHandler( SystemData.Events.L_BUTTON_UP_PROCESSED, "EA_Window_OpenPartyManage.OnLButtonUpProcessed" )
    
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.BATTLEGROUP_UPDATED,       "EA_Window_OpenPartyManage.UpdateWarband" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.GROUP_UPDATED,             "EA_Window_OpenPartyManage.UpdateParty" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.GROUP_SETTINGS_UPDATED,    "EA_Window_OpenPartyManage.UpdateSettings" )
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.BATTLEGROUP_MEMBER_UPDATED,"EA_Window_OpenPartyManage.SingleMemberUpdate" )
    
    LabelSetText( PARENT_WINDOW.."LootHeaderText", GetStringFromTable( "SocialStrings", StringTables.Social.HEADER_LOOT_OPTIONS ) )
    LabelSetText( PARENT_WINDOW.."WarbandHeaderText", GetStringFromTable( "SocialStrings", StringTables.Social.HEADER_WARBAND_MEMBERS ) )
    
    -- Options
    LabelSetText( PARENT_WINDOW.."NeedOnUseButtonLabel", GetString( StringTables.Default.LABEL_NEED_ON_USE_SETTING ) )
    LabelSetText( PARENT_WINDOW.."AutoLootRvRLabel", GetString( StringTables.Default.LABEL_AUTO_LOOT_RVR_SETTING ) )

    LabelSetText( PARENT_WINDOW.."LootModeTitle", GetString( StringTables.Default.LABEL_CURRENT_LOOT_MODE ) )
    ComboBoxAddMenuItem( PARENT_WINDOW.."LootModeCombo", GetString( StringTables.Default.LABEL_LOOT_ROUND_ROBIN ) )
    ComboBoxAddMenuItem( PARENT_WINDOW.."LootModeCombo", GetString( StringTables.Default.LABEL_LOOT_FFA ) )
    ComboBoxAddMenuItem( PARENT_WINDOW.."LootModeCombo", GetString( StringTables.Default.LABEL_LOOT_MASTER_LOOT ) )
    
    LabelSetText( PARENT_WINDOW.."LootThresholdTitle", GetString( StringTables.Default.LABEL_CURRENT_LOOT_THRESHOLD ) )
    ComboBoxAddMenuItem( PARENT_WINDOW.."LootThresholdCombo", GetString( StringTables.Default.LABEL_ALL) )
    ComboBoxAddMenuItem( PARENT_WINDOW.."LootThresholdCombo", GetString( StringTables.Default.LABEL_ITEM_RARITY_COMMON ) )
    ComboBoxAddMenuItem( PARENT_WINDOW.."LootThresholdCombo", GetString( StringTables.Default.LABEL_ITEM_RARITY_UNCOMMON ) )
    ComboBoxAddMenuItem( PARENT_WINDOW.."LootThresholdCombo", GetString( StringTables.Default.LABEL_ITEM_RARITY_RARE ) )
    ComboBoxAddMenuItem( PARENT_WINDOW.."LootThresholdCombo", GetString( StringTables.Default.LABEL_ITEM_RARITY_VERY_RARE ) )
    ComboBoxAddMenuItem( PARENT_WINDOW.."LootThresholdCombo", GetString( StringTables.Default.LABEL_ITEM_RARITY_ARTIFACT ) )
    ComboBoxAddMenuItem( PARENT_WINDOW.."LootThresholdCombo", GetString( StringTables.Default.LABEL_NONE ) )
    
    LabelSetText( PARENT_WINDOW.."MasterLooterTitle", GetString( StringTables.Default.LABEL_CURRENT_MASTER_LOOTERS ) )
    
    
    -- Legend
    LabelSetText( PARENT_WINDOW.."LegendLeaderText", GetStringFromTable("SocialStrings", StringTables.Social.MANAGE_LEGEND_WARBAND_LEADER) )
    LabelSetText( PARENT_WINDOW.."LegendMainAssistText", GetStringFromTable("SocialStrings", StringTables.Social.MANAGE_LEGEND_MAIN_ASSIST) )
    LabelSetText( PARENT_WINDOW.."LegendAssistantText", GetStringFromTable("SocialStrings", StringTables.Social.MANAGE_LEGEND_WARBAND_ASSISTANT) )
    LabelSetText( PARENT_WINDOW.."LegendMasterLooterText", GetStringFromTable("SocialStrings", StringTables.Social.MANAGE_LEGEND_MASTER_LOOTER) )
    

    -- Set Label Text
    ButtonSetText( PARENT_WINDOW.."ConvertToWarbandButton" , GetString( StringTables.Default.LABEL_PARTY_FORM_WARPARTY ) )
    
    LabelSetText( GetPartyWindowName(1).."Label", GetString( StringTables.Default.LABEL_GROUP_1 ) )
    LabelSetText( GetPartyWindowName(2).."Label", GetString( StringTables.Default.LABEL_GROUP_2 ) )
    LabelSetText( GetPartyWindowName(3).."Label", GetString( StringTables.Default.LABEL_GROUP_3 ) )
    LabelSetText( GetPartyWindowName(4).."Label", GetString( StringTables.Default.LABEL_GROUP_4 ) )
    
    for partyIndex = 1, PartyUtils.PARTIES_PER_WARBAND
    do
        local partyWindowCheckBox = GetPartyWindowName(partyIndex).."Show"
        ButtonSetCheckButtonFlag( partyWindowCheckBox, true )
        ButtonSetPressedFlag( partyWindowCheckBox, true )
    end

    CreateWindow( PARENT_WINDOW.."DragWindow", false )
    WindowSetTintColor( PARENT_WINDOW.."DragWindowRowBackground", 255, 255, 255 )
    WindowSetAlpha( PARENT_WINDOW.."DragWindowRowBackground", 0.1 )
    
    -- Hide hover frame
    WindowSetShowing( PARENT_WINDOW.."WarbandHoverFrame", false )
    DefaultColor.SetWindowTint( PARENT_WINDOW.."WarbandHoverFrame", DefaultColor.TEAL )

    EA_Window_OpenPartyManage.UpdateWarband()
    EA_Window_OpenPartyManage.UpdateSettings()
    
end

local function EnableShowCheckBoxes( enable )
    for partyIndex = 1, PartyUtils.PARTIES_PER_WARBAND
    do
        local partyWindowCheckBox = GetPartyWindowName(partyIndex).."Show"
        ButtonSetDisabledFlag( partyWindowCheckBox, not enable )
    end
end

function EA_Window_OpenPartyManage.FormWarband()
    if( ButtonGetDisabledFlag( PARENT_WINDOW.."ConvertToWarbandButton" ) )
    then
        return
    end

    SendChatText( L"/warbandconvert", L"" )
end

local function UpdateFormWarbandButtonState()
    local warbandActive = IsWarBandActive()
    WindowSetShowing( PARENT_WINDOW.."ConvertToWarband", not warbandActive )
    ButtonSetDisabledFlag( PARENT_WINDOW.."ConvertToWarbandButton", not GameData.Player.isGroupLeader )
end

function EA_Window_OpenPartyManage.OnShown()
    EA_Window_OpenPartyManage.UpdateWarband()
end

local function IsManageTabHidden()
    return (not WindowGetShowing( "EA_Window_OpenParty" ) or not WindowGetShowing( "EA_Window_OpenPartyManage" ))
end

function EA_Window_OpenPartyManage.SingleMemberUpdate( partyIndex, memberIndex )
    if IsManageTabHidden()
    then
        return
    end
    
    local member = PartyUtils.GetWarbandMember( partyIndex, memberIndex )

    if( member == nil )
    then
        return
    end
    
    local rowWindow = GetRowWindowName( partyIndex, memberIndex )
    if( member.online )
    then
        LabelSetTextColor( rowWindow.."Name", 255, 255, 255 )
    else
        LabelSetTextColor( rowWindow.."Name", 100, 100, 100 )
    end
end

function EA_Window_OpenPartyManage.UpdateWarband()
    if IsManageTabHidden()
    then
        return
    end

    local warbandActive = IsWarBandActive()
    EnableShowCheckBoxes( warbandActive )
    UpdateFormWarbandButtonState()
    if( warbandActive )
    then
        WindowSetFontAlpha( PARENT_WINDOW.."Warband", 1.0 )
    else
        WindowSetFontAlpha( PARENT_WINDOW.."Warband", 0.4 )
    end

    -- put warband data in to global table for list box population
    EA_Window_OpenPartyManage.warbandParties = PartyUtils.GetWarbandData()

    for index = 1, PartyUtils.PARTIES_PER_WARBAND
    do
        EA_Window_OpenPartyManage.UpdateWarbandParty( index )
    end
    
    EA_Window_OpenPartyManage.UpdateMasterLooterList()
    EA_Window_OpenPartyManage.UpdateSettings()
end

function EA_Window_OpenPartyManage.UpdateParty()
    if IsManageTabHidden()
    then
        return
    end

    EA_Window_OpenPartyManage.UpdateMasterLooterList()
    EA_Window_OpenPartyManage.UpdateSettings()
    UpdateFormWarbandButtonState()
end

function EA_Window_OpenPartyManage.UpdateWarbandParty( partyIndex )
    local party = PartyUtils.GetWarbandParty( partyIndex )
    local displayOrder = {}
    for index, member in ipairs( party.players )
    do
        -- Generate the row ids for this group's rows so that we can quickly and easily determine which row is which.
        local rowWindow = GetRowWindowName( partyIndex, index )
        WindowSetId( rowWindow, GetRowId( partyIndex, index ) )
        table.insert( displayOrder, index )

        -- Add career icon to the table...
        member.careerIcon = Icons.GetCareerIconIDFromCareerLine( member.careerLine )
    end

    ListBoxSetDisplayOrder( GetPartyWindowName(partyIndex).."List", displayOrder )
end

local function WarbandPartyPopulator( partyIndex, populatorIndices )
    if( populatorIndices == nil )
    then
        return
    end

    for rowIndex, dataIndex in ipairs( populatorIndices )
    do
        local member = PartyUtils.GetWarbandMember( partyIndex, dataIndex )
        local windowName = GetRowWindowName( partyIndex, dataIndex )
        if( member == nil )
        then
            continue
        end
        WindowSetShowing( windowName.."GroupLeaderIcon", member.isGroupLeader )
        WindowSetShowing( windowName.."GroupAssistantIcon", member.isAssistant and not member.isGroupLeader )
        WindowSetShowing( windowName.."MainAssistIcon", member.isMainAssist )
        WindowSetShowing( windowName.."MasterLooterIcon", member.isMasterLooter )
        
        if( member.online )
        then
            LabelSetTextColor( windowName.."Name", 255, 255, 255 )
        else
            LabelSetTextColor( windowName.."Name", 100, 100, 100 )
        end
    end
end

function EA_Window_OpenPartyManage.PopulateParty1()
    WarbandPartyPopulator( 1, EA_Window_OpenPartyManageWarband1List.PopulatorIndices )
end
function EA_Window_OpenPartyManage.PopulateParty2()
    WarbandPartyPopulator( 2, EA_Window_OpenPartyManageWarband2List.PopulatorIndices )
end
function EA_Window_OpenPartyManage.PopulateParty3()
    WarbandPartyPopulator( 3, EA_Window_OpenPartyManageWarband3List.PopulatorIndices )
end
function EA_Window_OpenPartyManage.PopulateParty4()
    WarbandPartyPopulator( 4, EA_Window_OpenPartyManageWarband4List.PopulatorIndices )
end


function EA_Window_OpenPartyManage.ToggleWarbandVisibility()
    if( BattlegroupHUD )
    then
        BattlegroupHUD.Update()
    end
end

--------------------------------------------------------------------------------
-- PARTY SETTINGS FUNCTIONS
--------------------------------------------------------------------------------

function EA_Window_OpenPartyManage.UpdateSettings()

    -- Adding 1 is necessary because GameData.Player.Group.Settings.lootMode is needlessly incremented by the client
    local masterLooterIsActive = GameData.Player.Group.Settings.lootMode == (GameData.LootModes.MASTER_LOOT + 1)
    
    -- NEED ON USE
    ButtonSetPressedFlag( PARENT_WINDOW.."NeedOnUseButtonButton", GameData.Player.Group.Settings.noNeedOnGreed )
    ButtonSetDisabledFlag( PARENT_WINDOW.."NeedOnUseButtonButton", masterLooterIsActive or GameData.Player.isGroupLeader == false )

    -- AUTO LOOT IN RVR
    ButtonSetPressedFlag( PARENT_WINDOW.."AutoLootRvRButton", GameData.Player.Group.Settings.autoLootInRvR )
    ButtonSetDisabledFlag( PARENT_WINDOW.."AutoLootRvRButton", masterLooterIsActive or GameData.Player.isGroupLeader == false )

        
    -- LOOT MODE
    ComboBoxSetSelectedMenuItem( PARENT_WINDOW.."LootModeCombo", GameData.Player.Group.Settings.lootMode )
    ComboBoxSetDisabledFlag( PARENT_WINDOW.."LootModeCombo", GameData.Player.isGroupLeader == false )
    
    -- LOOT THRESHOLD
    local disableThreshold = GameData.Player.Group.Settings.autoLootInRvR or GameData.Player.isGroupLeader == false
    disableThreshold = ((GameData.Player.isGroupLeader == true) and (GameData.Player.Group.Settings.lootMode == 3)) == false
    ComboBoxSetSelectedMenuItem( PARENT_WINDOW.."LootThresholdCombo", GameData.Player.Group.Settings.lootThreshold )
    ComboBoxSetDisabledFlag( PARENT_WINDOW.."LootThresholdCombo", disableThreshold )
    
    -- MASTER LOOTER
    local disableMasterCombo = not masterLooterIsActive
    ComboBoxSetDisabledFlag( PARENT_WINDOW.."MasterLooterCombo", disableMasterCombo or GameData.Player.isGroupLeader == false )
    if( GameData.Player.Group.Settings.isMasterLooter ~= nil )
    then
        for index, isMasterLooter in ipairs( GameData.Player.Group.Settings.isMasterLooter )
        do
            if( isMasterLooter )
            then
                ComboBoxSetSelectedMenuItem( PARENT_WINDOW.."MasterLooterCombo", index )
                break
            end
        end
    end
end

function EA_Window_OpenPartyManage.ToggleNeedOnUse()
    if( not ButtonGetDisabledFlag( PARENT_WINDOW.."NeedOnUseButtonButton" ) )
    then
        local isPressed = ButtonGetPressedFlag( PARENT_WINDOW.."NeedOnUseButtonButton" )
        SetGroupNeedMode( not isPressed )
        ButtonSetPressedFlag( PARENT_WINDOW.."NeedOnUseButtonButton", not isPressed )
    end
end

function EA_Window_OpenPartyManage.OnMouseoverNeedOnUse()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )

    Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_NEED_ON_USE_SETTING ) )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )

    Tooltips.SetTooltipText( 2, 1, GetString( StringTables.Default.TEXT_NEED_ON_USE_DESC ) )
    Tooltips.SetTooltipColorDef( 2, 1, Tooltips.COLOR_BODY )

    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end

function EA_Window_OpenPartyManage.ToggleAutoLootRvR()
    if( not ButtonGetDisabledFlag( PARENT_WINDOW.."AutoLootRvRButton" ) )
    then
        local isPressed = ButtonGetPressedFlag( PARENT_WINDOW.."AutoLootRvRButton" )
        SetGroupAutoLootInRvR( not isPressed )
        ButtonSetPressedFlag( PARENT_WINDOW.."AutoLootRvRButton", not isPressed )
    end
end

function EA_Window_OpenPartyManage.OnMouseoverAutoLootRvR()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )

    Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_AUTO_LOOT_RVR_SETTING ) )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )

    Tooltips.SetTooltipText( 2, 1, GetString( StringTables.Default.TEXT_AUTO_LOOT_RVR_DESC ) )
    Tooltips.SetTooltipColorDef( 2, 1, Tooltips.COLOR_BODY )

    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end



function EA_Window_OpenPartyManage.OnLootModeSelChange( newMode )
    SetGroupLootMode( newMode )
end

function EA_Window_OpenPartyManage.OnMouseoverLootModeCombo()
    local txtColumn = Tooltips.COLUMN_RIGHT_LEFT_ALIGN

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )

    local row = 1
    local text = GetString( StringTables.Default.LABEL_CURRENT_LOOT_MODE )
    Tooltips.SetTooltipText( 1, 1, text)
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    row = row + 1

    local text =  GetString( StringTables.Default.TEXT_LOOT_MODE_DESC )
    Tooltips.SetTooltipText( row, 1, text)
    Tooltips.SetTooltipColorDef( row, 1, Tooltips.COLOR_BODY )
    row = row + 1

    local type = GetString( StringTables.Default.LABEL_LOOT_ROUND_ROBIN )..L":   "
    local text =  GetString( StringTables.Default.TEXT_LOOT_ROUND_ROBIN_DESC )
    Tooltips.SetTooltipText( row, 1, type)
    Tooltips.SetTooltipColorDef( row, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( row, txtColumn, text)
    Tooltips.SetTooltipColorDef( row, txtColumn, Tooltips.COLOR_BODY )
    row = row + 1

    local type = GetString( StringTables.Default.LABEL_LOOT_FFA )..L":   "
    local text = GetString( StringTables.Default.TEXT_LOOT_FFA_DESC )
    Tooltips.SetTooltipText( row, 1, type)
    Tooltips.SetTooltipColorDef( row, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( row, txtColumn, text)
    Tooltips.SetTooltipColorDef( row, txtColumn, Tooltips.COLOR_BODY )
    row = row + 1

    local type = GetString( StringTables.Default.LABEL_LOOT_MASTER_LOOT )..L":   "
    local text = GetString( StringTables.Default.TEXT_LOOT_MASTER_LOOT_DESC )
    Tooltips.SetTooltipText( row, 1, type)
    Tooltips.SetTooltipColorDef( row, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( row, txtColumn, text)
    Tooltips.SetTooltipColorDef( row, txtColumn, Tooltips.COLOR_BODY )
    row = row + 1

    -- Show action text when the player cannot change the loot options
    if( GameData.Player.isGroupLeader == false ) then
        local actiontext = GetString( StringTables.Default.TEXT_CHANGE_LOOT_OPTIONS )
        Tooltips.SetTooltipActionText( actiontext )
    end

    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end

function EA_Window_OpenPartyManage.OnLootThresholdSelChange( newThreshold )
    SetGroupLootThreshold( newThreshold )
end

function EA_Window_OpenPartyManage.OnMouseoverLootThresholdCombo()

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )

    local text = GetString( StringTables.Default.LABEL_CURRENT_LOOT_THRESHOLD )
    Tooltips.SetTooltipText( 1, 1, text)
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )

    local text =  GetString( StringTables.Default.TEXT_LOOT_THRESHOLD_DESC )
    Tooltips.SetTooltipText( 2, 1, text)
    Tooltips.SetTooltipColorDef( 2, 1, Tooltips.COLOR_BODY )

    -- Show action text when the player cannot change the loot options
    if( GameData.Player.isGroupLeader == false ) then
        local actiontext = GetString( StringTables.Default.TEXT_CHANGE_LOOT_OPTIONS )
        Tooltips.SetTooltipActionText( actiontext )
    end

    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )

end

function EA_Window_OpenPartyManage.OnMasterLooterSelChange( newMasterLooter )
    if( newMasterLooter <= 0 )
    then
        return
    end
    SystemData.UserInput.selectedGroupMember = ComboBoxGetSelectedText( PARENT_WINDOW.."MasterLooterCombo" )
    PartyUtils.SetMasterLooter()
end

function EA_Window_OpenPartyManage.UpdateMasterLooterList()
    ComboBoxClearMenuItems( PARENT_WINDOW.."MasterLooterCombo" )
    if( not IsWarBandActive() )
    then
        ComboBoxAddMenuItem( PARENT_WINDOW.."MasterLooterCombo", GameData.Player.name )
        for index = 1, PartyUtils.PLAYERS_PER_PARTY_WITHOUT_LOCAL
        do
            if( PartyUtils.IsPartyMemberValid( index ) )
            then
                ComboBoxAddMenuItem( PARENT_WINDOW.."MasterLooterCombo", PartyUtils.GetPartyMember( index ).name )
            end
        end
    else
        local warband = PartyUtils.GetWarbandData()
        for groupIndex, group in ipairs( warband )
        do
            for memberIndex, member in ipairs( group.players )
            do
                ComboBoxAddMenuItem( PARENT_WINDOW.."MasterLooterCombo", member.name )
            end
        end
    end
end

--------------------------------------------------------------------------------
-- CONTEXT MENU FUNCTIONS AND CALLBACKS
--------------------------------------------------------------------------------
function EA_Window_OpenPartyManage.ShowWarbandMemberMenu( member )

    SystemData.UserInput.selectedGroupMember = member.name

    -- Build the Custom Section of the Player Menu
    local customMenuItems = {}

    -- Show the "Make Leader" option if the player is a group leader
    if( GameData.Player.isGroupLeader )
    then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_MAKE_LEADER ), PartyUtils.SetWarbandLeader, member.isGroupLeader or not member.online ) )
        if( member.isAssistant )
        then
            table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_DEMOTE_ASSISTANT ), PartyUtils.DemoteWarbandAssistant, member.isGroupLeader or not member.online ) )
        else
            table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_MAKE_ASSISTANT ), PartyUtils.SetWarbandAssistant, member.isGroupLeader or not member.online ) )
        end
    end

    -- Main Assist
    local mainAssistMember = PartyUtils.GetWarbandMainAssist()
    if( GameData.Player.isGroupLeader or ( mainAssistMember ~= nil and WStringsCompareIgnoreGrammer( mainAssistMember.name, GameData.Player.name ) == 0 ) )
    then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_MAKE_MAIN_ASSIST ), PartyUtils.SetMainAssist, member.isMainAssist or not member.online ) )
    end

    -- Master looter
    local masterLootSet = GameData.Player.Group.Settings.lootMode == (GameData.LootModes.MASTER_LOOT + 1)
    if( GameData.Player.isGroupLeader and masterLootSet ) then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_MAKE_MASTER_LOOTER ), PartyUtils.SetMasterLooter, member.isMasterLooter or not member.online ) )
    end

     -- Create the Menu
    PlayerMenuWindow.ShowMenu( member.name, 0, customMenuItems )

end

--------------------------------------------------------------------------------
-- WARBAND MEMBER ROW EVENT HANDLERS
--------------------------------------------------------------------------------

function EA_Window_OpenPartyManage.OnRButtonUpPlayerRow()
    local rowId = WindowGetId( SystemData.MouseOverWindow.name )
    local partyIndex = GetPartyByRowId( rowId )
    local memberIndex = GetRowIndexByRowId( rowId )
    local member = PartyUtils.GetWarbandMember( partyIndex, memberIndex )
    if( member )
    then
        EA_Window_OpenPartyManage.ShowWarbandMemberMenu( member )
    end
end

--------------------------------------------------------------------------------
-- DRAGGING FUNCTIONS
--------------------------------------------------------------------------------

local function ShowMouseOverHoverFrame( hoverPartyIndex )
    local rowId = WindowGetId( draggedWindow )
    local partyIndex = GetPartyByRowId( rowId )
    if( partyIndex == hoverPartyIndex )
    then
        WindowSetShowing( PARENT_WINDOW.."WarbandHoverFrame", false )
        return
    end

    WindowClearAnchors( PARENT_WINDOW.."WarbandHoverFrame" )
    WindowAddAnchor( PARENT_WINDOW.."WarbandHoverFrame", "topleft", SystemData.MouseOverWindow.name, "topleft", 0, 0 )
    WindowAddAnchor( PARENT_WINDOW.."WarbandHoverFrame", "bottomright", SystemData.MouseOverWindow.name, "bottomright", 0, 0 )

    WindowSetShowing( PARENT_WINDOW.."WarbandHoverFrame", true )
end

function EA_Window_OpenPartyManage.OnMouseOverWarbandListBox()
    if( draggedWindow == nil )
    then
        WindowSetShowing( PARENT_WINDOW.."WarbandHoverFrame", false )
        return
    end
    
    local newPartyIndex = GetPartyIndexByWindowName( SystemData.MouseOverWindow.name )
    ShowMouseOverHoverFrame( newPartyIndex )
end

function EA_Window_OpenPartyManage.OnMouseOverPlayerRow()
    if( draggedWindow == nil )
    then
        WindowSetShowing( PARENT_WINDOW.."WarbandHoverFrame", false )
        return
    end
    
    local newRowId = GetRowIdByWindowName( SystemData.MouseOverWindow.name )
    local newPartyIndex = GetPartyByRowId( newRowId )
    ShowMouseOverHoverFrame( newPartyIndex )
end

function EA_Window_OpenPartyManage.OnMouseOverEndWarbandListBox()
    WindowSetShowing( PARENT_WINDOW.."WarbandHoverFrame", false )
end

function EA_Window_OpenPartyManage.OnLButtonDownPlayerRow()
    if( GameData.Player.isGroupLeader == false and GameData.Player.isWarbandAssistant == false )
    then
        return
    end
    
    -- We can sometimes get a mouse down trigger on this window with
    -- SystemData.MouseOverWindow.name set to Root due to the game not having focus
    if( not string.find( SystemData.MouseOverWindow.name, PARENT_WINDOW.."Warband" ) )
    then
        return
    end
    
    draggedWindow = SystemData.MouseOverWindow.name
end

function EA_Window_OpenPartyManage.OnMouseOverEndPlayerRow()
    if( draggedWindow == nil )
    then
        return
    end

    local rowId = WindowGetId( draggedWindow )
    local partyIndex = GetPartyByRowId( rowId )
    local memberIndex = GetRowIndexByRowId( rowId )
    local member = EA_Window_OpenPartyManage.warbandParties[partyIndex].players[memberIndex]
    if( member == nil )
    then
        draggedWindow = nil
        return
    end

    LabelSetText( PARENT_WINDOW.."DragWindowName", member.name )
    LabelSetText( PARENT_WINDOW.."DragWindowRank", towstring(member.level) )
    local texture, x, y = GetIconData( member.careerIcon )
    DynamicImageSetTexture( PARENT_WINDOW.."DragWindowCareerIcon", texture, x, y )
    WindowSetShowing( PARENT_WINDOW.."DragWindowGroupLeaderIcon", member.isGroupLeader )
    WindowSetShowing( PARENT_WINDOW.."DragWindowMainAssistIcon", member.isMainAssist )
    WindowSetShowing( PARENT_WINDOW.."DragWindowMasterLooterIcon", member.isMasterLooter )

    WindowClearAnchors( PARENT_WINDOW.."DragWindow" )
    local anchor = { Point = "topleft", RelativeTo = "CursorWindow", RelativePoint = "topleft", XOffset = 0, YOffset = 0 }
    WindowAddAnchor( PARENT_WINDOW.."DragWindow", anchor.Point, anchor.RelativeTo, anchor.RelativePoint, anchor.XOffset, anchor.YOffset )
    WindowSetShowing( PARENT_WINDOW.."DragWindow", true )
    WindowSetShowing( PARENT_WINDOW.."WarbandHoverFrame", false )
end

function EA_Window_OpenPartyManage.OnLButtonUpProcessed()
    if( draggedWindow == nil )
    then
        return
    end

    local rowId = WindowGetId( draggedWindow )
    local partyIndex = GetPartyByRowId( rowId )
    local memberIndex = GetRowIndexByRowId( rowId )
    local member = PartyUtils.GetWarbandMember( partyIndex, memberIndex )

    if(     member ~= nil
        and string.find( SystemData.MouseOverWindow.name, PARENT_WINDOW.."Warband" )
        and string.find( SystemData.MouseOverWindow.name, "List" )
        and draggedWindow ~= SystemData.MouseOverWindow.name )
    then
        if( string.find( SystemData.MouseOverWindow.name, "Row" ) )
        then
            local newRowId = GetRowIdByWindowName( SystemData.MouseOverWindow.name )
            local newPartyIndex = GetPartyByRowId( newRowId )
            local newMemberIndex = GetRowIndexByRowId( newRowId )
            local memberToSwap = PartyUtils.GetWarbandMember( newPartyIndex, newMemberIndex )
            if( memberToSwap ~= nil and partyIndex ~= newPartyIndex )
            then
                PartyUtils.SwapWarbandMembers( member.name, memberToSwap.name )
            end
        else
            -- didn't drop on another player, move to this party
            local newPartyIndex = GetPartyIndexByWindowName( SystemData.MouseOverWindow.name )
            if( partyIndex ~= newPartyIndex )
            then
                PartyUtils.MoveWarbandMember( member.name, newPartyIndex )
            end
        end
    end

    WindowClearAnchors( PARENT_WINDOW.."DragWindow" )
    WindowSetShowing( PARENT_WINDOW.."DragWindow", false )
    WindowSetShowing( PARENT_WINDOW.."WarbandHoverFrame", false )
    draggedWindow = nil
end

