
------------------------------------------------------------------------------------------------------------------------------------------------
--# Title: HUD Editor
--#     This file contains the implementaion for the HUD layout editor.
------------------------------------------------------------------------------------------------------------------------------------------------

LayoutEditor = 
{
    WINDOW_NAME = "LayoutEditorWindow",

    windowsList     = {},           -- Window currently registered for editing. 
    framesList      = {},           -- Layout Frames currently active.
    
    controlFramesList   = {},       -- Control Frames for all of the selected LayoutFrames
    
    isActive        = false,
    hasChanges      = false,    
    
    
    Settings        = {},           -- Saved Settings
    EventHandlers   = {},           -- List of event handlers for various layout editor events, these are all functions
                                    -- The function will ideally match this signature:
                                    -- function Handler (eventCode)
    
    -- Layout Event Codes
    
    EDITING_BEGIN       = 1,        -- Passed to the event handler to indicated that the user has started the editing session.
    EDITING_END         = 2,        -- Passed to the event handler to indicated that the user has completed the editing session.
}

-- Settings Functions

local function SaveWindowSettings( windowData )
    LayoutEditor.Settings[ windowData.windowName ] = 
    { 
        locked            = windowData.isLocked, 
        hidden            = windowData.isUserHidden, 
    }
end

local function LoadWindowSettings( windowData )

    local settings = LayoutEditor.Settings[ windowData.windowName ]
    if( settings == nil )
    then
        return
    end 
    
    if( settings.locked ~= nil ) 
    then
        windowData.isLocked = settings.locked
    end
    
    if( settings.hidden ~= nil ) 
    then
        windowData.isUserHidden = settings.hidden
    end
end


-----------------------------------------------------------------------------------------------------------------------------
--  External API

function LayoutEditor.RegisterWindow( windowName, windowDisplayName, windowDesc, allowSizeWidth, allowSizeHeight, allowHiding, setHiddenCallback, allowableAnchorList, neverLockAspect, minSize, resizeEndCallback, moveEndCallback )
      
    if( LayoutEditor.windowsList[ windowName ] ~= nil )
    then
        ERROR( L"LayoutEditor.RegisterWindow: "..StringToWString(windowName)..L" is a duplicate!")
        return
    end       
    
    if( DoesWindowExist( windowName ) == false )
    then
        ERROR( L"LayoutEditor.RegisterWindow: "..StringToWString(windowName)..L" does not exist!")
        return
    end    

    local windowData = LayoutFrame.NewWindowData( windowName, windowDisplayName, windowDesc, allowSizeWidth, allowSizeHeight, allowHiding, setHiddenCallback, allowableAnchorList, neverLockAspect, minSize, resizeEndCallback, moveEndCallback )
    LoadWindowSettings( windowData )
    
    LayoutEditor.windowsList[windowName] = windowData 

end

function LayoutEditor.UnregisterWindow( windowName )
    
    if( LayoutEditor.windowsList[ windowName ] == nil )
    then
        --ERROR( L"LayoutEditor.UnregisterWindow: "..StringToWString(windowName)..L" is not registered")
        return
    end
    
    SaveWindowSettings( LayoutEditor.windowsList[ windowName ] )
    
    LayoutEditor.windowsList[ windowName ] = nil
    
    if( LayoutEditor.isActive )
    then
        local frame = LayoutEditor.framesList[ windowName ]
        if( frame )
        then
            frame:Detach( false )
            frame:Destroy()
        end
        
        LayoutEditor.framesList[ windowName ] = nil   
    end                 
    
end

function LayoutEditor.Show( windowName )
    if ( LayoutEditor.windowsList[ windowName ] == nil )
    then
        ERROR( L"LayoutEditor.Show: "..StringToWString(windowName)..L" is not registered")
        return
    end
    
    LayoutEditor.windowsList[ windowName ].isAppHidden = false

    WindowSetShowing( windowName, not LayoutEditor.windowsList[ windowName ].isUserHidden )
end

function LayoutEditor.Hide( windowName )
    if ( LayoutEditor.windowsList[ windowName ] == nil )
    then
        ERROR( L"LayoutEditor.Hide: "..StringToWString(windowName)..L" is not registered")
        return
    end
    
    LayoutEditor.windowsList[ windowName ].isAppHidden = true

    WindowSetShowing( windowName, false )
end

function LayoutEditor.UserShow( windowName )
    if ( LayoutEditor.windowsList[ windowName ] == nil )
    then
        ERROR( L"LayoutEditor.Show: "..StringToWString(windowName)..L" is not registered")
        return
    end
    
    LayoutEditor.windowsList[ windowName ].isUserHidden = false

    WindowSetShowing( windowName, not LayoutEditor.windowsList[ windowName ].isAppHidden )
