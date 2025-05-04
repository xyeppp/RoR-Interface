----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

MenuBarWindow = {}

MenuBarWindow.TOME_ALERT_TIME = 5
MenuBarWindow.tomeAlertTime = 0

local FADE_IN = 0
local FADE_OUT = 1

MenuBarWindow.HELP_BUTTON_FADE_MIN = .33
MenuBarWindow.HELP_BUTTON_FADE_MAX = 1
MenuBarWindow.HelpButtonFadeTimer = 1			-- Accumulated time
MenuBarWindow.HelpButtonDirection = FADE_OUT	-- Direction to fade the Help Button

MenuBarWindow.HighlightedButtons = {}

----------------------------------------------------------------
-- General Functions
----------------------------------------------------------------

function MenuBarWindow.Initialize()
    
    -- Register this window for movement with the Layout Editor
    LayoutEditor.RegisterWindow( "MenuBarWindow", 
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_MENU_BAR_NAME ),
                                 GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_MENU_BAR_DESC ),
                                 false, false,
                                 true, nil )

    WindowRegisterEventHandler( "MenuBarWindow", SystemData.Events.TOGGLE_CHARACTER_WINDOW, "MenuBarWindow.ToggleCharacterWindow")
    WindowRegisterEventHandler( "MenuBarWindow", SystemData.Events.TOGGLE_ABILITIES_WINDOW, "MenuBarWindow.ToggleAbilitiesWindow")
    WindowRegisterEventHandler( "MenuBarWindow", SystemData.Events.TOGGLE_BACKPACK_WINDOW, "MenuBarWindow.ToggleBackpackWindow")
    WindowRegisterEventHandler( "MenuBarWindow", SystemData.Events.TOGGLE_GUILD_WINDOW, "MenuBarWindow.ToggleGuildWindow")
    WindowRegisterEventHandler( "MenuBarWindow", SystemData.Events.TOGGLE_HELP_WINDOW, "MenuBarWindow.ToggleHelpWindow")
    WindowRegisterEventHandler( "MenuBarWindow", SystemData.Events.TOGGLE_PARTY_WINDOW, "MenuBarWindow.ToggleOpenPartyWindow")
    WindowRegisterEventHandler( "MenuBarWindow", SystemData.Events.TOGGLE_MENU_WINDOW, "MenuBarWindow.ToggleMenuWindow")
    WindowRegisterEventHandler( "MenuBarWindow", SystemData.Events.TOGGLE_TOME_WINDOW, "MenuBarWindow.ToggleTomeWindow")
    WindowRegisterEventHandler( "MenuBarWindow", SystemData.Events.TOGGLE_USER_SETTINGS_WINDOW, "MenuBarWindow.ToggleSettingsWindow")    
    WindowRegisterEventHandler( "MenuBarWindow", SystemData.Events.TOME_ALERTS_UPDATED, "MenuBarWindow.OnTomeAlertsUpdated")

    ButtonSetStayDownFlag( "MenuBarWindowToggleTomeWindowButton", true )    
    ButtonSetStayDownFlag( "MenuBarWindowToggleTomeWindowNewEntriesButton", true )    
 
    ButtonSetStayDownFlag( "MenuBarWindowToggleGuildWindowButton", true )  
    ButtonSetStayDownFlag( "MenuBarWindowToggleCharacterWindowButton", true )     
    ButtonSetStayDownFlag( "MenuBarWindowToggleAbilitiesWindowButton", true )    
    ButtonSetStayDownFlag( "MenuBarWindowToggleMenuWindowButton", true )
    ButtonSetStayDownFlag( "MenuBarWindowToggleOpenPartyWindowButton", true )
    ButtonSetStayDownFlag( "MenuBarWindowToggleBackpackWindowButton", true )
    ButtonSetStayDownFlag( "MenuBarWindowToggleHelpWindowButton", true )  
    ButtonSetStayDownFlag( "MenuBarWindowToggleSettingsWindowButton", true )  
    
    MenuBarWindow.InitializeIconHighlights()
    
    MenuBarWindow.UpdateTomeAlerts()
                  
                  
    WindowUtils.AddWindowStateButton( "MenuBarWindowToggleCharacterWindowButton", "CharacterWindow" )
    WindowUtils.AddWindowStateButton( "MenuBarWindowToggleMenuWindowButton", "MainMenuWindow" )
    WindowUtils.AddWindowStateButton( "MenuBarWindowToggleOpenPartyWindowButton", "EA_Window_OpenParty" )
    WindowUtils.AddWindowStateButton( "MenuBarWindowToggleHelpWindowButton", "EA_Window_Help" )
    
    -- NOTE: Hardcoding these window names may make it dificult for modders to replace with custom versions of these windows
    -- However we can't use EA_BackpackUtilsMediator to get the windowName since 
    --   it's not guaranteed to be initialized until all UI initialization is complete
    WindowUtils.AddWindowStateButton( "MenuBarWindowToggleBackpackWindowButton", "EA_Window_Backpack" )
    WindowUtils.AddWindowStateButton( "MenuBarWindowToggleAbilitiesWindowButton", "AbilitiesWindow" )
    WindowUtils.AddWindowStateButton( "MenuBarWindowToggleGuildWindowButton", "GuildWindow" )
    WindowUtils.AddWindowStateButton( "MenuBarWindowToggleTomeWindowButton", "TomeWindow" )
    WindowUtils.AddWindowStateButton( "MenuBarWindowToggleTomeWindowNewEntriesButton", "TomeWindow" )
    WindowUtils.AddWindowStateButton( "MenuBarWindowToggleSettingsWindowButton", "SettingsWindowTabbed" )
    
