
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

KeyMappingWindow = {}

KeyMappingWindow.selectedKeys = {}

KeyMappingWindow.actionsData = {}
KeyMappingWindow.actionListOrder = {}

KeyMappingWindow.SelectedActionDataIndex = 1

KeyMappingWindow.categoryTabLabels = {}
KeyMappingWindow.NUM_CATEGORY_TABS = 6
KeyMappingWindow.selectedCategory = 1

KeyMappingWindow.hasChanged = false
local noKeyLabel = GetString( StringTables.Default.LABEL_NONE )
local clearLabel = GetString( StringTables.Default.LABEL_CLEAR )
local buttonBound = 1
local MAX_SHOWN_BINDINGS = 2

local KEY_ORDER_FIRST = 1
local KEY_ORDER_SECOND = 2
local KEY_ORDER_THIRD = 3
local KEY_ORDER_LAST = 4

local LCTRL = 29
local RCTRL = 157
local LSHIFT = 42
local RSHIFT = 54
local LALT = 56
local RALT = 184

local MOUSE1 = 0
local MOUSE2 = 1

local modifierKeyTableOrder =
{
    [LCTRL]     = KEY_ORDER_SECOND,
    [RCTRL]     = KEY_ORDER_SECOND,
    
    [LSHIFT]    = KEY_ORDER_THIRD,
    [RSHIFT]    = KEY_ORDER_THIRD,
    
    [LALT]      = KEY_ORDER_FIRST,
    [RALT]      = KEY_ORDER_FIRST,
}

local modiferKeyOppositeLookup =
{
    [LCTRL]     = RCTRL,
    [RCTRL]     = LCTRL,
    
    [LSHIFT]    = RSHIFT,
    [RSHIFT]    = LSHIFT,
    
    [LALT]      = RALT,
    [RALT]      = LALT,
}

KeyMappingWindow.bindingKeyName = L""
KeyMappingWindow.bindingButtonName = ""

local function CompareActions( index1, index2 )
    return( KeyMappingWindow.actionsData[ index1 ].listOrder < KeyMappingWindow.actionsData[ index2 ].listOrder )
end

local function IsOppositeModifierKeyInTable( keyTable, itemId )
    if( IsModifierKey( itemId ) )
    then
        return keyTable[ modiferKeyOppositeLookup[ itemId ] ] ~= nil
    else
        return false
    end
end

local function SwapBindings( bindingIndex )
    local table1 = { name=KeyMappingWindow.actionsData[ bindingIndex ].keys1.name,
                     buttons=KeyMappingWindow.actionsData[ bindingIndex ].keys1.buttons,
                     deviceId=KeyMappingWindow.actionsData[ bindingIndex ].keys1.deviceId }
                        
    local table2 = { name=KeyMappingWindow.actionsData[ bindingIndex ].keys2.name,
                     buttons=KeyMappingWindow.actionsData[ bindingIndex ].keys2.buttons,
                     deviceId=KeyMappingWindow.actionsData[ bindingIndex ].keys2.deviceId }
    
    KeyMappingWindow.actionsData[ bindingIndex ].keys1 = table2
    KeyMappingWindow.actionsData[ bindingIndex ].keys2 = table1
end

local function ClearBindingData( bindingIndex, keyIndex )
    KeyMappingWindow.actionsData[ bindingIndex ]["keys"..keyIndex] = {}
    KeyMappingWindow.actionsData[ bindingIndex ]["keys"..keyIndex].name = noKeyLabel
    KeyMappingWindow.actionsData[ bindingIndex ]["keys"..keyIndex].buttons = {}
    KeyMappingWindow.actionsData[ bindingIndex ]["keys"..keyIndex].deviceId = 0
end

