----------------------------------------------------------------
-- TomeWindow - Live Event Implementation
--
--  This file contains all of the initialization and callack
--  functions for the Live Event section of the Tome of Knowledge.
-- 
----------------------------------------------------------------


-- Constants
local PARENT_WINDOW = "LiveEventPageWindowContentsChild"
local PARENT_WINDOW_DETAIL = "LiveEventTaskDetailsPageWindowContentsChild"
local PARENT_WINDOW_LIST = "LiveEventListPageWindowContentsChild"

local TASK_IMAGE_SIZE = 128
local TASK_IMAGE_TEXT_SPACE = 5
local TASK_TEXT_WIDTH = 327
local TASK_TEXT_MIN_HEIGHT = 23
local ONLYTEXT_TEXT_WIDTH = 450

-- Saved Settings
TomeWindow.LiveEventSettings =
{
    showEndedEvents = true,
    showIneligibleEvents = false
}

-- Variables
local LiveEventTasks = {}
local LiveEventTasksFlat = {}
TomeWindow.CurrentLiveEventId = nil
TomeWindow.CurrentLiveEventTaskId = nil
TomeWindow.CurrentLiveEventName = L""
local taskWindowMappings = {}
local taskLabelCount = {}
local taskButtonCount = {}
local taskTextLabelCount = {}
local taskTextButtonCount = {}
local taskImageCount = {}
local taskContainerCount = {}
local lastRemovedEvent = { eventId=0, timestamp=0 }

----------------------------------------------------------------
-- Local Functions

local function NewLiveEventAlert( paramText, eventId, parentTaskId )
    local eventData = GetLiveEventData( eventId )
    local eventName = eventData.title
    local alert = { section = GameData.Tome.SECTION_LIVE_EVENT, entry = eventId, subEntry = 0, name = eventName, text = paramText, xp = 0, useName = true }
    if ( parentTaskId ~= nil )
    then
        alert.subEntry = parentTaskId
    end
    TomeAlertWindow.QueueAlert( alert )
end

local function IsAnyLiveEventActive()
    local liveEventList = GetLiveEventList()
    return ( next(liveEventList) ~= nil )
end

local function BuildTasksFlatMap( rootTaskTable, parentTask )
                
    -- first, sort tasks in the order we are going to display them.
    -- sort by ascending task ID, except put "task 0" at the end, because it is the Overall Progress task
    function sort_task_list( task1, task2 )
        if ( task1.taskId == 0 )
        then
            return false    -- Put task2 before task 1
        elseif ( task2.taskId == 0 )
        then
            return true     -- Put task 1 before task 2
        else
            return ( task1.taskId < task2.taskId )
        end
    end
    
    table.sort( rootTaskTable, sort_task_list )
    
    -- merge into LiveEventTasks table for later access
    for _, task in ipairs( rootTaskTable )
    do
        if type( task ) ~= "table" or (not task.taskId) 
        then
            continue
        end
        
        if parentTask
        then
            task.parentTask = parentTask
        end
        if LiveEventTasksFlat[task.taskId] == nil then --DupeCheck
            LiveEventTasksFlat[task.taskId] = task
            BuildTasksFlatMap ( task.subtasks, task )
        end
    end
end

local function FindTaskParentId( eventId, taskId )
    local tasksList = GetLiveEventTasks( eventId )
    local function RecursiveHelper( currentTasksList, parentTaskId )
        for _, task in ipairs( currentTasksList )
        do
            if ( type( task ) ~= "table" )
            then
                continue
            end
            
            if ( task.taskId == taskId )
            then
                return true, parentTaskId
            end
            
            local didFind, foundParentTaskId = RecursiveHelper( task.subtasks, task.taskId )
            if ( didFind )
            then
                return true, foundParentTaskId
            end
        end
        
        return false
    end
    return RecursiveHelper( tasksList, nil )
end

local function OnUpdateNavButtons( pageWindow )
    local curPage   = PageWindowGetCurrentPage( pageWindow )
    local numPages  = PageWindowGetNumPages( pageWindow )
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )
    WindowStartAlphaAnimation("TomeWindowPreviousPageButton", Window.AnimationType.SINGLE_NO_RESET,0, 1, 0.5, false, 0, 0)
    WindowStartAlphaAnimation("TomeWindowNextPageButton", Window.AnimationType.SINGLE_NO_RESET,0, 1, 0.5, false, 0, 0)
end

local function OnPreviousPage( pageWindow )
    TomeWindow.FlipPageWindowBackward( pageWindow )
end

local function OnNextPage( pageWindow )
    TomeWindow.FlipPageWindowForward( pageWindow )
end

local function OnMouseOverPreviousPage( pageWindow )
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage( pageWindow )
    local numPages  = PageWindowGetNumPages( pageWindow )
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_LIVE_EVENT )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

local function OnMouseOverNextPage( pageWindow )
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage( pageWindow )
    local numPages  = PageWindowGetNumPages( pageWindow )
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_LIVE_EVENT )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end

local function ShouldDisplayInEventList( ended, eligible )
    return ( TomeWindow.LiveEventSettings.showEndedEvents or not ended ) and ( TomeWindow.LiveEventSettings.showIneligibleEvents or eligible )
end

