
-- NOTE: This file is doccumented with NaturalDocs style comments. All comments begining with "--#' will
-- be included in the output.


--# Title: Tooltips
--#     The tooltip system is a lua-run system that manages the display of all UI tooltips. This is a shared
--#     resource that may be used by all other windows.

Tooltips = {}


-- Window - Relative Anchor Positions
-- NOTE: The nil anchor serves as a constant, so that there's no confusion about passing nil
-- to the AnchorTooltip function.
Tooltips.ANCHOR_WINDOW_LEFT     = { Point = "topleft",      RelativeTo = "", RelativePoint = "topright",    XOffset = -4, YOffset = 0 }
Tooltips.ANCHOR_WINDOW_RIGHT    = { Point = "topright",     RelativeTo = "", RelativePoint = "topleft", XOffset = 4, YOffset = 0 }
Tooltips.ANCHOR_WINDOW_TOP      = { Point = "topleft",      RelativeTo = "", RelativePoint = "bottomleft",  XOffset = 0, YOffset = -4 }
Tooltips.ANCHOR_WINDOW_BOTTOM   = { Point = "bottomleft",   RelativeTo = "", RelativePoint = "topleft", XOffset = 0, YOffset = 4 }
Tooltips.ANCHOR_WINDOW_VARIABLE = nil;

-- Screen - Relative Anchor Position
Tooltips.ANCHOR_SCREEN_BOTTOM_RIGHT = { Point = "bottomright", RelativeTo = "Root", RelativePoint = "bottomright", XOffset = 104, YOffset = 0 }

Tooltips.MOUSE_OVER_TARGET_TOOLTIP_MARGIN = 10
Tooltips.ANCHOR_MOUSE_OVER_TARGET_WINDOW = { Point = "bottomright", RelativeTo = "MouseOverTargetWindow", RelativePoint = "bottomright",
                                             XOffset = -Tooltips.MOUSE_OVER_TARGET_TOOLTIP_MARGIN,
                                             YOffset = -Tooltips.MOUSE_OVER_TARGET_TOOLTIP_MARGIN }

Tooltips.ANCHOR_CURSOR = { Point = "bottomleft", RelativeTo = "CursorWindow", RelativePoint = "topleft", XOffset = 0, YOffset = 0 }
Tooltips.ANCHOR_CURSOR_LEFT = { Point = "topleft", RelativeTo = "CursorWindow", RelativePoint = "topright", XOffset = 0, YOffset = 0 }


-- Default tooltip table dimensions
Tooltips.NUM_ROWS = 17
Tooltips.NUM_COLUMNS = 3
Tooltips.ROW_SPACING = 5
Tooltips.BORDER_SIZE = { X=10, Y=5 }
Tooltips.MAX_WIDTH = 375

-- Default Tooltip Columns
Tooltips.COLUMN_LEFT = 1
Tooltips.COLUMN_RIGHT_RIGHT_ALIGN = 2
Tooltips.COLUMN_RIGHT_LEFT_ALIGN = 3

-- These Defs are used for initialization.
Tooltips.ItemTooltip = {}
Tooltips.ItemTooltip.COMPARISON_WIN_1   = "ItemComparisonTooltip";
Tooltips.ItemTooltip.COMPARISON_WIN_2   = "ItemComparisonTooltip2";

Tooltips.COLOR_HEADING              = DefaultColor.TOOLTIP_HEADING
Tooltips.COLOR_BODY                 = DefaultColor.TOOLTIP_BODY
Tooltips.COLOR_MEETS_REQUIREMENTS   = DefaultColor.TOOLTIP_MEETS_REQUIREMENTS
Tooltips.COLOR_FAILS_REQUIREMENTS   = DefaultColor.TOOLTIP_FAILS_REQUIREMENTS
Tooltips.COLOR_EXTRA_TEXT_DEFAULT   = DefaultColor.TOOLTIP_EXTRA_TEXT_DEFAULT
Tooltips.COLOR_WARNING              = DefaultColor.TOOLTIP_WARNING
Tooltips.COLOR_ACTION               = DefaultColor.TOOLTIP_ACTION
Tooltips.COLOR_ITEM_SET_ENABLED     = DefaultColor.TOOLTIP_ITEM_SET_ENABLED
Tooltips.COLOR_ITEM_SET_DISABLED    = DefaultColor.TOOLTIP_ITEM_SET_DISABLED
Tooltips.COLOR_ITEM_BONUS           = DefaultColor.TOOLTIP_ITEM_BONUS
Tooltips.COLOR_ITEM_DISABLED        = DefaultColor.TOOLTIP_ITEM_DISABLED
Tooltips.COLOR_ITEM_HIGHLIGHT       = DefaultColor.TOOLTIP_ITEM_HIGHLIGHT
Tooltips.COLOR_DEFAULT_ACTION       = DefaultColor.TOOLTIP_DEFAULT_ACTION
Tooltips.COLOR_ABILITY_ACTION       = DefaultColor.TOOLTIP_ABILITY_ACTION
Tooltips.COLOR_ITEM_DEFAULT_GRAY    = { r=150, g=150, b=150 }


