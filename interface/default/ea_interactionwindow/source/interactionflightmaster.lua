----------------------------------------------------------------
-- Local Functions (placed here to avoid dependency issues)
----------------------------------------------------------------
local function ColorFlightButton(buttonName, zoneAvailable, highlight)
    
    if( zoneAvailable ) 
    then
        if( highlight )
        then
            WindowSetTintColor( buttonName, 255, 255, 255)
        else
            WindowSetTintColor( buttonName, 155, 155, 155)
        end
    else
        if( highlight )
        then
            WindowSetTintColor( buttonName, 255, 0, 0)
        else
            WindowSetTintColor( buttonName, 200, 0, 0)
        end
    end

end

----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_InteractionFlightMasterWindow = {}

EA_InteractionFlightMasterWindow.flightMasterData         = nil

EA_InteractionFlightMasterWindow.TOOLTIP_ANCHOR = { Point = "topright",    RelativeTo = "EA_InteractionFlightMasterWindow", RelativePoint = "topleft",    XOffset=5, YOffset=75 }
EA_InteractionFlightMasterWindow.flightPairing = 0
EA_InteractionFlightMasterWindow.NUM_FLIGHT_NAME_BUTTONS = 14
EA_InteractionFlightMasterWindow.NUM_PAIRINGS = 3

EA_InteractionFlightMasterWindow.TombKingsQuestWindowID = nil

EA_InteractionFlightMasterWindow.ZoneButtonLookup = {}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ] = {}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ] = {}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.ELVES_DARKELVES ] = {}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.ExpansionMapRegion.TOMB_KINGS ] = {}

-- DvG Zone lookup table
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][6] = {zoneName="Ekrund"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][11] = {zoneName="MountBloodhorn"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][7] = {zoneName="BarakVarr"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][1] = {zoneName="MarshesOfMadness"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][8] = {zoneName="BlackFirePass"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][2] = {zoneName="TheBadlands"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][62] = {zoneName="KarazAKarak"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][10] = {zoneName="Stonewatch"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][9] = {zoneName="KadrinValley"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][5] = {zoneName="ThunderMountain"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][26] = {zoneName="CinderFall"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][27] = {zoneName="DeathPeak"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][3] = {zoneName="BlackCrag"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][4] = {zoneName="ButchersPass"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.GREENSKIN_DWARVES ][61] = {zoneName="KarakEightPeaks"}

-- EvC Zone lookup table
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][100] = {zoneName="Norsca"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][106] = {zoneName="Nordland"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][101] = {zoneName="TrollCountry"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][107] = {zoneName="Ostland"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][102] = {zoneName="HighPass"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][108] = {zoneName="Talabecland"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][161] = {zoneName="InevitableCity"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][104] = {zoneName="TheMaw"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][103] = {zoneName="ChaosWastes"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][105] = {zoneName="Praag"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][120] = {zoneName="WestPraag"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][109] = {zoneName="Reikland"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][110] = {zoneName="Reikwald"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.EMPIRE_CHAOS ][162] = {zoneName="Altdorf"}

-- HEvDE Zone lookup table
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.ELVES_DARKELVES ][200] = {zoneName="BlightedIsle"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.ELVES_DARKELVES ][206] = {zoneName="Chrace"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.ELVES_DARKELVES ][201] = {zoneName="Shadowlands"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.ELVES_DARKELVES ][207] = {zoneName="Ellyrion"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.ELVES_DARKELVES ][202] = {zoneName="Avelorn"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.ELVES_DARKELVES ][208] = {zoneName="Saphery"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.ELVES_DARKELVES ][204] = {zoneName="FellLanding"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.ELVES_DARKELVES ][203] = {zoneName="Caledor"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.ELVES_DARKELVES ][205] = {zoneName="Dragonwake"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.ELVES_DARKELVES ][220] = {zoneName="IsleOfTheDead"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.ELVES_DARKELVES ][209] = {zoneName="Eataine"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.Pairing.ELVES_DARKELVES ][210] = {zoneName="ShiningWay"}

-- TK Zone lookup table
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.ExpansionMapRegion.TOMB_KINGS ][191] = {zoneName="NecZandri"}
EA_InteractionFlightMasterWindow.ZoneButtonLookup[ GameData.ExpansionMapRegion.TOMB_KINGS ][413] = {zoneName="GarQuaph"}

