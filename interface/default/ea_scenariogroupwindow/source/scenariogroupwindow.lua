
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

ScenarioGroupWindow = {}

----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

ScenarioGroupWindow.GroupWindowSettings     = {}
ScenarioGroupWindow.GroupSlotVisibility     = {}
ScenarioGroupWindow.GroupSlotReservedStatus = {}
ScenarioGroupWindow.UngroupedPlayerData     = {}
ScenarioGroupWindow.playerGroupData         = {}
ScenarioGroupWindow.playerGroupDataMap      = {}
ScenarioGroupWindow.slotReservationData     = {}
ScenarioGroupWindow.MAX_SCENARIO_GROUPS     = 6
ScenarioGroupWindow.MAX_GROUP_MEMBERS       = 6
ScenarioGroupWindow.NumUngroupedPlayers     = 0
ScenarioGroupWindow.GroupJoined             = 0
ScenarioGroupWindow.IsInScenarioGroup       = false

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local LeaveGroupButtonAnchorPosition = { Point = "topleft", relativePoint = "topleft", XOffset = 0, YOffset = 0 }

local LocalPlayerIsMainAssist = false

----------------------------------------------------------------
-- ScenarioGroupWindow Local Functions
----------------------------------------------------------------

local function GetMemberFromWindowId( windowId )

    local groupIndex = math.ceil( windowId / ScenarioGroupWindow.MAX_GROUP_MEMBERS )
    local memberIndex = windowId - ( (groupIndex - 1) * ScenarioGroupWindow.MAX_GROUP_MEMBERS )
    
    if( ScenarioGroupWindow.playerGroupDataMap[groupIndex] == nil )
    then
        return nil
    end
    
    return ScenarioGroupWindow.playerGroupData[ ScenarioGroupWindow.playerGroupDataMap[groupIndex][memberIndex] ]
    
end

-- Filters the scenario players list for ungrouped players
local function FilterUngroupedPlayersList()	
    
    ScenarioGroupWindow.UngroupedPlayerData = {}
    
    if( ScenarioGroupWindow.playerGroupData ~= nil ) then
            
        for index, player in ipairs( ScenarioGroupWindow.playerGroupData ) do
            if( player.sgroupindex == 0 ) then
                table.insert( ScenarioGroupWindow.UngroupedPlayerData, index )
            end
        end
        
    end
    
end


-- Updates the ungrouped players list
local function UpdateUngroupedPlayersList()

    FilterUngroupedPlayersList()
    ListBoxSetDisplayOrder( "UngroupedPlayersWindowList", ScenarioGroupWindow.UngroupedPlayerData )
    
end

local function UpdateSingleMemberHitPoints( memberWindow, player )

    LabelSetText( memberWindow.."LabelHealth", player.health..L"%" )
    local isDead = false    
    
    if( player.health == 100 ) then
        BattlegroupHUD.AdjustStatusSettings( memberWindow, DefaultColor.HEALTH_TEXT_FULL, 0.5, false )
    elseif( player.health < 100 and player.health > 0 ) then
        BattlegroupHUD.AdjustStatusSettings( memberWindow, DefaultColor.HEALTH_TEXT_NOT_FULL, 1.0, true )
    else
        BattlegroupHUD.AdjustStatusSettings( memberWindow, DefaultColor.HEALTH_TEXT_NOT_FULL, 1.0, true )
        isDead = true
    end
    
    -- TODO: determine if player is actually dead or out of range, and display death icon
    -- Set the current health/AP values
    StatusBarSetCurrentValue( memberWindow.."HPBar", player.health )
    
    if( isDead )
    then
        StatusBarSetCurrentValue( memberWindow.."APBar", 0 ) 
    else
        StatusBarSetCurrentValue( memberWindow.."APBar", player.ap ) 
    end
        
end


local function UpdateSingleMemberWindow( memberWindow, player )

    LabelSetText( memberWindow.."LabelName", player.name )
    
    local texture, x, y = GetIconData( Icons.GetCareerIconIDFromCareerNamesID( player.careerId ) )
    DynamicImageSetTexture( memberWindow.."CareerIcon", texture, x, y )
    
    WindowSetGameActionData( memberWindow, GameData.PlayerActions.SET_TARGET, 0, player.name )
    
    UpdateSingleMemberHitPoints( memberWindow, player )
end