Tooltips.DISABLE_COMPARISON         = true;
Tooltips.ENABLE_COMPARISON          = false;





------------------------------------------------------------------------------------------------------------
-- Local Variables
------------------------------------------------------------------------------------------------------------

Tooltips.curMouseOverWindow     = ""
Tooltips.curStyle               = 0
Tooltips.curAnchor              = Tooltips.ANCHOR_RIGHT
Tooltips.curTooltipWindow       = ""
Tooltips.visible                = false
Tooltips.curUpdateCallback      = nil
Tooltips.curItemData            = nil
Tooltips.curExtraWindows        = {} 

Tooltips.displayFlags           = {};
Tooltips.FLAG_IS_SET_ITEM       = 1;



------------------------------------------------------------------------------------------------------------
-- Local Tooltip Functions
------------------------------------------------------------------------------------------------------------

function Tooltips.NewTooltipFlags ()
    local flags = {};
  
    flags[Tooltips.FLAG_IS_SET_ITEM]    = false;
    
    return { flags }    
end

function Tooltips.ClearTooltipFlags ()
    Tooltips.displayFlags = {};
end

function Tooltips.SetTooltipFlag (windowName, flag, isSet)
    if (Tooltips.displayFlags[windowName] == nil) then
        Tooltips.displayFlags[windowName] = Tooltips.NewTooltipFlags ();
    end
    
    if ( Tooltips.displayFlags[windowName].flags == nil ) then
        Tooltips.displayFlags[windowName].flags = {}
    end
     
    Tooltips.displayFlags[windowName].flags[flag] = isSet;    
end

function Tooltips.GetTooltipFlag (windowName, flag)
    if (Tooltips.displayFlags[windowName] == nil) then
        return false;
    end
    
    if ( Tooltips.displayFlags[windowName].flags == nil ) then
        return false;
    end

    return Tooltips.displayFlags[windowName].flags[flag];
end

--[[
    Caches strings for tactics ids.
--]]

Tooltips.TacticsTypeStrings = {}

--[[
    Caches strings for crafting ids.
--]]


------------------------------------------------------------------------------------------------------------
-- Tooltip Functions
------------------------------------------------------------------------------------------------------------

local function CreateAndInitWindow( windowName, title, actionTextColor )
    CreateWindow( windowName, false )
    WindowSetTintColor( windowName.."BackgroundInner", 0, 0, 0 )
    WindowSetAlpha( windowName.."BackgroundInner", .9 )
    
    if( title )
    then
        LabelSetText( windowName.."Title", title )
    end
    
    if( actionTextColor )
    then
        WindowSetTintColor( windowName.."ActionTextLine", actionTextColor.r, actionTextColor.g, actionTextColor.b )
    end
end

TooltipWindowData =
{
    ["DefaultTooltip"]                      = { actionTextColor = Tooltips.COLOR_DEFAULT_ACTION },
    ["ItemTooltip"]                         = { },
    [Tooltips.ItemTooltip.COMPARISON_WIN_1] = { title = GetString( StringTables.Default.LABEL_CURRENT_ITEM ) },
    [Tooltips.ItemTooltip.COMPARISON_WIN_2] = { title = GetString( StringTables.Default.LABEL_CURRENT_ITEM ) },
    ["AbilityTooltip"]                      = { actionTextColor = Tooltips.COLOR_ABILITY_ACTION },
    ["TwoLineActionTooltip"]                = { },
    ["MapPointsTooltip"]                    = { },
    ["BrokenItemTooltip"]                   = { },
    ["AppearanceItemTooltip"]               = { },
    ["MoneyTooltip"]                        = { },
    ["DefaultListTooltip"]                  = { },
    ["GlyphTooltip"]                        = { },
}


