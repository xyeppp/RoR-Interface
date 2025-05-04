----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_Loot = {}

EA_Window_Loot.MAX_GROUP_MEMBER_BUTTONS = 6

EA_Window_Loot.TOOLTIP_ANCHOR = { Point = "topright",   RelativeTo = "EA_Window_Loot", RelativePoint = "topleft",   XOffset=5, YOffset=75 }


EA_Window_Loot.LOOT_RULES_MASTER = 3

EA_Window_Loot.curSlot = nil

-- Regular Loot Window Variables
EA_Window_Loot.lootData = nil
EA_Window_Loot.lootDataDisplayOrder = {}
EA_Window_Loot.NUM_VISIBLE_ROWS = 3

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

EA_Window_Loot.dropPending = false 

----------------------------------------------------------------
-- EA_Window_Loot Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_Loot.Initialize()        
     
	WindowRegisterEventHandler( "EA_Window_Loot", SystemData.Events.GROUP_SETTINGS_UPDATED, "EA_Window_Loot.UpdateGroupLootSettings")    
    WindowRegisterEventHandler( "EA_Window_Loot", SystemData.Events.INTERACT_SHOW_LOOT, "EA_Window_Loot.UpdateLootData")
    WindowRegisterEventHandler( "EA_Window_Loot", SystemData.Events.AUTO_LOOT, "EA_Window_Loot.OnLootAll")

    -- Label Text
    LabelSetText( "EA_Window_LootTitleBarText", GetString( StringTables.Default.LABEL_LOOT_NOUN) )       
    
    ButtonSetText("EA_Window_LootLootAllButton", GetString( StringTables.Default.LABEL_LOOT_ALL))

    EA_Window_Loot.UpdateGroupLootSettings()
    
end



function EA_Window_Loot.OnShown()
    WindowUtils.OnShown() 
end


-- OnShutdown Handler
function EA_Window_Loot.Shutdown()
    EA_Window_Loot.Hide()
end


function EA_Window_Loot.Hide()
    WindowSetShowing( "EA_Window_Loot", false )
end

function EA_Window_Loot.OnHidden()

    -- Send the 'Loot Window Close' event
    BroadcastEvent (SystemData.Events.INTERACT_LOOT_CLOSE);  

    WindowUtils.OnHidden()
end


function EA_Window_Loot.UpdateGroupLootSettings()

	-- Set the instructions text
	if( GameData.Player.Group.Settings.playerIsMasterLooter ) then
		LabelSetText( "EA_Window_LootText", GetString( StringTables.Default.TEXT_MASTER_LOOT_INSTRUCTIONS ) )
	else	
		LabelSetText( "EA_Window_LootText", GetString( StringTables.Default.TEXT_LOOT_INSTRUCTIONS ) )
	end

end


-- Standard Loot Window

function EA_Window_Loot.UpdateLootData()		
    
    -- Update the ListBox with the new loot data

    EA_Window_Loot.lootData = GameData.InteractData.GetLootList()
    EA_Window_Loot.lootDataDisplayOrder = {}
    
	for lootIndex, _ in ipairs( EA_Window_Loot.lootData ) 
	do
	    table.insert( EA_Window_Loot.lootDataDisplayOrder, lootIndex )
	end   	
	
    ListBoxSetDisplayOrder("EA_Window_LootList", EA_Window_Loot.lootDataDisplayOrder )
    	
    -- Show the Window when it contains items
    WindowSetShowing( "EA_Window_Loot", EA_Window_Loot.lootDataDisplayOrder[1] ~= nil  )
    
    local lootAllItemsExist = EA_Window_Loot.IsLootAllApplicable()
	-- Hide the Loot All Button when there's nothing to auto loot
	WindowSetShowing("EA_Window_LootLootAllButton", lootAllItemsExist )
end

