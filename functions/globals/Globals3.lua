------@meta
-- @desc Refunds all spent Renown points.
function RefundRenownPoints()   end
---
-- @desc Refunds all spent Specialization/Mastery points.
function RefundSpecialtyPoints()   end
---
-- @desc Removes a tactic from the player's active set. (Usage not found for documentation)
-- @param tacticId number|nil The ID of the tactic to remove (or slot index?).
function RemoveActiveTactic(tacticId)   end
---
-- @desc Removes all current key bindings, resetting them to unbound. (Usage not found for documentation)
function RemoveAllBindings()   end
---
-- @desc Removes a specific key binding for an action.
-- @param actionId number The ID of the action whose binding is to be removed.
-- @param deviceId number The ID of the input device (e.g., SystemData.InputDevice.KEYBOARD).
-- @param buttonId number|table The ID or table of IDs of the button(s) bound to the action.
function RemoveBinding(actionId, deviceId, buttonId)   end
---
-- @desc Removes an item from a crafting window slot.
-- @param tradeskillId number The ID of the relevant tradeskill (e.g., GameData.TradeSkills.APOTHECARY).
-- @param sourceSlot number The index of the slot from which to remove the item.
-- @param backpackType number The type of backpack the item originated from (e.g., GameData.ItemLocs.INVENTORY).
function RemoveCraftingItem(tradeskillId, sourceSlot, backpackType)   end
---
-- @desc Removes/cancels a buff or debuff effect currently active on the player.
-- @param effectIndex number The index of the effect to remove.
function RemoveEffect(effectIndex)   end
---
-- @desc Removes an enhancement (e.g., talisman) from an item's enhancement slot.
-- @param enhancementSlotId number The ID of the enhancement slot to clear.
function RemoveItemEnhancement(enhancementSlotId)   end
---
-- @desc Removes/destroys a map instance associated with a map display window.
-- @param mapDisplayName string The name of the map display window whose instance should be removed.
function RemoveMapInstance(mapDisplayName)   end
---
-- @desc Deselects a chosen quest reward item.
-- @param rewardIndex number The index/ID of the reward to deselect.
function RemoveSelectedReward(rewardIndex)   end
---
-- @desc Removes a specific buff/debuff effect from the current target. (Usage not found for documentation)
-- @param effectIndex number The index or ID of the effect to remove from the target.
function RemoveTargetEffect(effectIndex)   end
---
-- @desc Dismisses or removes a specific Tome of Knowledge alert.
-- @param alertId number The ID of the tome alert to remove.
function RemoveTomeAlert(alertId)   end
---
-- @desc Initiates repairing the currently controlled siege weapon.
function RepairSiegeWeapon()   end
---
---@desc Requests to equip a trophy item into a specific trophy slot.
---@param trophyItemId number The unique ID of the trophy item to equip.
---@param trophySlot number The target trophy slot index (e.g., GameData.ItemLocs.TROPHY_1).
---@usage Called from ea_characterwindow/source/characterwindowtrophies.lua when equipping a trophy.
function RequestEquipTrophy(trophyItemId, trophySlot)   end
---
-- @desc Requests item set data from the server.
-- @param itemSetId number The ID of the item set to request data for.
function RequestItemSet(itemSetId)   end
---
-- @desc Requests to move an item stack between two locations/slots.
-- @param sourceLocation number The source location ID (e.g., GameData.ItemLocs.INVENTORY).
-- @param sourceSlot number The source slot index.
-- @param destLocation number The destination location ID (e.g., GameData.ItemLocs.BANK).
-- @param destSlot number The destination slot index.
-- @param stackCount number The number of items to move.
function RequestMoveItem(sourceLocation, sourceSlot, destLocation, destSlot, stackCount)   end
---
-- @desc Initiates the salvaging process for a selected item.
-- @param itemSlot number The inventory/bank slot of the item to salvage.
-- @param backpackType number The location type of the item (e.g., GameData.ItemLocs.INVENTORY).
-- @param salvagingType number The type of salvaging being performed (?).
-- @param selectedStat number|nil The stat selected for focused salvaging (if applicable).
-- @return boolean True if the salvage request was successfully sent, false otherwise.
function RequestSalvageItem(itemSlot, backpackType, salvagingType, selectedStat)   end
---
-- @desc Resets the guild's heraldry design to default.
function ResetGuildHeraldry()   end
---
--- Respecs (refunds) spent guild tactic points.
---@usage Called from ea_guildwindow/source/guildrespectacticslist.lua
function RespecGuildTactics()   end
---
-- @desc Restores all key bindings to their default settings.
function RestoreDefaultBindings()   end
---
-- @desc Reverts all currently previewed dye changes on the character model.
function RevertAllDyePreview()   end
---
-- @desc Reverts a dye preview on a specific item slot.
-- @param location number The item location ID (e.g., GameData.ItemLocs.EQUIPPED).
-- @param slot number The slot index.
function RevertDyePreview(location, slot)   end
---
-- @desc Reverts any temporary player appearance variations being previewed.
function RevertPlayerVariation()   end

------- #S -------