-- Zone Numbers Table
EA_InteractionFlightMasterWindow.ZoneNumbersLookup = {}
EA_InteractionFlightMasterWindow.ZoneNumbersLookup[ GameData.Pairing.GREENSKIN_DWARVES ] = {}
EA_InteractionFlightMasterWindow.ZoneNumbersLookup[ GameData.Pairing.GREENSKIN_DWARVES ][GameData.Realm.ORDER] =  { 6, 11, 7, 1, 8, 2, 62, 10, 9, 5, 3, 4, 61 }
EA_InteractionFlightMasterWindow.ZoneNumbersLookup[ GameData.Pairing.GREENSKIN_DWARVES ][GameData.Realm.DESTRUCTION] =  { 6, 11, 7, 1, 8, 2, 62, 10, 9, 5, 3, 4, 61 }
EA_InteractionFlightMasterWindow.ZoneNumbersLookup[ GameData.Pairing.EMPIRE_CHAOS ] = {}
EA_InteractionFlightMasterWindow.ZoneNumbersLookup[ GameData.Pairing.EMPIRE_CHAOS ][GameData.Realm.ORDER] =  { 100, 106, 101, 107, 102, 108, 161, 104, 103, 105, 109, 110, 162 }
EA_InteractionFlightMasterWindow.ZoneNumbersLookup[ GameData.Pairing.EMPIRE_CHAOS ][GameData.Realm.DESTRUCTION] =  { 100, 106, 101, 107, 102, 108, 161, 104, 103, 105, 109, 110, 162 }
EA_InteractionFlightMasterWindow.ZoneNumbersLookup[ GameData.Pairing.ELVES_DARKELVES ] = {}
EA_InteractionFlightMasterWindow.ZoneNumbersLookup[ GameData.Pairing.ELVES_DARKELVES ][GameData.Realm.ORDER] =  { 200, 206, 201, 207, 202, 208, 204, 203, 205, 209, 210 }
EA_InteractionFlightMasterWindow.ZoneNumbersLookup[ GameData.Pairing.ELVES_DARKELVES ][GameData.Realm.DESTRUCTION] =  { 200, 206, 201, 207, 202, 208, 204, 203, 205, 209, 210 }
EA_InteractionFlightMasterWindow.ZoneNumbersLookup[ GameData.ExpansionMapRegion.TOMB_KINGS ] = {}
EA_InteractionFlightMasterWindow.ZoneNumbersLookup[ GameData.ExpansionMapRegion.TOMB_KINGS ][GameData.Realm.ORDER] =  { 191, 413 }
EA_InteractionFlightMasterWindow.ZoneNumbersLookup[ GameData.ExpansionMapRegion.TOMB_KINGS ][GameData.Realm.DESTRUCTION] =  { 191, 413 }


local wingZoneLookUp =
{
    [26]=true,
    [27]=true,
    [120]=true,
    [220]=true
}

local smallFortZoneLookUp =
{
    [4]=true,
    [10]=true,
    [104]=true,
    [110]=true
}
----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- EA_InteractionFlightMasterWindow Functions
----------------------------------------------------------------

