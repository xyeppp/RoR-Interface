
--- Item Tooltip
Tooltips.ItemTooltip.BORDER_SIZE        = 25
Tooltips.ItemTooltip.ICON_HEIGHT        = 40
Tooltips.ItemTooltip.ICON_H_SPACING     = 10
Tooltips.ItemTooltip.ICON_V_SPACING     = 15
Tooltips.ItemTooltip.INTERNAL_WIDTH     = 250
Tooltips.ItemTooltip.WIDTH              = Tooltips.ItemTooltip.INTERNAL_WIDTH + Tooltips.ItemTooltip.BORDER_SIZE
Tooltips.ItemTooltip.SET_PIECE_INDENT   = 20
Tooltips.ItemTooltip.SET_SEPERATOR      = 20

Tooltips.ItemTooltip.NUM_SET_PIECES     = 9
Tooltips.ItemTooltip.NUM_SET_BONUSES    = 7

Tooltips.ItemTooltip.NUM_PASSIVES       = 5

-- Stat Tooltip
Tooltips.STAT_TOOLTIP_STAT_HEIGHT = 50
Tooltips.ADVANCE_TOOLTIP_WIDTH = 300

GameData.Item.EITEMFLAG_ACCOUNT_BOUND = 11
GameData.Item.EITEMFLAG_EVENT = 12

---------------- BROKEN ITEM TOOLTIP  ----------------
BrokenItemTooltip = {}

-------------- APPEARANCE ITEM TOOLTIP  --------------
AppearanceItemTooltip = {}

-- **************************************************************************
-- Item Tooltip

--
-- Returns the index into GameData.Player.Equipment that this item will occupy.
-- This is for comparison tooltip lookups.
--
-- If the item can be slot in either hand, returns both hands for the indices into
-- GameData.Player.Equipment.  The second returned value is nil in other cases.
--
local function GetEquipmentSlot (slotType)
    local equipmentSlot     = 0;
    local altEquipmentSlot  = nil;
    
    if (slotType) then
        if (slotType > GameData.Player.c_NUM_READIED_SLOTS) then
            equipmentSlot = slotType - (GameData.Player.c_NUM_READIED_SLOTS - GameData.Player.c_NUM_USED_READIED_SLOTS);
        elseif (slotType == GameData.EquipSlots.EITHER_HAND) then
            equipmentSlot = GameData.EquipSlots.RIGHT_HAND;
            altEquipmentSlot = GameData.EquipSlots.LEFT_HAND;
        else
            equipmentSlot = slotType;
        end
    end
    
    return equipmentSlot, altEquipmentSlot;
end


local function SetRequirementsLabel (labelName, labelText, playerMeetsRequirements)

    LabelSetText (labelName, labelText)
    
    if (playerMeetsRequirements == true) then
        LabelSetTextColor (labelName, Tooltips.COLOR_MEETS_REQUIREMENTS.r, 
                                      Tooltips.COLOR_MEETS_REQUIREMENTS.g, 
                                      Tooltips.COLOR_MEETS_REQUIREMENTS.b)
    else
        LabelSetTextColor (labelName, Tooltips.COLOR_FAILS_REQUIREMENTS.r, 
                                      Tooltips.COLOR_FAILS_REQUIREMENTS.g, 
                                      Tooltips.COLOR_FAILS_REQUIREMENTS.b)
    end

end

function Tooltips.SetReqsWithLookup (labelName, baseText, itemTable, textTable, playerMeetsRequirements)

    local text = L""
    
    for ix, reqId in ipairs (itemTable) do
    
        --DEBUG (L"Label: "..StringToWString (labelName)..L"[ix: "..ix..L", req: "..reqId..L"]")
        
        if (reqId ~= 0 and textTable[reqId] ~= nil) then
            if (ix == 1) then                
                if baseText ~= nil and baseText ~= L"" then
                    text = baseText..L": "..textTable[reqId].name
                else
                    text = textTable[reqId].name
                end
            else
                text = text..L", "..textTable[reqId].name
            end
        end
        --DEBUG (L"text: "..text)
        
    end
    
    SetRequirementsLabel (labelName, text, playerMeetsRequirements)
    
end

function Tooltips.SetReqsWithValue (labelName, text, itemValue, playerMeetsRequirements)

    if (itemValue > 0) then
    
        SetRequirementsLabel (labelName, text, playerMeetsRequirements)
        
    else
    
        LabelSetText (labelName, L"")
    
    end

end

