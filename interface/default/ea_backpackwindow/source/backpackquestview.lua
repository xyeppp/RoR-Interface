----------------------------------------------------------------
-- Backpack Quest View Utils
--
-- This file contains the implementation for the Backpack QUEST
-- items tab
----------------------------------------------------------------


function EA_Window_Backpack.UpdateAllQuestItemSlots()
    
    local questItems = DataUtils.GetQuestItems() 
    if questItems ~= nil then
    
		EA_Window_Backpack.DrawQuestItemsLayout()
	
		for slot = 1, EA_Window_Backpack.numberOfSlots[EA_Window_Backpack.TYPE_QUEST] do
			itemData = questItems[slot]
			EA_Window_Backpack.SetQuestBackpackSlot( EA_Window_Backpack.QUEST_SLOT_NAME_BASE..slot, itemData, false, nil )
		end
	
    end
end


function EA_Window_Backpack.CreateAllQuestSlotWindows()

	local slotName
	
	local parentWindow = EA_Window_Backpack.GetPocketName( EA_Window_Backpack.TYPE_QUEST )
	for i = 1, EA_Window_Backpack.numberOfSlots[EA_Window_Backpack.TYPE_QUEST] do
		slotName = EA_Window_Backpack.GetWindowNameForSlot( i, EA_Window_Backpack.POCKETS_START_INDEX[EA_Window_Backpack.TYPE_QUEST] )
		if DoesWindowExist( slotName ) then
			continue
		end
		CreateWindowFromTemplate( slotName, EA_Window_Backpack.QUEST_ITEM_BUTTON_TEMPLATE, parentWindow )
		WindowSetId( slotName, i )
	
	end
	
end



-- this only displays slots that contain quest items, so when a quest item is removed, everything is reanchored
--   to make sure it ends up in the proper column/row with no empty slots
--
function EA_Window_Backpack.DrawQuestItemsLayout( width )
	
	width = width or EA_Window_Backpack.views[EA_Window_Backpack.VIEW_MODE_QUEST].mainWindowWidth
	
	local row, column = 1, 1 
	local slotWindowName, previousSlot, previousRowSlot
	local itemData, itemExists
		
	for slotID = 1, EA_Window_Backpack.numberOfSlots[EA_Window_Backpack.TYPE_QUEST] do
				
		slotWindowName = EA_Window_Backpack.GetWindowNameForSlot( slotID, EA_Window_Backpack.POCKETS_START_INDEX[EA_Window_Backpack.TYPE_QUEST] )

		itemData = DataUtils.GetQuestItems()[slotID]
		itemExists = EA_Window_Backpack.ValidItem( itemData )
		WindowSetShowing( slotWindowName, itemExists )
		if not itemExists then
			continue
		end
		
		if column > EA_Window_Backpack.NUM_SLOTS_WIDE then
			row = row + 1
			column = 1
		end
			
		WindowClearAnchors( slotWindowName )
		if column == 1 then
			if row == 1 then
                local parentName = EA_Window_Backpack.GetPocketName( EA_Window_Backpack.TYPE_QUEST )
				WindowAddAnchor( slotWindowName, "topleft", parentName, "topleft", 
				                 EA_Window_Backpack.POCKET_LEFT_SPACING, EA_Window_Backpack.POCKET_TOP_SPACING )
			else
				WindowAddAnchor( slotWindowName, "bottomleft", previousRowSlot, "topleft", 
				                 0, EA_Window_Backpack.VERTICAL_SPACE_BETWEEN_SLOTS )
			end
			previousRowSlot = slotWindowName
		else
			
			WindowAddAnchor( slotWindowName, "topright", previousSlot, "topleft", 
			                 EA_Window_Backpack.HORIZONTAL_SPACE_BETWEEN_SLOTS, 0 )
		end
		
		previousSlot = slotWindowName
		column = column + 1
	end	
	
	-- show the correct number of Quest Row Backgrounds
	EA_Window_Backpack.NumberOfVisibleQuestBackgrounds = row
	
	for i = 1, EA_Window_Backpack.NumberOfVisibleQuestBackgrounds  do
		WindowSetShowing( EA_Window_Backpack.QUEST_BACKGROUND_BASE_NAME..i, true )
	end
	
	for i = EA_Window_Backpack.NumberOfVisibleQuestBackgrounds+1, EA_Window_Backpack.TotalNumberOfQuestBackgrounds  do
		WindowSetShowing( EA_Window_Backpack.QUEST_BACKGROUND_BASE_NAME..i, false )
	end
	
	-- when width is initially set (or if width ever changes) resize each row's background 
	if width ~= EA_Window_Backpack.views[EA_Window_Backpack.VIEW_MODE_QUEST].mainWindowWidth then
	
		local backgroundWidth = width - (EA_Window_Backpack.SEE_THROUGH_LEFT_SPACING + EA_Window_Backpack.SEE_THROUGH_RIGHT_SPACING ) 
	
		for i = 1, EA_Window_Backpack.TotalNumberOfQuestBackgrounds do
			WindowSetDimensions( EA_Window_Backpack.QUEST_BACKGROUND_BASE_NAME..i, backgroundWidth, EA_Window_Backpack.SLOT_HEIGHT )
		end
	end
	
	local height = EA_Window_Backpack.ResizePocket( EA_Window_Backpack.POCKETS_START_INDEX[EA_Window_Backpack.TYPE_QUEST], row, width )
	height = height + EA_Window_Backpack.mainFrameTopHeight + EA_Window_Backpack.mainFrameBottomHeight
	EA_Window_Backpack.views[EA_Window_Backpack.VIEW_MODE_QUEST].mainWindowWidth = width
	EA_Window_Backpack.views[EA_Window_Backpack.VIEW_MODE_QUEST].mainWindowHeight = height 
	
	if EA_Window_Backpack.currentMode == EA_Window_Backpack.VIEW_MODE_QUEST or EA_Window_Backpack.currentMode == EA_Window_Backpack.VIEW_MODE_CRAFTING then
        WindowSetDimensions( EA_Window_Backpack.windowName, width, height )
	end
	
