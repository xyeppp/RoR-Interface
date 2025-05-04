----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

GroupWindow = {}
--[[
-- Some debug group population code
for index = 1, 5, 1 do
    GameData.Player.Group[index].name = L"Groupiehasname"..index
    GameData.Player.Group[index].healthPercent = 100        --math.random(1,100)
    GameData.Player.Group[index].actionPointPercent = 100   --math.random(1,100)
    GameData.Player.Group[index].moraleLevel = 0        --math.random(1,4)
    GameData.Player.Group[index].level = 5                  --math.random(1,40)
end
--]]

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
GroupWindow.MAX_GROUP_MEMBERS = 5
GroupWindow.MAX_WARBAND_MEMBERS = 24
GroupWindow.PLAYER_WINDOW_SIZE = { x=335, y=60 }
GroupWindow.Buffs = {}
GroupWindow.hitPointAlerts = {}

GroupWindow.groupMembersAnchors = {}
GroupWindow.groupMembers = {}
GroupWindow.groupPets = {}

GroupWindow.curPlayer = { name=L"", objNum=0 }

GroupWindow.inScenarioGroup = false
GroupWindow.inWorldGroup = false

local c_GROUP_MEMBER = "GroupMember"
local c_GROUP_PET = "GroupPet"
local prevMoraleLevel =
{
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0
}
local MoraleLevelSliceMap =
{
    [1]  = { slice = "Morale-Mini-1" },
    [2]  = { slice = "Morale-Mini-2" },
    [3]  = { slice = "Morale-Mini-3" },
    [4]  = { slice = "Morale-Mini-4" }
}

GroupWindow.CONTAINER_WINDOW = "GroupWindow"

----------------------------------------------------------------
-- GroupWindow Functions
----------------------------------------------------------------

function GroupWindow.Initialize()

    -- Register this window for movement with the Layout Editor
    LayoutEditor.RegisterWindow( GroupWindow.CONTAINER_WINDOW,  
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PARTY_MEMBERS_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PARTY_MEMBERS_DESC ),
                                false, false,
                                true, nil )

    -- Register events
    RegisterEventHandler( SystemData.Events.GROUP_UPDATED, "GroupWindow.OnGroupUpdated")
    RegisterEventHandler( SystemData.Events.BATTLEGROUP_UPDATED, "GroupWindow.OnGroupUpdated")
    RegisterEventHandler( SystemData.Events.GROUP_STATUS_UPDATED, "GroupWindow.OnStatusUpdated")
    RegisterEventHandler( SystemData.Events.GROUP_EFFECTS_UPDATED, "GroupWindow.OnEffectsUpdated")
    RegisterEventHandler( SystemData.Events.GROUP_PLAYER_ADDED, "GroupWindow.OnGroupPlayerAdded")
    RegisterEventHandler( SystemData.Events.SCENARIO_BEGIN, "GroupWindow.OnScenarioBegin")
    RegisterEventHandler( SystemData.Events.CITY_SCENARIO_BEGIN, "GroupWindow.OnScenarioBegin")
    RegisterEventHandler( SystemData.Events.SCENARIO_END, "GroupWindow.OnScenarioEnd")
    RegisterEventHandler( SystemData.Events.CITY_SCENARIO_END, "GroupWindow.OnScenarioEnd")
    RegisterEventHandler( SystemData.Events.SCENARIO_GROUP_JOIN, "GroupWindow.OnScenarioGroupJoin")
    RegisterEventHandler( SystemData.Events.SCENARIO_GROUP_LEAVE, "GroupWindow.OnScenarioGroupLeave")
    
    -- Initialize the Group Window
    for index = 1, GroupWindow.MAX_GROUP_MEMBERS do
        GroupWindow.hitPointAlerts[index] = false        
    end    
    
    GroupWindow.OnGroupUpdated()
end

function GroupWindow.OnContainerWindowHidden()
    for _, buffs in pairs( GroupWindow.Buffs )
    do
        buffs:ClearAllBuffs()
    end