function Tooltips.SetReqSlotsForEnhancement( windowName, itemData )

    local ENHANCEABLE_WEAPONS = 
    {
        GameData.EquipSlots.RIGHT_HAND,
        GameData.EquipSlots.LEFT_HAND,
        GameData.EquipSlots.RANGED,
        GameData.EquipSlots.EITHER_HAND,
    }
    local ENHANCEABLE_ARMOR = 
    { 
        GameData.EquipSlots.BODY,
        GameData.EquipSlots.GLOVES,
        GameData.EquipSlots.BOOTS,
        GameData.EquipSlots.HELM,
        GameData.EquipSlots.SHOULDERS,
    }

    local function tablesAreEqual(t1, t2) 
    
        if t1 == nil or t2 == nil then 
            return false 
        end 
            
        for k,v in pairs(t1) do
            if t2[k]== nil or t2[k] ~= v then       
                return false 
            end 
        end
        
        return (#t1 == #t2)
    end
    
    if itemData.slots == nil or #itemData.slots == 0 or
       ( itemData.type ~= GameData.ItemTypes.ENHANCEMENT and 
         itemData.type ~= GameData.ItemTypes.TROPHY ) then
         
        LabelSetText (windowName, L"")
   
    elseif tablesAreEqual( ENHANCEABLE_WEAPONS, itemData.slots ) then
        LabelSetText (windowName, GetString( StringTables.Default.WEAPONS_ONLY ) )
    
    elseif tablesAreEqual( ENHANCEABLE_ARMOR, itemData.slots ) then 
        LabelSetText (windowName, GetString( StringTables.Default.ARMOR_ONLY ) )
        
    elseif itemData.type == GameData.ItemTypes.ENHANCEMENT then
         Tooltips.SetReqsWithLookup (windowName, GetString( StringTables.Default.LABEL_USABLE_ON ), itemData.slots, ItemSlots, true)

    else
        Tooltips.SetReqsWithLookup (windowName, GetString( StringTables.Default.LABEL_USABLE_ON ), itemData.slots, TrophySlots, true)

    end
    
end


--
-- Shows tooltips for items you have equipped, so you can compare your gear
-- to the piece of gear that you're mousing over.
-- It is assumed that CreateItemComparisonTooltip will only get called from
-- Tooltips.CreateItemTooltip.
--
local function CreateItemComparisonTooltip( anchorTo, itemData )
    
    -- Only display comparison tooltips if the player has something equipped in the slot the
    -- item *would* occupy 
    -- I am removing the check for requirements just to see what kinds of responses it illicits...
    
    -- local reqsTable     = DataUtils.PlayerMeetsReqs (itemData);
    local reqsMet       = true; -- (reqsTable.career and reqsTable.skills and reqsTable.race and reqsTable.renown and reqsTable.level);
    local equipableItem = (itemData.equipSlot ~= 0 )
    local compWin       = Tooltips.ItemTooltip.COMPARISON_WIN_1;
    
    if( reqsMet and equipableItem ) then
        -- DEBUG (L" Trying to create comparison ["..itemData.name..L"] at slot: "..itemData.equipSlot);

        local playerEquipSlot, altEquipSlot = GetEquipmentSlot (itemData.equipSlot);
        
        -- DEBUG (L"Index into GameData.Player.Equipment: "..playerEquipSlot);
        
        local curItem = DataUtils.GetEquipmentData()[playerEquipSlot];
        if( curItem ~= nil and curItem.id ~= 0  ) then
            Tooltips.SetItemTooltipData( compWin, curItem )
            Tooltips.AddExtraWindow( compWin, anchorTo, curItem )

            Tooltips.TintWindowForEquippedItems( compWin )
            
            -- Switch to the other comparison window...
            compWin     = Tooltips.ItemTooltip.COMPARISON_WIN_2;
            anchorTo    = Tooltips.ItemTooltip.COMPARISON_WIN_1;
            
        end
        
        if (altEquipSlot) then
            curItem = DataUtils.GetEquipmentData()[altEquipSlot];
            if (curItem and curItem.id ~= 0) then
                Tooltips.SetItemTooltipData (compWin, curItem);
                Tooltips.AddExtraWindow (compWin, anchorTo, curItem);
                Tooltips.TintWindowForEquippedItems( compWin )
            end
        end
    end

end

-- Help functions for tinting the tooltip background and border differently, to highlight equipped items
function Tooltips.TintWindowForEquippedItems( window )
    WindowSetTintColor( window.."BackgroundInner", DefaultColor.DARK_GRAY.r, DefaultColor.DARK_GRAY.g, DefaultColor.DARK_GRAY.b )
    WindowSetTintColor( window.."BackgroundBorder", DefaultColor.GOLD.r, DefaultColor.GOLD.g, DefaultColor.GOLD.b )
end

function Tooltips.CreateAndTintItemTooltip( itemData, mouseoverWindow, anchor, disableComparison, extraText, extraTextColor, ignoreBroken )
    local tooltipWindow = Tooltips.CreateItemTooltip( itemData, mouseoverWindow, anchor, disableComparison, extraText, extraTextColor, ignoreBroken )
    Tooltips.TintWindowForEquippedItems( tooltipWindow )
end

--[[
    Create an item tooltip that will anchor itself to the mouseoverWindow.
    The 'anchor' parameter is ignored, because item tooltips anchor themselves
    to a 'best-guess' point so that they will fit on the screen, and not be obscured
    by the mouse cursor.
    
    If extraText is present, it will render below a seperator at the end of the tooltip.
    When drawing extraText, if extraTextColor is present (table must look like { r=red, g=green, b=blue} )
    that will be the color of the extraText, otherwise it will default to Tooltips.COLOR_EXTRA_TEXT_DEFAULT
    If disableComparison is true then NO item comparison will happen even if you moused over an equippable item
    If disableComparison is nil or false, then equippable items will still be compared to what you have equipped.
--]]
function Tooltips.CreateItemTooltip( itemData, mouseoverWindow, anchor, disableComparison, extraText, extraTextColor, ignoreBroken )
    
    local tooltipWindow = "ItemTooltip"
    
    -- Reset any tinting that previously was done to the Item Tooltip
    WindowSetTintColor( "ItemTooltipBackgroundInner", 0, 0, 0 )
    WindowSetTintColor( "ItemTooltipBackgroundBorder", 255, 255, 255 )
        
    if( itemData and itemData.broken and not ignoreBroken )
    then 
        tooltipWindow = "BrokenItemTooltip" 
        Tooltips.SetItemTooltipData( "BrokenItemTooltipRepairedItem", itemData, extraText, extraTextColor )
        BrokenItemTooltip.SetTooltipData( "BrokenItemTooltip", itemData )
        WindowSetShowing( "BrokenItemTooltipSellPrice", false );
    else
        Tooltips.SetItemTooltipData( tooltipWindow, itemData, extraText, extraTextColor )
    end
    
    Tooltips.CreateCustomTooltip( mouseoverWindow, tooltipWindow )
      
    -- Set the current item for the tooltip window so that if there needs to be an update, we have the old item
    -- data lying around...
    Tooltips.curItemData = itemData;
    
    -- If item has timer-based information, ensure that the window gets updates
    if( (itemData.timeLeftBeforeDecay > 0) or DataUtils.ItemHasEnhancementTimer(itemData) ) then
        Tooltips.SetUpdateCallback( Tooltips.ItemUpdateCallback )
    end
    
    if( anchor ~= Tooltips.ANCHOR_MOUSE_OVER_TARGET_WINDOW )
    then
        anchor = Tooltips.ANCHOR_WINDOW_VARIABLE
    end
    
    -- The pseudocode is what I think should eventually happen
    -- with item tooltip comparisons
    if 
    (
        (disableComparison == nil or disableComparison == false)
        and 
        (itemData.equipSlot ~= 0)
        -- and 
        -- (
        --    (only_display_comparison_when_mod_key_is_pressed == false)
        --    or 
        --    (only_display_comparison_when_mod_key_is_pressed and user_is_pressing_mod_key)
        -- )
    )
    then
    
        Tooltips.AnchorTooltip( anchor, true )
        CreateItemComparisonTooltip( tooltipWindow, itemData);
    else
        Tooltips.AnchorTooltip( anchor, true )
    end
    
    return tooltipWindow
end

--[[
    Create an item tooltip in the specified tooltip window.
    This window must inherit from the "ItemTooltip" window definition.
    
    This function does not have the extra parameters for anchoring,
    item comparisons, or extra text.
--]]
function Tooltips.CreateCustomItemTooltip (itemData, windowTemplate)
    Tooltips.SetItemTooltipData (windowTemplate, itemData, nil, nil)
end

--[[
    Displays the sell price of an item in the existing tooltip window.
--]]

function Tooltips.ShowSellPrice (itemData)
    --DEBUG(L"Tooltips.ShowSellPrice ")

    if ( itemData == nil )
    then
        return
    end

    local priceWindow, repairableItemWindow
    if itemData.broken then
        if itemData.repairedName ~= nil and itemData.repairedName ~= L"" then
            priceWindow = "BrokenItemTooltipRepairedItemSellPrice"
            repairableItemWindow = "BrokenItemTooltipRepairedItem"
        else
            priceWindow = "BrokenItemTooltipSellPrice"
        end
    else
        priceWindow = Tooltips.curTooltipWindow.."SellPrice";
    end
    local priceLabel = priceWindow.."Text"
    local moneyWindow = priceWindow.."Money"

    local value = 0
    local notification = L""

    -- if in repair mode display the repairPrice rather than sellPrice
    if EA_Window_InteractionStore.repairModeOn then
        value = itemData.repairPrice or 0
        -- TODO: if value <= 0 then Should probably make notification text say something like "Not repairable."
    else
        if ( not itemData.flags[GameData.Item.EITEMFLAG_NO_SELL] )
        then
            value = itemData.sellPrice or 0
        end
        if value <= 0 then
            notification = GetString( StringTables.Default.LABEL_NO_SELL_PRICE )
        end
    end

    -- multiply the per item price by the stack count
    -- TODO: It would be great to also put price per item next to the total price
    value = value * itemData.stackCount

    -- Show/hide the windows.
    local showMoneyFrame = ( value ~= 0 )
    local showPriceWindow = ( showMoneyFrame or notification ~= L"" )

    WindowSetShowing( priceWindow, showPriceWindow )

    LabelSetText( priceLabel, notification )

    WindowSetShowing( moneyWindow, showMoneyFrame )
    if ( showMoneyFrame )
    then
        MoneyFrame.FormatMoney( moneyWindow, value, MoneyFrame.HIDE_EMPTY_WINDOWS )
    end

    -- If there is no sell price, and the action text for "Right Click To Sell" is 
    -- showing, we have to remove it at this point.
    local unsellableHeightAdjustment = 0
    if ( not showMoneyFrame )
    then
        local tmp
        tmp, unsellableHeightAdjustment = LabelGetTextDimensions( Tooltips.curTooltipWindow.."ActionText" )
        Tooltips.SetExtraText( Tooltips.curTooltipWindow, "ActionText", "ActionTextLine", nil, nil )
    end

    --WindowSetShowing( Tooltips.curTooltipWindow.."Seperator", true )

    -- Find out what the new size has to be...
    local w, h      = WindowGetDimensions( Tooltips.curTooltipWindow )

    local x = 0
    local y = 0
    if ( showPriceWindow )
    then
        x, y = WindowGetDimensions( priceWindow )
    end

    local padding = 10   -- 10 for anchor offset 

    --local curScale  = WindowGetScale (priceWindow)
    --local padding   = Tooltips.ItemTooltip.BORDER_SIZE
    --if (curScale ~= 0) then
    --    padding = padding * curScale
    --end 

    h = (h + y + padding) - unsellableHeightAdjustment

    WindowSetDimensions (Tooltips.curTooltipWindow, w, h)

    if repairableItemWindow ~= nil then
        w, h      = WindowGetDimensions (repairableItemWindow)
        h = (h + y + padding) - unsellableHeightAdjustment 
        WindowSetDimensions (repairableItemWindow, w, h)
    end
end

--[[ 
    Convenience function to clear the item set data portion of the item tooltip.
--]]
local function ClearItemSetTooltipData (tooltipWindow)
    local setNameLabel      = tooltipWindow.."SetName";
    local basePieceLabel    = tooltipWindow.."SetPiece";
    local baseBonusLabel    = tooltipWindow.."SetBonus";
    
    LabelSetText (setNameLabel, L"");
    
    for i = 1, Tooltips.ItemTooltip.NUM_SET_PIECES do
        LabelSetText (basePieceLabel..i, L"");
    end
    
    for i = 1, Tooltips.ItemTooltip.NUM_SET_BONUSES do
        LabelSetText (baseBonusLabel..i, L"");
    end  
    
    Tooltips.SetTooltipFlag (tooltipWindow, Tooltips.FLAG_IS_SET_ITEM, false);
end

--[[
    Sets the item set portion of an item tooltip window appropriately...this should
    only be called when itemSetData is known to be valid and actually exists for the
    item in question...or when you want to destroy the item set data for a window...
--]]
local function SetItemSetTooltipData (tooltipWindow, itemData, itemSetData)

    local playerOwned, numPieces = DataUtils.GetPlayerOwnedSetPieces (itemSetData);
    
    local setNameLabel      = tooltipWindow.."SetName";
    local basePieceLabel    = tooltipWindow.."SetPiece";
    local baseBonusLabel    = tooltipWindow.."SetBonus";
    
    -- Using the assumption that a set always has more than 0 pieces...
    -- but keeping in mind the fact that the player might not have any of them.
    local nameColor = Tooltips.COLOR_ITEM_SET_DISABLED;
    local nameData  = itemSetData.name;
    
    if (numPieces > 0) then
        nameColor   = Tooltips.COLOR_ITEM_SET_ENABLED;
        nameData    = nameData..L" ("..numPieces..L" / "..itemSetData.numPieces..L")";
    else
        nameData    = nameData..L" (0 / "..itemSetData.numPieces..L")";
    end
        
    LabelSetText (setNameLabel, nameData);
    LabelSetTextColor (setNameLabel, nameColor.r, nameColor.g, nameColor.b);

    --
    -- Handle each piece in the set...
    --    
    local windowIdx = 1;  -- Don't let this get higher than Tooltips.ItemTooltip.NUM_SET_PIECES
   
    for nameIdx = 1, GameDefs.MAX_ITEMS_IN_SET do

        local pieceName = itemSetData.iton[nameIdx];

        if (pieceName and pieceName ~= L"") then
            
            if (windowIdx > Tooltips.ItemTooltip.NUM_SET_PIECES) then
                DEBUG(L"Set["..itemSetData.name..L"] has more than "..Tooltips.ItemTooltip.NUM_SET_PIECES..L" pieces. Ignoring extras.");
                break;
            end
        
            LabelSetText (basePieceLabel..windowIdx, pieceName);

            if (true == playerOwned[nameIdx]) then
                nameColor = Tooltips.COLOR_ITEM_SET_ENABLED;
            else
                nameColor = Tooltips.COLOR_ITEM_SET_DISABLED;
            end

            LabelSetTextColor (basePieceLabel..windowIdx, nameColor.r, nameColor.g, nameColor.b);
            windowIdx = windowIdx + 1;
            
        end
    end
 
    -- Clear the remaining labels...
    while (windowIdx <= Tooltips.ItemTooltip.NUM_SET_PIECES) do
        LabelSetText (basePieceLabel..windowIdx, L"");
        windowIdx = windowIdx + 1;
    end    
    
    --
    -- Handle all the set bonuses...
    --
    windowIdx = 1;  -- Don't let this get higher than Tooltips.ItemTooltip.NUM_SET_BONUSES
    
    local bonusDescriptions = DataUtils.GetSetBonuses (itemSetData, numPieces, itemData.iLevel, itemData.careers)
    local bonusColor
    		
    for bonusIdx, bonusDesc in ipairs (bonusDescriptions) do
        
        if (bonusDesc and bonusDesc.desc ~= L"") then
        
            if (windowIdx > Tooltips.ItemTooltip.NUM_SET_BONUSES) then
                DEBUG (L"Set["..itemSetData.name..L"] has more than "..Tooltips.ItemTooltip.NUM_SET_BONUSES..L" bonuses.");
                break;
            end
        
            if (true == bonusDesc.unlocked) then
                bonusColor = Tooltips.COLOR_ITEM_SET_ENABLED;
            else
                bonusColor = Tooltips.COLOR_ITEM_SET_DISABLED;
            end
            
            LabelSetText (baseBonusLabel..windowIdx, bonusDesc.desc);
            LabelSetTextColor (baseBonusLabel..windowIdx, bonusColor.r, bonusColor.g, bonusColor.b);
            windowIdx = windowIdx + 1;
        end
    
    end
    
    -- Clear the remaining labels...
    while (windowIdx <= Tooltips.ItemTooltip.NUM_SET_BONUSES) do
        LabelSetText (baseBonusLabel..windowIdx, L"");
        windowIdx = windowIdx + 1;
    end
    
    Tooltips.SetTooltipFlag (tooltipWindow, Tooltips.FLAG_IS_SET_ITEM, true);
end

--[[
    Called to determine the size of the ItemSetData portion of the
    item tooltip window.  If the tooltip window is not displaying
    an item set, this returns 0, Tooltips.ItemTooltip.INTERNAL_WIDTH.
    
    The width returned is the larger of Tooltips.ItemTooltip.INTERNAL_WIDTH
    or however large the item set labels are.
--]]
local function CalculateItemSetTooltipSize (tooltipWindow, isSetItem)

    if (not isSetItem) then
        return 0, 0;
    end
    
    local itemSetSizeData = { };
    local height    = Tooltips.ItemTooltip.SET_SEPERATOR;
    local width     = Tooltips.ItemTooltip.INTERNAL_WIDTH;
    local offsX     = Tooltips.ItemTooltip.SET_PIECE_INDENT;
    
    itemSetSizeData[tooltipWindow.."SetName"]     = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetPiece1"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetPiece2"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetPiece3"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetPiece4"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetPiece5"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetPiece6"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetPiece7"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetPiece8"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetBonus1"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetBonus2"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetBonus3"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetBonus4"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetBonus5"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetBonus6"]   = { minHeight = 0 }
    itemSetSizeData[tooltipWindow.."SetBonus7"]   = { minHeight = 0 }
    
    for labelName, sizeData in pairs (itemSetSizeData) do
        local x, y = LabelGetTextDimensions (labelName)
       
        if (y > sizeData.minHeight) then
            height = height + y;
        else
            height = height + sizeData.minHeight;
        end
        
        if ((x + offsX) > width) then
            width = x + offsX;
        end
    end
    
    return width, height;
