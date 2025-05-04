------------------------------------------------------- Comment Notes -------------------------------------------------------------
-- Event: This means the function is used for a registered system event, such as SystemData.Events.TOGGLE_GUILD_WINDOW
-- EventHandler: This means the function has been defined by an Event Handler in a .XML file, such as GuildWindow.OnLButtonUpClose
-----------------------------------------------------------------------------------------------------------------------------------

GuildWindow = {}
GuildWindow.SavedSettings = {}

GuildWindow.TABS_PROFILE	= 1
GuildWindow.TABS_CALENDAR	= 2
GuildWindow.TABS_ROSTER		= 3
GuildWindow.TABS_ALLIANCE	= 4
GuildWindow.TABS_REWARDS	= 5
GuildWindow.TABS_ADMIN	    = 6
GuildWindow.TABS_RECRUIT	= 7
GuildWindow.TABS_MAX_NUMBER	= 7


GuildWindow.SelectedTab		= GuildWindow.TABS_PROFILE

GuildWindow.Tabs = {} 
GuildWindow.Tabs[ GuildWindow.TABS_PROFILE  ]	= { window = "GWProfile",	name="GuildWindowTabProfile",	label=StringTables.Guild.LABEL_GUILD_TAB_PROFILE,	tooltip=StringTables.Guild.TOOLTIP_GUILD_TAB_PROFILE,	permissionFunction=GuildWindowTabProfile.UpdatePermissions }
GuildWindow.Tabs[ GuildWindow.TABS_CALENDAR ]	= { window = "GWCalendar",	name="GuildWindowTabCalendar",	label=StringTables.Guild.LABEL_GUILD_TAB_CALENDAR,	tooltip=StringTables.Guild.TOOLTIP_GUILD_TAB_CALENDAR,	permissionFunction=GuildWindowTabCalendar.UpdatePermissions }
GuildWindow.Tabs[ GuildWindow.TABS_ROSTER ]		= { window = "GWRoster",	name="GuildWindowTabRoster",	label=StringTables.Guild.LABEL_GUILD_TAB_ROSTER,	tooltip=StringTables.Guild.TOOLTIP_GUILD_TAB_ROSTER,	permissionFunction=GuildWindowTabRoster.UpdatePermissions }
GuildWindow.Tabs[ GuildWindow.TABS_ALLIANCE ]	= { window = "GWAlliance",	name="GuildWindowTabAlliance",	label=StringTables.Guild.LABEL_GUILD_TAB_ALLIANCE,	tooltip=StringTables.Guild.TOOLTIP_GUILD_TAB_ALLIANCE,	permissionFunction=GuildWindowTabAlliance.UpdatePermissions }
GuildWindow.Tabs[ GuildWindow.TABS_REWARDS ]	= { window = "GWRewards",	name="GuildWindowTabRewards",	label=StringTables.Guild.LABEL_GUILD_TAB_REWARDS,	tooltip=StringTables.Guild.TOOLTIP_GUILD_TAB_REWARDS,	permissionFunction=GuildWindowTabRewards.UpdatePermissions }
GuildWindow.Tabs[ GuildWindow.TABS_ADMIN ]	    = { window = "GWAdmin",	    name="GuildWindowTabAdmin",	    label=StringTables.Guild.LABEL_GUILD_TAB_ADMIN,	    tooltip=StringTables.Guild.TOOLTIP_GUILD_TAB_ADMIN,	    permissionFunction=GuildWindowTabAdmin.UpdatePermissions }
GuildWindow.Tabs[ GuildWindow.TABS_RECRUIT ]	= { window = "GWRecruit",	name="GuildWindowTabRecruit",	label=StringTables.Guild.LABEL_GUILD_TAB_RECRUIT,	tooltip=StringTables.Guild.TOOLTIP_GUILD_TAB_RECRUIT,	permissionFunction=GuildWindowTabRecruit.UpdatePermissions }