local function CreateActionsDataTable()

    KeyMappingWindow.actionsData = {}
    local index = 1
    for action, actionDataEntry in pairs( SystemData.Settings.Keybindings ) 
    do      
        if( action and StringTables.BindableActions[ action ] )
        then
            local name = GetStringFromTable("BindableActions", StringTables.BindableActions[ action ] )
            if( name ~= nil ) 
            then
            
                KeyMappingWindow.actionsData[ index ] = {}
                KeyMappingWindow.actionsData[ index ].action = action       
                KeyMappingWindow.actionsData[ index ].name = name
                KeyMappingWindow.actionsData[ index ].category = actionDataEntry.category
                KeyMappingWindow.actionsData[ index ].listOrder = actionDataEntry.id
                
                local bindingData = {}
                KeyUtils.GetBindingsForAction( action, bindingData )
                local keyTextIndex = 1
                local noKey = false
                for keyIndex, binding in ipairs( bindingData )
                do
                    if( keyIndex > MAX_SHOWN_BINDINGS ) -- only show the first 2 bindings
                    then
                        break
                    end
                    
                    KeyMappingWindow.actionsData[ index ]["keys"..keyIndex] = {}
                    KeyMappingWindow.actionsData[ index ]["keys"..keyIndex].buttons = binding.buttons
                    KeyMappingWindow.actionsData[ index ]["keys"..keyIndex].deviceId = binding.deviceId
                    if( binding.name ~= L"" )
                    then
                        KeyMappingWindow.actionsData[ index ]["keys"..keyIndex].name = binding.name
                    else
                        noKey = true
                        KeyMappingWindow.actionsData[ index ]["keys"..keyIndex].name = noKeyLabel
                    end
 
                    keyTextIndex = keyTextIndex + 1
                end
                
                -- Set the text for the unbound keys
                for keyIndex=keyTextIndex, MAX_SHOWN_BINDINGS
                do
                    ClearBindingData( index, keyIndex )
                end
                
                index = index + 1
            end
        end
    end
end

local function UpdateSingleBindingForAction( actionName, keyBindingName )
    local index = 1
    for action, key in pairs( SystemData.Settings.Keybindings )
    do  
        if( StringTables.BindableActions[ action ] )
        then
            if( actionName == KeyMappingWindow.actionsData[ index ].action )
            then
                local bindingData = {}
                KeyUtils.GetBindingsForAction( action, bindingData )
                
                local keyTextIndex = 1
                local noKey = false
                for keyIndex, binding in ipairs( bindingData )
                do
                    if( keyIndex > MAX_SHOWN_BINDINGS ) -- only show the first 2 bindings
                    then
                        break
                    end
                    
                    KeyMappingWindow.actionsData[ index ]["keys"..keyIndex].buttons = binding.buttons
                    KeyMappingWindow.actionsData[ index ]["keys"..keyIndex].deviceId = binding.deviceId
                    if( binding.name ~= L"" )
                    then
                        KeyMappingWindow.actionsData[ index ]["keys"..keyIndex].name = binding.name
                    else
                        noKey = true
                        KeyMappingWindow.actionsData[ index ]["keys"..keyIndex].name = noKeyLabel
                    end
                    
                    -- Switch the order of the buttons shown to get around the unordered map problem
                    if( keyIndex == MAX_SHOWN_BINDINGS and not noKey and buttonBound ~= 1 )
                    then
                        SwapBindings( index )
                    end
                    
                    keyTextIndex = keyTextIndex + 1
                end
                
                -- Set the text for the unbound keys
                for keyIndex=keyTextIndex, MAX_SHOWN_BINDINGS
                do
                    ClearBindingData( index, keyIndex )
                end
            elseif( KeyMappingWindow.actionsData[ index ].keys1.name == keyBindingName and keyBindingName ~= noKeyLabel )
            then
                ClearBindingData( index, 1 )
                if( KeyMappingWindow.actionsData[ index ].keys2.name ~= noKeyLabel )
                then
                    SwapBindings( index )
                end
            elseif( KeyMappingWindow.actionsData[ index ].keys2.name == keyBindingName and keyBindingName ~= noKeyLabel )
            then
                ClearBindingData( index, 2 )
            end
            
            index = index + 1
        end
    end
end

