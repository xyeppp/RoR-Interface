----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_OverheadMap = {}
EA_Window_OverheadMap.activateZoom    = true
EA_Window_OverheadMap.oldMinimapBorder = false  -- The XML specifies the new border, so this defaults to false

----------------------------------------------------------------
-- Saved Variables
----------------------------------------------------------------
EA_Window_OverheadMap.Settings = {}

-- Default most map filters to 'on'
EA_Window_OverheadMap.Settings.mapPinFilters = {}
EA_Window_OverheadMap.Settings.mapPinGutters = {}

if( not SystemData.Territory.KOREA )
then
    -- Default these select filters off
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.KILL_COLLECTOR_QUEST_PENDING_NPC ]     = false
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.KILL_COLLECTOR_QUEST_COMPLETE_NPC ]    = false
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.STORE_NPC ]                            = false
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.SCENARIO_GATEKEEPER_NPC ]              = false
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.VAULT_KEEPER_NPC ]                     = false
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.BINDER_NPC ]                           = false
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.GUILD_REGISTRAR_NPC ]                  = false
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.HEALER_NPC ]                           = false
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.MAILBOX ]                              = false
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.MERCHANT_LASTNAME ]                    = false
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.MERCHANT_DYE ]                         = false
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.BANNER ]                               = false
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.INFLUENCE_REWARDS_NPC ]                = false
    EA_Window_OverheadMap.Settings.mapPinFilters[ SystemData.MapPips.INFLUENCE_REWARDS_PENDING_NPC ]        = false
end


EA_Window_OverheadMap.RALLY_CALL_TIMER = 2 * 60
EA_Window_OverheadMap.currentTimerTime = 0
----------------------------------------------------------------
-- Bad Ideas
----------------------------------------------------------------
EA_Window_OverheadMap.INSTANCETYPE_SCENARIO = 3
EA_Window_OverheadMap.INSTANCETYPE_CITY = 4

