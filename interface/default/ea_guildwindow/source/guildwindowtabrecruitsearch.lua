

-- Placeholder Data
--[[
local testSearchResults = {}

for index=1, 20 
do
    testSearchResults[ index ] = {}
    testSearchResults[ index ].name             = L"Test Guild #"..index
    testSearchResults[ index ].desc             = L"Test Description "..index
    testSearchResults[ index ].guildLeader      = L"GuildLeader"..index
    testSearchResults[ index ].summary          = L"Test Summary "..index..L"Test Summary "..index..L"Test Summary "..index..L"Test Summary "..index..L"Test Summary "..index..L"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum sed lorem. Mauris luctus. Proin consequat scelerisque lectus. Aenean tincidunt vestibulum urna. Proin pretium mauris ac mi porttitor dignissim. Nulla commodo lobortis odio. Fusce nibh eros, venenatis sed, interdum vitae, pulvinar vitae, pede. Phasellus aliquam bibendum metus. Vivamus consequat, sem quis. "
    testSearchResults[ index ].rank             = math.random( 1, 40 )   
    testSearchResults[ index ].playersTotal     = math.random( 1, 500 )
    testSearchResults[ index ].playersOnline    = math.random( 0, testSearchResults[ index ].playersTotal )

    testSearchResults[ index ].playStyle        = math.random( 1, 6)
    testSearchResults[ index ].atmosphere       = math.random( 1, 4 )

    testSearchResults[ index ].careersNeeded = {}
    for _, data in ipairs(GuildWindowTabRecruit.OrderCareers)
    do               
        testSearchResults[ index ].careersNeeded[ data.flagId ] = math.random(1, 2) == 1  
    end  
    
    testSearchResults[ index ].tiersNeeded = {}
    for _, data in ipairs(GuildWindowTabRecruit.TiersNeeded)
    do               
        testSearchResults[ index ].tiersNeeded[ data.flagId ] = math.random(1, 2) == 1  
    end     
    
    testSearchResults[ index ].interests = {}
    for _, data in ipairs(GuildWindowTabRecruit.Interests)
    do               
        testSearchResults[ index ].interests[ data.flagId ] = math.random(1, 2) == 1  
    end 
    
     testSearchResults[ index ].recruiters = {}
     for index2 = 1, 3
     do
        testSearchResults[ index ].recruiters[ index2 ] = { name=L"Recruiter"..index }
     end

end
--]]

function NewGuildSortData( param_label, param_tooltipString )
    return { windowName=param_label, tooltipStringId=param_tooltipString }
end

-- Search Tab Data

GuildWindowTabRecruit.Search =
{
    waitingForSearchResults = false,    
    
    guildProfiles = {},
    displayOrder = {},
    selectedProfile = nil,
            
    -- Sorting Rules
    
    SORT_ORDER_UP	   = 1,
    SORT_ORDER_DOWN	   = 2,

    GUILD_SORTBY_RANK             = 1,
    GUILD_SORTBY_NAME             = 2,
    GUILD_SORTBY_PLAYERS_ONLINE   = 3,
    GUILD_SORTBY_PLAYERS_TOTAL    = 4,
    
    sortData =
    {
        NewGuildSortData( "GWRecruitSearchSortButton1", StringTables.Guild.TEXT_RECRUIT_SEARCH_SORTBY_RANK ),
        NewGuildSortData( "GWRecruitSearchSortButton2", StringTables.Guild.TEXT_RECRUIT_SEARCH_SORTBY_GUILD_NAME ),
        NewGuildSortData( "GWRecruitSearchSortButton3", StringTables.Guild.TEXT_RECRUIT_SEARCH_SORTBY_MEMBERS_ONLINE ),
        NewGuildSortData( "GWRecruitSearchSortButton4", StringTables.Guild.TEXT_RECRUIT_SEARCH_SORTBY_MEMBERS_TOTAL ),
    },


    curSortType = 1,
    curSortOrder = 1,	
}
    
