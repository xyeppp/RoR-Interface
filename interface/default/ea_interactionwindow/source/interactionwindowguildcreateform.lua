
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

InteractionWindowGuildCreateForm = {}
InteractionWindowGuildCreateForm.DEFAULT_WINDOW_HEIGHT = 450
InteractionWindowGuildCreateForm.DEFAULT_WINDOW_WIDTH = 450

InteractionWindowGuildCreateForm.GuildNPC_ID = 0
InteractionWindowGuildCreateForm.GuildCreationCost = 1


----------------------------------------------------------------
-- InteractionWindowGuildCreateForm Functions
----------------------------------------------------------------

local function SetErrorText( text )
    if( text == nil )
    then
        text = L""
    end
    
    LabelSetText( "InteractionWindowGuildCreateFormError", text )
    
    local _, y = LabelGetTextDimensions( "InteractionWindowGuildCreateFormError" )
    WindowSetDimensions( "InteractionWindowGuildCreateForm",
        InteractionWindowGuildCreateForm.DEFAULT_WINDOW_WIDTH,
        InteractionWindowGuildCreateForm.DEFAULT_WINDOW_HEIGHT + y )
end

-- OnInitialize Handler
function InteractionWindowGuildCreateForm.Initialize()
    
    -- Event Handlers
    WindowRegisterEventHandler( "InteractionWindowGuildCreateForm", SystemData.Events.INTERACT_GUILD_SHOW_FORM, "InteractionWindowGuildCreateForm.Show" )
    WindowRegisterEventHandler( "InteractionWindowGuildCreateForm", SystemData.Events.INTERACT_GUILD_NPC_ERROR, "InteractionWindowGuildCreateForm.HandleError" )
    WindowRegisterEventHandler( "InteractionWindowGuildCreateForm", SystemData.Events.INTERACT_GUILD_CREATION_COMPLETE, "InteractionWindowGuildCreateForm.CreationComplete" )
    WindowRegisterEventHandler( "InteractionWindowGuildCreateForm", SystemData.Events.INTERACT_DONE, "InteractionWindowGuildCreateForm.Hide" )

    -- Text labels
    LabelSetText( "InteractionWindowGuildCreateFormTitleBarText", GetString(StringTables.Default.LABEL_GUILD_CREATE_GUILD_WINDOW_TITLE) )
    LabelSetText( "InteractionWindowGuildCreateFormNamePrompt", GetString(StringTables.Default.LABEL_GUILD_NAME) )

    -- Button Labels
    ButtonSetText( "CreateGuildButton",	 GetString ( StringTables.Default.LABEL_GUILD_COMMAND_CREATE_GUILD_BUTTON ) )
end

-- OnShutdown Handler
function InteractionWindowGuildCreateForm.Shutdown()

end

function InteractionWindowGuildCreateForm.OnShown()
    WindowUtils.OnShown( InteractionWindowGuildCreateForm.Hide, WindowUtils.Cascade.MODE_HIGHLANDER )
end

function InteractionWindowGuildCreateForm.Show()
    WindowSetShowing( "InteractionWindowGuildCreateForm", true )
    
    -- Determine the correct currency label and monetary value for the
    -- brass amount sent to us from the server
    local currencyText = StringTables.Default.LABEL_CURRENCY_BRASS
    local creationCost = InteractionWindowGuildCreateForm.GuildCreationCost
    local brassPerGold = GetNumBrassPerGold()
    local brassPerSilver = GetNumBrassPerSilver()

    if( creationCost >= brassPerGold ) then
        creationCost = creationCost / brassPerGold
        currencyText = GetString(StringTables.Default.LABEL_CURRENCY_GOLD)
    elseif( creationCost >= brassPerSilver and creationCost < brassPerGold ) then
        creationCost = creationCost / brassPerSilver
        currencyText = GetString(StringTables.Default.LABEL_CURRENCY_SILVER)
    end

    -- Set the label's text based on the data received from the server
    local text = GetFormatStringFromTable( "default", StringTables.Default.LABEL_GUILD_FORMATION_RULES, { creationCost, currencyText } )
    LabelSetText( "InteractionWindowGuildCreateFormDialogText", text )
    ScrollWindowSetOffset( "GuildFormScrollWindow", 0 )
    ScrollWindowUpdateScrollRect( "GuildFormScrollWindow" )
    
    -- Clear Error Text
    SetErrorText( L"" )
    
end

function InteractionWindowGuildCreateForm.Hide()   
    
    WindowSetShowing( "InteractionWindowGuildCreateForm", false );
    EA_Window_InteractionBase.Done()
    
end

function InteractionWindowGuildCreateForm.HandleError( errorText )
    SetErrorText( errorText )
end

function InteractionWindowGuildCreateForm.CreationComplete()
    -- DEBUG(L"Entered InteractionWindowGuildCreateForm.CreationComplete")
    
    InteractionWindowGuildCreateForm.Hide()
end

function InteractionWindowGuildCreateForm.GuildCommandCreateGuild()

    InteractionWindowGuildCreateForm.GuildName = GuildNameEditBox.Text
    BroadcastEvent( SystemData.Events.GUILD_COMMAND_CREATE )
end