----------------------------------------------------------------
-- Map Pin Filter to Map Pin lookup table
----------------------------------------------------------------
EA_Window_OverheadMap.NUM_PIN_FILTER_COLUMNS = 2
EA_Window_OverheadMap.mapPinFilters =
{
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_WAYPOINT,           slice="Waypoint-Large",              scale=1.0,  pins={ SystemData.MapPips.QUEST_AREA, SystemData.MapPips.LIVE_EVENT_WAYPOINT }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_PUBLIC_QUEST,       slice="PQ-Large",                    scale=1.0,  pins={ SystemData.MapPips.PUBLIC_QUEST }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_QUESTS,             slice="QuestCompleted-Gold",         scale=1.0,  pins={ SystemData.MapPips.QUEST_OFFER_NPC, SystemData.MapPips.REPEATABLE_QUEST_OFFER_NPC, SystemData.MapPips.LIVE_EVENT_QUEST_OFFER_NPC, SystemData.MapPips.QUEST_PENDING_NPC, SystemData.MapPips.QUEST_COMPLETE_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_KILL_COLLECTOR,     slice="KillCollector",               scale=1.0,  pins={ SystemData.MapPips.KILL_COLLECTOR_QUEST_PENDING_NPC, SystemData.MapPips.KILL_COLLECTOR_QUEST_COMPLETE_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_MERCHANT,           slice="NPC-Merchant",                scale=1.0,  pins={ SystemData.MapPips.STORE_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_TRAINERS,           slice="NPC-TrainerActive",           scale=1.0,  pins={ SystemData.MapPips.TRAINER_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_BINDER,             slice="NPC-Binder",                  scale=1.1,  pins={ SystemData.MapPips.BINDER_NPC, SystemData.MapPips.INFLUENCE_REWARDS_NPC, SystemData.MapPips.INFLUENCE_REWARDS_PENDING_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_MAILBOX,            slice="Mail-Large",                  scale=1.0,  pins={ SystemData.MapPips.MAILBOX }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_TRAVEL,             slice="NPC-Travel",                  scale=1.0,  pins={ SystemData.MapPips.TRAVEL_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_HEALER,             slice="NPC-Healer-Large",            scale=1.0,  pins={ SystemData.MapPips.HEALER_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_VAULT,              slice="Vault",                       scale=1.0,  pins={ SystemData.MapPips.VAULT_KEEPER_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_AUCTION,            slice="Auctioneer",                  scale=1.0,  pins={ SystemData.MapPips.AUCTION_HOUSE_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_GUILD_REGISTRATION, slice="NPC-GuildRegistrar-Large",    scale=1.0,  pins={ SystemData.MapPips.GUILD_REGISTRAR_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_LASTNAME,           slice="LastNames-Large",             scale=1.0,  pins={ SystemData.MapPips.MERCHANT_LASTNAME }, },
}
EA_Window_OverheadMap.mapPinGutters =
{
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_OBJECTIVE,          slice="FlagNeutral",                 scale=1.0,  pins={ SystemData.MapPips.OBJECTIVE }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_KEEP,               slice="Keep-Grayed",                 scale=0.75, pins={ SystemData.MapPips.KEEP }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_GROUP_MEMBER,       slice="PlayerCircleGroupmate",       scale=1.75, pins={ SystemData.MapPips.GROUP_MEMBER }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_IMPORTANT_MONSTER,  slice="BombNeutral",                 scale=1.0,  pins={ SystemData.MapPips.IMPORTANT_MONSTER }, },
}
 
----------------------------------------------------------------
-- Standard Window Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_OverheadMap.Initialize()

    -- Register this window for movement with the Layout Editor
    LayoutEditor.RegisterWindow( "EA_Window_OverheadMap",  
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_MINI_MAP_NAME ),
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_MINI_MAP_DESC ),
                                 false, false,
                                 true, nil )
                                

    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.CITY_RATING_UPDATED,      "EA_Window_OverheadMap.UpdateCityRating")
    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.TOGGLE_WORLD_MAP_WINDOW,  "EA_Window_OverheadMap.ToggleWorldMapWindow")
    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.LOADING_END,              "EA_Window_OverheadMap.OnLoadingEnd" )
    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.USER_SETTINGS_CHANGED,    "EA_Window_OverheadMap.UpdateMinimapBorder" )
 
    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.SCENARIO_BEGIN,                 "EA_Window_OverheadMap.UpdateScenarioButtons")
    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.SCENARIO_END,                   "EA_Window_OverheadMap.UpdateScenarioButtons")
    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.PLAYER_RVR_FLAG_UPDATED,        "EA_Window_OverheadMap.UpdateScenarioButtons")
    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.INTERACT_UPDATED_SCENARIO_QUEUE_LIST, "EA_Window_OverheadMap.UpdateScenarioButtons")
    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.SCENARIO_ACTIVE_QUEUE_UPDATED,  "EA_Window_OverheadMap.UpdateScenarioQueueButton")

    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.PLAYER_AREA_NAME_CHANGED,    "EA_Window_OverheadMap.OnAreaNameChange" )
    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.PLAYER_ZONE_CHANGED,         "EA_Window_OverheadMap.OnZoneChange" )

    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.MAILBOX_UNREAD_COUNT_CHANGED, "EA_Window_OverheadMap.UpdateMailIcon")
    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.RALLY_CALL_INVITE, "EA_Window_OverheadMap.ActivateRallyCall")

    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.PLAYER_CAREER_RANK_UPDATED, "EA_Window_OverheadMap.UpdateTutorial")
        
    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.TOGGLE_CURRENT_EVENTS_WINDOW, "EA_Window_OverheadMap.ToggleCurrentEvents")    
    WindowRegisterEventHandler( "EA_Window_OverheadMap", SystemData.Events.CURRENT_EVENTS_LIST_UPDATED, "EA_Window_OverheadMap.OnEventsUpdated" )
    EA_Window_OverheadMap.OnEventsUpdated( CurrentEventsGetList() )
    
    ButtonSetStayDownFlag( "EA_Window_OverheadMapMapWorldMapButton", true )

    -- Initialize the map
    CreateMapInstance( "EA_Window_OverheadMapMapDisplay", SystemData.MapTypes.OVERHEAD )
    
    -- Players with pre-gutter saved settings won't have the mapPinGutters settings array at all, so we must create an empty one
    if ( EA_Window_OverheadMap.Settings.mapPinGutters == nil )
    then
        EA_Window_OverheadMap.Settings.mapPinGutters = {}
    end

    for index, filterType in pairs( SystemData.MapPips )
    do
        -- Default any new filter types to on
        if( EA_Window_OverheadMap.Settings.mapPinFilters[filterType] == nil )
        then
            EA_Window_OverheadMap.Settings.mapPinFilters[filterType] = true
        end
        if( EA_Window_OverheadMap.Settings.mapPinGutters[filterType] == nil )
        then
            EA_Window_OverheadMap.Settings.mapPinGutters[filterType] = true
        end
    
        local show = EA_Window_OverheadMap.Settings.mapPinFilters[filterType] 
        MapSetPinFilter("EA_Window_OverheadMapMapDisplay", filterType, show )
        
        local gutter = EA_Window_OverheadMap.Settings.mapPinGutters[filterType] 
        MapSetPinGutter("EA_Window_OverheadMapMapDisplay", filterType, gutter )
    end
    
    WindowSetShowing("EA_Window_OverheadMapPinFilterMenu", false )
        
    EA_Window_OverheadMap.UpdateMinimapBorder()
    EA_Window_OverheadMap.UpdateMap()
    EA_Window_OverheadMap.UpdateScenarioButtons()
    EA_Window_OverheadMap.OnZoneChange()
    EA_Window_OverheadMap.UpdateScenarioQueueButton()
    EA_Window_OverheadMap.RepositionZoomSlider()
    EA_Window_OverheadMap.UpdateZoomButtons()
    EA_Window_OverheadMap.RefreshMapPointFilterMenu()
    EA_Window_OverheadMap.UpdateMailIcon()
    EA_Window_OverheadMap.UpdateTutorial()
    
    WindowUtils.AddWindowStateButton( "EA_Window_OverheadMapMapWorldMapButton", "EA_Window_WorldMap" )
    WindowUtils.AddWindowStateButton( "EA_Window_OverheadMapScenarioSummaryButton", "ScenarioSummaryWindow" )
    WindowSetShowing( "EA_Window_OverheadMapRallyCallButtonGlowAnim", false )    
    
    WindowUtils.AddWindowStateButton( "EA_Window_OverheadCurrentEventsButton", "EA_Window_CurrentEvents" )
    
