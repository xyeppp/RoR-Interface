----------------------------------------------------------------
-- Hyperlinking Functions
--
--  This file contains the implementation for inserting and 
--  processing Hyperlinks within the Chat Window.
----------------------------------------------------------------


-- Local Variables
local PLAYER_TAG    = L"PLAYER:"   -- Format: "PLAYER:<PlayerName>"             Example: "PLAYER:Bob"
local PLAYERNS_TAG  = L"PLAYERNS:" -- Format: "PLAYERNS:<PlayerName>"           Example: "PLAYERNS:Bob"  (no report spam)
local FRIENDED_TAG  = L"FRIENDED:" -- Format: "FRIENDED:<PlayerName>"           Example: "FRIENDED:Bob"
local ITEM_TAG      = L"ITEM:"     -- Format: "ITEM:<Item #>"                   Example: "ITEM:1234"
local QUEST_TAG     = L"QUEST:"    -- Format: "QUEST:<Quest #>"                 Example: "QUEST:5678"
local TOME_TAG      = L"TOME:"     -- Format: "TOME:<Section #>:<Entry #>"      Example: "TOME:2:55"
local GUILD_TAG     = L"GUILD:"    -- Format: "GUILD:<Guild #>"                 Example: "GUILD:1212"
local URL    		= L"URL:"      -- Format: "URL:<Url #>"                		Example: "URL:8" 
local ERASE         = L""

EA_ChatWindow.HyperLinks =
{
    Items       = {},
    Quests      = {},
    Abilities   = {},
    Guilds      = {},
    Urls        = {},	
}

local CLOSE_BUTTON_OFFSET = 12

----------------------------------------------------------------
-- Button Callbacks 
----------------------------------------------------------------

function EA_ChatWindow.OnHyperLinkLButtonUp( linkData, flags, x, y )
    --d( L"EA_ChatWindow.OnHyperLinkLButtonUp: "..linkData )
  
    -- Player Links
    local playerName, findCount = wstring.gsub( linkData, PLAYER_TAG, ERASE )
    if( findCount > 0  ) 
    then       
       EA_ChatWindow.OnPlayerLinkLButtonUp( playerName, flags, x, y )
       return
    end
    
    -- Player Links (No Report Spam)
    local playerName, findCount = wstring.gsub( linkData, PLAYERNS_TAG, ERASE )
    if( findCount > 0  ) 
    then       
       EA_ChatWindow.OnPlayerLinkLButtonUp( playerName, flags, x, y )
       return
    end
    
    -- Item Links
    local itemNumberText, findCount = wstring.gsub( linkData, ITEM_TAG, ERASE )
    if( findCount > 0  ) 
    then       
       EA_ChatWindow.OnItemLinkLButtonUp( tonumber(itemNumberText), flags, x, y )
       return
    end
    
    -- Quest Links
    local questNumberText, findCount = wstring.gsub( linkData, QUEST_TAG, ERASE )
    if( findCount > 0  ) 
    then       
       EA_ChatWindow.OnQuestLinkLButtonUp( tonumber(questNumberText), flags, x, y )
       return
    end
    
        
    -- Tome Links
    local tomeLinkText, findCount = wstring.gsub( linkData, TOME_TAG, ERASE )
    if( findCount > 0  ) 
    then       
       EA_ChatWindow.OnTomeLinkLButtonUp( tomeLinkText, flags, x, y )
       return
    end
    
            
    -- Guild Links
    local guildLinkText, findCount = wstring.gsub( linkData, GUILD_TAG, ERASE )
    if( findCount > 0  ) 
    then       
       EA_ChatWindow.OnGuildLinkLButtonUp( tonumber(guildLinkText), flags, x, y )
       return
    end
    
    -- Friended Links
    local playerName, findCount = wstring.gsub( linkData, FRIENDED_TAG, ERASE )
    if( findCount > 0  ) 
    then       
       EA_ChatWindow.OnFriendedLinkLButtonUp( playerName, flags, x, y )
       return
    end
	
	 local urlLink, findCount = wstring.gsub( linkData, URL, ERASE )
    if( findCount > 0  ) 
    then       
       EA_ChatWindow.OnUrlLinkLButtonUp(  tonumber(urlLink), flags, x, y )
       return
    end
end


function EA_ChatWindow.OnHyperLinkRButtonUp( linkData, flags, x, y )
    --d( L"EA_ChatWindow.OnHyperLinkRButtonUp: "..linkData )
  
    -- Player Links
    local playerName, findCount = wstring.gsub( linkData, PLAYER_TAG, ERASE )   
    if( findCount > 0  ) 
    then       
       EA_ChatWindow.OnPlayerLinkRButtonUp( playerName, flags, x, y )
       return
    end
    
end

