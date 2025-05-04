-----------------------------------------------------------------------------
--
-- Local utility functions and lookup tables
--
-----------------------------------------------------------------------------


local FRIENDLY_UNIT     = true
local HOSTILE_UNIT      = false

local FADE_TIME         = 1.0
local DELAY_TIME        = 0.5
local fadeOutStarted    = false

local UnitStatusInfo =
{
    [FRIENDLY_UNIT]     =   {
                                NameColor = {r = DefaultColor.NAME_COLOR_PLAYER.r, g = DefaultColor.NAME_COLOR_PLAYER.g, b = DefaultColor.NAME_COLOR_PLAYER.b},
                                HealthColor = { r = 255, g = 0, b = 0 },
                                TextAlignment = "leftcenter",
                                Anchor = {Point = "topleft", RelativePoint = "topleft", XOffset = 0, YOffset = 3},
                                MirrorTexture = false,
                                LevelTextColor = DefaultColor.XP_COLOR_FILLED
                            },
                            
    [HOSTILE_UNIT]      =   {
                                NameColor = {r = DefaultColor.NAME_COLOR_THREAT.r, g = DefaultColor.NAME_COLOR_THREAT.g, b = DefaultColor.NAME_COLOR_THREAT.b},
                                HealthColor = { r = 0, g = 255, b = 0 },
                                TextAlignment = "rightcenter",
                                Anchor = {Point = "topright", RelativePoint = "center", XOffset = -17, YOffset = 17},
                                MirrorTexture = true,
                                LevelTextColor = DefaultColor.BLACK
                            }
                            
}

--
-- The window for the entire unit frame.
--
MouseOverTargetUnitFrame = Frame:Subclass ("MouseOverTargetUnitFrame")
MouseOverTargetObject = Frame:Subclass ("MouseOverTargetObjectWindow")
--
-- Create a new instance of a MouseOverTargetUnitFrame and initialize it.
-- Call sequence:  MouseOverTargetWindow.Initialize --> UnitFrames:CreateNewFrame --> MouseOverTargetUnitFrame:Create(MouseOverTargetUnitWindow, mouseovertarget)
-- 
function MouseOverTargetUnitFrame:Create (windowName, unitId)    
    local newUnitFrame = self:CreateFromTemplate (windowName)
        
    if (newUnitFrame == nil)
    then
        return nil
    end

    -- Table 'variables' to be set via MouseOverTargetUnitFrame:UpdateUnit
    newUnitFrame.m_UnitId               = unitId
    newUnitFrame.m_Type                 = 0
    newUnitFrame.m_IsAStaticObject      = false
    newUnitFrame.m_IsThePlayer          = false 
    newUnitFrame.m_IsFriendly           = false
    newUnitFrame.m_NameColor            = nil
    newUnitFrame.m_ConColor             = nil
    
    -- The special-case frame for target objects, which uses a different template window.
    -- Updates for this mouseover are handled in MouseOverTargetUnitFrame:UpdateUnit().
    -- We cannot just use a tooltip, because there is no window to set as its mouseOverWindow; Tooltips.lua would not know when to destroy it, etc.
    newUnitFrame.m_TargetObjectWindow = MouseOverTargetObject:CreateFromTemplate ("MouseOverTargetObjectWin")
    
    return newUnitFrame
end

--
-- MouseOverTargetUnitFrame event handlers.  These are the generic
-- handlers from the template.  They need to extract unique
-- window id's to know which MouseOverTargetUnitFrame to actually operate on.
--


--
-- Time-based update function
--
function MouseOverTargetUnitFrame:Update (elapsedTime)

end

--
-- Update a unit frame from its unitId information.
--
function MouseOverTargetUnitFrame:UpdateUnit ()
    -- Using local variables because I removed the arguments...
    local unitId = self.m_UnitId
   

    -- Track these so the frame knows whether or not to show the con level (ie, not for static objects)
    -- Similar reasoning behind caching m_IsThePlayer.    
    self.m_Type = TargetInfo:UnitType (unitId);    
    self.m_IsAStaticObject  = (self.m_Type == SystemData.TargetObjectType.STATIC_ATTACKABLE or self.m_Type == SystemData.TargetObjectType.STATIC)
    self.m_IsThePlayer      = (self.m_Type == SystemData.TargetObjectType.SELF)
    self.m_IsFriendly       = TargetInfo:UnitIsFriendly(unitId)
    
    -- Unit must have a name to show.
    local unitName      = TargetInfo:UnitName (unitId)
    local unitHasName   = unitName ~= L""
    local showUnitFrame = unitHasName -- and (self.m_Type ~= SystemData.TargetObjectType.STATIC)  -- Still showing static object frames, even though i hate it!
    
    -- If unit does not have a name, hide all mouseovers.
    if (not showUnitFrame) then
        -- Checking fadeOutStarted because we have no way to know if what we
        -- moused off of is a static or a monster, so just force the animation
        -- to only start once
        if( not fadeOutStarted )
        then
            self:StartAlphaAnimation( Window.AnimationType.EASE_OUT_HIDE, 1.0, 0.0, FADE_TIME, DELAY_TIME, 0 )
            fadeOutStarted = true
        end
        
        self.m_TargetObjectWindow:Show(false)
        Tooltips.ClearTooltip()
        return
    end
    
    -- Otherwise, update and show the mouseover of the appropriate type.

    -- Show a static object (e.g. road sign):
    if (self.m_IsAStaticObject) then
        self:ShowAndUpdateForStaticObject(unitName)
    
    -- Show a non-static mousover (e.g. player, monster, or static attackable):
    else
        self:ShowAndUpdateForNonStatic(unitId, unitName)
    end
    
