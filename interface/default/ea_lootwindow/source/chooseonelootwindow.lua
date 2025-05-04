----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_ChooseOneLoot = {}

EA_Window_ChooseOneLoot.TOOLTIP_ANCHOR = { Point = "topright",   RelativeTo = "EA_Window_ChooseOneLoot", RelativePoint = "topleft",   XOffset=5, YOffset=75 }

-- Loot Types
-- Used to determine what action should take place for certain
-- types of item containers in WAR
EA_Window_ChooseOneLoot.LOOT_TYPE_PQR_MYSTERY_BAG = 1
EA_Window_ChooseOneLoot.LOOT_TYPE_ITEM_CONTAINER = 2

EA_Window_ChooseOneLoot.lootData = nil
EA_Window_ChooseOneLoot.lootDataDisplayOrder = {}
EA_Window_ChooseOneLoot.NO_SELECTION_MADE = -1
EA_Window_ChooseOneLoot.lootType = EA_Window_ChooseOneLoot.LOOT_TYPE_PQR_MYSTERY_BAG


-- OnInitialize Handler
function EA_Window_ChooseOneLoot.Initialize()        
  
    WindowRegisterEventHandler( "EA_Window_ChooseOneLoot", SystemData.Events.INTERACT_SHOW_PQ_LOOT, "EA_Window_ChooseOneLoot.HandlePQRLootUpdate")
    WindowRegisterEventHandler( "EA_Window_ChooseOneLoot", SystemData.Events.INTERACT_SHOW_ITEM_CONTAINER_LOOT, "EA_Window_ChooseOneLoot.HandleItemContainerLootUpdate")

    LabelSetText( "EA_Window_ChooseOneLootTitleBarText", GetString( StringTables.Default.LABEL_PQLOOT_REWARDS_TITLE ) )           
	LabelSetText( "EA_Window_ChooseOneLootText", GetString( StringTables.Default.LABEL_PQLOOT_REWARDS_INSTRUCTION ) )		
    ButtonSetText("EA_Window_ChooseOneLootAcceptButton", GetString( StringTables.Default.LABEL_ACCEPT ))       
    
    EA_Window_ChooseOneLoot.SelectItem( EA_Window_ChooseOneLoot.NO_SELECTION_MADE  )
end


-- OnShutdown Handler
function EA_Window_ChooseOneLoot.Shutdown()
    EA_Window_ChooseOneLoot.Hide()
end

function EA_Window_ChooseOneLoot.Hide()
    WindowSetShowing( "EA_Window_ChooseOneLoot", false )
end

function EA_Window_ChooseOneLoot.OnShown()

    WindowUtils.OnShown()
end

function EA_Window_ChooseOneLoot.OnHidden()

    -- Send the 'Loot Window Close' event
    BroadcastEvent (SystemData.Events.INTERACT_LOOT_CLOSE) 
    
    -- Clear the Selection
    EA_Window_ChooseOneLoot.SelectItem( EA_Window_ChooseOneLoot.NO_SELECTION_MADE  )    
    WindowUtils.OnHidden()  
end


function EA_Window_ChooseOneLoot.OnMouseOverItem()

    -- Convert the Row index to the item index
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local lootIndex = EA_Window_ChooseOneLootList.PopulatorIndices[ rowNum ]
	
	EA_Window_ChooseOneLoot.MouseOverItemIndex( lootIndex )
end

function EA_Window_ChooseOneLoot.MouseOverItemIndex( lootIndex )

	local item = EA_Window_ChooseOneLoot.lootData[lootIndex]
	if item ~= nil and item.id ~= 0 
	then
		Tooltips.CreateItemTooltip( item, SystemData.ActiveWindow.name , Tooltips.ANCHOR_WINDOW_LEFT )
	end
end


function EA_Window_ChooseOneLoot.OnButtonUpItem()

    -- Convert the Row index to the item index
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local lootIndex = EA_Window_ChooseOneLootList.PopulatorIndices[ rowNum ]
		
	EA_Window_ChooseOneLoot.SelectItem( lootIndex )
		
end

function EA_Window_ChooseOneLoot.SelectItem( lootIndex )

	EA_Window_ChooseOneLoot.currentlySelectedChoice = lootIndex
		
	ButtonSetDisabledFlag( "EA_Window_ChooseOneLootAcceptButton", EA_Window_ChooseOneLoot.currentlySelectedChoice < 1 )

    EA_Window_ChooseOneLoot.UpdateSelectedRow()
end