-- Updates player data as group information is received from the server
local function UpdatePlayerData()

    -- Set all group member slots to inactive
    ScenarioGroupWindow.FlagGroupSlotsInactive()
    
    -- Get the scenario group data from the client
    ScenarioGroupWindow.playerGroupData = GameData.GetScenarioPlayerGroups()
    
    -- Since we got new group data, clear the map
    ScenarioGroupWindow.playerGroupDataMap = {}
        
    -- Update the ungrouped players window list
    UpdateUngroupedPlayersList()
        
    if( ScenarioGroupWindow.playerGroupData ~= nil ) then
        
        for index, player in ipairs( ScenarioGroupWindow.playerGroupData ) do	
                        
            if( player.sgroupindex > 0 ) then
                
                local groupIndex = player.sgroupindex
                local groupSlotNum = player.sgroupslotnum
                
                -- Update the map
                if( ScenarioGroupWindow.playerGroupDataMap[groupIndex] == nil )
                then
                    ScenarioGroupWindow.playerGroupDataMap[groupIndex] = {}
                end
                ScenarioGroupWindow.playerGroupDataMap[groupIndex][groupSlotNum] = index

                -- Set member's window data, and show the window
                local memberWindow = "ScenarioGroupWindowGroup"..groupIndex.."MembersMember"..groupSlotNum
                UpdateSingleMemberWindow( memberWindow, player )
                WindowSetShowing( memberWindow, true )
                WindowSetShowing( "ScenarioGroupWindowGroup"..groupIndex.."MemberStatus"..groupSlotNum, false )

                -- And again for the floating version
                memberWindow = "FloatingScenarioGroup"..groupIndex.."WindowMember"..groupSlotNum
                UpdateSingleMemberWindow( memberWindow, player )
                WindowSetShowing( memberWindow, true )

                -- Update the active flag
                if( ScenarioGroupWindow.GroupSlotVisibility ~= nil ) then
                    ScenarioGroupWindow.GroupSlotVisibility[groupIndex][groupSlotNum] = true
                end
                
            end
            
        end
    end
    
    -- Hide any inactive group slots
    ScenarioGroupWindow.HideInactiveSlots()
    
    -- Sometimes the update message gets processed once more after a scenario ends, so force this window
    -- to close if the player isn't in a scenario
    if( not GameData.Player.isInScenario and not GameData.Player.isInSiege ) then
        ScenarioGroupWindow.OnScenarioEnd()
    end
    
end

-- Updates the group slots in the UI to indicate which slots are reserved
local function UpdateGroupReservations()

    -- Clear all reservation flags before beginning the update
    ScenarioGroupWindow.GroupSlotReservedStatus = {}
    
    if( ScenarioGroupWindow.GroupSlotReservedStatus ~= nil ) then                        
        for index = 1, ScenarioGroupWindow.MAX_SCENARIO_GROUPS do  
                               
            ScenarioGroupWindow.GroupSlotReservedStatus[index] = {}
            
            for slot = 1, ScenarioGroupWindow.MAX_GROUP_MEMBERS do
                ScenarioGroupWindow.GroupSlotReservedStatus[index][slot] = 0             
                ScenarioGroupWindow.GroupSlotReservedStatus[index][slot] = false
            end
            
        end                
    end
    
    -- Get the scenario group slot reservation data from the client
    ScenarioGroupWindow.slotReservationData = GameData.GetScenarioGroupReservations()
        
    if( ScenarioGroupWindow.slotReservationData ~= nil ) then
                
        for index, slot in ipairs( ScenarioGroupWindow.slotReservationData ) do
                                        
            local groupIndex = slot.sgroupindex
            local groupSlotNum = slot.sgroupslotnum
            
            -- Update the reservation flag
            if( ScenarioGroupWindow.GroupSlotReservedStatus ~= nil ) then
                ScenarioGroupWindow.GroupSlotReservedStatus[groupIndex][groupSlotNum] = true
            end
            
        end
        
    end
    
    -- Now call to update the player list, since it will call the appropriate functionality
    -- to update the group windows as needed
    UpdatePlayerData()
end

-- Removes and sets up event handlers for the windows inherited from the battlegroup hud
local function InitializeEventHandlers( memberWindow, floating )
    -- We inherited these member windows from the battlegroup, so remove the event handlers...
    WindowUnregisterCoreEventHandler( memberWindow, "OnLButtonUp" )
    WindowUnregisterCoreEventHandler( memberWindow, "OnRButtonUp" )
    WindowUnregisterCoreEventHandler( memberWindow.."CareerIcon", "OnMouseOver" )
    
    -- Now add our own
    WindowRegisterCoreEventHandler( memberWindow.."CareerIcon", "OnMouseOver", "ScenarioGroupWindow.OnMouseOverCareerIcon" )
    if( floating )
    then
        WindowRegisterCoreEventHandler( memberWindow, "OnLButtonUp", "ScenarioGroupWindow.SelectGroupMember" )
        WindowRegisterCoreEventHandler( memberWindow, "OnRButtonUp", "ScenarioGroupWindow.OnRButtonUp" )
    end
end


----------------------------------------------------------------
-- ScenarioGroupWindow Global Functions
----------------------------------------------------------------


