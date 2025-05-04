FAQWindow = {}

FAQWindow.data = {}            -- data we receive from C
FAQWindow.listBoxData = {}     -- same data, but organized in such a way that ListBox can display it.
FAQWindow.rowToEntryMap = {}   -- map used to go from the # of the row to the entry in FAQWindow.data
numTotalRows = 0                -- this value is used to count how many rows are currently visible in the listbox
lastPressedButtonId = 0

function FAQWindow.Initialize()
    LabelSetText( "FAQWindowTitleBarText", GetHelpString(StringTables.Help.TEXT_HELP_TITLE_BAR) )
    LabelSetText( "FAQWindowHeaderText", GetHelpString( StringTables.Help.BUTTON_HELP_FAQ) )

	ButtonSetText("FAQWindowBackButton", GetHelpString( StringTables.Help.BUTTON_BACK))
	ButtonSetText("FAQWindowKnowledgeBaseButton", GetHelpString( StringTables.Help.BUTTON_KNOWLEDGE_BASE))
    
    FAQWindow.data = EA_Window_HelpGetFAQTopicList()
    FAQWindow.PrepareData()
    FAQWindow.UpdateFAQWindowRow()
    
    -- setting up a default message
    LabelSetText( "FAQWindowTopicLabel", GetHelpString(StringTables.Help.LABEL_CHOOSE_A_TOPIC ) )
    LabelSetText( "FAQWindowMainText", L"" )
    FAQWindow.SetListRowTints()
    -- open the first entry in the first category
    -- I'd rather have a default message in the FAQ window text box but oh wel..
    if( FAQWindow.data )
    then
        FAQWindow.DisplayRow( 1 )
        FAQWindow.DisplayRow( 2 )
    end
end

function FAQWindow.OnShown()
    WindowSetShowing("FAQWindow", true)
end

function FAQWindow.Hide()
    WindowSetShowing("FAQWindow", false)
end

function FAQWindow.Shutdown()
end

function FAQWindow.UpdateFAQWindowRow()
end

function FAQWindow.OnRButtonUpPlayerRow()
end

-- function not yet applied anywhere.
-- Figure out why can't do SetTintColor on just a label instead of the entire folder..
function FAQWindow.MouseOverRow()
    local row = WindowGetId( SystemData.ActiveWindow.name )
    local targetRowWindow = "FAQWindowPlayerListRow"..row
    DefaultColor.SetLabelColor(targetRowWindow.."Name", DefaultColor.MAGENTA)
end

-- Processes the information stored in FAQWindow.data in order to display it in the listbox.
function FAQWindow.PrepareData()
    -- reset tables and counters that are going to be used later on
    orderTable = {}
    FAQWindow.listBoxData = {}
    numTotalRows = 1                -- more of an index than row counter
    FAQWindow.rowToEntryMap = {}
    
    if( not FAQWindow.data ) then return end   -- quit if we have no data to work on.
    
    table.sort( FAQWindow.data, DataUtils.AlphabetizeByNames ) -- sort the sections first
    for sectionIndex, sectionData in ipairs( FAQWindow.data ) do   -- iterate once per section        
        if( sectionData.expanded == false ) then    -- hide the minuses if collapsed, hide the pluses if expanded
            --WindowSetShowing( "FAQWindowPlayerListRow"..numTotalRows.."MinusButton", false )
            --WindowSetShowing( "FAQWindowPlayerListRow"..numTotalRows.."PlusButton", true )
        else
            --WindowSetShowing( "FAQWindowPlayerListRow"..numTotalRows.."MinusButton", true )
            --WindowSetShowing( "FAQWindowPlayerListRow"..numTotalRows.."PlusButton", false )
        end

		-- the row contains a section, paint it gold
        --ButtonSetTextColor("FAQWindowPlayerListRow"..numTotalRows.."Name",Button.ButtonState.NORMAL, DefaultColor.GOLD.r, DefaultColor.GOLD.g, DefaultColor.GOLD.b)

		-- TODO: What if no entries?
        table.sort( sectionData.entries, DataUtils.AlphabetizeByNames ) -- sort individual entries in the table 

        local sectionTable = {name = sectionData.name, isSection = true, id = sectionData.id}
        table.insert( FAQWindow.listBoxData, numTotalRows, sectionTable ) -- add the section table to FAQWindow.listBoxData[numTotalRows]
        table.insert( orderTable, numTotalRows ) -- save the row to the order table, so we know that we want to display it later
        local indexStruct = {index = sectionIndex, isSection = true}
        table.insert( FAQWindow.rowToEntryMap, numTotalRows, indexStruct ) -- save the position of an entry in FAQWindow.data with respect to its row
        numTotalRows = numTotalRows + 1
        if( sectionData.expanded == true ) then -- we check if the category is expanded, and if so, we loop on its entries
            for entryIndex, entryData in ipairs( sectionData.entries ) do -- loop once per each entry of the section
                --WindowSetShowing( "FAQWindowPlayerListRow"..numTotalRows.."MinusButton", false )
                --WindowSetShowing( "FAQWindowPlayerListRow"..numTotalRows.."PlusButton", false )
                --ButtonSetTextColor("FAQWindowPlayerListRow"..numTotalRows.."Name",Button.ButtonState.NORMAL, DefaultColor.CLEAR_WHITE.r, DefaultColor.CLEAR_WHITE.g, DefaultColor.CLEAR_WHITE.b)
                local entryTable = {name = L"   "..entryData.name, isSection = false, id = entryData.id}
                table.insert( FAQWindow.listBoxData, numTotalRows, entryTable )
                table.insert(orderTable, numTotalRows)
                local indexStruct = {categoryIndex = sectionIndex, index = entryIndex, isSection = false}
                table.insert( FAQWindow.rowToEntryMap, numTotalRows, indexStruct )
                numTotalRows = numTotalRows + 1
            end
        end
    end
    
    ListBoxSetDisplayOrder("FAQWindowPlayerList", orderTable )       
    FAQWindow.SetListRowTints()
    FAQWindow.UpdateColorsAndSigns()
    FAQWindow.ResetAllButtons()
