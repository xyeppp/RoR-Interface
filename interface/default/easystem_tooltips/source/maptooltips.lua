
-- Constants
Tooltips.MAX_MAP_POINT_TOOLTIP_TEXT_LINES = 10

-- Text Colors
Tooltips.MAP_DESC_TEXT_COLOR = { r=255, g=204, b=51 }
Tooltips.MAP_SELF_TEXT_COLOR = { r=82, g=125, b=247 }


Tooltips.MAP_TOOLTIP_LABELS_SPACING = 15
Tooltips.MAP_TOOLTIP_VERTICAL_BORDER = 75

Tooltips.NUM_CITY_RANKS = 5
Tooltips.MAX_CITY_ACTIVITES = 8
Tooltips.CITY_ACTIVITY_SPACING = 8
Tooltips.CITY_RATING_OFFSET = 45

Tooltips.MAP_TYPE_MAINMAP = 1
Tooltips.MAP_TYPE_MINIMAP = 2
Tooltips.MAP_TYPE_OTHER = 3

------------------------------------------------------------------------------------------------------------
-- Map Point Tooltip Tooltip Functions
------------------------------------------------------------------------------------------------------------
    
local MapPointSortOrder  = {}
MapPointSortOrder[ SystemData.MapPips.LANDMARK ]                            = 1
MapPointSortOrder[ SystemData.MapPips.CHAPTER ]                             = 2
MapPointSortOrder[ SystemData.MapPips.WAR_CAMP ]                            = 3
MapPointSortOrder[ SystemData.MapPips.PUBLIC_QUEST ]                        = 4
MapPointSortOrder[ SystemData.MapPips.KEEP ]                                = 5
MapPointSortOrder[ SystemData.MapPips.OBJECTIVE ]                           = 6
MapPointSortOrder[ SystemData.MapPips.FLAG ]                                = 7
MapPointSortOrder[ SystemData.MapPips.QUEST_AREA ]                          = 8
MapPointSortOrder[ SystemData.MapPips.LIVE_EVENT_WAYPOINT ]                 = 9
MapPointSortOrder[ SystemData.MapPips.LIVE_EVENT_QUEST_OFFER_NPC ]          = 10
MapPointSortOrder[ SystemData.MapPips.QUEST_OFFER_NPC ]                     = 11
MapPointSortOrder[ SystemData.MapPips.REPEATABLE_QUEST_OFFER_NPC ]          = 12
MapPointSortOrder[ SystemData.MapPips.QUEST_PENDING_NPC ]                   = 13
MapPointSortOrder[ SystemData.MapPips.QUEST_COMPLETE_NPC ]                  = 14
MapPointSortOrder[ SystemData.MapPips.INFLUENCE_REWARDS_NPC ]               = 15
MapPointSortOrder[ SystemData.MapPips.INFLUENCE_REWARDS_PENDING_NPC ]       = 16
MapPointSortOrder[ SystemData.MapPips.BOUNTY_HUNTER_QUEST_OFFER_NPC ]       = 17
MapPointSortOrder[ SystemData.MapPips.BOUNTY_HUNTER_QUEST_PENDING_NPC ]     = 18
MapPointSortOrder[ SystemData.MapPips.BOUNTY_HUNTER_QUEST_COMPLETE_NPC ]    = 19
MapPointSortOrder[ SystemData.MapPips.KILL_COLLECTOR_QUEST_PENDING_NPC ]    = 20
MapPointSortOrder[ SystemData.MapPips.KILL_COLLECTOR_QUEST_COMPLETE_NPC ]   = 21
MapPointSortOrder[ SystemData.MapPips.STORE_NPC ]                           = 22
MapPointSortOrder[ SystemData.MapPips.EQUIPMENT_UPGRADE_NPC ]               = 23
MapPointSortOrder[ SystemData.MapPips.TRAINER_NPC ]                         = 24
MapPointSortOrder[ SystemData.MapPips.SCENARIO_GATEKEEPER_NPC ]             = 25
MapPointSortOrder[ SystemData.MapPips.AUCTION_HOUSE_NPC ]                   = 26
MapPointSortOrder[ SystemData.MapPips.TRAVEL_NPC ]                          = 27
MapPointSortOrder[ SystemData.MapPips.VAULT_KEEPER_NPC ]                    = 28
MapPointSortOrder[ SystemData.MapPips.BINDER_NPC ]                          = 29
MapPointSortOrder[ SystemData.MapPips.GUILD_REGISTRAR_NPC ]                 = 30
MapPointSortOrder[ SystemData.MapPips.MERCHANT_LASTNAME ]                   = 31
MapPointSortOrder[ SystemData.MapPips.PLAYER ]                              = 32
MapPointSortOrder[ SystemData.MapPips.GROUP_MEMBER ]                        = 33
MapPointSortOrder[ SystemData.MapPips.WARBAND_MEMBER ]                      = 34
MapPointSortOrder[ SystemData.MapPips.ORDER_ARMY ]                          = 35
MapPointSortOrder[ SystemData.MapPips.DESTRUCTION_ARMY ]                    = 36
MapPointSortOrder[ SystemData.MapPips.IMPORTANT_MONSTER ]                   = 37
MapPointSortOrder[ SystemData.MapPips.HEALER_NPC ]                          = 38
MapPointSortOrder[ SystemData.MapPips.MAILBOX ]                             = 39
MapPointSortOrder[ SystemData.MapPips.HOTSPOT_LARGE ]                       = 40
MapPointSortOrder[ SystemData.MapPips.HOTSPOT_MEDIUM ]                      = 41
MapPointSortOrder[ SystemData.MapPips.HOTSPOT_SMALL ]                       = 42
local NUM_SORTED_MAP_POINT_TYPES =  42

