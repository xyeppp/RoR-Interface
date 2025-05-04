----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_Claim = {}

EA_Window_Claim.TOOLTIP_ANCHOR = { Point = "topright",   RelativeTo = "EA_Window_Claim", RelativePoint = "topleft",   XOffset=5, YOffset=75 }

EA_Window_Claim.lootData = nil
EA_Window_Claim.lootDataDisplayOrder = {}
EA_Window_Claim.NO_SELECTION_MADE = -1

-- These statuses should match the ERewardStatus enum in
-- CharacterConsts.h
EA_Window_Claim.REWARD_STATUS_NOT_RECEIVED = 0
EA_Window_Claim.REWARD_STATUS_SENT_MAIL = 1
EA_Window_Claim.REWARD_STATUS_ERROR_SENDING = 2
EA_Window_Claim.REWARD_STATUS_NOT_ELIGIBLE = 3
EA_Window_Claim.REWARD_STATUS_CLAIMED = 4
EA_Window_Claim.REWARD_HAS_REMAINING_QUANTITY = 5
EA_Window_Claim.REWARD_NEEDS_MORE_QUANTITY = 6

-- OnInitialize Handler
function EA_Window_Claim.Initialize()        
  
    WindowRegisterEventHandler( "EA_Window_Claim", SystemData.Events.INTERACT_SHOW_CLAIM_WINDOW, "EA_Window_Claim.HandleRewardListUpdate")

    LabelSetText( "EA_Window_ClaimTitleBarText", GetString( StringTables.Default.LABEL_ACCOUNT_ENTITLEMENTS_TITLE ) )           
	LabelSetText( "EA_Window_ClaimText", GetString( StringTables.Default.LABEL_ACCOUNT_ENTITLEMENTS_INSTRUCTIONS ) )        
	LabelSetText( "EA_Window_ClaimResetText", GetString( StringTables.Default.LABEL_ACCOUNT_ENTITLEMENTS_RESET_INSTRUCTIONS ) )			
    ButtonSetText("EA_Window_ClaimAcceptButton", GetString( StringTables.Default.LABEL_CLAIM ))     	
    ButtonSetText("EA_Window_ClaimResetButton", GetString( StringTables.Default.LABEL_RESET_REWARD )) 
    
    -- Hide the Reset button until an item that can use it is selected
    WindowSetShowing("EA_Window_ClaimResetButton", false)        
    
    EA_Window_Claim.SelectItem( EA_Window_Claim.NO_SELECTION_MADE  )
end


-- OnShutdown Handler
function EA_Window_Claim.Shutdown()
    EA_Window_Claim.Hide()
end

function EA_Window_Claim.Hide()
    WindowSetShowing( "EA_Window_Claim", false )
end

function EA_Window_Claim.OnShown()

    WindowUtils.OnShown()
end

function EA_Window_Claim.OnHidden()

    -- Send the 'Loot Window Close' event
    BroadcastEvent (SystemData.Events.INTERACT_LOOT_CLOSE) 
    
    -- Clear the Selection
    WindowSetShowing("EA_Window_ClaimResetButton", false)
    EA_Window_Claim.SelectItem( EA_Window_Claim.NO_SELECTION_MADE  )    
    WindowUtils.OnHidden()  
end


function EA_Window_Claim.OnMouseOverItem()

    -- Convert the Row index to the item index
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local lootIndex = EA_Window_ClaimList.PopulatorIndices[ rowNum ]
	
	EA_Window_Claim.MouseOverItemIndex( lootIndex )
end

function EA_Window_Claim.MouseOverItemIndex( lootIndex )

	local item = EA_Window_Claim.lootData[lootIndex]
	if item ~= nil and item.id ~= 0 
	then
	    local resetTextColor = DefaultColor.RED
	    local resetText = GetString( StringTables.Default.LABEL_CLAIM_TOOLTIP_CANNOT_RESET )
	    if(item.rewardCanReset)
	    then
	        resetTextColor = DefaultColor.GREEN
	        resetText = GetString( StringTables.Default.LABEL_CLAIM_TOOLTIP_CAN_BE_RESET )
	    end
	    
		Tooltips.CreateItemTooltip( item, SystemData.ActiveWindow.name , Tooltips.ANCHOR_WINDOW_LEFT, true, resetText, resetTextColor )
	end
end


function EA_Window_Claim.OnButtonUpItem()

    -- Convert the Row index to the item index
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local lootIndex = EA_Window_ClaimList.PopulatorIndices[ rowNum ]
		
	EA_Window_Claim.SelectItem( lootIndex )
		
end

function EA_Window_Claim.SelectItem( lootIndex )

	EA_Window_Claim.currentlySelectedChoice = lootIndex
		
    if ( EA_Window_Claim.currentlySelectedChoice < 1 )
    then
        ButtonSetDisabledFlag( "EA_Window_ClaimAcceptButton", true )
        ButtonSetPressedFlag( "EA_Window_ClaimAcceptButton", false )
    else
        ButtonSetDisabledFlag( "EA_Window_ClaimAcceptButton", false )
    end

    EA_Window_Claim.UpdateSelectedRow()
end

function EA_Window_Claim.ClaimReward()

	if EA_Window_Claim.currentlySelectedChoice ~= EA_Window_Claim.NO_SELECTION_MADE 
	then
	    ClaimMarketingReward( EA_Window_Claim.currentlySelectedChoice )		  		
	end
	
end