GuildWindow.XP_TOOLTIP_ANCHOR = { Point = "bottom", 
                                  RelativeTo = "GuildXPBarWindow", 
                                  RelativePoint = "top",	
                                  XOffset = 0, 
                                  YOffset = 10 }

GuildWindow.Calendar = {}
GuildWindow.Calendar.MonthName = {
                                StringTables.Guild.DATE_MONTH_1,
                                StringTables.Guild.DATE_MONTH_2,
                                StringTables.Guild.DATE_MONTH_3,
                                StringTables.Guild.DATE_MONTH_4,
                                StringTables.Guild.DATE_MONTH_5,
                                StringTables.Guild.DATE_MONTH_6,
                                StringTables.Guild.DATE_MONTH_7,
                                StringTables.Guild.DATE_MONTH_8,
                                StringTables.Guild.DATE_MONTH_9,
                                StringTables.Guild.DATE_MONTH_10,
                                StringTables.Guild.DATE_MONTH_11,
                                StringTables.Guild.DATE_MONTH_12
                                }

GuildWindow.POLL_TYPE_KICK = 1

GuildWindow.localPlayerCache = {}
GuildWindow.localPlayerCache.statusNumber = 0

-- Event: OnInitialize Handler
function GuildWindow.Initialize()

    WindowRegisterEventHandler( "GuildWindow", SystemData.Events.GUILD_REFRESH, "GuildWindow.OnGuildRefresh")
    WindowRegisterEventHandler( "GuildWindow", SystemData.Events.GUILD_INFO_UPDATED, "GuildWindow.OnInfoUpdated")

    WindowRegisterEventHandler( "GuildWindow", SystemData.Events.GUILD_PERMISSIONS_UPDATED, "GuildWindow.OnPermissionsUpdated")
	WindowRegisterEventHandler( "GuildWindow", SystemData.Events.PLAYER_INFO_CHANGED, "GuildWindow.OnPlayerInfoChanged")
	WindowRegisterEventHandler( "GuildWindow", SystemData.Events.GUILD_POLL_UPDATED, "GuildWindow.OnPollUpdated" )

	WindowRegisterEventHandler( "GuildWindow", SystemData.Events.GUILD_ROSTER_INIT,		        "GuildWindow.OnRosterInit")
	WindowRegisterEventHandler( "GuildWindow", SystemData.Events.GUILD_MEMBER_UPDATED,	        "GuildWindow.OnMemberUpdated")
	WindowRegisterEventHandler( "GuildWindow", SystemData.Events.GUILD_MEMBER_NOTES_UPDATED,	"GuildWindowTabRoster.OnMemberNotesUpdated")
	WindowRegisterEventHandler( "GuildWindow", SystemData.Events.GUILD_MEMBER_ADDED,	        "GuildWindow.OnMemberAdded")
	WindowRegisterEventHandler( "GuildWindow", SystemData.Events.GUILD_MEMBER_REMOVED,	        "GuildWindow.OnMemberRemoved")	
	WindowRegisterEventHandler( "GuildWindow", SystemData.Events.GUILD_EXP_UPDATED,             "GuildWindow.UpdateGuildXPBar")

	WindowRegisterEventHandler( "GuildWindow", SystemData.Events.TRANSFER_GUILD, "GuildWindow.TransferGuild")

    -- Initialize All of the Tabs
    GuildWindowTabRoster.Initialize()
    GuildWindowTabCalendar.Initialize()
    GuildWindowTabRecruit.Initialize()
    
    
	GuildWindow.LoadSettings()

    GuildWindow.SetTabLabels()
    GuildWindow.UpdateGuildName()
    GuildWindow.UpdateGuildXPBar()

end

function GuildWindow.OnShutdown()    
	GuildWindow.SaveSettings()
end

