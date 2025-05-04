GuildWindowTabRecruit = {}

--------------------------------------------------------------------------------------
-- Definitions
--------------------------------------------------------------------------------------

-- RecruitingStatus
local function RecruitStatus( inFlagId, inStringId, inSearchOnly )
    return { flagId=inFlagId, name=GetGuildString( inStringId ), searchOnly=inSearchOnly }
end

GuildWindowTabRecruit.RecruitingStatus = 
{
    RecruitStatus( GameData.Recruitment.RecruitingFlag.ACCEPTING_APPLICATIONS,  StringTables.Guild.LABEL_RECRUIT_PROFILE_STATUS_NEW_MEMBERS,   false ),
    RecruitStatus( GameData.Recruitment.RecruitingFlag.ADD_TO_ALLIANCE,         StringTables.Guild.LABEL_RECRUIT_PROFILE_STATUS_NEW_ALLIANCE,  false ),
    RecruitStatus( GameData.Recruitment.RecruitingFlag.FORM_NEW_ALLIANCE,       StringTables.Guild.LABEL_RECRUIT_PROFILE_STATUS_FORM_ALLIANCE, false ),
    RecruitStatus( GameData.Recruitment.RecruitingFlag.ALL,                     StringTables.Guild.LABEL_RECRUIT_PROFILE_STATUS_ALL,           true ),
}


-- PlayStyles
local function RecruitPlayStyle( inPlayStyleId, inStringId )
    return { flagId=inPlayStyleId, name=GetGuildString( inStringId ) }
end

GuildWindowTabRecruit.PlayStyles = 
{
    RecruitPlayStyle( GameData.Recruitment.PlayStyleFlag.NON_SPECIFIC,  StringTables.Guild.LABEL_RECRUIT_PLAY_STYLE_NONSPECIFIC ),
    RecruitPlayStyle( GameData.Recruitment.PlayStyleFlag.RVR,           StringTables.Guild.LABEL_RECRUIT_PLAY_STYLE_RVR ),
    RecruitPlayStyle( GameData.Recruitment.PlayStyleFlag.CASUAL,        StringTables.Guild.LABEL_RECRUIT_PLAY_STYLE_CASUAL ),
    RecruitPlayStyle( GameData.Recruitment.PlayStyleFlag.ROLEPLAY,      StringTables.Guild.LABEL_RECRUIT_PLAY_STYLE_ROLEPLAY ),
    RecruitPlayStyle( GameData.Recruitment.PlayStyleFlag.HARDCORE,      StringTables.Guild.LABEL_RECRUIT_PLAY_STYLE_HARDCORE ),
}


-- Atmosphere
local function RecruitAtmosphere( inFlagId, inStringId )
    return { flagId=inFlagId, name=GetGuildString( inStringId ) }
end

GuildWindowTabRecruit.Atmosphere = 
{
    RecruitAtmosphere( GameData.Recruitment.AtmosphereFlag.NON_SPECIFIC,    StringTables.Guild.LABEL_RECRUIT_ATMOSPHERE_NONSPECIFIC ),
    RecruitAtmosphere( GameData.Recruitment.AtmosphereFlag.CHATTY,          StringTables.Guild.LABEL_RECRUIT_ATMOSPHERE_CHATTY ),
    RecruitAtmosphere( GameData.Recruitment.AtmosphereFlag.ROLEPLAY,        StringTables.Guild.LABEL_RECRUIT_ATMOSPHERE_ROLEPLAY ),
    RecruitAtmosphere( GameData.Recruitment.AtmosphereFlag.FAMILY,          StringTables.Guild.LABEL_RECRUIT_ATMOSPHERE_FAMILY),
    RecruitAtmosphere( GameData.Recruitment.AtmosphereFlag.MATURE,          StringTables.Guild.LABEL_RECRUIT_ATMOSPHERE_MATURE ),
}

-- Careers

local function RecruitCareer( inFlagId, inCareerLineId )
    return { flagId=inFlagId, careerLineId=inCareerLineId, name=GetCareerLine(inCareerLineId) }
end

