----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

GuildWindowTabRewards = {}

GuildWindowTabRewards.rewardListData = {}
GuildWindowTabRewards.rewardListOrder = nil

GuildWindowTabRewards.tacticPointRewardIndexMap = {}


-- A value of -1 in a tactic slot means that it has not yet been purchased
GuildWindowTabRewards.TACTICID_INVALID = -1

-- Indicates a guild rank only has 1 reward and a tactic point (so we call AddSingleRewardAndTacticPoint())
GuildWindowTabRewards.TACTICID_SINGLE_REWARD_AND_TACTIC = -2

-- Guild Heraldry is set as -101 as a special case to indicate the tacticID is used for the Heraldry button.
GuildWindowTabRewards.TACTICID_GUILD_HERALDRY_OFFSET = -101

GuildWindowTabRewards.ABILITY_POPUP_ANCHOR = { Point="top", RelativeTo="", RelativePoint="bottom", XOffset=0, YOffset=-20 }

local function CompareRewards(index1, index2)   -- Compare function for sorting the rewards list.
    if (index2 == nil) then
        return false
    end

    local reward1 = GuildWindowTabRewards.rewardListData[index1]
    local reward2 = GuildWindowTabRewards.rewardListData[index2]
    
    -- Sort by Rank
    if reward1.rewardRank == reward2.rewardRank and reward1.sortOrder ~= nil then
		return reward1.sortOrder < reward2.sortOrder	-- Any subsorting is built into the table def 
    else
        return reward1.rewardRank < reward2.rewardRank
    end
end

function GuildWindowTabRewards.Initialize()

    LabelSetText( "GWRewardsListHeaderGuildRank", GetGuildString(StringTables.Guild.HEADER_GUILD_REWARDS_LIST_GUILD_RANK ) )
    LabelSetText( "GWRewardsListHeaderRewards", GetGuildString(StringTables.Guild.HEADER_GUILD_REWARDS_LIST_REWARDS ) )

    ButtonSetText( "GWRewardsShowTacticsButton", GetGuildString(StringTables.Guild.BUTTON_GUILD_REWARDS_SHOW_TACTICS ) )
    local color = DataUtils.GetAlternatingRowColorGreyOnGrey( 1 )

    ButtonSetText("GWRewardsResetHeraldryButton", GetGuildString(StringTables.Guild.BUTTON_GUILD_RESET_HERALDRY) )
    ButtonSetDisabledFlag("GWRewardsResetHeraldryButton", true)

    WindowSetTintColor("GWRewardsListHeaderBackground", color.r, color.g, color.b )
    WindowSetAlpha("GWRewardsListHeaderBackground", color.a)
    GuildWindowTabRewards.InitializeRewards()
    GuildWindowTabRewards.InitializeRewardsList()
    GuildWindowTabRewards.UpdateRewardRowColors()
    GuildWindowTabRewards.UpdateRewardTactics()

    WindowRegisterEventHandler( "GuildWindowTabRewards", SystemData.Events.GUILD_REWARDS_UPDATED, "GuildWindowTabRewards.OnRewardsUpdated")
    WindowRegisterEventHandler( "GuildWindowTabRewards", SystemData.Events.GUILD_MEMBER_UPDATED, "GuildWindowTabRewards.OnMemberUpdated")
		
end


-- Local Functions and Vars to help init the reward table
-- This lookup table has whether the reward is realm dependeant in the string table
-- It is indexed by the reward rank, and the reward number, so to check if a reward was realm dependent for a
-- rank 2 reward that is the second reward you recieve
-- You would write the following if rewardsRealmsAtRank[2][2] then CODE BLOCK end
local rewardsRealmAtRank =
{
    [5] = { [1]=1 },
    [5] = { [3]=1 },
    [6] = { [1]=1 },
    [9] = { [1]=1 },
    [13] = { [1]=1 },
    [16] = { [1]=1 },
    [17] = { [1]=1 },
    [18] = { [2]=1 },
    [18] = { [3]=1 },
    [22] = { [1]=1 },
    [26] = { [1]=1 },
    [30] = { [1]=1 },
    [30] = { [3]=1 },
    [34] = { [1]=1 },
    [38] = { [1]=1 }
}

