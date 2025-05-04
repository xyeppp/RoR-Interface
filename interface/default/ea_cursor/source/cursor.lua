----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

function NewCursorData()
    return { Source = 0, SourceSlot = 0, ObjectId = 0, IconId = 0, StackAmount = 0 }
end

--This is used for Targeting, If player right clicks an item, and it can be used to target another
--object in there inventory, this stores the source location of the targeted object
function NewTargetData()
    return { Source = 0, SourceSlot = 0, TargetMapId = 0, CursorIconId = 0, TargetLoc = 0, TargetSlot = 0 }
end

Cursor = {}
Cursor.Data = nil
Cursor.PendingData = nil
Cursor.PickupTimer = 0
Cursor.PICKUP_TIME = 0.01 -- Seconds -- not sure why this was set to 3 seconds previously -jmahar
Cursor.LButtonDown = false
Cursor.PickupWindow = ""

Cursor.TargetData = nil
Cursor.UseItemTargeting = false

-- Cursor Object Sources
Cursor.SOURCE_ACTION_LIST   		= 1
Cursor.SOURCE_EQUIPMENT     		= GameData.ItemLocs.EQUIPPED
Cursor.SOURCE_INVENTORY     		= GameData.ItemLocs.INVENTORY
Cursor.SOURCE_BANK          		= GameData.ItemLocs.BANK 
Cursor.SOURCE_TACTICS_LIST  		= 5
Cursor.SOURCE_MACRO         		= 6
Cursor.SOURCE_MORALE_LIST   		= 7
Cursor.SOURCE_LOOT          		= 8
Cursor.SOURCE_QUEST_ITEM    		= GameData.ItemLocs.QUEST_ITEM
Cursor.SOURCE_CRAFTING      		= 10
Cursor.SOURCE_MERCHANT      		= 11
Cursor.SOURCE_INVENTORY_OVERFLOW	= GameData.ItemLocs.INVENTORY_OVERFLOW
Cursor.SOURCE_CRAFTING_ITEM			= GameData.ItemLocs.CRAFTING_ITEM
Cursor.SOURCE_CURRENCY_ITEM			= GameData.ItemLocs.CURRENCY_ITEM
Cursor.SOURCE_GUILD_VAULT1			= 101
Cursor.SOURCE_GUILD_VAULT2			= 102
Cursor.SOURCE_GUILD_VAULT3			= 103
Cursor.SOURCE_GUILD_VAULT4			= 104
Cursor.SOURCE_GUILD_VAULT5			= 105

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local DIALOGID_DESTROY_ITEM = DialogManager.CreateDialogId()

----------------------------------------------------------------
-- Functions Variables
----------------------------------------------------------------

function Cursor.Initialize()

    WindowRegisterEventHandler( "Root", SystemData.Events.L_BUTTON_DOWN_PROCESSED, "Cursor.OnLButtonDownProcessed") 
    WindowRegisterEventHandler( "Root", SystemData.Events.L_BUTTON_UP_PROCESSED, "Cursor.OnLButtonUpProcessed")    
    WindowRegisterEventHandler( "Root", SystemData.Events.R_BUTTON_DOWN_PROCESSED, "Cursor.OnRButtonDownProcessed")
    
end

function Cursor.Shutdown()
    WindowUnregisterEventHandler ("Root", SystemData.Events.L_BUTTON_DOWN_PROCESSED) 
    WindowUnregisterEventHandler ("Root", SystemData.Events.L_BUTTON_UP_PROCESSED)    
    WindowUnregisterEventHandler ("Root", SystemData.Events.R_BUTTON_DOWN_PROCESSED)
    
    Cursor.ClearTargetingData()
end

function Cursor.IconOnCursor()
    if( Cursor.Data ~= nil ) then
        return true
    end

    return false
end

Cursor.AUTO_PICKUP_ON_LBUTTON_UP    = true
Cursor.NO_AUTO_PICKUP               = false

