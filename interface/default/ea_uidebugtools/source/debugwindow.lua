
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

DebugWindow = {}

DebugWindow.Settings = 
{
    logsOn = false,
    useDevErrorHandling = false,
    loadLuaDebugLibrary = false
}
DebugWindow.Settings.LogFilters = {}
DebugWindow.Settings.LogFilters[ SystemData.UiLogFilters.SYSTEM ]   = { enabled=true,   color=DefaultColor.MAGENTA }
DebugWindow.Settings.LogFilters[ SystemData.UiLogFilters.WARNING ]  = { enabled=true,   color=DefaultColor.ORANGE } 
DebugWindow.Settings.LogFilters[ SystemData.UiLogFilters.ERROR ]    = { enabled=true,   color=DefaultColor.RED }
DebugWindow.Settings.LogFilters[ SystemData.UiLogFilters.DEBUG ]    = { enabled=true,   color=DefaultColor.YELLOW } 
DebugWindow.Settings.LogFilters[ SystemData.UiLogFilters.LOADING ]  = { enabled=false,  color=DefaultColor.LIGHT_GRAY } 
DebugWindow.Settings.LogFilters[ SystemData.UiLogFilters.FUNCTION ] = { enabled=false,  color=DefaultColor.GREEN }

DebugWindow.currentMouseoverWindow = nil

-- For Internal Builds, Default the Settings to the current log states in the pregame 
-- if the log is currently enabled.
if( IsInternalBuild() and (InterfaceCore.inGame == false) and TextLogGetEnabled( "UiLog" ) )
then
    DebugWindow.Settings.logsOn = true 
    DebugWindow.Settings.useDevErrorHandling = GetUseLuaErrorHandling()
    DebugWindow.Settings.loadLuaDebugLibrary = GetLoadLuaDebugLibrary()
    
    -- Filters
    for filterType, filterData in pairs( DebugWindow.Settings.LogFilters )
    do
       filterData.enabled = TextLogGetFilterEnabled( "UiLog", filterType)
    end   
    
end

local function HandlePregameInit()

    if( IsInternalBuild() and (InterfaceCore.inGame == false) )
    then

        -- If the Logs are enabled in the pregame, show the window
        if( DebugWindow.Settings.logsOn )
        then
            WindowSetShowing( "DebugWindow", true )
        end
    end
end

----------------------------------------------------------------
-- DebugWindow Functions
----------------------------------------------------------------

local function UpdateLoggingButton ()

    if ( DebugWindow.Settings.logsOn == true) then
        ButtonSetText("DebugWindowToggleLogging", L"Logs (On)") 
    else
        ButtonSetText("DebugWindowToggleLogging", L"Logs (Off)")
    end

end

