----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

GuildTacticsList = {}

GuildTacticsList.abilityListData    = {}
GuildTacticsList.tacticsTable       = {}
GuildTacticsList.abilityListOrder   = {}
GuildTacticsList.abilityPurchasedListOrder   = {}

-- Sorting Parameters for the Ability List
GuildTacticsList.SORT_TYPE_NAME         = 1
GuildTacticsList.SORT_TYPE_MAX_NUMBER   = 1

GuildTacticsList.FILTER_MEMBERS_ALL     = 1
GuildTacticsList.FILTER_MAX_NUMBER      = 1

GuildTacticsList.SORT_ORDER_UP          = 1
GuildTacticsList.SORT_ORDER_DOWN        = 2

GuildTacticsList.CurrentGuildRankSelected       = 0 -- To purchase a tactic, player must have opened the tactics List via the Choose Tactic button.
GuildTacticsList.SelectedGuildRank              = 0 -- This stores the selected guild rank so C can pull from it.
GuildTacticsList.SelectedTacticIDWString        = L""
GuildTacticsList.SelectedAbilityDataIndexInList = 0 -- The index into the listtable of the guild tactic that the user selected.

GuildTacticsList.sortButtons = {  "GuildTacticsListSortButtonBarNameButton",        -- Order List Header 
                                        }

GuildTacticsList.sortKeys = {"name",
                                    }

GuildTacticsList.display = { type=GuildTacticsList.SORT_TYPE_NAME, 
                                order=GuildTacticsList.SORT_ORDER_UP, 
                                filter=GuildTacticsList.FILTER_MEMBERS_ALL }

GuildTacticsList.ABILITY_POPUP_ANCHOR = { Point="topright", RelativeTo="", RelativePoint="topleft", XOffset=0, YOffset=0 }

local function InitAbilityListData()

    GuildTacticsList.tacticsTable = GetAbilityTable (GameData.AbilityType.GUILD)
    GuildTacticsList.abilityListData = {}

    GuildWindowTabRewards.ClearPurchasedTactics()

    local guildAdvancementData = GetGuildAdvancementData()

    if ( guildAdvancementData ~=nil) then
        for key, value in ipairs( guildAdvancementData ) do

            if (value.abilityID > 0) then
                GuildTacticsList.abilityListData[key] = {}
                GuildTacticsList.abilityListData[key].abilityID = value.abilityID
				GuildTacticsList.abilityListData[key].prereqAbilityID = value.prereqAbilityID
                GuildTacticsList.abilityListData[key].guildRankPurchasedAt = value.guildRankPurchasedAt

                -- Be courteous and let the rewards tab know that the tactic has been purchased so its list will update accordingly.
                if value.guildRankPurchasedAt > 0 then
                    GuildWindowTabRewards.UpdateTacticToPurchased(value.abilityID, value.guildRankPurchasedAt)
                end

                local ability = GuildTacticsList.GetTacticData (value.abilityID)
                
                if (ability ~= nil and ability.name~=nil and ability.name ~=L"") then
                    GuildTacticsList.abilityListData[key].name = ability.name
                    GuildTacticsList.abilityListData[key].iconNum = ability.iconNum
                end
            end
        end

        -- Update the rewards tab only after we have updated all of its data
        GuildWindowTabRewards.UpdateRewardTactics()
    end
end

local function GetAblityIDFromBannerSlot(slotNumber)
    if (slotNumber ~= nil and slotNumber > 0 and slotNumber <= 3) then
        return GuildTacticsList.Banners[GuildWindowTabBanner.CurrentBannerNumber].AbilityID[slotNumber]
    end
end

local function CompareAbilities( index1, index2 )

    if( index2 == nil ) then
        return false
    end

    local ability1 = GuildTacticsList.abilityListData[index1]
    local ability2 = GuildTacticsList.abilityListData[index2]
    
    if (ability1 == nil or ability1.name == nil or ability1.name == L"") then
        return false
    end
    
    if (ability2 == nil or ability2.name == nil or ability2.name == L"") then
        return true
    end
    
    local type = GuildTacticsList.display.type
    local order = GuildTacticsList.display.order
    
    local compareResult