end

-- function that colors the background of the FAQ sections
function FAQWindow.SetListRowTints()
	local row_mod = 0
    for row = 1, numTotalRows do
        row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        local targetRowWindow = "FAQWindowPlayerListRow"..row
        WindowSetTintColor(targetRowWindow.."RowBackground", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."RowBackground", color.a )
    end
end

-- function that gets called on left click on an entry
function FAQWindow.OnLButtonUpPlayerRow()
    local row = WindowGetId( SystemData.ActiveWindow.name )
    local dataIndex = ListBoxGetDataIndex("FAQWindowPlayerList", row)
    --FAQWindow.DisplayRow( row )
    FAQWindow.DisplayRow( ListBoxGetDataIndex("FAQWindowPlayerList", row) )
    FAQWindow.UpdateColorsAndSigns()
end

-- resets last entry selection
function FAQWindow.ResetPressedButton()
    FAQWindow.SetEntrySelectedById( lastPressedButtonId, false )
end

function FAQWindow.ResetAllButtons()
    for index, data in ipairs( FAQWindow.listBoxData ) do
        --DEBUG(L"Index "..index)
        if( lastPressedButtonId == data.id and data.isSection == false ) then
            ButtonSetPressedFlag("FAQWindowPlayerListRow"..index.."Name", true ) -- set newly selected entry as pressed
            --DEBUG(L"Set pressed")
        else
            ButtonSetPressedFlag("FAQWindowPlayerListRow"..index.."Name", false )
            --DEBUG(L"Set unpressed")
        end
    end
end

-- displays the entry information for a certain row
function FAQWindow.DisplayRow( row )
    local index = FAQWindow.rowToEntryMap[row].index   -- get the index in FAQWindow.data from the row
    if( FAQWindow.rowToEntryMap[row].isSection ) then
        if( FAQWindow.data[index].expanded ) then  -- expand if not expanded, otherwise collapse
            FAQWindow.data[index].expanded = false
        else
            FAQWindow.data[index].expanded = true
        end
    else
        FAQWindow.ResetPressedButton()
        local categoryIndex = FAQWindow.rowToEntryMap[row].categoryIndex
        lastPressedButtonId = FAQWindow.data[categoryIndex].entries[index].id
        ButtonSetPressedFlag("FAQWindowPlayerListRow"..row.."Name", true ) -- set newly selected entry as pressed
        FAQWindow.DisplayFAQEntry( FAQWindow.data[categoryIndex].entries[index].id, FAQWindow.data[categoryIndex].entries[index].name ) -- display text for the just selected entry
    end
        
    FAQWindow.PrepareData()
end

function FAQWindow.SetEntrySelectedById( id, selected )
    for index, data in pairs( FAQWindow.listBoxData ) do
        if( data.isSection == false and data.id == lastPressedButtonId ) then
            ButtonSetPressedFlag("FAQWindowPlayerListRow"..index.."Name", selected ) -- set newly selected entry as pressed
        end
    end
end

function FAQWindow.DisplayFAQEntry( id, name )
    local entryData = EA_Window_HelpGetFAQEntryData( id ) 
    LabelSetText( "FAQWindowTopicLabel", name )        -- display the title for the entry
    LabelSetText( "FAQWindowMainText", entryData.text )-- display the entry's text
    ScrollWindowSetOffset( "FAQWindowMain", 0 )        -- reset the scroll bar.
    ScrollWindowUpdateScrollRect("FAQWindowMain")      -- reset the scroll bar.  
end

function FAQWindow.OnLButtonUpBackButton()
	FAQWindow.Hide()
	EA_Window_Help.OnShown()
end

function FAQWindow.OnLButtonUpKnowledgeBaseButton()
	-- Create Confirmation Dialog
    local dialogText = GetHelpString( StringTables.Help.DIALOG_CONFIRM_OPEN_KNOWLEDGE_BASE)
    
    local confirmYes = GetHelpString( StringTables.Help.BUTTON_CONFIRM_YES)
    local confirmNo = GetHelpString( StringTables.Help.BUTTON_CONFIRM_NO)
    DialogManager.MakeTwoButtonDialog( dialogText, confirmYes, FAQWindow.ConfirmedOpenKnowledgeBase, confirmNo, nil)
end

function FAQWindow.ConfirmedOpenKnowledgeBase()
    OpenURL( GameData.URLs.URL_KNOWLEDGE_BASE )
end

function FAQWindow.UpdateColorsAndSigns()
    for index = 1, FAQWindowPlayerList.numVisibleRows do
        WindowSetShowing( "FAQWindowPlayerListRow"..index.."MinusButton", false )
        WindowSetShowing( "FAQWindowPlayerListRow"..index.."PlusButton", false )

    end                 
end