function GuildWindow.SaveSettings()
	GuildWindow.SavedSettings.SelectedTab = GuildWindow.SelectedTab

	GuildWindow.SavedSettings[GuildWindow.TABS_ROSTER] = {}
	GuildWindow.SavedSettings[GuildWindow.TABS_ROSTER].sortButton  = GuildWindowTabRoster.sort.type
	GuildWindow.SavedSettings[GuildWindow.TABS_ROSTER].sortOrder   = GuildWindowTabRoster.sort.order
	GuildWindow.SavedSettings[GuildWindow.TABS_ROSTER].sortFilter  = GuildWindowTabRoster.sort.filter

end

function GuildWindow.LoadSettings()

    if( GuildWindow.IsPlayerInAGuild() )
    then
        if GuildWindow.SavedSettings ~= nil and GuildWindow.SavedSettings.SelectedTab ~= nil then
		    GuildWindow.SelectedTab = GuildWindow.SavedSettings.SelectedTab
		    GuildWindow.SelectTab(GuildWindow.SelectedTab)
	    else
		    GuildWindow.SelectTab(GuildWindow.TABS_PROFILE)
	    end
	else
	    GuildWindow.SelectTab(nil)
    end


	if GuildWindow.SavedSettings[GuildWindow.TABS_ROSTER] ~= nil 
	then
		GuildWindowTabRoster.sort.type   = GuildWindow.SavedSettings[GuildWindow.TABS_ROSTER].sortButton
		GuildWindowTabRoster.sort.order  = GuildWindow.SavedSettings[GuildWindow.TABS_ROSTER].sortOrder
		GuildWindowTabRoster.sort.filter = GuildWindow.SavedSettings[GuildWindow.TABS_ROSTER].sortFilter

		ButtonSetPressedFlag("GWRosterHideOfflineCheckBox", GuildWindow.SavedSettings[GuildWindow.TABS_ROSTER].sortFilter == GuildWindowTabRoster.FILTER_MEMBERS_ONLINE)
		GuildWindowTabRoster.UpdateMemberList()
	end
end

-- Event: SystemData.Events.TOGGLE_GUILD_WINDOW. Called from MenuBarWindow to show/hide the Guild Window or when the user hits 'G'
function GuildWindow.ToggleShowing()
    WindowUtils.ToggleShowing( "GuildWindow" )
end

-- Event: OnShown Handler
function GuildWindow.OnShown()
	WindowUtils.OnShown(nil, WindowUtils.Cascade.MODE_AUTOMATIC)

	if GuildWindow.IsPlayerInAGuild() then
		GuildWindow.SetupInAGuild()
	else
		GuildWindow.SetupNotInAGuild()
		return
	end

    GuildWindowTabProfile.ClearEditBoxes()

end

-- Event: OnHidden Handler. Also gets called after the player leaves their own guild.
function GuildWindow.OnHidden()
    WindowUtils.OnHidden()
	GuildWindow.SaveSettings()

    GuildWindowTabProfile.ClearEditBoxes()

    if( WindowGetShowing("HeraldryEditor") == true )
    then
        HeraldryEditor.OnHidden()
    end

    if( WindowGetShowing("GuildTacticsList") == true )
    then
        GuildTacticsList.OnHidden()
    end
end

-- EventHandler: Called when the user L-Clicks on the "close" button on the title bar
function GuildWindow.OnLButtonUpClose()
    GuildWindowTabProfile.ClearEditBoxes()
    GuildWindowTabAdmin.UpdateTitleBeingEdited(-1)
	GuildWindow.SaveSettings()
    WindowSetShowing( "GuildWindow", false )
end

function GuildWindow.OnMouseOverBackground()
    -- This is a stub function to handle mouseover input so that the cursor doesn't mouseover things behind the window background.
end

--------------------------------------------------------------------------------------------------------------------------------
-- Update Functions
-- Things change. People change. Data Changes. Hairstyles change. Here's the group of functions to handle real-time UI updates.
--------------------------------------------------------------------------------------------------------------------------------

