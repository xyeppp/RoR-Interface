----------------------------------------------------------------
-- Local Functions (placed here to avoid dependency issues)
----------------------------------------------------------------

----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_Rename = {}

local containerWindowName = "EA_Window_Rename_Container"
local windowName = "EA_Window_Rename"

function EA_Window_Rename.Initialize()
    -- Set the text of all the buttons/labels
    LabelSetText( windowName.."KeyInputLabel", GetPregameString( StringTables.Pregame.LABEL_RENAME_EDITBOX ) )
    LabelSetText( windowName.."TitleBarText", GetPregameString( StringTables.Pregame.LABEL_RENAME_WINDOW ) )
    LabelSetText( windowName.."MessageText", GetPregameString( StringTables.Pregame.LABEL_RENAME_PLAYER ) )
    ButtonSetText( windowName.."Accept", GetPregameString( StringTables.Pregame.LABEL_RENAME_ACCEPT) )
    
    WindowRegisterEventHandler( windowName, SystemData.Events.CHARACTER_PREGAME_NAMING_CONFLICT_RESPONSE, "EA_Window_Rename.Response" )
end

function EA_Window_Rename.Hide()
    WindowSetShowing( containerWindowName, false )
end

function EA_Window_Rename.LockInput()
    ButtonSetDisabledFlag(windowName.."Accept", true)
end

function EA_Window_Rename.UnlockInput()
    ButtonSetDisabledFlag(windowName.."Accept", false)
end

function EA_Window_Rename.OnAcceptButton()
    if ( not ButtonGetDisabledFlag(windowName.."Accept") )
    then
        local newName = TextEditBoxGetText( windowName.."TextInput" )
        if( newName ~= L"" )
        then
            LabelSetText( windowName.."MessageText", GetPregameString( StringTables.Pregame.LABEL_RENAME_VALIDATING_NEW_NAME) )
            EA_Window_Rename.LockInput()
            NamingConflictRequestNewName( newName )
        else
            LabelSetText( windowName.."MessageText", GetPregameString( StringTables.Pregame.LABEL_RENAME_VALIDATING_ERROR ) )
        end
    end
end

function EA_Window_Rename.PopUp()
    if ( DoesWindowExist( containerWindowName ) )
    then
        WindowSetShowing( containerWindowName, true )
    else
        CreateWindow( containerWindowName, true )
    end
    
    LabelSetText( windowName.."MessageText", GetPregameString( StringTables.Pregame.LABEL_RENAME_PLAYER ) )
    TextEditBoxSetText( windowName.."TextInput", L"" )
    EA_Window_Rename.UnlockInput()
    WindowAssignFocus(windowName.."TextInput", true)
end

function EA_Window_Rename.Response( success )
    if( success )
    then
        EA_Window_Rename.Hide()
    else
        LabelSetText( windowName.."MessageText", GetPregameString( StringTables.Pregame.LABEL_RENAME_VALIDATING_ERROR ) )
    end
    
    EA_Window_Rename.UnlockInput()
end