end

--
-- Update function for static object mousover.
--

function MouseOverTargetUnitFrame:ShowAndUpdateForStaticObject(unitName)
    --toooltips actually resize themselves properly
    Tooltips.CreateTextOnlyTooltip("Root", unitName)
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_CURSOR) 
end

--
-- Update Functions for default mouseover.
--

function MouseOverTargetUnitFrame:ShowAndUpdateForNonStatic(unitId, unitName)

    local unitTier          = TargetInfo:UnitTier (unitId)
    local unitLevel         = TargetInfo:UnitLevel (unitId)
    local unitBattleLevel   = TargetInfo:UnitBattleLevel (unitId)
    local nameColor         = TargetInfo:UnitRelationshipColor (unitId)
    
    local unitCon           = TargetInfo:UnitConType (unitId)
    local unitConDesc       = DataUtils.GetTargetConDesc (unitCon)
    local conColor          = DataUtils.GetTargetConColor (unitCon)
    self.m_IsFriendly       = TargetInfo:UnitIsFriendly (self.m_UnitId)

    local isObject          = self.m_IsAStaticObject
    local isSelf            = self.m_IsThePlayer
    
    local careerTitle
    if( TargetInfo:UnitIsNPC( unitId ) )
    then
        careerTitle = TargetInfo:UnitNPCTitle( unitId )
    else
        careerTitle = TargetInfo:UnitCareerName( unitId )
    end

    -- Updates:
    self:UpdateLevel (unitLevel, unitBattleLevel, conColor)
    self:UpdateUnitName (unitName, nameColor)
    self:UpdateUnitCareerTitle (careerTitle)
    self:UpdateUnitCon (unitConDesc, not (isObject or isSelf), conColor)
    self:UpdateUnitTier (unitTier)

    -- Resize the window to contents
    local _, nameY = LabelGetTextDimensions( self:GetName().."Name" )
    local _, careerY = LabelGetTextDimensions( self:GetName().."CareerLabel" )
    local _, levelY = WindowGetDimensions( self:GetName().."LevelBackground" )
    local padding = 25 -- to account for spacing and margins
    local x, _ = self:GetDimensions()
    self:SetDimensions( x, nameY + careerY + levelY + padding )

    self:StopAlphaAnimation()
    self:SetAlpha( 1.0 )
    self:SetFontAlpha( 1.0 )
    self:Show(true, Frame.FORCE_OVERRIDE)
    fadeOutStarted = false
end

-- Updates label "MouseOverTargetUnitFrameName", with text = 'unitName' and text color = 'nameColor'.
function MouseOverTargetUnitFrame:UpdateUnitName (unitName, nameColor)
    local labelName = self:GetName ().."Name"
    
    if (self.m_NameColor ~= nameColor) then
        LabelSetTextColor (labelName, nameColor.r, nameColor.g, nameColor.b)
        self.m_NameColor = nameColor
    end
    
    LabelSetText (labelName, GetStringFormatFromTable("HUDStrings", StringTables.HUD.LABEL_HUD_MOUSEOVER_TARGET_UNIT_NAME, {unitName}))
end

function MouseOverTargetUnitFrame:UpdateUnitCareerTitle (unitCareerOrTitle)
    local labelName = self:GetName().."CareerLabel"
    LabelSetText( labelName, unitCareerOrTitle )
end

-- Updates label "MouseOverTargetUnitFrameConLabel", with text = conName (i.e. con description), RGB color table = 'conColor', and boolean 'showCon' indicating whether or not to display it.
function MouseOverTargetUnitFrame:UpdateUnitCon (conName, showCon, conColor)

    -- For the mouseover tooltip, 'Friendly' text is displayed in the Con label, rather than the Tier label.
    if (self.m_IsFriendly) then
        conName = GetString (StringTables.Default.LABEL_TARGET_IS_FRIENDLY)
        conColor = DefaultColor.WHITE
    end    
    
    if (self.m_ConColor ~= conColor) then
        LabelSetTextColor (self:GetName ().."ConLabel", conColor.r, conColor.g, conColor.b)
        self.m_ConColor = conColor
    end

    LabelSetText (self:GetName ().."ConLabel", conName)
    WindowSetShowing (self:GetName ().."ConLabel", showCon)
end

-- Updates "MouseOverTargetUnitFrameTierLabel" with text = 'unitTier'; this is the text that reads "CHAMPION", "HERO", etc.
function MouseOverTargetUnitFrame:UpdateUnitTier (unitTier)
    LabelSetText (self:GetName ().."TierLabel", GameDefs.TIER_NAMES[unitTier])
    LabelSetTextColor (self:GetName().."TierLabel", DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b)
end

-- Updates the level text ('level') and the background color behind the level text ('conColor')
function MouseOverTargetUnitFrame:UpdateLevel (level, battleLevel, conColor)
    local windowName = self:GetName ()
    
    LabelSetText        (windowName.."LevelText", L""..battleLevel)
    LabelSetTextColor   (windowName.."LevelText", UnitStatusInfo[self.m_IsFriendly].LevelTextColor.r, UnitStatusInfo[self.m_IsFriendly].LevelTextColor.g, UnitStatusInfo[self.m_IsFriendly].LevelTextColor.b)
    WindowSetTintColor  (windowName.."LevelBackgroundTint", conColor.r, conColor.g, conColor.b)

    WindowSetShowing    (windowName.."LevelText",        self.m_IsAStaticObject == false) 
    WindowSetShowing    (windowName.."LevelBackground",  self.m_IsAStaticObject == false)
    WindowSetShowing    (windowName.."LevelBackgroundTint", self.m_IsAStaticObject==false and self.m_IsFriendly==false)
end