GuildWindowTabRecruit.OrderCareers = 
{
    RecruitCareer( GameData.Recruitment.CareerFlags.IRON_BREAKER,   GameData.CareerLine.IRON_BREAKER ),
    RecruitCareer( GameData.Recruitment.CareerFlags.RUNE_PRIEST,    GameData.CareerLine.RUNE_PRIEST ),
    RecruitCareer( GameData.Recruitment.CareerFlags.ENGINEER,       GameData.CareerLine.ENGINEER ),
    RecruitCareer( GameData.Recruitment.CareerFlags.SLAYER,         GameData.CareerLine.SLAYER ),
    RecruitCareer( GameData.Recruitment.CareerFlags.WITCH_HUNTER,   GameData.CareerLine.WITCH_HUNTER ),
    RecruitCareer( GameData.Recruitment.CareerFlags.KNIGHT,         GameData.CareerLine.KNIGHT ),
    RecruitCareer( GameData.Recruitment.CareerFlags.BRIGHT_WIZARD,  GameData.CareerLine.BRIGHT_WIZARD ),
    RecruitCareer( GameData.Recruitment.CareerFlags.WARRIOR_PRIEST, GameData.CareerLine.WARRIOR_PRIEST ),
    RecruitCareer( GameData.Recruitment.CareerFlags.SWORDMASTER,    GameData.CareerLine.SWORDMASTER ),
    RecruitCareer( GameData.Recruitment.CareerFlags.SHADOW_WARRIOR, GameData.CareerLine.SHADOW_WARRIOR ),
    RecruitCareer( GameData.Recruitment.CareerFlags.WHITE_LION,     GameData.CareerLine.WHITE_LION ),
    RecruitCareer( GameData.Recruitment.CareerFlags.ARCHMAGE,       GameData.CareerLine.ARCHMAGE ),
}

GuildWindowTabRecruit.DestructionCareers = 
{
    RecruitCareer( GameData.Recruitment.CareerFlags.BLACK_ORC,      GameData.CareerLine.BLACK_ORC ),
    RecruitCareer( GameData.Recruitment.CareerFlags.SHAMAN,         GameData.CareerLine.SHAMAN ),
    RecruitCareer( GameData.Recruitment.CareerFlags.SQUIG_HERDER,   GameData.CareerLine.SQUIG_HERDER ),
    RecruitCareer( GameData.Recruitment.CareerFlags.CHOPPA,         GameData.CareerLine.CHOPPA ),
    RecruitCareer( GameData.Recruitment.CareerFlags.CHOSEN,         GameData.CareerLine.CHOSEN ),
    RecruitCareer( GameData.Recruitment.CareerFlags.MARAUDER,       GameData.CareerLine.MARAUDER ),
    RecruitCareer( GameData.Recruitment.CareerFlags.ZEALOT,         GameData.CareerLine.ZEALOT ),
    RecruitCareer( GameData.Recruitment.CareerFlags.MAGUS,          GameData.CareerLine.MAGUS ),
    RecruitCareer( GameData.Recruitment.CareerFlags.BLACKGUARD,     GameData.CareerLine.BLACKGUARD ),
    RecruitCareer( GameData.Recruitment.CareerFlags.WITCH_ELF,      GameData.CareerLine.WITCH_ELF ),
    RecruitCareer( GameData.Recruitment.CareerFlags.DISCIPLE,       GameData.CareerLine.DISCIPLE ),
    RecruitCareer( GameData.Recruitment.CareerFlags.SORCERER,       GameData.CareerLine.SORCERER ),
}

-- Tiers
local function RecruitTier( inTierFlag, inTierId, inMinRank, inMaxRank )
    return 
    { 
    
    flagId=inTierFlag, 
    tierId=inTierId, 
    minRank=inMinRank, 
    maxRank=inMaxRank, 
    
    name = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.TEXT_RECRUIT_TIER, { L""..inTierId,
                                                                                             L""..inMinRank,
                                                                                             L""..inMaxRank 
                                                                                           } )
   }
end

GuildWindowTabRecruit.TiersNeeded = 
{
    RecruitTier( GameData.Recruitment.TierFlag.TIER_1, 1, 1, 11 ),
    RecruitTier( GameData.Recruitment.TierFlag.TIER_2, 2, 12, 21 ),
    RecruitTier( GameData.Recruitment.TierFlag.TIER_3, 3, 22, 31 ),
    RecruitTier( GameData.Recruitment.TierFlag.TIER_4, 4, 32, 40 ),
}


-- Interests
local function RecruitInterest( inFlagId, inStringId )
    return { flagId=inFlagId, name=GetGuildString( inStringId ) }
end

GuildWindowTabRecruit.Interests = 
{
    RecruitInterest( GameData.Recruitment.InterestFlag.QUESTS,          StringTables.Guild.LABEL_RECRUIT_INTEREST_QUESTS ),
    RecruitInterest( GameData.Recruitment.InterestFlag.RVR,             StringTables.Guild.LABEL_RECRUIT_INTEREST_RVR ),
    RecruitInterest( GameData.Recruitment.InterestFlag.PUBLICQUESTS,    StringTables.Guild.LABEL_RECRUIT_INTEREST_PUBLIC_QUESTS ),
    RecruitInterest( GameData.Recruitment.InterestFlag.ROLEPLAY,        StringTables.Guild.LABEL_RECRUIT_INTEREST_ROLEPLAY ),
    RecruitInterest( GameData.Recruitment.InterestFlag.RAIDING,         StringTables.Guild.LABEL_RECRUIT_INTEREST_RAIDING ),
    RecruitInterest( GameData.Recruitment.InterestFlag.SCENARIO,        StringTables.Guild.LABEL_RECRUIT_INTEREST_SCENARIOS ),
}