-- Check for sorting by all the the string fields first
    
    -- Sorting by Name
    if( type == GuildTacticsList.SORT_TYPE_NAME )then
        if( order == GuildTacticsList.SORT_ORDER_UP ) then
            return ( WStringsCompare(ability1.name, ability2.name) < 0 )
        else
            return ( WStringsCompare(ability1.name, ability2.name) > 0 )
        end
    end
    
-- Otherwise assume we're sorting by a number, not a string.
    -- Sorting By A Numerical Value - When tied, sort by name
    local key = GuildTacticsList.sortKeys[type]
    if( tonumber(ability1[key]) == tonumber(ability2[key]) ) then
        compareResult = WStringsCompare(ability1.name, ability2.name)
    else        
        if ( tonumber(ability1[key]) < tonumber(ability2[key]) ) then
            compareResult = -1
        else
            compareResult = 1
        end
    end
    
    if( order == GuildTacticsList.SORT_ORDER_UP ) then
        return ( compareResult < 0)
    else
        return ( compareResult > 0)
    end
end

local function SortAbilityList()
    table.sort( GuildTacticsList.abilityListOrder, CompareAbilities )
    table.sort( GuildTacticsList.abilityPurchasedListOrder, CompareAbilities )
end

local function FilterAbilityList()  
    GuildTacticsList.abilityListOrder = {}
    GuildTacticsList.abilityPurchasedListOrder = {}
    for dataIndex, data in ipairs( GuildTacticsList.abilityListData ) do
        if (data.guildRankPurchasedAt == 0) then										-- Only add tactics that we've yet to purchase
			if GuildTacticsList.HasPrereqBeenPurchased(data.abilityID) == true then		-- Only add tactics we can buy (no unmet prereqs)
				table.insert(GuildTacticsList.abilityListOrder, dataIndex)
			end
        else
            table.insert(GuildTacticsList.abilityPurchasedListOrder, dataIndex)
        end
    end
end

local function UpdateAbilityList()
    -- Filter, Sort, and Update
    InitAbilityListData()
    GuildTacticsList.display.filter = GuildTacticsList.FILTER_MEMBERS_ALL
    FilterAbilityList()
    SortAbilityList()
    ListBoxSetDisplayOrder( "GuildTacticsListAbilityList", GuildTacticsList.abilityListOrder )
end

-- OnInitialize Handler
function GuildTacticsList.Initialize()
    LabelSetText( "GuildTacticsListTitleBarText", GetGuildString(StringTables.Guild.LABEL_GUILD_TACTICS_LIST) )

    ButtonSetText( "GuildTacticsListPurchaseButton", GetGuildString(StringTables.Guild.BUTTON_TACTICS_PURCHASE) )
    ButtonSetText( "GuildTacticsListCancelButton", GetGuildString(StringTables.Guild.BUTTON_TACTICS_CANCEL) )
    
    UpdateAbilityList()
    GuildTacticsList.SetListRowTints()

    WindowRegisterEventHandler( "GuildTacticsList", SystemData.Events.GUILD_ABILITIES_PURCHASED_UPDATED, "GuildTacticsList.OnAbilitiesPurchasedUpdated")
    WindowRegisterEventHandler( "GuildTacticsList", SystemData.Events.GUILD_ABILITIES_AVAILABLE_UPDATED, "GuildTacticsList.OnAbilitiesUpdated")

end

function GuildTacticsList.OnAbilitiesUpdated()
    UpdateAbilityList()
    GuildTacticsList.SetListRowTints()
    GuildRespecTacticsList.UpdateDisplayList()
end

function GuildTacticsList.OnClose()
    GuildTacticsList.CurrentGuildRankSelected = 0
end

function GuildTacticsList.UpdateSelectedAbilityByRowNumber( rowNumber )
    -- Set the label values
    if (rowNumber ~= nil and rowNumber ~= 0) then
        local dataIndex = ListBoxGetDataIndex("GuildTacticsListAbilityList", rowNumber)
        GuildTacticsList.SelectedAbilityDataIndexInList = dataIndex
    else
        GuildTacticsList.SelectedAbilityDataIndexInList = 0
    end
end