-- OnInitialize Handler
function ScenarioGroupWindow.Initialize()
    
    -- Register Events
    WindowRegisterEventHandler( "ScenarioGroupWindow", SystemData.Events.SCENARIO_PLAYERS_LIST_GROUPS_UPDATED, "ScenarioGroupWindow.OnPlayerListGroupsUpdated")
    WindowRegisterEventHandler( "ScenarioGroupWindow", SystemData.Events.SCENARIO_PLAYERS_LIST_RESERVATIONS_UPDATED, "ScenarioGroupWindow.OnScenarioGroupReservationsUpdated")
    WindowRegisterEventHandler( "ScenarioGroupWindow", SystemData.Events.SCENARIO_BEGIN, "ScenarioGroupWindow.OnScenarioBegin")
    WindowRegisterEventHandler( "ScenarioGroupWindow", SystemData.Events.CITY_SCENARIO_BEGIN, "ScenarioGroupWindow.OnScenarioBegin")
    WindowRegisterEventHandler( "ScenarioGroupWindow", SystemData.Events.SCENARIO_END, "ScenarioGroupWindow.OnScenarioEnd")
    WindowRegisterEventHandler( "ScenarioGroupWindow", SystemData.Events.CITY_SCENARIO_END, "ScenarioGroupWindow.OnScenarioEnd")
    WindowRegisterEventHandler( "ScenarioGroupWindow", SystemData.Events.SCENARIO_GROUP_JOIN, "ScenarioGroupWindow.OnScenarioGroupJoin")
    WindowRegisterEventHandler( "ScenarioGroupWindow", SystemData.Events.SCENARIO_GROUP_LEAVE, "ScenarioGroupWindow.OnScenarioGroupLeave")
    WindowRegisterEventHandler( "ScenarioGroupWindow", SystemData.Events.PLAYER_MAIN_ASSIST_UPDATED, "ScenarioGroupWindow.UpdateMainAssist")
    WindowRegisterEventHandler( "ScenarioGroupWindow", SystemData.Events.SCENARIO_PLAYER_HITS_UPDATED, "ScenarioGroupWindow.OnUpdatePlayerHits")
    
    -- Setup the localized text strings where required
    LabelSetText( "ScenarioGroupWindowTitleBarText", GetString( StringTables.Default.LABEL_SCENARIO_GROUPS ) )
        
    ButtonSetText( "ScenarioGroupWindowLeaveButton", GetString( StringTables.Default.LABEL_SCENARIO_GROUP_LEAVE ) )
    ButtonSetText( "ScenarioGroupWindowBottomBarBigClose", GetString( StringTables.Default.LABEL_CLOSE ) )
    ButtonSetText( "ScenarioGroupWindowBottomBarClaimMainAssist", GetString( StringTables.Default.LABEL_CLAIM_MAIN_ASSIST ) )
    ButtonSetText( "ScenarioGroupWindowBottomBarUngroupedLauncher", GetString( StringTables.Default.LABEL_SCENARIO_GROUP_VIEW_UNGROUPED ) )    
    
    WindowSetShowing( "ScenarioGroupWindowLeaveButton", false )
    
    ButtonSetCheckButtonFlag( "ScenarioGroupWindowMiddleBarGroupToggleButton", true )
    LabelSetText( "ScenarioGroupWindowMiddleBarGroupToggleButtonText", GetString( StringTables.Default.LABEL_SCENARIO_SHOW_MAIN_PARTY ) )
    -- Set default checked state
    local pressed = ScenarioGroupWindow.GroupWindowSettings.showMainGroup
    if( pressed == nil )
    then
        pressed = true
    end
    ButtonSetPressedFlag( "ScenarioGroupWindowMiddleBarGroupToggleButton", pressed )
    ScenarioGroupWindow.GroupWindowSettings.showMainGroup = pressed
    
    -- Do basic setup on each group's window elements   
    local uniqueMemberID = 1;
    for index = 1, ScenarioGroupWindow.MAX_SCENARIO_GROUPS do
        ButtonSetCheckButtonFlag( "ScenarioGroupWindowGroup"..index.."VisibleButton", true )
    
        -- Turn off the mini free-floating group windows    
        CreateWindow( "FloatingScenarioGroup"..index.."Window", false )
        -- No leaders in a scenario...
        WindowSetShowing("FloatingScenarioGroup"..index.."WindowGroupLeaderIcon", false )
        WindowSetShowing("ScenarioGroupWindowGroup"..index.."MembersGroupLeaderIcon", false )
        
        -- No main assists in the floating scenario groups for the moment
        WindowSetShowing( "FloatingScenarioGroup"..index.."WindowMainAssistIcon", false )
        WindowSetShowing( "ScenarioGroupWindowGroup"..index.."MembersMainAssistIcon", false )
        
        -- Setup UI info for individual group member windows
        for member = 1, ScenarioGroupWindow.MAX_GROUP_MEMBERS do    
            WindowSetShowing( "ScenarioGroupWindowGroup"..index.."MemberStatus"..member, false )
            local memberWindow ="ScenarioGroupWindowGroup"..index.."MembersMember"..member
            WindowSetId( memberWindow, uniqueMemberID )
            StatusBarSetMaximumValue( memberWindow.."HPBar", 100 )
            StatusBarSetMaximumValue( memberWindow.."APBar", 100 )
            WindowSetShowing( memberWindow.."DeathIcon", false )
            InitializeEventHandlers( memberWindow )
            
              
            memberWindow ="FloatingScenarioGroup"..index.."WindowMember"..member
            WindowSetId( memberWindow, uniqueMemberID )
            StatusBarSetMaximumValue( memberWindow.."HPBar", 100 )
            StatusBarSetMaximumValue( memberWindow.."APBar", 100 )
            WindowSetShowing( memberWindow.."DeathIcon", false )
            InitializeEventHandlers( memberWindow, true )
            
            uniqueMemberID = uniqueMemberID + 1
        end
        
        -- Add text to the join buttons
        ButtonSetText( "ScenarioGroupWindowJoinGroup"..index, GetString( StringTables.Default.LABEL_SCENARIO_GROUP_JOIN ) )
        
        -- Set each little group window's name
        LabelSetText( "ScenarioGroupWindowGroup"..index.."Name", GetString( StringTables.Default.LABEL_SCENARIO_GROUP_GROUP )..L" "..index )
        
        -- Set the IDs of each group window
        WindowSetId( "ScenarioGroupWindowGroup"..index.."Name", index )
        WindowSetId( "ScenarioGroupWindowGroup"..index.."NameBG", index )
        WindowSetId( "ScenarioGroupWindowGroup"..index.."VisibleButton", index )
        
        WindowSetId( "FloatingScenarioGroup"..index.."Window", index )
        
        if( ScenarioGroupWindow.GroupWindowSettings.floatingVisibility == nil )
        then
            ScenarioGroupWindow.GroupWindowSettings.floatingVisibility = {}
        end
        local pressed = ScenarioGroupWindow.GroupWindowSettings.floatingVisibility[index] or false
        ButtonSetPressedFlag( "ScenarioGroupWindowGroup"..index.."VisibleButton", pressed )
        
        -- Register the window for layout editor
        LayoutEditor.RegisterWindow( "FloatingScenarioGroup"..index.."Window",
            GetFormatStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_SP_MEMBERS_NAME, { index } ),
            GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_SP_MEMBERS_DESC),
            false, false,
            true, nil )
    end
    
    -- Create the ungrouped players window and hide it
    CreateWindow( "UngroupedPlayersWindow", false )
    WindowSetShowing( "UngroupedPlayersWindow", false )
    LabelSetText( "UngroupedPlayersWindowTitleBarText", GetString( StringTables.Default.LABEL_SCENARIO_GROUP_UNGROUPED_PLAYERS ) )
    ScenarioGroupWindow.SetListRowTints()
    
    CreateWindowFromTemplate( "ScenarioGroupSetOpacityWindow", "ScenarioGroupSetOpacityWindow", "Root" )
    WindowSetShowing( "ScenarioGroupSetOpacityWindow", false )
    LabelSetText( "ScenarioGroupSetOpacityWindowTitleBarText", GetString( StringTables.Default.LABEL_OPACITY ) )
    -- Restore saved background alpha setting
    if( ScenarioGroupWindow.GroupWindowSettings.backgroundAlpha )
    then
        ScenarioGroupWindow.SetBackgroundAlpha( ScenarioGroupWindow.GroupWindowSettings.backgroundAlpha )
    end
    
    -- Flag scenarios as not started
    ScenarioGroupWindow.IsInScenarioGroup = false
    
    -- Force an update on player data  
    UpdateGroupReservations()  
    UpdatePlayerData()
    ScenarioGroupWindow.UpdateMainAssist( nil, nil )
    
