-- Main things to do when adding a filter tab for Actions, Morale, or Tactics mode:
--          update table AbilitiesWindow.FilterTabsPerMode with the new number of tabs for that mode
--          update table AbilitiesWindow.FilterData, adding an entry with index (new # of tabs for that mode)
--                  the filter function can assume that abilities are already of the right type (actions, morale, or tactics), from GetAbilityTable(type enum)
--          ensure that AbilitiesWindow.ApplyFilters(), AbilitiesWindow.DisplayCurrentPage(), and AbilitiesWindow.ActionMouseOver() still work properly when this filter is selected
--
-- Main things to do when adding a filter tab for General mode (abilities that need to be handled differently):
--          update AbilitiesWindow.FilterTabsPerMode[AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES] to indicate an extra tab should be created
--          update AbilitiesWindow.GeneralTabs to have a name for this tab's window id (they go 1 through n down the right)
--          add AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.NEW_FILTER_NAME] as an empty table
--          update table AbilitiesWindow.FilterData, adding an entry with index (new # of tabs for that mode)
--                  the filter function won't actually be used
--          create a new function that updates and orders the list AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.NEW_FILTER_NAME] (e.g. AbilitiesWindow.UpdateGeneralList())
--                  this should store entries with indexes 1 to (# of abilities), with each item containing a wstring field .name, and a number field .iconNum (to be used with GetIconData())
--                  it can also contain a field like .skillID, .tradeSkillID, etc. unique to this type of ability (e.g. .tradeSkillID is from the ETradeSkills enum)
--          update AbilitiesWindow.HandleSpecialFilter() to handle the new filter, via calling the list-updating function just created ^
--          ensure AbilitiesWindow.HandleSpecialDisplay() is still working properly (it always uses a square icon border and only displays the icon & name of the ability...)
--          update AbilitiesWindow.HandleSpecialMouseover() to handle the new filter and make some kind of tooltip
--
-- Details about storage list contents are in comments above where AbilitiesWindow.abilityData and AbilitiesWindow.GeneralLists are created.

----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

AbilitiesWindow = {}

AbilitiesWindow.stillLoading = true

AbilitiesWindow.TOOLTIP_ANCHOR = { Point="topright", RelativeTo="AbilitiesWindowBackgroundStoneTablet", RelativePoint="topleft", XOffset=-100, YOffset=0 }

AbilitiesWindow.Modes = {}
AbilitiesWindow.Modes.MODE_ACTION_ABILITIES   = 1
AbilitiesWindow.Modes.MODE_MORALE_ABILITIES   = 2
AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES   = 3
AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES  = 4
AbilitiesWindow.Modes.NUM_MODES = 4

AbilitiesWindow.currentMode      = AbilitiesWindow.Modes.MODE_ACTION_ABILITIES
AbilitiesWindow.currentSubFilter = nil

-- These are the window IDs of the filter tabs for 'General' mode.  These must match the window ids given to the filter tabs in AbilitiesWindow.CreateFilterTabs().
AbilitiesWindow.GeneralTabs = {}
AbilitiesWindow.GeneralTabs.FILTER_ALL               = 1
AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES = 2
AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_SKILLS    = 3
AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS      = 4

-- Lists for Actions, Morale, and Tactics modes.
-- These lists contain only an ability ID for each entry.
AbilitiesWindow.abilityData        = {}
AbilitiesWindow.displayList        = {}

-- The ability/skill lists for General mode; populated in AbilitiesWindow.ApplyFilters(), via AbilitiesWindow.HandleSpecialFilters().
-- These need to be handled differently from the above, since they can't be obtained via a single call to GetAbilityTable.
--
-- Each entry 'data' contains:
--              data.name       = the widestring name of the ability
--              data.iconNum = the number to pass to GetIconData()
--
-- Fields specific to certain types of general abilities:
--              data.tradeSkillId  = trade skill,        value from enum ETradeSkills in WHConsts.h
--              data.advanceID    = passive ability, value from data retrieved via GameData.Player.GetAdvanceData() -- these passive abilities are distinct from those below, which have .id fields
--              data.id                   = passive ability, value from data retrieved via GetAbilityTable(GameData.AbilityType.PASSIVE)
--              data.skillId            = passive skill,     value from enum ESkills in CombatConsts.h
AbilitiesWindow.GeneralLists = {}
AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_ALL]               = {}   -- populated in AbilitiesWindow.UpdateGeneralList()
AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES] = {}   -- populated in AbilitiesWindow.UpdatePassiveAbilitiesList()
AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_SKILLS]    = {}   -- populated in AbilitiesWindow.UpdatePassiveSkillsList()
AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS]      = {}   -- populated in AbilitiesWindow.UpdateTradeSkillsList()

-- These are initialized to invalid values; pages are 1-indexed.  Values are set in AbilitiesWindow.ApplyFilters().
AbilitiesWindow.totalPages  = 0
AbilitiesWindow.currentPage = 0

-- Entries in the ability window are 1-indexed.
local FIRST_ITEM_INDEX = 1
local LAST_ITEM_INDEX  = 6
local ITEMS_PER_PAGE   = 6

-- Holds the window ID of the currently selected right filter tab, for each mode.
AbilitiesWindow.FilterTabSelected = {}
AbilitiesWindow.FilterTabSelected[ AbilitiesWindow.Modes.MODE_ACTION_ABILITIES ]   = 1
AbilitiesWindow.FilterTabSelected[ AbilitiesWindow.Modes.MODE_MORALE_ABILITIES ]   = 1
AbilitiesWindow.FilterTabSelected[ AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES ]   = 1
AbilitiesWindow.FilterTabSelected[ AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES ]  = 1

AbilitiesWindow.FirstTradeSkill = 1
AbilitiesWindow.MaxTradeSkill   = GameData.TradeSkills.NUM_TRADE_SKILLS

AbilitiesWindow.TradeSkillLabels = 
{
    [GameData.TradeSkills.BUTCHERING]  = GetString (StringTables.Default.LABEL_SKILL_BUTCHERING),
    [GameData.TradeSkills.SCAVENGING]  = GetString (StringTables.Default.LABEL_SKILL_SCAVENGING),
    [GameData.TradeSkills.CULTIVATION] = GetString (StringTables.Default.LABEL_SKILL_CULTIVATION),
    [GameData.TradeSkills.APOTHECARY]  = GetString (StringTables.Default.LABEL_SKILL_APOTHECARY),
    [GameData.TradeSkills.TALISMAN]    = GetString (StringTables.Default.LABEL_SKILL_TALISMAN),
    [GameData.TradeSkills.SALVAGING]   = GetString (StringTables.Default.LABEL_SKILL_SALVAGING),
}

