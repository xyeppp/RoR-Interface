----------------------------------------------------------------
-- TomeWindow - Quests Implementation
--
--  This file contains all of the initialization and callack
--  functions for the Quest Journal section of the Tome of Knowledge.
-- 
----------------------------------------------------------------

-- Constants
TomeWindow.MAX_QUEST_SLOTS = 40
TomeWindow.NUM_CONDITION_COUNTERS = 10
TomeWindow.NUM_GIVEN_REWARD_SLOTS = 10
TomeWindow.NUM_CHOICE_REWARD_SLOTS = 10

TomeWindow.MONEY_REWARD_ID = -1
TomeWindow.XP_REWARD_ID    = -2

-- Variables
TomeWindow.QuestJournal = {}

TomeWindow.QuestJournal.questData = {}
TomeWindow.QuestJournal.questDataDisplayOrder = {}

TomeWindow.QuestJournal.currentQuestData = nil
TomeWindow.QuestJournal.visibleQuestRewardItems = nil

TomeWindow.QuestJournal.questTOCWindowCount = 0

-- Sorting Data
            
TomeWindow.QuestJournal.SORT_ORDER_UP           = 1
TomeWindow.QuestJournal.SORT_ORDER_DOWN         = 2

            
function NewQuestSortData( param_label, param_title, param_desc )
    return { windowName=param_label, title=param_title, desc=param_desc }
end

TomeWindow.QUEST_SORTBY_COMPLETE    = 1
TomeWindow.QUEST_SORTBY_TYPE        = 2
TomeWindow.QUEST_SORTBY_NAME        = 3
TomeWindow.QUEST_SORTBY_ZONE        = 4
TomeWindow.QUEST_SORTBY_TRACK       = 5
TomeWindow.QUEST_SORTBY_MAP         = 6

TomeWindow.QuestJournal.sortData = {}   
TomeWindow.QuestJournal.sortData[1] = NewQuestSortData( "QuestTOCHeadersQuestComplete",   L"",        GetString(StringTables.Default.TEXT_SORTBY_QUEST_COMPLETE) )
TomeWindow.QuestJournal.sortData[2] = NewQuestSortData( "QuestTOCHeadersQuestType",   L"",        GetString(StringTables.Default.TEXT_SORTBY_QUEST_TYPE) )
TomeWindow.QuestJournal.sortData[3] = NewQuestSortData( "QuestTOCHeadersName", GetString(StringTables.Default.LABEL_QUEST_NAME),         GetString(StringTables.Default.TEXT_SORTBY_QUEST_NAME) )
TomeWindow.QuestJournal.sortData[4] = NewQuestSortData( "QuestTOCHeadersZone",    GetString(StringTables.Default.LABEL_ZONE),        GetString(StringTables.Default.TEXT_SORTBY_QUEST_ZONE) )
TomeWindow.QuestJournal.sortData[5] = NewQuestSortData( "QuestTOCHeadersTrack",      L"", GetString(StringTables.Default.TEXT_SORTBY_QUEST_TRACK) )
TomeWindow.QuestJournal.sortData[6] = NewQuestSortData( "QuestTOCHeadersMapPin",    L"",   GetString(StringTables.Default.TEXT_SORTBY_QUEST_MAP) )
TomeWindow.QuestJournal.NUM_SORT_TYPES = 5

TomeWindow.QuestJournal.curSortType     = TomeWindow.QUEST_SORTBY_NAME
TomeWindow.QuestJournal.curSortOrder    = TomeWindow.QuestJournal.SORT_ORDER_UP 


