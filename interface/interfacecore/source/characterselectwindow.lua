----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

CharacterSelectWindow = {}

CharacterSelectWindow.FADE_IN_TIME = 2

CharacterSelectWindow.iState = -1

CharacterSelectWindow.iQueueTime = 0
CharacterSelectWindow.iQueuePos = 0
CharacterSelectWindow.iQueueSize = 0
CharacterSelectWindow.iLastUpdate = 0
CharacterSelectWindow.iMaxQueueTime = 65535 -- the max server time (0xFFFF) is sent down when the server doesn't know what time to send so we won't display a time at that time
CharacterSelectWindow.iCharacterSelection = 0
CharacterSelectWindow.iRealm = -1
CharacterSelectWindow.iRaceChoice = -1
CharacterSelectWindow.iCareerChoice = -1
CharacterSelectWindow.iMouseOver = -1
CharacterSelectWindow.iRealmOver = -1
CharacterSelectWindow.iGender = GameData.Gender.MALE
CharacterSelectWindow.bUseTemplate = false
CharacterSelectWindow.featuresData = {}
CharacterSelectWindow.bMustUseATemplate = false
CharacterSelectWindow.bFirstCharUpdate = false -- this is used to decide if we need to go to the character create screen or the character select screen
CharacterSelectWindow.bAllowTemplatesInPublicBuilds = false
CharacterSelectWindow.iNumOrderPages = 0
CharacterSelectWindow.iNumDestructionPages = 0
CharacterSelectWindow.numTemplates = 0
CharacterSelectWindow.bNoTemplateOptionDisplayed = false

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local CharacterDataCareers = {}

local featureStrings = {}

local REALM_LIMIT_ORDER_ONLY = 2
local REALM_LIMIT_DESTRUCTION_ONLY = 3

CharacterSelectWindow.trialPlayer = false
CharacterSelectWindow.buddiedPlayer = false

----------------------------------------------------------------
-- Constants
----------------------------------------------------------------
local STATE_CHARACTER_LOGIN = 0
local STATE_CHARACTER_SERVER_SELECT = 1
local STATE_CHARACTER_QUICK_ENTRY = 2
local STATE_CHARACTER_SELECT = 3
local STATE_CHARACTER_CREATE_ARMY = 4
local STATE_CHARACTER_CREATE_CAREER = 5
local STATE_CHARACTER_CREATE_FEATURE_IN = 6
local STATE_CHARACTER_CREATE_FEATURE_OUT = 7

local MAX_FEATURES = 8

----------------------------------------------------------------
-- CharacterSelectWindow Functions
----------------------------------------------------------------
local function ShouldShowCustomization()
    return CharacterSelectWindow.iState == STATE_CHARACTER_CREATE_FEATURE_IN 
      or CharacterSelectWindow.iState == STATE_CHARACTER_CREATE_FEATURE_OUT
end

local function GetRawCharacterPageIndexFromRealmIndex( realm, page )
    if ( realm == GameData.Realm.ORDER )
    then
        return page
    else
        return page + CharacterSelectWindow.iNumOrderPages
    end
end

local function GetRealmCharacterPageIndexFromRawIndex( rawIndex )
    if ( rawIndex > CharacterSelectWindow.iNumOrderPages )
    then
        return GameData.Realm.DESTRUCTION, rawIndex - CharacterSelectWindow.iNumOrderPages
    else
        return GameData.Realm.ORDER, rawIndex
    end
end

local function GetTotalNumRawCharacterPages()
    return CharacterSelectWindow.iNumOrderPages + CharacterSelectWindow.iNumDestructionPages
end

-- OnInitialize Handler
function CharacterSelectWindow.Initialize()
    --TextLogSetIncrementalSaving( "UiLog", true, L"logs/uilog.log");
    --TextLogSetEnabled( "UiLog", true )
    --WindowSetShowing("DebugWindow", true)
    
    
    LoadStringTable("PregameCreationFeatures", "data/strings/<LANG>/pregame", "creationfeatures.txt", "cache/<LANG>", "StringTables.PregameCreationFeatures" )

    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_STATE_UPDATED, "CharacterSelectWindow.ForceUpdateState")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_QUEUE_UPDATED, "CharacterSelectWindow.OnQueueUpdated")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_CHARACTER_SELECTION_UPDATED, "CharacterSelectWindow.CharacterSelectionUpdated")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_CREATE_RACE_UPDATED, "CharacterSelectWindow.RaceUpdated")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_CREATE_CAREER_UPDATED, "CharacterSelectWindow.CareerUpdated")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_REALM_UPDATED, "CharacterSelectWindow.RealmUpdated")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_CREATE_GENDER_UPDATED, "CharacterSelectWindow.GenderUpdated")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_MOUSE_OVER_UPDATED, "CharacterSelectWindow.MouseOverUpdated")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_REALM_OVER_UPDATED, "CharacterSelectWindow.RealmOverUpdated")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_CREATE_FEATURES_UPDATED, "CharacterSelectWindow.FeaturesUpdated")
    
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_TEMPLATES_UPDATED, "CharacterSelectWindow.UpdateCharacterTemplatesList")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_PREGAME_RANDOM_NAME_UPDATE_CHAR_SELECT, "CharacterSelectWindow.UpdateCharacterSelectRandomName")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_PREGAME_RANDOM_NAME_UPDATE_FORCED_SELECT, "CharacterSelectWindow.UpdateCharacterForcedRandomName")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_PREGAME_FORCED_RANDOM_NAME_START, "CharacterSelectWindow.ShowForcedNameSelectWindow")
    
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_SELECT_PAGES_UPDATED, "CharacterSelectWindow.UpdateNumCharacters")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_SELECT_CURRENT_PAGE_UPDATED, "CharacterSelectWindow.UpdateCurrentPage")
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_SELECT_LOCKOUT_TIMER_UPDATED, "CharacterSelectWindow.LockoutTimerUpdated")
    
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_PREGAME_NAMING_CONFLICT_POP_UP_WINDOW, "EA_Window_Rename.PopUp" )
    
    WindowRegisterEventHandler( "CharacterSelectWindow", SystemData.Events.CHARACTER_SELECT_NUM_PAID_NAME_CHANGES_UPDATED, "CharacterSelectWindow.TogglePNCButton" )
       
    -- Button Text
    ButtonSetText("CharacterSelectServer", GetPregameString( StringTables.Pregame.LABEL_SERVER ) )
    ButtonSetText("CharacterSelectPlay", GetPregameString( StringTables.Pregame.LABEL_PLAY ) )
    ButtonSetText("CharacterSelectNewChar", GetPregameString( StringTables.Pregame.LABEL_CREATE_CHAR ) )
    ButtonSetText("CharacterSelectQuit", GetPregameString( StringTables.Pregame.LABEL_QUIT ) )
    ButtonSetText("CharacterSelectDeleteButton", GetPregameString( StringTables.Pregame.LABEL_DELETE ) )
    ButtonSetText("CharacterSelectUpgradeTrial", GetPregameString( StringTables.Pregame.LABEL_UPGRADE ) )
    ButtonSetText("CharacterSelectPNC", GetPregameString( StringTables.Pregame.LABEL_PNC_BUTTON ) )

    ButtonSetText("CharacterSelectBack", GetPregameString( StringTables.Pregame.LABEL_BACK ) )
    ButtonSetText("CharacterSelectCareerToFeature", GetPregameString( StringTables.Pregame.LABEL_NEXT ) )
    ButtonSetText("CharacterSelectCareerCreateChar", GetPregameString( StringTables.Pregame.LABEL_DONE ) )

    LabelSetText("CharacterSelectNameLabel", GetPregameString( StringTables.Pregame.LABEL_NAME ) )
    ButtonSetText("CharacterSelectRandomName", GetPregameString( StringTables.Pregame.LABEL_BUTTON_RANDOM_NAME ) )
    ButtonSetText("CharacterSelectRandomFeatures", GetPregameString( StringTables.Pregame.LABEL_RANDOM ) )

    ButtonSetText("CharacterSelectSettingsButton", GetPregameString( StringTables.Pregame.LABEL_USER_SETTINGS ) )
    ButtonSetText("CharacterSelectUiModButton", GetPregameString( StringTables.Pregame.LABEL_UI_MODS ) )
    WindowSetShowing("CharacterSelectUiModButton", IsInternalBuild() ) -- Hide for public builds atm
        
    WindowSetShowing("CharacterSelectTemplateOptions", IsInternalBuild() )
    LabelSetText("CharacterSelectTemplateOptionsTemplatesLabel", GetPregameString( StringTables.Pregame.LABEL_FEATURE_TEMPLATE ))
    
    WindowSetShowing("CharacterSelectCharacterSlotsAvailableText", false)
    
    -- Hide the paid name change button initially until a character is selected
    WindowSetShowing("CharacterSelectPNC", false)
        
    CharacterSelectWindow.InitDeleteDialog()
    CharacterSelectWindow.InitForcedRandomNameDialog()

    -- set the realm bonus icons
    DynamicImageSetTextureSlice( "CharacterSelectInfoBoxLeftIconBase", "RealmBonus-Order" )
    DynamicImageSetTextureSlice( "CharacterSelectInfoBoxRightIconBase", "RealmBonus-Destruction" )

    -- the careers are set to valid on the server now so there is only the one set of careers
    CharacterSelectWindow.InitializeCharacterDataCareers()

    CharacterSelectWindow.iState = -1
    CharacterSelectWindow.bFirstCharUpdate = true
    
    WindowSetShowing("QueueStatusWindow", false)
    ButtonSetStayDownFlag("CharacterSelectPlay", true )
    CharacterSelectWindow.ResetPlayButton()
    
    CharacterSelectWindow.InitializeFeatureStrings()

    CharacterSelectWindow.ColorizeInfoBoxes(CharacterSelectWindow.iMouseOver)
    WindowSetAlpha("CharacterSelectInfoBoxRightBackgroundBackground", .5)
    WindowSetAlpha("CharacterSelectInfoBoxLeftBackgroundBackground", .5)
    WindowSetAlpha("CharacterSelectInfoBox2RightBackgroundBackground", .5)
    ButtonSetTextColor( "CharacterSelectNewChar", Button.ButtonState.DISABLED, DefaultColor.MEDIUM_GRAY.r, DefaultColor.MEDIUM_GRAY.g, DefaultColor.MEDIUM_GRAY.b)

    LabelSetText("CharacterSelectAutoLoggedText", GetStringFormatFromTable("Pregame", StringTables.Pregame.LABEL_AUTO_LOGGED_IN, {GameData.Account.ServerName}) )
    WindowSetAlpha("CharacterSelectAutoLoggedBackgroundBackground", .75)

    -- Fade the window in
    WindowStartAlphaAnimation( "CharacterSelectWindow", Window.AnimationType.SINGLE_NO_RESET, 0.0, 1.0, CharacterSelectWindow.FADE_IN_TIME, false, 0, 0)

    -- update the server name label if the LobbyBackground window exists
    if (DoesWindowExist("LobbyBackground")) then
        LobbyBackground.UpdateServerName()
    end

    -- initialize the mouse over block state
    CharacterSelectWindow.BlockMouseOver(false)

    -- get the player data, this indicates if the player is a trial player and/or a buddied trial player
    CharacterSelectWindow.RefreshPlayerData()
    -- show the upgrade button if this is a trial player
    if CharacterSelectWindow.trialPlayer
    then
        WindowSetShowing("CharacterSelectUpgradeTrial", true)
    else
        WindowSetShowing("CharacterSelectUpgradeTrial", false)
    end
    
    -- update trial account info text
    CharacterSelectWindow.UpdateTrialAccountInfoText()

    -- if the transfer flag hasn't been used yet
    if not SystemData.Server.TransferFlagUsed
    then
        -- set the use flag
        SystemData.Server.TransferFlagUsed = true
        
        -- if the transfer flag is on and the server isn't set to not show the transfer message
        if (SystemData.Server.TransferFlag == 1)
        then
        
            local serverStatus = EA_Window_TransferPopup.OPEN_SERVER
            
            local serverList = GetServerList()
            for _, serverData in ipairs( serverList )
            do
                if ( SystemData.Server.ID == serverData.id )
                then
                    if ( serverData.legacy )
                    then
                        serverStatus = EA_Window_TransferPopup.LEGACY_SERVER
                    end
                    break
                end
            end
    
            EA_Window_TransferPopup.Show( serverStatus)
        end
    end
    
    -- Character Delete Handler
    EA_UiProfilesCharacterDeleteHandler.Initialize()
    
    CharacterSelectWindow.UpdateNumCharacters()