-- This function is used to compare guild profiles for table.sort() on
-- the list display order.
local function CompareGuilds( index1, index2 )

    if( index2 == nil ) 
    then
        return false
    end
    
    local sortType  = GuildWindowTabRecruit.Search.curSortType
    local order     = GuildWindowTabRecruit.Search.curSortOrder 
    
    --DEBUG(L"Sorting.. Type="..sortType..L" Order="..order )
    
    local guild1 = GuildWindowTabRecruit.Search.guildProfiles[ index1 ]
    local guild2 = GuildWindowTabRecruit.Search.guildProfiles[ index2 ]
    
    -- Sort By Name
    if( sortType == GuildWindowTabRecruit.Search.GUILD_SORTBY_NAME ) 
    then
        return StringUtils.SortByString( guild1.name, guild2.name, order ) 
    end
    
    -- Sort By Rank
    if( sortType == GuildWindowTabRecruit.Search.GUILD_SORTBY_RANK ) 
    then
        if( guild1.rank == guild2.rank  ) 
        then        
            return StringUtils.SortByString( guild1.name, guild2.name, GuildWindowTabRecruit.Search.SORT_ORDER_UP )  
        else   
                    
            if( order == GuildWindowTabRecruit.Search.SORT_ORDER_UP ) 
            then	
                return ( guild1.rank < guild2.rank )
            else
                return ( guild2.rank < guild1.rank )
            end		
        end
    end
    
     -- Sort By Players Online
    if( sortType == GuildWindowTabRecruit.Search.GUILD_SORTBY_PLAYERS_ONLINE ) 
    then
        if( guild1.playersOnline == guild2.playersOnline  ) 
        then        
            return StringUtils.SortByString( guild1.name, guild2.name, GuildWindowTabRecruit.Search.SORT_ORDER_UP )  
        else   
                    
            if( order == GuildWindowTabRecruit.Search.SORT_ORDER_UP ) 
            then	
                return ( guild1.playersOnline < guild2.playersOnline )
            else
                return ( guild2.playersOnline < guild1.playersOnline )
            end		
        end
    end
    
    -- Sort By Players Total
    if( sortType == GuildWindowTabRecruit.Search.GUILD_SORTBY_PLAYERS_TOTAL ) 
    then
        if( guild1.playersTotal == guild2.playersTotal  ) 
        then        
            return StringUtils.SortByString( guild1.name, guild2.name, GuildWindowTabRecruit.Search.SORT_ORDER_UP )  
        else   
                    
            if( order == GuildWindowTabRecruit.Search.SORT_ORDER_UP ) 
            then	
                return ( guild1.playersTotal < guild2.playersTotal )
            else
                return ( guild2.playersTotal < guild1.playersTotal )
            end		
        end
    end
    
end

local function SortGuildsList()

    local sortType  = GuildWindowTabRecruit.Search.curSortType
    local order     = GuildWindowTabRecruit.Search.curSortOrder 
    
    --DEBUG(L" Sorting Mods: type="..sortType..L" order="..order )
    table.sort( GuildWindowTabRecruit.Search.displayOrder, CompareGuilds )
end

local function UpdateGuildsList()
    
    ListBoxSetDisplayOrder("GWRecruitSearchList", GuildWindowTabRecruit.Search.displayOrder )
end



--------------------------------------------------------------------------------------
-- Search Page Functions
--------------------------------------------------------------------------------------

