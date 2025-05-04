
FriendSuggester = {}
FriendSuggester.Data = {}

-- registered functions for update callbacks
local callbackFunctions = {}

local REASONS = {
    PARTY       = 1,
    WARBAND     = 2,
    SCENARIO    = 3,
    WHISPER     = 4,
    FRIENDED    = 5,
}

local SCALARS = {
    [REASONS.PARTY]     = 10,
    [REASONS.WARBAND]   = 5,
    [REASONS.SCENARIO]  = 5,
    [REASONS.WHISPER]   = 3.5,
    [REASONS.FRIENDED]  = 15,
}

-- how old data can get before purging a player
local purgeTime = 60 * 60 * 24 * 5

-- how often to pulse again for group data (so grouping with someone for a long
-- time counts more than grouping for 2 seconds)
-- this MUST be larger than lockoutTime below!
local pulseTime = 60 * 30

-- only allow a single player/reason combination once every 5 minutes or so
local lockoutTime = 60 * 10
-- define "lockout groups" such that a suggestion for one reason within a group
-- prevents any other reason within the group from being triggered until the
-- lockout timer is up
local LOCKOUT_GROUPS = {
    { [REASONS.PARTY] = true, [REASONS.WARBAND] = true, [REASONS.SCENARIO] = true },
}

local function Suggest( name, reason )
    name = wstring.gsub( name, L"(^.)", L"" )
    if not SocialWindow
        or SocialWindow.IsPlayerOnFriendsList( name )
        or SocialWindow.IsPlayerOnIgnoreList( name )
        or WStringsCompareIgnoreGrammer( GameData.Player.name, name ) == 0
    then
        if SocialWindow
        then
            -- Should not be suggesting this person if we were. Stop suggesting someone if they've become a friend or were ignored 
            FriendSuggester.Data[ name ] = nil
        end
        return false
    end
    
    if not FriendSuggester.Data[ name ]
    then
        FriendSuggester.Data[ name ] = {}
    end
    local friendData = FriendSuggester.Data[ name ]
    
    local function GetLastSuggestTime()
        if not friendData.lockouts
        then
            friendData.lockouts = {}
        end
        return friendData.lockouts[ reason ] or 0
    end
    
    local time = GetEpochTime()
    if time - GetLastSuggestTime() < lockoutTime
    then
        return false
    end
    for _, lockoutGroup in ipairs( LOCKOUT_GROUPS )
    do
        if not lockoutGroup[ reason ]
        then
            continue
        end
        for lockoutId, _ in pairs( lockoutGroup )
        do
            friendData.lockouts[ lockoutId ] = time
        end
    end
    friendData.lockouts[ reason ] = time
    
    local currentValue = friendData.value or 0
    friendData.value = currentValue + SCALARS[ reason ]
    
    return true
end

local function RunCallbacks()
    for _, func in ipairs( callbackFunctions )
    do
        local result, err = pcall( func )
        if not result
        then
            ERROR( towstring( err ) )
        end
    end
end

function FriendSuggester.Initialize()
    RegisterEventHandler( SystemData.Events.GROUP_UPDATED, "FriendSuggester.OnPartyUpdated" )
    RegisterEventHandler( SystemData.Events.BATTLEGROUP_UPDATED, "FriendSuggester.OnWarbandUpdated" )
    RegisterEventHandler( SystemData.Events.SCENARIO_POST_MODE, "FriendSuggester.ScenarioFinish" )
    RegisterEventHandler( SystemData.Events.CHAT_TEXT_ARRIVED, "FriendSuggester.OnChatText" )
    RegisterEventHandler( SystemData.Events.SOCIAL_YOU_HAVE_BEEN_FRIENDED, "FriendSuggester.OnYouHaveBeenFriended" )

    -- purge old data
    local playersToPurge = {}
    local now = GetEpochTime()
    for name, data in pairs( FriendSuggester.Data )
    do
        local mostRecentTime = 0
        for reason, time in pairs( data.lockouts )
        do
            if time > mostRecentTime
            then
                mostRecentTime = time
            end
        end
        if now - mostRecentTime > purgeTime
        then
            table.insert( playersToPurge, name )
        end
    end
    for _, name in ipairs( playersToPurge )
    do
        FriendSuggester.Data[ name ] = nil
    end
end

function FriendSuggester.RegisterCallback( func )
    table.insert( callbackFunctions, func )
end

local timer = 0
function FriendSuggester.Update( dt )
    timer = timer + dt
    if timer >= pulseTime
    then
        timer = 0
        FriendSuggester.OnPartyUpdated()
        FriendSuggester.OnWarbandUpdated()
    end
end

function FriendSuggester.OnPartyUpdated()
    local dataChanged = false
    local party = PartyUtils.GetPartyData()
    for index, member in ipairs( party )
    do
        if PartyUtils.IsPartyMemberValid( index )
        then
            dataChanged = Suggest( member.name, REASONS.PARTY ) or dataChanged
        end
    end
    
    if dataChanged
    then
        RunCallbacks()
    end
end

function FriendSuggester.OnWarbandUpdated()
    local dataChanged = false
    local warband = PartyUtils.GetWarbandData()
    for partyIndex, party in ipairs( warband )
    do
        for memberIndex, member in ipairs( party.players )
        do
            dataChanged = Suggest( member.name, REASONS.WARBAND ) or dataChanged
        end
    end
    
    if dataChanged
    then
        RunCallbacks()
    end
end

function FriendSuggester.ScenarioFinish()
    if not ScenarioSummaryWindow or not ScenarioSummaryWindow.playersData
    then
        return
    end
    local dataChanged = false
    for _, player in ipairs( ScenarioSummaryWindow.playersData )
    do
        if( player.realm == GameData.Player.realm )
        then
            dataChanged = Suggest( player.name, REASONS.SCENARIO ) or dataChanged
        end
    end
    
    if dataChanged
    then
        RunCallbacks()
    end
end

function FriendSuggester.OnChatText()
    local dataChanged = false
    if GameData.ChatData.type == SystemData.ChatLogFilters.TELL_SEND
    then
        dataChanged = Suggest( GameData.ChatData.name, REASONS.WHISPER )
    end
    
    if dataChanged
    then
        RunCallbacks()
    end
end

function FriendSuggester.HasDataForPlayer( name )
    name = wstring.gsub( name, L"(^.)", L"" )
    return (FriendSuggester.Data[ name ] ~= nil)
end

function FriendSuggester.OnFriendAdded( name )
    name = wstring.gsub( name, L"(^.)", L"" )
    FriendSuggester.Data[ name ] = nil
end

function FriendSuggester.OnYouHaveBeenFriended(name)
    if( name == nil)
    then 
        return
    end
    
    local dataChanged = Suggest( name, REASONS.FRIENDED )
    
    if( dataChanged )
    then
        RunCallbacks()
    end
end