-- This function is used as the comparison function for 
-- table.sort() on the quest list display order
local function CompareQuests( index1, index2)

    if( index2 == nil ) then
        --DEBUG(L" CompareQuests( "..index1..L", nil )" )
        return false
    end

    --DEBUG(L" CompareQuests( "..index1..L", "..index2..L" )" ) 
    local sortType  = TomeWindow.QuestJournal.curSortType
    local order     = TomeWindow.QuestJournal.curSortOrder 

    local quest1 = TomeWindow.QuestJournal.questData[index1]
    local quest2 = TomeWindow.QuestJournal.questData[index2]
    
    -- Sort By Complete
    if( sortType == TomeWindow.QUEST_SORTBY_COMPLETE ) then
        if( quest1.complete == quest2.complete  ) then        
            return StringUtils.SortByString( quest1.name, quest2.name, TomeWindow.QuestJournal.SORT_ORDER_UP )  
        else            
            if( order == TomeWindow.QuestJournal.SORT_ORDER_UP ) then   
                return ( quest2.complete )
            else
                return ( quest1.complete )
            end     
        end
    end

    -- Sort By Type
    if( sortType == TomeWindow.QUEST_SORTBY_TYPE ) then
    
        local types1 = quest1.questTypes
        local types2 = quest2.questTypes
        
        local index = 1
        
        -- Find first non-equal quest type index
        while( types1[index] ~= nil and types2[index] ~= nil and types1[index] == types2[index] ) do
            index = index + 1
        end 
        
        -- If the quests have identical types, sort by name 
        if( types1[index] == nil and types2[index] == nil ) then
            return StringUtils.SortByString( quest1.name, quest2.name, TomeWindow.QuestJournal.SORT_ORDER_UP ) 
        end
        
        -- Otherwise, compare the last type
        if( order == TomeWindow.QuestJournal.SORT_ORDER_UP ) then   
            if( types1[index] == nil ) then
                return true
            elseif( types2[index] == nil ) then
                return false
            else
                if (types1[index]) and not (types2[index])
                then
                    return false
                else
                    return true
                end
            end
        else
            if( types1[index] == nil ) then
                return false
            elseif( types2[index] == nil ) then
                return true
            else
                if (not types1[index]) and (types2[index])
                then
                    return false
                else
                    return true
                end
            end
        end
    
    end
    
    -- Sorting By Name
    if( sortType == TomeWindow.QUEST_SORTBY_NAME ) then
        return StringUtils.SortByString( quest1.name, quest2.name, order ) 
    end
    
    -- Sorting By Zone
    if( sortType == TomeWindow.QUEST_SORTBY_ZONE ) then
        
        local zone1Name = L"" 
        if( quest1.zones[1] ~= nil ) then
            zone1Name = quest1.zones[1].zoneName
        end
        
        local zone2Name = L"" 
        if( quest2.zones[1] ~= nil ) then
            zone2Name = quest2.zones[1].zoneName
        end
        
        if( WStringsCompare( zone1Name, zone2Name ) == 0 ) then        
            return StringUtils.SortByString( quest1.name, quest2.name, TomeWindow.QuestJournal.SORT_ORDER_UP ) 
        else
            return StringUtils.SortByString( zone1Name, zone2Name, order )  
        end
    end
    
    -- Sort By Track
    if( sortType == TomeWindow.QUEST_SORTBY_TRACK ) then        
        if( quest1.tracking == quest2.tracking  ) then        
            return StringUtils.SortByString( quest1.name, quest2.name, TomeWindow.QuestJournal.SORT_ORDER_UP )  
        else            
            if( order == TomeWindow.QuestJournal.SORT_ORDER_UP ) then   
                return ( quest2.tracking )
            else
                return ( quest1.tracking )
            end     
        end
    end

    -- Sort By Map
    if( sortType == TomeWindow.QUEST_SORTBY_MAP ) then
        if( quest1.trackingPin == quest2.trackingPin  ) then        
            return StringUtils.SortByString( quest1.name, quest2.name, TomeWindow.QuestJournal.SORT_ORDER_UP )  
        else            
            if( order == TomeWindow.QuestJournal.SORT_ORDER_UP ) then   
                return ( quest2.trackingPin )
            else
                return ( quest1.trackingPin )
            end 
        end
    end        
end

local function SortQuests()

    local sortType  = TomeWindow.QuestJournal.curSortType
    local order     = TomeWindow.QuestJournal.curSortOrder 


    --DEBUG(L" Sorting Quests: type="..sortType..L" order="..order )
    table.sort( TomeWindow.QuestJournal.questDataDisplayOrder, CompareQuests )
end

local function UpdateQuestListData()
    
    -- Update the Quest Data
    TomeWindow.QuestJournal.questData = DataUtils.GetQuests()
    
    TomeWindow.QuestJournal.questDataDisplayOrder = {}
    for index, data in ipairs( TomeWindow.QuestJournal.questData ) do
        table.insert( TomeWindow.QuestJournal.questDataDisplayOrder, index )
    end
    
    -- Sort the quest lists
    SortQuests()
end
    

----------------------------------------------------------------
-- QuestJournal Functions
----------------------------------------------------------------


function TomeWindow.InitializeQuestJournal()

    -- > Initialize the PageData
    
    -- Quest TOC
    TomeWindow.Pages[ TomeWindow.PAGE_QUEST_TOC ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_QUESTS, 
                        "QuestTableOfContents", 
                        nil,
                        TomeWindow.OnQuestJournalTOCUpdateNavButtons,
                        TomeWindow.OnQuestJournalTOCPreviousPage,
                        TomeWindow.OnQuestJournalTOCNextPage,
                        TomeWindow.OnQuestJournalTOCMouseOverPreviousPage,
                        TomeWindow.OnQuestJournalTOCMouseOverNextPage )
                        
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_QUEST_TOC, 
                                  GetString( StringTables.Default.LABEL_QUESTS ), 
                                  L"" )  

    -- Quest Info                 
    TomeWindow.Pages[ TomeWindow.PAGE_QUEST_INFO ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_QUESTS, 
                    "TomeWindowQuestInfo", 
                    TomeWindow.DisplayQuest,
                    TomeWindow.OnQuestInfoUpdateNavButtons,
                    TomeWindow.OnQuestInfoPreviousPage,
                    TomeWindow.OnQuestInfoNextPage, 
                    TomeWindow.OnQuestInfoMouseOverPreviousPage,
                    TomeWindow.OnQuestInfoMouseOverNextPage )

    

    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.QUEST_LIST_UPDATED, "TomeWindow.OnQuestListUpdated")
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.QUEST_INFO_UPDATED, "TomeWindow.OnQuestUpdated")
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.RESOLUTION_CHANGED, "TomeWindow.OnQuestPageResolutionChanged")


    -- Initialize the Quest TOC Sort Buttons
    for index, data in ipairs( TomeWindow.QuestJournal.sortData ) do            
        WindowSetId( data.windowName, index )    
        ButtonSetText( data.windowName, data.title )        
        ButtonSetStayDownFlag( data.windowName, true )        
    end


    TomeWindow.QuestJournal.questTOCWindowCount = 0
    
    -- Quest Info
    
    LabelSetText("TomeWindowQuestInfoTrackLabel", GetString( StringTables.Default.LABEL_TRACK ) )    
    LabelSetText("TomeWindowQuestInfoMapLabel", GetString( StringTables.Default.LABEL_SHOW_ON_MAP ) )    
    ButtonSetStayDownFlag("TomeWindowQuestInfoTrackBtn", true )     
    ButtonSetStayDownFlag("TomeWindowQuestInfoMapBtn", true )     
    
    LabelSetText("TomeWindowQuestInfoQuestDetailsLabel", GetString( StringTables.Default.LABEL_QUEST_PARTICULARS ) )    
    PageWindowAddPageBreak( "TomeWindowQuestInfoPageWindow", "TomeWindowQuestInfoQuestDetailsLabel" )
 

    LabelSetText( "TomeWindowQuestInfoRequirementsLabel", GetString( StringTables.Default.LABEL_REQUIREMENTS ) )   
    LabelSetText( "TomeWindowQuestInfoRewardsLabel", GetString( StringTables.Default.LABEL_REWARDS ) )   

    LabelSetText( "TomeWindowQuestInfoTimerText", GetString( StringTables.Default.TEXT_QUEST_TIME_REMAINING ) )


    ButtonSetText("TomeWindowQuestInfoAbandonButton", GetString( StringTables.Default.LABEL_ABANDON ))   
    ButtonSetText("TomeWindowQuestInfoShareButton", GetString( StringTables.Default.TEXT_SHARE_QUEST ))   
        
    TomeWindow.OnQuestListUpdated()    
    TomeWindow.UpdateQuestSortButtons()
