TipsWindow = {}

TipsWindow.data = nil           -- data we receive from C
TipsWindow.orderTable = {}
TipsWindow.lastPressedButtonId = 0

local SortKeys =
{
    ["name"]     = { fallback = "sortId", sortType=1},
    ["sortId"]   = { fallback = "unlockId", sortType=2},
    ["unlockId"]   = { sortType=3},
}
local SortTypes = 
{
    [1] = "name",
    [2] = "sortId",
    [3] = "unlockId",
}

TipsWindow.display = { sortCol="sortId", 
                       sortOrder=DataUtils.SORT_ORDER_UP }
                       
TipsWindow.sortButtons = {  "TipsWindowSortButtonBarNameButton",		-- Order List Header 
                            }
                            
local function InitListData()
    TipsWindow.data = EA_Window_HelpGetHelpTipsList()
    for dataIndex, tipData in ipairs(TipsWindow.data)
    do
        tipData.sortId = dataIndex
        
        local stringId = tipData.unlockId - HelpTips.INDEX_OFFSET
        tipData.name = GetStringFromTable("HelpTipNames", stringId )
    end
end

local function FilterList()
    TipsWindow.orderTable = {}
    for dataIndex, tipData in ipairs(TipsWindow.data)
    do
        if tipData.name and tipData.name ~= L""
        then
            table.insert(TipsWindow.orderTable, dataIndex)
        end
    end
end

local function CompareTips( tipIndex1, tipIndex2 )
    if( tipIndex2 == nil ) then
        return false
    end

    local tip1 = TipsWindow.data[tipIndex1]
    local tip2 = TipsWindow.data[tipIndex2]
    
    return DataUtils.OrderingFunction( tip1, tip2, TipsWindow.display.sortCol, SortKeys, TipsWindow.display.sortOrder )
end

local function SortList()
    table.sort( TipsWindow.orderTable, CompareTips )
end

local function UpdateTipsList()
    InitListData()
    FilterList()
    SortList()
    
    
    ListBoxSetDisplayOrder( "TipsWindowList", TipsWindow.orderTable )
end

function TipsWindow.Initialize()
    LabelSetText( "TipsWindowTitleBarText", GetHelpString(StringTables.Help.TEXT_HELP_TITLE_BAR) )
    LabelSetText( "TipsWindowHeaderText", GetHelpString( StringTables.Help.BUTTON_HELP_TIPS) )

	ButtonSetText("TipsWindowBackButton", GetHelpString( StringTables.Help.BUTTON_BACK))
    
    -- set sort header labels
    ButtonSetText( "TipsWindowSortButtonBarNameButton",  GetHelpString( StringTables.Help.LABEL_HELP_SORT_BUTTON_TIP_NAME ) )

    TipsWindow.InitTutorialCombo()    
end

function TipsWindow.OnShown()
    if not TipsWindow.data -- lazy load, most players are never going to look at this window
    then
        UpdateTipsList()
        TipsWindow.UpdateSortButtons()
        -- default show the first tip
        TipsWindow.DisplayRow( 1 )
    end
end

function TipsWindow.Show()
    WindowSetShowing("TipsWindow", true)
end

function TipsWindow.Hide()
    WindowSetShowing("TipsWindow", false)
end

function TipsWindow.Shutdown()
end

function TipsWindow.PopulateTipsList()
    if (TipsWindowList.PopulatorIndices == nil) 
    then
        return
    end
    
    TipsWindow.SetListRowTints()
end

-- function that colors the background of the Manual sections
function TipsWindow.SetListRowTints()
    for row = 1, TipsWindowList.numVisibleRows do
        local row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        local targetRowWindow = "TipsWindowListRow"..row
        WindowSetTintColor(targetRowWindow.."Background", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."Background", color.a )
    end
end

-- function that gets called on left click on an entry
function TipsWindow.OnLButtonUpRow()
    local rowIndex = WindowGetId( SystemData.ActiveWindow.name )
    TipsWindow.DisplayRow( ListBoxGetDataIndex("TipsWindowList", rowIndex) )
end

function TipsWindow.OnRButtonUpRow()
    TipsWindow.OnLButtonUpRow()
end

-- displays the entry information for a certain row
function TipsWindow.DisplayRow( dataIndex )
    local tip = TipsWindow.data[dataIndex]
    if tip
    then
        local stringId = tip.unlockId - HelpTips.INDEX_OFFSET
        LabelSetText( "TipsWindowMainScrollChildTopicLabel", tip.name )
        
        local strDescription = GetStringFromTable("HelpTipDescriptionsAlternate", stringId )
        if not strDescription or strDescription == L""
        then
            strDescription = GetStringFromTable("HelpTipDescriptions", stringId )
        end
        LabelSetText( "TipsWindowMainScrollChildMainText",  strDescription)
        
        ScrollWindowSetOffset( "TipsWindowMain", 0 )        -- reset the scroll bar.
        ScrollWindowUpdateScrollRect("TipsWindowMain")      -- reset the scroll bar.  
    end
end

function TipsWindow.OnLButtonUpBackButton()
	TipsWindow.Hide()
	EA_Window_Help.OnShown()