function Tooltips.Initialize()

    -- Create the Tooltip Windows
    
    for windowName, windowSettings in pairs( TooltipWindowData )
    do
        CreateAndInitWindow( windowName, windowSettings.title, windowSettings.actionTextColor )
    end 
    
    -- These windows still need to be created
    CreateWindow( "PairingMapCityToolTip", false )
    CreateWindow( "PairingMapZoneToolTip", false )
    CreateWindow( "PairingMapFortToolTip", false )
    CreateWindow( "PairingMapTravelToolTip", false )
    CreateWindow( "PairingMapTierToolTip", false )
    
    WindowSetShowing("BrokenItemTooltipRepairedItemBackground", false )

    local highlightColor = Tooltips.COLOR_ITEM_HIGHLIGHT 
    LabelSetTextColor("BrokenItemTooltipDecayTime", highlightColor.r, highlightColor.g, highlightColor.b )
    local actionColor = Tooltips.COLOR_ACTION 
    LabelSetTextColor("BrokenItemTooltipRepairText", actionColor.r, actionColor.g, actionColor.b )
    
    Tooltips.curTooltipWindow = "DefaultTooltip"
    Tooltips.ClearTooltip()
    
    -- Register the main tooltip window for item set updates (only cares about the update if it's
    -- displaying an item that's part of an item set that isn't cached in the client data...)
    WindowRegisterEventHandler ("ItemTooltip", SystemData.Events.ITEM_SET_DATA_UPDATED, "Tooltips.RefreshItemSetData");
    
    -- Create the tactic type to string mapping
    Tooltips.TacticsTypeStrings[GameData.TacticType.CAREER]  = GetString (StringTables.Default.TACTIC_TYPE_CAREER)
    Tooltips.TacticsTypeStrings[GameData.TacticType.RENOWN]  = GetString (StringTables.Default.TACTIC_TYPE_RENOWN);
    Tooltips.TacticsTypeStrings[GameData.TacticType.TOME]    = GetString (StringTables.Default.TACTIC_TYPE_TOME);
    
end

--[[
    Hide the tooltip if the current mouseover target does not match
    the current window, otherwise updates the current tooltip if it has a callback.
--]]

function Tooltips.Update( timePassed )
    if( Tooltips.visible ) then            
        if( Tooltips.curMouseOverWindow ~= SystemData.MouseOverWindow.name or not SystemData.Settings.GamePlay.showToolTips ) then
            Tooltips.ClearTooltip()
        elseif( Tooltips.curUpdateCallback ~= nil ) then
            Tooltips.curUpdateCallback( timePassed )        
        end
    end
end


----------------------------------------------------------------------------------------------------
--# Function: Tooltips.ClearTooltip()
--#     Clears the current tooltip.
--#
--#     Parameters:
--#         nil - no parameters
--#
--#     Returns:
--#         nil - no return valuse
--#
--#     Notes:
--#         none
--#
----------------------------------------------------------------------------------------------------
function Tooltips.ClearTooltip()
    
    if( Tooltips.curTooltipWindow ~= "" ) then      
        WindowSetShowing( Tooltips.curTooltipWindow, false )     
        WindowClearAnchors (Tooltips.curTooltipWindow);
        Tooltips.SetTooltipAlpha( 1.0 )
        
        if( Tooltips.curTooltipWindow == "DefaultTooltip" ) then
            -- Clear all tooltip text
            for rowNum = 1, Tooltips.NUM_ROWS do
                for colNum = 1, Tooltips.NUM_COLUMNS do
                    colName = Tooltips.curTooltipWindow.."Row"..rowNum.."Col"..colNum.."Text"
                    WindowSetDimensions( colName, Tooltips.MAX_WIDTH, 0 )
                    LabelSetText( colName, L"" )
                    LabelSetTextColor( colName, 255, 255, 255 ) 
                    --LabelSetFont( colName, "font_default_text", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING )         
                end
            end
            LabelSetText( "DefaultTooltipActionText", L"" )
            WindowSetDimensions( "DefaultTooltipActionText", Tooltips.MAX_WIDTH, 0 )
        end
        
        -- Get rid of the item data
        Tooltips.curItemData = nil;
        
        -- Hide any extra on-mouseover windows
        for index, tooltipWindow in ipairs (Tooltips.curExtraWindows) do
            WindowSetShowing (tooltipWindow.name, false);
            Tooltips.curExtraWindows[index] = nil;
        end
        
        Tooltips.curUpdateCallback = nil
    end
    
    Tooltips.ClearTooltipFlags ();
    Tooltips.visible = false 
end
----------------------------------------------------------------------------------------------------
--# Function: Tooltips.AnchorTooltipManual()
--#     Anchors the active tooltip according to the parameters.
--#
--#     Parameters:
--#         anchorPoint     - (string) The name point on the at which to anchor the window. { "topleft", "top", "topright", "left", "center", "right", "bottomleft", "bottom", "bottomright" }
--#         relativeTo      - (string) The name of another window to which you want to anchor this one. 
--#         relativePoint   - (string) The point on this that you wish to attach to the anchor window. { "topleft", "top", "topright", "left", "center", "right", "bottomleft", "bottom", "bottomright" }
--#         xOffset         - (number) The x pixel offset from this anchor location.
--#         yOffset         - (number) The y pixel offset from this anchor location.
--#
--#     Returns:
--#         nil - no return valuse
--#
--#     Notes:
--#         none
--#
----------------------------------------------------------------------------------------------------
function Tooltips.AnchorTooltipManual( anchorPoint, anchorToWindow, anchorRelativePoint, anchorOffsetX, anchorOffsetY )
    
    WindowClearAnchors( Tooltips.curTooltipWindow )
    WindowAddAnchor( Tooltips.curTooltipWindow, anchorPoint, anchorToWindow, anchorRelativePoint, anchorOffsetX, anchorOffsetY )
    
