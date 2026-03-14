----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

GuildWindowTabBanner = {}

GuildWindowTabBanner.PurchasedTacticIconIDs = {}
GuildWindowTabBanner.TOTAL_NUMBER_OF_AVAILABLE_TACTICS = 18
GuildWindowTabBanner.TOTAL_NUMBER_OF_STANDARDS = 3

GuildWindowTabBanner.CurrentBannerNumber	= 1
GuildWindowTabBanner.CurrentPostNumber	= 1

-- Table of when the Guild Standards (Banners) unlock
GuildWindowTabBanner.BannerUnlocks = {}
GuildWindowTabBanner.BannerUnlocks[1] = 5
GuildWindowTabBanner.BannerUnlocks[2] = 18
GuildWindowTabBanner.BannerUnlocks[3] = 30

GuildWindowTabBanner.TacticUnlocks = {}
GuildWindowTabBanner.TacticUnlocks[1] = {}
GuildWindowTabBanner.TacticUnlocks[1][1] = 5
GuildWindowTabBanner.TacticUnlocks[1][2] = 9
GuildWindowTabBanner.TacticUnlocks[1][3] = 13
GuildWindowTabBanner.TacticUnlocks[2] = {}
GuildWindowTabBanner.TacticUnlocks[2][1] = 18
GuildWindowTabBanner.TacticUnlocks[2][2] = 22
GuildWindowTabBanner.TacticUnlocks[2][3] = 26
GuildWindowTabBanner.TacticUnlocks[3] = {}
GuildWindowTabBanner.TacticUnlocks[3][1] = 30
GuildWindowTabBanner.TacticUnlocks[3][2] = 34
GuildWindowTabBanner.TacticUnlocks[3][3] = 38

GuildWindowTabBanner.TacticSlotTypeString = {}
GuildWindowTabBanner.TacticSlotTypeString[1] = GetGuildString(StringTables.Guild.TOOLTIP_TACTIC_TYPE1)
GuildWindowTabBanner.TacticSlotTypeString[2] = GetGuildString(StringTables.Guild.TOOLTIP_TACTIC_TYPE2)
GuildWindowTabBanner.TacticSlotTypeString[3] = GetGuildString(StringTables.Guild.TOOLTIP_TACTIC_TYPE3)

GuildWindowTabBanner.HERALDRY_UNLOCKS_AT_RANK = 9
GuildWindowTabBanner.TROPHY_UNLOCKS_AT_RANK = 6
GuildWindowTabBanner.isMovingFromActiveSlot = false

-- load commonly used Tactic and Trophy icons
--  Icon id="00037" texture="Textures/Ge_Trophy.dds" name=""
--  Icon id="00053" texture="Textures/Ge_Trophy_Locked.dds" name=""
--  Icon id="00152" texture="Textures/Tac_Slot.dds" name="Tactic"
--  Icon id="00153" texture="Textures/Tac_Slot_Locked.dds" name="Tactic"
local iconTexture, iconX, iconY = GetIconData( 37 )
GuildWindowTabBanner.TROPHY_ICON_EMPTY = {texture=iconTexture, x=iconX, y=iconY }

iconTexture, iconX, iconY = GetIconData( 53 )
GuildWindowTabBanner.TROPHY_ICON_LOCKED = {texture=iconTexture, x=iconX, y=iconY }

iconTexture, iconX, iconY = GetIconData( 152 )
GuildWindowTabBanner.TACTIC_ICON_EMPTY = {texture=iconTexture, x=iconX, y=iconY }

iconTexture, iconX, iconY = GetIconData( 22693 )
GuildWindowTabBanner.GUILD_TACTIC_ICON_GREY = {texture=iconTexture, x=iconX, y=iconY }

iconTexture, iconX, iconY = GetIconData( 22671 )
GuildWindowTabBanner.GUILD_TACTIC_ICON_RED = {texture=iconTexture, x=iconX, y=iconY }

iconTexture, iconX, iconY = GetIconData( 22715 )
GuildWindowTabBanner.GUILD_TACTIC_ICON_GREEN = {texture=iconTexture, x=iconX, y=iconY }

iconTexture, iconX, iconY = GetIconData( 22737 )
GuildWindowTabBanner.GUILD_TACTIC_ICON_BLUE = {texture=iconTexture, x=iconX, y=iconY }

iconTexture, iconX, iconY = GetIconData( 153 )
GuildWindowTabBanner.TACTIC_ICON_LOCKED = {texture=iconTexture, x=iconX, y=iconY }

GuildWindowTabBanner.ABILITY_POPUP_ANCHOR = { Point="top", RelativeTo="", RelativePoint="bottom", XOffset=0, YOffset=-10 }

GuildWindowTabBanner.StandardNames = {}
GuildWindowTabBanner.StandardNames[1] = {}	-- Order Standards
GuildWindowTabBanner.StandardNames[1][1] = { id= StringTables.Guild.LABEL_GUILD_RANK5_REWARD1_ORDER }	-- Order's 1st Standard
GuildWindowTabBanner.StandardNames[1][2] = { id= StringTables.Guild.LABEL_GUILD_RANK18_REWARD1_ORDER }	-- Order's 2nd Standard
GuildWindowTabBanner.StandardNames[1][3] = { id= StringTables.Guild.LABEL_GUILD_RANK30_REWARD1_ORDER }	-- Order's 3rd Standard

GuildWindowTabBanner.StandardNames[2] = {}	-- Destruction Standards
GuildWindowTabBanner.StandardNames[2][1] = { id= StringTables.Guild.LABEL_GUILD_RANK5_REWARD1_DESTRUCTION }	-- Destruction's 1st Standard
GuildWindowTabBanner.StandardNames[2][2] = { id= StringTables.Guild.LABEL_GUILD_RANK18_REWARD1_DESTRUCTION }	-- Destruction's 2nd Standard
GuildWindowTabBanner.StandardNames[2][3] = { id= StringTables.Guild.LABEL_GUILD_RANK30_REWARD1_DESTRUCTION }	-- Destruction's 3rd Standard