-- @desc Debug utility: Prints the current Lua call stack trace to the log.
-- @param startLevel number|nil (Optional) The stack level to start tracing from (default is 2).
function SHOW_STACK_TRACE(startLevel)   end
---
-- @desc Debug utility: Prints a simplified Lua stack traceback to the log.
function SIMPLE_STACK_TRACE()   end
---
-- @desc Debug hook function: Logs the start of a function call. Used internally by debug system.
-- @param event string The debug event type ("call").
-- @param line number The line number where the call occurred.
function START_FUNCTION(event, line)   end
---
-- @desc Saves the current arrangement of tactics to a specific tactics set index.
-- @param setId number The index of the tactics set to save (0 to MAX_TACTICS_SETS - 1).
-- @param tacticsTable table A list of tactic ability IDs to save in the set.
function SaveTacticsSet(setId, tacticsTable)   end
---
---@desc Selects rewards from a Live Event.
---@param eventId number The ID of the Live Event.
---@param rewardIds table A table of chosen reward IDs.
---@usage Called from ea_interactionwindow/source/interactioneventrewards.lua
function SelectEventRewards(eventId, rewardIds)   end
---
-- @desc Selects a specific reward from an influence level.
-- @param level number The influence level index.
-- @param rewardIndex number The index/ID of the reward being selected.
function SelectInfluenceReward(level, rewardIndex)   end
---
-- @desc Makes a choice (Need, Greed, Pass) on a loot roll item.
-- @param sourceId number The source ID of the loot roll (e.g., corpse ID).
-- @param lootSlot number The slot index of the item being rolled on.
-- @param rollChoice number The choice constant (e.g., EA_Window_LootRoll.ROLL_CHOICE_PASS).
function SelectItemRollChoice(sourceId, lootSlot, rollChoice)   end
---
-- @desc Selects a game server to connect to during the pre-game sequence. (Usage not found for documentation)
-- @param serverId number The ID of the server to select.
function SelectServer(serverId)   end
---
---@desc Sends an auction house search query to the server.
---@param filters table A table containing search filter criteria.
---@usage Called from ea_auctionhousewindow/source/auctionwindowlistdatamanager.lua
function SendAuctionSearch(filters)   end
---
-- @desc Sends the configuration data for a guild banner to the server.
-- @param bannerNum number The index of the banner being configured.
-- @param configData table A table containing the banner configuration details.
function SendBannerConfigurationData(bannerNum, configData)   end
---
-- @desc Sends a bug report to the server.
-- @param reportType number The type ID of the bug report category.
-- @param reportText string The text content of the bug report.
function SendBugReport(reportType, reportText)   end
---
-- @desc Sends a chat message or slash command to the server.
-- @param text string The chat message or slash command (e.g., "/invite PlayerName").
-- @param channel string The target chat channel (often empty for commands).
function SendChatText(text, channel)   end
---
-- @desc Notifies the server that a crafting session is ending.
-- @param tradeskillId number The ID of the tradeskill whose session is closing.
function SendCloseCrafting(tradeskillId)   end
---
---@desc Sends the player's chosen custom icon for an item (e.g., macro) to the server.
---@param itemLocation number The location ID of the item.
---@param itemSlot number The slot index of the item.
---@param iconId number The chosen icon ID.
---@usage Called from ea_characterwindow/source/characterwindowitemappearance.lua
function SendCustomizeItemIcon(itemLocation, itemSlot, iconId)   end
---
-- @desc Sends a command related to guild alliances.
-- @param commandId number The ID of the alliance command (e.g., GuildWindowTabAlliance.COMMAND_POLL_CREATE).
-- @param guildId number|nil The target guild ID (if applicable).
-- @param pollId number|nil The target poll ID (if applicable).
-- @param voteValue number|nil The vote value (0 or 1, if applicable).
function SendGuildAllianceCommand(commandId, guildId, pollId, voteValue)   end
---
-- @desc Sends a command related to guild calendar appointments.
-- @param commandId number The ID of the appointment command (e.g., GuildWindowTabCalendar.APPOINTMENT_ADD).
-- @param ... any Additional parameters specific to the command (appointment details).
function SendGuildAppointmentData(commandId, ...)   end
---
-- @desc Sends a command related to the guild vault.
-- @param commandId number The ID of the vault command (e.g., SystemData.GuildVaultCommands.MOVE_ITEM).
-- @param ... any Additional parameters specific to the command (vault index, slot, money, etc.).
function SendGuildVaultCommand(commandId, ...)   end
---
-- @desc Sends a help request (Feedback, Appeal, Bug Report) to the server.
-- @param helpType number The type ID of the help request (GameData.HelpType).
-- @param ... any Up to 11 additional string/number parameters specific to the help type.
function SendHelpMessage(helpType, ...)   end
---
-- @desc Sends the chosen guild heraldry configuration to the server.
-- @param emblemId number The ID of the chosen emblem.
-- @param patternId number The ID of the chosen pattern.
-- @param primaryColor table The primary color {r, g, b}.
-- @param secondaryColor table The secondary color {r, g, b}.
-- @param tertiaryColor table The tertiary color {r, g, b}.
function SendHeraldryConfigurationData(emblemId, patternId, primaryColor, secondaryColor, tertiaryColor)   end
---
-- @desc Notifies the server that a crafting session is starting.
-- @param tradeskillId number The ID of the tradeskill whose session is starting.
function SendInitCrafting(tradeskillId)   end
---
-- @desc Sends a command related to the mailbox.
-- @param commandId number The ID of the mailbox command (e.g., MailWindow.MAILBOX_SEND).
-- @param mailboxType number The type of mailbox (GameData.MailboxType).
-- @param ... any Additional parameters specific to the command (message ID, recipient, subject, etc.).
function SendMailboxCommand(commandId, mailboxType, ...)   end
---
-- @desc Sends a request for the list of nearby open parties.
-- @param requestType number The type of list requested (e.g., GameData.OpenPartyRequestType.ALL).
function SendOpenPartySearchRequest(requestType)   end
---
-- @desc Sends a search request for open parties across the world/server based on criteria.
-- @param tier number The desired tier.
-- @param interestType number The general interest type ID.
-- @param specificInterest1 number The first specific interest ID (zone/scenario).
-- @param specificInterest2 number The second specific interest ID.
-- @param specificInterest3 number The third specific interest ID.
-- @param specificInterest4 number The fourth specific interest ID.
function SendOpenPartyWorldSearch(tier, interestType, specificInterest1, specificInterest2, specificInterest3, specificInterest4)   end
---
-- @desc Sends a request to inspect the currently targeted player.
function SendPlayerInspectionRequest()   end
---
-- @desc Sends a player search request to the server based on criteria.
-- @param playerName string The player name filter.
-- @param guildName string The guild name filter.
-- @param zoneId number The zone ID filter.
-- @param minRank number The minimum rank filter.
-- @param maxRank number The maximum rank filter.
-- @param careerId number The career ID filter.
function SendPlayerSearchRequest(playerName, guildName, zoneId, minRank, maxRank, careerId)   end
---
-- @desc Sends the player's response to a survey.
-- @param surveyId number The ID of the survey.
-- @param eventType number The type of event triggering the survey.
-- @param objectId number The ID of the related object (if any).
-- @param objectName string The name of the related object (if any).
-- @param commentText string The player's comment text.
-- @param submitted boolean True if submitting the survey, false if declining.
function SendSurveyResponse(surveyId, eventType, objectId, objectName, commentText, submitted)   end
---
-- @desc Requests to use an item from a specific location/slot, potentially on a target.
-- @param sourceLocation number The location ID of the item being used.
-- @param sourceSlot number The slot index of the item being used.
-- @param abilityId number|nil (Optional) Ability ID if the item use triggers one (usually 0).
-- @param targetLocation number|nil (Optional) Target location ID if using on another item (usually 0).
-- @param targetSlot number|nil (Optional) Target slot index if using on another item (usually 0).
function SendUseItem(sourceLocation, sourceSlot, abilityId, targetLocation, targetSlot)   end
---
-- @desc Sets the player's advisor flag preference.
-- @param isAdvisor boolean True to enable the advisor flag, false to disable.
function SetAdvisorFlag(isAdvisor)   end
---
-- @desc Sets a specific bragging right slot to display a tome entry.
-- @param index number The index of the bragging right slot (1-based?).
-- @param entryId number The ID of the tome entry to display.
function SetBraggingRight(index, entryId)   end
---
-- @desc Sets the visual card displayed for bragging rights. (Usage not found for documentation)
-- @param cardId number The ID of the card to display.
function SetBraggingRightsCard(cardId)   end
---
-- @desc Sets the images displayed for the three career mastery paths.
-- @param imagePath1 string The file path for the first mastery path image.
-- @param imagePath2 string The file path for the second mastery path image.
-- @param imagePath3 string The file path for the third mastery path image.
function SetCareerMasteryImages(imagePath1, imagePath2, imagePath3)   end
---
-- @desc Changes the appearance of the mouse cursor.
-- @param textureName string The name of the texture file for the new cursor.
function SetCursor(textureName)   end
---
-- @desc Sets the desired interaction action, changing the cursor appearance and behavior.
-- @param actionId number The interaction action constant (e.g., SystemData.InteractActions.REPAIR).
function SetDesiredInteractAction(actionId)   end
---
-- @desc Toggles the visibility of an equipped item (Helm or Cloak).
-- @param slotId number The equipment slot ID (GameData.EquipSlots.HELM or GameData.EquipSlots.BACK).
-- @param visible boolean True to show the item, false to hide.
function SetEquippedItemVisible(slotId, visible)   end
---
-- @desc Sets the group's auto-loot setting specifically for RvR scenarios.
-- @param autoLoot boolean True to enable auto-loot in RvR, false to disable.
function SetGroupAutoLootInRvR(autoLoot)   end
---
-- @desc Sets the group's loot distribution mode.
-- @param modeId number The ID of the loot mode (e.g., GameData.LootMode.ROUND_ROBIN).
function SetGroupLootMode(modeId)   end
---
-- @desc Sets the item quality threshold for group loot rolls.
-- @param thresholdId number The ID of the quality threshold (e.g., GameData.LootThreshold.UNCOMMON).
function SetGroupLootThreshold(thresholdId)   end
---
-- @desc Toggles the "Need Before Greed on Use" setting for the group.
-- @param needOnUse boolean True to enable Need Before Greed on Use, false otherwise.
function SetGroupNeedMode(needOnUse)   end
---
-- @desc Updates the 3D preview scene for the guild heraldry editor.
-- @param patternId number The ID of the selected pattern.
-- @param primaryColor table The selected primary color {r, g, b}.
-- @param secondaryColor table The selected secondary color {r, g, b}.
-- @param emblemId number The ID of the selected emblem.
-- @param updateStandard boolean True if the guild standard preview should also be updated.
function SetGuildHeraldryScene(patternId, primaryColor, secondaryColor, emblemId, updateStandard)   end
---
-- @desc Updates the 3D preview scene for the guild standard (banner).
-- @param postId number The ID of the selected banner post/pole.
function SetGuildStandardScene(postId)   end
---
-- @desc Changes the hardware mouse cursor displayed by the OS.
-- @param cursorType number The cursor type constant (e.g., SystemData.Cursor.RESIZE2).
function SetHardwareCursor(cursorType)   end
---
-- @desc Assigns an action (ability, item, macro, etc.) to a specific hotbar slot.
-- @param slotIndex number The index of the hotbar slot (-1 for first available?).
-- @param actionType number The type ID of the action (GameData.PlayerActions).
-- @param actionId number The ID of the specific ability, item, or macro.
function SetHotbarData(slotIndex, actionType, actionId)   end
---
-- @desc Maps a physical hotbar page index to a logical hotbar page index.
-- @param physicalPageIndex number The index of the physical hotbar (1-based?).
-- @param logicalPageIndex number The index of the logical hotbar page to display.
function SetHotbarPage(physicalPageIndex, logicalPageIndex)   end
---
-- @desc Sets the image associated with a specific task within a live event.
-- @param eventId number The ID of the live event.
-- @param taskId number The ID of the task.
function SetLiveEventTaskImage(eventId, taskId)   end
---
-- @desc Saves or updates a player-defined macro.
-- @param name string The name of the macro.
-- @param text string The text content (commands) of the macro.
-- @param iconNum number The icon number chosen for the macro.
-- @param macroId number The ID of the macro being updated (or 0/nil for a new macro?).
function SetMacroData(name, text, iconNum, macroId)   end
---
-- @desc Assigns a morale ability to a specific morale level slot on the morale bar.
-- @param moraleLevel number The morale level (1-4).
-- @param abilityId number The ID of the morale ability to assign (0 to clear).
function SetMoraleBarData(moraleLevel, abilityId)   end
---
-- @desc Sets the font files used for player/NPC names and titles in the game world.
-- @param namesFont string The filename of the font for names.
-- @param titlesFont string The filename of the font for titles.
function SetNamesAndTitlesFont(namesFont, titlesFont)   end
---
-- @desc Sets the player's interests for the world-wide open party system.
-- @param tier number The desired tier.
-- @param interestType number The general interest type ID.
-- @param specificInterest1 number The first specific interest ID (zone/scenario).
-- @param specificInterest2 number The second specific interest ID.
-- @param specificInterest3 number The third specific interest ID.
-- @param specificInterest4 number The fourth specific interest ID.
function SetOpenPartyWorldInterests(tier, interestType, specificInterest1, specificInterest2, specificInterest3, specificInterest4)   end
---
-- @desc Sets the zoom level of the overhead map.
-- @param zoomLevel number The desired zoom level.
function SetOverheadMapZoomLevel(zoomLevel)   end
---
-- @desc Sets the background image for the player's portrait. (Usage not found for documentation)
-- @param backgroundName string The name or path of the background image.
function SetPlayerPortraitBackground(backgroundName)   end
---
-- @desc Applies a temporary appearance variation to the player model (e.g., for item previews).
-- @param slotId number The equipment slot ID of the item causing the variation.
function SetPlayerVariation(slotId)   end
---
-- @desc Highlights the currently sorted column in the scenario summary list.
-- @param rowIndex number The index of the row being processed.
-- @param rowName string The base name of the row window elements.
-- @param sortType number The ID of the currently active sort type/column.
function SetSelectedColumnColor(rowIndex, rowName, sortType)   end
---
-- @desc Sets the background image for the target's portrait. (Usage not found for documentation)
-- @param backgroundName string The name or path of the background image.
function SetTargetPortraitBackground(backgroundName)   end
---
-- @desc Specifies the target player for a subsequent summon item use.
-- @param playerName string The name of the player to be summoned.
function SetTargetToSummon(playerName)   end
---
---@desc Sets the image displayed by a texture UI element.
---@param windowName string The name of the texture window.
---@param texturePath string The path to the texture file.
---@usage Called from ea_helpwindow/source/tutorialwindow.lua
function SetTextureImage(windowName, texturePath)   end
---
-- @desc Toggles whether a specific quest is tracked in the quest tracker UI.
-- @param questId number The ID of the quest.
-- @param track boolean True to track the quest, false to untrack.
function SetTrackQuest(questId, track)   end
---
-- @desc Toggles whether a specific quest's objective pin is shown on the map.
-- @param questId number The ID of the quest.
-- @param showPin boolean True to show the map pin, false to hide.
function SetTrackQuestPin(questId, showPin)   end
---
-- @desc Gets a formatted string representing the Shaman's current Waaagh! points.
-- @param self table The Shaman career resource data object.
-- @return string The formatted points string (e.g., "Healing Waaagh!: 50/100").
function Shaman_GetPointsString(self)   end
---
-- @desc Initiates sharing the specified quest with group members.
-- @param questId number The ID of the quest to share.
function ShareQuest(questId)   end
---
-- @desc Sets the image displayed for the siege weapon wind direction indicator.
-- @param windowName string The name of the image window element.
function SiegeSetWindDirectionImage(windowName)   end
---
-- @desc Splits a standard string into a table of substrings based on a delimiter.
-- @param inString string The input string.
-- @param delimiter string The delimiter character(s).
-- @return table A list of substrings.
function StringSplit(inString, delimiter)   end
---
-- @desc Compares two standard strings lexicographically.
-- @param string1 string The first string.
-- @param string2 string The second string.
-- @return number -1 if string1 < string2, 0 if equal, 1 if string1 > string2.
function StringsCompare(string1, string2)   end
---
-- @desc Swaps the positions of two tactics within the player's active set. (Usage not found for documentation)
-- @param tacticId1 number|nil ID or slot index of the first tactic.
-- @param tacticId2 number|nil ID or slot index of the second tactic.
function SwapActiveTactic(tacticId1, tacticId2)   end
---
-- @desc Switches the displayed category in a store window.
-- @param categoryId number The server-side ID of the category to display.
function SwitchStoreCategories(categoryId)   end
---
-- @desc Gets a formatted string representing the Swordmaster's current balance points.
-- @param self table The Swordmaster career resource data object.
-- @return string The formatted balance points string.
function Swordmaster_GetPointsString(self)   end

