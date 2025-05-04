----------------------------------------------------------------
-- Local Functions (placed here to avoid dependency issues)
----------------------------------------------------------------

----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_InteractionHealer = 
{
    penaltyCount                = 0,
    costToRemoveSinglePenalty   = 0,
}

EA_Window_InteractionHealer.TOOLTIP_ANCHOR = { Point = "topright",    RelativeTo = "EA_Window_InteractionHealer", RelativePoint = "topleft",    XOffset=5, YOffset=75 }
EA_Window_InteractionHealer.SCROLL_WINDOW_BASE_WIDTH = 370
EA_Window_InteractionHealer.SCROLL_WINDOW_BASE_HEIGHT = 202
EA_Window_InteractionHealer.ELEMENT_TO_EDGE_HEIGHT = 15 -- standard size between a UI element and the edge
EA_Window_InteractionHealer.SEPARATOR_OFFSET = 5 -- offset from a UI element and the top of the separator art
----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
-- Pull this into data collect
EA_Window_InteractionHealer.Width = 350
EA_Window_InteractionHealer.Height = 250

EA_Window_InteractionHealer.label1Width = 0
EA_Window_InteractionHealer.label1Height = 0

EA_Window_InteractionHealer.label2Width = 0
EA_Window_InteractionHealer.label2Height = 0

EA_Window_InteractionHealer.label3Width = 0
EA_Window_InteractionHealer.label3Height = 0

EA_Window_InteractionHealer.titleWidth = 0
EA_Window_InteractionHealer.titleHeight = 0

EA_Window_InteractionHealer.uiScale = 0.0


-- Function to get the Dimensions Data of the 3 labels
function EA_Window_InteractionHealer.CollectLabelsData()
    
    EA_Window_InteractionHealer.label1Width, EA_Window_InteractionHealer.label1Height = LabelGetTextDimensions("EA_Window_InteractionHealerMainScrollChildNumPenaltiesLabel")
    EA_Window_InteractionHealer.label2Width, EA_Window_InteractionHealer.label2Height = LabelGetTextDimensions("EA_Window_InteractionHealerMainScrollChildCostToRemoveLabel")
    EA_Window_InteractionHealer.label3Width, EA_Window_InteractionHealer.label3Height = LabelGetTextDimensions("EA_Window_InteractionHealerMainScrollChildCostToRemoveAllLabel")
    EA_Window_InteractionHealer.titleWidth, EA_Window_InteractionHealer.titleHeight = WindowGetDimensions("EA_Window_InteractionHealerTitleBar")		
    
    
    EA_Window_InteractionHealer.uiScale = WindowGetScale( "EA_Window_InteractionHealer")

end

----------------------------------------------------------------
-- EA_Window_InteractionHealer Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_InteractionHealer.Initialize()

    WindowRegisterEventHandler( "EA_Window_InteractionHealer", SystemData.Events.INTERACT_SHOW_HEALER,  "EA_Window_InteractionHealer.Show")
    WindowRegisterEventHandler( "EA_Window_InteractionHealer", SystemData.Events.INTERACT_DONE,          "EA_Window_InteractionHealer.Hide")

    ButtonSetText( "EA_Window_InteractionHealerHealAll", GetString( StringTables.Default.LABEL_HEAL_ALL ) )
    ButtonSetTextColor("EA_Window_InteractionHealerHealAll", Button.ButtonState.NORMAL, 222, 192, 50)
    ButtonSetText( "EA_Window_InteractionHealerHealOne", GetString( StringTables.Default.LABEL_HEAL_ONE ) )
    ButtonSetTextColor("EA_Window_InteractionHealerHealOne", Button.ButtonState.NORMAL, 222, 192, 50)
end


-- OnShutdown Handler
function EA_Window_InteractionHealer.Shutdown()

    WindowUnregisterEventHandler( "EA_Window_InteractionHealer", SystemData.Events.INTERACT_SHOW_HEALER )

end