-- Map Tooltip
function Tooltips.CreateMapPointTooltip( mapDisplay, points, anchor, mapDisplayType )

    -- Parse out the points
    local sortedPoints = {}
    local numPts = 0
    for _, ptIndex in ipairs( points ) do
        local ptData = GetMapPointData( mapDisplay, ptIndex )
        if (ptData ~= nil) then
            ptData.pointIndex = ptIndex
        
            local sortIndex = MapPointSortOrder[ptData.pointType]
            if (sortIndex ~= nil) then
                if( sortedPoints[sortIndex] == nil ) then
                    sortedPoints[sortIndex] = {}
                end
                table.insert( sortedPoints[sortIndex], ptData )
                numPts = numPts + 1
            end
        end
    end
    
    if (numPts == 0) then
        Tooltips.ClearTooltip()
        return
    end
    
    -- Create the tooltip display for each point
    local MAX_MAP_POINT_INFO = 10
    local ICON_SIZE = 28

    local infoIndex = 1
    local largestTextWidth = 100
    for sortIndex = 1, NUM_SORTED_MAP_POINT_TYPES do
    
        if( sortedPoints[sortIndex] ) then
            for _, ptData in ipairs( sortedPoints[sortIndex] ) do
                        
                local iconWindow        = "MapPointsTooltipInfo"..infoIndex.."Icon"
                local nameWindow        = "MapPointsTooltipInfo"..infoIndex.."Name"
                local pinTypeWindow     = "MapPointsTooltipInfo"..infoIndex.."PinTypeDesc"
                local textWindows       =
                {
                    "MapPointsTooltipInfo"..infoIndex.."Text1",
                    "MapPointsTooltipInfo"..infoIndex.."Text2",
                    "MapPointsTooltipInfo"..infoIndex.."Text3",
                    "MapPointsTooltipInfo"..infoIndex.."Text4",
                    "MapPointsTooltipInfo"..infoIndex.."Text5",
                    "MapPointsTooltipInfo"..infoIndex.."Text6",
                    "MapPointsTooltipInfo"..infoIndex.."Text7",
                }
                
                            
                local questData = nil 
                if( ptData.pointType == SystemData.MapPips.QUEST_AREA ) 
                then
                    questData = DataUtils.GetQuestData( ptData.id )
                end 

                -- Set the Icon
                local textureX, textureY, sizeX, sizeY
                
                -- Quest Areas use the scoll icon for the tooltip instead of the map icon
                if( ptData.pointType == SystemData.MapPips.QUEST_AREA ) then                 
                    sizeX = 32
                    sizeY = 32
                    DynamicImageSetTexture( iconWindow, "map_markers01", 0, 0 )   
                    -- set the slice on the dynamic image
                    QuestUtils.SetCompletionIcon( questData, iconWindow )
                elseif ( ptData.pointType == SystemData.MapPips.LIVE_EVENT_WAYPOINT ) then
                    sizeX = 32
                    sizeY = 32
                    DynamicImageSetTexture( iconWindow, "map_markers01", 0, 0 )
                    DynamicImageSetTextureSlice( iconWindow, "QuestAvailable-LiveEvent" )
                else
                    textureX, textureY, sizeX, sizeY = GetMapIconData( ptData.mapIcon )
                    -- Clear the slice on the dynamic image. DynamicImageSetTexture will not work
                    -- correctly if a slice is assigned.
                    DynamicImageSetTextureSlice( iconWindow, "" )
                    DynamicImageSetTexture( iconWindow, "map_markers01", textureX, textureY )   
                end
                
                -- Scale the icon
                DynamicImageSetTextureDimensions( iconWindow, sizeX, sizeY )
                
                local xScale = ICON_SIZE/sizeX;
                local yScale = ICON_SIZE/sizeY;
                
                if( xScale < yScale ) 
                then
                    WindowSetDimensions( iconWindow, ICON_SIZE, ICON_SIZE*(xScale/yScale))
                else        
                    WindowSetDimensions( iconWindow, ICON_SIZE*(yScale/xScale), ICON_SIZE)
                end
                
                -- Keep data             
                local keepData = nil 
                if( ptData.pointType == SystemData.MapPips.KEEP ) 
                then
                    keepData = GetKeepData( ptData.id )
                end 
                                
                
                -- Name 
                if( questData ) then
                    -- For Quests, show the quest name
                    LabelSetText(nameWindow, GetStringFormatFromTable("Mapsystem", StringTables.MapSystem.LABEL_MINIMAP_TOOLTIP_QUEST, {questData.name} ) )
                elseif ( ptData.pointType == SystemData.MapPips.LIVE_EVENT_WAYPOINT ) then
                    -- For Live Event waypoints, show the live event name
                    local eventData = GetLiveEventData( ptData.id )
                    if ( eventData ~= nil ) then
                        LabelSetText(nameWindow, GetStringFormatFromTable("MapSystem", StringTables.MapSystem.LABEL_MINIMAP_TOOLTIP_LIVE_EVENT, {eventData.title} ) )
                    end
                elseif ( ptData.pointType == SystemData.MapPips.IMPORTANT_MONSTER ) then
                    -- For Important Monsters, show their map pip name
                    LabelSetText(nameWindow, ptData.name)
                else
                    LabelSetText(nameWindow, GetStringFormatFromTable("Mapsystem", StringTables.MapSystem.LABEL_MINIMAP_TOOLTIP, {ptData.name} ) ) -- Tooltip name on the Map Pin on the minimap
                end
                
                local x, y = WindowGetDimensions( nameWindow )
                
                local height = 20
                if( y > height ) then
                    height = y 
                end
                
                if( x > largestTextWidth ) then
                    largestTextWidth = x
                end
                
                 -- Pin Type Desc
                local pinDesc = L""
                if ( keepData )
                then
                    pinDesc = GetStringFormatFromTable( "MapPointTypes", StringTables.MapPointTypes.PIN_TYPE_KEEP, { GetRealmName( keepData.realmOwner ) } )
                elseif ( ptData.pointType == SystemData.MapPips.LANDMARK ) then
                
                    local importanceStr = L""
                    if (ptData.importance == SystemData.LandmarkImportance.MAJOR) then
                        importanceStr = GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_LANDMARK_IMPORTANCE_MAJOR )
                    elseif (ptData.importance == SystemData.LandmarkImportance.MINOR) then
                        importanceStr = GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_LANDMARK_IMPORTANCE_MINOR )
                    end
                    pinDesc = GetStringFormatFromTable("MapPointTypes", StringTables.MapPointTypes.PIN_TYPE_LANDMARK, { importanceStr } )
                    
                elseif ( ptData.pointType == SystemData.MapPips.CHAPTER ) then
                
                    local factionName = L""
                    if (ptData.faction ~= GameData.Factions.NONE) then
                        factionName = StringUtils.GetFactionNameNoun(ptData.faction)
                    else
                        -- No faction; use realm
                        factionName = GetRealmName(ptData.realm)
                    end
                    
                    local chapterNumber = L""..ptData.chapter
                    pinDesc = GetStringFormatFromTable("MapPointTypes", StringTables.MapPointTypes.PIN_TYPE_CHAPTER, { factionName, chapterNumber } )
                    
                elseif ( ptData.pointType == SystemData.MapPips.WAR_CAMP ) then
                
                    local factionName = L""
                    if (ptData.faction ~= GameData.Factions.NONE) then
                        factionName = StringUtils.GetFactionNameNoun(ptData.faction)
                    else
                        -- No faction; use realm
                        factionName = GetRealmName(ptData.realm)
                    end
                    
                    pinDesc = GetStringFormatFromTable("MapPointTypes", StringTables.MapPointTypes.PIN_TYPE_WAR_CAMP, { factionName } )
                    
                elseif ( ptData.pointType == SystemData.MapPips.PUBLIC_QUEST ) then
                    -- The IDs for the chapter 22 hard PQ, this is needed as we cannot set very hard in the mappoints for PQ
                    local ch_22_vhard_ids = {116, 127, 319, 332, 482, 494}
                    local difficultyStr = L""
                    if (ptData.difficulty == SystemData.PublicQuestTypes.EASY_DIFFICULTY) then
                        difficultyStr = GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_PUBLIC_QUEST_EASY_DIFFICULTY )
                    elseif (ptData.difficulty == SystemData.PublicQuestTypes.NORMAL_DIFFICULTY) then
                        difficultyStr = GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_PUBLIC_QUEST_NORMAL_DIFFICULTY )
                    elseif (ptData.difficulty == SystemData.PublicQuestTypes.HARD_DIFFICULTY) then
                        difficultyStr = GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_PUBLIC_QUEST_HARD_DIFFICULTY )
                    end
                    if ptData.id ~= nil and HasValue(ch_22_vhard_ids, ptData.id) then
                        difficultyStr = GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_PUBLIC_QUEST_VERY_HARD_DIFFICULTY )
                    end
                    pinDesc = GetStringFormatFromTable("MapPointTypes", StringTables.MapPointTypes.PIN_TYPE_PUBLIC_QUEST, { difficultyStr } )
                    
                elseif ( ptData.pointType == SystemData.MapPips.IMPORTANT_MONSTER ) then
                
                    if(wstring.len(ptData.mapPipName) > 0)
                    then
                        pinDesc = ptData.mapPipName
                    else
                        pinDesc = GetStringFromTable("MapPointTypes", ptData.pointType)                        
                    end
                    
                else
                
                    pinDesc = GetStringFromTable("MapPointTypes", ptData.pointType)
                    
                end
                
                LabelSetText(pinTypeWindow, pinDesc )

                local x, y = WindowGetDimensions( pinTypeWindow )
                height = height + y
                
                if( x > largestTextWidth ) then
                    largestTextWidth = x
                end
                
                -- Text
                local textValues = {}
                local textColors = {}
                local currentLabel = 1
                
                for textWindowIndex = 1, #textWindows
                do
                    textValues[textWindowIndex] = L""
                    textColors[textWindowIndex] = DefaultColor.ZERO_TINT
                end
                
                if( ptData.text ~= nil and ptData.text ~= L"" ) then
                    textValues[currentLabel] = ptData.text
                    currentLabel = currentLabel + 1
                end

                if ( ptData.pointType == SystemData.MapPips.LANDMARK ) then
                    if ( ptData.specialType > 0 ) then
                        textValues[currentLabel] = GetStringFromTable( "LandmarkSpecialTypes", ptData.specialType )
                        currentLabel = currentLabel + 1
                    end
                    
                    if ( ptData.glyphsRequired ~= nil ) then
                        if ( #ptData.glyphsRequired >= 3 ) then
                            textValues[currentLabel] = GetStringFormatFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_GLYPH_REQUIRED_3, ptData.glyphsRequired )
                            currentLabel = currentLabel + 1
                        elseif ( #ptData.glyphsRequired >= 2 ) then
                            textValues[currentLabel] = GetStringFormatFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_GLYPH_REQUIRED_2, ptData.glyphsRequired )
                            currentLabel = currentLabel + 1
                        elseif ( #ptData.glyphsRequired >= 1 ) then
                            textValues[currentLabel] = GetStringFormatFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_GLYPH_REQUIRED_1, ptData.glyphsRequired )
                            currentLabel = currentLabel + 1
                        end
                    end
                end
                
                if ( ptData.pointType == SystemData.MapPips.OBJECTIVE ) then
                    local objectiveId = ptData.id
                    local objectiveData = GameData.GetObjectiveData(objectiveId)
                    if ( objectiveData ~= nil ) then
                        if ( objectiveData.controllingRealm == GameData.Realm.ORDER ) then
                            textValues[currentLabel] = GetStringFromTable( "MapSystem", StringTables.MapSystem.TEXT_OBJECTIVE_CONTROLLED_BY_ORDER )
                        elseif ( objectiveData.controllingRealm == GameData.Realm.DESTRUCTION ) then
                            textValues[currentLabel] = GetStringFromTable( "MapSystem", StringTables.MapSystem.TEXT_OBJECTIVE_CONTROLLED_BY_DESTRUCTION )
                        elseif ( objectiveData.controllingRealm == GameData.Realm.NONE ) then
                            textValues[currentLabel] = GetStringFromTable( "MapSystem", StringTables.MapSystem.TEXT_OBJECTIVE_NOT_CONTROLLED )
                        else
                            textValues[currentLabel] = GetStringFromTable( "MapSystem", StringTables.MapSystem.TEXT_OBJECTIVE_CONTROL_UNKNOWN )
                        end
                        currentLabel = currentLabel + 1
                    else
                        textValues[currentLabel] = GetStringFromTable( "MapSystem", StringTables.MapSystem.TEXT_OBJECTIVE_CONTROL_UNKNOWN )
                        currentLabel = currentLabel + 1
                    end
                end
                
                if ( ( ptData.pointType == SystemData.MapPips.CHAPTER ) or ( ptData.pointType == SystemData.MapPips.WAR_CAMP ) or ( ptData.pointType == SystemData.MapPips.PUBLIC_QUEST ) ) then
                    if ( ptData.hasRankCount ) then
                        if ( ptData.rankMin == ptData.rankMax ) then
                            local rankMin = L""..ptData.rankMin
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_RANK_SINGLE, { rankMin } )
                        else
                            local rankMin = L""..ptData.rankMin
                            local rankMax = L""..ptData.rankMax
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_RANK_RANGE, { rankMin, rankMax } )
                        end
                        currentLabel = currentLabel + 1
                    end
                end
                
                if ( ptData.pointType == SystemData.MapPips.PUBLIC_QUEST ) then
                    if (ptData.rewards == SystemData.PublicQuestTypes.BASIC_REWARDS) then
                        textValues[currentLabel] = GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_PUBLIC_QUEST_BASIC_REWARDS )
                    elseif (ptData.rewards == SystemData.PublicQuestTypes.NORMAL_REWARDS) then
                        textValues[currentLabel] = GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_PUBLIC_QUEST_NORMAL_REWARDS )
                    elseif (ptData.rewards == SystemData.PublicQuestTypes.ADVANCED_REWARDS) then
                        textValues[currentLabel] = GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_PUBLIC_QUEST_ADVANCED_REWARDS )
                    elseif (ptData.rewards == SystemData.PublicQuestTypes.TOKEN_REWARDS) then
                        textValues[currentLabel] = GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_PUBLIC_QUEST_TOKEN_REWARDS )
                    end
                    currentLabel = currentLabel + 1
                        
                    if ( ptData.glyphAwarded ~= nil ) then
                        textValues[currentLabel] = GetStringFormatFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_GLYPH_AWARD, { ptData.glyphAwarded } )
                        currentLabel = currentLabel + 1
                    end
                        
                    if ( ptData.playersIsRange ) then
                        local playersMin = L""..ptData.playersMin
                        local playersMax = L""..ptData.playersMax
                        textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_PUBLIC_QUEST_PLAYERS_RANGE, { playersMin, playersMax } )
                    else
                        local playersMin = L""..ptData.playersMin
                        textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_PUBLIC_QUEST_PLAYERS_MINIMUM, { playersMin } )
                    end
                    currentLabel = currentLabel + 1
                        
                    if ( ptData.hasPopCount ) then
                        -- Only show pop count on mainmap
                        if ( mapDisplayType == Tooltips.MAP_TYPE_MAINMAP ) then
                            local popCount = L""..ptData.popCount
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_PUBLIC_QUEST_POPULATION, { popCount } )
                            currentLabel = currentLabel + 1
                        end
                    end
                end
                    
                if ( ( ptData.pointType == SystemData.MapPips.CHAPTER ) or ( ptData.pointType == SystemData.MapPips.WAR_CAMP ) ) then
                    local trainerNames = {}
                    local merchantNames = {}
                    local serviceNames = {}
                    local otherNames = {}
                    
                    if ( ptData.services[SystemData.HubService.CAREER_TRAINER] ) then
                        table.insert( trainerNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_CAREER_TRAINER ) )
                    end
                    if ( ptData.services[SystemData.HubService.TRADESKILL_TRAINERS] ) then
                        table.insert( trainerNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_TRADESKILL_TRAINERS ) )
                    end
                    if ( ptData.services[SystemData.HubService.RENOWN_TRAINER] ) then
                        table.insert( trainerNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_RENOWN_TRAINER ) )
                    end
                    if ( ptData.services[SystemData.HubService.APPRENTICE_CAREER_TRAINER] ) then
                        table.insert( trainerNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_APPRENTICE_CAREER_TRAINER ) )
                    end
                    if ( ptData.services[SystemData.HubService.APPRENTICE_RENOWN_TRAINER] ) then
                        table.insert( trainerNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_APPRENTICE_RENOWN_TRAINER ) )
                    end
                    if ( ptData.services[SystemData.HubService.GENERAL_MERCHANTS] ) then
                        table.insert( merchantNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_GENERAL_MERCHANTS ) )
                    end
                    if ( ptData.services[SystemData.HubService.SIEGE_WEAPON_MERCHANT] ) then
                        table.insert( merchantNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_SIEGE_WEAPON_MERCHANT ) )
                    end
                    if ( ptData.services[SystemData.HubService.RENOWN_GEAR_MERCHANT] ) then
                        table.insert( merchantNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_RENOWN_GEAR_MERCHANT ) )
                    end
                    if ( ptData.services[SystemData.HubService.QUARTERMASTER] ) then
                        table.insert( merchantNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_QUARTERMASTER ) )
                    end
                    if ( ptData.services[SystemData.HubService.CRAFT_SUPPLY_MERCHANT] ) then
                        table.insert( merchantNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_CRAFT_SUPPLY_MERCHANT ) )
                    end
                    if ( ptData.services[SystemData.HubService.RECRUITS_MEDALLION_MERCHANT] ) then
                        table.insert( merchantNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_RECRUITS_MEDALLION_MERCHANT ) )
                    end
                    if ( ptData.services[SystemData.HubService.RECRUITS_EMBLEM_MERCHANT] ) then
                        table.insert( merchantNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_RECRUITS_EMBLEM_MERCHANT ) )
                    end
                    if ( ptData.services[SystemData.HubService.HEALER] ) then
                        table.insert( serviceNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_HEALER ) )
                    end
                    if ( ptData.services[SystemData.HubService.RALLY_MASTER] ) then
                        table.insert( serviceNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_RALLY_MASTER ) )
                    end
                    if ( ptData.services[SystemData.HubService.FLIGHT_MASTER] ) then
                        table.insert( serviceNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_FLIGHT_MASTER ) )
                    end
                    if ( ptData.services[SystemData.HubService.AUCTIONEER] ) then
                        table.insert( serviceNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_AUCTIONEER ) )
                    end
                    if ( ptData.services[SystemData.HubService.KILL_COLLECTOR] ) then
                        table.insert( otherNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_KILL_COLLECTOR ) )
                    end
                    if ( ptData.services[SystemData.HubService.MAILBOX] ) then
                        table.insert( otherNames, GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_HUB_MAILBOX ) )
                    end
                    
                    local numTrainers = #trainerNames
                    local numMerchants = #merchantNames
                    local numServices = #serviceNames
                    local numOthers = #otherNames
                    
                    if (numTrainers > 0) then
                        if (numTrainers >= 5) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_TRAINERS_5, trainerNames )
                        elseif (numTrainers >= 4) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_TRAINERS_4, trainerNames )
                        elseif (numTrainers >= 3) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_TRAINERS_3, trainerNames )
                        elseif (numTrainers == 2) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_TRAINERS_2, trainerNames )
                        elseif (numTrainers == 1) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_TRAINERS_1, trainerNames )
                        end
                        currentLabel = currentLabel + 1
                    end
                    
                    if (numMerchants > 0) then
                        if (numMerchants >= 7) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_MERCHANTS_7, merchantNames )
                        elseif (numMerchants >= 6) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_MERCHANTS_6, merchantNames )
                        elseif (numMerchants >= 5) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_MERCHANTS_5, merchantNames )
                        elseif (numMerchants >= 4) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_MERCHANTS_4, merchantNames )
                        elseif (numMerchants == 3) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_MERCHANTS_3, merchantNames )
                        elseif (numMerchants == 2) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_MERCHANTS_2, merchantNames )
                        elseif (numMerchants == 1) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_MERCHANTS_1, merchantNames )
                        end
                        currentLabel = currentLabel + 1
                    end
                    
                    if (numServices > 0) then
                        if (numServices >= 4) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_SERVICES_4, serviceNames )
                        elseif (numServices == 3) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_SERVICES_3, serviceNames )
                        elseif (numServices == 2) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_SERVICES_2, serviceNames )
                        elseif (numServices == 1) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_SERVICES_1, serviceNames )
                        end
                        currentLabel = currentLabel + 1
                    end
                    
                    if (numOthers > 0) then
                        if (numOthers >= 2) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_OTHER_2, otherNames )
                        elseif (numOthers == 1) then
                            textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_HUB_OTHER_1, otherNames )
                        end
                        currentLabel = currentLabel + 1
                    end
                    
                end
                
                -- Display distance only on the minimap and only if the point isn't too close to the player
                local minimumDistanceToDisplay = 200    -- 200 feet
                if ( ( mapDisplayType == Tooltips.MAP_TYPE_MINIMAP ) and ( ptData.distance >= minimumDistanceToDisplay ) )
                then
                    if ( SystemData.Territory.KOREA )
                    then
                        local footToMeter = 0.3048
                        local roundTo = 5       -- 5 meters
                        
                        local adjustedDistance = ptData.distance * footToMeter
                        adjustedDistance = math.floor(adjustedDistance / roundTo + 0.5) * roundTo
                        textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_DISTANCE_METERS, { towstring(adjustedDistance) } )
                    else
                        local roundTo = 10      -- 10 feet
                        
                        local adjustedDistance = math.floor(ptData.distance / roundTo + 0.5) * roundTo
                        textValues[currentLabel] = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TOOLTIP_DISTANCE_FEET, { towstring(adjustedDistance) } )
                    end
                    textColors[currentLabel] = { r=255, g=204, b=51 }
                    currentLabel = currentLabel + 1
                end
                
                if ( keepData )
                then
                    -- Only show Siege/Skaven data if the Keep's zone isn't locked.
                    local zoneData = GetCampaignZoneData( ptData.zone )
                    if ( ( zoneData ~= nil ) and ( not zoneData.isLocked ) )
                    then
                        if ( keepData.siege )
                        then
                            local hasAnySiege = false
                            local isFirst = true
                            local siegeText = L""
                            local pairing = GetZonePairing()    -- We don't show this info for keeps not in the player's pairing, so assume this keep is in the player's pairing
                            for index, siegeInfo in ipairs( keepData.siege )
                            do
                                local stringId = StringTables.MapSystem["TOOLTIP_SIEGE_PAIR_"..pairing.."_REALM_"..keepData.realmOwner.."_TYPE_"..index]
                                if ( stringId ~= nil )
                                then
                                    if ( not isFirst )
                                    then
                                        siegeText = siegeText..L"<br>"
                                    end
                                    
                                    siegeText = siegeText..GetStringFormatFromTable( "MapSystem", stringId, { siegeInfo.current, siegeInfo.max } )
                                    
                                    if ( siegeInfo.max > 0 )
                                    then
                                        hasAnySiege = true
                                    end
                                    
                                    isFirst = false
                                end
                            end
                            
                            if ( hasAnySiege )
                            then
                                textValues[currentLabel] = L"<br>"..GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_DEPLOYED_SIEGE )
                                textColors[currentLabel] = DefaultColor.ORANGE
                                currentLabel = currentLabel + 1
                            
                                textValues[currentLabel] = siegeText
                                currentLabel = currentLabel + 1
                            end
                        end
                    
                        if ( keepData.skaven )
                        then
                            local hasAnySkaven = false
                            local isFirst = true
                            local skavenText = L""
                            for index, skavenInfo in ipairs( keepData.skaven )
                            do
                                local stringId = StringTables.MapSystem["TOOLTIP_SKAVEN_"..index]
                                if ( stringId ~= nil )
                                then
                                    if ( not isFirst )
                                    then
                                        skavenText = skavenText..L"<br>"
                                    end
                                    
                                    skavenText = skavenText..GetStringFormatFromTable( "MapSystem", stringId, { skavenInfo.current, skavenInfo.max } )
                                    
                                    if ( skavenInfo.max > 0 )
                                    then
                                        hasAnySkaven = true
                                    end
                                    
                                    isFirst = false
                                end
                            end
                            
                            if ( hasAnySkaven )
                            then
                                textValues[currentLabel] = L"<br>"..GetStringFromTable( "MapSystem", StringTables.MapSystem.TOOLTIP_CONTROLLED_SKAVEN )
                                textColors[currentLabel] = DefaultColor.ORANGE
                                currentLabel = currentLabel + 1
                            
                                textValues[currentLabel] = skavenText
                                currentLabel = currentLabel + 1
                            end
                        end
                    end
                end
                
                for textWindowIndex, textWindow in ipairs(textWindows)
                do
                    LabelSetText( textWindow, textValues[textWindowIndex] )
                    DefaultColor.SetLabelColor( textWindow, textColors[textWindowIndex] )
                    
                    local x, y = WindowGetDimensions( textWindow )
                    height = height + y
                
                    if( x > largestTextWidth ) then
                        largestTextWidth = x
                    end 
                end
                
                -- If this is a waypoint, show the quest conditions
                local condIndex = 1
                local function AddWaypointCondition(conditionName, curCounter, maxCounter)
                    local conditionWindow = "MapPointsTooltipInfo"..infoIndex.."QuestCondition"..condIndex
                    local nameLabel = conditionWindow.."Name"
                    local counterLabel = conditionWindow.."Counter"

                    LabelSetText( nameLabel, conditionName )            
                    if( maxCounter > 0 )
                    then
                        LabelSetText( counterLabel, L""..curCounter..L"/"..maxCounter )
                    else
                        LabelSetText( counterLabel, L"" )
                    end
                                
                    if( curCounter == maxCounter)
                    then
                        DefaultColor.LabelSetTextColor( counterLabel, GameDefs.CompleteCounterColor )
                    else
                        DefaultColor.LabelSetTextColor( counterLabel, GameDefs.IncompleteCounterColor )
                    end         
                                
                    local x, y = LabelGetTextDimensions( nameLabel )    
                    if( x > largestTextWidth )
                    then
                        largestTextWidth = x
                    end
                    local w, h = WindowGetDimensions( conditionWindow )
                    WindowSetDimensions( conditionWindow, w, math.max( y, h ) )
                                            
                    height = height + math.max( y, h )
                    if( WindowGetShowing(conditionWindow) == false )
                    then
                        WindowSetShowing(conditionWindow, true )
                    end    
                                                            
                    condIndex = condIndex + 1
                end
                if( questData ) 
                then  
                                
                    local condList = GetQuestPointConditions( mapDisplay, ptData.pointIndex )
                    
                    if( condList )
                    then
                        for index, condition in ipairs( condList )
                        do                            
                            
                            local conditionData = questData.conditions[condition]
                            if( conditionData == nil )
                            then
                                continue
                            end
                        
                            if ( conditionData.name ~= L"" )
                            then
                                AddWaypointCondition( conditionData.name, conditionData.curCounter, conditionData.maxCounter )
                            end
                        end
                    end
                elseif ( ptData.pointType == SystemData.MapPips.LIVE_EVENT_WAYPOINT ) then
                    local tasksData = GetLiveEventTasks( ptData.id )
                    if ( tasksData ~= nil ) then
                        local function RecursivelyFindTask( taskTable, taskIdToFind )
                            for _, task in ipairs( taskTable )
                            do
                                if type( task ) ~= "table" or ( not task.taskId ) 
                                then
                                    continue
                                end
                                
                                if ( task.taskId == taskIdToFind )
                                then
                                    return task
                                end
                                
                                local foundTask = RecursivelyFindTask( task.subtasks, taskIdToFind )
                                if ( foundTask ~= nil )
                                then
                                    return foundTask
                                end
                            end
                            
                            return nil
                        end
                        
                        local task = RecursivelyFindTask( tasksData, ptData.taskId )
                        if ( task ~= nil ) then
                            AddWaypointCondition( task.name, task.currentValue, task.maxValue )
                        end
                    end                   
                end  
                
                -- Hide unused conditions (if not a waypoint, this will be all conditions)
                for condition = condIndex, Tooltips.MAX_MAP_POINT_TOOLTIP_TEXT_LINES
                do  
                    local conditionWindow = "MapPointsTooltipInfo"..infoIndex.."QuestCondition"..condition
                    if( WindowGetShowing(conditionWindow) == true )
                    then 
                        WindowSetShowing(conditionWindow, false ) 
                    end
                end
                
                -- Show/Hide the dividing line except on the last point
                local showDivLine = false
                if( infoIndex < numPts ) then
                    local POINT_OFFSET = 5
                    height = height + POINT_OFFSET
                    showDivLine = true
                end
                               
                if( showDivLine ~= WindowGetShowing( "MapPointsTooltipInfo"..infoIndex.."DivLine" ) ) then
                    WindowSetShowing( "MapPointsTooltipInfo"..infoIndex.."DivLine", showDivLine )
                end
                
                -- Update the Window Size
                local width, y = WindowGetDimensions( "MapPointsTooltipInfo"..infoIndex )
                if( y ~= height ) then
                    WindowSetDimensions( "MapPointsTooltipInfo"..infoIndex, width, height )
                end   
                
                infoIndex = infoIndex + 1
                
                if( infoIndex > MAX_MAP_POINT_INFO ) then
                    break
                end               
            end     
        end
        
        if( infoIndex > MAX_MAP_POINT_INFO ) then
            break
        end
    end
    
    
    -- Finialize the tooltip
    local height = 20
    local COUNTER_SIZE = 60
    local TOOL_TIP_TOTAL_BORDER_PLUS_ICON_SIZE = 40 + ICON_SIZE + COUNTER_SIZE
    local DEV_LINE_ADJUSTMENT = 20

    for index = 1, MAX_MAP_POINT_INFO
    do
    
        -- Show/Hide the Info as needed
        local show = index <= numPts
        if( WindowGetShowing( "MapPointsTooltipInfo"..index ) ~= show )
        then
             WindowSetShowing( "MapPointsTooltipInfo"..index, show )
        end
    
        if( show )
        then            
            local x, y = WindowGetDimensions( "MapPointsTooltipInfo"..index ) 
            height = height + y
            
            -- DEBUG(L"  MapPointsTooltipInfo"..index..L" => ("..largestTextWidth + TOOL_TIP_TOTAL_BORDER_PLUS_ICON_SIZE..L", "..y..L")")
            WindowSetDimensions( "MapPointsTooltipInfo"..index, largestTextWidth + TOOL_TIP_TOTAL_BORDER_PLUS_ICON_SIZE, y )
            
            --Also adjust the conditions
            if( WindowGetShowing( "MapPointsTooltipInfo"..index.."Quest" ) ) then
            
                for condIndex = 1, Tooltips.MAX_MAP_POINT_TOOLTIP_TEXT_LINES
                do
                    if( WindowGetShowing( "MapPointsTooltipInfo"..index.."QuestCondition"..condIndex ) )
                    then
                        local _, y = WindowGetDimensions( "MapPointsTooltipInfo"..index.."QuestCondition"..condIndex ) 
                        -- DEBUG(L"    MapPointsTooltipInfo"..index..L"QuestCondition"..condIndex..L" => ("..largestTextWidth + ICON_SIZE..L", "..y..L")")
                        WindowSetDimensions( "MapPointsTooltipInfo"..index.."QuestCondition"..condIndex, largestTextWidth + ICON_SIZE + COUNTER_SIZE, y )
                    end
                end
                
                -- Also Set the Size of the quest data window
                local _, y = WindowGetDimensions( "MapPointsTooltipInfo"..index.."Quest" ) 
                -- DEBUG(L"  MapPointsTooltipInfo"..index..L"Quest"..L" => ("..largestTextWidth + TOOL_TIP_TOTAL_BORDER_PLUS_ICON_SIZE..L", "..y..L")")
                WindowSetDimensions( "MapPointsTooltipInfo"..index.."Quest", largestTextWidth + TOOL_TIP_TOTAL_BORDER_PLUS_ICON_SIZE, y )
            end
        end
    
    end
    
    
    -- Update the Window Size
    local width, y = WindowGetDimensions( "MapPointsTooltip" )
    if( y ~= height or width ~= largestTextWidth + TOOL_TIP_TOTAL_BORDER_PLUS_ICON_SIZE) then
        WindowSetDimensions( "MapPointsTooltip", largestTextWidth + TOOL_TIP_TOTAL_BORDER_PLUS_ICON_SIZE, height )
    end   
      

    Tooltips.CreateCustomTooltip( mapDisplay, "MapPointsTooltip" )
    Tooltips.AnchorTooltip( anchor )
        
    WindowSetAlpha("MapPointsTooltip", 1.0)
        
