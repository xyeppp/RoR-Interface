RoR_MatchMakingRaiting = {}
local version = "0.1"
local PlayerName = wstring.sub( GameData.Player.name,1,-3 )

function RoR_MatchMakingRaiting.OnInitialize()
RegisterEventHandler(TextLogGetUpdateEventId("Chat"), "RoR_MatchMakingRaiting.OnChatLogUpdated")
TextLogAddEntry("Chat", 0, L"<icon00057> RoR_MatchMakingRaiting "..towstring(version)..L" Loaded.")
PlayerName = wstring.sub( GameData.Player.name,1,-3 )
RegisterEventHandler( SystemData.Events.ENTER_WORLD, "RoR_MatchMakingRaiting.Enable" )
RegisterEventHandler( SystemData.Events.INTERFACE_RELOADED, "RoR_MatchMakingRaiting.Enable" )
end

function RoR_MatchMakingRaiting.Enable()
SendChatText(L"]mmrenable", ChatSettings.Channels[0].serverCmd)
end

function RoR_MatchMakingRaiting.OnChatLogUpdated(updateType, filterType)
		if( updateType == SystemData.TextLogUpdate.ADDED ) then 			
			if filterType == SystemData.ChatLogFilters.CHANNEL_9 then	
				local _, filterId, text = TextLogGetEntry( "Chat", TextLogGetNumEntries("Chat") - 1 ) 
				
				if text:find(L"MMR_Char") then
				RoR_MatchMakingRaiting.Text_Stream_Fetch(text)
				end
			end
		end
end

function RoR_MatchMakingRaiting.Text_Stream_Fetch(text)
local text = towstring(text)
local MMR_SPLIT_TEXT = StringSplit(tostring(text), ":")
local CHAR_NAME = MMR_SPLIT_TEXT[2]
local MMR_SCR = tonumber(MMR_SPLIT_TEXT[3])
local MMR_PREMADE = tonumber(MMR_SPLIT_TEXT[4])
local MMR_SOLO = tonumber(MMR_SPLIT_TEXT[5]) 

RoR_MatchMakingRaiting[tostring(CHAR_NAME)] = {MMR_SCR,MMR_PREMADE,MMR_SOLO}

if tostring(PlayerName) == tostring(CHAR_NAME) then
	local id1 = WindowGetId( "TomeWindowTitlePageStatSoloMMR" )
	local id2 = WindowGetId( "TomeWindowTitlePageStatPremadeMMR" ) 
	
	TomeWindow.SetTOCItemText( "TomeWindowTitlePageStatSoloMMR", id1, L"MMR Solo",towstring(RoR_MatchMakingRaiting[tostring(CHAR_NAME)][3]))
    TomeWindow.SetTOCItemText( "TomeWindowTitlePageStatPremadeMMR", id2, L"MMR Premade", towstring(RoR_MatchMakingRaiting[tostring(CHAR_NAME)][2]))
end


end

function RoR_MatchMakingRaiting.UpdateMMR(name)
local Char = tostring(RoR_MatchMakingRaiting.FixString(name))
if (GameData.Player.isInScenario or GameData.Player.isInSiege) then 
--if GameData.Player.zone ~= 237 then return -2 end
if RoR_MatchMakingRaiting[Char] == nil then return -1 end
	return RoR_MatchMakingRaiting[Char][3]	
	end
end


--zone id 237
function RoR_MatchMakingRaiting.FixString (str)
	if (str == nil) then return nil end
	local str = str
	local pos = str:find (L"^", 1, true)
	if (pos) then str = str:sub (1, pos - 1) end	
	return str
end
