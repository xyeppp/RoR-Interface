
GuildWindowTabAdmin = {}

-- TODO: Don't initialize this window from GuildWindow.SetupInAGuild() so we can get rid of this?
--       For now prevent the Initialize function from getting called multiple times.
GuildWindowTabAdmin.Initialized = false

GuildWindowTabAdmin.permissionListData = {}
GuildWindowTabAdmin.permissionListOrder = {}

GuildWindowTabAdmin.SelectedTitleNumber            = -1  -- The Guild Title # we've selected (-1 if no title is selected)
GuildWindowTabAdmin.SelectedTitleNumberBeingEdited = -1 -- The Guild Title # we're currently editing (-1 if no title is being edited)

GuildWindowTabAdmin.Permissions =
{
    [ SystemData.GuildPermissons.INVITE ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME0,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP0
    },
    [ SystemData.GuildPermissons.KICK ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME1,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP1
    },
    [ SystemData.GuildPermissons.PROMOTE ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME2,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP2
    },
    [ SystemData.GuildPermissons.DEMOTE ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME3,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP3
    },
    [ SystemData.GuildPermissons.EDIT_PROFILE ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME4,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP4
    },
    [ SystemData.GuildPermissons.READ_OFFICER_CHAT ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME5,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP5
    },
    [ SystemData.GuildPermissons.SET_PERMISSIONS ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME6,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP6
    },
    [ SystemData.GuildPermissons.SET_GUILD_LEADER ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME7,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP7
    },
    [ SystemData.GuildPermissons.EDIT_TITLES ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME8,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP8
    },
    [ SystemData.GuildPermissons.ENABLE_RANKS ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME9,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP9
    },
    [ SystemData.GuildPermissons.CLAIM_KEEP ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME10,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP10
    },
    [ SystemData.GuildPermissons.FORM_ALLIANCE ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME11,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP11
    },
    [ SystemData.GuildPermissons.READ_GUILD_CHAT ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME12,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP12
    },
    [ SystemData.GuildPermissons.SPEAK_GUILD_CHAT ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME13,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP13
    },
    [ SystemData.GuildPermissons.SPEAK_READ_OFFICER_CHAT ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME14,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP14
    },
    [ SystemData.GuildPermissons.EDIT_YOUR_PUBLIC_NOTES ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME15,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP15
    },
    [ SystemData.GuildPermissons.EDIT_ANYONES_PUBLIC_NOTES ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME16,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP16
    },
    [ SystemData.GuildPermissons.READ_OFFICER_NOTE ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME17,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP17
    },
    [ SystemData.GuildPermissons.EDIT_ANYONES_OFFICER_NOTE ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME18,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP18
    },
    [ SystemData.GuildPermissons.TACTICS_PURCHASE ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME19,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP19
    },
    [ SystemData.GuildPermissons.BANNER_MANAGEMENT ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME20,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP20
    },
    [ SystemData.GuildPermissons.EDIT_YOUR_EVENTS ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME21,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP21
    },
    [ SystemData.GuildPermissons.EDIT_ALL_EVENTS ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME22,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP22
    },
    [ SystemData.GuildPermissons.CALENDAR_SIGNUP ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME23,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP23
    },
    [ SystemData.GuildPermissons.EDIT_HERALDRY ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME24,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP24
    },
    [ SystemData.GuildPermissons.UNASSIGN_BANNERS ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME28,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP28
    },
    [ SystemData.GuildPermissons.EDIT_TAX_RATE ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME29,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP29
    },
    [ SystemData.GuildPermissons.SET_RECRUITERS ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME30,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP30
    },
    [ SystemData.GuildPermissons.ASSIGN_BANNERS ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME31,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP31
    },
    [ SystemData.GuildPermissons.KEEPUPGRADE_EDIT ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME56,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP56
    },
    [ SystemData.GuildPermissons.DIVINEFAVORALTAR_INTERACT ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME57,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP57
    },
    [ SystemData.GuildPermissons.VAULT1_VIEW ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT1_VIEW,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP32
    },
    [ SystemData.GuildPermissons.VAULT1_ADD_ITEM ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT1_ADD,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP33
    },
    [ SystemData.GuildPermissons.VAULT1_TAKE_ITEM ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT1_TAKE,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP34
    },
    [ SystemData.GuildPermissons.VAULT_DEPOSIT ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT_DEPOSIT,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP35
    },
    [ SystemData.GuildPermissons.VAULT_WITHDRAW ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT_WITHDRAW,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP36
    },
    [ SystemData.GuildPermissons.VAULT2_VIEW ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT2_VIEW,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP39
    },
    [ SystemData.GuildPermissons.VAULT2_ADD_ITEM ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT2_ADD,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP40
    },
    [ SystemData.GuildPermissons.VAULT2_TAKE_ITEM ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT2_TAKE,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP41
    },
    [ SystemData.GuildPermissons.VAULT3_VIEW ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT3_VIEW,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP46
    },
    [ SystemData.GuildPermissons.VAULT3_ADD_ITEM ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT3_ADD,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP47
    },
    [ SystemData.GuildPermissons.VAULT3_TAKE_ITEM ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT3_TAKE,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP48
    },
    [ SystemData.GuildPermissons.VAULT4_VIEW ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT4_VIEW,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP53
    },
    [ SystemData.GuildPermissons.VAULT4_ADD_ITEM ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT4_ADD,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP54
    },
    [ SystemData.GuildPermissons.VAULT4_TAKE_ITEM ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT4_TAKE,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP55
    },
    [ SystemData.GuildPermissons.VAULT5_VIEW ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT5_VIEW,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP58
    },
    [ SystemData.GuildPermissons.VAULT5_ADD_ITEM ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT5_ADD,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP59
    },
    [ SystemData.GuildPermissons.VAULT5_TAKE_ITEM ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_VAULT5_TAKE,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP60
    },
    [ SystemData.GuildPermissons.ASSIGN_REALM_CAPTAIN ] =
    {
        NameStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_NAME45,
        TooltipStringId = StringTables.Guild.LABEL_GUILD_PERMISSION_TOOLTIP45
    },
}

