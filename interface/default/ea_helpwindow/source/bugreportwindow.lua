----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

BugReportWindow = {}

BugReportWindow.bugTypes = {}
BugReportWindow.bugTypes[GameData.BugReport.ART]						= {labelID = StringTables.Help.HEADER_BUG_ART}
BugReportWindow.bugTypes[GameData.BugReport.CHARACTER]					= {labelID = StringTables.Help.HEADER_BUG_CHARACTER}
BugReportWindow.bugTypes[GameData.BugReport.CRASH]						= {labelID = StringTables.Help.HEADER_BUG_CRASH}
BugReportWindow.bugTypes[GameData.BugReport.ITEM]						= {labelID = StringTables.Help.HEADER_BUG_ITEM}
BugReportWindow.bugTypes[GameData.BugReport.MONSTER_PATHING]			= {labelID = StringTables.Help.HEADER_BUG_MONSTER_PATHING}
BugReportWindow.bugTypes[GameData.BugReport.OTHER]						= {labelID = StringTables.Help.HEADER_BUG_OTHER}
BugReportWindow.bugTypes[GameData.BugReport.QUESTS_AND_PUBLIC_QUESTS]	= {labelID = StringTables.Help.HEADER_BUG_QUESTS}

BugReportWindow.selectedType = GameData.BugReport.OTHER

function BugReportWindow.Initialize()       

    BugReportWindow.IntializeCheckBoxes()

    -- Setup component text
    LabelSetText( "BugReportWindowTitleBarText", GetHelpString(StringTables.Help.TEXT_HELP_TITLE_BAR) )
    LabelSetText( "BugReportWindowHeaderText", GetHelpString( StringTables.Help.HEADER_BUG) )
    LabelSetText( "BugReportWindowBugReportDescriptionHeader", GetHelpString( StringTables.Help.HEADER_BUG_REPORT_DESCRIPTION) )
    LabelSetText( "BugReportWindowDetailsHeader", GetHelpString( StringTables.Help.HEADER_BUG_DETAILS) )

    ButtonSetText( "BugReportWindowSubmitButton", GetHelpString( StringTables.Help.BUTTON_SUBMIT) )
    ButtonSetText( "BugReportWindowClearButton", GetHelpString( StringTables.Help.BUTTON_CLEAR) )
    ButtonSetText( "BugReportWindowBackButton", GetHelpString( StringTables.Help.BUTTON_BACK) )
end

function BugReportWindow.IntializeCheckBoxes()

	for bugTypeIndex, bugTypeData in pairs(BugReportWindow.bugTypes) do
		LabelSetText("BugReportType"..bugTypeIndex.."Label", GetHelpString(bugTypeData.labelID) )
		ButtonSetStayDownFlag("BugReportType"..bugTypeIndex.."Button", true)

		DefaultColor.SetLabelColor("BugReportType"..bugTypeIndex.."Label", DefaultColor.YELLOW)
	end
	
	BugReportWindow.SelectBugType( BugReportWindow.selectedType )
end

function BugReportWindow.Shutdown()

end

function BugReportWindow.Show()
    WindowSetShowing( "BugReportWindow", true )
end

function BugReportWindow.Hide()
    WindowSetShowing( "BugReportWindow", false )
end

function BugReportWindow.ToggleShowing()
    if ( BugReportWindow.IsShowing() == true ) then
        BugReportWindow.Hide()
    else
        BugReportWindow.Show()
    end
end

function BugReportWindow.IsShowing()
    return WindowGetShowing( "BugReportWindow" )
end

function BugReportWindow.SelectBugType( type )
    -- Select it
    BugReportWindow.selectedType = type

    -- Unselect others
    for bugTypeIndex, bugTypeData in pairs(BugReportWindow.bugTypes) do
        ButtonSetPressedFlag( "BugReportType"..bugTypeIndex.."Button", BugReportWindow.selectedType == bugTypeIndex )
    end
end

function BugReportWindow.Submit()
	-- SendHelpMessage expects the following params:
	--		param1 (number) = The type of help message this is, defined by GameData.HelpType.*
	--		param2 (number) = The subtype, aka topic, of this message.  Defined by GameData.AppealTopic.*
	--		param3 (WString) = The sub-subtype, aka topic category, of this message. Defined by EViolation
	--		param4 (WString) = The details field of this message.
	--		param5 (number)  = field ID for string 1
	--		param6 (WString) = Generic string1 param
	--		param7 (number)  = field ID for string 2
	--		param8 (WString) = Generic string2 param
	--		param9 (number)  = field ID for string 3
	--		param10 (WString)= Generic string3 param
	--		param11 (number) = field ID for string 4
	--		param12 (WString)= Generic string4 param
	
	SendHelpMessage(GameData.HelpType.CREATE_BUG_REPORT, BugReportWindow.selectedType, L"", 
					TextEditBoxGetText("BugReportWindowText"), 0, L"", 0, L"", 0, L"", 0, L"")

    --DEBUG(L"Reporting Bug: Type="..BugReportWindow.selectedType..L", Text="..BugReportWindowReportText.Text )
    --SendBugReport( BugReportWindow.selectedType, BugReportWindowReportText.Text )
    BugReportWindow.Hide()
end

function BugReportWindow.Clear()
    BugReportWindow.SelectBugType( GameData.BugReport.OTHER )
    TextEditBoxSetText( "BugReportWindowText", L"" )
end

function BugReportWindow.OnLButtonUpBackButton()
	BugReportWindow.Hide()
	EA_Window_Help.OnShown()
end

function BugReportWindow.OnSelectBugType()
    local type = WindowGetId(SystemData.ActiveWindow.name) 
    BugReportWindow.SelectBugType( type )
end

function BugReportWindow.OnShown()
    --WindowUtils.OnShown(BugReportWindow.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
    BugReportWindow.Clear()
end

function BugReportWindow.OnHidden()
    WindowUtils.OnHidden()
end