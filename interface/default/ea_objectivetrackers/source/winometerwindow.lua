----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_WinOMeter = 
{
    STATUS_BAR_BACKGROUND_TINT          = { r=20, g=20, b=20 },
    STATUS_BAR_FOREGROUND_TINT          = { r=255, g=0, b=0 },
    currentValue                        = 100,
    scoreOrder                          = 0,
    scoreDestruction                    = 0,
    OFFSET_ORDER_TICKER_DEFAULT         = { x=0, y=-7 },
    OFFSET_DESTRUCTION_TICKER_DEFAULT   = { x=0, y=47 },
    TICKER_WIDTH                        = 280,
}

----------------------------------------------------------------
-- Local functions
----------------------------------------------------------------
local function ResetRealmAnchors( )

    local orderOffset = EA_Window_WinOMeter.OFFSET_ORDER_TICKER_DEFAULT
    WindowSetOffsetFromParent( "EA_Window_WinOMeterOrderTicker", orderOffset.x, orderOffset.y )
    
    local destructionOffset = EA_Window_WinOMeter.OFFSET_DESTRUCTION_TICKER_DEFAULT
    WindowSetOffsetFromParent( "EA_Window_WinOMeterDestructionTicker", destructionOffset.x, destructionOffset.y )
    
end

----------------------------------------------------------------
-- EA_Window_WinOMeter Functions
----------------------------------------------------------------
-- OnInitialize Handler
function EA_Window_WinOMeter.Initialize()

    LayoutEditor.RegisterWindow( "EA_Window_WinOMeter",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_WINOMETER_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_WINOMETER_WINDOW_DESC ),
                                false, false,
                                true, nil,
                                { "topleft", "top", "topright" } )
                                

    WindowRegisterEventHandler( "EA_Window_WinOMeter", SystemData.Events.PUBLIC_QUEST_SHOW_WINOMETER,   "EA_Window_WinOMeter.OnShowRequest")
    WindowRegisterEventHandler( "EA_Window_WinOMeter", SystemData.Events.PUBLIC_QUEST_HIDE_WINOMETER, "EA_Window_WinOMeter.OnHideRequest")
    WindowRegisterEventHandler( "EA_Window_WinOMeter", SystemData.Events.PUBLIC_QUEST_WINOMETER_UPDATED, "EA_Window_WinOMeter.OnUpdateRequest")
    WindowRegisterEventHandler( "EA_Window_WinOMeter", SystemData.Events.PUBLIC_QUEST_REMOVED, "EA_Window_WinOMeter.OnPublicQuestRemoved")
    
    -- Set up the status bar
    StatusBarSetMaximumValue( "EA_Window_WinOMeterStatusBar", 100 )
    
    local colorBackground = EA_Window_WinOMeter.STATUS_BAR_BACKGROUND_TINT
    local colorForeground = EA_Window_WinOMeter.STATUS_BAR_FOREGROUND_TINT    
    StatusBarSetBackgroundTint("EA_Window_WinOMeterStatusBar", colorBackground.r, colorBackground.g, colorBackground.b)
    StatusBarSetForegroundTint("EA_Window_WinOMeterStatusBar", colorForeground.r, colorForeground.g, colorForeground.b)
    
    -- Initially we want the bar full, a server update will provide
    -- the correct value when needed
    StatusBarSetCurrentValue( "EA_Window_WinOMeterStatusBar", 100 )
    
    -- Set up the initial anchors on the order and destruction tickers
    ResetRealmAnchors()
    
    -- Hide the window initially until needed by a PQ
    LayoutEditor.Hide( "EA_Window_WinOMeter" )
    
end


-- OnUpdateRequest Handler
function EA_Window_WinOMeter.OnUpdateRequest( newValue, orderScore, destructionScore )
    
    -- Update the full value of the win-o-meter's health
    EA_Window_WinOMeter.currentValue = newValue;
    StatusBarSetCurrentValue( "EA_Window_WinOMeterStatusBar", EA_Window_WinOMeter.currentValue )
    
    -- Update the individual realm ticker offsets where appropriate   
    EA_Window_WinOMeter.scoreOrder = orderScore; 
    local orderOffset = EA_Window_WinOMeter.OFFSET_ORDER_TICKER_DEFAULT
    local newOrderXOffset = EA_Window_WinOMeter.TICKER_WIDTH * (EA_Window_WinOMeter.scoreOrder / 100)    
    WindowSetOffsetFromParent( "EA_Window_WinOMeterOrderTicker", newOrderXOffset, orderOffset.y )
    
    EA_Window_WinOMeter.scoreDestruction = destructionScore;
    local destructionOffset = EA_Window_WinOMeter.OFFSET_DESTRUCTION_TICKER_DEFAULT
    local newDestructionXOffset = EA_Window_WinOMeter.TICKER_WIDTH * (EA_Window_WinOMeter.scoreDestruction / 100)
    WindowSetOffsetFromParent( "EA_Window_WinOMeterDestructionTicker", newDestructionXOffset, destructionOffset.y )
    
end


-- OnShowRequest Handler
function EA_Window_WinOMeter.OnShowRequest( )
    LayoutEditor.Show( "EA_Window_WinOMeter" )
end


-- OnHideRequest Handler
function EA_Window_WinOMeter.OnHideRequest( )
    LayoutEditor.Hide( "EA_Window_WinOMeter" )
end


-- OnPublicQuestRemoved Handler
function EA_Window_WinOMeter.OnPublicQuestRemoved( )
    
    ResetRealmAnchors()
    EA_Window_WinOMeter.OnHideRequest()
    
end


-- OnMouseOverStatus Handler
function EA_Window_WinOMeter.OnMouseOverStatus( )

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )    
    local row = 1
    local column = 1

    -- Title
    local text = GetString( StringTables.Default.LABEL_WINOMETER ) 
    Tooltips.SetTooltipFont( row, column, "font_default_sub_heading", WindowUtils.FONT_DEFAULT_SUB_HEADING_LINESPACING  )
    Tooltips.SetTooltipText( row, column, text )
    Tooltips.SetTooltipColor( row, column, 255, 204, 102 )
    
    row = row + 1
    
    -- Scores
    text = GetStringFormat(StringTables.Default.LABEL_WINOMETER_CURRENT_VALUE, { EA_Window_WinOMeter.currentValue } )
    Tooltips.SetTooltipText( row, column, text )
    row = row + 1
    
    text = GetStringFormat(StringTables.Default.LABEL_WINOMETER_ORDER_SCORE, { EA_Window_WinOMeter.scoreOrder } )
    Tooltips.SetTooltipText( row, column, text )
    row = row + 1
    
    text = GetStringFormat(StringTables.Default.LABEL_WINOMETER_DESTRUCTION_SCORE, { EA_Window_WinOMeter.scoreDestruction } )
    Tooltips.SetTooltipText( row, column, text )
    row = row + 1
    
    -- Anchors away!
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )     

end