GuildWindowTabAdmin.PermissionCategories =
{
    {
        NameStringId = StringTables.Guild.PERMISSION_CATEGORY_ROSTER_MANAGEMENT,
        Permissions =
        {
            SystemData.GuildPermissons.INVITE,
            SystemData.GuildPermissons.KICK,
            SystemData.GuildPermissons.PROMOTE,
            SystemData.GuildPermissons.DEMOTE,
            SystemData.GuildPermissons.EDIT_YOUR_PUBLIC_NOTES,
            SystemData.GuildPermissons.EDIT_ANYONES_PUBLIC_NOTES,
            SystemData.GuildPermissons.SET_GUILD_LEADER,
            SystemData.GuildPermissons.READ_OFFICER_NOTE,
            SystemData.GuildPermissons.EDIT_ANYONES_OFFICER_NOTE,
            SystemData.GuildPermissons.SET_RECRUITERS,
            SystemData.GuildPermissons.ASSIGN_REALM_CAPTAIN,
        }
    },
    {
        NameStringId = StringTables.Guild.PERMISSION_CATEGORY_CHAT,
        Permissions =
        {
            SystemData.GuildPermissons.READ_OFFICER_CHAT,
            SystemData.GuildPermissons.READ_GUILD_CHAT,
            SystemData.GuildPermissons.SPEAK_GUILD_CHAT,
            SystemData.GuildPermissons.SPEAK_READ_OFFICER_CHAT
        }
    },
    {
        NameStringId = StringTables.Guild.PERMISSION_CATEGORY_GUILD_MANAGEMENT,
        Permissions =
        {
            SystemData.GuildPermissons.EDIT_PROFILE,
            SystemData.GuildPermissons.SET_PERMISSIONS,
            SystemData.GuildPermissons.TACTICS_PURCHASE,
            SystemData.GuildPermissons.EDIT_TITLES,
            SystemData.GuildPermissons.ENABLE_RANKS,
            SystemData.GuildPermissons.EDIT_TAX_RATE
        }
    },
    {
        NameStringId = StringTables.Guild.PERMISSION_CATEGORY_ALLIANCE,
        Permissions =
        {
            SystemData.GuildPermissons.FORM_ALLIANCE
        }
    },
    {
        NameStringId = StringTables.Guild.PERMISSION_CATEGORY_KEEPS,
        Permissions =
        {
            SystemData.GuildPermissons.CLAIM_KEEP,
            SystemData.GuildPermissons.KEEPUPGRADE_EDIT,
            SystemData.GuildPermissons.DIVINEFAVORALTAR_INTERACT
        }
    },
    {
        NameStringId = StringTables.Guild.PERMISSION_CATEGORY_STANDARDS_AND_HERALDRY,
        Permissions =
        {
            SystemData.GuildPermissons.BANNER_MANAGEMENT,
            SystemData.GuildPermissons.EDIT_HERALDRY,
            SystemData.GuildPermissons.UNASSIGN_BANNERS,
            SystemData.GuildPermissons.ASSIGN_BANNERS
        }
    },
    {
        NameStringId = StringTables.Guild.PERMISSION_CATEGORY_EVENTS,
        Permissions =
        {
            SystemData.GuildPermissons.EDIT_YOUR_EVENTS,
            SystemData.GuildPermissons.EDIT_ALL_EVENTS,
            SystemData.GuildPermissons.CALENDAR_SIGNUP
        }
    },
    {
        NameStringId = StringTables.Guild.PERMISSION_CATEGORY_VAULT,
        Permissions =
        {
            SystemData.GuildPermissons.VAULT1_VIEW,
            SystemData.GuildPermissons.VAULT1_ADD_ITEM,
            SystemData.GuildPermissons.VAULT1_TAKE_ITEM,
            SystemData.GuildPermissons.VAULT_DEPOSIT,
            SystemData.GuildPermissons.VAULT_WITHDRAW,
            SystemData.GuildPermissons.VAULT2_VIEW,
            SystemData.GuildPermissons.VAULT2_ADD_ITEM,
            SystemData.GuildPermissons.VAULT2_TAKE_ITEM,
            SystemData.GuildPermissons.VAULT3_VIEW,
            SystemData.GuildPermissons.VAULT3_ADD_ITEM,
            SystemData.GuildPermissons.VAULT3_TAKE_ITEM,
            SystemData.GuildPermissons.VAULT4_VIEW,
            SystemData.GuildPermissons.VAULT4_ADD_ITEM,
            SystemData.GuildPermissons.VAULT4_TAKE_ITEM,
            SystemData.GuildPermissons.VAULT5_VIEW,
            SystemData.GuildPermissons.VAULT5_ADD_ITEM,
            SystemData.GuildPermissons.VAULT5_TAKE_ITEM
        }
    }
}