-- OnInitialize Handlera
function EA_InteractionFlightMasterWindow.Initialize()
    WindowRegisterEventHandler( "EA_InteractionFlightMasterWindow", SystemData.Events.INTERACT_SHOW_FLIGHTMASTER, "EA_InteractionFlightMasterWindow.Show")
    
    RRQProgressBar.AddListener( EA_InteractionFlightMasterWindow.OnRRQsUpdated )
    
    -- Set the name of the window
    LabelSetText("EA_InteractionFlightMasterWindowZoneHeader", GetString( StringTables.Default.LABEL_TRAVEL_WINDOW_FLIGHT_POINTS ) )
    LabelSetText("EA_InteractionFlightMasterWindowRealmWarHeader", GetString( StringTables.Default.LABEL_TRAVEL_WINDOW_REALM_WARS ) )
    LabelSetText("EA_InteractionFlightMasterWindowTravelHeader", GetString( StringTables.Default.LABEL_TRAVEL_WINDOW_TRAVEL ) )
    LabelSetText("EA_InteractionFlightMasterWindowTravelDescription", GetString( StringTables.Default.TEXT_TRAVEL_WINDOW_DESCRIPTION ) )
    
    -- init the labels
    for pairing=GameData.Pairing.GREENSKIN_DWARVES, EA_InteractionFlightMasterWindow.NUM_PAIRINGS
    do
        ButtonSetText( "EA_InteractionFlightMasterWindowPairing"..pairing, GetStringFromTable("MapSystem", StringTables.MapSystem["LABEL_PAIRING_"..pairing] ) )
    end
    for pairing=GameData.ExpansionMapRegion.FIRST, GameData.ExpansionMapRegion.LAST
    do
        ButtonSetText( "EA_InteractionFlightMasterWindowPairing"..pairing, GetStringFromTable("MapSystem", StringTables.MapSystem["LABEL_EXPANSION_MAP_REGION_"..pairing] ) )
    end
    
    -- Set all the IDs of the buttons to their zone numbers in the map button windows and their zone name
    local function SetupPairingZoneButtons( pairingIndex )
        local windowId
        local mapWindowName = "EA_InteractionFlightMasterWindow"..pairingIndex.."Map"

        for index, button in pairs( EA_InteractionFlightMasterWindow.ZoneButtonLookup[ pairingIndex ] )
        do
            -- initialize all buttons to assume the zone is available
            button.zoneAvailable = true
            
            windowId = WindowGetId( mapWindowName..button.zoneName )
            WindowSetId( mapWindowName..button.zoneName.."FlightButton", windowId )
            if( not wingZoneLookUp[windowId] and not smallFortZoneLookUp[windowId] )
            then
                LabelSetText( mapWindowName..button.zoneName.."Text", StringUtils.ToUpperZoneName( GetZoneName( windowId ) ) )
            end
        end
    end
    for pairingIndex=GameData.Pairing.GREENSKIN_DWARVES, EA_InteractionFlightMasterWindow.NUM_PAIRINGS
    do
        SetupPairingZoneButtons( pairingIndex )
    end
    for pairingIndex=GameData.ExpansionMapRegion.FIRST, GameData.ExpansionMapRegion.LAST
    do
        SetupPairingZoneButtons( pairingIndex )
    end
    
end



-- OnShutdown Handler
function EA_InteractionFlightMasterWindow.Shutdown()

end

function EA_InteractionFlightMasterWindow.Show()
    -- Show the window
    WindowSetShowing( "EA_InteractionFlightMasterWindow", true )
    
    EA_InteractionFlightMasterWindow.OnPairingChanged( GetZonePairing() )
end

function EA_InteractionFlightMasterWindow.Hide()   
    
    WindowSetShowing( "EA_InteractionFlightMasterWindow", false );
end

----------------------------------------------------------------
-- Default Interact Functions
----------------------------------------------------------------

