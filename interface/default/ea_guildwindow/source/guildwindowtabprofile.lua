GuildWindowTabProfile = {}

function GuildWindowTabProfile.Initialize()
	
	GuildWindowTabProfile.InitializeNews()

	-- Update the Guild information
	GuildWindowTabProfile.OnInfoUpdated()

	-- Hide all the Edit Boxes
	GuildWindowTabProfile.ClearEditBoxes()

    -- Center the MOTD text.
    LabelSetTextAlign( "GWProfileMOTDText", "center" )

    ButtonSetText( "GWProfileInfoTitleText", GetGuildString(StringTables.Guild.HEADER_PROFILE_DETAILS) )
    ButtonSetDisabledFlag( "GWProfileInfoTitleText", true )

    ButtonSetText( "GWProfileGuildStatisticsTitle", GetGuildString(StringTables.Guild.GUILD_INFORMATION) )
    ButtonSetDisabledFlag( "GWProfileGuildStatisticsTitle", true )

    LabelSetText( "GWProfileGuildStatisticsFoundedTitle", GetGuildString( StringTables.Guild.GUILD_INFORMATION_FOUNDED ) )
    LabelSetText( "GWProfileGuildStatisticsMembersTitle", GetGuildString( StringTables.Guild.GUILD_INFORMATION_MEMBERS ) )
    LabelSetText( "GWProfileGuildStatisticsRenownTitle", GetGuildString( StringTables.Guild.GUILD_INFORMATION_RENOWN ) )
    LabelSetText( "GWProfileGuildStatisticsTaxRateTitle", GetGuildString( StringTables.Guild.GUILD_INFORMATION_TAX_RATE ) )
    LabelSetText( "GWProfileGuildStatisticsKeepTitle", GetGuildString( StringTables.Guild.GUILD_INFORMATION_KEEP ) )
    LabelSetText( "GWProfileGuildStatisticsUpkeepTitle", GetGuildString( StringTables.Guild.GUILD_INFORMATION_UPKEEP ) )

    LabelSetText("GWProfilePersonalStatisticsTitle", GetGuildString(StringTables.Guild.PERSONAL_INFORMATION) )

    LabelSetText( "GWProfilePersonalStatisticsDateJoinedTitle", GetGuildString( StringTables.Guild.PERSONAL_INFORMATION_DATE_JOINED ) )
    LabelSetText( "GWProfilePersonalStatisticsTitleTitle", GetGuildString( StringTables.Guild.PERSONAL_INFORMATION_TITLE ) )
    LabelSetText( "GWProfilePersonalStatisticsRenownContributedTitle", GetGuildString( StringTables.Guild.PERSONAL_INFORMATION_RENOWN_CONTRIBUTED ) )
    LabelSetText( "GWProfilePersonalStatisticsTitheContributedTitle", GetGuildString( StringTables.Guild.PERSONAL_INFORMATION_TITHE_CONTRIBUTED ) )

	ButtonSetText( "GWProfileNewsHeader", GetGuildString(StringTables.Guild.HEADER_GUILD_NEWS) )
	ButtonSetDisabledFlag( "GWProfileNewsHeader", true )
	
	ButtonSetText( "GWProfileNewsFilterAll", GetGuildString(StringTables.Guild.NEWS_FILTER_BUTTON_ALL) )
	ButtonSetText( "GWProfileNewsFilterRvR", GetGuildString(StringTables.Guild.NEWS_FILTER_BUTTON_RVR) )
	ButtonSetText( "GWProfileNewsFilterEvents", GetGuildString(StringTables.Guild.NEWS_FILTER_BUTTON_EVENTS) )
	ButtonSetText( "GWProfileNewsFilterRanks", GetGuildString(StringTables.Guild.NEWS_FILTER_BUTTON_RANKS) )
	
    WindowRegisterEventHandler( "GuildWindowTabProfile", SystemData.Events.GUILD_INFO_UPDATED, "GuildWindowTabProfile.OnInfoUpdated" )
    WindowRegisterEventHandler( "GuildWindowTabProfile", SystemData.Events.GUILD_EXP_UPDATED, "GuildWindowTabProfile.OnGuildExpUpdated" )
    WindowRegisterEventHandler( "GuildWindowTabProfile", SystemData.Events.GUILD_TAX_TITHE_UPDATED, "GuildWindowTabProfile.OnTaxTitheRateUpdated" )
    WindowRegisterEventHandler( "GuildWindowTabProfile", SystemData.Events.GUILD_KEEP_UPDATED, "GuildWindowTabProfile.OnKeepUpdated" )
    WindowRegisterEventHandler( "GuildWindowTabProfile", SystemData.Events.GUILD_PERSONAL_STATISTICS_UPDATED, "GuildWindowTabProfile.OnPersonalStatisticsUpdated" )
