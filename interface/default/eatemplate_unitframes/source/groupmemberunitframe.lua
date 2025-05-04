-----------------------------------------------------------------------------
--
-- Local utility functions and lookup tables
--
-----------------------------------------------------------------------------

local UnitIdToGroupMemberMapping =
{
    ["GroupMember1"]  = { groupMemberIndex = 1 },
    ["GroupMember2"]  = { groupMemberIndex = 2 },
    ["GroupMember3"]  = { groupMemberIndex = 3 },
    ["GroupMember4"]  = { groupMemberIndex = 4 },
    ["GroupMember5"]  = { groupMemberIndex = 5 }
}

local FADE_OUT_ANIM_DELAY = 2

--
-- The window for the entire unit frame.  Most of it is created dynamically (aside from the anchoring)
-- but the portrait remains as part of the window definition for GroupMemberUnitFrame.
--

GroupMemberUnitFrame = Frame:Subclass ("GroupMemberUnitFrame")


--
-- Create a new instance of a GroupMemberUnitFrame and initialize it.
-- 
function GroupMemberUnitFrame:Create (windowName, unitId)    
    local newUnitFrame = self:CreateFromTemplate (windowName)
        
    if (newUnitFrame == nil)
    then
        return nil
    end
    
    newUnitFrame.m_unitId = unitId
    newUnitFrame.m_fadeOutAnimationDelay = 0
    newUnitFrame.m_isFadeIn = false -- Was the last fade a fade in (true) or a fade out (false)
    
    LabelSetText( newUnitFrame:GetName().."OfflineText", GetString( StringTables.Default.LABEL_PARTY_MEMBER_OFFLINE ) )
    LabelSetText( newUnitFrame:GetName().."DistantText", GetString( StringTables.Default.LABEL_PARTY_MEMBER_IS_DISTANT ) )
    StatusBarSetMaximumValue( newUnitFrame:GetName().."HealthPercentBar", 100 )
    StatusBarSetMaximumValue( newUnitFrame:GetName().."APPercentBar", 100 )
    CircleImageSetTexture( newUnitFrame:GetName().."Portrait", "render_scene_group_portrait"..UnitIdToGroupMemberMapping[unitId].groupMemberIndex, 40, 54 )
    WindowSetId( newUnitFrame:GetName().."Portrait", UnitIdToGroupMemberMapping[unitId].groupMemberIndex )
    -- Initially hide some of the arbitrary indicator widgets until updates are processed
    WindowSetShowing( newUnitFrame:GetName().."MoraleMini", false )
    WindowSetShowing( newUnitFrame:GetName().."GroupLeaderCrown", false)
    WindowSetShowing( newUnitFrame:GetName().."WarbandLeaderCrown", false)
    WindowSetShowing( newUnitFrame:GetName().."DeathPortrait", false )
    WindowSetShowing( newUnitFrame:GetName().."MainAssistCrown", false)
    WindowSetShowing( newUnitFrame:GetName().."OfflineText", false )
    WindowSetShowing( newUnitFrame:GetName().."DistantText", false )
    
    -- The text fields are never used, always hide them
    WindowSetShowing( newUnitFrame:GetName().."HealthText", false )
    WindowSetShowing( newUnitFrame:GetName().."APText", false )
    
    -- Create RvR Indicator
    newUnitFrame.m_RvRFrame = RvRIndicator:Create (newUnitFrame:GetName().."RvRFlagIndicator", newUnitFrame:GetName())
    newUnitFrame.m_RvRFrame:SetAnchor ({Point = "topleft", RelativePoint = "topleft", RelativeTo = newUnitFrame:GetName().."Portrait", XOffset = -15, YOffset = 25})
    newUnitFrame.m_RvRFrame:SetRelativeScale(.80)
    newUnitFrame.m_RvRFrame:SetTargetType(SystemData.TargetObjectType.ALLY_PLAYER)
    local buffAnchor = 
    {
        Point           = "bottomleft",
        RelativePoint   = "topleft",
        RelativeTo      = newUnitFrame:GetName().."APPercentBar", 
        XOffset         = 8,
        YOffset         = 4,
    }
    
    local groupIndex = UnitIdToGroupMemberMapping[unitId].groupMemberIndex
    
    GroupWindow.Buffs[groupIndex] = BuffTracker:Create ("Group"..groupIndex.."Buffs", "Root", buffAnchor, GameData.BuffTargetType.GROUP_MEMBER_START + (groupIndex - 1), 5, 5, HIDE_BUFF_FRAME_TIMER_LABELS)
    
    return newUnitFrame
end