end

-- Macro Tooltip
function Tooltips.CreateMacroTooltip( macroData, mouseoverWindow, anchor, extraText )

    if(macroData == nil) then
        return
    end
    
    local row = 1
    local column = 1

    -- first section
    Tooltips.CreateTextOnlyTooltip( mouseoverWindow, nil )
    Tooltips.SetTooltipText( row, column, macroData.name )
    row = row + 1
    column = 1
    
    if( extraText ) then         
        Tooltips.SetTooltipActionText( extraText )
    end
    
        
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( anchor )
end


local function SetTextRtnHeight( labelName, text )
    LabelSetText( labelName, text )
    local _, y = LabelGetTextDimensions( labelName )
    return y
end

local function PairingMapSetToolTipLabels( controlledBy, zoneName, zoneTypeText, zoneRanksText, defaultControlLabelId, toolTipWindow, mouseOverWindow, anchor, clickText )
    
    if( zoneName == nil or toolTipWindow == nil)
    then
        return
    end
    
    local height = Tooltips.MAP_TOOLTIP_LABELS_SPACING 
    
    local textID = defaultControlLabelId
    local controlColor = {}
    controlColor = DefaultColor.ContestedColor
    if( controlledBy == GameData.Realm.ORDER )
    then
        textID = StringTables.Default.LABEL_ORDER_CONTROLLED
        controlColor = DefaultColor.OrderMapColor
    elseif( controlledBy == GameData.Realm.DESTRUCTION )
    then
        textID = StringTables.Default.LABEL_DESTRUCTION_CONTROLLED
        controlColor = DefaultColor.DestructionMapColor
    end
    
    -- Zone Name
    height = height + SetTextRtnHeight( toolTipWindow.."LabelsTitle", zoneName )
    
    -- Zone Type
    height = height + SetTextRtnHeight( toolTipWindow.."LabelsZoneType", zoneTypeText )    
    
    -- Click Text
    if( not clickText )
    then
        clickText = GetString( StringTables.Default.LABEL_CLICK_FOR_ZONE_MAP )
    end
    height = height + SetTextRtnHeight( toolTipWindow.."LabelsClick", clickText  )
    
    -- Recommended Ranks
    height = height + SetTextRtnHeight( toolTipWindow.."LabelsRanks", zoneRanksText )
    
    -- Zone Control Status
    if (controlledBy == nil)
    then
        height = height + SetTextRtnHeight( toolTipWindow.."LabelsStatus", L"" )
    else
        height = height + SetTextRtnHeight( toolTipWindow.."LabelsStatus", GetString( textID ) )
        LabelSetTextColor( toolTipWindow.."LabelsStatus", controlColor.r, controlColor.g, controlColor.b )
    end

    x, _ = WindowGetDimensions( toolTipWindow.."Labels" )
    WindowSetDimensions( toolTipWindow.."Labels", x, height )

    Tooltips.CreateCustomTooltip( mouseOverWindow, toolTipWindow )
    Tooltips.AnchorTooltip( anchor )

    return height