end

function GuildWindowTabProfile.InitializeNews()
    -- Initialize News Logging
    LogDisplaySetShowTimestamp( "GWProfileNewsText", false )
    LogDisplaySetShowLogName( "GWProfileNewsText", false )
    LogDisplaySetShowFilterName( "GWProfileNewsText", false)
    LogDisplayAddLog( "GWProfileNewsText", "GuildNews", true )
    
    LogDisplaySetFilterState( "GWProfileNewsText", "GuildNews", SystemData.GuildNewsLogFilters.GENERAL, true )
    LogDisplaySetFilterState( "GWProfileNewsText", "GuildNews", SystemData.GuildNewsLogFilters.ADVANCEMENTS, true )
    LogDisplaySetFilterState( "GWProfileNewsText", "GuildNews", SystemData.GuildNewsLogFilters.REMINDERS, true )
    LogDisplaySetFilterState( "GWProfileNewsText", "GuildNews", SystemData.GuildNewsLogFilters.CREATION, true )
    LogDisplaySetFilterState( "GWProfileNewsText", "GuildNews", SystemData.GuildNewsLogFilters.MEMBERJOINED, true )
    ButtonSetPressedFlag( "GWProfileNewsFilterAll", true )
    
    -- TextLog filter colors aren't working... the filters are correct per the filter names printed out, but the colors just won't stick!
    LogDisplaySetFilterColor( "GWProfileNewsText", "GuildNews", SystemData.GuildNewsLogFilters.GENERAL, 255, 255, 255 ) -- White
    LogDisplaySetFilterColor( "GWProfileNewsText", "GuildNews", SystemData.GuildNewsLogFilters.ADVANCEMENTS, 255, 255, 0 ) -- Yellow
    LogDisplaySetFilterColor( "GWProfileNewsText", "GuildNews", SystemData.GuildNewsLogFilters.REMINDERS, 255, 102, 255 ) -- Lavendar
    LogDisplaySetFilterColor( "GWProfileNewsText", "GuildNews", SystemData.GuildNewsLogFilters.CREATION, 255, 204, 51 ) -- Orange
    LogDisplaySetFilterColor( "GWProfileNewsText", "GuildNews", SystemData.GuildNewsLogFilters.MEMBERJOINED, 102, 255, 102 ) -- Light Green
end

-- TODO: only call this function when all statistics need updated
function GuildWindowTabProfile.UpdateStatisticsText()
	GuildWindowTabProfile.UpdateStatisticFoundedDate()
	GuildWindowTabProfile.UpdateStatisticMembers()
    GuildWindowTabProfile.UpdateStatisticRenown()
    GuildWindowTabProfile.UpdateStatisticTaxRate()
    GuildWindowTabProfile.UpdateStatisticKeep()
    GuildWindowTabProfile.UpdateStatisticUpkeep()

    GuildWindowTabProfile.UpdatePersonalStatisticDateJoined()
    GuildWindowTabProfile.UpdatePersonalStatisticTitle()
    GuildWindowTabProfile.UpdatePersonalStatisticTitheContributed()
    GuildWindowTabProfile.UpdatePersonalStatisticRenownContributed()
end

function GuildWindowTabProfile.UpdateStatisticFoundedDate()
	local dateText = GetFormatStringFromTable( "guildstrings", StringTables.Guild.DATE_FORMAT_DAY_MONTH_YEAR_NUMBERS, {GameData.Guild.m_GuildCreationDateDay, GameData.Guild.m_GuildCreationDateMonth, GameData.Guild.m_GuildCreationDateYear} )
    LabelSetText( "GWProfileGuildStatisticsFoundedText", dateText )
end

function GuildWindowTabProfile.UpdateStatisticMembers()
    local membersOnline = 0
    local totalMembers = 0
    for _, memberData in pairs( GuildWindowTabRoster.memberListData )
    do
        totalMembers = totalMembers + 1
        if ( GuildWindowTabRoster.IsMemberOnline( memberData ) )
        then
            membersOnline = membersOnline + 1
        end
    end
    local memberText = GetFormatStringFromTable( "guildstrings", StringTables.Guild.LABEL_FRACTION, {membersOnline, totalMembers} )
    LabelSetText( "GWProfileGuildStatisticsMembersText", memberText )
end

function GuildWindowTabProfile.UpdateStatisticRenown()
    LabelSetText( "GWProfileGuildStatisticsRenownText", L""..GameData.Guild.m_GuildRenown )