end

-- Update everything that has to do with the main assist, this is only needed to be done when the main assist changes
-- Arguments are used only from the c event update. Calls from Lua should send nil as arguments, since Lua should not udpate these values.
function ScenarioGroupWindow.UpdateMainAssist( playerIsMA, validMainAssist )

    -- Pull the data from c, cause this needs to be updated before we check for main assist 
    ScenarioGroupWindow.playerGroupData = GameData.GetScenarioPlayerGroups()
    if( ScenarioGroupWindow.playerGroupData ~= nil ) then
        local groupIndexOfMainAssist = -1
        for index, player in ipairs( ScenarioGroupWindow.playerGroupData ) do	
            if( player.sgroupindex > 0 ) then
                
                local groupIndex = player.sgroupindex
                local groupSlotNum = player.sgroupslotnum
               
                if( player.isMainAssist )
                then
                    groupIndexOfMainAssist = groupIndex
                    local memberWindow = "FloatingScenarioGroup"..groupIndex.."WindowMember"..groupSlotNum
                    WindowClearAnchors( "FloatingScenarioGroup"..groupIndex.."WindowMainAssistIcon" )
                    WindowAddAnchor( "FloatingScenarioGroup"..groupIndex.."WindowMainAssistIcon", "right", memberWindow, "center", 0, 0 )
                    
                    if( playerIsMA ~= nil )
                    then
                        LocalPlayerIsMainAssist = playerIsMA;
                    elseif ( WStringsCompareIgnoreGrammer( player.name, GameData.Player.name ) == 0 )
                    then
                        LocalPlayerIsMainAssist = true
                    else
                        LocalPlayerIsMainAssist = false
                    end
                end
            end
        end
        
        -- If we have a known main assist update the crown, else hide the crown
        if( groupIndexOfMainAssist ~= -1 )
        then
            WindowSetShowing("FloatingScenarioGroup"..groupIndexOfMainAssist.."WindowMainAssistIcon", true )
        else
            for groupIndex = 1, ScenarioGroupWindow.MAX_SCENARIO_GROUPS
            do
                WindowSetShowing("FloatingScenarioGroup"..groupIndex.."WindowMainAssistIcon", false )
            end
        end
        
        -- If we have a main assist (known or not) or we are not in a scenario group,
        -- disable the claim main assist button, else enable it 
        if( groupIndexOfMainAssist ~= -1 or validMainAssist == true or not ScenarioGroupWindow.IsInScenarioGroup )
        then
            ButtonSetDisabledFlag( "ScenarioGroupWindowBottomBarClaimMainAssist", true )
        else
            ButtonSetDisabledFlag( "ScenarioGroupWindowBottomBarClaimMainAssist", false )
        end
    end