function GroupMemberUnitFrame:Show ( bShow )
    self:ParentShow (bShow)
    
    if (self.m_unitId == nil)
    then
        -- Early out since data is invalid
        return
    end
    
    if (bShow == true)
    then
        if (GroupWindow.groupData[UnitIdToGroupMemberMapping[self.m_unitId].groupMemberIndex].isRVRFlagged == true)
        then
            self.m_RvRFrame:Show(true)
        else
            self.m_RvRFrame:Show(false)
        end
    else
        GroupWindow.Buffs[UnitIdToGroupMemberMapping[self.m_unitId].groupMemberIndex]:ClearAllBuffs()
        self.m_RvRFrame:Show(false)
    end
end

function GroupMemberUnitFrame:ShowHealthWindow ()
    local windowName = self:GetName()
    WindowSetShowing( windowName.."HealthPercentBar", true )
    WindowSetShowing( windowName.."HealthBarFrame", true )
    WindowSetShowing( windowName.."HealthBarBG", true )
    WindowSetShowing( windowName.."APPercentBar", true )
    WindowSetShowing( windowName.."APBarFrame", true )
    WindowSetShowing( windowName.."APBarBG", true )
end
function GroupMemberUnitFrame:HideHealthWindow ()
    local windowName = self:GetName()
    WindowSetShowing( windowName.."HealthPercentBar", false )
    WindowSetShowing( windowName.."HealthBarFrame", false )
    WindowSetShowing( windowName.."HealthBarBG", false )
    WindowSetShowing( windowName.."APPercentBar", false )
    WindowSetShowing( windowName.."APBarFrame", false )
    WindowSetShowing( windowName.."APBarBG", false )
end