function EA_Window_Loot.PopulateLootData()

    if (nil == EA_Window_Loot.lootData ) 
    then
        -- DEBUG(L"  No loot data!")
    end
    
    -- Setup the Custom formating for each row
    for row, data in ipairs( EA_Window_LootList.PopulatorIndices ) 
    do
        local itemData = EA_Window_Loot.lootData[data]
        
        local rowName   = "EA_Window_LootListRow"..row

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
             EA_Window_Loot.MouseOverItemIndex( lootIndex )
        end
    end
end

function EA_Window_Loot.OnMouseOverItem()

    -- Convert the Row index to the item index
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local lootIndex = EA_Window_LootList.PopulatorIndices[ rowNum ]
	
	EA_Window_Loot.MouseOverItemIndex( lootIndex )
end

function EA_Window_Loot.MouseOverItemIndex( index )

	local item = EA_Window_Loot.lootData[index]
	if item ~= nil and item.id ~= 0 
	then
		Tooltips.CreateItemTooltip( item, SystemData.ActiveWindow.name , Tooltips.ANCHOR_WINDOW_LEFT )
	end
end


function EA_Window_Loot.WarnBindOnPickUp( lootIndex )

    local item = EA_Window_Loot.lootData[lootIndex]
    if( item.flags[GameData.Item.EITEMFLAG_BIND_ON_PICKUP] and item.flags[GameData.Item.EITEMFLAG_BROKEN] == false )
    then
        EA_Window_Loot.slotToLoot = lootIndex
        DialogManager.MakeTwoButtonDialog( GetString(StringTables.Default.TEXT_LOOT_BIND_ON_PICK_UP_CONFIRMATION), 
                                           GetString(StringTables.Default.LABEL_YES), EA_Window_Loot.OnLootBindOnPickUpItem, 
                                           GetString(StringTables.Default.LABEL_NO) )
        return true
    end
    
    return false
end

function EA_Window_Loot.OnLootItem()

    -- Convert the Row index to the item index
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local lootIndex = EA_Window_LootList.PopulatorIndices[ rowNum ]
	
    if( EA_Window_Loot.WarnBindOnPickUp( lootIndex ) )
    then
        return
    end
    LootItem( lootIndex )
end

function EA_Window_Loot.OnLootBindOnPickUpItem()
    if( EA_Window_Loot.slotToLoot )
    then
        LootItem( EA_Window_Loot.slotToLoot )
        EA_Window_Loot.slotToLoot = nil
    end
end

-- Returns 2 bools, first indicating whether anything will be looted by auto loot,
-- the second indicating if any of those items are BOP
function EA_Window_Loot.IsLootAllApplicable()
	if( EA_Window_Loot.lootData == nil )
	then
	    return false, false
	end

    local lootAllItemsExist = false
    local warnBOP = false
	for lootIndex, itemData in ipairs( EA_Window_Loot.lootData )
	do
    	-- Special case for master looting...
    	-- Don't warn about things at or above threshold, as we won't be looting them anyway
    	if( (GameData.Player.Group.Settings.playerIsMasterLooter == true and itemData.rarity < GameData.Player.Group.Settings.lootThreshold)
            or GameData.Player.Group.Settings.playerIsMasterLooter == false )
    	then
    	    if( itemData.flags[GameData.Item.EITEMFLAG_BIND_ON_PICKUP] == true and itemData.flags[GameData.Item.EITEMFLAG_BROKEN] == false )
            then
                warnBOP = true
            end
            lootAllItemsExist = true
        end
    end
    
    return lootAllItemsExist, warnBOP
end

function EA_Window_Loot.OnLootAll()

    local lootAllItemsExist, warnBOP = EA_Window_Loot.IsLootAllApplicable()
    
	-- Hide the Loot All Button when there's nothing to auto loot
	WindowSetShowing("EA_Window_LootLootAllButton", lootAllItemsExist )
    
    if( warnBOP )
    then
        DialogManager.MakeTwoButtonDialog( GetString(StringTables.Default.TEXT_LOOT_ALL_BIND_ON_PICK_UP_CONFIRMATION),
                                           GetString(StringTables.Default.LABEL_YES), EA_Window_Loot.OnLootAllBindOnPickUpItems,
                                           GetString(StringTables.Default.LABEL_NO) )
        return
    end
    
    EA_Window_Loot.OnLootAllBindOnPickUpItems()
