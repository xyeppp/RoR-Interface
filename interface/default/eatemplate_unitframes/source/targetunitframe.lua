-----------------------------------------------------------------------------
--
-- Local utility functions and lookup tables
--
-----------------------------------------------------------------------------

local UnitIdToBuffTargetMapping =
{
    ["selfhostiletarget"]   = { buffTarget = GameData.BuffTargetType.TARGET_HOSTILE,    healthColor = { r = 255, g = 0, b = 0 } },
    ["selffriendlytarget"]  = { buffTarget = GameData.BuffTargetType.TARGET_FRIENDLY,   healthColor = { r = 0, g = 255, b = 0 } }
}

local ConTierToSkullAnchorMapping =
{
    -- # refers to the number of skulls to be shown for this threat level
    ["ThreatLevel1"]    =   { 
                                ["Skull1"] = {Point = "bottom",  RelativeTo = "PortraitFrame", RelativePoint = "bottom", XOffset = 0, YOffset = 0},
                            },
    ["ThreatLevel2"]    =   { 
                                ["Skull1"] = {Point = "bottom",  RelativeTo = "PortraitFrame", RelativePoint = "bottom", XOffset = -10, YOffset = -3},
                                ["Skull2"] = {Point = "bottom",  RelativeTo = "PortraitFrame", RelativePoint = "bottom", XOffset = 10, YOffset = -3},
                            },
    ["ThreatLevel3"]    =   { 
                                ["Skull1"] = {Point = "bottom",  RelativeTo = "PortraitFrame", RelativePoint = "bottom", XOffset = 0, YOffset = 0},
                                ["Skull2"] = {Point = "center",  RelativeTo = "Skull1", RelativePoint = "center", XOffset = -20, YOffset = -5},
                                ["Skull3"] = {Point = "center",  RelativeTo = "Skull1", RelativePoint = "center", XOffset = 20, YOffset = -5},
                            },
    ["ThreatLevel4"]    =   {
                                ["Skull1"] = {Point = "bottom",  RelativeTo = "PortraitFrame", RelativePoint = "bottom", XOffset = -25, YOffset = -10},
                                ["Skull2"] = {Point = "bottom",  RelativeTo = "PortraitFrame", RelativePoint = "bottom", XOffset = -10, YOffset = -3},
                                ["Skull3"] = {Point = "bottom",  RelativeTo = "PortraitFrame", RelativePoint = "bottom", XOffset = 10, YOffset = -3},
                                ["Skull4"] = {Point = "bottom",  RelativeTo = "PortraitFrame", RelativePoint = "bottom", XOffset = 25, YOffset = -10}
                            }
}

local FRIENDLY_UNIT     = true
local HOSTILE_UNIT      = false

local UnitStatusInfo =
{
    [FRIENDLY_UNIT]     =   {
                                NameColor = {r = DefaultColor.NAME_COLOR_PLAYER.r, g = DefaultColor.NAME_COLOR_PLAYER.g, b = DefaultColor.NAME_COLOR_PLAYER.b},
                                TextAlignment = "leftcenter",
                                Anchor = {Point = "topleft", RelativePoint = "topleft", XOffset = 0, YOffset = 3},
                                MirrorTexture = false,
                                LevelTextColor = DefaultColor.WHITE
                            },
                            
    [HOSTILE_UNIT]      =   {
                                NameColor = {r = DefaultColor.NAME_COLOR_THREAT.r, g = DefaultColor.NAME_COLOR_THREAT.g, b = DefaultColor.NAME_COLOR_THREAT.b},
                                TextAlignment = "rightcenter",
                                Anchor = {Point = "topright", RelativePoint = "center", XOffset = -103, YOffset = 66},
                                MirrorTexture = true,
                                LevelTextColor = DefaultColor.BLACK
                            
                            }
}

local HostileUnitSigilDisplayInfo = {}

local c_MAX_BUFF_COUNT  = 12
local c_BUFF_ROW_STRIDE = 4

--
-- Holds the name, health bar, (mana bar?), con, con level text, hero class info, etc....you know, status.
-- Does NOT hold the buff information, or the level information, since that's a little image that hangs off the portrait frame
--
TargetUnitFrameStatus = Frame:Subclass ("TargetUnitFrameStatusContainer")