end



function EA_Window_Backpack.SetQuestBackpackSlot( buttonName, itemData, isLocked, highLightColor )
	
	if DoesWindowExist( buttonName ) == false then
		ERROR(L"SetQuestBackpackSlot failed to find window="..StringToWString(buttonName) )
		return
	end
	
    -- Clear the Slot if no item is set.
    if not EA_Window_Backpack.ValidItem( itemData ) then
               
        DynamicImageSetTexture (buttonName.."Icon", "", 0, 0)
        --ButtonSetText(buttonName, L"" )
        --LabelSetText(buttonName.."Text", L"" )
		WindowSetShowing( buttonName.."Text", false )
        
		WindowSetShowing( buttonName.."Cooldown", false )
		WindowSetShowing( buttonName.."CooldownTimer", false )
        return
    end
    
    -- Set the Data
    
    -- Icon
    local texture, x, y = GetIconData(itemData.iconNum)
    DynamicImageSetTexture( buttonName.."Icon", texture, x, y)
    --DynamicImageSetTextureScale( buttonName.."Icon", EA_Window_Backpack.ICON_SCALE )
    
    -- Count            
    WindowSetShowing( buttonName.."Text", itemData.stackCount > 1 )
    if itemData.stackCount > 1 then
        --ButtonSetText(buttonName, L""..itemData.stackCount )
        LabelSetText(buttonName.."Text", L""..itemData.stackCount )
    end
    
    -- Cooldown not currently used for quests
    WindowSetShowing( buttonName.."Cooldown", false )
    WindowSetShowing( buttonName.."CooldownTimer", false )
    
    -- NOTE: I've removing the call to WindowSetGameActionData( buttonName, GameData.PlayerActions.USE_ITEM
    --   We now handle the UseItem call directly in EA_Window_Backpack.EquipmentRButtonUp.
    
    if isLocked then
        if highLightColor then
            WindowSetTintColor( buttonName, highLightColor.r, highLightColor.g, highLightColor.b )
            WindowSetTintColor (buttonName.."Icon", 255, 255, 255)
        else
            WindowSetTintColor( buttonName, 255, 255, 255 )
            WindowSetTintColor (buttonName.."Icon", 75, 75, 75)
        end
    else
        WindowSetTintColor( buttonName, 255, 255, 255 )
        WindowSetTintColor (buttonName.."Icon", 255, 255, 255)
    end