function EA_Window_ChooseOneLoot.LootAccepted()

	if EA_Window_ChooseOneLoot.currentlySelectedChoice ~= EA_Window_ChooseOneLoot.NO_SELECTION_MADE 
	then
	    if(EA_Window_ChooseOneLoot.lootType == EA_Window_ChooseOneLoot.LOOT_TYPE_PQR_MYSTERY_BAG)
	    then
		    PQLootItem( EA_Window_ChooseOneLoot.currentlySelectedChoice )
		elseif(EA_Window_ChooseOneLoot.lootType == EA_Window_ChooseOneLoot.LOOT_TYPE_ITEM_CONTAINER)
		then
		    ItemContainerLootItem( EA_Window_ChooseOneLoot.currentlySelectedChoice )
		end
		   
		EA_Window_ChooseOneLoot.Hide()
	end
end

function EA_Window_ChooseOneLoot.HandlePQRLootUpdate()

    EA_Window_ChooseOneLoot.lootType = EA_Window_ChooseOneLoot.LOOT_TYPE_PQR_MYSTERY_BAG
    EA_Window_ChooseOneLoot.UpdateLootData()
    
end

function EA_Window_ChooseOneLoot.HandleItemContainerLootUpdate()

    EA_Window_ChooseOneLoot.lootType = EA_Window_ChooseOneLoot.LOOT_TYPE_ITEM_CONTAINER
    EA_Window_ChooseOneLoot.UpdateLootData()
    
end

-- TODO: we should be able to reuse the functionality in EA_Window_Loot.UpdateLootData for most of this function
function EA_Window_ChooseOneLoot.UpdateLootData()		
	
	-- Update the ListBox with the new loot data
	EA_Window_ChooseOneLoot.lootData = GameData.InteractData.GetItemLootList()        
    EA_Window_ChooseOneLoot.lootDataDisplayOrder = {}
    
	for lootIndex, itemData in ipairs( EA_Window_ChooseOneLoot.lootData ) 
	do
	    table.insert( EA_Window_ChooseOneLoot.lootDataDisplayOrder, lootIndex )
	    	    
	    -- If this is the Money Reward, update the name; should only apply to PQR Mystery Bags
		if ( (itemData.id == 0) and (itemData.sellPrice > 0 ) )
		then		
			itemData.name = MoneyFrame.FormatMoneyString( itemData.sellPrice )
		end
	end   	
		
	ListBoxSetDisplayOrder("EA_Window_ChooseOneLootList", EA_Window_ChooseOneLoot.lootDataDisplayOrder )
        		
    -- Show the Window when it contains items
    WindowSetShowing( "EA_Window_ChooseOneLoot", EA_Window_ChooseOneLoot.lootDataDisplayOrder[1] ~= nil  )
	
end


function EA_Window_ChooseOneLoot.PopulateLootData()

    if (nil == EA_Window_ChooseOneLoot.lootData ) 
    then
        -- DEBUG(L"  No loot data!")
        return
    end
    
    if( nil == EA_Window_ChooseOneLootList.PopulatorIndices )
    then
        return
    end    
    
    EA_Window_ChooseOneLoot.UpdateSelectedRow()
    
    -- Setup the Custom formating for each row
    for row, lootIndex in ipairs( EA_Window_ChooseOneLootList.PopulatorIndices ) 
    do
        local itemData = EA_Window_ChooseOneLoot.lootData[lootIndex]
        
        local rowName   = "EA_Window_ChooseOneLootListRow"..row

        -- Color the Item based on rarity
		local color = DataUtils.GetItemRarityColor(itemData)
		LabelSetTextColor( rowName.."Name", color.r, color.g, color.b )
		
        -- Hide the stack count label if the stack count is less than 2
        local showStackCount = true
        if( itemData.stackCount < 2 )
        then
            showStackCount = false
        end
        WindowSetShowing( rowName.."StackCount", showStackCount )        
        
		-- Update the Row Background		
        local row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        DefaultColor.SetWindowTint( rowName.."Background", color )
        
        -- If the mouse is over this window, update the tooltip
        if( SystemData.MouseOverWindow.name == rowName )
        then
             EA_Window_ChooseOneLoot.MouseOverItemIndex( lootIndex )
        end
    end
    
end

function EA_Window_ChooseOneLoot.UpdateSelectedRow()

    if (nil == EA_Window_ChooseOneLoot.lootData ) 
    then
        -- DEBUG(L"  No loot data!")
        return
    end
    
    if( nil == EA_Window_ChooseOneLootList.PopulatorIndices )
    then
        return
    end
    
    -- Setup the Custom formating for each row
    for row, lootIndex in ipairs( EA_Window_ChooseOneLootList.PopulatorIndices ) 
    do    
        local selected = EA_Window_ChooseOneLoot.currentlySelectedChoice == lootIndex
        
        local rowName   = "EA_Window_ChooseOneLootListRow"..row

        ButtonSetPressedFlag(rowName, selected )
        ButtonSetStayDownFlag(rowName, selected )
    end
    
end