function GuildTacticsList.GetPrereqTacticID(tacticID)
    -- First, Find the tactic in our list
	for key, value in ipairs( GuildTacticsList.abilityListData ) do		
		if (value.abilityID == tacticID) then					-- Found the tactic
			if value.prereqAbilityID == 0 then
				return 0										-- If this tactic doesn't have a prereq, return 0
			else
			    return value.prereqAbilityID
			end
		end
	end
end

-- Returns true if the passed in tactic ID can be purchased based on prereqs, false otherwise.
function GuildTacticsList.HasPrereqBeenPurchased(tacticID)

	-- First, Find the tactic in our list
	for key, value in ipairs( GuildTacticsList.abilityListData ) do		
		if (value.abilityID == tacticID) then					-- Found the tactic
			if value.prereqAbilityID == 0 then
				return true										-- If this tactic doesn't have a prereq, return true
			end

			-- Second, find the prereq tactic in our list
			for key2, value2 in ipairs( GuildTacticsList.abilityListData ) do
				if (value2.abilityID == value.prereqAbilityID) then		-- Found the prereq tactic
					if value2.guildRankPurchasedAt > 0 then				-- If it's been purchased, return TRUE, False otherwise.
						return true
					else
						return false
					end
				end
			end
		end
	end
	
	-- we should never get here, but just in case
	return false
end

-- Highlights the text of the selected ability
function GuildTacticsList.UpdateHighlightedAbilityText(rowIndex)

    local labelColor = { r=255, g=255, b=255 }      -- Default Ability Text is white
    local dataIndex = ListBoxGetDataIndex("GuildTacticsListAbilityList", rowIndex)
    if (dataIndex ~=nil and dataIndex > 0) then

        local labelName = "GuildTacticsListAbilityListRow"..rowIndex

        if (GuildTacticsList.SelectedAbilityDataIndexInList == dataIndex) then
            labelColor = { r=255, g=204, b=102 }        -- Selected member is yellow, regardless of anything else
        end

        LabelSetTextColor (labelName.."Name", labelColor.r, labelColor.g, labelColor.b)
    end
end

-- Populates the career icon
function GuildTacticsList.PopulateIcon(_rowName, abilityID)
    local abilityData = GuildTacticsList.GetTacticData (abilityID)
    
    if (abilityData ~= nil)
    then
        local texture, x, y = GetIconData (abilityData.iconNum)
        DynamicImageSetTexture(_rowName.."AbilityIcon", texture, x, y)
    else
        local icon = GuildWindowTabBanner.TACTIC_ICON_EMPTY
        DynamicImageSetTexture(_rowName.."AbilityIcon", icon.texture, icon.x, icon.y)
    end
end

-- Callback from the <List> that updates a single row.
function GuildTacticsList.UpdateAbilityRow()
    if (GuildTacticsListAbilityList.PopulatorIndices ~= nil) then
        local windowRowName = ""

        for rowIndex, dataIndex in ipairs (GuildTacticsListAbilityList.PopulatorIndices) do
            GuildTacticsList.UpdateHighlightedAbilityText(rowIndex)
            GuildTacticsList.PopulateIcon("GuildTacticsListAbilityListRow"..rowIndex, GuildTacticsList.abilityListData[dataIndex].abilityID)
            ButtonSetPressedFlag("GuildTacticsListAbilityListRow"..rowIndex,  (dataIndex == GuildTacticsList.SelectedAbilityDataIndexInList) )
        end
    end
end

function GuildTacticsList.SetListRowTints()
    local targetRowWindow = ""
    local row_mod = 0
    local color

    for row = 1, GuildTacticsListAbilityList.numVisibleRows do
        row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        targetRowWindow = "GuildTacticsListAbilityListRow"..row
        WindowSetTintColor(targetRowWindow.."RowBackground", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."RowBackground", color.a)
    end
end

function GuildTacticsList.OnMouseOverAbilityRow()
    local rowNumber = WindowGetId(SystemData.MouseOverWindow.name)
    local dataIndex = ListBoxGetDataIndex(WindowGetParent(SystemData.MouseOverWindow.name)--[["GuildTacticsListAbilityList"--]], rowNumber)
    local guildAbilityInfo = GuildTacticsList.abilityListData[dataIndex]

    local abilityData = GuildTacticsList.GetTacticData (guildAbilityInfo.abilityID)
    
    if (abilityData ~= nil) 
    then
        Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name, GuildTacticsList.ABILITY_POPUP_ANCHOR )
    end