end

----------------------------------------------------------------------------------------------------
--# Function: Tooltips.AnchorTooltip()
--#     Anchors to the specified anchor
--#
--#     Parameters:
--#         anchorDef       - (table) An anchor defintion.
--# 
--#         Format as follows....
--#
--#         anchorDef.Point           - (string) The name of the anchor point on the RelativeTo window. { "topleft", "top", "topright", "left", "center", "right", "bottomleft", "bottom", "bottomright" }
--#         anchorDef.RelativeTo      - (string) The name of another window to which you want to anchor this one. 
--#         anchorDef.RelativePoint   - (string) The name of the anchor point on the tooltip. { "topleft", "top", "topright", "left", "center", "right", "bottomleft", "bottom", "bottomright" }
--#         anchorDef.XOffset         - (number) The x pixel offset from this anchor location.
--#         anchorDef.YOffset         - (number) The y pixel offset from this anchor location.
--#
--#     Returns:
--#         nil - no return valuse
--#
--#     Notes:
--#         none
--#
----------------------------------------------------------------------------------------------------
function Tooltips.AnchorTooltip( anchor, ignoreStaticPlacementOption, internalIsAbilityTooltip )
    if( not Tooltips.curMouseOverWindow or not DoesWindowExist( Tooltips.curMouseOverWindow ) )
    then
        return
    end
    
    if not ignoreStaticPlacementOption and SystemData.Settings.GamePlay.staticTooltipPlacement and DoesWindowExist( "MouseOverTargetWindow" )
    then
        anchor = Tooltips.ANCHOR_MOUSE_OVER_TARGET_WINDOW
    end
    
    -- Intercept and rebuild this anchor due to the strange way the ability tooltip window is constructed
    -- TODO: Change ability tooltips to actually set parent window size properly so we don't need the internal param above and this intercept
    if internalIsAbilityTooltip == true and anchor == Tooltips.ANCHOR_MOUSE_OVER_TARGET_WINDOW
    then
        local x, y = WindowGetDimensions( "AbilityTooltipDesc" )
        local abilityMargin = 15
        local _, anchorYOffset = WindowGetDimensions( "AbilityTooltipActionText" )
        anchor = { Point = "bottomright", RelativeTo = "MouseOverTargetWindow", RelativePoint = "bottomright",
                   XOffset = -x - Tooltips.MOUSE_OVER_TARGET_TOOLTIP_MARGIN - abilityMargin,
                   YOffset = -anchorYOffset - Tooltips.MOUSE_OVER_TARGET_TOOLTIP_MARGIN - abilityMargin }
    end

    if (anchor == Tooltips.ANCHOR_WINDOW_VARIABLE)
    then
        -- Figure out where to anchor the current tooltip based on the curMouseOverWindow position.

        local mouseoverX, mouseoverY    = WindowGetScreenPosition (Tooltips.curMouseOverWindow)
        local screenWidth, screenHeight = WindowGetDimensions ("Root")
        local tipWidth, tipHeight       = WindowGetDimensions (Tooltips.curTooltipWindow)
        
        local relPointV = "top"
        local pointV    = "bottom"
        local offsV     = 4
        
        if (mouseoverY > (screenHeight / 2))
        then
            relPointV, pointV   = pointV, relPointV
            offsV               = -offsV
        end
        
        local relPointH = "left"
        local pointH    = "right"
        local offsH     = 4
        
        if (mouseoverX > (screenWidth / 2)) 
        then
            relPointH, pointH   = pointH, relPointH
            offsH               = -offsH
        end
        
        anchor = { Point = pointV..pointH, RelativeTo = "", RelativePoint = relPointV..relPointH, XOffset = offsH, YOffset = offsV }        
    end

    local anchorToWindow = anchor.RelativeTo

    if( anchorToWindow == ""  ) then
        
        anchorToWindow = Tooltips.curMouseOverWindow
    
    end 
    
    WindowClearAnchors( Tooltips.curTooltipWindow )
    WindowAddAnchor( Tooltips.curTooltipWindow, anchor.Point, anchorToWindow, anchor.RelativePoint, anchor.XOffset, anchor.YOffset ) 

    WindowSetAlpha( Tooltips.curTooltipWindow, 1.0 )
end

----------------------------------------------------------------------------------------------------
--# Function: Tooltips.CreateTextOnlyTooltip()
--#     Creates a basic tooltip with a single line of text. (Or initalizes a multiline text tooltip).
--#
--#     Parameters:
--#         mouseOverWindow         - (string) The window the mouse is currently over.
--#         text                    - (wstring) The text to display
--#
--#     Returns:
--#         nil - no return valuse
--#
--#     Notes:
--#         If you wish to create a formated tooltip with multiple pieces of text,
--#         call this function with text=nil, and then manually set the text for each row 
--#         colum with Tooltips.SetTooltipText() amd then call Tooltips.Finalize() to complete it.
--#
----------------------------------------------------------------------------------------------------
function Tooltips.CreateTextOnlyTooltip( mouseOverWindow, text )
    Tooltips.curMouseOverWindow = mouseOverWindow
    
    Tooltips.ClearTooltip()
    
    Tooltips.curTooltipWindow = "DefaultTooltip"

    if( text ~= nil ) then
        Tooltips.SetTooltipText( 1, 1, text )
        Tooltips.Finalize()
    end
    
    WindowSetShowing( Tooltips.curTooltipWindow, true )

    Tooltips.visible = true
        