end

function MenuBarWindow.Shutdown()

end


-- NOTE: The highlight is limited to the backpack right now, but there are hopes
--   to add highlights to other buttons as well
function MenuBarWindow.InitializeIconHighlights()

    LabelSetText( "MenuBarWindowToggleBackpackWindowLabel", GetString (StringTables.Default.TEXT_MENUBAR_BACKPACK_OVERFLOWING) )

	-- Check if Backpack should be highlighted
    WindowRegisterEventHandler( "MenuBarWindow", SystemData.Events.PLAYER_INVENTORY_OVERFLOW_UPDATED, "MenuBarWindow.OnOverflowSlotUpdated")
	local overflowItem, overflowCount = GetOverflowData()
	MenuBarWindow.OnOverflowSlotUpdated( overflowItem, overflowCount )
	
end


----------------------------------------------------------------
-- Menu Bar Functions
----------------------------------------------------------------

function MenuBarWindow.OnOverflowSlotUpdated( overflowItemData, overflowCount )
	MenuBarWindow.SetButtonHighlightShowing( "MenuBarWindowToggleBackpackWindow", (overflowCount>0) )
end

function MenuBarWindow.SetButtonHighlightShowing( windowName, isShowing )

    MenuBarWindow.HighlightedButtons[windowName] = isShowing
    MenuBarWindow.UpdatedButtonHighlightDisplay( windowName )
end

function MenuBarWindow.UpdatedButtonHighlightDisplay( windowName, overrideShowing )
	
	local isShowing 
	if overrideShowing ~= nil then
		isShowing = overrideShowing
	else
		isShowing = MenuBarWindow.HighlightedButtons[windowName] or false
	end
	
    WindowSetShowing( windowName.."Glow", isShowing )
    WindowSetShowing( windowName.."Label", isShowing )
end

function MenuBarWindow.OnMouseoverBackpackBtnEnd()

	MenuBarWindow.UpdatedButtonHighlightDisplay( "MenuBarWindowToggleBackpackWindow" )
end


function MenuBarWindow.ToggleCharacterWindow()  
    CharacterWindow.ToggleShowing()
end

function MenuBarWindow.OnMouseoverCharacterBtn()
    WindowUtils.OnMouseOverButton( GetString( StringTables.Default.LABEL_CHARACTER ), KeyUtils.GetFirstBindingNameForAction( "TOGGLE_CHARACTER_WINDOW" ) )
end

function MenuBarWindow.ToggleGuildWindow()
    GuildWindow.ToggleShowing()
end

