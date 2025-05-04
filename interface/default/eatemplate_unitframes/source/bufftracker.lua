--
-- The core unit of the buff tracker, the BuffFrame.
-- Contains information about a single effect, subclassed from
-- a Frame.
--

SHOW_BUFF_FRAME_TIMER_LABELS = true
HIDE_BUFF_FRAME_TIMER_LABELS = false

local BUFF_FADE_START           = 10    -- The time remaining on a buff at which the buff begins to fade out
local BUFF_TOOLTIP_UPDATE_ALL   = true  -- update all fields in the buff tooltip 
local BUFF_TOOLTIP_UPDATE_TIME  = false -- only update the time field in the buff tooltip
local g_currentMouseOverBuff    = nil   -- Used to update the current buff tooltip...


local function IsValidBuff( buffData )
    return ( buffData ~= nil and buffData.effectIndex ~= nil and buffData.iconNum ~= nil and buffData.iconNum > 0 )
end


BuffFrame = Frame:Subclass( "BuffIcon" )

function BuffFrame:Create( windowName, parentWindow, buffSlot, buffTargetType, showTimerLabels )
    local buffFrame = self:CreateFromTemplate( windowName, parentWindow )

    if ( buffFrame ~= nil )
    then
        buffFrame.m_buffSlot            = buffSlot          -- Window slot number
        buffFrame.m_buffData            = nil               -- Buff data
        buffFrame.m_buffTargetType      = buffTargetType
        buffFrame.m_lastDurationUpdate  = 0
        buffFrame.m_IsFading            = false
        buffFrame.m_IsTrackerShowing    = true

        buffFrame:ShowBuffTimerLabel( showTimerLabels )
    end

    return buffFrame
end

function BuffFrame:Update( force )
    local buffData = self.m_buffData
    if ( not IsValidBuff( buffData ) )
    then
        return
    end

    local flooredDuration = math.floor( buffData.duration )
    if ( flooredDuration ~= self.m_lastDurationUpdate or force )
    then
        if ( buffData.stackCount <= 1 )
        then
            if ( buffData.permanentUntilDispelled )
            then
                LabelSetText( self:GetName().."Timer", L"" )
            else
                local timeLabel = TimeUtils.FormatTimeCondensed( buffData.duration )
                LabelSetText( self:GetName().."Timer", timeLabel )
            end
        end

        if ( not buffData.permanentUntilDispelled and
             buffData.duration < BUFF_FADE_START )
        then
            self:StartFading()
        else
            self:StopFading()
        end

        self.m_lastDurationUpdate = flooredDuration
    end
end

function BuffFrame:StopFading()
    if ( self.m_IsFading == true )
    then
        WindowStopAlphaAnimation( self:GetName() )
        self.m_IsFading = false
    end
end

function BuffFrame:StartFading()
    if ( self.m_IsFading == false )
    then
        WindowStartAlphaAnimation( self:GetName(), Window.AnimationType.LOOP, 1, 0.5, 1, true, 0, 0 )
        self.m_IsFading = true
    end
end