-- Career-specific texture slices for filter tabs; used in AbilitiesWindow.PopulateDynamicFields().
AbilitiesWindow.FilterTabCareerTextures =
{
    [GameData.CareerLine.WITCH_ELF]         =
    {
        [1] = "Tab-WitchElf1-Carnage",
        [2] = "Tab-WitchElf2-Suffering",
        [3] = "Tab-WitchElf3-Treachery"
    },
    [GameData.CareerLine.ARCHMAGE]          =
    {
        [1] = "Tab-Archmage1-Isha",
        [2] = "Tab-Archmage2-Asuryan",
        [3] = "Tab-Archmage3-Vaul"
    },
    [GameData.CareerLine.BLACK_ORC]         =
    {
        [1] = "Tab-BlackOrc1-DaBrawler",
        [2] = "Tab-BlackOrc3-DaToughest",
        [3] = "Tab-BlackOrc2-DaBoss"
    },
    [GameData.CareerLine.DISCIPLE]          =
    {
        [1] = "Tab-Disciple1-Dark-Rites",
        [2] = "Tab-Disciple2-Torture",
        [3] = "Tab-Disciple3-Sacrifice"
    },
    [GameData.CareerLine.BRIGHT_WIZARD]     =
    {
        [1] = "Tab-BrightWizard1-Incineration",
        [2] = "Tab-BrightWizard2-Immolation",
        [3] = "Tab-BrightWizard3-Conflagration"
    },
    [GameData.CareerLine.CHOSEN]            =
    {
        [1] = "Tab-Chosen1-Dread",
        [2] = "Tab-Chosen2-Corruption",
        [3] = "Tab-Chosen3-Discord"
    },
    [GameData.CareerLine.CHOPPA]            =
    {
        [1] = "Tab-Choppa1-DaSavage",
        [2] = "Tab-Choppa2-DabigHitta",
        [3] = "Tab-Choppa3-DaWrecka"
    },
    [GameData.CareerLine.ENGINEER]          =
    {
        [1] = "Tab-Engineer2-Rifleman",
        [2] = "Tab-Engineer3-Grenadier",
        [3] = "Tab-Engineer1-Tinkerer"
    },
    [GameData.CareerLine.SLAYER]            =
    {
        [1] = "Tab-Slayer1-Giantslayer",
        [2] = "Tab-Slayer2-Trollslayer",
        [3] = "Tab-Slayer3-Skavenslayer"
    },
    [GameData.CareerLine.IRON_BREAKER]      =
    {
        [1] = "Tab-IronBreaker1-Vengeance",
        [2] = "Tab-IronBreaker2-Stone",
        [3] = "Tab-IronBreaker3-Brotherhood"
    },
    [GameData.CareerLine.MAGUS]             =
    {
        [1] = "Tab-Magus1-Havoc",
        [2] = "Tab-Magus2-Changing",
        [3] = "Tab-Magus3-Daemonology"
    },
    [GameData.CareerLine.RUNE_PRIEST]       =
    {
        [1] = "Tab-RunePriest2-Grungni",
        [2] = "Tab-RunePriest3-Valaya",
        [3] = "Tab-RunePriest1-Grimnir"
    },
    [GameData.CareerLine.WHITE_LION]        =
    {
        [1] = "Tab-WhiteLion1-TheHunter",
        [2] = "Tab-WhiteLion2-TheAxeman",
        [3] = "Tab-WhiteLion3-TheGuardian"
    },
    [GameData.CareerLine.SHADOW_WARRIOR]    =
    {
        [1] = "Tab-ShadowWarrior1-TheScout",
        [2] = "Tab-ShadowWarrior2-Assault",
        [3] = "Tab-ShadowWarrior3-TheSkirmisher"
    },
    [GameData.CareerLine.SHAMAN]            =
    {
        [1] = "Tab-Shaman3-Mork",
        [2] = "Tab-Shaman2-Gork",
        [3] = "Tab-Shaman1-DaGreen"
    },
    [GameData.CareerLine.SORCERER]          =
    {
        [1] = "Tab-Sorceress1-Agony",
        [2] = "Tab-Sorceress2-Calamity",
        [3] = "Tab-Sorceress3-Destruction"
    },
    [GameData.CareerLine.SQUIG_HERDER]      =
    {
        [1] = "Tab-SquigHerder2-BigShootin",
        [2] = "Tab-SquigHerder1-Stabbin",
        [3] = "Tab-SquigHerder3-QuickShootin"
    },
    [GameData.CareerLine.SWORDMASTER]       =
    {
        [1] = "Tab-Swordmaster1-Khaine",
        [2] = "Tab-Swordmaster2-Vaul",
        [3] = "Tab-Swordmaster3-Hoeth"
    },
    [GameData.CareerLine.MARAUDER]          =
    {
        [1] = "Tab-Marauder3-Monstrosity",
        [2] = "Tab-Marauder2-Brutality",
        [3] = "Tab-Marauder1-Savagery"
    },
    [GameData.CareerLine.WARRIOR_PRIEST]    =
    {
        [1] = "Tab-WarriorPriest1-Salvation",
        [2] = "Tab-WarriorPriest2-Grace",
        [3] = "Tab-WarriorPriest3-Wrath"
    },
    [GameData.CareerLine.WITCH_HUNTER]      =
    {
        [1] = "Tab-WitchHunter1-Confession",
        [2] = "Tab-WitchHunter2-Inquisition",
        [3] = "Tab-WitchHunter3-Judgement"
    },
    [GameData.CareerLine.ZEALOT]            =
    {
        [1] = "Tab-Zealot1-Alchemy",
        [2] = "Tab-Zealot2-Witchcraft",
        [3] = "Tab-Zealot3-DarkRites"
    },
    [GameData.CareerLine.KNIGHT]            =
    {
        [1] = "Tab-Knight1-Conquest",
        [2] = "Tab-Knight2-Vigilance",
        [3] = "Tab-Knight3-Glory"
    },
    [GameData.CareerLine.BLACKGUARD]        =
    {
        [1] = "Tab-BlackGuard1-Malice",
        [2] = "Tab-BlackGuard2-Loathing",
        [3] = "Tab-BlackGuard3-Anguish"
    }
}

-- Tooltip text for the major tabs.
AbilitiesWindow.ModeTooltips = {}
AbilitiesWindow.ModeTooltips[AbilitiesWindow.Modes.MODE_ACTION_ABILITIES]   = GetString (StringTables.Default.LABEL_ACTIONS)
AbilitiesWindow.ModeTooltips[AbilitiesWindow.Modes.MODE_MORALE_ABILITIES]   = GetString (StringTables.Default.LABEL_MORALE)
AbilitiesWindow.ModeTooltips[AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES]   = GetString (StringTables.Default.LABEL_TACTICS)
AbilitiesWindow.ModeTooltips[AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES]  = GetString (StringTables.Default.LABEL_GENERAL)

-- Description of how to use each ability type; used by AbilitiesWindow.ActionMouseOver().
AbilitiesWindow.AbilityTypeDesc = {}
AbilitiesWindow.AbilityTypeDesc[ AbilitiesWindow.Modes.MODE_ACTION_ABILITIES ]   = GetString( StringTables.Default.TEXT_ACTION_ABILITY_DESC )
AbilitiesWindow.AbilityTypeDesc[ AbilitiesWindow.Modes.MODE_MORALE_ABILITIES ]   = GetString( StringTables.Default.TEXT_MORALE_ABILITY_DESC )
AbilitiesWindow.AbilityTypeDesc[ AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES ]   = GetString( StringTables.Default.TEXT_TACTIC_ABILITY_DESC )
AbilitiesWindow.AbilityTypeDesc[ AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES ]  = L""

-- Used for populating the six ability entries, when under the tactics major tab; used by the local function GetAbilitySpecLine.
local TacticsTypeText =
{
    [0] = GetString (StringTables.Default.LABEL_CAREER_TACTIC),
    [1] = GetString (StringTables.Default.LABEL_RENOWN_TACTIC),
    [2] = GetString (StringTables.Default.LABEL_TOME_TACTIC)
}

-- filter tab counts:
AbilitiesWindow.MAX_FILTER_TABS = 7
AbilitiesWindow.FilterTabsPerMode = {}
AbilitiesWindow.FilterTabsPerMode[AbilitiesWindow.Modes.MODE_ACTION_ABILITIES]  = 6
AbilitiesWindow.FilterTabsPerMode[AbilitiesWindow.Modes.MODE_MORALE_ABILITIES]  = 5
AbilitiesWindow.FilterTabsPerMode[AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES]  = 7
AbilitiesWindow.FilterTabsPerMode[AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES] = 4

-- When the user may have been right-clicking to clear the cursor, supress the opacity menu popup.
AbilitiesWindow.supressOpacityMenu = false

----------------------------------------------------------------
-- AbilityFilterTab functions
----------------------------------------------------------------

AbilityFilterTab = Frame:Subclass("AbilitiesWindowFilterTab")