end

local function GetEnhancementSize( contributionName )

    local text = LabelGetText( contributionName.."Text" )
    if text == nil or text == L"" then
        return 0, 0
    end
    
    local offset = 5
    local imageSize = 25
    local width, height = LabelGetTextDimensions( contributionName.."Text" )
    return width + offset + imageSize, height
end

--[[
    Determines the contribution to the item tooltip window size from the 
    stats bonuses section (only for MAGIC type stats)
    
    This also resizes the window frame around the stats window so that any other
    tooltip elements anchored to that frame will position themselves correctly.
--]]
local function CalculateStatsWindowSize (tooltipWindow)
   
    local statsSizeData = { };
    local height        = 5;    -- anchor offset from the window above it
                                -- TODO: FIXME: the better solution is not to have any offsets in the XML but actually 
                                --    to have every window that has height > 0 just add 5 to it's height before resizing in Lua
    local width         = Tooltips.ItemTooltip.INTERNAL_WIDTH;
    
    statsSizeData[tooltipWindow.."StatBonus1"]  = { minHeight = 0 }
    statsSizeData[tooltipWindow.."StatBonus2"]  = { minHeight = 0 }
    statsSizeData[tooltipWindow.."StatBonus3"]  = { minHeight = 0 }
    statsSizeData[tooltipWindow.."StatBonus4"]  = { minHeight = 0 }
    statsSizeData[tooltipWindow.."StatBonus5"]  = { minHeight = 0 }
    statsSizeData[tooltipWindow.."StatBonus6"]  = { minHeight = 0 }
    statsSizeData[tooltipWindow.."StatBonus7"]  = { minHeight = 0 }
    statsSizeData[tooltipWindow.."StatBonus8"]  = { minHeight = 0 }
    statsSizeData[tooltipWindow.."StatBonus9"]  = { minHeight = 0 }
    statsSizeData[tooltipWindow.."StatBonus10"] = { minHeight = 0 }
    
    for statLineName, sizeData in pairs (statsSizeData) do
        -- NOTE: This only checks the height of the TOTAL stat bonus label
        -- not the contributions from enhancements...
        -- The reasoning being that the line will definitely have this label
        -- set to something if there is any bonus on this stat line.
        
        local x, y = LabelGetTextDimensions (statLineName.."Text")
        if y > 0 then 
            -- get height of actual window being anchored against. 
            -- or do we mean to resize it's height?
            __, y = WindowGetDimensions (statLineName)
        end
 
        if (y > sizeData.minHeight) then
            height = height + y;
        else
            height = height + sizeData.minHeight;
        end
        
        for i=1, 3
        do
            local enhanceWidth, enhanceHeight = GetEnhancementSize( statLineName.."Contribution"..i )
            x = x + enhanceWidth
        end
        
        if( x > width )
        then
            width = x
        end
    end
    
    WindowSetDimensions (tooltipWindow.."StatBonus", width, height);
    
    return width, height;
end

-- this could be more generic perhaps...
local function CalculatePassivesWindowSize (tooltipWindow)
   
    local statsSizeData = { };
    local height        = 0;
    local width         = Tooltips.ItemTooltip.INTERNAL_WIDTH;
    
    for i = 1, Tooltips.ItemTooltip.NUM_PASSIVES
    do
        statsSizeData[tooltipWindow.."PassiveAbility"..i]  = { minHeight = 0 }
    end
    
    for statLineName, sizeData in pairs (statsSizeData) do
        
        local x, y = LabelGetTextDimensions (statLineName.."Text")
        WindowSetDimensions (statLineName, x, y)
 
        if (y > sizeData.minHeight) then
            height = height + y;
        else
            height = height + sizeData.minHeight;
        end
        
        if( x > width )
        then
            width = x
        end
    end
    
    WindowSetDimensions (tooltipWindow.."PassiveAbility", width, height);
    
    return width, height;
end

local function GetDimensionsOfTooltipLabels( labelSizeData )
    -- height and width apply to the current tooltip.
    local height        = Tooltips.ItemTooltip.BORDER_SIZE;
    local width         = Tooltips.ItemTooltip.INTERNAL_WIDTH;
    
    for labelName, sizeData in pairs (labelSizeData) do
    
        -- field height/width apply to the component window within the current tooltip
        local fieldWidth    = 0;
        local fieldHeight   = 0;
        
        if (sizeData.isWindow) then
            fieldHeight = sizeData.minHeight;
            
            if (sizeData.minWidth and sizeData.minWidth > width) then
                fieldWidth = sizeData.minWidth;
            end
        else
            fieldWidth, fieldHeight = LabelGetTextDimensions (labelName);
            
            -- Safe guard against labelName not existing 
            if (fieldWidth  == nil) then fieldWidth     = 0; end
            if (fieldHeight == nil) then fieldHeight    = 0; end
        end
                
        if (sizeData.noHeightIfMissing) then
            fieldHeight = 0;
        end
       
        if (fieldHeight > sizeData.minHeight) then
            height = height + fieldHeight
        else
            height = height + sizeData.minHeight
        end
        
        -- Assuming that this field is anchored at an xOffset of 0 from the left side of the tooltip,
        -- if the field's width exceeds the current width of the tooltip, resize the tooltip.
        if (fieldWidth > width) then
            width = fieldWidth;
        end
    end
    return width, height
end