local function ClearBanners()

    GuildWindowTabBanner.Banners = {}
    
    for i=1, GuildWindowTabBanner.TOTAL_NUMBER_OF_STANDARDS do
        GuildWindowTabBanner.Banners[i] = {}
        GuildWindowTabBanner.Banners[i].bannerID = 0
        GuildWindowTabBanner.Banners[i].postID = 1
        GuildWindowTabBanner.Banners[i].lastEdited = 0
        GuildWindowTabBanner.Banners[i].isCaptured = 0
        GuildWindowTabBanner.Banners[i].numberUnlockedAbilitySlots = 0
        GuildWindowTabBanner.Banners[i].numberUnlockedTrophySlots = 0

        GuildWindowTabBanner.Banners[i].AbilityID = {}
        GuildWindowTabBanner.Banners[i].AbilityID[1] = 0
        GuildWindowTabBanner.Banners[i].AbilityID[2] = 0
        GuildWindowTabBanner.Banners[i].AbilityID[3] = 0
    end
end

-- Returns a table containing the Icon data {texture, x, and y} based on the abilityID. Returns a default empty icon upon any failures.
local function GetIconDataFromTacticID(tacticID)
    -- If we've purchased a tactic, the tacticID will be the ID of that tactic, otheriwse it will be <= 0

    if (tacticID ~= nil and tacticID > 0)  
    then    
        local abilityData = GuildTacticsList.GetTacticData (tacticID)
        
        if (abilityData ~= nil) 
        then
            local iconData = {}
            
            iconData.texture, iconData.x, iconData.y = GetIconData(abilityData.iconNum)
            
            if ((iconData.texture ~= nil) and (iconData.texture ~= ""))
            then
                return iconData
            end
        end
    end
    
    return GuildWindowTabBanner.GUILD_TACTIC_ICON_GREY
    
end

function GuildWindowTabBanner.Initialize()

    LabelSetText("GWRewardsBannerAvailableGuildTrophiesHeader", GetGuildString( StringTables.Guild.HEADER_GUILD_BANNER_AVAILABLE_GUILD_TROPHIES ) )
    LabelSetText("GWRewardsBannerAvailableGuildTacticsHeader", GetGuildString( StringTables.Guild.HEADER_GUILD_BANNER_PURCHASED_GUILD_TACTICS ) )
    
    ButtonSetText("GWRewardsBannerSaveButton", GetString( StringTables.Default.LABEL_SAVE ) )
    ButtonSetText("GWRewardsBannerCancelButton", GetString( StringTables.Default.LABEL_CANCEL ) )

    ClearBanners()
    GuildWindowTabBanner.ClearPurchasedTacticsAndAvailableTrophies()
    GuildWindowTabBanner.UpdateAllBannerConfigurations()
    GuildWindowTabBanner.UpdateSelectedBanner()
	GuildWindowTabBanner.SetupPostComboBox()
	-- Init Note: We have to delay initializing the rendering of the post until after all the heraldry stuff is setup.
	
	GuildWindowTabRewards.InitializeRewards()	-- Init Note. The Reward Tab initializes after the Banner Tab, but we need the rewardtable, so init it here.
    GuildWindowTabBanner.UpdateAvailableTrophyIcons()

    if (GameData.Realm.ORDER == GameData.Player.realm) then 
        DynamicImageSetTexture( "GWRewardsBannerPicture", "EA_Guild_BannerBGOrder", 0, 0 )
        DynamicImageSetTextureSlice( "GWRewardsBannerPicture", "order-background" )
    else
        DynamicImageSetTexture( "GWRewardsBannerPicture", "EA_Guild_BannerBGDestruction", 0, 0 )
        DynamicImageSetTextureSlice( "GWRewardsBannerPicture", "destruction-background" )
    end

    WindowRegisterEventHandler( "GWRewardsBanner", SystemData.Events.GUILD_HERALDRY_UPDATED, "GuildWindowTabBanner.OnHeraldryUpdatedFromServer")
    WindowRegisterEventHandler( "GWRewardsBanner", SystemData.Events.GUILD_REWARDS_UPDATED, "GuildWindowTabBanner.OnRewardsUpdated")
    WindowRegisterEventHandler( "GWRewardsBanner", SystemData.Events.GUILD_MEMBER_UPDATED, "GuildWindowTabBanner.OnMemberUpdated")
	WindowRegisterEventHandler( "GWRewardsBanner", SystemData.Events.GUILD_BANNERS_UPDATED, "GuildWindowTabBanner.OnBannersUpdated")
	WindowRegisterEventHandler( "GWRewardsBanner", SystemData.Events.LOADING_END, "GuildWindowTabBanner.OnHeraldryUpdatedFromServer" )
end

function GuildWindowTabBanner.ClearPurchasedTacticsAndAvailableTrophies()

    GuildWindowTabBanner.AvailableTrophyIcons = {}
    for i=1, 6 do
        GuildWindowTabBanner.AvailableTrophyIcons[i] = 0
    end

    GuildWindowTabBanner.PurchasedTacticIconIDs = {}
    for i=1, GuildWindowTabBanner.TOTAL_NUMBER_OF_AVAILABLE_TACTICS do
        GuildWindowTabBanner.PurchasedTacticIconIDs[i] = 0
    end    
end

function GuildWindowTabBanner.UpdateBackgroundImage()

    if (GameData.Realm.ORDER == GameData.Player.realm) 
    then 
        DynamicImageSetTexture( "GWRewardsBannerPicture", "EA_Guild_BannerBGOrder", 0, 0 )
        DynamicImageSetTextureSlice( "GWRewardsBannerPicture", "order-background" )
    else

		DynamicImageSetTexture( "GWRewardsBannerPicture", "EA_Guild_BannerBGDestruction", 0, 0 )
        DynamicImageSetTextureSlice( "GWRewardsBannerPicture", "destruction-background" )
	end
end

function GuildWindowTabBanner.SetRenderPostAndComboBox(postID)
	ComboBoxSetSelectedMenuItem("GWRewardsBannerPostCombo", postID )
	GuildWindowTabBanner.CurrentPostNumber = postID
	SetGuildStandardScene( postID )
	BroadcastEvent( SystemData.Events.UPDATE_GUILDSTANDARD )
	BroadcastEvent( SystemData.Events.UPDATE_GUILDHERALDRY )
end

function GuildWindowTabBanner.SetupPostComboBox()
	local GuildAdvancementData = GetGuildAdvancementData()

    ComboBoxClearMenuItems("GWRewardsBannerPostCombo")
    ComboBoxAddMenuItem( "GWRewardsBannerPostCombo", GetFormatStringFromTable( "guildstrings", StringTables.Guild.TEXT_POST_X, {1} ) )

	if GuildAdvancementData ~= nil then
        for postNumber = 2, GuildAdvancementData.numberPolesUnlocked do
            ComboBoxAddMenuItem( "GWRewardsBannerPostCombo", GetFormatStringFromTable( "guildstrings", StringTables.Guild.TEXT_POST_X, {postNumber} ) )
        end
	end