end


function TomeWindow.OnQuestListUpdated()
    --DEBUG(L"TomeWindow.OnQuestListUpdated()")
    
    UpdateQuestListData()
    TomeWindow.UpdateQuestListDisplay()

    -- If we're currently viewing a quest and the quest has been removed, flip back the TOC
    if( TomeWindow.currentState.pageType == TomeWindow.PAGE_QUEST_INFO ) then
        
        local questData = DataUtils.GetQuestData( TomeWindow.currentState.params[1] )
        if( questData == nil ) then
            TomeWindow.SetState( TomeWindow.PAGE_QUEST_TOC, {}, {TomeWindow.FLIP_BACKWARD_MULTI} )
            TomeWindow.QuestJournal.currentQuestData = nil
            TomeWindow.QuestJournal.visibleQuestRewardItems = nil
        end
    end

end

    
function TomeWindow.UpdateQuestListDisplay()

    local dots = L"........................................................................................................................"

    --DEBUG(L"TomeWindow.UpdateQuestListDisplay()")
    
     -- Create the TOC entry for each Entry
    local parentWindow = "QuestTOCPageWindowContentsChild"     
    local anchorWindow = "QuestTOCPageWindowContentsChildQuestListAnchor"    
    local xOffset = 0
    local yOffset = 0
    
    local questCount = 0       
    for index, questDataIndex in ipairs( TomeWindow.QuestJournal.questDataDisplayOrder ) do
    
        local questData = TomeWindow.QuestJournal.questData[ questDataIndex ]
    
        --DEBUG( L"["..index..L"] = "..questData.id..L": "..questData.name )
        
        questCount = questCount + 1    
        
        -- Create the entry window if necessary
        local questWindowName = "QuestTableOfContentsLine"..questCount
        if( TomeWindow.QuestJournal.questTOCWindowCount < questCount ) then
        
            CreateWindowFromTemplate( questWindowName, "QuestTableOfContentsLine", parentWindow )
            ButtonSetStayDownFlag( questWindowName.."TrackBtn", true )
            ButtonSetStayDownFlag( questWindowName.."TrackPinBtn", true )
            
            ButtonSetStayDownFlag( questWindowName.."Complete", true )
            ButtonSetDisabledFlag( questWindowName.."Complete", true )
                         
            WindowAddAnchor( questWindowName, "bottomleft", anchorWindow, "topleft", xOffset, yOffset )        
            
            TomeWindow.QuestJournal.questTOCWindowCount = TomeWindow.QuestJournal.questTOCWindowCount + 1
        end
        anchorWindow = questWindowName     
        
        -- Set the Id
        WindowSetId( questWindowName, questData.id )        
        
        -- Set the Complete Check
        ButtonSetPressedFlag( questWindowName.."Complete", questData.complete )
        
        -- Set the Type Icons
        local slice = QuestUtils.GetSliceForType( questData.questTypes )
        DynamicImageSetTextureSlice( questWindowName.."QuestTypeIcon", slice )
        
        -- Set The Name
        ButtonSetText( questWindowName.."QuestNameText", questData.name )
        WindowForceProcessAnchors( questWindowName.."QuestName" )
        LabelSetText( questWindowName.."QuestNameDottedLine", dots )
      
        -- Set the Zone(s)
        local zoneText = L""
        for index, zone in ipairs( questData.zones ) do            
            if( zoneText ~= L"" ) then
                zoneText = zoneText..L", "
            end
            zoneText = zoneText..zone.zoneName
        end
        ButtonSetText( questWindowName.."ZoneText", zoneText )
        ButtonSetDisabledFlag( questWindowName.."ZoneText", true )
        WindowForceProcessAnchors( questWindowName.."Zone" )
        LabelSetText( questWindowName.."ZoneDottedLine", dots )
        
        -- Set the Track Button
        ButtonSetPressedFlag(questWindowName.."TrackBtn", questData.tracking )
        
        -- Set the Map Button
        ButtonSetPressedFlag(questWindowName.."TrackPinBtn", questData.trackingPin )
        
      
      
      
        --WindowSetDimensions(questWindowName, width, height )
               
                
    end
    
    -- Show/Hide the appropriate number of entry windows.
    for index = 1, TomeWindow.QuestJournal.questTOCWindowCount do
        local show = index <= questCount
        local windowName = "QuestTableOfContentsLine"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
    end
    
    
    PageWindowUpdatePages("QuestTOCPageWindow")
    TomeWindow.OnWarJournalTOCUpdateNavButtons()  
    
    if( TomeWindow.QuestJournal.currentQuestData ~= nil ) then
        TomeWindow.DisplayQuest( TomeWindow.QuestJournal.currentQuestData.id )
    end