--[[
    Called after an item tooltip has all of its labels/icons set up to
    resize to the proper dimensions
--]]
local function CalculateItemTooltipSize (tooltipWindow)
    
    local hasExtraText  = LabelGetText( tooltipWindow.."ActionText" ) ~= L""
    local isSetItem     = Tooltips.GetTooltipFlag (tooltipWindow, Tooltips.FLAG_IS_SET_ITEM);
    
    local labelSizeData = {}
    
    labelSizeData[tooltipWindow.."Title"]                    = { minHeight = 0 } 
    labelSizeData[tooltipWindow.."Slot"]                     = { minHeight = 0 }
    labelSizeData[tooltipWindow.."Type"]                     = { minHeight = 0 }
    labelSizeData[tooltipWindow.."ItemLevel"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."MaxEquip"]                 = { minHeight = 0 }
    labelSizeData[tooltipWindow.."Armor"]                    = { minHeight = 0 }
    labelSizeData[tooltipWindow.."DPS"]                      = { minHeight = 0 }
    labelSizeData[tooltipWindow.."Speed"]                    = { minHeight = 0 }
    labelSizeData[tooltipWindow.."BlockRate"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."DyeColor"]                 = { minHeight = 0 }
    labelSizeData[tooltipWindow.."DyeInstruction"]           = { minHeight = 0 }
    labelSizeData[tooltipWindow.."Bind"]                     = { minHeight = 0 }
    labelSizeData[tooltipWindow.."TrialText"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."LevelText"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."CareerReq"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SkillsReq"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."RenownReq"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."RaceReq"]                  = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SlotReq"]                  = { minHeight = 0 }
    labelSizeData[tooltipWindow.."AppearanceState"]          = { minHeight = 0 }
    labelSizeData[tooltipWindow.."AppearanceName"]           = { minHeight = 0 }
    labelSizeData[tooltipWindow.."UseEffect"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."DecayTime"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SalvageText"]              = { minHeight = 0 }
    labelSizeData[tooltipWindow.."Description"]              = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SalvageBonusesLabel1"]     = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SalvageBonusesLabel2"]     = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SalvageBonusesLabel3"]     = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SalvageBonusesLabel4"]     = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SalvageBonusesLabel5"]     = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SalvageBonusesLabel6"]     = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SalvageBonusesLabel7"]     = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SalvageBonusesLabel8"]     = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SalvageBonusesLabel9"]     = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SalvageBonusesLabel10"]    = { minHeight = 0 }
    
    -- Set up size data for all the windows on the tooltip (the non-label elements that require
    -- more complex size determinations)
    local atWidth, atHeight= 0, 0;
    
    if (hasExtraText) then
        atWidth, atHeight = LabelGetTextDimensions (tooltipWindow.."ActionText");
        
        --local c_SEPARATOR_LINE_TOTAL_HEIGHT = 33;
        local c_SEPARATOR_LINE_TOTAL_HEIGHT = 15;
        atHeight = atHeight + c_SEPARATOR_LINE_TOTAL_HEIGHT;
    end
        
    labelSizeData[tooltipWindow.."ActionText"]      = { minWidth = atWidth, minHeight = atHeight, isWindow = true }
    
    -- SellPrice is always missing initially, because it will never be shown at this point of the 
    -- item tooltip construction...it has to be shown AFTER you've created the item tooltip.
    
    -- We really need to get rid of the action text and change the actual CURSOR when you mouse over an item you
    -- can buy or sell!!  (UI rule 825, be consistent, if the mouse cursor changes when you hover over
    -- one interactable thing, make sure it behaves the same for ALL interactable things.)
    labelSizeData[tooltipWindow.."SellPrice"]   = { minHeight = 0, isWindow = true }
    
    -- Item sets...
    local itemSetWindow = tooltipWindow.."Set";
    local itemSetWidth, itemSetHeight = CalculateItemSetTooltipSize (tooltipWindow, isSetItem);
    
    labelSizeData[itemSetWindow] = { minWidth = itemSetWidth, minHeight = itemSetHeight, isWindow = true }
    
    -- The name is also a special case since it is anchored to the icon.
    local nameWindow            = tooltipWindow.."Name";
    local iSize                 = Tooltips.ItemTooltip.ICON_HEIGHT;
    local hSpace                = Tooltips.ItemTooltip.ICON_H_SPACING;
    local vSpace                = Tooltips.ItemTooltip.ICON_V_SPACING;    
    
    -- consider both the width and hight of name window
    local nameWidth, nameHeight = LabelGetTextDimensions( nameWindow )
    
    -- account for width of locked text in the name window if present
    local lockedWindow = tooltipWindow.."Locked"
    local lockedWidth, lockedHeight = LabelGetTextDimensions(lockedWindow)
    
    -- reanchor slot window according to the height of the name window
    if( nameHeight > iSize )
    then
        WindowClearAnchors( tooltipWindow.."Slot" )
        WindowAddAnchor( tooltipWindow.."Slot", "bottomleft", tooltipWindow.."Name", "topleft", -50, 5 )
    else
        WindowClearAnchors( tooltipWindow.."Slot" )
        WindowAddAnchor( tooltipWindow.."Slot", "bottomleft", tooltipWindow.."Icon", "topleft", 0, 5 )
    end
    
    -- adjust name window size
    nameWidth                   = iSize + nameWidth + lockedWidth + hSpace
    nameHeight                  = math.max( iSize, nameHeight ) + vSpace

    labelSizeData[nameWindow] = { minWidth = nameWidth, minHeight = nameHeight, isWindow = true }
    
    -- Find the dimensions for the stat bonuses (same deal as item sets...)
    local statWidth, statHeight = CalculateStatsWindowSize (tooltipWindow);
    
    labelSizeData[tooltipWindow.."StatBonus"] = { minWidth = statWidth, minHeight = statHeight, isWindow = true }        
    
    -- Find the dimensions for the enhancements present on the item (almost the same deal as item sets...)
    local enhWidth, enhHeight = WindowGetDimensions (tooltipWindow.."Enhancements");
    
    labelSizeData[tooltipWindow.."Enhancements"] = { minWidth = enhWidth, minHeight = enhHeight, isWindow = true }
    
    local passiveWidth, passiveHeight = CalculatePassivesWindowSize (tooltipWindow);
    labelSizeData[tooltipWindow.."PassiveAbility"] = { minWidth = passiveWidth, minHeight = passiveHeight, isWindow = true }   
    
    -- height and width apply to the current tooltip.
    local width, height = GetDimensionsOfTooltipLabels( labelSizeData )
        
    -- This is not very efficient, but I need to hide the sell price in most
    -- cases, so I am commiting the sin of a redundant function call...
    -- This works because the sell price is shown AFTER the tooltip has been created.
    WindowSetShowing (tooltipWindow.."SellPrice", false);
    
    -- Then set the height as normal...    
    WindowSetDimensions (tooltipWindow, width + Tooltips.ItemTooltip.BORDER_SIZE*2, height)
    
    -- Set the height of the item set stuff so that the anchors on the extra data/sell price
    -- will process properly...
    WindowSetDimensions (itemSetWindow, width, labelSizeData[itemSetWindow].minHeight);

end