end

-- OnShutdown Handler
function CharacterSelectWindow.Shutdown()

    UnloadStringTable( "PregameCreationFeatures" )
end

function CharacterSelectWindow.Update( elapsedTime )

    if ( WindowGetShowing( "CharacterSelectMultirealmInfo" ) )
    then
        CharacterSelectWindow.UpdateMultirealmInfo( true )
    end
    
    -- Don't drop below 1 second left, and stop counting at that point.
    if (CharacterSelectWindow.iQueueTime > 0.8) then

        CharacterSelectWindow.iQueueTime = CharacterSelectWindow.iQueueTime - elapsedTime
        
        if (CharacterSelectWindow.iQueueTime <= 0.8) then
            CharacterSelectWindow.iQueueTime = 0.8
        end
        
        local currentSec = math.floor( CharacterSelectWindow.iQueueTime )
        
        -- Only update the display when the seconds value has changed since our last display update
        if (CharacterSelectWindow.iLastUpdate ~= currentSec) then
            CharacterSelectWindow.iLastUpdate = currentSec
            CharacterSelectWindow.UpdateQueueStatus()
        end
    end
end

function CharacterSelectWindow.CanClickPlayButton()
    -- Can't click Play button if they are in a queue
    if ( CharacterSelectWindow.iQueueTime > 0 )
    then
        return false
    end
    
    -- Can't click Play if we're already loading into the world
    if ( DataUtils.IsWorldLoading() )
    then
        return false
    end
    
    -- Verify they have a valid character selected and that they aren't locked out of its realm
    if ( CharacterSelectWindow.iCharacterSelection ~= -1 )
    then
        local charSlot = GameData.Account.CharacterSlot[CharacterSelectWindow.iCharacterSelection+1]
        if ( charSlot ~= nil )
        then
            if ( ( GameData.Account.CharacterCreation.LastSwitchedToRealm == GameData.Realm.NONE ) or ( GameData.Account.CharacterCreation.LastSwitchedToRealm == charSlot.Realm ) )
            then
                return true
            end
        end
    end
    
    return false
end

function CharacterSelectWindow.ResetPlayButton()
    if ( CharacterSelectWindow.CanClickPlayButton() )
    then
        CharacterSelectWindow.TogglePNCButton()
        ButtonSetDisabledFlag( "CharacterSelectPlay", false )
    else
        WindowSetShowing( "CharacterSelectPNC", false )
        ButtonSetDisabledFlag( "CharacterSelectPlay", true )
        ButtonSetPressedFlag( "CharacterSelectPlay", false )
    end
end

function CharacterSelectWindow.LockoutTimerUpdated()
    if ( CharacterSelectWindow.iState == STATE_CHARACTER_SELECT )
    then
        CharacterSelectWindow.UpdateMultirealmInfo( true )
    end
    
    CharacterSelectWindow.ResetPlayButton()
end

function CharacterSelectWindow.UpdateNumCharacters()

    -- Update whether the New character button is enabled based on new number of chars available
    if ( CharacterSelectWindow.GetNumSlotsLeft() == 0 )
    then
        ButtonSetDisabledFlag( "CharacterSelectNewChar", true )
        ButtonSetPressedFlag( "CharacterSelectNewChar", false )
    else
        ButtonSetDisabledFlag( "CharacterSelectNewChar", false )
    end
    
    -- If the Slots Available text is showing, then update it, as it may have changed
    if ( WindowGetShowing( "CharacterSelectCharacterSlotsAvailableText" ) )
    then
        CharacterSelectWindow.ShowAvailableSlots()
    end
    
    -- Update the character page changer
    local orderNumPages, destructionNumPages = PregameGetCharacterSelectNumPages()
    local bNeedsPageChanger = ( orderNumPages + destructionNumPages > 1 )
    local bIsInCharacterSelectMode = (CharacterSelectWindow.iState == STATE_CHARACTER_SELECT)
    
    WindowSetShowing( "CharacterSelectPageChange", bIsInCharacterSelectMode and bNeedsPageChanger )
    
    CharacterSelectWindow.iNumOrderPages = orderNumPages
    CharacterSelectWindow.iNumDestructionPages = destructionNumPages
        
    ComboBoxClearMenuItems( "CharacterSelectPageChangeComboBox" )
    
    local realmText = GetPregameString( StringTables.Pregame.LABEL_ORDER )
    for pageNum = 1, orderNumPages
    do
        local text = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_PAGE_ITEM, { realmText, towstring(pageNum) } )
        ComboBoxAddMenuItem( "CharacterSelectPageChangeComboBox", text )
    end
    
    realmText = GetPregameString( StringTables.Pregame.LABEL_CHAOS )
    for pageNum = 1, destructionNumPages
    do
        local text = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_PAGE_ITEM, { realmText, towstring(pageNum) } )
        ComboBoxAddMenuItem( "CharacterSelectPageChangeComboBox", text )
    end
    
    CharacterSelectWindow.UpdateCurrentPage( PregameGetCharacterSelectPage() )

end

function CharacterSelectWindow.UpdateCurrentPage( currentRealm, currentPage )
    ComboBoxSetSelectedMenuItem( "CharacterSelectPageChangeComboBox", GetRawCharacterPageIndexFromRealmIndex( currentRealm, currentPage ) )
end

-- OnLButtonUp Handler for the 'Play' Button
function CharacterSelectWindow.Play( flags, mouseX, mouseY )

    if (ButtonGetDisabledFlag("CharacterSelectPlay"))
    then
        return
    end

    if STATE_CHARACTER_SELECT ~= CharacterSelectWindow.iState
    then
        return
    end

	-- The character should NOT be playable if it belongs to a trial account and rank > GameData.TrialAccount.MaxLevel.
	-- Popup a warning message dialog box to alert user
	if( SystemData.Territory.TAIWAN )
    then
        if CharacterSelectWindow.trialPlayer
        then
            local selectedSlot = GameData.Account.CharacterSlot[ GameData.Account.SelectedCharacterSlot ]
            if ( ( selectedSlot ~= nil ) and ( selectedSlot.Level > GameData.TrialAccount.MaxLevel ) )
            then
                DialogManager.MakeTwoButtonDialog( GetString(StringTables.Default.TEXT_UPGRADE_ACCOUNT_FOR_HIGH_LEVEL_CHARACTER),
                                                   GetString(StringTables.Default.LABEL_YES), EA_TrialAlertWindow.OnUpgradeModal,
                                                   GetString(StringTables.Default.LABEL_NO), CharacterSelectWindow.ResetPlayButton(),
                                                   nil, nil, nil, nil, DialogManager.TYPE_MODAL )
                return
            end
        end
    end

    DataUtils.BeginLoading()
    ButtonSetDisabledFlag("CharacterSelectPlay", true)
    BroadcastEvent( SystemData.Events.PLAY)

    
end

function CharacterSelectWindow.NewChar()
    
    if ( ButtonGetDisabledFlag( "CharacterSelectNewChar" ) == true or DataUtils.IsWorldLoading() ) then
        return
    end
    
    -- Close Any Secondary Windows that may be up
    
    local function CloseIfShowing( windowName, closeFunction )
        if( DoesWindowExist( windowName ) and WindowGetShowing( windowName ) )
        then
            closeFunction()
        end
    end
    
    CloseIfShowing( "SettingsWindowTabbed",         SettingsWindowTabbed.OnCancelButton )
    CloseIfShowing( "UiModAdvancedWindow",          UiModWindow.OnAdvancedCancelButton )
    CloseIfShowing( "EA_Window_CinematicDisplay",   EA_Window_CinematicDisplay.Hide )
    CloseIfShowing( "EA_Window_Credits",            EA_Window_Credits.Hide )

    
    GameData.Account.SelectedCharacterSlot = -1
    -- Broadcast the Selection Update
    BroadcastEvent( SystemData.Events.SELECT_CHARACTER )    
    BroadcastEvent( SystemData.Events.BEGIN_CREATE_CHARACTER )
    CharacterSelectWindow.ChangeState(STATE_CHARACTER_CREATE_ARMY)
end

function CharacterSelectWindow.ShowAvailableSlots()
    LabelSetText("CharacterSelectCharacterSlotsAvailableText", GetStringFormatFromTable("Pregame", StringTables.Pregame.LABEL_CHARACTER_SLOTS_AVAILABLE, {CharacterSelectWindow.GetNumSlotsLeftText()})) 
    WindowSetShowing("CharacterSelectCharacterSlotsAvailableText", true)
end

function CharacterSelectWindow.HideAvailableSlots()
    WindowSetShowing("CharacterSelectCharacterSlotsAvailableText", false)
end

-- OnLButtonUp Handler for the 'Quit' Button
function CharacterSelectWindow.Quit( flags, mouseX, mouseY )

    -- Broadcast the event
    BroadcastEvent( SystemData.Events.QUIT )
end

function CharacterSelectWindow.BlockMouseOver(bBlock)
    -- start/stop handling mouse over & mouse button clicks on the C side
    PregameBlockMouseOver(bBlock)
    
    -- when mouse-over is blocked, character pages cannot be changed, so don't let the user interact with the page change combo box
    ComboBoxSetDisabledFlag("CharacterSelectPageChangeComboBox", bBlock)
end

function CharacterSelectWindow.InitDeleteDialog()
    local deleteLabel = GetPregameString( StringTables.Pregame.LABEL_DELETE )
    local cancelLabel = GetPregameString( StringTables.Pregame.LABEL_CANCEL )
    local promptLabel = GetPregameString( StringTables.Pregame.LABEL_TYPE_Y_E_S )
    WindowSetShowing("DeleteConfirmation", false)
    ButtonSetText("DeleteConfirmationBoxDelete", deleteLabel )
    ButtonSetText("DeleteConfirmationBoxCancel", cancelLabel )
    LabelSetText( "DeleteConfirmationBoxLabelPrompt", promptLabel )
end