-- This is a custom handler strictly for hyperlinks in a chat window and nowhere else
-- (ie - not chat bubbles or any other windows).
-- We want to ensure that if a hyperlink is clicked on, that we get the window ID
-- from a chat window only.  We keep the original EA_ChatWindow.OnHyperLinkRButtonUp() to
-- maintain functionality for other types of windows that need it.
function EA_ChatWindow.OnHyperLinkRButtonUpChatWindowOnly(linkData, flags, x, y)
    local wndGroupId = WindowGetId(SystemData.ActiveWindow.name)
    
    -- Player Links
    local playerName, findCount = wstring.gsub( linkData, PLAYER_TAG, ERASE )   
    if( findCount > 0  ) 
    then       
       EA_ChatWindow.OnPlayerLinkRButtonUp( playerName, flags, x, y, wndGroupId)
       return
    end
    
    -- Player Links (No Report Spam)
    local playerName, findCount = wstring.gsub( linkData, PLAYERNS_TAG, ERASE )   
    if( findCount > 0  ) 
    then       
       EA_ChatWindow.OnPlayerLinkRButtonUp( playerName, flags, x, y )  -- Leave off wndGroupId to suppress report spam option
       return
    end
end
----------------------------------------------------------------
-- Player Link Functions
----------------------------------------------------------------

function EA_ChatWindow.OnPlayerLinkLButtonUp( playerName, flags, x, y )
    --d( L"EA_ChatWindow.OnPlayerLinkLButtonUp: "..playerName )

    -- Open up a Tell window to the player
    
    playerName = wstring.gsub( playerName, L"(^.)", L"" )
    local text = L"/tell "..playerName..L" "
    EA_ChatWindow.SwitchChannelWithExistingText(text)

end

function EA_ChatWindow.OnUrlLinkLButtonUp( urlLink, flags, x, y )
	local function ClickCallBack( SelectedOption )
		    return function() OpenURL(SelectedOption) end
		end		
DialogManager.MakeTwoButtonDialog( L"This will open site \n"..towstring(GetStringFromTable("UrlStrings", urlLink))..L" in a web browser window \n\n Auto cancel in:", GetString(StringTables.Default.LABEL_YES),ClickCallBack(urlLink),GetString(StringTables.Default.LABEL_NO),nil,60,nil )
	
end


function EA_ChatWindow.OnPlayerLinkRButtonUp( playerName, flags, x, y, wndGroupId)
	
    local WindowGroup = wndGroupId
	local _X = x
	local _Y = y
	
if wndGroupId ~= nil then	
	local wndGroup = EA_ChatWindowGroups[wndGroupId]
    local activeTabId = wndGroup.activeTab
    local activeTabName = EA_ChatTabManager.GetTabName( wndGroup.Tabs[activeTabId].tabManagerId )
    
    local offendingMessage = towstring(LogDisplayGetStringFromCursorPos(activeTabName.."TextLog", x, y))
	local FormatedMessage = wstring.gsub(towstring(wstring.gsub(towstring(offendingMessage),L"<br>", L"")),L"\n", L"")
	
	ReportText = FormatedMessage
 end	
    local function PassParametersToReportSpam()
        PlayerMenuWindow.OnReportSpam(WindowGroup, _X, _Y)
    end
    
	local function ReportDialog()
      DialogManager.MakeTwoButtonDialog( L"Are you sure you want to report?", GetPregameString( StringTables.Pregame.LABEL_OKAY ) , PassParametersToReportSpam, GetPregameString( StringTables.Pregame.LABEL_CANCEL ), nil,60, 2, nil, nil, dialogType, DialogManager.TYPE_MODAL,_okDialog )
    end	
	
	
    local CustomButtons = {}
    
    if (wndGroupId ~= nil)
    then
        -- Create a Context Menu, make a custom button "Report Spam" that only appears
        -- when the player is clicking a player hyperlink in a chat window.
        table.insert(CustomButtons, PlayerMenuWindow.NewCustomItem(GetString( StringTables.Default.LABEL_PLAYER_MENU_REPORT_SPAM ), ReportDialog, false))
    end

    PlayerMenuWindow.ShowMenu( playerName, 0,  CustomButtons)

end

----------------------------------------------------------------
-- Tome Link Functions
----------------------------------------------------------------

function EA_ChatWindow.OnTomeLinkLButtonUp( linkData, flags, x, y )
    --d( L"EA_ChatWindow.OnTomeLinkLButtonUp: "..linkData )

    -- Use the Standard HyperLinking
    TomeWindow.OnHyperLinkClicked( linkParam )

end


----------------------------------------------------------------
-- Item Link Functions
----------------------------------------------------------------

function EA_ChatWindow.InsertItemLink( itemData )
    
    if( itemData == nil )
    then
        return
    end

    local data  = ITEM_TAG..itemData.uniqueID 
    local text  = L"["..itemData.name..L"]"    
    local color = DataUtils.GetItemRarityColor(itemData)
    
    local link  = CreateHyperLink( data, text, {color.r,color.g,color.b}, {} )
    
    EA_ChatWindow.InsertText( link )