end

function EA_Window_OverheadMap.OnLoadingEnd()
	EA_Window_OverheadMap.UpdateMap()
	EA_Window_OverheadMap.UpdateScenarioButtons()
end

function EA_Window_OverheadMap.UpdateMap()
    MapSetMapView( "EA_Window_OverheadMapMapDisplay", GameDefs.MapLevel.ZONE_MAP, GameData.Player.zone  )
end

-- OnShutdown Handler
function EA_Window_OverheadMap.Shutdown()
    RemoveMapInstance( "EA_Window_OverheadMapMapDisplay" )
end


function EA_Window_OverheadMap.OnLButtonDown()
    -- Handle L Button Down so clicks don't go through to the world..
end


function EA_Window_OverheadMap.OnMouseOverPoint( )
    -- Make sure we're not handling input that is actually intended for a window on top of us
    if (SystemData.MouseOverWindow.name == "EA_Window_OverheadMapMapDisplay") then
        Tooltips.CreateMapPointTooltip( "EA_Window_OverheadMapMapDisplay", EA_Window_OverheadMapMapDisplay.MouseoverPoints, Tooltips.ANCHOR_CURSOR_LEFT, Tooltips.MAP_TYPE_MINIMAP )    
    end
end

function EA_Window_OverheadMap.OnClickMap( )
    MapUtils.ClickMap( "EA_Window_OverheadMapMapDisplay", EA_Window_OverheadMapMapDisplay.MouseoverPoints )    
end


function EA_Window_OverheadMap.ToggleWorldMapWindow()
    WindowUtils.ToggleShowing( "EA_Window_WorldMap" )    
end

function EA_Window_OverheadMap.OnMouseoverWorldMapBtn()
    WindowUtils.OnMouseOverButton( GetString( StringTables.Default.LABEL_WORLD_MAP ), KeyUtils.GetFirstBindingNameForAction( "TOGGLE_WORLD_MAP_WINDOW" ), nil, Tooltips.ANCHOR_WINDOW_TOP )
end

function EA_Window_OverheadMap.ToggleAdvancedWarWindow()
    WindowUtils.ToggleShowing( "EA_Window_AdvancedWar" )
end

function EA_Window_OverheadMap.OnMouseoverAdvancedWarBtn()
    WindowUtils.OnMouseOverButton( GetString( StringTables.Default.LABEL_ADVANCED_WAR_TITLE	 ), nil, nil, Tooltips.ANCHOR_WINDOW_TOP )
end

function EA_Window_OverheadMap.UpdateMinimapBorder()
    local areAnyGuttersEnabled = false
    for _, gutterData in ipairs(EA_Window_OverheadMap.mapPinGutters)
    do
        for _, pinType in ipairs(gutterData.pins)
        do
            if ( EA_Window_OverheadMap.Settings.mapPinGutters[ pinType ] )
            then
                areAnyGuttersEnabled = true
                break
            end
        end
    end
    
    local shouldUseOldMinimapBorder = SystemData.Settings.GamePlay.oldMinimapBorder or not areAnyGuttersEnabled
    if ( shouldUseOldMinimapBorder ~= EA_Window_OverheadMap.oldMinimapBorder )
    then
        EA_Window_OverheadMap.oldMinimapBorder = shouldUseOldMinimapBorder
        
        if ( shouldUseOldMinimapBorder )
        then
            DynamicImageSetTexture( "EA_Window_OverheadMapMapDisplayFrame", "EA_MinimapNoGutter", 0, 0 )
            DynamicImageSetTextureSlice( "EA_Window_OverheadMapMapDisplayFrame", "Minimap-Frame-NoGutter" )
        else
            DynamicImageSetTexture( "EA_Window_OverheadMapMapDisplayFrame", "EA_HUD_01", 0, 0 )
            DynamicImageSetTextureSlice( "EA_Window_OverheadMapMapDisplayFrame", "Minimap-Frame" )
        end
    end
end

----------------------------------------------------------------
-- Zoom Slider
----------------------------------------------------------------

function EA_Window_OverheadMap.UpdateZoomButtons()
    local zoomLevel = GetOverheadMapZoomLevel()
    ButtonSetDisabledFlag("EA_Window_OverheadMapZoomSliderInButton",  zoomLevel == SystemData.OverheadMap.MAX_ZOOM_LEVEL )
    ButtonSetDisabledFlag("EA_Window_OverheadMapZoomSliderOutButton", zoomLevel == SystemData.OverheadMap.MIN_ZOOM_LEVEL )
end