function EA_Window_InteractionHealer.Show(penaltyCount, costToRemove)
    EA_Window_InteractionHealer.penaltyCount                = penaltyCount
    EA_Window_InteractionHealer.costToRemoveSinglePenalty   = costToRemove
    
    WindowSetShowing( "EA_Window_InteractionHealer", true )

    EA_Window_InteractionHealer.ShowDefaultFrame()   
end

function EA_Window_InteractionHealer.OnHidden()
    WindowUtils.OnHidden()
    -- Only play the sound if the window was actually open...
    PlayInteractSound("healer_goodbye")
end

function EA_Window_InteractionHealer.Hide()   
    WindowSetShowing( "EA_Window_InteractionHealer", false );
end

function EA_Window_InteractionHealer.OnShown()
    WindowUtils.OnShown(EA_Window_InteractionHealer.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
end

----------------------------------------------------------------
-- Default Interact Functions
----------------------------------------------------------------

function EA_Window_InteractionHealer.ShowDefaultFrame()
    -- Name
    LabelSetText( "EA_Window_InteractionHealerTitleBarText", GetString( StringTables.Default.LABEL_HEAL_PENALTIES) )
    LabelSetTextColor("EA_Window_InteractionHealerTitleBarText", 222, 192, 50)
    
    LabelSetText( "EA_Window_InteractionHealerMainScrollChildNumPenaltiesLabel", GetString( StringTables.Default.LABEL_NUM_PENALTIES ) )
    LabelSetText( "EA_Window_InteractionHealerMainScrollChildCostToRemoveLabel", GetString( StringTables.Default.LABEL_COST_TO_HEAL_A_PENALTY ) )    
    LabelSetText( "EA_Window_InteractionHealerMainScrollChildCostToRemoveAllLabel", GetString( StringTables.Default.LABEL_COST_TO_HEAL_ALL_PENALTIES ) ) 
    
    EA_Window_InteractionHealer.CollectLabelsData()
    
    -- Resizing of the window due to larger/smaller label text happens here
    EA_Window_InteractionHealer.UpdateLabels()
    
    -- Update the scroll window 
    --ScrollWindowSetOffset( "EA_Window_InteractionHealerMain", 0 )
    --ScrollWindowUpdateScrollRect( "EA_Window_InteractionHealerMain" )
    
    PlayInteractSound("healer_offer")
end

function EA_Window_InteractionHealer.HealOnePenalty()
    SystemData.UserInput.NumPenaltiesRequestingToHeal = 1
    BroadcastEvent( SystemData.Events.INTERACT_PURCHASE_HEAL )
    EA_Window_InteractionHealer.Hide()
end

function EA_Window_InteractionHealer.HealAllPenalties()
    SystemData.UserInput.NumPenaltiesRequestingToHeal = EA_Window_InteractionHealer.penaltyCount
    BroadcastEvent( SystemData.Events.INTERACT_PURCHASE_HEAL )
    EA_Window_InteractionHealer.Hide()
end

function EA_Window_InteractionHealer.UpdateLabels()

    LabelSetText( "EA_Window_InteractionHealerMainScrollChildNumPenalties", L""..EA_Window_InteractionHealer.penaltyCount )
    
    MoneyFrame.FormatMoney("EA_Window_InteractionHealerMainScrollChildCostToRemoveMoneyFrame", EA_Window_InteractionHealer.costToRemoveSinglePenalty, MoneyFrame.SHOW_EMPTY_WINDOWS )
    MoneyFrame.FormatMoney("EA_Window_InteractionHealerMainScrollChildCostToRemoveAllMoneyFrame", EA_Window_InteractionHealer.costToRemoveSinglePenalty * EA_Window_InteractionHealer.penaltyCount, MoneyFrame.SHOW_EMPTY_WINDOWS )
    
end

function EA_Window_InteractionHealer.OnRButtonUp()
    EA_Window_ContextMenu.CreateDefaultContextMenu( "EA_Window_InteractionHealer" );
end