function TargetUnitFrameStatus:Create (windowName, parentName, statusAnchor, isFriendly)
    local newStatusContainer = self:CreateFromTemplate (windowName, parentName)
    
    if (newStatusContainer == nil)
    then
        return nil
    end
        
    if (isFriendly) then
        newStatusContainer.m_HealthBar = UnitFrameFriendlyStatusBar:Create (windowName.."HealthPercentBar", windowName)
        newStatusContainer.m_HealthBar:SetAnchor ({Point = "topleft", RelativePoint = "topleft", RelativeTo = windowName.."HealthBarBG", XOffset = 11, YOffset = 4})
    else        
        newStatusContainer.m_HealthBar = UnitFrameHostileStatusBar:Create (windowName.."HealthPercentBar", windowName)
        newStatusContainer.m_HealthBar:SetAnchor ({Point = "topleft", RelativePoint = "topleft", RelativeTo = windowName.."HealthBarBG", XOffset = 5, YOffset = 4})
        LabelSetTextAlign (windowName.."TierLabel", "rightcenter")
    end
    
    -- Just to let everyone know where it comes from and force an initial update...
    newStatusContainer.m_HealthColor    = nil 
    newStatusContainer.m_NameColor      = nil    

    newStatusContainer:SetAnchor (statusAnchor)
    newStatusContainer:Show (true) -- So that it shows and hides with its parent.
    
    return newStatusContainer
end

function TargetUnitFrameStatus:UpdateUnitName (unitName, nameColor)
    local labelName = self:GetName ().."Name"
    
    if (self.m_NameColor ~= nameColor)
    then
        LabelSetTextColor (labelName, nameColor.r, nameColor.g, nameColor.b)
    end

    LabelSetText (labelName, GetStringFormatFromTable("HUDStrings", StringTables.HUD.LABEL_HUD_TARGET_UNIT_NAME, {unitName}))
end

function TargetUnitFrameStatus:UpdateUnitCon (conName, conColor, showCon)
    local windowName = self:GetName ()

    WindowSetShowing (windowName.."ConLabel", showCon)
    LabelSetTextColor (windowName.."ConLabel", conColor.r, conColor.g, conColor.b)
    LabelSetText (windowName.."ConLabel", conName)
end

local function AlterColor (color, changePercentage)
    changePercentage = changePercentage or 0
    local newColor = { r = color.r, g = color.g, b = color.b }
    
    for k, v in pairs (color)
    do
        v = v + (v * changePercentage)
        if (v < 0) then v = 0 end
        if (v > 255) then v = 255 end
        
        newColor[k] = v
    end
    
    return newColor
end

function TargetUnitFrameStatus:SetUnitHealth (health, healthColor, showHealth)
    if (self.m_HealthBar:Show (showHealth) == false)
    then
        return
    end
        
    self.m_HealthBar:SetValue (health)
end

function TargetUnitFrameStatus:StopInterpolating()
    self.m_HealthBar:StopInterpolating()
end

function TargetUnitFrameStatus:UpdateUnitTier (unitTier, textAlign)
    LabelSetText (self:GetName ().."TierLabel", unitTier)
    LabelSetTextAlign (self:GetName().."TierLabel", textAlign)
end

--
-- The window for the entire unit frame.  Most of it is created dynamically (aside from the anchoring)
-- but the portrait remains as part of the window definition for TargetUnitFrame.
--

TargetUnitFrame = Frame:Subclass ("TargetUnitFrame")

