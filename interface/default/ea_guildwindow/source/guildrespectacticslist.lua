----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

GuildRespecTacticsList = {}

GuildRespecTacticsList.PURCHASED_TAB = 1
GuildRespecTacticsList.AVAILABLE_TAB = 2

local WINDOW_NAME = "GuildRespecTacticsList"
local TAB_NAME = WINDOW_NAME.."Tab"
local ABILITY_LIST_NAME = WINDOW_NAME.."AbilityList"

local ABILITY_LIST_TOP_ANCHOR = { point="bottomleft", relativeTo=TAB_NAME, relativePoint="topleft", xOffset=0, yOffset=0 }
local ABILITY_LIST_PURCHASED_ANCHOR = { point="topright", relativeTo=WINDOW_NAME.."ButtonBarBackground", relativePoint="bottomright", xOffset=0, yOffset=0 }
local ABILITY_LIST_AVAILABLE_ANCHOR = { point="bottomright", relativeTo=WINDOW_NAME.."Background", relativePoint="bottomright", xOffset=-5, yOffset=-5 }

local TAB_PROPERTIES = {
                        [GuildRespecTacticsList.PURCHASED_TAB] = {name=TAB_NAME.."Purchased", abilityListAnchor=ABILITY_LIST_PURCHASED_ANCHOR, numVisibleRows=7},
                        [GuildRespecTacticsList.AVAILABLE_TAB] = {name=TAB_NAME.."Available", abilityListAnchor=ABILITY_LIST_AVAILABLE_ANCHOR, numVisibleRows=8}
                       }

local currentTab = 0

local function GetCurrentOrderList()
    if( currentTab == GuildRespecTacticsList.PURCHASED_TAB )
    then
        return GuildTacticsList.abilityPurchasedListOrder
    end

    return GuildTacticsList.abilityListOrder
end

local function SetRowTint( row )
    local row_mod = math.mod(row, 2)
    local color = DataUtils.GetAlternatingRowColor( row_mod )
    local rowWindow = ABILITY_LIST_NAME.."Row"..row
    WindowSetTintColor(rowWindow.."RowBackground", color.r, color.g, color.b )
    WindowSetAlpha(rowWindow.."RowBackground", color.a)
end

local function SetListRowTints()
    if( GuildRespecTacticsListAbilityList.PopulatorIndices )
    then
        for k, v in ipairs( GuildRespecTacticsListAbilityList.PopulatorIndices )
        do
            SetRowTint( k )
        end
    end
end

function GuildRespecTacticsList.UpdateDisplayList()
    ListBoxSetDisplayOrder( ABILITY_LIST_NAME, GetCurrentOrderList() )
    GuildRespecTacticsList.UpdateRespecButton()
end

function GuildRespecTacticsList.OnLButtonUpTab()
    GuildRespecTacticsList.SwitchTab( WindowGetId(SystemData.ActiveWindow.name) )
end

local function AddAbilityListAnchor( anchor )
    WindowAddAnchor(ABILITY_LIST_NAME, anchor.point, anchor.relativeTo, anchor.relativePoint, anchor.xOffset, anchor.yOffset)
end

function GuildRespecTacticsList.SwitchTab(newTab)
    if( newTab ~= currentTab )
    then
        if( currentTab ~= 0 )
        then
            ButtonSetPressedFlag( TAB_PROPERTIES[currentTab].name, false )
        end

        currentTab = newTab
        
        --Hide the buttons if we are not on the purchased list
        WindowSetShowing(WINDOW_NAME.."ButtonBar", currentTab == GuildRespecTacticsList.PURCHASED_TAB )

        WindowClearAnchors(ABILITY_LIST_NAME)
        AddAbilityListAnchor(ABILITY_LIST_TOP_ANCHOR)
        AddAbilityListAnchor(TAB_PROPERTIES[currentTab].abilityListAnchor)
        ListBoxSetVisibleRowCount(ABILITY_LIST_NAME, TAB_PROPERTIES[currentTab].numVisibleRows )
        GuildRespecTacticsList.UpdateDisplayList()
    end

    ButtonSetPressedFlag( TAB_PROPERTIES[currentTab].name, true )