function EA_InteractionFlightMasterWindow.ShowDefaultFrame()
    -- Initialize the window and then set it to the player's zone pairing
    EA_InteractionFlightMasterWindow.GetNewDataAndSort()
    
    local pairing = EA_InteractionFlightMasterWindow.flightPairing
    -- Hide the maps
    for index=GameData.Pairing.GREENSKIN_DWARVES, EA_InteractionFlightMasterWindow.NUM_PAIRINGS
    do
        WindowSetShowing( "EA_InteractionFlightMasterWindow"..index.."Map", index == pairing )
    end
    for index=GameData.ExpansionMapRegion.FIRST, GameData.ExpansionMapRegion.LAST
    do
        WindowSetShowing( "EA_InteractionFlightMasterWindow"..index.."Map", index == pairing )
    end
    
    local mapWindowName = "EA_InteractionFlightMasterWindow"..pairing.."Map"
    local buttonName = "FlightButton"
    -- Disable the buttons, because we are only told which flight
    -- points we can use, and the wing zones have no flight paths to them
    -- Also, assume that all zones are available, we will be told if they are not.
    for index, button in pairs( EA_InteractionFlightMasterWindow.ZoneButtonLookup[pairing] )
    do
        -- make sure tint color is reset...
        -- There's currently an issue with vertices losing their tint colors, so
        -- unless we ensure the dirty flag is set by setting the tint color to
        -- something else, the window might not render how we expect it to
        WindowSetTintColor(mapWindowName..button.zoneName..buttonName, 255, 255, 255)
        WindowSetTintColor(mapWindowName..button.zoneName..buttonName, 155, 155, 155)
        ButtonSetDisabledFlag(mapWindowName..button.zoneName..buttonName, true)
        button.zoneAvailable = true
    end
    
    local windowName = "EA_InteractionFlightMasterWindowNameButton"
    local moneyFrameName = "MoneyFrame"
    local zoneName
    local buttonIndex = 1
    local showCurrentZone = false
    local currentZoneMarkerName = mapWindowName.."CurrentZone"
    for index, zoneNum in ipairs( EA_InteractionFlightMasterWindow.ZoneNumbersLookup[ pairing ][ GameData.Player.realm ] )
    do
        local nameButton = windowName..index..buttonName
        
        -- Set the name and the ID
        ButtonSetText( nameButton, GetZoneName( zoneNum ) )
        WindowSetShowing( windowName..index, true )
        WindowSetId( nameButton, zoneNum )
        
        zoneName = EA_InteractionFlightMasterWindow.ZoneButtonLookup[pairing][zoneNum].zoneName
        
        local roundButton = nil
        if( zoneName )
        then
            roundButton = mapWindowName..zoneName..buttonName
        
            -- Set the current zone marker
            if( WindowGetId( roundButton ) == GameData.Player.zone )
            then
                WindowClearAnchors( currentZoneMarkerName )
                WindowAddAnchor( currentZoneMarkerName, "center", mapWindowName..zoneName, "center", 0, 0  )
                showCurrentZone = true
                ButtonSetDisabledFlag( roundButton, false )
                ButtonSetStayDownFlag( roundButton, true )
                ButtonSetPressedFlag( roundButton, true )
            else
                ButtonSetStayDownFlag( roundButton, false )
                ButtonSetPressedFlag( roundButton, false )
            end
        end
        
        -- Enable the right buttons...
        local flightData = EA_InteractionFlightMasterWindow.flightMasterData[ pairing ][ zoneNum ]
        if( flightData ~= nil and (flightData.zoneAvailable == true) )
        then
            MoneyFrame.FormatMoney( windowName..index..moneyFrameName, flightData.cost, MoneyFrame.HIDE_EMPTY_WINDOWS )
            WindowSetShowing( windowName..index..moneyFrameName, true )
            ButtonSetDisabledFlag( nameButton, false )
            
            -- Enable the round button
            if( roundButton )
            then
                ButtonSetDisabledFlag(roundButton, false)
            end
        else
            --Disable the buttons and hide the moneyframe
            ButtonSetDisabledFlag( nameButton, true )
            WindowSetShowing( windowName..index..moneyFrameName, false )
            if( roundButton )
            then
                if( not ButtonGetStayDownFlag( roundButton ) )
                then
                    ButtonSetDisabledFlag(roundButton, true)
                end
            
                if( flightData ~= nil and (flightData.zoneAvailable == false) )
                then
                    EA_InteractionFlightMasterWindow.ZoneButtonLookup[pairing][zoneNum].zoneAvailable = false
                    ColorFlightButton( roundButton, 
                                       false, 
                                       false )
                end
            end
        end
        
        buttonIndex = buttonIndex + 1
    end

    LabelSetText( mapWindowName.."Order",       StringUtils.GetRaceNameNounFromPairingAndRealm( pairing, GameData.Realm.ORDER, true ) )
    LabelSetText( mapWindowName.."Destruction", StringUtils.GetRaceNameNounFromPairingAndRealm( pairing, GameData.Realm.DESTRUCTION, true ) )
    if ( pairing < GameData.ExpansionMapRegion.FIRST )
    then
        LabelSetText( "EA_InteractionFlightMasterWindowBorderTitleText", GetStringFromTable( "MapSystem", StringTables.MapSystem["LABEL_PAIRING_"..pairing] ) )
    else
        LabelSetText( "EA_InteractionFlightMasterWindowBorderTitleText", GetStringFromTable( "MapSystem", StringTables.MapSystem["LABEL_EXPANSION_MAP_REGION_"..pairing] ) )
    end
    

    WindowSetShowing( currentZoneMarkerName, showCurrentZone )
    
    for pairingIndex=GameData.Pairing.GREENSKIN_DWARVES, EA_InteractionFlightMasterWindow.NUM_PAIRINGS
    do
        ButtonSetDisabledFlag( "EA_InteractionFlightMasterWindowPairing"..pairingIndex, pairingIndex == pairing )
    end
    for pairingIndex=GameData.ExpansionMapRegion.FIRST, GameData.ExpansionMapRegion.LAST
    do
        ButtonSetDisabledFlag( "EA_InteractionFlightMasterWindowPairing"..pairingIndex, pairingIndex == pairing )
    end
    
    -- Hide the remaining text buttons
    for index = buttonIndex, EA_InteractionFlightMasterWindow.NUM_FLIGHT_NAME_BUTTONS
    do
        WindowSetShowing( windowName..index, false )
    end
    
    -- shows the Tomb Kings realm resource quest tracker element if we are looking at that map
    EA_InteractionFlightMasterWindow.OnRRQsUpdated()
    
    PlayInteractSound("travel_offer")
