----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

ThreePartBar = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local ThreePartBarTracker = { }

local BAR_BORDER = { x = 0, y = 3 }

local UNDERDOG_PAIRING_LOCKDOWN =
{
    [3] = L"1:00",
    [2] = L"2:00",
    [1] = L"3:00",
    [0] = L"3:00",
    [-1] = L"3:00",
    [-2] = L"4:00",
    [-3] = L"5:00",
}

local STRING_ZERO_VALUE     = 0
local STRING_POSITIVE_VALUE = 1
local STRING_NEGATIVE_VALUE = 2

local MODE_REALM_BARS   = 1     -- Show Order and Destruction bars
local MODE_POOL_BARS    = 2     -- Show Winner and Loser pool bars

----------------------------------------------------------------
-- Local/Utility Functions
----------------------------------------------------------------

local function AnchorPointBar( self, parentName )
    local xBorder = BAR_BORDER.x
    local yBorder = BAR_BORDER.y
    
    WindowClearAnchors( self.barName )
    WindowAddAnchor( self.barName, "topleft",     parentName, "topleft",     -xBorder, -yBorder )
    WindowAddAnchor( self.barName, "bottomright", parentName, "bottomright",  xBorder,  yBorder )
    
    self.barSize.width, self.barSize.height = WindowGetDimensions( self.barName )
    self.barSize.width  = self.barSize.width  - xBorder
    self.barSize.height = self.barSize.height - yBorder
end

local function UpdateProgressMeter( self, side, curPercent )
    local barName = self.barName..side
    local width = ( ( curPercent / 100 ) * self.barSize.width )

    if ( width > 0 )
    then
        local _, height = WindowGetDimensions( barName )
        WindowSetDimensions( barName, width, height )
        WindowSetShowing( barName, true )
    else
        WindowSetShowing( barName, false )
    end
end

-- If the slice names for the EA_VictoryPoints01_32b texture change than this has to change as well
local function UpdateVictoryStatus( self )
    local leftTexSlice  = "Order-Symbol-horiz"
    local rightTexSlice = "Dest-Symbol-horiz"

    if ( self.controllingRealm == GameData.Realm.ORDER )
    then
        leftTexSlice  = leftTexSlice.."-WIN"
        rightTexSlice = rightTexSlice.."-LOSE"
    elseif ( self.controllingRealm == GameData.Realm.DESTRUCTION )
    then
        rightTexSlice = rightTexSlice.."-WIN"
        leftTexSlice  = leftTexSlice.."-LOSE"
    elseif ( self.mode == MODE_POOL_BARS )
    then
        leftTexSlice  = "Generic-Symbol-horiz"
        rightTexSlice = "Generic-Symbol-horiz"
    end
        
    DynamicImageSetTextureSlice( self.barName.."LeftEndCap",  leftTexSlice )
    DynamicImageSetTextureSlice( self.barName.."RightEndCap", rightTexSlice )
end

local function UpdatePointBar( self )
    if ( self.mode == MODE_REALM_BARS )
    then
        UpdateProgressMeter( self, "Order",       self.leftValue )
        UpdateProgressMeter( self, "Destruction", self.rightValue )
        UpdateProgressMeter( self, "WinnerPool",  0 )
        UpdateProgressMeter( self, "LoserPool",   0 )
    else
        UpdateProgressMeter( self, "WinnerPool",  self.leftValue )
        UpdateProgressMeter( self, "LoserPool",   self.rightValue )
        UpdateProgressMeter( self, "Order",       0 )
        UpdateProgressMeter( self, "Destruction", 0 )
    end
    UpdateVictoryStatus( self )
end

----------------------------------------------------------------
-- ThreePartBar Functions
----------------------------------------------------------------

function ThreePartBar.Initialize()

   RegisterEventHandler( SystemData.Events.CAMPAIGN_ZONE_UPDATED,    "ThreePartBar.OnZoneUpdated" )
   RegisterEventHandler( SystemData.Events.RVR_REWARD_POOLS_UPDATED, "ThreePartBar.OnRewardPoolsUpdated" )
   