end


function TomeWindow.OnMouseOverTOCQuestType()
    local index = DataUtils.GetQuestData( WindowGetId( WindowGetParent(SystemData.MouseOverWindow.name ) ) )   
    local questData = TomeWindow.QuestJournal.questData[index]
    QuestUtils.CreateQuestTypeTooltip( questData, SystemData.MouseOverWindow.name )    
end



function TomeWindow.OnQuestUpdated()

    if(  TomeWindow.currentState.pageType == TomeWindow.PAGE_QUEST_INFO and
         TomeWindow.currentState.params[1] == GameData.Player.Quests.updatedQuest  ) then
        TomeWindow.DisplayQuest( TomeWindow.currentState.params[1] )
    end
end

function TomeWindow.OnQuestPageResolutionChanged()
	--[[
		This code should get executed even if the quest page in the tome
		is not showing because, otherwise, if the tome was closed on the quest page,
		it won't get updated when the tome gets reopened even though there was a resolution
		change.
	--]]

    PageWindowUpdatePages( "TomeWindowQuestInfoPageWindow" )
    PageWindowSetCurrentPage( "TomeWindowQuestInfoPageWindow", 1 )
    TomeWindow.OnQuestInfoUpdateNavButtons()
end

function TomeWindow.SelectQuest()
    local questId = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name) )

    local params = { questId }
    TomeWindow.SetState( TomeWindow.PAGE_QUEST_INFO, params )      
end



function TomeWindow.OpenToQuest( questId )
    local params = { questId }
    TomeWindow.SetState( TomeWindow.PAGE_QUEST_INFO,params )
end

function TomeWindow.IsShowingQuest( questId )

    return TomeWindow.currentState.pageType == TomeWindow.PAGE_QUEST_INFO 
            and questId == TomeWindow.currentState.params[1]
end