end

-- OnInitialize Handler
function GuildRespecTacticsList.Initialize()
    LabelSetText( WINDOW_NAME.."TitleBarText", GetGuildString(StringTables.Guild.LABEL_GUILD_TACTICS_LIST) )

    ButtonSetText( WINDOW_NAME.."ButtonBarRespecButton", GetGuildString(StringTables.Guild.BUTTON_GUILD_RESPEC_TACTICS) )
    ButtonSetText( WINDOW_NAME.."ButtonBarCancelButton", GetGuildString(StringTables.Guild.BUTTON_TACTICS_CANCEL) )
    ButtonSetText( TAB_PROPERTIES[GuildRespecTacticsList.PURCHASED_TAB].name, GetGuildString(StringTables.Guild.BUTTON_GUILD_RESPEC_TACTICS_PURCHASED_TAB) )
    ButtonSetText( TAB_PROPERTIES[GuildRespecTacticsList.AVAILABLE_TAB].name, GetGuildString(StringTables.Guild.BUTTON_GUILD_RESPEC_TACTICS_AVAILABLE_TAB) )
    
    GuildRespecTacticsList.SwitchTab( GuildRespecTacticsList.PURCHASED_TAB )

    WindowRegisterEventHandler( "GuildRespecTacticsList", SystemData.Events.GUILD_PERMISSIONS_UPDATED, "GuildRespecTacticsList.UpdateRespecButton" )
end

function GuildRespecTacticsList.UpdateRespecButton()
    if( WindowGetShowing( WINDOW_NAME ) )
    then
        local playerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
        local canRespec = GuildWindowTabAdmin.GetGuildCommandPermission(SystemData.GuildPermissons.TACTICS_PURCHASE, playerTitleNumber)
                          and GuildTacticsList.abilityPurchasedListOrder[1] ~= nil

        ButtonSetDisabledFlag("GuildRespecTacticsListButtonBarRespecButton", not canRespec )
    end
end

function GuildRespecTacticsList.UpdateList()
    if( WindowGetShowing( WINDOW_NAME ) )
    then
        if (GuildRespecTacticsListAbilityList.PopulatorIndices ~= nil)
        then
            for rowIndex, dataIndex in ipairs (GuildRespecTacticsListAbilityList.PopulatorIndices)
            do
                GuildTacticsList.PopulateIcon(WINDOW_NAME.."AbilityListRow"..rowIndex, GuildTacticsList.abilityListData[dataIndex].abilityID)
                SetRowTint( rowIndex )
            end
        end
    end
end

function GuildRespecTacticsList.Show()
    WindowSetShowing(WINDOW_NAME, true)
    GuildRespecTacticsList.UpdateRespecButton()
    GuildRespecTacticsList.UpdateList()
end

function GuildRespecTacticsList.Hide()
    WindowSetShowing(WINDOW_NAME, false)
end

function GuildRespecTacticsList.OnLButtonUpCancelButton()
    GuildRespecTacticsList.Hide()
end

function GuildRespecTacticsList.OnLButtonUpRespecButton()
    if( not ButtonGetDisabledFlag( WINDOW_NAME.."ButtonBarRespecButton" ) )
    then
        -- Pop up dialog to confirm (or have the server send it through a server dialog)
        local respecCost = GetGuildTacticsRespecCost()
            
        -- Create Confirmation Dialog
        local dialogText = GetFormatStringFromTable( "guildstrings", StringTables.Guild.DIALOG_CONFIRM_RESPEC_GUILD_TACTICS, { MoneyFrame.FormatMoneyString (respecCost, false, true) } )
        
        local function repecGuildTacticsConfirmed()
            RespecGuildTactics()
        end

        DialogManager.MakeTwoButtonDialog( dialogText, 
									       GetGuildString(StringTables.Guild.BUTTON_CONFIRM_YES),
									       repecGuildTacticsConfirmed,
									       GetGuildString(StringTables.Guild.BUTTON_CONFIRM_NO),
									       nil )
        
       GuildRespecTacticsList.Hide()
    end
end
