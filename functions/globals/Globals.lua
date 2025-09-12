---@meta

---@return nil @Abandon the current quest.
function AbandonQuest()   end
---@return nil @Accept the current trade offer.
function AcceptTrade()   end
---@return number @Gets the icon ID for an action button group.
function ActionButtonGroupGetIcon()   end
---@return number @Gets the ID for an action button group.
function ActionButtonGroupGetId()   end
---@return boolean @Checks if an action button group is showing.
function ActionButtonGroupGetShowing()   end
---@param id number @Sets the ID for an action button group.
---@return nil
function ActionButtonGroupSetId(id)   end
---@param showing boolean @Sets the showing state for an action button group.
---@return nil
function ActionButtonGroupSetShowing(showing)   end
---@param tacticsList table @Activates a list of tactics.
---@return nil
function ActivateTactics(tacticsList)   end
---@param tacticId number @The ID of the tactic to add.
---@return nil @Adds an active tactic.
function AddActiveTactic(tacticId)   end
---@param action number @Adds a key binding for an action.
---@param deviceId number
---@param buttons table
---@return nil
function AddBinding(action, deviceId, buttons)   end
---@param tradeSkill number @Adds a crafting container.
---@param backpackSlot number
---@param backpackType number
---@return nil
function AddCraftingContainer(tradeSkill, backpackSlot, backpackType)   end
---@param tradeSkill number @Adds a crafting item.
---@param slotNum number
---@param backpackSlot number
---@param backpackType number
---@return nil
function AddCraftingItem(tradeSkill, slotNum, backpackSlot, backpackType)   end
---@param enhancementSlotId number @Adds an item enhancement.
---@param sourceSlot number
---@return nil
function AddItemEnhancement(enhancementSlotId, sourceSlot)   end
---@param reward any @Adds a selected reward.
---@return nil
function AddSelectedReward(reward)   end
---@param playerName string @Adds a player to the temporary ignore list.
---@return nil
function AddTemporaryIgnore(playerName)   end
---@param slot number @Applies a player variation based on a slot.
---@return nil
function ApplyPlayerVariation(slot)   end
---@param self any @Gets the points string for the Archmage career.
---@return string
function ArchMage_GetPointsString(self)   end
---@param slot number @Assigns a loot item to a slot.
---@param name string
---@return nil
function AssignLootItem(slot, name)   end
---@return nil @Attaches a trophy to a location.
function AttachTrophyToLocation()   end
---@return nil @Attaches a window to a world object.
function AttachWindowToWorldObject()   end
---@param inventorySlot number @Automatically equips an item from an inventory slot.
---@return nil
function AutoEquipItem(inventorySlot)   end
---@return boolean @Checks if barbershop features have changed.
function BarbershopHaveFeaturesChanged()   end
---@return nil @Resets barbershop features.
function BarbershopResetFeatures()   end
---@return nil @Sets a barbershop feature.
function BarbershopSetFeature()   end
---@return nil @Submits barbershop features.
function BarbershopSubmitFeatures()   end
---@param slot number @Begins the item enhancement process for a slot.
---@return nil
function BeginItemEnhancement(slot)   end
---@param weaponId number @Builds a siege weapon.
---@return nil
function BuildSiegeWeapon(weaponId)   end
---@return nil @Buys an item from the auction house.
function BuyAuction()   end
---@return nil @Buys additional backpack slots.
function BuyBackpackSlots()   end
---@return nil @Buys additional bank slots.
function BuyBankSlots()   end
---@param tier number @Buys a career package.
---@param category number
---@param packageID number
---@return nil
function BuyCareerPackage(tier, category, packageID)   end
---@param tradeSkill number @Buys a trade skill.
---@param conflictingSkill number
---@return nil
function BuyTradeSkill(tradeSkill, conflictingSkill)   end
---@param text string @Logs a debug message to the chat.
---@return nil
function CHAT_DEBUG(text)   end
---@param actionType number @Caches data associated with an action.
---@param actionId number
---@param key any
---@param data any
---@return nil
function CacheData(actionType, actionId, key, data)   end
---@return boolean @Checks if a cinematic can be played.
function CanPlayCinematic()   end
---@param sourceLocation number @Checks if a dye item can be used.
---@param dyeSlot number
---@return boolean
function CanUseDyeItem(sourceLocation, dyeSlot)   end
---@return nil @Cancels an auction.
function CancelAuction()   end
---@param keepUpgradeId number @Cancels a keep upgrade.
---@return nil
function CancelKeepUpgrade(keepUpgradeId)   end
---@return nil @Cancels the current spell cast.
function CancelSpell()   end
---@return nil @Cancels the current trade.
function CancelTrade()   end
---@param slot number @Changes the current trade offer.
---@param invSlotNum number
---@param backpackType number
---@param money number
---@return nil
function ChangeTrade(slot, invSlotNum, backpackType, money)   end
---@return nil @Clears the running default UI flag in character settings.
function CharacterSettingsClearRunningDefaultUiFlag()   end
---@return nil @Creates a UI profile in character settings.
function CharacterSettingsCreateUiProfile()   end
---@return nil @Exports a UI profile from character settings.
function CharacterSettingsExportUiProfile()   end
---@return table @Gets all UI profiles from character settings.
function CharacterSettingsGetAllUiProfiles()   end
---@return table @Gets character settings data.
function CharacterSettingsGetData()   end
---@return table @Gets other characters using a UI profile.
function CharacterSettingsGetOtherCharactersUsingProfile()   end
---@return nil @Handles a deleted character in character settings.
function CharacterSettingsHandleDeletedCharacter()   end
---@return nil @Imports a UI profile into character settings.
function CharacterSettingsImportUiProfile()   end
---@return nil @Removes a UI profile from character settings.
function CharacterSettingsRemoveUiProfile()   end
---@return nil @Renames a UI profile in character settings.
function CharacterSettingsRenameUiProfile()   end
---@return nil @Sets the active UI profile in character settings.
function CharacterSettingsSetActiveUiProfile()   end
---@return nil @Sets a UI profile as shared in character settings.
function CharacterSettingsSetUiProfileShared()   end
---@return nil @Moves the rotation center of a circle image.
function CircleImageMoveRotationCenter()   end
---@return nil @Clears the active tactics.
function ClearActiveTactics()   end
---@return nil @Clears the cursor.
function ClearCursor()   end
---@return nil @Clears Public Quest loot data.
function ClearPQLootData()   end
---@return nil @Clears the selected rewards.
function ClearSelectedRewards()   end
---@return nil @Clears the current target.
function ClearTarget()   end
---@param command number @Commands the player's pet.
---@return nil
function CommandPet()   end
---@param actionId number @Commands the player's pet to use an ability.
---@return nil
function CommandPetDoAbility()   end
---@param actionId number @Toggles a pet ability.
---@return nil
function CommandPetToggleAbility()   end
---@return nil @Confirms the transfer of a guild.
function ConfirmedTransferGuild()   end
---@return nil @Creates a new auction.
function CreateAuction()   end
---@return nil @Creates a conversation log.
function CreateConversationLog()   end
---@param data string @Creates a hyperlink.
---@param text string
---@param color table
---@param options table
---@return string
function CreateHyperLink(data, text, color, options)   end
---@param name string @Creates a map instance.
---@param mapType number
---@return nil
function CreateMapInstance(name, mapType)   end
---@return table @Gets the list of current events.
function CurrentEventsGetList()   end
---@return table @Gets the timers for current events.
function CurrentEventsGetTimers()   end
---@return nil @Jumps to a specific current event.
function CurrentEventsJumpToEvent()   end
---@return nil @Updates the current events.
function CurrentEventsUpdate()   end
---@param text string @Logs a debug message.
---@return nil
function DEBUG(text)   end
---@param t table @Dumps the contents of a table for debugging.
---@param indent string
---@param tableHistory table
---@return nil
function DUMP_TABLE(t, indent, tableHistory)   end
---@param t table @Dumps the contents of a table to a specified print function.
---@param printFunction function
---@param indent string
---@param tableHistory table
---@return nil
function DUMP_TABLE_TO(t, printFunction, indent, tableHistory)   end
---@param source number @Destroys an item.
---@param sourceSlot number
---@return nil
function DestroyItem(source, sourceSlot)   end
---@param worldObject number @Detaches a window from a world object.
---@param windowName string
---@return nil
function DetachWindowFromWorldObject(worldObject, windowName)   end
---@param donationType number @Donates items to an altar.
---@param amount number
---@return nil
function DonateToAltar(donationType, amount)   end
---@return nil @Previews dyes at the dye merchant.
function DyeMerchantPreview()   end
---@return nil @Previews all dyes at the dye merchant.
function DyeMerchantPreviewAll()   end
---@param sourceLoc number @Previews a dye application.
---@param sourceSlot number
---@param tintMask number
---@param targetLoc number
---@param targetSlot number
---@return nil
function DyePreview(sourceLoc, sourceSlot, tintMask, targetLoc, targetSlot)   end
---@return nil @Clears the custom shader on a dynamic image.
function DynamicImageClearCustomShader()   end
---@return nil @Sets a custom shader on a dynamic image.
function DynamicImageSetCustomShader()   end
---@return any @Gets help entry data.
function EA_Window_HelpGetEntryData()   end
---@return any @Gets FAQ entry data.
function EA_Window_HelpGetFAQEntryData()   end
---@return table @Gets the list of FAQ topics.
function EA_Window_HelpGetFAQTopicList()   end
---@return table @Gets the list of help tips.
function EA_Window_HelpGetHelpTipsList()   end
---@return table @Gets the list of help topics.
function EA_Window_HelpGetTopicList()   end
---@param value number @Enables or disables tracing.
---@return nil
function ENABLE_TRACE(value)   end
---@param event any @Marks the end of a function for tracing.
---@param line number
---@return nil
function END_FUNCTION(event, line)   end
---@param text string @Logs an error message.
---@return nil
function ERROR(text)   end
---@param text string @Logs an error message with a stack trace.
---@return nil
function ERROR_TRACE(text)   end
---@param container number @Enables or disables an alert container.
---@param enabled boolean
---@param cooldownInMs number
---@return nil
function EnableAlert(container, enabled, cooldownInMs)   end
---@return nil @Enables updates for Realm vs. Realm quests.
function EnableRRQUpdates()   end
---@return nil @Ends the item enhancement process.
function EndItemEnhancement()   end
---@return nil @Fires an ability from an altar.
function FireAltarAbility()   end
---@param worldObject number @Forces an update of a window attached to a world object.
---@param windowName string
---@return nil
function ForceUpdateWorldObjectWindow(worldObject, windowName)   end
---@param _timeInSeconds number @Formats the last login time.
---@param _hour number
---@param _month number
---@param _day number
---@param _year number
---@return string
function FormatLastLoginTime(_timeInSeconds, _hour, _month, _day, _year)   end
---@return nil @Fuses item enhancements.
function FuseItemEnhancements()   end
---@return boolean @Gets the Away From Keyboard flag status.
function GetAFKFlag()   end
---@return number @Gets the action point cost of an ability.
function GetAbilityActionPointCost()   end
---@return number @Gets the cast time of an ability.
function GetAbilityCastTime()   end
---@return number @Gets the cooldown of an ability.
function GetAbilityCooldown()   end
---@param abilityId number @Gets data for a specific ability.
---@param abilityType number
---@return table
function GetAbilityData(abilityId, abilityType)   end
---@return string @Gets the description of an ability.
function GetAbilityDesc()   end
---@return string @Gets the description of an ability.
function GetAbilityDescription()   end
---@param abilityId number @Gets the name of an ability.
---@return string
function GetAbilityName(abilityId)   end
---@return table @Gets the ranges of an ability.
function GetAbilityRanges()   end
---@return table @Gets the requirements of an ability.
function GetAbilityRequirements()   end
---@param typeEnum number @Gets a table of abilities of a specific type.
---@return table
function GetAbilityTable(typeEnum)   end
---@return number @Gets the upgrade rank of an ability.
function GetAbilityUpgradeRank()   end
---@return table @Gets account data.
function GetAccountData()   end
---@param actionName string @Gets the action ID from an action name.
---@return number
function GetActionIdFromName(actionName)   end
---@return string @Gets the action name from an action ID.
function GetActionNameFromId()   end
---@return table @Gets actions for a button combination.
function GetActionsForButtonCombination()   end
---@return table @Gets data for active objectives.
function GetActiveObjectivesData()   end
---@return table @Gets the currently active tactics.
function GetActiveTactics()   end
---@return boolean @Gets the advisor flag status.
function GetAdvisorFlag()   end
---@return table @Gets the counts of alliance members.
function GetAllianceMemberCounts()   end
---@return table @Gets data for alliance members.
function GetAllianceMemberData()   end
---@return boolean @Gets and clears the party member dirty flag.
function GetAndClearPartyMemberDirtyFlag()   end
---@return boolean @Gets and clears the warband member dirty flag.
function GetAndClearWarbandMemberDirtyFlag()   end
---@return table @Gets data for the current area.
function GetAreaData()   end
---@return table @Gets bank data.
function GetBankData()   end
---@return table @Gets banner configuration data.
function GetBannerConfigurationData()   end
---@return table @Gets data for battlegroup members.
function GetBattlegroupMemberData()   end
---@param action number @Gets key bindings for an action.
---@param bindings table
---@return nil
function GetBindingsForAction(action, bindings)   end
---@return table @Gets a list of blocked abilities.
function GetBlockedAbilities()   end
---@return any @Gets the bolster buddy.
function GetBolsterBuddy()   end
---@return any @Gets a bonus.
function GetBonus()   end
---@param itemLevel number @Checks if a bonus is salvagable.
---@param bonusReference number
---@return number
function GetBonusIsSalvagable(itemLevel, bonusReference)   end
---@return table @Gets bragging rights data.
function GetBraggingRights()   end
---@return table @Gets a list of active buffs.
function GetBuffs()   end
---@param deviceId number @Gets the name of a button.
---@param itemId number
---@return string
function GetButtonName(deviceId, itemId)   end
---@return table @Gets buyback data.
function GetBuyBackData()   end
---@param actionType number @Gets cached data for an action.
---@param actionId number
---@param key any
---@return any
function GetCachedData(actionType, actionId, key)   end
---@return table @Gets campaign city data.
function GetCampaignCityData()   end
---@return table @Gets campaign pairing data.
function GetCampaignPairingData()   end
---@param zoneNum number @Gets campaign zone data.
---@return table
function GetCampaignZoneData(zoneNum)   end
---@param careerLineId number @Gets the name of a career line.
---@return string
function GetCareerLine(careerLineId)   end
---@param targetType number @Gets the current career resource value.
---@return number
function GetCareerResource(targetType)   end
---@param influenceId number @Gets the name of a chapter based on influence ID.
---@return string
function GetChapterName(influenceId)   end
---@return string @Gets the short name of the current chapter.
function GetChapterShortName()   end
---@return table @Gets the names of chat channels.
function GetChatChannelNames()   end
---@param stringId number @Gets a localized chat string.
---@return string
function GetChatString(stringId)   end
---@return table @Gets data for choice rewards.
function GetChoiceRewardsData()   end
---@return number @Gets the current city instance ID.
function GetCityInstanceId()   end
---@return string @Gets the name of the current city.
function GetCityName()   end
---@return string @Gets the name of the city for the current realm.
function GetCityNameForRealm()   end
---@param cityId number @Gets the rating for a city by its ID.
---@return number
function GetCityRatingForCityId(cityId)   end
---@return any @Gets the cluster anchor point.
function GetClusterAnchorPoint()   end
---@return number @Gets the computer's time.
function GetComputerTime()   end
---@param tradeSkill number @Gets the crafting backpack slots for a trade skill.
---@return table
function GetCraftingBackPackSlots(tradeSkill)   end
---@param itemData table @Gets crafting data for an item.
---@return table
function GetCraftingData(itemData)   end
---@return table @Gets crafting item data.
function GetCraftingItemData()   end
---@return table @Gets credits data.
function GetCreditsData()   end
---@param plotNum number @Gets cultivation information for a plot.
---@return table
function GetCultivationInfo(plotNum)   end
---@return table @Gets currency item data.
function GetCurrencyItemData()   end
---@return table @Gets data for the current item enhancement.
function GetCurrentEnhancementItemData()   end
---@return number @Gets the DPS modifier.
function GetDPSModifier()   end
---@param abilityId number @Gets ability data from the database.
---@return table
function GetDatabaseAbilityData(abilityId)   end
---@param guildId number @Gets guild data from the database.
---@return table
function GetDatabaseGuildData(guildId)   end
---@param itemId number @Gets item data from the database.
---@return table
function GetDatabaseItemData(itemId)   end
---@param questId number @Gets quest data from the database.
---@return table
function GetDatabaseQuestData(questId)   end
---@return number @Gets the desired interaction action.
function GetDesiredInteractAction()   end
---@return table @Gets dye merchant data.
function GetDyeMerchantData()   end
---@return string @Gets the name of a dye.
function GetDyeName()   end
---@return string @Gets the name string of a dye.
function GetDyeNameString()   end
---@return table @Gets the tint masks for dyes.
function GetDyeTintMasks()   end
---@return number @Gets the current epoch time.
function GetEpochTime()   end
---@return table @Gets equipment data.
function GetEquipmentData()   end
---@param equipSlot number @Checks if an item in an equipment slot is visible.
---@return boolean
function GetEquippedItemVisible(equipSlot)   end
---@return table @Gets experience data.
function GetExperienceData()   end
---@return number @Gets the first day of the week setting.
function GetFirstDayOfWeek()   end
---@return table @Gets flight master data.
function GetFlightMasterData()   end
---@param tableName string @Gets a formatted string from a table.
---@param stringId number
---@param params table
---@return string
function GetFormatStringFromTable(tableName, stringId, params)   end
---@param frameName string @Gets a UI frame by name.
---@return any
function GetFrame(frameName)   end
---@return table @Gets the player's friends list.
function GetFriendsList()   end
---@return table @Gets game data objectives.
function GetGameDataObjectives()   end
---@return number @Gets the current game time.
function GetGameTime()   end
---@return table @Gets data for given rewards.
function GetGivenRewardsData()   end
---@return table @Gets group data.
function GetGroupData()   end
---@return table @Gets status data for group members.
function GetGroupMemberStatusData()   end
---@return table @Gets guild advancement data.
function GetGuildAdvancementData()   end
---@return table @Gets guild appointment data.
function GetGuildAppointmentData()   end
---@return table @Gets data for guild members.
function GetGuildMemberData()   end
---@return table @Gets guild permission data.
function GetGuildPermissionData()   end
---@return table @Gets guild poll data.
function GetGuildPollData()   end
---@param appointmentId number @Gets guild signup data for an appointment.
---@return table
function GetGuildSignupData(appointmentId)   end
---@param stringId number @Gets a localized guild string.
---@return string
function GetGuildString(stringId)   end
---@return number @Gets the cost to respec guild tactics.
function GetGuildTacticsRespecCost()   end
---@return string @Gets a help string.
function GetHelpString()   end
---@return table @Gets help tip strings.
function GetHelpTipStrings()   end
---@param filterId number @Gets the best heraldry options based on filters.
---@param shapeChoice number
---@return table
function GetHeraldryBestOptions(filterId, shapeChoice)   end
---@return table @Gets heraldry configuration data.
function GetHeraldryConfigurationData()   end
---@return number @Gets the cost of heraldry.
function GetHeraldryCost()   end
---@return number @Gets the cost to reset heraldry.
function GetHeraldryResetCost()   end
---@param slot number @Gets the current and maximum cooldown for a hotbar slot.
---@return number, number
function GetHotbarCooldown(slot)   end
---@param slot number @Gets data for a hotbar slot.
---@return number, number, boolean, boolean, boolean
function GetHotbarData(slot)   end
---@param slot number @Gets the glow levels for a hotbar slot.
---@return number, number
function GetHotbarGlowLevels(slot)   end
---@param slot number @Gets the icon ID for a hotbar slot.
---@return number
function GetHotbarIcon(slot)   end