function TomeWindow.DisplayQuest( questId )

    --DEBUG(L"Displaying Quest #"..questId )
    local questData = DataUtils.GetQuestData( questId )
    if( questData == nil )
    then
        --ERROR(L"TomeWindow.DisplayQuest("..questId..L") - QUEST DATA NOT FOUND! ")
        
        -- Flip back to quest list
        -- BAD - this causes corrupted tome UI when called during GoBack->ShowPage
        -- yet if I remove this I'll break places where we actually wanted it to go to TOC
        TomeWindow.SetState( TomeWindow.PAGE_QUEST_TOC, {} )
        return
    end

    TomeWindow.QuestJournal.currentQuestData = questData
    TomeWindow.QuestJournal.visibleQuestRewardItems = { given = {}, choice = {}, money=0, xp=0  }
    
    local questRewards = GameData.GetQuestRewards( questId )
    
    TomeWindow.QuestJournal.visibleQuestRewardItems.money = questRewards.money
    TomeWindow.QuestJournal.visibleQuestRewardItems.xp = questRewards.xp
    
    -- Name
    LabelSetText("TomeWindowQuestInfoQuestName", wstring.upper( questData.name ) )
    
    -- Type
    local typeName = QuestUtils.GetQuestTypeStringFromTypes( questData.questTypes )
    if( typeName ~= L"" )
    then
        LabelSetText( "TomeWindowQuestInfoTypeNameText", typeName )
        local slice = QuestUtils.GetSliceForType( questData.questTypes )
        DynamicImageSetTextureSlice( "TomeWindowQuestInfoTypeNameIconLeft", slice )
        DynamicImageSetTextureSlice( "TomeWindowQuestInfoTypeNameIconRight", slice )
        
        -- update anchors
        WindowClearAnchors( "TomeWindowQuestInfoStartDlgText" )
        WindowAddAnchor( "TomeWindowQuestInfoStartDlgText", "bottom", "TomeWindowQuestInfoTypeName", "top", 0, 10 )
    else
        -- update anchors
        WindowClearAnchors( "TomeWindowQuestInfoStartDlgText" )
        WindowAddAnchor( "TomeWindowQuestInfoStartDlgText", "bottom", "TomeWindowQuestInfoQuestName", "top", 0, 10 )
    end
    WindowSetShowing( "TomeWindowQuestInfoTypeName", typeName ~= L"" )
    
    
    -- Options
    ButtonSetPressedFlag("TomeWindowQuestInfoTrackBtn", questData.tracking )
    ButtonSetPressedFlag("TomeWindowQuestInfoMapBtn", questData.trackingPin )
    
   -- Starting Dialog  
  	local G_Name = towstring(GameData.Guild.m_GuildName) or L"Guildless"
	
    local startText = questData.startDesc
	startText = wstring.gsub(towstring(startText), L"|g",G_Name)	
	
    LabelSetText("TomeWindowQuestInfoStartDlgText", startText )   
    
    
    -- Description
    local descText = questData.journalDesc
	descText = wstring.gsub(towstring(descText), L"|g",G_Name)		
    LabelSetText("TomeWindowQuestInfoDescriptionText", descText )

    local anchorWindow = "TomeWindowQuestInfoRequirementsLabel"
    local anchorOffsetX = 0
    local anchorOffsetY = 0
    
    WindowClearAnchors( "TomeWindowQuestInfoTimer" )

    -- Timer
    local hasTimer = questData.maxTimer ~= 0
    WindowSetShowing( "TomeWindowQuestInfoTimer", hasTimer )
    if( hasTimer ) then     
        
        WindowAddAnchor( "TomeWindowQuestInfoTimer", "bottom", anchorWindow, "top", 0, 10 )
        anchorWindow = "TomeWindowQuestInfoTimer"       

        local text = TimeUtils.FormatClock( questData.timeLeft )
        LabelSetText( "TomeWindowQuestInfoTimerValue", text )     
    end
    
    anchorOffsetY = 10

    -- Conditions
    local numConditions = #questData.conditions
    
    for condition, conditionData in ipairs(questData.conditions)
    do
        local conditionName = conditionData.name
        local curCounter    = conditionData.curCounter
        local maxCounter    = conditionData.maxCounter
        
        local targetWindow  = "TomeWindowQuestInfoCondition"..condition

        WindowClearAnchors( targetWindow )
        WindowSetShowing( targetWindow, true )
        
        WindowAddAnchor( targetWindow, "bottom", anchorWindow, "top", anchorOffsetX, anchorOffsetY )
        anchorWindow = targetWindow
        anchorOffsetY = 5
        
        LabelSetText( targetWindow.."Name", conditionName )
        if( maxCounter > 0 )
        then
            LabelSetText( targetWindow.."Counter", L""..curCounter..L"/"..maxCounter )
        else
            LabelSetText( targetWindow.."Counter", L"" )
        end

        -- Adjust the size of the condition window account for line wrapping with the condition name
        local x, nameHeight = WindowGetDimensions( targetWindow.."Name" )                   
        WindowSetDimensions( targetWindow, 350, nameHeight )   
        
        -- Set the Check
        ButtonSetPressedFlag( targetWindow.."Check", curCounter > 0 and curCounter == maxCounter )
        ButtonSetStayDownFlag( targetWindow.."Check", true )
        ButtonSetDisabledFlag( targetWindow.."Check", true )
    end
    
    for condition = numConditions+1, TomeWindow.NUM_CONDITION_COUNTERS
    do
        WindowClearAnchors( "TomeWindowQuestInfoCondition"..condition )
        WindowSetShowing( "TomeWindowQuestInfoCondition"..condition, false )
    end
    
    anchorOffsetY = 30
    
    -- Anchor the Rewards Label
    WindowClearAnchors( "TomeWindowQuestInfoRewardsLabel" )        
    WindowAddAnchor( "TomeWindowQuestInfoRewardsLabel", "bottom", anchorWindow, "top", anchorOffsetX, anchorOffsetY )
    anchorWindow = "TomeWindowQuestInfoRewardsLabel"

    -- Given Rewards
    local numGivenRewards = 0
    
    local xpShowing    = (questRewards.xp > 0)
    local moneyShowing = (questRewards.money > 0)
    
    if xpShowing
    then
        -- construct the fake xp icon
        numGivenRewards = numGivenRewards + 1
        WindowSetShowing("TomeWindowQuestInfoGivenReward"..numGivenRewards, true )
        local texture, x, y = GetIconData( Icons.XP_REWARD )
        DynamicImageSetTexture( "TomeWindowQuestInfoGivenReward"..numGivenRewards.."IconBase", texture, x, y ) 
        WindowSetId( "TomeWindowQuestInfoGivenReward"..numGivenRewards, TomeWindow.XP_REWARD_ID )
        WindowSetShowing("TomeWindowQuestInfoGivenReward"..numGivenRewards.."Text", false )
    end
    
    if moneyShowing
    then        
        -- construct the fake money icon        
        numGivenRewards = numGivenRewards + 1
        WindowSetShowing("TomeWindowQuestInfoGivenReward"..numGivenRewards, true )
        local texture, x, y = GetIconData( Icons.GOLD_REWARD )
        DynamicImageSetTexture( "TomeWindowQuestInfoGivenReward"..numGivenRewards.."IconBase", texture, x, y ) 
        WindowSetId( "TomeWindowQuestInfoGivenReward"..numGivenRewards, TomeWindow.MONEY_REWARD_ID )
        WindowSetShowing("TomeWindowQuestInfoGivenReward"..numGivenRewards.."Text", false )
    end
        

    for rewardIndex, rewardItem in ipairs(questRewards.itemsGiven)
    do 
        numGivenRewards = numGivenRewards + 1
        TomeWindow.QuestJournal.visibleQuestRewardItems.given[rewardIndex] = rewardItem
        WindowSetShowing("TomeWindowQuestInfoGivenReward"..numGivenRewards, true )
        local texture, x, y = GetIconData( rewardItem.iconNum )
        DynamicImageSetTexture( "TomeWindowQuestInfoGivenReward"..numGivenRewards.."IconBase", texture, x, y ) 
        WindowSetId( "TomeWindowQuestInfoGivenReward"..numGivenRewards, rewardIndex )
        
        if ( rewardItem.stackCount > 1 )
        then
            WindowSetShowing( "TomeWindowQuestInfoGivenReward"..numGivenRewards.."Text", true )
            LabelSetText( "TomeWindowQuestInfoGivenReward"..numGivenRewards.."Text", L""..rewardItem.stackCount )
        else
            WindowSetShowing( "TomeWindowQuestInfoGivenReward"..numGivenRewards.."Text", false )
        end
    end

    for rewardIndex = numGivenRewards+1,TomeWindow.NUM_GIVEN_REWARD_SLOTS
    do
        WindowSetShowing("TomeWindowQuestInfoGivenReward"..rewardIndex, false )
    end
    
    anchorWindow = "TomeWindowQuestInfoGivenReward1"
    anchorOffsetX = -20
    if( numGivenRewards > 5 )
    then
        anchorWindow = "TomeWindowQuestInfoGivenReward6"
    end
    
    
    -- Choice Rewards
    local numChoiceRewards = 0
    for rewardIndex, rewardItem in ipairs(questRewards.itemsChosen) do
    
        local playerCareer = GameData.Player.career.line
        
        -- Filter the choices, don't display any that are unusable by the character's career
        local isRewardRelevent = DataUtils.CareerIsAllowedForItem(playerCareer, rewardItem) and
                                 DataUtils.SkillIsEnoughForItem(GameData.Player.Skills, rewardItem)

        
        -- Do something if the filter removes all rewards?        
        
        local isChoiceVisible = isRewardRelevent
        
        if( isChoiceVisible ) then
            numChoiceRewards = numChoiceRewards + 1
            TomeWindow.QuestJournal.visibleQuestRewardItems.choice[numChoiceRewards] = rewardItem
            local texture, x, y = GetIconData( rewardItem.iconNum )
            DynamicImageSetTexture( "TomeWindowQuestInfoChoiceReward"..numChoiceRewards.."IconBase", texture, x, y )    
            
            if ( rewardItem.stackCount > 1 )
            then
                WindowSetShowing( "TomeWindowQuestInfoChoiceReward"..numChoiceRewards.."Text", true )
                LabelSetText( "TomeWindowQuestInfoChoiceReward"..numChoiceRewards.."Text", L""..rewardItem.stackCount )
            else
                WindowSetShowing( "TomeWindowQuestInfoChoiceReward"..numChoiceRewards.."Text", false )
            end
        end
        WindowSetShowing("TomeWindowQuestInfoChoiceReward"..numChoiceRewards, isChoiceVisible )
    end
    
    for rewardIndex = numChoiceRewards+1,TomeWindow.NUM_CHOICE_REWARD_SLOTS do
        WindowSetShowing("TomeWindowQuestInfoChoiceReward"..rewardIndex, false )
    end
    
    -- Update the Choice Rewards Label
    WindowSetShowing("TomeWindowQuestInfoChoiceRewardsLabel", numChoiceRewards ~= 0 )
    LabelSetText("TomeWindowQuestInfoChoiceRewardsLabel", GetStringFormat( StringTables.Default.TEXT_CHOICE_REWARD_OFFER , { questRewards.maxChoices } ) )

    
    WindowClearAnchors("TomeWindowQuestInfoChoiceRewardsLabel" )   
    WindowAddAnchor( "TomeWindowQuestInfoChoiceRewardsLabel", "bottomleft", anchorWindow, "topleft", anchorOffsetX, 10 )
    
        
    PageWindowUpdatePages( "TomeWindowQuestInfoPageWindow" )
    PageWindowSetCurrentPage( "TomeWindowQuestInfoPageWindow", 1 )
    TomeWindow.OnQuestInfoUpdateNavButtons()
    
                   
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_QUEST_INFO, 
                                  GetString( StringTables.Default.LABEL_QUESTS ), 
                                  questData.name )  
