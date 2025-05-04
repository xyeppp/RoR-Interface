----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
HelpTips = {}

HelpTips.openTips = nil
HelpTips.pendingTips = nil
HelpTips.closedTips = nil

HelpTips.helpTip = {}
HelpTips.MAX_VISIBLE_TIPS = 5
HelpTips.BUFFER_BETWEEN_TIPS = 2
HelpTips.HELP_TIP_WINDOW_NAME = "Help"
HelpTips.FOCUS_WINDOW_NAME = "Focus"
HelpTips.INDEX_OFFSET = 11799

local BASE_WINDOW_HEIGHT = 225
local MIN_TEXT_HEIGHT    = 75

----------------------------------------------------------------
-- Saved Variables
----------------------------------------------------------------



----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
HelpTips.currentShowing = 0
HelpTips.displayWindowOpen = false


local function NewTip( id, type )
    return { tipId = id, tipType = type }
end
----------------------------------------------------------------
-- Standard Window Functions
----------------------------------------------------------------

-- OnInitialize Handler
function HelpTips.Initialize()
    --
    --DEBUG(L"<*>Init HelpTips.Initialize()")   
    
    WindowRegisterEventHandler( "EA_HelpTipsContainerWindow", SystemData.Events.HELP_TIP_UPDATED, "HelpTips.AddTip" )   
       
    HelpTips.openTips = Queue:Create()
    HelpTips.closedTips = Queue:Create()  
    HelpTips.pendingTips = Queue:Create()
    
    for index = 0, HelpTips.MAX_VISIBLE_TIPS do
        local windowName = "Tip"..index
        CreateWindowFromTemplate(windowName, "EA_HelpTipBase", "EA_HelpTipsContainerWindow")
        WindowSetId( windowName, index )
        WindowSetShowing(windowName, false )
        HelpTips.closedTips:PushBack(index)
    end
    
    -- Resize the container
    local winX, winY = WindowGetDimensions("Tip1")
    local finalWidth = ( HelpTips.MAX_VISIBLE_TIPS + 1 ) * (winX + (HelpTips.BUFFER_BETWEEN_TIPS * 2) )
    WindowSetDimensions("EA_HelpTipsContainerWindow", finalWidth, winY)   
    
    --DEBUG(L"    Initialization Complete...")       
    
    CreateWindowFromTemplate( HelpTips.HELP_TIP_WINDOW_NAME, "EA_HelpTipWindow", "Root")
    WindowSetShowing( HelpTips.HELP_TIP_WINDOW_NAME, false )
    WindowAddAnchor( HelpTips.HELP_TIP_WINDOW_NAME, "topleft", "EA_HelpTipsContainerWindow", "bottom", 0, 50 )
    ButtonSetText( HelpTips.HELP_TIP_WINDOW_NAME.."CloseButton", GetString(StringTables.Default.LABEL_CLOSE) )
    ButtonSetCheckButtonFlag( HelpTips.HELP_TIP_WINDOW_NAME.."CheckButtonButton", true )    
    
    CreateWindowFromTemplate( HelpTips.FOCUS_WINDOW_NAME, "EA_FocusWindow", "Root")
    WindowSetShowing( HelpTips.FOCUS_WINDOW_NAME, false )

    LayoutEditor.RegisterWindow( "EA_HelpTipsContainerWindow",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_HELP_TIPS_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_HELP_TIPS_WINDOW_DESC ),
                                false, false,
                                true, nil )
    
end

function HelpTips.Shutdown()
    HelpTips.openTips:Clear()
    HelpTips.closedTips:Clear()
end

function HelpTips.CreateHelpTip( tip )     
    -- Creating help tips creates a help tip {id, tipId} pair and slaps it into the open list
    -- id = the ToK id
   
    -- when creating, first see if exist open slot
    local freeSlot = HelpTips.GetId()    
    if( freeSlot == nil ) then
        -- no free display slot, slap it in the pending list        
        HelpTips.pendingTips:PushBack( tip )
    else
        -- since GetId() already poped the closed, we add this to the open        
        HelpTips.openTips:PushBack( tip )
    end

    HelpTips.ShowHelpTips()
    
    if ( freeSlot ~= nil )
    then
        HelpTips.AnimateTip(freeSlot)
    end
    