function EA_Window_OverheadMap.ZoomIn()
    local sliderFraction = SliderBarGetCurrentPosition( "EA_Window_OverheadMapZoomSliderBar" )
    
    local oneTickAmount = (1 / (SystemData.OverheadMap.MAX_ZOOM_LEVEL - SystemData.OverheadMap.MIN_ZOOM_LEVEL))
    if ((sliderFraction - oneTickAmount) >= 0)
    then
        sliderFraction = sliderFraction - oneTickAmount
    else
        sliderFraction = 0
    end

    EA_Window_OverheadMap.activateZoom = true
    SliderBarSetCurrentPosition("EA_Window_OverheadMapZoomSliderBar", sliderFraction)
    EA_Window_OverheadMap.SlideZoom()
end

function EA_Window_OverheadMap.OnMouseoverZoomInBtn()
    local text = GetString( StringTables.Default.LABEL_ZOOM_IN )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function EA_Window_OverheadMap.ZoomOut()   
    local sliderFraction = SliderBarGetCurrentPosition( "EA_Window_OverheadMapZoomSliderBar" )
    
    local oneTickAmount = (1 / (SystemData.OverheadMap.MAX_ZOOM_LEVEL - SystemData.OverheadMap.MIN_ZOOM_LEVEL))
    if ((sliderFraction + oneTickAmount) <= 1)
    then
        sliderFraction = sliderFraction + oneTickAmount
    else
        sliderFraction = 1
    end
    
    EA_Window_OverheadMap.activateZoom = true
    SliderBarSetCurrentPosition("EA_Window_OverheadMapZoomSliderBar", sliderFraction)
    EA_Window_OverheadMap.SlideZoom()
end

function EA_Window_OverheadMap.OnMouseoverZoomOutBtn()
    local text = GetString( StringTables.Default.LABEL_ZOOM_OUT )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

-- move the slider bar without changing maps (i.e., maps were changed in some other fashion)
function EA_Window_OverheadMap.RepositionZoomSlider()
    local zoomLevel       = GetOverheadMapZoomLevel()
    local oneTickAmount   = (1 / (SystemData.OverheadMap.MAX_ZOOM_LEVEL - SystemData.OverheadMap.MIN_ZOOM_LEVEL))
    local newZoomFraction = ((zoomLevel - SystemData.OverheadMap.MIN_ZOOM_LEVEL) * oneTickAmount)

    -- DEBUG(L"  zoomLevel="..zoomLevel..L",  zoomFraction="..newZoomFraction)
    EA_Window_OverheadMap.activateZoom = false
    SliderBarSetCurrentPosition("EA_Window_OverheadMapZoomSliderBar", 1.0 - newZoomFraction )
    EA_Window_OverheadMap.UpdateZoomButtons()
end

function EA_Window_OverheadMap.SlideZoom()
    if (not EA_Window_OverheadMap.activateZoom)
    then
        EA_Window_OverheadMap.activateZoom = true
        return
    end

    local sliderFraction = 1.0 - SliderBarGetCurrentPosition("EA_Window_OverheadMapZoomSliderBar")
    local newZoomLevel   = (sliderFraction * (SystemData.OverheadMap.MAX_ZOOM_LEVEL - SystemData.OverheadMap.MIN_ZOOM_LEVEL)) + SystemData.OverheadMap.MIN_ZOOM_LEVEL

    SetOverheadMapZoomLevel( newZoomLevel )
    EA_Window_OverheadMap.UpdateZoomButtons()
end

----------------------------------------------------------------
-- Scenario Summary
----------------------------------------------------------------

function EA_Window_OverheadMap.ToggleScenarioSummaryWindow()
    BroadcastEvent( SystemData.Events.TOGGLE_SCENARIO_SUMMARY_WINDOW )
end


function EA_Window_OverheadMap.ToggleScenarioGroupWindow()
    if( GameData.Player.isInScenario or GameData.Player.isInSiege ) then        
        if( WindowGetShowing("ScenarioGroupWindow") == true ) then
            WindowSetShowing( "ScenarioGroupWindow", false )
        else
            WindowSetShowing( "ScenarioGroupWindow", true )
        end
    end
end

function EA_Window_OverheadMap.OnMouseoverScenarioSummaryBtn()
    WindowUtils.OnMouseOverButton( GetString( StringTables.Default.LABEL_SCENARIO_SUMMARY ), KeyUtils.GetFirstBindingNameForAction( "TOGGLE_SCENARIO_SUMMARY_WINDOW" ) )
end

function EA_Window_OverheadMap.OnMouseoverScenarioGroupBtn()

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil ) 
    
    local row = 1
    local column = 1
    Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.LABEL_SCENARIO_GROUPS ) )
    
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end

function EA_Window_OverheadMap.UpdateScenarioButtons()
    local isInScenarioOrCity = GameData.Player.isInScenario or GameData.Player.isInSiege
    WindowSetShowing("EA_Window_OverheadMapScenarioSummaryButton", isInScenarioOrCity )
    WindowSetShowing("EA_Window_OverheadMapScenarioGroupButton", isInScenarioOrCity )
    WindowSetShowing("EA_Window_OverheadMapMapScenarioQueue", not isInScenarioOrCity )
    WindowSetShowing("EA_Window_OverheadMapRallyCallButton", not isInScenarioOrCity )
    
    -- Disable the scenario queue button if there are no available scenarios
    ButtonSetDisabledFlag("EA_Window_OverheadMapMapScenarioQueue", GameData.ScenarioQueueData[1].id == 0)    