--
-- Create a new instance of a TargetUnitFrame and initialize it.
-- 
function TargetUnitFrame:Create (windowName, unitId)    
    local newUnitFrame = self:CreateFromTemplate (windowName)
        
    if (newUnitFrame == nil)
    then
        return nil
    end

    newUnitFrame.m_AlwaysShowHitPoints  = false
    newUnitFrame.m_UnitId               = unitId
    newUnitFrame.m_Type                 = 0
    newUnitFrame.m_IsAStaticObject      = false
    newUnitFrame.m_IsThePlayer          = false 
    newUnitFrame.m_IsFriendly           = unitId == "selffriendlytarget"
    
    --
    -- Create the dynamic frames...
    --
    
    -- Create Status Frame
    
    local portraitWindow = windowName.."PortraitFrame"
    local careerIconWindow = windowName.."CareerIcon"
    
    local statusAnchor      = 
        {
            Point           = "left", 
            RelativePoint   = "right", 
            RelativeTo      = portraitWindow, 
            XOffset         = 2, 
            YOffset         = -4,
        }
    
    if (newUnitFrame.m_IsFriendly) then
        statusAnchor.XOffset = 18
    end

    -- Depending on whether or not the unit is a friendly or a hostile, the anchoring changes....
    -- Friendlies look like the player unit frame, hostiles look like the oldschool target frame.
    if (newUnitFrame.m_IsFriendly)
    then
        WindowClearAnchors (portraitWindow)
        WindowAddAnchor (portraitWindow, "topleft", windowName, "topleft", 0, 0)
        
        statusAnchor.Point, statusAnchor.RelativePoint = statusAnchor.RelativePoint, statusAnchor.Point
        statusAnchor.XOffset = -statusAnchor.XOffset
        
        WindowClearAnchors( careerIconWindow )
        WindowAddAnchor( careerIconWindow, "topleft", portraitWindow, "topleft", 0, 56 )
    else
        -- Note: Sigils can only show on the hostile target so we only create it if it is not friendly
        local sigilButtonName = windowName.."SigilButton"
        if (CreateWindowFromTemplate (sigilButtonName, "UnitFrameHostileSigilButton", windowName) == true)
        then
            WindowAddAnchor (sigilButtonName, "right", portraitWindow, "right", 0, 0)    
            -- Hide newly created window
            WindowSetShowing (sigilButtonName, false)
        end
    end
    
    newUnitFrame.m_StatusFrame = TargetUnitFrameStatus:Create (windowName.."Status", windowName, statusAnchor, newUnitFrame.m_IsFriendly)
    
    -- Create buffs...
   
    local buffAnchor = 
    {
        Point           = "bottomleft",
        RelativePoint   = "topleft",
        RelativeTo      = windowName.."Status", 
        XOffset         = 2,
        YOffset         = -4,
    }
    
    if (newUnitFrame.m_IsFriendly) then
        buffAnchor.XOffset = 14
        buffAnchor.YOffset = -3
    end
    
    newUnitFrame.m_BuffTracker = BuffTracker:Create (windowName.."Buffs", windowName, buffAnchor, UnitIdToBuffTargetMapping[unitId].buffTarget, c_MAX_BUFF_COUNT, c_BUFF_ROW_STRIDE, SHOW_BUFF_FRAME_TIMER_LABELS)
    
    -- Create RvR Indicator
    
    newUnitFrame.m_RvRFrame = RvRIndicator:Create (windowName.."RvRFlagIndicator", windowName)
    newUnitFrame.m_RvRFrame:SetAnchor ({Point = "top", RelativePoint = "center", RelativeTo = portraitWindow, XOffset = 0, YOffset = 25})
    
    -- Make sure all the dynamically created windows were valid...destroy this frame if they weren't.
    if 
    (
        (newUnitFrame.m_StatusFrame == nil) or
        (newUnitFrame.m_BuffTracker == nil) or
        (newUnitFrame.m_RvRFrame    == nil)
    )
    then
        self:Destroy ()
        return nil
    end
    
    -- Adjust anchors and status bar orientation accordingly depending on if
    -- the target is friendly or hostile

    LabelSetTextColor (windowName.."StatusName", UnitStatusInfo[newUnitFrame.m_IsFriendly].NameColor.r, UnitStatusInfo[newUnitFrame.m_IsFriendly].NameColor.g, UnitStatusInfo[newUnitFrame.m_IsFriendly].NameColor.b)
    
    LabelSetTextAlign (windowName.."StatusName", UnitStatusInfo[newUnitFrame.m_IsFriendly].TextAlignment)

    WindowClearAnchors (windowName.."LevelBackground")
    WindowAddAnchor (windowName.."LevelBackground", UnitStatusInfo[newUnitFrame.m_IsFriendly].Anchor.Point, portraitWindow, UnitStatusInfo[newUnitFrame.m_IsFriendly].Anchor.RelativePoint, UnitStatusInfo[newUnitFrame.m_IsFriendly].Anchor.XOffset, UnitStatusInfo[newUnitFrame.m_IsFriendly].Anchor.YOffset)

    DynamicImageSetTextureOrientation (windowName.."StatusHealthBarFrame", UnitStatusInfo[newUnitFrame.m_IsFriendly].MirrorTexture)
    
    WindowSetShowing (windowName.."StatusSwordLeft", false)
    WindowSetShowing (windowName.."StatusSwordRight", false)

    
    --
    -- This was in TargetWindow.lua ...i have no idea why...it creates a new dynamic image of the supplied windowdef at the given offset
    -- I didn't look into how this was actually used for portraits.  Probably going to abandon this for NifDisplay, but that seems to have
    -- some problems as well.  (ie, must clone geometry)
    --
    -- SetTargetPortraitBackground( "TargetPortraitBackground", 10, 10 )
    --
    
    return newUnitFrame
