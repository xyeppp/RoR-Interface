----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

ColorPicker = {}

ColorPicker.COLOR_CHOICE_BASE = 1
ColorPicker.COLOR_CHOICE_PATTERN  = 2
ColorPicker.SelectedCustomization = 0
ColorPicker.SelectedColorPickerWindowID = 0

ColorPicker.doneInitialized = false

-- OnInitialize Handler
function ColorPicker.Initialize()
    local newWindowName = L""
    local previousWindowName = L""
    local parentWindow = "ColorPicker"

    local anchorWindow = "ColorPicker"
    local colorBoxIndex = 0
    local tempNum = 0

	WindowClearAnchors("ColorPicker")
	WindowAddAnchor( "ColorPicker", "bottomright", "HeraldryEditorTitleBar", "topleft", 0, 4 )

	-- Loop through each row
	for colorBoxRow, data in ipairs(DefaultColor.ColorPickerColors) do

		-- loop through each colum
		for colorBoxColumn, data in ipairs(DefaultColor.ColorPickerColors[colorBoxRow]) do
			-- calculate what window number we're on
			--colorBoxIndex = colorBoxColumn + ((colorBoxRow-1)*HeraldryEditor.NUM_COLS)
			colorBoxIndex = colorBoxIndex + 1
            newWindowName = "ColorPickerColorBox"..colorBoxIndex

            CreateWindowFromTemplate(newWindowName, "EA_Templates_Color_Picker_Button", parentWindow)

            -- Special Circumstance: The Default Realm Colors are reserved for IDs 1(Order) and 2(Dest), so we'll offset by 2 here:
			WindowSetId(newWindowName, colorBoxIndex+2)

            if (colorBoxIndex == 1) then		-- The very first color box
                WindowAddAnchor( newWindowName, "topleft", anchorWindow, "topleft", 7, 7 )

            else
                if (colorBoxColumn == 1) then	-- The first color box of a single row
                    tempNum = colorBoxIndex - HeraldryEditor.NUM_COLS
                    previousWindowName = "ColorPickerColorBox"..tempNum
                    WindowAddAnchor( newWindowName, "bottom", previousWindowName, "top", 0, 0 )
                else
                    tempNum = colorBoxIndex-1	-- The rest of the color boxes in a single row
                    previousWindowName = "ColorPickerColorBox"..tempNum
                    WindowAddAnchor( newWindowName, "right", previousWindowName, "left", 0, 0 )
                end
            end
			if DefaultColor.ColorPickerColors[colorBoxRow][colorBoxColumn].id > 0 then
				DefaultColor.SetWindowTint("ColorPickerColorBox"..colorBoxIndex, DefaultColor.ColorPickerColors[colorBoxRow][colorBoxColumn] )
			else
				WindowSetShowing("ColorPickerColorBox"..colorBoxIndex, false)
			end
        end
    end

    -- TODO: Fix this
	WindowSetId("ColorPickerColorBox41", 2)
	WindowSetId("ColorPickerColorBox42", 43)
	WindowSetId("ColorPickerColorBox43", 44)
	WindowSetId("ColorPickerColorBox44", 45)

	-- There are 3 colors that don't fit within the other rows, so we have to treat them special.
	newWindowName = "ColorPickerColorBoxEdge201"
	CreateWindowFromTemplate(newWindowName, "EA_Templates_Color_Picker_Button", parentWindow)
	WindowSetId(newWindowName, 46)
	WindowAddAnchor( newWindowName, "right", "ColorPickerColorBox12", "left", -6, 14 )
	DefaultColor.SetWindowTint(newWindowName, DefaultColor.ColorPickerEdgeColors[1])

	newWindowName = "ColorPickerColorBoxEdge202"
	CreateWindowFromTemplate(newWindowName, "EA_Templates_Color_Picker_Button", parentWindow)
	WindowSetId(newWindowName, 47)
	WindowAddAnchor( newWindowName, "right", "ColorPickerColorBox28", "left", -6, 14 )
	DefaultColor.SetWindowTint(newWindowName, DefaultColor.ColorPickerEdgeColors[2])

	newWindowName = "ColorPickerColorBoxEdge203"
	CreateWindowFromTemplate(newWindowName, "EA_Templates_Color_Picker_Button", parentWindow)
	WindowSetId(newWindowName, 1)		-- This is the default order color, which ID1 was reserved for.
	WindowAddAnchor( newWindowName, "right", "ColorPickerColorBox40", "left", -6, 14 )
	DefaultColor.SetWindowTint(newWindowName, DefaultColor.ColorPickerEdgeColors[3])

	ColorPicker.doneInitialized = true
	HeraldryEditor.UpdateColorChoices(false)
end

function ColorPicker.Shutdown()
end

function ColorPicker.OnClose()
end

function ColorPicker.OnHidden()
	WindowSetShowing("ColorPicker", false)
end

function ColorPicker.FilterColorChoices()
	if HeraldryEditor.BestOptionsFiltered == nil or ColorPicker.doneInitialized == false then
		return
	end
end

function ColorPicker.OnMouseoverColorBox()
end

function ColorPicker.OnMouseoverEndColorBox()
end

function ColorPicker.GetRGBValuesFromColorID(colorID)
	local r = 0
	local g = 0
	local b = 0

	for colorBoxRow, data in ipairs(DefaultColor.ColorPickerColors) do
		for colorBoxColumn, data in ipairs(DefaultColor.ColorPickerColors[colorBoxRow]) do 		-- loop through each column
			if colorID == DefaultColor.ColorPickerColors[colorBoxRow][colorBoxColumn].id then
				r = DefaultColor.ColorPickerColors[colorBoxRow][colorBoxColumn].r
				g = DefaultColor.ColorPickerColors[colorBoxRow][colorBoxColumn].g
				b = DefaultColor.ColorPickerColors[colorBoxRow][colorBoxColumn].b
				return r,g,b
			end
		end
	end

	return r,g,b
end

function ColorPicker.OnLButtonUpColorBox()
	local windowID = WindowGetId( SystemData.ActiveWindow.name )
	ColorPicker.SelectedColorPickerWindowID = windowID

	local r,g,b

    if windowID > 45 or windowID == 1 then -- (These are the 3 special boxes on the edge)
		if windowID == 1 then
			r, g, b = WindowGetTintColor("ColorPickerColorBoxEdge203")
		elseif windowID == 46 then
			r, g, b = WindowGetTintColor("ColorPickerColorBoxEdge201")
		else
			r, g, b = WindowGetTintColor("ColorPickerColorBoxEdge202")
		end

	else
		r,g,b = ColorPicker.GetRGBValuesFromColorID(HeraldryEditor.BestOptionsFiltered.colorList[windowID])
	end

	-- Now that we've got our selected color, pass it along to the window that opened the Color Picker
	-- (Note: We only have 1 possible choice right  now, the Heraldry Editor)
	if WindowGetShowing("HeraldryEditor") == true then
		HeraldryEditor.HandleColorPickerChoice( r,g,b, HeraldryEditor.BestOptionsFiltered.colorList[windowID] )
	end
end