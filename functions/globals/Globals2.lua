---
-- @desc Gets the name of ability/macro/item on the hotbar slot.
-- @param slotId number The slot ID of the hotbar.
-- @return string The name of ability/macro/item on the hotbar slot.
function GetHotbarName(slotId)   end
---
-- @param physicalPage number The physical hotbar page.
-- @return number The logical hotbar page.
-- @desc Gets the logical hotbar page for a given physical page.
function GetHotbarPage(physicalPage)   end
---
-- @return table
-- @desc Gets the list of ignored players.
function GetIgnoreList()   end
---
-- @param influenceId number
-- @return table
-- @desc Gets influence data for a given influence ID.
function GetInfluenceData(influenceId)   end
---
-- @return string
-- @desc Gets a string representing the current input language.
function GetInputLanguageString()   end
---
-- @return table
-- @desc Gets data related to inspection bragging rights.
function GetInspectionBragData()   end
---
-- @return table
-- @desc Gets data related to inspected equipment.
function GetInspectionData()   end
---
-- @return table
-- @desc Gets data for inventory items.
function GetInventoryItemData()   end
---
-- @desc Gets the stack count for an inventory slot. (Usage not found for documentation)
function GetInventorySlotStackCount()   end
---
-- @param itemType number|string The type or ID of the item.
-- @return number The stack count of the item.
-- @desc Gets the stack count of a specific item.
function GetItemStackCount(itemType)   end
---
-- @param keepId number
-- @return table
-- @desc Gets data for a specific keep.
function GetKeepData(keepId)   end
---
-- @param keepId number
-- @return string
-- @desc Gets the name of a keep for a given keep ID.
function GetKeepName(keepId)   end
---
-- @param upgradeId number
-- @return string
-- @desc Gets the description of a keep upgrade for a given upgrade ID.
function GetKeepUpgradeDesc(upgradeId)   end
---
-- @param upgradeId number
-- @return string
-- @desc Gets the name of a keep upgrade for a given upgrade ID.
function GetKeepUpgradeName(upgradeId)   end
---
-- @param eventId number
-- @return table
-- @desc Gets data for a live event for a given event ID.
function GetLiveEventData(eventId)   end
---
-- @return table
-- @desc Gets a list of active live events.
function GetLiveEventList()   end
---
-- @param eventId number
-- @return table
-- @desc Gets a list of tasks for a given live event ID.
function GetLiveEventTasks(eventId)   end
---
-- @return table The locations for trophies.
-- @desc Gets locations for trophies. 
function GetLocationsForTrophies()   end
---
-- @return table
-- @desc Gets data for active loot rolls.
function GetLootRollData()   end
---
-- @return table
-- @desc Gets data for user-defined macros.
function GetMacrosData()   end
---
-- Returns a string from the Mail string table.
-- @param stringId string The ID or key of the string to retrieve.
-- @return string The retrieved string.
function GetMailString(stringId)   end
---
-- @param mapDisplay table|object Data or object representing the map display.
-- @param pointIndex number The index or ID of the map point.
-- @return table Data for the specified map point.
-- @desc Gets data for a specific map point.
function GetMapPointData(mapDisplay, pointIndex)   end
---
-- @param mapDisplay table|object Data or object representing the map display.
-- @return table Data for map text points on the specified map.
-- @desc Gets data for map text points.
function GetMapTextPoints(mapDisplay)   end
---
-- @desc Gets the name of a month. (Usage not found for documentation)
-- @param monthNumber number The number of the month you want the name for.
-- @param isShorthandle boolean  True for shorthandle ("Jan"), false or nil for full name ("January")
-- @return string The name of the month.
function GetMonthName(monthNumber, isShorthandle)   end
---
-- @param moraleLevel number The morale level.
-- @return any The first returned value (unknown).
-- @return number The ability ID associated with the morale level.
-- @desc Gets data for the morale bar, including an ability ID for a given morale level.
function GetMoraleBarData(moraleLevel)   end
---
-- @param moraleLevel number The morale level.
-- @return number The current morale cooldown.
-- @return number The maximum morale cooldown.
-- @desc Gets the current and maximum cooldown for a given morale level.
function GetMoraleCooldown(moraleLevel)   end
---
-- @param moraleLevel number The morale level.
-- @return number The percentage for the given morale level.
-- @desc Gets the percentage value associated with a given morale level.
function GetMoralePercentForLevel(moraleLevel)   end
---
-- @param object table|object|number|string The object or its ID.
-- @return string The name of the object.
-- @desc Gets the name for a given object or its ID.
function GetNameForObject(object)   end
---
-- @return boolean True if it's a newbie guild, false otherwise.
-- @desc Gets a flag indicating if the current guild is a newbie guild.
function GetNewbieGuildFlag()   end
---
-- @desc Gets the number of assigned bearers. (Usage not found for documentation)
function GetNumAssignedBearers()   end
---
-- @return number The number of brass coins equivalent to one gold coin.
-- @desc Gets the number of brass coins equivalent to one gold coin.
function GetNumBrassPerGold()   end 
---
-- @desc Gets the number of brass coins equivalent to one silver coin.
-- @return number The number of brass coins per silver.
---
-- @desc Gets the number of brass coins equivalent to one silver coin.
-- @return number The number of brass coins per silver.
function GetNumBrassPerSilver()   end
---
-- @desc Gets the number of players currently in the player's group.
-- @return number The number of groupmates.
---
-- @desc Gets the number of players currently in the player's group.
-- @return number The number of groupmates.
function GetNumGroupmates()   end
---
-- @desc Gets the number of available tactic slots for the player.
-- @return table A table containing the number of slots for different tactic types.
---
-- @desc Gets the number of available tactic slots for the player.
-- @return table A table containing the number of slots for different tactic types.
function GetNumTacticsSlots()   end
---
-- @desc Gets the name of a specific objective.
-- @param id number The ID of the objective.
-- @return string The name of the objective.
---
-- @desc Gets the name of a specific objective.
-- @param id number The ID of the objective.
-- @return string The name of the objective.
function GetObjectiveName(id)   end
---
-- @desc Gets the full list of nearby open parties.
-- @return table A list of open party data tables.
---
-- @desc Gets the full list of nearby open parties.
-- @return table A list of open party data tables.
function GetOpenPartyFullList()   end
---
-- @desc Gets the list of notifications related to open parties.
-- @return table A list of open party notification data tables.
function GetOpenPartyNotificationList()   end
---
-- @desc Gets the list of open parties across the world/server.
-- @return table A list of world open party data tables.
function GetOpenPartyWorldList()   end
---
-- @desc Gets data about the item currently in the inventory overflow slot.
-- @return table|nil itemData The data for the overflow item, or nil if none.
-- @return number|nil count The stack count of the overflow item, or nil if none.
function GetOverflowData()   end
---
-- @desc Gets the current zoom level of the overhead map.
-- @return number The current zoom level.
function GetOverheadMapZoomLevel()   end
---
-- @desc Gets data about the winners of the most recent Public Quest loot roll.
-- @return table|nil A table containing data about the PQ loot winners, or nil.
function GetPQLootWinners()   end
---
-- @desc Gets data about the top contributors to the most recent Public Quest.
-- @return table|nil A table containing data about the PQ top contributors, or nil.
function GetPQTopContributors()   end
---
-- @desc Gets the player's current energy or primary resource amount. (Usage not found for documentation)
-- @return number The player's current energy.
function GetPlayerEnergy()   end
---
-- @desc Gets the player's current morale level.
-- @return number The player's morale level (0-4).
function GetPlayerMoraleLevel()   end
---
-- @desc Gets player variation data. (Usage not found for documentation)
-- @return number|string Unknown player variation data.
function GetPlayerVariation()   end
---
-- @desc Gets a localized string from the pre-game string table.
-- @param stringId number The ID of the string in StringTables.Pregame.
-- @return string The localized string.
function GetPregameString(stringId)   end
---
-- @desc Gets a formatted localized string from the pre-game string table. (Usage not found for documentation)
-- @param stringId number The ID of the string in StringTables.Pregame.
-- @param ... any Format arguments.
-- @return string The formatted localized string.
function GetPregameStringFormat(stringId, ...)   end
---
-- @desc Gets data for all active quests the player has. Also used internally to get data for a specific quest ID.
-- @param questId number|nil (Optional) The ID of a specific quest to retrieve data for. If nil, returns all quest data.
-- @return table A table containing quest data. If questId is provided, returns data for that specific quest or nil if not found.
function GetQuestData(questId)   end
---
-- @desc Gets data for all items currently in the player's quest inventory.
-- @return table A table containing quest item data.
function GetQuestItemData()   end
---
-- @desc Gets the conditions associated with a specific point on a map display.
-- @param mapDisplay table The map display object or data.
-- @param pointIndex number The index of the point on the map.
-- @return table|nil A table containing the conditions for the quest point, or nil.
function GetQuestPointConditions(mapDisplay, pointIndex)   end
---
-- @desc Gets data related to the current Realm Resource Quest (RRQ).
-- @return table A table containing RRQ data.
function GetRRQData()   end
---
-- @desc Gets the name of a realm.
-- @param id number The ID of the realm (e.g., GameData.Realm.ORDER).
-- @return string The name of the realm.
function GetRealmName(id)   end
---
-- @desc Gets the index of the relevant area. (Usage not found for documentation - Typo in name)
-- @return number The relevant area index.
function GetReleventAreaIndex()   end
---
-- @desc Gets data about the current reward pools (e.g., for zone control).
-- @return number winnerRewardPool The reward pool value for the winning side.
-- @return number loserRewardPool The reward pool value for the losing side.
-- @return boolean isNextShift Indicates if the next shift is occurring.
-- @return number timeUntilShift Time remaining until the next shift.
function GetRewardPools()   end
---
-- @desc Gets the difficulty class and success percentage for salvaging an item based on its level.
-- @param itemLevel number The item level of the item to be salvaged.
-- @return number difficultyClass The difficulty class (e.g., GameData.Salvaging constant).
-- @return number difficultyPercent The percentage chance of success.
function GetSalvagingDifficulty(itemLevel)   end
---
-- @desc Gets the description text for a scenario lobby.
-- @param id number The ID of the scenario.
-- @return string The scenario lobby description.
function GetScenarioLobbyDesc(id)   end
---
-- @desc Gets the name of a scenario.
-- @param id number The ID of the scenario.
-- @return string The name of the scenario.
function GetScenarioName(id)   end
---
-- @desc Gets data about the scenarios the player is currently queued for.
-- @return table A table containing data about the queued scenarios.
function GetScenarioQueueData()   end
---
-- @desc Gets the description text related to a scenario's scoring objectives.
-- @param id number The ID of the scenario.
-- @return string The scenario score description.
function GetScenarioScoreDesc(id)   end
---
-- @desc Gets the list of players found via the player search function.
-- @return table A list of player data tables matching the search criteria.
function GetSearchList()   end
---
-- @desc Gets the list of available game servers. (Usage not found for documentation)
-- @return table A list of server data tables.
function GetServerList()   end
---
-- @desc Gets data related to building siege weapons on a specific siege pad.
-- @return table A table containing buildable siege weapon data for the current interaction target.
function GetSiegePadBuildData()   end
---
-- @desc Gets data required for controlling the currently targeted siege weapon.
-- @return table A table containing control data for the siege weapon.
function GetSiegeWeaponControlData()   end
---
-- @desc Gets data about the players currently using the targeted siege weapon.
-- @return table A list of user data tables for the siege weapon.
function GetSiegeWeaponUsersData()   end
---
-- @desc Gets data for a single item at a specific location and slot.
-- @param location number The item location ID (e.g., GameData.ItemLocs.BANK).
-- @param slot number The slot index within the location.
-- @param forceUpdate boolean|nil If true, forces an update from the server (?). Defaults to false/nil.
-- @return table|nil Item data table for the item in the slot, or nil if empty.
function GetSingleItem(location, slot, forceUpdate)   end
---
-- @desc Gets the player's current social preference settings.
-- @return table A table containing the player's social preferences.
function GetSocialPreferenceData()   end
---
-- @desc Gets the description text for a specific specialization path.
-- @param id number The ID of the specialization path (e.g., GameData.Player.SPECIALIZATION_PATH_1).
-- @return string The description of the specialization path.
function GetSpecializationPathDescription(id)   end
---
-- @desc Gets the name of a specific specialization path.
-- @param id number The ID of the specialization path (e.g., GameData.Player.SPECIALIZATION_PATH_1).
-- @return string The name of the specialization path.
function GetSpecializationPathName(id)   end
---
-- @desc Gets the list of item categories available in the currently interacted store.
-- @return table A list of store category data tables.
function GetStoreCategories()   end
---
-- @desc Gets the data (items, prices, etc.) for the currently interacted store or librarian.
-- @return table A table containing the store's data.
function GetStoreData()   end
---
-- @desc Gets a localized string from the specified string table using its ID.
-- @param stringTableId number The ID of the string table (e.g., StringTables.Default).
-- @param stringId number The ID of the string within the table.
-- @return string The localized string.
function GetString(stringTableId, stringId)   end
---
-- @desc Gets a formatted localized string from the specified string table using its ID and format arguments.
-- @param stringTableId number The ID of the string table (e.g., StringTables.Default).
-- @param stringId number The ID of the string within the table.
-- @param formatArgs table A table of arguments to format the string with.
-- @return string The formatted localized string.
function GetStringFormat(stringTableId, stringId, formatArgs)   end
---
-- @desc Gets the list of tactic IDs assigned to a specific tactics set.
-- @param setId number The index of the tactics set (0 to MAX_TACTICS_SETS - 1).
-- @return table A list of tactic ability IDs in the specified set.
function GetTacticsSet(setId)   end
---
-- @desc Gets data about the states of the current target. (Usage not found for documentation)
-- @return table A table containing target state data.
function GetTargetStatesData()   end
---
-- @desc Gets the width and height dimensions for a given window template name.
-- @param templateName string The name of the window template.
-- @return number width The width of the template window.
-- @return number height The height of the template window.
function GetTemplateWindowDimensions(templateName)   end
---
-- @desc Converts a date and time into a numerical timestamp.
-- @param month number The month (1-12).
-- @param day number The day (1-31).
-- @param year number The year.
-- @param hour number The hour (0-23).
-- @param minute number The minute (0-59).
-- @return number The calculated timestamp.
function GetTimeStamp(month, day, year, hour, minute)   end
---
-- @desc Gets the remaining time in seconds until the player automatically respawns.
-- @return number The time in seconds until auto-respawn.
function GetTimeUntilAutoRespawn()   end
---
-- @desc Gets the current server date.
-- @return table A table containing { todaysMonth, todaysDay, todaysYear }.
function GetTodaysDate()   end
---
-- @desc Gets data for currently active Tome of Knowledge alerts.
-- @return table A list of tome alert data tables.
function GetTomeAlertsData()   end
---
-- @desc Gets the item and money data for either the player's or the trade target's current trade offer.
-- @param refreshType number Specifies which offer to refresh (e.g., EA_Window_Trade.MY_OFFER_UPDATED, EA_Window_Trade.OTHER_OFFER_UPDATED).
-- @return table itemData A list of item data tables in the offer.
-- @return number money The amount of money in the offer.
function GetTradeItemData(refreshType)   end
---
-- @desc Gets the player's current skill level in a specific tradeskill.
-- @param tradeskillId number The ID of the tradeskill (e.g., GameData.TradeSkills.SALVAGING).
-- @return number The player's skill level in that tradeskill (0 if not learned).
function GetTradeSkillLevel(tradeskillId)   end
---
-- @desc Gets the icon number associated with a specific tradeskill.
-- @param tradeskillId number The ID of the tradeskill.
-- @return number The icon number for the tradeskill.
function GetTradeskillIcon(tradeskillId)   end
---
-- @desc Gets data for the items equipped in the player's trophy slots.
-- @return table A list of item data tables for equipped trophies.
function GetTrophyData()   end
---
-- @desc Gets the current underdog rating points for Order and Destruction realms.
-- @return number orderPoints The underdog points for the Order realm.
-- @return number destPoints The underdog points for the Destruction realm.
function GetUnderdogRatings()   end
---
-- @desc Gets a list of targets whose data has been updated since the last call. Used internally by TargetInfo system.
-- @return table A list of updated target data tables.
function GetUpdatedTargets()   end
---
-- @desc Gets status information for a specific member within a warband party.
-- @param partyIndex number The index of the party within the warband (1-4).
-- @param memberIndex number The index of the member within the party (1-6).
-- @return table A table containing status data for the member (e.g., healthPercent).
function GetWarbandMemberStatus(partyIndex, memberIndex)   end
---
-- @desc Gets the name of a day of the week.
-- @param dayIndex number The index of the day (1-7, likely Sunday=1).
-- @param isShorthand boolean|nil If true, returns the shorthand name (e.g., "Sun"). Defaults to false/nil for full name.
-- @return string The name of the weekday.
function GetWeekDayName(dayIndex, isShorthand)   end
---
-- @desc Gets a formatted string representing the year and month name.
-- @param year number The year.
-- @param month number The month (1-12).
-- @return string The formatted year and month string (e.g., "May 2025").
function GetYearMonthName(year, month)   end
---
-- @desc Gets the name of a specific area within a zone.
-- @param zoneId number The ID of the zone.
-- @param areaId number The ID of the area within the zone.
-- @return string The name of the zone area.
function GetZoneAreaName(zoneId, areaId)   end
---
-- @desc Gets a list of all zone IDs.
-- @return table A list containing all zone IDs.
function GetZoneIDList()   end
---
-- @desc Gets the size of the largest hotspot in the specified zone.
-- @param zoneId number The ID of the zone.
-- @return number The size of the largest hotspot.
function GetZoneLargestHotspotSize(zoneId)   end
---
-- @desc Gets the localized name of a zone.
-- @param zoneId number The ID of the zone.
-- @return string The name of the zone.
function GetZoneName(zoneId)   end
---
-- @desc Gets data about the objectives within a specific zone.
-- @param zoneId number The ID of the zone.
-- @return table|nil A table containing objective data for the zone, or nil if none.
function GetZoneObjectivesData(zoneId)   end
---
-- @desc Gets the ID of the zone pairing the player is currently in.
-- @return number The ID of the current zone pairing.
function GetZonePairing()   end
---
-- @desc Gets the recommended rank range for the player's realm in the specified zone.
-- @param zoneId number The ID of the zone.
-- @return string A string representing the recommended rank range (e.g., "1-10").
function GetZoneRanksForCurrentRealm(zoneId)   end
---
-- @desc Gets the tier number for the specified zone.
-- @param zoneId number The ID of the zone.
-- @return number The tier number (1-4) of the zone.
function GetZoneTier(zoneId)   end
---
-- @desc Gets data for zone transition points displayed on a map.
-- @param mapDisplay string The name of the map display window.
-- @return table A list of transition point data tables.
function GetZoneTransitionPoints(mapDisplay)   end
---
-- @desc Accepts the pending group invitation. Called by the group invite dialog.
function GroupInviteAccept()   end
---
-- @desc Callback function registered as an event handler for group invites.
function GroupInviteCallback()   end
---
-- @desc Declines the pending group invitation. Called by the group invite dialog.
function GroupInviteDecline()   end
---
-- @desc Gets available guild reward data.
-- @return table A table containing guild reward information.
function GuildGetRewards()   end
---
-- @desc Gets the guild's current recruitment profile data.
-- @return table A table containing the recruitment profile settings.
function GuildRecruitmentProfileGetData()   end
---
-- @desc Sets the guild's recruitment profile data.
-- @param descText string The full description text.
-- @param summaryText string The summary text.
-- @param playStyle number The selected playstyle ID.
-- @param atmosphere number The selected atmosphere ID.
-- @param interest1 number The first selected interest ID.
-- @param interest2 number The second selected interest ID.
-- @param interest3 number The third selected interest ID.
-- @param interest4 number The fourth selected interest ID.
-- @param minRank number The minimum rank for recruitment.
-- @param maxRank number The maximum rank for recruitment.
-- @param recruitingClasses table A table indicating which classes are being recruited (boolean flags).
function GuildRecruitmentProfileSetData(descText, summaryText, playStyle, atmosphere, interest1, interest2, interest3, interest4, minRank, maxRank, recruitingClasses)   end
---
-- @desc Performs a search for guilds based on recruitment criteria.
-- @param playStyle number The desired playstyle ID.
-- @param atmosphere number The desired atmosphere ID.
-- @param interest1 number The first desired interest ID.
-- @param interest2 number The second desired interest ID.
-- @param interest3 number The third desired interest ID.
-- @param interest4 number The fourth desired interest ID.
-- @param minRank number The minimum rank desired.
-- @param maxRank number The maximum rank desired.
-- @param recruitingClasses table A table indicating desired classes (boolean flags).
function GuildRecruitmentSearch(playStyle, atmosphere, interest1, interest2, interest3, interest4, minRank, maxRank, recruitingClasses)   end
---
-- @desc Initializes the standard UI dialog windows.
function InitializeDialogs()   end
---
-- @desc Initiates a trade with the current target.
-- @param arg1 number Unknown argument (possibly trade type or flag).
-- @param arg2 number Unknown argument (possibly related to target).
function InitiateTrade(arg1, arg2)   end
---
-- @desc Gets the base interaction menu data for a specified target.
-- @param interactionTargetID number The ID of the interaction target.
-- @return table A table containing the base interaction options.
function InteractGetBaseInteractionData(interactionTargetID)   end
---
-- @desc Selects a specific option from an interaction menu.
-- @param target number The ID of the interaction target.
-- @param optionType number The type ID of the interaction option selected.
-- @param optionSlot number The slot/index of the specific option chosen (if applicable, e.g., for quest rewards).
function InteractSelect(target, optionType, optionSlot)   end
---
-- @desc Checks if a specific ability is currently enabled (usable).
-- @param abilityId number The ID of the ability to check.
-- @return boolean True if the ability is enabled, false otherwise.
function IsAbilityEnabled(abilityId)   end
---
-- @desc Checks if a specific ability is currently toggled on. (Usage not found for documentation)
-- @param abilityId number The ID of the ability to check.
-- @return boolean True if the ability is toggled on, false otherwise.
function IsAbilityToggledOn(abilityId)   end
---
-- @desc Checks if the current game client is an internal development build.
-- @return boolean True if it's an internal build, false otherwise.
function IsInternalBuild()   end
---
-- @desc Checks if the game client is running on macOS. (Usage not found for documentation)
-- @return boolean True if it's the Mac client, false otherwise.
function IsMacClient()   end
---
-- @desc Checks if a given key ID corresponds to a modifier key (Shift, Ctrl, Alt).
-- @param itemId number The ID of the key being checked.
-- @return boolean True if the key is a modifier key, false otherwise.
function IsModifierKey(itemId)   end
---
-- @desc Checks if the player character data has been fully initialized by the client.
-- @return boolean True if the player is initialized, false otherwise.
function IsPlayerInitialized()   end
---
-- @desc Checks if the player is currently designated as the Main Assist.
-- @return number 1 if the player is Main Assist, 0 otherwise.
function IsPlayerMainAssist()   end
---
-- @desc Checks if the player is currently solo (not in a group or warband).
-- @return number 1 if the player is solo, 0 otherwise.
function IsPlayerSolo()   end
---
-- @desc Checks if the player's cloak heraldry is currently being displayed.
-- @return boolean True if cloak heraldry is showing, false otherwise.
function IsShowingCloakHeraldry()   end
---
-- @desc Checks if the current target is valid for a specific ability.
-- @param abilityId number The ID of the ability.
-- @return boolean isTargetValid True if the target is generally valid (e.g., exists, in range), false otherwise.
-- @return boolean hasRequiredUnitTypeTargeted True if the target is of the required unit type for the ability, false otherwise.
function IsTargetValid(abilityId)   end
---
-- @desc Checks if the player is currently in an active warband.
-- @return boolean True if in an active warband, false otherwise.
function IsWarBandActive()   end
---
-- @desc Loots a specific item choice from an item container (e.g., Choose One reward window).
-- @param choiceIndex number The index of the item choice to loot.
function ItemContainerLootItem(choiceIndex)   end
---
-- @desc Joins a specific scenario group.
-- @param groupIndex number The index of the scenario group to join.
function JoinScenarioGroup(groupIndex)   end
---
-- @desc Sets the image displayed by a bitmap element on an LCD page.
-- @param page number The index of the LCD page.
-- @param name string The name of the bitmap element.
-- @param imagePath string The file path to the bitmap image.
-- @param update boolean|nil Unknown purpose, possibly related to visibility or forcing an update.
function LCDBitmapSetImage(page, name, imagePath, update)   end
---
-- @desc Handles a button press event from the LCD keyboard. (Usage not found for documentation)
-- @param buttonId number The ID of the button pressed.
function LCDButtonPressed(buttonId)   end
---
-- @desc Creates a bitmap element on an LCD page.
-- @param page number The index of the LCD page.
-- @param name string The name to assign to the bitmap element.
function LCDCreateBitmap(page, name)   end
---
-- @desc Creates a new page on the LCD display.
-- @param page number The index/ID to assign to the new page.
function LCDCreatePage(page)   end
---
-- @desc Creates a progress bar element on an LCD page.
-- @param page number The index of the LCD page.
-- @param name string The name to assign to the progress bar element.
-- @param style string The style of the progress bar (e.g., "filled").
-- @param minVal number The minimum value of the progress bar.
-- @param maxVal number The maximum value of the progress bar.
function LCDCreateProgressBar(page, name, style, minVal, maxVal)   end
---
-- @desc Creates a static text element on an LCD page.
-- @param page number The index of the LCD page.
-- @param name string The name to assign to the text element.
-- @param fontSize number The font size (e.g., 1).
-- @param alignment string The text alignment ("left", "center", "right").
-- @param width number The width of the text element.
-- @param lines number The maximum number of lines for the text.
function LCDCreateStaticText(page, name, fontSize, alignment, width, lines)   end
---
-- @desc Destroys/removes a page from the LCD display. (Usage not found for documentation)
-- @param page number The index/ID of the page to destroy.
function LCDDestroyPage(page)   end
---
-- @desc Gets the X, Y coordinates of an element on an LCD page. (Usage not found for documentation)
-- @param page number The index of the LCD page.
-- @param name string The name of the element.
-- @return number x The X-coordinate of the element.
-- @return number y The Y-coordinate of the element.
function LCDGetLocation(page, name)   end
---
-- @desc Gets the width and height of an element on an LCD page. (Usage not found for documentation)
-- @param page number The index of the LCD page.
-- @param name string The name of the element.
-- @return number width The width of the element.
-- @return number height The height of the element.
function LCDGetSize(page, name)   end
---
-- @desc Gets the current progress value of a progress bar element on an LCD page. (Usage not found for documentation)
-- @param page number The index of the LCD page.
-- @param name string The name of the progress bar element.
-- @return number The current progress value.
function LCDProgressBarGetProgress(page, name)   end
---
-- @desc Sets the current progress value of a progress bar element on an LCD page.
-- @param page number The index of the LCD page.
-- @param name string The name of the progress bar element.
-- @param progress number The new progress value to set.
function LCDProgressBarSetProgress(page, name, progress)   end
---
-- @desc Registers a Lua function as an event handler for a specific system event on an LCD page.
-- @param page number The index of the LCD page.
-- @param eventId number The ID of the system event (e.g., SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED).
-- @param handlerFuncName string The name of the Lua function to call when the event occurs.
function LCDRegisterEventHandler(page, eventId, handlerFuncName)   end
---
-- @desc Assigns a Lua function to handle button presses for a specific LCD page.
-- @param page number The index of the LCD page.
-- @param handlerFuncName string The name of the Lua function to call when a button is pressed on this page.
function LCDSetButtonHandler(page, handlerFuncName)   end
---
-- @desc Sets the X, Y position of an element on an LCD page.
-- @param page number The index of the LCD page.
-- @param name string The name of the element.
-- @param x number The new X-coordinate.
-- @param y number The new Y-coordinate.
function LCDSetLocation(page, name, x, y)   end
---
-- @desc Sets the width and height of an element on an LCD page.
-- @param page number The index of the LCD page.
-- @param name string The name of the element.
-- @param width number The new width.
-- @param height number The new height.
function LCDSetSize(page, name, width, height)   end
---
-- @desc Makes a specific page visible on the LCD display.
-- @param page number The index/ID of the page to show.
function LCDShowPage(page)   end
---
-- @desc Sets the text content of a static text element on an LCD page.
-- @param page number The index of the LCD page.
-- @param name string The name of the static text element.
-- @param text string The text content to display.
function LCDStaticTextSetText(page, name, text)   end
---
-- @desc Unregisters a previously registered event handler for an LCD page. (Usage not found for documentation)
-- @param page number The index of the LCD page.
-- @param eventId number The ID of the system event.
-- @param handlerFuncName string The name of the Lua function that was registered.
function LCDUnregisterEventHandler(page, eventId, handlerFuncName)   end
---
-- @desc Removes a previously set button handler for an LCD page. (Usage not found for documentation)
-- @param page number The index of the LCD page.
-- @param handlerFuncName string The name of the Lua function that was set as the handler.
function LCDUnsetButtonHandler(page, handlerFuncName)   end
---
-- @desc Leaves the current scenario group.
function LeaveScenarioGroup()   end
---
-- @desc Gets data relevant to the current loading screen being displayed.
-- @return table A table containing loading screen data (e.g., zoneId, scenarioId).
function LoadingScreenGetCurrentData()   end
---
-- @desc Gets patch notes data for display on the loading screen.
-- @return table|nil A table containing patch notes data, or nil if none available.
function LoadingScreenGetPatchNotesData()   end
---
-- @desc Gets the string content from a text log display at specific cursor coordinates.
-- @param logWindowName string The name of the text log window (e.g., "ChatWindow1TextLog").
-- @param x number The X-coordinate of the cursor within the log window.
-- @param y number The Y-coordinate of the cursor within the log window.
-- @return string The text content at the specified cursor position.
function LogDisplayGetStringFromCursorPos(logWindowName, x, y)   end
---
-- @desc Logs a message to the UI log system. Used internally by DEBUG/ERROR functions.
-- @param source string The source of the message (e.g., "Lua").
-- @param filterId number The log filter ID (e.g., SystemData.UiLogFilters.DEBUG).
-- @param message string The message text to log.
function LogLuaMessage(source, filterId, message)   end
---
-- @desc Loots all items currently available in the main loot window.
function LootAllItems()   end
---
-- @desc Loots a specific item from the main loot window by its slot index.
-- @param lootIndex number The index (slot) of the item to loot.
function LootItem(lootIndex)   end
---
-- @desc Opts in or out of loot rolls for a specific objective.
-- @param objectiveId number The ID of the objective.
-- @param optOutValue boolean True to opt out, false to opt in.
function LootRollOptOut(objectiveId, optOutValue)   end
---
-- @desc Gets a list of child maps for a given parent map. (Usage not found for documentation)
-- @param mapLevel number The level of the parent map (e.g., GameDefs.MapLevel.PAIRING_MAP).
-- @param mapId number The ID of the parent map.
-- @return table A list of child map data tables.
function MapGetChildMaps(mapLevel, mapId)   end
---
-- @desc Converts screen coordinates (relative to a map display) into map coordinates.
-- @param mapDisplayName string The name of the map display window.
-- @param screenX number The X-coordinate relative to the map display window (scaled).
-- @param screenY number The Y-coordinate relative to the map display window (scaled).
-- @return number mapX The calculated map X-coordinate.
-- @return number mapY The calculated map Y-coordinate.
function MapGetCoordinatesForPoint(mapDisplayName, screenX, screenY)   end
---
-- @desc Gets information about the parent map of a given map.
-- @param mapLevel number The level of the current map (e.g., GameDefs.MapLevel.ZONE_MAP).
-- @param mapId number The ID of the current map.
-- @return table|nil A table containing parent map data (mapNumber, etc.), or nil if no parent.
function MapGetParentMap(mapLevel, mapId)   end
---
-- @desc Gets a list of maps relevant to the player's current location (world, pairing, zone).
-- @return table A list of map data tables representing the player's location hierarchy.
function MapGetPlayerLocationMaps()   end
---
-- @desc Converts map coordinates into screen coordinates relative to a map display window.
-- @param mapDisplayName string The name of the map display window.
-- @param mapX number The map X-coordinate.
-- @param mapY number The map Y-coordinate.
-- @return number screenX The calculated screen X-coordinate relative to the map display.
-- @return number screenY The calculated screen Y-coordinate relative to the map display.
function MapGetPointForCoordinates(mapDisplayName, mapX, mapY)   end
---
-- @desc Sets the view of a map display window to a specific map level and ID.
-- @param mapDisplayName string The name of the map display window.
-- @param mapLevel number The map level to display (e.g., GameDefs.MapLevel.ZONE_MAP).
-- @param mapId number The ID of the map to display.
function MapSetMapView(mapDisplayName, mapLevel, mapId)   end
---
-- @desc Sets the visibility filter for a specific type of map pin on a map display.
-- @param mapDisplayName string The name of the map display window.
-- @param pinType number The type ID of the map pin (e.g., SystemData.MapPips.PLAYER).
-- @param show boolean True to show pins of this type, false to hide.
function MapSetPinFilter(mapDisplayName, pinType, show)   end
---
-- @desc Sets the gutter size (spacing) for a specific type of map pin on a map display.
-- @param mapDisplayName string The name of the map display window.
-- @param pinType number The type ID of the map pin.
-- @param gutterSize number The desired gutter size value.
function MapSetPinGutter(mapDisplayName, pinType, gutterSize)   end
---
-- @desc Registers a Lua variable within a module to be saved across sessions. (Usage not found for documentation)
-- @param moduleName string The name of the module.
-- @param variableName string The name of the variable to save.
-- @param variableRef table The Lua table variable itself.
function ModuleAddSavedVariable(moduleName, variableName, variableRef)   end
---
-- @desc Unregisters a previously registered saved variable for a module. (Usage not found for documentation)
-- @param moduleName string The name of the module.
-- @param variableName string The name of the variable to stop saving.
function ModuleRemoveSavedVariable(moduleName, variableName)   end
---
-- @desc Moves and anchors a UI window to a specific world object's position.
-- @param windowName string The name of the UI window to move.
-- @param worldObject userdata The world object to anchor to.
-- @param attachHeight number The vertical offset from the object's anchor point.
function MoveWindowToWorldObject(windowName, worldObject, attachHeight)   end
---
-- @desc Requests a new name when a character naming conflict occurs. (Usage not found for documentation)
-- @param conflictingName string The name that caused the conflict.
function NamingConflictRequestNewName(conflictingName)   end
---
-- @desc Creates a data structure for a single chat bubble message.
-- @param txt string The text content of the chat bubble.
-- @param dspTime number The duration (in seconds) the bubble should be displayed.
-- @return table The chat bubble data table { text, alpha, displayTime, fading }.
function NewChatBubbleData(txt, dspTime)   end
---
-- @desc Creates a data structure for a group of chat bubbles associated with a world object.
-- @return table The chat bubble group data table { worldObject = 0, bubbleData = {} }.
function NewChatBubbleGroupData()   end
---
-- @desc Creates a simple RGB color table.
-- @param red number The red component (0-255).
-- @param green number The green component (0-255).
-- @param blue number The blue component (0-255).
-- @return table The color data table { r, g, b }.
function NewColor(red, green, blue)   end
---
-- @desc Creates a data structure representing the item/action currently held on the cursor.
-- @return table The cursor data table { Source = 0, SourceSlot = 0, ObjectId = 0, IconId = 0, StackAmount = 0 }.
function NewCursorData()   end
---
-- @desc Creates a data structure for guild list sorting options.
-- @param labelWindowName string The name of the label/button window associated with the sort option.
-- @param tooltipStringId number The string table ID for the tooltip text.
-- @return table The guild sort data table { windowName, tooltipStringId }.
function NewGuildSortData(labelWindowName, tooltipStringId)   end
---
-- @desc Creates a data structure for UI Mod or Layout Editor window sorting options.
-- @param labelWindowName string The name of the label/button window associated with the sort option.
-- @param title string The title text for the sort option.
-- @param desc string The description text for the sort option.
-- @return table The mod sort data table { windowName, title, desc }.
function NewModSortData(labelWindowName, title, desc)   end
---
-- @desc Creates a data structure for Quest Journal sorting options.
-- @param labelWindowName string The name of the label/button window associated with the sort option.
-- @param title string The title text for the sort option.
-- @param desc string The description text for the sort option.
-- @return table The quest sort data table { windowName, title, desc }.
function NewQuestSortData(labelWindowName, title, desc)   end
---
-- @desc Creates a generic data structure for sorting options in various UI lists.
-- @param labelWindowName string The name of the label/button window.
-- @param title string|number The title text or string ID for the sort option.
-- @param desc string|number The description text or string ID for the sort option.
-- @param varName string|nil (Optional) The variable name used for sorting (e.g., in Scenario Summary).
-- @return table The sort data table.
function NewSortData(labelWindowName, title, desc, varName)   end
---
-- @desc Creates a data structure representing the current state of the Tome of Knowledge window.
-- @param pageType number The type ID of the current page.
-- @param params table Parameters specific to the current page state.
-- @param flipModeParams table Parameters related to the page flip animation/mode.
-- @return table The state data table { pageType, params, flipModeParams }.
function NewStateData(pageType, params, flipModeParams)   end
---
-- @desc Creates a data structure holding information about an item targeting action.
-- @return table The target data table { Source = 0, SourceSlot = 0, TargetMapId = 0, CursorIconId = 0, TargetLoc = 0, TargetSlot = 0 }.
function NewTargetData()   end
---
-- @desc Creates a data structure representing a statistic displayed in the Tome of Knowledge.
-- @param windowName string The base name of the window elements displaying the stat.
-- @param strIndex number The string table ID for the stat's label.
-- @param updateEvent number The system event ID that triggers an update for this stat.
-- @param variableName string The name of the variable holding the stat value in GameData.PlayerStats.
-- @return table The tome stat data table { windowName, strIndex, updateEvent, variableName }.
function NewTomeStat(windowName, strIndex, updateEvent, variableName)   end
---
-- @desc Creates a data structure for a world event text message displayed on screen.
-- @param txt string The text content of the message.
-- @param dspTime number The duration (in seconds) the message should be displayed.
-- @return table The world event text data table { text, alpha, displayTime, fading }.
function NewWorldEventTextData(txt, dspTime)   end
---
---@desc Sets the translation (position offset) of a NIF model display window.
---@param windowName string The name of the NIF display window.
---@param x number The X-axis translation offset.
---@param y number The Y-axis translation offset.
---@param z number The Z-axis translation offset.
---@usage Used in ea_barbershopwindow/source/barbershopwindow.lua to adjust character model position.
function NifDisplaySetTranslation(windowName, x, y, z)   end
---
-- @desc Opens the specified URL in the system's default web browser.
-- @param url string The URL to open.
function OpenURL(url)   end
---
-- @desc Loots a specific item choice from a Public Quest reward container.
-- @param choiceIndex number The index of the item choice to loot.
function PQLootItem(choiceIndex)   end
---
-- @desc Initiates the crafting process for a specific tradeskill.
-- @param tradeskillId number The ID of the tradeskill to perform (e.g., GameData.TradeSkills.APOTHECARY).
-- @param count number The number of items to craft.
function PerformCrafting(tradeskillId, count)   end
---
-- @desc Plays a sound effect associated with a specific interaction event.
-- @param soundName string The name of the interaction sound (e.g., "trainer_accept").
function PlayInteractSound(soundName)   end
---
-- @desc Plays a sound effect identified by its ID.
-- @param soundId number The ID of the sound effect to play.
function PlaySound(soundId)   end
---
-- @desc Handles mouseover events for blocks/elements in the pre-game screens. (Usage not found for documentation)
function PregameBlockMouseOver()   end
---
-- @desc Gets the total number of pages available in the pre-game character selection screen. (Usage not found for documentation)
-- @return number The total number of character select pages.
function PregameGetCharacterSelectNumPages()   end
---
-- @desc Gets the currently displayed page number in the pre-game character selection screen. (Usage not found for documentation)
-- @return number The current character select page number.
function PregameGetCharacterSelectPage()   end
---
-- @desc Gets the filename of the End User License Agreement (EULA) file. (Usage not found for documentation)
-- @return string The EULA filename.
--- Gets the filename of the End User License Agreement (EULA) file.
---@return string The EULA filename.
---@usage Called from interfacecore/source/eularocwindow.lua
function PregameGetEULAFileName()   end
---
-- @desc Gets the pre-selected server and realm chosen by the player. (Usage not found for documentation)
-- @return number serverId The ID of the pre-selected server.
-- @return number realmId The ID of the pre-selected realm (GameData.Realm).
function PregameGetPreSelectedServerRealm()   end
---
-- @desc Gets labels used in the quick start or character creation process. (Usage not found for documentation)
-- @return table A table containing quick start labels.
function PregameGetQuickStartLabels()   end
---
-- @desc Gets the filename of the Rules of Conduct (ROC) file. (Usage not found for documentation)
-- @return string The ROC filename.
--- Gets the filename of the Rules of Conduct (ROC) file.
---@return string The ROC filename.
---@usage Called from interfacecore/source/eularocwindow.lua
function PregameGetROCFileName()   end
---
-- @desc Gets the character limit per realm. (Usage not found for documentation)
-- @return number The maximum number of characters allowed per realm.
function PregameGetRealmLimit()   end
---
-- @desc Gets bonus information (e.g., population bonuses) for servers and realms. (Usage not found for documentation)
-- @return table A table containing server/realm bonus data.
function PregameGetServerRealmBonuses()   end
---
-- @desc Checks if the End User License Agreement (EULA) has changed since last accepted. (Usage not found for documentation)
-- @return boolean True if the EULA has changed, false otherwise.
--- Checks if the End User License Agreement (EULA) has changed since last accepted.
---@return boolean True if the EULA has changed, false otherwise.
---@usage Called from interfacecore/source/eularocwindow.lua
function PregameHasEULAChanged()   end
---
-- @desc Checks if the Rules of Conduct (ROC) have changed since last accepted. (Usage not found for documentation)
-- @return boolean True if the ROC has changed, false otherwise.
--- Checks if the Rules of Conduct (ROC) have changed since last accepted.
---@return boolean True if the ROC has changed, false otherwise.
---@usage Called from interfacecore/source/eularocwindow.lua
function PregameHasROCChanged()   end
---
-- @desc Plays a cinematic video during the pre-game sequence. (Usage not found for documentation)
-- @param cinematicId number|string The ID or filename of the cinematic to play.
function PregamePlayCinematic(cinematicId)   end
---
-- @desc Randomizes selectable appearance features during character creation. (Usage not found for documentation)
function PregameRandomFeatures()   end
---
---@desc Sets the currently displayed page in the pre-game character selection screen.
---@param pageNum number The page number to display within that realm.
---@usage Called from interfacecore/source/characterselectwindow.lua when changing character pages.
function PregameSetCharacterSelectPage( pageNum)   end
---
-- @desc Sets a specific appearance feature during character creation. (Usage not found for documentation)
-- @param featureId number The ID of the feature to set.
-- @param value number The chosen value for the feature.
function PregameSetFeature(featureId, value)   end
---
-- @desc Sets the server and realm pre-selected by the player before connecting. (Usage not found for documentation)
-- @param serverId number The ID of the selected server.
-- @param realmId number The ID of the selected realm (GameData.Realm).
function PregameSetPreSelectedServerRealm(serverId, realmId)   end
---
-- @desc Sets server/realm bonus data (e.g., population bonuses). (Usage not found for documentation)
-- @param bonusData table A table containing the bonus data to set.
function PregameSetServerRealmBonuses(bonusData)   end
---
-- @desc Stops any currently playing pre-game cinematic. (Usage not found for documentation)
function PregameStopCinematic()   end
---
-- @desc Initiates the purchase of a specific keep upgrade level.
-- @param upgradeId number The ID of the keep upgrade to purchase.
-- @param targetLevel number The desired level of the upgrade.
function PurchaseKeepUpgrade(upgradeId, targetLevel)   end