end

function Tooltips.CreatePairingMapTierToolTip( tierText, ranksText, mouseOverWindow, anchor )
    local height = PairingMapSetToolTipLabels( nil, tierText, L"", ranksText, nil, "PairingMapTierToolTip", mouseOverWindow, anchor, L"" )
    
    local width, _ = WindowGetDimensions( "PairingMapTierToolTip" )
    WindowSetDimensions( "PairingMapTierToolTip", width, height + Tooltips.MAP_TOOLTIP_VERTICAL_BORDER )
end

function Tooltips.CreatePairingMapTravelToolTip( controlledBy, zoneName, zoneTier, zoneRanksText, extraText, extraText2, mouseOverWindow, anchor, clickText, cost )
    if( controlledBy == nil )
    then
        return
    end
    
    local defaultControlLabelId = StringTables.Default.LABEL_UNCONTROLLED
    if( zoneTier == 4 )
    then
        if( controlledBy == GameData.Realm.NONE )
        then
            defaultControlLabelId = StringTables.Default.LABEL_CONTESTED
        end
    end
    
    if( not clickText )
    then
        clickText = GetString(StringTables.Default.TOOLTIP_TRAVEL_WINDOW_CLICK_TO_TRAVEL_HERE )
    end
    
    local height = PairingMapSetToolTipLabels( controlledBy, zoneName, L"", zoneRanksText, defaultControlLabelId, "PairingMapTravelToolTip", mouseOverWindow, anchor, clickText )

    -- Extra Text
    if( cost ~= 0 )
    then
        extraText = GetString( StringTables.Default.TOOLTIP_TRAVEL_WINDOW_COST )
    elseif( extraText == nil )
    then
        extraText = L""
    end
    height = height + SetTextRtnHeight( "PairingMapTravelToolTipText", extraText )
    
    if( extraText2 == nil )
    then
        extraText2 = L""
    end
    height = height + SetTextRtnHeight( "PairingMapTravelToolTipText2", extraText2 )
        
    MoneyFrame.FormatMoney( "PairingMapTravelToolTipMoney", cost, MoneyFrame.HIDE_EMPTY_WINDOWS )
    
    if ((extraText ~= L"") or (cost > 0) or (extraText2 ~= L"")) then
        height = height + 10    -- 10 is the anchor offset between the labels window and extraText, and needs to be accounted for if extraText or anything below it is visible
    end
    
    if ((cost > 0) or (extraText2 ~= L"")) then
        height = height + 10    -- 10 is the anchor offset between extraText and the money frame, and needs to be accounted for if the money frame or anything below it is visible
    end
            
    local _, y = WindowGetDimensions( "PairingMapTravelToolTipMoney" )
    height = height + y
    
    x, _ = WindowGetDimensions( "PairingMapTravelToolTip" )
    WindowSetDimensions( "PairingMapTravelToolTip", x, height + Tooltips.MAP_TOOLTIP_VERTICAL_BORDER )