-- Tiers
local function SearchLimit( inFlagId, value )

    local text = L""
    if( value == 0 )
    then
        text = GetGuildString( StringTables.Guild.LABEL_RECRUIT_SEARCH_LIMIT_ANY )
    else
        text = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.LABEL_RECRUIT_SEARCH_LIMIT_GREATER_THAN_X, {L""..value} )
    end

    return { flagId=inFlagId, limit=value, name=text }
end

GuildWindowTabRecruit.TotalPlayersSearch = 
{
    SearchLimit( 0, 0 ),
    SearchLimit( 1, 50 ),
    SearchLimit( 2, 100 ),
    SearchLimit( 3, 200 ),
    SearchLimit( 4, 300 ),
    SearchLimit( 5, 400 ),
}

GuildWindowTabRecruit.OnlinePlayersSearch = 
{
    SearchLimit( 0, 0 ),
    SearchLimit( 1, 10 ),
    SearchLimit( 2, 25 ),
    SearchLimit( 3, 50 ),
    SearchLimit( 4, 100 ),
    SearchLimit( 5, 200 ),
}

GuildWindowTabRecruit.GuildRankSearch = 
{
    SearchLimit( 0, 0 ),
    SearchLimit( 1, 5 ),
    SearchLimit( 2, 10 ),
    SearchLimit( 3, 15 ),
    SearchLimit( 4, 20 ),
    SearchLimit( 5, 30 ),
}

function GuildWindowTabRecruit.InitCombBox( comboBoxName, itemsTable )

    for _, itemData in ipairs( itemsTable )
    do
        ComboBoxAddMenuItem( comboBoxName, itemData.name )
    end
    
    ComboBoxSetSelectedMenuItem( comboBoxName, 1 )

end

local function RecruitTab( inWindowName, inTabName, inStringId, inShowNoGuild, inShowInGuild )
    return { windowName=inWindowName, tabName=inTabName, stringId=inStringId, showNoGuild=inShowNoGuild, showInGuild=inShowInGuild }
end


-- Data for the Bottom Tabs
GuildWindowTabRecruit.TAB_PROFILE = 1
GuildWindowTabRecruit.TAB_SEARCH  = 2
GuildWindowTabRecruit.TAB_FORM    = 3

GuildWindowTabRecruit.BottomTabs = 
{
    [GuildWindowTabRecruit.TAB_PROFILE] = RecruitTab( "GWRecruitProfile", "GWRecruitTabProfile",    StringTables.Guild.LABEL_RECRUIT_TAB_PROFILE,   false,  true ) ,
    [GuildWindowTabRecruit.TAB_SEARCH]  = RecruitTab( "GWRecruitSearch",  "GWRecruitTabSearch",     StringTables.Guild.LABEL_RECRUIT_TAB_SEARCH,    true,   true  ) ,    
    [GuildWindowTabRecruit.TAB_FORM]    = RecruitTab( "GWRecruitForm",    "GWRecruitTabForm",       StringTables.Guild.LABEL_RECRUIT_TAB_FORM,      true,   false  ) ,
}


--------------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------------

GuildWindowTabRecruit.Settings = 
{
    selectedBottomTab = GuildWindowTabRecruit.TAB_PROFILE,
}


--------------------------------------------------------------------------------------
-- General Recruit Tab Functions
--------------------------------------------------------------------------------------

function GuildWindowTabRecruit.Initialize()

    for id, data in pairs( GuildWindowTabRecruit.BottomTabs )
    do
        ButtonSetText( data.tabName, GetGuildString( data.stringId ) )
    end

        
    GuildWindowTabRecruit.InitializeProfile()
    GuildWindowTabRecruit.InitializeSearch()	
    GuildWindowTabRecruit.InitializeForm()
        
    GuildWindowTabRecruit.SelectBottomTab( GuildWindowTabRecruit.Settings.selectedBottomTab )
    
end

function GuildWindowTabRecruit.UpdatePermissions()
    GuildWindowTabRecruit.Profile.UpdatePermissions()
end


function GuildWindowTabRecruit.OnBottomTab()
    
    local tabId = WindowGetId( SystemData.ActiveWindow.name )
    GuildWindowTabRecruit.SelectBottomTab( tabId )
end