end

function EA_ChatWindow.OnItemLinkLButtonUp( itemId, flags, x, y )
    
    -- Spawn a Item HyperLink Window
    -- These look like item tooltips, but are movable and have a close button.
    EA_ChatWindow.CreateItemLinkWindow( itemId )
end

function EA_ChatWindow.CreateItemLinkWindow( itemId )
    
    if( itemId == nil )
    then
        return
    end
    
    local itemData = GetDatabaseItemData( itemId )
    if( not itemData )
    then
        -- Show an error message
        return
    end
        
    local windowName = "EA_ItemLinkWindow"..itemId    
    
    -- Only allow one window per item
    if( DoesWindowExist( windowName ) )
    then
        -- Re-Showing the window will force it to the top of it's layer 
        -- if it is behind annother window.
        WindowSetShowing( windowName, true )
        return
    end    
    
    -- Cache a reference to the data
    EA_ChatWindow.HyperLinks.Items[ itemId ] = itemData
       
    -- Create the Window & Set the Data
    if( itemData.broken )
    then
        CreateWindowFromTemplate( windowName, "EA_Window_BrokenItemLinkTemplate", "Root" )
        
        Tooltips.SetItemTooltipData( windowName.."DataRepairedItem", itemData, extraText, extraTextColor )
        BrokenItemTooltip.SetTooltipData( windowName.."Data", itemData )
        WindowSetShowing( windowName.."DataSellPrice", false )
        WindowSetShowing( windowName.."DataRepairedItemBackground", false )
    else    
        CreateWindowFromTemplate( windowName, "EA_Window_ItemLinkTemplate", "Root" )
        
        Tooltips.SetItemTooltipData( windowName.."Data", itemData, nil, nil )
    end
        
    WindowSetId( windowName, itemId )

    -- Size the Parent Window to the data's dimensions
    local x, y = WindowGetDimensions( windowName.."Data" )
    x = x + CLOSE_BUTTON_OFFSET
    y = y + CLOSE_BUTTON_OFFSET
    WindowSetDimensions( windowName, x, y )
    
    -- Position the window on the screen
    WindowAddAnchor( windowName, "center", "Root", "center", 0, 0 )
    WindowSetShowing( windowName, true )
end

function EA_ChatWindow.OnHiddenItemLinkWindow()

    WindowUtils.OnHidden()
    
    -- Clear the Data
    local itemId = WindowGetId( SystemData.ActiveWindow.name )
    EA_ChatWindow.HyperLinks.Items[ itemId ] = nil
    
    -- Destroy the Window
    DestroyWindow( SystemData.ActiveWindow.name )
end


function EA_ChatWindow.OnLButtonDownItemLinkWindow( flags, x, y )
    
    -- Create an Item Link on Shift-Left Click
    if( flags == SystemData.ButtonFlags.SHIFT )
    then    
        local itemId = WindowGetId( SystemData.ActiveWindow.name )
        local itemData = EA_ChatWindow.HyperLinks.Items[ itemId ]
                
        EA_ChatWindow.InsertItemLink( itemData )
        
        WindowSetMoving( SystemData.ActiveWindow.name, false )
    end
end


----------------------------------------------------------------
-- Quest Link Functions
----------------------------------------------------------------

function EA_ChatWindow.InsertQuestLink( questData )
    
    if( questData == nil )
    then
        return
    end

    local data  = QUEST_TAG..questData.id 
    local text  = L"["..questData.name..L"]"    
    local color = DefaultColor.GOLD
    
    local link  = CreateHyperLink( data, text, {color.r,color.g,color.b}, {} )
    
    EA_ChatWindow.InsertText( link )
end


function EA_ChatWindow.OnQuestLinkLButtonUp( questId, flags, x, y )
    
    -- Spawn a Quest HyperLink Window
    -- These look like Interaction Quest Offer Window, but are movable and have a close button.
    EA_ChatWindow.CreateQuestLinkWindow( questId )
end

function EA_ChatWindow.CreateQuestLinkWindow( questId )
    
    if( questId == nil )
    then
        return
    end
    
    local windowName = "EA_QuestLinkWindow"..questId    
    
    -- Only allow one window per item
    if( DoesWindowExist( windowName ) )
    then
        -- Re-Showing the window will force it to the top of it's layer 
        -- if it is behind annother window.
        WindowSetShowing( windowName, true )
        return
    end    
    
    local questData = GetDatabaseQuestData( questId )
    if( not questData )
    then
        -- Show an error message
        return
    end      
    
    -- Cache a reference to the data
    EA_ChatWindow.HyperLinks.Quests[ questId ] = questData
    
    -- Create the Window
    CreateWindowFromTemplate( windowName, "EA_Window_QuestLinkTemplate", "Root" )
    WindowSetId( windowName, questId )
    
    -- Set the Data
    EA_ChatWindow.LayoutQuestWindow( windowName, questData )
    
    -- Position the window on the screen
    WindowAddAnchor( windowName, "center", "Root", "center", 0, 0 )
    WindowSetShowing( windowName, true )

