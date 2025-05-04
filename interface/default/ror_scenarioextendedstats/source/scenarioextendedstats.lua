RoR_ScenarioExtendedStats = {}
local version = "0.1"

function RoR_ScenarioExtendedStats.OnInitialize()
	RegisterEventHandler(TextLogGetUpdateEventId("Chat"), "RoR_ScenarioExtendedStats.OnChatLogUpdated")
end

function RoR_ScenarioExtendedStats.OnChatLogUpdated(updateType, filterType)
	if updateType ~= SystemData.TextLogUpdate.ADDED then return end
	if filterType ~= SystemData.ChatLogFilters.CHANNEL_9 then return end

	local _, filterId, text = TextLogGetEntry( "Chat", TextLogGetNumEntries("Chat") - 1 )

	if text:sub(1, 9) == L"SC_STATS=" then
		RoR_ScenarioExtendedStats.playersDataString = text
		RoR_ScenarioExtendedStats.playersData = nil
	end
end

-- The format is: SC_STATS=<charid>:<stat1value>;<stat2value>;<stat3value>;<stat4value>|<charid>:<stat1value>;<stat2value>;<stat3value>;<stat4value>
function RoR_ScenarioExtendedStats.UpdatePlayerData()
	RoR_ScenarioExtendedStats.playersData = {}

	if RoR_ScenarioExtendedStats.playersDataString == nil then return end

	local statsText = RoR_ScenarioExtendedStats.playersDataString:sub(10) -- remove the SC_STATS= prefix
	local PlayerSplitText = WStringSplit(statsText, L"|")
	for charId,v in pairs(PlayerSplitText) do
		local CharSplitText = WStringSplit(v, L":")
		RoR_ScenarioExtendedStats.playersData[CharSplitText[1]] = WStringSplit(CharSplitText[2], L";")
	end
end