function GroupMemberUnitFrame:UpdateVisibility()
    local groupMemberIndex = UnitIdToGroupMemberMapping[self.m_unitId].groupMemberIndex    
    local isStatusBarFull = ( GroupWindow.groupData[groupMemberIndex].healthPercent == 100 and 
                              GroupWindow.groupData[groupMemberIndex].actionPointPercent == 100 )
    local currentAlpha = WindowGetAlpha( self:GetName().."HealthBarFrame" )
    
    if ( not isStatusBarFull )
    then
        -- Status container should be shown. Fade it in (unless we're already in the process of fading it in)
        self.m_fadeOutAnimationDelay = 0
        if ( ( currentAlpha == 0.0 ) or ( ( currentAlpha < 1.0 ) and not self.m_isFadeIn ) )
        then
            self:ShowHealthWindow()
            self:PerformFadeIn( currentAlpha )
        end
    else
        -- Status container should be hidden. Fade it out (unless we're already in the process of fading it out, or already in the "delay" phase)
        if ( ( self.m_fadeOutAnimationDelay == 0 ) and ( ( currentAlpha == 1 ) or ( ( currentAlpha > 0.0 ) and self.m_isFadeIn ) ) )
        then
            self.m_fadeOutAnimationDelay = PlayerWindow.FADE_OUT_ANIM_DELAY
        end
    end
end

function GroupMemberUnitFrame:SetCareerIcon( careerLine )
    local texture, x, y = GetIconData( Icons.GetCareerIconIDFromCareerLine( careerLine ) )
    DynamicImageSetTexture( self:GetName().."CareerIcon", texture, x, y )
end

function GroupMemberUnitFrame:ShowCareerIcon( show )
    WindowSetShowing( self:GetName().."CareerIcon", show )
end

--
-- Update a unit frame from its unitId information.
--
function GroupMemberUnitFrame:SetName (groupMemberName, extraText)
    local labelText = groupMemberName
    if( extraText )
    then
        labelText = labelText..extraText
    end
    LabelSetText( self:GetName().."Name", labelText )
    
    -- Setting the Game Action so that clicking on the window will target this player.
    WindowSetGameActionData( self:GetName(), GameData.PlayerActions.SET_TARGET, 0, groupMemberName )
end
function GroupMemberUnitFrame:UpdateHealth (newHealthVal)
   local groupMemberIndex = UnitIdToGroupMemberMapping[self.m_unitId].groupMemberIndex
    GroupWindow.groupData[groupMemberIndex].healthPercent = newHealthVal
    StatusBarSetCurrentValue( self:GetName().."HealthPercentBar", newHealthVal )
    
    -- Flash the HP bar when it's under 20%
    if( GroupWindow.groupData[groupMemberIndex].healthPercent < 20 ) then
        if( GroupWindow.hitPointAlerts[groupMemberIndex] == false ) then
            WindowSetShowing( "GroupWindowPlayer"..groupMemberIndex.."HealthPercentBar", true )
            WindowStartAlphaAnimation( "GroupWindowPlayer"..groupMemberIndex.."HealthPercentBar", Window.AnimationType.LOOP, 0.5, 1.0, 0.5, false, 0, 0 )
            GroupWindow.hitPointAlerts[groupMemberIndex] = true
        end
    else
        if( GroupWindow.hitPointAlerts[groupMemberIndex] == true ) then
            WindowStopAlphaAnimation( "GroupWindowPlayer"..groupMemberIndex.."HealthPercentBar")
            GroupWindow.hitPointAlerts[groupMemberIndex] = false
        end
    end
    
    self:UpdateVisibility()
end
function GroupMemberUnitFrame:UpdateActionPoints (newActionPoints)
    local groupMemberIndex = UnitIdToGroupMemberMapping[self.m_unitId].groupMemberIndex
    GroupWindow.groupData[groupMemberIndex].actionPointPercent = newActionPoints
    StatusBarSetCurrentValue( self:GetName().."APPercentBar", newActionPoints )
    
    self:UpdateVisibility()
end

function GroupMemberUnitFrame:UpdateInSameRegion (isInSameRegion, newHealthVal, onlineStatus)
    local groupMemberIndex = UnitIdToGroupMemberMapping[self.m_unitId].groupMemberIndex
    if( newHealthVal <= 0 and onlineStatus == true ) then
        if( WindowGetShowing("GroupWindowPlayer"..groupMemberIndex.."DeathPortrait") == false ) then
            WindowSetShowing( "GroupWindowPlayer"..groupMemberIndex.."DeathPortrait", true )
            WindowSetShowing( "GroupWindowPlayer"..groupMemberIndex.."Portrait", false )
        end
    else
        if(WindowGetShowing("GroupWindowPlayer"..groupMemberIndex.."Portrait") == false ) then
            WindowSetShowing( "GroupWindowPlayer"..groupMemberIndex.."DeathPortrait", false )
            WindowSetShowing( "GroupWindowPlayer"..groupMemberIndex.."Portrait", true )
        end
    end

end

function GroupMemberUnitFrame:UpdateLevel( level, battleLevel )
    local windowName = self:GetName ()
    
    local color = PartyUtils.GetLevelTextColor( level, battleLevel )
    
    LabelSetText( windowName.."LevelText", L""..battleLevel )
    LabelSetTextColor( windowName.."LevelText", color.r, color.g, color.b )
end

function GroupMemberUnitFrame:UpdateRVRFlag (isFlagged)
    self.m_RvRFrame:Show(isFlagged)
end

function GroupMemberUnitFrame:UpdateOnlineStatus (isOnline)
    WindowSetShowing( self:GetName().."OfflineText", not isOnline )
    if( isOnline )
    then
        self:SetAlpha( 1.0 )
        WindowSetFontAlpha( self:GetName(), 1.0 )
    else
        self:SetAlpha( 0.5 )
        WindowSetFontAlpha( self:GetName(), 0.5 )
        WindowSetShowing( self:GetName().."DistantText", false )
        WindowSetTintColor( self:GetName(), 255, 255, 255 )
    end
end

function GroupMemberUnitFrame:UpdateDistantStatus( isDistant )
    local isOffline = WindowGetShowing( self:GetName().."OfflineText" )
    if( isDistant and not isOffline )
    then
        WindowSetShowing( self:GetName().."DistantText", true )
        WindowSetTintColor( self:GetName(), 100, 100, 200 )        
    else
        WindowSetShowing( self:GetName().."DistantText", false )
        WindowSetTintColor( self:GetName(), 255, 255, 255 )
    end
end

function GroupMemberUnitFrame:Update (elapsedTime)
    if (elapsedTime == nil) then
        return
    end
    local groupMemberIndex = UnitIdToGroupMemberMapping[self.m_unitId].groupMemberIndex
    
    if (self.m_fadeOutAnimationDelay > 0) then
        if ( WindowGetAlpha( self:GetName().."HealthBarFrame" ) == 1.0 ) -- Don't begin fade out delay until status container is fully shown
        then
            self.m_fadeOutAnimationDelay = self.m_fadeOutAnimationDelay - elapsedTime
            if ( self.m_fadeOutAnimationDelay <= 0 )
            then
                self:PerformFadeOut()
            end
        end
    end
    
    GroupWindow.Buffs[groupMemberIndex]:Update (elapsedTime)
end

function GroupMemberUnitFrame:PerformFadeIn( currentAlpha )
    -- Fade Bars in
    self.m_fadeOutAnimationDelay = 0
    self.m_isFadeIn = true
    WindowStartAlphaAnimation( self:GetName().."HealthPercentBar", Window.AnimationType.SINGLE_NO_RESET, currentAlpha, 1.0, 0.5, false, 0, 0 )
    WindowStartAlphaAnimation( self:GetName().."HealthBarFrame", Window.AnimationType.SINGLE_NO_RESET, currentAlpha, 1.0, 0.5, false, 0, 0 )
    WindowStartAlphaAnimation( self:GetName().."HealthBarBG", Window.AnimationType.SINGLE_NO_RESET, currentAlpha, 1.0, 0.5, false, 0, 0 )
    WindowStartAlphaAnimation( self:GetName().."APPercentBar", Window.AnimationType.SINGLE_NO_RESET, currentAlpha, 1.0, 0.5, false, 0, 0 )
    WindowStartAlphaAnimation( self:GetName().."APBarFrame", Window.AnimationType.SINGLE_NO_RESET, currentAlpha, 1.0, 0.5, false, 0, 0 )
    WindowStartAlphaAnimation( self:GetName().."APBarBG", Window.AnimationType.SINGLE_NO_RESET, currentAlpha, 1.0, 0.5, false, 0, 0 )
end
function GroupMemberUnitFrame:PerformFadeOut()
    -- Fade Bars out
    self.m_fadeOutAnimationDelay = 0
    self.m_isFadeIn = false
    WindowStartAlphaAnimation( self:GetName().."HealthPercentBar", Window.AnimationType.SINGLE_NO_RESET_HIDE, 1.0, 0.0, 2.0, false, 0, 0 )
    WindowStartAlphaAnimation( self:GetName().."HealthBarFrame", Window.AnimationType.SINGLE_NO_RESET_HIDE, 1.0, 0.0, 2.0, false, 0, 0 )
    WindowStartAlphaAnimation( self:GetName().."HealthBarBG", Window.AnimationType.SINGLE_NO_RESET_HIDE, 1.0, 0.0, 2.0, false, 0, 0 )
    WindowStartAlphaAnimation( self:GetName().."APPercentBar", Window.AnimationType.SINGLE_NO_RESET_HIDE, 1.0, 0.0, 2.0, false, 0, 0 )
    WindowStartAlphaAnimation( self:GetName().."APBarFrame", Window.AnimationType.SINGLE_NO_RESET_HIDE, 1.0, 0.0, 2.0, false, 0, 0 )
    WindowStartAlphaAnimation( self:GetName().."APBarBG", Window.AnimationType.SINGLE_NO_RESET_HIDE, 1.0, 0.0, 2.0, false, 0, 0 )
end
--
-- Generic RButtonUp event handler for GroupMemberUnitFrame
--
function GroupMemberUnitFrame.OnRButtonUp (flags, x, y)
    local unitFrame = FrameManager:GetActiveWindow ()
    if (unitFrame ~= nil)
    then
        local groupMemberName = LabelGetText(unitFrame:GetName().."Name")
        local isOffline = WindowGetShowing( unitFrame:GetName().."OfflineText" )
        GroupWindow.ShowMenu( groupMemberName, isOffline )
    end
end

--
-- Generic LButtonUp event handler for GroupMemberUnitFrame
--
function GroupMemberUnitFrame.OnLButtonUp (flags, x, y)
    local unitFrame = FrameManager:GetActiveWindow ()
    if (unitFrame ~= nil)
    then
        -- Targeting is handled by the WindowSetGameActionData() call.
        if( GetDesiredInteractAction() == SystemData.InteractActions.TELEPORT )
        then
            UseItemTargeting.SendTeleport()
        end
    end
end

--
-- Generic MouseOver event handler for GroupMemberUnitFrame
--
function GroupMemberUnitFrame.OnMouseOver (flags, x, y)
    local unitFrame = FrameManager:GetActiveWindow ()
    
    if (unitFrame ~= nil)
    then
        local groupMemberName = LabelGetText(unitFrame:GetName().."Name")
        local actiontext = GetString( StringTables.Default.TEXT_R_CLICK_TO_OPEN_GROUP_MENU )
        
        local player = GroupWindow.groupData[UnitIdToGroupMemberMapping[unitFrame.m_unitId].groupMemberIndex]
        
        Tooltips.CreateTextOnlyTooltip( unitFrame:GetName() )
        Tooltips.SetTooltipText( 1, 1, player.name )
        Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
        local levelString = PartyUtils.GetLevelText( player.level, player.battleLevel )
        Tooltips.SetTooltipText( 2, 1, GetStringFormat( StringTables.Default.LABEL_RANK_X, { levelString } ) )
        Tooltips.SetTooltipText( 3, 1, GetStringFormatFromTable("HUDStrings", StringTables.HUD.LABEL_HUD_PLAYER_WINDOW_TOOLTIP_CAREER_NAME, {player.careerName}) )
        Tooltips.SetTooltipText( 4, 1, GetZoneName( player.zoneNum ) )
        if( player.isRVRFlagged )
        then
            Tooltips.SetTooltipText( 5, 1, GetStringFromTable("HUDStrings", StringTables.HUD.LABEL_PLAYER_IS_RVR_FLAGGED) )
        end
        
        Tooltips.Finalize()
        local anchor = { Point = "bottomright",  RelativeTo = unitFrame:GetName().."Portrait", RelativePoint = "topleft",   XOffset = -5, YOffset = -5 }
        Tooltips.AnchorTooltip( anchor ) 
    end
end