end

function EA_ChatWindow.OnHiddenQuestLinkWindow()
    
    WindowUtils.OnHidden()
    
    -- Clear the Data
    local questId = WindowGetId( SystemData.ActiveWindow.name )
    EA_ChatWindow.HyperLinks.Quests[ questId ] = nil
    
    -- Destroy the Window
    DestroyWindow( SystemData.ActiveWindow.name )    
    
end

function EA_ChatWindow.OnLButtonDownQuestLinkWindow( flags, x, y)
   
    -- Create an Quest Link on Shift-Left Click
    if( flags == SystemData.ButtonFlags.SHIFT )
    then    
        local questId = WindowGetId( SystemData.ActiveWindow.name )
        local questData = EA_ChatWindow.HyperLinks.Quests[ questId ]
                
        EA_ChatWindow.InsertQuestLink( questData )
        
        WindowSetMoving( SystemData.ActiveWindow.name, false )
    end
end

--
-- Layout and Content Functions
--

function EA_ChatWindow.LayoutQuestWindow( windowName, questData )

    -- Quest Name
    LabelSetText(windowName.."TitleLabel", questData.name )

	local G_Name = towstring(GameData.Guild.m_GuildName) or L"Guildless"
	local mainText = questData.startDesc
	mainText = wstring.gsub(towstring(mainText), L"|g",G_Name)	
    -- Quest Starting Text
    LabelSetText(windowName.."InfoScrollChildText", mainText )
    
    local scrollWindowHeight = 0
    local _, textHeight = LabelGetTextDimensions(windowName.."InfoScrollChildText")
    local scrollWindowHeight = textHeight + 31 -- magic 31 is the amount of anchoring between weapons
    WindowSetDimensions( windowName.."InfoScrollChildText",
                         EA_Window_InteractionQuest.QUEST_TEXT_WIDTH_EXTENT, textHeight )
    
    -- Quest Journal Text
 	local journalDesc = questData.journalDesc
	journalDesc = wstring.gsub(towstring(journalDesc), L"|g",G_Name)		
	
    LabelSetText(windowName.."InfoScrollChildJournalEntryText", journalDesc )
    
    
    local _, textHeight = LabelGetTextDimensions( windowName.."InfoScrollChildJournalEntryText" )
    scrollWindowHeight = scrollWindowHeight + textHeight
    WindowSetDimensions( windowName.."InfoScrollChildJournalEntryText", EA_Window_InteractionQuest.QUEST_TEXT_WIDTH_EXTENT, textHeight )
    WindowSetShowing(windowName.."InfoScrollChildJournalEntryText", true)

    local _, windowHeight = WindowGetDimensions( windowName.."InfoScrollChildDivider")
    WindowSetShowing(windowName.."InfoScrollChildDivider", true)
    scrollWindowHeight = scrollWindowHeight + windowHeight + 26 -- magic 26 is the anchor padding on the top and bottom of the divider

    -- DEBUG(L" scrollWindowHeight = "..scrollWindowHeight)
    scrollWindowHeight = scrollWindowHeight + EA_ChatWindow.LayoutTimer( windowName, questData )   
    -- DEBUG(L" +timer             = "..scrollWindowHeight)
    scrollWindowHeight = scrollWindowHeight + EA_ChatWindow.LayoutConditions( windowName, questData )  
    -- DEBUG(L" +conditions        = "..scrollWindowHeight)
    scrollWindowHeight = scrollWindowHeight + EA_ChatWindow.LayoutGivenRewards( windowName, questData )  
    -- DEBUG(L" +rewards           = "..scrollWindowHeight)
    scrollWindowHeight = scrollWindowHeight + EA_ChatWindow.LayoutChoiceRewards( windowName, questData )  
    -- DEBUG(L" +choicerewards     = "..scrollWindowHeight)


    local _, windowHeight = WindowGetDimensions( windowName.."InfoScrollChildConditionsDivider")
    WindowSetShowing(windowName.."InfoScrollChildConditionsDivider", true)
    scrollWindowHeight = scrollWindowHeight + windowHeight + 26 -- magic 26 is the anchor padding on the sides of the divider
    -- DEBUG(L" +condition divider = "..scrollWindowHeight)

    
    -- Resize the window based on how big the scroll window is
    if (scrollWindowHeight >= EA_Window_InteractionQuest.SCROLL_WINDOW_MAXIMUM_HEIGHT)
    then
        -- We don't need to shrink the window, so set it to it's maximum.
        WindowSetDimensions( windowName,
                             EA_Window_InteractionQuest.QUEST_WINDOW_WIDTH, EA_Window_InteractionQuest.QUEST_WINDOW_HEIGHT )
        WindowSetDimensions( windowName.."Info",
                             EA_Window_InteractionQuest.QUEST_WINDOW_WIDTH, EA_Window_InteractionQuest.SCROLL_WINDOW_MAXIMUM_HEIGHT )
    else
        -- Determine how much shorter the main window should be
        local heightDifference = EA_Window_InteractionQuest.SCROLL_WINDOW_MAXIMUM_HEIGHT - scrollWindowHeight
        -- DEBUG(L"  Max Scroll Height: "..EA_Window_InteractionQuest.SCROLL_WINDOW_MAXIMUM_HEIGHT..L"  heightDifference = "..heightDifference)
        -- DEBUG(L"  Max Window Height: "..EA_Window_InteractionQuest.QUEST_WINDOW_HEIGHT..L"  "..EA_ChatWindow.QUEST_WINDOW_HEIGHT - heightDifference)
        WindowSetDimensions( windowName,
                             EA_Window_InteractionQuest.QUEST_WINDOW_WIDTH, EA_Window_InteractionQuest.QUEST_WINDOW_HEIGHT - heightDifference )
        WindowSetDimensions( windowName.."Info",
                             EA_Window_InteractionQuest.QUEST_WINDOW_WIDTH, scrollWindowHeight )
    end
    
    -- Update the scroll window 
    ScrollWindowSetOffset( windowName.."Info", 0 )
    ScrollWindowUpdateScrollRect( windowName.."Info" )
    
    
    -- Set the Button Text
    ButtonSetText( windowName.."Done",     GetString( StringTables.Default.LABEL_CLOSE ))
    