local function CompareCategoryListEntries( data1, data2 )    -- Compare function for sorting categories.
    if ( not data1.isCategory or
         not data2.isCategory )
    then
        -- Function used incorrectly.
        -- Only use this to compare categories.
        return nil  -- TODO: raise an error instead
    end

    local categoryName1 = GetGuildString( GuildWindowTabAdmin.PermissionCategories[ data1.categoryIndex ].NameStringId )
    local categoryName2 = GetGuildString( GuildWindowTabAdmin.PermissionCategories[ data2.categoryIndex ].NameStringId )

    -- Sort by name.
    return ( WStringsCompare( categoryName1, categoryName2 ) < 0 )
end

local function ComparePermissionListEntries( data1, data2 )    -- Compare function for sorting permissions.
    if ( data1.isCategory or
         data2.isCategory )
    then
        -- Function used incorrectly.
        -- Only use this to compare permissions.
        return nil  -- TODO: raise an error instead
    end

    local permissionName1 = GetGuildString( GuildWindowTabAdmin.Permissions[ data1.permissionId ].NameStringId )
    local permissionName2 = GetGuildString( GuildWindowTabAdmin.Permissions[ data2.permissionId ].NameStringId )

    -- Sort by name.
    return ( WStringsCompare( permissionName1, permissionName2 ) < 0 )
end

function GuildWindowTabAdmin.Initialize()
    if ( GuildWindowTabAdmin.Initialized )
    then
        return
    end

    LabelSetText( "GWAdminHeaderText", GetGuildString( StringTables.Guild.LABEL_GUILD_ADMIN_TITLE ) )

    LabelSetText( "GWAdminTitlesIDHeader", GetGuildString( StringTables.Guild.LABEL_GUILD_ADMIN_TITLES_ID_HEADER ) )
    LabelSetText( "GWAdminTitlesTitleHeader", GetGuildString( StringTables.Guild.LABEL_GUILD_ADMIN_TITLES_TITLE_HEADER ) )
    LabelSetText( "GWAdminTitlesQtyHeader", GetGuildString( StringTables.Guild.LABEL_GUILD_ADMIN_TITLES_QTY_HEADER ) )

    LabelSetText( "GWAdminPermissionsHeader", GetGuildString( StringTables.Guild.LABEL_PERMISSIONS_HEADER ) )

    LabelSetText( "GWAdminTaxRate", GetFormatStringFromTable( "GuildStrings", StringTables.Guild.LABEL_GUILD_TAX_X, { GameData.Guild.TaxRate } ) )
    LabelSetText( "GWAdminTitheRate", GetFormatStringFromTable( "GuildStrings", StringTables.Guild.LABEL_GUILD_TITHE_X, { GameData.Guild.TitheRate } ) )

    -- These labels never change.
    LabelSetText( "GWAdminID0", L"0" )
    LabelSetText( "GWAdminID1", L"1" )
    LabelSetText( "GWAdminID2", L"2" )
    LabelSetText( "GWAdminID3", L"3" )
    LabelSetText( "GWAdminID4", L"4" )
    LabelSetText( "GWAdminID5", L"5" )
    LabelSetText( "GWAdminID6", L"6" )
    LabelSetText( "GWAdminID7", L"7" )
    LabelSetText( "GWAdminID8", L"8" )
    LabelSetText( "GWAdminID9", L"9" )
    LabelSetText( "GWAdminIDHeader0", L"0" )
    LabelSetText( "GWAdminIDHeader1", L"1" )
    LabelSetText( "GWAdminIDHeader2", L"2" )
    LabelSetText( "GWAdminIDHeader3", L"3" )
    LabelSetText( "GWAdminIDHeader4", L"4" )
    LabelSetText( "GWAdminIDHeader5", L"5" )
    LabelSetText( "GWAdminIDHeader6", L"6" )
    LabelSetText( "GWAdminIDHeader7", L"7" )
    LabelSetText( "GWAdminIDHeader8", L"8" )
    LabelSetText( "GWAdminIDHeader9", L"9" )

    ButtonSetText( "GWAdminCommandEditTitleButton", GetGuildString(StringTables.Guild.BUTTON_GUILD_ADMIN_COMMAND_EDIT_TITLE) )
    ButtonSetText( "GWAdminCommandAddRemoveTitleButton", GetGuildString(StringTables.Guild.BUTTON_GUILD_ADMIN_COMMAND_ADD_TITLE) )

    WindowRegisterEventHandler( "GuildWindowTabAdmin", SystemData.Events.GUILD_TAX_TITHE_UPDATED, "GuildWindowTabAdmin.OnTaxTitheRateUpdated")

    GuildWindowTabAdmin.InitializeGuildTitleWindowIDs()
    GuildWindowTabAdmin.InitializePermissionListData()
    GuildWindowTabAdmin.InitializePermissionRows()

    GuildWindowTabAdmin.UpdatePermissions()
    GuildWindowTabAdmin.UpdateTitleBeingEdited( -1 )

    GuildWindowTabAdmin.Initialized = true