end

function HelpTips.RemoveHelpTip( windowId )
    --DEBUG(L"#--#HelpTips.RemoveHelpTip( "..windowId..L" ) ")
    
    local tempList = HelpTips.openTips
    local finalList = Queue:Create()
    for index = tempList:Begin(), tempList:End() do
        if( index ~= windowId ) then
            -- copy it over to the final
            local val = tempList[ index ]
            finalList:PushBack( val )
        end
        tempList:PopFront()
    end
    
    HelpTips.openTips:Clear()
    for index = finalList:Begin(), finalList:End() do
        HelpTips.openTips:PushBack(finalList[ index ])
    end
    
    if( HelpTips.pendingTips:IsEmpty() ) then
        -- pending is empty, need to add one to the closedList
        local lastIndexInOpen = HelpTips.openTips:End()
        HelpTips.closedTips:PushFront( lastIndexInOpen + 1 )
    else
        -- pending is not empty, add it to the open
        local val = HelpTips.pendingTips:PopFront()
        HelpTips.openTips:PushBack( val )
    end   
    
    HelpTips.ShowHelpTips()     
end

function HelpTips.OnLTipPress()
    local tipWindowButton = SystemData.ActiveWindow.name
    local tipWindowParent = WindowGetParent( tipWindowButton )
    local tipId = WindowGetId( tipWindowParent ) 
   
    -- If the Focus Window Was showing, remove it, in case our current help tip does not need it
    if( WindowGetShowing( HelpTips.FOCUS_WINDOW_NAME ) ) then
        WindowSetShowing(HelpTips.FOCUS_WINDOW_NAME, false)
    end
    
    if( HelpTipsReferences.ToKIdMappings[HelpTips.openTips[ tipId ].tipId] ) then
        -- We clicked on a tip that has a window reference, focus the frame on the widow
        local windowName = HelpTipsReferences.ToKIdMappings[HelpTips.openTips[ tipId ].tipId]
        HelpTips.SetFocusOnWindow( windowName )
    end
    -- When you LPress on a ?, show the Window and remove the ?
    
    HelpTips.DisplayTipWindow( HelpTips.openTips[ tipId ] )
    HelpTips.currentShowing =  tipId    
       
end

function HelpTips.OnRTipPress()
    if( HelpTips.displayWindowOpen ) then
        --
    else
        local tipWindowButton = SystemData.ActiveWindow.name
        local tipWindowParent = WindowGetParent( tipWindowButton )
        local tipId = WindowGetId( tipWindowParent ) 
        HelpTips.RemoveHelpTip(tipId)
    end
    --    
end

function HelpTips.OnMouseOverTip()
    --
    local tipWindowButton = SystemData.ActiveWindow.name
    local tipWindowParent = WindowGetParent( tipWindowButton )
    local tipId = HelpTips.openTips[ WindowGetId(tipWindowParent) ].tipId

    local id = tipId - HelpTips.INDEX_OFFSET
    local tipName, tipText = GetHelpTipStrings( id )
    tipText = GetStringFormat( StringTables.Default.TEXT_HELP_TIP_TOOLTIP, { tipName } )
    
    Tooltips.CreateTextOnlyTooltip( tipWindowButton, nil )     
    local row = 1
    local column = 1
    Tooltips.SetTooltipText( row, column, tipName )

    row = row + 1 
    Tooltips.SetTooltipColor( row, column, 140, 100, 0 )
    Tooltips.SetTooltipText( row, column, tipText )
    
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
    
end

function HelpTips.AnimateTip( id )
    -- First get the window
    local animWindow = "Tip"..id     
    WindowStartAlphaAnimation(animWindow.."ImageOne", Window.AnimationType.LOOP, 1, 0, 0.5, false, 0, 0)
end

function HelpTips.StopAnimatingTip( id )
    local animWindow = "Tip"..id    
    WindowStopAlphaAnimation(animWindow.."ImageOne")