end

function EA_InteractionFlightMasterWindow.OnMouseOverFlightMapPoint()
    local zoneNum = WindowGetId( SystemData.MouseOverWindow.name )
    local tier = 1

    local campaignData
    if EA_InteractionFlightMasterWindow.flightPairing < GameData.ExpansionMapRegion.FIRST
    then
        campaignData = GetCampaignZoneData( zoneNum )
    elseif EA_InteractionFlightMasterWindow.flightPairing == GameData.ExpansionMapRegion.TOMB_KINGS
    then
        -- psuedo-campaign zone data so at least the zone icon looks right for Tomb Kings
        campaignData = {controllingRealm=GameData.Realm.NONE, pairingId=GameData.ExpansionMapRegion.TOMB_KINGS, 
                    tierId = EA_Window_WorldMap.CAMPAIGN_TIER, isLocked=false}
        
        if RRQProgressBar ~= nil 
        then
            local rrqData = RRQProgressBar.GetFirstQuestDataOfType(GameData.RRQDisplayType.ERRQDISPLAY_TOMB_KINGS)
            if rrqData ~= nil
            then
                if rrqData.realmWithAccess > 0 
                then
                    campaignData.controllingRealm = rrqData.realmWithAccess
                end
                campaignData.isLocked = rrqData.paused
            end
        end
    end
    
    
    local controlledBy = 0
    if( campaignData )
    then
        controlledBy = campaignData.controllingRealm
        tier = campaignData.tierId
    end
    
    if( not controlledBy or controlledBy == 0 )
    then
        controlledBy = GameData.Realm.NONE
    end
    
    local flightData = EA_InteractionFlightMasterWindow.flightMasterData[ EA_InteractionFlightMasterWindow.flightPairing ][ zoneNum ]
    
    local function GetCityOwner( cityZone, realm )
        if( flightData )
        then
            if( GameData.Player.realm == realm )
            then
                controlledBy = realm
            else
                controlledBy = GameData.Realm.NONE
            end
        else
            controlledBy = realm
        end
    end
    
    -- TODO: Need to get a better way to find out who owns the city
    if( zoneNum == 61 )
    then
        GetCityOwner( 61, GameData.Realm.DESTRUCTION )
    elseif( zoneNum == 62 )
    then
        GetCityOwner( 62, GameData.Realm.ORDER )
    elseif( zoneNum == 161 )
    then
        GetCityOwner( 161, GameData.Realm.DESTRUCTION )
    elseif( zoneNum == 162 )
    then
        GetCityOwner( 162, GameData.Realm.ORDER )
    end

    local extraText
    local extraText2
    local clickText
    if( ButtonGetDisabledFlag( SystemData.MouseOverWindow.name ) )
    then
        clickText = GetString( StringTables.Default.TOOLTIP_TRAVEL_WINDOW_FLIGHT_POINT_LOCKED )
        
        if( flightData and (flightData.zoneAvailable == false) )
        then
            extraText = GetString( StringTables.Default.TOOLTIP_TRAVEL_WINDOW_LOCATION_UNAVAILABLE )
        elseif ( controlledBy == GameData.Realm.NONE and ( zoneNum == 61 or zoneNum == 62 or zoneNum == 161 or zoneNum == 162 ) )
        then
            extraText = GetString( StringTables.Default.TOOLTIP_TRAVEL_WINDOW_CITY_CONTESTED )
        elseif ( zoneNum == 191 )   -- 191 is Zandri (Land of the Dead), TODO: Remove hardcoded numbers
        then
            -- Use extraText2 instead of extraText because it is left aligned and the string contains a bulleted list. Leave extraText empty.
            extraText2 = GetStringFormat( StringTables.Default.TOOLTIP_TRAVEL_WINDOW_LAND_OF_DEAD_REQUIREMENTS, { GameData.LandOfTheDead.MinAccessLevel } )
        else
            extraText = GetString( StringTables.Default.TOOLTIP_TRAVEL_WINDOW_CANT_TRAVEL )
        end
    elseif( zoneNum == GameData.Player.zone )
    then
        clickText = GetString( StringTables.Default.TOOLTIP_TRAVEL_WINDOW_YOU_ARE_HERE )
    end
    
    local cost = 0
    if( flightData and (flightData.zoneAvailable == true) )
    then
        cost = flightData.cost
    end
    
    Tooltips.CreatePairingMapTravelToolTip( controlledBy,
                                            StringUtils.ToUpperZoneName( GetZoneName( zoneNum ) ),
                                            tier,
                                            GetZoneRanksForCurrentRealm( zoneNum ),
                                            extraText,
                                            extraText2,
                                            SystemData.MouseOverWindow.name,
                                            nil,
                                            clickText,
                                            cost )

    -- Highlight the map button
    ColorFlightButton( SystemData.MouseOverWindow.name, 
                       EA_InteractionFlightMasterWindow.ZoneButtonLookup[ EA_InteractionFlightMasterWindow.flightPairing ][ zoneNum ].zoneAvailable, 
                       true )