function CharacterSelectWindow.UpdateDeleteConfirmation( )
    -- if we aren't showing the delete confirmation window then we don't need to update the edit box
    if not WindowGetShowing("DeleteConfirmation") then
        return
    end

    -- if the edit box has any text in it
    if (DeleteConfirmationBoxEdit.Text ~= L"") then
        -- check to see if we have spelled yes yet
        if (DeleteConfirmationBoxEdit.Text == GetPregameString( StringTables.Pregame.LABEL_CAPITAL_YES )) then
            -- enable the delete button if we have
            ButtonSetDisabledFlag("DeleteConfirmationBoxDelete", false)
        -- otherwise disable it, this is to assure if they type yes and backspace it disables the delete button
        else
            ButtonSetDisabledFlag("DeleteConfirmationBoxDelete", true)
            ButtonSetPressedFlag("DeleteConfirmationBoxDelete", false)
        end
    -- if there is no text in the box we also want to make sure the delete button is disabled
    else
        ButtonSetDisabledFlag("DeleteConfirmationBoxDelete", true)
        ButtonSetPressedFlag("DeleteConfirmationBoxDelete", false)
    end
end

function CharacterSelectWindow.HideDeleteDialog()
    WindowSetShowing("DeleteConfirmation", false)

    -- this allows the player to change characters again after the cancel button is hit
    CharacterSelectWindow.BlockMouseOver(false)
end

-- OnLButtonUp Handler for the 'Delete' Button
function CharacterSelectWindow.Delete( flags, mouseX, mouseY )

    local selectedSlot = GameData.Account.CharacterSlot[ GameData.Account.SelectedCharacterSlot ]
    if ( ( selectedSlot == nil ) or ( selectedSlot.Name == L"" ) )
    then
        return
    end

    -- this stops the player from changing the selected character during the deletion process.
    CharacterSelectWindow.BlockMouseOver(true)

    -- Create a Confirmation Dialog
    local charName = selectedSlot.Name
    local text = GetPregameStringFormat( StringTables.Pregame.TEXT_DELETE_CONFIRM, { charName } )

    LabelSetText( "DeleteConfirmationBoxLabelDialog", text )
    ButtonSetDisabledFlag("DeleteConfirmationBoxDelete", true)
    ButtonSetPressedFlag("DeleteConfirmationBoxDelete", false)
    WindowSetShowing("DeleteConfirmation", true)
    -- assure that the edit box retains has focus
    CharacterSelectWindow.GiveDeleteEditBoxFocus()
    -- initialize the edit box to be empty
    TextEditBoxSetText("DeleteConfirmationBoxEdit", L"" )
end

function CharacterSelectWindow.DoDelete()
    -- if the player hasn't typed in "YES" then we don't want to delete the character yet
    if (ButtonGetDisabledFlag( "DeleteConfirmationBoxDelete" ) == true) then
        return
    end

    -- Broadcast the event
    BroadcastEvent( SystemData.Events.DELETE_CHARACTER )
    WindowSetShowing("DeleteConfirmation", false)

    -- this allows the player to change characters again after the delete button is hit
    CharacterSelectWindow.BlockMouseOver(false)
end

function CharacterSelectWindow.OnSettingsButton()
    -- Open the Settings Window
    local showing = WindowGetShowing("SettingsWindowTabbed" )
    WindowSetShowing("SettingsWindowTabbed", not showing  )        
end

function CharacterSelectWindow.OnUiModButton()

    -- Open the Ui Mod Advanced Settings Window
    local showing = WindowGetShowing("UiModAdvancedWindow" )
    WindowSetShowing("UiModAdvancedWindow", not showing  )        
end

function CharacterSelectWindow.LButtonUp( flags, mouseX, mouseY )
    -- Broadcast the event
    BroadcastEvent( SystemData.Events.MOUSE_UP_ON_CHAR_SELECT_NIF )
end

function CharacterSelectWindow.LButtonDown( flags, mouseX, mouseY )
    -- Broadcast the event
    BroadcastEvent( SystemData.Events.MOUSE_DOWN_ON_CHAR_SELECT_NIF )
end

function CharacterSelectWindow.GetNumSlotsLeftText( )
    return L""..CharacterSelectWindow.GetNumSlotsLeft( )
end

function CharacterSelectWindow.GetNumSlotsLeft( )
    local inUseSlotCount = 0
    for slotIndex = 1, GameData.Account.CharacterCreation.MaxCharacterSlots
    do
        if ( GameData.Account.CharacterSlot[slotIndex].Name ~= L"" )
        then
            inUseSlotCount = inUseSlotCount + 1
        end
    end
    
    local slotsLeft = GameData.Account.CharacterCreation.MaxCharacters - inUseSlotCount
    if ( slotsLeft < 0 )
    then
        slotsLeft = 0
    end

    return slotsLeft
end

function CharacterSelectWindow.InitializeCharacterDataCareers()
    local function NewCareer( id, careerId, descStrId, maleIma, femaleIma )
        return
        {
            Name =
            {
                [GameData.Gender.MALE] = GetStringFromTable( "CareerLinesMale", careerId ),
                [GameData.Gender.FEMALE] = GetStringFromTable( "CareerLinesFemale", careerId ),
            },
            Image =
            {
                [GameData.Gender.MALE] = maleIma,
                [GameData.Gender.FEMALE] = femaleIma,
            },
            Id = id,
            CareerId = careerId,
            Desc = GetPregameString( descStrId ),
        }
    end

    CharacterDataCareers[ GameData.Realm.ORDER ] =
    {
        [ 1 ] =
        {
            Id = GameData.Races.DWARF,
            Name = GetPregameString( StringTables.Pregame.RACE_DWARF ),
            Desc = GetPregameString( StringTables.Pregame.RACE_DWARF_DESC ),
            ArmyScreenCareerChoice = 1,
            ArmyScreenCareerGenderChoice = GameData.Gender.MALE,
            Careers =
            {
                [ 1 ] = NewCareer( 20, GameData.CareerLine.IRON_BREAKER,    StringTables.Pregame.CAREER_IRON_BREAKER_DESC,  16, 17 ),
                [ 2 ] = NewCareer( 21, GameData.CareerLine.SLAYER,          StringTables.Pregame.CAREER_SLAYER_DESC,        18, nil ),
                [ 3 ] = NewCareer( 23, GameData.CareerLine.ENGINEER,        StringTables.Pregame.CAREER_ENGINEER_DESC,      20, 21 ),
                [ 4 ] = NewCareer( 22, GameData.CareerLine.RUNE_PRIEST,     StringTables.Pregame.CAREER_RUNE_PRIEST_DESC,   22, 23 ),
            },
        },
        [ 2 ] =
        {
            Id = GameData.Races.EMPIRE,
            Name = GetPregameString( StringTables.Pregame.RACE_EMPIRE ),
            Desc = GetPregameString( StringTables.Pregame.RACE_EMPIRE_DESC ),
            ArmyScreenCareerChoice = 1,
            ArmyScreenCareerGenderChoice = GameData.Gender.MALE,
            Careers =
            {
                [ 1 ] = NewCareer( 62, GameData.CareerLine.BRIGHT_WIZARD,   StringTables.Pregame.CAREER_BRIGHT_WIZARD_DESC,     32, 33 ),
                [ 2 ] = NewCareer( 63, GameData.CareerLine.WARRIOR_PRIEST,  StringTables.Pregame.CAREER_WARRIOR_PRIEST_DESC,    36, 37 ),
                [ 3 ] = NewCareer( 61, GameData.CareerLine.KNIGHT,          StringTables.Pregame.CAREER_KNIGHT_DESC,            30, 31 ),
                [ 4 ] = NewCareer( 60, GameData.CareerLine.WITCH_HUNTER,    StringTables.Pregame.CAREER_WITCH_HUNTER_DESC,      34, 35 ),
            },
        },
        [ 3 ] =
        {
            Id = GameData.Races.HIGH_ELF,
            Name = GetPregameString( StringTables.Pregame.RACE_ELVES ),
            Desc = GetPregameString( StringTables.Pregame.RACE_ELVES_DESC ),
            ArmyScreenCareerChoice = 2,
            ArmyScreenCareerGenderChoice = GameData.Gender.FEMALE,
            Careers =
            {
                [ 1 ] = NewCareer( 100, GameData.CareerLine.SWORDMASTER,    StringTables.Pregame.CAREER_SWORDMASTER_DESC,       48, 49 ),
                [ 2 ] = NewCareer( 101, GameData.CareerLine.SHADOW_WARRIOR, StringTables.Pregame.CAREER_SHADOW_WARRIOR_DESC,    50, 51 ),
                [ 3 ] = NewCareer( 102, GameData.CareerLine.WHITE_LION,     StringTables.Pregame.CAREER_WHITE_LION_DESC,        46, 47 ),
                [ 4 ] = NewCareer( 103, GameData.CareerLine.ARCHMAGE,       StringTables.Pregame.CAREER_ARCH_MAGE_DESC,         44, 45 ),
            }
        },
    }
    
    CharacterDataCareers[ GameData.Realm.DESTRUCTION ] =
    {
        [ 1 ] =
        {
            Id = GameData.Races.ORC,
            Name = GetPregameString( StringTables.Pregame.RACE_GREENSKIN ),
            Desc = GetPregameString( StringTables.Pregame.RACE_GREENSKIN_DESC ),
            ArmyScreenCareerChoice = 3,
            ArmyScreenCareerGenderChoice = GameData.Gender.MALE,
            Careers =
            {
                [ 1 ] = NewCareer( 24, GameData.CareerLine.BLACK_ORC,       StringTables.Pregame.CAREER_BLACKORC_DESC,      12, nil ),
                [ 2 ] = NewCareer( 25, GameData.CareerLine.CHOPPA,          StringTables.Pregame.CAREER_IRON_CLAW_DESC,     13, nil ),
                [ 3 ] = NewCareer( 26, GameData.CareerLine.SHAMAN,          StringTables.Pregame.CAREER_SHAMAN_DESC,        14, nil ),
                [ 4 ] = NewCareer( 27, GameData.CareerLine.SQUIG_HERDER,    StringTables.Pregame.CAREER_SQUIG_HERDER_DESC,  15, nil ),
            },
        },
        [ 2 ] =
        {
            Id = GameData.Races.CHAOS,
            Name = GetPregameString( StringTables.Pregame.RACE_CHAOS ),
            Desc = GetPregameString( StringTables.Pregame.RACE_CHAOS_DESC ),
            ArmyScreenCareerChoice = 2,
            ArmyScreenCareerGenderChoice = GameData.Gender.MALE,
            Careers =
            {
                [ 1 ] = NewCareer( 67, GameData.CareerLine.MAGUS,           StringTables.Pregame.CAREER_MAGUS_DESC,         28, 29 ),
                [ 2 ] = NewCareer( 64, GameData.CareerLine.CHOSEN,          StringTables.Pregame.CAREER_CHOSEN_DESC,        24, nil ),
                [ 3 ] = NewCareer( 66, GameData.CareerLine.ZEALOT,          StringTables.Pregame.CAREER_ZEALOT_DESC,        26, 27 ),
                [ 4 ] = NewCareer( 65, GameData.CareerLine.MARAUDER,        StringTables.Pregame.CAREER_MARAUDER_DESC,      25, nil ),
            },
        },
        [ 3 ] =
        {
            Id = GameData.Races.DARK_ELF,
            Name = GetPregameString( StringTables.Pregame.RACE_DARK_ELVES ),
            Desc = GetPregameString( StringTables.Pregame.RACE_DARK_ELVES_DESC ),
            ArmyScreenCareerChoice = 4,
            ArmyScreenCareerGenderChoice = GameData.Gender.FEMALE,
            Careers =
            {
                [ 1 ] = NewCareer( 104, GameData.CareerLine.BLACKGUARD,     StringTables.Pregame.CAREER_BLACKGUARD_DESC,    39, 40 ),
                [ 2 ] = NewCareer( 105, GameData.CareerLine.WITCH_ELF,      StringTables.Pregame.CAREER_WITCH_ELF_DESC,     nil, 43 ),
                [ 3 ] = NewCareer( 106, GameData.CareerLine.DISCIPLE,       StringTables.Pregame.CAREER_DISCIPLE_DESC,      38, 11 ),
                [ 4 ] = NewCareer( 107, GameData.CareerLine.SORCERER,       StringTables.Pregame.CAREER_SORCERER_DESC,      41, 42 ),
            },
        },
    }

    CharacterSelectWindow.UpdateCharacterDataLuaVars()