local function GetEventListAboveAndBelow( eventId )
    local aboveEventId = nil
    local belowEventId = nil
    local liveEventList = GetLiveEventList()
    for _, event in ipairs(liveEventList)
    do
        if ( ShouldDisplayInEventList( event.ended, event.eligible ) )
        then
            if ( eventId < event.id )
            then
                belowEventId = event.id
                break
            elseif ( eventId ~= event.id )
            then        
                aboveEventId = event.id
            end
        end
    end
    
    return aboveEventId, belowEventId
end

local function GetEventListAnchorWindow( aboveEventId )
    if ( aboveEventId == nil )
    then
        return PARENT_WINDOW_LIST.."PageBreakDummy"
    end
    
    return PARENT_WINDOW_LIST.."Event"..aboveEventId
end

local function SetupEventListWindow( eventId, eventTitle, aboveEventId )
    local windowName = PARENT_WINDOW_LIST.."Event"..eventId
    
    CreateWindowFromTemplate( windowName, "LiveEventListButton", PARENT_WINDOW_LIST )
    ButtonSetText( windowName, wstring.upper( eventTitle ) )
    
    WindowClearAnchors( windowName )
    WindowAddAnchor( windowName, "bottomleft", GetEventListAnchorWindow( aboveEventId ), "topleft", 0, 15 )
    
    WindowSetId( windowName, eventId )
end

local function AddEventToEventList( eventId )
    local windowName = PARENT_WINDOW_LIST.."Event"..eventId
    local aboveEventId, belowEventId = GetEventListAboveAndBelow( eventId )
    local eventData = GetLiveEventData( eventId )
    
    SetupEventListWindow( eventId, eventData.title, aboveEventId )
    
    if ( belowEventId ~= nil )
    then
        local belowWindowName = PARENT_WINDOW_LIST.."Event"..belowEventId
        WindowClearAnchors( belowWindowName )
        WindowAddAnchor( belowWindowName, "bottomleft", windowName, "topleft", 0, 15 )
    end
    
    PageWindowUpdatePages( "LiveEventListPageWindow" )
end

local function RemoveEventFromEventList( eventId )
    local windowName = PARENT_WINDOW_LIST.."Event"..eventId
    if ( DoesWindowExist( windowName ) )
    then
        local aboveEventId, belowEventId = GetEventListAboveAndBelow( eventId )
        
        if ( belowEventId ~= nil )
        then
            local belowWindowName = PARENT_WINDOW_LIST.."Event"..belowEventId
            WindowClearAnchors( belowWindowName )
            WindowAddAnchor( belowWindowName, "bottomleft", GetEventListAnchorWindow( aboveEventId ), "topleft", 0, 15 )
        end
        
        DestroyWindow( windowName )
        
        PageWindowUpdatePages( "LiveEventListPageWindow" )
    end
end

----------------------------------------------------------------
-- Live Event Functions
----------------------------------------------------------------

function TomeWindow.InitializeLiveEvent()

    TomeWindow.Pages[ TomeWindow.PAGE_LIVE_EVENT ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_LIVE_EVENT,
                    "LiveEvent",
                    TomeWindow.OnShowLiveEvent,
                    TomeWindow.OnLiveEventUpdateNavButtons,
                    TomeWindow.OnLiveEventPreviousPage,
                    TomeWindow.OnLiveEventNextPage,
                    TomeWindow.OnLiveEventMouseOverPreviousPage,
                    TomeWindow.OnLiveEventMouseOverNextPage )
                    
    TomeWindow.Pages[ TomeWindow.PAGE_LIVE_EVENT_TASK_DETAILS ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_LIVE_EVENT,
                    "LiveEventTaskDetails",
                    TomeWindow.OnShowLiveEventTaskDetails,
                    TomeWindow.OnLiveEventTaskDetailsUpdateNavButtons,
                    TomeWindow.OnLiveEventTaskDetailsPreviousPage,
                    TomeWindow.OnLiveEventTaskDetailsNextPage,
                    TomeWindow.OnLiveEventTaskDetailsMouseOverPreviousPage,
                    TomeWindow.OnLiveEventTaskDetailsMouseOverNextPage )
                    
    TomeWindow.Pages[ TomeWindow.PAGE_LIVE_EVENT_LIST ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_LIVE_EVENT,
                    "LiveEventList",
                    nil,    -- Page is always kept up to date, so it doesn't need to be updated when shown
                    TomeWindow.OnLiveEventListUpdateNavButtons,
                    TomeWindow.OnLiveEventListPreviousPage,
                    TomeWindow.OnLiveEventListNextPage,
                    TomeWindow.OnLiveEventListMouseOverPreviousPage,
                    TomeWindow.OnLiveEventListMouseOverNextPage )
                    
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_LIVE_EVENT_LOADED, "TomeWindow.OnLiveEventLoaded" )
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_LIVE_EVENT_REMOVED, "TomeWindow.OnLiveEventRemoved" )
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_LIVE_EVENT_ENDED, "TomeWindow.OnLiveEventEnded" )
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_LIVE_EVENT_TASKS_UPDATED, "TomeWindow.OnUpdateLiveEventTasks" )
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_LIVE_EVENT_TASK_COUNTER_UPDATED, "TomeWindow.OnUpdateLiveEventTaskCounter" )
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_LIVE_EVENT_OVERALL_COUNTER_UPDATED, "TomeWindow.OnOverallProgressUpdated" )
    
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_LIVE_EVENT_LIST,
                                  GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_LIVE_EVENT ),
                                  L"" )
    
    LabelSetText( PARENT_WINDOW_LIST.."Title", wstring.upper( GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_LIVE_EVENT ) ) )
    LabelSetText( "LiveEventListShowEndedName", GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_SHOW_ENDED ) )
    LabelSetText( "LiveEventListShowIneligibleName", GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_SHOW_INELIGIBLE ) )
    
    ButtonSetPressedFlag( "LiveEventListShowEndedCheckBox", TomeWindow.LiveEventSettings.showEndedEvents )
    ButtonSetPressedFlag( "LiveEventListShowIneligibleCheckBox", TomeWindow.LiveEventSettings.showIneligibleEvents )
    
    LabelSetText( PARENT_WINDOW.."IneligibleText", GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_LIVE_EVENT_INELIGIBLE ) )

    LabelSetText( PARENT_WINDOW.."ProgressLevel1Label", GetString( StringTables.Default.LABEL_BASIC_REWARDS ) )
    LabelSetText( PARENT_WINDOW.."ProgressLevel2Label", GetString( StringTables.Default.LABEL_ADVANCED_REWARDS ) )
    LabelSetText( PARENT_WINDOW.."ProgressLevel3Label", GetString( StringTables.Default.LABEL_ELITE_REWARDS ) )
    
    for level = 1, TomeWindow.NUM_REWARD_LEVELS
    do
        ButtonSetDisabledFlag( PARENT_WINDOW.."ProgressBarCheck"..level, true )
        for reward = 1, TomeWindow.MAX_REWARDS_PER_LEVEL
        do
            ButtonSetDisabledFlag( PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward, true )
        end
    end
    
    local liveEventList = GetLiveEventList()
    local previousEventId = nil
    for _, event in ipairs(liveEventList)
    do
        if ( ShouldDisplayInEventList( event.ended, event.eligible ) )
        then
            SetupEventListWindow( event.id, event.title, previousEventId )
            previousEventId = event.id
        end
    end
    
    PageWindowUpdatePages( "LiveEventListPageWindow" )

    PageWindowAddPageBreak( "LiveEventPageWindow", PARENT_WINDOW.."LoreText" )
    
    WindowSetShowing( "TomeWindowLiveEventBookmark", IsAnyLiveEventActive() )