end

function EA_InteractionFlightMasterWindow.OnMouseOverEndFlightRoundButton()
    local pairing = EA_InteractionFlightMasterWindow.flightPairing
    local zoneNum = WindowGetId( SystemData.ActiveWindow.name )

    -- Set the map button back to normal
    ColorFlightButton( "EA_InteractionFlightMasterWindow"..pairing.."Map"..EA_InteractionFlightMasterWindow.ZoneButtonLookup[ pairing ][ zoneNum ].zoneName.."FlightButton", 
                       EA_InteractionFlightMasterWindow.ZoneButtonLookup[ EA_InteractionFlightMasterWindow.flightPairing ][ zoneNum ].zoneAvailable, 
                       false )
end

function EA_InteractionFlightMasterWindow.FlightPointLButtonUp()
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) or ButtonGetStayDownFlag( SystemData.ActiveWindow.name ) ) then
        return
    end
    local zoneNum = WindowGetId( SystemData.ActiveWindow.name )
    SystemData.UserInput.SelectedFlightPoint = EA_InteractionFlightMasterWindow.flightMasterData[ EA_InteractionFlightMasterWindow.flightPairing ][ zoneNum ].flightPointID
    BroadcastEvent( SystemData.Events.INTERACT_SELECT_FLIGHT_POINT )
    EA_InteractionFlightMasterWindow.Hide()
    PlayInteractSound("travel_accept")
end

function EA_InteractionFlightMasterWindow.FlightMapPointLButtonUp()
    EA_InteractionFlightMasterWindow.FlightPointLButtonUp()
end

function EA_InteractionFlightMasterWindow.GetNewDataAndSort()
    EA_InteractionFlightMasterWindow.flightMasterData = {}
    EA_InteractionFlightMasterWindow.flightMasterData[ GameData.Pairing.GREENSKIN_DWARVES ] = {}
    EA_InteractionFlightMasterWindow.flightMasterData[ GameData.Pairing.EMPIRE_CHAOS ] = {}
    EA_InteractionFlightMasterWindow.flightMasterData[ GameData.Pairing.ELVES_DARKELVES ] = {}
    EA_InteractionFlightMasterWindow.flightMasterData[ GameData.ExpansionMapRegion.TOMB_KINGS ] = {}
    
    local tempFlightMasterData = GetFlightMasterData()
    for flightIndex, flightData in ipairs( tempFlightMasterData )
    do
        if( (flightData.pairing <= EA_InteractionFlightMasterWindow.NUM_PAIRINGS and flightData.pairing > 0) or 
            (flightData.pairing >= GameData.ExpansionMapRegion.FIRST and flightData.pairing <= GameData.ExpansionMapRegion.LAST) )
        then
            EA_InteractionFlightMasterWindow.flightMasterData[ flightData.pairing ][ flightData.zoneNum ] = {}
            EA_InteractionFlightMasterWindow.flightMasterData[ flightData.pairing ][ flightData.zoneNum ].cost = flightData.cost
            EA_InteractionFlightMasterWindow.flightMasterData[ flightData.pairing ][ flightData.zoneNum ].flightPointID = flightData.flightPointID
            EA_InteractionFlightMasterWindow.flightMasterData[ flightData.pairing ][ flightData.zoneNum ].zoneNum = flightData.zoneNum
            EA_InteractionFlightMasterWindow.flightMasterData[ flightData.pairing ][ flightData.zoneNum ].zoneAvailable = flightData.zoneAvailable
        end
    end
