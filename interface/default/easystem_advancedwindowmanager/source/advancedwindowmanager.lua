
-- This file defines a Tutorial System that will introduce new players to different advanced UI elements 
-- only when they become applicable to the player.

EA_AdvancedWindowManager = 
{
    -- Areas of the Game Included in the Tutorial
    WINDOW_TYPE_XP                  = 1,
    WINDOW_TYPE_RP                  = 2,
    WINDOW_TYPE_MORALE              = 3,
    WINDOW_TYPE_TACTICS             = 4,
    WINDOW_TYPE_RALLY_CALL          = 5,
    WINDOW_TYPE_MASTERY_TRAINING    = 6,
    WINDOW_TYPE_TOK_ALERTS          = 7,
    WINDOW_TYPE_CURRENT_EVENTS      = 8,
    WINDOW_TYPE_ZONE_CONTROL_BAR    = 9,
    WINDOW_TYPE_INFLUENCE_BAR       = 10,
}

EA_AdvancedWindowManager.Settings = 
{
    hideAdvancedWindowsUntilNeeded = true
}

-----------------------------------------------------------------------------------
-- Local Functions & Variables
-----------------------------------------------------------------------------------

local function ShouldShowXP() 
    
    -- Only show the XP Bar if the player has gained XP.
    return ( GameData.Player.level > 1 ) or ( GameData.Player.Experience.curXpEarned > 0 )    

end

local function ShouldShowRP() 
    
    -- Only show the RP Bar if the player has gained RP.
    return ( GameData.Player.Renown.curRank > 0 ) or ( GameData.Player.Renown.curRenownEarned > 0 )    

end

local function ShouldShowMorale()

    -- Only Show the Morale window if the player has Morale Abiltiies
    -- This table is indexed by non sequential ability id's so the '#' operator won't work.    
    local abilitiesTable = Player.GetAbilityTable( GameData.AbilityType.MORALE )
    return ( next(abilitiesTable, nil) ~= nil )

end

local function ShouldShowTactics()

    -- Only Show the Tactics window if the player has Tactic Abiltiies
    -- This table is indexed by non sequential ability id's so the '#' operator won't work.  
    local abilitiesTable = Player.GetAbilityTable( GameData.AbilityType.TACTIC )
    return ( next(abilitiesTable, nil) ~= nil )  
    
end

local function ShouldShowRallyCall()

    -- Low level players cannot use rally call.
    local RANK = 7
    return ( GameData.Player.level >= RANK )
    
end

local function ShouldShowMasteryTraining()

    -- Low level players do not recieve mastery points.
    local MIN_RANK = 11  
    return ( GameData.Player.level >= MIN_RANK )
end

local function ShouldShowTOKAlerts()

    -- Only show TOK info after the player has encountered the Tome Quest
    -- or has reached rank 4.
    local RANK = 4
    return GameData.Player.knowsAboutTome or ( GameData.Player.level >= RANK )
end

local function ShouldShowCurrentEvents()

    -- Only show Current Events for players rank 5 of higher
    local RANK = 5
    return ( GameData.Player.level >= RANK )
end
   
local function ShouldShowZoneControlBar()

    -- Only show zone control bar after the player has entered a warcamp, or if the player has achieved Renown Rank 2
    local MIN_RENOWN_RANK = 2
    return GameData.Player.knowsAboutZoneControl or ( GameData.Player.Renown.curRank >= MIN_RENOWN_RANK )
end

local function ShouldShowInfluenceBar()

    -- Show the influence bar if the player has been to a PQ area, or if the player is rank 4 or higher
    local RANK = 4
    return GameData.Player.knowsAboutInfluence or ( GameData.Player.level >= RANK )
end
   

local m_shouldShowFunctions = 
{
    [EA_AdvancedWindowManager.WINDOW_TYPE_XP]                = ShouldShowXP,
    [EA_AdvancedWindowManager.WINDOW_TYPE_RP]                = ShouldShowRP,
    [EA_AdvancedWindowManager.WINDOW_TYPE_MORALE]            = ShouldShowMorale,
    [EA_AdvancedWindowManager.WINDOW_TYPE_TACTICS]           = ShouldShowTactics,
    [EA_AdvancedWindowManager.WINDOW_TYPE_RALLY_CALL]        = ShouldShowRallyCall,    
    [EA_AdvancedWindowManager.WINDOW_TYPE_MASTERY_TRAINING]  = ShouldShowMasteryTraining,
    [EA_AdvancedWindowManager.WINDOW_TYPE_TOK_ALERTS]        = ShouldShowTOKAlerts,
    [EA_AdvancedWindowManager.WINDOW_TYPE_CURRENT_EVENTS]    = ShouldShowCurrentEvents,
    [EA_AdvancedWindowManager.WINDOW_TYPE_ZONE_CONTROL_BAR]  = ShouldShowZoneControlBar,
    [EA_AdvancedWindowManager.WINDOW_TYPE_INFLUENCE_BAR]     = ShouldShowInfluenceBar,
}


local m_registeredWindows = {}

--------------------------------------------------------------------------------------
-- Global Functions
-----------------------------------------------------------------------------------

function EA_AdvancedWindowManager.GetHideAdvancedWindowsUntilNeeded()
    return EA_AdvancedWindowManager.Settings.hideAdvancedWindowsUntilNeeded
end

function EA_AdvancedWindowManager.SetHideAdvancedWindowsUntilNeeded( value )

    if( EA_AdvancedWindowManager.Settings.hideAdvancedWindowsUntilNeeded == value )
    then
        return
    end    
    
    EA_AdvancedWindowManager.Settings.hideAdvancedWindowsUntilNeeded = value

    -- Update Each Window
    for windowName, windowType in pairs( m_registeredWindows ) 
    do   
        EA_AdvancedWindowManager.UpdateWindowShowing( windowName, windowType )
    end  
end


function EA_AdvancedWindowManager.ShouldShow( windowType )
    return (EA_AdvancedWindowManager.Settings.hideAdvancedWindowsUntilNeeded == false)
                           or m_shouldShowFunctions[windowType]()
end

function EA_AdvancedWindowManager.UpdateWindowShowing( windowName, windowType )

    if( m_shouldShowFunctions[ windowType ] == nil )
    then
        ERROR( L"EA_AdvancedWindowManager.UpdateWindowShowing: Invalid Tutorial Type" )
        return
    end   
    
    local windowShowing = WindowGetShowing( windowName )
    local shouldShow    = EA_AdvancedWindowManager.ShouldShow( windowType )
      
    if( windowShowing ~= shouldShow )
    then
        WindowSetShowing( windowName, shouldShow )        
    end
    
    
    -- Cache the Window Name
    m_registeredWindows[ windowName ] = windowType
    
end 