end

-- Scenario Group Update Handler
function ScenarioGroupWindow.OnPlayerListGroupsUpdated()
    UpdatePlayerData()
end

function ScenarioGroupWindow.OnUpdatePlayerHits( groupIndex, groupSlotNum, hits )

    if( ScenarioGroupWindow.playerGroupData == nil ) 
    then 
        return 
    end
    
    local groupData = ScenarioGroupWindow.playerGroupDataMap[groupIndex]
    if( groupData == nil ) 
    then 
        return 
    end   
    
    local playerIndex = groupData[groupSlotNum]
    if( playerIndex == nil )
    then
        return
    end
    
    local player = ScenarioGroupWindow.playerGroupData[ playerIndex ]
    player.health = hits
        
    -- Main Window
    if( WindowGetShowing( "ScenarioGroupWindowGroup"..groupIndex ) )
    then
        local memberWindow = "ScenarioGroupWindowGroup"..groupIndex.."MembersMember"..groupSlotNum
        UpdateSingleMemberHitPoints( memberWindow, player )
    end

    -- HUD Overlay
    if( WindowGetShowing( "FloatingScenarioGroup"..groupIndex.."Window" ) )
    then
        local memberWindow = "FloatingScenarioGroup"..groupIndex.."WindowMember"..groupSlotNum
        UpdateSingleMemberHitPoints( memberWindow, player )
    end
end

-- Scenario Group Reservations Update Handler
function ScenarioGroupWindow.OnScenarioGroupReservationsUpdated()
    UpdateGroupReservations()
end


-- Scenario Begin Handler
function ScenarioGroupWindow.OnScenarioBegin()
    
    -- Show the window when a scenario begins to give players the option to choose groups at startup
    if( GameData.Player.isInScenario or GameData.Player.isInSiege ) then
        if( ScenarioGroupWindow.IsInScenarioGroup == false ) then
            ScenarioGroupWindow.HideLeaveGroupElements()
            WindowSetShowing( "ScenarioGroupWindow", true )
        end
        
        for index = 1, ScenarioGroupWindow.MAX_SCENARIO_GROUPS
        do
            if ( ButtonGetPressedFlag( "ScenarioGroupWindowGroup"..index.."VisibleButton" ) )
            then
                LayoutEditor.Show( "FloatingScenarioGroup"..index.."Window" )
            else
                LayoutEditor.Hide( "FloatingScenarioGroup"..index.."Window" )
            end
        end
    end
    
end


-- Scenario End Handler
function ScenarioGroupWindow.OnScenarioEnd()
    
    -- Hide this window and clear all data when the player is no longer in a scenario
    ScenarioGroupWindow.FlagGroupSlotsInactive()
    ScenarioGroupWindow.HideInactiveSlots()
    ScenarioGroupWindow.IsInScenarioGroup = false
    ScenarioGroupWindow.HideLeaveGroupElements()
    WindowSetShowing( "ScenarioGroupWindow", false )
        
    for index = 1, ScenarioGroupWindow.MAX_SCENARIO_GROUPS
    do
        LayoutEditor.Hide( "FloatingScenarioGroup"..index.."Window" )
    end
    
end


-- Scenario Group Join Handler
function ScenarioGroupWindow.OnScenarioGroupJoin( groupIndex )
    
    if( GameData.Player.isInScenario or GameData.Player.isInSiege ) then
        ScenarioGroupWindow.IsInScenarioGroup = true
        ScenarioGroupWindow.GroupJoined = groupIndex
        ScenarioGroupWindow.HideJoinGroupElements()
        
        ScenarioGroupWindow.UpdateMainAssist( nil, nil )
    end

end


-- Scenario Group Leave Handler
function ScenarioGroupWindow.OnScenarioGroupLeave()
    
    if( GameData.Player.isInScenario or GameData.Player.isInSiege ) then
        ScenarioGroupWindow.IsInScenarioGroup = false
        ScenarioGroupWindow.GroupJoined = 0
        ScenarioGroupWindow.HideLeaveGroupElements()
        
        ScenarioGroupWindow.UpdateMainAssist( nil, nil )
    end

end


-- Sets all group member windows to flagged inactive
function ScenarioGroupWindow.FlagGroupSlotsInactive()

    ScenarioGroupWindow.GroupSlotVisibility = {}
    
    if( ScenarioGroupWindow.GroupSlotVisibility ~= nil ) then                        
        for index = 1, ScenarioGroupWindow.MAX_SCENARIO_GROUPS do  
                               
            ScenarioGroupWindow.GroupSlotVisibility[index] = {}
            
            for slot = 1, ScenarioGroupWindow.MAX_GROUP_MEMBERS do
                ScenarioGroupWindow.GroupSlotVisibility[index][slot] = 0             
                ScenarioGroupWindow.GroupSlotVisibility[index][slot] = false
            end
            
        end                
    end

end