end

function TipsWindow.OnSortList()
    local sortType = WindowGetId( SystemData.ActiveWindow.name )
    -- If we are already using this sort type, toggle the order.
    if( sortType == SortKeys[TipsWindow.display.sortCol].sortType ) then
        if( TipsWindow.display.sortOrder == DataUtils.SORT_ORDER_UP ) then
            TipsWindow.display.sortOrder = DataUtils.SORT_ORDER_DOWN
        else
            TipsWindow.display.sortOrder = DataUtils.SORT_ORDER_UP
        end
        
    -- Otherwise change the type and use the up order.	
    else
        TipsWindow.display.sortCol = SortTypes[sortType]
        TipsWindow.display.sortOrder = DataUtils.SORT_ORDER_UP
    end

    SortList()
    ListBoxSetDisplayOrder( "TipsWindowList", TipsWindow.orderTable )
    
    TipsWindow.UpdateSortButtons()
end

-- Displays the clicked sort button as pressed down and positions an arrow above it
function TipsWindow.UpdateSortButtons()
    
    local sortType = SortKeys[TipsWindow.display.sortCol].sortType
    local sortOrder = TipsWindow.display.sortOrder

    for index = 1, #TipsWindow.sortButtons do
        local window = TipsWindow.sortButtons[index]
        ButtonSetPressedFlag( window, index == sortType )
    end
    
    -- Update the Arrow
    WindowSetShowing( "TipsWindowSortButtonBarUpArrow", sortOrder == DataUtils.SORT_ORDER_UP )
    WindowSetShowing( "TipsWindowSortButtonBarDownArrow", sortOrder == DataUtils.SORT_ORDER_DOWN )

    local window = TipsWindow.sortButtons[sortType]

    if window
    then
        if( sortOrder == DataUtils.SORT_ORDER_UP ) then		
            WindowClearAnchors( "TipsWindowSortButtonBarUpArrow" )
            WindowAddAnchor("TipsWindowSortButtonBarUpArrow", "left", window, "left", 0, 0 )
        else
            WindowClearAnchors( "TipsWindowSortButtonBarDownArrow" )
            WindowAddAnchor("TipsWindowSortButtonBarDownArrow", "right", window, "right", 0, 0 )
        end
    else
        WindowSetShowing( "TipsWindowSortButtonBarUpArrow", false )
        WindowSetShowing( "TipsWindowSortButtonBarDownArrow", false )
    end


end

----------------------------------------------------------------------------------------------------
-- Tutorials
----------------------------------------------------------------------------------------------------

local TUTORIALS = 
{
    { tutorialId=TutorialWindow.TUTORIAL_MODE_BASIC_CONTROLS,  stringId=StringTables.Tutorial.BASIC_CONTROLS_NAME },
    { tutorialId=TutorialWindow.TUTORIAL_MODE_QUESTS,          stringId=StringTables.Tutorial.QUESTS_NAME },
    { tutorialId=TutorialWindow.TUTORIAL_MODE_COMBAT,          stringId=StringTables.Tutorial.COMBAT_NAME },
    { tutorialId=TutorialWindow.TUTORIAL_MODE_INVENTORY,       stringId=StringTables.Tutorial.INVENTORY_NAME },
    { tutorialId=TutorialWindow.TUTORIAL_MODE_TRAINING,        stringId=StringTables.Tutorial.TRAINING_NAME },
    { tutorialId=TutorialWindow.TUTORIAL_MODE_PQ,              stringId=StringTables.Tutorial.PQ_NAME },
    { tutorialId=TutorialWindow.TUTORIAL_MODE_GROUPING,        stringId=StringTables.Tutorial.GROUPING_NAME },
    { tutorialId=TutorialWindow.TUTORIAL_MODE_TOK,             stringId=StringTables.Tutorial.TOK_NAME },
    { tutorialId=TutorialWindow.TUTORIAL_MODE_SCENARIOS,       stringId=StringTables.Tutorial.SCENARIO_NAME },
    { tutorialId=TutorialWindow.TUTORIAL_MODE_WARCAMP,         stringId=StringTables.Tutorial.WAR_CAMP_NAME },
}

function TipsWindow.InitTutorialCombo()

    LabelSetText( "TipsWindowTutorialsLabel", GetHelpString(StringTables.Help.LABEL_TIPS_TUTORIALS )  )
    ButtonSetText( "TipsWindowTutorialsShowButton", GetHelpString(StringTables.Help.BUTTON_TIPS_SHOW_TUTORIAL ) )

    for _, data in ipairs( TUTORIALS )
    do
        ComboBoxAddMenuItem( "TipsWindowTutorialsComboBox", GetStringFromTable( "TutorialStrings", data.stringId ) )
    end

end

function TipsWindow.ShowTutorial()
   
    local index = ComboBoxGetSelectedMenuItem( "TipsWindowTutorialsComboBox" )
   
    if( TUTORIALS[ index ] )
    then
        TutorialWindow.SetModeDelayed( TUTORIALS[ index ].tutorialId )
    end 
end