end

function Tooltips.CreatePairingMapZoneTooltip( controlledBy, zoneName, zoneTier, zoneRanksText, mouseOverWindow, anchor, clickText )
    if( controlledBy == nil or zoneTier == nil )
    then
        return
    end
    
    local showLocks = false
    local defaultControlLabelId = StringTables.Default.LABEL_UNCONTROLLED
    if( zoneTier == 4 )
    then
        if( controlledBy == GameData.Realm.NONE )
        then
            defaultControlLabelId = StringTables.Default.LABEL_CONTESTED
        else
            showLocks = true
        end
    end
    
    WindowSetShowing( "PairingMapZoneToolTipRightLock", showLocks )
    WindowSetShowing( "PairingMapZoneToolTipLeftLock", showLocks )
    local zoneNameLocalized = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.LABEL_WORLDMAP_TOOLTIP_ZONE_NAME, {zoneName} )
    local height = PairingMapSetToolTipLabels( controlledBy, zoneNameLocalized, L"", zoneRanksText, defaultControlLabelId, "PairingMapZoneToolTip", mouseOverWindow, anchor, clickText )
    
    local width, _ = WindowGetDimensions( "PairingMapZoneToolTip" )
    WindowSetDimensions( "PairingMapZoneToolTip", width, height + Tooltips.MAP_TOOLTIP_VERTICAL_BORDER )