end

function EA_Window_Backpack.GetWindowNameForSlot( slotID, pocketNumber )

	pocketNumber = pocketNumber or EA_Window_Backpack.POCKET_MAIN_INVENTORY_INDEX 
	
	local baseWindowName
	if pocketNumber == EA_Window_Backpack.POCKETS_START_INDEX[EA_Window_Backpack.TYPE_QUEST]  then
		baseWindowName = EA_Window_Backpack.QUEST_SLOT_NAME_BASE
	else
		baseWindowName = EA_Window_Backpack.SLOT_NAME_BASE
	end
	
	return baseWindowName..slotID
end



-------------------------------------------------------------------------
-- Button Handlers
-------------------------------------------------------------------------

-- OnLButtonDown Handler
function EA_Window_Backpack.QuestItemLButtonDown(flags, x, y)
    local slot = WindowGetId(SystemData.ActiveWindow.name)
    local itemData = DataUtils.GetQuestItems()[slot]
    
    if Cursor.IconOnCursor() then
        -- Need to see if I should "RequestMoveItem" to destroy it, or just clear the cursor because quest item
        -- moves will not be allowed in this cut...
        
        -- For now I am just going to clear the cursor...
        Cursor.Clear ()
    elseif( itemData and itemData.uniqueID ~= 0 ) then
        -- If you click on a quest item, pick it up, so that you can destroy it and abandon the quest...
        Cursor.PickUp (Cursor.SOURCE_QUEST_ITEM, slot, itemData.uniqueID, itemData.iconNum, true)
    end
end


-- OnRButtonUp Handler
function EA_Window_Backpack.QuestItemRButtonUp ()
    
    local slot      = WindowGetId(SystemData.ActiveWindow.name)
    local itemData  = DataUtils.GetQuestItems()[slot]
    
    if EA_Window_Backpack.ValidItem( itemData ) then
        SendUseItem( GameData.ItemLocs.QUEST_ITEM, slot, 0, 0, 0)
    end
end


-- OnMouseOver Handler
function EA_Window_Backpack.QuestItemMouseOver()
    EA_Window_Backpack.MouseOverQuestSlot( WindowGetId(SystemData.ActiveWindow.name) )
end 


function EA_Window_Backpack.MouseOverQuestSlot( slot )
	
    local itemData = DataUtils.GetQuestItems()[slot]
        
    if EA_Window_Backpack.ValidItem( itemData ) then                
        Tooltips.CreateItemTooltip (itemData, EA_Window_Backpack.QUEST_SLOT_NAME_BASE..slot, Tooltips.ANCHOR_WINDOW_RIGHT)
        return
    else 
        Tooltips.ClearTooltip()
    end
end


-- SystemData.Events.PLAYER_QUEST_ITEM_SLOT_UPDATED Handler
function EA_Window_Backpack.UpdateQuestItemSlot( updatedSlots )

    for _, slot in ipairs( updatedSlots )
    do    
        local itemData = DataUtils.GetQuestItems()[slot]
	    --local itemExists = EA_Window_Backpack.ValidItem( itemData )
	    --WindowSetShowing( EA_Window_Backpack.QUEST_SLOT_NAME_BASE..slot, itemExists ) 
    	
	    EA_Window_Backpack.DrawQuestItemsLayout()

	    EA_Window_Backpack.SetQuestBackpackSlot( EA_Window_Backpack.QUEST_SLOT_NAME_BASE..slot, itemData, false, nil )
    	
     
        -- If we are mousing over the updated slot, show the tooltip
        if( SystemData.MouseOverWindow.name == EA_Window_Backpack.QUEST_SLOT_NAME_BASE..slot ) then    
            EA_Window_Backpack.MouseOverQuestSlot( slot )
        end
    
    end
end


-- END Quest Item Handlers 
-----------------------------