end

function TomeWindow.OnShowLiveEvent( eventId )
    if ( TomeWindow.CurrentLiveEventId ~= eventId )
    then
        TomeWindow.CurrentLiveEventTaskId = nil
        TomeWindow.CurrentLiveEventId = eventId
        TomeWindow.UpdateLiveEvent()
    end
end

function TomeWindow.OnLiveEventLoaded( eventId, ended, eligible )
    local anyEventActive = IsAnyLiveEventActive()
    if ( anyEventActive )
    then
        WindowSetShowing( "TomeWindowLiveEventBookmark", true )
    end
    
    if ( ShouldDisplayInEventList( ended, eligible ) )
    then
        AddEventToEventList( eventId )
    end
    
    if ( eligible and not ended )
    then
        -- Sometimes the server "refreshes" an event, immediately deactivating and reactivating it. Check for this and suppress the alert in that case
        if ( ( eventId ~= lastRemovedEvent.eventId ) or ( GetGameTime() ~= lastRemovedEvent.timestamp ) )
        then
            local alertText = GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_LIVE_EVENT_LOADED )
            NewLiveEventAlert( alertText, eventId )
        end
    end
end

function TomeWindow.OnLiveEventRemoved( eventId )
    local anyEventActive = IsAnyLiveEventActive()
    
    RemoveEventFromEventList( eventId )
    
    if ( TomeWindow.GetCurrentState() == TomeWindow.PAGE_LIVE_EVENT_LIST )
    then
        if ( not anyEventActive )
        then
            TomeWindow.SetState( TomeWindow.PAGE_TITLE_PAGE, {} )
        end
    elseif ( ( TomeWindow.GetCurrentState() == TomeWindow.PAGE_LIVE_EVENT ) or ( TomeWindow.GetCurrentState() == TomeWindow.PAGE_LIVE_EVENT_TASK_DETAILS ) )
    then
        if ( TomeWindow.CurrentLiveEventId == eventId )
        then
            TomeWindow.CurrentLiveEventId = nil
            TomeWindow.CurrentLiveEventTaskId = nil
            
            if ( anyEventActive )
            then
                TomeWindow.SetState( TomeWindow.PAGE_LIVE_EVENT_LIST, {} )
            else
                TomeWindow.SetState( TomeWindow.PAGE_TITLE_PAGE, {} )
            end
        end
    end
    
    if ( not anyEventActive )
    then
        WindowSetShowing( "TomeWindowLiveEventBookmark", false )
    end
    
    lastRemovedEvent = { eventId=eventId, timestamp=GetGameTime() }
end

function TomeWindow.OnLiveEventEnded( eventId )
    if ( not TomeWindow.LiveEventSettings.showEndedEvents )
    then
        RemoveEventFromEventList( eventId )
    end
end