function AbilityFilterTab:Create(windowName, parentName, windowId)
    local filterTab = self:CreateFromTemplate (windowName, parentName)

    -- If the xml names are changed, it only needs to be changed here:
    filterTab.iconName       = windowName.."Icon"
    filterTab.selectedName   = windowName.."ActiveImage"
    filterTab.unselectedName = windowName.."InactiveImage"
    
    filterTab.filter      = AbilitiesWindow.SubFilterAll
    filterTab.tooltipText = L""
    
    -- Change tab window ID to a custom value, based on the tab's index among the other tabs (for identification purposes on mouse over).
    WindowSetId (windowName, windowId)
    WindowSetId (filterTab.unselectedName, windowId) -- so tooltips to work properly
    filterTab.m_Id = windowId
    
    
    -- Show the tab showing in its unselected state.
    filterTab:Show( true )
    filterTab:SetSelected( false )
    
    return filterTab
end

-- Set selected state based on boolean 'setSelected'; handled independently of hiding/showing the entire tab.
function AbilityFilterTab:SetSelected( selected )
    WindowSetShowing( self.selectedName, selected )
    WindowSetShowing( self.unselectedName, not selected )
end

-- This information will change on major tab selection (Actions/Morale/Tactics/Passives)
function AbilityFilterTab:SetFilterData( filter, textureSlice, tooltipText  )
    self.filter = filter
    DynamicImageSetTextureSlice( self.iconName, textureSlice )
    self.tooltipText = tooltipText
end

-- Table to hold the AbilitiesWindow filter tabs
AbilitiesWindow.FilterTabs = {}

function AbilitiesWindow.CreateFilterTabs()
    
    local anchor =
    {
        Point         = "bottomLeft",
        RelativeTo    = "AbilitiesWindowTopBookend",
        RelativePoint = "topleft",
        XOffset       = 0,
        YOffset       = 2
    }
    
    for indexId = 1, AbilitiesWindow.MAX_FILTER_TABS do
        local tabName = "AbilitiesWindowFilterTab"..indexId
        AbilitiesWindow.FilterTabs[indexId] = AbilityFilterTab:Create( tabName, "AbilitiesWindow", indexId)
        
        AbilitiesWindow.FilterTabs[indexId]:SetAnchor( anchor )
        anchor.RelativeTo = tabName
    end
end

-- Updates the filter tabs, and AbilitiesWindow.curentSubFilter
function AbilitiesWindow.UpdateFiltersForMode( mode )
    if (mode < AbilitiesWindow.Modes.MODE_ACTION_ABILITIES or mode > AbilitiesWindow.Modes.NUM_MODES) then
        DEBUG(L"AbilitiewsWindow.UpdateFiltersForMode:  invalid mode ID.")
        return
    end
    
    local numToShow  = AbilitiesWindow.FilterTabsPerMode[mode]
    local filterData = AbilitiesWindow.FilterData[mode]
    
    -- Iterate through visible filters:
    for indexId, filterTab in pairs( AbilitiesWindow.FilterTabs ) do
        
        if ( filterTab.m_Id <= numToShow ) then

            local filter   = filterData[filterTab.m_Id].filter
            local texSlice = filterData[filterTab.m_Id].textureSlice
            local tooltip  = filterData[filterTab.m_Id].tooltip

            filterTab:SetFilterData( filter, texSlice, tooltip )
            filterTab:Show( true )
            
            -- Update selected state and AbilitiesWindow filter.
            if( filterTab.m_Id == AbilitiesWindow.FilterTabSelected[mode] ) then
                filterTab:SetSelected( true )
                AbilitiesWindow.currentSubFilter = filter
            else
                filterTab:SetSelected( false )
            end
            
            -- If this is the last filter tab, reanchor the bottom bookend to it.
            if( filterTab.m_Id == numToShow ) then
                WindowClearAnchors( "AbilitiesWindowBottomBookend" )
                WindowAddAnchor( "AbilitiesWindowBottomBookend", "bottomleft", filterTab:GetName(), "topleft", 0, 2 )
            end
            
        else
            filterTab:Show( false )
        end
    end
end


----------------------------------------------------------------
-- AbilitiesWindow Functions
----------------------------------------------------------------

-- OnInitialize Handler
function AbilitiesWindow.Initialize()

    LabelSetText( "AbilitiesWindowTitleBarText", GetString( StringTables.Default.LABEL_ABILITIES ) )    
    
    -- We might need to add in some handler for when passive abilities are updated via renown trainers.
    WindowRegisterEventHandler( "AbilitiesWindow", SystemData.Events.PLAYER_ABILITIES_LIST_UPDATED, "AbilitiesWindow.UpdateIfNotLoading")
    WindowRegisterEventHandler( "AbilitiesWindow", SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED, "AbilitiesWindow.UpdateIfNotLoading")
    WindowRegisterEventHandler( "AbilitiesWindow", SystemData.Events.TRADE_SKILL_UPDATED, "AbilitiesWindow.UpdateIfNotLoading")
    WindowRegisterEventHandler( "AbilitiesWindow", SystemData.Events.LOADING_END, "AbilitiesWindow.OnLoadingEnd")
    WindowRegisterEventHandler( "AbilitiesWindow", SystemData.Events.RELOAD_INTERFACE, "AbilitiesWindow.OnLoadingEnd")
	WindowRegisterEventHandler( "AbilitiesWindow", SystemData.Events.PLAYER_BLOCKED_ABILITIES_UPDATED, "AbilitiesWindow.UpdateBlockedAbilities")
    
    DynamicImageSetTextureSlice( "AbilitiesWindowModeTab1Icon", "MainTab-SymbolActions")
    DynamicImageSetTextureSlice( "AbilitiesWindowModeTab2Icon", "MainTab-SymbolMorale")
    DynamicImageSetTextureSlice( "AbilitiesWindowModeTab3Icon", "MainTab-SymbolTactics")
    -- The default icon is "MainTab-SymbolGeneral".
    
    -- Set ID for the inactive images of the major tabs, so that their tooltips will work.
    for i = AbilitiesWindow.Modes.MODE_ACTION_ABILITIES, AbilitiesWindow.Modes.NUM_MODES do
        WindowSetId( "AbilitiesWindowModeTab"..i.."InactiveImage", i )
    end
    
    -- Make the six empty ability entires:
    local anchor =
    {
        Point = "topleft",
        RelativeTo = "AbilitiesWindowBackgroundStoneTablet",
        RelativePoint = "topleft",
        OffsetX = 17,
        OffsetY = 0
    }
    
    local entryName = "AbilitiesWindowAbilityEntry"
    for i = FIRST_ITEM_INDEX, LAST_ITEM_INDEX do
        CreateWindowFromTemplate (entryName..i, "AbilityEntry", "AbilitiesWindow")
        WindowAddAnchor (entryName..i, anchor.Point, anchor.RelativeTo, anchor.RelativePoint, anchor.OffsetX, anchor.OffsetY)
        WindowSetId (entryName..i.."Button", i) -- for telling which ability this is... see OnMouseOver handler, ActionMouseOver()
        
        if (i == 1) then
            anchor.Point = "bottomleft"
            anchor.OffsetX = 0
        end
        anchor.RelativeTo = entryName..i
    end
    
    -- No abilities text
    LabelSetText("AbilitiesWindowNoAbilitiesText", GetString( StringTables.Default.TEXT_NO_ABILITIES ) )

    AbilitiesWindow.CreateFilterTabs()
    AbilitiesWindow.SetMode( AbilitiesWindow.Modes.MODE_ACTION_ABILITIES )
end

-- Handler for when the player's abilities are updated.
function AbilitiesWindow.UpdateIfNotLoading()
    -- Do not update when loading, as abilities are added one at a time to the player;
    -- this would cause update calls equal to the number of abilities the player has.
    if (not AbilitiesWindow.stillLoading) then
        AbilitiesWindow.UpdateAbilitiesDisplay()
    end
end

-- Handler for loading end and UI reloads
function AbilitiesWindow.OnLoadingEnd()
    AbilitiesWindow.PopulateDynamicFields()
    AbilitiesWindow.UpdateAbilitiesDisplay()
    AbilitiesWindow.stillLoading = false
end

