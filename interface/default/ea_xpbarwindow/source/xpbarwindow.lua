----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

XpBarWindow = {}

XpBarWindow.TOOLTIP_ANCHOR = { Point = "bottom",  RelativeTo = "XpBarWindow", RelativePoint = "top",  XOffset = 0, YOffset = 10 }

XpBarWindow.NUM_DIVISIONS = 10

XpBarWindow.NUM_TICKS = XpBarWindow.NUM_DIVISIONS - 1
XpBarWindow.barWidth = 0


----------------------------------------------------------------
-- Local functions
----------------------------------------------------------------


----------------------------------------------------------------
-- General Functions
----------------------------------------------------------------

function XpBarWindow.Initialize()

    -- Register this window for movement with the Layout Editor
    LayoutEditor.RegisterWindow( "XpBarWindow",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_XP_BAR_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_XP_BAR_DESC ),
                                true, false,
                                true, nil )
        
        
    WindowRegisterEventHandler( "XpBarWindow", SystemData.Events.PLAYER_EXP_UPDATED, "XpBarWindow.UpdateExpBar")
            
    WindowSetShowing( "XpBarWindowContentsText", false )        
            
    -- Dynamically Create the desired number of tick marks. 
    for tickIndex = 1, XpBarWindow.NUM_TICKS do     
        local windowName = "XpBarWindowContentsTick"..tickIndex        
        CreateWindowFromTemplate( windowName, "EA_DynamicImage_HUDStatusBar_NarrowTickMark", "XpBarWindowContents" )        
        CreateWindowFromTemplate( windowName.."Rest", "EA_DynamicImage_HUDStatusBar_NarrowTickMarkBright", "XpBarWindowContents" )        
    end    
    
    StatusBarSetMaximumValue( "XpBarWindowContentsRestBarBackground", 100 )
        
    XpBarWindow.UpdateExpBar()    
        
end

function XpBarWindow.OnBarSizeUpdated( width, height )

    XpBarWindow.barWidth = width

    -- Update the Tick Marks to be spaced evenly across the bar
    local divisionWidth = width / XpBarWindow.NUM_DIVISIONS     
  
    local x, y = WindowGetDimensions( "XpBarWindowContentsTick1" )    
    local tickOffsetX = divisionWidth - x/2
    
    for tickIndex = 1, XpBarWindow.NUM_TICKS do 
        
        local windowName = "XpBarWindowContentsTick"..tickIndex        

        -- Regular Tick Mark
        WindowClearAnchors( windowName )
        WindowAddAnchor( windowName, "topleft", "XpBarWindowContents", "top", tickOffsetX, -2 )            
        
        -- Rest Tick Mark
        WindowClearAnchors( windowName.."Rest" )
        WindowAddAnchor( windowName.."Rest", "topleft", "XpBarWindowContents", "top", tickOffsetX, -2 )                
    
        tickOffsetX = tickOffsetX + divisionWidth
    end           
    
    XpBarWindow.UpdateRestLimit()

end

function XpBarWindow.Shutdown()

end