-- Loops through the slot visibility array and hides inactive member windows
function ScenarioGroupWindow.HideInactiveSlots()

    if( ScenarioGroupWindow.GroupSlotVisibility ~= nil ) then           
        for index = 1, ScenarioGroupWindow.MAX_SCENARIO_GROUPS do     
                   
            for slot = 1, ScenarioGroupWindow.MAX_GROUP_MEMBERS do                  
                if( ScenarioGroupWindow.GroupSlotVisibility[index][slot] == false ) then    
                    
                    -- See if this slot is reserved, if so, show the reserved status, otherwise,
                    -- just show the available status    
                    local bReserved = false                
                    if( ScenarioGroupWindow.GroupSlotReservedStatus ~= nil ) then
                        if( ScenarioGroupWindow.GroupSlotReservedStatus[index][slot] == true ) then
                            bReserved = true
                            LabelSetText( "ScenarioGroupWindowGroup"..index.."MemberStatus"..slot.."Label", GetString( StringTables.Default.LABEL_SCENARIO_GROUP_RESERVED ) )
                            LabelSetTextColor( "ScenarioGroupWindowGroup"..index.."MemberStatus"..slot.."Label", DefaultColor.Reserved.r, DefaultColor.Reserved.g, DefaultColor.Reserved.b )
                        end
                    end
                    
                    if( bReserved == false ) then
                        LabelSetText( "ScenarioGroupWindowGroup"..index.."MemberStatus"..slot.."Label", GetString( StringTables.Default.LABEL_SCENARIO_GROUP_AVAILABLE ) )
                        LabelSetTextColor( "ScenarioGroupWindowGroup"..index.."MemberStatus"..slot.."Label", DefaultColor.Available.r, DefaultColor.Available.g, DefaultColor.Available.b )
                    end
                    
                    WindowSetShowing( "ScenarioGroupWindowGroup"..index.."MemberStatus"..slot, true )                    
                    WindowSetShowing( "ScenarioGroupWindowGroup"..index.."MembersMember"..slot, false )
                    WindowSetShowing( "FloatingScenarioGroup"..index.."WindowMember"..slot, false )
                    
                else
                    
                    -- Clear any text that used to be in the member's status label
                    LabelSetText( "ScenarioGroupWindowGroup"..index.."MemberStatus"..slot.."Label", L"" )
                    
                end                
            end
            
        end                
    end

end


-- Hide Handler
function ScenarioGroupWindow.Hide()
    WindowSetShowing( "ScenarioGroupWindow", false )   
end


-- Hide Handler for the Ungrouped Players Window
function ScenarioGroupWindow.HideUngroupedPlayersWindow()
    WindowSetShowing( "UngroupedPlayersWindow", false ) 
end


-- Hides the Join Group UI Elements and Shows the Leave Group UI Elements
function ScenarioGroupWindow.HideJoinGroupElements()

    local strInstructions = GetStringFormat( StringTables.Default.LABEL_SCENARIO_GROUPS_CHAT_INSTRUCTIONS, { ScenarioGroupWindow.GroupJoined } )                                      
                                       
    LabelSetText( "ScenarioGroupWindowMiddleBarInstructions", strInstructions )
    
    for index = 1, ScenarioGroupWindow.MAX_SCENARIO_GROUPS do
        WindowSetShowing( "ScenarioGroupWindowJoinGroup"..index, true )
        
        ButtonSetDisabledFlag( "ScenarioGroupWindowJoinGroup"..index, true )
    end
    
    if( ScenarioGroupWindow.GroupJoined > 0 ) then
        local toggleButtonWindowName = "ScenarioGroupWindowGroup"..ScenarioGroupWindow.GroupJoined.."VisibleButton"
        local joinButtonWindowName = "ScenarioGroupWindowJoinGroup"..ScenarioGroupWindow.GroupJoined
        
        WindowClearAnchors( "ScenarioGroupWindowLeaveButton" )
        WindowAddAnchor ( "ScenarioGroupWindowLeaveButton", LeaveGroupButtonAnchorPosition.Point, joinButtonWindowName, LeaveGroupButtonAnchorPosition.relativePoint, LeaveGroupButtonAnchorPosition.XOffset, LeaveGroupButtonAnchorPosition.YOffset)
        WindowSetShowing( "ScenarioGroupWindowLeaveButton", true )
        
        WindowSetShowing( joinButtonWindowName, false )
    else
        -- Not in a group, hide the leave button by default!
        WindowSetShowing( "ScenarioGroupWindowLeaveButton", false )
    end
    
end


-- Hides the Leave Group UI Elements and Shows the Join Group UI Elements
function ScenarioGroupWindow.HideLeaveGroupElements()

    LabelSetText( "ScenarioGroupWindowMiddleBarInstructions", GetString( StringTables.Default.LABEL_SCENARIO_GROUPS_JOIN_INSTRUCTIONS ) )
    
    for index = 1, ScenarioGroupWindow.MAX_SCENARIO_GROUPS do
        WindowSetShowing( "ScenarioGroupWindowJoinGroup"..index, true )
                
        local toggleButtonWindowName = "ScenarioGroupWindowGroup"..index.."VisibleButton"
        WindowSetShowing( toggleButtonWindowName, true )
        
        ButtonSetDisabledFlag( "ScenarioGroupWindowJoinGroup"..index, false )
    end
    
    WindowSetShowing( "ScenarioGroupWindowLeaveButton", false )    
    
