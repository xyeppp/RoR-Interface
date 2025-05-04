--[[
        Code for operating on money frame template windows.
        Should be used to format money on all windows using the
        MoneyFrame.xml window template.
]]

-- GLOBALS

MoneyFrame = {}
MoneyFrame.valueChangedCallbacks = {}

MoneyFrame.altCurrencyTooltips = {}

MoneyFrame.SHOW_EMPTY_WINDOWS = 0				-- 100 brass displays as 0g 1s 0b
MoneyFrame.HIDE_EMPTY_WINDOWS = 1				-- 100 brass displays as 1s
MoneyFrame.HIDE_EMPTY_WINDOWS_ABOVE_VALUE = 2	-- only shows windows with a value of 0 if they 
												--   are to the right of a non-zero value, so 
												-- 100 brass displays as 1s 0b

MoneyFrame.GREYOUT_WINDOWS = false	-- If set to true when passed as param, this will make the text and coin icons grey out

MoneyFrame.GOLD_INDEX   = 1
MoneyFrame.SILVER_INDEX = 2
MoneyFrame.BRASS_INDEX  = 3

MoneyFrame.GoldIcon     = GetString( StringTables.Default.ICON_MONEY_GOLD )
MoneyFrame.SilverIcon   = GetString( StringTables.Default.ICON_MONEY_SILVER )
MoneyFrame.BrassIcon    = GetString( StringTables.Default.ICON_MONEY_BRASS )

MoneyFrame.GoldText     = GetString( StringTables.Default.TEXT_MONEY_GOLD )
MoneyFrame.SilverText   = GetString( StringTables.Default.TEXT_MONEY_SILVER )
MoneyFrame.BrassText    = GetString( StringTables.Default.TEXT_MONEY_BRASS )
MoneyFrame.NoMoneyText  = GetString( StringTables.Default.TEXT_NO_MONEY )

MoneyFrame.ALT_CURRENCY_ICON_SCALE = 16 / 64  -- rescaling 64x64 item icons to fit into the 16x16 box

-- LOCAL FUNCTIONS

--[[
    Given an amount of brass , returns the value
    as gold, silver, and brass...
--]]
function MoneyFrame.ConvertBrassToCurrency (amount)

    if (amount == nil)
    then
        return 0, 0, 0
    end

    local g = math.floor (amount / 10000)
    local s = math.floor ((amount - (g * 10000)) / 100)
    local b = math.mod (amount, 100)
    
    return g, s, b
end

--[[
    Given a MoneyFrame windowName, returns it's value in brass 
--]]
function MoneyFrame.ConvertCurrencyToBrass (windowName)
    local g = MoneyFrame.GetMoneyValue( windowName.."GoldText" )
    local s = MoneyFrame.GetMoneyValue( windowName.."SilverText" )
    local b = MoneyFrame.GetMoneyValue( windowName.."BrassText" )
    
    return (g*10000) + (s*100) + b
end


-- GLOBAL FUNCTIONS

function MoneyFrame.RegisterCallbackForValueChanged( windowName, callbackFunction )

    MoneyFrame.valueChangedCallbacks[windowName] = callbackFunction

end

function MoneyFrame.UnregisterCallbackForValueChanged( windowName )

    MoneyFrame.valueChangedCallbacks[windowName] = nil

end

--[[
    Given a money window and an amount formats an iconic representation 
    of a currency amount.
    
    An optional hideWindowsWithoutCashEnum value can be set to one of 3 values:
    MoneyFrame.SHOW_EMPTY_WINDOWS, MoneyFrame.HIDE_EMPTY_WINDOWS, or MoneyFrame.HIDE_EMPTY_WINDOWS_ABOVE_VALUE
    (see their definitions at the top for explanation)
    
--]]