-- Event: SystemData.Events.GUILD_REFRESH. This is called when the server sends a message to clear/flush all Guild Data
function GuildWindow.OnGuildRefresh()
	GuildWindow.SetupNotInAGuild()
	GuildWindowTabBanner.UpdateAllBannerConfigurations()
	GuildWindowTabRewards.InitializeRewards()
end

-- Event: SystemData.Events.GUILD_INFO_UPDATED. This is called when information about the Guild itself is changed, 
-- such as the MOTD, Email, Summary, or Playstyle.
function GuildWindow.OnInfoUpdated()
    GuildWindow.UpdateGuildName()

	if GuildWindow.IsPlayerInAGuild() then
		GuildWindow.SetupInAGuild()
	else
		GuildWindow.SetupNotInAGuild()
	end
end

-- global (to file) var to control whether or not we should switch to the profile tab when we get guild info
local shouldSwitchToProfileTab = true

-- If the player isn't in a Guild, there's a lot of stuff to do
function GuildWindow.SetupNotInAGuild()
    -- Change the window title bar text
    LabelSetText( "GuildWindowTitleBarText", GetGuildString( StringTables.Guild.LABEL_GUILD_NOT_IN_GUILD ) )

    -- Hide the XP Bar.
    WindowSetShowing( "GuildXPBarWindow", false )
    WindowSetShowing( "GuildXPRankBackground", false )
    WindowSetShowing( "GuildXPRankText", false )

    -- Default to the Recruit / Search Tab    
	GuildWindow.SelectTab(GuildWindow.TABS_RECRUIT)	
	GuildWindowTabRecruit.SetInGuild( false )

    -- Hide all the Tabs
    WindowSetShowing("GuildWindowTab", false)
    
    -- switch this var on in case we join another guild
    shouldSwitchToProfileTab = true
end

-- If the player is in a Guild, there's a lot of stuff to unhide
function GuildWindow.SetupInAGuild()

	GuildWindowTabRecruit.SetInGuild( true )

    -- The first time we get guild info, switch to the profile tab, this way
    -- new guild members won't see the recruit tab first thing
    if shouldSwitchToProfileTab
    then
        GuildWindow.SelectTab(GuildWindow.TABS_PROFILE)
        shouldSwitchToProfileTab = false
    else
        GuildWindow.SelectTab(GuildWindow.SelectedTab)
    end
    
    -- Show the XP Bar.
    WindowSetShowing( "GuildXPBarWindow", true )
    WindowSetShowing( "GuildXPRankBackground", true )
    WindowSetShowing( "GuildXPRankText", true )
    

    LabelSetText( "GuildWindowTitleBarText", GameData.Guild.m_GuildName )
    GuildWindowTabProfile.UpdateStatisticFoundedDate()

    -- Show all the Tabs
    WindowSetShowing("GuildWindowTab", true)
    
	GuildWindowTabAdmin.Initialize()
end

function GuildWindow.IsPlayerInAGuild()
    if (GameData.Guild.m_GuildName ~= L"") then
        return true
    else
        return false
    end
end

function GuildWindow.UpdateGuildName()
	LabelSetText( "GuildWindowTitleBarText", GameData.Guild.m_GuildName )
end

function GuildWindow.UpdateGuildPlaySyle()
    --ComboBoxSetSelectedMenuItem("GWProfilePlayStyleCombo", GameData.Guild.m_GuildPlayStyle +1)	-- LUA is 1-based
end

-- Whenever Guild Permissions change, we have to show/hide buttons and other UI elements based on the new permission.
-- Each Guild Window Tab is responsible for doing this, so just call whatever one is in view (if any)
function GuildWindow.OnPermissionsUpdated()

    GuildWindowTabAdmin.InitializeGuildTitleWindowIDs()

	if WindowGetShowing("GuildWindow") == false then
		return
	end

    if( GuildWindow.SelectedTab )
    then    
	    GuildWindow.Tabs[GuildWindow.SelectedTab].permissionFunction()
	end