-- This function is for work that needs to be done after loading has finished.
function AbilitiesWindow.PopulateDynamicFields()

    local careerTex = AbilitiesWindow.FilterTabCareerTextures[GameData.Player.career.line]
    
    -- populate career-specific data for the FilterData table:
    for mode = AbilitiesWindow.Modes.MODE_ACTION_ABILITIES, AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES do
        local filters = AbilitiesWindow.FilterData[ mode ]
       
        filters[3].tooltip = GetStringFormat (StringTables.Default.LABEL_SPECIALIZATION_PATH, {GetSpecializationPathName (GameData.Player.SPECIALIZATION_PATH_1)})
        filters[4].tooltip = GetStringFormat (StringTables.Default.LABEL_SPECIALIZATION_PATH, {GetSpecializationPathName (GameData.Player.SPECIALIZATION_PATH_2)})
        filters[5].tooltip = GetStringFormat (StringTables.Default.LABEL_SPECIALIZATION_PATH, {GetSpecializationPathName (GameData.Player.SPECIALIZATION_PATH_3)})
   
        if( careerTex ) then
            filters[3].textureSlice = careerTex[1]
            filters[4].textureSlice = careerTex[2]
            filters[5].textureSlice = careerTex[3]
        end
    end
    
    -- Set mode, now that the FilterData table is properly populated:
    AbilitiesWindow.SetMode(AbilitiesWindow.currentMode)
   
end

local function GetAbilityTypeFromMode( mode )
	if( mode == AbilitiesWindow.Modes.MODE_ACTION_ABILITIES )
	then
		return GameData.AbilityType.STANDARD
	elseif( mode == AbilitiesWindow.Modes.MODE_MORALE_ABILITIES )
	then
		return GameData.AbilityType.MORALE
	elseif( mode == AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES )
	then
		return GameData.AbilityType.TACTIC
	end
	return nil
end

function AbilitiesWindow.UpdateBlockedAbilities()
		
	local list = AbilitiesWindow.displayList
	local page = AbilitiesWindow.currentPage
    local mode = AbilitiesWindow.currentMode
	
	local abilityType = GetAbilityTypeFromMode( mode )
	
    if( abilityType )
	then
        for i = FIRST_ITEM_INDEX, LAST_ITEM_INDEX
		do
            local abilityId = list[(page - FIRST_ITEM_INDEX) * ITEMS_PER_PAGE + i]
            local window = "AbilitiesWindowAbilityEntry"..i.."Button"
			
			if( abilityId )
			then
				Player.TintWindowIfAbilityIsBlocked( window, abilityId, abilityType )
			end
		end
	end
end




-- OnShutdown Handler
function AbilitiesWindow.Shutdown()
end

function AbilitiesWindow.OnOpen()
    -- Show all availiable morale & tactic slots
    WindowUtils.OnShown(AbilitiesWindow.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
    AbilitiesWindow.UpdateAbilitiesDisplay()
    MoraleSystem.ShowSlotsForEditing( true )
end

function AbilitiesWindow.OnClose()
    -- Hide all unused morale & tactic slots
    WindowUtils.OnHidden()
    MoraleSystem.ShowSlotsForEditing( false )
end

function AbilitiesWindow.Hide()
    WindowSetShowing( "AbilitiesWindow", false )
end

function AbilitiesWindow.ToggleShowing()
    WindowUtils.ToggleShowing( "AbilitiesWindow" )
end


----------------------------------------------------------------
-- Mouse button handlers
----------------------------------------------------------------

-- OnLButtonDown Handler
function AbilitiesWindow.ActionLButtonDown( flags, x, y )

    local abilityData = AbilitiesWindow.abilityData[ AbilitiesWindow.GetAbilityFromMouseOverEntry() ]
    local mode        = AbilitiesWindow.currentMode
    local filter      = AbilitiesWindow.FilterTabSelected[mode]
           
    
    if( abilityData ~= nil) and (mode ~= AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES) 
    then    
                
        Cursor.PickUp( Cursor.SOURCE_ACTION_LIST, index, abilityData.id, 
                       abilityData.iconNum, false )
    
    -- Handle the case of trade skill icons in General mode (when either the All filter tab or Trade Skill filter tab is selected) 
    elseif( filter == AbilitiesWindow.GeneralTabs.FILTER_ALL ) or ( filter == AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS ) 
    then
        local index = ITEMS_PER_PAGE * (AbilitiesWindow.currentPage - FIRST_ITEM_INDEX) + WindowGetId(SystemData.MouseOverWindow.name)
        local data  = AbilitiesWindow.GeneralLists[filter][index]
        if( data ) then
            local id    = data.tradeSkillId
            
            if id and (id ~= GameData.TradeSkills.BUTCHERING) and (id ~= GameData.TradeSkills.SCAVENGING) and (id ~= GameData.TradeSkills.NONE) then
                AbilitiesWindow.lButtonDown = true
            end
        end
    end

end

-- OnLButtonUp Handler
function AbilitiesWindow.ActionLButtonUp( flags, x, y)
    
    local mode   = AbilitiesWindow.currentMode
    local filter = AbilitiesWindow.FilterTabSelected[mode]

    -- Handle the case of trade skill icons in General mode (when either the All filter tab or Trade Skill filter tab is selected) 
    if (mode == AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES) and ((filter == AbilitiesWindow.GeneralTabs.FILTER_ALL) or (filter == AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS)) then
        local index = ITEMS_PER_PAGE * (AbilitiesWindow.currentPage - FIRST_ITEM_INDEX) + WindowGetId(SystemData.MouseOverWindow.name)
        local data  = AbilitiesWindow.GeneralLists[filter][index]
        if( data and data.tradeSkillId) then
            local id    = data.tradeSkillId
            
            if id and (id ~= GameData.TradeSkills.BUTCHERING) and (id ~= GameData.TradeSkills.SCAVENGING) and (id ~= GameData.TradeSkills.NONE) then
                
                if( id == GameData.TradeSkills.SALVAGING )
                then
                    SalvagingWindow.BeginSalvage()
                else
                    CraftingSystem.ToggleShowing( id )
                end
            end
            
            AbilitiesWindow.lButtonDown = false
        end
    end
        
    -- Clear the cursor data so the icon doesn't magically appear on the mouse the next
    -- time you click in the world
    Cursor.Clear()  
end

-- OnRButtonDown Handler
function AbilitiesWindow.ActionRButtonDown()

    local abilityData = AbilitiesWindow.abilityData[ AbilitiesWindow.GetAbilityFromMouseOverEntry() ]
    
    if (abilityData ~= nil) then
    -- If an action ability, locate the first available action bar slot on the visible action bar
    -- stick this ability into it
        if (AbilitiesWindow.currentMode == AbilitiesWindow.Modes.MODE_ACTION_ABILITIES) then
            SetHotbarData( -1, GameData.PlayerActions.DO_ABILITY, abilityData.id )
        -- If morale ability, replace that % slot's morale with the ability, regardless of whether it
        --   is full or not.
        elseif (AbilitiesWindow.currentMode == AbilitiesWindow.Modes.MODE_MORALE_ABILITIES) then
            SetMoraleBarData( abilityData.moraleLevel, abilityData.id )
        -- If a tactic, and there are sufficient tactic slots remaining, slot the tactic.
        elseif (AbilitiesWindow.currentMode == AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES) then
            TacticsEditor.ExternalAddTactic (abilityData.id);      
        else
            -- unhandled mode
            return
        end
    end
    
end

-- OnRButtonUp Handler
function AbilitiesWindow.ActionRButtonUp()
    -- This is just to trap the event so that the AbilitiesWindow handler doesn't open up the opacity popup.
end

function AbilitiesWindow.OnRButtonDown()
    
    -- Remember not to open the opacity menu on the next RButtonUp event.
    if Cursor.IconOnCursor() then
        AbilitiesWindow.supressOpacityMenu = true
    end

end

function AbilitiesWindow.OnRButtonUp()

    -- Clear the cursor if there is an icon on it; otherwise try to open the opacity adjustment popup.
    if Cursor.IconOnCursor()
    then
        Cursor.Clear()
        
    else
        if( not AbilitiesWindow.supressOpacityMenu ) then
            EA_Window_ContextMenu.CreateOpacityOnlyContextMenu( "AbilitiesWindow" )
        end
    end
    
    -- We are guaranteed now not to have an icon on the cursor.
    AbilitiesWindow.supressOpacityMenu = false
end

----------------------------------------------------------------
-- Mouse over / mouse wheel handlers
----------------------------------------------------------------

function AbilitiesWindow.GetAbilityFromMouseOverEntry()
    local index = WindowGetId(SystemData.MouseOverWindow.name)
    return AbilitiesWindow.displayList[ITEMS_PER_PAGE * (AbilitiesWindow.currentPage - FIRST_ITEM_INDEX) + index]
end

-- OnMouseMove Handler
function AbilitiesWindow.ActionMouseOver()

    if( AbilitiesWindow.HandleSpecialMouseOver() == false) then
        local abilityData = GetAbilityData( AbilitiesWindow.GetAbilityFromMouseOverEntry() )
        
        if( abilityData ~= nil ) then
            local text = AbilitiesWindow.AbilityTypeDesc[ AbilitiesWindow.currentMode ]
			-- Override the interaction text if the ability is blocked
			if( Player.IsAbilityBlocked( abilityData.id, abilityData.abilityType ))
			then
				text = GetString( StringTables.Default.TEXT_BLOCKED_ABILITY_DESC )
			end
			
            Tooltips.CreateAbilityTooltip( abilityData, SystemData.ActiveWindow.name, AbilitiesWindow.TOOLTIP_ANCHOR, text )
        end
    end
    
    AbilitiesWindow.SetActionMouseOverFrame()
    
end

function AbilitiesWindow.HandleSpecialMouseOver()
    local specialMouseOver = false
    local mode             = AbilitiesWindow.currentMode
    local filter           = AbilitiesWindow.FilterTabSelected[mode]

    if (mode == AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES) then
        local index   = ITEMS_PER_PAGE * (AbilitiesWindow.currentPage - FIRST_ITEM_INDEX) + WindowGetId(SystemData.MouseOverWindow.name)
        local data    = AbilitiesWindow.GeneralLists[filter][index]
        
        if (data) then
        
            -- If this is a passive skill:
            if (data.skillID) then
                local text    = GetStringFormat (StringTables.Default.TEXT_PLAYER_SKILL_TOOLTIP, {data.name})
                Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
                Tooltips.AnchorTooltip( AbilitiesWindow.TOOLTIP_ANCHOR )
                
            -- If this is a trade skill:
            elseif (data.tradeSkillId) then
                Tooltips.CreateTradeskillTooltip (data.tradeSkillId)
                Tooltips.AnchorTooltip( AbilitiesWindow.TOOLTIP_ANCHOR )
                --AbilitiesWindow.SetActionMouseOverFrame()
            
            -- If this is a passive ability:
            else
                if (data.id) then
                    Tooltips.CreateAbilityTooltip( GetAbilityData(data.id), SystemData.ActiveWindow.name, AbilitiesWindow.TOOLTIP_ANCHOR)
                else
                    Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name)

                    Tooltips.SetTooltipText( 1, 1, data.name )
                    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
                    Tooltips.SetTooltipText( 2, 1, GetStringFromTable( "PackageDescriptions", data.advanceID ) )
                    Tooltips.Finalize()
                    Tooltips.AnchorTooltip( AbilitiesWindow.TOOLTIP_ANCHOR ) 
                end
            end
            
        end
        
        specialMouseOver = true
    end

    return specialMouseOver