end

function EA_InteractionFlightMasterWindow.OnPairingButton()
    local pairing = WindowGetId( SystemData.ActiveWindow.name )
    EA_InteractionFlightMasterWindow.OnPairingChanged( pairing )
end

function EA_InteractionFlightMasterWindow.OnPairingChanged( pairing )
    EA_InteractionFlightMasterWindow.flightPairing = pairing
    EA_InteractionFlightMasterWindow.ShowDefaultFrame()
end

function EA_InteractionFlightMasterWindow.OnMouseOverFlightTextButton()
    local pairing = EA_InteractionFlightMasterWindow.flightPairing
    local zoneNum = WindowGetId( SystemData.ActiveWindow.name )

    -- Highlight the map button
    ColorFlightButton( "EA_InteractionFlightMasterWindow"..pairing.."Map"..EA_InteractionFlightMasterWindow.ZoneButtonLookup[ pairing ][ zoneNum ].zoneName.."FlightButton", 
                       EA_InteractionFlightMasterWindow.ZoneButtonLookup[ pairing ][ zoneNum ].zoneAvailable, 
                       true )

end

function EA_InteractionFlightMasterWindow.OnMouseOverEndFlightTextButton()
    local pairing = EA_InteractionFlightMasterWindow.flightPairing
    local zoneNum = WindowGetId( SystemData.ActiveWindow.name )

    -- Set the map button back to normal
    ColorFlightButton( "EA_InteractionFlightMasterWindow"..pairing.."Map"..EA_InteractionFlightMasterWindow.ZoneButtonLookup[ pairing ][ zoneNum ].zoneName.."FlightButton", 
                       EA_InteractionFlightMasterWindow.ZoneButtonLookup[ pairing ][ zoneNum ].zoneAvailable, 
                       false )

end

function EA_InteractionFlightMasterWindow.OnRButtonUp()
    EA_Window_ContextMenu.CreateDefaultContextMenu( "EA_InteractionFlightMasterWindow" )
end

function EA_InteractionFlightMasterWindow.ShouldShowRRQ()
    if ( EA_InteractionFlightMasterWindow.flightPairing == GameData.ExpansionMapRegion.TOMB_KINGS )
    then
        return true
    end
    return false
end

--manages setting up the RRQ tracking window elements, but only when there's actually an ongoing RRQ
function EA_InteractionFlightMasterWindow.OnRRQsUpdated()
    local bShow = false

    -- Tomb Kings tracker on the bottom-right
    rrqData = RRQProgressBar.GetFirstQuestDataOfType(GameData.RRQDisplayType.ERRQDISPLAY_TOMB_KINGS)
    if rrqData ~= nil
    then
        -- lazy window creation, so make sure it exists and create if we need to
        if not DoesWindowExist("EA_InteractionFlightMasterWindowTombKingsBarContainerStatus")
        then
            -- setup Realm Resource Quest Status Window
            EA_InteractionFlightMasterWindow.TombKingsQuestWindowID = RRQProgressBar.Create( "EA_InteractionFlightMasterWindowTombKingsBarContainerStatus", 
                                                                                "EA_InteractionFlightMasterWindowTombKingsBarContainer",
                                                                                rrqData.displayType)
        end

        if not (RRQProgressBar.GetRRQuestIDfromWindowID( EA_InteractionFlightMasterWindow.TombKingsQuestWindowID ) == rrqData.rrquestID)
        then
            RRQProgressBar.SetRRQuestID( EA_InteractionFlightMasterWindow.TombKingsQuestWindowID, rrqData.rrquestID )
        end
        
        -- we only want this visible if there is currently an ongoing RRQ
        bShow = true
    end
    
    bShow = bShow and EA_InteractionFlightMasterWindow.ShouldShowRRQ()
    WindowSetShowing("EA_InteractionFlightMasterWindowTombKingsBarContainer", bShow)
    
end