end

function CharacterSelectWindow.UpdateCharacterDataLuaVars()
    local RacesArray =
    {
        [ GameData.Realm.ORDER ] = GameData.Account.CharacterCreation.OrderRaces,
        [ GameData.Realm.DESTRUCTION ] = GameData.Account.CharacterCreation.DestructionRaces,
    }
    local CareersArray =
    {
        [ GameData.Realm.ORDER ] = GameData.Account.CharacterCreation.OrderCareers,
        [ GameData.Realm.DESTRUCTION ] = GameData.Account.CharacterCreation.DestructionCareers,
    }
    
    for realm, realmData in pairs(CharacterDataCareers)
    do
        for race, raceData in ipairs(realmData)
        do
            local armyScreenCareer = raceData.Careers[raceData.ArmyScreenCareerChoice]
            if ( armyScreenCareer ~= nil )
            then
                RacesArray[realm][race].ArmyName = raceData.Name
                RacesArray[realm][race].Race = raceData.Id
                RacesArray[realm][race].Career = armyScreenCareer.Id
                RacesArray[realm][race].Image = armyScreenCareer.Image[raceData.ArmyScreenCareerGenderChoice]
                RacesArray[realm][race].Gender = raceData.ArmyScreenCareerGenderChoice
            end
            for career, careerData in ipairs(raceData.Careers)
            do
                CareersArray[realm][race][career].ArmyName = raceData.Name
                CareersArray[realm][race][career].MaleCareerName = careerData.Name[GameData.Gender.MALE]
                CareersArray[realm][race][career].FemaleCareerName = careerData.Name[GameData.Gender.FEMALE]
                CareersArray[realm][race][career].Race = raceData.Id
                CareersArray[realm][race][career].Career = careerData.Id
                CareersArray[realm][race][career].MaleImage = careerData.Image[GameData.Gender.MALE]
                CareersArray[realm][race][career].FemaleImage = careerData.Image[GameData.Gender.FEMALE]
            end
        end
    end
    
    BroadcastEvent( SystemData.Events.CHARACTER_DATA_LUA_VARS_UPDATED )
end

function CharacterSelectWindow.ShowCharacterSelect(bShow)
    WindowSetShowing("CharacterSelectQuit", bShow)
    WindowSetShowing("CharacterSelectSettingsButton", bShow)
    WindowSetShowing("CharacterSelectDeleteButton", bShow)
    WindowSetShowing("CharacterSelectNewChar", bShow)
    WindowSetShowing("CharacterSelectServer", bShow)
    WindowSetShowing("CharacterSelectPlay", bShow)
    
    local bNeedsPageChanger = ( GetTotalNumRawCharacterPages() > 1 )
    WindowSetShowing("CharacterSelectPageChange", bShow and bNeedsPageChanger)
    
    CharacterSelectWindow.UpdateMultirealmInfo(bShow)
end

function CharacterSelectWindow.ShowCharacterCreateArmy(bShow)
    -- if we have no characters we will hide the back button on the army screen
    -- and so that there is an option for the player we will show the server select button
    -- we will also show the server welcome text if there are no characters on the server
    if CharacterSelectWindow.iCharacterSelection == -1 then
        WindowSetShowing("CharacterSelectBack", false)
        WindowSetShowing("CharacterSelectServer", bShow)
        -- show welcome text if appropriate
        WindowSetShowing("CharacterSelectAutoLogged", bShow and ServerSelectWindow.autoLoggedIn)
    else
        WindowSetShowing("CharacterSelectBack", bShow)
        -- if there are characters we don't show the server welcome text
        WindowSetShowing("CharacterSelectAutoLogged", false)
    end
    WindowSetShowing("CharacterSelectInfoBoxRight", bShow)
    WindowSetShowing("CharacterSelectInfoBoxLeft", bShow)
    WindowSetShowing("LobbyBackgroundServerName", not bShow)
    WindowSetShowing("LobbyBackgroundGameVersion", not bShow)
    CharacterSelectWindow.ShowTrialAccountInfo( not bShow )
end

function CharacterSelectWindow.ShowCharacterCreateCareer(bShow)
    if CharacterSelectWindow.iCareerChoice == -1 then
        WindowSetShowing("CharacterSelectCareerToFeature", false)
    else
        WindowSetShowing("CharacterSelectCareerToFeature", bShow)
    end
    WindowSetShowing("CharacterSelectBack", bShow)
    WindowSetShowing("CharacterSelectInfoBox2Right", bShow)
    WindowSetShowing("LobbyBackgroundServerName", not bShow)
    WindowSetShowing("LobbyBackgroundGameVersion", not bShow)
    CharacterSelectWindow.ShowGenderButtons(bShow)
    CharacterSelectWindow.ShowTrialAccountInfo( not bShow )
end

function CharacterSelectWindow.ShowCharacterCreateFeature(bShow)
    WindowSetShowing("CharacterSelectCareerCreateChar", bShow)
    WindowSetShowing("CharacterSelectBack", bShow)
    CharacterSelectWindow.ShowTrialAccountInfo( not bShow )

    --DEBUG(L"CharacterSelectWindow.iRealm = "..CharacterSelectWindow.iRealm)
    --DEBUG(L"CharacterSelectWindow.iRaceChoice = "..CharacterSelectWindow.iRaceChoice)
    --DEBUG(L"CharacterSelectWindow.iCareerChoice = "..CharacterSelectWindow.iCareerChoice)
    CharacterSelectWindow.ShowGenderButtons(bShow)
    WindowSetShowing("CharacterSelectNameEdit", bShow)
    if ( bShow ) then
        WindowAssignFocus( "CharacterSelectNameEdit", true )
    end
    WindowSetShowing("CharacterSelectNameEditBackground", bShow)
    WindowSetShowing("CharacterSelectNameLabel", bShow)
    WindowSetShowing("CharacterSelectRandomName", bShow)
    CharacterSelectWindow.UpdateCustomizationFeatures(bShow)
    WindowSetShowing("CharacterSelectCareerZoomIn", bShow)
    WindowSetShowing("CharacterSelectCareerZoomOut", bShow)
    WindowSetShowing("LobbyBackgroundServerName", not bShow)
    WindowSetShowing("LobbyBackgroundGameVersion", not bShow)
    
    -- if we must use a template then we want to make sure we show/hide the combo box
    -- we will only use templates with a public build when the AllowPublicTemplates returns true
    -- and if we are an internal build we will want to show/hide it properly
    if (IsInternalBuild() or (CharacterSelectWindow.AllowPublicTemplates() and CharacterSelectWindow.bMustUseATemplate))
    then        
        -- If no templates exist, hide the windows related to them regardless of the value of bShow
        if( (CharacterSelectWindow.numTemplates == 0 and CharacterSelectWindow.bNoTemplateOptionDisplayed == false) or
            (CharacterSelectWindow.numTemplates < 2 and CharacterSelectWindow.bNoTemplateOptionDisplayed == true) )
        then
            WindowSetShowing("CharacterSelectTemplateOptions", false)
            WindowSetShowing("CharacterSelectTemplateOptionsComboBox", false)            
        else    
            WindowSetShowing("CharacterSelectTemplateOptions", bShow)
            WindowSetShowing("CharacterSelectTemplateOptionsComboBox", bShow)
        end
    end
end

function CharacterSelectWindow.ShowGenderButtons(bShow)
    local validRealm = ( CharacterSelectWindow.iRealm > 0 )
    local validRace = ( CharacterSelectWindow.iRaceChoice > 0 )
    local validCareer = ( CharacterSelectWindow.iCareerChoice > 0 )
    
    local isGreenskin = validRealm and validRace and ( CharacterDataCareers[CharacterSelectWindow.iRealm][CharacterSelectWindow.iRaceChoice].Id == GameData.Races.ORC )
    WindowSetShowing("CharacterSelectCareerGenderMale", bShow and not isGreenskin)
    WindowSetShowing("CharacterSelectCareerGenderFemale", bShow and not isGreenskin)
    
    local disableMale   = validRealm and validRace and validCareer and ( CharacterDataCareers[CharacterSelectWindow.iRealm][CharacterSelectWindow.iRaceChoice].Careers[CharacterSelectWindow.iCareerChoice].Image[GameData.Gender.MALE] == nil )
    local disableFemale = validRealm and validRace and validCareer and ( CharacterDataCareers[CharacterSelectWindow.iRealm][CharacterSelectWindow.iRaceChoice].Careers[CharacterSelectWindow.iCareerChoice].Image[GameData.Gender.FEMALE] == nil )
    ButtonSetDisabledFlag("CharacterSelectCareerGenderMale",   disableMale)
    ButtonSetDisabledFlag("CharacterSelectCareerGenderFemale", disableFemale)
end

function CharacterSelectWindow.ShowServerSelect()
    --DEBUG(L"SERVER SELECT")
    BroadcastEvent( SystemData.Events.PREGAME_LAUNCH_SERVER_SELECT )
end

function CharacterSelectWindow.Back()
    --DEBUG(L"GOING BACK")
    if CharacterSelectWindow.iState == STATE_CHARACTER_CREATE_FEATURE_IN or CharacterSelectWindow.iState == STATE_CHARACTER_CREATE_FEATURE_OUT then
        CharacterSelectWindow.ChangeState(STATE_CHARACTER_CREATE_CAREER)
    elseif CharacterSelectWindow.iState == STATE_CHARACTER_CREATE_CAREER then
        CharacterSelectWindow.ChangeState(STATE_CHARACTER_CREATE_ARMY)
    elseif CharacterSelectWindow.iState == STATE_CHARACTER_CREATE_ARMY then
        CharacterSelectWindow.ChangeState(STATE_CHARACTER_SELECT)
    end
    
    --Clear the random name list
    -- initialize the name box to be empty
    TextEditBoxSetText("CharacterSelectNameEdit", L"" )
    BroadcastEvent( SystemData.Events.PREGAME_CLEAR_RANDOM_NAME_LIST )
end

function CharacterSelectWindow.ToCareer()
    --DEBUG(L"ToCareer")
    CharacterSelectWindow.ChangeState(STATE_CHARACTER_CREATE_CAREER)
end

function CharacterSelectWindow.ToFeature()
    --DEBUG(L"ToFeature")
    CharacterSelectWindow.ChangeState(STATE_CHARACTER_CREATE_FEATURE_IN)
end