end

function GuildWindow.OnRosterInit()

    -- This function will assign the player's rank, so permissions must be updated
    GuildWindowTabRoster.OnRosterInit()
    
    GuildWindow.OnPermissionsUpdated()

end

--------------------------------------------------------------------------------------------------------------------------------
-- Tab related Functions
-- These functions relate to setting up, pressing, and updating the tab buttons, or for buttons that act like a tab.
--------------------------------------------------------------------------------------------------------------------------------

-- Initializes all the text on the tab buttons
function GuildWindow.SetTabLabels()
    for index, TabData in ipairs(GuildWindow.Tabs) do
        ButtonSetText(TabData.name, GetGuildString(TabData.label ) )
    end
end

-- Changes the state of the Tab Buttons and show / hide the tabbed window
function GuildWindow.SetHighlightedTabText(tabNumber)

    for index, TabIndex in ipairs(GuildWindow.Tabs) do
        if (index ~= tabNumber) then
            ButtonSetPressedFlag( TabIndex.name, false )
            WindowSetShowing( TabIndex.window, false )
        else
            ButtonSetPressedFlag( TabIndex.name, true )
            WindowSetShowing( TabIndex.window, true )
        end
    end

end

-- This function hides all the tabbed windows and shows the tabbed window based on the param.
function GuildWindow.SelectTab(tabNumber)

    GuildWindow.SelectedTab = tabNumber
    GuildWindow.SetHighlightedTabText(GuildWindow.SelectedTab)

	if GuildWindow.SelectedTab == GuildWindow.TABS_CALENDAR 
	then
		GuildWindowTabCalendar.SetAppointmentMode(0)
		GuildWindowTabCalendar.UpdateCalendarWatermark()
		GuildWindowTabCalendar.UpdateAppointmentList()
		Calendar.Reset()
	end

	if tabNumber == GuildWindow.TABS_ROSTER 
	then
		GuildWindowTabRoster.UpdateMemberList()
	end

	if GuildWindow.SelectedTab == GuildWindow.TABS_REWARDS 
	then
		GuildWindowTabRewards.PopulateRewards()
	end

	if GuildWindow.SelectedTab == GuildWindow.TABS_BANNER then
		GuildWindowTabRewards.PopulateRewards()
		GuildWindowTabBanner.UpdatePurchasedTacticIcons()
	end

	GuildWindow.OnPermissionsUpdated()
end

-- EventHandler for when the user moves the mouse over a Tab
function GuildWindow.OnMouseOverTab()
    local windowName	= SystemData.ActiveWindow.name
    local windowIndex	= WindowGetId (windowName)

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, GetGuildString( GuildWindow.Tabs[windowIndex].tooltip) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()
    
    local anchor = { Point="bottom", RelativeTo=windowName, RelativePoint="top", XOffset=0, YOffset=32 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

-- EventHandler for OnLButtonUp when a user L- clicks a tab
function GuildWindow.OnLButtonUpTab()

    -- Don't allow the user to select the tab when disabled.
    if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true )
    then
        return
    end

    GuildWindow.SelectTab(WindowGetId (SystemData.ActiveWindow.name))
end

-----------------------------------------------------
-- XP BAR
-----------------------------------------------------

function GuildWindow.UpdateGuildXPBar()

    local xpTotal				= GameData.Guild.m_GuildExpCurrent
    local xpInLevel				= GameData.Guild.m_GuildExpInCurrentLevel
    local xpNextLevel			= GameData.Guild.m_GuildExpNeeded
    local xpNeeded				= xpNextLevel - xpInLevel
    local xpPrevLevel			= xpTotal - xpInLevel
  
    StatusBarSetCurrentValue( "GuildXPBarWindowBar", xpInLevel )	
	StatusBarSetMaximumValue( "GuildXPBarWindowBar", xpNextLevel-xpPrevLevel )
    
	GuildWindow.UpdateGuildRank()
	GuildWindowTabProfile.UpdateStatisticsText()
