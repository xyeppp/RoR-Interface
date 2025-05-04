EA_Window_ZoneControl = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
local barId = 0

 
function EA_Window_ZoneControl.Initialize()    
    barId = ThreePartBar.Create( "EA_Window_ZoneControlBar", "EA_Window_ZoneControlContainer", false, nil )

    -- Register this window for movement with the Layout Editor
    LayoutEditor.RegisterWindow( "EA_Window_ZoneControl",  
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_ZONE_CONTROL_NAME ),
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_ZONE_CONTROL_DESC ),
                                 false, false,
                                 true, nil )



    WindowRegisterEventHandler( "EA_Window_ZoneControl", SystemData.Events.INTERFACE_RELOADED,                      "EA_Window_ZoneControl.UpdateZoneControl" )   
    WindowRegisterEventHandler( "EA_Window_ZoneControl", SystemData.Events.PLAYER_ZONE_CHANGED,                     "EA_Window_ZoneControl.UpdateZoneControl" )
    WindowRegisterEventHandler( "EA_Window_ZoneControl", SystemData.Events.PLAYER_LEARNED_ABOUT_UI_ELEMENT,         "EA_Window_ZoneControl.UpdateTutorial" )
    WindowRegisterEventHandler( "EA_Window_ZoneControl", SystemData.Events.PLAYER_RENOWN_UPDATED,                   "EA_Window_ZoneControl.UpdateTutorial" )
    
    EA_Window_ZoneControl.UpdateTutorial()
    EA_Window_ZoneControl.UpdateZoneControl()
end

function EA_Window_ZoneControl.Shutdown()
    ThreePartBar.Destroy( barId )
end

----------------------------------------------------------------
-- Zone Control
----------------------------------------------------------------

function EA_Window_ZoneControl.UpdateZoneControl()
    local zoneData = GetCampaignZoneData( GameData.Player.zone )
    
    if ( zoneData )
    then
        ThreePartBar.Show( barId )
        ThreePartBar.SetZone( barId, GameData.Player.zone )
    else
        ThreePartBar.Hide( barId )
    end    
end

function EA_Window_ZoneControl.UpdateTutorial()
    EA_AdvancedWindowManager.UpdateWindowShowing( "EA_Window_ZoneControlContainer", EA_AdvancedWindowManager.WINDOW_TYPE_ZONE_CONTROL_BAR )
end