end

function TomeWindow.QuestInfoUpdate( timePassed )
    if( TomeWindow.QuestJournal.currentQuestData == nil )
    then
        return
    end
    local questData = TomeWindow.QuestJournal.currentQuestData
    
    -- Timer
    local hasTimer = questData.maxTimer ~= 0
    if( hasTimer ) then     
        local text = TimeUtils.FormatClock( questData.timeLeft )
        LabelSetText( "TomeWindowQuestInfoTimerValue", text )     
    end
end

function TomeWindow.ToggleTrackQuest()

    local questId = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )    
    QuestUtils.ToggleTrackQuest( questId )
    
end

function TomeWindow.ToggleTrackQuestPin()
    local questId = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )    
    QuestUtils.ToggleTrackQuestMapPin( questId ) 
end



function TomeWindow.QuestInfoToggleTrackQuest()
    local questData = TomeWindow.QuestJournal.currentQuestData  
    QuestUtils.ToggleTrackQuest( questData.id )   
end

function TomeWindow.QuestInfoToggleTrackQuestPin()
    local questData = TomeWindow.QuestJournal.currentQuestData
    QuestUtils.ToggleTrackQuestMapPin( questData.id  )   
end


function TomeWindow.OnMouseOverGivenReward()
    if( TomeWindow.QuestJournal.currentQuestData == nil )
    then
        return
    end 
    
    local reward = WindowGetId(SystemData.ActiveWindow.name)
    
    if( reward == TomeWindow.MONEY_REWARD_ID )
    then        
        Tooltips.CreateMoneyTooltip( GetString( StringTables.Default.LABEL_MONEY ),
                                     TomeWindow.QuestJournal.visibleQuestRewardItems.money,
                                     SystemData.ActiveWindow.name,
                                     Tooltips.ANCHOR_WINDOW_RIGHT )
        
    elseif( reward == TomeWindow.XP_REWARD_ID )
    then
    
        Tooltips.CreateTextOnlyTooltip ( SystemData.ActiveWindow.name, nil )
        Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_XP ) )
        Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
        Tooltips.SetTooltipText( 2, 1, L""..TomeWindow.QuestJournal.visibleQuestRewardItems.xp )
        Tooltips.SetTooltipColorDef( 2, 1, Tooltips.COLOR_BODY )
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
        Tooltips.Finalize()
    else
    
        Tooltips.CreateItemTooltip( TomeWindow.QuestJournal.visibleQuestRewardItems.given[reward],
                                    SystemData.ActiveWindow.name, 
                                    Tooltips.ANCHOR_WINDOW_RIGHT )

    end
    
    
