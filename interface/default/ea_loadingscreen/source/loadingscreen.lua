----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_LoadingScreen = 
{
    MODE_NONE           = 0,
    MODE_STANDARD_ZONE  = 1,  
    MODE_SCENARIO_ENTER = 2,
    MODE_SCENARIO_EXIT  = 3,
    MODE_NO_DATA        = 4,
    MODE_PATCH_NOTES    = 5,

    -- Callbacks for each type of loading screen
    modes =
    {       
        -- MODE_STANDARD_ZONE
        {   
            windowName          ="EA_Window_LoadingScreenStandard",
            beginCallbackName   ="BeginStandardLoadScreen",
            endCallbackName     ="EndStandardLoadScreen", 
            streamingCallbackName     ="UpdateStreamingStandardLoadScreen",        
        },
        
        -- MODE_SCENARIO_ENTER
        {   
            windowName          ="EA_Window_LoadingScreenScenarioEnter",
            beginCallbackName   ="BeginScenarioEnterLoadScreen",
            endCallbackName     ="EndScenarioEnterLoadScreen",
			-- Added here so it is always possible to close the ScenarioSummaryWindow (See comments in LoadBegin for why this is needed).           
            stopCallbackName    ="StopScenarioExitLoadScreen",             
            streamingCallbackName     ="UpdateStreamingScenarioEnterLoadScreen",
        },
        
        -- MODE_SCENARIO_EXIT
        {   
            windowName          ="EA_Window_LoadingScreenScenarioExit",
            beginCallbackName   ="BeginScenarioExitLoadScreen",
            endCallbackName     ="EndScenarioExitLoadScreen",
            stopCallbackName    ="StopScenarioExitLoadScreen",
        },
        
        -- MODE_NO_DATA
        {   
            windowName          ="EA_Window_LoadingScreenNoData", 
            beginCallbackName   ="BeginNoDataLoadScreen",
            endCallbackName     ="EndNoDataLoadScreen",          
        },
        
        -- MODE_PATCH_NOTES
        {
            windowName          ="EA_Window_LoadingScreenPatchNotes",
            beginCallbackName   ="BeginPatchNotesLoadScreen",
            endCallbackName     ="EndPatchNotesLoadScreen",
            streamingCallbackName     ="UpdateStreamingPatchNotesLoadScreen",
        },
    },
    
    activeMode = MODE_NONE,
    
    
    hideTimer = 0,
    
    -- Animation Values
    FADE_OUT_TIME = 1.0,
    FLIP_TIME = 6/12,
    FADE_IN_TIME = 0.5,
    FLIP_FPS = 12,
    FLIP_TIME = 0.5,
    
    isTrial = false,
}


-- Scenario Frame Data

----------------------------------------------------------------
-- EA_Window_LoadingScreen Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_LoadingScreen.Initialize()
    
    WindowRegisterEventHandler( "EA_Window_LoadingScreen", SystemData.Events.LOADING_BEGIN, "EA_Window_LoadingScreen.OnLoadBegin" )
    WindowRegisterEventHandler( "EA_Window_LoadingScreen", SystemData.Events.LOADING_END, "EA_Window_LoadingScreen.OnLoadEnd" )
    WindowRegisterEventHandler( "EA_Window_LoadingScreen", SystemData.Events.STREAMING_STATUS_UPDATED, "EA_Window_LoadingScreen.OnStreamingStatusUpdated" )

    EA_Window_LoadingScreen.isTrial, _ = GetAccountData()
    
    if( SystemData.LoadingData.isLoading ) then
        -- DEBUG(L"Loading = true")
        EA_Window_LoadingScreen.OnLoadBegin()
    else
        -- DEBUG(L"Loading = false")
    end
end

function EA_Window_LoadingScreen.Shutdown()
end

function EA_Window_LoadingScreen.OnLButtonDown()
    -- This Callback is here to prevent mouse clicks from going through the window background
end