end

function ThreePartBar.Shutdown()

   UnregisterEventHandler( SystemData.Events.CAMPAIGN_ZONE_UPDATED,    "ThreePartBar.OnZoneUpdated" )
   UnregisterEventHandler( SystemData.Events.RVR_REWARD_POOLS_UPDATED, "ThreePartBar.OnRewardPoolsUpdated" )

    -- The anchor points for the progress bars should destroy their children
    -- when they get destroyed, but just in case, I'll destroy the windows here.
    
    for k, v in pairs (ThreePartBarTracker) do
        if (nil ~= v.pointBarName) then
            DestroyWindow (v.pointBarName);
        end
    end
    
    ThreePartBarTracker = {};

end


function ThreePartBar.Create( pointBarName, parentName, vertical, scale )
    if ( vertical )
    then
        ERROR(L"Vertical Three Part Bars are no longer supported.")
        return
    end
    
    local windowTemplateName = "ThreePartProgressBar"
    
    CreateWindowFromTemplate( pointBarName, windowTemplateName, parentName )
    if ( scale )
    then
        WindowSetScale( pointBarName, scale )
    end
        
    -- Map this bar's point pool id to a name so that there's an easy way to perform the updates.
    --   need to generate a unique ID

    -- Linear search - fast enough since this function isn't called often.
    --   Used since there's no generic ID generator in Lua
    local barId = 0
    while ( ThreePartBarTracker[barId] ~= nil )
    do
        barId = barId + 1
    end
    
    -- the parent has the mouse-over callback on it, so set the ID on the parent
    WindowSetId( parentName, barId )

    ThreePartBarTracker[barId] =
    {
        barName     = pointBarName,
        barSize     =
        {
            width   = 0,
            height  = 0,
        },
        mode        = MODE_REALM_BARS,
        leftValue   = 0,
        rightValue  = 0,
        controllingRealm = GameData.Realm.NONE,
        zoneId      = 0, -- Zone that is curently displayed on this bar.
        
        AnchorPointBar   = AnchorPointBar,
        UpdatePointBar   = UpdatePointBar,
    }
    
    ThreePartBarTracker[barId]:AnchorPointBar( parentName )
    ThreePartBarTracker[barId]:UpdatePointBar()
    
    return barId
end

function ThreePartBar.Destroy( barId )
    if ( ThreePartBarTracker[barId] ~= nil )
    then
        DestroyWindow( ThreePartBarTracker[barId].barName )
        ThreePartBarTracker[barId] = nil
    end
end

function ThreePartBar.Hide( barId )
    if ( ThreePartBarTracker[barId] ~= nil )
    then
        WindowSetShowing( ThreePartBarTracker[barId].barName, false )
    end
end

function ThreePartBar.Show( barId )
    if ( ThreePartBarTracker[barId] ~= nil )
    then
        WindowSetShowing( ThreePartBarTracker[barId].barName, true )
    end
end

function ThreePartBar.SetZone( barId, zone )
    if ( ThreePartBarTracker[barId] ~= nil )
    then
        ThreePartBarTracker[barId].zoneId = zone
        ThreePartBar.UpdateBar( barId )
    end
end

function ThreePartBar.OnZoneUpdated( zoneId )
    for barId, barData in pairs( ThreePartBarTracker )
    do
        if ( barData.zoneId == zoneId )
        then
            ThreePartBar.UpdateBar( barId )
        end
    end
end

function ThreePartBar.OnRewardPoolsUpdated()
    for barId, barData in pairs( ThreePartBarTracker )
    do
        if ( barData.mode == MODE_POOL_BARS )
        then
            ThreePartBar.UpdateBar( barId )
        end
    end
end