end    

function HelpTips.GetId()
--  
    local curId
    if( HelpTips.closedTips:IsEmpty() ) then        
        -- closed is empty, meaning all 6 tips are being shown, add the tip to the pending list
        -- signified by a returned Id of nil
        curId = nil
    else
        curId = HelpTips.closedTips:PopFront()
    end
    return curId
end

function HelpTips.ShowHelpTips()
--
    local openList = HelpTips.openTips
        
    for index = 0, HelpTips.MAX_VISIBLE_TIPS do
        local windowName = "Tip"..index
        if( WindowGetShowing( windowName ) ) then
            WindowSetShowing( windowName, false )
        end
    end

    -- go through the open and show the windows
    for index = openList:Begin(), openList:End() do
        local windowIndex = index 
        if( windowIndex ~= nil ) then
            local windowName = "Tip"..windowIndex    
            WindowClearAnchors( windowName )
            if( windowIndex == 0 ) then                
                WindowAddAnchor(windowName, "left", "EA_HelpTipsContainerWindow", "left", HelpTips.BUFFER_BETWEEN_TIPS, 0)                            
            else
                local prevWindowIndex = windowIndex - 1
                local prevWindowName = "Tip"..prevWindowIndex
                WindowAddAnchor(windowName, "right", prevWindowName, "left", HelpTips.BUFFER_BETWEEN_TIPS, 0)
            end
            WindowSetShowing( windowName, true )            
        end
    end        
end

function HelpTips.DisplayTipWindow( tip )
    local id = tip.tipId - HelpTips.INDEX_OFFSET
    local type = tip.tipType
    local tipName, tipDesc = GetHelpTipStrings( id )
    WindowClearAnchors( HelpTips.HELP_TIP_WINDOW_NAME )
    WindowAddAnchor( HelpTips.HELP_TIP_WINDOW_NAME, "top", "Tip"..0, "bottom", 0, -20 )
    if( WindowGetShowing( HelpTips.HELP_TIP_WINDOW_NAME )) then
    --
    else
       WindowSetShowing(HelpTips.HELP_TIP_WINDOW_NAME, true)
       HelpTips.displayWindowOpen = true
    end
    
    LabelSetText( HelpTips.HELP_TIP_WINDOW_NAME.."TitleText", tipName )
    LabelSetText( HelpTips.HELP_TIP_WINDOW_NAME.."Text", tipDesc )
        
    -- Size the Window according to the Text Height
    local _, textHeight  = LabelGetTextDimensions( HelpTips.HELP_TIP_WINDOW_NAME.."Text" )
    local windowWidth, _ = WindowGetDimensions( HelpTips.HELP_TIP_WINDOW_NAME )
    local windowHeight = BASE_WINDOW_HEIGHT + math.max( textHeight, MIN_TEXT_HEIGHT )
    WindowSetDimensions( HelpTips.HELP_TIP_WINDOW_NAME, windowWidth, windowHeight )
    
    
    LabelSetText( HelpTips.HELP_TIP_WINDOW_NAME.."CheckButtonLabel", HelpTipsReferences.TipTypes[type].typeLabel )
    local flag = true
    if( type == 1 ) then
        flag = SystemData.Settings.GamePlay.showBeginnerHelpTips
    elseif( type == 2 ) then
        flag = SystemData.Settings.GamePlay.showGameplayHelpTips
    elseif( type == 3 ) then
        flag = SystemData.Settings.GamePlay.showUiHelpTips
    elseif( type == 4 ) then
        flag = SystemData.Settings.GamePlay.showAdvancedHelpTips
    else
        --
    end    
    ButtonSetPressedFlag( HelpTips.HELP_TIP_WINDOW_NAME.."CheckButtonButton", flag )
    HelpTipsReferences.TipTypes[type].typeVar = flag    
end