-- Add a single guild reward
local function AddGuildRewardData( rank, taticId, realm, sortOrder, rewardNum )
    local IdString = "GUILD_RANK"..rank.."_REWARD"..rewardNum
    
    if( realm == 1 )
    then
        IdString = IdString.."_ORDER"
    end

    local rewardTable = { rewardRank=rank, tacticID=taticId, realm=realm, rewardID=StringTables.Guild["LABEL_"..IdString], tooltipID=StringTables.Guild["TOOLTIP_"..IdString], sortOrder=sortOrder }
    table.insert( GuildWindowTabRewards.rewardListData, rewardTable )
    if( taticId == -1 )
    then
        GuildWindowTabRewards.tacticPointRewardIndexMap[rank] = #GuildWindowTabRewards.rewardListData
    end
end

-- Get the rewards realm if it has one
local function GetRewardsRealm( rank, reward )
    local rewardsRealms = rewardsRealmAtRank[rank]
    local realm = 0
    if( rewardsRealms and rewardsRealms[reward] )
    then
        realm = rewardsRealms[reward]
    end
    
    return realm
end

local function AddSingleRewardAndTacticPoint( rank )
    local reward1Realm = GetRewardsRealm( rank, 1 )
    AddGuildRewardData( rank, 0, reward1Realm, 1, 1 )
    AddGuildRewardData( rank, -1, 0, 2, 2 )
end

local function AddSingleRewardRange( startRank, endRank )
    for rank=startRank, endRank
    do
        AddSingleRewardAndTacticPoint( rank )
    end
end

function GuildWindowTabRewards.InitializeRewards()       

	GuildWindowTabRewards.rewardListData = 
    {
        -- NOTE: "tacticID" is used to store unchosen and chosen tactic points, but also stores values for special buttons.
		-- 0 if no tactic point is awarded at this rank, a positive number represents 
        -- the tacticID that was purchased at that guild rank, and a negative number means that point number has yet to be spent.
        -- A tacticID of GuildWindowTabRewards.TACTICID_GUILD_HERALDRY_OFFSET (-101) is the Guild rank 9 button link to open the Heraldry.
        -- we'll use .realm to determine if the reward string table is realm specific. 
		-- .sortOrder will be used to sort the rewards of the same rewardRank.
        
        --[[ .csv file format
            A tacticId of -2 (GuildWindowTabRewards.TACTICID_SINGLE_REWARD_AND_TACTIC) means that guild rank has a single reward
                and tactic point (this replaces the calls to AddSingleRewardRange).
            A tacticId of -1 means GuildRewardTabRewards.TACTICID_INVALID
            A tacticId of -101 means GuildWindowTabRewards.TACTICID_GUILD_HERALDRY_OFFSET
            A sortOrder of 0 will get translated to nil before the call to AddGuildRewardData
        ]]
	}

    local guildRewards = GuildGetRewards()
    
    for k, v in ipairs(guildRewards) do    
        if(v.sortOrder == 0)
        then
            v.sortOrder = nil
        end
        
        if(v.tacticId == GuildWindowTabRewards.TACTICID_SINGLE_REWARD_AND_TACTIC)
        then
            AddSingleRewardAndTacticPoint(v.rank)
        else
            AddGuildRewardData(v.rank, v.tacticId, v.realm, v.sortOrder, v.rewardNum)
        end
    end
    
	GuildWindowTabRewards.InitializeRewardStrings()
end

function GuildWindowTabRewards.InitializeRewardStrings()
    for dataIndex, data in ipairs( GuildWindowTabRewards.rewardListData ) do
        if data.realm > 0 and GameData.Realm.DESTRUCTION == GameData.Player.realm then
            -- the tactic ID is 0 if there will be no tactic button, I use this to use a different label to make it pretty
            if (data.tacticID == 0)
            then
                data.rewardName = GetGuildString(data.rewardID + 1) -- Use the Destruction string instead, which is always 1 ID more than the Order one.
            else
                data.rewardName = GetGuildString(data.rewardID + 1) -- Use the Destruction string instead, which is always 1 ID more than the Order one.
            end
        else
            -- the tactic ID is 0 if there will be no tactic button, I use this to use a different label to make it pretty
            if (data.tacticID == 0)
            then
                data.rewardName = GetGuildString(data.rewardID) -- otherwise use the Order string
            else
                data.rewardName = GetGuildString(data.rewardID) -- otherwise use the Order string
            end
        end
    end
end


--------------------------------
-- List Functions
--------------------------------

-- populates the reward list rows with the names of the rewards
function GuildWindowTabRewards.InitializeRewardsList()

    -- We don't want to filter this list, so just add everything.
    GuildWindowTabRewards.rewardListOrder = {}
    for dataIndex, data in ipairs( GuildWindowTabRewards.rewardListData ) do
        table.insert(GuildWindowTabRewards.rewardListOrder, dataIndex)
    end

    -- Sort the list
    table.sort( GuildWindowTabRewards.rewardListOrder, CompareRewards )

    -- Finally, set the listbox to display our data
    ListBoxSetDisplayOrder( "GWRewardsList", GuildWindowTabRewards.rewardListOrder )
 
 end