end


function EA_Window_OverheadMap.OnZoneChange()
    EA_Window_OverheadMap.UpdateMap()
    EA_Window_OverheadMap.OnAreaNameChange()   
    EA_Window_OverheadMap.UpdateCityRating()
	EA_Window_OverheadMap.DeactivateRallyCall()
end

function EA_Window_OverheadMap.OnAreaNameChange()
-- When the player moves to a different area, we need to update the area Text
    local text
    if( GameData.Player.isInSiege )
    then
        --text = GameData.Player.area.name
        local cityName = GetZoneName(GameData.Player.zone)
        local instanceIdData = GetCityInstanceId()        
        text = GetStringFormat( StringTables.Default.TEXT_CITY_INSTANCE_LABEL, { cityName, instanceIdData.instanceId } )
        -- DEBUG( instanceId )    
    else
        text = GameData.Player.area.name
        if( text == L"")
        then
            text = GetStringFormatFromTable( "MapSystem", StringTables.MapSystem.LABEL_ZONE_NAME, {GetZoneName(GameData.Player.zone)} )
        end
        
        if( text == L"")
        then
            text = GetStringFormatFromTable( "MapSystem", StringTables.MapSystem.LABEL_ZONE_NAME, {L"Zone "..GameData.Player.zone} )
        end
    end
    -- DEBUG( GetZoneName(GameData.Player.zone) )
    -- DEBUG( GameData.Player.isInSiege )
    -- DEBUG( text )
    --DEBUG(L"Entered New Area: "..text)
    LabelSetText("EA_Window_OverheadMapAreaNameText", text )
end
----------------------------------------------------------------
-- Rally Call
----------------------------------------------------------------
function EA_Window_OverheadMap.RallyCallControl()
-- Controls the rally call timer, after 5 mins, deactivate the rally call
end

function EA_Window_OverheadMap.OnRallyCallLButtonUp()
-- If button is active > put up popup -> wanna join?
    if( WindowGetShowing( "EA_Window_OverheadMapRallyCallButtonGlowAnim" ) )
    then
        --DEBUG(L"Joining Rally CAll")
        BroadcastEvent( SystemData.Events.RALLY_CALL_JOIN )
    else
        -- do nothing
    end
end

function EA_Window_OverheadMap.OnMouseoverRallyCall()
-- make tooltip
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil ) 
    
    local row = 1
    local column = 1
    if( WindowGetShowing( "EA_Window_OverheadMapRallyCallButtonGlowAnim" ) )
    then
        Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.TOOLTIP_RALLY_CALL_ACTIVE ) )
    else
        Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.TOOLTIP_RALLY_CALL_INACTIVE ) )
    end   
    
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)   
    
end

function EA_Window_OverheadMap.ActivateRallyCall()
-- start it animating
    WindowSetShowing( "EA_Window_OverheadMapRallyCallButtonGlowAnim", true )
    AnimatedImageStartAnimation( "EA_Window_OverheadMapRallyCallButtonGlowAnim", 0, true, false, 0.0 )
    EA_Window_OverheadMap.currentTimerTime = EA_Window_OverheadMap.RALLY_CALL_TIMER
end

function EA_Window_OverheadMap.DeactivateRallyCall()
-- stop animating
    --DEBUG(L"DEACTIVATING RALLY CALL")
    WindowSetShowing( "EA_Window_OverheadMapRallyCallButtonGlowAnim", false )
    AnimatedImageStopAnimation( "EA_Window_OverheadMapRallyCallButtonGlowAnim")
end

function EA_Window_OverheadMap.UpdateRallyTimer( timePassed )
    if( EA_Window_OverheadMap.currentTimerTime > 0 )
    then
        EA_Window_OverheadMap.currentTimerTime = EA_Window_OverheadMap.currentTimerTime - timePassed
        if( EA_Window_OverheadMap.currentTimerTime <= 0 )
        then
            EA_Window_OverheadMap.currentTimerTime = 0
            EA_Window_OverheadMap.DeactivateRallyCall()
        end
    end
end
        
function EA_Window_OverheadMap.UpdateTutorial()
    EA_AdvancedWindowManager.UpdateWindowShowing( "EA_Window_OverheadMapRallyCall", EA_AdvancedWindowManager.WINDOW_TYPE_RALLY_CALL )
    EA_AdvancedWindowManager.UpdateWindowShowing( "EA_Window_OverheadCurrentEvents", EA_AdvancedWindowManager.WINDOW_TYPE_CURRENT_EVENTS )
end
        
----------------------------------------------------------------
-- Scenario Queue
----------------------------------------------------------------

function EA_Window_OverheadMap.GetQueueName(queueType, id)
    if (queueType == EA_Window_OverheadMap.INSTANCETYPE_SCENARIO) then
        -- Scenario queue
        return GetScenarioName(id)
    end
    
    if (id == 0) then
        -- General city queue
        return GetString( StringTables.Default.TEXT_CITY_INSTANCE_QUEUE_GENERAL )
    end
    
    -- Specific city queue
    return GetStringFormat( StringTables.Default.TEXT_CITY_INSTANCE_QUEUE_SPECIFIC, { id } )