end

function EA_ChatWindow.LayoutTimer( windowName, questData )
    -- Timer
    local timer = questData.maxTimer
    local text = TimeUtils.FormatClock(timer)
    LabelSetText( windowName.."InfoScrollChildTimerValue", text ) 
    WindowSetShowing(windowName.."InfoScrollChildTimer", timer > 0 )   
    
    local windowWidth, _ = WindowGetDimensions(windowName.."InfoScrollChildTimer")
    if( timer > 0 )
    then        
        local _, textHeight = LabelGetTextDimensions( windowName.."InfoScrollChildTimerValue" )
        WindowSetDimensions( windowName.."InfoScrollChildTimer", windowWidth, textHeight )
        return textHeight
    else
        WindowSetDimensions( windowName.."InfoScrollChildTimer", windowWidth, 0 )
        return 0
    end
end

function EA_ChatWindow.LayoutConditions( windowName, questData )

    local conditionText = L""
    local conditionsExist = false
    local conditionsTotalHeight = 0


    -- Conditions
    for condition = 1, EA_Window_InteractionQuest.NUM_CONDITION_COUNTERS
    do
        local conditionData = questData.conditions[condition];
        local conditionWindowName = windowName.."InfoScrollChildConditions"..condition        
        
        if( conditionData ~= nil )
        then
            local conditionName = conditionData.name
            local curCounter    = conditionData.curCounter
            local maxCounter    = conditionData.maxCounter
        
            local iconData = QuestUtils.PENDING_QUEST_ICON
            
            conditionsExist = true
            local conditionCounters = L""

            if( maxCounter > 0 )
            then
                local conditionCounterString = GetStringFormat( StringTables.Default.TEXT_CONDITION_COUNTER_FORMAT, {curCounter, maxCounter} )
                conditionCounters = conditionCounterString
                
                if( maxCounter == curCounter )
                then
                    iconData = QuestUtils.COMPLETE_QUEST_ICON
                end
            end

            conditionText = conditionName..L" "..conditionCounters
            LabelSetText( conditionWindowName.."Label", conditionText )

            -- Size the conditions text
            local _, conditionHeight = LabelGetTextDimensions( conditionWindowName.."Label" )
            
            conditionHeight = conditionHeight + 5 -- 5 is the anchor offset of the Label from the condition<N> window
            
            if( iconData.height > conditionHeight )
            then
                conditionHeight = iconData.height
            end

            conditionsTotalHeight = conditionsTotalHeight + conditionHeight + 5 -- 5 is the anchor offset between conditions
            
            DynamicImageSetTexture( conditionWindowName.."Icon", iconData.texture, iconData.x, iconData.y )
            WindowSetDimensions(conditionWindowName, EA_Window_InteractionQuest.QUEST_TEXT_WIDTH_EXTENT, conditionHeight)
            WindowSetShowing(conditionWindowName, true)
        else
            WindowSetShowing(conditionWindowName, false)
        end
    end

    if( conditionsExist )
    then    
        WindowSetDimensions(windowName.."InfoScrollChildConditions", EA_Window_InteractionQuest.QUEST_TEXT_WIDTH_EXTENT, conditionsTotalHeight)
        WindowSetShowing(windowName.."InfoScrollChildConditions", true)
        return conditionsTotalHeight
    
    else
        WindowSetDimensions(windowName.."InfoScrollChildConditions",  EA_Window_InteractionQuest.QUEST_TEXT_WIDTH_EXTENT, 0)
        WindowSetShowing(windowName.."InfoScrollChildConditions",     false)
        return 0
    end
    
