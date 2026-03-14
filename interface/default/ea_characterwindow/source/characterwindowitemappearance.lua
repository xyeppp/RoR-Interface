local function IsForSameEquipSlot( sourceSlot, source, targetEquipSlot )
    local sourceEquipData = DataUtils.GetItemData( source, sourceSlot )
    
    return sourceEquipData.equipSlot == targetEquipSlot or
			((sourceEquipData.equipSlot == GameData.EquipSlots.RIGHT_HAND or sourceEquipData.equipSlot == GameData.EquipSlots.EITHER_HAND) and (targetEquipSlot == GameData.EquipSlots.RIGHT_HAND or targetEquipSlot == GameData.EquipSlots.EITHER_HAND)) or
			((sourceEquipData.equipSlot == GameData.EquipSlots.LEFT_HAND or sourceEquipData.equipSlot == GameData.EquipSlots.EITHER_HAND) and (targetEquipSlot == GameData.EquipSlots.LEFT_HAND or targetEquipSlot == GameData.EquipSlots.EITHER_HAND))
end

function CharacterWindow.PrintError( stringId, itemName )
    local errorString
    if( itemName and itemName ~= L"" )
    then
        errorString = GetStringFormat( stringId, {itemName} )
    else
        errorString = GetString( stringId )
    end
    EA_ChatWindow.Print( errorString, SystemData.ChatLogFilters.SAY )
end

function CharacterWindow.UpdateItemAppearanceMode()
    if( CharacterWindow.mode == CharacterWindow.MODE_ITEM_APPEARANCE )
    then
        ButtonSetPressedFlag( "CharacterWindowContentsAppearanceModeButton", true )
        WindowSetShowing( "CharacterWindowContentsAppearanceMode", true )
    else
        ButtonSetPressedFlag( "CharacterWindowContentsAppearanceModeButton", false )
    end
    
    CharacterWindow.UpdateSlotIcons()
end

function CharacterWindow.OnLButtonUpAppearanceMode()
    EA_LabelCheckButton.Toggle()
    
    local mode = CharacterWindow.MODE_NORMAL
    if( EA_LabelCheckButton.IsChecked() )
    then
        mode = CharacterWindow.MODE_ITEM_APPEARANCE
    end
    
    CharacterWindow.UpdateMode( mode )
end

function CharacterWindow.MouseOverAppearanceCheckBox()
    Tooltips.CreateTextOnlyTooltip( "CharacterWindowContentsAppearanceMode", nil )
    Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.TOOLTIP_ITEM_APPEARANCE_CHECK_BOX ) )
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_BOTTOM )
end

function CharacterWindow.OnLButtonDownItemAppearance( flags )

end

function CharacterWindow.ApplyItemAppearanceToSlot( source, sourceSlot, slot )
    local sourceAppearanceData = DataUtils.GetItemData( source, sourceSlot )
	if( DataUtils.IsItemAppearanceCustomizable( slot, CharacterWindow.equipmentData[slot] ) and not (source == Cursor.SOURCE_EQUIPMENT) and DataUtils.IsItemAppearanceCustomizable( slot, sourceAppearanceData ) )
    then
        if( IsForSameEquipSlot( sourceSlot, source, CharacterWindow.equipmentData[slot].equipSlot ) )
        then
            local function ApplyItemAppearance()
                -- Try to customize the item in the slot
                SendCustomizeItemIcon( slot, sourceSlot, source )
            end

			
			
			if( sourceAppearanceData.flags[GameData.Item.EITEMFLAG_BIND_ON_EQUIP] and not sourceAppearanceData.boundToPlayer )
			then
			    dialogString = GetString( StringTables.Default.DIALOG_TEXT_APPLY_BOE_ITEM_APPEARANCE )
			else
			    dialogString = GetString( StringTables.Default.DIALOG_TEXT_APPLY_ITEM_APPEARANCE )
			end
			
			DialogManager.MakeTwoButtonDialog( dialogString, 
						                       GetString( StringTables.Default.LABEL_YES ),
						                       ApplyItemAppearance,
						                       GetString( StringTables.Default.LABEL_NO ),
						                       nil )
        else
            -- Display Error!
            CharacterWindow.PrintError( StringTables.Default.ERROR_TEXT_ITEM_APPEARANCE_MISMATCHING_EQUIP_SLOT, CharacterWindow.equipmentData[slot].name )
        end
    else
        local stringId, itemName
		if( not DataUtils.IsItemSlotCustomizable(slot) )
		then
		    stringId = StringTables.Default.ERROR_TEXT_ITEM_APPEARANCE_NEVER_CUSTOMIZED
			itemName = ItemSlots[slot].name
        elseif( not CharacterWindow.equipmentData[slot] or not CharacterWindow.equipmentData[slot].name or CharacterWindow.equipmentData[slot].name == L"" )
        then
            stringId = StringTables.Default.ERROR_TEXT_ITEM_APPEARANCE_EMPTY_SLOT
        elseif( source == Cursor.SOURCE_EQUIPMENT )
		then
		    stringId = StringTables.Default.ERROR_TEXT_CANNOT_USE_ITEM_EQUIPPED
		elseif( not DataUtils.IsItemAppearanceCustomizable( slot, sourceAppearanceData ) )
		then
			stringId = StringTables.Default.ERROR_TEXT_CANNOT_USE_ITEM_FOR_APPERANCE
			itemName = sourceAppearanceData.name
		else
            stringId = StringTables.Default.ERROR_TEXT_ITEM_APPEARANCE_CANNOT_BE_CUSTOMIZED
            itemName = CharacterWindow.equipmentData[slot].name
        end
        
        -- Display Error!
        CharacterWindow.PrintError( stringId, itemName )
    end
end

function CharacterWindow.OnLButtonUpItemAppearance( flags )
    local slot = WindowGetId( SystemData.ActiveWindow.name )
    CharacterWindow.ApplyItemAppearanceToSlot( Cursor.Data.Source, Cursor.Data.SourceSlot, slot )
    Cursor.Clear()
end

function CharacterWindow.OnRButtonUpItemAppearance( flags )
    local slot = WindowGetId( SystemData.ActiveWindow.name )
    if( CharacterWindow.equipmentData[slot] and CharacterWindow.equipmentData[slot].customizedIconNum ~= 0 )
    then
        local function RemoveItemAppearance()
            -- Try to remove the item's customized icon
            SendCustomizeItemIcon( slot, 0, 0 )
        end
        
        DialogManager.MakeTwoButtonDialog( GetString( StringTables.Default.DIALOG_TEXT_REMOVE_ITEM_APPEARANCE ), 
									       GetString( StringTables.Default.LABEL_YES ),
									       RemoveItemAppearance,
									       GetString( StringTables.Default.LABEL_NO ),
									       nil )
    end
end