-- <List Callback>
function GuildWindowTabRewards.PopulateRewards()
    GuildWindowTabRewards.UpdateRewardRowColors()
    GuildWindowTabRewards.UpdateRewardTactics()
end

-- Updates all the colors in a Reward row, including text colors AND row tinting. 
-- NOTE: These rows are NOT alternating colors. We change the color based on the Rank, not the row#.
-- This allows us to make it seem as if several lines exist for a single rank with multiple rewards. 
function GuildWindowTabRewards.UpdateRewardRowColors()

    if GWRewardsList.PopulatorIndices == nil then
        return 
    end

    local rewardData = nil
    local rowName = nil
    local row_mod = 0
    local color = nil

    for row, data in ipairs(GWRewardsList.PopulatorIndices) do
        rewardData = GuildWindowTabRewards.rewardListData[data]
        rowName = "GWRewardsListRow"..row

        -- Text Colors
        if rewardData.rewardRank <= GameData.Guild.m_GuildRank then
            DefaultColor.LabelSetTextColor(rowName.."Rank", DefaultColor.GUILD_RANK)
            DefaultColor.LabelSetTextColor(rowName.."Name", DefaultColor.WHITE)
            DefaultColor.LabelSetTextColor(rowName.."NameNoTactic", DefaultColor.WHITE)
        else
            DefaultColor.LabelSetTextColor(rowName.."Rank", DefaultColor.GUILD_MEDIUM_GRAY)
            DefaultColor.LabelSetTextColor(rowName.."Name", DefaultColor.GUILD_MEDIUM_GRAY)
            DefaultColor.LabelSetTextColor(rowName.."NameNoTactic", DefaultColor.GUILD_MEDIUM_GRAY)
        end

        -- Background Tints
        row_mod = math.mod(rewardData.rewardRank, 2)
        color = DataUtils.GetAlternatingRowColorGreyOnGrey( row_mod )

        WindowSetTintColor(rowName.."Background", color.r, color.g, color.b )
        WindowSetAlpha(rowName.."Background", color.a)
    end
end

function GuildWindowTabRewards.IsHeraldryButton(rewardData)
	return (rewardData.tacticID == GuildWindowTabRewards.TACTICID_GUILD_HERALDRY_OFFSET and 
			GameData.Guild.m_GuildRank >= rewardData.rewardRank)
end

function GuildWindowTabRewards.UpdateHeraldryResetButton( heraldryData )
    if( not heraldryData )
    then
        heraldryData = GetHeraldryConfigurationData()
    end

    local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
	local bCanResetHeraldry = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_HERALDRY, playerTitleNumber) and heraldryData.reserved == SystemData.GuildHeraldryReservation.LOCKED

    -- If heraldry is not reserved or we do not have permission to reset then disable the button
    ButtonSetDisabledFlag("GWRewardsResetHeraldryButton",  not bCanResetHeraldry)
end