function EA_Window_Claim.ResetReward()

	if EA_Window_Claim.currentlySelectedChoice ~= EA_Window_Claim.NO_SELECTION_MADE 
	then
	    ResetMarketingReward( EA_Window_Claim.currentlySelectedChoice )		  		
	end
	
end

function EA_Window_Claim.HandleRewardListUpdate()

    EA_Window_Claim.UpdateRewardData()
    
end

function EA_Window_Claim.UpdateRewardData()		
	
	-- Update the ListBox with the new reward data (stored in a loot data struct)
	EA_Window_Claim.lootData = GameData.InteractData.GetClaimWindowList()        
    EA_Window_Claim.lootDataDisplayOrder = {}
    
	for lootIndex, itemData in ipairs( EA_Window_Claim.lootData ) 
	do
	    table.insert( EA_Window_Claim.lootDataDisplayOrder, lootIndex )
	end   	
		
	ListBoxSetDisplayOrder("EA_Window_ClaimList", EA_Window_Claim.lootDataDisplayOrder )
        		
    -- Show the Window when it contains items
    WindowSetShowing( "EA_Window_Claim", EA_Window_Claim.lootDataDisplayOrder[1] ~= nil  )
	
end


function EA_Window_Claim.PopulateLootData()

    if (nil == EA_Window_Claim.lootData ) 
    then
        -- DEBUG(L"  No loot data!")
        return
    end
    
    if( nil == EA_Window_ClaimList.PopulatorIndices )
    then
        return
    end    
    
    EA_Window_Claim.UpdateSelectedRow()
    
    -- Setup the Custom formating for each row
    for row, lootIndex in ipairs( EA_Window_ClaimList.PopulatorIndices ) 
    do
        local itemData = EA_Window_Claim.lootData[lootIndex]
        
        local rowName   = "EA_Window_ClaimListRow"..row      
        
		-- Update the Row Background		
        local row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        DefaultColor.SetWindowTint( rowName.."Background", color )
        
        -- Update the reward status		
		local statusText = GetString( StringTables.Default.LABEL_CLAIM_STATUS_CLAIMED )
		local statusColor = DefaultColor.RED
		if( itemData.rewardStatus == EA_Window_Claim.REWARD_STATUS_NOT_RECEIVED or
		    itemData.rewardStatus == EA_Window_Claim.REWARD_STATUS_ERROR_SENDING or
		    itemData.rewardStatus == EA_Window_Claim.REWARD_STATUS_NOT_RECEIVED or
		    itemData.rewardStatus == EA_Window_Claim.REWARD_HAS_QUANTITY_REMAINING )
		then
		    statusText = GetString( StringTables.Default.LABEL_CLAIM_STATUS_AVAILABLE )
		    statusColor = DefaultColor.GREEN
		end
		
		if( itemData.rewardStatus == EA_Window_Claim.REWARD_NEEDS_MORE_QUANTITY )
		then
		    statusText = GetString( StringTables.Default.LABEL_CLAIM_STATUS_NEEDS_MORE_QUANTITY )
		    statusColor = DefaultColor.YELLOW
		end
		
		LabelSetTextColor( rowName.."RewardStatus", statusColor.r, statusColor.g, statusColor.b )
        LabelSetText( rowName.."RewardStatus", statusText)
        
        LabelSetText( rowName.."RewardSubject", itemData.rewardSubject )
        
        -- If the mouse is over this window, update the tooltip
        if( SystemData.MouseOverWindow.name == rowName )
        then
             EA_Window_Claim.MouseOverItemIndex( lootIndex )
        end
    end
    
end

function EA_Window_Claim.UpdateSelectedRow()

    if (nil == EA_Window_Claim.lootData ) 
    then
        -- DEBUG(L"  No loot data!")
        return
    end
    
    if( nil == EA_Window_ClaimList.PopulatorIndices )
    then
        return
    end
    
    -- Setup the Custom formating for each row
    for row, lootIndex in ipairs( EA_Window_ClaimList.PopulatorIndices ) 
    do    
        local selected = EA_Window_Claim.currentlySelectedChoice == lootIndex
        
        local rowName   = "EA_Window_ClaimListRow"..row

        ButtonSetPressedFlag(rowName, selected )
        ButtonSetStayDownFlag(rowName, selected )
    end
    
    -- Toggle the Claim button based on the reward status of the selected item
    local itemData = EA_Window_Claim.lootData[EA_Window_Claim.currentlySelectedChoice]
    if(itemData ~= nil)
    then
    
        -- Is this an item that can still be claimed?
        if(itemData.rewardStatus == EA_Window_Claim.REWARD_STATUS_NOT_ELIGIBLE or
           itemData.rewardStatus == EA_Window_Claim.REWARD_STATUS_SENT_MAIL or
           itemData.rewardStatus == EA_Window_Claim.REWARD_STATUS_CLAIMED or
           itemData.rewardStatus == EA_Window_Claim.REWARD_NEEDS_MORE_QUANTITY)
        then
            ButtonSetDisabledFlag("EA_Window_ClaimAcceptButton", true)
            ButtonSetPressedFlag( "EA_Window_ClaimAcceptButton", false )
        else
            ButtonSetDisabledFlag("EA_Window_ClaimAcceptButton", false)
        end
        
        -- Can this item be reset by the player?
        if(itemData.rewardCanReset == true)
        then
            WindowSetShowing("EA_Window_ClaimResetButton", true)
        else
            WindowSetShowing("EA_Window_ClaimResetButton", false)
        end
        
    end
    
end