end

function AbilitiesWindow.ActionMouseOverEnd()

    local tradeSkill = WindowGetId( SystemData.MouseOverWindow.name )
    
    local abilityData = AbilitiesWindow.abilityData[ AbilitiesWindow.GetAbilityFromMouseOverEntry() ]
    local mode        = AbilitiesWindow.currentMode
    local filter      = AbilitiesWindow.FilterTabSelected[mode]
  
    -- Handle the case of trade skill icons in General mode (when either the All filter tab or Trade Skill filter tab is selected) 
    if (mode == AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES) and ((filter == AbilitiesWindow.GeneralTabs.FILTER_ALL ) or ( filter == AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS )) then
        local index = ITEMS_PER_PAGE * (AbilitiesWindow.currentPage - FIRST_ITEM_INDEX) + WindowGetId(SystemData.MouseOverWindow.name)
        local data  = AbilitiesWindow.GeneralLists[filter][index]
        if( data ) then
            local id    = data.tradeSkillId
            if id and (id ~= GameData.TradeSkills.BUTCHERING) and (id ~= GameData.TradeSkills.SCAVENGING) and (id ~= GameData.TradeSkills.NONE) then
                if( AbilitiesWindow.lButtonDown )
                then
                    --DEBUG(L"Picking Up!")
                    Cursor.PickUp( Cursor.SOURCE_CRAFTING, id, id, GetTradeskillIcon (id), false )
                    AbilitiesWindow.lButtonDown = false
                end
            end
        end
    end

    AbilitiesWindow.HideMouseOverFrame()
end

-- Sets the mouse over highlight frame so that it matches the icon shape.
function AbilitiesWindow.SetActionMouseOverFrame()  
    local mode = AbilitiesWindow.currentMode
    
    if ( (mode == AbilitiesWindow.Modes.MODE_ACTION_ABILITIES) or
         (mode == AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES)   ) then
        ButtonSetTexture (SystemData.ActiveWindow.name, Button.ButtonState.HIGHLIGHTED, "EA_SquareFrame_Highlight", 0, 0)
    elseif (mode == AbilitiesWindow.Modes.MODE_MORALE_ABILITIES) then
        ButtonSetTexture (SystemData.ActiveWindow.name, Button.ButtonState.HIGHLIGHTED, "EA_RoundFrame_Highlight", 0, 0)
    elseif (mode == AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES) then
        ButtonSetTexture (SystemData.ActiveWindow.name, Button.ButtonState.HIGHLIGHTED, "EA_HexFrame_Highlight", 0, 0)
    end
end

function AbilitiesWindow.HideMouseOverFrame ()
    ButtonSetTexture (SystemData.ActiveWindow.name, Button.ButtonState.HIGHLIGHTED, "", 0, 0)
end

function AbilitiesWindow.OnMouseWheel (x, y, delta, flags) 
    if (delta > 0) then
        AbilitiesWindow.PrevPage ();
        
    elseif (delta < 0) then
        AbilitiesWindow.NextPage ();
    end
end

-- OnMouseOver handler for the main tabs across the top.
function AbilitiesWindow.MainTabTooltip ()
    local winId = WindowGetId( SystemData.MouseOverWindow.name )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, AbilitiesWindow.ModeTooltips[winId] )
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP);
end

-- OnMouseOver handler for the filter tabs down the right.
function AbilitiesWindow.FilterTabTooltip()
    local winId = WindowGetId( SystemData.MouseOverWindow.name )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, AbilitiesWindow.FilterData[AbilitiesWindow.currentMode][winId].tooltip )
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_RIGHT);
end


----------------------------------------------------------------
-- Major tab, filter tab, and page manipulation functions
----------------------------------------------------------------

-- OnLButtonUp handler for the filter tabs; sets the tab selected/unselected states and remembers this tab as the one selected for the current mode.
-- Also sets AbilitiesWindow.FilterTabSelected.
function AbilitiesWindow.SetFilterTab()    
    local selectedTabId = WindowGetId( SystemData.ActiveWindow.name )
    
    for indexId = 1, AbilitiesWindow.FilterTabsPerMode[AbilitiesWindow.currentMode] do
        local selected = indexId == selectedTabId
        local tab      = AbilitiesWindow.FilterTabs[indexId]
        
        WindowSetShowing( tab.selectedName, selected )
        WindowSetShowing( tab.unselectedName, not selected )
        
        if( selected ) then
            AbilitiesWindow.currentSubFilter = tab.filter
            AbilitiesWindow.FilterTabSelected[ AbilitiesWindow.currentMode ] = indexId
        end
    end
    
    -- This is the only place after initialization where FilterTabSelected will be updated.
    AbilitiesWindow.ApplyFilters() -- sets currentPage, totalPages
    AbilitiesWindow.DisplayCurrentPage()