function TomeWindow.UpdateLiveEvent()

    -- Set the Page Windows back to the first page. If the page window is on a different page when we recreate the layout, things may break.
    PageWindowSetCurrentPage( "LiveEventPageWindow", 1 )

    local eventData = GetLiveEventData( TomeWindow.CurrentLiveEventId )
    
    TomeWindow.CurrentLiveEventName = eventData.title

    LabelSetText( PARENT_WINDOW.."Title", wstring.upper( eventData.title ) )
    LabelSetText( PARENT_WINDOW.."SubTitle", eventData.subTitle )
    LabelSetText( PARENT_WINDOW.."SummaryText", eventData.description )
    LabelSetText( PARENT_WINDOW.."LoreText", eventData.loreText )
    
    DynamicImageSetTexture( PARENT_WINDOW.."Image", eventData.textureName, 0, 0)
        
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_LIVE_EVENT,
                                  GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_LIVE_EVENT ),
                                  eventData.title )

    TomeWindow.OnUpdateLiveEventTasks( TomeWindow.CurrentLiveEventId, true )
    
    -- This must be called after OnUpdateLiveEventTasks because that function updates the LiveEventTasks array, which contains the rewards data
    TomeWindow.SetupLiveEventRewards()

end

local function CreateOrUpdateTaskWindows_DefaultLayout(parentWindowName, anchorWindowName, tasksTable, parentTask)

    local taskLabelName = parentWindowName.."TaskLabel"
    local taskButtonName = parentWindowName.."TaskButton"
    local taskTextLabelName = parentWindowName.."TextLabel"
    local taskTextButtonName = parentWindowName.."TextButton"
    local taskImageName = parentWindowName.."Image"
    local taskContainerName = parentWindowName.."Container"
    -- as windows are created on demand, they can update the below table to determine how the next window will anchor
    local anchorTable = { relativeTo = anchorWindowName, anchorPoint = "bottomleft", relativePoint = "topleft", xOffset = 0, yOffset = 15 }
    local prevImageTextureName = nil
    local prevImageWindowName = nil
    local prevContainerWindowName = nil
    
    -- Destroy any existing windows and reset counts to 0
    local function DestroyExistingWindowsAndResetCount( baseArray, windowNameDef )
        local windowCount = baseArray[parentWindowName]
        if ( ( windowCount ~= nil ) and ( windowCount > 0 ) )
        then
            for index = 1, windowCount
            do
                DestroyWindow(windowNameDef..index)
            end
        end
        baseArray[parentWindowName] = 0
    end
    
    DestroyExistingWindowsAndResetCount(taskLabelCount, taskLabelName)
    DestroyExistingWindowsAndResetCount(taskButtonCount, taskButtonName)
    DestroyExistingWindowsAndResetCount(taskTextLabelCount, taskTextLabelName)
    DestroyExistingWindowsAndResetCount(taskTextButtonCount, taskTextButtonName)
    DestroyExistingWindowsAndResetCount(taskImageCount, taskImageName)
    DestroyExistingWindowsAndResetCount(taskContainerCount, taskContainerName)
    
    taskWindowMappings[parentWindowName] = {}   -- this needs to be done every time, not just the first time
    
    -- returns the new window created count
    local function CreateTaskWindow( winName, templateName )
        CreateWindowFromTemplate( winName, templateName, prevContainerWindowName or parentWindowName )
        WindowSetShowing(winName, true)
        
        -- add the anchor using the upvalue local anchor
        WindowClearAnchors( winName )
        WindowAddAnchor( winName, anchorTable.anchorPoint, anchorTable.relativeTo, anchorTable.relativePoint, anchorTable.xOffset, anchorTable.yOffset )
    
        -- Set the new anchor window
        anchorTable.relativeTo = winName
        anchorTable.anchorPoint = "bottomleft"
        anchorTable.relativePoint = "topleft"
        anchorTable.yOffset = 15
        anchorTable.xOffset = 0
    end
    
    local function CreateTaskImage( winName, templateName, task )
        CreateWindowFromTemplate( winName, templateName, prevContainerWindowName or parentWindowName )
        WindowSetShowing(winName, true)
        
        -- add the anchor using the upvalue local anchor
        WindowClearAnchors( winName )
        if ( task.textureRightAlign )
        then
            -- first image
            WindowAddAnchor( winName, "topright", anchorTable.relativeTo, "topright", 0, 0 )
            -- Set the new anchor
            anchorTable.relativeTo = winName
            anchorTable.anchorPoint = "topleft"
            anchorTable.relativePoint = "topright"
            anchorTable.yOffset = 0
            anchorTable.xOffset = -TASK_IMAGE_TEXT_SPACE
        else
            -- first image
            WindowAddAnchor( winName, "topleft", anchorTable.relativeTo, "topleft", 0, 0 )
            -- Set the new anchor
            anchorTable.relativeTo = winName
            anchorTable.anchorPoint = "topright"
            anchorTable.relativePoint = "topleft"
            anchorTable.yOffset = 0
            anchorTable.xOffset = TASK_IMAGE_TEXT_SPACE
        end
        
        SetLiveEventTaskImage( TomeWindow.CurrentLiveEventId, task.taskId )
        DynamicImageSetTexture( winName, task.textureName, 0, 0)
    end
    local EventDupeCheck = {} --DupeCheck
    for _, task in ipairs( tasksTable )
    do
     if EventDupeCheck[task.taskId] == nil then
        EventDupeCheck[task.taskId] = true
        if (prevImageTextureName ~= task.textureName) and (prevContainerWindowName ~= nil)
        then
            WindowResizeOnChildren( prevContainerWindowName, true, 0 )
            -- start a newline anchored to the bottom of the previous/finished container window
            anchorTable.relativeTo = prevContainerWindowName
            anchorTable.anchorPoint = "bottomleft"
            anchorTable.relativePoint = "topleft"
            anchorTable.yOffset = 15
            anchorTable.xOffset = 0
            
            prevContainerWindowName = nil
        end
        if task.textureName and prevImageTextureName ~= task.textureName
        then
            taskContainerCount[parentWindowName] = taskContainerCount[parentWindowName] + 1
            local containerName = taskContainerName..taskContainerCount[parentWindowName]
            CreateTaskWindow( containerName, "ImageTaskGroupContainer" )
            prevContainerWindowName = containerName
            
            taskImageCount[parentWindowName] = taskImageCount[parentWindowName] + 1
            local imageName = taskImageName..taskImageCount[parentWindowName]
            CreateTaskImage( imageName, "LiveEventTaskImage", task )
            
            prevImageWindowName = imageName
        end
        prevImageTextureName = task.textureName
            
        local isButton = (next(task.subtasks) ~= nil)
        local textWidth = 0
        local curWinName = ""
        if( not task.isOnlyText )
        then
            if (isButton)
            then
                taskButtonCount[parentWindowName] = taskButtonCount[parentWindowName] + 1
                curWinName = taskButtonName..taskButtonCount[parentWindowName]
                CreateTaskWindow( curWinName, "LiveEventTaskClickableEntryDef" )
                taskWindowMappings[parentWindowName][task.taskId] = taskButtonCount[parentWindowName]
            else
                taskLabelCount[parentWindowName] = taskLabelCount[parentWindowName] + 1
                curWinName = taskLabelName..taskLabelCount[parentWindowName]
                CreateTaskWindow( curWinName, "LiveEventTaskEntryDef" )
                taskWindowMappings[parentWindowName][task.taskId] = taskLabelCount[parentWindowName]
            end
            
            ButtonSetStayDownFlag( curWinName.."CompletedBtn", true )
            ButtonSetDisabledFlag( curWinName.."CompletedBtn", true )
            
            textWidth = TASK_TEXT_WIDTH
        else
            if (isButton)
            then
                taskTextButtonCount[parentWindowName] = taskTextButtonCount[parentWindowName] +1
                curWinName = taskTextButtonName..taskTextButtonCount[parentWindowName]
                CreateTaskWindow( curWinName, "LiveEventTaskClickableTextEntryDef" )
            else
                taskTextLabelCount[parentWindowName] = taskTextLabelCount[parentWindowName] +1
                curWinName = taskTextLabelName..taskTextLabelCount[parentWindowName]
                CreateTaskWindow( curWinName, "LiveEventTaskTextEntryDef" )
            end
            
            textWidth = ONLYTEXT_TEXT_WIDTH
        end
        
        local taskText = task.name
        if( not task.isOnlyText )
        then
            local counterText = GetFormatStringFromTable( "LiveEventStrings",
                                                          StringTables.LiveEventStrings.LABEL_LIVE_EVENT_COUNTER_FORMAT,
                                                          { towstring(task.currentValue), towstring(task.maxValue) } )
            LabelSetText( curWinName.."Counter", counterText )
            ButtonSetPressedFlag( curWinName.."CompletedBtn", task.currentValue == task.maxValue )
        end

        if ( task.textureName )
        then
            textWidth = textWidth - TASK_IMAGE_SIZE - TASK_IMAGE_TEXT_SPACE
        end
        
        WindowSetDimensions( curWinName.."Text", textWidth, TASK_TEXT_MIN_HEIGHT )
        
        if (isButton)
        then
            ButtonSetText( curWinName.."Text", taskText )
        else
            LabelSetText( curWinName.."Text", taskText )
        end
        
        if ( task.textureName )
        then
            local _, textHeight = WindowGetDimensions( curWinName.."Text" )
            WindowSetDimensions( curWinName, ONLYTEXT_TEXT_WIDTH - TASK_IMAGE_SIZE - TASK_IMAGE_TEXT_SPACE, textHeight )
        else
            WindowResizeOnChildren( curWinName, false, 0 )
        end
        
        WindowSetId( curWinName, task.taskId )
       end         
    end
    if prevContainerWindowName
    then
        WindowResizeOnChildren( prevContainerWindowName, true, 0 )
    end
