----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

ItemStackingWindow = {}
ItemStackingWindow.CurrentItemSlot = nil
ItemStackingWindow.CurrentSourceLoc = nil

ItemStackingWindow.MAX_NON_STACKABLE_ITEMS = 100

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- CharacterWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function ItemStackingWindow.Initialize()		
            
    local windowName = "ItemStackingWindow"
        
    ButtonSetText( windowName.."Okay", GetString( StringTables.Default.LABEL_OKAY))
    ButtonSetText( windowName.."Cancel", GetString( StringTables.Default.LABEL_CANCEL))
    
end

function ItemStackingWindow.Show(slotLoc, slot, titleText)

    local itemData = ItemStackingWindow.GetItemData(slotLoc, slot)    
    if(itemData == nil) then
        return
    end
    
    local windowName = "ItemStackingWindow"
    local editBoxText = windowName.."TextInput"
    
    local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
    local backpackCursor = EA_BackpackUtilsMediator.GetCursorForBackpack( backpackType )
    -- if was a previous lock, release it
    if ItemStackingWindow.CurrentSourceLoc == backpackCursor and ItemStackingWindow.CurrentItemSlot then
        EA_BackpackUtilsMediator.ReleaseLockForSlot(ItemStackingWindow.CurrentItemSlot, backpackType, windowName)
    end

    --Store the item id
    ItemStackingWindow.CurrentItemSlot = slot
    ItemStackingWindow.CurrentSourceLoc = slotLoc

    -- if backpack slot, lock it in place
    if ItemStackingWindow.CurrentSourceLoc == backpackCursor and ItemStackingWindow.CurrentItemSlot then
        EA_BackpackUtilsMediator.RequestLockForSlot(ItemStackingWindow.CurrentItemSlot, backpackType, windowName)
    end
    
    titleText = titleText or GetString( StringTables.Default.LABEL_STACK_SPLITTING)
    LabelSetText( windowName.."TitleBarText", titleText )
    
    local itemText = itemData.name
    if itemData.stackCount > 1 then
        itemText = itemText..L" ("..itemData.stackCount..L")"
    end
    LabelSetText( windowName.."ItemText", itemText)
    TextEditBoxSetText(editBoxText, L"1")
    
    --Setting the anchor position to be beneath the mouse cursor
    ItemStackingWindow.HandleAnchor()
    
    WindowSetShowing( windowName, true)
    WindowAssignFocus( editBoxText, true)
    TextEditBoxSelectAll( editBoxText )
end

--Place the window where the mouse cursor currently is
function ItemStackingWindow.HandleAnchor()
    local windowName = "ItemStackingWindow"
    local x = SystemData.MousePosition.x / InterfaceCore.GetScale() -100
    local y = SystemData.MousePosition.y / InterfaceCore.GetScale() -15
    WindowClearAnchors( windowName )
    WindowAddAnchor( windowName, "topleft", "Root", "topleft", x, y )  
end

-- OnShutdown Handler
function ItemStackingWindow.Shutdown()

end

-- On Escape key pressed
function ItemStackingWindow.OnKeyEscape()
    ItemStackingWindow.OnClose()
end

--On Enter key pressed
function ItemStackingWindow.OnKeyEnter()
    ItemStackingWindow.OkayButton()
    Cursor.OnLButtonUpProcessed()
end

-- On typing text into the text edit box
function ItemStackingWindow.OnTextChanged()
    local slot = ItemStackingWindow.CurrentItemSlot
    local slotLoc = ItemStackingWindow.CurrentSourceLoc
    --Exit out of text amount if the current item id is 0
    if(slot == nil) then
        return
    end
    
    local itemData = ItemStackingWindow.GetItemData(slotLoc, slot)
    
    if( itemData == nil ) then
        return
    end
    
    local windowName = "ItemStackingWindow"
    local editBoxText = windowName.."TextInput"

    --Hexadecimal of 0 and 9 and Backspace
    
    local amount = itemData.stackCount
    if itemData.stackCount <= 1 then
        -- TODO: we really should have server send us what the stack capacity is for an item so we can use that when an item is stackable
        -- if itemData.capacity > 1 then
        -- amount = itemData.capacity
        amount = ItemStackingWindow.MAX_NON_STACKABLE_ITEMS
    end
    
    local editInputText = TextEditBoxGetText(editBoxText)
    local outputNum = nil
    if( editInputText ~= nil ) then
        outputNum = tonumber(WStringToString(editInputText))
    end
    
    if( outputNum ~= nil) then	
        if( outputNum > amount ) then
            outputNum = amount
            TextEditBoxSetText(editBoxText, L""..outputNum)
            TextEditBoxSelectAll( editBoxText )
        end
    end
end

--On Okay Button LButtonUp pressed
function ItemStackingWindow.OkayButton()
    local itemData = ItemStackingWindow.GetItemData(ItemStackingWindow.CurrentSourceLoc, ItemStackingWindow.CurrentItemSlot)
    if(itemData == nil) then
        return
    end
    
    local windowName = "ItemStackingWindow"
    local editBoxText = windowName.."TextInput"

    local editInputText = TextEditBoxGetText(editBoxText)
    local outputNum = nil
    if( editInputText ~= nil ) then
        outputNum = tonumber(WStringToString(editInputText))
    end
    
    if(outputNum ~= nil and outputNum > 0) then
        Cursor.PickUp( ItemStackingWindow.CurrentSourceLoc, ItemStackingWindow.CurrentItemSlot, itemData.uniqueID, itemData.iconNum, true, outputNum )
    end
    
    ItemStackingWindow.OnClose()
end

--On Cancel Button LButtonUp pressed
function ItemStackingWindow.CancelButton()
    ItemStackingWindow.OnClose()
end

function ItemStackingWindow.OnClose()
    local windowName = "ItemStackingWindow"
    local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
    local backpackCursor = EA_BackpackUtilsMediator.GetCursorForBackpack( backpackType )
    if ItemStackingWindow.CurrentSourceLoc == backpackCursor and ItemStackingWindow.CurrentItemSlot then
        EA_BackpackUtilsMediator.ReleaseLockForSlot(ItemStackingWindow.CurrentItemSlot, backpackType, windowName)
    end
    ItemStackingWindow.CurrentItemSlot = nil
    ItemStackingWindow.CurrentSourceLoc = nil
    WindowSetShowing( windowName, false)
end

function ItemStackingWindow.GetItemData(sourceLoc, slot)
    
    local itemData
    
    -- NOTE: I removed sourceLoc == Cursor.SOURCE_EQUIPMENT and sourceLoc == Cursor.SOURCE_QUEST_ITEM (1/12/09)
    --	 as valid choices, since I can't think of any reason we would have a stackable item in the CharacterWindow,
    --   and we shouldn't be able to split a stacked item in Quest Backpack

    local backpackType = EA_BackpackUtilsMediator.GetCurrentBackpackType()
    local curretBackpackCursor = EA_BackpackUtilsMediator.GetCursorForBackpack( backpackType )      
    if( sourceLoc ~= Cursor.SOURCE_QUEST_ITEM and ( sourceLoc == curretBackpackCursor or 
        sourceLoc == Cursor.SOURCE_BANK ) )
    then
        itemData = DataUtils.GetItemData(sourceLoc, slot)

    elseif sourceLoc == Cursor.SOURCE_MERCHANT then
        itemData = EA_Window_InteractionStore.GetItem(slot)
    end
    
    return itemData
end