--[[
    Called after an broken item tooltip has all of its labels/icons set up to
    resize to the proper dimensions
--]]
local function CalculateBrokenItemTooltipSize( tooltipWindow, repairableItemAvailable )
    local labelSizeData = {}
    
    labelSizeData[tooltipWindow.."Bind"]                     = { minHeight = 0 }
    labelSizeData[tooltipWindow.."TrialText"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."LevelText"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."CareerReq"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SkillsReq"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."RenownReq"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."RaceReq"]                  = { minHeight = 0 }
    labelSizeData[tooltipWindow.."SlotReq"]                  = { minHeight = 0 }
    labelSizeData[tooltipWindow.."DecayTime"]                = { minHeight = 0 }
    labelSizeData[tooltipWindow.."RepairText"]               = { minHeight = 0 }
    
    
    -- The name is also a special case since it is anchored to the icon.
    local nameWindow            = tooltipWindow.."BrokenName";
    local iSize                 = Tooltips.ItemTooltip.ICON_HEIGHT;
    local hSpace                = Tooltips.ItemTooltip.ICON_H_SPACING;
    local vSpace                = Tooltips.ItemTooltip.ICON_V_SPACING;    
    -- consider both the width and hight of name window
    local nameWidth, nameHeight = LabelGetTextDimensions( nameWindow )

    -- adjust name window size
    nameWidth                   = iSize + nameWidth + hSpace
    nameHeight                  = math.max( iSize, nameHeight ) + vSpace

    labelSizeData[nameWindow] = { minWidth = nameWidth, minHeight = nameHeight, isWindow = true }
       
    -- height and width apply to the current tooltip.
    local width, height = GetDimensionsOfTooltipLabels( labelSizeData )
       
    if( repairableItemAvailable )
    then
        WindowSetShowing( tooltipWindow.."Line", true )
        x, y = WindowGetDimensions( tooltipWindow.."Line" )
        height = height + y   
        
        WindowSetShowing( tooltipWindow.."SellPrice", false )
        WindowSetShowing( tooltipWindow.."RepairedItem", true )
        x, y = WindowGetDimensions( tooltipWindow.."RepairedItem" )
        height = height + y   
        if( x > width )
        then 
            width = x + 10
        end
    else
        WindowSetShowing( tooltipWindow.."SellPrice", true)
        WindowSetShowing( tooltipWindow.."Line", false )
        WindowSetShowing( tooltipWindow.."RepairedItem", false )
    end
    
    -- Then set the height as normal...    
    WindowSetDimensions( tooltipWindow, width + Tooltips.ItemTooltip.BORDER_SIZE * 2, height)   

end


--[[
    main tooltip window we're using (duh!)
    stat line info about the windows we need to use
    the index of the slot (used to lookup icon info!)
    and finally, the formatted text of how much this enhancement bonus contributes to the main stat!
    
    When this function returns, the lineInfo gets its contribution window index updated.
--]]
local c_SLOT_IMG_TEXTURE    = "assorted_hud_pieces";
local c_SLOT_IMG_COORDS     = { 
                                [1] = { x = 193, y = 103 },
                                [2] = { x = 193, y = 124 },
                                [3] = { x = 214, y = 103 }
                              };
                              
local function AddEnhancementContributionText (tooltipWindow, lineInfo, ixEnhSlot, contribution)

    local contributionWindowBase    = tooltipWindow.."StatBonus"..lineInfo.line.."Contribution";
    local contributionWindowText    = contributionWindowBase..lineInfo.count.."Text";
    local contributionWindowImg     = contributionWindowBase..lineInfo.count.."SlotImg";
    
    -- Set the proper texture coordinates depending on the slot that the contribution
    -- originates from.
       
    DynamicImageSetTexture (contributionWindowImg, c_SLOT_IMG_TEXTURE, c_SLOT_IMG_COORDS[ixEnhSlot].x, c_SLOT_IMG_COORDS[ixEnhSlot].y);
    WindowSetShowing (contributionWindowImg, true);
    
    -- Update the text..
    LabelSetText (contributionWindowText, contribution);
    
    -- Don't forget to update the next contribution index to use...
    lineInfo.count = lineInfo.count + 1;
end

--[[
    Hide all image windows for enhancement contributions
--]]
local function HideStatLine (tooltipWindow, line)
    local lineWindowBase            = tooltipWindow.."StatBonus"..line;
    local contributionWindowBase    = lineWindowBase.."Contribution";
    
    LabelSetText (lineWindowBase.."Text", L"");
    
    for i = 1, GameDefs.MAX_ITEM_ENHANCEMENT_SLOTS do               
        LabelSetText (contributionWindowBase..i.."Text", L"");
        WindowSetShowing (contributionWindowBase..i.."SlotImg", false);
    end
end

--[[
    Utility function to get the formatted text of a bonus for a bonus_type and value
    
    Returns the string that represents a readable bonus
    If the bonus amount is 0, I am tentatively assuming that this it applies to an 
    enhancement item, and describing which attribute the item enhances.
--]]



--[[
    For a given item and tooltipWindow shows/hides the enhancement slot data
    
    Example: Item has 2 enhancement slots, only the second one is filled:
    
    <Circle Icon> "Empty Enhancement Slot"
    <Square Icon> "Name of power up 2!"
    <Triangle Icon> "" <---- This whole line is hidden.   
    
    To cut down on recomputing window sizes, also properly sizes the window
    containing this data.  Hmm, maybe I should do the same for the rest of
    the tooltip windows
--]]
local c_EMPTY_ENH_SLOT_NAME = GetString (StringTables.Default.LABEL_EMPTY_ENHANCEMENT_SLOT);
local c_ENH_SLOT_SPACING    = 7;
local c_ENH_ICON_SIZE       = 20;
local c_ENH_ICON_SPACING    = 5;

local function SetItemTooltipEnhSlotInfo (tooltipWindow, itemData)
    local ixCurSlot                 = 1;
    local totalWidth, totalHeight   = Tooltips.ItemTooltip.INTERNAL_WIDTH, 0; 
    local curWidth, curHeight       = 0, 0;
    
    local baseWindow = tooltipWindow.."Enhancements";
    
    for i = 1, itemData.numEnhancementSlots do
        local enhSlot = itemData.enhSlot[i]
        local slotLabelName = baseWindow..i.."Text";
        
        WindowSetShowing (baseWindow..i, true);
        
        if (enhSlot ~= nil and enhSlot.name and enhSlot.name ~= L"") then
            LabelSetText (slotLabelName, enhSlot.name);
            LabelSetTextColor (slotLabelName, Tooltips.COLOR_ITEM_BONUS.r, Tooltips.COLOR_ITEM_BONUS.g, Tooltips.COLOR_ITEM_BONUS.b);
            WindowSetTintColor (baseWindow..i, 255, 255, 255);
        else
            LabelSetText (slotLabelName, c_EMPTY_ENH_SLOT_NAME);
            LabelSetTextColor (slotLabelName, Tooltips.COLOR_ITEM_DISABLED.r, Tooltips.COLOR_ITEM_DISABLED.g, Tooltips.COLOR_ITEM_DISABLED.b);
            WindowSetTintColor (baseWindow..i, Tooltips.COLOR_ITEM_DISABLED.r, Tooltips.COLOR_ITEM_DISABLED.g, Tooltips.COLOR_ITEM_DISABLED.b);
        end
        
        curWidth, curHeight = LabelGetTextDimensions (slotLabelName);
        
        if (curHeight == nil) then curHeight = 0 end
        if (curWidth == nil) then curWidth = 0 end
        
        -- Update the width of the window by the width of the slot icon plus the spacing!
        curWidth = curWidth + c_ENH_ICON_SIZE + c_ENH_ICON_SPACING;
        
        if (curWidth > totalWidth) then
            totalWidth = curWidth;
        end        
        
        -- Update the height...don't use the label's height for window sizing, just the icon!
        totalHeight = totalHeight + (c_ENH_ICON_SIZE + c_ENH_SLOT_SPACING);
        
        ixCurSlot = ixCurSlot + 1;
    end
    
    -- Hide the rest of the windows that won't show because this item doesn't use these enhancement slots.
    while (ixCurSlot <= GameDefs.MAX_ITEM_ENHANCEMENT_SLOTS) do
        WindowSetShowing (baseWindow..ixCurSlot, false);
        LabelSetText (baseWindow..ixCurSlot.."Text", L"");
        ixCurSlot = ixCurSlot + 1;
    end
    
    -- Perform all the anchor adjustment that is needed.
    WindowSetDimensions (baseWindow, totalWidth, totalHeight);
end

--[[
    A set of utility functions encapsulating the stat bonus line table
    
    After iterating over an item's stat bonuses (MAGIC type), several of
    these tables will exist, one final iteration can then be performed over
    the tooltip's labels to set all the text, color, images, etc...without having
    to perform redundant calls to the game.
--]]
local function CreateStatLine (ixLine, numSources, numContribs, value, enhancementDuration, isPercentage )
    return { line = ixLine, count = numSources, totalValue = value, numContributions = numContribs, contributions = { }, duration = enhancementDuration, isPercentageValue = isPercentage }
end

local function AddStatContribution (lineTable, valueIncrement, ixEnhSlot, enhancementDuration)
    lineTable.totalValue        = lineTable.totalValue + valueIncrement;
    lineTable.count             = lineTable.count + 1;
    
    local c                     = lineTable.numContributions + 1;
    lineTable.numContributions  = c;
    lineTable.contributions[c]  = { value = valueIncrement, slot = ixEnhSlot, duration = enhancementDuration };

end

local function DisplayStatLine (tooltipWindow, bonusRef, lineTable, careers)

    if bonusRef == nil or BonusTypes[bonusRef] == nil then
        DEBUG (L"Toolip.lua DisplayStatLine() received unknown BonusTypes value");
        return (L"");
    end
    
    local lineWindowBase = tooltipWindow.."StatBonus"..lineTable.line;
    local contributionWindowBase = lineWindowBase.."Contribution";
    
    local bonusText = DataUtils.GetStatBonusString( bonusRef, lineTable.totalValue, lineTable.isPercentageValue, careers )	
    
    if (lineTable.duration and lineTable.duration > 0) then     
        local durationText = TimeUtils.FormatTimeCondensedTruncate( lineTable.duration )
        
        bonusText = GetStringFormat( StringTables.Default.LABEL_BONUS_WITH_DURATION, { bonusText, durationText } )
    end
    
    if (lineTable.numContributions > 0) then
        bonusText = GetStringFormat( StringTables.Default.LABEL_BONUS_CONTRIBUTION_LIST_START, { bonusText } )
    end
    
    LabelSetText (lineWindowBase.."Text", bonusText);


    for i = 1, lineTable.numContributions do
    
        local contributionWindowImg = contributionWindowBase..i.."SlotImg";
        local ixEnhSlot             = lineTable.contributions[i].slot;
                
        
        DynamicImageSetTexture (contributionWindowImg, c_SLOT_IMG_TEXTURE, c_SLOT_IMG_COORDS[ixEnhSlot].x, c_SLOT_IMG_COORDS[ixEnhSlot].y);
        WindowSetShowing (contributionWindowImg, true);
        
        local statText = DataUtils.GetBonusContributionString( lineTable.contributions[i].value  )

        local duration = lineTable.contributions[i].duration
        if duration ~= nil and duration > 0 then
            local durationText = TimeUtils.FormatTimeCondensedTruncate( duration )
            statText = statText..L" "..durationText
        end
        
        if (i == lineTable.numContributions) then
			statText = GetStringFormat( StringTables.Default.LABEL_BONUS_CONTRIBUTION_LIST_END, { statText } )
        end
        
        LabelSetText (contributionWindowBase..i.."Text", statText )
    end
    
    
    -- Clear the remaining windows on this stat line...
    for i = (lineTable.numContributions + 1), GameDefs.MAX_ITEM_ENHANCEMENT_SLOTS do
        LabelSetText (contributionWindowBase..i.."Text", L"");
        WindowSetShowing (contributionWindowBase..i.."SlotImg", false);        
    end    
end

local function DisplayPassiveAbilityLine( tooltipWindow, iLineNumber, bonus, bonusText)

    if bonus == nil or bonusText == nil or bonusText == L"" 
    then
        return
    end
    bonusText = GetStringFormat( StringTables.Default.LABEL_BONUS_FORMAT_PASSIVE_ABILITY, { bonusText } )
    if (bonus.duration and bonus.duration > 0) 
    then     
        local durationText = TimeUtils.FormatTimeCondensedTruncate( bonus.duration )
        bonusText = GetStringFormat( StringTables.Default.LABEL_BONUS_WITH_DURATION, { bonusText, durationText } )
    end

    if iLineNumber <= Tooltips.ItemTooltip.NUM_PASSIVES
    then
        local abilityWindowName = tooltipWindow.."PassiveAbility"..iLineNumber.."Text"
        LabelSetText (abilityWindowName, bonusText)
        WindowSetShowing(abilityWindowName, true)
    end
end

--[[
    Utility function for all the item bonus data
--]]
local function SetItemTooltipBonusData (tooltipWindow, itemData)
    local ixStat        = 1;
    local ixContinuous  = 1;
    
    local text = L"";
    local useEffectDesc = L""
    
    local salvageText = L"";
    local salvageTextColor = DefaultColor.WHITE;
    local playerHasSalvagingSkill = (GetTradeSkillLevel(GameData.TradeSkills.SALVAGING) > 0);
    local itemIsSalvagable = (itemData.flags[GameData.Item.EITEMFLAG_MAGICAL_SALVAGABLE] == true);
    local hasUnsalvagableBonuses = false;
    local unsalvagableBonusCount = 0;
    
    if(playerHasSalvagingSkill and itemIsSalvagable)
    then
        local difficultyClass = GetSalvagingDifficulty( itemData.iLevel );
        salvageText = GetStringFromTable( "Default", StringTables.Default.TEXT_SALVAGING_SALVAGEABLE );
        salvageTextColor = CraftingUtils.SalvagingDifficulty[difficultyClass].color;
    end
             
	-- clear and hide all passive ability labels, they may have been used for the previous item
    for i = 1, Tooltips.ItemTooltip.NUM_PASSIVES
    do
        local windowName = tooltipWindow.."PassiveAbility"..i.."Text"
        LabelSetText (windowName, L"")
        WindowSetShowing(windowName, false)
    end
	
	
    local statLines = { };
    local iCurPassiveAbility = 1
    
    for i, bonus in ipairs(itemData.bonus) do

        local bonusText = ItemUtils.GetFormattedBonus (bonus, false, itemData.currChargesRemaining, itemData.iLevel, itemData.careers);
    
        -- Make sure all bonuses are salvagable
        if(playerHasSalvagingSkill and itemIsSalvagable and bonus.type == GameData.BonusTypes.SETBONUS_MAGIC )
        then
            if( CraftingUtils.SalvagingStatStringLookUp[bonus.reference] ~= nil )
            then
                if(GetBonusIsSalvagable(itemData.level, bonus.reference) == 0)
                then
                    --This bonus is not salvagable
                    if(hasUnsalvagableBonuses == false)
                    then
                        hasUnsalvagableBonuses = true
                        salvageText = salvageText..GetStringFromTable( "Default", StringTables.Default.TEXT_SALVAGING_EXCEPT_FOR )
                    end
                    local unsalvagableBonusLabel = tooltipWindow.."SalvageBonusesLabel"..i;
                    LabelSetText(unsalvagableBonusLabel, CraftingUtils.SalvagingStatStringLookUp[bonus.reference]);
                    LabelSetTextColor(unsalvagableBonusLabel, DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b)
                    unsalvagableBonusCount = unsalvagableBonusCount + 1;
                end
            end
        end
                     
        -- Handle stat increases...
        
        -- NOTE: Changing this to only allow non-zero stat bonuses. 
        -- ASSUMPTION: I hope we didn't actually want to have bonuses that didn't have a numeric value, e.g. "improves attack speed"
        --if( bonus.type == GameDefs.ITEMBONUS_MAGIC and bonus.reference > 0) then            
        if( bonus.type == GameDefs.ITEMBONUS_MAGIC and bonus.reference > 0 and bonus.value ~= 0 ) then       
            
            -- Cache the line this bonus was on...we'll get back to this for enhancements.
            statLines[bonus.reference] = CreateStatLine( ixStat, 1, 0, bonus.value, bonus.duration, bonus.isPercentage );
            ixStat = ixStat + 1;
        -- Handle proc abilities/effects, now supporting up to 5 of them
        elseif ((bonus.type == GameDefs.ITEMBONUS_CONTINUOUS) and (bonus.reference > 0))
        then
            DisplayPassiveAbilityLine( tooltipWindow, iCurPassiveAbility, bonus, bonusText)
            iCurPassiveAbility = iCurPassiveAbility + 1
        -- Handle on Use text
        elseif ((bonus.type == GameDefs.ITEMBONUS_USE) and (bonus.reference > 0))
        then
            -- don't want the breaks on the first use effect
            if useEffectDesc == L""
            then
                useEffectDesc = bonusText
            else
                useEffectDesc = useEffectDesc..L"<br><br>"..bonusText
            end
        end
    end
    
    -- After displaying all the baseline bonuses from the item, look at any enhancements that
    -- are slotted on the item and display their information.
    -- This not only updates the Stat lines from above, it also updates the tooltip lines describing
    -- which enhancements are slotted on the item.
    
    for i = 1, itemData.numEnhancementSlots do
        local enhSlot = itemData.enhSlot[i]
        if enhSlot ~= nil then
            for ixEnhSlotBonus, bonus in ipairs(enhSlot.bonus) do
        
                local bonus = enhSlot.bonus[ixEnhSlotBonus];
            
                --DEBUG( L"enhSlot.bonus["..ixEnhSlotBonus..L"].duration = "..bonus.duration )
                if( bonus.type == GameDefs.ITEMBONUS_MAGIC and bonus.reference > 0 and bonus.value ~= 0) then
                    
                    if (statLines[bonus.reference] ~= nil) then
                        AddStatContribution (statLines[bonus.reference], bonus.value, i, bonus.duration);
                    else
                        -- Instead of creating the line with a real value, use 0, so that the total bonus
                        -- on the item isn't larger than it should be (because we're adding ONLY contributions
                        -- to an item without this stat.)
                        statLines[bonus.reference] = CreateStatLine( ixStat, 1, 0, 0 );
                        AddStatContribution (statLines[bonus.reference], bonus.value, i, bonus.duration);
                        
                        
                        ixStat = ixStat + 1;
                    end
                elseif( ( bonus.type == GameDefs.ITEMBONUS_CONTINUOUS ) and bonus.reference > 0 )
                then
                    local bonusText = ItemUtils.GetFormattedBonus( bonus, false, itemData.currChargesRemaining, itemData.iLevel, itemData.careers )
                    DisplayPassiveAbilityLine( tooltipWindow, iCurPassiveAbility, bonus, bonusText)
                    iCurPassiveAbility = iCurPassiveAbility + 1
                elseif( ( bonus.type == GameDefs.ITEMBONUS_USE ) and bonus.reference > 0 )
                then
                    local bonusText = ItemUtils.GetFormattedBonus( bonus, false, itemData.currChargesRemaining, itemData.iLevel, itemData.careers );
                    if( useEffectDesc ~= L"" )
                    then
                        bonusText = L"<br>"..bonusText
                    end
                    useEffectDesc = useEffectDesc..bonusText
                end
            end
        end
    end
    
    -- Now, it's time to loop over the cached bonus values and spit them all out to the tooltip labels.
    -- Yes, this could use for k, v in pairs (table), but then the ordering of bonuses would not be preserved.
    for i = 1, GameData.BonusTypes.EBONUS_NUM_BONUS_TYPES do
        if (statLines[i] ~= nil) then
            DisplayStatLine (tooltipWindow, i, statLines[i], itemData.careers);
        end
    end
            
    -- Clear out the remaining stat labels...
    while( ixStat <= GameDefs.MAX_BONUSES_PER_ITEM ) do  
        HideStatLine (tooltipWindow, ixStat);
        ixStat = ixStat + 1
    end
        
    LabelSetText( tooltipWindow.."UseEffect", useEffectDesc );        


    for i = unsalvagableBonusCount + 1, 10
    do
       local unsalvagableBonusLabel = tooltipWindow.."SalvageBonusesLabel"..i;
       LabelSetText(unsalvagableBonusLabel, L""); 
    end  

    if(playerHasSalvagingSkill and itemIsSalvagable)
    then
       LabelSetText(tooltipWindow.."SalvageText", salvageText);
       LabelSetTextColor(tooltipWindow.."SalvageText", salvageTextColor.r, salvageTextColor.g, salvageTextColor.b);
       WindowSetShowing(tooltipWindow.."SalvageBonuses", true);
    else
       LabelSetText(tooltipWindow.."SalvageText", L"");
       WindowSetShowing(tooltipWindow.."SalvageBonuses", false);   
    end

    -- NOTE: This also loops through all enhancement slots!!!!!  INEFFICIENT!
    SetItemTooltipEnhSlotInfo (tooltipWindow, itemData);    