end

function TomeWindow.OnUpdateLiveEventTasks( eventId, suppressTomeAlert )
    if ( TomeWindow.CurrentLiveEventId == eventId )
    then
        LiveEventTasks = GetLiveEventTasks( eventId )
    
        -- build flat map of tasks
        LiveEventTasksFlat = {}
        BuildTasksFlatMap( LiveEventTasks )
    
        CreateOrUpdateTaskWindows_DefaultLayout(PARENT_WINDOW, PARENT_WINDOW.."LoreText", LiveEventTasks)

        PageWindowUpdatePages( "LiveEventPageWindow" )
        TomeWindow.OnLiveEventUpdateNavButtons()
    
        if ( TomeWindow.CurrentLiveEventTaskId ~= nil )
        then
            TomeWindow.OnShowLiveEventTaskDetails( TomeWindow.CurrentLiveEventId, TomeWindow.CurrentLiveEventTaskId )
        end
    end
    
    if ( ( suppressTomeAlert == nil ) or ( suppressTomeAlert == false ) )
    then
        local alertText = GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_LIVE_EVENT_ALERT )
        NewLiveEventAlert( alertText, eventId )
    end
end

function TomeWindow.SetupLiveEventRewards()
    if ( not LiveEventTasks.eligible )
    then
        WindowSetShowing( PARENT_WINDOW.."Progress", false )
        WindowSetShowing( PARENT_WINDOW.."IneligibleText", true )
    elseif ( LiveEventTasks.rewards[1] ~= nil )
    then
        for level = 1, TomeWindow.NUM_REWARD_LEVELS
        do
            if (LiveEventTasks.rewards[level] ~= nil)
            then
                ButtonSetStayDownFlag( PARENT_WINDOW.."ProgressBarCheck"..level, true )
                ButtonSetDisabledFlag( PARENT_WINDOW.."ProgressBarCheck"..level, true )

                for reward = 1, TomeWindow.MAX_REWARDS_PER_LEVEL
                do
                    if( LiveEventTasks.rewards[level].items[reward] ~= nil )
                    then
                        local texture, x, y = GetIconData( LiveEventTasks.rewards[level].items[reward].iconNum )
                        DynamicImageSetTexture( PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward.."IconBase", texture, x, y )
                        WindowSetShowing( PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward, true )
						if( LiveEventTasks.rewards[level].items[reward].stackCount > 1 )
						then
							WindowSetShowing( PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward.."Text", true )
							LabelSetText(PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward.."Text", L""..LiveEventTasks.rewards[level].items[reward].stackCount )
						else
						    WindowSetShowing( PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward.."Text", false )
						end
                    else
                        WindowSetShowing( PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward, false )
                    end
                end
                
                local xOffset = 0
                if (#LiveEventTasks.rewards[level].items > 2)
                then
                    xOffset = -32
                end
                WindowClearAnchors( PARENT_WINDOW.."ProgressLevel"..level.."Reward1" )
                WindowAddAnchor( PARENT_WINDOW.."ProgressLevel"..level.."Reward1", "bottom", PARENT_WINDOW.."ProgressLevel"..level.."Label", "top", xOffset, 0 )
            else
                for reward = 1, TomeWindow.MAX_REWARDS_PER_LEVEL
                do
                    WindowSetShowing( PARENT_WINDOW.."ProgressLevel"..level.."Reward"..reward, false )
                end
            end
        end
        StatusBarSetMaximumValue( PARENT_WINDOW.."ProgressBarStatus", 1.0 )
        WindowSetShowing( PARENT_WINDOW.."Progress", true )
        WindowSetShowing( PARENT_WINDOW.."IneligibleText", false )
    else
        WindowSetShowing( PARENT_WINDOW.."Progress", false )
        WindowSetShowing( PARENT_WINDOW.."IneligibleText", false )
    end
    
    TomeWindow.UpdateLiveEventRewards()
end

function TomeWindow.UpdateLiveEventRewards()
    if ( LiveEventTasks.eligible and ( LiveEventTasks.rewards[1] ~= nil ) )
    then
        local lastLevelThreshold = 0
        local statusBarPercent = 0
        
        for level = 1, TomeWindow.NUM_REWARD_LEVELS
        do
            if (LiveEventTasks.rewards[level] ~= nil)
            then
                local levelPercent = 0
                if( LiveEventTasks.rewards[level].threshold - lastLevelThreshold > 0 )
                then
                    levelPercent = ( LiveEventTasks.overallCurrentValue - lastLevelThreshold ) / ( LiveEventTasks.rewards[level].threshold - lastLevelThreshold )
                end
                if( levelPercent > 1.0 )
                then
                    statusBarPercent = statusBarPercent + ( 1.0 / TomeWindow.NUM_REWARD_LEVELS )
                elseif( levelPercent > 0 )
                then
                    statusBarPercent = statusBarPercent + ( 1.0 / TomeWindow.NUM_REWARD_LEVELS ) * levelPercent
                end
                lastLevelThreshold = LiveEventTasks.rewards[level].threshold

                local checked = LiveEventTasks.overallCurrentValue >= LiveEventTasks.rewards[level].threshold
                ButtonSetPressedFlag( PARENT_WINDOW.."ProgressBarCheck"..level, checked )
            end
        end
        StatusBarSetCurrentValue( PARENT_WINDOW.."ProgressBarStatus", statusBarPercent )
    end
end

function TomeWindow.OnUpdateLiveEventTaskCounter(eventId, taskId, value, completed)
    if ( TomeWindow.CurrentLiveEventId == eventId )
    then    
        if ( LiveEventTasksFlat[taskId] ~= nil )
        then
            local task = LiveEventTasksFlat[taskId]
            task.currentValue = value
            
            if ( not task.isOnlyText )
            then
                local mainWindowMapping = nil
                local detailWindowMapping = nil
                
                if ( taskWindowMappings[PARENT_WINDOW] ~= nil )
                then
                    mainWindowMapping = taskWindowMappings[PARENT_WINDOW][taskId]
                end
                if ( taskWindowMappings[PARENT_WINDOW_DETAIL] ~= nil )
                then
                    detailWindowMapping = taskWindowMappings[PARENT_WINDOW_DETAIL][taskId]
                end
                
                if ( ( mainWindowMapping ~= nil ) or ( detailWindowMapping ~= nil ) )
                then
                    local counterText = GetFormatStringFromTable( "LiveEventStrings",
                                                                  StringTables.LiveEventStrings.LABEL_LIVE_EVENT_COUNTER_FORMAT,
                                                                  { towstring(task.currentValue), towstring(task.maxValue) } )
                                                                  
                    local taskWindowName
                    local isButton = (next(task.subtasks) ~= nil)
                    if (isButton)
                    then
                        taskWindowName = "TaskButton"
                    else
                        taskWindowName = "TaskLabel"
                    end
                    
                    if ( mainWindowMapping ~= nil )
                    then
                        local curWinName = PARENT_WINDOW..taskWindowName..mainWindowMapping
                        LabelSetText( curWinName.."Counter", counterText )
                        ButtonSetPressedFlag( curWinName.."CompletedBtn", completed )
                    end
                    
                    if ( detailWindowMapping ~= nil )
                    then
                        local curWinName = PARENT_WINDOW_DETAIL..taskWindowName..detailWindowMapping
                        LabelSetText( curWinName.."Counter", counterText )
                        ButtonSetPressedFlag( curWinName.."CompletedBtn", completed )
                    end
                end
            end
        end
    end
    
    if ( completed )
    then
        local didFind, foundParentTaskId = FindTaskParentId( eventId, taskId )
        if ( didFind )
        then
            local alertText = GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_LIVE_EVENT_TASK_COMPLETE )
            if ( foundParentTaskId == nil )
            then
                -- This is a top-level task. Queue an alert for the main event page.
                NewLiveEventAlert( alertText, eventId )
            else
                -- We are no longer showing task completed alerts for subtasks.
                -- Uncomment the line below to turn them back on.
                --NewLiveEventAlert( alertText, eventId, foundParentTaskId )
            end
        end
    end