function Cursor.PickUp( objectSource, sourceSlot, objectId, iconId, autoOnLButtonUp, stackAmount )

   -- DEBUG( L"Setting Pending Cursor Data: Source = "..objectSource..L" SourceSlot = "..sourceSlot..L" ObjectId = "..objectId..L" IconId = "..iconId )
        
    Cursor.PendingData = NewCursorData()

    Cursor.PendingData.Source     = objectSource
    Cursor.PendingData.SourceSlot = sourceSlot

    Cursor.PendingData.ObjectId   = objectId
    
    Cursor.PendingData.IconId     = iconId    
    
    if(stackAmount ~= nil) then
        Cursor.PendingData.StackAmount = stackAmount 
    end 

    Cursor.PickupTimer            = Cursor.PICKUP_TIME  
    Cursor.PickupWindow           = SystemData.ActiveWindow.name
    Cursor.AutoOnLButtonUp        = autoOnLButtonUp

    Sound.Play( Sound.ICON_PICKUP ) 
end


function Cursor.Drop( dynamicImg )

    --DEBUG( L"Dropping Icon on "..StringToWString(dynamicImg) )

    if( Cursor.Data ~= nil and dynamicImg ~= nil ) then
    
        local texture, x, y = GetIconData( Cursor.Data.IconId )
        DynamicImageSetTexture( dynamicImg, texture, x, y )
    end
    
    Cursor.Clear()

    Sound.Play( Sound.ICON_DROP )
end

function Cursor.Clear( shouldRepressSound )
	
	-- default to false if not provided
	shouldRepressSound = shouldRepressSound or false
	
    if( Cursor.IconOnCursor() or Cursor.PendingData ~= nil or Cursor.TargetData ~= nil) then
        Cursor.Data = nil
        Cursor.PendingData = nil
        Cursor.ClearTargetingData()
        ClearCursor() 
        
        -- clear any existing item deletion dialog boxes
        DialogManager.OnRemoveDialog(DIALOGID_DESTROY_ITEM)

		if not shouldRepressSound then
			Sound.Play( Sound.ICON_CLEAR )
		end
    end
    SetItemDragging(false)
end

function Cursor.LoadPendingData()
    Cursor.Data = Cursor.PendingData
    Cursor.PendingData = nil    

    if( Cursor.Data.IconId ) then   
        local texture, x, y = GetIconData( Cursor.Data.IconId )
        SetCursor( texture )
        
        SetItemDragging(true)
    end  
end


function Cursor.OnLButtonDownProcessed()
    Cursor.LButtonDown = true
    -- DEBUGGING STUFF
    --[[
    local windowName = StringToWString (SystemData.MouseOverWindow.name)
    local mX, mY = SystemData.MousePosition.x, SystemData.MousePosition.y
    local winId = WindowGetId (SystemData.MouseOverWindow.name)
    
    DEBUG(L"MouseoverWindow = "..windowName..L"(id: "..winId..L") at mouse ("..SystemData.MousePosition.x..L", "..SystemData.MousePosition.y..L")")
	--]]
    -- END DEBUGGING STUFF
    
    if( Cursor.Data ~= nil and SystemData.MouseOverWindow.name == "Root" )  then
        -- If this is an item on the cursor, attempt to drop it.
        
		local itemData = DataUtils.GetItemData( Cursor.Data.Source, Cursor.Data.SourceSlot )
    
        if DataUtils.IsValidItem( itemData ) then
            if ( Cursor.Data ~= nil )
            then
                -- clear any existing item deletion dialog boxes
                DialogManager.OnRemoveDialog(DIALOGID_DESTROY_ITEM)
            end
			local text = GetStringFormat (StringTables.Default.LABEL_TEXT_DESTROY_ITEM_CONFIRM, { itemData.name } )
			DialogManager.MakeTwoButtonDialog( text, GetString( StringTables.Default.LABEL_YES ),Cursor.DoDestroyItem, GetString( StringTables.Default.LABEL_NO ), nil, 
                                                nil, nil, nil, nil, nil, DIALOGID_DESTROY_ITEM )
		end
    end
    
    --Need to clear cursor target data, if they clicked outside on the root window
    if( Cursor.TargetData ~= nil and SystemData.MouseOverWindow.name == "Root" )  then
        Cursor.ClearTargetingData()
    end
    
end