end

--[[
    Utility Function for all the item requirements data
--]]
local function SetItemTooltipRequirementsData (tooltipWindow, itemData, shouldColorType)
    local reqs = DataUtils.PlayerMeetsReqs (itemData)
    
    -- if trial user, and the item is not flagged for use by trial players, set the a warning string
    local isTrial, _ = GetAccountData()
    if( isTrial and not itemData.flags[GameData.Item.EITEMFLAG_CAN_USE_IN_TRIAL] ) 
    then
        LabelSetText (tooltipWindow.."TrialText", GetString( StringTables.Default.TEXT_TRIAL_ONLY_ITEM ) );
    else 
        LabelSetText (tooltipWindow.."TrialText", L"");
    end
    
    Tooltips.SetReqsWithLookup (tooltipWindow.."CareerReq",   GetString( StringTables.Default.LABEL_CAREER ),  itemData.careers,   CareerNames,    reqs.career)
    Tooltips.SetReqsWithLookup (tooltipWindow.."RaceReq",     GetString( StringTables.Default.LABEL_RACE ),    itemData.races,     RaceNames,      reqs.race)
    
    local appearanceTooltipText = L""
    local appearanceNameTooltipText = L""
	
	if( itemData.customizedIconNum ~= 0 )
    then
        appearanceTooltipText = GetString( StringTables.Default.TOOLTIP_ITEM_APPEARANCE_APPLIED )
		appearanceNameTooltipText = itemData.customizedIconName
    elseif( DataUtils.IsItemAppearanceCustomizable( itemData.equipSlot, itemData ) )
    then
        appearanceTooltipText = GetString( StringTables.Default.TOOLTIP_ITEM_APPEARANCE_READY )
    end
    
    LabelSetText( tooltipWindow.."AppearanceState", appearanceTooltipText )
	LabelSetText( tooltipWindow.."AppearanceName", appearanceNameTooltipText )
    
    -- Color the item type label if the players skills are not sufficient instead of using the skill label
    if ( shouldColorType )
    then
        if( reqs.skills == false )
        then
            DefaultColor.LabelSetTextColor( tooltipWindow.."Type", Tooltips.COLOR_FAILS_REQUIREMENTS )
        else
            DefaultColor.LabelSetTextColor( tooltipWindow.."Type", Tooltips.COLOR_ITEM_DEFAULT_GRAY )
        end
    end
    
    -- TODO: ItemSlots does not actually match up to inventory numbers
    --   but it probably should
    Tooltips.SetReqSlotsForEnhancement( tooltipWindow.."SlotReq", itemData )
    
    Tooltips.SetReqsWithValue (tooltipWindow.."RenownReq",   
                                GetStringFormat (StringTables.Default.LABEL_RENOWN_X, { itemData.renown } ),
                                itemData.renown,
                                reqs.renown)
                                
    if (itemData.rarity == SystemData.ItemRarity.UTILITY) then
        LabelSetText (tooltipWindow.."LevelText", L"");
    else
        Tooltips.SetReqsWithValue (tooltipWindow.."LevelText",   
                                    GetStringFormat (StringTables.Default.LABEL_MINIMUM_RANK_X, { itemData.level } ),  
                                    itemData.level, 
                                    reqs.level)
    end
    
    -- set trade skills requirements if exists
    if DataUtils.IsTradeSkillItem( itemData ) then
        local reqText = GetString( StringTables.Default.LABEL_SKILL )..L" "..DataUtils.GetStringForTradeSkillsLevel( itemData )
        local hasHighEnoughSkill = DataUtils.PlayerTradeSkillLevelIsEnoughForItem( itemData )
        
        SetRequirementsLabel( tooltipWindow.."SkillsReq", reqText, hasHighEnoughSkill )
    else
        SetRequirementsLabel( tooltipWindow.."SkillsReq", L"", true )
    end
    
end


local function GetBrokenItemName (itemData)

    itemData.brokenName = itemData.brokenName or itemData.name or L""   -- protect against returning nil
    return itemData.brokenName
end

--
local function GetBrokenItemIcon (itemData)

    itemData.brokenIconNum = itemData.brokenIconNum or itemData.iconNum or -1       -- protect against returning nil
    return itemData.brokenIconNum
end