function BuffFrame:SetBuff( buffData )
    self.m_buffData = buffData

    local isValidBuff = IsValidBuff( buffData )
    if ( isValidBuff )
    then
        local windowName = self:GetName ()

        local texture, x, y = GetIconData( buffData.iconNum )
        DynamicImageSetTexture( windowName.."IconBase", texture, x, y )
        WindowSetAlpha( windowName, 1.0 )
        WindowSetFontAlpha( windowName, 1.0 )

        local buffSlice, buffTexDimsX, buffTexDimsY, buffRed, buffGreen, buffBlue = DataUtils.GetAbilityTypeTextureAndColor( buffData )

        if ( buffSlice and buffSlice ~= "" and buffSlice ~= self.m_CurrentSlice )
        then
        -- TODO: Fix this. Currently this puts obstacles in the way of a customizable buff tracker.
            local verticalSlop = 3
            DynamicImageSetTextureSlice( windowName.."Frame", buffSlice )
            WindowSetDimensions( windowName.."Frame", (buffTexDimsX / 2), (buffTexDimsY / 2) + verticalSlop )
            DynamicImageSetTextureDimensions( windowName.."Frame", buffTexDimsX, buffTexDimsY )

            self.m_CurrentSlice = buffSlice
        end

        if ( buffRed and buffGreen and buffBlue )
        then
            WindowSetTintColor( windowName.."Frame", buffRed, buffGreen, buffBlue )
        else
            WindowSetTintColor( windowName.."Frame", 255, 255, 255 )
        end

        if ( buffData.stackCount > 1 )
        then
            -- TODO: Localize if necessary
            LabelSetText( self:GetName().."Timer", L"x"..buffData.stackCount )
            WindowSetShowing( self:GetName().."Timer", true )
        else
            WindowSetShowing( self:GetName().."Timer", (self.m_ShowingTimerLabels == SHOW_BUFF_FRAME_TIMER_LABELS) )
        end

        self:Update( true )
    end

    self:Show( isValidBuff and self.m_IsTrackerShowing )
end

function BuffFrame:ShowBuffTimerLabel( showType )
    self.m_ShowingTimerLabels = showType
    WindowSetShowing( self:GetName().."Timer", (showType == SHOW_BUFF_FRAME_TIMER_LABELS) )
end

function BuffFrame.OnMouseOver()
    local buffFrame = FrameManager:GetMouseOverWindow()
    if ( buffFrame == nil )
    then
        return
    end
    
    local buffData = buffFrame.m_buffData
    if ( IsValidBuff( buffData ) )
    then
        -- Point the current mouse over buff at the frame, the frame will always exist.
        -- The frame's data may be cleared at any point in time...this way the update
        -- can always query the frame for its data, rather than directly referring to the data...
        g_currentMouseOverBuff = buffFrame

        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil )
        Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
        Tooltips.SetTooltipColorDef( 1, 2, Tooltips.COLOR_HEADING )
        Tooltips.SetTooltipActionText( GetString( StringTables.Default.TEXT_R_CLICK_TO_REMOVE_EFFECT ) )

        BuffFrame.PopulateTooltipFields( buffData, BUFF_TOOLTIP_UPDATE_ALL )

        local tooltipAnchor = { Point = "bottom",  RelativeTo = SystemData.ActiveWindow.name, RelativePoint = "top",   XOffset = 0, YOffset = 20 }

        Tooltips.AnchorTooltip( tooltipAnchor )
        Tooltips.SetUpdateCallback( BuffFrame.MouseOverUpdate )
    end
end

function BuffFrame.OnMouseOverEnd()
    g_currentMouseOverBuff = nil
end

function BuffFrame.OnRButtonUp()
    local buffFrame = FrameManager:GetActiveWindow()
    if ( buffFrame == nil )
    then
        return
    end

    -- Only the player is allowed to attempt to remove buffs from itself.
    if ( buffFrame.m_buffTargetType ~= GameData.BuffTargetType.SELF )
    then
        return
    end

    local buffData = buffFrame.m_buffData
    if ( IsValidBuff( buffData ) )
    then
        RemoveEffect( buffData.effectIndex )
    end
end

function BuffFrame.PopulateTooltipFields( buffData, updateType )
    if ( updateType == BUFF_TOOLTIP_UPDATE_ALL )
    then
        Tooltips.SetTooltipText( 1, 1, buffData.name )
        Tooltips.SetTooltipText( 3, 1, buffData.effectText )

        -- buffData is not an abilityData, but the fields required by this function should be present...
        Tooltips.SetTooltipText( 1, 2, DataUtils.GetAbilityTypeText( buffData ) )
    end

    if ( not buffData.permanentUntilDispelled )
    then
        -- As long as we only update the buff text label when ever the floor value of buffData.duration
        -- changes, we also need to clamp the value here, or it will update at different times.
        local ceilingDuration = math.ceil( buffData.duration )
        local durationText = TimeUtils.FormatTimeCondensed( ceilingDuration )
        Tooltips.SetTooltipText( 2, 1, durationText )
    else
        Tooltips.SetTooltipText( 2, 1, L"" )
    end

    Tooltips.Finalize()