end

-- Scenario Begin Handler
function GroupWindow.OnScenarioBegin()
        
    -- Hide the default group window while in a scenario (or city scenario) and not in a scenario group
    if( GameData.Player.isInScenario or GameData.Player.isInSiege ) then
        if( GroupWindow.inScenarioGroup == false ) then
            for index = 1, GroupWindow.MAX_GROUP_MEMBERS do
                if (GroupWindow.IsMemberValid(index) == true) then
                    GroupWindow.groupMembers[index]:Show (false)
                end
            end
        end
    end
    
end

-- Scenario End Handler
function GroupWindow.OnScenarioEnd()
        
    -- When a scenario ends, force a group window to hide until the next group update
    -- passes through from the server
    GroupWindow.inScenarioGroup = false
    
    for index = 1, GroupWindow.MAX_GROUP_MEMBERS do
        if (GroupWindow.IsMemberValid(index) == true) then
            GroupWindow.groupMembers[index]:Show (false)
        end
    end
    GroupWindow.UpdateGroupMembers()
end

-- Scenario Group Join Handler
function GroupWindow.OnScenarioGroupJoin()
    
    if( GameData.Player.isInScenario or GameData.Player.isInSiege ) then
        GroupWindow.inScenarioGroup = true
        GroupWindow.UpdateGroupMembers()
    end

end

-- Scenario Group Leave Handler
function GroupWindow.OnScenarioGroupLeave()
    
    if( GameData.Player.isInScenario or GameData.Player.isInSiege ) then
        GroupWindow.inScenarioGroup = false
        GroupWindow.UpdateGroupMembers()
    end

end

-- Update all available Group Member Windows with the correct anchor, as well as hide/show windows as needed.
-- Function will only Populate the Group Member information if parameter is set to 'true'
function GroupWindow.PositionGroupMemberWindows ( shouldPopulate )
    for index = 1, GroupWindow.MAX_GROUP_MEMBERS do
        if ( GroupWindow.IsMemberValid(index) ) then
            -- New Player create the new window
            if (GroupWindow.groupMembers[index] == nil ) then
                GroupWindow.groupMembers[index] = UnitFrames:CreateNewFrame("GroupWindowPlayer"..index, UnitFrames.UNITFRAME_GROUP_MEMBER, c_GROUP_MEMBER..index)
                GroupWindow.groupMembers[index]:SetParent( GroupWindow.CONTAINER_WINDOW )
                GroupWindow.groupMembers[index]:SetScale( WindowGetScale( GroupWindow.CONTAINER_WINDOW ) )
            end
            -- Reposition the anchors so that it doesn't conflict with pet or buff windows.
            if (index == 1) then
                GroupWindow.groupMembers[index]:SetAnchor( {Point = "topleft", RelativePoint = "topleft", RelativeTo = GroupWindow.CONTAINER_WINDOW, XOffset = 0, YOffset = 3} )
            else
                local prevIndex = index - 1
                if (GroupWindow.groupData[prevIndex].Pet.healthPercent ~= 0) then
                    GroupWindow.groupMembers[index]:SetAnchor( {Point = "bottomleft", RelativePoint = "topleft", RelativeTo = "GroupWindowPlayer"..prevIndex.."PortraitFrame", XOffset = 0, YOffset = 32} )
                else
                    GroupWindow.groupMembers[index]:SetAnchor( {Point = "bottomleft", RelativePoint = "topleft", RelativeTo = "GroupWindowPlayer"..prevIndex.."PortraitFrame", XOffset = 0, YOffset = 3} )
                end
            end

            -- If this player has an active pet, create a frame for its information
            if (GroupWindow.groupData[index].Pet.healthPercent ~= nil and 
                    GroupWindow.groupData[index].Pet.healthPercent ~= 0) then
                if ( DoesWindowExist("GroupWindowPet"..index) == false ) then
                    GroupWindow.groupPets[index] = UnitFrames:CreateNewFrame("GroupWindowPet"..index, UnitFrames.UNITFRAME_GROUP_PET, c_GROUP_PET..index)
                    GroupWindow.groupPets[index]:SetParent( GroupWindow.CONTAINER_WINDOW )
                    GroupWindow.groupPets[index]:SetScale( WindowGetScale( GroupWindow.CONTAINER_WINDOW ) )
                end
                GroupWindow.groupPets[index]:SetPetPortrait()
                GroupWindow.groupPets[index]:SetAnchor( {Point = "bottomright", RelativePoint = "topleft", RelativeTo = "GroupWindowPlayer"..index.."PortraitFrame", XOffset = -42, YOffset = -18} )
            else 
                if ( DoesWindowExist("GroupWindowPet"..index) == true) then
                    GroupWindow.groupPets[index]:Show (false)
                end
            end
            
            if (shouldPopulate == true) then
                GroupWindow.PopulateGroupMemberWindow(index)
            end
        else
            -- Player does not exist, however they could've left the group check to see if we need to hide windows
            if (DoesWindowExist("GroupWindowPlayer"..index) == true) then
                GroupWindow.groupMembers[index]:Show (false)
            end
            if (DoesWindowExist("GroupWindowPet"..index) == true) then
                GroupWindow.groupPets[index]:Show (false)
            end
        end
    end
    
    --WindowResizeOnChildren( GroupWindow.CONTAINER_WINDOW, false, 0 )