function HelpTips.OnCloseButton()
--    
    if( WindowGetShowing( HelpTips.FOCUS_WINDOW_NAME ) ) then
        --
        WindowStopAlphaAnimation( HelpTips.FOCUS_WINDOW_NAME )
        WindowSetShowing( HelpTips.FOCUS_WINDOW_NAME, false )        
    else
        --
    end
    local disabled = ButtonGetPressedFlag( HelpTips.HELP_TIP_WINDOW_NAME.."CheckButtonButton" )   
    local tipInfo = HelpTips.openTips[ HelpTips.currentShowing ]
    local currentSetting = HelpTipsReferences.TipTypes[ tipInfo.tipType ].typeVar
    
    if( currentSetting ~= disabled ) then
        HelpTips.UpdateSaveSettings( tipInfo.tipType, disabled )               
    end    
    HelpTips.RemoveHelpTip( HelpTips.currentShowing )    
    WindowSetShowing( HelpTips.HELP_TIP_WINDOW_NAME, false )
    HelpTips.displayWindowOpen = false       
end

function HelpTips.SetFocusOnWindow( windowName )
--
    WindowClearAnchors( HelpTips.FOCUS_WINDOW_NAME ) 
    WindowAddAnchor( HelpTips.FOCUS_WINDOW_NAME, "topleft", windowName, "topleft", -2, -2 )
    WindowAddAnchor( HelpTips.FOCUS_WINDOW_NAME, "bottomright", windowName, "bottomright", 2, 2 )
    if( WindowGetShowing( HelpTips.FOCUS_WINDOW_NAME ) ) then
        --
    else
        WindowSetShowing( HelpTips.FOCUS_WINDOW_NAME, true )
    end    
    WindowStartAlphaAnimation(HelpTips.FOCUS_WINDOW_NAME, Window.AnimationType.LOOP, 1, 0, 0.5, false, 0, 0)

    
    Sound.Play( GameData.Sound.HELP_TIPS_HIGHTLIGHT_WINDOW )
end

function HelpTips.AnchorContainerWindow()
    -- if it was previously positioned with the LayoutEditor and settings were saved, do not move it
    local point, relativePoint, relativeTo, xoffs, yoffs = WindowGetAnchor( "EA_HelpTipsContainerWindow", 1 )  
    if ( point == "bottom" and relativePoint == "bottom" and relativeTo == "Root" and 
            xoffs > 255 and xoffs < 257 and yoffs > -201 and yoffs < -199) 
    then
        -- It had default anchoring. Can assume player didn't position it themselves, so we can do it now. 
        -- now if only we could just ask the LayoutEditor if the window had been moved using LayoutEditor!
        WindowClearAnchors("EA_HelpTipsContainerWindow" )
        if( DoesWindowExist( "EA_CareerResourceWindow") ) then
            WindowAddAnchor("EA_HelpTipsContainerWindow", "top", "EA_CareerResourceWindow", "bottomleft", -35, 0)
        else
            if( DoesWindowExist( "EA_GrantedAbilities" ) ) then
                WindowAddAnchor("EA_HelpTipsContainerWindow", "topright", "EA_GrantedAbilities", "bottomright", 75, 0)
            else
                WindowAddAnchor("EA_HelpTipsContainerWindow", "topright", "EA_ActionBar1", "bottomleft", -45, -15)
            end
        end
    end
    WindowForceProcessAnchors("EA_HelpTipsContainerWindow")
end

function HelpTips.AddTip( tipId, tipType )
    HelpTips.AnchorContainerWindow()

    local newTip = NewTip( tipId, tipType )    
    HelpTips.CreateHelpTip( newTip )
        
    Sound.Play( GameData.Sound.HELP_TIPS_NEW ) 
end

function HelpTips.UpdateSaveSettings( type, newVal )
    if( type == 1 ) then
        SystemData.Settings.GamePlay.showBeginnerHelpTips = newVal
    elseif( type == 2 ) then
        SystemData.Settings.GamePlay.showGameplayHelpTips = newVal
    elseif( type == 3 ) then
        SystemData.Settings.GamePlay.showUiHelpTips = newVal
    elseif( type == 4 ) then
        SystemData.Settings.GamePlay.showAdvancedHelpTips = newVal
    else
     --
    end
    BroadcastEvent( SystemData.Events.USER_SETTINGS_CHANGED )    
end


    
    