function MoneyFrame.FormatMoney (windowName, amount, hideWindowsWithoutCashEnum, greyOut)

	if hideWindowsWithoutCashEnum == nil or hideWindowsWithoutCashEnum == false then
		hideWindowsWithoutCashEnum = MoneyFrame.SHOW_EMPTY_WINDOWS
	elseif hideWindowsWithoutCashEnum == true then
		hideWindowsWithoutCashEnum = MoneyFrame.HIDE_EMPTY_WINDOWS
	end

    local g, s, b = MoneyFrame.ConvertBrassToCurrency (amount)

    local moneyTable = {}
    moneyTable[MoneyFrame.GOLD_INDEX]   = { frame = (windowName.."GoldFrame"),     label = (windowName.."GoldText"),   icon = 00046, count = g, showing = true }
    moneyTable[MoneyFrame.SILVER_INDEX] = { frame = (windowName.."SilverFrame"),   label = (windowName.."SilverText"), icon = 00047, count = s, showing = true }
    moneyTable[MoneyFrame.BRASS_INDEX]  = { frame = (windowName.."BrassFrame"),    label = (windowName.."BrassText"),  icon = 00048, count = b, showing = true }
    
    local currentAnchor = windowName
	local width, height, totalWidth = 0, 0, 0
	
	local hideEmptyWindows = (hideWindowsWithoutCashEnum == MoneyFrame.HIDE_EMPTY_WINDOWS) or 
							 (hideWindowsWithoutCashEnum == MoneyFrame.HIDE_EMPTY_WINDOWS_ABOVE_VALUE)
    for i, moneyData in ipairs (moneyTable) do
       
        MoneyFrame.SetMoneyValue (moneyData.label, moneyData.count)
        
        if ( moneyData.count == 0 and hideEmptyWindows )then 
            moneyData.showing = false
        else
            moneyData.showing = true
            if hideWindowsWithoutCashEnum == MoneyFrame.HIDE_EMPTY_WINDOWS_ABOVE_VALUE then
				hideEmptyWindows = false
            end
        end
            
        local texture, x, y = GetIconData(moneyTable[i].icon )

        local imageWindow = moneyData.frame.."Image"
        DynamicImageSetTexture(imageWindow, texture, x, y)

		if greyOut ~=nil then
			if greyOut == true then
				WindowSetTintColor(imageWindow, DefaultColor.MEDIUM_GRAY.r, DefaultColor.MEDIUM_GRAY.g, DefaultColor.MEDIUM_GRAY.b)
				DefaultColor.SetLabelColor( moneyData.label, DefaultColor.MEDIUM_GRAY )
			else
				WindowSetTintColor(imageWindow, DefaultColor.ZERO_TINT.r, DefaultColor.ZERO_TINT.g, DefaultColor.ZERO_TINT.b)
				DefaultColor.SetLabelColor( moneyData.label, DefaultColor.ZERO_TINT )
			end
		end

        WindowSetShowing(imageWindow,     moneyData.showing)
        WindowSetShowing(moneyData.label, moneyData.showing)   
        
        WindowClearAnchors (moneyData.label)
        if (currentAnchor == windowName) then
            WindowAddAnchor (moneyData.label, "topleft", currentAnchor, "topleft", 5, 0)
        else
            WindowAddAnchor (moneyData.label, "topright", currentAnchor, "topleft", 5, 0)
        end
        
        if (moneyData.showing) then
			width = WindowGetDimensions( moneyData.label )
			totalWidth = totalWidth + width + 30	-- 30 = size of icon + space before # + space before icon
            currentAnchor = moneyData.frame
        end
    end

	width, height = WindowGetDimensions( windowName )
	WindowSetDimensions( windowName, totalWidth, height )
	
    return currentAnchor
end