function GuildWindowTabRecruit.SelectBottomTab( tabId )
    
    GuildWindowTabRecruit.Settings.selectedBottomTab = tabId
    
    for id, data in pairs( GuildWindowTabRecruit.BottomTabs )
    do
        WindowSetShowing( data.windowName, id == tabId )
        ButtonSetStayDownFlag( data.tabName, id == tabId )
        ButtonSetPressedFlag( data.tabName, id == tabId )
    end
end


function GuildWindowTabRecruit.SetInGuild( inGuild )

    -- Show the approproate Tabs if the Player is Guilded or Unguilded.
    for id, data in pairs( GuildWindowTabRecruit.BottomTabs )
    do
        local show = (inGuild and data.showInGuild) or (not inGuild and data.showNoGuild)
        WindowSetShowing( data.tabName, show )
    end

   
    -- Update the Search Tab when not in a guild.
    WindowSetShowing("GWRecruitSearchNotInGuild", not inGuild )
    
    -- When not in a guild, only allow Player Searches
    ComboBoxSetSelectedMenuItem( "GWRecruitSearchSearchTypeCombo", 1 )    
    WindowSetShowing("GWRecruitSearchSearchTypeTitle", inGuild )
    WindowSetShowing("GWRecruitSearchSearchTypeCombo", inGuild )
      
    if( inGuild )
    then
        if( GuildWindowTabRecruit.Settings.selectedBottomTab == GuildWindowTabRecruit.TAB_FORM )
        then
            GuildWindowTabRecruit.SelectBottomTab( GuildWindowTabRecruit.TAB_PROFILE )
        else
            GuildWindowTabRecruit.SelectBottomTab( GuildWindowTabRecruit.Settings.selectedBottomTab )
        end
    else
        -- Force the Window to the Search Screen if not in guild    
        GuildWindowTabRecruit.SelectBottomTab( GuildWindowTabRecruit.TAB_SEARCH )
        -- Also automatically do a search for a guild
        GuildWindowTabRecruit.SearchForGuilds()
    end
    
     GuildWindowTabRecruit.UpdateGuildFormInstructions()
end



----------------------------------------------------------------------------------------
-- Form a Guild Tab - This just displays information and is otherwise non-interactive.
----------------------------------------------------------------------------------------

local function GuildFormInstruction( inOrderStringId, inDestructionStringId )
    return { orderStringId=inOrderStringId, destructionStringId=inDestructionStringId }
    
end

local guildFormInstructions =
{
    GuildFormInstruction( StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_1,         StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_1 ),
    GuildFormInstruction( StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_2_ORDER,   StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_2_DESTRUCTION ),
    GuildFormInstruction( StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_3_ORDER,   StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_3_DESTRUCTION ),
    GuildFormInstruction( StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_4,         StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_4 ),
    GuildFormInstruction( StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_5,         StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_5 ),
    GuildFormInstruction( StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_6,         StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_6 ),
    GuildFormInstruction( StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_7,         StringTables.Guild.TEXT_HOW_TO_FORM_GUILD_LINE_7 ),
}

function GuildWindowTabRecruit.InitializeForm()
           
    LabelSetText("GWRecruitFormGuildDesc", GetGuildString( StringTables.Guild.TEXT_RECRUIT_FORM_GUILD_DESC ) )
    LabelSetText("GWRecruitFormInstructionsTitle", GetGuildString( StringTables.Guild.LABEL_HOW_TO_FOR_A_GUILD_TITLE ) )        

    -- Initialize the Instructions
        
    local parentWindow = "GWRecruitForm"
    local anchorWindow = "GWRecruitFormInstructionsTitle"
    
    for index, data in ipairs(guildFormInstructions)
    do        
        local windowName = parentWindow.."Instruction"..index
        
        CreateWindowFromTemplate( windowName, "GuildFormInstructionTemplate", parentWindow )
        
        WindowAddAnchor( windowName, "bottomleft", anchorWindow, "topleft", 0, 0 )
        anchorWindow = windowName       
                
                
        local color = DefaultColor.GetRowColor( index )			
        DefaultColor.SetWindowTint( windowName.."Background",  color )
    end  


end

function GuildWindowTabRecruit.UpdateGuildFormInstructions()

    -- Set the Instructions Text for the Player's current Realm
        
    local parentWindow = "GWRecruitForm"
    local anchorWindow = "GWRecruitFormInstructionsTitle"
    
    for index, data in ipairs(guildFormInstructions)
    do        
        local windowName = parentWindow.."Instruction"..index        
        
        local stringId = data.orderStringId        
        if( GameData.Player.realm == GameData.Realm.DESTRUCTION )
        then
            stringId = data.destructionStringId        
        end
        
        LabelSetText( windowName.."Text", GetGuildString( stringId ) )            
    end  

end