end

function Tooltips.CreatePairingMapFortTooltip( pairingId, realmId, controlledBy, zoneName, zoneRanksText, timeLeft, mouseOverWindow, anchor, clickText )
    
    if( controlledBy == nil )
    then
        return
    end
    
    -- Build the (<RACE> Fortress) text
    local racialName = StringUtils.GetRaceNameAdjectiveFromPairingAndRealm( pairingId, realmId, false )
    local zoneTypeText = L""-- GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TEXT_RACE_X_FORTRESS, { racialName } )                
    local zoneNameLocalized = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.LABEL_WORLDMAP_TOOLTIP_FORT_NAME, {zoneName} )
    local height = PairingMapSetToolTipLabels( controlledBy, zoneNameLocalized, zoneTypeText, zoneRanksText, StringTables.Default.LABEL_CONTESTED, "PairingMapFortToolTip", mouseOverWindow, anchor, clickText  )
    
    local timeLeftText = L""
    if (timeLeft > 0) then
        if (controlledBy == GameData.Realm.NONE) then
            timeLeftText = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TEXT_FORTRESS_TIME_REMAINING_ASSAULT, { TimeUtils.FormatClock(timeLeft) } )
        else
            timeLeftText = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TEXT_FORTRESS_TIME_REMAINING_RESET, { TimeUtils.FormatClock(timeLeft) } )
        end
    end
    height = height + SetTextRtnHeight( "PairingMapFortToolTipTimeLeft", timeLeftText )
    
    local showLocks = (controlledBy ~= GameData.Realm.NONE)
    WindowSetShowing( "PairingMapFortToolTipRightLock", showLocks )
    WindowSetShowing( "PairingMapFortToolTipLeftLock", showLocks )
    
    local width, _ = WindowGetDimensions( "PairingMapFortToolTip" )
    WindowSetDimensions( "PairingMapFortToolTip", width, height + Tooltips.MAP_TOOLTIP_VERTICAL_BORDER )    