end

--------------------------------
-- List Functions
--------------------------------

function GuildWindowTabAdmin.InitializePermissionListData()
    GuildWindowTabAdmin.permissionListData = {}

    -- First insert all categories.
    for categoryIndex, categoryData in ipairs( GuildWindowTabAdmin.PermissionCategories )
    do
        -- Don't insert categories that have 0 permissions (though really, those shouldn't exist).
        if ( #categoryData.Permissions > 0 )
        then
            local insertData = { categoryIndex = categoryIndex, isCategory = true, isExpanded = false }
            table.insert( GuildWindowTabAdmin.permissionListData, insertData )
        end
    end

    -- Sort the categories.
    table.sort( GuildWindowTabAdmin.permissionListData, CompareCategoryListEntries )

    -- For each of the sorted categories...
    -- (we can't use ipairs here, and must iterate backwards, because we edit the list during iteration)
    for listIndex = #GuildWindowTabAdmin.permissionListData, 1, -1
    do
        local listData = GuildWindowTabAdmin.permissionListData[ listIndex ]
        local categoryData = GuildWindowTabAdmin.PermissionCategories[ listData.categoryIndex ]

        -- Build a table of its permissions.
        local permissions = {}
        for permissionIndex, permissionId in ipairs( categoryData.Permissions )
        do
            local insertData = { categoryIndex = listData.categoryIndex, isCategory = false, permissionId = permissionId }
            table.insert( permissions, insertData )
        end

        -- Sort the permissions.
        table.sort( permissions, ComparePermissionListEntries )

        -- Insert the sorted permissions into the table.
        local insertIndex = listIndex + 1
        for permissionIndex, permissionData in ipairs( permissions )
        do
            table.insert( GuildWindowTabAdmin.permissionListData, insertIndex, permissionData )
            insertIndex = insertIndex + 1
        end
    end

    GuildWindowTabAdmin.RefreshListBoxDisplay()
end

function GuildWindowTabAdmin.RefreshListBoxDisplay()
    GuildWindowTabAdmin.permissionListOrder = {}

    -- GuildWindowTabAdmin.permissionListData is already sorted.
    -- So all we have to do is iterate over it and copy indexes of entries to display.

    local prevCategoryExpanded = true
    for dataIndex, data in ipairs( GuildWindowTabAdmin.permissionListData )
    do
        if ( data.isCategory )
        then
            -- Always insert categories.
            table.insert( GuildWindowTabAdmin.permissionListOrder, dataIndex )
            prevCategoryExpanded = data.isExpanded
        else    -- permission
            -- Insert permissions if the category was expanded.
            if ( prevCategoryExpanded )
            then
                table.insert( GuildWindowTabAdmin.permissionListOrder, dataIndex )
            end
        end
    end

    ListBoxSetDisplayOrder( "GWAdminPermissionsList", GuildWindowTabAdmin.permissionListOrder )
end

function GuildWindowTabAdmin.InitializePermissionRows()
    for row = 1, GWAdminPermissionsList.numVisibleRows do
        local rowWindow = "GWAdminPermissionsListRow"..row

        -- Set the row tint.
        local rowMod = math.mod( row, 2 )
        local color = DataUtils.GetAlternatingRowColor( rowMod )
        WindowSetTintColor( rowWindow.."Background", color.r, color.g, color.b )
        WindowSetAlpha( rowWindow.."Background", color.a )

        -- Set the checkboxes to perform like checkboxes.
        local rowEnabledBoxWindowPrefix = rowWindow.."Enabled"
        for buttonIndex = 0, 9
        do
            ButtonSetStayDownFlag( rowEnabledBoxWindowPrefix..buttonIndex, true )
        end
    end
end

function GuildWindowTabAdmin.UpdatePermissionRows()
    if ( GWAdminPermissionsList.PopulatorIndices == nil )
    then
        return
    end

    local guildPermissionData = GetGuildPermissionData()
    if ( guildPermissionData == nil )
    then
        return
    end

    local localPlayerTitleNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
    local userCanEditPermissions = GuildWindowTabAdmin.GetGuildCommandPermission( SystemData.GuildPermissons.SET_PERMISSIONS, localPlayerTitleNumber )

    for rowIndex, dataIndex in ipairs( GWAdminPermissionsList.PopulatorIndices )
    do
        local rowWindow = "GWAdminPermissionsListRow"..rowIndex
        local rowNameWindow = rowWindow.."Name"

        local data = GuildWindowTabAdmin.permissionListData[ dataIndex ]
        if ( data.isCategory )
        then
            -- Show the + or - icon depending on whether the category is expanded.
            WindowSetShowing( rowWindow.."PlusButton", not data.isExpanded )
            WindowSetShowing( rowWindow.."MinusButton", data.isExpanded )

            -- Set the name text and color.
            LabelSetText( rowNameWindow, GetGuildString( GuildWindowTabAdmin.PermissionCategories[ data.categoryIndex ].NameStringId ) )
            DefaultColor.LabelSetTextColor( rowNameWindow, DefaultColor.GUILD_ADMIN_PERMISSION_NORMAL )

            -- Hide the row checkboxes.
            local rowEnabledBoxWindowPrefix = rowWindow.."Enabled"
            for titleId = 0, 9
            do
                local rowEnabledBoxWindow = rowEnabledBoxWindowPrefix..titleId
                WindowSetShowing( rowEnabledBoxWindow, false )
            end
        else    -- permission
            -- Hide the + and - icons.
            WindowSetShowing( rowWindow.."PlusButton", false )
            WindowSetShowing( rowWindow.."MinusButton", false )

            -- Set the name text.
            LabelSetText( rowNameWindow, GetGuildString( GuildWindowTabAdmin.Permissions[ data.permissionId ].NameStringId ) )

            local canEditThisPermission = ( userCanEditPermissions and
                                            data.permissionId ~= SystemData.GuildPermissons.FORM_ALLIANCE and                  -- leader only, and cannot be changed
                                            data.permissionId ~= SystemData.GuildPermissons.SET_GUILD_LEADER )                 -- leader only, and cannot be changed

            -- Set the name color.
            local color = nil
            if ( canEditThisPermission )
            then
                color = DefaultColor.GUILD_ADMIN_PERMISSION_NORMAL
            else
                color = DefaultColor.GUILD_ADMIN_PERMISSION_DISABLED
            end
            DefaultColor.LabelSetTextColor( rowNameWindow, color )

            -- Show and set the status of the checkboxes for each title.
            local rowEnabledBoxWindowPrefix = rowWindow.."Enabled"
            for titleId = 0, 9
            do
                local titlePermissionData = guildPermissionData[ titleId + 1 ]
                local rowEnabledBoxWindow = rowEnabledBoxWindowPrefix..titleId

                local canEditThisTitle = ( localPlayerTitleNumber > titleId and         -- cannot edit permissions of a title higher than you.
                                           titleId ~= SystemData.GuildRanks.LEADER and  -- none of the leader's permissions may be changed.
                                           titlePermissionData.rankUsed )               -- can only edit permissions for enabled titles.

                WindowSetShowing( rowEnabledBoxWindow, true )
                ButtonSetPressedFlag( rowEnabledBoxWindow, titlePermissionData[ data.permissionId ] )
                ButtonSetDisabledFlag( rowEnabledBoxWindow, not ( canEditThisPermission and canEditThisTitle ) )
            end
        end
    end
end

-- This function refreshes all the guild titles, permissions, and command buttons.
function GuildWindowTabAdmin.UpdatePermissions()
    GuildWindowTabAdmin.UpdateGuildTitles() -- TODO: is this necessary?
    GuildWindowTabAdmin.UpdateAdminCommandButtons()
    GuildWindowTabAdmin.UpdatePermissionRows()
end

-- ListBox callback.
function GuildWindowTabAdmin.PopulatePermissions()
    GuildWindowTabAdmin.UpdatePermissionRows()
end

--------------------------------
-- Title Functions
--------------------------------

-- This sets all the Window IDs so we can reference them to know what title we've selected or are editing
function GuildWindowTabAdmin.InitializeGuildTitleWindowIDs()
    local guildPermissionData = GetGuildPermissionData()
    if ( guildPermissionData == nil )
    then
        return
    end

    for key, value in ipairs( guildPermissionData ) do
        WindowSetId( "GWAdminTitle"..value.rankID, value.rankID )
    end
end

-- This function updates all the guild titles and the # of members that are of that title.
function GuildWindowTabAdmin.UpdateGuildTitles()

    local guildPermissionData = GetGuildPermissionData()
    if ( guildPermissionData == nil )
    then
        return
    end

    for key, value in ipairs( guildPermissionData )
    do
        local idWindow = "GWAdminID"..value.rankID
        local titleWindow = "GWAdminTitle"..value.rankID
        local qtyWindow = "GWAdminQty"..value.rankID

        LabelSetText( titleWindow, value.rankTitle )
        LabelSetText( qtyWindow, L""..value.rankQty )

        local color = nil
        if ( GuildWindowTabAdmin.SelectedTitleNumber == value.rankID )
        then
            color = DefaultColor.GUILD_ADMIN_TITLE_SELECTED
        elseif ( value.rankUsed )
        then
            color = DefaultColor.GUILD_ADMIN_TITLE_UNSELECTED
        else
            color = DefaultColor.GUILD_MEDIUM_GRAY
        end
        DefaultColor.LabelSetTextColor( idWindow, color )
        DefaultColor.LabelSetTextColor( titleWindow, color )
        DefaultColor.LabelSetTextColor( qtyWindow, color )
    end
end

-- This function updates showing the Edit/Remove title button and its text
function GuildWindowTabAdmin.UpdateAdminCommandButtons()
    local selectedTitleData = nil
    if ( GuildWindowTabAdmin.SelectedTitleNumber >= 0 )
    then
        local guildPermissionData = GetGuildPermissionData()
        if ( guildPermissionData == nil )
        then
            return
        end

        selectedTitleData = guildPermissionData[ GuildWindowTabAdmin.SelectedTitleNumber + 1 ]
    end

    ButtonSetDisabledFlag( "GWAdminCommandEditTitleButton", ( selectedTitleData == nil ) )

    local titleCanBeToggled = ( selectedTitleData ~= nil and
                                selectedTitleData.rankID < SystemData.GuildRanks.OFFICER and
                                selectedTitleData.rankID > SystemData.GuildRanks.MEMBER )

    ButtonSetDisabledFlag( "GWAdminCommandAddRemoveTitleButton", not titleCanBeToggled )

    local toggleText = nil
    if ( titleCanBeToggled and
         selectedTitleData ~= nil and
         not selectedTitleData.rankUsed )
    then
        toggleText = GetGuildString( StringTables.Guild.BUTTON_GUILD_ADMIN_COMMAND_ADD_TITLE )
    else
        toggleText = GetGuildString( StringTables.Guild.BUTTON_GUILD_ADMIN_COMMAND_REMOVE_TITLE )
    end
    ButtonSetText( "GWAdminCommandAddRemoveTitleButton", toggleText )
end

-- This function does everything needed to show/hide the Guild Title Editbox.
function GuildWindowTabAdmin.UpdateTitleBeingEdited( _titleNumber )
    local oldTitleBeingEdited = GuildWindowTabAdmin.SelectedTitleNumberBeingEdited

    if ( _titleNumber == nil or _titleNumber < 0 )
    then
        GuildWindowTabAdmin.SelectedTitleNumberBeingEdited = -1

        if ( oldTitleBeingEdited ~= -1 )
        then
            WindowSetShowing( "GWAdminTitle"..oldTitleBeingEdited, true )   -- Show the Guild Title again
        end

        WindowSetShowing( "GWAdminTitleEditBox", false )    -- Hide the Edit Box
        WindowAssignFocus( "GWAdminTitleEditBox", false )   -- Remove any focus the edit box may have had
    else
		GuildWindowTabAdmin.SelectedTitleNumberBeingEdited = _titleNumber

		-- Anchor the editbox to the guild title being edited
        TextEditBoxSetText( "GWAdminTitleEditBox", LabelGetText( "GWAdminTitle".._titleNumber ) )
		WindowClearAnchors( "GWAdminTitleEditBox" )
		WindowAddAnchor( "GWAdminTitleEditBox", "topleft", "GWAdminTitle".._titleNumber, "topleft", 0, 0 )
		WindowAddAnchor( "GWAdminTitleEditBox", "bottomright", "GWAdminTitle".._titleNumber, "bottomright", 0, 0 )
		WindowSetShowing( "GWAdminTitle".._titleNumber, false ) -- Hide the label underneath
		WindowSetShowing( "GWAdminTitleEditBox", true )         -- Show the Editbox
		WindowAssignFocus( "GWAdminTitleEditBox", true )        -- Assign focus to the edit box
	end
end

--------------------------------
-- Event Handlers
--------------------------------

function GuildWindowTabAdmin.OnTaxTitheRateUpdated( tax, tithe )
    LabelSetText( "GWAdminTaxRate", GetFormatStringFromTable( "GuildStrings", StringTables.Guild.LABEL_GUILD_TAX_X, { tax } ) )
    LabelSetText( "GWAdminTitheRate", GetFormatStringFromTable( "GuildStrings", StringTables.Guild.LABEL_GUILD_TITHE_X, { tithe } ) )
end

function GuildWindowTabAdmin.OnLButtonUpTaxRate()
    local statusNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
	if ( not GuildWindowTabAdmin.GetGuildCommandPermission( SystemData.GuildPermissons.EDIT_TAX_RATE, statusNumber ) )
    then
        -- User can't edit the tax rate, so bail.
		return
	end

    local dialogTitle = GetGuildString( StringTables.Guild.DIALOG_TAX_RATE )
    local dialogText = GetGuildString( StringTables.Guild.DIALOG_EDIT_GUILD_TAX_RATE_SHORT ) 
    DialogManager.MakeTextEntryDialog( dialogTitle, dialogText, L"", GuildWindowTabAdmin.OnAcceptedEditTaxRate, nil )
end

function GuildWindowTabAdmin.OnAcceptedEditTaxRate( rateText )
    local rate = tonumber( rateText )
	if ( rate < 0 )
    then
        rate = 0
	elseif ( rate > 100 )
    then
        rate = 100
    end

    SendChatText( L"/guildtax "..rate, L"" )
end

function GuildWindowTabAdmin.OnMouseOverTaxRate()
    local statusNumber = GuildWindowTabAdmin.GetLocalMemberTitleNumber()
	if ( not GuildWindowTabAdmin.GetGuildCommandPermission( SystemData.GuildPermissons.EDIT_TAX_RATE, statusNumber ) )
    then
        -- User can't edit the tax rate, so bail.
        return
    end

    DefaultColor.LabelSetTextColor( "GWAdminTaxRate", DefaultColor.ORANGE )
end

function GuildWindowTabAdmin.OnMouseOverEndTaxRate()
    DefaultColor.LabelSetTextColor( "GWAdminTaxRate", DefaultColor.YELLOW )
end

function GuildWindowTabAdmin.OnLButtonUpTitheRate()
    local dialogTitle = GetGuildString( StringTables.Guild.DIALOG_TITHE_RATE )
    local dialogText = GetGuildString( StringTables.Guild.DIALOG_EDIT_GUILD_TITHE_RATE_SHORT ) 
    DialogManager.MakeTextEntryDialog( dialogTitle, dialogText, L"", GuildWindowTabAdmin.OnAcceptedEditTitheRate, nil )
end

function GuildWindowTabAdmin.OnAcceptedEditTitheRate( rateText )
    local rate = tonumber( rateText )
	if ( rate < 0 )
    then
        rate = 0
	elseif ( rate > 100 )
    then
        rate = 100
    end

    SendChatText( L"/guildtithe "..rate, L"" )
end

function GuildWindowTabAdmin.OnMouseOverTitheRate()
    DefaultColor.LabelSetTextColor( "GWAdminTitheRate", DefaultColor.ORANGE )
end

function GuildWindowTabAdmin.OnMouseOverEndTitheRate()
    DefaultColor.LabelSetTextColor( "GWAdminTitheRate", DefaultColor.YELLOW )
end

function GuildWindowTabAdmin.OnMouseOverPermissionRow()
    local selectedRow = WindowGetId( SystemData.MouseOverWindow.name )
    local dataIndex = ListBoxGetDataIndex( "GWAdminPermissionsList", selectedRow )
    local data = GuildWindowTabAdmin.permissionListData[ dataIndex ]
    if ( data.isCategory )
    then
        -- Categories have no tooltip.
        return
    end

    Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name, nil )
    Tooltips.SetTooltipText( 1, 1, GetGuildString( GuildWindowTabAdmin.Permissions[ data.permissionId ].TooltipStringId ) )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.Finalize()

    local anchor = { Point="left", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="right", XOffset=-10, YOffset=0 }
    Tooltips.AnchorTooltip( anchor )
    Tooltips.SetTooltipAlpha( 1 )
end

function GuildWindowTabAdmin.OnMouseOverEditTitleButton()
    Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name, nil )
    Tooltips.SetTooltipText( 1, 1, GetGuildString( StringTables.Guild.TOOLTIP_ADMIN_EDIT_TITLE_BUTTON ) )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.Finalize()
    
    local anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottomleft", XOffset=10, YOffset=-10 }
    Tooltips.AnchorTooltip( anchor )
    Tooltips.SetTooltipAlpha( 1 )