end

function GroupWindow.PopulateGroupMemberWindow( groupIndex )
    local member = GroupWindow.groupData[groupIndex]
    if (member.Pet.healthPercent ~= nil and 
            member.Pet.healthPercent ~= 0) then
        GroupWindow.groupPets[groupIndex]:UpdateHealth(member.Pet.healthPercent)
        GroupWindow.groupPets[groupIndex]:Show (true)
    end
    -- Populate all of the data
    GroupWindow.groupMembers[groupIndex]:SetName(member.name)
    GroupWindow.groupMembers[groupIndex]:UpdateLevel( member.level, member.battleLevel )
    GroupWindow.groupMembers[groupIndex]:UpdateHealth(member.healthPercent)
    GroupWindow.groupMembers[groupIndex]:UpdateActionPoints(member.actionPointPercent)
    GroupWindow.groupMembers[groupIndex]:UpdateRVRFlag(member.isRVRFlagged)
    GroupWindow.groupMembers[groupIndex]:UpdateInSameRegion(member.isInSameRegion, member.healthPercent, member.online)
    GroupWindow.groupMembers[groupIndex]:UpdateOnlineStatus(member.online)
    GroupWindow.groupMembers[groupIndex]:UpdateDistantStatus(member.isDistant)
    
    
    WindowSetShowing("GroupWindowPlayer"..groupIndex.."GroupLeaderCrown", member.isGroupLeader == true)
    
    WindowSetShowing("GroupWindowPlayer"..groupIndex.."MainAssistCrown", member.isMainAssist == true)
    
    -- If the morale level has changed, handle showing/hiding the window and
    -- displaying the appropriate texture slice for morale
    if( prevMoraleLevel[groupIndex] ~= member.moraleLevel and member.moraleLevel ~= 0 ) then  
            DynamicImageSetTextureSlice( "GroupWindowPlayer"..groupIndex.."MoraleMini", MoraleLevelSliceMap[member.moraleLevel].slice )
            WindowSetShowing( "GroupWindowPlayer"..groupIndex.."MoraleMini", true )
    elseif( morale == 0) then
        -- Don't show the morale mini if there are no unlocked abilities
        if( WindowGetShowing("GroupWindowPlayer"..groupIndex.."MoraleMini") == true ) then
            WindowSetShowing( "GroupWindowPlayer"..groupIndex.."MoraleMini", false )
        end
    end
    
    -- Cache the determined morale level
    prevMoraleLevel[groupIndex] = member.moraleLevel;
    
    GroupWindow.groupMembers[groupIndex]:Show(true)