function ThreePartBar.UpdateBar( barId )
    local barData = ThreePartBarTracker[barId]
    if ( barData ~= nil )
    then
        local zoneData = GetCampaignZoneData( barData.zoneId )
        if ( zoneData == nil )
        then
            return
        end
        
        -- Update all of the values
        barData.controllingRealm = zoneData.controllingRealm
        if ( ( zoneData.tierId == 1 ) or ( zoneData.controllingRealm ~= GameData.Realm.NONE ) )
        then
            barData.mode       = MODE_REALM_BARS
            barData.leftValue  = zoneData.controlPoints[ GameData.Realm.ORDER ]
            barData.rightValue = zoneData.controlPoints[ GameData.Realm.DESTRUCTION ]
        else
            barData.mode = MODE_POOL_BARS
            barData.leftValue, barData.rightValue = GetRewardPools()
        end
        
        -- Update the Display
        barData:UpdatePointBar()
        
        -- Update the Lock
        WindowSetShowing( barData.barName.."Lock", zoneData.isLocked )
    end
end

function ThreePartBar.OnMouseoverCallback()
    local barId = WindowGetId( SystemData.ActiveWindow.name )
    if ( ThreePartBarTracker[barId] ~= nil )
    then
        local zoneData = GetCampaignZoneData( ThreePartBarTracker[barId].zoneId )
        if ( zoneData == nil ) 
        then
            return
        end
        
        local currentRow = 1

        -- First line: <realm> controls <zone>
        local realmName = GetRealmName( zoneData.controllingRealm )    
        local zoneName  = GetZoneName( zoneData.zoneId )

        -- (1) Control Info
        local controlString = GetStringFormatFromTable( "WorldControl", StringTables.WorldControl.LABEL_CONTROL, { realmName, zoneName } )
        
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
        Tooltips.SetTooltipText( currentRow, 1, controlString )
        Tooltips.SetTooltipColorDef( currentRow, 1, Tooltips.COLOR_HEADING )
        currentRow = currentRow + 1
        
        -- (2) Control Description
        if ( zoneData.tierId == 1 )
        then
            Tooltips.SetTooltipText( currentRow, 1, GetStringFromTable( "WorldControl", StringTables.WorldControl.TEXT_CONTROL_TIER1_DESCRIPTION ) )
            Tooltips.SetTooltipColorDef( currentRow, 1, Tooltips.COLOR_BODY )
            currentRow = currentRow + 1
        elseif ( zoneData.controllingRealm == GameData.Realm.NONE )
        then
            Tooltips.SetTooltipText( currentRow, 1, GetStringFromTable( "WorldControl", StringTables.WorldControl.TEXT_CONTROL_POOL_DESCRIPTION ) )
            Tooltips.SetTooltipColorDef( currentRow, 1, Tooltips.COLOR_BODY )
            currentRow = currentRow + 1
            Tooltips.SetTooltipText( currentRow, 1, GetStringFromTable( "WorldControl", StringTables.WorldControl.TEXT_CONTROL_POOL_DESCRIPTION2 ) )
            Tooltips.SetTooltipColorDef( currentRow, 2, Tooltips.COLOR_BODY )
            currentRow = currentRow + 1
            
            local winnerRewardPool, loserRewardPool, isNextShift, timeUntilShift = GetRewardPools()
            Tooltips.SetTooltipText( currentRow, 1, GetStringFromTable( "WorldControl", StringTables.WorldControl.TEXT_CONTROL_CURRENT_POOLS_DESC ) )
            Tooltips.SetTooltipColorDef( currentRow, 1, Tooltips.COLOR_BODY )
            Tooltips.SetTooltipText( currentRow, 2, GetStringFormatFromTable( "WorldControl", StringTables.WorldControl.TEXT_CONTROL_CURRENT_POOLS_DETAILS, { towstring(winnerRewardPool), towstring(loserRewardPool) } ) )
            Tooltips.SetTooltipColorDef( currentRow, 2, DefaultColor.GREEN )
            currentRow = currentRow + 1
            
            if ( isNextShift )
            then
                Tooltips.SetTooltipText( currentRow, 1, GetStringFromTable( "WorldControl", StringTables.WorldControl.TEXT_CONTROL_SHIFT_TIME_DESC ) )
                Tooltips.SetTooltipColorDef( currentRow, 1, Tooltips.COLOR_BODY )
                Tooltips.SetTooltipText( currentRow, 2, TimeUtils.FormatSeconds( timeUntilShift ) )
                Tooltips.SetTooltipColorDef( currentRow, 2, DefaultColor.GREEN )
                currentRow = currentRow + 1
            end
        end

        -- (3) Underdog section
        if ( zoneData.tierId >= 4 )
        then
            Tooltips.SetTooltipText( currentRow, 1, GetStringFromTable( "WorldControl", StringTables.WorldControl.TEXT_CONTROL_UNDERDOG_TITLE ) )
            Tooltips.SetTooltipColorDef( currentRow, 1, Tooltips.COLOR_HEADING )
            currentRow = currentRow + 1
            
            Tooltips.SetTooltipText( currentRow, 1, GetStringFromTable( "WorldControl", StringTables.WorldControl.TEXT_CONTROL_UNDERDOG_DESCRIPTION ) )
            Tooltips.SetTooltipColorDef( currentRow, 1, Tooltips.COLOR_BODY )
            currentRow = currentRow + 1
            
            local function SetThreeColumnTooltip( row, text1, color1, text2, color2, text3, color3 )
                Tooltips.SetTooltipText( row, 1, text1 )
                Tooltips.SetTooltipColorDef( row, 1, color1 )

                Tooltips.SetTooltipText( row, 2, text2 )
                Tooltips.SetTooltipColorDef( row, 2, color2 )

                Tooltips.SetTooltipText( row, 3, text3 )
                Tooltips.SetTooltipColorDef( row, 3, color3 )
            end
            
            -- Return the opposite of what the values are; formatting for passing into grammar func.
            local function GetSignParams( val )
                if ( val == 0 )
                then
                    return { towstring(val), towstring(STRING_ZERO_VALUE) }
                elseif ( val < 0 )
                then
                    return { towstring(-val), towstring(STRING_POSITIVE_VALUE) }
                else
                    return { towstring(val), towstring(STRING_NEGATIVE_VALUE) }
                end
            end
            
            local orderPoints, destPoints = GetUnderdogRatings()
            local orderText = GetStringFormatFromTable( "WorldControl", StringTables.WorldControl.TEXT_CONTROL_BONUS_UNDERDOG_ORDER_POINTS, GetSignParams( orderPoints ) )
            local destText = GetStringFormatFromTable( "WorldControl", StringTables.WorldControl.TEXT_CONTROL_BONUS_UNDERDOG_DESTRUCTION_POINTS, GetSignParams( destPoints ) )
            SetThreeColumnTooltip( currentRow,
                                   orderText, DefaultColor.LIGHT_GRAY,
                                   L"", DefaultColor.LIGHT_GRAY,
                                   destText, DefaultColor.LIGHT_GRAY )
            currentRow = currentRow + 1
            
            local pairingLockdownDescText = GetStringFromTable( "WorldControl", StringTables.WorldControl.TEXT_CONTROL_BONUS_UNDERDOG_PAIRING_LOCKDOWN )
            SetThreeColumnTooltip( currentRow,
                                   towstring(UNDERDOG_PAIRING_LOCKDOWN[orderPoints]), DefaultColor.BLUE,
                                   pairingLockdownDescText, DefaultColor.LIGHT_GRAY,
                                   towstring(UNDERDOG_PAIRING_LOCKDOWN[destPoints]), DefaultColor.RED )
            currentRow = currentRow + 1
        end

        Tooltips.Finalize()
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
    end
end