end

function GuildWindowTabBanner.Shutdown()
end

function GuildWindowTabBanner.UpdateAllBannerConfigurations()

    if GuildWindowTabBanner.Banners == nil then
        return
    end

    local bannerConfigurationData = GetBannerConfigurationData()
    if ( bannerConfigurationData ~= nil) then
        for key, value in ipairs( bannerConfigurationData ) do
            GuildWindowTabBanner.Banners[key] = {}
            GuildWindowTabBanner.Banners[key].bannerID = value.bannerID
            GuildWindowTabBanner.Banners[key].lastEdited = value.lastEdited
			GuildWindowTabBanner.Banners[key].postID = value.postID
            GuildWindowTabBanner.Banners[key].isCaptured = value.isCaptured

            GuildWindowTabBanner.Banners[key].numberUnlockedTrophySlots  = value.numberUnlockedTrophySlots
            GuildWindowTabBanner.Banners[key].numberUnlockedAbilitySlots = value.numberUnlockedAbilitySlots

            GuildWindowTabBanner.Banners[key].AbilityID = {}
            
            if (value.abilitySlot1 == nil)
            then
                GuildWindowTabBanner.Banners[key].AbilityID[1] = 0
            else
                GuildWindowTabBanner.Banners[key].AbilityID[1] = value.abilitySlot1
            end
            
            if (value.abilitySlot2 == nil)
            then
                GuildWindowTabBanner.Banners[key].AbilityID[2] = 0
            else
                GuildWindowTabBanner.Banners[key].AbilityID[2] = value.abilitySlot2
            end
            
            if (value.abilitySlot3 == nil)
            then
                GuildWindowTabBanner.Banners[key].AbilityID[3] = 0
            else
                GuildWindowTabBanner.Banners[key].AbilityID[3] = value.abilitySlot3
            end
        end
    end
end

function GuildWindowTabBanner.UpdateSelectedBanner()
    if (GuildWindowTabBanner.Banners ~= nil) then
        GuildWindowTabBanner.UpdateBannerNumberHeader()
        GuildWindowTabBanner.UpdateBannerWatermark()
		GuildWindowTabBanner.UpdateBannerLockIcon()
        GuildWindowTabBanner.UpdateSelectedBannerTrophyIcon()
        GuildWindowTabBanner.UpdateSelectedBannerTacticIcons()
        GuildWindowTabBanner.UpdateBannerElements()
    end
    BroadcastEvent( SystemData.Events.UPDATE_GUILDSTANDARD )
end

function GuildWindowTabBanner.UpdateBannerNumberHeader()
	LabelSetText("GWRewardsBannerBannerNumberHeader", GetGuildString( GuildWindowTabBanner.StandardNames[GameData.Player.realm][GuildWindowTabBanner.CurrentBannerNumber].id ) )
end

-- If the Standard # is unlocked, the watermark is hidden, otheriwse it displays when the Standard will be unlocked.
function GuildWindowTabBanner.UpdateBannerWatermark()

    local guildAdvancementData = GetGuildAdvancementData()

    if guildAdvancementData ~= nil and GuildWindowTabBanner.CurrentBannerNumber <= guildAdvancementData.numberBannersUnlocked then
        WindowSetShowing("GWRewardsBannerBannerWatermark", false)
        WindowSetShowing("GuildStandardScene", true)
    else
        LabelSetText("GWRewardsBannerBannerWatermark", GetFormatStringFromTable( "guildstrings", StringTables.Guild.TEXT_STANDARD_X_UNLOCKS_AT_RANK_Y, {GuildWindowTabBanner.CurrentBannerNumber, GuildWindowTabBanner.BannerUnlocks[GuildWindowTabBanner.CurrentBannerNumber]} ) )
        WindowSetShowing("GWRewardsBannerBannerWatermark", true)
        WindowSetShowing("GuildStandardScene", false)
    end

end

-- If the banner has been edited in the last 24 hours, then show the lock icon.
function GuildWindowTabBanner.UpdateBannerLockIcon()
	if GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].lastEdited > 0 then
		WindowSetShowing("GWRewardsBannerLock", true)
	else
		WindowSetShowing("GWRewardsBannerLock", false)
	end

end

-- based on Guild Rank and user permissions, update all the elements on this tab (buttons, arrows, combo box, etc)
function GuildWindowTabBanner.UpdateBannerElements()

    local guildAdvancementData = GetGuildAdvancementData()
	local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()

	-- If the player doesn't have permission to ever edit the Guild Standard, hide the save and cancel buttons
	local bCanEditStandard  = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.BANNER_MANAGEMENT, playerTitleNumber)

	if bCanEditStandard == false then
		WindowSetShowing("GWRewardsBannerSaveButton", false)
		WindowSetShowing("GWRewardsBannerCancelButton", false)
		WindowSetShowing("GWRewardsBannerPostCombo", false )
	else
		WindowSetShowing("GWRewardsBannerSaveButton", true)
		WindowSetShowing("GWRewardsBannerCancelButton", true)
		WindowSetShowing("GWRewardsBannerPostCombo", true )

		-- If the player will eventually have permission to edit the Guild Standard, but just not yet, then grey out the buttons.
		if  guildAdvancementData == nil or GuildWindowTabBanner.CurrentBannerNumber > guildAdvancementData.numberBannersUnlocked then
			ButtonSetDisabledFlag("GWRewardsBannerSaveButton", true)
			ButtonSetDisabledFlag("GWRewardsBannerCancelButton", true)
			ComboBoxSetDisabledFlag("GWRewardsBannerPostCombo", true )
		else
			ButtonSetDisabledFlag("GWRewardsBannerSaveButton", false)
			ButtonSetDisabledFlag("GWRewardsBannerCancelButton", false)
			ComboBoxSetDisabledFlag("GWRewardsBannerPostCombo", false )
		end
    end
end

function GuildWindowTabBanner.UpdateSelectedBannerTrophyIcon()
    -- display trophy slot icon

    local icon = nil
    if GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].numberUnlockedTrophySlots > 0 then
        icon = GuildWindowTabBanner.TROPHY_ICON_EMPTY
        ButtonSetDisabledFlag("GWRewardsBannerTrophySlot", false)
    else
        icon = GuildWindowTabBanner.TROPHY_ICON_LOCKED
        ButtonSetDisabledFlag("GWRewardsBannerTrophySlot", true)
    end

    DynamicImageSetTexture( "GWRewardsBannerTrophySlotIcon", icon.texture, icon.x, icon.y )