end

function GuildTacticsList.OnLButtonUpAbilityRow()

    local rowNumber = WindowGetId(SystemData.MouseOverWindow.name)
    local dataIndex = ListBoxGetDataIndex("GuildTacticsListAbilityList", rowNumber)
    if (dataIndex == GuildTacticsList.SelectedAbilityDataIndexInList) then
        GuildTacticsList.UpdateSelectedAbilityByRowNumber()             -- Unselect if row is already selected
		ButtonSetDisabledFlag("GuildTacticsListPurchaseButton", true)
    else
        GuildTacticsList.UpdateSelectedAbilityByRowNumber(rowNumber)    -- Select the row
		ButtonSetDisabledFlag("GuildTacticsListPurchaseButton", GuildTacticsList.CurrentGuildRankSelected == 0)
    end
    GuildTacticsList.UpdateHighlightedAbilityText(rowNumber)
    GuildTacticsList.UpdateAbilityRow()
end

function GuildTacticsList.OnRewardsUpdated()    -- Event function trigger
    InitBannerConfiguration()   
end

function GuildTacticsList.OnAbilitiesPurchasedUpdated() -- Event function trigger
    GuildTacticsList.OnAbilitiesUpdated()
    
    -- Update the Purchased Guild tactic icons in the Guild Window Tab Stndard window
    GuildWindowTabBanner.UpdatePurchasedTacticIcons()

    -- Update the colors of the rows and any tactics that were bought.
    GuildWindowTabRewards.PopulateRewards()
end

function GuildTacticsList.OnOpened()
    WindowSetShowing("GuildTacticsList", true)
end

function GuildTacticsList.OnHidden()
    WindowSetShowing("GuildTacticsList", false)
    GuildTacticsList.SelectedAbilityDataIndexInList = 0
    GuildTacticsList.CurrentGuildRankSelected = 0
end

function GuildTacticsList.OnLButtonUpCancelButton()
    WindowSetShowing("GuildTacticsList", false)
	GuildTacticsList.UpdateSelectedAbilityByRowNumber()	-- Unselect row
	GuildTacticsList.UpdateAbilityRow()
end

function GuildTacticsList.OnLButtonUpPurchaseButton()
    if (GuildTacticsList.SelectedAbilityDataIndexInList == 0) then
        DEBUG(L"[GuildTacticsList.Purchase] Cannot purchase an invalid ability index")
        return
    end

    local abilityInfo = GuildTacticsList.abilityListData[GuildTacticsList.SelectedAbilityDataIndexInList]
    if (abilityInfo == nil or abilityInfo.abilityID == nil) then
        DEBUG(L"[GuildTacticsList.Purchase] Cannot purchase an ability with Invalid info")
        return
    end

    if GuildTacticsList.CurrentGuildRankSelected > 0 then
        -- GuildTacticsList.SelectedGuildRank is the variable that's being used in C to determine what Guild Rank was selected
        GuildTacticsList.SelectedGuildRank = GuildTacticsList.CurrentGuildRankSelected
        -- GuildTacticsList.SelectedTacticIDWString is the variable that's being used in C to determine what AbilityID to purchase.
        GuildTacticsList.SelectedTacticIDWString = L""..abilityInfo.abilityID
        BroadcastEvent( SystemData.Events.GUILD_COMMAND_PURCHASE_TACTIC )
        GuildTacticsList.OnHidden()
    end
end

function GuildTacticsList.OnMouseOverPurchaseButton()
    Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString(StringTables.Guild.TOOLTIP_GUILD_TACTICS_PURCHASE_BUTTON) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)  
    Tooltips.Finalize ()
    
    local anchor = { Point="topright", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottom", XOffset=0, YOffset=-20 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function GuildTacticsList.GetTacticData (id)
    if (id)
    then
        return GuildTacticsList.tacticsTable[id]
    end
    
    return nil
end