--[[
    Provides the ability to display "alternate currencies" in place of the usual gold, silver, brass
    for vendors selling things in exchange for items
    
    Inputs:
        * windowName - base windowName that's inheritting the AltCurrencyFrame
        * altCurrencyTable - array of *size 3* altcurrency objects containing:
            - altCurrencyTable[i].icon - icon number to display
            - altCurrencyTable[i].quantity - number of that currency required for purchase
            (Note that there must be 3 items even if less are set. quantity 0 values will be hidden
            unless hideIfNotSet is set to false)
        * hideIfNotSet (defaults to true if not set) -  when true hides the icon and quanity for any of the 3  
                                                        alt currency icon/quantity where quantity==0
        
    TODO: the "Gold", "Silver", "Brass" window names should be changed to something more generic at some point. 
--]]
function MoneyFrame.FormatAltCurrency (windowName, altCurrencyTable, hideIfNotSet)
    hideIfNotSet = hideIfNotSet
    
    local currencyTable = 
    {
        { frame = (windowName.."GoldFrame"),     label = (windowName.."GoldText")   },
        { frame = (windowName.."SilverFrame"),   label = (windowName.."SilverText") },
        { frame = (windowName.."BrassFrame"),    label = (windowName.."BrassText")  },
    }
    
    local currentAnchor = windowName
	
    for i, altCurrencyData in ipairs (currencyTable) do
       
        if (altCurrencyTable[i] ~= nil)
        then
            if (altCurrencyTable[i].icon ~= 0)
            then
                local texture, x, y = GetIconData(altCurrencyTable[i].icon )
                local ImageWindow = altCurrencyData.frame.."Image"
                DynamicImageSetTexture(ImageWindow, texture, x, y)
                DynamicImageSetTextureScale(ImageWindow, MoneyFrame.ALT_CURRENCY_ICON_SCALE )
                
                --
	            if altCurrencyTable[i].name ~= nil  
	            then
					MoneyFrame.altCurrencyTooltips[ImageWindow] = altCurrencyTable[i].name
				end
                if (altCurrencyTable[i].tint ~= nil)
                then
                    local TintColor = altCurrencyTable[i].tint
                    WindowSetTintColor(ImageWindow, TintColor.r, TintColor.g, TintColor.b)
                end
            end
           
            MoneyFrame.SetMoneyValue (altCurrencyData.label, altCurrencyTable[i].quantity)

            if (altCurrencyTable[i].quantity == 0 and hideIfNotSet)
            then 
                altCurrencyData.showing = false
            else
                altCurrencyData.showing = true
            end
                
            WindowSetShowing (altCurrencyData.frame.."Image", altCurrencyData.showing)
            WindowSetShowing (altCurrencyData.label, altCurrencyData.showing)  
            
            WindowClearAnchors (altCurrencyData.label)
            if (currentAnchor == windowName)
            then
                WindowAddAnchor (altCurrencyData.label, "topleft", currentAnchor, "topleft", 5, 0)
            else
                WindowAddAnchor (altCurrencyData.label, "topright", currentAnchor, "topleft", 5, 0)
            end
            
            if (altCurrencyData.showing) then
                currentAnchor = altCurrencyData.frame
            end
        else
            MoneyFrame.SetMoneyValue(altCurrencyData.label, 0)
            WindowSetShowing (altCurrencyData.frame.."Image", false)
            WindowSetShowing (altCurrencyData.label, false)
        end
    end

    return currentAnchor
end
--[[
    abstracts out whether we're using Labels or TextEdits when setting value
--]]
function MoneyFrame.SetMoneyValue( windowName, number )

    if DoesWindowExist(windowName) == false then
        windowName = windowName or "<nil>"
        DEBUG(L"ERROR in MoneyFrame.SetMoneyValue: window: "..StringToWString(windowName)..L" does not exist")
        return
    end

    local text
    if number < 0 then
        text = L"0"
    else
        text = L""..number
    end
    
    if WindowGetId(windowName) == 99999 then
        TextEditBoxSetText(windowName, text)
    else
        LabelSetText (windowName, text)
    end

end

--[[
    abstracts out whether we're using Labels or TextEdits when getting value
    ASSUMPTION: this doesn't verify that the windowName provided is valid
    
    Returns numeric value of text (or 0 if no text was set)
--]]
function MoneyFrame.GetMoneyValue( windowName )
    local text
    --    TODO: Fix this so that is does not rely on the ID.
    --    For now use ID to tell whether we're using a Label or EditBox,
    --    but this means that if a user needs the ID then they can't use 
    --    the EditBox version (and has to avoid ID=99999 when using the Label version)
    if WindowGetId(windowName) == 99999 then
        text = TextEditBoxGetText(windowName)
    else
        text = LabelGetText (windowName)
    end
    
    local textNoZeroes = wstring.gsub( text, L"^0", L"" )
    if textNoZeroes == nil or textNoZeroes == L"" or textNoZeroes == "" then	
        textNoZeroes = L"0"
    end
    
    if text ~= textNoZeroes then
        MoneyFrame.SetMoneyValue( windowName, tonumber( textNoZeroes ) )
    end
    return tonumber( textNoZeroes )
end