function GuildWindowTabRecruit.InitializeSearch()	

    -- 1) Set the Not in a Guild Text
    LabelSetText( "GWRecruitSearchNotInGuildText", GetGuildString( StringTables.Guild.TEXT_RECRUIT_SEARCH_NOT_IN_GUILD_INSTRUCTIONS ) )


    -- 2) Setup the Search Options	
    
    -- Search Type
    LabelSetText( "GWRecruitSearchSearchTypeTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_SEARCH_SEARCH_FOR ) )
    GuildWindowTabRecruit.InitCombBox( "GWRecruitSearchSearchTypeCombo", GuildWindowTabRecruit.RecruitingStatus )        
   
    -- Play Style
    LabelSetText( "GWRecruitSearchPlayStyleTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_PLAY_STYLE_TITLE ) )
    GuildWindowTabRecruit.InitCombBox( "GWRecruitSearchPlayStyleCombo", GuildWindowTabRecruit.PlayStyles )
    
    -- Atmosphere
    LabelSetText( "GWRecruitSearchAtmosphereTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_ATMOSPHERE_TITLE ) )
    GuildWindowTabRecruit.InitCombBox( "GWRecruitSearchAtmosphereCombo", GuildWindowTabRecruit.Atmosphere )

    -- Total Players
    LabelSetText( "GWRecruitSearchTotalPlayersTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_SEARCH_TOTAL_PLAYERS ) )
    GuildWindowTabRecruit.InitCombBox( "GWRecruitSearchTotalPlayersCombo", GuildWindowTabRecruit.TotalPlayersSearch )
    
    -- Players Online
    LabelSetText( "GWRecruitSearchOnlinePlayersTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_SEARCH_PLAYERS_ONLINE ) )
    GuildWindowTabRecruit.InitCombBox( "GWRecruitSearchOnlinePlayersCombo", GuildWindowTabRecruit.OnlinePlayersSearch )

    -- Guild Rank
    LabelSetText( "GWRecruitSearchGuildRankTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_SEARCH_GUILD_RANK ) )
    GuildWindowTabRecruit.InitCombBox( "GWRecruitSearchGuildRankCombo", GuildWindowTabRecruit.GuildRankSearch )     
    
    LabelSetText( "GWRecruitSearchIsRecruitingPlayerLabel", GetGuildString( StringTables.Guild.LABEL_RECRUIT_IS_RECRUITING_PLAYER ) )
    
    -- Search Button
    ButtonSetText("GWRecruitSearchSearchButton", GetGuildString( StringTables.Guild.BUTTON_RECRUIT_DO_SEARCH ) )
    
        
    -- 2) Setup the Search Screen    
    ButtonSetText( "GWRecruitSearchSortButton2", GetGuildString( StringTables.Guild.LABEL_RECRUIT_SEARCH_SORTBY_GUILD_NAME ) )	
    ButtonSetText( "GWRecruitSearchSortButton3", GetGuildString( StringTables.Guild.LABEL_RECRUIT_SEARCH_SORTBY_GUILD_PLAYERS_ONLINE ) )	
    ButtonSetText( "GWRecruitSearchSortButton4", GetGuildString( StringTables.Guild.LABEL_RECRUIT_SEARCH_SORTBY_GUILD_PLAYERS_TOTAL ) )	
    
    GuildWindowTabRecruit.UpdateSearchListSortButtons()	
    
    LabelSetText( "GWRecruitSearchNoGuildsFoundText", GetGuildString( StringTables.Guild.TEXT_RECRUIT_SEARCH_NO_GUILDS_FOUND ) )
    	
    -- 3) Setup the Results Screen
    GuildWindowTabRecruit.InitGuildProfileData( "GWRecruitSearchSelectedProfile" )	    	  	
    	
    WindowRegisterEventHandler( "GWRecruitSearch", SystemData.Events.GUILD_RECRUITMENT_SEARCH_RESULTS_UPDATED, "GuildWindowTabRecruit.UpdateSearchResults")    
    GuildWindowTabRecruit.UpdateSearchResults( {} )
    
end

--------------------------------------------------------------
-- Search Parameters


function GuildWindowTabRecruit.SearchForGuilds()

    -- If the UI is currently waiting for the server responce, 
    -- from a previous search, ignore this search.
    if( GuildWindowTabRecruit.Search.waitingForSearchResults == true )
    then
        return
    end            

    -- Gather the Options from the UI    
    
    -- Search Type
    local searchTypeIndex = ComboBoxGetSelectedMenuItem( "GWRecruitSearchSearchTypeCombo" )    
    local searchType = GuildWindowTabRecruit.RecruitingStatus[ searchTypeIndex ].flagId
    
    -- Play Style
    local playStyleIndex = ComboBoxGetSelectedMenuItem( "GWRecruitSearchPlayStyleCombo" )    
    local playStyle = GuildWindowTabRecruit.PlayStyles[ playStyleIndex ].flagId
    
    -- Atmosphere
    local atmosphereIndex = ComboBoxGetSelectedMenuItem( "GWRecruitSearchAtmosphereCombo" )
    local atmosphere = GuildWindowTabRecruit.Atmosphere[ atmosphereIndex ].flagId    
    
    -- TotalPlayers
    local totalPlayersIndex = ComboBoxGetSelectedMenuItem( "GWRecruitSearchTotalPlayersCombo" )
    local minTotalPlayers = GuildWindowTabRecruit.TotalPlayersSearch[ totalPlayersIndex ].limit
        
    -- TotalPlayers
    local onlinePlayersIndex = ComboBoxGetSelectedMenuItem( "GWRecruitSearchOnlinePlayersCombo" )
    local minOnlinePlayers = GuildWindowTabRecruit.OnlinePlayersSearch[ onlinePlayersIndex ].limit
        
    -- Guild Rank
    local guildRankIndex = ComboBoxGetSelectedMenuItem( "GWRecruitSearchGuildRankCombo" )
    local minGuildRank = GuildWindowTabRecruit.GuildRankSearch[ guildRankIndex ].limit
    
    -- Is Recruiting Player
    local isRecruitingPlayer = ButtonGetPressedFlag( "GWRecruitSearchIsRecruitingPlayerButton" )
    
    
    -- Request the Results from the server....
    
    GuildRecruitmentSearch( playStyle, 
                            atmosphere, 
                            searchType,
                            isRecruitingPlayer,  
                            minTotalPlayers, 
                            minOnlinePlayers, 
                            minGuildRank )
    
    
    -- Disable the Search Button
    GuildWindowTabRecruit.Search.waitingForSearchResults = true
    ButtonSetDisabledFlag( "GWRecruitSearchSearchButton", true )

end


--------------------------------------------------------------
-- Search Results List Functions


function GuildWindowTabRecruit.UpdateSearchResults( resultsTable )
  
    -- Set the Data
    GuildWindowTabRecruit.Search.guildProfiles = resultsTable    
    
    -- Sort the Guilds Alphabetically by name    
    table.sort( GuildWindowTabRecruit.Search.guildProfiles, DataUtils.AlphabetizeByNames ) 
    
    GuildWindowTabRecruit.Search.displayOrder = {}
    for index, _ in ipairs( GuildWindowTabRecruit.Search.guildProfiles )
    do
        table.insert( GuildWindowTabRecruit.Search.displayOrder, index )
    end
    
    
    -- Sort the Data according to the current settings & update the ListBox.
    SortGuildsList()
    UpdateGuildsList()
        
    -- Select the first item
    GuildWindowTabRecruit.SelectGuildProfile( GuildWindowTabRecruit.Search.displayOrder[1] )        
    
    -- If no results were found, show the the 'No Guilds Found' text if this update is in responce to a search.
    local showNoGuildsTxt = (GuildWindowTabRecruit.Search.waitingForSearchResults == true) and (GuildWindowTabRecruit.Search.displayOrder[1] == nil)
    WindowSetShowing( "GWRecruitSearchNoGuildsFoundText", showNoGuildsTxt )    
    
    -- Enable the Search Button
    GuildWindowTabRecruit.Search.waitingForSearchResults = false
    ButtonSetDisabledFlag( "GWRecruitSearchSearchButton", false )

end


function GuildWindowTabRecruit.PopulateSearchResults()

    if( GWRecruitSearchList.PopulatorIndices == nil )
    then
        return
    end

    for rowIndex, dataIndex in ipairs (GWRecruitSearchList.PopulatorIndices) 
    do    
        local guildData = GuildWindowTabRecruit.Search.guildProfiles[ dataIndex ]
        
        -- Set the Row's Background Color    
        local row_mod = math.mod(rowIndex, 2)
        local color = DataUtils.GetAlternatingRowColorGreyOnGrey( row_mod )
        DefaultColor.SetWindowTint( "GWRecruitSearchListRow"..rowIndex.."Background",  color )		 	
        
        -- Set the Players Text: "(X/Y) Online"
        local text =  GetStringFormatFromTable( "GuildStrings", StringTables.Guild.TEXT_PERCENT_PLAYERS_ONLINE, {L""..guildData.playersOnline, L""..guildData.playersTotal} )
        LabelSetText(  "GWRecruitSearchListRow"..rowIndex.."PlayersText", text )
        			
    end
   
    GuildWindowTabRecruit.UpdateSearchResultsButtonStates()
end

------------------------------------------
-- Sorting

function GuildWindowTabRecruit.OnMouseOverSearchListSortButton()
    
    local type = WindowGetId( SystemData.ActiveWindow.name )    
    local text = GetGuildString( GuildWindowTabRecruit.Search.sortData[type].tooltipStringId )    
    
    Tooltips.CreateTextOnlyTooltip(  SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, text)
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( nil )
    
end


function GuildWindowTabRecruit.OnClickSearchListSortButton()

    local type = WindowGetId( SystemData.ActiveWindow.name )
    
    -- If we are already using this sort type, toggle the order.
    if( type == GuildWindowTabRecruit.Search.curSortType ) then
        if( GuildWindowTabRecruit.Search.curSortOrder == GuildWindowTabRecruit.Search.SORT_ORDER_UP ) 
        then
            GuildWindowTabRecruit.Search.curSortOrder = GuildWindowTabRecruit.Search.SORT_ORDER_DOWN
        else
            GuildWindowTabRecruit.Search.curSortOrder = GuildWindowTabRecruit.Search.SORT_ORDER_UP
        end
        
    -- Otherwise change the type and use the up order.	
    else
        GuildWindowTabRecruit.Search.curSortType = type
        GuildWindowTabRecruit.Search.curSortOrder = GuildWindowTabRecruit.Search.SORT_ORDER_UP
    end

    SortGuildsList()
    UpdateGuildsList()
    
    GuildWindowTabRecruit.UpdateSearchListSortButtons()
end

-- Displays the clicked sort button as pressed down and positions an arrow above it
function GuildWindowTabRecruit.UpdateSearchListSortButtons()

    local type = GuildWindowTabRecruit.Search.curSortType
    local order = GuildWindowTabRecruit.Search.curSortOrder
    
    for index, data in ipairs( GuildWindowTabRecruit.Search.sortData ) 
    do      
        ButtonSetPressedFlag( data.windowName, index == GuildWindowTabRecruit.Search.curSortType )       
    end
    
    -- Update the Arrow
    WindowSetShowing( "GWRecruitSearchSortUpArrow", order == GuildWindowTabRecruit.Search.SORT_ORDER_UP )
    WindowSetShowing( "GWRecruitSearchSortDownArrow", order == GuildWindowTabRecruit.Search.SORT_ORDER_DOWN )
            
    local window = GuildWindowTabRecruit.Search.sortData[type].windowName

    if( order == GuildWindowTabRecruit.Search.SORT_ORDER_UP ) 
    then		
        WindowClearAnchors( "GWRecruitSearchSortUpArrow" )
        WindowAddAnchor("GWRecruitSearchSortUpArrow", "right", window, "right", -8, 0 )
        
    else
        WindowClearAnchors( "GWRecruitSearchSortDownArrow" )
        WindowAddAnchor("GWRecruitSearchSortDownArrow", "right", window, "right", -8, 0 )
        
    end

end



------------------------------------------
-- Selection

function GuildWindowTabRecruit.UpdateSearchResultsButtonStates()
    -- DEBUG(L"GuildWindowTabRecruit.UpdateSearchResultsButtonStates()")
    
    if (GWRecruitSearchList.PopulatorIndices == nil)
    then
        return
    end
    
    for rowIndex, dataIndex in ipairs(GWRecruitSearchList.PopulatorIndices)
    do
        local rowWindow = "GWRecruitSearchListRow"..rowIndex
        
        -- Highlight the selected row, unhighlight the rest
        ButtonSetPressedFlag(rowWindow, (dataIndex == GuildWindowTabRecruit.Search.selectedProfile))
        ButtonSetStayDownFlag(rowWindow, (dataIndex == GuildWindowTabRecruit.Search.selectedProfile))            
    end    
end


function GuildWindowTabRecruit.OnLButtonUpGuildsList( flags, x, y )

    local rowIndex = WindowGetId(SystemData.ActiveWindow.name)        
    local dataIndex = GWRecruitSearchList.PopulatorIndices[ rowIndex ] 

    -- If Shift is pressed, generate a Guild Hyper-Link
    if( flags == SystemData.ButtonFlags.SHIFT )
    then    
        local guildData = GuildWindowTabRecruit.Search.guildProfiles[ dataIndex ]          
        EA_ChatWindow.InsertGuildLink( guildData )
    else    
        GuildWindowTabRecruit.SelectGuildProfile( dataIndex )
    end    
    
end

function GuildWindowTabRecruit.SelectGuildProfile( dataIndex )

    -- Record the list item that was selected / deselect other buttons        
    GuildWindowTabRecruit.Search.selectedProfile = dataIndex
    GuildWindowTabRecruit.UpdateSearchResultsButtonStates()

    --DEBUG(L"GuildWindowTabRecruit.SelectGuildProfile() selecting entry "..GuildWindowTabRecruit.Search.selectedProfile)
            
    if( dataIndex == nil )
    then
        WindowSetShowing("GWRecruitSearchSelectedProfile", false )
        return
    end
    
    local guildData = GuildWindowTabRecruit.Search.guildProfiles[ dataIndex ]
    
    if( guildData == nil )
    then
        WindowSetShowing("GWRecruitSearchSelectedProfile", false )
        return
    end
    
    -- Set the Data......
    
    WindowSetShowing("GWRecruitSearchSelectedProfile", true )

    GuildWindowTabRecruit.SetGuildProfileData( "GWRecruitSearchSelectedProfile", guildData )

end


function GuildWindowTabRecruit.OnLButtonDownSelectedProfile( flags, x, y)
    
    local dataIndex = GuildWindowTabRecruit.Search.selectedProfile     
    if( dataIndex == nil )
    then
        return
    end

    -- If Shift is pressed, generate a Guild Hyper-Link
    if( flags == SystemData.ButtonFlags.SHIFT )
    then    
        local guildData = GuildWindowTabRecruit.Search.guildProfiles[ dataIndex ]          
        EA_ChatWindow.InsertGuildLink( guildData )
    end

end

function GuildWindowTabRecruit.InitGuildProfileData( windowName )

    -- Initialized the Non-Data driven compoents
     
    -- Heading Background
    local color = DefaultColor.GetRowColor( 1 )			
    DefaultColor.SetWindowTint( windowName.."HeadingBackground",  color )	
    
    -- Guild Leader
    LabelSetText( windowName.."GuildLeaderTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_PROFILE_GUILD_LEADER_TITLE ) )

    -- Alliance
    LabelSetText( windowName.."AllianceTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_ALLIANCE_TITLE ) )
    
    -- Play Style
    LabelSetText( windowName.."PlayStyleTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_PLAY_STYLE_TITLE ) )
    
    -- Atmosphere
    LabelSetText( windowName.."AtmosphereTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_ATMOSPHERE_TITLE ) )
    
     -- Careers Needed
    LabelSetText( windowName.."CareersNeededTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_CAREERS_NEEDED_TITLE ) )
    
    -- Tiers Needed
    LabelSetText( windowName.."TiersNeededTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_RANKS_NEEDED_TITLE ) )
    
    -- Interests
    LabelSetText( windowName.."InterestsTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_INTERESTS_TITLE ) )  

    -- Recruiters
    LabelSetText( windowName.."RecruitersTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_PROFILE_RECRUITERS_TITLE ) )   
    

end

function GuildWindowTabRecruit.SetGuildProfileData( windowName, guildData )
    
    -- Guild Name
    LabelSetText( windowName.."Name", guildData.name )
    
    -- Guild Rank
    LabelSetText( windowName.."RankText", L""..guildData.rank )
    
    -- Guild Leader
    local name = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.LABEL_RECRUIT_PROFILE_GUILD_LEADER_NAME, {guildData.guildLeader} )
    local text = CreateHyperLink( L"PLAYER:"..name, name, {}, {} )
    LabelSetText( windowName.."GuildLeaderText", text )
    
    -- Alliance Name
    local allianceName = guildData.allianceName
    if allianceName == L""
    then
        allianceName = GetGuildString( StringTables.Guild.LABEL_RECRUIT_ALLIANCE_NONE )
    end
    LabelSetText( windowName.."AllianceText", allianceName )
    
    -- Recruiters
    local recruitersText = L""
    for _, recruiterData in ipairs(guildData.recruiters)
    do       
    
       local text = CreateHyperLink( L"PLAYER:"..recruiterData.name, recruiterData.name, {}, {} )     

       if( recruitersText == L"" )
       then
            recruitersText = text
       else
            recruitersText = StringUtils.AppendItemToList( recruitersText, text )
       end
             
    end 
    
    if( recruitersText == L"" )
    then
        recruitersText = GetGuildString( StringTables.Guild.TEXT_RECRUIT_PROFILE_OPTION_NONE_SPECIFIED )
    end
    
    LabelSetText( windowName.."RecruitersText", recruitersText)
    
    -- Guild Summary
    LabelSetText( windowName.."SummaryScrollChildText", guildData.summary )
    ScrollWindowSetOffset( windowName.."Summary", 0 )
    ScrollWindowUpdateScrollRect( windowName.."Summary" )     
        
    -- Set the Players Text: "(X/Y) Online"
    local text =  GetStringFormatFromTable( "GuildStrings", StringTables.Guild.TEXT_PERCENT_PLAYERS_ONLINE, {L""..guildData.playersOnline, L""..guildData.playersTotal} )
    LabelSetText(  windowName.."PlayersText", text )
    
     -- Play Style        
    local playStyleText = L""
    for index, data in ipairs( GuildWindowTabRecruit.PlayStyles )
    do
        if( data.flagId == guildData.playStyle )
        then
            playStyleText = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.TEXT_RECRUIT_PROFILE_PLAYSTYLE_VALUE, { data.name } )
        end
    end
    LabelSetText(  windowName.."PlayStyleText", playStyleText )
    
    -- Atmosphere
    local atmosphereText = L""
    for index, data in ipairs( GuildWindowTabRecruit.Atmosphere )
    do
        if( data.flagId == guildData.atmosphere )
        then
            atmosphereText = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.TEXT_RECRUIT_PROFILE_ATMOSPHERE_VALUE, { data.name } )
        end
    end
    
    LabelSetText(  windowName.."AtmosphereText", atmosphereText )
    
    -- Interests
    local interestsText = L""
    for _, interestData in ipairs(GuildWindowTabRecruit.Interests)
    do        
        local hasFlag = guildData.interests[ interestData.flagId ]           
        if( hasFlag )
        then
           if( interestsText == L"" )
           then
                interestsText = interestData.name
           else
                interestsText = StringUtils.AppendItemToList( interestsText, interestData.name )
           end
        end        
    end 
    
    if( interestsText == L"" )
    then
        interestsText = GetGuildString( StringTables.Guild.TEXT_RECRUIT_PROFILE_OPTION_NONE_SPECIFIED )
    end
    
    LabelSetText( windowName.."InterestsText", interestsText)
    
    -- Set Tiers Needed
    
    local function AppendRank( text, minRank, maxRank )
    
       local rankText = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.TEXT_RECRUIT_RANKS, { L""..minRank, L""..maxRank } )
    
       if( text == L"" )
       then
            return rankText
       else
            return StringUtils.AppendItemToList( text, rankText )
       end   
    
    end
    
    local tiersNeededText = L""
    local minRank = 0
    local maxRank = 0
    for _, tierData in ipairs(GuildWindowTabRecruit.TiersNeeded)
    do        
        local hasFlag = guildData.tiersNeeded[ tierData.flagId ]   
        local continous = false        
        if( hasFlag )
        then
            
           -- If no rank has been specified yet, set it.
           if( minRank == 0 )
           then
                minRank = tierData.minRank
                maxRank = tierData.maxRank
                
           elseif( maxRank == tierData.minRank - 1 )
           then
                -- If the ranks are continous, adjust the end rank
                maxRank = tierData.maxRank
           end         
           
        elseif( minRank ~= 0 )
        then   
            -- Append the text for the previous ranks if needed.         
            tiersNeededText = AppendRank( tiersNeededText, minRank, maxRank )
                        
            -- Reset the Ranks
            minRank = 0
            maxRank = 0
        end
        
    end 
    
    if( maxRank ~= minRank )
    then
        tiersNeededText = AppendRank( tiersNeededText, minRank, maxRank )
    end
    
    if( tiersNeededText == L"" )
    then
        tiersNeededText = GetGuildString( StringTables.Guild.TEXT_RECRUIT_PROFILE_OPTION_NONE_SPECIFIED )
    end
    
    LabelSetText( windowName.."TiersNeededText", tiersNeededText)


    -- Set the Careers Needed
    local careers = {}
    for index, careerData in ipairs(GuildWindowTabRecruit.Profile.Careers)
    do                
        local needed = guildData.careersNeeded[ careerData.flagId ] 
        if( needed )
        then
            table.insert( careers, careerData.careerLineId )
        end            
    end
    
    local rows = 1
    local cols = #careers
    
	ActionButtonGroupSetNumButtons( windowName.."CareersNeeded", rows, cols )
	
	for index, careerLineId in ipairs( careers )
	do
	    local iconNum = Icons.GetCareerIconIDFromCareerLine(careerLineId)
	    ActionButtonGroupSetIcon( windowName.."CareersNeeded", index, iconNum )
	    ActionButtonGroupSetId( windowName.."CareersNeeded", index, careerLineId )
	end
    
    local careersNeededText = L""
    if( #careers == 0 )
    then
        careersNeededText = GetGuildString( StringTables.Guild.TEXT_RECRUIT_PROFILE_OPTION_NONE_SPECIFIED )
    end
    
    LabelSetText( windowName.."CareersNeededText", careersNeededText)
  
end