---
-- @desc Requests a new name when a character naming conflict occurs.
-- @param newName string The desired new character name.
-- @usage Called from interfacecore/source/renamewindow.lua when the user submits a new name after a conflict.
function NamingConflictRequestNewName(newName)   end
---
-- @desc Blocks or unblocks mouseover events in the pre-game character selection NIF display.
-- @param block boolean True to block mouseover, false to allow.
-- @usage Called from interfacecore/source/characterselectwindow.lua to prevent character changes during deletion or forced rename.
function PregameBlockMouseOver(block)   end
---
-- @desc Gets the total number of character pages for each realm in the pre-game character selection screen.
-- @return number orderNumPages The number of pages for the Order realm.
-- @return number destructionNumPages The number of pages for the Destruction realm.
-- @usage Called from interfacecore/source/characterselectwindow.lua to update the page changer UI.
function PregameGetCharacterSelectNumPages()   end
---
-- @desc Gets the currently displayed page number and realm in the pre-game character selection screen.
-- @return number realm The current realm (GameData.Realm.ORDER or GameData.Realm.DESTRUCTION).
-- @return number page The current page number within that realm.
-- @usage Called from interfacecore/source/characterselectwindow.lua to update the page changer UI.
function PregameGetCharacterSelectPage()   end
---
-- @desc Gets the pre-selected server realm chosen by the player or determined by server rules.
-- @return number realmId The ID of the pre-selected realm (GameData.Realm) or a constant like ServerSelectWindow.BOTH_REALM_OPTIONS.
-- @usage Called from interfacecore/source/characterselectwindow.lua to handle realm limitations.
function PregameGetPreSelectedServerRealm()   end
---
-- @desc Gets labels used in the quick start screen (last played character info).
-- @return string nameLabel The character's name.
-- @return number rank The character's rank/level.
-- @return string careerLabel The character's career name.
-- @return string locationLabel The character's last location.
-- @usage Called from interfacecore/source/quickstartwindow.lua to display last played character info.
function PregameGetQuickStartLabels()   end
---
-- @desc Gets the character creation limit status for the current server (e.g., Order only, Destruction only, Both allowed).
-- @return number limitConstant A constant indicating the realm limitation (e.g., ServerSelectWindow.ORDER_ONLY).
-- @usage Called from interfacecore/source/characterselectwindow.lua to display realm eligibility messages.
function PregameGetRealmLimit()   end
---
-- @desc Gets bonus information (e.g., population bonuses) for the current server's realms.
-- @return number orderBonus The bonus value for the Order realm (non-zero indicates bonus).
-- @return number destructionBonus The bonus value for the Destruction realm (non-zero indicates bonus).
-- @usage Called from interfacecore/source/characterselectwindow.lua to display realm bonus icons/text.
function PregameGetServerRealmBonuses()   end
---
-- @desc Plays a cinematic video during the pre-game sequence.
-- @param cinematicId number|string The ID or filename of the cinematic to play.
-- @usage Called from interfacecore/source/cinematicwindow.lua when showing the cinematic window.
function PregamePlayCinematic(cinematicId)   end
---
-- @desc Randomizes selectable appearance features during character creation.
-- @usage Called from interfacecore/source/characterselectwindow.lua when the random features button is clicked.
function PregameRandomFeatures()   end
---
-- @desc Sets a specific appearance feature during character creation.
-- @param featureType number The ID/type of the feature to set (e.g., hair style, face).
-- @param value number The chosen value/index for the feature.
-- @usage Called from interfacecore/source/characterselectwindow.lua when changing feature options.
function PregameSetFeature(featureType, value)   end
---
-- @desc Sets the server realm the player will be directed to upon character creation (used for realm balancing/recommendations).
---@param realmOption number A constant indicating the realm choice (e.g., ServerSelectWindow.BOTH_REALM_OPTIONS, .ORDER_ONLY, .DESTRUCTION_ONLY).
---@usage Called from interfacecore/source/serverselectwindow.lua when selecting a server, especially a recommended one.
function PregameSetPreSelectedServerRealm(realmOption)   end
---
-- @desc Sets server/realm bonus data (likely received from the server).
-- @param orderBonus number The bonus value for the Order realm.
-- @param destructionBonus number The bonus value for the Destruction realm.
-- @usage Called from interfacecore/source/serverselectwindow.lua when selecting a recommended server with bonuses.
function PregameSetServerRealmBonuses(orderBonus, destructionBonus)   end
---
-- @desc Stops any currently playing pre-game cinematic.
-- @usage Called from interfacecore/source/cinematicwindow.lua when hiding the cinematic window.
function PregameStopCinematic()   end
---
-- @desc Selects a game server to connect to during the pre-game sequence.
-- @param serverId number The ID of the server to select.
-- @usage Called from interfacecore/source/serverselectwindow.lua when the user confirms server selection.
function SelectServer(serverId)   end
