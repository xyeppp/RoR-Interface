KeyUtils = {}

local BINDING_DELIMITER = L" + "

--
-- Populates a table with all of the named key combinations that when pressed will result in this action being executed.
--

function KeyUtils.GetBindingsForAction (action, boundKeysData)
    if (boundKeysData == nil)
    then
        return
    end
    
    local boundKeys = GetBindingsForAction( action )

    if (boundKeys == nil)
    then
        return
    end
    
    local index = 1
    for bindingCount, bindingData in ipairs( boundKeys ) 
    do  
        boundKeysData[ index ] = {}
        boundKeysData[ index ].buttons = {}
        boundKeysData[ index ].deviceId = bindingData.deviceId
        
        local bindingButtons = L""
        local numButtons = #bindingData.buttons
        
        for buttonCount, buttonId in ipairs( bindingData.buttons )
        do
            boundKeysData[ index ].buttons[ buttonCount ] = buttonId
            
            local deviceId = bindingData.deviceId
            
            -- Modifiers are always on the keyboard, so force the device id
            -- on anything before the final button, so we can show things like shift-mouse3
            if( numButtons ~= buttonCount )
            then
                deviceId = SystemData.InputDevice.KEYBOARD
            end

            local buttonName = GetButtonName( deviceId, buttonId )
            
            if( buttonName ~= nil ) 
            then
                if( wstring.len( bindingButtons ) > 0 ) 
                then 
                    bindingButtons = bindingButtons..BINDING_DELIMITER
                    
                    -- Shorten keys after the first modifier so these strings
                    -- don't get too crazy long
                    buttonName = KeyUtils.ShortenBindingName( buttonName )
                end
                
                bindingButtons = bindingButtons..buttonName
            end
        end
        
        boundKeysData[ index ].name = bindingButtons
        
        index = index + 1
    end
end

-- see KeyboardButtons_win32.h
-- NOTE: Should the client provide these IDs? Could they change by platform?
local LCTRL = 29
local RCTRL = 157
local LSHIFT = 42
local RSHIFT = 54
local LALT = 56
local RALT = 184
local NUMPAD1 = 0x4F
local NUMPAD2 = 0x50
local NUMPAD3 = 0x51
local NUMPAD4 = 0x4B
local NUMPAD5 = 0x4C
local NUMPAD6 = 0x4D
local NUMPAD7 = 0x47
local NUMPAD8 = 0x48
local NUMPAD9 = 0x49
local NUMPAD0 = 0x52
local NUMLOCK = 0x45
local NUMDECIMAL = 0x53
local NUMADD = 0x4E
local NUMSUBTRACT = 0x4A
local NUMDIVIDE = 0xB5
local NUMENTER = 0x9C
local PAGEUP = 0xC9
local PAGEDOWN = 0xD1
local MOUSEMID = 2
local MOUSE4 = 3
local MOUSE5 = 4



function KeyUtils.GetBindingName( buttons, deviceId )
    local bindingButtons = L""
    
    for buttonCount, buttonId in pairs( buttons ) 
    do
        local buttonDeviceId = deviceId
        if( buttonId == LCTRL or buttonId == RCTRL or
            buttonId == LSHIFT or buttonId == RSHIFT or
            buttonId == LALT or buttonId == RALT )
        then
            buttonDeviceId = SystemData.InputDevice.KEYBOARD
        end
        
        local buttonName = GetButtonName( buttonDeviceId, buttonId )
        
        if( buttonName ~= nil ) 
        then
            if( wstring.len( bindingButtons ) > 0 ) 
            then 
                bindingButtons = bindingButtons..BINDING_DELIMITER
            end
            
            bindingButtons = bindingButtons..buttonName
        end
    end
    
    return bindingButtons
end

function KeyUtils.GetFirstBindingNameForAction( action )
    local bindingData = {}
    KeyUtils.GetBindingsForAction( action, bindingData )
    if( bindingData[1] and bindingData[1].name )
    then
        return bindingData[1].name
    end
    
    return GetString( StringTables.Default.TEXT_UNBOUND )
end

--
-- Shortens a binding name so that it can fit on an action button (or in other space-constrained labels)
-- Uses the ShortKeyNames string table to localize the key names.
-- Feel free to add more key names here (Up Arrow, Backspace, Enter, etc...)
-- Note: You need to use GetButtonName as lookups to this table are using already localized names

local ShortKeyNameLookup =
{
    [GetButtonName(SystemData.InputDevice.KEYBOARD, LSHIFT)]      = StringTables.ShortKeyNames.SHORTKEY_LEFT_SHIFT,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, LCTRL)]       = StringTables.ShortKeyNames.SHORTKEY_LEFT_CONTROL,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, LALT)]        = StringTables.ShortKeyNames.SHORTKEY_LEFT_ALT,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, RSHIFT)]      = StringTables.ShortKeyNames.SHORTKEY_RIGHT_SHIFT,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, RCTRL)]       = StringTables.ShortKeyNames.SHORTKEY_RIGHT_CONTROL,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, RALT)]        = StringTables.ShortKeyNames.SHORTKEY_RIGHT_ALT,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMPAD1)]     = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_1,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMPAD2)]     = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_2,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMPAD3)]     = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_3,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMPAD4)]     = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_4,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMPAD5)]     = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_5,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMPAD6)]     = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_6,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMPAD7)]     = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_7,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMPAD8)]     = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_8,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMPAD9)]     = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_9,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMPAD0)]     = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_0,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMLOCK)]     = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_NUM_LOCK,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMDECIMAL)]  = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_DECIMAL,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMADD)]      = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_PLUS,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMSUBTRACT)] = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_MINUS,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMDIVIDE)]   = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_SLASH,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, NUMENTER)]    = StringTables.ShortKeyNames.SHORTKEY_NUM_PAD_ENTER,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, PAGEUP)]      = StringTables.ShortKeyNames.SHORTKEY_PAGE_UP,
    [GetButtonName(SystemData.InputDevice.KEYBOARD, PAGEDOWN)]    = StringTables.ShortKeyNames.SHORTKEY_PAGE_DOWN,
    [GetButtonName(SystemData.InputDevice.MOUSE,    MOUSE4)]      = StringTables.ShortKeyNames.SHORTKEY_MOUSE_AUX_1,
    [GetButtonName(SystemData.InputDevice.MOUSE,    MOUSE5)]      = StringTables.ShortKeyNames.SHORTKEY_MOUSE_AUX_2,
    [GetButtonName(SystemData.InputDevice.MOUSE,    MOUSEMID)]    = StringTables.ShortKeyNames.SHORTKEY_MIDDLE_MOUSE,
}


function KeyUtils.ShortenBindingName (bindingName)
    local splitName = WStringSplit (bindingName, BINDING_DELIMITER)
    local finalName = L""    
    
    for keyIndex, keyName in ipairs (splitName)
    do
        local shortName = keyName
        local shortId   = ShortKeyNameLookup[keyName]
        
        if (shortId ~= nil)
        then
            shortName = GetStringFromTable ("ShortKeyNames", shortId)
        end
        
        finalName = finalName..shortName
    end
    
    return finalName
end