------- #T -------

-- @desc Debug hook function: Logs line-by-line execution trace. Used internally by debug system.
-- @param event string The debug event type ("line").
-- @param line number The line number being executed.
function TRACE(event, line)   end
---
-- @desc Captures a screenshot of the game and saves it in the /screenshots directory.
function TakeScreenShot()   end
---
-- @desc Toggles the input language state (simulates Shift+Alt).
function ToggleLanguageState()   end
---
-- @desc Retrieves detailed data for a specific achievement entry in the Tome of Knowledge.
-- @param entryId number The ID of the achievement entry.
-- @return table|nil A table containing the achievement entry data, or nil if not found.
function TomeGetAchievementsEntryData(entryId)   end
---
-- @desc Retrieves data for a specific achievement subtype (category) in the Tome of Knowledge.
-- @param subTypeId number The ID of the achievement subtype.
-- @return table|nil A table containing the achievement subtype data, or nil if not found.
function TomeGetAchievementsSubTypeData(subTypeId)   end
---
-- @desc Retrieves the Table of Contents data for the Achievements section of the Tome.
-- @return table|nil A table containing the Achievements TOC data, or nil if empty/error.
function TomeGetAchievementsTOC()   end
---
-- @desc Retrieves detailed data for a specific bestiary species entry in the Tome of Knowledge.
-- @param speciesId number The ID of the bestiary species.
-- @return table|nil A table containing the bestiary species data, or nil if not found.
function TomeGetBestiarySpeciesData(speciesId)   end
---
-- @desc Retrieves data for a specific bestiary subtype (category) in the Tome of Knowledge.
-- @param subTypeId number The ID of the bestiary subtype.
-- @return table|nil A table containing the bestiary subtype data, or nil if not found.
function TomeGetBestiarySubTypeData(subTypeId)   end
---
-- @desc Retrieves the Table of Contents data for the Bestiary section of the Tome.
-- @return table|nil A table containing the Bestiary TOC data, or nil if empty/error.
function TomeGetBestiaryTOC()   end
---
-- @desc Retrieves data for a specific Tome Card.
-- @param cardId number The ID of the Tome Card.
-- @return table|nil A table containing the card data, or nil if not found.
function TomeGetCardData(cardId)   end
---
-- @desc Retrieves the list of all Tome Cards unlocked by the player.
-- @return table A list of unlocked Tome Card data tables.
function TomeGetCardList()   end
---
-- @desc Retrieves detailed data for a specific History & Lore entry in the Tome of Knowledge.
-- @param entryId number The ID of the History & Lore entry.
-- @return table|nil A table containing the entry data, or nil if not found.
function TomeGetHistoryAndLoreEntryData(entryId)   end
---
-- @desc Retrieves the Table of Contents data for the History & Lore section of the Tome.
-- @return table|nil A table containing the History & Lore TOC data, or nil if empty/error.
function TomeGetHistoryAndLoreTOC()   end
---
-- @desc Retrieves History & Lore entries specific to a particular zone.
-- @param zoneId number The ID of the zone.
-- @return table|nil A table containing zone-specific History & Lore entry data, or nil if none.
function TomeGetHistoryAndLoreZoneData(zoneId)   end
---
-- @desc Retrieves data for a specific item reward available through the Tome of Knowledge.
-- @param itemId number The ID of the item reward.
-- @return table|nil A table containing the item reward data, or nil if not found.
function TomeGetItemRewardData(itemId)   end
---
-- @desc Retrieves the list of all available item rewards from the Tome of Knowledge.
-- @return table A list of item reward data tables.
function TomeGetItemRewardsList()   end
---
-- @desc Retrieves detailed data for a specific Noteworthy Person entry in the Tome of Knowledge.
-- @param entryId number The ID of the Noteworthy Person entry.
-- @return table|nil A table containing the entry data, or nil if not found.
function TomeGetNoteworthyPersonsEntryData(entryId)   end
---
-- @desc Retrieves the Table of Contents data for the Noteworthy Persons section of the Tome.
-- @return table|nil A table containing the Noteworthy Persons TOC data, or nil if empty/error.
function TomeGetNoteworthyPersonsTOC()   end
---
-- @desc Retrieves Noteworthy Persons entries specific to a particular zone.
-- @param zoneId number The ID of the zone.
-- @return table|nil A table containing zone-specific Noteworthy Persons entry data, or nil if none.
function TomeGetNoteworthyPersonsZoneData(zoneId)   end
---
-- @desc Retrieves data for a specific Old World Armory armor set.
-- @param armorSetId number The ID of the armor set.
-- @return table|nil A table containing the armor set data, or nil if not found.
function TomeGetOldWorldArmoryArmorSet(armorSetId)   end
---
-- @desc Retrieves the Table of Contents data for the Old World Armory section of the Tome.
-- @return table|nil A table containing the Old World Armory TOC data, or nil if empty/error.
function TomeGetOldWorldArmoryTOC()   end
---
-- @desc Retrieves the Table of Contents data for a specific tier within the Old World Armory section (likely for sigils).
-- @return table|nil A table containing the tier-specific TOC data, or nil if empty/error.
function TomeGetOldWorldArmoryTierTOC()   end
---
-- @desc Retrieves data for a specific player title.
-- @param titleId number The ID of the title.
-- @return table|nil A table containing the title data, or nil if not found.
function TomeGetPlayerTitleData(titleId)   end
---
-- @desc Retrieves a list of available player title types (categories).
-- @return table|nil A list of title type data tables, or nil if none.
function TomeGetPlayerTitlesAvailiableTypes()   end
---
-- @desc Retrieves the list of player titles belonging to a specific type (category).
-- @param typeId number The ID of the title type.
-- @return table|nil A list of title data tables for that type, or nil if none.
function TomeGetPlayerTitlesTypeData(typeId)   end
---
-- @desc Gets display information (icon, name, tooltip) for a specific sigil entry ID.
-- @param sigilEntryId number The ID of the sigil entry.
-- @return table|nil A table containing display info for the sigil, or nil if not found.
function TomeGetSigilDisplayInfo(sigilEntryId)   end
---
-- @desc Retrieves detailed data for a specific sigil entry in the Tome of Knowledge.
-- @param sigilEntryId number The ID of the sigil entry.
-- @return table|nil A table containing the sigil entry data, or nil if not found.
function TomeGetSigilEntry(sigilEntryId)   end
---
-- @desc Retrieves the Table of Contents data for the Sigils section of the Tome.
-- @return table|nil A table containing the Sigils TOC data, or nil if empty/error.
function TomeGetSigilTOC()   end
---
-- @desc Retrieves information about a tactic counter (unlock progress).
-- @param counterId number The ID of the tactic counter.
-- @return string tacticLineName The name of the associated tactic line.
-- @return number progress The current progress value of the counter.
-- @return table rewardData Data about the reward unlocked by the counter.
function TomeGetTacticCounter(counterId)   end
---
-- @desc Retrieves the reward data associated with a specific tactic counter reward ID.
-- @param rewardId number The ID of the tactic counter reward.
-- @return table|nil A table containing the reward data, or nil if not found.
function TomeGetTacticCounterRewardData(rewardId)   end
---
-- @desc Retrieves data for a specific tactic reward available through the Tome of Knowledge.
-- @param rewardId number The ID of the tactic reward.
-- @return table|nil A table containing the tactic reward data, or nil if not found.
function TomeGetTacticRewardData(rewardId)   end
---
-- @desc Retrieves the list of all available tactic rewards from the Tome of Knowledge.
-- @return table A list of tactic reward data tables.
function TomeGetTacticRewardsList()   end
---
-- @desc Retrieves the list of available storylines for the War Journal section of the Tome.
-- @return table|nil A list of available storyline data tables, or nil if none.
function TomeGetWarJournalAvailiableStorylines()   end
---
-- @desc Retrieves detailed data for a specific War Journal entry.
-- @param entryId number The ID of the War Journal entry.
-- @return table|nil A table containing the entry data, or nil if not found.
function TomeGetWarJournalEntryData(entryId)   end
---
-- @desc Retrieves the War Journal entry ID associated with a glyph activity in a specific zone.
-- @param zoneId number The ID of the zone.
-- @return number|nil The ID of the associated War Journal entry, or nil if none.
function TomeGetWarJournalGlyphEntryForZone(zoneId)   end
---
-- @desc Retrieves data for a specific War Journal storyline.
-- @param storylineId number The ID of the storyline.
-- @return table|nil A table containing the storyline data, or nil if not found.
function TomeGetWarJournalStorylineData(storylineId)   end
---
-- @desc Checks if a specific achievement entry has been unlocked by the player. (Usage not found for documentation)
-- @param entryId number The ID of the achievement entry.
-- @return boolean True if unlocked, false otherwise.
function TomeIsAchievementsEntryUnlocked(entryId)   end
---
-- @desc Checks if a specific achievement subtype (category) has been unlocked. (Usage not found for documentation)
-- @param subTypeId number The ID of the achievement subtype.
-- @return boolean True if unlocked, false otherwise.
function TomeIsAchievementsSubTypeUnlocked(subTypeId)   end
---
-- @desc Checks if a specific bestiary species entry has been unlocked by the player.
-- @param speciesId number The ID of the bestiary species.
-- @return boolean True if unlocked, false otherwise.
function TomeIsBestiarySpeciesUnlocked(speciesId)   end
---
-- @desc Checks if a specific bestiary subtype (category) has been unlocked.
-- @param subTypeId number The ID of the bestiary subtype.
-- @return boolean True if unlocked, false otherwise.
function TomeIsBestiarySubTypeUnlocked(subTypeId)   end
---
-- @desc Checks if a specific History & Lore entry has been unlocked.
-- @param entryId number The ID of the History & Lore entry.
-- @return boolean True if unlocked, false otherwise.
function TomeIsHistoryAndLoreEntryUnlocked(entryId)   end
---
-- @desc Checks if a specific Noteworthy Person entry has been unlocked.
-- @param entryId number The ID of the Noteworthy Person entry.
-- @return boolean True if unlocked, false otherwise.
function TomeIsNoteworthyPersonsEntryUnlocked(entryId)   end
---
-- @desc Checks if a specific player title has been unlocked. (Usage not found for documentation)
-- @param titleId number The ID of the title.
-- @return boolean True if unlocked, false otherwise.
function TomeIsPlayerTitleUnlocked(titleId)   end
---
-- @desc Checks if a specific War Journal entry has been unlocked.
-- @param entryId number The ID of the War Journal entry.
-- @return boolean True if unlocked, false otherwise.
function TomeIsWarJournalEntryUnlocked(entryId)   end
---
-- @desc Checks if a specific War Journal storyline has been unlocked.
-- @param storylineId number The ID of the storyline.
-- @return boolean True if unlocked, false otherwise.
function TomeIsWarJournalStorylineUnlocked(storylineId)   end
---
-- @desc Sets the image displayed for an achievement subtype in the Tome.
-- @param subTypeId number The ID of the achievement subtype.
function TomeSetAchievementsSubTypeImage(subTypeId)   end
---
-- @desc Sets the player's currently active title.
-- @param titleId number The ID of the title to activate (0 to clear).
function TomeSetActivePlayerTitle(titleId)   end
---
-- @desc Sets the image displayed for a bestiary species entry in the Tome.
-- @param speciesId number The ID of the bestiary species.
function TomeSetBestiarySpeciesImage(speciesId)   end
---
-- @desc Sets the image displayed for a bestiary subtype (category) in the Tome. (Usage not found for documentation)
-- @param subTypeId number The ID of the bestiary subtype.
function TomeSetBestiarySubTypeImage(subTypeId)   end
---
-- @desc Sets the image displayed for a War Journal entry in the Tome.
-- @param entryId number The ID of the War Journal entry.
function TomeSetWarJournalEntryImage(entryId)   end
---
-- @desc Sets the image displayed for a War Journal glyph activity.
-- @param glyphId number The ID of the glyph activity.
function TomeSetWarJournalGlyphImage(glyphId)   end
---
-- @desc Filter function to check if player meets rank requirement for a training advancement.
-- @param advanceData table The data table for the training advancement.
-- @return boolean True if player meets rank requirement, false otherwise.
function TrainerHasSufficientRankFilter(advanceData)   end
---
-- @desc Transfers an item stack between different backpack types (Inventory, Bank, Guild Vault).
-- @param slotIndex number The index of the item slot in the source backpack.
-- @param sourceMode number The source backpack type ID.
function TransferBetweenBackpacks(slotIndex, sourceMode)   end