end

function GuildWindowTabAdmin.OnMouseOverAddRemoveTitleButton()
    Tooltips.CreateTextOnlyTooltip( SystemData.MouseOverWindow.name, nil )
    Tooltips.SetTooltipText( 1, 1, GetGuildString( StringTables.Guild.TOOLTIP_ADMIN_ADD_REMOVE_TITLE_BUTTON ) )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.Finalize()
    
    local anchor = { Point="top", RelativeTo=SystemData.MouseOverWindow.name, RelativePoint="bottomleft", XOffset=10, YOffset=-10 }
    Tooltips.AnchorTooltip( anchor )
    Tooltips.SetTooltipAlpha( 1 )
end

function GuildWindowTabAdmin.OnLButtonUpPermissionRow()
    local selectedRow = WindowGetId( SystemData.MouseOverWindow.name )
    local dataIndex = ListBoxGetDataIndex( "GWAdminPermissionsList", selectedRow )
    if dataIndex == nil
    then
        return
    end
    local data = GuildWindowTabAdmin.permissionListData[ dataIndex ]
    if ( not data.isCategory )
    then
        -- Clicking a permission does nothing.
        return
    end

    -- Toggle category expansion and refresh the editbox.
    data.isExpanded = not data.isExpanded
    GuildWindowTabAdmin.RefreshListBoxDisplay()