function CharacterSelectWindow.CreateChar()
    --DEBUG(L"CreateChar")
    -- if the create character button is disabled we will return without doing anything
    if ( ButtonGetDisabledFlag( "CharacterSelectCareerCreateChar" ) == true  or DataUtils.IsWorldLoading() ) then
        return
    end
    if ( CharacterSelectWindow.bUseTemplate )
    then
        GameData.Account.CharacterCreation.Image = CharacterDataCareers[CharacterSelectWindow.iRealm][CharacterSelectWindow.iRaceChoice].Careers[CharacterSelectWindow.iCareerChoice].Image[CharacterSelectWindow.iGender]
    end
    
    GameData.Account.CharacterCreation.Name = CharacterSelectNameEdit.Text

    BroadcastEvent( SystemData.Events.CREATE_CHARACTER )
end

function CharacterSelectWindow.ChangeState(iState)
    CharacterSelectWindow.ForceUpdateState(iState)
    BroadcastEvent( SystemData.Events.PREGAME_SET_STATE )
end

function CharacterSelectWindow.RandomName()
    if( ButtonGetDisabledFlag( "CharacterSelectRandomName" ) ) then
        return
    end
    ButtonSetDisabledFlag("CharacterSelectRandomName", true)
    ButtonSetPressedFlag("CharacterSelectRandomName", false)
    BroadcastEvent( SystemData.Events.CHARACTER_PREGAME_RANDOM_NAME_REQUESTED )
end

function CharacterSelectWindow.ForcedRandomName()
    if( ButtonGetDisabledFlag( "ForcedRandomNameBoxRandom" ) ) then
        return
    end
    ButtonSetDisabledFlag("ForcedRandomNameBoxRandom", true)
    ButtonSetPressedFlag("ForcedRandomNameBoxRandom", false)
    BroadcastEvent( SystemData.Events.CHARACTER_PREGAME_RANDOM_NAME_REQUESTED )
end

function CharacterSelectWindow.FindFeatureCurrentValue( featureData )
    for index, value in ipairs(featureData)
    do
        if ( value == featureData.curValue )
        then
            return index
        end
    end
end

function CharacterSelectWindow.NextFeature()
    local featureType  = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )     
    local featureData  = CharacterSelectWindow.featuresData[featureType]
    
    local curValue     = CharacterSelectWindow.FindFeatureCurrentValue( featureData )
    local featureValue = featureData[curValue + 1]
    if ( featureValue == nil )
    then
        featureValue = featureData[1]
    end
    
    PregameSetFeature( featureType, featureValue )
end