end

function EA_ChatWindow.LayoutGivenRewards( windowName, questData )

    local questRewards = questData.rewards

    local xpShowing    = (questRewards.xp> 0)
    local moneyShowing = (questRewards.money > 0)
    
    -- Given Rewards
    local numGivenRewards = 0
    
    if xpShowing
    then
        numGivenRewards = numGivenRewards + 1
                
        -- Construct the Fake Xp Icon
        -- DEBUG(L"  XP Reward "..questRewards.xp)
        WindowSetShowing( windowName.."InfoScrollChildGivenRewards"..numGivenRewards, true )
        local texture, x, y = GetIconData( Icons.XP_REWARD )
        DynamicImageSetTexture( windowName.."InfoScrollChildGivenRewards"..numGivenRewards.."IconBase", texture, x, y ) 
        WindowSetId( windowName.."InfoScrollChildGivenRewards"..numGivenRewards, EA_Window_InteractionQuest.XP_REWARD_ID )
    end
    
    if moneyShowing
    then
        numGivenRewards = numGivenRewards + 1
                
        -- Construct the Fake old Icon
        -- DEBUG(L"  Money Reward "..questRewards.money)
        WindowSetShowing( windowName.."InfoScrollChildGivenRewards"..numGivenRewards, true )
        local texture, x, y = GetIconData( Icons.GOLD_REWARD )
        DynamicImageSetTexture( windowName.."InfoScrollChildGivenRewards"..numGivenRewards.."IconBase", texture, x, y ) 
        WindowSetId( windowName.."InfoScrollChildGivenRewards"..numGivenRewards, EA_Window_InteractionQuest.MONEY_REWARD_ID )
    end
    
    -- Actual Items
    for rewardIndex, rewardItem in ipairs(questRewards.itemsGiven)
    do 
        numGivenRewards = numGivenRewards + 1
        -- DEBUG( L"  Given Reward #"..rewardIndex..L" = "..rewardItem.name..L", stored at index "..numGivenRewards )
        WindowSetShowing( windowName.."InfoScrollChildGivenRewards"..numGivenRewards, true )
        local texture, x, y = GetIconData( rewardItem.iconNum )
        DynamicImageSetTexture( windowName.."InfoScrollChildGivenRewards"..numGivenRewards.."IconBase", texture, x, y ) 
        WindowSetId( windowName.."InfoScrollChildGivenRewards"..numGivenRewards, rewardIndex )
    end

    for rewardIndex = numGivenRewards+1,EA_Window_InteractionQuest.NUM_GIVEN_REWARD_SLOTS
    do
        WindowSetShowing(windowName.."InfoScrollChildGivenRewards"..rewardIndex, false )
    end
    
    -- Resize the given rewards container
    -- Hide the Rewards for 'pending' quests
    local rewardsExist = ( (numGivenRewards ~= 0) or xpShowing or moneyShowing )
    if ( rewardsExist )
    then
        WindowSetShowing( windowName.."InfoScrollChildGivenRewards", true )
        
        local rewardRows = 1
        if (numGivenRewards > 5)
        then
            rewardRows = 2
        end
        
        local windowHeight = rewardRows * EA_Window_InteractionQuest.REWARD_BUTTON_HEIGHT
        WindowSetDimensions( windowName.."InfoScrollChildGivenRewards",
                             EA_Window_InteractionQuest.BASE_QUEST_SCROLL_CHILD_WINDOW_WIDTH,
                             windowHeight )
        return windowHeight
    else
        WindowSetShowing( windowName.."InfoScrollChildGivenRewards", false )
        WindowSetDimensions( windowName.."InfoScrollChildGivenRewards",
                             EA_Window_InteractionQuest.BASE_QUEST_SCROLL_CHILD_WINDOW_WIDTH,
                             0 )
        return 0
    end

end