function XpBarWindow.UpdateExpBar()
    
    if( GameData.Player.Experience.curXpNeeded == nil ) then
        return
    end
    
    EA_AdvancedWindowManager.UpdateWindowShowing( "XpBarWindowContents", EA_AdvancedWindowManager.WINDOW_TYPE_XP )
    
    
    local totalNeeded   = GameData.Player.Experience.curXpNeeded
    local totalEarned   = GameData.Player.Experience.curXpEarned
   
   
    -- Set the Xp Bar 
    StatusBarSetMaximumValue( "XpBarWindowContentsBar", totalNeeded )
    StatusBarSetCurrentValue( "XpBarWindowContentsBar", totalEarned )
    
    -- Set the displayable value on the XP label
    local text = GetStringFormat( StringTables.Default.TEXT_EXP_BAR, { totalEarned, totalNeeded } )
    LabelSetText( "XpBarWindowContentsText", text )
    
    -- Update the RestXP Bar    
    
    local hasRest     = GameData.Player.Experience.restXp > 0
    local showRestBar = hasRest
    
    
    -- If the Rest Xp is on/off, update the bar art.
    if( XpBarWindow.hasRest == nil or XpBarWindow.hasRest ~= hasRest ) then
    
        XpBarWindow.hasRest = hasRest        
        
        -- Background
        WindowSetShowing( "XpBarWindowContentsRestBarBackground", hasRest )
    
        -- Limit Marker
        WindowSetShowing( "XpBarWindowContentsRestXpLimitMarker", hasRest )
                
        -- Ticks
        for tickIndex = 1, XpBarWindow.NUM_TICKS do    
            WindowSetShowing( "XpBarWindowContentsTick"..tickIndex, not hasRest )
            WindowSetShowing( "XpBarWindowContentsTick"..tickIndex.."Rest", hasRest )  
        end    

        -- End Pieces
        WindowSetShowing( "XpBarWindowContentsLeftEndCap", not hasRest )  
        WindowSetShowing( "XpBarWindowContentsRightEndCap", not hasRest )  
        WindowSetShowing( "XpBarWindowContentsLeftEndCapRest", hasRest )  
        WindowSetShowing( "XpBarWindowContentsRightEndCapRest", hasRest )  
    end
       
    -- If the player has rest, update the ticks
    if( hasRest ) then
   
       -- The Rest XP value is the percentage of this level the player       
    
        local restPercent = XpBarWindow.GetRestPercent()
        StatusBarSetCurrentValue( "XpBarWindowContentsRestBarBackground", restPercent*100 )              
        
        -- Only show the rest and end caps if they are below the end of the bar.
        WindowSetShowing( "XpBarWindowContentsRestXpLimitMarker", restPercent < 100 )           
        WindowSetShowing( "XpBarWindowContentsRightEndCap", restPercent >= 100  )
                        
        XpBarWindow.UpdateRestLimit()
        
        -- Ticks - Show only those up to the end of the rest amount
        for tickIndex = 1, XpBarWindow.NUM_TICKS do  
            
            local showRestTick = tickIndex/XpBarWindow.NUM_DIVISIONS <= restPercent           
              
            WindowSetShowing( "XpBarWindowContentsTick"..tickIndex, not showRestTick )
            WindowSetShowing( "XpBarWindowContentsTick"..tickIndex.."Rest", showRestTick )  
        end    

    end
      
    --DEBUG(L"XP: cur="..totalEarned..L" needed="..totalNeeded..L" rest="..GameData.Player.Experience.restXp )
end

function XpBarWindow.GetRestPercent()
    local restPercent = (GameData.Player.Experience.curXpEarned + GameData.Player.Experience.restXp )/GameData.Player.Experience.curXpNeeded 
    return restPercent
end

function XpBarWindow.UpdateRestLimit()

    local xOffset = XpBarWindow.barWidth*XpBarWindow.GetRestPercent()
    
    WindowClearAnchors( "XpBarWindowContentsRestXpLimitMarker" )
    WindowAddAnchor( "XpBarWindowContentsRestXpLimitMarker", "left", "XpBarWindowContentsBar", "center", xOffset, 0 )    
    
end

function XpBarWindow.SetXPLabelText()

    local line1 = GetString( StringTables.Default.LABEL_EXP_POINTS )
    Tooltips.SetTooltipText( 1, 1, line1 )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )

    local line2 = GetString( StringTables.Default.TEXT_EXP_BAR_DESC )
    Tooltips.SetTooltipText( 2, 1, line2 )

    local line3 = L""
    local curPoints = GameData.Player.Experience.curXpEarned
    local maxPoints = GameData.Player.Experience.curXpNeeded
    if ( maxPoints == 0 ) then
        -- We're the maximum level.
        line3 = GetString( StringTables.Default.TEXT_CUR_EXP_MAXIMUM )
    else
        local percent = wstring.format(L"%d", curPoints / maxPoints * 100)
        line3 = GetStringFormat( StringTables.Default.TEXT_CUR_EXP, {curPoints, maxPoints, percent } )
    end
    Tooltips.SetTooltipText( 3, 1, line3 )
    Tooltips.SetTooltipColorDef( 3, 1, Tooltips.COLOR_HEADING )

    if (GameData.Player.Experience.restXp > 0) then
        local line4 = GetStringFormat( StringTables.Default.LABEL_EXP_RESTED, {GameData.Player.Experience.restXp} )
        Tooltips.SetTooltipText( 4, 1, line4 )
        Tooltips.SetTooltipColorDef( 4, 1, DefaultColor.XP_COLOR_RESTED )
    end

    Tooltips.Finalize()
    Tooltips.AnchorTooltip( XpBarWindow.TOOLTIP_ANCHOR )

end

-- OnMouseOver Handler for xp bar
function XpBarWindow.MouseoverXPBar()

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetUpdateCallback( XpBarWindow.SetXPLabelText )
    
    WindowSetShowing( "XpBarWindowContentsText", true )    
end

-- OnMouseOverEnd Handler for xp bar
function XpBarWindow.MouseoverEndXPBar()

    WindowSetShowing( "XpBarWindowContentsText", false )    
end