local function GetBindText( itemData )
    if ( itemData.boundToPlayer)
    then
        if (itemData.flags[GameData.Item.EITEMFLAG_ACCOUNT_BOUND])
        then
            return GetString( StringTables.Default.LABEL_BOUND_TO_ACCOUNT )
        else
            return GetString( StringTables.Default.LABEL_BOUND_TO_PLAYER )
        end
    elseif ( itemData.flags[GameData.Item.EITEMFLAG_BIND_ON_PICKUP] )
    then
        if (itemData.flags[GameData.Item.EITEMFLAG_ACCOUNT_BOUND])
        then
            return GetString( StringTables.Default.LABEL_BIND_TO_ACCOUNT_ON_PICKUP )
        else
            return GetString( StringTables.Default.LABEL_BIND_ON_PICKUP )
        end
    elseif ( itemData.flags[GameData.Item.EITEMFLAG_BIND_ON_EQUIP] )
    then
        if (itemData.flags[GameData.Item.EITEMFLAG_ACCOUNT_BOUND])
        then
            return GetString( StringTables.Default.LABEL_BIND_TO_ACCOUNT_ON_EQUIP )
        else
            return GetString( StringTables.Default.LABEL_BIND_ON_EQUIP )
        end
    else
        return L""
    end
end

--[[
    Utility function for updating decay time information for an item tooltip.
--]]

local function UpdateItemDecayTime(tooltipWindow, itemData)
    local decayText = L""
    if( itemData.timeLeftBeforeDecay > 0 ) then
        local currentTimeLeftBeforeDecay = itemData.timeLeftBeforeDecay;
        

		
        if( not itemData.decayPaused )then
            currentTimeLeftBeforeDecay = currentTimeLeftBeforeDecay + itemData.timestamp - GetGameTime()
            if( currentTimeLeftBeforeDecay <= 0 ) then
                currentTimeLeftBeforeDecay = 1
            end
        end
        
        decayText = GetStringFormat(StringTables.Default.LABEL_ITEM_DECAY_TIME, {})..TimeUtils.FormatTime(currentTimeLeftBeforeDecay)
    end
	--Timer color
		if( itemData.timeLeftBeforeDecay > 3600 ) then	
	 	LabelSetTextColor(tooltipWindow.."DecayTime", 0,255,0 )
		else
		LabelSetTextColor(tooltipWindow.."DecayTime", 255,0,0 )
	end	

    LabelSetText(tooltipWindow.."DecayTime", decayText )
end

--[[
    Utility function to deal with the base information about an item...
--]]

local function SetItemTooltipBaseData (tooltipWindow, itemData)
    local color

    -- Name
    if itemData.broken and itemData.repairedName ~= nil and itemData.repairedName ~= L""
    then
        LabelSetText( tooltipWindow.."Name", GetStringFormat(StringTables.Default.LABEL_ITEM_NAME_FORMAT_ITEM_TOOLTIP, {itemData.repairedName}) )
    else
        LabelSetText( tooltipWindow.."Name", GetStringFormat(StringTables.Default.LABEL_ITEM_NAME_FORMAT_ITEM_TOOLTIP, {itemData.name}) )
    end
    color = DataUtils.GetItemRarityColor(itemData)
    LabelSetTextColor( tooltipWindow.."Name", color.r, color.g, color.b )
    
    -- Locked Text
    if(itemData.type == GameData.ItemTypes.TREASURE_CHEST) then
        color = DataUtils.GetItemTierColor(itemData)
        LabelSetText(tooltipWindow.."Locked", GetString(StringTables.Default.TEXT_LOCKED))
        LabelSetTextColor(tooltipWindow.."Locked", color.r, color.g, color.b)
    else
        LabelSetText(tooltipWindow.."Locked", L"")
    end
    
   -- Icon   
    local texture, x, y
    if itemData.broken and itemData.repairedIconNum ~= nil
    then
        texture, x, y = GetIconData( itemData.repairedIconNum )
    else
        texture, x, y = GetIconData( itemData.iconNum )
    end
    DynamicImageSetTexture( tooltipWindow.."Icon", texture, x, y )
                    
    -- Slot 
    local slotText = DataUtils.GetItemEquipSlotName( itemData )
    LabelSetText(tooltipWindow.."Slot", slotText )
    
    -- If this is an "Either Hand" item, check for dualwielding 
    if( itemData.equipSlot == GameData.EquipSlots.EITHER_HAND )
    then
        LabelSetText(tooltipWindow.."SlotEitherHand", GetString( StringTables.Default.LABEL_EITHER_HAND ) )
        if( GameData.Player.Skills[GameData.SkillType.DUAL_WIELD] == false )
        then            
            LabelSetTextColor( tooltipWindow.."SlotEitherHand", Tooltips.COLOR_FAILS_REQUIREMENTS.r,
                Tooltips.COLOR_FAILS_REQUIREMENTS.g, Tooltips.COLOR_FAILS_REQUIREMENTS.b )
        else
            LabelSetTextColor( tooltipWindow.."SlotEitherHand", Tooltips.COLOR_ITEM_DEFAULT_GRAY.r,
                Tooltips.COLOR_ITEM_DEFAULT_GRAY.g, Tooltips.COLOR_ITEM_DEFAULT_GRAY.b )
        end
    else
        LabelSetText(tooltipWindow.."SlotEitherHand", L"" )
    end
    
    -- Type 
    -- trade skill items don't have an item type and even once they do, they can't 
    --   use the simple item type to string mapping, so have special case for them here
    local typeText 
    if DataUtils.IsTradeSkillItem( itemData )
    then
        typeText = DataUtils.GetStringForAllTradeSkills( itemData )
    else
        typeText = DataUtils.GetItemTypeName( itemData.type, itemData.isTwoHanded )
    end
    LabelSetText(tooltipWindow.."Type", typeText )
    
    -- Item Level
    local itemLevelText = L""
    if ( ( itemData.iLevel > 0 ) and not itemData.flags[GameData.Item.EITEMFLAG_HIDE_ITEM_LEVEL] )
    then
        itemLevelText = GetStringFormat( StringTables.Default.LABEL_ITEM_LEVEL_X, { itemData.iLevel } )
    end
    LabelSetText(tooltipWindow.."ItemLevel", itemLevelText )
    
    local maxEquipText = L""
    if( itemData.maxEquip == 1 )
    then
        maxEquipText = GetString( StringTables.Default.LABEL_UNIQUE_EQUIPPED )
    elseif( itemData.maxEquip > 1 )
    then
        maxEquipText = GetStringFormat( StringTables.Default.LABEL_UNIQUE_EQUIPPED_MAX_NUMBER, { itemData.maxEquip } )
    end
    LabelSetText( tooltipWindow.."MaxEquip", maxEquipText )
    
    
    -- Armor  
    local armorText = L""  
    if( itemData.armor > 0 ) then
        armorText = GetStringFormat( StringTables.Default.LABEL_X_ARMOR, { itemData.armor } )
    end
    LabelSetText(tooltipWindow.."Armor", armorText )
    
    -- DPS
    local dpsText = L""
    if( itemData.dps > 0 ) then
        dpsText = GetStringFormat( StringTables.Default.LABEL_X_DPS, { wstring.format(L"%.01f",itemData.dps) } )
    end
    LabelSetText(tooltipWindow.."DPS", dpsText )
    
    -- Speed
    local speedText = L""
    if( itemData.speed > 0 ) then
        speedText = GetStringFormat( StringTables.Default.LABEL_X_SPEED, { wstring.format(L"%.01f",itemData.speed) } )
    end
    LabelSetText(tooltipWindow.."Speed", speedText )
    
    -- Block Rating
    local blockText = L""
    if( itemData.blockRating > 0 ) then
        blockText = GetStringFormat( StringTables.Default.LABEL_X_BLOCK_RATING, { itemData.blockRating } )
    end
    LabelSetText(tooltipWindow.."BlockRate", blockText )
    
    -- Decay Time
    UpdateItemDecayTime( tooltipWindow, itemData )
        
    -- Color the item if it has been dyed
    local dyeColorText = L""
    local dyeTintA = itemData.dyeTintA
    local dyeTintB = itemData.dyeTintB
    if( (dyeTintA ~= 0) and (dyeTintB ~= 0) ) then
        local dyeAText = GetDyeNameString(dyeTintA)
        local dyeBText = GetDyeNameString(dyeTintB)
        dyeColorText = GetStringFormat( StringTables.Default.TEXT_TWO_DYE_COLOR, {dyeAText , dyeBText} )
    elseif ( dyeTintA ~= 0 ) then
        local dyeTintAText = GetDyeNameString(dyeTintA)
        dyeColorText = GetStringFormat( StringTables.Default.TEXT_ONE_DYE_COLOR, {dyeTintAText} )
    elseif ( dyeTintB ~= 0 ) then
        local dyeTintBText = GetDyeNameString(dyeTintB)
        dyeColorText = GetStringFormat( StringTables.Default.TEXT_ONE_DYE_COLOR, {dyeTintBText} )
    end
    LabelSetText(tooltipWindow.."DyeColor", dyeColorText )
    
    -- Text for the dye item
    local dyeItemColorText = L""
    local dyeInstructionText = L""
    local tintA = itemData.tintA
    local tintB = itemData.tintB
    if( itemData.type == GameData.ItemTypes.DYE ) then
        if( (tintA == 0) and ( tintB == 0) ) then
            dyeInstructionText =  GetString( StringTables.Default.TEXT_HOW_TO_BLEACH_AN_ITEM )
        else
            local tintAText = GetDyeNameString(tintA)
            local tintBText = GetDyeNameString(tintB)
                dyeInstructionText =  GetString( StringTables.Default.TEXT_HOW_TO_DYE_AN_ITEM )
            if( (tintA ~= 0) and (tintB ~=0) ) then
                dyeItemColorText = GetStringFormat( StringTables.Default.TEXT_TWO_SELECT_DYE_COLOR, { tintAText, tintBText } )
            elseif( tintA ~= 0) then
                dyeItemColorText = GetStringFormat( StringTables.Default.TEXT_ONE_SELECT_DYE_COLOR, { tintAText } )
            elseif( tintB ~= 0) then
                dyeItemColorText = GetStringFormat( StringTables.Default.TEXT_ONE_SELECT_DYE_COLOR, { tintBText } )
            end
            dyeInstructionText = dyeItemColorText..dyeInstructionText
        end
    end
    
    LabelSetText(tooltipWindow.."DyeInstruction", dyeInstructionText )
        
    -- Bound on pickup/ Bound on equip/ Bound to Player   
    LabelSetText(tooltipWindow.."Bind", GetBindText( itemData ) )

    -- Description
    LabelSetText(tooltipWindow.."Description", itemData.description)
    
end