end

--
-- TargetUnitFrame event handlers.  These are the generic
-- handlers from the template.  They need to extract unique
-- window id's to know which TargetUnitFrame to actually operate on
--

--
-- Generic RButtonUp event handler for TargetUnitFrame
--
function TargetUnitFrame.OnRButtonUp (flags, x, y)
    local unitFrame = FrameManager:GetActiveWindow ()
    
    if (unitFrame ~= nil)
    then
        local targetName = TargetInfo:UnitName (unitFrame.m_UnitId);
        local targetType = TargetInfo:UnitType (unitFrame.m_UnitId);

        if (targetName ~= GameData.Player.name and targetType == SystemData.TargetObjectType.ALLY_PLAYER) 
        then
            PlayerMenuWindow.ShowMenu(targetName) 
        end
    end
end

function TargetUnitFrame.MouseOverCareerIcon()
    
    local unitFrame = GetFrame( WindowGetParent( SystemData.ActiveWindow.name ) )
    if( unitFrame == nil )
    then
        return
    end

    local unitName      = TargetInfo:UnitName( unitFrame.m_UnitId )
    local level         = TargetInfo:UnitLevel( unitFrame.m_UnitId )
    local battleLevel   = TargetInfo:UnitBattleLevel( unitFrame.m_UnitId )
    local careerString  = TargetInfo:UnitCareerName( unitFrame.m_UnitId )
    local levelString = PartyUtils.GetLevelText( level, battleLevel )
    
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, unitName )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, GetStringFormat( StringTables.Default.LABEL_RANK_X, { levelString } ) )
    Tooltips.SetTooltipText( 3, 1, GetStringFormatFromTable("HUDStrings", StringTables.HUD.LABEL_HUD_PLAYER_WINDOW_TOOLTIP_CAREER_NAME, {careerString}) )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( ANCHOR_WINDOW_VARIABLE )
end

--
-- Time-based update function
--
function TargetUnitFrame:Update (elapsedTime)
    self.m_BuffTracker:Update (elapsedTime)
end

