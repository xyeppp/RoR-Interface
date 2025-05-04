ManualWindow = {}

ManualWindow.data = nil           -- data we receive from C
ManualWindow.orderTable = {}
ManualWindow.listBoxData = {}     -- same data, but organized in such a way that ListBox can display it.
ManualWindow.rowToEntryMap = {}   -- map used to go from the # of the row to the entry in ManualWindow.data
ManualWindow.numTotalRows = 0                -- this value is used to count how many rows are currently visible in the listbox
ManualWindow.lastPressedButtonId = 0

function ManualWindow.Initialize()
    LabelSetText( "ManualWindowTitleBarText", GetHelpString(StringTables.Help.TEXT_HELP_TITLE_BAR) )
    LabelSetText( "ManualWindowHeaderText", GetHelpString( StringTables.Help.BUTTON_HELP_MANUAL) )

	ButtonSetText("ManualWindowBackButton", GetHelpString( StringTables.Help.BUTTON_BACK))
    
    -- disable "Back" button for Korean build. Because for Korean build when click on help button,
    -- it will go directly to this ManualWindow, so there is no "back" functionality for Korean build.
    if ( SystemData.Territory.KOREA )
    then        
        WindowSetShowing( "ManualWindowBackButton", false )
    end
end

function ManualWindow.OnShown()
    -- lazy load the manual data as this window is almost never opened
    if not ManualWindow.data
    then
        ManualWindow.data = EA_Window_HelpGetTopicList()
        ManualWindow.PrepareData()
        ManualWindow.UpdateManualWindowRow()
        
        -- setting up a default message
        LabelSetText( "ManualWindowTopicLabel", GetHelpString(StringTables.Help.LABEL_CHOOSE_A_TOPIC) )
        LabelSetText( "ManualWindowMainText", GetHelpString(StringTables.Help.TEXT_MANUAL_INTRO) )
        ManualWindow.SetListRowTints()

    end
end

function ManualWindow.ToggleShowing()
    WindowUtils.ToggleShowing("ManualWindow")
end

function ManualWindow.Show()
    WindowSetShowing("ManualWindow", true)
end

function ManualWindow.Hide()
    WindowSetShowing("ManualWindow", false)
end

function ManualWindow.Shutdown()
end

function ManualWindow.UpdateManualWindowRow()
    for row = 1, ManualWindowList.numVisibleRows do
        local rowWindow = "ManualWindowListRow"..row
        local index = ListBoxGetDataIndex("ManualWindowList", row)
        local data = ManualWindow.rowToEntryMap[index]
        
        if (data ~= nil)
        then
            if (ManualWindow.lastPressedButtonId == data.id )
            then
                ButtonSetPressedFlag(rowWindow.."Name", true ) -- set newly selected entry as pressed
            else
                ButtonSetPressedFlag(rowWindow.."Name", false )
            end
            
            local hasChildEntries = #data.childEntries > 0
            WindowSetShowing(rowWindow.."PlusButton",  hasChildEntries and not data.expanded)
            WindowSetShowing(rowWindow.."MinusButton", hasChildEntries and data.expanded)
        
            local depth = ManualWindow.listBoxData[index].depth
            WindowClearAnchors(rowWindow.."Name")
            WindowAddAnchor(rowWindow.."Name", "left", rowWindow, "left", 30 + (15 * depth), 6)
        end
    end
end

function ManualWindow.OnRButtonUpRow()
    -- currently unused
end

-- function not yet applied anywhere.
-- Figure out why can't do SetTintColor on just a label instead of the entire folder..
function ManualWindow.MouseOverRow()
    local row = WindowGetId( SystemData.ActiveWindow.name )
    local targetRowWindow = "ManualWindowListRow"..row
    DefaultColor.SetLabelColor(targetRowWindow.."Name", DefaultColor.MAGENTA)
end