end

function GuildWindow.UpdateGuildRank()
    LabelSetText        ("GuildXPRankText", L""..GameData.Guild.m_GuildRank)
	LabelSetTextColor   ("GuildXPRankText", DefaultColor.GUILD_RANK.r, DefaultColor.GUILD_RANK.g, DefaultColor.GUILD_RANK.b)

	GuildWindowTabBanner.UpdateAllBannerConfigurations()
	GuildWindowTabBanner.UpdateSelectedBanner()
	GuildWindowTabCalendar.UpdateCalendarWatermark()
	GuildWindowTabRewards.UpdateRewardRowColors()
	GuildWindowTabRewards.UpdateRewardTactics()
end

function GuildWindow.OnMouseOverXPBar()

    local xpTotal				= GameData.Guild.m_GuildExpCurrent
    local xpInLevel				= GameData.Guild.m_GuildExpInCurrentLevel
    local xpNextLevel			= GameData.Guild.m_GuildExpNeeded
    local xpNeeded				= xpNextLevel - xpInLevel
    local xpPrevLevel			= xpTotal     - xpInLevel
    local denom					= xpNextLevel - xpPrevLevel
    local percent				= 0
    if denom ~= 0 then
		percent = xpInLevel/ denom*100
	end
    local percentString			= wstring.format(L"%d", percent)
    
    local line1 = GetGuildString(StringTables.Guild.TOOLTIP_GUILD_XP_TITLE )
    local line2 = GetGuildString(StringTables.Guild.TOOLTIP_GUILD_XP_DESCRIPTION )
    local line3 = GetFormatStringFromTable( "guildstrings", StringTables.Guild.TEXT_GUILD_XP_TOTAL_X, { StringUtils.FormatNumberIntoDelimitedString(xpTotal) } )
    local line4
    if GameData.Guild.m_GuildRank < 40 then
		line4 = GetFormatStringFromTable( "guildstrings", StringTables.Guild.TEXT_GUILD_XP_NEEDED_X_Y_Z_PERCENT, 
		{ StringUtils.FormatNumberIntoDelimitedString(xpInLevel),
		  StringUtils.FormatNumberIntoDelimitedString(xpNextLevel-xpPrevLevel),
		  StringUtils.FormatNumberIntoDelimitedString(percentString) } )
	end
	
    Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name )
    Tooltips.SetTooltipText( 1, 1, line1)
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, line2)
    Tooltips.SetTooltipText( 3, 1, line3)
    Tooltips.SetTooltipColorDef( 3, 1, Tooltips.COLOR_HEADING )
    if GameData.Guild.m_GuildRank < 40 then
		Tooltips.SetTooltipText( 4, 1, line4)
        Tooltips.SetTooltipColorDef( 4, 1, Tooltips.COLOR_HEADING )
    end
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( GuildWindow.XP_TOOLTIP_ANCHOR )
    
end

-- When a player logs out and back in, the interface loads before the charinfo updates. 
-- So now, handle the event that told us the charinfo changed (e.g., realm)
function GuildWindow.OnPlayerInfoChanged()

	GuildWindowTabBanner.UpdateBackgroundImage()
	GuildWindowTabRewards.InitializeRewardStrings()
	HeraldryEditor.InitializeComboBoxes()
end

function GuildWindow.OnPollUpdated()
	GuildWindowTabAlliance.DrawMembersList()
end

function GuildWindow.OnMemberUpdated(memberData)
	GuildWindowTabRoster.OnMemberUpdated(memberData)
	
    if GuildWindow.SelectedTab == GuildWindow.TABS_ADMIN
    then
        GuildWindowTabAdmin.UpdateGuildTitles()
    end