end

function GuildWindowTabProfile.UpdateStatisticTaxRate()
    local rate = GameData.Guild.TaxRate
    LabelSetText( "GWProfileGuildStatisticsTaxRateText", GetStringFormat( StringTables.Default.GENERIC_PERCENTAGE, { L""..rate } ) )
end

function GuildWindowTabProfile.UpdateStatisticKeep()
    local keepId = GameData.Guild.KeepId

    local text = L""
    if( keepId ~= 0 )
    then
        text = GetKeepName( keepId )
    else    
        text = GetString( StringTables.Default.LABEL_NONE )
    end

    LabelSetText( "GWProfileGuildStatisticsKeepText", text )
end

function GuildWindowTabProfile.UpdateStatisticUpkeep()
    local cost = GameData.Guild.KeepUpkeep
    MoneyFrame.FormatMoney( "GWProfileGuildStatisticsUpkeepMoney", cost, MoneyFrame.SHOW_EMPTY_WINDOWS )
end

function GuildWindowTabProfile.UpdatePersonalStatisticDateJoined()
    local dateText = GetFormatStringFromTable( "guildstrings", StringTables.Guild.DATE_FORMAT_DAY_MONTH_YEAR_NUMBERS, { GameData.Guild.PersonalJoinedDay, GameData.Guild.PersonalJoinedMonth, GameData.Guild.PersonalJoinedYear} )
    LabelSetText( "GWProfilePersonalStatisticsDateJoinedText", dateText )
end

function GuildWindowTabProfile.UpdatePersonalStatisticTitle()
    local title = nil

    local localMemberData = GuildWindowTabRoster.GetMember()
    if ( localMemberData ~= nil )
    then
        title = localMemberData.titleString
    else
        title = GetString( StringTables.Default.UNKNOWN )
    end

    LabelSetText( "GWProfilePersonalStatisticsTitleText", title )
end

function GuildWindowTabProfile.UpdatePersonalStatisticTitheContributed()
    local amount = GameData.Guild.PersonalCoinContributed
    MoneyFrame.FormatMoney( "GWProfilePersonalStatisticsTitheContributedMoney", amount, MoneyFrame.SHOW_EMPTY_WINDOWS )
end

function GuildWindowTabProfile.UpdatePersonalStatisticRenownContributed()
    local amount = GameData.Guild.PersonalRenownContributed
    LabelSetText( "GWProfilePersonalStatisticsRenownContributedText", L""..amount )
end

--------------------------------------
-- System Event Functions			--
--------------------------------------

function GuildWindowTabProfile.OnInfoUpdated()
	LabelSetText("GWProfileMOTDText", GameData.Guild.m_GuildMOTD)
	LabelSetText("GWProfileDetailsText", GameData.Guild.m_GuildDetails)
    GuildWindowTabProfile.UpdateStatisticsText()
end

function GuildWindowTabProfile.OnGuildExpUpdated()
    GuildWindowTabProfile.UpdateStatisticRenown()
end

function GuildWindowTabProfile.OnTaxTitheRateUpdated( tax, tithe )
    LabelSetText( "GWProfileGuildStatisticsTaxRateText", GetStringFormat( StringTables.Default.GENERIC_PERCENTAGE, { L""..tax } ) )
end

function GuildWindowTabProfile.OnKeepUpdated()
    GuildWindowTabProfile.UpdateStatisticKeep()
    GuildWindowTabProfile.UpdateStatisticUpkeep()
end

function GuildWindowTabProfile.OnPersonalStatisticsUpdated()
    GuildWindowTabProfile.UpdatePersonalStatisticDateJoined()
    GuildWindowTabProfile.UpdatePersonalStatisticTitheContributed()
    GuildWindowTabProfile.UpdatePersonalStatisticRenownContributed()
end

function GuildWindowTabProfile.OnGuildMembersUpdated()
    GuildWindowTabProfile.UpdateStatisticMembers()
    GuildWindowTabProfile.UpdatePersonalStatisticTitle()
end

--------------------------------------
-- Guild Command Functions --
--------------------------------------

function GuildWindowTabProfile.GuildCommandMOTD()
    SendChatText( L"/guildmotd "..GWProfileMOTDEditBox.Text, L"" )
end

function GuildWindowTabProfile.GuildCommandDetails()
    SendChatText( L"/guilddetails "..GWProfileDetailsEditBox.Text, L"" )
end

--------------------------------------
-- Edit Box Functions --
--------------------------------------