end

function GroupWindow.UpdateGroupMembers()
    if ( GroupWindow.groupData == nil ) 
    then
        return
    end

    -- If there is a valid group member in index 1, then we should show the GroupWindow
    GroupWindow.inWorldGroup = GroupWindow.IsMemberValid( 1 )
    
    -- Position & Populate the Group Member Windows
    GroupWindow.PositionGroupMemberWindows(true)
    
    -- If the player is in a scenario, but not in a group, hide the window
    if( GameData.Player.isInScenario or GameData.Player.isInSiege ) 
    then
        if( GroupWindow.inScenarioGroup == false ) 
        then
            GroupWindow.inWorldGroup = false
        end
    end
        
    for index = 1, GroupWindow.MAX_GROUP_MEMBERS
    do
        local isValid = GroupWindow.IsMemberValid(index)
        if ( isValid )
        then
            GroupWindow.groupMembers[index]:Show (not IsWarBandActive())
            GroupWindow.groupMembers[index]:SetCareerIcon( GroupWindow.groupData[index].careerLine )
            GroupWindow.groupMembers[index]:ShowCareerIcon( isValid and not IsWarBandActive())
            
            if not GroupWindow.groupMembers[index]:IsShowing() or not WindowGetShowing( GroupWindow.CONTAINER_WINDOW )
            then
                GroupWindow.Buffs[index]:ClearAllBuffs()
            else
                GroupWindow.Buffs[index]:Refresh()
            end
        end
    end
  
end

function GroupWindow.UpdateMemberStatus( groupMemberIndex )
    if ( GroupWindow.groupData == nil ) then
        return
    end
    
    local player = PartyUtils.GetPartyMember( groupMemberIndex )
    
    if( player ) then

       GroupWindow.PositionGroupMemberWindows(false)
       
       if (DoesWindowExist ("GroupWindowPet"..groupMemberIndex.."HealthPercentBar") and WindowGetShowing ("GroupWindowPet"..groupMemberIndex.."HealthPercentBar") ) then
            GroupWindow.groupPets[groupMemberIndex]:UpdateHealth( player.Pet.healthPercent )
       end

        GroupWindow.groupMembers[groupMemberIndex]:UpdateHealth( player.healthPercent )
        GroupWindow.groupMembers[groupMemberIndex]:UpdateLevel( player.level, player.battleLevel )
        GroupWindow.groupMembers[groupMemberIndex]:UpdateActionPoints( player.actionPointPercent )
		GroupWindow.groupMembers[groupMemberIndex]:UpdateInSameRegion( player.isInSameRegion, player.healthPercent, player.online )
        GroupWindow.groupMembers[groupMemberIndex]:UpdateRVRFlag( player.isRVRFlagged )
        GroupWindow.groupMembers[groupMemberIndex]:UpdateOnlineStatus( player.online )
        GroupWindow.groupMembers[groupMemberIndex]:UpdateDistantStatus( player.isDistant )
        
        -- If the morale level has changed, handle showing/hiding the window and
        -- displaying the appropriate texture slice for morale
        if( prevMoraleLevel[groupMemberIndex] ~= player.moraleLevel and player.moraleLevel ~= 0 ) then
                DynamicImageSetTextureSlice( "GroupWindowPlayer"..groupMemberIndex.."MoraleMini", MoraleLevelSliceMap[player.moraleLevel].slice )
                WindowSetShowing( "GroupWindowPlayer"..groupMemberIndex.."MoraleMini", true )
        elseif( player.moraleLevel == 0) then
            -- Don't show the morale mini if there are no unlocked abilities
            if( WindowGetShowing("GroupWindowPlayer"..groupMemberIndex.."MoraleMini") == true ) then
                WindowSetShowing( "GroupWindowPlayer"..groupMemberIndex.."MoraleMini", false )
            end
        end
        
        -- Cache the determined morale level
        prevMoraleLevel[groupMemberIndex] = morale;
    end