end

function GuildWindowTabBanner.UpdateSelectedBannerTacticIcons()
    --local abilityData = nil

    local tacticID = 0
    local iconData = nil

    for slotNumber = 1, GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].numberUnlockedAbilitySlots do
        tacticID = GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[slotNumber]
        iconData = GetIconDataFromTacticID(tacticID)

        DynamicImageSetTexture( "GWRewardsBannerTacticSlot"..slotNumber.."Icon", iconData.texture, iconData.x, iconData.y )
        ButtonSetDisabledFlag("GWRewardsBannerTacticSlot"..slotNumber, false)  
    end

    iconData = GuildWindowTabBanner.TACTIC_ICON_LOCKED
    for slotNumber = GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].numberUnlockedAbilitySlots + 1, 3 do
        DynamicImageSetTexture( "GWRewardsBannerTacticSlot"..slotNumber.."Icon", iconData.texture, iconData.x, iconData.y )
        ButtonSetDisabledFlag("GWRewardsBannerTacticSlot"..slotNumber, true)
    end
end

function GuildWindowTabBanner.UpdatePurchasedTacticIcons()

    local selectedBannerTacticSlotNumber = 0
    local tacticID = 0
    local iconData = nil
    local slotNumber = 0
    local tacticUsed = false
    local tacticUpgraded = false
    local previousTacticID = 0
    local upgradedTacticIndex = 0

	GuildWindowTabBanner.PurchasedTacticIconIDs = {}

    local rewardList = GuildWindowTabRewards.GetRewardList()
    local tacticPointRewardIndexMap = GuildWindowTabRewards.GetRewardTacticPointRewardIndexMap()
    local rewardData

	-- Loop through the only the tactic rewards
    for k, rewardIndex in pairs(tacticPointRewardIndexMap)
    do
        rewardData = rewardList[rewardIndex]
        tacticUsed = false
        tacticUpgraded = false
        previousTacticID = 0
        upgradedTacticIndex = 0
        tacticID = rewardData.tacticID

		-- If the tacticID is a positive number, then that means the tactic with the stored ID was purchased.
        if tacticID > 0 then
            iconData = GetIconDataFromTacticID(tacticID)

			-- Check if the tactic has prereqs becasue we only want to show the highest level purchased, not any of its prereqs.
            if (GuildTacticsList.HasPrereqBeenPurchased(tacticID))
            then
                previousTacticID = GuildTacticsList.GetPrereqTacticID(tacticID)
                if (previousTacticID > 0)
                then
                    for idx = 1, GuildWindowTabBanner.TOTAL_NUMBER_OF_AVAILABLE_TACTICS do
                        -- Find this tactic id in the list
                        if (GuildWindowTabBanner.PurchasedTacticIconIDs[idx] == previousTacticID)
                        then
                            tacticUpgraded = true
                            GuildWindowTabBanner.PurchasedTacticIconIDs[idx] = tacticID
							if DoesWindowExist("GWRewardsBannerAvailTacticSlot"..idx) then
								DynamicImageSetTexture("GWRewardsBannerAvailTacticSlot"..idx.."Icon", iconData.texture, iconData.x, iconData.y )
								ButtonSetDisabledFlag("GWRewardsBannerAvailTacticSlot"..idx, false)
								WindowSetTintColor("GWRewardsBannerAvailTacticSlot"..idx.."Icon", 255, 255, 255)
								upgradedTacticIndex = idx
							end
                            break
                        end
                    end
                end
            end
            
            for idxStandard = 1, GuildWindowTabBanner.TOTAL_NUMBER_OF_STANDARDS do
                for slotNum = 1, GuildWindowTabBanner.Banners[idxStandard].numberUnlockedAbilitySlots do
                    if (tacticUpgraded == true)
                    then
                        if (GuildWindowTabBanner.Banners[idxStandard].AbilityID[slotNum] == previousTacticID
                            or GuildWindowTabBanner.Banners[idxStandard].AbilityID[slotNum] == tacticID)
                        then
                            GuildWindowTabBanner.Banners[idxStandard].AbilityID[slotNum] = tacticID
                            for idx = 1, GuildWindowTabBanner.TOTAL_NUMBER_OF_AVAILABLE_TACTICS do
                                if (GuildWindowTabBanner.PurchasedTacticIconIDs[idx] == tacticID)
                                then
									if DoesWindowExist("GWRewardsBannerAvailTacticSlot"..idx) then
										ButtonSetDisabledFlag("GWRewardsBannerAvailTacticSlot"..idx, true)
										WindowSetTintColor("GWRewardsBannerAvailTacticSlot"..idx.."Icon", 92, 92, 92)
									end
								end
                            end
                            break
                        end
                    else
                        if (GuildWindowTabBanner.Banners[idxStandard].AbilityID[slotNum] == tacticID)
                        then
                            tacticUsed = true
                            break  
                        end
                    end
                end
            end

            if (tacticUpgraded == false)
            then
               slotNumber = slotNumber +1
			   if DoesWindowExist("GWRewardsBannerAvailTacticSlot"..slotNumber) then
					DynamicImageSetTexture("GWRewardsBannerAvailTacticSlot"..slotNumber.."Icon", iconData.texture, iconData.x, iconData.y )
               end
			   if (tacticUsed == false)
               then
			     if DoesWindowExist("GWRewardsBannerAvailTacticSlot"..slotNumber) then
                    ButtonSetDisabledFlag("GWRewardsBannerAvailTacticSlot"..slotNumber, false)
                    WindowSetTintColor("GWRewardsBannerAvailTacticSlot"..slotNumber.."Icon", 255, 255, 255)
				end
			   else
                    -- Make sure that all buttons that have been slotted are Disabled and Darkened
                if DoesWindowExist("GWRewardsBannerAvailTacticSlot"..slotNumber) then
					ButtonSetDisabledFlag("GWRewardsBannerAvailTacticSlot"..slotNumber, true)
                    WindowSetTintColor("GWRewardsBannerAvailTacticSlot"..slotNumber.."Icon", 92, 92, 92)
				end
			   end
                    
			   GuildWindowTabBanner.PurchasedTacticIconIDs[slotNumber] = tacticID
            end
        end
    end

    -- Fill in any empty slots remaining
    iconData = GuildWindowTabBanner.GUILD_TACTIC_ICON_GREY
    for slotNumber = slotNumber+1, GuildWindowTabBanner.TOTAL_NUMBER_OF_AVAILABLE_TACTICS do
        if DoesWindowExist("GWRewardsBannerAvailTacticSlot"..slotNumber) then
			DynamicImageSetTexture("GWRewardsBannerAvailTacticSlot"..slotNumber.."Icon", iconData.texture, iconData.x, iconData.y )
			WindowSetTintColor("GWRewardsBannerAvailTacticSlot"..slotNumber.."Icon", 255, 255, 255)
			ButtonSetDisabledFlag("GWRewardsBannerAvailTacticSlot"..slotNumber, true)
		end
	end