end

function BuffFrame.MouseOverUpdate()
    if ( g_currentMouseOverBuff == nil )
    then
        return
    end

    local buffData = g_currentMouseOverBuff.m_buffData
    if ( IsValidBuff( buffData ) )
    then
        BuffFrame.PopulateTooltipFields( buffData, BUFF_TOOLTIP_UPDATE_TIME )
    end
end


--
-- Generic BuffTracker for Lua, hopefully going to be sharable between
-- all unit frames...but hey, this is the first cut, so who knows what will happen?
--

--
-- The BuffTracker wraps access to GetBuffs.  It should remain unit-agnostic.
-- All the systems that track unit buffs should utilize this as the effects container
-- as it will provide the mapping from the GameData.BuffTargetType.* and WindowId
-- to the actual buff/effect table necessary for displaying buff information.
--

BuffTracker = {}
BuffTracker.__index = BuffTracker

function BuffTracker:Create( windowName, parentName, initialAnchor, buffTargetType, maxBuffCount, buffRowStride, showTimerLabels )
    local newTracker =
    {
        m_buffData      = {},               -- Contains buff/effect data. Indexed by server effect id.
        m_buffMapping   = {},               -- Contains window id -> buff id mapping.
        m_targetType    = buffTargetType,   -- How this tracker knows which unit to query for buff/effects information...
        m_maxBuffs      = maxBuffCount,     -- How many windows this bufftracker creates...
        m_buffFrames    = {},
        m_buffRowStride = buffRowStride,    -- Number of buffs per row
    }

    local currentAnchor = initialAnchor

    for buffSlot = 1, maxBuffCount
    do
        local buffFrameName = windowName..buffSlot
        local buffFrame     = BuffFrame:Create( buffFrameName, parentName, buffSlot, buffTargetType, showTimerLabels )

        if ( buffFrame ~= nil )
        then
            newTracker.m_buffFrames[ buffSlot ] = buffFrame

            buffFrame:SetAnchor( currentAnchor )

            local nextSlot  = buffSlot + 1
            local remainder = math.fmod( nextSlot, buffRowStride )

            if ( remainder == 1 )
            then
                currentAnchor.Point             = "bottomleft"
                currentAnchor.RelativePoint     = "topleft"
                currentAnchor.RelativeTo        = windowName..( nextSlot - buffRowStride )
                currentAnchor.XOffset           = 0
                currentAnchor.YOffset           = 24 -- vertical buff spacing between rows...parameterize?
            else
                currentAnchor.Point             = "right"
                currentAnchor.RelativePoint     = "left"
                currentAnchor.RelativeTo        = windowName..buffSlot
                currentAnchor.XOffset           = 2 -- horizontal buff spacing between columns...parameterize?
                currentAnchor.YOffset           = 0
            end
        end
    end

    newTracker = setmetatable( newTracker, self )
    newTracker.__index = self

    -- Load all buffs now.
    newTracker:Refresh()

    return newTracker
end

function BuffTracker:Shutdown()
    for buffSlot, buffFrame in ipairs( self.m_buffFrames )
    do
        buffFrame:Destroy()
    end
end

function BuffTracker:Show( showState )
    for _, buffFrame in ipairs( self.m_buffFrames )
    do
        buffFrame.m_IsTrackerShowing = showState
        buffFrame:Show( showState and IsValidBuff( buffFrame.m_buffData ) )
    end
end

function BuffTracker:ClearAllBuffs()
    -- Clear our data.
    self.m_buffData = {}
    self:OnBuffsChanged()
end