end

function GroupWindow.OnEffectsUpdated( updateType, updatedEffects, isFullList )
    if ( updateType < GameData.BuffTargetType.GROUP_MEMBER_START or
         updateType > GameData.BuffTargetType.GROUP_MEMBER_END )
    then
        DEBUG( L"GroupWindow.OnEffectsUpdated - Received invalid updateType ("..updateType..L")." )
        return
    end

    local memberIndex = updateType - GameData.BuffTargetType.GROUP_MEMBER_START + 1
    
    -- Clear out buffs when the unit frame is not showing
    if not GroupWindow.groupMembers[memberIndex]:IsShowing() or not WindowGetShowing( GroupWindow.CONTAINER_WINDOW )
    then
        updatedEffects = {}
        isFullList = true
    end
    
    GroupWindow.Buffs[ memberIndex ]:UpdateBuffs( updatedEffects, isFullList )
end

function GroupWindow.ShowMenu( playerName, isOffline )
    SystemData.UserInput.selectedGroupMember = playerName
    
    -- Build the Custom Section of the Player Menu    
    local customMenuItems = {}    

    -- 1) World-Based Group Options
    local isNotLeader = GameData.Player.isGroupLeader ~= true
    if( not GameData.Player.isInScenario and not GameData.Player.isInSiege )
    then
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_GROUP_OPTIONS ), EA_Window_OpenParty.OpenToManageTab, false ) )
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_PARTY_FORM_WARPARTY ), GroupWindow.OnFormWarparty, isNotLeader ) )
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_MAKE_LEADER ), GroupWindow.OnMakeLeader, isNotLeader or isOffline ) )
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_LEAVE_GROUP ), GroupWindow.OnLeaveGroup, false ) )       
    end

    -- 2) Main Assist
    -- Don't show the main assist option unless the player is the current main assist or group leader in a non scenario party
    -- This is done to keep persistent with how battlegroup context menu behaves
    local currentMainAssist = GroupWindow.GetMainAssist()
    if( ( GameData.Player.isGroupLeader and not GameData.Player.isInScenario and not GameData.Player.isInSiege ) or currentMainAssist == GameData.Player.name )
    then
        local disableMainAssist = (currentMainAssist == playerName) or isOffline
        table.insert( customMenuItems, PlayerMenuWindow.NewCustomItem( GetString( StringTables.Default.LABEL_MAKE_MAIN_ASSIST ), GroupWindow.OnMakeMainAssist, disableMainAssist ) ) 
    end

    -- Create the Menu
    PlayerMenuWindow.ShowMenu( playerName, 0, customMenuItems ) 

end

function GroupWindow.IsMemberValid(index)
    return ( GroupWindow.groupData ~= nil and
             GroupWindow.groupData[index] ~= nil and
             GroupWindow.groupData[index].name ~= nil and
             GroupWindow.groupData[index].name ~= L"" )
end

function GroupWindow.OnGroupUpdated()
    GroupWindow.groupData = PartyUtils.GetPartyData()
    GroupWindow.UpdateGroupMembers()
    GroupWindow.ConditionalShow()
end

function GroupWindow.OnStatusUpdated( groupMemberIndex )
    GroupWindow.UpdateMemberStatus( groupMemberIndex )
    GroupWindow.ConditionalShow()
end

function GroupWindow.OnGroupPlayerAdded()
    -- The "player added" event always comes after a "group updated" event so any variable updates are done in GroupWindow.OnGroupUpdated().
    Sound.Play( Sound.GROUP_PLAYER_ADDED )
    
    GroupWindow.ConditionalShow()

    -- Refresh all group members' effects.
    -- TODO: We should only refresh the guy who just joined. Add his id to the event.
    for index = 1, GroupWindow.MAX_GROUP_MEMBERS
    do
        if ( GroupWindow.IsMemberValid( index ) )
        then
            GroupWindow.Buffs[ index ]:Refresh()
        end
    end
