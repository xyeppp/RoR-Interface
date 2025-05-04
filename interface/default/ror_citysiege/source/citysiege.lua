RoR_CitySiege = {}
RoR_CitySiege.Data = {}

function RoR_CitySiege.OnInitialize()
	ror_PacketHandling.Register("RoRCity",RoR_CitySiege.Text_Stream_Fetch)
end

function RoR_CitySiege.Text_Stream_Fetch(text)
local text = string.gsub(text,"RoRCity:","")
local CityTable = json.decode(text)

	local CITY_ID = tonumber(CityTable.cityId)
	local CITY_RATING_TIMER = tonumber(CityTable.nextRatingUp)
	local CITY_SIEGE_TIMER = tonumber(CityTable.timeLeft)
	local CITY_INSTANCES = tonumber(CityTable.instanceCount)
	local CITY_ORDER_WON = tonumber(CityTable.orderWins) 
	local CITY_DESTRO_WON = tonumber(CityTable.destroWins) 
	local CITY_STATE = tonumber(CityTable.cityState) 
	local CITY_INITIAL_REALM = tonumber(CityTable.cityRealm)
	local CITY_CONTROLLING_REALM = tonumber(CityTable.controllingRealm)
	local CITY_PAIRING = tonumber(CityTable.pairing)

	RoR_CitySiege.Data[CITY_ID] = { cityId=CITY_ID, ratingTimer=CITY_RATING_TIMER, timeLeft=CITY_SIEGE_TIMER, instanceCount=CITY_INSTANCES, orderWins=CITY_ORDER_WON, destroWins=CITY_DESTRO_WON, state=CITY_STATE, initialRealm=CITY_INITIAL_REALM, controllingRealm=CITY_CONTROLLING_REALM, pairingId=CITY_PAIRING }

    BroadcastEvent( SystemData.Events.CITY_SCENARIO_UPDATE_TIME )
end

function RoR_CitySiege.GetCity( cityId )
	return RoR_CitySiege.Data[ cityId ]
end

function RoR_CitySiege.GetCityFromPairing()
	if GameData.Player.realm ~= nil and GetZonePairing() ~= nil then
		return ((GetZonePairing() - 1) * 2) + GameData.Player.realm
	end
end


function RoR_CitySiege.Update( timePassed )
    for index, citySiegeData in pairs( RoR_CitySiege.Data ) do
        if( citySiegeData.ratingTimer ~= 0  ) then
			
            citySiegeData.ratingTimer = citySiegeData.ratingTimer - timePassed 
            if( citySiegeData.ratingTimer < 0 ) then
                citySiegeData.ratingTimer = 0
            end
        end     
             
        if( citySiegeData.timeLeft ~= 0  ) then
			
            citySiegeData.timeLeft = citySiegeData.timeLeft - timePassed 
            if( citySiegeData.timeLeft < 0 ) then
                citySiegeData.timeLeft = 0
            end
        end 		
    end
end