local function FilterActionList()
    KeyMappingWindow.actionListOrder = {}   
    for dataIndex, data in ipairs( KeyMappingWindow.actionsData ) do
        if( data.category == KeyMappingWindow.selectedCategory )
        then
            table.insert(KeyMappingWindow.actionListOrder, dataIndex)
        end
    end
    table.sort( KeyMappingWindow.actionListOrder, CompareActions )
end

local function UpdateActionList()
    FilterActionList()
    ListBoxSetDisplayOrder( "KeyMappingWindowActionsList", KeyMappingWindow.actionListOrder )
end

local function ShowCategoryTab( tabId )
    -- Set selected tab index
    KeyMappingWindow.selectedCategory = tabId
    
    -- Update the Tabs
    for index, tabData in ipairs( KeyMappingWindow.categoryTabLabels ) do
        ButtonSetText( "KeyMappingWindowCategoryTab"..index, tabData.name )
        ButtonSetPressedFlag( "KeyMappingWindowCategoryTab"..index, index == tabId )
    end
    
    -- Update list view for new category
    UpdateActionList()
end

----------------------------------------------------------------
-- KeyMappingWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler()
function KeyMappingWindow.Initialize()
    LabelSetText( "KeyMappingWindowTitleBarText", GetString( StringTables.Default.LABEL_KEY_MAPPING ) )

    ButtonSetText( "KeyMappingWindowDefaultsButton", GetString( StringTables.Default.LABEL_DEFAULTS ) )
    ButtonSetText( "KeyMappingWindowSaveButton", GetString( StringTables.Default.LABEL_SAVE ) )

    LabelSetText( "KeyMappingWindowActionListLabel", GetString( StringTables.Default.LABEL_BINDABLE_ACTIONS ) )
    LabelSetText( "KeyMappingWindowActionListBoundKeysLabel", GetString( StringTables.Default.LABEL_BOUND_KEYS ) )
    
    LabelSetText( "KeyMappingWindowHelpText", GetString( StringTables.Default.TEXT_KEYBINDING_HELP ) )
    
    for categoryIndex=1, KeyMappingWindow.NUM_CATEGORY_TABS
    do
        local categoryLabelName = SystemData.Settings.Keybindings.category[categoryIndex].labelName
        KeyMappingWindow.categoryTabLabels[categoryIndex] = { name=GetStringFromTable("BindableActions", StringTables.BindableActions[ categoryLabelName ]) }
    end
    
    
    WindowRegisterEventHandler( "KeyMappingWindow", SystemData.Events.KEYBINDINGS_UPDATED, "KeyMappingWindow.UpdateData")
    
    KeyMappingWindow.UpdateData()
    ShowCategoryTab( KeyMappingWindow.selectedCategory )
end

function KeyMappingWindow.UpdateData()

    CreateActionsDataTable()
    FilterActionList()
    KeyMappingWindow.SelectedActionDataIndex = KeyMappingWindow.actionListOrder[1]
    ListBoxSetDisplayOrder( "KeyMappingWindowActionsList", KeyMappingWindow.actionListOrder )

end

function KeyMappingWindow.OnTabSelected()
    local tab = WindowGetId( SystemData.ActiveWindow.name )
    ShowCategoryTab( tab )
end

function KeyMappingWindow.OnLButtonBinding1()
    buttonBound = 1
    KeyMappingWindow.OnLButtonRawDeviceInput( 1 )
end

function KeyMappingWindow.OnLButtonBinding2()
    buttonBound = 2
    KeyMappingWindow.OnLButtonRawDeviceInput( 2 )
end