end

function GuildWindowTabBanner.UpdateAvailableTrophyIcons()


    ButtonSetDisabledFlag("GWRewardsBannerTrophiesLeftArrow", true)
    ButtonSetDisabledFlag("GWRewardsBannerTrophiesRightArrow", true)

    local icon = {}
    for slotNumber = 1, 6 do
        if GuildWindowTabBanner.AvailableTrophyIcons[slotNumber] > 0 then
            icon.texture, icon.x, icon.y = GetIconData( GuildWindowTabBanner.AvailableTrophyIcons[slotNumber] )
            ButtonSetDisabledFlag("GWRewardsBannerAvailableTrophy"..slotNumber, false)
        else
            icon = GuildWindowTabBanner.TROPHY_ICON_EMPTY
            ButtonSetDisabledFlag("GWRewardsBannerAvailableTrophy"..slotNumber, true)
        end
        DynamicImageSetTexture( "GWRewardsBannerAvailableTrophy"..slotNumber.."Icon", icon.texture, icon.x, icon.y )
    end

end

function GuildWindowTabBanner.OnMouseOverLock()

    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_GUILD_BANNER_LOCK) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
    Tooltips.Finalize ()
    
    local anchor = { Point="center", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottom", XOffset=0, YOffset=20 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)

    
end

function GuildWindowTabBanner.OnLButtonUpEditHeraldryButton()
    local bShowing = WindowGetShowing("HeraldryEditor")
    if bShowing then
        WindowSetShowing("HeraldryEditor", false)
        WindowSetShowing("ColorPicker", false)
    else
        HeraldryEditor.SyncHeraldryOptions()
        HeraldryEditor.UpdateAllChoiceLabels()
        HeraldryEditor.UpdateAllChoices(false)
        HeraldryEditor.UpdateColorChoices(false)
        WindowSetShowing("HeraldryEditor", true)
    end
end

function GuildWindowTabBanner.OnMouseoverBannerSaveButton()


    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetFormatStringFromTable( "guildstrings", StringTables.Guild.TOOLTIP_SAVE_STANDARD_BUTTON, { 24 } ) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
    Tooltips.Finalize ()
    
    local anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottomleft", XOffset=0, YOffset=-20 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)

    
end

function GuildWindowTabBanner.OnLButtonUpBannerSaveButton()
    if (ButtonGetDisabledFlag("GWRewardsBannerSaveButton") == true) then
        return
    end
    
	-- Create Confirmation Dialog
    local dialogText = GetFormatStringFromTable( "guildstrings", StringTables.Guild.DIALOG_CONFIRM_SAVING_STANDARD, { 24 } )
    DialogManager.MakeTwoButtonDialog( dialogText, GetGuildString(StringTables.Guild.BUTTON_CONFIRM_YES), GuildWindowTabBanner.OnBannerSaveConfirm, GetGuildString(StringTables.Guild.BUTTON_CONFIRM_NO), nil)
end

function GuildWindowTabBanner.OnBannerSaveConfirm()

    -- Params are : Banner Number, Number of ability slots for this banner. (Should be 3), Ability1ID, Ability2ID, Ability3ID, PostID
    -- NOTE: No Trophy support at this time.
    SendBannerConfigurationData( GuildWindowTabBanner.CurrentBannerNumber, 
                                 3, 
                                 GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[1],
                                 GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[2],
                                 GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[3], 
								 GuildWindowTabBanner.CurrentPostNumber)
	BroadcastEvent( SystemData.Events.UPDATE_GUILDSTANDARD )
end

function GuildWindowTabBanner.OnMouseoverBannerCancelButton()


    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_CANCEL_STANDARD_BUTTON) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
    Tooltips.Finalize ()
    
    local anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottom", XOffset=0, YOffset=-20 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)

end

function GuildWindowTabBanner.OnLButtonUpBannerCancelButton()
    ClearBanners()
    GuildWindowTabBanner.UpdateAllBannerConfigurations()
    GuildWindowTabBanner.UpdateSelectedBanner()
	GuildWindowTabBanner.SetRenderPostAndComboBox(GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].postID)

	-- We could assign a purchased tactic to a banner slot, which tints the tactic as in use, and then click the cancel button. 
	-- But that doesn't un-tint the tactic, so we have to go through and update them again.
	GuildWindowTabBanner.UpdatePurchasedTacticIcons()
end