function MenuBarWindow.OnMouseoverGuildBtn()
    WindowUtils.OnMouseOverButton( GetString( StringTables.Default.LABEL_GUILD ), KeyUtils.GetFirstBindingNameForAction( "TOGGLE_GUILD_WINDOW" ) )
end

function MenuBarWindow.ToggleAbilitiesWindow()  
    AbilitiesWindow.ToggleShowing()
end

function MenuBarWindow.OnMouseoverAbilitiesBtn()
    WindowUtils.OnMouseOverButton( GetString( StringTables.Default.LABEL_ABILITIES ), KeyUtils.GetFirstBindingNameForAction( "TOGGLE_ABILITIES_WINDOW" ) )
end

function MenuBarWindow.ToggleMenuWindow()   
    MainMenuWindow.ToggleShowing()
end

function MenuBarWindow.OnMouseoverMenuBtn()
    WindowUtils.OnMouseOverButton( GetString( StringTables.Default.LABEL_MENU ), GetString( StringTables.Default.LABEL_ESCAPE_KEY_NAME ) )
end


function MenuBarWindow.ToggleSettingsWindow()   
    WindowUtils.ToggleShowing("SettingsWindowTabbed")
end

function MenuBarWindow.OnMouseoverSettingsBtn()
   WindowUtils.OnMouseOverButton( GetString( StringTables.Default.LABEL_USER_SETTINGS ), KeyUtils.GetFirstBindingNameForAction( "TOGGLE_USER_SETTINGS_WINDOW" ) )
end


function MenuBarWindow.ToggleTomeWindow()    
    TomeWindow.ToggleShowing()
end

function MenuBarWindow.OnMouseoverTomeBtn()
    local text = nil
    
    if( WindowGetShowing("MenuBarWindowToggleTomeWindowNewEntries" ) == true ) then
        text = GetString( StringTables.Default.TEXT_YOU_HAVE_TOME_ENTIRES  ) 
    end

    WindowUtils.OnMouseOverButton( GetString( StringTables.Default.LABEL_TOME_OF_KNOWLEDGE ), KeyUtils.GetFirstBindingNameForAction( "TOGGLE_TOME_WINDOW" ), text )
end

function MenuBarWindow.ToggleBackpackWindow()
	EA_BackpackUtilsMediator.ToggleBackpackWindow() 
end

function MenuBarWindow.OnMouseoverBackpackBtn()

	local tooltipText = GetString( StringTables.Default.LABEL_BACKPACK )
	
	if MenuBarWindow.HighlightedButtons["MenuBarWindowToggleBackpackWindow"] then
		tooltipText = tooltipText..GetString( StringTables.Default.TOOLTIP_MENUBAR_BACKPACK_OVERFLOWING )
		MenuBarWindow.UpdatedButtonHighlightDisplay( "MenuBarWindowToggleBackpackWindow", false )
	end

    WindowUtils.OnMouseOverButton( tooltipText, KeyUtils.GetFirstBindingNameForAction( "TOGGLE_BACKPACK_WINDOW" ) )
end

function MenuBarWindow.ToggleHelpWindow()   
    if ( SystemData.Territory.KOREA )
    then
        -- for Korean version, go to Manual window instead of Help window
        ManualWindow.ToggleShowing()
    else
        EA_Window_Help.ToggleShowing()    
    end
end

function MenuBarWindow.OnMouseoverHelpBtn()
    WindowUtils.OnMouseOverButton( GetString( StringTables.Default.LABEL_HELP), KeyUtils.GetFirstBindingNameForAction( "TOGGLE_HELP_WINDOW" ) )
end

function MenuBarWindow.ToggleOpenPartyWindow()
    EA_Window_OpenParty.ToggleFullWindow()
end

function MenuBarWindow.OnMouseoverOpenPartyBtn()
    WindowUtils.OnMouseOverButton( GetString( StringTables.Default.LABEL_PARTIES_AND_WARBANDS ), KeyUtils.GetFirstBindingNameForAction( "TOGGLE_PARTY_WINDOW" ) )
end

function MenuBarWindow.OnTomeAlertsUpdated()
    MenuBarWindow.UpdateTomeAlerts()
end