------- #U -------

---
-- @desc Retrieves or sets information about a game unit (player, NPC). Likely internal to TargetInfo system.
-- @param unitId number|string The identifier for the unit.
-- @param ... any (Optional) Data to set for the unit.
-- @return table|nil Unit information table, or nil if not found.
function UnitInfo(unitId, ...)   end
---
-- @desc Clears the player's set interests for the world-wide open party system.
function UnsetOpenPartyWorldInterests()   end
---
-- @desc Updates the crafting UI based on server events or player actions. Can be an event handler or called internally.
-- @param ... any Varies depending on context (updatedIngredients table, command IDs, etc.).
function UpdateCraftingStatus(...)   end
---
-- @desc Decrements the remaining duration of temporary item enhancements. Called periodically.
-- @param timePassed number The time elapsed since the last update.
function UpdateEnhancementDurations(timePassed)   end
---
---@desc Initiates an equipment upgrade process.
---@param itemSlot number|nil The slot of the item to upgrade.
---@param ... any (Optional) Upgrade materials, currency, etc.
---@usage Called from ea_craftingwindow/source/equipmentupgradewindow.lua
function UpgradeEquipment(itemSlot, ...)   end
---
-- @desc Triggers the "Use:" effect of an item. (Usage not found for exact call signature)
-- @param itemLocation number|nil The location ID of the item.
-- @param itemSlot number|nil The slot index of the item.
function UseEffect(itemLocation, itemSlot)   end