end

function EA_Window_Loot.OnLootAllBindOnPickUpItems()
	if( EA_Window_Loot.lootData == nil )
	then
	    return
	end

    -- If the master looter auto-looted, only grab the stuff below threshold
    if( GameData.Player.Group.Settings.playerIsMasterLooter == true )
    then
    	for lootIndex, itemData in ipairs( EA_Window_Loot.lootData )
    	do
            if( itemData.rarity < GameData.Player.Group.Settings.lootThreshold )
            then
                LootItem( lootIndex )
            end
        end
    else
        LootAllItems()
    end
end

function EA_Window_Loot.OnButtonUpItem()

    -- Convert the Row index to the item index
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local lootIndex = EA_Window_LootList.PopulatorIndices[ rowNum ]
		
	-- Place the item on the cursor for dragging
    local item = EA_Window_Loot.lootData[lootIndex]
	if( GameData.Player.Group.Settings.playerIsMasterLooter == true and item and item.rarity >= GameData.Player.Group.Settings.lootThreshold ) then
	
		EA_Window_Loot.curSlot = lootIndex
		
		local function MakeCallBack( name )
		    return function() EA_Window_Loot.OnSelectGroupMember( name ) end
		end
		
		EA_Window_ContextMenu.CreateContextMenu( SystemData.ActiveWindow.name, EA_Window_ContextMenu.CONTEXT_MENU_1 )
		--buttonText, callbackFunction, bDisabled, bCloseAfterClick, contextMenuNumber
		if( not IsWarBandActive() )
		then
		    EA_Window_ContextMenu.AddMenuItem(  GameData.Player.name,
		                                        MakeCallBack( GameData.Player.name ),
		                                        false, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
		                                       
			for index = 1, EA_Window_Loot.MAX_GROUP_MEMBER_BUTTONS-1 do
		        if ( GroupWindow.groupData and
		             GroupWindow.groupData[index] and
		             GroupWindow.groupData[index].name and
		             GroupWindow.groupData[index].name ~= L"" )
		        then
		            EA_Window_ContextMenu.AddMenuItem(  GroupWindow.groupData[index].name,
		                                                MakeCallBack( GroupWindow.groupData[index].name ),
		                                                false, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
		        end
	        end
	    else
            local warband = PartyUtils.GetWarbandData()
            for groupIndex, group in ipairs( warband )
            do
                for memberIndex, member in ipairs( group.players )
                do
                    EA_Window_ContextMenu.AddMenuItem(  member.name,
		                                                MakeCallBack( member.name ),
		                                                false, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
                end
            end
	    end
	    EA_Window_ContextMenu.Finalize()

		
	else
	    if( EA_Window_Loot.WarnBindOnPickUp( lootIndex ) )
        then
            return
        end
		LootItem( lootIndex )
	end

end

function EA_Window_Loot.OnMouseOverGroupMember()

	-- Does the player have a loot item on the cursor?
	if( Cursor.IconOnCursor() and ( Cursor.Data.Source == Cursor.SOURCE_LOOT ) ) 
	then	
			
		local itemData = EA_Window_Loot.lootData[EA_Window_Loot.curSlot]
		
		local playerName = ButtonGetText( SystemData.ActiveWindow.name )
		
		local text = L"Give "..itemData.name..L" to "..playerName
		
		Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
		--Tooltips.SetTooltipText( 1, 1, line1)
		--Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
		--Tooltips.SetTooltipText( 2, 1, line2)
		--Tooltips.Finalize()    
		Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
	
	end	
end

function EA_Window_Loot.OnSelectGroupMember( name )
	if( EA_Window_Loot.curSlot ~= nil ) 
	then
		-- Give the item to the player
		AssignLootItem( EA_Window_Loot.curSlot, name )	
	end	
end