-- OnInitialize Handler
function DebugWindow.Initialize()
    
    -- Setup the Log
    DebugWindow.UpdateLog()
    
    -- Init the Settings
    for filterName, filterType in pairs( SystemData.UiLogFilters )
    do
        if( DebugWindow.Settings.LogFilters[filterType] == nil )
        then
            DebugWindow.Settings.LogFilters[filterType] = { enabled=true, color=DefaultColors.WHITE }
        end
    end
    
    LabelSetText( "DebugWindowTitleBarText", L"UI Debugging Window" )

    LabelSetText("DebugWindowMouseOverLabel", L"Mouseover Window:" )
    LabelSetText("DebugWindowMousePointLabel", L"Mouse Point: " )
    LabelSetText("DebugWindowMousePointText", L"" )
    
    -- Display Settings
    LogDisplaySetShowTimestamp( "DebugWindowText", false )
    LogDisplaySetShowLogName( "DebugWindowText", true )
    LogDisplaySetShowFilterName( "DebugWindowText", true )

    -- Add the Lua Log
    DebugWindow.AddUiLog()        
    ButtonSetText("DebugWindowReloadUi", L"Reload UI")


    -- Options              
    ButtonSetText( "DebugWindowToggleOptions", L"Options")  
    
    
    CreateWindow( "DebugWindowOptions", false )
    LabelSetText( "DebugWindowOptionsTitleBarText", L"Debug Options")
    
    LabelSetText( "DebugWindowOptionsFiltersTitle", L"Logging Filters:" )
    LabelSetText( "DebugWindowOptionsFilterType1Label", L"Ui System Messages" )
    LabelSetText( "DebugWindowOptionsFilterType2Label", L"Warning Messages" )    
    LabelSetText( "DebugWindowOptionsFilterType3Label", L"Error Messages" )
    LabelSetText( "DebugWindowOptionsFilterType4Label", L"Debug Messages" )
    LabelSetText( "DebugWindowOptionsFilterType5Label", L"Function Calls Messages" )
    LabelSetText( "DebugWindowOptionsFilterType6Label", L"File Loading Messages" )
    
    -- Options
    for filterType, filterData in pairs( DebugWindow.Settings.LogFilters )
    do
        local buttonName = "DebugWindowOptionsFilterType"..filterType.."Button"
        ButtonSetStayDownFlag( buttonName, true )
        
        LogDisplaySetFilterState( "DebugWindowText", "UiLog", filterType, filterData.enabled )
        ButtonSetPressedFlag( buttonName, filterData.enabled )    
        WindowSetId( buttonName, filterType )
        
        -- When UI Log filters are off, disable logging of that filter type entirely.
        TextLogSetFilterEnabled( "UiLog", filterType, filterData.enabled  )
    end

    LabelSetText(  "DebugWindowOptionsErrorHandlingTitle", L"Generate lua-errors from:" )
    LabelSetText(  "DebugWindowOptionsErrorOption1Label", L"Lua calls to ERROR()" )
    LabelSetText(  "DebugWindowOptionsErrorOption2Label", L"Errors in lua calls to C" )
    
    for index = 1, 2 
    do
        ButtonSetStayDownFlag( "DebugWindowOptionsErrorOption"..index.."Button", true )
    end
    ButtonSetPressedFlag( "DebugWindowOptionsErrorOption1Button", DebugWindow.Settings.useDevErrorHandling  )    
    ButtonSetPressedFlag( "DebugWindowOptionsErrorOption2Button", GetUseLuaErrorHandling() )    
        
    LabelSetText(  "DebugWindowOptionsLuaDebugLibraryLabel", L"Load Lua Debug Library" )
    ButtonSetPressedFlag( "DebugWindowOptionsLuaDebugLibraryButton", GetLoadLuaDebugLibrary() )
    
    ButtonSetText( "DebugWindowOptionsClearLogText", L"Clear Log" )
    
    WindowSetShowing("DebugWindowOptions", false )
    
    
    HandlePregameInit()
    
end

-- OnShutdown Handler
function DebugWindow.Shutdown()

end


-- OnUpdate Handler
function DebugWindow.Update( timePassed )

    if (DebugWindow.lastMouseX ~= SystemData.MousePosition.x or DebugWindow.lastMouseY ~= SystemData.MousePosition.x) then
        local mousePoint = L""..SystemData.MousePosition.x..L", "..SystemData.MousePosition.y;
        LabelSetText ("DebugWindowMousePointText", mousePoint);
        
        DebugWindow.lastMouseX = SystemData.MousePosition.x;
        DebugWindow.lastMouseY = SystemData.MousePosition.y;
    end


    
    -- Update the MouseoverWindow
    if( DebugWindow.lastMouseOverWindow ~= SystemData.MouseOverWindow.name ) then  
        LabelSetText( "DebugWindowMouseOverText", StringToWString(SystemData.MouseOverWindow.name) )       
        DebugWindow.lastMouseOverWindow = SystemData.MouseOverWindow.name
    end
end


function DebugWindow.Hide()
    WindowSetShowing("DebugWindow", false )
    WindowSetShowing("DebugWindowOptions", false )
end

function DebugWindow.ToggleLogging()

    DebugWindow.Settings.logsOn = not DebugWindow.Settings.logsOn 
    
    if( DebugWindow.Settings.logsOn ) then
        CHAT_DEBUG( L" UI Logging ON" )
    else
        CHAT_DEBUG( L" UI Logging OFF" )
    end
    
    DebugWindow.UpdateLog()