--
-- Update a unit frame from its unitId information.
--
function TargetUnitFrame:UpdateUnit ()

    -- Using local variables because I removed the arguments...
    local unitId = self.m_UnitId

    -- Track these so the frame knows whether or not to show the con level (ie, not for static objects)
    -- Similar reasoning behind caching m_IsThePlayer.    
    self.m_Type = TargetInfo:UnitType (unitId)
    self.showHealthBar = TargetInfo:ShowHealthBar (unitId)

    self.m_IsAStaticObject  = (self.m_Type == SystemData.TargetObjectType.STATIC_ATTACKABLE or self.m_Type == SystemData.TargetObjectType.STATIC)
    self.m_IsThePlayer      = (self.m_Type == SystemData.TargetObjectType.SELF)
    
    -- Unit must have a name to show
    -- Unit must be a non-static, or attackable static object.
    local unitName      = TargetInfo:UnitName (unitId)
    local unitHasName   = unitName ~= L""
    local showUnitFrame = unitHasName -- and (self.m_Type ~= SystemData.TargetObjectType.STATIC)  -- Still showing static object frames, even though i hate it!
      
    -- Frame:Show returns the input parameter, to eliminate the need for another evaluation.
    if (self:Show (showUnitFrame) == false)
    then
        return
    end

    local unitTier          = TargetInfo:UnitTier (unitId)
    local unitLevel         = TargetInfo:UnitLevel (unitId)
    local unitBattleLevel   = TargetInfo:UnitBattleLevel( unitId )
    local unitCon           = TargetInfo:UnitConType (unitId)
    local conColor          = DataUtils.GetTargetConColor (unitCon)
        
    self:UpdateLevel (unitLevel, unitBattleLevel, conColor)
    self:UpdateStatusFrame (unitName, unitCon, unitTier)
    self:UpdateHealth ()  
    local careerLine = TargetInfo:UnitCareer(unitId)
    if( careerLine ~= 0 )
    then
        self:SetCareerIcon( careerLine )
    end
    self:ShowCareerIcon( careerLine ~= 0 )
    self.m_RvRFrame:SetTargetType (self.m_Type)
    self.m_RvRFrame:Show (TargetInfo:UnitIsPvPFlagged (unitId))
    
    local unitDiffMask = TargetInfo:UnitDifficultyMask (unitId)
    
    for skull = 1, 4 do
        local skullWinName = self.m_Name.."Skull"..skull
        
        WindowSetShowing (skullWinName, (skull <= unitDiffMask) and (not self.m_IsAStaticObject))
        
        if( (skull <= unitDiffMask) and (not self.m_IsAStaticObject) ) then
            local skullName         = "Skull"..skull
            local threatLevel       = "ThreatLevel"..unitDiffMask
            local skullRelativeWin  = self.m_Name..ConTierToSkullAnchorMapping[threatLevel][skullName].RelativeTo
            local anchor            = ConTierToSkullAnchorMapping[threatLevel][skullName]
            
            WindowClearAnchors (skullWinName)
            WindowAddAnchor (skullWinName, anchor.Point, skullRelativeWin, anchor.RelativePoint, anchor.XOffset, anchor.YOffset)                    
        end        
    end
    
    -- Update the temporary portrait with the correct image and color...
    local textureSlice = "skull"
    
    if (self.m_IsFriendly)
    then
        textureSlice = "dove"
    else
        -- Only try to set the sigil on the hostile target
        local unitSigilEntryId = TargetInfo:UnitSigilEntryId (unitId)
        if( unitSigilEntryId ~= 0 )
        then
            self:SetSigil( unitSigilEntryId )
        end
        self:ShowSigil( unitSigilEntryId ~= 0 )
    end
    
    local relationshipColor = TargetInfo:UnitRelationshipColor (unitId)
    
    DynamicImageSetTextureSlice (self:GetName ().."TempPortraitFG", textureSlice)
    WindowSetTintColor (self:GetName ().."TempPortraitBG", relationshipColor.r, relationshipColor.g, relationshipColor.b)
end

function TargetUnitFrame:SetCareerIcon( careerLine )
    local texture, x, y = GetIconData( Icons.GetCareerIconIDFromCareerLine( careerLine ) )
    DynamicImageSetTexture( self:GetName().."CareerIcon", texture, x, y )
end

function TargetUnitFrame:ShowCareerIcon( show )
    WindowSetShowing( self:GetName().."CareerIcon", show )
end

function TargetUnitFrame.SigilMouseOver()
    
    if( HostileUnitSigilDisplayInfo.name == nil )
    then
        return
    end

    local sigilName = HostileUnitSigilDisplayInfo.name
    
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, sigilName )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( ANCHOR_WINDOW_VARIABLE )
end

function TargetUnitFrame.SigilLButtonUp()
    
    if( HostileUnitSigilDisplayInfo.id == nil )
    then
        return
    end
    
    if( TomeWindow )
    then
        TomeWindow.OpenTomeToEntry( GameData.Tome.SECTION_ARMORY_SIGILS, HostileUnitSigilDisplayInfo.id)    
    end
end