function GuildWindowTabBanner.OnMouseOverBannerArrow()
    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_BANNER_STANDARDTOEDIT) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
    Tooltips.Finalize ()
    
    local anchor = { Point="bottom", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="topleft", XOffset=0, YOffset=20 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function GuildWindowTabBanner.OnMouseOverPostComboBox()
    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_BANNER_POSTSELECTION) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
    Tooltips.Finalize ()
    
    local anchor = { Point="right", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottomleft", XOffset=10, YOffset=0 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function GuildWindowTabBanner.OnMouseOverBannerTrophiesHeader()
    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_BANNER_TROPHIES_HEADER_DESCRIPTION) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
    Tooltips.Finalize ()
    
    local anchor = { Point="bottom", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="top", XOffset=0, YOffset=20 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function GuildWindowTabBanner.OnMouseOverBannerTacticsHeader()
    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_BANNER_TACTICS_HEADER_DESCRIPTION) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
    Tooltips.Finalize ()
    
    local anchor = { Point="bottom", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="top", XOffset=0, YOffset=20 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function GuildWindowTabBanner.OnLButtonUpBannerLeftArrow()
    GuildWindowTabBanner.CurrentBannerNumber = GuildWindowTabBanner.CurrentBannerNumber - 1
    if GuildWindowTabBanner.CurrentBannerNumber < 1 then
        GuildWindowTabBanner.CurrentBannerNumber = GuildWindowTabBanner.TOTAL_NUMBER_OF_STANDARDS
    end

	-- Clicking an arrow to change banners effectively cancels out the settings of the one that was selected.
    GuildWindowTabBanner.OnLButtonUpBannerCancelButton()
end

function GuildWindowTabBanner.OnLButtonUpBannerRightArrow()
    GuildWindowTabBanner.CurrentBannerNumber = GuildWindowTabBanner.CurrentBannerNumber + 1
    if GuildWindowTabBanner.CurrentBannerNumber > GuildWindowTabBanner.TOTAL_NUMBER_OF_STANDARDS then
        GuildWindowTabBanner.CurrentBannerNumber = 1
    end

   	-- Clicking an arrow to change banners effectively cancels out the settings of the one that was selected.
    GuildWindowTabBanner.OnLButtonUpBannerCancelButton()
end

function GuildWindowTabBanner.OnSelChangedPost()
	local postChoice = ComboBoxGetSelectedMenuItem("GWRewardsBannerPostCombo")
	if postChoice > 0 then
		GuildWindowTabBanner.SetRenderPostAndComboBox(postChoice)
	end
end

function GuildWindowTabBanner.OnHeraldryUpdatedFromServer()
    HeraldryEditor.SyncHeraldryOptions()
    ColorPicker.SelectedColorPickerWindowID = -1 -- Set the selected color to uninitialized.
    HeraldryEditor.UpdateAllChoiceLabels()
    HeraldryEditor.UpdateAllChoices(true)
    HeraldryEditor.UpdateColorChoices(true)
    
    GuildWindowTabBanner.UpdateSelectedBanner()
	GuildWindowTabRewards.UpdateRewardTactics()
    GuildWindowTabRewards.UpdateHeraldryResetButton()
end

-------------------------------------
-- Guild Trophy Slot Functions
-------------------------------------

---------- Available Trophies ----------

function GuildWindowTabBanner.OnMouseDragAvailTrophy()
end

function GuildWindowTabBanner.OnMouseOverAvailTrophy()
    local windowIndex   = WindowGetId (SystemData.ActiveWindow.name)
    
    if GuildWindowTabBanner.AvailableTrophyIcons[windowIndex] <= 0 then -- Can't select a trophy that doesn't exist.
        return  
    end
    
    local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()

	-- If the player doesn't have permission to ever edit the Guild Standard, hide the save and cancel buttons
	local bCanEditStandard  = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.BANNER_MANAGEMENT, playerTitleNumber)
	if (bCanEditStandard == false)
	then
	    return
	end
    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_BANNER_TROPHIES_EQUIP_DESCRIPTION) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
    local anchor = { Point="bottom", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="top", XOffset=0, YOffset=20 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.Finalize()
end

function GuildWindowTabBanner.OnRButtonUpAvailTrophy()

    local windowIndex   = WindowGetId (SystemData.ActiveWindow.name)
    
    if GuildWindowTabBanner.AvailableTrophyIcons[windowIndex] <= 0 then -- Can't select a trophy that doesn't exist.
        return  
    end
    local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()

	-- If the player doesn't have permission to ever edit the Guild Standard, hide the save and cancel buttons
	local bCanEditStandard  = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.BANNER_MANAGEMENT, playerTitleNumber)
	if (bCanEditStandard == false)
	then
	    return
	end
	
    GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].bannerID = GuildWindowTabBanner.AvailableTrophyIcons[windowIndex]
    local icon={}
    icon.texture, icon.x, icon.y = GetIconData( GuildWindowTabBanner.AvailableTrophyIcons[windowIndex] )
    DynamicImageSetTexture( "GWRewardsBannerTrophySlotIcon", icon.texture, icon.x, icon.y )

    
end

---------- Available Tactics ----------
function GuildWindowTabBanner.OnMouseDragAvailTactic()
    
    local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()

	-- If the player doesn't have permission to ever edit the Guild Standard, hide the save and cancel buttons
	local bCanEditStandard  = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.BANNER_MANAGEMENT, playerTitleNumber)
	if (bCanEditStandard == false)
	then
	    return
	end
	-- If the banner has been saved, do not allow edits.
	if (GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].lastEdited > 0)
	then
	    return
	end
    local tacticSlotNumber = WindowGetId(SystemData.MouseOverWindow.name)
    local tacticID = GuildWindowTabBanner.PurchasedTacticIconIDs[tacticSlotNumber]
    if (tacticID and tacticID > 0)
    then
        local abilityData = GuildTacticsList.GetTacticData (tacticID)
		
        Cursor.PickUp (Cursor.SOURCE_TACTICS_LIST, tacticSlotNumber, abilityData.abilityID, abilityData.iconNum, true)
        GuildWindowTabBanner.isMovingFromActiveSlot = false
    end
end

function GuildWindowTabBanner.ShowErrorDuplicateTacticCategory(bIsStatsBuff, bIsDefensive, bIsOffensive)
	local errorMsg = L""
    local okText = GetGuildString(StringTables.Guild.BUTTON_CONFIRM_OK)

	if bIsStatsBuff then  
		errorMsg = GetGuildString(StringTables.Guild.DIALOG_ERROR_GUILD_TACTIC_ISSTATSBUFF)
	elseif bIsDefensive then  
		errorMsg = GetGuildString(StringTables.Guild.DIALOG_ERROR_GUILD_TACTIC_ISDEFENSIVE)
	else
		errorMsg = GetGuildString(StringTables.Guild.DIALOG_ERROR_GUILD_TACTIC_ISOFFENSIVE)
	end

    DialogManager.MakeOneButtonDialog( errorMsg, okText)
end

function GuildWindowTabBanner.OnRButtonUpAvailTactic()

    Cursor.Clear()
    
    local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()

	-- If the player doesn't have permission to ever edit the Guild Standard, hide the save and cancel buttons
	local bCanEditStandard  = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.BANNER_MANAGEMENT, playerTitleNumber)
	if (bCanEditStandard == false) then
	    return
	end

	-- If the banner has been saved, do not allow edits.
	if (GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].lastEdited > 0) then
	    return
	end

    local tacticSlotNumber = WindowGetId(SystemData.MouseOverWindow.name)
    local tacticID = GuildWindowTabBanner.PurchasedTacticIconIDs[tacticSlotNumber]
    local abilityData = GuildTacticsList.GetTacticData( tacticID )

    if (ButtonGetDisabledFlag("GWRewardsBannerAvailTacticSlot"..tacticSlotNumber) == true) then
        return
    end

    -- Stick the ability in the first unlocked slot we find. If there aen't any empty ones, do nothing.
    for slotNum = 1, GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].numberUnlockedAbilitySlots do

		-- Check if there's already an ability type assigned and inform the user only 1 type per banner is allowed.
		if GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[slotNum] > 0 then
			local selectedAbilityData = GuildTacticsList.GetTacticData( GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[slotNum] )
			if selectedAbilityData ~= nil then 
				if  (abilityData.isStatsBuff == true and selectedAbilityData.isStatsBuff == true) or 
					(abilityData.isOffensive == true and selectedAbilityData.isOffensive == true) or
					(abilityData.isDefensive == true and selectedAbilityData.isDefensive == true) 
				then
					GuildWindowTabBanner.ShowErrorDuplicateTacticCategory(abilityData.isStatsBuff, abilityData.isDefensive, abilityData.isOffensive)
					return
				end					
			end
        end

		if GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[slotNum] == 0 then
            if DoesWindowExist("GWRewardsBannerAvailTacticSlot"..tacticSlotNumber) then
				ButtonSetDisabledFlag("GWRewardsBannerAvailTacticSlot"..tacticSlotNumber, true)
				WindowSetTintColor("GWRewardsBannerAvailTacticSlot"..tacticSlotNumber.."Icon", 92, 92, 92)
				GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[slotNum] = tacticID
				GuildWindowTabBanner.UpdateSelectedBannerTacticIcons()
				return
			end
        end
    end