end
--]]

function AbilitiesWindow.SelectMode()
    local mode = WindowGetId(SystemData.ActiveWindow.name)
    AbilitiesWindow.SetMode(mode)  
end

function AbilitiesWindow.SetMode( mode )

    -- Update tab buttons
    for index = 1, AbilitiesWindow.Modes.NUM_MODES do
        WindowSetShowing("AbilitiesWindowModeTab"..index.."ActiveImage",   mode == index)
        WindowSetShowing("AbilitiesWindowModeTab"..index.."InactiveImage", mode ~= index )
    end
    
    AbilitiesWindow.currentMode = mode
    AbilitiesWindow.UpdateFiltersForMode( mode )

    AbilitiesWindow.UpdateAbilitiesDisplay()
end

function AbilitiesWindow.PrevPage()
    if( (not WindowGetShowing ("AbilitiesWindowPrevPage")) or (AbilitiesWindow.currentPage == 1)) then
        return
    end
    
    -- We know there is a previous page by this point, since the button is showing.
    AbilitiesWindow.currentPage = AbilitiesWindow.currentPage - 1
    
    -- Filtering should already be done, so there is no need to call AbilitiesWindow.UpdateAbilitiesDisplay().
    AbilitiesWindow.DisplayCurrentPage()
end

function AbilitiesWindow.NextPage()
    if (not WindowGetShowing ("AbilitiesWindowNextPage")) or (AbilitiesWindow.currentPage == AbilitiesWindow.totalPages) then
        return
    end
    
    -- We know there is a next page by this point, since the button is showing.
    AbilitiesWindow.currentPage = AbilitiesWindow.currentPage + 1
    
    -- Filtering should already be done, so there is no need to call AbilitiesWindow.UpdateAbilitiesDisplay().
    AbilitiesWindow.DisplayCurrentPage()
end

-- Logic for hiding / showing pagination buttons and text; called by AbilitiesWindow.DisplayCurrentPage().
function AbilitiesWindow.UpdatePageButtons()

    local pagination = not ( (AbilitiesWindow.currentMode == AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES)
                             and (AbilitiesWindow.FilterTabSelected[AbilitiesWindow.currentMode] == "AbilitiesWindowFilterTab44") )

    WindowSetShowing ("AbilitiesWindowPrevPage", (AbilitiesWindow.currentPage > 1) and pagination)
    WindowSetShowing ("AbilitiesWindowNextPage", (AbilitiesWindow.currentPage < AbilitiesWindow.totalPages) and pagination)
    WindowSetShowing ("AbilitiesWindowPageNumber", pagination)
    
    if( AbilitiesWindow.totalPages > 1 ) then
        LabelSetText ("AbilitiesWindowPageNumber", GetStringFormat( StringTables.Default.LABEL_ABILITIES_PAGE_NUMBER, {AbilitiesWindow.currentPage, AbilitiesWindow.totalPages}))
    else
        LabelSetText ("AbilitiesWindowPageNumber", L"")
    end
end

function AbilitiesWindow.UpdateAbilitiesDisplay()
    -- currentSubFilter should already be set, either in UpdateFiltersForMode or tab selection callback
    AbilitiesWindow.ApplyFilters()
    AbilitiesWindow.DisplayCurrentPage()
end

----------------------------------------------------------------
-- Filter and display functions
----------------------------------------------------------------

local function OrderAbilities( abilityData1, abilityData2)
    local mode   = AbilitiesWindow.currentMode
    local filter = AbilitiesWindow.FilterTabSelected[mode]
    
    if( mode == AbilitiesWindow.Modes.MODE_ACTION_ABILITIES or mode == AbilitiesWindow.Modes.MODE_MORALE_ABILITIES or mode == AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES ) then
        local ab1  = GetAbilityData( abilityData1 )
        local ab2  = GetAbilityData( abilityData2 )
        
        if (ab1 and ab1.name and ab2 and ab2.name) then
            return ab1.name < ab2.name
        end
    
        return false
    
    -- Sorting for general abilities.
    elseif( mode == AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES) and (filter == AbilitiesWindow.GeneralTabs.FILTER_ALL or filter == AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES) then
        
        if (abilityData1 and abilityData1.name and abilityData2 and abilityData2.name) then
            return abilityData1.name < abilityData2.name
        end
    
        return false
    end
    
    return false
end