end

function TomeWindow.OnOverallProgressUpdated(eventId, value)
    if ( TomeWindow.CurrentLiveEventId == eventId )
    then    
        LiveEventTasks.overallCurrentValue = value
        TomeWindow.UpdateLiveEventRewards()
    end
end

local function OnMouseOverLiveEventReward(level)
    local levelData = LiveEventTasks.rewards[level]
    if( levelData ~= nil )
    then
        local reward = WindowGetId( SystemData.ActiveWindow.name )
        local itemData = levelData.items[reward]
        if( itemData ~= nil and itemData.id ~= nil )
        then
            Tooltips.CreateItemTooltip( itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_RIGHT )
        end
    end
end

function TomeWindow.OnMouseOverLiveEventReward1()
    OnMouseOverLiveEventReward( 1 )
end

function TomeWindow.OnMouseOverLiveEventReward2()
    OnMouseOverLiveEventReward( 2 )
end

function TomeWindow.OnMouseOverLiveEventReward3()
    OnMouseOverLiveEventReward( 3 )
end

---------------------------------------------------------
-- > Nav Buttons

function TomeWindow.OnLiveEventUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_LIVE_EVENT ) then
        return
    end
    
    OnUpdateNavButtons( "LiveEventPageWindow" )
end

function TomeWindow.OnLiveEventPreviousPage()
    OnPreviousPage( "LiveEventPageWindow" )