function EA_Window_LoadingScreen.OnLoadBegin()
    --DEBUG( L"EA_Window_LoadingScreen.OnLoadBegin()")

    -- Determine the type of loading screen to use    
    
    local loadingData = LoadingScreenGetCurrentData()
    local patchNotesData = nil
    
    if( SystemData.LoadingData.initialLoad )
    then
        patchNotesData = LoadingScreenGetPatchNotesData()
    end
     
    if( patchNotesData )
    then
        EA_Window_LoadingScreen.activeMode = EA_Window_LoadingScreen.MODE_PATCH_NOTES

    -- If the player was in a scenario, and is leaving the zone use the scenario Exit Screen
    elseif( GameData.ScenarioData.id ~= 0 )
    then
        -- If the player is loading into the same zone, they have died so just use the
        -- enter screen.
        -- This will also happen if a jump was registered when the scenario ended resulting in a
        -- stuck scenario summary window unless Stop() also callbacks for ENTER.
        if( GameData.Player.zone ~= loadingData.zoneId )
        then
            EA_Window_LoadingScreen.activeMode = EA_Window_LoadingScreen.MODE_SCENARIO_EXIT    
        else
            EA_Window_LoadingScreen.activeMode = EA_Window_LoadingScreen.MODE_SCENARIO_ENTER   
        end
        
    -- If the player is entering a scenario, use the scenario Enter Screen
    elseif( loadingData.scenarioId ~= 0 and (loadingData.screenDefId ~= 0) )   
    then     
        EA_Window_LoadingScreen.activeMode = EA_Window_LoadingScreen.MODE_SCENARIO_ENTER   
    
    -- Otherwise use the standard zone screen if we have data
    elseif( (loadingData.zoneId ~= 0) and (loadingData.screenDefId ~= 0) )
    then
       EA_Window_LoadingScreen.activeMode = EA_Window_LoadingScreen.MODE_STANDARD_ZONE  
    
    -- Fall back to the basic screen
    else
        EA_Window_LoadingScreen.activeMode = EA_Window_LoadingScreen.MODE_NO_DATA    
    end
    
    -- Show the Appropriate Screen
    for mode, data in ipairs( EA_Window_LoadingScreen.modes )
    do
        WindowSetShowing( data.windowName, mode == EA_Window_LoadingScreen.activeMode)
    end
    
    WindowSetShowing( "EA_Window_LoadingScreen", true )   
    
    -- Trigger the Begin Callback
    local modeData = EA_Window_LoadingScreen.modes[ EA_Window_LoadingScreen.activeMode ]
    EA_Window_LoadingScreen[ modeData.beginCallbackName ]( loadingData, patchNotesData )

    -- Update current screen's streaming status
    EA_Window_LoadingScreen.OnStreamingStatusUpdated()
    
    -- Fade in the Background
    local backgroundWindowName = "EA_Window_LoadingScreenBackground" 
    WindowStartAlphaAnimation( backgroundWindowName, Window.AnimationType.SINGLE_NO_RESET, 0, 1, 
            EA_Window_LoadingScreen.FADE_IN_TIME, true, 0, 0 )                      
          
end

function EA_Window_LoadingScreen.OnLoadEnd()

    if( WindowGetShowing( "EA_Window_LoadingScreen" ) == false )
    then
        return
    end

    --DEBUG( L"EA_Window_LoadingScreen.OnLoadEnd()")
    
    -- Fade out the background
    local delay = EA_Window_LoadingScreen.FADE_IN_TIME
    
    local backgroundWindowName = "EA_Window_LoadingScreenBackground" 
    WindowStartAlphaAnimation( backgroundWindowName, Window.AnimationType.SINGLE_NO_RESET, 1, 0, 
             EA_Window_LoadingScreen.FADE_IN_TIME, true, delay, 0 )
            
            
    -- Trigger the End Callback     
    local modeData = EA_Window_LoadingScreen.modes[ EA_Window_LoadingScreen.activeMode ]
    EA_Window_LoadingScreen[ modeData.endCallbackName ]()
            
    
    EA_Window_LoadingScreen.SetHideTimer( EA_Window_LoadingScreen.FADE_IN_TIME*2 )

end

