--------------------------------------------------------------------
-- Here's the mighty target window!  Fear its accurate description!
--------------------------------------------------------------------

TargetWindow = { }

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local c_PRIMARY_TARGET_LAYOUT_WINDOW   = "PrimaryTargetLayoutWindow"
local c_SECONDARY_TARGET_LAYOUT_WINDOW = "SecondaryTargetLayoutWindow"

local c_PRIMARY_TARGET_LAYOUT_WINDOW_SCALE = 1.0
local c_SECONDARY_TARGET_LAYOUT_WINDOW_SCALE = 0.75

local c_PRIMARY_TARGET_ANCHOR  = 
{ 
    Point           = "topleft", 
    RelativeTo      = c_PRIMARY_TARGET_LAYOUT_WINDOW,
    RelativePoint   = "topleft", 
    XOffset         = 0,
    YOffset         = 0,
}

local c_SECONDARY_TARGET_ANCHOR  = 
{ 
    Point           = "topleft", 
    RelativeTo      = c_SECONDARY_TARGET_LAYOUT_WINDOW,
    RelativePoint   = "topleft", 
    XOffset         = 0,
    YOffset         = 0,
}


local c_HOSTILE_TARGET          = "selfhostiletarget"
local c_HOSTILE_TARGET_WINDOW   = "TargetWindow"


local c_FRIENDLY_TARGET         = "selffriendlytarget"
local c_FRIENDLY_TARGET_WINDOW  = "FriendlyTargetWindow"

local currentFriendlyTargetAnchorTo = c_PRIMARY_TARGET_LAYOUT_WINDOW

local hostileTargetFrame        = nil 
local friendlyTargetFrame       = nil

local bAlwaysShowHitPoints = false

----------------------------------------------------------------
-- TargetWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function TargetWindow.Initialize()

    -- Hostile Target
    hostileTargetFrame = UnitFrames:CreateNewFrame (c_HOSTILE_TARGET_WINDOW, UnitFrames.UNITFRAME_TARGET, c_HOSTILE_TARGET)
    hostileTargetFrame:SetParent( c_PRIMARY_TARGET_LAYOUT_WINDOW )
    hostileTargetFrame:SetScale( WindowGetScale( c_PRIMARY_TARGET_LAYOUT_WINDOW ) )
    hostileTargetFrame:SetAnchor( c_PRIMARY_TARGET_ANCHOR )
    hostileTargetFrame.m_SizeX, hostileTargetFrame.m_SizeY = GetTemplateWindowDimensions( hostileTargetFrame.m_Template )
    
    -- Friendly Target
    friendlyTargetFrame = UnitFrames:CreateNewFrame (c_FRIENDLY_TARGET_WINDOW, UnitFrames.UNITFRAME_TARGET, c_FRIENDLY_TARGET)   
    friendlyTargetFrame:SetParent( c_PRIMARY_TARGET_LAYOUT_WINDOW )
    friendlyTargetFrame:SetScale( WindowGetScale( c_PRIMARY_TARGET_LAYOUT_WINDOW ) )
    friendlyTargetFrame:SetAnchor( c_PRIMARY_TARGET_ANCHOR ) 
    friendlyTargetFrame.m_SizeX, friendlyTargetFrame.m_SizeY = GetTemplateWindowDimensions( friendlyTargetFrame.m_Template )

    -- Layout Windows
    WindowRegisterCoreEventHandler( c_SECONDARY_TARGET_LAYOUT_WINDOW, "OnInitializeCustomSettings", "TargetWindow.InitializeSecondaryTargetLayout" )
    
    LayoutEditor.RegisterWindow( c_PRIMARY_TARGET_LAYOUT_WINDOW,
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PRIMARY_TARGET_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PRIMARY_TARGET_WINDOW_DESC ),
                                false, false,
                                true, nil )
       
    LayoutEditor.RegisterWindow( c_SECONDARY_TARGET_LAYOUT_WINDOW,
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_SECONDARY_TARGET_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_SECONDARY_TARGET_WINDOW_DESC ),
                                false, false,
                                true, nil )


    WindowRegisterEventHandler (c_HOSTILE_TARGET_WINDOW, SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "TargetWindow.UpdateTargetCombat")
    WindowRegisterEventHandler (c_HOSTILE_TARGET_WINDOW, SystemData.Events.PLAYER_TARGET_UPDATED, "TargetWindow.UpdateTarget")
    WindowRegisterEventHandler (c_HOSTILE_TARGET_WINDOW, SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED, "TargetWindow.OnEffectsUpdated")

    TargetWindow.UpdateTarget()