end

function LayoutEditor.UserHide( windowName )
    if ( LayoutEditor.windowsList[ windowName ] == nil )
    then
        ERROR( L"LayoutEditor.Hide: "..StringToWString(windowName)..L" is not registered")
        return
    end
    
    LayoutEditor.windowsList[ windowName ].isUserHidden = true

    WindowSetShowing( windowName, false )
end

function LayoutEditor.IsWindowHidden( windowName )
    if ( LayoutEditor.windowsList[ windowName ] == nil )
    then
        ERROR( L"LayoutEditor.IsWindowHidden: "..StringToWString(windowName)..L" is not registered")
        return false
    end

    return LayoutEditor.windowsList[ windowName ].isAppHidden
end

function LayoutEditor.IsWindowUserHidden( windowName )
    if ( LayoutEditor.windowsList[ windowName ] == nil )
    then
        ERROR( L"LayoutEditor.IsWindowHidden: "..StringToWString(windowName)..L" is not registered")
        return false
    end

    return LayoutEditor.windowsList[ windowName ].isUserHidden
end

function LayoutEditor.SetDefaultHidden( windowName, isHidden )
    if ( LayoutEditor.windowsList[ windowName ] == nil )
    then
        ERROR( L"LayoutEditor.Hide: "..StringToWString(windowName)..L" is not registered")
        return
    end
    
    LayoutEditor.windowsList[ windowName ].isDefaultHidden = isHidden
end

function LayoutEditor.GetFrameForSourceWindow( windowName )
    
    if( LayoutEditor.windowsList[ windowName ] == nil )
    then
        ERROR( L"LayoutEditor.GetFrameForSourceWindow: "..StringToWString(windowName)..L" is not registered")
        return nil
    end

    return LayoutEditor.framesList[ windowName ]
end

function LayoutEditor.RegisterEditCallback( callbackFunction )

    table.insert( LayoutEditor.EventHandlers, callbackFunction )

end

-----------------------------------------------------------------------------------------------------------------------------
-- Core System Functions

function LayoutEditor.Initialize()
    RegisterEventHandler( SystemData.Events.PRE_MODULE_SHUTDOWNS, "LayoutEditor.OnPreShutdown" )
end   

function LayoutEditor.OnPreShutdown()
    if( LayoutEditor.isActive )
    then
        LayoutEditor.ResetExit()
    end
end

function LayoutEditor.Shutdown()
    -- Save out all the windows
    for index, windowData in pairs( LayoutEditor.windowsList ) 
    do       
        SaveWindowSettings( windowData )
    end
    LayoutEditor.windowsList = {}
    
end

function LayoutEditor.CallRegisteredEditorCallbacks( editorCode )

    for k, v in pairs( LayoutEditor.EventHandlers )
    do
        v( editorCode )
    end

end

-----------------------------------------------------------------------------------------------------------------------------
-- Mode Initialization