function EA_ChatWindow.LayoutChoiceRewards( windowName, questData )
    
    local questRewards = questData.rewards

     -- Choice Rewards
    local numChoiceRewards = 0
    for rewardIndex, rewardItem in ipairs(questRewards.itemsChosen) do
    
        local playerCareer = GameData.Player.career.line
        
        -- Filter the choices, don't display any that are unusable by the character's career
        local isRewardRelevent = DataUtils.CareerIsAllowedForItem(playerCareer, rewardItem) and
                                 DataUtils.SkillIsEnoughForItem(GameData.Player.Skills, rewardItem)

        
        -- Do something if the filter removes all rewards?        
        
        local isChoiceVisible = isRewardRelevent
        
        -- DEBUG( L"Choice Reward #"..reward..L" = "..rewardName..L", icon = "..rewardIcon )
        if( isChoiceVisible ) 
        then
            numChoiceRewards = numChoiceRewards + 1
            local texture, x, y = GetIconData( rewardItem.iconNum )
            DynamicImageSetTexture( windowName.."InfoScrollChildChoiceRewards"..numChoiceRewards.."IconBase", texture, x, y )    
        end
        WindowSetShowing(windowName.."InfoScrollChildChoiceRewards"..numChoiceRewards, isChoiceVisible )
    end
    
    for rewardIndex = numChoiceRewards+1,EA_Window_InteractionQuest.NUM_CHOICE_REWARD_SLOTS do
        WindowSetShowing(windowName.."InfoScrollChildChoiceRewards"..rewardIndex, false )
    end
    
    
    local windowHeight = 0
    -- Resize the choice rewards container
    local choicesExist = (numChoiceRewards ~= 0)
    if ( choicesExist )
    then
        WindowSetShowing( windowName.."InfoScrollChildChoiceRewards", true )
        
        local rewardRows = 1
        if (numChoiceRewards > 5)
        then
            rewardRows = 2
        end
        
        windowHeight = rewardRows * EA_Window_InteractionQuest.REWARD_BUTTON_HEIGHT
        WindowSetDimensions( windowName.."InfoScrollChildChoiceRewards",
                             EA_Window_InteractionQuest.BASE_QUEST_SCROLL_CHILD_WINDOW_WIDTH,
                             windowHeight )
    else
        WindowSetShowing( windowName.."InfoScrollChildChoiceRewards", false )
        WindowSetDimensions( windowName.."InfoScrollChildChoiceRewards",
                             EA_Window_InteractionQuest.BASE_QUEST_SCROLL_CHILD_WINDOW_WIDTH,
                             0 )
    end
    
    -- Update the Choice Rewards Label
    WindowSetShowing(windowName.."InfoScrollChildChoiceRewardsLabel", numChoiceRewards ~= 0 )
    local maxChoices = questRewards.maxChoices
    LabelSetText(windowName.."InfoScrollChildChoiceRewardsLabel", GetStringFormat( StringTables.Default.TEXT_CHOICE_REWARD , { maxChoices } ) )

    return windowHeight
end

function EA_ChatWindow.OnMouseOverQuestLinkGivenReward()

end


-- Mouse Handlers

local function GetQuestIdFromRewardWindow( rewardWindow )

    local numParentLevels = 4
    
    local windowName = rewardWindow
    for index = 1, numParentLevels 
    do
        windowName = WindowGetParent( windowName)
    end
    
    return WindowGetId( windowName )
end

function EA_ChatWindow.OnMouseOverHyperLinkQuestGivenReward()
    
    local rewardIndex   = WindowGetId(SystemData.ActiveWindow.name)    
    local questId       = GetQuestIdFromRewardWindow(SystemData.ActiveWindow.name)    
    local questData     = EA_ChatWindow.HyperLinks.Quests[ questId ]  
    
    if( rewardIndex == EA_Window_InteractionQuest.MONEY_REWARD_ID )
    then        
        Tooltips.CreateMoneyTooltip( GetString( StringTables.Default.LABEL_MONEY ),
                                     questData.rewards.money,
                                     SystemData.ActiveWindow.name,
                                     Tooltips.ANCHOR_WINDOW_RIGHT )
        
    elseif( rewardIndex == EA_Window_InteractionQuest.XP_REWARD_ID )
    then
    
        Tooltips.CreateTextOnlyTooltip ( SystemData.ActiveWindow.name, nil )
        Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_XP ) )
        Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
        Tooltips.SetTooltipText( 2, 1, L""..questData.rewards.xp )
        Tooltips.SetTooltipColorDef( 2, 1, Tooltips.COLOR_BODY )
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
        Tooltips.Finalize()
    else
    
        local itemData = questData.rewards.itemsGiven[rewardIndex]
        if( itemData == nil )
        then
            return
        end
    
        Tooltips.CreateItemTooltip( itemData,
                                    SystemData.ActiveWindow.name, 
                                    Tooltips.ANCHOR_WINDOW_RIGHT )

    end
    
    
end

function EA_ChatWindow.OnMouseOverHyperLinkQuestChoiceReward() 

    local rewardIndex   = WindowGetId(SystemData.ActiveWindow.name)    
    local questId       = GetQuestIdFromRewardWindow(SystemData.ActiveWindow.name)    
    local questData     = EA_ChatWindow.HyperLinks.Quests[ questId ]       

    local itemData = questData.rewards.itemsChosen[rewardIndex]
    if( itemData == nil )
    then
        return
    end
    
    Tooltips.CreateItemTooltip( itemData, 
                                SystemData.ActiveWindow.name, 
                                Tooltips.ANCHOR_WINDOW_RIGHT )