end


function TargetWindow.InitializePrimaryTargetLayout()
    currentFriendlyTargetAnchorTo = nil

    WindowSetScale( c_PRIMARY_TARGET_LAYOUT_WINDOW, c_PRIMARY_TARGET_LAYOUT_WINDOW_SCALE*InterfaceCore.GetScale() )
end

function TargetWindow.InitializeSecondaryTargetLayout()
    currentFriendlyTargetAnchorTo = nil

    WindowSetScale( c_SECONDARY_TARGET_LAYOUT_WINDOW, c_SECONDARY_TARGET_LAYOUT_WINDOW_SCALE*InterfaceCore.GetScale() )
    TargetWindow.UpdateLayoutForTargets()
end


function TargetWindow.UpdateTargetCombat()
    hostileTargetFrame:UpdateCombatState (GameData.Player.inCombat)
end

function TargetWindow.OnEffectsUpdated( updateType, updatedEffects, isFullList )
    if ( updateType == GameData.BuffTargetType.TARGET_HOSTILE )
    then
        hostileTargetFrame.m_BuffTracker:UpdateBuffs( updatedEffects, isFullList )
        TargetWindow.UpdateWindowDimensions( c_HOSTILE_TARGET_WINDOW, hostileTargetFrame )
    elseif ( updateType == GameData.BuffTargetType.TARGET_FRIENDLY )
    then
        friendlyTargetFrame.m_BuffTracker:UpdateBuffs( updatedEffects, isFullList )
        TargetWindow.UpdateWindowDimensions( c_FRIENDLY_TARGET_WINDOW, friendlyTargetFrame )
    else
        DEBUG( L"TargetWindow.OnEffectsUpdated - Got unexpected updateType "..updateType )
    end
end

function TargetWindow.UpdateWindowDimensions( window, targetFrame )
    -- Change the size of the target window depending on how many buffs are applied
    local numBuffRows = targetFrame.m_BuffTracker.m_VisibleRowCount
    local xBuff, yBuff = WindowGetDimensions( window.."Buffs1" )
    local newSizeX = targetFrame.m_SizeX
    local newSizeY = targetFrame.m_SizeY 
    if( numBuffRows > 1 )
    then
        newSizeY = newSizeY + ( numBuffRows - 1 ) * ( yBuff + 24 )
    end
    WindowSetDimensions(window, newSizeX, newSizeY )
    
    local numberOfTargets = TargetWindow.NumberOfTargetWindowsShowing()
    if ( numberOfTargets > 1 and  window == c_FRIENDLY_TARGET_WINDOW )
    then
        WindowSetDimensions( c_SECONDARY_TARGET_LAYOUT_WINDOW, newSizeX, newSizeY )
    else
        WindowSetDimensions( c_PRIMARY_TARGET_LAYOUT_WINDOW, newSizeX, newSizeY )
    end

    -- If multiple targets then update anchoring so buffs aren't overlapped
    -- Only do this if it's still anchored to c_PRIMARY_TARGET_LAYOUT_WINDOW (it won't be if the user has moved it in the layout editor)
    local _, _, relativeTo, _, _ = WindowGetAnchor( c_SECONDARY_TARGET_LAYOUT_WINDOW, 1 )
    if ( numberOfTargets > 1 and relativeTo == c_PRIMARY_TARGET_LAYOUT_WINDOW )
    then
        WindowClearAnchors( c_SECONDARY_TARGET_LAYOUT_WINDOW )
        WindowAddAnchor( c_SECONDARY_TARGET_LAYOUT_WINDOW, "bottomleft", c_PRIMARY_TARGET_LAYOUT_WINDOW, "topleft", 0, 0 )
    end
end