end

function EA_Window_OverheadMap.OnScenarioQueueLButtonUp()
    EA_Window_OverheadMap.OnJoinAScenario()        
end

function EA_Window_OverheadMap.OnScenarioQueueRButtonUp()
    local queueData = GetScenarioQueueData()
    
    if( queueData ~= nil) then
        -- player is in a queue, show the context menu that allows him/her to leave the queue
        EA_Window_ContextMenu.CreateContextMenu( SystemData.ActiveWindow.name )
        
        local queueCount = queueData.totalQueuedScenarios
        for index = 1, queueCount do
            local queueName = EA_Window_OverheadMap.GetQueueName( queueData[index].type, queueData[index].id )
            local menuText = GetStringFormat( StringTables.Default.TEXT_LEAVE_SCENARIO, { queueName } )
            EA_Window_ContextMenu.AddMenuItem( menuText, EA_Window_OverheadMap.LeaveScenario, false, true )            
        end
        
        EA_Window_ContextMenu.Finalize()
    end    
    
end
    

function EA_Window_OverheadMap.OnJoinAScenario()
    BroadcastEvent( SystemData.Events.INTERACT_SHOW_SCENARIO_QUEUE_LIST )
end

function EA_Window_OverheadMap.OnMouseoverScenarioQueue()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil ) 

    local queueData = GetScenarioQueueData()
    local row = 1
    local column = 1
    if( queueData ~= nil) then
        Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.LABEL_SCENARIO_QUEUE_CURRENT_QUEUE ) )
        
        local queueCount = queueData.totalQueuedScenarios
        for index = 1, queueCount do
            local queueName = EA_Window_OverheadMap.GetQueueName( queueData[index].type, queueData[index].id )
            Tooltips.SetTooltipText( index+1, column, queueName )
            Tooltips.SetTooltipColor( index+1, column, 255, 255, 255 )
        end
        
        Tooltips.SetTooltipText( queueCount+2, column, GetString( StringTables.Default.TEXT_SCENARIO_QUEUE_MORE ) )
        Tooltips.SetTooltipText( queueCount+3, column, GetString( StringTables.Default.TEXT_SCENARIO_QUEUE_LESS ) )
        
        Tooltips.SetTooltipColor( row, column, 255, 204, 102 )
        Tooltips.SetTooltipColor( queueCount+2, column, 175, 175, 175 )
        Tooltips.SetTooltipColor( queueCount+3, column, 175, 175, 175 )
    else
        if (GameData.ScenarioQueueData[1].id == 0) then
            -- No scenarios are available; indicate that in tooltip
            Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.LABEL_SCENARIO_QUEUE_NONE_AVAILABLE ) )
        else
            Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.LABEL_SCENARIO_QUEUE ) )
        end
    end
    
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end

function EA_Window_OverheadMap.UpdateScenarioQueueButton()
    local queuedScenarioData = GetScenarioQueueData()
    -- DEBUG( queuedScenarioData )
    --if( GameData.ScenarioData.activeQueue ~= 0 and GameData.ScenarioData.activeQueue ~= nil and queuedScenarioData ~= nil) then
    if( queuedScenarioData ~= nil) then
        --DEBUG(L"In Queue")
        WindowSetShowing( "EA_Window_OverheadMapMapScenarioQueueGlowAnim", true )
        AnimatedImageStartAnimation( "EA_Window_OverheadMapMapScenarioQueueGlowAnim", 0, true, false, 0.0 )
    else
        --DEBUG(L"NOT in Queue")
        WindowSetShowing( "EA_Window_OverheadMapMapScenarioQueueGlowAnim", false )
        AnimatedImageStopAnimation( "EA_Window_OverheadMapMapScenarioQueueGlowAnim")
        
        --The scenario window may not exist yet...
        if( DoesWindowExist("EA_Window_InScenarioQueue") ) then
            WindowSetShowing( "EA_Window_InScenarioQueue", false )
        end
    end
end


----------------------------------------------------------------
-- Map Point Filter Menu
----------------------------------------------------------------
function EA_Window_OverheadMap.RefreshMapPointFilterMenu()

    local numFilters = #EA_Window_OverheadMap.mapPinFilters
    local numFilterRows = math.ceil(numFilters / EA_Window_OverheadMap.NUM_PIN_FILTER_COLUMNS)
    
    local filterDisplayOrder = {}
    for index = 1, numFilterRows
    do
        table.insert(filterDisplayOrder, index)
    end
    ListBoxSetDisplayOrder("EA_Window_OverheadMapPinFilterMenuFiltersList", filterDisplayOrder)
    
    local numGutters = #EA_Window_OverheadMap.mapPinGutters
    local numGutterRows = math.ceil(numFilters / EA_Window_OverheadMap.NUM_PIN_FILTER_COLUMNS)
    
    local gutterDisplayOrder = {}
    for index = 1, numGutterRows
    do
        table.insert(gutterDisplayOrder, index)
    end
    ListBoxSetDisplayOrder("EA_Window_OverheadMapPinFilterMenuGuttersList", gutterDisplayOrder)
    
    LabelSetText("EA_Window_OverheadMapPinFilterMenuFiltersHeading", GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_MAP_FILTERS))
    LabelSetText("EA_Window_OverheadMapPinFilterMenuGuttersHeading", GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_MAP_GUTTERS))
    