------- #V -------

---
-- @desc Checks if the in-game video player is currently playing a video.
-- @return boolean True if a video is playing, false otherwise.
function VideoPlayerIsPlaying()   end

------- #W -------

---
-- @desc Splits a wide string (wstring) into a table of substrings based on a delimiter.
-- @param inString wstring The input wide string.
-- @param delimiter wstring The delimiter wide string.
-- @return table A list of wide string substrings.
function WStringSplit(inString, delimiter)   end
---
-- @desc Compares two wide strings (wstring) lexicographically.
-- @param string1 wstring The first wide string.
-- @param string2 wstring The second wide string.
-- @return number -1 if string1 < string2, 0 if equal, 1 if string1 > string2.
function WStringsCompare(string1, string2)   end
---
-- @desc Compares two wide strings (wstring) lexicographically, ignoring grammatical variations (case, accents).
-- @param string1 wstring The first wide string.
-- @param string2 wstring The second wide string.
-- @return number -1 if string1 < string2, 0 if equal, 1 if string1 > string2.
function WStringsCompareIgnoreGrammer(string1, string2)   end
---
-- @desc Removes potential grammatical markers (likely first character based on implementation) from a wide string.
-- @param inputString wstring The input wide string.
-- @return wstring The modified wide string.
function WStringsRemoveGrammar(inputString)   end
---
-- @desc Converts data of various types (number, boolean, string, nil) into a wide string representation.
-- @param data any The input data.
-- @return wstring The wide string representation of the data.
function WideStringFromData(data)   end
---
-- @desc Converts 3D world coordinates to 2D screen coordinates. (Usage not found for documentation)
-- @param worldX number The world X-coordinate.
-- @param worldY number The world Y-coordinate.
-- @param worldZ number The world Z-coordinate.
-- @return number screenX The calculated screen X-coordinate.
-- @return number screenY The calculated screen Y-coordinate.
-- @return boolean onScreen True if the point is on screen, false otherwise.
function WorldToScreen(worldX, worldY, worldZ)   end