function TargetWindow.UpdateTarget( targetClassification, targetId, targetType )
    
    if( targetClassification ~= c_HOSTILE_TARGET and targetClassification ~= c_FRIENDLY_TARGET )
    then
        return
    end

    -- This is a little cheesy, but works until we can better differentiate
    -- between target changes and target hp updates. -bmazza
    local oldHostileEntityId = TargetInfo:UnitEntityId( c_HOSTILE_TARGET )
    local oldFriendlyEntityId = TargetInfo:UnitEntityId( c_FRIENDLY_TARGET )
    local targetHasChanged = false
	local oldNumberOfTargets = TargetWindow.NumberOfTargetWindowsShowing()

    TargetInfo:UpdateFromClient()
    
    hostileTargetFrame:UpdateUnit()
    friendlyTargetFrame:UpdateUnit()

    if ( TargetInfo:UnitEntityId("selfhostiletarget") ~= oldHostileEntityId ) then
        hostileTargetFrame:StopInterpolatingStatus()
        hostileTargetFrame.m_BuffTracker:Refresh()
        targetHasChanged = true
    end
    if ( TargetInfo:UnitEntityId("selffriendlytarget") ~= oldFriendlyEntityId ) then
        friendlyTargetFrame:StopInterpolatingStatus()
        friendlyTargetFrame.m_BuffTracker:Refresh()
        targetHasChanged = true
    end

    TargetWindow.UpdateLayoutForTargets()
    -- Play appropriate targets added/removed/changed sound
    if targetHasChanged then
		local newNumberOfTargets = TargetWindow.NumberOfTargetWindowsShowing()
		if newNumberOfTargets < oldNumberOfTargets then
			Sound.Play( Sound.TARGET_DESELECT )
		else
			Sound.Play( Sound.TARGET_SELECT )		
		end
	end
end

function TargetWindow.NumberOfTargetWindowsShowing()

    if WindowGetShowing( c_SECONDARY_TARGET_LAYOUT_WINDOW ) then
		return 2
    elseif WindowGetShowing( c_PRIMARY_TARGET_LAYOUT_WINDOW ) then
		return 1
    else
		return 0
	end
end
    
function TargetWindow.UpdateLayoutForTargets()
    
    --We can hit this function before initialization, so just make sure the frame exist, else bail out.
    if( not friendlyTargetFrame )
    then
        return
    end
    
    -- Reanchor so there's never any empty space...
    
    if (friendlyTargetFrame:IsShowing () and hostileTargetFrame:IsShowing () and currentFriendlyTargetAnchorTo ~= c_SECONDARY_TARGET_LAYOUT_WINDOW )
    then
        currentFriendlyTargetAnchorTo = c_SECONDARY_TARGET_LAYOUT_WINDOW
        
        friendlyTargetFrame:SetParent( c_SECONDARY_TARGET_LAYOUT_WINDOW )
        friendlyTargetFrame:SetScale( WindowGetScale( c_SECONDARY_TARGET_LAYOUT_WINDOW ) )
        friendlyTargetFrame:SetAnchor( c_SECONDARY_TARGET_ANCHOR )
        friendlyTargetFrame:ShowBuffTimerLabels (HIDE_BUFF_FRAME_TIMER_LABELS)
        
    elseif (friendlyTargetFrame:IsShowing () and not hostileTargetFrame:IsShowing () and currentFriendlyTargetAnchorTo ~= c_PRIMARY_TARGET_LAYOUT_WINDOW )
    then        
        
        currentFriendlyTargetAnchorTo = c_PRIMARY_TARGET_LAYOUT_WINDOW
        
        friendlyTargetFrame:SetParent( c_PRIMARY_TARGET_LAYOUT_WINDOW )
        friendlyTargetFrame:SetScale( WindowGetScale( c_PRIMARY_TARGET_LAYOUT_WINDOW ) )
        friendlyTargetFrame:SetAnchor( c_PRIMARY_TARGET_ANCHOR )
        friendlyTargetFrame:ShowBuffTimerLabels (SHOW_BUFF_FRAME_TIMER_LABELS)
    end   
    
    -- Show the layout frames when they are in-use
    if ( hostileTargetFrame:IsShowing() or friendlyTargetFrame:IsShowing() )
    then
        LayoutEditor.Show( c_PRIMARY_TARGET_LAYOUT_WINDOW )
    else
        LayoutEditor.Hide( c_PRIMARY_TARGET_LAYOUT_WINDOW )
    end
    
    if ( hostileTargetFrame:IsShowing() and friendlyTargetFrame:IsShowing() )
    then
        LayoutEditor.Show( c_SECONDARY_TARGET_LAYOUT_WINDOW )
    else
        LayoutEditor.Hide( c_SECONDARY_TARGET_LAYOUT_WINDOW )
    end

end