-- If we have focus within an edit box, and click the Edit Text icon (or hit Enter), then we send the guild command. Otherwise show the Edit Box.
function GuildWindowTabProfile.OnLButtonUpEditTextIcon()
	local windowName           = SystemData.ActiveWindow.name
	local windowID             = WindowGetId( windowName )
	local windowEditBoxName    = GuildWindowTabProfile.EditBoxes[windowID].windowName.."EditBox"
	local windowTextName       = GuildWindowTabProfile.EditBoxes[windowID].windowName.."Text"

	-- Figure out if the Editbox is showing
	bShowing = WindowGetShowing(windowEditBoxName)

	if (bShowing == true) then
		GuildWindowTabProfile.EditBoxes[windowID].functionOnEnter()
		WindowSetShowing(windowEditBoxName, false)
		WindowAssignFocus(windowEditBoxName, false)
		WindowSetShowing(windowTextName, true)		
	else
		--TextEditBoxSetText(windowEditBoxName, GameData.Guild.m_GuildMOTD)
		-- Well, if there is a way to embed a ref to gamedata inside a table, I don't know how to do it. So, we'll resort to IF THEN :(
		
		-- Set the text in the edit box to the label text
		if windowID == GuildWindowTabProfile.EDITBOXES_MOTD then
			TextEditBoxSetText(windowEditBoxName, GameData.Guild.m_GuildMOTD)
		elseif windowID == GuildWindowTabProfile.EDITBOXES_DETAILS then
			TextEditBoxSetText(windowEditBoxName, GameData.Guild.m_GuildDetails)
		end

		WindowSetShowing(windowEditBoxName, true)	-- Show the Edit Box
		WindowAssignFocus(windowEditBoxName, true)	-- Set the cursor inside the newly opened Edit Box
		WindowSetShowing(windowTextName, false)		-- Hide the Text that was there
	end
end

-- Show a tooltip when the user hovers over the Edit Text icon
function GuildWindowTabProfile.OnMouseOverEditTextIcon()
	local windowName   = SystemData.ActiveWindow.name
	local windowID     = WindowGetId( windowName )

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    --Tooltips.SetTooltipText (1, 1, GetGuildString( StringTables.Guild.TOOLTIP_EDIT_TEXT_MOTD ) )
	Tooltips.SetTooltipText (1, 1, GetGuildString( GuildWindowTabProfile.EditBoxes[windowID].tooltip ) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
    Tooltips.Finalize ()
    
    local anchor = { Point="bottomright", RelativeTo=windowName, RelativePoint="topleft", XOffset=25, YOffset=25 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function GuildWindowTabProfile.OnKeyEscapeEditBox()
    -- Escape out of any Edit box we happen to be in, changing nothing
    GuildWindowTabProfile.ClearEditBoxes()
end

-- Clear the text from all the edit boxes and remove any focus they may have
function GuildWindowTabProfile.ClearEditBoxes()
    for index, data in ipairs(GuildWindowTabProfile.EditBoxes) do
		TextEditBoxSetText(data.windowName.."EditBox", L"")		-- Clear any text in the editbox.
		WindowAssignFocus(data.windowName.."EditBox", false)	-- Remove any focus the edit box may have had
		WindowSetShowing(data.windowName.."EditBox", false)		-- Hide the editbox.

		WindowSetShowing(data.windowName.."Text", true)			-- Show the label
	end
end

function GuildWindowTabProfile.OnSelChangedRecruiting()
	local recruitingID = ComboBoxGetSelectedMenuItem("GWProfileRecruitingCombo")
end

function GuildWindowTabProfile.OnSelChangedPlayStyle()
end

function GuildWindowTabProfile.UpdatePermissions()
	if GuildWindow.SelectedTab ~= GuildWindow.TABS_PROFILE then
		return
	end

	local localPlayerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
	local bCanEditGuildProfile = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.EDIT_PROFILE, localPlayerTitleNumber)

	-- If the player doesn't have permission to alter the Guild Profile, then hide the text edit buttons
	WindowSetShowing("GWProfileMOTDEditButton", bCanEditGuildProfile)
	WindowSetShowing("GWProfileDetailsEditButton", bCanEditGuildProfile)
end

-----------------
--  EDIT BOXES --
-----------------
-- Each Edit box is templated from Templates_GuildWindow.xml to include the following:
--	1. Text
--	2. Edit Box
--  3. An icon anchored to the bottom-right. When clicked, it does one of two things:
--		a) If the label is showing, hide it and show the editbox. Also, auto-fill the editbox with the label text.
--		b) If the editbox is showing, hide the editbox and call a function. Note: Do not set the text label here. That's done via server messaging.
--
-- Example: The Message of the Day shows the Guild's Message Of The Day text. When the icon is clicked, the text is hidden and an editbox appears.
--			After hitting ENTER or clicking the icon again, a slash command is sent to the server, the editbox is hidden, and the original text
--			appears again. When the server sends a Guild Info Updated message, that's when the text actually changes.
--
-- Since each editbox and each icon would need its own HandleEvent function, tooltip, etc...(And a page or three of XML code), 
-- What we're going to do is derive each editbox section from a template. 
-- Window IDs will be used to figure out which HandleEvent function to call, which tooltip to show when the user hovers over the icon, etc.