end

function GuildWindow.OnMemberNotesUpdated(memberNotes)
	GuildWindowTabRoster.OnMemberNotesUpdated(memberNotes)
end

function GuildWindow.OnMemberAdded(memberData)
	GuildWindowTabRoster.OnMemberAdded(memberData)
end

function GuildWindow.OnMemberRemoved(memberID)
	GuildWindowTabRoster.OnMemberRemoved(memberID)
end

function GuildWindow.UpdateLocalPlayerCache(memberData)
	GuildWindow.localPlayerCache = {}

	if memberData == nil then
		return
	end

	GuildWindow.localPlayerCache.statusNumber = memberData.statusNumber
end

function GuildWindow.SetupTransferGuildDialog()
    WindowSetShowing("TransferGuildConfirmationWindow", false)
    ButtonSetText("TransferGuildConfirmationWindowConfirmTransferButton", GetGuildString(StringTables.Guild.BUTTON_CONFIRM_TRANSFER) )
    ButtonSetText("TransferGuildConfirmationWindowCancel", GetGuildString(StringTables.Guild.BUTTON_CANCEL_TRANSFER) )
    LabelSetText( "TransferGuildConfirmationWindowLabelDialog", GetGuildString(StringTables.Guild.TEXT_TRANSFER_GUILD_CONFIRMATION) )
	ButtonSetDisabledFlag("TransferGuildConfirmationWindowConfirmTransferButton", true)
end

function GuildWindow.TransferGuild()
	local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
	if GuildWindow.IsPlayerInAGuild() and playerTitleNumber == SystemData.GuildRanks.LEADER then
		GuildWindow.SetupTransferGuildDialog()
		WindowSetShowing("TransferGuildConfirmationWindow", true)
		GuildWindow.GiveTranferGuildDialogEditBoxFocus()
		TextEditBoxSetText("TransferGuildConfirmationWindowEdit", L"" )
	end
end

function GuildWindow.ConfirmTransferGuild()
	-- Ensure the player typed in YES
	if TransferGuildConfirmationWindowEdit.Text ~= L"" then
		local response = wstring.upper(TransferGuildConfirmationWindowEdit.Text)
		local bConfirmedTransferGuild = WStringsCompare(response, GetGuildString(StringTables.Guild.BUTTON_CONFIRM_TRANSFER_YES)) == 0
		if bConfirmedTransferGuild then
			ConfirmedTransferGuild()	-- Registered C function that sends the command to the server to begin transfering the guild
		end
		GuildWindow.HideTransferGuildConfirmationDialog()
	else
		GuildWindow.HideTransferGuildConfirmationDialog()
	end
end

function GuildWindow.HideTransferGuildConfirmationDialog()
	WindowAssignFocus("TransferGuildConfirmationWindowEdit", false)
	WindowSetShowing("TransferGuildConfirmationWindow", false)
end

function GuildWindow.GiveTranferGuildDialogEditBoxFocus()
	WindowAssignFocus("TransferGuildConfirmationWindowEdit", true)
end

function GuildWindow.OnTextChangedTransferGuildConfirmationDialog()
	if TransferGuildConfirmationWindowEdit.Text ~= L"" then
		-- check to see if we have spelled yes yet
		if (WStringsCompare(TransferGuildConfirmationWindowEdit.Text, GetGuildString(StringTables.Guild.BUTTON_CONFIRM_TRANSFER_YES)) == 0) then
			ButtonSetDisabledFlag("TransferGuildConfirmationWindowConfirmTransferButton", false)
		else
			ButtonSetDisabledFlag("TransferGuildConfirmationWindowConfirmTransferButton", true)
		end
	else
		ButtonSetDisabledFlag("TransferGuildConfirmationWindowConfirmTransferButton", true)
	end
end

function GuildWindow.OnMouseOverTransferGuildConfirmationDialog()

end