function MenuBarWindow.UpdateTomeAlerts()
    local tomeAlerts = DataUtils.GetTomeAlerts()
    local hasAlerts = tomeAlerts[1] ~= nil
    
    WindowSetShowing( "MenuBarWindowToggleTomeWindow", not hasAlerts )
    WindowSetShowing( "MenuBarWindowToggleTomeWindowNewEntries", hasAlerts)
end

function MenuBarWindow.Update(timePassed)
	if EA_Window_Help.AppealStatus == GameData.AppealStatus.AWAITING_PLAYER then			-- Pulse the icon in and out
		if MenuBarWindow.HelpButtonFadeTimer <= MenuBarWindow.HELP_BUTTON_FADE_MIN then
			MenuBarWindow.HelpButtonFadeTimer = MenuBarWindow.HELP_BUTTON_FADE_MIN
			MenuBarWindow.HelpButtonDirection = FADE_IN
		elseif MenuBarWindow.HelpButtonFadeTimer >= MenuBarWindow.HELP_BUTTON_FADE_MAX then 
			MenuBarWindow.HelpButtonFadeTimer = MenuBarWindow.HELP_BUTTON_FADE_MAX
			MenuBarWindow.HelpButtonDirection = FADE_OUT
		end
		
		if MenuBarWindow.HelpButtonDirection == FADE_OUT then
			MenuBarWindow.HelpButtonFadeTimer = MenuBarWindow.HelpButtonFadeTimer - timePassed
		else
			MenuBarWindow.HelpButtonFadeTimer = MenuBarWindow.HelpButtonFadeTimer + timePassed
		end

		WindowSetAlpha( "MenuBarWindowToggleHelpWindow", MenuBarWindow.HelpButtonFadeTimer )
		WindowSetAlpha( "EA_Window_HelpEditAppealButton", MenuBarWindow.HelpButtonFadeTimer )
	
	elseif EA_Window_Help.AppealStatus == GameData.AppealStatus.AWAITING_CS then			-- Fade it out a bit to indicate an outstanding appeal
		WindowSetAlpha( "MenuBarWindowToggleHelpWindow", (MenuBarWindow.HELP_BUTTON_FADE_MAX + MenuBarWindow.HELP_BUTTON_FADE_MIN)/2 )
		WindowSetAlpha( "EA_Window_HelpEditAppealButton", (MenuBarWindow.HELP_BUTTON_FADE_MAX + MenuBarWindow.HELP_BUTTON_FADE_MIN)/2 )
	
	else																				-- Set to normal state
		MenuBarWindow.HelpButtonFadeTimer = 1
		MenuBarWindow.HelpButtonDirection = FADE_OUT
		WindowSetAlpha( "MenuBarWindowToggleHelpWindow", MenuBarWindow.HELP_BUTTON_FADE_MAX )
		WindowSetAlpha( "EA_Window_HelpEditAppealButton", MenuBarWindow.HELP_BUTTON_FADE_MAX )
	end
end

----------------------------------------------------------------
-- Streaming Indicator Functions
----------------------------------------------------------------

function MenuBarWindow.InitializeStreamingIndicator()
    WindowRegisterEventHandler( "StreamingIndicator", SystemData.Events.STREAMING_STATUS_UPDATED, "MenuBarWindow.OnStreamingStatusUpdated" )
    
    MenuBarWindow.OnStreamingStatusUpdated()
end

function MenuBarWindow.OnStreamingStatusUpdated()
    if ( SystemData.StreamingData.isStreaming )
    then
        WindowSetShowing( "StreamingIndicator", true )
        WindowSetShowing( "StreamingIndicatorAnim", true )
        AnimatedImageStartAnimation( "StreamingIndicatorAnim", 0, true, false, 0 )
    else
        AnimatedImageStopAnimation( "StreamingIndicatorAnim" )
        WindowSetShowing( "StreamingIndicatorAnim", false )
        WindowSetShowing( "StreamingIndicator", false )
    end
end

function MenuBarWindow.OnMouseoverStreamingIndicator()
    local text = GetStringFromTable( "HUDStrings", StringTables.HUD.TEXT_STREAMING_TOOLTIP )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_BOTTOM )
end