function KeyMappingWindow.OnLButtonRawDeviceInput( buttonNum )
    if( KeyMappingWindow.bindingButtonName == SystemData.MouseOverWindow.name or
        SystemData.MouseOverWindow.name ~= SystemData.ActiveWindow.name )
    then
        if( KeyMappingWindow.bindMode and KeyMappingWindow.bindingButtonName == SystemData.MouseOverWindow.name )
        then
            KeyMappingWindow.OnExitBindingMode(0, 0, 0, true)
        end
        return
    end

    -- Get us out of binding mode if we were in it
    if( KeyMappingWindow.bindMode and KeyMappingWindow.bindingButtonName ~= "" )
    then
        KeyMappingWindow.OnExitBindingMode()
    end

    -- Put us in bindmode
    KeyMappingWindow.bindMode = true
    
    -- Init the data we will use
    KeyMappingWindow.bindingButtonName = SystemData.MouseOverWindow.name
    KeyMappingWindow.bindingKeyName = L""
    KeyMappingWindow.selectedKeys = {}
    KeyMappingWindow.bindIndex = buttonNum
    
    -- Check the button
    ButtonSetCheckButtonFlag( KeyMappingWindow.bindingButtonName, true )
    ButtonSetPressedFlag( KeyMappingWindow.bindingButtonName, true )
    ButtonSetStayDownFlag( KeyMappingWindow.bindingButtonName, true )
    
    -- Get the selected action
    local windowParent = WindowGetParent( KeyMappingWindow.bindingButtonName )
    local windowIndex = WindowGetId( windowParent )
    local dataIndex = ListBoxGetDataIndex (WindowGetParent( windowParent ), windowIndex)
    KeyMappingWindow.SelectedActionDataIndex = dataIndex 
    
    -- Set the help text
    LabelSetText( "KeyMappingWindowHelpText", GetString( StringTables.Default.TEXT_KEYBINDING_BINDMODE_HELP ) )
    
    -- Register for events so we can get the next key stroke
    WindowRegisterCoreEventHandler( KeyMappingWindow.bindingButtonName, "OnRawDeviceInput", "KeyMappingWindow.OnRawDeviceInput" )
    WindowRegisterEventHandler( KeyMappingWindow.bindingButtonName, SystemData.Events.L_BUTTON_UP_PROCESSED, "KeyMappingWindow.OnExitBindingMode" )
    WindowRegisterEventHandler( KeyMappingWindow.bindingButtonName, SystemData.Events.M_BUTTON_UP_PROCESSED, "KeyMappingWindow.OnExitBindingMode" )
    WindowRegisterEventHandler( KeyMappingWindow.bindingButtonName, SystemData.Events.R_BUTTON_UP_PROCESSED, "KeyMappingWindow.OnExitBindingMode" )
    WindowRegisterCoreEventHandler( "KeyMappingWindowActionsList", "OnMouseWheel", "KeyMappingWindow.OnExitBindingModeMouseWheel" )
end