end

function GuildWindowTabAdmin.OnLButtonUpPermissionCheckBox()
    if ( ButtonGetDisabledFlag( SystemData.MouseOverWindow.name ) )
    then
        return
    end

    -- TODO: Fix list box so that you can specify the ID of the children of each row.
    -- ListBoxes set the id of the row window to its index in the ListBox.
    -- This is fine. The problem is it also sets all child windows to that same id,
    -- which means our checkbox's id is the index of the row, not the id we specified in the xml definition.
    -- This is BAD; preferably we'd use the checkbox's id to know which title it corresponds to,
    -- but we don't have that option since our id is replaced by the row index.
    -- So we have to use this method of getting the final character of the checkbox's window name.
    --local selectedTitle = WindowGetId( SystemData.MouseOverWindow.name )
    local selectedTitle = tonumber( string.sub( SystemData.MouseOverWindow.name, -1 ) )

    local windowParent = WindowGetParent( SystemData.MouseOverWindow.name )
    local selectedRow = WindowGetId( windowParent )

    local dataIndex = ListBoxGetDataIndex( "GWAdminPermissionsList", selectedRow )
    local data = GuildWindowTabAdmin.permissionListData[ dataIndex ]
    -- In theory it should be impossible for data to be a category.

    SendChatText( L"/guildrankpermission "..selectedTitle..L" "..data.permissionId, L"" )