end

----------------------------------------------------------------------------------------------------
--# Function: Tooltips.CreateCustomTooltip()
--#     Uses the specifed window for a custom tooltip. 
--#
--#     Parameters:
--#         mouseOverWindow         - (string) The window the mouse is currently over.
--#         text                    - (wstring) The text to display
--#
--#     Returns:
--#         nil - no return valuse
--#
--#     Notes:
--#         The tooltip system is only
--#         reponsible for displaying and hiding this window when appropriate. All data
--#         must be set elsewhere.
--#
----------------------------------------------------------------------------------------------------
function Tooltips.CreateCustomTooltip( mouseOverWindow, tooltipWindow )
    Tooltips.curMouseOverWindow = mouseOverWindow
    
    Tooltips.ClearTooltip()
    
    Tooltips.curTooltipWindow = tooltipWindow
    
    WindowSetShowing( Tooltips.curTooltipWindow, true )

    Tooltips.visible = true

end

--[[
    Returns the data field of the given extraTooltip window
    Returns nil if the window is not in the Tooltips.curExtraWindows table.
--]]
function Tooltips.GetExtraWindowData (windowName)
    if (windowName == nil) then
        return nil;
    end
    
    local index = 1
    while (Tooltips.curExtraWindows[index] ~= nil ) do
        if (Tooltips.curExtraWindows[index].name == windowName) then
            return Tooltips.curExtraWindows[index].data;
        end
        
        index = index + 1
    end
    
    return nil;
end

-- This helper function is used by Tooltips.AddExtraWindow, when it needs to anchor a tooltip to either the rightmost or leftmost of the existing tooltips.
-- windowBeingAnchored is the tooltip being anchored, so we must not return this window.  compareFunction is either math.min or math.max.
-- This function assumes that Tooltips.curTooltipWindow exists, since this function is only called when adding extra tooltips.
function Tooltips.GetLeftmostOrRightmostTooltip( windowBeingAnchored, compareFunction )
    
    local tooltip = Tooltips.curTooltipWindow
    local winX, _ = WindowGetScreenPosition( tooltip )
    
    local index = 1
    while (Tooltips.curExtraWindows[index] ~= nil) do
        local thisTooltip = Tooltips.curExtraWindows[index].name
        
        if (thisTooltip and DoesWindowExist(thisTooltip)) then
            local thisX, _    = WindowGetScreenPosition( thisTooltip )
            
            if (thisTooltip ~= windowBeingAnchored) and (compareFunction (thisX, winX) == thisX) then
                winX    = thisX
                tooltip = thisTooltip
            end
        end
        
        index = index + 1
    end
    
    return tooltip
end

--[[
    Adds an additional tooltip window anchored to some arbitrary window with an optional extra data parameter.
    If anchoring to the given windowToAnchorTo will make windowName be off the screen, then this anchors
    to the leftmost or rightmost of the existing tooltips, attempting to keep it entirely on the screen.
--]]
function Tooltips.AddExtraWindow (windowName, windowToAnchorTo, extraData)
    local index = 1
    while( Tooltips.curExtraWindows[index] ~= nil ) do
        index = index + 1
    end
    
    WindowSetShowing( windowName, true )
    Tooltips.curExtraWindows[index] = { name = windowName, data = extraData };
    
    -- Anchor the additional tooltip windows differently, depending on which side
    -- of the anchor to window of the anchorToWindow the anchorToWindow is placed.
    if WindowGetAnchorCount( windowToAnchorTo ) > 0
    then
        local _, _, anchorTo, _, _ = WindowGetAnchor (windowToAnchorTo, 1)
    end
    local parentParentX, parentParentY = 0, 0
    if( anchorTo and DoesWindowExist(anchorTo) ) then
        parentParentX, parentParentY = WindowGetScreenPosition(anchorTo)
    end
    
    local anchorWindowX, anchorWindowY          = WindowGetScreenPosition (windowToAnchorTo)
    local anchorWindowWidth, anchorWindowHeight = WindowGetDimensions (windowToAnchorTo)
    local newWindowWidth, newWindowHeight       = WindowGetDimensions (windowName)
    local rootWidth, rootHeight                 = WindowGetDimensions ("Root")
    
    -- WindowGetScreenPosition is returning scaled values, that match "Mouse Point" in the UI Debug window;
    -- we want unscaled, to match WindowGetDimensions.
    anchorWindowX = anchorWindowX/InterfaceCore.GetScale()

    WindowClearAnchors (windowName)
    
    if (anchorWindowX > parentParentX) then
        -- Try to anchor the new tooltip to the right of windowToAnchorTo, if it will fit on the screen.
        if (anchorWindowX + anchorWindowWidth + newWindowWidth < rootWidth) then
            WindowAddAnchor (windowName, "topright", windowToAnchorTo, "topleft", 0, 0)
        
        -- Otherwise anchor it to the left of the leftmost current tooltip window.
        else
            WindowAddAnchor (windowName, "topleft", Tooltips.GetLeftmostOrRightmostTooltip(windowName, math.min), "topright", 0, 0)
        end
        
    else
        -- Try to anchor the new tooltip to the left of windowToAnchorTo, if it will fit on the screen.
        if (anchorWindowX - newWindowWidth > 0) then
            WindowAddAnchor (windowName, "topleft", windowToAnchorTo, "topright", 0, 0) -- anchor on the left of windowToAnchorTo
            
        -- Otherwise anchor it to the right of the rightmost current tooltip window.
        else
            WindowAddAnchor (windowName, "topright", Tooltips.GetLeftmostOrRightmostTooltip(windowName, math.max), "topleft", 0, 0)
        end
    end