function LayoutEditor.Begin()

    LayoutEditor.isActive = true
    
    WindowUtils.ClearOpenList()
    
    -- Create the base editor window.
    CreateWindow( LayoutEditor.WINDOW_NAME, true )
    WindowAssignFocus( LayoutEditor.WINDOW_NAME, true )     
           

    -- Initialize the HUD Controls
    LabelSetText("LayoutEditorWindowHUDControlsTitleBarText", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_CONTROLS ) )
    ButtonSetText("LayoutEditorWindowHUDControlsOptionsButton",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_OPTIONS_BUTTON ) )    
    ButtonSetText("LayoutEditorWindowHUDControlsWindowsBrowserButton",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_WINDOWS_BUTTON ) )    
    ButtonSetText("LayoutEditorWindowHUDControlsRestoreDefaultsButton",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_RESTORE_DEFAULTS ) )
    ButtonSetText("LayoutEditorWindowHUDControlsExitButton",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_EXIT ) )    
     
    ButtonSetStayDownFlag( "LayoutEditorWindowHUDControlsWindowsBrowserButton", true ) 
           
    -- Initialize the Control Screen
    LabelSetText("LayoutEditorWindowControlScreenDialogTitleBarText", GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_LAYOUT_EDITOR ) )
    LabelSetText("LayoutEditorWindowControlScreenDialogScrollWindowScrollChildContainerDescText",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_LAYOUT_EDITOR_INTRO ) )
    LabelSetText("LayoutEditorWindowControlScreenDialogScrollWindowScrollChildContainerInstructionsLabel",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_INSTRUCTIONS ) )
    LabelSetText("LayoutEditorWindowControlScreenDialogScrollWindowScrollChildContainerInstructionsText",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_LAYOUT_EDITOR_INSTRUCTIONS ) )
    ScrollWindowUpdateScrollRect( "LayoutEditorWindowControlScreenDialogScrollWindow" )    
    ScrollWindowSetOffset( "LayoutEditorWindowControlScreenDialogScrollWindow", 0 )

    ButtonSetText("LayoutEditorWindowControlScreenDialogStartButton",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_START_LAYOUT_MODE ) )
    ButtonSetText("LayoutEditorWindowControlScreenDialogExitButton",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_EXIT ) )
    ButtonSetText("LayoutEditorWindowControlScreenDialogRestoreDefaultsButton",  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.LABEL_RESTORE_DEFAULTS ) )

        
       
    -- Create Manipulation framesList for each of the resistered windows.    
    for windowName, windowData in pairs( LayoutEditor.windowsList )
    do    
        local frame = LayoutFrame:Create( windowData, LayoutEditor.WINDOW_NAME )   
        LayoutEditor.framesList[ windowName ] = frame
    end
    
    -- Initialize all the framesList AFTER creation. 
    for _, frame in pairs( LayoutEditor.framesList ) 
    do   
        if( frame )
        then
            frame:Attach()               
        end
    end
    
    
    RegisterEventHandler( SystemData.Events.L_BUTTON_UP_PROCESSED,   "LayoutEditor.OnLButtonUpProcessed")  
    
    -- Initialize the Sub Windows
    LayoutEditor.InitializeWindowBrowser()
    LayoutEditor.InitializeOptions()
    
    LayoutEditor.CallRegisteredEditorCallbacks( LayoutEditor.EDITING_BEGIN )      
end

function LayoutEditor.End()

    UnregisterEventHandler( SystemData.Events.L_BUTTON_UP_PROCESSED,   "LayoutEditor.OnLButtonUpProcessed")  
    
    LayoutEditor.ClearActiveFrames()
 
    LayoutEditor.ShutdownWindowBrowser()
 
    -- Destroy all the Frames
    for _, frame in pairs( LayoutEditor.framesList ) 
    do       
        if( frame )
        then      
          frame:Destroy()
        end
    end
    LayoutEditor.framesList = {}
       
 
    DestroyWindow( "LayoutEditorWindow" )
    
    LayoutEditor.hasChanges = false
         
    LayoutEditor.isActive = false
    
    LayoutEditor.CallRegisteredEditorCallbacks( LayoutEditor.EDITING_END )
    
 end 
 
function LayoutEditor.UpdateWhenActive( timePassed )

    LayoutEditor.UpdateActiveFrames( timePassed )

end
 
 function LayoutEditor.ReleaseFrames( saveChanges )
    
    LayoutEditor.ClearSelection() 
    for _, frame in pairs( LayoutEditor.framesList ) 
    do       
        if( frame )
        then        
          frame:Detach( saveChanges )   
        end
    end
end

function LayoutEditor.SetChangedFlag()
    LayoutEditor.hasChanges = true
end
   
  
   
-----------------------------------------------------------------------------------------------------------------------------
-- Control Screen Button Callbacks

function LayoutEditor.ToggleOptions()
  WindowUtils.ToggleShowing( "LayoutEditorWindowOptions" )
  ButtonSetPressedFlag( "LayoutEditorWindowHUDControlsOptionsButton", WindowGetShowing( "LayoutEditorWindowOptions" ) )
end

function LayoutEditor.ToggleControlScreen()
    WindowUtils.ToggleShowing( "LayoutEditorWindowControlScreen" )
end

function LayoutEditor.ToggleWindowBrowser()
  WindowUtils.ToggleShowing( "LayoutEditorWindowControlScreenBrowser" )
  ButtonSetPressedFlag( "LayoutEditorWindowHUDControlsWindowsBrowserButton", WindowGetShowing( "LayoutEditorWindowControlScreenBrowser" ) )
end

function LayoutEditor.StartEditing()
    LayoutEditor.SetChangedFlag()
    LayoutEditor.ToggleControlScreen()
end

-- Restore Defaults
function LayoutEditor.OnMouseOverRestoreDefaults()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, 
        GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_RESTORE_DEFAULTS_TOOLTIP ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end