end

-- Selects the Guild Title, highlighting it in the process
function GuildWindowTabAdmin.SelectGuildTitle( titleId )
    if ( GuildWindowTabAdmin.SelectedTitleNumberBeingEdited >= 0 )
    then
        GuildWindowTabAdmin.UpdateTitleBeingEdited( -1 )
    end

    -- Set the label values
    if ( titleId ~= nil ) then
        GuildWindowTabAdmin.SelectedTitleNumber = titleId
    else
        GuildWindowTabAdmin.SelectedTitleNumber = -1
    end

    GuildWindowTabAdmin.UpdateGuildTitles()
    GuildWindowTabAdmin.UpdateAdminCommandButtons()
end

-- Handles the Left Button click on a Guild Title 
function GuildWindowTabAdmin.OnLButtonUpTitle()
	GuildWindowTabAdmin.SelectGuildTitle( WindowGetId( SystemData.MouseOverWindow.name ) )
end

--------------------------------
-- Permission Functions
--------------------------------

-- Returns the statusNumber of the local player
function GuildWindowTabAdmin.GetLocalMemberTitleNumber()
	if GuildWindow.localPlayerCache.statusNumber > 0 then
		return GuildWindow.localPlayerCache.statusNumber
	end

	local localMemberTitleNumber = GuildWindowTabAdmin.GetMemberTitleNumberByMemberName(GameData.Player.name)
	GuildWindow.localPlayerCache.statusNumber = localMemberTitleNumber
	
	return localMemberTitleNumber