function EA_Window_LoadingScreen.OnStreamingStatusUpdated()
   
    local modeData = EA_Window_LoadingScreen.modes[ EA_Window_LoadingScreen.activeMode ]
    if( modeData == nil )
    then 
       return
    end       

    -- Update the Streaming if applicable
    if( modeData.streamingCallbackName ~= nil )
    then
        EA_Window_LoadingScreen[ modeData.streamingCallbackName ]( SystemData.StreamingData.isStreaming )    
    end
    
end

function EA_Window_LoadingScreen.OnUpdate( timePassed )
        
    -- Hide the Window after it has finished fading out.
    if( EA_Window_LoadingScreen.hideTimer > 0 )
    then
        EA_Window_LoadingScreen.hideTimer = EA_Window_LoadingScreen.hideTimer - timePassed
        if( EA_Window_LoadingScreen.hideTimer <= 0 )
        then
            EA_Window_LoadingScreen.SetHideTimer( 0 )
            EA_Window_LoadingScreen.Stop()
            
        end 
    end    

end

function EA_Window_LoadingScreen.SetHideTimer( value )
    EA_Window_LoadingScreen.hideTimer = value
end


function EA_Window_LoadingScreen.Stop()
    -- Trigger the Stop Callback     
    local modeData = EA_Window_LoadingScreen.modes[ EA_Window_LoadingScreen.activeMode ]
    if( EA_Window_LoadingScreen[ modeData.stopCallbackName ] )
    then
        EA_Window_LoadingScreen[ modeData.stopCallbackName ]()
    end

    EA_Window_LoadingScreen.activeMode = EA_Window_LoadingScreen.MODE_NONE  
    
    WindowSetShowing( "EA_Window_LoadingScreen", false )     
    
    BroadcastEvent( SystemData.Events.ENTER_WORLD )

end


function EA_Window_LoadingScreen.AddTrialNotes(contentsWindowName, textContainerName, numTrialNoteItemWindows)

    WindowSetShowing( contentsWindowName.."ZoneImage", false)
    WindowSetShowing( contentsWindowName.."BlankBookImage", true)

    -- Now for the right hand side of the load screen
    LabelSetText( textContainerName.."NotesHeading", GetString( StringTables.Default.LABEL_TRIAL_LOADSCREEN_HEADING ) )
    LabelSetText( textContainerName.."NotesHeading2", GetString( StringTables.Default.LABEL_TRIAL_LOADSCREEN_SUBHEADING ) )
   
    -- this is to make the potentially non-sequential trial string ids into a sequential array of ids starting at 1
    local stringIds = {}
    local numStringIds = 0
    for _, stringId in pairs(StringTables.TrialStrings)
    do
        numStringIds = numStringIds + 1
        stringIds[numStringIds] = stringId 
    end
  
    local itemWindowName = textContainerName.."NoteItem"
    local anchorWindow = textContainerName.."NotesHeading2"
	
	-- show 5 sequential strings from the string table starting from a random index
    local stringIndex = math.random(numStringIds)
	
    for index=1,5
    do
        local trialNoteWindow = itemWindowName..index
        if (index > numTrialNoteItemWindows )
        then
            numTrialNoteItemWindows = numTrialNoteItemWindows + 1
            CreateWindowFromTemplate( trialNoteWindow, "EA_Template_LoadScreen_PatchNoteItem", textContainerName )
        end
        
        LabelSetText( trialNoteWindow.."Text", GetStringFromTable( "TrialStrings", stringIds[stringIndex] ) )
        WindowSetShowing( trialNoteWindow, true )
        WindowResizeOnChildren( trialNoteWindow, false, 0 )
        WindowClearAnchors( trialNoteWindow )
		
		local YOffset = 15
		if index == 1
		then
			YOffset = 30
		end
		
        WindowAddAnchor( trialNoteWindow, "bottomleft", anchorWindow, "topleft", 0, YOffset )
        anchorWindow = trialNoteWindow
		
		stringIndex = stringIndex + 1
		-- wrap back to 1 if necessary
		if( stringIndex > numStringIds )
		then
			stringIndex = 1
		end
    end
    
    return numTrialNoteItemWindows
end