function LayoutEditor.RestoreDefaults()

    LayoutEditor.ClearSelection()
    
    -- Reset all of the framesList
    for _, frame in pairs( LayoutEditor.framesList ) 
    do       
        if( frame )
        then  
            frame:RestoreDefaults()  
        end
    end
    
    ForceProcessAllWindowAnchors()
    
    for _, frame in pairs( LayoutEditor.framesList ) 
    do       
        if( frame )
        then  
            frame:Attach()  
        end
    end
    
    LayoutEditor.SetChangedFlag()
end


-- Lock
function LayoutEditor.OnMouseOverLockAllWindows()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, 
        GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_LOCK_WINDOWS_TOOLTIP ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end

function LayoutEditor.LockAllWindows()

    LayoutEditor.ClearSelection() 
    for _, frame in pairs( LayoutEditor.framesList ) 
    do       
        if( frame )
        then        
          frame:SetLocked(true)
        end
    end
end

-- Unlock
function LayoutEditor.OnMouseOverUnlockAllWindows()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, 
        GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_UNLOCK_WINDOWS_TOOLTIP ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end
function LayoutEditor.UnlockAllWindows()

    LayoutEditor.ClearSelection() 
    for _, frame in pairs( LayoutEditor.framesList ) 
    do       
        if( frame )
        then        
          frame:SetLocked(false)
        end
    end
end

-- Show 
function LayoutEditor.OnMouseOverShowAllWindows()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, 
        GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_SHOW_WINDOWS_TOOLTIP ) )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT)
end

function LayoutEditor.ShowAllWindows()

    LayoutEditor.ClearSelection() 
    for _, frame in pairs( LayoutEditor.framesList ) 
    do       
        if( frame )
        then        
          frame:SetLocked(true)
        end
    end
end

function LayoutEditor.Exit()
    
    -- If nothing has changed, just exit.
    if( not LayoutEditor.hasChanges )
    then
        LayoutEditor.ResetExit()
        return
    end

    -- Otherwise pop up a dialog.
    DialogManager.MakeThreeButtonDialog(  GetStringFromTable( "CustomizeUiStrings", StringTables.CustomizeUi.TEXT_EXIT_SAVE_CONFIRM ), 
                                            GetString( StringTables.Default.LABEL_YES ), LayoutEditor.SaveExit, 
                                            GetString( StringTables.Default.LABEL_NO ),  LayoutEditor.ResetExit,
                                            GetString( StringTables.Default.LABEL_CANCEL ),  nil,
                                            nil, nil, nil, nil, DialogManager.TYPE_MODE_LESS)   
end


function LayoutEditor.SaveExit()
    LayoutEditor.OnLButtonUpProcessed()
    LayoutEditor.ReleaseFrames( true )
    LayoutEditor.End()
    
    ModulesSaveSettings() -- Force the settings files to be written to disk.
end


function LayoutEditor.ResetExit()
    LayoutEditor.OnLButtonUpProcessed()
    LayoutEditor.ReleaseFrames( false )
    LayoutEditor.End()
end



-- Active Frame

function LayoutEditor.SetActiveFrame( frame )
    LayoutEditor.ClearActiveFrames()
 
    -- Add the window as an active frame 
    local controlFrame = LayoutEditor.AddControlFrame( frame ) 

    return controlFrame
end


function LayoutEditor.AddControlFrame( layoutFrame )

    -- Check to see if this frame already has a control frame
    for _, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do 
        if( controlFrame:GetActiveFrame() == layoutFrame )
        then
            return controlFrame
        end
    end
        
    -- Spawn a new control frame                   
    local windowName = layoutFrame:GetName().."Controls"
    
    local controlFrame = LayoutControlFrame:Create( windowName, LayoutEditor.WINDOW_NAME )  
    controlFrame:SetActiveFrame( layoutFrame )
    
    table.insert( LayoutEditor.controlFramesList, controlFrame )
    
    -- Consider the layout to have changed the first time an window is selected.    
    LayoutEditor.SetChangedFlag()
    
    return controlFrame
end


function LayoutEditor.RemoveControlFrame( layoutFrame )

    -- Look for the Frame in the Table.
    for index, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do 
        if( controlFrame:GetActiveFrame() == layoutFrame )
        then
            controlFrame:SetActiveFrame( nil )
            controlFrame:DestroyInstance() 
            table.remove( LayoutEditor.controlFramesList, index ) 
        end
    end       
end



function LayoutEditor.ClearActiveFrames()
    
    for _, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do             
        controlFrame:SetActiveFrame( nil )
        controlFrame:DestroyInstance()       
    end
    
    LayoutEditor.controlFramesList = {}