function CharacterSelectWindow.PrevFeature()
    local featureType  = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local featureData  = CharacterSelectWindow.featuresData[featureType]
    
    local curValue     = CharacterSelectWindow.FindFeatureCurrentValue( featureData )
    local featureValue = featureData[curValue - 1]
    if ( featureValue == nil )
    then
        featureValue = featureData[#featureData]
    end
    
    PregameSetFeature( featureType, featureValue )
end

function CharacterSelectWindow.RandomFeatures()
    PregameRandomFeatures()
end

function CharacterSelectWindow.OnSelectFeature( curSel )
    if ( curSel < 1 )
    then
        -- Bail if the selection was cleared
        return
    end

    local featureType  = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local featureData  = CharacterSelectWindow.featuresData[featureType]
    
    local featureValue = featureData[curSel]
    PregameSetFeature( featureType, featureValue )
end

function CharacterSelectWindow.UpdateCustomizationFeatures(bShow)
    local iNumFeatures = #CharacterSelectWindow.featuresData
    if ( bShow and ( iNumFeatures > 0 ) and ( CharacterSelectWindow.iRealm > 0 ) and ( CharacterSelectWindow.iRaceChoice > 0 ) and ( CharacterSelectWindow.iCareerChoice > 0 ) )
    then
        local careerId = CharacterDataCareers[CharacterSelectWindow.iRealm][CharacterSelectWindow.iRaceChoice].Careers[CharacterSelectWindow.iCareerChoice].CareerId
        local featureName = featureStrings[careerId][CharacterSelectWindow.iGender].FeatureName
        local featureOptions = featureStrings[careerId][CharacterSelectWindow.iGender].FeatureOptions
        
        for iIndex, features in ipairs(CharacterSelectWindow.featuresData)
        do
            if ( iIndex <= MAX_FEATURES )
            then
                local featureLabel = featureName[iIndex] or L""
                LabelSetText("CharacterSelectFeatureWindow"..iIndex.."FeatureLabel", featureLabel)
            
                local comboName = "CharacterSelectFeatureWindow"..iIndex.."ComboBox"
                ComboBoxClearMenuItems( comboName )                
                
                local curValue = features.curValue
                for menuItemIndex, value in ipairs(features)
                do
                    local text = L""
                    if ( ( featureOptions[iIndex] ~= nil ) and ( featureOptions[iIndex][value+1] ~= nil ) )
                    then
                        text = featureOptions[iIndex][value+1]
                    else
                        text = wstring.format( L"#%d", value+1 )
                    end
                    
                    ComboBoxAddMenuItem( comboName, text )
                    
                    if ( value == curValue )
                    then
                        ComboBoxSetSelectedMenuItem( comboName, menuItemIndex )
                    end
                end
                WindowSetShowing("CharacterSelectFeatureWindow"..iIndex, true)
            end
        end
        
        if ( iNumFeatures < MAX_FEATURES )
        then
            for iIndex = iNumFeatures+1, MAX_FEATURES
            do
                WindowSetShowing("CharacterSelectFeatureWindow"..iIndex, false)
            end
        end
        
        WindowClearAnchors( "CharacterSelectRandomFeatures" )
        WindowAddAnchor( "CharacterSelectRandomFeatures", "bottom", "CharacterSelectFeatureWindow"..math.min(iNumFeatures, MAX_FEATURES).."ComboBox", "top", 0, 10 )
        WindowSetShowing("CharacterSelectRandomFeatures", true)
    else
        for iIndex = 1, MAX_FEATURES
        do
            WindowSetShowing("CharacterSelectFeatureWindow"..iIndex, false)
        end
        WindowSetShowing("CharacterSelectRandomFeatures", false)
    end
end

function CharacterSelectWindow.ZoomIn()
    CharacterSelectWindow.ChangeState(STATE_CHARACTER_CREATE_FEATURE_IN)
end

function CharacterSelectWindow.ZoomOut()
    CharacterSelectWindow.ChangeState(STATE_CHARACTER_CREATE_FEATURE_OUT)
end

function CharacterSelectWindow.SelectGender()
    if (ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true)
    then
        return
    end
    CharacterSelectWindow.OnSelectGender( WindowGetId(SystemData.ActiveWindow.name) )
end

function CharacterSelectWindow.OnSelectGender( gender )
    --DEBUG(L"gender change: gender = "..gender)
    CharacterSelectWindow.iGender = gender
    GameData.Account.CharacterCreation.Gender = gender
    BroadcastEvent( SystemData.Events.UPDATE_CREATION_CHARACTER )
    
    -- Update the Feature Names when in the Character Customization State
    CharacterSelectWindow.UpdateCustomizationFeatures(ShouldShowCustomization())    
end

function CharacterSelectWindow.ForceUpdateState( eState )
    if (eState ~= nil)
    then
        if eState == CharacterSelectWindow.iState
        then
            return
        end

        if eState == STATE_CHARACTER_SELECT then            -- Normal Character Select
            if CharacterSelectWindow.iState == STATE_CHARACTER_CREATE_FEATURE_IN or CharacterSelectWindow.iState == STATE_CHARACTER_CREATE_FEATURE_OUT then
                TextEditBoxSetText("CharacterSelectNameEdit", L"" )
            end
            
            if( CharacterSelectWindow.iState == -1 )
            then
                Sound.Play( GameData.Sound.PREGAME_PLAY_CHARACTER_ORDER ) -- Play the order sound cause we always goto the order background scene when going to character select from Quick Start
            elseif( CharacterSelectWindow.iRealm == GameData.Realm.ORDER)
            then
                Sound.Play( GameData.Sound.PREGAME_PLAY_CHARACTER_ORDER )
            else
                Sound.Play( GameData.Sound.PREGAME_PLAY_CHARACTER_DESTRUCTION )
            end
            
            CharacterSelectWindow.ShowCharacterCreateArmy(false)
            CharacterSelectWindow.ShowCharacterCreateCareer(false)
            CharacterSelectWindow.ShowCharacterCreateFeature(false)
            CharacterSelectWindow.ShowCharacterSelect(true)
            CharacterSelectWindow.UpdateTitle(L"")
            CharacterSelectWindow.UpdateSubTitle(L"")
            CharacterSelectWindow.TogglePNCButton()
        elseif eState == STATE_CHARACTER_CREATE_ARMY then		-- Character Create - Army select
            CharacterSelectWindow.ShowCharacterSelect(false)
            CharacterSelectWindow.ShowCharacterCreateCareer(false)
            CharacterSelectWindow.ShowCharacterCreateFeature(false)
            CharacterSelectWindow.ShowCharacterCreateArmy(true)
            CharacterSelectWindow.UpdateTitle(GetPregameString( StringTables.Pregame.LABEL_CHOOSE_RACE ))
            CharacterSelectWindow.UpdateSubTitle(L"")            
            WindowSetShowing("CharacterSelectPNC", false)
            Sound.Play( GameData.Sound.PREGAME_CHOOSE_RACE )
        elseif eState == STATE_CHARACTER_CREATE_CAREER then		-- Character Create - Career select
            CharacterSelectWindow.ShowCharacterSelect(false)
            CharacterSelectWindow.ShowCharacterCreateArmy(false)
            CharacterSelectWindow.ShowCharacterCreateFeature(false)
            CharacterSelectWindow.ShowCharacterCreateCareer(true)
            CharacterSelectWindow.UpdateTitle(GetPregameString( StringTables.Pregame.LABEL_CHOOSE_CAREER ))
            CharacterSelectWindow.UpdateSubTitle(L"")        
            WindowSetShowing("CharacterSelectPNC", false)
            -- each time we go to the choose career state we will disable the create button
            -- this takes care of each direction since you can only change careers from this state
            CharacterSelectWindow.EnableCreateButton(false)
            if( CharacterSelectWindow.iRealm == GameData.Realm.ORDER )
            then
                Sound.Play( GameData.Sound.PREGAME_CHOOSE_CAREER_ORDER )
            else
                Sound.Play( GameData.Sound.PREGAME_CHOOSE_CAREER_DESTRUCTION )
            end
        elseif eState == STATE_CHARACTER_CREATE_FEATURE_IN or eState == STATE_CHARACTER_CREATE_FEATURE_OUT then		-- Character Create - Feature select
            CharacterSelectWindow.ShowCharacterSelect(false)
            CharacterSelectWindow.ShowCharacterCreateArmy(false)
            CharacterSelectWindow.ShowCharacterCreateCareer(false)
            CharacterSelectWindow.ShowCharacterCreateFeature(true)
            CharacterSelectWindow.UpdateTitle(GetPregameString( StringTables.Pregame.LABEL_CUSTOMIZE_YOUR_CHARACTER ))
            CharacterSelectWindow.UpdateSubTitle(L"")        
            WindowSetShowing("CharacterSelectPNC", false)
        end
        CharacterSelectWindow.iState = eState
        GameData.Account.SelectedCharacterCurrentState = eState
        CharacterSelectWindow.UpdateInfoBoxes()
    end
end

function CharacterSelectWindow.OnQueueUpdated( waitSeconds, queuePos, queueSize )

    WindowSetShowing("QueueStatusWindow", true)

    CharacterSelectWindow.iQueueTime = waitSeconds
    CharacterSelectWindow.iQueuePos = queuePos
    CharacterSelectWindow.iQueueSize = queueSize
    CharacterSelectWindow.iLastUpdate = 0

    CharacterSelectWindow.UpdateQueueStatus()
end

function CharacterSelectWindow.UpdateQueueStatus()

    local text = GetPregameStringFormat( StringTables.Pregame.TEXT_REALM_FULL_QUEUE, { CharacterSelectWindow.iQueuePos, CharacterSelectWindow.iQueueSize, CharacterSelectWindow.GetTimeRemainingString() } )
    
    LabelSetText("QueueStatusWindowText", text)
    
    CharacterSelectWindow.ResetPlayButton()

end

function CharacterSelectWindow.CharacterSelectionUpdated(iNewCharacterSelection)
    --DEBUG(L"iNewRace = "..iNewCharacterSelection)
    CharacterSelectWindow.iCharacterSelection = iNewCharacterSelection
    --DEBUG(L"CharacterSelectWindow.iCharacterSelection = "..CharacterSelectWindow.iCharacterSelection)
    if CharacterSelectWindow.bFirstCharUpdate then
        CharacterSelectWindow.bFirstCharUpdate = false
        if CharacterSelectWindow.iCharacterSelection == -1 then
            CharacterSelectWindow.NewChar()
        else
            CharacterSelectWindow.ChangeState(STATE_CHARACTER_SELECT)
        end
    else
        if iNewCharacterSelection == -1 then
            CharacterSelectWindow.NewChar()
        end
    end

    CharacterSelectWindow.ResetPlayButton()
end

function CharacterSelectWindow.RaceUpdated(iNewRace)
    --DEBUG(L"iNewRace = "..iNewRace)
    CharacterSelectWindow.iRaceChoice = iNewRace + 1
    CharacterSelectWindow.iCareerChoice = -1
end

function CharacterSelectWindow.CareerUpdated(iNewCareer)
    --DEBUG(L"iNewCareer = "..iNewCareer)
    if -1 == iNewCareer then -- so I don't have to go back to all of the -1 references and change them to 0
        CharacterSelectWindow.iCareerChoice = iNewCareer
    else
        CharacterSelectWindow.iCareerChoice = iNewCareer + 1
    end
    CharacterSelectWindow.UpdateCharacterTemplatesList()
    CharacterSelectWindow.ShowCharacterCreateCareer(true)
    -- each time we choose a career we will disable the create button
    CharacterSelectWindow.EnableCreateButton(false)
end

function CharacterSelectWindow.RealmUpdated(iNewRealm)
    --DEBUG(L"iNewRealm = "..iNewRealm)
    CharacterSelectWindow.iRealm = iNewRealm + 1
end

function CharacterSelectWindow.GenderUpdated(iNewGender)
    --DEBUG(L"iNewGender = "..iNewGender)
    CharacterSelectWindow.iGender = iNewGender
    GameData.Account.CharacterCreation.Gender = iNewGender
    
    -- Update the Feature Names when in the Character Customization State
    CharacterSelectWindow.UpdateCustomizationFeatures(ShouldShowCustomization())    
end

function CharacterSelectWindow.MouseOverUpdated(iNewMouseOver)
    --DEBUG(L"iNewMouseOver = "..iNewMouseOver)
    CharacterSelectWindow.iMouseOver = iNewMouseOver
    CharacterSelectWindow.UpdateInfoBoxes()
end

function CharacterSelectWindow.RealmOverUpdated(iNewRealmOver)
    --DEBUG(L"iNewRealmOver = "..iNewRealmOver)
    CharacterSelectWindow.iRealmOver = iNewRealmOver
    CharacterSelectWindow.UpdateInfoBoxes()
end

function CharacterSelectWindow.FeaturesUpdated(featuresData)
    CharacterSelectWindow.featuresData = featuresData
    CharacterSelectWindow.UpdateCustomizationFeatures(ShouldShowCustomization())
end

function CharacterSelectWindow.InitializeFeatureStrings( )

    BuildTableFromCSV("data\\gamedata\\pregame_features.csv", "PregameFeatureList")
    
    -- Initialize call careers to empty
    for _, careerId in pairs(GameData.CareerLine)
    do
        featureStrings[careerId] =
        {
            [GameData.Gender.MALE] =
            {
                FeatureName = {},
                FeatureOptions = {},
            },
            [GameData.Gender.FEMALE] =
            {
                FeatureName = {},
                FeatureOptions = {},
            },
        }
    end
    
    -- Loop through each feature in the CSV and Populate the Data Structures
    for _, featureData in ipairs( PregameFeatureList )  
    do
        local career = GameData.CareerLine[featureData.FEATURE_CAREER]
        local gender = GameData.Gender[featureData.FEATURE_GENDER]
        local featureName = GetPregameString( StringTables.Pregame[featureData.FEATURE_LABEL] )
        
        CharacterSelectWindow.SetFeatureDataString( career, gender, featureName, featureData.featureStringIdBase )
    end
    
    PregameFeatureList = nil
end

function CharacterSelectWindow.SetFeatureDataString( career, gender, featureName, featureStringIdBase )

    table.insert( featureStrings[career][gender].FeatureName, featureName )
    
    -- Feature Menu Item Strings
    
    local featureOptions = {}
    if ( featureStringIdBase ~= nil )
    then
        local featureItemIndex = 1
         
        local stringId = StringTables.PregameCreationFeatures[ featureStringIdBase.."_"..featureItemIndex ]
        while( stringId ~= nil )
        do
            table.insert( featureOptions, wstring.upper( GetStringFromTable( "PregameCreationFeatures", stringId ) ) )
            
            featureItemIndex = featureItemIndex + 1
            stringId = StringTables.PregameCreationFeatures[ featureStringIdBase.."_"..featureItemIndex ]
        end 
    end
    table.insert( featureStrings[career][gender].FeatureOptions, featureOptions )
end

function CharacterSelectWindow.UpdateTitle(szLabel)
    --DEBUG(L"szLabel = "..szLabel)
    LabelSetText("CharacterSelectTitleLabel", szLabel)
end

function CharacterSelectWindow.UpdateSubTitle(szLabel)
    --DEBUG(L"szLabel = "..szLabel)
    LabelSetText("CharacterSelectTitleSubLabel", szLabel)
end

function CharacterSelectWindow.UpdateInfoBoxes()
    -- Character Create - Army select
    if CharacterSelectWindow.iState == STATE_CHARACTER_CREATE_ARMY
    then
        local wszLeftTitle        = GetPregameString( StringTables.Pregame.LABEL_REALM_ORDER )
        local wszLeftSecondTitleLeft  = GetPregameString( StringTables.Pregame.LABEL_ARMYS_DWARF )
        local wszLeftSecondTitleMiddle  = GetPregameString( StringTables.Pregame.LABEL_ARMYS_EMPIRE )
        local wszLeftSecondTitleRight  = GetPregameString( StringTables.Pregame.LABEL_ARMYS_HIGH_ELF )
        local wszLeftLabel        = GetPregameString( StringTables.Pregame.LABEL_ORDER_DESCRIPTION )
        local wszRightTitle       = GetPregameString( StringTables.Pregame.LABEL_REALM_DESTRUCTION )
        local wszRightSecondTitleLeft = GetPregameString( StringTables.Pregame.LABEL_ARMYS_DARK_ELF )
        local wszRightSecondTitleMiddle = GetPregameString( StringTables.Pregame.LABEL_ARMYS_CHAOS )
        local wszRightSecondTitleRight = GetPregameString( StringTables.Pregame.LABEL_ARMYS_GREENSKIN )
        local wszRightLabel       = GetPregameString( StringTables.Pregame.LABEL_DESTRUCTION_DESCRIPTION )
        -- initailize the population bonus text to the empty string and hide the icons
        local wszRightPopBonus    = L""
        local wszLeftPopBonus     = L""
        WindowSetShowing("CharacterSelectInfoBoxLeftIconBase", false)
        WindowSetShowing("CharacterSelectInfoBoxRightIconBase", false)

        -- get the realm bonuses that the server select screen set for us
        local iOrderBonus, iDestructionBonus = PregameGetServerRealmBonuses()
        -- if there is an order bonus we will set the label text and show the icon
        if iOrderBonus ~= 0
        then
            local realmText = GetPregameString( StringTables.Pregame.LABEL_ORDER )
            wszLeftPopBonus = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_POPULATION_BONUS, { realmText } )
            WindowSetShowing("CharacterSelectInfoBoxLeftIconBase", true)
        end
        -- if there is a destruction bonus we will set the label text and show the icon
        if iDestructionBonus ~= 0
        then
            local realmText = GetPregameString( StringTables.Pregame.LABEL_CHAOS )
            wszRightPopBonus = GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_POPULATION_BONUS, { realmText } )
            WindowSetShowing("CharacterSelectInfoBoxRightIconBase", true)
        end

        if 0 == CharacterSelectWindow.iRealmOver
        then
            if (0 <= CharacterSelectWindow.iMouseOver) and (2 >= CharacterSelectWindow.iMouseOver)
            then
                wszLeftLabel = CharacterDataCareers[GameData.Realm.ORDER][CharacterSelectWindow.iMouseOver+1].Desc
            end
        else
            if (0 <= CharacterSelectWindow.iMouseOver) and (2 >= CharacterSelectWindow.iMouseOver)
            then
                wszRightLabel = CharacterDataCareers[GameData.Realm.DESTRUCTION][CharacterSelectWindow.iMouseOver+1].Desc
            end
        end

        CharacterSelectWindow.ColorizeInfoBoxes(CharacterSelectWindow.iRealmOver)

        -- get the realm limitation for the player
        local realmLimit = PregameGetRealmLimit( )
        --DEBUG(L"RealmLimit = "..realmLimit)
        -- if the realm limitation is order only we need to let the player know what happened to the
        -- destruction option
        if REALM_LIMIT_ORDER_ONLY == realmLimit
        then
            wszRightTitle = GetPregameString( StringTables.Pregame.LABEL_DESTRUCTION_NOT_ELIGIBLE )
            wszRightSecondTitleLeft = L""
            wszRightSecondTitleMiddle = L""
            wszRightSecondTitleRight = L""
            wszRightLabel = GetPregameString( StringTables.Pregame.LABEL_DESTRUCTION_NOT_ELIGIBLE_DESCRIPTION )
        -- if the realm limitation is destruction only we need to let the player know what happened to the
        -- order option
        elseif REALM_LIMIT_DESTRUCTION_ONLY == realmLimit
        then
            wszLeftTitle = GetPregameString( StringTables.Pregame.LABEL_ORDER_NOT_ELIGIBLE )
            wszLeftSecondTitleLeft = L""
            wszLeftSecondTitleMiddle = L""
            wszLeftSecondTitleRight = L""
            wszLeftLabel = GetPregameString( StringTables.Pregame.LABEL_ORDER_NOT_ELIGIBLE_DESCRIPTION )
        end

        -- if there is a pre-selected server limitation we will hide the un-shown side's info box
        local preSelectedServerRealm = PregameGetPreSelectedServerRealm( )
        if REALM_LIMIT_ORDER_ONLY == preSelectedServerRealm
        then
            WindowSetShowing("CharacterSelectInfoBoxRight", false)
        elseif REALM_LIMIT_DESTRUCTION_ONLY == preSelectedServerRealm
        then
            WindowSetShowing("CharacterSelectInfoBoxLeft", false)
        end


        LabelSetText("CharacterSelectInfoBoxLeftLabelTitle",        wszLeftTitle)
        LabelSetText("CharacterSelectInfoBoxLeftLabelSecondTitleLeft",  wszLeftSecondTitleLeft)
        LabelSetText("CharacterSelectInfoBoxLeftLabelSecondTitleMiddle",  wszLeftSecondTitleMiddle)
        LabelSetText("CharacterSelectInfoBoxLeftLabelSecondTitleRight",  wszLeftSecondTitleRight)
        LabelSetText("CharacterSelectInfoBoxLeftLabel",             wszLeftLabel)
        LabelSetText("CharacterSelectInfoBoxRightLabelTitle",       wszRightTitle)
        LabelSetText("CharacterSelectInfoBoxRightLabelSecondTitleLeft", wszRightSecondTitleLeft)
        LabelSetText("CharacterSelectInfoBoxRightLabelSecondTitleMiddle", wszRightSecondTitleMiddle)
        LabelSetText("CharacterSelectInfoBoxRightLabelSecondTitleRight", wszRightSecondTitleRight)
        LabelSetText("CharacterSelectInfoBoxRightLabel",            wszRightLabel)
        LabelSetText("CharacterSelectInfoBoxLeftPopBonusLabel",            wszLeftPopBonus)
        LabelSetText("CharacterSelectInfoBoxRightPopBonusLabel",            wszRightPopBonus)

    -- Character Create - Career select
    elseif CharacterSelectWindow.iState == STATE_CHARACTER_CREATE_CAREER
    then
        
        -- Durring initialization this can be called with an invalid race.
        if ( ( CharacterSelectWindow.iRealm < 1 ) or ( CharacterSelectWindow.iRaceChoice < 1 ) )
        then
            return
        end
    
        -- the default text should vary based on realm
        wszLabelTitle = CharacterDataCareers[CharacterSelectWindow.iRealm][CharacterSelectWindow.iRaceChoice].Name
        wszLabelDesc = CharacterDataCareers[CharacterSelectWindow.iRealm][CharacterSelectWindow.iRaceChoice].Desc
        if ( (1 <= CharacterSelectWindow.iCareerChoice) and (4 >= CharacterSelectWindow.iCareerChoice) )
        then
            wszLabelTitle = CharacterDataCareers[CharacterSelectWindow.iRealm][CharacterSelectWindow.iRaceChoice].Careers[CharacterSelectWindow.iCareerChoice].Name[CharacterSelectWindow.iGender]
            wszLabelDesc = CharacterDataCareers[CharacterSelectWindow.iRealm][CharacterSelectWindow.iRaceChoice].Careers[CharacterSelectWindow.iCareerChoice].Desc
        end
        if ( (0 <= CharacterSelectWindow.iMouseOver) and (3 >= CharacterSelectWindow.iMouseOver) )
        then
            wszLabelTitle = CharacterDataCareers[CharacterSelectWindow.iRealm][CharacterSelectWindow.iRaceChoice].Careers[CharacterSelectWindow.iMouseOver+1].Name[CharacterSelectWindow.iGender]
            wszLabelDesc = CharacterDataCareers[CharacterSelectWindow.iRealm][CharacterSelectWindow.iRaceChoice].Careers[CharacterSelectWindow.iMouseOver+1].Desc
        end
        LabelSetText("CharacterSelectInfoBox2RightLabelTitle", wszLabelTitle)
        LabelSetText("CharacterSelectInfoBox2RightLabel", wszLabelDesc)
    end