--[[    
    -- Anchor the additional tooltip windows differently, depending
    -- on where the original tooltip window appeared.
    -- Window offsets are not scaled, GetDimensions appears to be scaled.
    
    local x, y                      = WindowGetOffsetFromParent (Tooltips.curTooltipWindow);
    local curScale                  = WindowGetScale (Tooltips.curTooltipWindow)
    local screenWidth, screenHeight = WindowGetDimensions ("Root");
    
    if (curScale ~= 0) then
        x = x * curScale;
        y = y * curScale;
    end
    
    local wstrWindowName    = StringToWString (windowName);
    local wstrAnchorName    = StringToWString (windowToAnchorTo);
    --DEBUG (L"Anchoring: "..wstrWindowName..L" to "..wstrAnchorName);
    --DEBUG (L"Position: ("..x..L", "..y..L")");
    
    WindowClearAnchors (windowName);
    
    if (x < (screenWidth / 2)) then
        WindowAddAnchor (windowName, "topright", windowToAnchorTo, "topleft", 0, 0);
    else
        WindowAddAnchor (windowName, "topleft", windowToAnchorTo, "topright", 0, 0);
    end    
--]]    

    WindowSetAlpha( windowName, 1.0 )
end

function Tooltips.SetUpdateCallback( callbackFunction )
    Tooltips.curUpdateCallback = callbackFunction
end

function Tooltips.SetTooltipAlpha( alpha )
        
    WindowSetAlpha( Tooltips.curTooltipWindow, alpha )
    WindowSetFontAlpha( Tooltips.curTooltipWindow, alpha )

end

function Tooltips.SetTooltipText( row, column, text, ignoreFormattingTags )

    local ignoreTags = ignoreFormattingTags == true

    if( row < 0 or row > Tooltips.NUM_ROWS or 
        column < 0 or column > Tooltips.NUM_COLUMNS ) then
        return
    end
    
    Tooltips.curTooltipWindow = "DefaultTooltip"
    local name = ""..Tooltips.curTooltipWindow.."Row"..row.."Col"..column.."Text"
    
    local currText = LabelGetText( name )
    if ( currText ~= text ) then
        LabelSetIgnoreFormattingTags( name, ignoreTags )
        LabelSetText( name, text )
    end
end

function Tooltips.GetTooltipText( row, column )

    if( row < 0 or row > Tooltips.NUM_ROWS or 
        column < 0 or column > Tooltips.NUM_COLUMNS ) then
        return ""
    end
    
    Tooltips.curTooltipWindow = "DefaultTooltip"
    local name = ""..Tooltips.curTooltipWindow.."Row"..row.."Col"..column.."Text"
    
    return LabelGetText( name )
end

function Tooltips.SetTooltipActionText( text )
    LabelSetText( "DefaultTooltipActionText", text )
end

function Tooltips.SetTooltipFont( row, column, font, linespacing )

    if( row < 0 or row > Tooltips.NUM_ROWS or 
        column < 0 or column > Tooltips.NUM_COLUMNS ) then
        return
    end

   Tooltips.curTooltipWindow = "DefaultTooltip"
   -- LabelSetFont( Tooltips.curTooltipWindow.."Row"..row.."Col"..column.."Text", font, linespacing )

end

function Tooltips.SetTooltipColor( row, column, red, green, blue )

    if( row < 0 or row > Tooltips.NUM_ROWS or 
        column < 0 or column > Tooltips.NUM_COLUMNS ) then
        return
    end

    Tooltips.curTooltipWindow = "DefaultTooltip"
    LabelSetTextColor( ""..Tooltips.curTooltipWindow.."Row"..row.."Col"..column.."Text", red, green, blue )