end

function LayoutEditor.UpdateActiveFrames( timePassed )
    
    for _, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do             
        controlFrame:Update( timePassed )
    end
    
end


-- Manipulation Functions


function LayoutEditor.TrapClick()
    -- Prevents the click from dropping through to parent windows.
end


-- The LayoutFrame Only handles ButtonDown events because
-- a ControlFrame is always created in the ButtonDown Handler

function LayoutEditor.OnLayoutFrameButtonDown( flags )

    local frame  = GetFrame(  SystemData.ActiveWindow.name )       

    -- If shift is not pressed, clear any 
    -- windows that are currently selected
    if( flags ~= SystemData.ButtonFlags.SHIFT )
    then
        LayoutEditor.ClearActiveFrames()
    end         
    
    -- Add the window as an active frame 
    local controlFrame = LayoutEditor.AddControlFrame( frame ) 

    return controlFrame
end


function LayoutEditor.OnLayoutWindowLButtonDown( flags, x, y )
    
    LayoutEditor.OnLayoutFrameButtonDown( flags )
    
    -- Pass the OnLButtonDown event to all control frames  
    for _, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do 
        controlFrame:OnLButtonDown()
    end
end


function LayoutEditor.OnLayoutWindowRButtonDown( flags, x, y )
      
    -- Add the window as an active frame 
    local controlFrame = LayoutEditor.OnLayoutFrameButtonDown( flags )
    
    -- R Button Down Only operates on the single window.     
    controlFrame:OnRButtonDown()
end


function LayoutEditor.OnLayoutWindowMButtonDown( flags, x, y )

    LayoutEditor.OnLayoutFrameButtonDown( flags )
    
    -- Pass the OnMButtonDown event to all control frames  
    for _, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do 
        controlFrame:OnMButtonDown()
    end
end

function LayoutEditor.OnLayoutWindowMButtonUp( flags, x, y )
    for _, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do 
        controlFrame:OnMButtonUp()
    end
end

function LayoutEditor.ClearSelection()   
    LayoutEditor.ClearActiveFrames()
end

function LayoutEditor.OnControlFrameLButtonDown( flags, x, y )       
    
    -- If Shift is press, remove the control frame
    if( flags == SystemData.ButtonFlags.SHIFT )
    then
        local controlFrame  = GetFrame(  SystemData.ActiveWindow.name )   
        LayoutEditor.RemoveControlFrame( controlFrame:GetActiveFrame() )
        return
    end  
    
    -- Otherwise Pass the OnLButtonDown event to all control frames  
    for _, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do 
        controlFrame:OnLButtonDown()
    end
end

function LayoutEditor.OnControlFrameLButtonUp( flags, x, y ) 

    -- Pass the OnLButtonUp event to all control frames   
    for _, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do 
        controlFrame:OnLButtonUp()
    end
end


function LayoutEditor.OnControlFrameRButtonDown( flags, x, y )

    -- R Button Down Only operates on the single window.
    local frame = GetFrame( SystemData.ActiveWindow.name )               
    frame:OnRButtonDown()  
    
end

function LayoutEditor.OnControlFrameRButtonUp( flags, x, y )
    -- R Button Up Only operates on the single window.
    local frame = GetFrame( SystemData.ActiveWindow.name )               
    frame:OnRButtonUp()  
end

function LayoutEditor.OnControlFrameMButtonDown( flags, x, y )
    -- Pass the OnMButtonDown event to all control frames   
    for _, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do 
        controlFrame:OnMButtonDown()
    end
end

function LayoutEditor.OnControlFrameMButtonUp( flags, x, y )
    -- Pass the OnMButtonUp event to all control frames   
    for _, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do 
        controlFrame:OnMButtonUp()
    end
end

function LayoutEditor.BeginResize()      
    -- Pass the BeginResize event to all control frames   
    local buttonId = WindowGetId( SystemData.ActiveWindow.name ) 
    for _, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do 
        controlFrame:BeginResize( buttonId )
    end
end

function LayoutEditor.OnLButtonUpProcessed()
    -- Pass the LButtonUpProcessed event to all control frames    
    for _, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do 
        controlFrame:OnLButtonUpProcessed()
    end
end


function LayoutEditor.OnRawDeviceInput( deviceId, itemId, itemDown )
    -- Pass the OnRawDeviceInput event to all control frames  
    for _, controlFrame in pairs( LayoutEditor.controlFramesList ) 
    do 
        controlFrame:OnRawDeviceInput( deviceId, itemId, itemDown )
    end
end