function BuffTracker:UpdateBuffs( updatedBuffsTable, isFullList )
    -- updatedBuffsTable can either be a full or differential table (i.e. contain all buffs, or only contain entries that have changed).
    -- isFullList will be true if it is a full table, or false if it is differential.
    -- updatedBuffsTable will take the form (for each buff): updatedBuffsTable[ EFFECT INDEX ] = { EFFECT DATA }
    -- For differential "remove" entries, [ EFFECT DATA ] will be an empty table.
    if( not updatedBuffsTable )
    then
        return
    end
    
    if ( isFullList )
    then
        -- This is a full update, so we'll clear first.
        self.m_buffData = {}
    end

    -- Apply the update.
    for buffId, buffData in pairs( updatedBuffsTable )
    do
        if ( IsValidBuff( buffData ) )
        then
            -- Place the valid buff in the table.
            self.m_buffData[ buffId ] = buffData
        elseif ( not isFullList )
        then
            -- This buff isn't valid, so it's probably an empty table,
            -- signaling us to remove it.
            self.m_buffData[ buffId ] = nil
        end
    end

    self:OnBuffsChanged()
end

function BuffTracker:Refresh()
    -- Get the full list of buffs from native code.
    local allBuffs = GetBuffs( self.m_targetType )
    if ( allBuffs ~= nil )
    then
        self.m_buffData = allBuffs
    else
        self.m_buffData = {}
    end

    self:OnBuffsChanged()
end

local BuffSortKeys =
{
    ["permanentUntilDispelled"]     = { fallback = "name" },
    ["name"]                        = {}
}

local function SortBuffs( buff1, buff2 )
    if ( buff1.trackerPriority and buff2.trackerPriority ) and ( buff1.trackerPriority ~= buff2.trackerPriority )
    then
        return buff1.trackerPriority > buff2.trackerPriority
    else
        return DataUtils.OrderingFunction( buff1, buff2, "permanentUntilDispelled", BuffSortKeys, DataUtils.SORT_ORDER_UP )
    end

end

function BuffTracker:OnBuffsChanged()
    -- Our buff data is a map-type container, not an array.
    -- So we'll make a table of the data for sorting.
    local sortedBuffData = {}

    -- Fill the table.
    for _, buffData in pairs( self.m_buffData )
    do
        table.insert( sortedBuffData, buffData )
    end

    -- Sort the table.
    table.sort( sortedBuffData, SortBuffs )

    -- Propagate the buff data to the BuffFrames.
    local maxBuffIndex = #sortedBuffData
    for buffSlot, buffFrame in ipairs( self.m_buffFrames )
    do
        if ( buffSlot <= maxBuffIndex )
        then
            buffFrame:SetBuff( sortedBuffData[ buffSlot ] )
        else
            buffFrame:SetBuff( nil )
        end
    end

    -- Calculate and cache our visible row count.
    self.m_VisibleRowCount = self:GetVisibleRowCount( maxBuffIndex )
end

function BuffTracker:Update( elapsedTime )
    -- Update all buffs.
    for buffId, buffData in pairs( self.m_buffData )
    do
        if ( IsValidBuff( buffData ) )
        then
            if ( buffData.duration >= elapsedTime )
            then
                buffData.duration = buffData.duration - elapsedTime
            else
                buffData.duration = 0
            end
        end
    end

    -- Update all buff frames.
    for buffSlot, buffFrame in ipairs( self.m_buffFrames )
    do
        buffFrame:Update( false )
    end
end

function BuffTracker:GetVisibleRowCount( buffTableEntryCount )
    if ( buffTableEntryCount == nil )
    then
        return self.m_VisibleRowCount or 0
    end

    return math.ceil( math.min( buffTableEntryCount, self.m_maxBuffs) / self.m_buffRowStride )
end

function BuffTracker:GetRowStride()
    return self.m_buffRowStride
end

function BuffTracker:ShowBuffTimerLabels( showType )
    if ( self.m_BuffLabelShowType ~= showType )
    then
        self.m_BuffLabelShowType = showType

        for _, buffFrame in ipairs( self.m_buffFrames )
        do
            buffFrame:ShowBuffTimerLabel( showType )
        end
    end
end