end

function TomeWindow.OnLiveEventNextPage()
    OnNextPage( "LiveEventPageWindow" )
end

function TomeWindow.OnLiveEventMouseOverPreviousPage()
    OnMouseOverPreviousPage( "LiveEventPageWindow" )
end

function TomeWindow.OnLiveEventMouseOverNextPage()
    OnMouseOverNextPage( "LiveEventPageWindow" )
end

function TomeWindow.OnMouseOverLiveEventTask()
    local taskId = WindowGetId( SystemData.MouseOverWindow.name )
    if taskId > 0 and LiveEventTasksFlat[taskId] ~= nil
    then
        local task = LiveEventTasksFlat[taskId]
        if task.tooltipText ~= L""
        then
            Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name, task.tooltipText )
            Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP)
        end
    end
end

function TomeWindow.OnClickLiveEventTask()
    local taskId = WindowGetId( SystemData.MouseOverWindow.name )
    if taskId > 0 and LiveEventTasksFlat[taskId]
    then
        TomeWindow.ShowLiveEventTaskDetails( TomeWindow.CurrentLiveEventId, taskId )
    end
end

---
-- Live Event Task Details page
---

function TomeWindow.ShowLiveEventTaskDetails( eventId, taskId )
    local params = { eventId, taskId }
    TomeWindow.SetState( TomeWindow.PAGE_LIVE_EVENT_TASK_DETAILS, params )
end