end

function Tooltips.SetTooltipColorDef( row, column, colorDef )

    if( row < 0 or row > Tooltips.NUM_ROWS or 
        column < 0 or column > Tooltips.NUM_COLUMNS ) then
        return
    end

    Tooltips.curTooltipWindow = "DefaultTooltip"
    LabelSetTextColor( ""..Tooltips.curTooltipWindow.."Row"..row.."Col"..column.."Text", colorDef.r, colorDef.g, colorDef.b )

end

function Tooltips.Finalize()
    
    -- Calculate new tooltip dimensions
    local newWidth = 0
    local newHeight = 0
    local numRows = 0
    --DEBUG( L"Finializing tooltip" )
    
    local columWidths = {}
    local rowHeights = {}

    for rowNum = 1, Tooltips.NUM_ROWS do
        local rowWidth = 0
        local rowHeight = 0
        local numColumns = 0
        rowName = Tooltips.curTooltipWindow.."Row"..rowNum
        local rowX, rowY = WindowGetDimensions( rowName )

        
        -- calculate this row's width and height
        for colNum = 1, Tooltips.NUM_COLUMNS do
            colName = rowName.."Col"..colNum.."Text"
            local x, y = LabelGetTextDimensions( colName )
            local colX, colY = WindowGetDimensions( colName )
            --DEBUG(L"Tooltip ("..rowNum..L","..colNum..L") text dimensions = ("..x..L","..y..L")" )
            --DEBUG(L"    column dimensions = ("..colX..L","..colY..L")" )

            if( x > 0 ) then
                rowWidth = rowWidth + x
                numColumns = numColumns + 1
            end
            
            if( y > rowHeight ) then
                rowHeight = y
            end  
            
            -- Max width for this column
            if( columWidths[colNum] == nil or columWidths[colNum] < x ) then
                columWidths[colNum] = x
            end      
        end
        
        rowHeights[rowNum] = rowHeight
        
        --DEBUG(L"Tooltip ( Row "..rowNum..L" height = "..rowHeight )
        -- if the row's current height isn't what it should be, fix it
        if(true) then --if( rowHeight ~= rowY ) then
            WindowSetDimensions( rowName, rowX, rowHeight )
        end

        -- remember this row's width if it's the widest one we've processed
        if( rowWidth > newWidth ) then
            newWidth = rowWidth
            
            -- If the row has multiple columns, add space between them
            if( numColumns > 1 ) then
                newWidth = newWidth + 10*(numColumns-1)
            end
        end

        newHeight = newHeight + rowHeight
        
        if( rowHeight > 0 ) then
            numRows = numRows + 1
        end
    end
    
    -- Resize Column Tooltips.COLUMN_RIGHT_LEFT_ALIGN to the max column width for the left align to work correctly
    for rowNum = 1, Tooltips.NUM_ROWS do        
        local windowName = Tooltips.curTooltipWindow.."Row"..rowNum.."Col"..Tooltips.COLUMN_RIGHT_LEFT_ALIGN.."Text"
    
        local newWidth = columWidths[Tooltips.COLUMN_RIGHT_LEFT_ALIGN]
        local newHeight = rowHeights[rowNum]
        
        local w, h = WindowGetDimensions( windowName )
        if ( w ~= newWidth or h ~= newHeight ) then
            WindowSetDimensions( windowName, newWidth, newHeight )
        end
    end

    local x, y = LabelGetTextDimensions( "DefaultTooltipActionText" )
    x = x + 20 -- add some buffer zone for the anchor offset
    if( y > 0  ) then
        numRows = numRows + 1       
        if( x > newWidth ) then
            newWidth = x
        end
        newHeight = newHeight + y + 10
        
        local w, h = WindowGetDimensions( "DefaultTooltipActionText" )
        if ( w ~= newWidth or h ~= y ) then
            WindowSetDimensions( "DefaultTooltipActionText", newWidth, y )                   
        end
        
        local actionTextShowing = WindowGetShowing( "DefaultTooltipActionText" )
        
        if ( actionTextShowing == false ) then
            WindowSetShowing( "DefaultTooltipActionText", true )
        end
    else
        WindowSetShowing( "DefaultTooltipActionText", false )
    end

    newHeight = newHeight + Tooltips.BORDER_SIZE.Y * 2
    if( numRows > 1 ) then
        newHeight = newHeight + Tooltips.ROW_SPACING*(numRows-1)
    end
    newWidth = newWidth + Tooltips.BORDER_SIZE.X * 2

    local w, h = WindowGetDimensions( Tooltips.curTooltipWindow )
    if ( w ~= newWidth or h ~= newHeight ) then
        WindowSetDimensions( Tooltips.curTooltipWindow, newWidth, newHeight )
    end
    --DEBUG( L"Setting tooltip dimensions to "..newWidth..L", "..newHeight)
end