end


function Tooltips.CreatePairingMapCityTooltip( controlledBy, zoneName, zoneRanksText, ratingTimer, timeLeft, cityState, cityId, mouseOverWindow, anchor, clickText )

    if( controlledBy == nil )
    then
        return
    end

    -- Build the (<REALM> City) text
    local realmName = L""
    if( cityId == GameData.CityId.EMPIRE or cityId == GameData.CityId.DWARF )
    then
        realmName = GetRealmName( GameData.Realm.ORDER )
    
    elseif( cityId == GameData.CityId.CHAOS or cityId == GameData.CityId.GREENSKIN )
    then
        realmName = GetRealmName( GameData.Realm.DESTRUCTION )
    end
    local zoneTypeText =  GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TEXT_REALM_X_CITY, { realmName } )                
    local zoneNameLocalized = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.LABEL_WORLDMAP_TOOLTIP_CITY_NAME, {zoneName} )
    local height = PairingMapSetToolTipLabels( controlledBy, zoneNameLocalized, zoneTypeText, zoneRanksText, StringTables.Default.LABEL_CONTESTED, "PairingMapCityToolTip", mouseOverWindow, anchor, clickText  )
    
    local timeLeftText = L""
    if (cityState ~= SystemData.CityStates.NONE and cityState ~= SystemData.CityStates.SAFE and timeLeft > 0) then
        timeLeftText = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TEXT_CITY_TIME_REMAINING, { TimeUtils.FormatClock(timeLeft) } )
    end
    height = height + SetTextRtnHeight( "PairingMapCityToolTipTimeLeft", timeLeftText )
        
    -- City Rating
    MapUtils.UpdateCityRatingWindow( cityId, "PairingMapCityToolTipCityRating" )
    local cityRating = GetCityRatingForCityId( cityId )
    height = height + Tooltips.CITY_RATING_OFFSET

    -- Add all of the City Activities
    local itemsText = MapUtils.GetCityActivityStrings( cityId, cityState, cityRating )
    for index = 1, Tooltips.MAX_CITY_ACTIVITES
    do
        height = height + Tooltips.SetCityActivityText( "PairingMapCityToolTipActivity"..index, itemsText[index] )
    end
    
    -- Determine Rating Text
    local ratingDescText = L""
    local descStringId = StringTables.RvRCity[ "CITY_"..cityId.."_RATING_"..cityRating.."_DESC" ]
    if( descStringId ~= nil )
    then
        ratingDescText = GetStringFromTable( "RvRCityStrings", descStringId )
    end                                           
    height = height + SetTextRtnHeight("PairingMapCityToolTipRatingDesc", ratingDescText )
    
    local ratingTimeLeftText = L""
    if ((cityState == SystemData.CityStates.SHUTDOWN or cityState == SystemData.CityStates.SAFE) and ratingTimer > 0) then
        ratingTimeLeftText = GetStringFormatFromTable("MapSystem", StringTables.MapSystem.TEXT_CITY_RATING_TIME_REMAINING, { TimeUtils.FormatClock(ratingTimer) } )
    end
    height = height + SetTextRtnHeight( "PairingMapCityToolTipRatingTimer", ratingTimeLeftText )

    local width, _ = WindowGetDimensions( "PairingMapCityToolTip" )
    WindowSetDimensions( "PairingMapCityToolTip", width, height + Tooltips.MAP_TOOLTIP_VERTICAL_BORDER )
    
    -- Need to reanchor tooltip since we've adjusted size. Fixes an issue where it gets cut off at bottom of screen.
    Tooltips.AnchorTooltip( anchor )
    
end

function Tooltips.SetCityActivityText( activityWindow, text )
    if( text == nil or text == L"" )
    then
        local width, _ = WindowGetDimensions( activityWindow )
        WindowSetDimensions( activityWindow, width, 0 )
        WindowSetShowing( activityWindow, false )
        
        return 0
    end     

    LabelSetText( activityWindow.."Text", text )   
    local _, height = WindowGetDimensions( activityWindow.."Text" )
    
    height = height + Tooltips.CITY_ACTIVITY_SPACING
    
    local width, _ = WindowGetDimensions( activityWindow )
    WindowSetDimensions( activityWindow, width, height )
    
    WindowSetShowing( activityWindow, true )
    
    return height 
end

-- Generic On Mouse Over Map Points handler
function Tooltips.OnMouseOverMapPoint()

    -- Get a reference to the points array
    local pointsArray = _G[ SystemData.ActiveWindow.name ].MouseoverPoints

    Tooltips.CreateMapPointTooltip( SystemData.ActiveWindow.name, 
                                    pointsArray, 
                                    Tooltips.ANCHOR_CURSOR,
                                    Tooltips.MAP_TYPE_OTHER )   
end

function HasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end