-- These indexes must match the ID defined in the GuildWindowTabProfile.xml file. We do this so we can use 1 template for all editboxes.
GuildWindowTabProfile.EDITBOXES_MOTD	= 1
GuildWindowTabProfile.EDITBOXES_DETAILS	= 2

-- This is where we define what tooltip, event, or whatever else to use for each instanced editbox section.
-- NOTE: Since the tables contructed here have functions in them, the functions must be declared first, which is why this block is bottom of file.
GuildWindowTabProfile.EditBoxes = {} 
GuildWindowTabProfile.EditBoxes[ GuildWindowTabProfile.EDITBOXES_MOTD  ]	= { windowName = "GWProfileMOTD",		tooltip=StringTables.Guild.TOOLTIP_EDIT_TEXT_MOTD,		functionOnEnter = GuildWindowTabProfile.GuildCommandMOTD }
GuildWindowTabProfile.EditBoxes[ GuildWindowTabProfile.EDITBOXES_DETAILS ]	= { windowName = "GWProfileDetails",	tooltip=StringTables.Guild.TOOLTIP_EDIT_TEXT_DETAILS,	functionOnEnter = GuildWindowTabProfile.GuildCommandDetails }

--------------------------------------
-- News Functions --
--------------------------------------
local function NewFilterSet( paramWindowName, paramFilters )
    local filterSet = {
        windowName = paramWindowName,
        ids = {
            [SystemData.GuildNewsLogFilters.GENERAL] = false,
            [SystemData.GuildNewsLogFilters.ADVANCEMENTS] = false,
            [SystemData.GuildNewsLogFilters.REMINDERS] = false,
            [SystemData.GuildNewsLogFilters.CREATION] = false,
            [SystemData.GuildNewsLogFilters.MEMBERJOINED] = false
        }
    }
    
    for _, id in ipairs( paramFilters )
    do
        if filterSet.ids[ id ] ~= nil
        then
            filterSet.ids[ id ] = true
        end
    end
    
    return filterSet
end

GuildWindowTabProfile.NEWS_FILTER_ALL       = 1
GuildWindowTabProfile.NEWS_FILTER_RVR       = 2
GuildWindowTabProfile.NEWS_FILTER_EVENTS    = 3
GuildWindowTabProfile.NEWS_FILTER_RANKS     = 4
GuildWindowTabProfile.NewsFilterSet = {
    [GuildWindowTabProfile.NEWS_FILTER_ALL]     = NewFilterSet( "GWProfileNewsFilterAll", { SystemData.GuildNewsLogFilters.GENERAL, SystemData.GuildNewsLogFilters.ADVANCEMENTS, SystemData.GuildNewsLogFilters.REMINDERS, SystemData.GuildNewsLogFilters.CREATION, SystemData.GuildNewsLogFilters.MEMBERJOINED } ),
    [GuildWindowTabProfile.NEWS_FILTER_RVR]     = NewFilterSet( "GWProfileNewsFilterRvR", { SystemData.GuildNewsLogFilters.CREATION } ),
    [GuildWindowTabProfile.NEWS_FILTER_EVENTS]  = NewFilterSet( "GWProfileNewsFilterEvents", { SystemData.GuildNewsLogFilters.REMINDERS } ),
    [GuildWindowTabProfile.NEWS_FILTER_RANKS]   = NewFilterSet( "GWProfileNewsFilterRanks", { SystemData.GuildNewsLogFilters.ADVANCEMENTS } )
}

function GuildWindowTabProfile.OnSelectNewsFilter()
    local filterId = WindowGetId( SystemData.ActiveWindow.name )
    local filterSet = GuildWindowTabProfile.NewsFilterSet[ filterId ]
    if not filterSet
    then
        return
    end
    
    for id, set in pairs( GuildWindowTabProfile.NewsFilterSet )
    do
        ButtonSetPressedFlag( set.windowName, id == filterId )
    end
    
    for id, enable in pairs( filterSet.ids )
    do
        LogDisplaySetFilterState( "GWProfileNewsText", "GuildNews", id, enable )
    end
end