end

function GuildWindowTabAdmin.GetMemberTitleNumberByMemberName(memberName)

    if (GuildWindowTabRoster.memberListData == nil or memberName == nil ) then
		--ERROR(L"GetMemberTitleNumberByMemberName: Invalid Guild Roster or Member Name")
        return 0
    end

    for rowIndex, data in ipairs (GuildWindowTabRoster.memberListData) do
		local bMatch = WStringsCompare(data.name, memberName) == 0
        if  bMatch == true then
            return data.statusNumber
		end
    end

    --ERROR( L"GuildWindowTabAdmin.GetMemberTitleNumberByMemberName(): Player Not Found" )
    return 0
end

-- Pass in the Permission# and the Title# and this function returns true if the title has the permission, false otherwise.
function GuildWindowTabAdmin.GetGuildCommandPermission(permissionIndex, statusNumber)
    if (permissionIndex == nil or permissionIndex < 0) then
        ERROR(L"GuildWindowTabAdmin.GetGuildCommandPermission(): Invalid Permission Index")
        return false
    end

    if (statusNumber == nil or statusNumber < SystemData.GuildRanks.INITIATE or statusNumber > SystemData.GuildRanks.LEADER) then
        ERROR(L"GuildWindowTabAdmin.GetGuildCommandPermission(): Invalid Status Number")
		return false
    end

    -- Get all the perrmissions. I suppose we can optimize this by being able to pass in the Status Number that we want the permissions for.
    local guildPermissionData = GetGuildPermissionData()
    if( guildPermissionData ~= nil and guildPermissionData[statusNumber + 1] ~= nil ) then
		local playerPermissions = guildPermissionData[statusNumber + 1] -- StatusNumbers are 0-9, but the LUA tables are 1-10]
        return playerPermissions[permissionIndex]
    end
    
    --ERROR(L"GuildWindowTabAdmin.GetGuildCommandPermission(): Permission:"..permissionIndex..L", Status:"..statusNumber..L" Not Found")    
    return false
end

function GuildWindowTabAdmin.GetGuildCommandPermissionForPlayer( permissionIndex )

    
    return GuildWindowTabAdmin.GetGuildCommandPermission( permissionIndex, GuildWindowTabAdmin.GetLocalMemberTitleNumber() )
end

--------------------------------
-- Command Functions
--------------------------------

function GuildWindowTabAdmin.OnKeyEnterTitleEditBox()
    SendChatText( L"/guildranksetname "..GuildWindowTabAdmin.SelectedTitleNumber..L" "..TextEditBoxGetText("GWAdminTitleEditBox"), L"" )
	
	GuildWindowTabAdmin.OnKeyEscapeTitleEditBox()	-- Return to normal
end

function GuildWindowTabAdmin.OnKeyEscapeTitleEditBox()
	GuildWindowTabAdmin.UpdateTitleBeingEdited( -1 )
end

function GuildWindowTabAdmin.OnLButtonUpEditTitleButton()
    if ( ButtonGetDisabledFlag( "GWAdminCommandEditTitleButton" ) )
    then
        return
    end
    if ( GuildWindowTabAdmin.SelectedTitleNumber < 0 )
    then
        return
    end

	GuildWindowTabAdmin.UpdateTitleBeingEdited( GuildWindowTabAdmin.SelectedTitleNumber )
end

function GuildWindowTabAdmin.OnLButtonUpAddRemoveTitleButton()
    if ( ButtonGetDisabledFlag( "GWAdminCommandAddRemoveTitleButton" ) )
    then
        return
    end
    if ( GuildWindowTabAdmin.SelectedTitleNumber < 0 )
    then
        return
    end

    local chatText = L"/guildrankdisable "..GuildWindowTabAdmin.SelectedTitleNumber
	-- We could spend a lot of time figuring out if the selected Title is being used or not, but its easier to just check the button text :)
	if ButtonGetText("GWAdminCommandAddRemoveTitleButton") == GetGuildString(StringTables.Guild.BUTTON_GUILD_ADMIN_COMMAND_ADD_TITLE) then
		chatText = L"/guildrankenable "..GuildWindowTabAdmin.SelectedTitleNumber
	end
	
    SendChatText( chatText, L"" )
end
