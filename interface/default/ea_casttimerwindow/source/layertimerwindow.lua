----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

LayerTimerWindow = 
{
    CAST_BAR_NORMAL_TINT        = { r=255, g=210, b=0 },
    CAST_BAR_SUCCESS_TINT       = { r=255, g=253, b=107 },
    CAST_BAR_FAIL_TINT          = { r=164, g=81, b=0 },
    CAST_BAR_BACKGROUND_TINT    = { r=20, g=20, b=20 },
    
    queuedCastBarHide           = false,
}

----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

local lastActiveWindow              = nil
local unknownAbilityName            = L""
local nameAlreadySet                = false
local MINIMUM_CAST_BAR_FADE_TIME    = 0.75
local QUEUED_HIDE_CALL              = true
local NOT_A_CANCELLATION            = false

local castTimer = 
{ 
    current                 = 0, 
    maximum                 = 0, 
    desired                 = 0,
    action                  = 0, 
    isChannel               = false,
    hideSelfWhenComplete    = false,
}

local function GetActiveActionName (abilityId)   
    if (nil == abilityId or 0 == abilityId) then
        return unknownAbilityName
    end

    local abilityName = GetAbilityName (abilityId)
    
    if (abilityName ~= nil and abilityName ~= L"")
    then
        return (abilityName)
    end
    
    return unknownAbilityName
end

----------------------------------------------------------------
-- LayerTimerWindow Functions
----------------------------------------------------------------

local function SetStatusBarTint (color)
    StatusBarSetForegroundTint ("LayerTimerWindowCastTimerStatusBar", color.r, color.g, color.b)
end

-- OnInitialize Handler
function LayerTimerWindow.Initialize()

    unknownAbilityName = GetString (StringTables.Default.LABEL_UNKNOWN_ABILITY_NAME);
    
    -- Register for Player Status updates
    WindowRegisterEventHandler ("LayerTimerWindow", SystemData.Events.PLAYER_START_INTERACT_TIMER,  "LayerTimerWindow.StartInteractTimer")
    WindowRegisterEventHandler ("LayerTimerWindow", SystemData.Events.INTERACT_DONE,                "LayerTimerWindow.HideCastBar")
    WindowRegisterEventHandler ("LayerTimerWindow", SystemData.Events.PLAYER_BEGIN_CAST,            "LayerTimerWindow.ShowCastBar")
    WindowRegisterEventHandler ("LayerTimerWindow", SystemData.Events.PLAYER_END_CAST,              "LayerTimerWindow.HideCastBar")
    WindowRegisterEventHandler ("LayerTimerWindow", SystemData.Events.PLAYER_CAST_TIMER_SETBACK,    "LayerTimerWindow.SetbackCastBar")
    
    local color = LayerTimerWindow.CAST_BAR_BACKGROUND_TINT
    StatusBarSetBackgroundTint ("LayerTimerWindowCastTimerStatusBar", color.r, color.g, color.b)
    
    -- Get the glow image to show up on top of the cast bar.
    WindowClearAnchors ("LayerTimerWindowCastTimerStatusBackgroundGlow")
    WindowAddAnchor ("LayerTimerWindowCastTimerStatusBackgroundGlow", "topleft", "LayerTimerWindowCastTimerStatus", "topleft", 0, 0)
    WindowAddAnchor ("LayerTimerWindowCastTimerStatusBackgroundGlow", "bottomright", "LayerTimerWindowCastTimerStatus", "bottomright", 0, 0)
        
    WindowSetShowing ("LayerTimerWindowCastTimer", false)
    
    -- Register the LayerTimerWindow with the Frame Manager. This is needed so the ActionBarClusterManager
    -- can properly register it for the layout editor and for anchoring.
    FrameForLayoutEditor:CreateFrameForExistingWindow( "LayerTimerWindow" )
end