--[[
    If useIcons is false or not supplied, returns a text string for the unit (i.e. L"gold")
    If useIcons is true, returns a text string for the icon for the unit (i.e. L"<icon46>")
--]]
function MoneyFrame.GetUnitString(unitIndex, useIcons)
    if (useIcons) then
        if (unitIndex == MoneyFrame.GOLD_INDEX) then
            return MoneyFrame.GoldIcon
        elseif (unitIndex == MoneyFrame.SILVER_INDEX) then
            return MoneyFrame.SilverIcon
        elseif (unitIndex == MoneyFrame.BRASS_INDEX) then
            return MoneyFrame.BrassIcon
        end
    end
    
    if (unitIndex == MoneyFrame.GOLD_INDEX) then
        return MoneyFrame.GoldText
    elseif (unitIndex == MoneyFrame.SILVER_INDEX) then
        return MoneyFrame.SilverText
    elseif (unitIndex == MoneyFrame.BRASS_INDEX) then
        return MoneyFrame.BrassText
    end
    
    return L""
end


--[[
    Given a currency amount, returns a localized wide string representing
    that amount.  (50236 = 5g 2s 36b, 2500 = 25s, 10024 = 1g 24b, etc.)
    useIcons defaults to false. useNonVerbose defaults to false for text, true for icons.
--]]
function MoneyFrame.FormatMoneyString (amount, useIcons, useNonVerbose) 
    local g, s, b = MoneyFrame.ConvertBrassToCurrency (amount)

    -- Count how many types of money we have to display.
    local stringParams = {}
    local numTypes = 0
    if ( g > 0 ) then
        table.insert( stringParams, g )
        table.insert( stringParams, MoneyFrame.GetUnitString( MoneyFrame.GOLD_INDEX, useIcons ) )
        numTypes = numTypes + 1
    end
    if ( s > 0 ) then
        table.insert( stringParams, s )
        table.insert( stringParams, MoneyFrame.GetUnitString( MoneyFrame.SILVER_INDEX, useIcons ) )
        numTypes = numTypes + 1
    end
    if ( b > 0 ) then
        table.insert( stringParams, b )
        table.insert( stringParams, MoneyFrame.GetUnitString( MoneyFrame.BRASS_INDEX, useIcons ) )
        numTypes = numTypes + 1
    end
    
    -- If useNonVerbose isn't supplied, make it default to false for text and true for icons
    if (useNonVerbose == nil) then
        useNonVerbose = useIcons
    end

    -- Figure out which string to use
    local stringToUse = nil
    if ( numTypes == 1 ) then
        if ( useNonVerbose ) then
            stringToUse = StringTables.Default.TEXT_MONEY_STRING_1X_NONVERBOSE
        else
            stringToUse = StringTables.Default.TEXT_MONEY_STRING_1X
        end
    elseif ( numTypes == 2 ) then
        if ( useNonVerbose ) then
            stringToUse = StringTables.Default.TEXT_MONEY_STRING_2X_NONVERBOSE
        else
            stringToUse = StringTables.Default.TEXT_MONEY_STRING_2X
        end
    elseif ( numTypes == 3 ) then
        if ( useNonVerbose ) then
            stringToUse = StringTables.Default.TEXT_MONEY_STRING_3X_NONVERBOSE
        else
            stringToUse = StringTables.Default.TEXT_MONEY_STRING_3X
        end
    else
        if (useIcons and useNonVerbose) then
            -- In this case, show 0 <brass icon>
            stringToUse = StringTables.Default.TEXT_MONEY_STRING_1X_NONVERBOSE
            stringParams = { 0, MoneyFrame.GetUnitString(MoneyFrame.BRASS_INDEX, useIcons) }
        else
            stringToUse = MoneyFrame.NoMoneyText
        end
    end

    return GetStringFormat( stringToUse, stringParams )
end

function MoneyFrame.ValueChanged()

    windowName = WindowGetParent( SystemData.ActiveWindow.name )

    if MoneyFrame.valueChangedCallbacks[windowName] ~= nil then
        local money = MoneyFrame.ConvertCurrencyToBrass (windowName)
        MoneyFrame.valueChangedCallbacks[windowName](money)
    end
end

function MoneyFrame.DisplayTooltip()

    iconName = SystemData.ActiveWindow.name
    if MoneyFrame.altCurrencyTooltips[iconName] ~= nil and MoneyFrame.altCurrencyTooltips[iconName] ~= L"" then
		Tooltips.CreateTextOnlyTooltip( iconName, MoneyFrame.altCurrencyTooltips[iconName] )
		Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_VARIABLE )
    end
end