function GuildWindowTabRewards.UpdateRewardTactics()
    if GWRewardsList.PopulatorIndices == nil then
        return 
    end

    local rewardData = nil
    local rowName = nil

    for row, data in ipairs(GWRewardsList.PopulatorIndices)
    do
        rewardData = GuildWindowTabRewards.rewardListData[data]
        
        local useNoTacticLabel = true
        
		-- Special case for the Reserve Heraldry Button
        if GuildWindowTabRewards.IsHeraldryButton(rewardData)
        then
            -- Show if we've already reserved the Heraldry or not. If we aren't high enough Guild Rank yet, don't show the button.
            local heraldryData = GetHeraldryConfigurationData()
            if heraldryData ~= nil and heraldryData.reserved == SystemData.GuildHeraldryReservation.LOCKED then
                useNoTacticLabel = false
                ButtonSetText("GWRewardsListRow"..row.."Tactic", GetGuildString(StringTables.Guild.LABEL_HERALDRY_RESERVED) )
                ButtonSetDisabledFlag("GWRewardsListRow"..row.."Tactic", true)
            else
				local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
				local bCanReserveHerald = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_HERALDRY, playerTitleNumber)
				if bCanReserveHerald == true
                then
					ButtonSetText("GWRewardsListRow"..row.."Tactic", GetGuildString(StringTables.Guild.BUTTON_RESERVE_HERALDRY) )
					useNoTacticLabel = false
					ButtonSetDisabledFlag("GWRewardsListRow"..row.."Tactic", false)
				end
            end
        elseif rewardData.tacticID < 0 and (GameData.Guild.m_GuildRank >= rewardData.rewardRank)
        then
			-- If the user doesn't have permission to purchase tactics, hide the button
			local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
			local bCanPurchaseTactic = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.TACTICS_PURCHASE, playerTitleNumber)
			if bCanPurchaseTactic == true
            then
				ButtonSetText("GWRewardsListRow"..row.."Tactic", GetGuildString(StringTables.Guild.BUTTON_CHOOSE_TACTIC) )
				useNoTacticLabel = false
				ButtonSetDisabledFlag("GWRewardsListRow"..row.."Tactic", false)
			end
        elseif rewardData.tacticID > 0 and (GameData.Guild.m_GuildRank >= rewardData.rewardRank) 
        then
            local ability = GuildTacticsList.GetTacticData( rewardData.tacticID )
            if (ability ~= nil and ability.name~=nil and ability.name ~=L"") 
            then
                ButtonSetText("GWRewardsListRow"..row.."Tactic", ability.name)
            else
                ButtonSetText("GWRewardsListRow"..row.."Tactic", L"Tactic Name Unknown")
            end
            ButtonSetDisabledFlag("GWRewardsListRow"..row.."Tactic", true)
            useNoTacticLabel = false
        end
        
        WindowSetShowing( "GWRewardsListRow"..row.."Tactic", not useNoTacticLabel )
        WindowSetShowing( "GWRewardsListRow"..row.."Name", not useNoTacticLabel )
        WindowSetShowing( "GWRewardsListRow"..row.."NameNoTactic", useNoTacticLabel )
    end
end

function GuildWindowTabRewards.OnLButtonUpViewTacticsListButton()
    local bShowing = WindowGetShowing("GuildTacticsList")
    if bShowing then
        GuildRespecTacticsList.Show()
    else
        GuildRespecTacticsList.Show()
    end
end

function GuildWindowTabRewards.OnLButtonUpResetHeraldry()
    if( not ButtonGetDisabledFlag( "GWRewardsResetHeraldryButton" ) )
    then
        -- Pop up dialog to confirm (or have the server send it through a server dialog)
        local heraldryCost = GetHeraldryResetCost()
            
        -- Create Confirmation Dialog
        local dialogText = GetFormatStringFromTable( "guildstrings", StringTables.Guild.DIALOG_CONFIRM_RESET_HERALDRY, { MoneyFrame.FormatMoneyString (heraldryCost, false, true) } )
        
        local function resetHeraldyConfirmed()
            ResetGuildHeraldry()
        end

        DialogManager.MakeTwoButtonDialog( dialogText, 
									       GetGuildString(StringTables.Guild.BUTTON_CONFIRM_YES),
									       resetHeraldyConfirmed,
									       GetGuildString(StringTables.Guild.BUTTON_CONFIRM_NO),
									       nil )
    end
end

function GuildWindowTabRewards.OnLButtonUpChooseTacticButton()

    if ButtonGetDisabledFlag(SystemData.ActiveWindow.name) == true then -- Don't allow clicks for disabled buttons (tactic has already been chosen)
        return
    end

    local windowIndex   = WindowGetId (SystemData.ActiveWindow.name)
    local windowParent  = WindowGetParent (SystemData.ActiveWindow.name)
    local dataIndex     = ListBoxGetDataIndex (WindowGetParent(windowParent), windowIndex)

    local guildRankSelected = GuildWindowTabRewards.rewardListData[dataIndex].rewardRank

    -- This is the special case of opening the Heraldry Editor instead of the Tactics Editor.
    if GuildWindowTabRewards.rewardListData[dataIndex].tacticID == GuildWindowTabRewards.TACTICID_GUILD_HERALDRY_OFFSET then
        GuildTacticsList.CurrentGuildRankSelected = 0
        GuildWindowTabBanner.OnLButtonUpEditHeraldryButton()
	else
        GuildTacticsList.CurrentGuildRankSelected = guildRankSelected
        GuildTacticsList.OnOpened()
        ButtonSetDisabledFlag("GuildTacticsListPurchaseButton", true)
    end
end