------- #_ -------

---
-- @desc Internal function: Gets the color defined for hyperlinks within a Label UI element. (Usage not found for documentation)
-- @param windowName string The name of the Label window.
---@return number r The red color component (0-255).
---@return number g The green color component (0-255).
---@return number b The blue color component (0-255).
function _LabelGetLinkColor(windowName)   end
---
-- @desc Internal function: Gets the current text content of a Label UI element. (Usage not found for documentation)
-- @param windowName string The name of the Label window.
-- @return string The text content.
function _LabelGetText(windowName)   end
---
-- @desc Internal function: Gets the current text color of a Label UI element. (Usage not found for documentation)
-- @param windowName string The name of the Label window.
-- @return table The text color {r, g, b}.
function _LabelGetTextColor(windowName)   end
---
-- @desc Internal function: Gets the calculated dimensions of the text within a Label UI element. (Usage not found for documentation)
-- @param windowName string The name of the Label window.
-- @return number width The calculated text width.
-- @return number height The calculated text height.
function _LabelGetTextDimensions(windowName)   end
---
-- @desc Internal function: Gets the current dimensions of a UI window. (Usage not found for documentation)
-- @param windowName string The name of the window.
-- @return number width The window width.
-- @return number height The window height.
function _WindowGetDimensions(windowName)   end
---
-- @desc Internal function: Checks if a UI window is currently visible. (Usage not found for documentation)
-- @param windowName string The name of the window.
-- @return boolean True if the window is showing, false otherwise.
function _WindowGetShowing(windowName)   end

------- # -------

---
-- @desc Utility function: Converts a boolean value (or nil) to its string representation ("true", "false", "nil").
-- @param bool boolean|nil The input boolean or nil value.
-- @return string The string representation.
function booltostring(bool)   end
---
-- @desc Debug utility: Shorthand for dumping variables or printing debug messages. (Exact behavior unknown)
-- @param ... any Arguments to dump or print.
function d(...)   end
---
-- @desc Debug utility: Shorthand for dumping tables. (Exact behavior unknown)
-- @param tbl table The table to dump.
function dt(tbl)   end
---
-- @desc Debug utility: Wrapper for standard Lua assert, potentially adding extra debug info.
-- @param condition any The condition to assert.
-- @param message string|nil (Optional) Message to display if assertion fails.
function luaAssert(condition, message)   end
---
-- @desc Utility function: Converts various data types (number, boolean, string, nil) into a wide string (wstring).
-- @param data any The input data.
-- @return wstring The wide string representation.
function towstring(data)   end