end

function GuildWindowTabBanner.OnMouseOverAvailTactic()

    local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()

	local bCanEditStandard  = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.BANNER_MANAGEMENT, playerTitleNumber)
	local bIsStandardLocked = (GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].lastEdited > 0)
    local tacticSlotNumber = WindowGetId(SystemData.MouseOverWindow.name)
    local tacticID = GuildWindowTabBanner.PurchasedTacticIconIDs[tacticSlotNumber]

    local abilityData = GuildTacticsList.GetTacticData (tacticID)
    if (abilityData ~=nil) then
        if (bCanEditStandard == true)
        then
            if (bIsStandardLocked == false)
            then
                Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name, GuildTacticsList.ABILITY_POPUP_ANCHOR,  GetGuildString(StringTables.Guild.TOOLTIP_BANNER_TACTICS_EQUIP_DESCRIPTION))
            else
                Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name, GuildTacticsList.ABILITY_POPUP_ANCHOR,  GetGuildString(StringTables.Guild.TOOLTIP_BANNER_LOCKED))
            end
        else
            Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name, GuildTacticsList.ABILITY_POPUP_ANCHOR,  GetGuildString(StringTables.Guild.TOOLTIP_BANNER_NO_PERMISSION))
        end
    end
end

function GuildWindowTabBanner.OnMouseOverEndAvailTactic()
end

---------- Trophy Slots ----------
function GuildWindowTabBanner.OnMouseDragTrophySlot()
end

function GuildWindowTabBanner.OnMouseOverTrophySlot()
    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetFormatStringFromTable( "guildstrings", StringTables.Guild.TOOLTIP_BANNER_CURRENT_TROPHY_UNLOCKS_AT_RANK_Y, { GuildWindowTabBanner.TROPHY_UNLOCKS_AT_RANK } ) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
    Tooltips.Finalize ()
    
    local anchor = { Point="bottom", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="topleft", XOffset=0, YOffset=20 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function GuildWindowTabBanner.OnRButtonUpTrophySlot()
    local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()

	-- If the player doesn't have permission to ever edit the Guild Standard, hide the save and cancel buttons
	local bCanEditStandard  = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.BANNER_MANAGEMENT, playerTitleNumber)
	if (bCanEditStandard == false)
	then
	    return
	end
    GuildWindowTabBanner.UpdateSelectedBannerTrophyIcon()
end

---------- Tactic Slots ----------
function GuildWindowTabBanner.OnMouseDragTacticSlot()
    local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()

	-- If the player doesn't have permission to ever edit the Guild Standard, hide the save and cancel buttons
	local bCanEditStandard  = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.BANNER_MANAGEMENT, playerTitleNumber)
	if (bCanEditStandard == false)
	then
	    return
	end
	
	-- If the banner has been saved, do not allow edits.
	if (GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].lastEdited > 0)
	then
	    return
	end
    
    local tacticSlotNumber = WindowGetId(SystemData.MouseOverWindow.name)
    local tacticID = GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[tacticSlotNumber]
    
    if (tacticID > 0)
    then
        local abilityData = GuildTacticsList.GetTacticData (tacticID)

        if (abilityData == nil)
        then
            return
        end
        Cursor.PickUp (Cursor.SOURCE_TACTICS_LIST, tacticSlotNumber, abilityData.abilityID, abilityData.iconNum, true)
        GuildWindowTabBanner.isMovingFromActiveSlot = true
    end
end

function GuildWindowTabBanner.OnRButtonUpTacticSlot()
    local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()

	-- If the player doesn't have permission to ever edit the Guild Standard, hide the save and cancel buttons
	local bCanEditStandard  = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.BANNER_MANAGEMENT, playerTitleNumber)
	if (bCanEditStandard == false)
	then
	    return
	end
	
	-- If the banner has been saved, do not allow edits.
	if (GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].lastEdited > 0)
	then
	    return
	end
    
    local windowIndex = WindowGetId (SystemData.ActiveWindow.name)
    GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[windowIndex] = 0
    GuildWindowTabBanner.UpdateSelectedBannerTacticIcons()
    GuildWindowTabBanner.UpdatePurchasedTacticIcons()    
end