end

function EA_Window_OverheadMap.PopulateFilterCell(listBoxWindowName, rowIndex, colIndex, pinTypeIndex, filterList, settingsList)
    local filterData  = filterList[pinTypeIndex]
    local rowFrame    = listBoxWindowName.."Row"..rowIndex
    local buttonFrame = rowFrame.."Button"..colIndex
    local iconFrame   = rowFrame.."Icon"..colIndex
    local labelFrame  = rowFrame.."Label"..colIndex
        
    if (filterData ~= nil)
    then
        WindowSetShowing(buttonFrame, true)
        WindowSetShowing(iconFrame, true)
        WindowSetShowing(labelFrame, true)
            
        LabelSetText(labelFrame, GetStringFromTable("MapPointFilterNames", filterData.label))
        WindowSetId(buttonFrame, pinTypeIndex)
        ButtonSetCheckButtonFlag(buttonFrame, true)
            
        local enableButton = false
        for _, pinType in ipairs(filterData.pins)
        do
            if ( settingsList and settingsList[ pinType ] )
            then
                enableButton = true
                break
            end
        end
        
        ButtonSetPressedFlag(buttonFrame, enableButton)
        DynamicImageSetTextureScale(iconFrame, filterData.scale)
        DynamicImageSetTextureSlice(iconFrame, filterData.slice)
    else
        WindowSetShowing(buttonFrame, false)
        WindowSetShowing(iconFrame, false)
        WindowSetShowing(labelFrame, false)
    end
end

function EA_Window_OverheadMap.PopulateFilters()
    for rowIndex, baseIndex in ipairs(EA_Window_OverheadMapPinFilterMenuFiltersList.PopulatorIndices)
    do
        for colIndex = 1, EA_Window_OverheadMap.NUM_PIN_FILTER_COLUMNS
        do
            local pinTypeIndex = ((baseIndex - 1) * EA_Window_OverheadMap.NUM_PIN_FILTER_COLUMNS) + colIndex
            EA_Window_OverheadMap.PopulateFilterCell("EA_Window_OverheadMapPinFilterMenuFiltersList", rowIndex, colIndex, pinTypeIndex, EA_Window_OverheadMap.mapPinFilters, EA_Window_OverheadMap.Settings.mapPinFilters)
        end
    end
end

function EA_Window_OverheadMap.PopulateGutters()
    for rowIndex, baseIndex in ipairs(EA_Window_OverheadMapPinFilterMenuGuttersList.PopulatorIndices)
    do
        for colIndex = 1, EA_Window_OverheadMap.NUM_PIN_FILTER_COLUMNS
        do
            local pinTypeIndex = ((baseIndex - 1) * EA_Window_OverheadMap.NUM_PIN_FILTER_COLUMNS) + colIndex
            EA_Window_OverheadMap.PopulateFilterCell("EA_Window_OverheadMapPinFilterMenuGuttersList", rowIndex, colIndex, pinTypeIndex, EA_Window_OverheadMap.mapPinGutters, EA_Window_OverheadMap.Settings.mapPinGutters)
        end
    end
end

function EA_Window_OverheadMap.ToggleFilterMenu()    
    WindowUtils.ToggleShowing( "EA_Window_OverheadMapPinFilterMenu" )
end

function EA_Window_OverheadMap.OnMouseOverFilterMenuButton()      
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_MAP_FILTERS_BUTTON)  ) 
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end

function EA_Window_OverheadMap.ToggleMapPinFilter()
    local showPin      = ButtonGetPressedFlag(SystemData.ActiveWindow.name)
    local pinTypeIndex = WindowGetId(SystemData.ActiveWindow.name)
    local pinTypes     = EA_Window_OverheadMap.mapPinFilters[pinTypeIndex].pins
    
    for _, pinType in ipairs(pinTypes)
    do
        -- Update the Settings
        MapSetPinFilter("EA_Window_OverheadMapMapDisplay", pinType, showPin)    
        EA_Window_OverheadMap.Settings.mapPinFilters[ pinType ] = showPin    
    end
end

function EA_Window_OverheadMap.ToggleMapPinGutter()
    local gutterPin    = ButtonGetPressedFlag(SystemData.ActiveWindow.name)
    local pinTypeIndex = WindowGetId(SystemData.ActiveWindow.name)
    local pinTypes     = EA_Window_OverheadMap.mapPinGutters[pinTypeIndex].pins
    
    for _, pinType in ipairs(pinTypes)
    do
        -- Update the Settings
        MapSetPinGutter("EA_Window_OverheadMapMapDisplay", pinType, gutterPin)    
        EA_Window_OverheadMap.Settings.mapPinGutters[ pinType ] = gutterPin    
    end
    
    -- The map border automatically switches between new and old style depending on whether any gutters are enabled
    -- (Unless the appropriate setting in User Settings is checked to always force the old border.)
    EA_Window_OverheadMap.UpdateMinimapBorder()