-- OnUpdate Handler
function LayerTimerWindow.Update( timePassed )

    local normalized        = -1 -- Normalize the actual cast time over the range of the desired cast time, assume that the update is unnecessary.
    local previousCastTime  = 0 -- Cache the current time (just in case it is needed for label updates)
  
    if ((castTimer.current > 0) and (castTimer.maximum > 0))
    then
        previousCastTime    = (castTimer.current / castTimer.maximum) * castTimer.desired   -- Normalized previous time
        castTimer.current   = castTimer.current - timePassed                                -- Update current time
        
        -- Ensure that the bar always fills to the end!
        if (castTimer.current < 0)
        then
            castTimer.current = 0
        end
       
        normalized = (castTimer.current / castTimer.maximum) * castTimer.desired   -- Renormalize for new time
    end

    if (normalized >= 0)
    then
        -- Make sure that the time differs sufficiently before updating the label, make sure the label is initialized correctly.
        if ( math.ceil( previousCastTime * 10 ) > math.ceil( normalized * 10 ) )
        then
			local timeValue = normalized
			timeValue = math.ceil( timeValue * 10 ) / 10
			timeValue = TimeUtils.FormatRoundedSeconds( timeValue, 0.5, true )
            LabelSetText( "LayerTimerWindowCastTimerTimeText", timeValue )
            WindowSetShowing( "LayerTimerWindowCastTimerTimeText", true )
        end
        
        local fillValue = 0
        if (castTimer.isChannel == true) then
            fillValue = normalized
        else
            fillValue = castTimer.desired - normalized
        end
        StatusBarSetCurrentValue( "LayerTimerWindowCastTimerStatusBar", fillValue )
    elseif (castTimer.hideSelfWhenComplete)
    then
        WindowSetShowing ("LayerTimerWindowCastTimer", false)
        nameAlreadySet = false
    elseif (LayerTimerWindow.HasQueuedCastBarHide ())
    then
        LayerTimerWindow.HideCastBar (NOT_A_CANCELLATION, QUEUED_HIDE_CALL)
    end
end

local function SetCastBarName (actionId, name)
    if( nameAlreadySet )
    then
        return
    end
    
    if (actionId)
    then
        LabelSetText ("LayerTimerWindowCastTimerText", GetActiveActionName (actionId))
    elseif (name)
    then
        LabelSetText ("LayerTimerWindowCastTimerText", name)
    end
end

local function ResetCastBarState (desiredTime)
    SetStatusBarTint (LayerTimerWindow.CAST_BAR_NORMAL_TINT)
    StatusBarSetCurrentValue ("LayerTimerWindowCastTimerStatusBar", 0 )
    StatusBarSetMaximumValue( "LayerTimerWindowCastTimerStatusBar", desiredTime )
    WindowStopAlphaAnimation ("LayerTimerWindowCastTimer")
    WindowSetShowing ("LayerTimerWindowCastTimerStatusBackgroundGlow", false)
    WindowSetShowing( "LayerTimerWindowCastTimer",  desiredTime > 0 )
    WindowSetAlpha( "LayerTimerWindowCastTimer", 1.0 )
    WindowSetFontAlpha( "LayerTimerWindowCastTimer", 1.0 )

    if ( desiredTime > 0 )
    then
		local timeValue = desiredTime
		timeValue = TimeUtils.FormatRoundedSeconds( timeValue, 0.5, true )
        LabelSetText( "LayerTimerWindowCastTimerTimeText", timeValue )
	end
end

-- Called by the crafting windows to set the name of the layer timer window.
function LayerTimerWindow.SetActionName( name, overrideSetName )
    if( name ~= nil )
    then
        LabelSetText( "LayerTimerWindowCastTimerText", name )
    end
    
    nameAlreadySet = overrideSetName
end

function LayerTimerWindow.StartInteractTimer()
    if ( not WindowGetShowing( "LayerTimerWindow" ) )
    then
        return
    end
    
    castTimer.current               = GameData.InteractTimer.time
    castTimer.maximum               = GameData.InteractTimer.time
    castTimer.desired               = GameData.InteractTimer.time
    castTimer.action                = 0
    castTimer.hideSelfWhenComplete  = true
    
    ResetCastBarState (castTimer.desired)
    SetCastBarName (nil, GameData.InteractTimer.objectName)
end

function LayerTimerWindow.ShowCastBar (abilityId, isChannel, desiredCastTime, holdCastBar)
    if ( not WindowGetShowing( "LayerTimerWindow" ) )
    then
        return
    end
    
	if ( desiredCastTime <= 0 )
    then
		castTimer.current = 0
        return
    end
    
    -- Special case for letting the cast bar be visible but not animated.
    if( holdCastBar == true )
    then
        castTimer.current = 0
        ResetCastBarState( desiredCastTime )
        if( isChannel == true )
        then
            StatusBarSetCurrentValue( "LayerTimerWindowCastTimerStatusBar", desiredCastTime )
        end
        LayerTimerWindow.SetUpCastBar( abilityId, isChannel, 0 )
        return
    end

    -- If last cast was a channel, then just pretend cast bar was finished, so it gets reset.
    if ( castTimer.isChannel == true and ( not isChannel ) )
    then    
        castTimer.current = 0
    end
    
    if ( ( castTimer.current > 0 ) and ( not isChannel ) )
    then
		if( WindowGetAlpha( "LayerTimerWindowCastTimer" ) < 1 )
		then
			-- Cast bar was hidden but hadn't had time to fill up yet, so re-start it
			castTimer.current = desiredCastTime
			ResetCastBarState( desiredCastTime )
		else
			-- Modify the time left on the cast. This happens when the server sends us a new cast time that
			-- doesn't line up with the client started time. If we ever change it so that the cast bar isn't
            -- shown until the server responds, this code should be removed.
			local changeModifier = desiredCastTime / castTimer.desired
			castTimer.current = castTimer.current * changeModifier

			StatusBarSetCurrentValue( "LayerTimerWindowCastTimerStatusBar", castTimer.current )
			StatusBarSetMaximumValue( "LayerTimerWindowCastTimerStatusBar", desiredCastTime )
		end
    else
		castTimer.current = desiredCastTime
        ResetCastBarState( desiredCastTime )
    end
   
    LayerTimerWindow.SetUpCastBar( abilityId, isChannel, desiredCastTime )