end
    
function DebugWindow.UpdateLog()      
    
    TextLogSetIncrementalSaving( "UiLog", DebugWindow.Settings.logsOn, L"logs/uilog.log");
    TextLogSetEnabled( "UiLog", DebugWindow.Settings.logsOn )   
    
    UpdateLoggingButton()

end

function DebugWindow.OnResizeBegin()
    WindowUtils.BeginResize( "DebugWindow", "topleft", 300, 200, nil)
end

--- Options Window

function DebugWindow.ToggleOptions()
    local showing = WindowGetShowing( "DebugWindowOptions" )
    WindowSetShowing("DebugWindowOptions", showing == false )
end

function DebugWindow.HideOptions()
    WindowSetShowing("DebugWindowOptions", false )
end

function DebugWindow.ClearTextLog()
    --DEBUG(L"Entered Clear text Log")
    
    -- Clear the UI log
    TextLogClear("UiLog")

    -- Options
    for filterType, filterData in pairs( DebugWindow.Settings.LogFilters )
    do
        LogDisplaySetFilterState( "DebugWindowText", "UiLog", filterType, filterData.enabled )
                    
        -- When UI Log filters are off, disable logging of that filter type entirely.
        TextLogSetFilterEnabled( "UiLog", filterType, filterData.enabled  )
    end


    for index = 1, 2
    do
        ButtonSetStayDownFlag( "DebugWindowOptionsErrorOption"..index.."Button", true )
    end
    
    ButtonSetPressedFlag( "DebugWindowOptionsErrorOption1Button", DebugWindow.Settings.useDevErrorHandling  )    
    ButtonSetPressedFlag( "DebugWindowOptionsErrorOption2Button", GetUseLuaErrorHandling() )    
    ButtonSetPressedFlag( "DebugWindowOptionsLuaDebugLibraryButton", GetLoadLuaDebugLibrary() )

end

function DebugWindow.AddUiLog()
    LogDisplayAddLog("DebugWindowText", "UiLog", true)
    
        -- Options
    for filterType, filterData in pairs( DebugWindow.Settings.LogFilters )
    do
        LogDisplaySetFilterColor( "DebugWindowText", "UiLog", filterType, filterData.color.r, filterData.color.g, filterData.color.b )
    end
    
    UpdateLoggingButton()
end

function DebugWindow.UpdateDisplayFilter()

    local filterId = WindowGetId(SystemData.ActiveWindow.name)
    
    local enabled = not DebugWindow.Settings.LogFilters[filterId].enabled
    DebugWindow.Settings.LogFilters[filterId].enabled = enabled
    
    ButtonSetPressedFlag( "DebugWindowOptionsFilterType"..filterId.."Button", enabled )
    LogDisplaySetFilterState( "DebugWindowText", "UiLog", filterId, enabled )
    
    -- When UI Log filters are off, disable logging of that filter type entirely.
    TextLogSetFilterEnabled( "UiLog", filterId, enabled )

end

function DebugWindow.UpdateLuaErrorHandling()

    DebugWindow.Settings.useDevErrorHandling = not DebugWindow.Settings.useDevErrorHandling ;
    ButtonSetPressedFlag( "DebugWindowOptionsErrorOption1Button", DebugWindow.Settings.useDevErrorHandling  )    
end

function DebugWindow.UpdateCodeErrorHandling()
    local enabled = GetUseLuaErrorHandling()
    enabled = not enabled
    
    SetUseLuaErrorHandling( enabled )
    ButtonSetPressedFlag( "DebugWindowOptionsErrorOption2Button", enabled )
end

function DebugWindow.UpdateLoadLuaDebugLibrary()
    local enabled = GetLoadLuaDebugLibrary()
    enabled = not enabled

    SetLoadLuaDebugLibrary( enabled )
    ButtonSetPressedFlag( "DebugWindowOptionsLuaDebugLibraryButton", enabled )
end