end

----------------------------------------------------------------
-- More Scenario Functions
----------------------------------------------------------------

function EA_Window_OverheadMap.LeaveScenario(  )
    local queueData = GetScenarioQueueData()
    local clickedWindowName = SystemData.ActiveWindow.name
    local windowId = WindowGetId(clickedWindowName)  

    if( queueData[windowId].type == EA_Window_OverheadMap.INSTANCETYPE_SCENARIO )
    then
        -- Leave scenario queue
        GameData.ScenarioQueueData.selectedId = queueData[windowId].id
        BroadcastEvent( SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE )
    else
        -- Leave city instance queue
        BroadcastEvent( SystemData.Events.CITY_CAPTURE_LEAVE_QUEUE )
    end
end

---------------------------------------------------------------------
-- City Rating Functions
---------------------------------------------------------------------

local function GetCurrentCityId()
    -- First check if player is in a peaceful or contested city
    local cityId = GameDefs.ZoneCityIds[GameData.Player.zone]
    if( cityId == nil )
    then
        -- Player could also be in a guild hall
        cityId = GameDefs.GuildHallCityMap[GameData.Player.zone]
    end
    return cityId
end

function EA_Window_OverheadMap.UpdateCityRating()
    local cityId = GetCurrentCityId()
    if( cityId == nil )
    then
        WindowSetShowing( "EA_Window_OverheadMapCityRating", false )
        return
    end
    
    MapUtils.UpdateCityRatingWindow( cityId, "EA_Window_OverheadMapCityRating" ) 
    WindowSetShowing( "EA_Window_OverheadMapCityRating", true )
end

function EA_Window_OverheadMap.OnMouseOverCityRating()

    local cityId = GetCurrentCityId()
    if( cityId == nil )
    then
        return
    end
        
    local cityRating = GetCityRatingForCityId( cityId )
    if cityRating==nil then 
      cityRating = 5
    end  
    -- Get the Strings for the Title
    local titleText = GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_CITY_RANK )
    
    -- Determine Rating Text
    local ratingText = L""
    
    local descStringId = StringTables.RvRCity[ "CITY_"..cityId.."_RATING_"..cityRating.."_DESC" ]


    
    if( descStringId ~= nil )
    then
        ratingText = GetStringFromTable( "RvRCityStrings", descStringId )
    end                                           
   
    
    -- Build the List of Items
    local itemsText = {}
    local cityData = GetCampaignCityData( cityId )
    if (cityData ~= nil) then
        itemsText = MapUtils.GetCityActivityStrings( cityId, cityData.cityState, cityRating )
    end    
    
    Tooltips.CreateListTooltip( titleText, ratingText, itemsText, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_LEFT ) 
    
end

---------------------------------------------------------------------
-- Pending Mail notification icon
---------------------------------------------------------------------

function EA_Window_OverheadMap.UpdateMailIcon()
    local showIcon = (GameData.Mailbox.PLAYER.unreadCount + GameData.Mailbox.AUCTION.unreadCount) > 0
    
    if (showIcon ~= WindowGetShowing("EA_Window_OverheadMapMailNotificationIcon"))
    then
        WindowSetShowing("EA_Window_OverheadMapMailNotificationIcon", showIcon)
    end
end

function EA_Window_OverheadMap.OnMouseoverMailNotification()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil ) 

    Tooltips.SetTooltipText( 1, 1, GetStringFormatFromTable("MailStrings", StringTables.Mail.TEXT_YOU_HAVE_X_UNREAD_MESSAGES_IN_YOUR_MAILBOX, { L""..GameData.Mailbox.PLAYER.unreadCount }) )
    Tooltips.SetTooltipText( 2, 1, GetStringFormatFromTable("MailStrings", StringTables.Mail.TEXT_YOU_HAVE_X_UNREAD_MESSAGES_IN_AUCTION_BOX, { L""..GameData.Mailbox.AUCTION.unreadCount }) )

    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end

-- Current Events

function EA_Window_OverheadMap.OnMouseOverCurrentEvents()
    local text = GetStringFromTable("CurrentEventsStrings", StringTables.CurrentEvents.MAP_BUTTON_TOOLTIP )

	WindowUtils.OnMouseOverButton( text, KeyUtils.GetFirstBindingNameForAction( "TOGGLE_CURRENT_EVENTS_WINDOW" ), nil, Tooltips.ANCHOR_WINDOW_LEFT )
end

function EA_Window_OverheadMap.ToggleCurrentEvents()
    if(GameData.Player.inCombat == true) 
    then
        WindowSetShowing("EA_Window_CurrentEvents", false)
    else
        WindowUtils.ToggleShowing( "EA_Window_CurrentEvents" )
    end
end

function EA_Window_OverheadMap.OnEventsUpdated( eventsData )
   -- Hide the Button when no events exist
   WindowSetShowing( "EA_Window_OverheadCurrentEventsButton", #eventsData > 0 )
end