function GuildWindowTabRewards.OnMouseOverTacticButton()

    local anchorWindow = WindowGetParent( SystemData.MouseOverWindow.name ).."Background"
    local anchor = { Point="topright", RelativeTo=anchorWindow, RelativePoint="topleft", XOffset=0, YOffset=0 }

    -- If the button has been disabled, that means that its been assigned to a tactic, so lets show an ability tooltip for it. 
    if ButtonGetDisabledFlag(SystemData.ActiveWindow.name) == false then 
        local buttonText = ButtonGetText(SystemData.ActiveWindow.name)   
        if (WStringsCompare(buttonText, GetGuildString(StringTables.Guild.BUTTON_CHOOSE_TACTIC)) == 0)
        then
            Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
            Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_REWARDS_CHOOSE_TACTIC) )
            Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
            Tooltips.Finalize ()
            Tooltips.AnchorTooltip (anchor)
        elseif (WStringsCompare(buttonText, GetGuildString(StringTables.Guild.BUTTON_RESERVE_HERALDRY)) == 0)
        then
            Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
            Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_HERALDRY_RESERVE) )
            Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
            Tooltips.Finalize ()
            Tooltips.AnchorTooltip (anchor)
        end
        return
    end

    local windowIndex   = WindowGetId (SystemData.ActiveWindow.name)
    local windowParent  = WindowGetParent (SystemData.ActiveWindow.name)
    local dataIndex     = ListBoxGetDataIndex (WindowGetParent(windowParent), windowIndex)

    local abilityID = GuildWindowTabRewards.rewardListData[dataIndex].tacticID

    local abilityData = GuildTacticsList.GetTacticData( abilityID )
    if (abilityData ~=nil) then
        Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name, GuildWindowTabRewards.ABILITY_POPUP_ANCHOR )
    end
end

function GuildWindowTabRewards.OnMouseOverTacticName()
    local windowIndex   = WindowGetId (SystemData.ActiveWindow.name)
    local windowParent  = WindowGetParent (SystemData.ActiveWindow.name)
    local dataIndex     = ListBoxGetDataIndex (WindowGetParent(windowParent), windowIndex)

    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)

    if GuildWindowTabRewards.rewardListData[dataIndex].realm > 0 and GameData.Realm.DESTRUCTION == GameData.Player.realm then
        Tooltips.SetTooltipText (1, 1, GetGuildString(GuildWindowTabRewards.rewardListData[dataIndex].tooltipID + 1) )-- Destruction tooltips are 1 ID higher.
    else
        Tooltips.SetTooltipText (1, 1, GetGuildString(GuildWindowTabRewards.rewardListData[dataIndex].tooltipID) )
    end

    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
    Tooltips.Finalize ()
    
    local anchorWindow = WindowGetParent( SystemData.MouseOverWindow.name ).."Background"
    local anchor = { Point="topright", RelativeTo=anchorWindow, RelativePoint="topleft", XOffset=0, YOffset=0 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)

end

function GuildWindowTabRewards.OnRewardsUpdated()
    GuildWindowTabRewards.UpdateHeraldryResetButton()
    GuildWindowTabAdmin.UpdateGuildTitles() -- Update the Maximum Number of Standard Bearers which increases as the Guild Ranks
end

function GuildWindowTabRewards.UpdateTacticToPurchased( abilityID, guildRankPurchasedAt )

    local rewardData = GuildWindowTabRewards.rewardListData[ GuildWindowTabRewards.tacticPointRewardIndexMap[guildRankPurchasedAt] ]
    if( rewardData and rewardData.tacticID == GuildWindowTabRewards.TACTICID_INVALID )
    then
        rewardData.tacticID = abilityID
    end

end

function GuildWindowTabRewards.GetRewardList()
    return GuildWindowTabRewards.rewardListData
end

function GuildWindowTabRewards.GetRewardTacticPointRewardIndexMap()
    return GuildWindowTabRewards.tacticPointRewardIndexMap
end

function GuildWindowTabRewards.ClearPurchasedTactics()
    local rewardDataList = GuildWindowTabRewards.rewardListData
    local rewardData

    for k, tacticRewardIndex in pairs (GuildWindowTabRewards.tacticPointRewardIndexMap)
    do
        rewardData = rewardDataList[tacticRewardIndex]
        if( rewardData and rewardData.tacticID > 0 )
        then
            rewardData.tacticID = GuildWindowTabRewards.TACTICID_INVALID
        end
    end

end

function GuildWindowTabRewards.UpdatePermissions()
	if GuildWindow.SelectedTab ~= GuildWindow.TABS_REWARDS then
		return
	end
    GuildWindowTabRewards.UpdateHeraldryResetButton()
	GuildWindowTabRewards.UpdateRewardTactics()
end

function GuildWindowTabRewards.OnMemberUpdated()
	GuildWindowTabRewards.UpdateRewardTactics()
end