end

function LayerTimerWindow.SetUpCastBar( abilityId, isChannel, desiredCastTime )
	castTimer.desired = desiredCastTime
	castTimer.maximum = desiredCastTime   
    castTimer.action = abilityId
    castTimer.isChannel = isChannel
    castTimer.hideSelfWhenComplete = false

    SetCastBarName( abilityId )
    LayerTimerWindow.RemoveQueuedCastBarHide()
end


function LayerTimerWindow.HideCastBar (isCancel, fromQueuedCall)
    if ( not WindowGetShowing( "LayerTimerWindow" ) )
    then
        return
    end
    
    -- If an ability with a really fast cast time is not started early (ie, before the server confirmation)
    -- on the client, there's a very good chance that the hide cast bar event will show up in the same
    -- frame.  So, to prevent the bar from being hidden as the cast begins, just queue this call to
    -- HideCastBar, and call it when the cast has actually finished...this is somewhat dangerous
    -- because there is only ever going to be ONE call to HideCastBar for this ability, so if its
    -- missed for any reason, this will result in a stuck cast bar.
    
    if ((isCancel == false) and (castTimer.maximum < MINIMUM_CAST_BAR_FADE_TIME) and (fromQueuedCall == nil))
    then
        LayerTimerWindow.QueueCastBarHide ()
        return
    end
    
    -- If the bar is already hidden or being hidden, there's no reason to pop it into existence and then hide it again...
    if (WindowGetAlpha ("LayerTimerWindowCastTimer") < 1)
    then
        return
    end
    
    local fadeTime = MINIMUM_CAST_BAR_FADE_TIME
    
    if ((WindowGetAlpha ("LayerTimerWindowCastTimer") == 1) and (isCancel == false))
    then
        -- Instead of immediately hiding the cast bar, initiate a quick fade-out over the remaining duration of the cast...
        SetStatusBarTint (LayerTimerWindow.CAST_BAR_SUCCESS_TINT)
        WindowSetShowing ("LayerTimerWindowCastTimerStatusBackgroundGlow", true)
        local fadeTime = math.max (fadeTime, castTimer.current)
    else
        castTimer.current = 0 -- Stop updates on the bar.
        SetStatusBarTint (LayerTimerWindow.CAST_BAR_FAIL_TINT)
        
        -- Leaving this out for now with the intent of putting it back in.
        -- I've heard some complaints that people don't like the cast bar filling after a spell interrupt.
        --StatusBarSetCurrentValue ("LayerTimerWindowCastTimerStatusBar", castTimer.maximum)
    end
    
    WindowStartAlphaAnimation ("LayerTimerWindowCastTimer", Window.AnimationType.SINGLE_NO_RESET, 0.95, 0, fadeTime, false, 0, 0)
    LayerTimerWindow.RemoveQueuedCastBarHide ()
  
    nameAlreadySet = false
end

function LayerTimerWindow.QueueCastBarHide ()
    LayerTimerWindow.queuedCastBarHide = true
end

function LayerTimerWindow.RemoveQueuedCastBarHide ()
    LayerTimerWindow.queuedCastBarHide = false
end

function LayerTimerWindow.HasQueuedCastBarHide ()
    return (LayerTimerWindow.queuedCastBarHide)
end

function LayerTimerWindow.SetbackCastBar (newCastTime)
    if (castTimer.current == nil) then castTimer.current = 0 end
    if (newCastTime == nil) then newCastTime = 0 end
    assert (castTimer.current > 0)
    -- If setback amount is deisred here's how to get it: newCastTime - castTimer.current
    castTimer.current = newCastTime
end

function LayerTimerWindow.OnHidden()
    ResetCastBarState( 0 )
end

function LayerTimerWindow.OnInitializeCustomSettings ()
    if (ActionBarClusterManager and CAST_BAR_NAME)
    then
        ActionBarClusterManager:OnInitializeCustomSettingsForFrame (GetFrame (CAST_BAR_NAME))
    end
end