end

function EA_ChatWindow.OnLButtonDownHyperLinkQuestGivenReward( flags, x, y ) 

    local rewardIndex   = WindowGetId(SystemData.ActiveWindow.name)    
    
    -- Do nothing for Xp and Money Rewards
    if( rewardIndex == EA_Window_InteractionQuest.MONEY_REWARD_ID or rewardIndex == EA_Window_InteractionQuest.XP_REWARD_ID )
    then
        return
    end
    
    local questId       = GetQuestIdFromRewardWindow(SystemData.ActiveWindow.name)    
    local questData     = EA_ChatWindow.HyperLinks.Quests[ questId ]   

    local itemData = questData.rewards.itemsGiven[rewardIndex]
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

function EA_ChatWindow.OnLButtonDownHyperLinkQuestChoiceReward( flags, x, y ) 

    
    local rewardIndex   = WindowGetId(SystemData.ActiveWindow.name)        
    local questId       = GetQuestIdFromRewardWindow(SystemData.ActiveWindow.name)    
    local questData     = EA_ChatWindow.HyperLinks.Quests[ questId ]       

    local itemData = questData.rewards.itemsChosen[rewardIndex]
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



----------------------------------------------------------------
-- Guild Link Functions
----------------------------------------------------------------

function EA_ChatWindow.InsertGuildLink( guildData )
    
    if( guildData == nil )
    then
        return
    end

    local data  = GUILD_TAG..guildData.id 
    local text  = L"["..guildData.name..L"]"    
    local color = DefaultColor.ORANGE 
    
    local link  = CreateHyperLink( data, text, {color.r,color.g,color.b}, {} )
    
    EA_ChatWindow.InsertText( link )
end

function EA_ChatWindow.OnGuildLinkLButtonUp( guildId, flags, x, y )
    if( flags == SystemData.ButtonFlags.SHIFT )
    then
        local guildData = GetDatabaseGuildData( guildId )
        if( not guildData )
        then
            return
        end
        EA_ChatWindow.InsertGuildLink( guildData )
        
        return
    end
    -- Spawn a Guild HyperLink Window
    -- These look like guild profile search details, but are movable and have a close button.
    EA_ChatWindow.CreateGuildLinkWindow( guildId )
end

function EA_ChatWindow.CreateGuildLinkWindow( guildId )
    
    if( guildId == nil )
    then
        return
    end
    
    local guildData = GetDatabaseGuildData( guildId )
    if( not guildData )
    then
        -- Show an error message
        return
    end
        
    local windowName = "EA_GuildLinkWindow"..guildId    
    
    -- Only allow one window per item
    if( DoesWindowExist( windowName ) )
    then
        -- Re-Showing the window will force it to the top of it's layer 
        -- if it is behind annother window.
        WindowSetShowing( windowName, true )
        return
    end
    
    
    -- Cache a reference to the data
    EA_ChatWindow.HyperLinks.Guilds[ guildId ] = guildData
    
    -- Create the Window
    CreateWindowFromTemplate( windowName, "EA_Window_GuildLinkTemplate", "Root" )
    WindowSetId( windowName, guildId )
    
    -- Set the Data
    GuildWindowTabRecruit.InitGuildProfileData( windowName.."Data" )
    GuildWindowTabRecruit.SetGuildProfileData( windowName.."Data", guildData )
    
    -- Position the window on the screen
    WindowAddAnchor( windowName, "center", "Root", "center", 0, 0 )
    WindowSetShowing( windowName, true )
end

function EA_ChatWindow.DestroyGuildLinkWindow()
    
    -- Clear the Data
    local guildId = WindowGetId( SystemData.ActiveWindow.name )
    EA_ChatWindow.HyperLinks.Guilds[ guildId ] = nil
    
    -- Destroy the Window
    DestroyWindow( WindowGetParent( SystemData.ActiveWindow.name) )
end


function EA_ChatWindow.OnLButtonDownGuildLinkWindow( flags, x, y )
    
    -- Create an Item Link on Shift-Left Click
    if( flags == SystemData.ButtonFlags.SHIFT )
    then    
        local guildId = WindowGetId( SystemData.ActiveWindow.name )
        local guildData = EA_ChatWindow.HyperLinks.Guilds[ guildId ]
                
        EA_ChatWindow.InsertGuildLink( guildData )
        
        WindowSetMoving( SystemData.ActiveWindow.name, false )
    end
end

----------------------------------------------------------------
-- Friended Link Functions
----------------------------------------------------------------

function EA_ChatWindow.OnFriendedLinkLButtonUp( playerName, flags, x, y )

    if ( SocialWindow and SocialWindow.IsPlayerOnFriendsList( playerName ) )
    then
        return
    end
    
    -- friend the player
    playerName = wstring.gsub( playerName, L"(^.)", L"" )
    SendChatText( L"/friend "..playerName, L"" )
end