end

function TomeWindow.OnMouseOverChoiceReward() 
    if( TomeWindow.QuestJournal.currentQuestData == nil ) 
    then
        return
    end 
    
    local reward = WindowGetId(SystemData.ActiveWindow.name)
    Tooltips.CreateItemTooltip( TomeWindow.QuestJournal.visibleQuestRewardItems.choice[reward], 
                                SystemData.ActiveWindow.name, 
                                Tooltips.ANCHOR_WINDOW_RIGHT )
end

function TomeWindow.OnLButtonDownGivenReward( flags, x, y ) 
    if( TomeWindow.QuestJournal.currentQuestData == nil ) 
    then
        return
    end 
    
    local reward = WindowGetId(SystemData.ActiveWindow.name)
    
    -- Do nothing for Xp and Money Rewards
    if( reward == TomeWindow.MONEY_REWARD_ID or reward == TomeWindow.XP_REWARD_ID )
    then
        return
    end
    
    local itemData = TomeWindow.QuestJournal.visibleQuestRewardItems.given[reward]
    if( itemData == nil )
    then
        return
    end
    
    -- Create an Item Link on Shift-Left Click
    if( flags == SystemData.ButtonFlags.SHIFT )
    then
        EA_ChatWindow.InsertItemLink( itemData )
    end   
    
end

function TomeWindow.OnLButtonDownChoiceReward( flags, x, y ) 
    if( TomeWindow.QuestJournal.currentQuestData == nil ) 
    then
        return
    end 
    
    local reward = WindowGetId(SystemData.ActiveWindow.name)
    local itemData = TomeWindow.QuestJournal.visibleQuestRewardItems.choice[reward]
    if( itemData == nil )
    then
        return
    end      
    
    -- Create an Item Link on Shift-Left Click
    if( flags == SystemData.ButtonFlags.SHIFT )
    then           
        EA_ChatWindow.InsertItemLink( itemData )
    end   
    
end


function TomeWindow.AbandonQuest()
    if( TomeWindow.QuestJournal.currentQuestData == nil ) then
        return
    end 
    
    -- Create a Confirmation Dialog
    local text = GetStringFormat( StringTables.Default.TEXT_ABANDON_QUEST_CONFIRM, { TomeWindow.QuestJournal.currentQuestData.name } )
    DialogManager.MakeTwoButtonDialog( text, GetString( StringTables.Default.LABEL_ABANDON ), TomeWindow.DoAbandon, GetString( StringTables.Default.LABEL_CANCEL ), nil )
end

function TomeWindow.DoAbandon()    
    AbandonQuest (TomeWindow.QuestJournal.currentQuestData.id)
    
    local questIDTemp = TomeWindow.QuestJournal.currentQuestData.id
    TomeWindow.QuestJournal.currentQuestData = nil
        
    -- Flip the book back to the quest list page
    if not TomeWindow.stateHistoryQueue:IsEmpty() and TomeWindow.stateHistoryQueue:Back().pageType == TomeWindow.PAGE_QUEST_TOC
    then
        --just go back if we were already there rather than duplicating it in the history
        --this way we pop it off the top of history so the back button doesn't do nothing
        TomeWindow.GoBack()
    else
        TomeWindow.SetState( TomeWindow.PAGE_QUEST_TOC, {}, {TomeWindow.FLIP_BACKWARD_MULTI} )
    end

    --need to remove ALL tome history occurances of the quest we just removed
    --it may appear multiple times in the history
    local oldQueue = TomeWindow.stateHistoryQueue
    TomeWindow.stateHistoryQueue = Queue:Create()
    TomeWindow.stateHistoryCount = 0
    
    local curState = nil
    while( not oldQueue:IsEmpty() )
    do
        curState = oldQueue:PopBack()
        if not (curState.pageType == TomeWindow.PAGE_QUEST_INFO and curState.params ~= nil 
                and curState.params[1] == questIDTemp)
        then
            TomeWindow.stateHistoryQueue:PushFront(curState)
            TomeWindow.stateHistoryCount = TomeWindow.stateHistoryCount + 1
        else
            --DEBUG(L"Filtered out a page history instance of removed quest")
        end
    end
    --DEBUG(L"History count after filtering out quest: "..TomeWindow.stateHistoryCount)
end


function TomeWindow.ShareQuest()     
    ShareQuest (TomeWindow.QuestJournal.currentQuestData.id)
end

-- > Quest Info Nav Buttons
function TomeWindow.OnQuestInfoUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_QUEST_INFO ) then
        return
    end
    local curPage   = PageWindowGetCurrentPage("TomeWindowQuestInfoPageWindow")
    local numPages  = PageWindowGetNumPages("TomeWindowQuestInfoPageWindow")
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )
end