end


-- Join Group Button Handler
function ScenarioGroupWindow.JoinGroup()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == false ) then  
        local selGroupIndex = WindowGetId( SystemData.ActiveWindow.name )
        JoinScenarioGroup( selGroupIndex )        
        ScenarioGroupWindow.GroupJoined = selGroupIndex
        ScenarioGroupWindow.HideJoinGroupElements()  
    end
    
end


-- Leave Group Button Handler
function ScenarioGroupWindow.LeaveGroup()
  
    LeaveScenarioGroup()
    ScenarioGroupWindow.GroupJoined = 0
    ScenarioGroupWindow.HideLeaveGroupElements() 
    
end


-- MouseOver Handler for Join Group Buttons
function ScenarioGroupWindow.OnJoinGroupMouseOver()

    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == false ) then
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil ) 
        
        windowId = WindowGetId( SystemData.ActiveWindow.name )
        
        local row = 1
        local column = 1
        local strPartyJoinText = GetString(StringTables.Default.LABEL_SCENARIO_GROUP_JOIN)..L" "..GetString(StringTables.Default.LABEL_SCENARIO_GROUP_GROUP)..L" "..windowId
        Tooltips.SetTooltipText( row, column, strPartyJoinText )
        
        Tooltips.Finalize()
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
    end

end


-- MouseOver Handler for Leave Group Button
function ScenarioGroupWindow.OnLeaveGroupMouseOver()

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil ) 
        
    local row = 1
    local column = 1
    local strPartyLeaveText = GetString(StringTables.Default.LABEL_SCENARIO_GROUP_LEAVE)..L" "..GetString(StringTables.Default.LABEL_SCENARIO_GROUP_GROUP)..L" "..ScenarioGroupWindow.GroupJoined
    Tooltips.SetTooltipText( row, column, strPartyLeaveText )
    
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)

end


-- MouseOver Handler for Visibility Check Buttons
function ScenarioGroupWindow.OnMouseoverVisibleButton()

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil ) 
    
    local row = 1
    local column = 1
    Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.LABEL_SCENARIO_GROUP_TOGGLE_VISIBILITY ) )
    
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
    
end


-- LButtonDown Handler for Toggling Visibility on the Check Buttons
function ScenarioGroupWindow.ToggleVisibility()

    local index = WindowGetId( SystemData.ActiveWindow.name )

    local isPressed = ButtonGetPressedFlag( "ScenarioGroupWindowGroup"..index.."VisibleButton" )
    if ( isPressed )
    then
        LayoutEditor.Show( "FloatingScenarioGroup"..index.."Window" )
    else
        LayoutEditor.Hide( "FloatingScenarioGroup"..index.."Window" )
    end

    -- Save visibility settings
    if( not ScenarioGroupWindow.GroupWindowSettings.floatingVisibility )
    then
        ScenarioGroupWindow.GroupWindowSettings.floatingVisibility = {}
    end
    ScenarioGroupWindow.GroupWindowSettings.floatingVisibility[index] = isPressed
end

function ScenarioGroupWindow.ToggleMainGroupVisibility()

    local isPressed = ButtonGetPressedFlag( "ScenarioGroupWindowMiddleBarGroupToggleButton" )
    ScenarioGroupWindow.GroupWindowSettings.showMainGroup = isPressed
    
    GroupWindow.ConditionalShow()
    
    -- Move floating windows when this toggle happens
    if( not isPressed and DoesWindowExist( "PlayerWindow" ) )
    then
    
        WindowClearAnchors( "FloatingScenarioGroup1Window" )
        WindowAddAnchor( "FloatingScenarioGroup1Window", "bottomleft", "PlayerWindow", "topleft", 0, 60 )
        
    elseif( isPressed and DoesWindowExist( "GroupWindow" ) )
    then
    
        WindowClearAnchors( "FloatingScenarioGroup1Window" )
        WindowAddAnchor( "FloatingScenarioGroup1Window", "topright", "GroupWindow", "topleft", 0, 12 )
        
    end
    
    WindowClearAnchors( "FloatingScenarioGroup2Window" )
    WindowAddAnchor( "FloatingScenarioGroup2Window", "bottomleft", "FloatingScenarioGroup1Window", "topleft", 0, 15 )
    
    WindowClearAnchors( "FloatingScenarioGroup3Window" )
    WindowAddAnchor( "FloatingScenarioGroup3Window", "topright", "FloatingScenarioGroup1Window", "topleft", 5, 0 )
    
    WindowClearAnchors( "FloatingScenarioGroup4Window" )
    WindowAddAnchor( "FloatingScenarioGroup4Window", "bottomleft", "FloatingScenarioGroup3Window", "topleft", 0, 15 )
    
    WindowClearAnchors( "FloatingScenarioGroup5Window" )
    WindowAddAnchor( "FloatingScenarioGroup5Window", "topright", "FloatingScenarioGroup3Window", "topleft", 5, 0 )
    
    WindowClearAnchors( "FloatingScenarioGroup6Window" )
    WindowAddAnchor( "FloatingScenarioGroup6Window", "bottomleft", "FloatingScenarioGroup5Window", "topleft", 0, 15 )
    