function TargetUnitFrame:SetSigil( sigilEntryId )
    
    HostileUnitSigilDisplayInfo = TomeGetSigilDisplayInfo( sigilEntryId )
    
    local buttonName = self:GetName().."SigilButton"
    local normalSlice = HostileUnitSigilDisplayInfo.sliceName
    local rolloverSlice = HostileUnitSigilDisplayInfo.sliceName.."-rollover"

    ButtonSetTextureSlice(buttonName, Button.ButtonState.NORMAL, "EA_HUD_01", normalSlice);
    ButtonSetTextureSlice(buttonName, Button.ButtonState.HIGHLIGHTED, "EA_HUD_01", rolloverSlice);
    ButtonSetTextureSlice(buttonName, Button.ButtonState.PRESSED, "EA_HUD_01", normalSlice);
    ButtonSetTextureSlice(buttonName, Button.ButtonState.PRESSED_HIGHLIGHTED, "EA_HUD_01", rolloverSlice);
end

function TargetUnitFrame:ShowSigil( show )
    WindowSetShowing( self:GetName().."SigilButton", show )
end

function TargetUnitFrame:UpdateCombatState (isInCombat)
    if (self.m_IsFriendly == false) then
        
        local windowName = self:GetName ()
        
        WindowSetShowing (windowName.."StatusSwordLeft", isInCombat)
        WindowSetShowing (windowName.."StatusSwordRight", isInCombat)
        
    end
end

function TargetUnitFrame:UpdateLevel (level, battleLevel, conColor)
    local windowName = self:GetName ()
    local levelColor

    if( not self.m_IsFriendly or level == battleLevel )
    then
        levelColor = UnitStatusInfo[self.m_IsFriendly].LevelTextColor
    else
        levelColor = PartyUtils.GetLevelTextColor( level, battleLevel )
    end
    
    LabelSetText        (windowName.."LevelText",        L""..battleLevel)
    LabelSetTextColor   (windowName.."LevelText",        levelColor.r, levelColor.g, levelColor.b)  
    WindowSetTintColor  (windowName.."LevelBackgroundTint", conColor.r, conColor.g, conColor.b)
    WindowSetShowing    (windowName.."LevelBackgroundTint", not self.m_IsFriendly)
    WindowSetShowing    (windowName.."LevelText",        self.m_IsAStaticObject == false)
    WindowSetShowing    (windowName.."LevelBackground",  self.m_IsAStaticObject == false)
end

function TargetUnitFrame:UpdateStatusFrame (unitName, unitCon, unitTier)
    local nameColor     = TargetInfo:UnitRelationshipColor (self.m_UnitId)
    local isObject      = self.m_IsAStaticObject
    local isSelf        = self.m_IsThePlayer
    local isFriendlyNPC = TargetInfo:UnitIsNPC(self.m_UnitId) and self.m_IsFriendly
    local tierTextAlign = UnitStatusInfo[self.m_IsFriendly].TextAlignment
    
    self.m_StatusFrame:UpdateUnitName (unitName, nameColor)
    self.m_StatusFrame:UpdateUnitCon (GameDefs.CON_DESCS[unitCon], GameDefs.CON_COLORS[unitCon], not (isObject or isSelf or isFriendlyNPC))
    
    if (isFriendlyNPC)
    then
        self.m_StatusFrame:UpdateUnitTier (GetString (StringTables.Default.LABEL_TARGET_IS_FRIENDLY), tierTextAlign)
    else
        self.m_StatusFrame:UpdateUnitTier (GameDefs.TIER_NAMES[unitTier], tierTextAlign)
    end
end

function TargetUnitFrame:UpdateHealth ()   
    local showHealth = ((self.m_Type ~= SystemData.TargetObjectType.STATIC) or self.showHealthBar)
    
    self.m_StatusFrame:SetUnitHealth (TargetInfo:UnitHealth (self.m_UnitId), UnitIdToBuffTargetMapping[self.m_UnitId].healthColor, showHealth)
end

function TargetUnitFrame:StopInterpolatingStatus()
    self.m_StatusFrame:StopInterpolating()
end

function TargetUnitFrame:ShowBuffTimerLabels (showType)
    self.m_BuffTracker:ShowBuffTimerLabels (showType)
end