function Tooltips.CreateTwoLineActionTooltip( line1, line2, mouseOverWindow, anchor )

    LabelSetText( "TwoLineActionTooltipLine1", line1 )
    LabelSetText( "TwoLineActionTooltipLine2", line2 )

    local height = Tooltips.ItemTooltip.BORDER_SIZE

    
    local x, y = LabelGetTextDimensions( "TwoLineActionTooltipLine1" )
    if( y > 0 ) then
        y = y + 5 
    end 
    height = height + y   
    
    local x, y = LabelGetTextDimensions( "TwoLineActionTooltipLine2" )
    if( y > 0 ) then
        y = y + 5 
    end 
    height = height + y   
    
    WindowSetDimensions( "TwoLineActionTooltip", 310, height )  
    
    Tooltips.CreateCustomTooltip( mouseOverWindow, "TwoLineActionTooltip" )
    Tooltips.AnchorTooltip( anchor )
end 


----------------------------------------------------------
-- MONEY TOOLTIP
----------------------------------------------------------

function Tooltips.CreateMoneyTooltip( title, amountBrass, mouseoverWindow, anchor)
    
    -- Populate fields:
    LabelSetText( "MoneyTooltipTitle", title )
    MoneyFrame.FormatMoney( "MoneyTooltipMoney", amountBrass, MoneyFrame.HIDE_EMPTY_WINDOWS)
    
    -- Resize the tooltip:
    local moneyWidth, moneyHeight = WindowGetDimensions( "MoneyTooltipMoney" )
    local titleWidth, titleHeight = WindowGetDimensions( "MoneyTooltipTitle" )
    
    local width  = math.max( moneyWidth, titleWidth ) + 2*Tooltips.BORDER_SIZE.X
    local height = moneyHeight + titleHeight + 2*Tooltips.BORDER_SIZE.Y
    WindowSetDimensions( "MoneyTooltip", width, height )
    
    -- Display the tooltip:
    Tooltips.CreateCustomTooltip( mouseoverWindow, "MoneyTooltip" ) 
    Tooltips.AnchorTooltip( anchor )
end



function Tooltips.SetExtraText (windowName, labelName, seperatorName, extraText, extraTextColor)

    local label     = windowName..labelName;
    local seperator = windowName..seperatorName;
    
    if (extraText ~= nil) then
        LabelSetText (label, extraText);
    else
        LabelSetText (label, L"");
    end
    
    WindowSetShowing (label, extraText ~= nil);
    WindowSetShowing (seperator, extraText ~= nil);
    
    if (extraText ~= nil) then
        if (extraTextColor ~= nil) then
            LabelSetTextColor (label, extraTextColor.r, extraTextColor.g, extraTextColor.b);
        else
            LabelSetTextColor (label, Tooltips.COLOR_EXTRA_TEXT_DEFAULT.r,
                                      Tooltips.COLOR_EXTRA_TEXT_DEFAULT.g,
                                      Tooltips.COLOR_EXTRA_TEXT_DEFAULT.b);
        end
    end
    
    return LabelGetTextDimensions(label)
end

----------------------------------------------------------
-- List TOOLTIP
----------------------------------------------------------

local LIST_MAX_ITEMS = 10
local LIST_BULLET_OFFSET = 15
local LIST_SPACING_OFFSET = 15
function Tooltips.CreateListTooltip( title, text, listText, mouseoverWindow, anchor ) 
    
    local width = 0
    local height = 0
    
    -- Set the Heading    
    LabelSetText( "DefaultListTooltipTitle", title )
    local x, y = WindowGetDimensions( "DefaultListTooltipTitle" )
    width = math.max( width, x )
    height = height + y
    
    -- Set the Text
    LabelSetText( "DefaultListTooltipText", text )
    local x, y = WindowGetDimensions( "DefaultListTooltipText" )
    width = math.max( width, x )
    height = height + y

    for index = 1, LIST_MAX_ITEMS
    do    
        WindowSetShowing( "DefaultListTooltipItem"..index, listText[index] ~= nil )
        if( listText[index] ~= nil )
        then
            LabelSetText( "DefaultListTooltipItem"..index.."Text", listText[index] )
            local x, y = WindowGetDimensions( "DefaultListTooltipItem"..index.."Text" )
            width = math.max( width, x + LIST_BULLET_OFFSET)
            height = height + y
            
            WindowSetDimensions( "DefaultListTooltipItem"..index, x + LIST_BULLET_OFFSET, y )
        end
        
    end

    -- Add the Offsets
    width  = width + Tooltips.BORDER_SIZE.X * 2
    height = height + Tooltips.BORDER_SIZE.Y * 2 + LIST_SPACING_OFFSET
    WindowSetDimensions( "DefaultListTooltip", width, height )


    -- Create the tooltip
    Tooltips.CreateCustomTooltip(mouseoverWindow, "DefaultListTooltip");
    Tooltips.AnchorTooltip(anchor);
end