-- Processes the information stored in ManualWindow.data in order to display it in the listbox.
function ManualWindow.PrepareData()
    -- reset tables and counters that are going to be used later on
    ManualWindow.orderTable = {}
    ManualWindow.listBoxData = {}
    ManualWindow.numTotalRows = 1                -- more of an index than row counter
    ManualWindow.rowToEntryMap = {}
    
    if( not ManualWindow.data ) then 
        return -- quit if we have no data to work on.
    end
    
    local function AddEntryAsRow(entryIndex, entryData, depth)
        local entryTable = {name = entryData.name, depth = depth}
        table.insert( ManualWindow.listBoxData, ManualWindow.numTotalRows, entryTable )
        table.insert( ManualWindow.orderTable, ManualWindow.numTotalRows)
        table.insert( ManualWindow.rowToEntryMap, ManualWindow.numTotalRows, entryData )
        
        ManualWindow.numTotalRows = ManualWindow.numTotalRows + 1
        
        if entryData.expanded
        then
            -- entry is expanded so add children as rows, recursively
            for childEntryIndex, childEntryData in ipairs( entryData.childEntries ) do 
                AddEntryAsRow(childEntryIndex, childEntryData, depth+1)
            end
        end
    end
    
    for entryIndex, entryData in ipairs( ManualWindow.data ) do  
        AddEntryAsRow(entryIndex, entryData, 0)
    end
    
    ListBoxSetDisplayOrder("ManualWindowList", ManualWindow.orderTable )
    ManualWindow.SetListRowTints()
end

-- function that colors the background of the Manual sections
function ManualWindow.SetListRowTints()
    for row = 1, ManualWindowList.numVisibleRows do
        local row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        local targetRowWindow = "ManualWindowListRow"..row
        WindowSetTintColor(targetRowWindow.."RowBackground", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."RowBackground", color.a )
    end
end

-- function that gets called on left click on an entry
function ManualWindow.OnLButtonUpRow()
    local row = WindowGetId( SystemData.ActiveWindow.name )
    ManualWindow.DisplayRow(row)
end

-- resets last entry selection
function ManualWindow.ResetPressedButton()
    ManualWindow.SetEntrySelectedById( ManualWindow.lastPressedButtonId, false )
end

-- displays the entry information for a certain row
function ManualWindow.DisplayRow( rowIndex )
    local dataIndex = ListBoxGetDataIndex("ManualWindowList", rowIndex)
    local entryData = ManualWindow.rowToEntryMap[dataIndex]   -- get the index in ManualWindow.data from the row
    entryData.expanded = not entryData.expanded

    ManualWindow.ResetPressedButton()
    ManualWindow.lastPressedButtonId = entryData.id
    ButtonSetPressedFlag("ManualWindowListRow"..rowIndex.."Name", true ) -- set newly selected entry as pressed
    ManualWindow.DisplayManualEntry( entryData ) -- display text for the just selected entry

        
    ManualWindow.PrepareData()
end

function ManualWindow.SetEntrySelectedById( id, selected )
    for row = 1, ManualWindowList.numVisibleRows do
        local index = ListBoxGetDataIndex("ManualWindowList", row)
        local data = ManualWindow.rowToEntryMap[index]
        if( data and data.id == ManualWindow.lastPressedButtonId ) then
            ButtonSetPressedFlag("ManualWindowListRow"..row.."Name", selected ) -- set newly selected entry as pressed
        end
    end
end

function ManualWindow.DisplayManualEntry( entryData )
    local entryText = EA_Window_HelpGetEntryData( entryData.id )
    LabelSetText( "ManualWindowTopicLabel", entryData.name )        -- display the title for the entry
    LabelSetText( "ManualWindowMainText", entryText.text )-- display the entry's text
    ScrollWindowSetOffset( "ManualWindowMain", 0 )        -- reset the scroll bar.
    ScrollWindowUpdateScrollRect("ManualWindowMain")      -- reset the scroll bar.  
end

function ManualWindow.OnLButtonUpBackButton()
	ManualWindow.Hide()
	EA_Window_Help.OnShown()
end
