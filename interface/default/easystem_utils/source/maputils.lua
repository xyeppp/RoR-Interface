

MapUtils = {}

-- Icons
MapUtils.MAP_ICON_PLAYER_ARROW      = 00001
MapUtils.MAP_ICON_ORDER_KEEP        = 00103
MapUtils.MAP_ICON_DESTRUCTION_KEEP  = 00104
MapUtils.MAP_ICON_TREASURE_CHEST    = 01072
MapUtils.MAP_ICON_PQ_ACTIVE         = 01314
MapUtils.MAP_ICON_GROUP_QUEST       = 00030
MapUtils.MAP_ICON_RVR_GROUP_QUEST   = 01301
MapUtils.MAP_ICON_RVR_HOTSPOT       = 00036

MapUtils.MAP_ICON_SCENARIO_FLAG_NEUTRAL     = 00090
MapUtils.MAP_ICON_SCENARIO_FLAG_ORDER       = 00091
MapUtils.MAP_ICON_SCENARIO_FLAG_DESTRUCTION = 00092


MapUtils.openTomeToQuestCallback = nil
MapUtils.openTomeToEventTaskCallback = nil
MapUtils.toggleTomeCallback = nil


function MapUtils.RegisterOpenTomeToQuestCallback( callbackFunction )

    if callbackFunction == nil then
        ERROR(L"Attempting to set Open Tome To Quest Callback function to nil!")
    else
        MapUtils.openTomeToQuestCallback = callbackFunction
    end
    
end

function MapUtils.RegisterOpenTomeToEventTaskCallback( callbackFunction )

    if callbackFunction == nil then
        ERROR(L"Attempting to set Open Tome To Event Task Callback function to nil!")
    else
        MapUtils.openTomeToEventTaskCallback = callbackFunction
    end
    
end

function MapUtils.RegisterToggleTomeCallback( callbackFunction )

    if callbackFunction == nil then
        ERROR(L"Attempting to set Toggle Tome Callback function to nil!")
    else
        MapUtils.toggleTomeCallback = callbackFunction
    end
    
end

function MapUtils.ClickMap( mapDisplay, points )

    if MapUtils.toggleTomeCallback ~= nil then

        for index, ptIndex in ipairs( points ) do    
         
            local pointData = GetMapPointData( mapDisplay, ptIndex )
            
            if( pointData.pointType == SystemData.MapPips.QUEST_AREA) then
            
                if( WindowGetShowing( "TomeWindow" ) == false  ) then	   	    
                    MapUtils.toggleTomeCallback()
                else
                    --bring to front even if it's behind something now
                    MapUtils.toggleTomeCallback()
                    MapUtils.toggleTomeCallback()
                end
                if ( MapUtils.openTomeToQuestCallback ~= nil ) then
                    MapUtils.openTomeToQuestCallback( pointData.id )
                end
                
                break
            elseif ( pointData.pointType == SystemData.MapPips.LIVE_EVENT_WAYPOINT ) then
                if ( WindowGetShowing( "TomeWindow" ) == false ) then
                    MapUtils.toggleTomeCallback()
                else
                    --bring to front even if it's behind something now
                    MapUtils.toggleTomeCallback()
                    MapUtils.toggleTomeCallback()
                end
                if ( MapUtils.openTomeToEventTaskCallback ~= nil ) then
                    MapUtils.openTomeToEventTaskCallback( pointData.id, pointData.taskId )
                end
                
                break
            end 

        end   
    
    end
    
end


-- Updates a CityRating container.
function MapUtils.UpdateCityRatingWindow( cityId, windowName )

    -- Show the Rating Stars    
    local sliceName = "star-order"
    if( cityId == GameData.CityId.CHAOS or cityId == GameData.CityId.GREENSKIN )
    then
        --DEBUG( L"Destruction"..controlledBy )
        sliceName = "star-destruction"
    end

    local cityRating = GetCityRatingForCityId( cityId )
    if cityRating==nil then 
      cityRating = 5
    end
    for rating = 1, GameDefs.NUM_CITY_RANKS 
    do
        local showStar = rating <= cityRating
        WindowSetShowing( windowName.."Star"..rating, showStar )
        
        if( showStar )
        then
            DynamicImageSetTextureSlice( windowName.."Star"..rating, sliceName )
       end
   end
   
   
      
end

-- Gets a list of activity strings for the given city, state, and rating
function MapUtils.GetCityActivityStrings( cityId, cityState, cityRating )
    local statePrefix
    if (cityState == SystemData.CityStates.PILLAGE or cityState == SystemData.CityStates.KINGUNLOCKED or cityState == SystemData.CityStates.MARTIAL)
    then
        statePrefix = "CAPTURED"
    elseif (cityState == SystemData.CityStates.TRANSITION)
    then
        statePrefix = "TRANSITION"
    elseif (cityState == SystemData.CityStates.STARTUP)
    then
        statePrefix = "STARTUP"
    elseif (cityState == SystemData.CityStates.OPEN)
    then
        statePrefix = "CONTESTED"
    elseif (cityState == SystemData.CityStates.SHUTDOWN)
    then
        statePrefix = "SHUTDOWN"
    else
        statePrefix = "PEACEFUL"
    end
    
    local itemsText = {}
    if (cityRating==nil) then cityRating = 5 end
    for rating = Tooltips.NUM_CITY_RANKS, 1, -1
    do        
        if( rating <= cityRating )
        then
        
            -- Set the Rank Descriptions                
            local activityRankIndex = 1
            local descItemStringId  = StringTables.RvRCity[ "CITY_"..cityId.."_"..statePrefix.."_RATING_"..rating.."_ACTIVITY_"..activityRankIndex ]   
            while( descItemStringId )
            do  
    
                local text = GetStringFromTable( "RvRCityStrings", descItemStringId )
                table.insert( itemsText, text )            
                    
                activityRankIndex = activityRankIndex + 1
                descItemStringId  = StringTables.RvRCity[ "CITY_"..cityId.."_"..statePrefix.."_RATING_"..rating.."_ACTIVITY_"..activityRankIndex ]  
            end           
        end            
    end
    
    if (statePrefix == "PEACEFUL")
    then
        -- Quest & PQ Text only applies to peaceful cities
        local text = GetStringFormatFromTable( "RvRCityStrings", StringTables.RvRCity.RANK_X_CITY_AND_PQ_AVAIL, { L""..cityRating } )     
        table.insert( itemsText, text )
    end
    
    return itemsText
end

-- Given the zone number of a peaceful city, get the zone number of its contested version
function MapUtils.GetContestedCityZoneFromPeacefulZone( peacefulZoneId )
    local cityId = GameDefs.PeacefulCityZoneIDs[peacefulZoneId]
    if (cityId ~= nil) then
        for possibleZoneId, possibleCityId in pairs(GameDefs.ZoneCityIds) do
            -- The contested city has the same city ID number as the peaceful city but a different zone number
            if ((possibleCityId == cityId) and (possibleZoneId ~= peacefulZoneId)) then
                return possibleZoneId
            end
        end
    end
    
    return 0
end
