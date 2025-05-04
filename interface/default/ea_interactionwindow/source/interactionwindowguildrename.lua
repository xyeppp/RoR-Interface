
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

InteractionWindowGuildRename = {}
InteractionWindowGuildRename.DEFAULT_WINDOW_HEIGHT = 275
InteractionWindowGuildRename.DEFAULT_WINDOW_WIDTH = 450

InteractionWindowGuildRename.InteractionNpcId = 0
InteractionWindowGuildRename.GuildName = L""

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------

local function SetErrorText( text )
    if ( text == nil )
    then
        text = L""
    end

    LabelSetText( "InteractionWindowGuildRenameError", text )

    -- Resize the window to adjust for the error label changing size.
    local _, y = LabelGetTextDimensions( "InteractionWindowGuildRenameError" )
    WindowSetDimensions( "InteractionWindowGuildRename",
        InteractionWindowGuildRename.DEFAULT_WINDOW_WIDTH,
        InteractionWindowGuildRename.DEFAULT_WINDOW_HEIGHT + y )
end

----------------------------------------------------------------
-- InteractionWindowGuildRename Functions
----------------------------------------------------------------

function InteractionWindowGuildRename.Initialize()
    -- Register event handlers
    WindowRegisterEventHandler( "InteractionWindowGuildRename", SystemData.Events.INTERACT_GUILD_RENAME_BEGIN, "InteractionWindowGuildRename.OnInteractBegin" )
    WindowRegisterEventHandler( "InteractionWindowGuildRename", SystemData.Events.INTERACT_DONE, "InteractionWindowGuildRename.OnInteractEnd" )
    WindowRegisterEventHandler( "InteractionWindowGuildRename", SystemData.Events.INTERACT_GUILD_NPC_ERROR, "InteractionWindowGuildRename.OnError" )

    -- Set text.
    LabelSetText( "InteractionWindowGuildRenameTitleBarText", GetString( StringTables.Default.LABEL_GUILD_RENAME_GUILD_WINDOW_TITLE ) )
    LabelSetText( "InteractionWindowGuildRenameDialogText", GetString( StringTables.Default.LABEL_GUILD_RENAME_WINDOW_TEXT ) )
    LabelSetText( "InteractionWindowGuildRenameNamePrompt", GetString( StringTables.Default.LABEL_GUILD_NAME ) )

    ButtonSetText( "InteractionWindowGuildRenameRenameGuildButton", GetString( StringTables.Default.LABEL_ACCEPT ) )
end

function InteractionWindowGuildRename.Shutdown()

end

function InteractionWindowGuildRename.Show()
    WindowSetShowing( "InteractionWindowGuildRename", true )
end

function InteractionWindowGuildRename.Hide()
    WindowSetShowing( "InteractionWindowGuildRename", false );
    EA_Window_InteractionBase.Done()
end

function InteractionWindowGuildRename.OnShown()
    WindowUtils.OnShown( InteractionWindowGuildRename.Hide, WindowUtils.Cascade.MODE_HIGHLANDER )
end

function InteractionWindowGuildRename.OnInteractBegin( interactNpcId )
    InteractionWindowGuildRename.InteractionNpcId = interactNpcId
    InteractionWindowGuildRename.Show()

    -- Clear text.
    TextEditBoxSetText( "InteractionWindowGuildRenameGuildNameEditBox", L"" )
    SetErrorText( L"" )
end

function InteractionWindowGuildRename.OnInteractEnd()
    InteractionWindowGuildRename.Hide()
end

function InteractionWindowGuildRename.OnError( errorText )
    -- Set the error text.
    SetErrorText( errorText )
end

function InteractionWindowGuildRename.OnLButtonUpAcceptButton()
    InteractionWindowGuildRename.GuildName = InteractionWindowGuildRenameGuildNameEditBox.Text
    BroadcastEvent( SystemData.Events.GUILD_COMMAND_RENAME )

    -- Close the window.
    InteractionWindowGuildRename.Hide()
end