function Cursor.OnLButtonUpProcessed()
    Cursor.LButtonDown = false
    -- Move the pending data to the cursor if the auto pickup is set
    if( (Cursor.Data == nil) and (Cursor.PendingData ~= nil) and (Cursor.AutoOnLButtonUp == true )) then    
        Cursor.LoadPendingData() 
    elseif( Cursor.PendingData ~= nil)  then
		Cursor.Clear()
    end
end

function Cursor.DoDestroyItem()
    if( Cursor.Data.Source == Cursor.SOURCE_EQUIPMENT or 
		Cursor.Data.Source == Cursor.SOURCE_BANK or 
		Cursor.Data.Source == Cursor.SOURCE_INVENTORY or
        Cursor.Data.Source == Cursor.SOURCE_CRAFTING_ITEM or
        Cursor.Data.Source == Cursor.SOURCE_CURRENCY_ITEM or
		Cursor.Data.Source == Cursor.SOURCE_INVENTORY_OVERFLOW or  
		Cursor.Data.Source == Cursor.SOURCE_QUEST_ITEM ) then
        DestroyItem( Cursor.Data.Source, Cursor.Data.SourceSlot )
		Cursor.Clear()
    end
end

function Cursor.OnRButtonDownProcessed()
--	DEBUG(L"[Cursor.OnRButtonDownProcessed]")

	-- If the source of the Cursor icon is the Guild Vault, we need to send a msg to the server to unlock the slot
	if( Cursor.Data~= nil and Cursor.Data~= nil and 
		Cursor.Data.Source >= Cursor.SOURCE_GUILD_VAULT1 and Cursor.Data.Source <= Cursor.SOURCE_GUILD_VAULT5 ) 
	then
		GuildVaultWindow.ClearUnlock(Cursor.Data.Source, Cursor.Data.SourceSlot)	
	end

	Cursor.Clear()
end

function Cursor.Update( timePassed )
    
    --DEBUG( L"Cursor Update" )
    
    -- Place the pending data on the cursor if...
    -- 1) The cursor has moved off the source window or
    -- 2) More than 3 seconds have passed with the mouse down
    
    --local text
    --
    
    --[[
    local pendingData = L"false"
    local data = L"false"
    local lButtonDown = L"false"
    if( Cursor.Data ~= nil) then data = L"true" end
    if( Cursor.PendingData ~= nil) then pendingData = L"true" end
    if( Cursor.LButtonDown == true) then lButtonDown = L"true" end
    
    DEBUG( L"Data = "..data..L",  PendingData = "..pendingData..L", PickupWindow = "..StringToWString(Cursor.PickupWindow)..L", MouseOver Window = "..StringToWString(SystemData.MouseOverWindow.name)..L", LButtonDown = "..lButtonDown  )
    --]] 
        
    if( (Cursor.Data == nil) and (Cursor.PendingData ~= nil) and (Cursor.LButtonDown == true) ) then
            
        Cursor.PickupTimer = Cursor.PickupTimer - timePassed
            
        if( (SystemData.MouseOverWindow.name ~= Cursor.PickupWindow) or (Cursor.PickupTimer <= 0) ) then
           -- DEBUG( L"Picking Up Icon, timer ="..Cursor.PickupTimer..L" mouseoverWindow = "..SystemData.MouseOverWindow.name )
            Cursor.LoadPendingData()         
        end     
    
    end
end


function Cursor.StartTargetingRUp( objectSource, sourceSlot, targetMapId )
    Cursor.TargetData = NewTargetData()

    Cursor.TargetData.Source     = objectSource
    Cursor.TargetData.SourceSlot = sourceSlot

    Cursor.TargetData.TargetMapId   = targetMapId
    
    --Cursor.TargetData.CursorIconId     = cursorIconId      
    Cursor.UseItemTargeting = true
end

function Cursor.SetTargetedSlotData(targetLoc, targetSlot)
    Cursor.TargetData.TargetLoc = targetLoc
    Cursor.TargetData.TargetSlot = targetSlot
end

function Cursor.ClearTargetingData()
    Cursor.TargetData = nil
    Cursor.UseItemTargeting = false
    
    --ClearCursor()   
    if GetDesiredInteractAction() ~= SystemData.InteractActions.NONE then
		SetDesiredInteractAction( SystemData.InteractActions.NONE )
	end
end