end

-- LButtonDown Handler for Selecting a Group Member
function ScenarioGroupWindow.SelectGroupMember()
    -- Targeting is handled by the WindowSetGameActionData() call.    
end


-- LButtonDown Handler for the Lone Wolves Display Button
function ScenarioGroupWindow.ShowUngroupedPlayers()

    ScenarioGroupWindow.UpdateUngroupedPlayerRow()
    if( WindowGetShowing( "UngroupedPlayersWindow" ) ) then
        WindowSetShowing( "UngroupedPlayersWindow", false )
    else        
        WindowSetShowing( "UngroupedPlayersWindow", true )
    end

end

-- Push this button to claim main assist status, only possible if no one is assigned as main assist already
function ScenarioGroupWindow.ClaimMainAssist()
    SystemData.UserInput.selectedGroupMember = GameData.Player.name
    BroadcastEvent( SystemData.Events.GROUP_SET_MAIN_ASSIST )
end


-- Sets up the tinted rows on the Ungrouped Players Window
function ScenarioGroupWindow.SetListRowTints()
	local targetRowWindow = L""

    for row = 1, UngroupedPlayersWindowList.numVisibleRows do
        local row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        targetRowWindow = "UngroupedPlayersWindowListRow"..row.."BackgroundName"
        DefaultColor.SetWindowTint( targetRowWindow, DefaultColor.GetRowColor( row ) )
    end
end


-- Dummy LButtonUp handler for the scrollbars to stop them from
-- failing to handle for lack of a LUA script event handler
function ScenarioGroupWindow.OnVertScrollLButtonUp()

    -- Not really needed for this particular window
    
end


-- Updates a Single Row of Ungrouped Player Data
function ScenarioGroupWindow.UpdateUngroupedPlayerRow()
    
    -- Not really needed for this particular window
    
end

function ScenarioGroupWindow.OnMouseOverCareerIcon()

    local member = GetMemberFromWindowId( WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) ) )

    if ( member == nil ) then
        return
    end

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, member.name )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, GetStringFormat( StringTables.Default.LABEL_RANK_X, { member.rank } ) )
    Tooltips.SetTooltipText( 3, 1, GetStringFormatFromTable("HUDStrings", StringTables.HUD.LABEL_HUD_PLAYER_WINDOW_TOOLTIP_CAREER_NAME, {member.career}) )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_VARIABLE )
end


function ScenarioGroupWindow.OnRButtonUp()

    -- Remember the window clicked on, so we know where to pop the opacity slider
    ScenarioGroupWindow.contextMenuOpenedFrom = SystemData.ActiveWindow.name
    
    EA_Window_ContextMenu.CreateContextMenu( SystemData.ActiveWindow.name )
    
    -- If the local player is main assist, give the option to re-assign it
    if( LocalPlayerIsMainAssist )
    then
        local member = GetMemberFromWindowId( WindowGetId( SystemData.ActiveWindow.name ) )
        SystemData.UserInput.selectedGroupMember = member.name
        local disableMainAssist = ( WStringsCompareIgnoreGrammer( member.name, GameData.Player.name ) == 0 )
        EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_MAKE_MAIN_ASSIST ), BattlegroupHUD.OnMenuClickMakeMainAssist, disableMainAssist, true )
    end
    
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_SET_OPACITY ), ScenarioGroupWindow.OnMenuClickSetBackgroundOpacity, false, true )
    EA_Window_ContextMenu.Finalize()
end

function ScenarioGroupWindow.OnMenuClickSetBackgroundOpacity()

    if( not ScenarioGroupWindow.contextMenuOpenedFrom )
    then
        return
    end

    local alpha = WindowGetAlpha( ScenarioGroupWindow.contextMenuOpenedFrom.."Background" )
    SliderBarSetCurrentPosition( "ScenarioGroupSetOpacityWindowSlider", alpha )

    -- Anchor the slider to the right of the clicked on member window
    WindowClearAnchors( "ScenarioGroupSetOpacityWindow" )
    WindowAddAnchor( "ScenarioGroupSetOpacityWindow", "right", ScenarioGroupWindow.contextMenuOpenedFrom, "left", 0, 0 )

    WindowSetShowing( "ScenarioGroupSetOpacityWindow", true )
end

function ScenarioGroupWindow.OnOpacitySlide( slidePos )
    ScenarioGroupWindow.GroupWindowSettings.backgroundAlpha = slidePos
    ScenarioGroupWindow.SetBackgroundAlpha( slidePos )
end

function ScenarioGroupWindow.SetBackgroundAlpha( alpha )

    for index = 1, ScenarioGroupWindow.MAX_SCENARIO_GROUPS
    do
        for member = 1, ScenarioGroupWindow.MAX_GROUP_MEMBERS
        do
            local memberWindow ="FloatingScenarioGroup"..index.."WindowMember"..member
            WindowSetAlpha( memberWindow.."Background", alpha )
        end
    end

end

function ScenarioGroupWindow.CloseSetOpacityWindow()
    WindowSetShowing( "ScenarioGroupSetOpacityWindow", false )
end

