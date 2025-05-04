----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

RpBarWindow = {}

-- Left Status Bar Data

RpBarWindow.TOOLTIP_ANCHOR = { Point = "bottom",  RelativeTo = "RpBarWindow", RelativePoint = "top",  XOffset = 0, YOffset = 10 }

RpBarWindow.NUM_DIVISIONS = 8


----------------------------------------------------------------
-- Local functions
----------------------------------------------------------------


----------------------------------------------------------------
-- General Functions
----------------------------------------------------------------

function RpBarWindow.Initialize()

    -- Register this window for movement with the Layout Editor
    LayoutEditor.RegisterWindow( "RpBarWindow",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_RP_BAR_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_RP_BAR_DESC ),
                                true, false,
                                true, nil )
                                
        
    WindowRegisterEventHandler( "RpBarWindow", SystemData.Events.PLAYER_RENOWN_UPDATED, "RpBarWindow.UpdateRpBar")
    WindowRegisterEventHandler( "RpBarWindow", SystemData.Events.PLAYER_RENOWN_RANK_UPDATED, "RpBarWindow.UpdateRenownRank")
            
    WindowSetShowing( "RpBarWindowContentsText", false )        
            
    RpBarWindow.UpdateRpBar()
    
    -- Dynamically Create the desired number of tick marks.     
    local numTicks = RpBarWindow.NUM_DIVISIONS - 1    
    for tickIndex = 1, numTicks do     
        local windowName = "RpBarWindowContentsTick"..tickIndex        
        
        -- Alternate the tick marks
        if( math.mod( tickIndex, 2 ) == 1 ) then         
            CreateWindowFromTemplate( windowName, "EA_DynamicImage_HUDStatusBar_WideTickMarkMini", "RpBarWindowContents" )
        else
            CreateWindowFromTemplate( windowName, "EA_DynamicImage_HUDStatusBar_WideTickMark", "RpBarWindowContents" )
        end
    end    

    local width, height = WindowGetDimensions( "RpBarWindow" )
    RpBarWindow.OnSizeUpdated( width, height )        
end

function RpBarWindow.OnSizeUpdated( width, height )

    -- Update the Tick Marks to be spaced evenly across the bar
    local divisionWidth = width / RpBarWindow.NUM_DIVISIONS     
    local numTicks = RpBarWindow.NUM_DIVISIONS - 1
        
  
    local x, y = WindowGetDimensions( "RpBarWindowContentsTick1" )    
    local tickOffsetX = divisionWidth - x/2
    
    for tickIndex = 1, numTicks do 
        
        local windowName = "RpBarWindowContentsTick"..tickIndex        

        WindowClearAnchors( windowName )
        WindowAddAnchor( windowName, "topleft", "RpBarWindowContents", "top", tickOffsetX, 1 )                
    
        tickOffsetX = tickOffsetX + divisionWidth
    end           

end

function RpBarWindow.Shutdown()

end

function RpBarWindow.UpdateRpBar()

    EA_AdvancedWindowManager.UpdateWindowShowing( "RpBarWindowContents", EA_AdvancedWindowManager.WINDOW_TYPE_RP )
    
    local maRpoints = GameData.Player.Renown.curRenownNeeded
    local curPoints =  GameData.Player.Renown.curRenownEarned
   
    StatusBarSetMaximumValue( "RpBarWindowContentsBar", maRpoints )
    StatusBarSetCurrentValue( "RpBarWindowContentsBar", curPoints )       
    
    -- Set the displayable value on the RP label
    local text = GetStringFormat( StringTables.Default.TEXT_RENOWN_BAR, { curPoints, maRpoints } )
    LabelSetText( "RpBarWindowContentsText", text )
    
end

function RpBarWindow.UpdateRenownRank()
    Sound.Play( Sound.RENOWN_RANK_UP )
end

function RpBarWindow.SetLabelText()

    local curPoints = GameData.Player.Renown.curRenownEarned
    local maRpoints = GameData.Player.Renown.curRenownNeeded
    
    local percent = L"0"
    if(maRpoints > 0)
    then
        percent = wstring.format(L"%d", curPoints/maRpoints*100)
    end
    
    local title = GameData.Player.Renown.curTitle 
    if( title == L"" ) then
        title = GetString( StringTables.Default.LABEL_NONE) 
    end
    
    local line1 = GetString( StringTables.Default.LABEL_RENOWN_POINTS )
    local line2 = GetString( StringTables.Default.TEXT_RENOWN_BAR_DESC )
    local line3 = GetString( StringTables.Default.LABEL_RENOWN_RANK )..L": "..GameData.Player.Renown.curRank
    local line4 = GetString( StringTables.Default.LABEL_CUR_TITLE )..L": "..title		
    local line5 = GetStringFormat( StringTables.Default.TEXT_CUR_RENOWN, {curPoints, maRpoints, percent } ) 	
    
    Tooltips.SetTooltipText( 1, 1, line1)
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, line2)
    Tooltips.SetTooltipText( 3, 1, line3)
    Tooltips.SetTooltipColorDef( 3, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 4, 1, line4)
    Tooltips.SetTooltipColorDef( 4, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 5, 1, line5)
    Tooltips.SetTooltipColorDef( 5, 1, Tooltips.COLOR_HEADING )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( RpBarWindow.TOOLTIP_ANCHOR )   
    
end

-- OnMouseOver Handler for Rp bar
function RpBarWindow.MouseoverRpBar()

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetUpdateCallback( RpBarWindow.SetLabelText )
    
    WindowSetShowing( "RpBarWindowContentsText", true )    
end

-- OnMouseOverEnd Handler for Rp bar
function RpBarWindow.MouseoverEndRpBar()

    WindowSetShowing( "RpBarWindowContentsText", false )    
end