function TomeWindow.OnQuestInfoPreviousPage()
    TomeWindow.FlipPageWindowBackward( "TomeWindowQuestInfoPageWindow")
end

function TomeWindow.OnQuestInfoMouseOverPreviousPage()  
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("TomeWindowQuestInfoPageWindow")
    local numPages  = PageWindowGetNumPages("TomeWindowQuestInfoPageWindow")
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = TomeWindow.QuestJournal.currentQuestData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    else     
        -- Quest TOC
        lines[1] = GetString( StringTables.Default.TEXT_QUEST_TOC )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnQuestInfoNextPage()
    TomeWindow.FlipPageWindowForward( "TomeWindowQuestInfoPageWindow")
end

function TomeWindow.OnQuestInfoMouseOverNextPage()  
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("TomeWindowQuestInfoPageWindow")
    local numPages  = PageWindowGetNumPages("TomeWindowQuestInfoPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = TomeWindow.QuestJournal.currentQuestData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end


---------------------------------------------------------
-- > Quest Journal TOC Nav Buttons

function TomeWindow.OnQuestJournalTOCUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_QUEST_TOC ) then
        return
    end
    
    local curPage   = PageWindowGetCurrentPage("QuestTOCPageWindow")
    local numPages  = PageWindowGetNumPages("QuestTOCPageWindow")
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 1 <= numPages )  
end

function TomeWindow.OnQuestJournalTOCPreviousPage()
    TomeWindow.FlipPageWindowBackward( "QuestTOCPageWindow" )
end

function TomeWindow.OnQuestJournalTOCMouseOverPreviousPage()  
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("QuestTOCPageWindow")
    local numPages  = PageWindowGetNumPages("QuestTOCPageWindow")
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = GetString( StringTables.Default.LABEL_QUEST_JOURNAL )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnQuestJournalTOCNextPage()
    TomeWindow.FlipPageWindowForward( "QuestTOCPageWindow" )
end

function TomeWindow.OnQuestJournalTOCMouseOverNextPage()  
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("QuestTOCPageWindow")
    local numPages  = PageWindowGetNumPages("QuestTOCPageWindow")
    if( curPage + 1 <= numPages ) then
        -- Next Pages
        lines[1] = GetString( StringTables.Default.LABEL_QUEST_JOURNAL )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end


function TomeWindow.OnMouseOverQuestTypeIcon()

    local questId = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name) )
    local questData = DataUtils.GetQuestData( questId )    
    
    QuestUtils.CreateQuestTypeTooltip( questData, SystemData.MouseOverWindow.name )    
end



function TomeWindow.OnMouseOverQuestTOCSortButton()
    local index = WindowGetId( SystemData.ActiveWindow.name )    
    local text = TomeWindow.QuestJournal.sortData[index].desc

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )    
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP )  
end

-- Button Callback for the Tome Quest List sort buttons
function TomeWindow.OnClickQuestTOCSortButton()
    
    local type = WindowGetId( SystemData.ActiveWindow.name )
    
    -- If we are already using this sort type, toggle the order.
    if( type == TomeWindow.QuestJournal.curSortType ) then
        if( TomeWindow.QuestJournal.curSortOrder == TomeWindow.QuestJournal.SORT_ORDER_UP ) then
            TomeWindow.QuestJournal.curSortOrder = TomeWindow.QuestJournal.SORT_ORDER_DOWN
        else
            TomeWindow.QuestJournal.curSortOrder = TomeWindow.QuestJournal.SORT_ORDER_UP
        end
        
    -- Otherwise change the type and use the up order.  
    else
        TomeWindow.QuestJournal.curSortType = type
        TomeWindow.QuestJournal.curSortOrder = TomeWindow.QuestJournal.SORT_ORDER_UP
    end

    SortQuests()
    TomeWindow.UpdateQuestListDisplay()
    TomeWindow.UpdateQuestSortButtons()
    
end

-- Displays the clicked sort button as pressed down and positions an arrow above it
function TomeWindow.UpdateQuestSortButtons()

    local type = TomeWindow.QuestJournal.curSortType
    local order = TomeWindow.QuestJournal.curSortOrder

    
    for index, data in ipairs( TomeWindow.QuestJournal.sortData )
    do      
        ButtonSetPressedFlag( data.windowName, index == TomeWindow.QuestJournal.curSortType )       
    end
    
    -- Update the Arrow
    WindowSetShowing( "QuestTOCHeaderUpArrow", order == TomeWindow.QuestJournal.SORT_ORDER_UP )
    WindowSetShowing( "QuestTOCHeaderDownArrow", order == TomeWindow.QuestJournal.SORT_ORDER_DOWN )
            
    local window = TomeWindow.QuestJournal.sortData[type].windowName

    local arrowWindow = ""
    if( order == TomeWindow.QuestJournal.SORT_ORDER_UP ) then     
        arrowWindow = "QuestTOCHeaderUpArrow"
    else
        arrowWindow = "QuestTOCHeaderDownArrow"
    end
    
    WindowClearAnchors( arrowWindow )
    
    local anchorVertOffset = 8
    
    local textWidth = ButtonGetTextDimensions( window )
    if( textWidth > 0 )
    then
        WindowAddAnchor( arrowWindow, "top", window, "topleft", textWidth / 2 + 5, anchorVertOffset )
    else
        WindowAddAnchor( arrowWindow, "topright", window, "topright", -5, anchorVertOffset )
    end

end