function KeyMappingWindow.OnRawDeviceInput( deviceId, itemId, itemDown )
    --DEBUG( L"DeviceId: "..deviceId..L" ItemId: "..itemId..L" ItemDown: "..itemDown..L" ActiveWindow: "..towstring(SystemData.ActiveWindow.name) )
    -- do not allow the binding of left and right mouse buttons
    if( deviceId == SystemData.InputDevice.MOUSE and (itemId == MOUSE1 or itemId == MOUSE2) )
    then
        return
    end
    
    -- Get the button info of the pressed button
    if( KeyMappingWindow.bindMode and itemDown )
    then
        if ( deviceId == SystemData.InputDevice.KEYBOARD )
        then
            -- To prevent Left Shift and Right Shift (same for Ctrl/Alt) from being bound separately, translate all Right modifier keys into Left modifier keys
            if ( itemId == RCTRL )
            then
                itemId = LCTRL
            elseif ( itemId == RSHIFT )
            then
                itemId = LSHIFT
            elseif ( itemId == RALT )
            then
                itemId = LALT
            end

            -- Don't put two of the "same" modifier keys in the table
            if( IsOppositeModifierKeyInTable( KeyMappingWindow.selectedKeys, itemId ) )
            then
                return
            end
        
            KeyMappingWindow.selectedKeys[itemId] = modifierKeyTableOrder[itemId]
            if( KeyMappingWindow.selectedKeys[itemId] == nil )
            then
                KeyMappingWindow.selectedKeys[itemId] = KEY_ORDER_LAST
            end
        else
            KeyMappingWindow.selectedKeys[itemId] = KEY_ORDER_LAST
        end
        
        local buttonName = GetButtonName( deviceId, itemId )
        ButtonSetText( SystemData.ActiveWindow.name, buttonName )
        if( KeyMappingWindow.bindingKeyName ~= L"" )
        then
            KeyMappingWindow.bindingKeyName = KeyMappingWindow.bindingKeyName..L" + "
        end
        
        KeyMappingWindow.bindingKeyName = KeyMappingWindow.bindingKeyName..buttonName
        
        -- if it was not a modifier key then bind it and exit binding mode!
        if( ( deviceId ~= SystemData.InputDevice.KEYBOARD ) or not IsModifierKey( itemId ) )
        then
            local buttons = {}
            for orderValue = KEY_ORDER_FIRST, KEY_ORDER_LAST
            do
                for key, value in pairs( KeyMappingWindow.selectedKeys )
                do
                    if ( value == orderValue )
                    then
                        table.insert( buttons, key )
                        break
                    end
                end
            end
            
            local action = KeyMappingWindow.actionsData[ KeyMappingWindow.SelectedActionDataIndex ].action
            -- Remove the old binding
            if( KeyMappingWindow.actionsData[ KeyMappingWindow.SelectedActionDataIndex ]["keys"..KeyMappingWindow.bindIndex].deviceId ~= 0 )
            then
                local boundKeyData = KeyMappingWindow.actionsData[ KeyMappingWindow.SelectedActionDataIndex ]["keys"..KeyMappingWindow.bindIndex]
                RemoveBinding( action, boundKeyData.deviceId, boundKeyData.buttons)
            end
            
            -- Add the bindings
            AddBinding( action, deviceId, buttons )
            
            -- Refresh the list
            UpdateSingleBindingForAction( action, KeyUtils.GetBindingName( buttons, deviceId ) )
            UpdateActionList()
            
            -- Mark has changed so this saves
            KeyMappingWindow.hasChanged = true
            
            -- Reset the button and unregister the events
            ButtonSetPressedFlag( KeyMappingWindow.bindingButtonName, false )
            ButtonSetStayDownFlag( KeyMappingWindow.bindingButtonName, false ) 
            ButtonSetCheckButtonFlag( KeyMappingWindow.bindingButtonName, false )
            KeyMappingWindow.bindMode = false
            KeyMappingWindow.bindingKeyName = L""
            LabelSetText( "KeyMappingWindowHelpText", GetString( StringTables.Default.TEXT_KEYBINDING_HELP ) )
            
            WindowUnregisterCoreEventHandler( KeyMappingWindow.bindingButtonName, "OnRawDeviceInput" )
            WindowUnregisterEventHandler( KeyMappingWindow.bindingButtonName, SystemData.Events.L_BUTTON_UP_PROCESSED )
            WindowUnregisterEventHandler( KeyMappingWindow.bindingButtonName, SystemData.Events.M_BUTTON_UP_PROCESSED )
            WindowUnregisterEventHandler( KeyMappingWindow.bindingButtonName, SystemData.Events.R_BUTTON_UP_PROCESSED )
            WindowUnregisterCoreEventHandler( "KeyMappingWindowActionsList", "OnMouseWheel" )
            
            KeyMappingWindow.bindingButtonName = ""
        end
    end
end

function KeyMappingWindow.OnClearBindings()
    local dataIndex = WindowGetId( SystemData.ActiveWindow.name )
    local actionIndex = KeyMappingWindowActionsList.PopulatorIndices[ dataIndex ]
    local action = KeyMappingWindow.actionsData[ actionIndex ].action
    
    for keyIndex=1, MAX_SHOWN_BINDINGS
    do
        local boundKeyData = KeyMappingWindow.actionsData[ actionIndex ]["keys"..keyIndex]
        RemoveBinding( action, boundKeyData.deviceId, boundKeyData.buttons)
    end

    UpdateSingleBindingForAction( action )
    UpdateActionList()
    KeyMappingWindow.hasChanged = true