function GuildWindowTabBanner.OnLButtonUpTacticSlot()
    local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()

	-- If the player doesn't have permission to ever edit the Guild Standard, hide the save and cancel buttons
	local bCanEditStandard  = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.BANNER_MANAGEMENT, playerTitleNumber)
	if (bCanEditStandard == false)
	then
	    return
	end
	
	-- If the banner has been saved, do not allow edits.
	if (GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].lastEdited > 0)
	then
	    if (Cursor.IconOnCursor())
	    then
	        Cursor.Clear()
	    end
	    return
	end
    
    if (Cursor.IconOnCursor()) then
        local tacticSlotNumber = WindowGetId(SystemData.MouseOverWindow.name)
        local tacticID, availTacticSlotNumber = 0
        if (GuildWindowTabBanner.isMovingFromActiveSlot == true)
        then
            tacticID = GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[Cursor.Data.SourceSlot]
            -- Discover which Tactic in the AvailableList this Slot number is.
            for idxAvailSlot=1, GuildWindowTabBanner.TOTAL_NUMBER_OF_AVAILABLE_TACTICS do
                if (GuildWindowTabBanner.PurchasedTacticIconIDs[idxAvailSlot] == tacticID) then
                    availTacticSlotNumber = idxAvailSlot
                end
            end
            -- Swap the values between the two that are moving, and update the new slot with the tacticID
            GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[Cursor.Data.SourceSlot] = GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[tacticSlotNumber]
            GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[tacticSlotNumber] = tacticID
            if DoesWindowExist("GWRewardsBannerAvailTacticSlot"..availTacticSlotNumber) then
				ButtonSetDisabledFlag("GWRewardsBannerAvailTacticSlot"..availTacticSlotNumber, true)
				WindowSetTintColor("GWRewardsBannerAvailTacticSlot"..availTacticSlotNumber.."Icon", 92, 92, 92)
            end
			GuildWindowTabBanner.isMovingFromActiveSlot = false
        else
            tacticID = GuildWindowTabBanner.PurchasedTacticIconIDs[Cursor.Data.SourceSlot]
            -- If this tactic exists on any Standard, don't allow it to be put on a Standard
            for idxStandard = 1, GuildWindowTabBanner.TOTAL_NUMBER_OF_STANDARDS do
                for slotNum = 1, GuildWindowTabBanner.Banners[idxStandard].numberUnlockedAbilitySlots do
                    if GuildWindowTabBanner.Banners[idxStandard].AbilityID[slotNum] == tacticID
                    then
                        Cursor.Clear()
                        return
                    end
                end
            end
            
            local abilityData = GuildTacticsList.GetTacticData (tacticID)
    		for slotNum = 1, 3 do
    			if GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[slotNum] > 0 then
    				local selectedAbilityData = GuildTacticsList.GetTacticData( GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[slotNum] )
    				if selectedAbilityData ~= nil then
    					if  (abilityData.isStatsBuff == true and selectedAbilityData.isStatsBuff == true) or
    						(abilityData.isOffensive == true and selectedAbilityData.isOffensive == true) or
    						(abilityData.isDefensive == true and selectedAbilityData.isDefensive == true)
    					then
    						GuildWindowTabBanner.ShowErrorDuplicateTacticCategory(abilityData.isStatsBuff, abilityData.isDefensive, abilityData.isOffensive)
    						Cursor.Clear()
    						return
    					end
    				end
    			end
            end -- End for Loop
            
            -- Stick the ability where the user clicked.
            GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[tacticSlotNumber] = tacticID
				if DoesWindowExist("GWRewardsBannerAvailTacticSlot"..Cursor.Data.SourceSlot) then
					ButtonSetDisabledFlag("GWRewardsBannerAvailTacticSlot"..Cursor.Data.SourceSlot, true)
					WindowSetTintColor("GWRewardsBannerAvailTacticSlot"..Cursor.Data.SourceSlot.."Icon", 92, 92, 92)
				end
		end
            
        GuildWindowTabBanner.UpdateSelectedBannerTacticIcons()
        GuildWindowTabBanner.UpdatePurchasedTacticIcons()
        Cursor.Clear()
        -- Called to update after dragging around, could have stale tooltip lingering
        GuildWindowTabBanner.OnMouseOverTacticSlot()
    end
end

function GuildWindowTabBanner.OnMouseOverTacticSlot()
    local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()

	-- If the player doesn't have permission to ever edit the Guild Standard, hide the save and cancel buttons
	local bCanEditStandard  = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.BANNER_MANAGEMENT, playerTitleNumber)
    local bIsStandardLocked = (GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].lastEdited > 0)
    local tacticSlotNumber = WindowGetId(SystemData.MouseOverWindow.name)
    local tacticID = GuildWindowTabBanner.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[tacticSlotNumber]
    local abilityData = GuildTacticsList.GetTacticData( tacticID )
    if (abilityData ~=nil) then
        if (bCanEditStandard == true)
        then
            if (bIsStandardLocked == false)
            then
                Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name, GuildTacticsList.ABILITY_POPUP_ANCHOR, GetGuildString(StringTables.Guild.TOOLTIP_BANNER_CLEAR_TACTIC) )
            else
                Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name, GuildTacticsList.ABILITY_POPUP_ANCHOR, GetGuildString(StringTables.Guild.TOOLTIP_BANNER_LOCKED) )
            end
        else
            Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name, GuildTacticsList.ABILITY_POPUP_ANCHOR, GetGuildString(StringTables.Guild.TOOLTIP_NO_PERMISSION) )
        end
    elseif (GuildWindowTabBanner.isMovingFromActiveSlot == false)
    then
        Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
		-- If the guild has already unlocked this slot, tell the user how to assign a tactic to it.
		if GameData.Guild.m_GuildRank >= GuildWindowTabBanner.TacticUnlocks[GuildWindowTabBanner.CurrentBannerNumber][tacticSlotNumber] then
			Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_HOW_TO_ASSIGN_GUILD_TACTIC) )
		else	-- Otherwise, tell them when the slot unlocks.
			Tooltips.SetTooltipText (1, 1, GetFormatStringFromTable( "guildstrings", StringTables.Guild.TOOLTIP_BANNER_X_TACTIC_UNLOCKS_AT_RANK_Y, { tacticSlotNumber, GuildWindowTabBanner.TacticUnlocks[GuildWindowTabBanner.CurrentBannerNumber][tacticSlotNumber] } ) )
		end
        Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
        Tooltips.Finalize ()
        
        local anchor = { Point="bottom", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="topleft", XOffset=0, YOffset=20 }
        Tooltips.AnchorTooltip (anchor)
        Tooltips.SetTooltipAlpha (1)
    end

end

function GuildWindowTabBanner.OnRewardsUpdated()
	ClearBanners()
    GuildWindowTabBanner.UpdateAllBannerConfigurations()
    GuildWindowTabBanner.UpdateSelectedBanner()
	GuildWindowTabBanner.SetupPostComboBox()
	local postID = ComboBoxGetSelectedMenuItem("GWRewardsBannerPostCombo")
	if postID < 1 then
		ComboBoxSetSelectedMenuItem("GWRewardsBannerPostCombo", 1 )
	end
end

function GuildWindowTabBanner.UpdatePermissions()
	if GuildWindow.SelectedTab ~= GuildWindow.TABS_BANNER then
		return
	end

	GuildWindowTabBanner.UpdateBannerElements()
end

function GuildWindowTabBanner.OnMemberUpdated()
	GuildWindowTabBanner.UpdateBannerElements()
end

function GuildWindowTabBanner.OnBannersUpdated()
    ClearBanners()
    GuildWindowTabBanner.UpdateAllBannerConfigurations()
    GuildWindowTabBanner.UpdateSelectedBanner()
	GuildWindowTabBanner.UpdatePurchasedTacticIcons()
end