-- This function should apply main-tab filters AND sub-filters
function AbilitiesWindow.ApplyFilters()

    if (WindowGetShowing("AbilitiesWindow") == false) then
        return
    end

    if (AbilitiesWindow.HandleSpecialFilters() == false) then

        local ModeTranslator =
        {
           [AbilitiesWindow.Modes.MODE_ACTION_ABILITIES]    = GameData.AbilityType.STANDARD,
           [AbilitiesWindow.Modes.MODE_MORALE_ABILITIES]    = GameData.AbilityType.MORALE,
           [AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES]    = GameData.AbilityType.TACTIC,
           [AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES]   = GameData.AbilityType.PASSIVE -- this should be always handled in HandleSpecialFilters...
        }

        AbilitiesWindow.abilityData = GetAbilityTable( ModeTranslator[AbilitiesWindow.currentMode] )
        
        if (AbilitiesWindow.abilityData == nil) then
            -- this can occur during the initial load, in which case ignore it
            return
        end

        AbilitiesWindow.displayList = {}
        if(AbilitiesWindow.currentSubFilter) then
            for index, data in pairs(AbilitiesWindow.abilityData) do
                if AbilitiesWindow.currentSubFilter( data ) then
                    table.insert(AbilitiesWindow.displayList, index)
                end
            end
        end
        
        table.sort (AbilitiesWindow.displayList, OrderAbilities)
        
        AbilitiesWindow.totalPages  = math.ceil (#AbilitiesWindow.displayList / ITEMS_PER_PAGE)
        WindowSetShowing("AbilitiesWindowNoAbilitiesText", (#AbilitiesWindow.displayList == 0) ) 
    end

    AbilitiesWindow.currentPage = 1
end

-- Returns true iff a special filter mode has been handled.  (Also handles the filtering / display)
function AbilitiesWindow.HandleSpecialFilters()
    local mode          = AbilitiesWindow.currentMode
    local filter        = AbilitiesWindow.FilterTabSelected[ mode ]
    local specialFilter = false
    
    if(mode == AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES) then

        if (filter == AbilitiesWindow.GeneralTabs.FILTER_ALL) then
            AbilitiesWindow.UpdateGeneralList()

        -- Passive abilities (e.g. from renown trainers)
        elseif (filter == AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES) then
            AbilitiesWindow.UpdatePassiveAbilitiesList()

        -- Player skills (e.g. Heavy Armor, Axe, etc.) -- these also need to be handled specially in display current page...
        elseif (filter == AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_SKILLS) then
            AbilitiesWindow.UpdatePassiveSkillsList()

        -- Trade skills
        elseif (filter == AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS) then
            AbilitiesWindow.UpdateTradeSkillsList()
        end
            
        AbilitiesWindow.totalPages = math.ceil (#AbilitiesWindow.GeneralLists[filter] / ITEMS_PER_PAGE)
        specialFilter = true
    end

    return specialFilter
end

local function GetAbilitySpecLine (ability)
    if( AbilitiesWindow.currentMode == AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES ) then
        return TacticsTypeText[ability.tacticType] or L""
    else
        return DataUtils.GetAbilitySpecLine (ability)
    end
end

-- This does not update the abilities list or filter at all; it just switches between pages.
function AbilitiesWindow.DisplayCurrentPage()
    -- iterate through the six ability display slots
    local list      = AbilitiesWindow.displayList
    local page      = AbilitiesWindow.currentPage  -- pages are 1-indexed
    local mode      = AbilitiesWindow.currentMode

    if (AbilitiesWindow.HandleSpecialDisplay() == false) then

        for i = FIRST_ITEM_INDEX, LAST_ITEM_INDEX do
            local abilityId = list[(page - FIRST_ITEM_INDEX) * ITEMS_PER_PAGE + i]
            local window    = "AbilitiesWindowAbilityEntry"..i.."Button"
            
            if (abilityId) then
            
                ability = GetAbilityData (abilityId)
                
                -- show/hide icons and frames
                WindowSetShowing(window.."SquareIconFrame", mode == AbilitiesWindow.Modes.MODE_ACTION_ABILITIES)
                WindowSetShowing(window.."SquareIcon", mode == AbilitiesWindow.Modes.MODE_ACTION_ABILITIES or mode == AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES)
                WindowSetShowing(window.."CircleIcon", mode == AbilitiesWindow.Modes.MODE_MORALE_ABILITIES)
                
                -- set icon image
                local texture, x, y = GetIconData( ability.iconNum )
                if(mode == AbilitiesWindow.Modes.MODE_ACTION_ABILITIES or mode == AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES) then
                    DynamicImageSetTexture (window.."SquareIcon", texture, x, y)
                elseif(mode == AbilitiesWindow.Modes.MODE_MORALE_ABILITIES) then
                    local winX, winY = WindowGetDimensions( window.."CircleIcon" )
                    CircleImageSetTexture (window.."CircleIcon", texture, x + winX/2, y + winY/2)
                end
                
                -- set text
                LabelSetText (window.."Desc", GetStringFormat(StringTables.Default.LABEL_ABILITIES_WINDOW_ABILITY_NAME_FORMAT, {ability.name}))
                LabelSetText (window.."DescPath", GetAbilitySpecLine (ability))
                
                local abilityTypeText = DataUtils.GetAbilityTypeText (ability)
                LabelSetText (window.."DescType", abilityTypeText)
                local _, _, _, r, g, b = DataUtils.GetAbilityTypeTextureAndColor(ability)
                
                LabelSetTextColor (window.."DescType", r, g, b)
                                
                WindowSetShowing (window.."DescType", not (mode == AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES))
                WindowSetShowing (window.."DescPath", true) -- in case previous mode hid this, e.g. player skills mode
				
				local abilityType = GetAbilityTypeFromMode( mode )
				Player.TintWindowIfAbilityIsBlocked( window, abilityId, abilityType )
            end

            WindowSetShowing(window, abilityId ~= nil)

        end 
    end
    
    AbilitiesWindow.UpdatePageButtons()
end

function AbilitiesWindow.HandleSpecialDisplay()
    local specialDisplay = false
    local mode           = AbilitiesWindow.currentMode
    local filter         = AbilitiesWindow.FilterTabSelected[mode]
    
    if(mode == AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES) then
        local list = AbilitiesWindow.GeneralLists[filter]
        local page = AbilitiesWindow.currentPage
            
        for i = FIRST_ITEM_INDEX, LAST_ITEM_INDEX do
            local data = list[(page - FIRST_ITEM_INDEX) * ITEMS_PER_PAGE + i]
            local window = "AbilitiesWindowAbilityEntry"..i.."Button"
            
            if (data) then
                WindowSetShowing(window.."SquareIconFrame", true)
                WindowSetShowing(window.."SquareIcon", true)
                WindowSetShowing(window.."CircleIcon", false)
                
                local texture, x, y = GetIconData(data.iconNum)
                DynamicImageSetTexture(window.."SquareIcon", texture, x, y)
                LabelSetText(window.."Desc", data.name)
                
                WindowSetShowing( window.."DescType", false)
                WindowSetShowing( window.."DescPath", false)
            end
            
            WindowSetShowing( window, data ~= nil)
        end
        
        specialDisplay = true
    end
    
    return specialDisplay
end

-- Update list of player skills to display; this needs to have a list rather than just update buttons like trade skills, since this section may be paginated.
function AbilitiesWindow.UpdatePassiveSkillsList()
    AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_SKILLS] = {}
    local skillData = GameData.Player.Skills
    local index = 1
    
    -- create a list of skill information, analogous to AbilitiesWindow.displayList.
    for id, hasSkill in pairs (skillData) do
        if hasSkill then
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_SKILLS][index] = {}
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_SKILLS][index].name    = SkillTypes[id].name
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_SKILLS][index].iconNum = SkillTypes[id].icon
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_SKILLS][index].skillID = id    -- this field is unique to passive skills

            index = index + 1
        end
    end
    
    WindowSetShowing( "AbilitiesWindowNoAbilitiesText", (#AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_SKILLS] == 0) )
end

-- helper function to determine if this renown passive should be displayed in the abilities window.
local function PlayerPurchasedStatPassive( data )
    
    -- Ensure that data is not nil, and that this ability has a category field.
    if (data == nil) or (data.category == nil) then
        return false
    end
    
    -- We want to exclude tactics from the passive renowns.
    if (data.numTacticSlots and data.numTacticSlots > 0) then
        return false
    end
    
    -- Return true if this has been purchased (for categories 9 to 15).
    if (data.category >= GameData.CareerCategory.RENOWN_STATS_A and data.category <= GameData.CareerCategory.RENOWN_REALM)
       and (data.timesPurchased and data.timesPurchased > 0)
    then
        return true
    end

end

-- Update list of renown passives to display; note that this list contains abilities from 
-- categories 9 to 11, and categories 12 to 14, which have slightly different data. 
-- (see wh_consts::ECareerAdvanceCategory)
function AbilitiesWindow.UpdatePassiveAbilitiesList()
    AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES] = {}
    local index       = 1

    -- For career categories 9 to 15 (see wh_consts::ECareerAdvanceCategory):
    local advanceList = GameData.Player.GetAdvanceData()
    
    for _, data in pairs(advanceList) do
        if (data and (PlayerPurchasedStatPassive(data))) then
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES][index] = {}
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES][index].name = data.advanceName
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES][index].iconNum = data.advanceIcon or data.iconNum
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES][index].advanceID = data.advanceID
            index = index + 1
        end
    end
    
    -- For categories 9 to 15 (see wh_consts::ECareerAdvanceCategory)
    local passiveList = GetAbilityTable( GameData.AbilityType.PASSIVE )
    
    for id, data in pairs(passiveList) do
        if (id) then -- here!
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES][index] = {}
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES][index].name    = data.name
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES][index].iconNum = data.iconNum
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES][index].id      = id                -- to differentiate from the other kind of renown passive, above
            index = index + 1
        end
    end
    
    table.sort( AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES], OrderAbilities )
    WindowSetShowing("AbilitiesWindowNoAbilitiesText", (#AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES] == 0) ) 
end

-- just for the "All" tab...
function AbilitiesWindow.UpdateTradeSkillsList()
    AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS] = {}
    index = 1
    
    for tradeSkill = AbilitiesWindow.FirstTradeSkill, AbilitiesWindow.MaxTradeSkill do
        if (GameData.TradeSkillLevels[tradeSkill] ~= nil) and (GameData.TradeSkillLevels[tradeSkill] > 0) then
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS][index] = {}
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS][index].name         = AbilitiesWindow.TradeSkillLabels[tradeSkill]
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS][index].iconNum      = GetTradeskillIcon (tradeSkill)
            AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS][index].tradeSkillId = tradeSkill -- enum value from ETradeSkills; the presence of this field is unique to trade skills (useful for the General mode > All tab...)
            
            index = index + 1
        end
    end
    
    WindowSetShowing("AbilitiesWindowNoAbilitiesText", (#AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS] == 0) ) 
end

-- updates Passive Abilities, Passive Skills, and Trade Skills, then combines them into one updated list.
-- It would be nicer to have the update functions take in a list as a parameter, and add to that...
function AbilitiesWindow.UpdateGeneralList()
    
    -- update data from all three General categories
    AbilitiesWindow.UpdatePassiveAbilitiesList()
    AbilitiesWindow.UpdatePassiveSkillsList()
    AbilitiesWindow.UpdateTradeSkillsList()
    
    AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_ALL] = {}
    
    local index = 1
    
    for _, data in pairs (AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES]) do
        AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_ALL][index] = data
        index = index + 1
    end

    for _, data in pairs (AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_SKILLS]) do
        AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_ALL][index] = data
        index = index + 1
    end
    
    for _, data in pairs (AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS]) do
        AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_ALL][index] = data
        index = index + 1
    end
    
    table.sort( AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_ALL], OrderAbilities )
    WindowSetShowing("AbilitiesWindowNoAbilitiesText", (#AbilitiesWindow.GeneralLists[AbilitiesWindow.GeneralTabs.FILTER_ALL] == 0) ) 
   
end

----------------------------------------------------------------
-- Filter functions and Filter Tab data table
----------------------------------------------------------------

-- Ability sub-filters:  We can already assume that abilityData.abilityType is what it should be.

function AbilitiesWindow.SubFilterAll(abilityData)
    return true
end

function AbilitiesWindow.SubFilterCore(abilityData)
    return (abilityData and abilityData.specialization and (abilityData.specialization == 0))
end

function AbilitiesWindow.SubFilterPath1(abilityData)
    return (abilityData and abilityData.specialization and (abilityData.specialization == 1))
end

function AbilitiesWindow.SubFilterPath2(abilityData)
    return (abilityData and abilityData.specialization and (abilityData.specialization == 2))
end

function AbilitiesWindow.SubFilterPath3(abilityData)
    return (abilityData and abilityData.specialization and (abilityData.specialization == 3))
end

function AbilitiesWindow.SubFilterRenown(abilityData)
    return (abilityData and abilityData.minimumRenown and (abilityData.minimumRenown > 0))
end

-- Tactic-specific ability filters:

function AbilitiesWindow.SubFilterCareerTactic(abilityData)
    return (abilityData and abilityData.tacticType and (abilityData.tacticType == 0))
end

function AbilitiesWindow.SubFilterRenownTactic(abilityData)
    return (abilityData and abilityData.tacticType and (abilityData.tacticType == 1))
end

function AbilitiesWindow.SubFilterTomeTacitc(abilityData)
    return (abilityData and abilityData.tacticType and (abilityData.tacticType == 2))
end

-- special filter for General mode > Trade Skills tab and General mode > Passive Skills tab, which acquire their data differently.

function AbilitiesWindow.SubFilterNone(abilityData)
    return false
end

AbilitiesWindow.FilterData =
{
    [AbilitiesWindow.Modes.MODE_ACTION_ABILITIES] =
    {
        [1] = {filter = AbilitiesWindow.SubFilterAll,    textureSlice = "Tab-ALL",                  tooltip = GetString (StringTables.Default.LABEL_ALL)},
        [2] = {filter = AbilitiesWindow.SubFilterCore,   textureSlice = "Tab-Core",                 tooltip = GetString (StringTables.Default.TACTIC_TYPE_CAREER)},
        [3] = {filter = AbilitiesWindow.SubFilterPath1,  textureSlice = "Tab-Disciple1-Dark-Rites", tooltip = L""}, -- populated in AbilitiesWindow.PopulateDynamicFields()
        [4] = {filter = AbilitiesWindow.SubFilterPath2,  textureSlice = "Tab-Disciple2-Torture",    tooltip = L""}, -- populated in AbilitiesWindow.PopulateDynamicFields()
        [5] = {filter = AbilitiesWindow.SubFilterPath3,  textureSlice = "Tab-Disciple3-Sacrifice",  tooltip = L""}, -- populated in AbilitiesWindow.PopulateDynamicFields()
        [6] = {filter = AbilitiesWindow.SubFilterRenown, textureSlice = "Tab-RvR",                  tooltip = GetString (StringTables.Default.LABEL_RENOWN)}
    },
    [AbilitiesWindow.Modes.MODE_MORALE_ABILITIES] =
    {
        [1] = {filter = AbilitiesWindow.SubFilterAll,    textureSlice = "Tab-ALL",                  tooltip = GetString (StringTables.Default.LABEL_ALL)},
        [2] = {filter = AbilitiesWindow.SubFilterCore,   textureSlice = "Tab-Core",                 tooltip = GetString (StringTables.Default.TACTIC_TYPE_CAREER)},
        [3] = {filter = AbilitiesWindow.SubFilterPath1,  textureSlice = "Tab-Disciple1-Dark-Rites", tooltip = L""}, -- populated in AbilitiesWindow.PopulateDynamicFields()
        [4] = {filter = AbilitiesWindow.SubFilterPath2,  textureSlice = "Tab-Disciple2-Torture",    tooltip = L""}, -- populated in AbilitiesWindow.PopulateDynamicFields()
        [5] = {filter = AbilitiesWindow.SubFilterPath3,  textureSlice = "Tab-Disciple3-Sacrifice",  tooltip = L""}, -- populated in AbilitiesWindow.PopulateDynamicFields()
    },
    [AbilitiesWindow.Modes.MODE_TACTIC_ABILITIES] =
    {
        [1] = {filter = AbilitiesWindow.SubFilterAll,          textureSlice = "Tab-ALL",                  tooltip = GetString (StringTables.Default.LABEL_ALL)},
        [2] = {filter = AbilitiesWindow.SubFilterCareerTactic, textureSlice = "Tab-Core",                 tooltip = GetString (StringTables.Default.TACTIC_TYPE_CAREER)},
        [3] = {filter = AbilitiesWindow.SubFilterPath1,        textureSlice = "Tab-Disciple1-Dark-Rites", tooltip = L""}, -- populated in AbilitiesWindow.PopulateDynamicFields()
        [4] = {filter = AbilitiesWindow.SubFilterPath2,        textureSlice = "Tab-Disciple2-Torture",    tooltip = L""}, -- populated in AbilitiesWindow.PopulateDynamicFields()
        [5] = {filter = AbilitiesWindow.SubFilterPath3,        textureSlice = "Tab-Disciple3-Sacrifice",  tooltip = L""}, -- populated in AbilitiesWindow.PopulateDynamicFields()
        [6] = {filter = AbilitiesWindow.SubFilterRenownTactic, textureSlice = "Tab-RvR",                  tooltip = GetString (StringTables.Default.TACTIC_TYPE_RENOWN)},
        [7] = {filter = AbilitiesWindow.SubFilterTomeTacitc,   textureSlice = "Tab-Tome",                 tooltip = GetString (StringTables.Default.TACTIC_TYPE_TOME)}
    },
    [AbilitiesWindow.Modes.MODE_GENERAL_ABILITIES] =
    {
        [AbilitiesWindow.GeneralTabs.FILTER_ALL]               = {filter = AbilitiesWindow.SubFilterAll,  textureSlice = "Tab-ALL",              tooltip = GetString( StringTables.Default.LABEL_ALL )},
        [AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_ABILITIES] = {filter = AbilitiesWindow.SubFilterAll,  textureSlice = "Tab-PassiveAbilities", tooltip = GetString( StringTables.Default.LABEL_PASSIVE_ABILITIES )},
        [AbilitiesWindow.GeneralTabs.FILTER_PASSIVE_SKILLS]    = {filter = AbilitiesWindow.SubFilterNone, textureSlice = "Tab-PassiveSkills",    tooltip = GetString (StringTables.Default.LABEL_PASSIVE_SKILLS)},
        [AbilitiesWindow.GeneralTabs.FILTER_TRADE_SKILLS]      = {filter = AbilitiesWindow.SubFilterNone, textureSlice = "Tab-Crafting",         tooltip = GetString (StringTables.Default.LABEL_TRADE_SKILLS)}
    }
}

