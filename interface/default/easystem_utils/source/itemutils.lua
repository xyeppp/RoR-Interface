
-- NOTE: This file is documented with NaturalDocs style comments. All comments begining with "--#' will
-- be included in the output.

ItemUtils = {}

ItemUtils.currentItemLoc = nil
ItemUtils.currentItemSlot = nil

ItemUtils.tooltips = {L"", L"", L""}

function ItemUtils.Initialize()
    CreateWindow( "BindOptionsDlg", false )
    LabelSetText("BindOptionsDlgBoxTitleBarText", GetString (StringTables.Default.TEXT_WHICH_BIND_USE))
    ButtonSetText("BindOptionsDlgBoxButton1", GetString (StringTables.Default.TEXT_BIND_USE1))
    ButtonSetText("BindOptionsDlgBoxButton2", GetString (StringTables.Default.TEXT_BIND_USE2))
    ButtonSetText("BindOptionsDlgBoxButton3", GetString (StringTables.Default.TEXT_BIND_USE3))
end

function ItemUtils.ShutDown()
    DestroyWindow( "BindOptionsDlg" )
end

-- I've made this function specificly for the book of binding
-- it can certainly be expanded upon to allow for generic items to have multiple
-- use bonuses in the future
function ItemUtils.ShowUseOptions(itemData, itemLoc, itemSlot)
    local buttonTexts = {L"", L"", L""}
    local buttonIndex = 0

    for i, bonus in ipairs(itemData.bonus) do
        if ((bonus.type == GameDefs.ITEMBONUS_USE) and (bonus.reference > 0))
        then
            local bonusText = ItemUtils.GetFormattedBonus (bonus, false, itemData.currChargesRemaining, itemData.iLevel, itemData.careers);
            -- increment first so that after the for loop we have the number of use bonuses
            buttonIndex = buttonIndex + 1
            ItemUtils.tooltips[buttonIndex] = bonusText
        end
    end

    -- We only need to show a dialog if there are 3 use options
    -- we'll return false if we don't show the dialog
    if buttonIndex ~= 3
    then
        return false
    end

    ItemUtils.currentItemLoc = itemLoc
    ItemUtils.currentItemSlot = itemSlot

    WindowSetShowing("BindOptionsDlg", true)

    -- since we have shown the dialog we'll return true
    return true
end

function ItemUtils.HideUseOptions()
    WindowSetShowing("BindOptionsDlg", false)
end

function ItemUtils.UseOption()
    if (ItemUtils.currentItemLoc ~= nil) and (ItemUtils.currentItemSlot ~= nil)
    then
        -- have to subtract 1 because the window ID is based on the lua array index starting at 1
        -- and the SendUseItem call goes to C++ which has the array index starting at 0
        local dlgIndex = WindowGetId( SystemData.ActiveWindow.name) - 1
        SendUseItem(ItemUtils.currentItemLoc, ItemUtils.currentItemSlot, dlgIndex, 0, 0)

        -- Hide the window and remove focus
        WindowSetShowing("BindOptionsDlg", false)

        -- clear out the current item now that a choice has been made
        ItemUtils.currentItemLoc = nil
        ItemUtils.currentItemSlot = nil
    end
end

function ItemUtils.GetFormattedBonus (bonus, bonusIsAContribution, currChargesRemaining, itemLevel, careers)

    -- Handle stat increases...
    if (bonus.reference > 0)
    then
    
        if (bonus.type == GameDefs.ITEMBONUS_MAGIC)
        then
        
            if (bonusIsAContribution)  then
				return DataUtils.GetBonusContributionString( bonus.value )..L" "
			else
				return DataUtils.GetStatBonusString( bonus.reference, bonus.value, false, careers )
            end
            
        elseif (bonus.type == GameDefs.ITEMBONUS_USE)
        then
            local itemAbility           = GetAbilityDesc (bonus.reference, itemLevel)
            local itemUseAbilityDesc    = L""

            if (itemAbility and itemAbility ~= L"") 
            then
                local useString     = GetString (StringTables.Default.LABEL_USE_ITEM)
                local chargesLeft   = GetString (StringTables.Default.LABEL_ITEM_CHARGES)

                itemUseAbilityDesc = useString..L" "..itemAbility
                
                -- TODO: Ensure that this is the desired behavior.  If the item actually has multiple
                -- uses, then display the "Use: Restores your coolness.\nCharges Remaining: x / y"
                -- If it has one or fewer charges, then just display: "Use: Does something when you use it."
                -- This seems like the desired behavior for all items that have "uses".
                -- This will not be the way that items with procs on them should display their abilities,
                -- but that's handled below.
                if (bonus.value > 1)
                then
                    return (itemUseAbilityDesc..L"<br>"..chargesLeft..L" "..currChargesRemaining..L"/"..bonus.value)
                else
                    return (itemUseAbilityDesc)
                end
            end

        -- Handle passive/proc abilities/effects
        elseif (bonus.type == GameDefs.ITEMBONUS_CONTINUOUS)
        then
            return GetAbilityDesc (bonus.reference, itemLevel)
        end
    end
    
    return (L"")
end

function ItemUtils.OnMouseOver(bonus, bonusIsAContribution, currChargesRemaining, itemLevel)
    local dlgIndex = WindowGetId( SystemData.ActiveWindow.name)
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, ItemUtils.tooltips[dlgIndex] )
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP);
end