end

function KeyMappingWindow.OnExitBindingModeMouseWheel()
    KeyMappingWindow.OnExitBindingMode( 0, 0, 0, true )
end

function KeyMappingWindow.OnExitBindingMode( flags, x, y, bForce )
    if( KeyMappingWindow.bindMode and ( SystemData.MouseOverWindow.name ~= KeyMappingWindow.bindingButtonName or bForce ) )
    then
        -- Reset the button and unregister the events
        ButtonSetPressedFlag( KeyMappingWindow.bindingButtonName, false )
        ButtonSetStayDownFlag( KeyMappingWindow.bindingButtonName, false )
        ButtonSetCheckButtonFlag( KeyMappingWindow.bindingButtonName, false )
        KeyMappingWindow.bindMode = false
        KeyMappingWindow.bindingKeyName = L""
        LabelSetText( "KeyMappingWindowHelpText", GetString( StringTables.Default.TEXT_KEYBINDING_HELP ) )
        
        WindowUnregisterCoreEventHandler( KeyMappingWindow.bindingButtonName, "OnRawDeviceInput" )
        WindowUnregisterEventHandler( KeyMappingWindow.bindingButtonName, SystemData.Events.L_BUTTON_UP_PROCESSED )
        WindowUnregisterEventHandler( KeyMappingWindow.bindingButtonName, SystemData.Events.M_BUTTON_UP_PROCESSED )
        WindowUnregisterEventHandler( KeyMappingWindow.bindingButtonName, SystemData.Events.R_BUTTON_UP_PROCESSED )
        WindowUnregisterCoreEventHandler( "KeyMappingWindowActionsList", "OnMouseWheel" )
        
        KeyMappingWindow.bindingButtonName = ""
    end
end

function KeyMappingWindow.UpdateActionRow()
    if (KeyMappingWindowActionsList.PopulatorIndices ~= nil) then               
        for rowIndex, dataIndex in ipairs (KeyMappingWindowActionsList.PopulatorIndices) do
                                
            -- Use the Alternating Row Colors for the BG
            local backgroundName = "KeyMappingWindowActionsListRow"..rowIndex.."BackgroundName"
            DefaultColor.SetWindowTint( backgroundName, DefaultColor.GetRowColor( rowIndex ) )

            ButtonSetText( "KeyMappingWindowActionsListRow"..rowIndex.."Binding1", KeyMappingWindow.actionsData[ dataIndex ].keys1.name )
            ButtonSetText( "KeyMappingWindowActionsListRow"..rowIndex.."Binding2", KeyMappingWindow.actionsData[ dataIndex ].keys2.name )
            ButtonSetText( "KeyMappingWindowActionsListRow"..rowIndex.."Clear",    clearLabel )
        end
    end    
end

function KeyMappingWindow.OnDefaultsButton()
    local text = GetString( StringTables.Default.LABEL_DEFAULTS_CONFIRMATION )
    DialogManager.MakeTwoButtonDialog( text, GetString( StringTables.Default.LABEL_YES ), KeyMappingWindow.RestoreDefaults, GetString( StringTables.Default.LABEL_NO ), nil )
end

function KeyMappingWindow.RestoreDefaults()
    RestoreDefaultBindings()
    CreateActionsDataTable()
    UpdateActionList()
    KeyMappingWindow.hasChanged = true
end

function KeyMappingWindow.Hide()
    -- Close the window     
    --ToggleWindowByName( "KeyMappingWindow", "", nil )
    WindowSetShowing( "KeyMappingWindow", false )
    if( KeyMappingWindow.hasChanged )
    then
        -- Don't just save when the user logs out!
        BroadcastEvent( SystemData.Events.USER_SETTINGS_CHANGED )
        KeyMappingWindow.hasChanged = false
    end
end
