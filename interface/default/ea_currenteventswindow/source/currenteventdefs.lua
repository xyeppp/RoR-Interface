
CurrentEvents = {}

-- Local Functions
local function GetOrMakeZoneName( zoneId )
    
    local zoneName = GetZoneName( zoneId )
    if( zoneName ~= L"" ) 
    then
        return zoneName
    end
    
    -- Otherwise create the string
    return L"Zone #"..zoneId

end


local function GetValidStringIds( stringBase )
    local values = {}
    
    local index = 1
    local stringId = StringTables.CurrentEvents[ stringBase..index ]
    while( stringId )
    do
        table.insert( values, stringId )
    
        index = index + 1
        stringId = StringTables.CurrentEvents[ stringBase..index ]
    end

    return values
end

-- Display Data Each Subtype
CurrentEvents.SubTypes = 
{
    ---------------------------------------------------------------------------------------------------------------------------------
    -- Test Events
    [ SystemData.CurrentEventSubType.TEST ] = 
        { 
          nameStringIds=GetValidStringIds( "SUBTYPE_NAME_TEST" ),
          descStringIds=GetValidStringIds( "SUBTYPE_DESC_TEST" ),
          rvrPriority = 10,
          pvePriority = 10,
          iconSlice = "WarReport-OpenParty",
          GetName = function( eventData )
                        return GetStringFromTable( "CurrentEventsStrings", eventData.nameStringId )
                    end,

          GetText = function( eventData )
                        local zoneName = GetOrMakeZoneName( eventData.zone )
                        return GetStringFormatFromTable( "CurrentEventsStrings", eventData.descStringId, { zoneName } )
                    end,
         
        },
                                            
    ---------------------------------------------------------------------------------------------------------------------------------
    -- PQ Events                                         
    [ SystemData.CurrentEventSubType.PQ ] = 
        {              
          nameStringIds=GetValidStringIds( "SUBTYPE_NAME_PQ" ),
          descStringIds=GetValidStringIds( "SUBTYPE_DESC_PQ" ),
          rvrPriority = 6,
          pvePriority = 1,
          iconSlice = "WarReport-ActivePQ",
          GetName = function( eventData )
                        return GetStringFromTable( "CurrentEventsStrings", eventData.nameStringId )
                    end,
                
          GetText = function( eventData )
                        local objectiveName = GetObjectiveName( eventData.subTypeId )
                        if( objectiveName == L"" )
                        then
                            objectiveName = L"PQ Objective #"..eventData.subTypeId
                        end
                        
                        local zoneName = GetOrMakeZoneName( eventData.zone )
                        return GetStringFormatFromTable( "CurrentEventsStrings", eventData.descStringId, { objectiveName, zoneName } )
                    end,
        },   
                  
    ---------------------------------------------------------------------------------------------------------------------------------
    -- Battlefield Objective Events                                     
    [ SystemData.CurrentEventSubType.BATTLEFIELD_OBJECTIVE ] = 
        {           
          nameStringIds=GetValidStringIds( "SUBTYPE_NAME_BO" ),
          descStringIds=GetValidStringIds( "SUBTYPE_DESC_BO" ),          
          rvrPriority = 4,
          pvePriority = 5,
          iconSlice = "WarReport-BOHotspot",
          GetName = function( eventData )
                        return GetStringFromTable( "CurrentEventsStrings", eventData.nameStringId )
                    end,
          
          GetText = function( eventData )
                        local objectiveName = GetObjectiveName( eventData.subTypeId )                                                                                                                        
                        if( objectiveName == L"" )
                        then
                            objectiveName = L"Battlefield Objective #"..eventData.subTypeId
                        end
                        
                        local zoneName = GetOrMakeZoneName( eventData.zone )
                        return GetStringFormatFromTable( "CurrentEventsStrings", eventData.descStringId, { objectiveName, zoneName } )
                    end,
        },                   

    ---------------------------------------------------------------------------------------------------------------------------------
    -- Hotspot Events                                  
    [ SystemData.CurrentEventSubType.HOTSPOT ] = 
        { 
            nameStringIds=GetValidStringIds( "SUBTYPE_NAME_HOTSPOT" ),
            descStringIds=GetValidStringIds( "SUBTYPE_DESC_HOTSPOT" ),      
            rvrPriority = 5,
            pvePriority = 6,
            iconSlice = "WarReport-RVRHotspot",
            GetName =   function( eventData )                        
                            return GetStringFromTable( "CurrentEventsStrings", eventData.nameStringId )
                        end,
                             
            GetText =   function( eventData )
                            local zoneName = GetOrMakeZoneName( eventData.zone )
                            return GetStringFormatFromTable( "CurrentEventsStrings", eventData.descStringId, { zoneName } )            
                        end,
        },                   


    ---------------------------------------------------------------------------------------------------------------------------------
    -- Keep Attack Events                                                                           
    [ SystemData.CurrentEventSubType.KEEP_ATTACK ] = 
        { 
            nameStringIds=GetValidStringIds( "SUBTYPE_NAME_KEEP_ATTACK" ),
            descStringIds=GetValidStringIds( "SUBTYPE_DESC_KEEP_ATTACK" ),      
            rvrPriority = 2,
            pvePriority = 3,
            iconSlice = "WarReport-KeepATTACKS",
            GetName =   function( eventData )                        
                            return GetStringFromTable( "CurrentEventsStrings", eventData.nameStringId )
                        end,
          
            GetText =   function( eventData )
                            local keepName = GetKeepName( eventData.subTypeId )
                            if( keepName == L"" )
                            then
                                keepName = L"Keep #"..eventData.subTypeId
                            end
                        
                            local zoneName = GetOrMakeZoneName( eventData.zone )
                            return GetStringFormatFromTable( "CurrentEventsStrings", eventData.descStringId, { keepName, zoneName } )                    
                        end,
        },                  

    ---------------------------------------------------------------------------------------------------------------------------------
    -- Keep Claim Events                                                                                   
    [ SystemData.CurrentEventSubType.KEEP_CLAIM ] = 
        { 
            nameStringIds=GetValidStringIds( "SUBTYPE_NAME_KEEP_CLAIM" ),
            descStringIds=GetValidStringIds( "SUBTYPE_DESC_KEEP_CLAIM" ),   
            rvrPriority = 3,
            pvePriority = 4,
            iconSlice = "WarReport-OpenParty",
            GetName =   function( eventData )                        
                            return GetStringFromTable( "CurrentEventsStrings", eventData.nameStringId )
                        end,
                    
            GetText =    function( eventData )
                            local keepName = GetKeepName( eventData.subTypeId )
                            if( keepName == L"" )
                            then
                                keepName = L"Keep #"..eventData.subTypeId
                            end
                        
                            local zoneName = GetOrMakeZoneName( eventData.zone )
                            return GetStringFormatFromTable( "CurrentEventsStrings", eventData.descStringId, { keepName, zoneName } )                    
                         end,
        },                   


    ---------------------------------------------------------------------------------------------------------------------------------
    -- City Events                                                          
    [ SystemData.CurrentEventSubType.CITY ] =
        {
            nameStringIds=GetValidStringIds( "SUBTYPE_NAME_CITY" ),
            descStringIds=GetValidStringIds( "SUBTYPE_DESC_CITY" ), 
            rvrPriority = 1,
            pvePriority = 2,
            iconSlice = "WarReport-CityATTACKS",
            GetName =   function( eventData )       
                            return GetStringFromTable( "CurrentEventsStrings", eventData.nameStringId )
                        end,
                    
            GetText =   function( eventData )
                            local cityName = GetCityName( eventData.subTypeId )
                            if( cityName == L"" )
                            then
                                cityName = L"City #"..eventData.subTypeId
                            end
                                                                                   
                            return GetStringFormatFromTable( "CurrentEventsStrings", eventData.descStringId, { cityName } )                    
                        end,
        },                   

    ---------------------------------------------------------------------------------------------------------------------------------
    -- Zone Pouplation Events      
    [ SystemData.CurrentEventSubType.ZONE_POPULATION ] = 
        { 
            nameStringIds=GetValidStringIds( "SUBTYPE_NAME_ZONE_POP" ),
            descStringIds=GetValidStringIds( "SUBTYPE_DESC_ZONE_POP" ), 
            rvrPriority = 8,
            pvePriority = 8,
            iconSlice = "WarReport-MostPopulatedZone",
            GetName =   function( eventData )          
                            return GetStringFromTable( "CurrentEventsStrings", eventData.nameStringId )
                        end,
                           
            GetText =   function( eventData )
                            local zoneName = GetOrMakeZoneName( eventData.zone )
                            return GetStringFormatFromTable( "CurrentEventsStrings", eventData.descStringId, { zoneName } )        
                        end,
            },                   
            
    ---------------------------------------------------------------------------------------------------------------------------------
    -- Content Events      
    [ SystemData.CurrentEventSubType.CONTENT_ACTION ] = 
        { 
            nameStringIds={1},  -- Dummy arrays. The actual string IDs come from a separate Content Current Event string table.
            descStringIds={1},
            rvrPriority = 9,
            pvePriority = 9,
            iconSlice = "WarReport-OpenParty",
            GetName =   function( eventData )          
                            return GetStringFromTable( "ContentCurrentEventNames", eventData.subTypeId )
                        end,
                           
            GetText =   function( eventData )
                            return GetStringFromTable( "ContentCurrentEventDescs", eventData.subTypeId )        
                        end,
            },                   
            
    ---------------------------------------------------------------------------------------------------------------------------------
    -- RvR Lake Population Events      
    [ SystemData.CurrentEventSubType.RVR_LAKE_POPULATION ] = 
        { 
            nameStringIds=GetValidStringIds( "SUBTYPE_NAME_RVRLAKE_POP" ),
            descStringIds=GetValidStringIds( "SUBTYPE_DESC_RVRLAKE_POP" ), 
            rvrPriority = 7,
            pvePriority = 7,
            iconSlice = "WarReport-MostPopulatedRVR",
            GetName =   function( eventData )          
                            return GetStringFromTable( "CurrentEventsStrings", eventData.nameStringId )
                        end,
                           
            GetText =   function( eventData )
                            local zoneName = GetOrMakeZoneName( eventData.zone )
                            return GetStringFormatFromTable( "CurrentEventsStrings", eventData.descStringId, { zoneName } )        
                        end,
            },                   


}