--[[
    Takes a tooltipWindow, an itemData (in regular game item format) and optional
    arguments for extra tooltip text/color and sets all the labels and icons for
    the item's tooltip.  The window is sized correctly after this function returns.
--]]
function Tooltips.SetItemTooltipData( tooltipWindow, itemData, extraText, extraTextColor )

     --DEBUG (L"*** SetItemTooltipData, win = "..StringToWString (tooltipWindow)..L" for item: "..itemData.name..L" ***");
    SetItemTooltipBaseData (tooltipWindow, itemData);
    SetItemTooltipBonusData (tooltipWindow, itemData);
    SetItemTooltipRequirementsData (tooltipWindow, itemData, true);
    
    -- Item Set Data
    ClearItemSetTooltipData (tooltipWindow);
    if (itemData.itemSet > 0) then
        local itemSetData = DataUtils.GetItemSetData (itemData.itemSet);
        
        if (itemSetData ~= nil) then
            SetItemSetTooltipData (tooltipWindow, itemData, itemSetData);
        end
    end
                        
    -- Optional extra text
    Tooltips.SetExtraText (tooltipWindow, "ActionText", "ActionTextLine", extraText, extraTextColor)

    -- Resize the window...    
    CalculateItemTooltipSize (tooltipWindow);
end

--[[
    Updates set item information for comparison tooltips.
--]]
local function RefreshItemSetDataForCompWindow (windowName, itemSet)
    local compItem = nil;
    
    if (WindowGetShowing (windowName)) then
        compItem = Tooltips.GetExtraWindowData (windowName);

        if (compItem                    and 
            compItem.itemSet ~= nil     and 
            compItem.itemSet == itemSet.id) 
        then
            SetItemSetTooltipData (windowName, compItem, itemSet);
            CalculateItemTooltipSize (windowName);
        end
    end
end


--[[
    Checks all visible item tooltips to see if they're displaying item set
    data, and if they are and the newly updated item set is what they need
    updates those tooltips.
--]]
function Tooltips.RefreshItemSetData ()
    -- DEBUG (L"Tooltips.RefreshItemSetData : Called to update set: "..GameData.UpdatedItemSet.id);
    
    local newItemSet = DataUtils.GetItemSetData (GameData.UpdatedItemSet.id);
    
    if ( newItemSet and Tooltips.curItemData and Tooltips.curTooltipWindow and
        Tooltips.curTooltipWindow ~= "DefaultTooltip" and
        Tooltips.curTooltipWindow ~= "BrokenItemTooltip" )
    then
        
        SetItemSetTooltipData (Tooltips.curTooltipWindow, Tooltips.curItemData, newItemSet);
        CalculateItemTooltipSize (Tooltips.curTooltipWindow);
        
        -- Just noticed that the backpack shows the price AFTER the tooltip is created...
        -- So, do the same thing here...another possible fix would be to add a showPrice
        -- parameter to the CreateItemTooltipMethod, but that's starting to get a little congested...
        -- or maybe add another flag to the item tooltips?
        if EA_Window_InteractionStore.InteractingWithStore() then
            Tooltips.ShowSellPrice (Tooltips.curItemData);
        end
        
        -- Update tooltips for the comparison windows, if they're showing.
        RefreshItemSetDataForCompWindow (Tooltips.ItemTooltip.COMPARISON_WIN_1, newItemSet);
        RefreshItemSetDataForCompWindow (Tooltips.ItemTooltip.COMPARISON_WIN_2, newItemSet);
    end
end


----------------------------------------------------------
-- BROKEN ITEM FUNCTIONS
----------------------------------------------------------


--[[
    Sets fields for the BrokenItemTooltip
--]]
function BrokenItemTooltip.SetTooltipData( tooltipWindow, itemData )

    local repairableItemAvailable = (itemData.repairedName ~= nil and itemData.repairedName ~= L"")

    -- Name
    LabelSetText( tooltipWindow.."BrokenName", GetStringFormat( StringTables.Default.LABEL_ITEM_NAME_FORMAT_ITEM_TOOLTIP, {GetBrokenItemName(itemData)} ) )
    local color = DataUtils.GetItemRarityColor(itemData)
    LabelSetTextColor( tooltipWindow.."BrokenName", color.r, color.g, color.b )
    
    -- Icon
    local texture, x, y = GetIconData( GetBrokenItemIcon( itemData ) )
    DynamicImageSetTexture( tooltipWindow.."BrokenIcon", texture, x, y )

    -- Req
    SetItemTooltipRequirementsData( tooltipWindow, itemData, false )
    
    -- Bound on pickup/ Bound on equip/ Bound to Player   
    LabelSetText( tooltipWindow.."Bind", GetBindText( itemData ) )
        
    if not repairableItemAvailable then
        instructions = GetString(StringTables.Default.LABEL_ITEM_BROKEN_BAD_CAREER )
    else
        instructions = GetStringFormat(StringTables.Default.LABEL_ITEM_BROKEN_REPAIR_TEXT, { GameData.Player.career.name } )
    end
    LabelSetText(tooltipWindow.."RepairText", instructions ) 

    CalculateBrokenItemTooltipSize( tooltipWindow, repairableItemAvailable )
    
end


----------------------------------------------------------
-- Tradeskill Tooltips
----------------------------------------------------------

-- TODO: Fix this so that if the order of the trad skill items changes this does not break.
local TradeSkillTooltips = 
{
    { name = GetString (StringTables.Default.LABEL_SKILL_BUTCHERING),           desc = GetString (StringTables.Default.TOOLTIP_SKILL_BUTCHERING),   },
    { name = GetString (StringTables.Default.LABEL_SKILL_SCAVENGING),           desc = GetString (StringTables.Default.TOOLTIP_SKILL_SCAVENGING),   },
    { name = GetString (StringTables.Default.LABEL_SKILL_CULTIVATION),          desc = GetString (StringTables.Default.TOOLTIP_SKILL_CULTIVATION),  },
    { name = GetString (StringTables.Default.LABEL_SKILL_APOTHECARY),           desc = GetString (StringTables.Default.TOOLTIP_SKILL_APOTHECARY),   },
    { name = GetString (StringTables.Default.LABEL_SKILL_TALISMAN),             desc = GetString (StringTables.Default.TOOLTIP_SKILL_TALISMAN),     },
    { name = GetString (StringTables.Default.LABEL_SKILL_SALVAGING),            desc = GetString (StringTables.Default.TOOLTIP_SKILL_SALVAGING),    },
}

local function GetTradeSkillBonusType( tradeSkillId )
    if( tradeSkillId == 1 )
    then
        return GameData.BonusTypes.EBONUS_TRADE_SKILL_BUTCHERING
    elseif ( tradeSkillId == 2)
    then
        return GameData.BonusTypes.EBONUS_TRADE_SKILL_SCAVENGING
    elseif ( tradeSkillId == 3)
    then
        return GameData.BonusTypes.EBONUS_TRADE_SKILL_CULTIVATION
    elseif ( tradeSkillId == 4)
    then
        return GameData.BonusTypes.EBONUS_TRADE_SKILL_APOTHECARY
    elseif ( tradeSkillId == 5)
    then
        return GameData.BonusTypes.EBONUS_TRADE_SKILL_TALISMAN
    else
        return GameData.BonusTypes.EBONUS_TRADE_SKILL_SALVAGING
    end
end    

function Tooltips.CreateTradeskillTooltip (tradeSkillId, anchor)
    if (TradeSkillTooltips[tradeSkillId]) 
    then
        local tradeData     = TradeSkillTooltips[tradeSkillId]
        local playerSkill   = GameData.TradeSkillLevels[tradeSkillId]
        
        Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
        Tooltips.SetTooltipText (1, 1, tradeData.name)
        Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
        Tooltips.SetTooltipText (2, 1, tradeData.desc)
        
        if ((playerSkill ~= nil) and (playerSkill > 0))
        then
            local bonusType = GetTradeSkillBonusType( tradeSkillId )
            playerSkill = GetBonus( bonusType, playerSkill )
            Tooltips.SetTooltipText (3, 1, GetStringFormat (StringTables.Default.TOOLTIP_SKILL_LEVEL, { playerSkill }))
            Tooltips.SetTooltipColorDef (3, 1, Tooltips.COLOR_HEADING)
        end
        
        Tooltips.Finalize ()
        Tooltips.AnchorTooltip (anchor)
    end
end

-----------------------------------------------------------------------
-- ITEM TOOLTIP UPDATE (used only if item requires timer-based updates)
-----------------------------------------------------------------------

function Tooltips.ItemUpdateCallback( elapsedTime )

    if( Tooltips.curItemData ) then
        
        -- Update the duration labels
        if( Tooltips.curItemData.durationUpdated ) then
            SetItemTooltipBonusData( "ItemTooltip", Tooltips.curItemData )
            Tooltips.curItemData.durationUpdated = false
        end
        
        -- Update decay times
        if( Tooltips.curItemData.timeLeftBeforeDecay > 0 ) then
            UpdateItemDecayTime( "ItemTooltip", Tooltips.curItemData )
        end

    end
    
end



----------------------------------------------------------
-- APPEARANCE ITEM FUNCTIONS
----------------------------------------------------------

--[[
    Sets fields for the AppearanceItemTooltip
--]]
function AppearanceItemTooltip.SetTooltipData( tooltipWindow, itemData )
    -- Name
    LabelSetText( tooltipWindow.."Name", GetStringFormat( StringTables.Default.LABEL_ITEM_NAME_FORMAT_ITEM_TOOLTIP, {itemData.customizedIconName} ) )
    LabelSetText( tooltipWindow.."Title", GetString( StringTables.Default.TOOLTIP_ITEM_APPEARANCE_TOOLTIP ) )
    -- Icon
    local texture, x, y = GetIconData( itemData.customizedIconNum )
    DynamicImageSetTexture( tooltipWindow.."Icon", texture, x, y )
end

--[[
	Create an appearance item tooltip with only icon and name
--]]
function Tooltips.CreateAppearanceItemTooltip( itemData, mouseoverWindow )
    local tooltipWindow = "AppearanceItemTooltip"
	
    AppearanceItemTooltip.SetTooltipData( tooltipWindow, itemData )
	Tooltips.CreateCustomTooltip( mouseoverWindow, tooltipWindow )
	Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_VARIABLE, true )
end