end

function GroupWindow.ConditionalShow()

    -- The scenario window is initialized after the group window,
    -- so this may be nil the first time through during initialization.
    local scenarioShowMainGroup = false
    if( ScenarioGroupWindow ~= nil )
    then
        scenarioShowMainGroup = ScenarioGroupWindow.GroupWindowSettings.showMainGroup
    end


    -- Don't show the party window if we're in a warband (and not in a scenario)
    -- or if we are in a scenario, but the user has turned it off
    if( (IsWarBandActive() and not GameData.Player.isInScenario and not GameData.Player.isInSiege)
        or ((GameData.Player.isInScenario or GameData.Player.isInSiege) and scenarioShowMainGroup == false) )
    then
        for index = 1, GroupWindow.MAX_GROUP_MEMBERS do
            if (GroupWindow.IsMemberValid(index) == true) then
                GroupWindow.groupMembers[index]:Show (false)
                if (DoesWindowExist("GroupWindowPet"..index) == true)
                then
                    GroupWindow.groupPets[index]:Show (false)
                end
            end
        end
    else
        for index = 1, GroupWindow.MAX_GROUP_MEMBERS do
            if (GroupWindow.IsMemberValid(index) == true) then
                GroupWindow.groupMembers[index]:Show(true)
            end
        end
    end
    
end

function GroupWindow.OnFormWarparty()
    SendChatText( L"/warbandconvert", L"" )

    if( EA_Window_OpenParty )
    then
        EA_Window_OpenParty.OpenToManageTab()
    end
end

function GroupWindow.OnMakeLeader()
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name ) == true ) then
        return
    end
    
    BroadcastEvent( SystemData.Events.GROUP_SET_LEADER )    
end

function GroupWindow.OnMakeMainAssist()
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name ) == true ) then
        return
    end
    BroadcastEvent( SystemData.Events.GROUP_SET_MAIN_ASSIST )    
end

function GroupWindow.OnLeaveGroup()
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name ) == true ) then
        return
    end
    

    BroadcastEvent( SystemData.Events.GROUP_LEAVE )    
end

function GroupWindow.OnGroupKick()
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true ) then
        return
    end
        
    BroadcastEvent( SystemData.Events.GROUP_KICK_PLAYER )    
end

function GroupWindow.OnTellMember()
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true ) then
        return
    end

    local text = L"/tell "..SystemData.UserInput.selectedGroupMember..L" "
    EA_ChatWindow.SwitchChannelWithExistingText(text)
end

function GroupWindow.OnTargetMember()
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true ) then
        return
    end

    SendChatText( L"/target "..SystemData.UserInput.selectedGroupMember, L"" )
end

function GroupWindow.OnAssistMember()
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true ) then
        return
    end

    SendChatText( L"/assist "..SystemData.UserInput.selectedGroupMember, L"" )
end

function GroupWindow.GetMainAssist( )
    for groupIndex = 1, GroupWindow.MAX_GROUP_MEMBERS
    do
        if( GroupWindow.groupData[groupIndex].isMainAssist )
        then
            return GroupWindow.groupData[groupIndex].name
        end
    end

    return GameData.Player.name
    
end

---------------------------------------------------------
-- Util Functions
---------------------------------------------------------
function GroupWindow.IsPlayerInGroup( playerName )

    for index = 1, GroupWindow.MAX_GROUP_MEMBERS 
    do
        if (GroupWindow.IsMemberValid( index )) 
        then
            
            if( WStringsCompareIgnoreGrammer( playerName, GroupWindow.groupData[index].name) == 0 )
            then
                return true  
            end
        end
    end
        
    return false
end

function GroupWindow.GetGroupMember( playerName )
    local party = PartyUtils.GetPartyData()
    for index, member in ipairs( party )
    do
        if( PartyUtils.IsPartyMemberValid( index ) and member.name == playerName )
        then
            return member
        end
    end
    return nil
end