end

function CharacterSelectWindow.ColorizeInfoBoxes(selectedSide)

    LabelSetTextColor("CharacterSelectInfoBox2RightLabelTitle",      DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
    LabelSetTextColor("CharacterSelectInfoBoxLeftPopBonusLabel",      DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
    LabelSetTextColor("CharacterSelectInfoBoxRightPopBonusLabel", DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)

    -- neither selected
    if (selectedSide == -1) then
        LabelSetTextColor("CharacterSelectInfoBoxLeftLabelTitle",       DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
        LabelSetTextColor("CharacterSelectInfoBoxLeftLabelSecondTitleLeft", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
        LabelSetTextColor("CharacterSelectInfoBoxLeftLabelSecondTitleMiddle", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
        LabelSetTextColor("CharacterSelectInfoBoxLeftLabelSecondTitleRight", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
        LabelSetTextColor("CharacterSelectInfoBoxLeftLabel",            DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)

        LabelSetTextColor("CharacterSelectInfoBoxRightLabelTitle",      DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)
        LabelSetTextColor("CharacterSelectInfoBoxRightLabelSecondTitleLeft", DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)
        LabelSetTextColor("CharacterSelectInfoBoxRightLabelSecondTitleMiddle", DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)
        LabelSetTextColor("CharacterSelectInfoBoxRightLabelSecondTitleRight", DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)
        LabelSetTextColor("CharacterSelectInfoBoxRightLabel",           DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)
    -- order
    else
        if 0 == CharacterSelectWindow.iRealmOver then
            LabelSetTextColor("CharacterSelectInfoBoxLeftLabelTitle",       DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b)
            LabelSetTextColor("CharacterSelectInfoBoxLeftLabel",            DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b)
            if (0 == CharacterSelectWindow.iMouseOver) then
                LabelSetTextColor("CharacterSelectInfoBoxLeftLabelSecondTitleLeft", DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b)
            else
                LabelSetTextColor("CharacterSelectInfoBoxLeftLabelSecondTitleLeft", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
            end
            if (1 == CharacterSelectWindow.iMouseOver) then
                LabelSetTextColor("CharacterSelectInfoBoxLeftLabelSecondTitleMiddle", DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b)
            else
                LabelSetTextColor("CharacterSelectInfoBoxLeftLabelSecondTitleMiddle", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
            end
            if (2 == CharacterSelectWindow.iMouseOver) then
                LabelSetTextColor("CharacterSelectInfoBoxLeftLabelSecondTitleRight", DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b)
            else
                LabelSetTextColor("CharacterSelectInfoBoxLeftLabelSecondTitleRight", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
            end

            LabelSetTextColor("CharacterSelectInfoBoxRightLabelTitle",      DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)
            LabelSetTextColor("CharacterSelectInfoBoxRightLabelSecondTitleLeft", DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)
            LabelSetTextColor("CharacterSelectInfoBoxRightLabelSecondTitleMiddle", DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)
            LabelSetTextColor("CharacterSelectInfoBoxRightLabelSecondTitleRight", DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)
            LabelSetTextColor("CharacterSelectInfoBoxRightLabel",           DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)
        else
            LabelSetTextColor("CharacterSelectInfoBoxLeftLabelTitle",       DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
            LabelSetTextColor("CharacterSelectInfoBoxLeftLabelSecondTitleLeft", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
            LabelSetTextColor("CharacterSelectInfoBoxLeftLabelSecondTitleMiddle", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
            LabelSetTextColor("CharacterSelectInfoBoxLeftLabelSecondTitleRight", DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)
            LabelSetTextColor("CharacterSelectInfoBoxLeftLabel",            DefaultColor.YELLOW.r, DefaultColor.YELLOW.g, DefaultColor.YELLOW.b)

            LabelSetTextColor("CharacterSelectInfoBoxRightLabelTitle",      DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b)
            LabelSetTextColor("CharacterSelectInfoBoxRightLabel",           DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b)

            -- greenskin is on the right side of the screen but is mouse over index 0
            -- dark elf is on the left side of the destruction races but is mouse over index 2
            -- hence the swap of the comparisons here.
            if (2 == CharacterSelectWindow.iMouseOver) then
                LabelSetTextColor("CharacterSelectInfoBoxRightLabelSecondTitleLeft", DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b)
            else
                LabelSetTextColor("CharacterSelectInfoBoxRightLabelSecondTitleLeft", DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)
            end
            if (1 == CharacterSelectWindow.iMouseOver) then
                LabelSetTextColor("CharacterSelectInfoBoxRightLabelSecondTitleMiddle", DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b)
            else
                LabelSetTextColor("CharacterSelectInfoBoxRightLabelSecondTitleMiddle", DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)
            end
            if (0 == CharacterSelectWindow.iMouseOver) then
                LabelSetTextColor("CharacterSelectInfoBoxRightLabelSecondTitleRight", DefaultColor.WHITE.r, DefaultColor.WHITE.g, DefaultColor.WHITE.b)
            else
                LabelSetTextColor("CharacterSelectInfoBoxRightLabelSecondTitleRight", DefaultColor.PREGAME_RED.r, DefaultColor.PREGAME_RED.g, DefaultColor.PREGAME_RED.b)
            end
        end
    end
end

function CharacterSelectWindow.UpdateCharacterTemplatesList()

    -- Clear ComboBox before populating to avoid duplicates
    ComboBoxClearMenuItems("CharacterSelectTemplateOptionsComboBox")
    
    -- reset must use template flag
    CharacterSelectWindow.bMustUseATemplate = false    
    CharacterSelectWindow.numTemplates = 0
    CharacterSelectWindow.bNoTemplateOptionDisplayed = false
    
    local careerID = -1
    -- figure out the current career's ID
    if (1 <= CharacterSelectWindow.iCareerChoice) and (4 >= CharacterSelectWindow.iCareerChoice) then
        careerID = CharacterDataCareers[CharacterSelectWindow.iRealm][CharacterSelectWindow.iRaceChoice].Careers[CharacterSelectWindow.iCareerChoice].Id
    end
    
    if(IsScenarioF2PServer() == false or IsInternalBuild())
    then
        -- Not a template-enforced server, so display the no-template option
        CharacterSelectWindow.numTemplates = 1
        CharacterSelectWindow.bNoTemplateOptionDisplayed = true
        ComboBoxAddMenuItem("CharacterSelectTemplateOptionsComboBox", GetPregameString( StringTables.Pregame.LABEL_NO_TEMPLATE ))
    end
    
    if (GameData.Account.CharacterCreation.AvailableTemplates_Names ~= nil) then
        -- Add template options to the combobox
        for index, name in ipairs(GameData.Account.CharacterCreation.AvailableTemplates_Names) do

            if (GameData.Account.CharacterCreation.AvailableTemplates_Classes[index] == careerID) then
                CharacterSelectWindow.numTemplates = CharacterSelectWindow.numTemplates + 1
                local displayName = string.gsub(WStringToString(name), "_", " ")
                ComboBoxAddMenuItem("CharacterSelectTemplateOptionsComboBox", StringToWString(displayName))
                -- since we have a template we will force the use of a template
                CharacterSelectWindow.bMustUseATemplate = true
            end
            
        end
    end

    -- Reset selections
    if(CharacterSelectWindow.bMustUseATemplate == true and CharacterSelectWindow.numTemplates > 0)
    then        
        -- Select the first real template in the list
        ComboBoxSetSelectedMenuItem("CharacterSelectTemplateOptionsComboBox", 1)
    else
        WindowSetShowing("CharacterSelectTemplateOptions", false)
        WindowSetShowing("CharacterSelectTemplateOptionsComboBox", false)  
    end
    
end

-- OnSelectionChange Handler for the Templates ComboBox
function CharacterSelectWindow.OnFilterSelChanged( curSel )

    selectedTemplateItem = ComboBoxGetSelectedMenuItem("CharacterSelectTemplateOptionsComboBox")
    
    -- if we have a valid template item then we will set the lua variable
    if ( (selectedTemplateItem > 1 and CharacterSelectWindow.bNoTemplateOptionDisplayed == true) or
         (selectedTemplateItem > 0 and CharacterSelectWindow.bNoTemplateOptionDisplayed == false) )
    then
        CharacterSelectWindow.bUseTemplate = true
        
        local realName = string.gsub(WStringToString(ComboBoxGetSelectedText("CharacterSelectTemplateOptionsComboBox")), " ", "_")
        GameData.Account.CharacterCreation.Template = StringToWString(realName)
        -- since we have a valid template we can go ahead and enable the character create button
        CharacterSelectWindow.EnableCreateButton(true)
    -- otherwise we will set the lua var to the empty string
    else
        CharacterSelectWindow.bUseTemplate = false
        GameData.Account.CharacterCreation.Template = L""
        -- since we don't have a valid template we will disable the character create button
        CharacterSelectWindow.EnableCreateButton(false)
    end
    
end

function CharacterSelectWindow.NextTemplate()

    selectedTemplateItem = ComboBoxGetSelectedMenuItem("CharacterSelectTemplateOptionsComboBox")
    local nextTemplate = selectedTemplateItem + 1
    
    if(CharacterSelectWindow.numTemplates > selectedTemplateItem)
    then
        ComboBoxSetSelectedMenuItem("CharacterSelectTemplateOptionsComboBox", nextTemplate)
        CharacterSelectWindow.OnFilterSelChanged(nextTemplate)
    else    
        -- Cycle back to the beginning
        ComboBoxSetSelectedMenuItem("CharacterSelectTemplateOptionsComboBox", 1)
        CharacterSelectWindow.OnFilterSelChanged(1)
    end

end

function CharacterSelectWindow.PrevTemplate()

    selectedTemplateItem = ComboBoxGetSelectedMenuItem("CharacterSelectTemplateOptionsComboBox")
    local prevTemplate = selectedTemplateItem - 1
    
    if(prevTemplate > 0)
    then
        ComboBoxSetSelectedMenuItem("CharacterSelectTemplateOptionsComboBox", prevTemplate)
        CharacterSelectWindow.OnFilterSelChanged(prevTemplate)
    else    
        -- Cycle to the back of the list
        ComboBoxSetSelectedMenuItem("CharacterSelectTemplateOptionsComboBox", CharacterSelectWindow.numTemplates)
        CharacterSelectWindow.OnFilterSelChanged(CharacterSelectWindow.numTemplates)
    end

end

function CharacterSelectWindow.EnableCreateButton(bEnable)
    -- only do enable / disable the create button if this is not an internal build
    -- we only want to bother with this if we are allowing public clients to use templates
    if (CharacterSelectWindow.AllowPublicTemplates() and (IsInternalBuild() == false))
    then
        if ((not CharacterSelectWindow.bMustUseATemplate) or bEnable) then
            ButtonSetDisabledFlag( "CharacterSelectCareerCreateChar", false )
        else
            ButtonSetDisabledFlag( "CharacterSelectCareerCreateChar", true )
            ButtonSetPressedFlag( "CharacterSelectCareerCreateChar", false )
        end
    end
end

function CharacterSelectWindow.GiveDeleteEditBoxFocus()
    WindowAssignFocus("DeleteConfirmationBoxEdit", true)
end

function CharacterSelectWindow.UpdateCharacterSelectRandomName()
    ButtonSetDisabledFlag( "CharacterSelectRandomName", false )
    TextEditBoxSetText("CharacterSelectNameEdit", GameData.Account.CharacterCreation.Name)
end

function CharacterSelectWindow.UpdateCharacterForcedRandomName()
    ButtonSetDisabledFlag( "ForcedRandomNameBoxRandom", false)
    LabelSetText("ForcedRandomNameBoxDisplay", GameData.Account.CharacterCreation.Name)
end

function CharacterSelectWindow.InitForcedRandomNameDialog()
    local promptLabel = GetPregameString( StringTables.Pregame.TEXT_FORCED_RENAME_CHARACTER )
    local randomLabel = GetPregameString( StringTables.Pregame.LABEL_BUTTON_RANDOM_NAME )
    local acceptLabel = GetPregameString( StringTables.Pregame.LABEL_BUTTON_FORCE_RENAME_ACCEPT )
  
    WindowSetShowing("ForcedRandomName", false)
    LabelSetText("ForcedRandomNameBoxLabelPrompt", promptLabel)
    ButtonSetText("ForcedRandomNameBoxRandom", randomLabel)
    ButtonSetText("ForcedRandomNameBoxAccept", acceptLabel)
end

function CharacterSelectWindow.ShowForcedNameSelectWindow()
    WindowSetShowing("ForcedRandomName", true)
    CharacterSelectWindow.BlockMouseOver(true)
    LabelSetText("ForcedRandomNameBoxDisplay", GameData.Account.CharacterCreation.Name)    
end

function CharacterSelectWindow.AcceptForcedRandomName()       
    if (DoesWindowExist("ForcedRandomName")) then
        WindowSetShowing("ForcedRandomName", false)
    end  

    ButtonSetDisabledFlag( "ForcedRandomNameBoxRandom", true)    
    ButtonSetPressedFlag("CharacterSelectPlay", true )
    ButtonSetDisabledFlag("CharacterSelectPlay", true )
    
    CharacterSelectWindow.BlockMouseOver(false)

    -- this message triggers makes them go to a play state
    DataUtils.BeginLoading()
    BroadcastEvent( SystemData.Events.CHARACTER_PREGAME_FORCED_RANDOM_NAME_ACCEPT )
end

-- putting this in a function so that I can swap it out for a C call if it becomes necessary
function CharacterSelectWindow.AllowPublicTemplates()
    return CharacterSelectWindow.bAllowTemplatesInPublicBuilds
end

function CharacterSelectWindow.GetTimeRemainingString()
    if CharacterSelectWindow.iQueueTime < 60
    then
        return GetPregameString( StringTables.Pregame.LABEL_SMALL_TIMER  )
    elseif CharacterSelectWindow.iQueueTime == CharacterSelectWindow.iMaxQueueTime
    then
        return L""
    end

    return TimeUtils.FormatTime(CharacterSelectWindow.iQueueTime)
end

function CharacterSelectWindow.RefreshPlayerData()
    CharacterSelectWindow.trialPlayer, CharacterSelectWindow.buddiedPlayer = GetAccountData()
end

function CharacterSelectWindow.UpgradeTrial()
    EA_TrialAlertWindow.OnUpgradeWithOutClose()
end

function CharacterSelectWindow.GetCharactersMaxLevel( )
    local maxLevel = 0
    for slotIndex = 1, GameData.Account.CharacterCreation.MaxCharacterSlots
    do
        if ( GameData.Account.CharacterSlot[slotIndex].Level > maxLevel )
        then
            maxLevel = GameData.Account.CharacterSlot[slotIndex].Level
        end
    end

    return maxLevel
end

function CharacterSelectWindow.UpdateTrialAccountInfoText()
    if( not SystemData.Territory.TAIWAN )
    then
        -- hide free trial account info
        WindowSetShowing("TrialAccountInfo", false)
        return
    end
    
    if CharacterSelectWindow.trialPlayer
    then
        -- show free trial account info
        LabelSetText( "TrialAccountInfoHeader", GetString( StringTables.Default.TEXT_FREE_TRIAL_ACCOUNT_HEADER ) )
        local maxLevel = CharacterSelectWindow.GetCharactersMaxLevel()        
        if( maxLevel > GameData.TrialAccount.MaxLevel )
        then
            -- this was a paid account before
            LabelSetText( "TrialAccountInfoText", GetString( StringTables.Default.TEXT_CHARACTER_SELECT_WINDOW_PAID_ACCOUNT ) )
        else
            -- this was a new trial account
            LabelSetText( "TrialAccountInfoText", GetString( StringTables.Default.TEXT_CHARACTER_SELECT_WINDOW_TRIAL_ACCOUNT ) )
        end        
        WindowSetShowing("TrialAccountInfo", true)
    else
        -- hide free trial account info
        WindowSetShowing("TrialAccountInfo", false)
    end
end

function CharacterSelectWindow.ShowTrialAccountInfo( bShow )
    WindowSetShowing("TrialAccountInfo", bShow and SystemData.Territory.TAIWAN and CharacterSelectWindow.trialPlayer)
end

function CharacterSelectWindow.NextCharacterPage()
    local rawPage = GetRawCharacterPageIndexFromRealmIndex( PregameGetCharacterSelectPage() ) + 1
    if ( rawPage > GetTotalNumRawCharacterPages() )
    then
        rawPage = 1
    end
    PregameSetCharacterSelectPage( GetRealmCharacterPageIndexFromRawIndex( rawPage ) )
end

function CharacterSelectWindow.PrevCharacterPage()
    local rawPage = GetRawCharacterPageIndexFromRealmIndex( PregameGetCharacterSelectPage() ) - 1
    if ( rawPage == 0 )
    then
        rawPage = GetTotalNumRawCharacterPages()
    end
    PregameSetCharacterSelectPage( GetRealmCharacterPageIndexFromRawIndex( rawPage ) )
end

function CharacterSelectWindow.OnSelectCharacterPage( selectedIndex )
    if ( selectedIndex > 0 )    -- When the combo box is cleared, this gets called with a selectedIndex of 0, which is invalid
    then
        PregameSetCharacterSelectPage( GetRealmCharacterPageIndexFromRawIndex( selectedIndex ) )
    end
end

function CharacterSelectWindow.UpdateMultirealmInfo( show )
    if ( ( not show ) or ( GameData.Account.CharacterCreation.LastSwitchedToRealm == GameData.Realm.NONE ) )
    then
        WindowSetShowing( "CharacterSelectMultirealmInfo", false )
    else
        local realmText = L""
        if ( GameData.Account.CharacterCreation.LastSwitchedToRealm == GameData.Realm.ORDER )
        then
            realmText = GetPregameString( StringTables.Pregame.LABEL_ORDER )
        else
            realmText = GetPregameString( StringTables.Pregame.LABEL_CHAOS )
        end
        
        local timeLeftText = TimeUtils.FormatTimeCondensed( GameData.Account.CharacterCreation.RemainingLockoutTime )
        
        LabelSetText( "CharacterSelectMultirealmInfo", GetStringFormatFromTable( "Pregame", StringTables.Pregame.LABEL_LOCKOUT_TIMER, { realmText, timeLeftText } ) )
        WindowSetShowing( "CharacterSelectMultirealmInfo", true )
    end
end

function CharacterSelectWindow.TogglePNCButton()

    if(CharacterSelectWindow.iCharacterSelection == -1)
    then
        WindowSetShowing("CharacterSelectPNC", false)
        WindowSetShowing("PNCWindow", false)
    end

    if(CharacterSelectWindow.CanClickPlayButton() and 
       GameData.Account.CharacterCreation.NumPaidNameChangesAvailable > 0)
    then
        WindowSetShowing("CharacterSelectPNC", true)
    else
        WindowSetShowing("CharacterSelectPNC", false)
        WindowSetShowing("PNCWindow", false)
    end

end

function CharacterSelectWindow.ShowPNCWindow()

    if(GameData.Account.CharacterCreation.NumPaidNameChangesAvailable > 0)
    then
        PNCWindow.Show()
    end

end