function TomeWindow.OnShowLiveEventTaskDetails( eventId, taskId )
    -- Make sure eventId is the current event
    if ( TomeWindow.CurrentLiveEventId ~= eventId )
    then
        TomeWindow.CurrentLiveEventTaskId = nil
        TomeWindow.CurrentLiveEventId = eventId
        TomeWindow.UpdateLiveEvent()
    end
    
    if ( LiveEventTasksFlat[taskId] ~= nil )
    then
        TomeWindow.CurrentLiveEventTaskId = taskId
        local task = LiveEventTasksFlat[taskId]
        if ( next(task.subtasks) ~= nil )
        then
            TomeWindow.SetPageHeaderText( TomeWindow.PAGE_LIVE_EVENT_TASK_DETAILS,
                                          GetStringFromTable( "LiveEventStrings", StringTables.LiveEventStrings.LABEL_LIVE_EVENT ),
                                          task.name )
            
            LabelSetText( PARENT_WINDOW_DETAIL.."Title", task.name )
            LabelSetText( PARENT_WINDOW_DETAIL.."SummaryText", task.tooltipText )
            
            CreateOrUpdateTaskWindows_DefaultLayout(PARENT_WINDOW_DETAIL, PARENT_WINDOW_DETAIL.."PageBreakDummy", task.subtasks, task )
            
            PageWindowUpdatePages( "LiveEventTaskDetailsPageWindow" )
        end
    end
end

function TomeWindow.OnLiveEventTaskDetailsUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_LIVE_EVENT_TASK_DETAILS ) then
        return
    end
    
    OnUpdateNavButtons( "LiveEventTaskDetailsPageWindow" )
end

function TomeWindow.OnLiveEventTaskDetailsPreviousPage()
    OnPreviousPage( "LiveEventTaskDetailsPageWindow" )
end

function TomeWindow.OnLiveEventTaskDetailsNextPage()
    OnNextPage( "LiveEventTaskDetailsPageWindow" )
end

function TomeWindow.OnLiveEventTaskDetailsMouseOverPreviousPage()
    OnMouseOverPreviousPage( "LiveEventTaskDetailsPageWindow" )
end

function TomeWindow.OnLiveEventTaskDetailsMouseOverNextPage()
    OnMouseOverNextPage( "LiveEventTaskDetailsPageWindow" )
end

---
-- Live Event List page - lists all live events available
---

function TomeWindow.OnClickLiveEventListButton()
    local eventId = WindowGetId( SystemData.ActiveWindow.name )
    if ( eventId > 0 )
    then
        TomeWindow.SetState( TomeWindow.PAGE_LIVE_EVENT, { eventId } )
        
        local eventData = GetLiveEventData( eventId )
        if ( eventData.soundId ~= 0 )
        then
            Sound.Play( eventData.soundId )
        end
    end
end

function TomeWindow.OnClickLiveEventShowEnded()
    TomeWindow.LiveEventSettings.showEndedEvents = not TomeWindow.LiveEventSettings.showEndedEvents
    ButtonSetPressedFlag( "LiveEventListShowEndedCheckBox", TomeWindow.LiveEventSettings.showEndedEvents )
    
    local liveEventList = GetLiveEventList()
    for _, event in ipairs(liveEventList)
    do
        if ( event.ended )
        then
            if ( TomeWindow.LiveEventSettings.showEndedEvents )
            then
                if ( ShouldDisplayInEventList( event.ended, event.eligible ) )
                then
                    AddEventToEventList( event.id )
                end
            else
                RemoveEventFromEventList( event.id )
            end
        end
    end
end

function TomeWindow.OnClickLiveEventShowIneligible()
    TomeWindow.LiveEventSettings.showIneligibleEvents = not TomeWindow.LiveEventSettings.showIneligibleEvents
    ButtonSetPressedFlag( "LiveEventListShowIneligibleCheckBox", TomeWindow.LiveEventSettings.showIneligibleEvents )
    
    local liveEventList = GetLiveEventList()
    for _, event in ipairs(liveEventList)
    do
        if ( not event.eligible )
        then
            if ( TomeWindow.LiveEventSettings.showIneligibleEvents )
            then
                if ( ShouldDisplayInEventList( event.ended, event.eligible ) )
                then
                    AddEventToEventList( event.id )
                end
            else
                RemoveEventFromEventList( event.id )
            end
        end
    end
end

function TomeWindow.OnLiveEventListUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_LIVE_EVENT_LIST ) then
        return
    end
    
    OnUpdateNavButtons( "LiveEventListPageWindow" )
end

function TomeWindow.OnLiveEventListPreviousPage()
    OnPreviousPage( "LiveEventListPageWindow" )
end

function TomeWindow.OnLiveEventListNextPage()
    OnNextPage( "LiveEventListPageWindow" )
end

function TomeWindow.OnLiveEventListMouseOverPreviousPage()
    OnMouseOverPreviousPage( "LiveEventListPageWindow" )
end

function TomeWindow.OnLiveEventListMouseOverNextPage()
    OnMouseOverNextPage( "LiveEventListPageWindow" )
end

-- External function to open the tome to a certain page
function TomeWindow.OpenToEventTask( eventId, taskId )
    local didFind, foundParentTaskId = FindTaskParentId( eventId, taskId )
    if ( didFind )
    then
        if ( foundParentTaskId == nil )
        then
            -- This is a top-level task. Show the main event page.
            TomeWindow.OpenTomeToEntry( GameData.Tome.SECTION_LIVE_EVENT, eventId )
        else
            -- This is a sub-task. Show the parent task's page.
            TomeWindow.OpenTomeToEntry( GameData.Tome.SECTION_LIVE_EVENT, eventId, foundParentTaskId )
        end
    end
end
