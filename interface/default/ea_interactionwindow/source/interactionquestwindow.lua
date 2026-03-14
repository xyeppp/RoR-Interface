----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_InteractionQuest = {}
EA_Window_InteractionQuest.givenRewardFrames = {}

EA_Window_InteractionQuest.NUM_CONDITION_COUNTERS = 10
EA_Window_InteractionQuest.VIRTUAL_REWARD_SLOTS   = 1 + 1 -- XP and Gold rewards.
EA_Window_InteractionQuest.NUM_GIVEN_REWARD_SLOTS = 10 + EA_Window_InteractionQuest.VIRTUAL_REWARD_SLOTS
EA_Window_InteractionQuest.NUM_CHOICE_REWARD_SLOTS = 10

EA_Window_InteractionQuest.REWARD_BUTTON_HEIGHT = 55
EA_Window_InteractionQuest.LABEL_HEIGHT         = 24

EA_Window_InteractionQuest.QUEST_WINDOW_WIDTH  = 512
EA_Window_InteractionQuest.QUEST_WINDOW_HEIGHT = 700
EA_Window_InteractionQuest.SCROLL_WINDOW_MAXIMUM_HEIGHT = 500
EA_Window_InteractionQuest.BASE_QUEST_SCROLL_WINDOW_WIDTH = 512
EA_Window_InteractionQuest.BASE_QUEST_SCROLL_CHILD_WINDOW_WIDTH = 422
EA_Window_InteractionQuest.QUEST_TEXT_WIDTH_EXTENT = 412

EA_Window_InteractionQuest.numSelectedRewards = 0

EA_Window_InteractionQuest.TOOLTIP_ANCHOR = { Point = "topright", RelativeTo = "EA_Window_InteractionQuest", RelativePoint = "topleft",    XOffset=5, YOffset=75 }

EA_Window_InteractionQuest.choiceRewardsData = nil
EA_Window_InteractionQuest.givenRewardsData  = nil

EA_Window_InteractionQuest.questGiverID      = nil
EA_Window_InteractionQuest.MONEY_REWARD_ID   = -1
EA_Window_InteractionQuest.XP_REWARD_ID      = -2

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------


----------------------------------------------------------------
-- EA_Window_InteractionQuest Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_InteractionQuest.Initialize()
    
    -- Main Window  
    WindowRegisterEventHandler( "EA_Window_InteractionQuest", SystemData.Events.INTERACT_SHOW_QUEST,    "EA_Window_InteractionQuest.ShowQuestFrame")
    WindowRegisterEventHandler( "EA_Window_InteractionQuest", SystemData.Events.INTERACT_DONE,          "EA_Window_InteractionQuest.Hide")

    -- Labels
    LabelSetText("EA_Window_InteractionQuestInfoScrollChildTimerText",      GetString( StringTables.Default.TEXT_QUEST_TIME_LIMIT ) )
    LabelSetText("EA_Window_InteractionQuestInfoScrollChildRewardsLabel",   GetString( StringTables.Default.LABEL_REWARDS )..L":")
    
    -- Buttons
    ButtonSetText("EA_Window_InteractionQuestBack",     GetString( StringTables.Default.LABEL_GO_BACK ))
    ButtonSetText("EA_Window_InteractionQuestDone",     GetString( StringTables.Default.LABEL_DONE ))
    ButtonSetText("EA_Window_InteractionQuestAccept",   GetString( StringTables.Default.LABEL_ACCEPT ))
    ButtonSetText("EA_Window_InteractionQuestDecline",  GetString( StringTables.Default.LABEL_DECLINE ))
    ButtonSetText("EA_Window_InteractionQuestComplete", GetString( StringTables.Default.LABEL_COMPLETE ))
    
    for btn = 1, EA_Window_InteractionQuest.NUM_CHOICE_REWARD_SLOTS
    do
        ButtonSetStayDownFlag( "EA_Window_InteractionQuestInfoScrollChildChoiceReward"..btn, true )
    end
    
    EA_Window_InteractionQuest.givenRewardFrames = {}
    EA_Window_InteractionQuest.InitializeFrames()
    
    WindowSetAlpha("EA_Window_InteractionQuestOfferBackground",    InteractionUtils.BASE_BACKGROUND_ALPHA)
    WindowSetAlpha("EA_Window_InteractionQuestPendingBackground",  InteractionUtils.BASE_BACKGROUND_ALPHA)
    WindowSetAlpha("EA_Window_InteractionQuestCompleteBackground", InteractionUtils.BASE_BACKGROUND_ALPHA)
end


-- OnShutdown Handler
function EA_Window_InteractionQuest.Shutdown()
    WindowUnregisterEventHandler( "EA_Window_InteractionQuest", SystemData.Events.INTERACT_SHOW_QUEST )
    WindowUnregisterEventHandler( "EA_Window_InteractionQuest", SystemData.Events.INTERACT_DONE )
end

function EA_Window_InteractionQuest.OnShown()
    WindowUtils.OnShown(EA_Window_InteractionQuest.Hide, WindowUtils.Cascade.MODE_HIGHLANDER)
end

function EA_Window_InteractionQuest.OnHidden()
    WindowUtils.OnHidden()
    EA_Window_InteractionQuest.choiceRewardsData = nil;
    EA_Window_InteractionQuest.givenRewardsData  = nil;
    
    -- Only play the sound if the window was actually open...
    PlayInteractSound("quest_goodbye")
end

function EA_Window_InteractionQuest.Show()
    -- DEBUG(L"EA_Window_InteractionQuest.Show()")
    WindowSetShowing( "EA_Window_InteractionQuest", true )
end

function EA_Window_InteractionQuest.Hide()
    -- DEBUG(L"EA_Window_InteractionQuest.Hide()")
    WindowSetShowing( "EA_Window_InteractionQuest", false )
end

----------------------------------------------------------------
-- Frame registration and setup
----------------------------------------------------------------
function EA_Window_InteractionQuest.InitializeFrames()
    for frameIndex = 1, EA_Window_InteractionQuest.NUM_GIVEN_REWARD_SLOTS
    do
        local rewardFrame = Frame:CreateFrameForExistingWindow( "EA_Window_InteractionQuestInfoScrollChildRewards"..frameIndex )
        table.insert(EA_Window_InteractionQuest.givenRewardFrames, rewardFrame)
    end
end

----------------------------------------------------------------
-- Show Quest  Functions
----------------------------------------------------------------

function EA_Window_InteractionQuest.ShowQuestFrame(sourceID) 
   
    if( GameData.InteractQuestData.name == L"" )
    then
        EA_Window_InteractionQuest.Hide();        
        return;
    end

    EA_Window_InteractionQuest.questGiverID      = sourceID
    EA_Window_InteractionQuest.choiceRewardsData = GetChoiceRewardsData()
    EA_Window_InteractionQuest.givenRewardsData  = GetGivenRewardsData()
    EA_Window_InteractionQuest.numSelectedRewards = 0

    -- Quest and Questgiver Name
    local targetName  = GetNameForObject(sourceID)
    local displayName = L" "
    
    if (targetName ~= L"")
    then
        displayName = GetStringFormat( StringTables.Default.INTERACTOR_NAME_FORMAT, { targetName } )
    end
    
    LabelSetText("EA_Window_InteractionQuestTitleLabel", GameData.InteractQuestData.name )
    LabelSetText("EA_Window_InteractionQuestTitleLabelSmall", GameData.InteractQuestData.name )
    
    local useSmall = (wstring.len(GameData.InteractQuestData.name) > 24)
    
    WindowSetShowing("EA_Window_InteractionQuestTitleLabel", not useSmall)
    WindowSetShowing("EA_Window_InteractionQuestTitleLabelSmall", useSmall)
    
    LabelSetText("EA_Window_InteractionQuestNameLabel",  displayName )
 
    EA_Window_InteractionQuest.LayoutScrollChild()
 
    WindowSetShowing("EA_Window_InteractionQuest", true)
    PlayInteractSound("quest_offer")
end

----------------------------------------------------------------
-- Layout and content
----------------------------------------------------------------
function EA_Window_InteractionQuest.LayoutScrollChild()

    -- What kind of quest is it?
    local isOffer    = GameData.InteractQuestData.status == "offer" or GameData.InteractQuestData.status == "repeatable_offer"
    local isPending  = GameData.InteractQuestData.status == "pending"
    local isComplete = GameData.InteractQuestData.status == "complete"

	local G_Name = towstring(GameData.Guild.m_GuildName) or L"Guildless"

    -- Quest Starting Text
    local mainText = GameData.InteractQuestData.text
	mainText = wstring.gsub(towstring(mainText), L"|g",G_Name)	
	
    LabelSetText("EA_Window_InteractionQuestInfoScrollChildText", mainText )
    
    local scrollWindowHeight = 0
    local _, textHeight = LabelGetTextDimensions("EA_Window_InteractionQuestInfoScrollChildText")
    local scrollWindowHeight = textHeight + 31 -- magic 31 is the amount of anchoring between weapons
    WindowSetDimensions( "EA_Window_InteractionQuestInfoScrollChildText",
                         EA_Window_InteractionQuest.QUEST_TEXT_WIDTH_EXTENT, textHeight )
    
    -- Quest Journal Text
    local journalText = GameData.InteractQuestData.journalText
	journalText = wstring.gsub(towstring(journalText), L"|g",G_Name)
	
    LabelSetText("EA_Window_InteractionQuestInfoScrollChildJournalEntryText", journalText )
    
    -- Hide the Journal Quest for the pending and complete windows
    if( isOffer )
    then
        local _, textHeight = LabelGetTextDimensions( "EA_Window_InteractionQuestInfoScrollChildJournalEntryText" )
        scrollWindowHeight = scrollWindowHeight + textHeight
        WindowSetDimensions( "EA_Window_InteractionQuestInfoScrollChildJournalEntryText", EA_Window_InteractionQuest.QUEST_TEXT_WIDTH_EXTENT, textHeight )
        WindowSetShowing("EA_Window_InteractionQuestInfoScrollChildJournalEntryText", true)

        local _, windowHeight = WindowGetDimensions( "EA_Window_InteractionQuestInfoScrollChildDivider")
        WindowSetShowing("EA_Window_InteractionQuestInfoScrollChildDivider", true)
        scrollWindowHeight = scrollWindowHeight + windowHeight + 26 -- magic 26 is the anchor padding on the top and bottom of the divider
    else
        WindowSetDimensions( "EA_Window_InteractionQuestInfoScrollChildJournalEntryText", EA_Window_InteractionQuest.QUEST_TEXT_WIDTH_EXTENT, 0 )
        WindowSetShowing("EA_Window_InteractionQuestInfoScrollChildDivider", false)
        WindowSetShowing("EA_Window_InteractionQuestInfoScrollChildJournalEntryText", false)
    end
    
    -- DEBUG(L" scrollWindowHeight = "..scrollWindowHeight)
    scrollWindowHeight = scrollWindowHeight + EA_Window_InteractionQuest.LayoutTimer()   
    -- DEBUG(L" +timer             = "..scrollWindowHeight)
    scrollWindowHeight = scrollWindowHeight + EA_Window_InteractionQuest.LayoutConditions(GameData.InteractQuestData.status)
    -- DEBUG(L" +conditions        = "..scrollWindowHeight)
    scrollWindowHeight = scrollWindowHeight + EA_Window_InteractionQuest.LayoutGivenRewards(isPending)
    -- DEBUG(L" +rewards           = "..scrollWindowHeight)
    scrollWindowHeight = scrollWindowHeight + EA_Window_InteractionQuest.LayoutChoiceRewards(isPending, isComplete)
    -- DEBUG(L" +choicerewards     = "..scrollWindowHeight)

    if (isPending)
    then
        WindowSetShowing("EA_Window_InteractionQuestInfoScrollChildConditionsDivider", false)
    else
        local _, windowHeight = WindowGetDimensions( "EA_Window_InteractionQuestInfoScrollChildConditionsDivider")
        WindowSetShowing("EA_Window_InteractionQuestInfoScrollChildConditionsDivider", true)
        scrollWindowHeight = scrollWindowHeight + windowHeight + 26 -- magic 26 is the anchor padding on the sides of the divider
    end
    -- DEBUG(L" +condition divider = "..scrollWindowHeight)
    
    -- Resize the window based on how big the scroll window is
    if (scrollWindowHeight >= EA_Window_InteractionQuest.SCROLL_WINDOW_MAXIMUM_HEIGHT)
    then
        -- We don't need to shrink the window, so set it to it's maximum.
        WindowSetDimensions( "EA_Window_InteractionQuest",
                             EA_Window_InteractionQuest.QUEST_WINDOW_WIDTH, EA_Window_InteractionQuest.QUEST_WINDOW_HEIGHT )
        WindowSetDimensions( "EA_Window_InteractionQuestInfo",
                             EA_Window_InteractionQuest.QUEST_WINDOW_WIDTH, EA_Window_InteractionQuest.SCROLL_WINDOW_MAXIMUM_HEIGHT )
    else
        -- Determine how much shorter the main window should be
        local heightDifference = EA_Window_InteractionQuest.SCROLL_WINDOW_MAXIMUM_HEIGHT - scrollWindowHeight
        -- DEBUG(L"  Max Scroll Height: "..EA_Window_InteractionQuest.SCROLL_WINDOW_MAXIMUM_HEIGHT..L"  heightDifference = "..heightDifference)
        -- DEBUG(L"  Max Window Height: "..EA_Window_InteractionQuest.QUEST_WINDOW_HEIGHT..L"  "..EA_Window_InteractionQuest.QUEST_WINDOW_HEIGHT - heightDifference)
        WindowSetDimensions( "EA_Window_InteractionQuest",
                             EA_Window_InteractionQuest.QUEST_WINDOW_WIDTH, EA_Window_InteractionQuest.QUEST_WINDOW_HEIGHT - heightDifference )
        WindowSetDimensions( "EA_Window_InteractionQuestInfo",
                             EA_Window_InteractionQuest.QUEST_WINDOW_WIDTH, scrollWindowHeight )
    end
    
    -- Update the scroll window 
    ScrollWindowSetOffset( "EA_Window_InteractionQuestInfo", 0 )
    ScrollWindowUpdateScrollRect( "EA_Window_InteractionQuestInfo" )

    -- Show the Buttons appropriate to the status
    WindowSetShowing("EA_Window_InteractionQuestBack",     isPending  )
    WindowSetShowing("EA_Window_InteractionQuestDone",     isPending  )   
    WindowSetShowing("EA_Window_InteractionQuestAccept",   isOffer    )
    WindowSetShowing("EA_Window_InteractionQuestDecline",  isOffer    )
    WindowSetShowing("EA_Window_InteractionQuestComplete", isComplete )
    
    -- Show the correct background.
    WindowSetShowing("EA_Window_InteractionQuestOfferBackground",       isOffer )
    WindowSetShowing("EA_Window_InteractionQuestPendingBackground",     isPending )
    WindowSetShowing("EA_Window_InteractionQuestCompleteBackground",    isComplete )

end

function EA_Window_InteractionQuest.LayoutTimer()
    -- Timer
    local timer = GameData.InteractQuestData.time
    local text = TimeUtils.FormatClock(timer)
    LabelSetText( "EA_Window_InteractionQuestInfoScrollChildTimerValue", text ) 
    WindowSetShowing("EA_Window_InteractionQuestInfoScrollChildTimer", timer > 0 )   
    
    local windowWidth, _ = WindowGetDimensions("EA_Window_InteractionQuestInfoScrollChildTimer")
    if( timer > 0 )
    then        
        local _, textHeight = LabelGetTextDimensions( "EA_Window_InteractionQuestInfoScrollChildTimerValue" )
        WindowSetDimensions( "EA_Window_InteractionQuestInfoScrollChildTimer", windowWidth, textHeight )
        return textHeight
    else
        WindowSetDimensions( "EA_Window_InteractionQuestInfoScrollChildTimer", windowWidth, 0 )
        return 0
    end
end

function EA_Window_InteractionQuest.LayoutConditions(questStatus)
    -- Conditions
    local conditionText = L""
    local conditionsExist = false
    local conditionsTotalHeight = 0

    if (questStatus ~= "pending")
    then
        for condition = 1, EA_Window_InteractionQuest.NUM_CONDITION_COUNTERS
        do
            local conditionName = GameData.InteractQuestData.conditions[condition].name
            local curCounter    = GameData.InteractQuestData.conditions[condition].curCounter
            local maxCounter    = GameData.InteractQuestData.conditions[condition].maxCounter
            
            local conditionWindowName = "EA_Window_InteractionQuestInfoScrollChildConditions"..condition        
            
            if( conditionName ~= L"" )
            then       
                
                local iconData 
                if (questStatus == "repeatable_offer")
                then
                    iconData = QuestUtils.OFFERED_REPEATABLE_QUEST_ICON                
                else
                    iconData = QuestUtils.OFFERED_QUEST_ICON
                end
                
                conditionsExist = true
                local conditionCounters = L""

                if( maxCounter > 0 )
                then
                    local conditionCounterString = GetStringFormat( StringTables.Default.TEXT_CONDITION_COUNTER_FORMAT, {curCounter, maxCounter} )
                    conditionCounters = conditionCounterString
                    
                    if( maxCounter == curCounter )
                    then
                        iconData = QuestUtils.COMPLETE_QUEST_ICON
                    elseif( curCounter > 0 )
                    then
                        iconData = QuestUtils.PENDING_QUEST_ICON
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
        
        WindowSetDimensions("EA_Window_InteractionQuestInfoScrollChildConditions", EA_Window_InteractionQuest.QUEST_TEXT_WIDTH_EXTENT, conditionsTotalHeight)
        WindowSetShowing("EA_Window_InteractionQuestInfoScrollChildConditions", true)
    end
    
    if (questStatus == "pending") or (not conditionsExist)
    then
        WindowSetDimensions("EA_Window_InteractionQuestInfoScrollChildConditions",  EA_Window_InteractionQuest.QUEST_TEXT_WIDTH_EXTENT, 0)
        WindowSetShowing("EA_Window_InteractionQuestInfoScrollChildConditions",     false)
        return 0
    end
        
    return conditionsTotalHeight
end

function EA_Window_InteractionQuest.LayoutGivenRewards(isPending)
    local xpShowing    = (GameData.InteractQuestData.xpReward > 0)
    local moneyShowing = (GameData.InteractQuestData.moneyReward > 0)
    
    -- Given Rewards
    local startReward = 0
    
    if xpShowing
    then
        startReward = startReward + 1
        
        -- construct the fake xp icon
        local targetFrame = EA_Window_InteractionQuest.givenRewardFrames[startReward]
        local texture, x, y = GetIconData( 35 )
        DynamicImageSetTexture( targetFrame:GetName().."IconBase", texture, x, y ) 
        WindowSetId( targetFrame:GetName(), EA_Window_InteractionQuest.XP_REWARD_ID )
        targetFrame:Show(true)
        WindowSetShowing( targetFrame:GetName().."TextBase", false )
    end
    
    if moneyShowing
    then
        startReward = startReward + 1
        
        -- construct the fake money icon
        local targetFrame = EA_Window_InteractionQuest.givenRewardFrames[startReward]
        local texture, x, y = GetIconData( 34 )
        DynamicImageSetTexture( targetFrame:GetName().."IconBase", texture, x, y )
        WindowSetId( targetFrame:GetName(), EA_Window_InteractionQuest.MONEY_REWARD_ID )
        targetFrame:Show(true)
        WindowSetShowing( targetFrame:GetName().."TextBase", false )
    end
    
    local givenRewardsCount = 0
    local rewardData = EA_Window_InteractionQuest.givenRewardsData
    for reward = 1, (EA_Window_InteractionQuest.NUM_GIVEN_REWARD_SLOTS - startReward)
    do
        local targetFrame = EA_Window_InteractionQuest.givenRewardFrames[reward + startReward]
        
        if( (rewardData[reward] == nil) or (rewardData[reward].name == nil) )
        then
            targetFrame:Show(false)
        else
            local rewardName = rewardData[reward].name
            local rewardIcon = rewardData[reward].iconNum
            local rewardStackCount = rewardData[reward].stackCount
            
            targetFrame:Show(rewardName ~= L"")
            
            if( rewardName ~= L"" )
            then
                local texture, x, y = GetIconData( rewardIcon )
                DynamicImageSetTexture( targetFrame:GetName().."IconBase", texture, x, y ) 
                WindowSetId( targetFrame:GetName(), reward )
                
                if( rewardStackCount > 1 )
			    then
				    WindowSetShowing( targetFrame:GetName().."TextBase", true )
				    LabelSetText( targetFrame:GetName().."TextBase", L""..rewardStackCount )
			    else
				    WindowSetShowing( targetFrame:GetName().."TextBase", false )
			    end
            
                givenRewardsCount = givenRewardsCount + 1
            end
        end
    end
    
    -- Resize the given rewards container
    -- Hide the Rewards for 'pending' quests
    local rewardsExist = ( (givenRewardsCount ~= 0) or xpShowing or moneyShowing )
    if ( rewardsExist and not isPending )
    then
        WindowSetShowing( "EA_Window_InteractionQuestInfoScrollChildRewards", true )
        
        local rewardRows = 1
        if (givenRewardsCount > 5)
        then
            rewardRows = 2
        end
        
        local windowHeight = rewardRows * EA_Window_InteractionQuest.REWARD_BUTTON_HEIGHT
        WindowSetDimensions( "EA_Window_InteractionQuestInfoScrollChildRewards",
                             EA_Window_InteractionQuest.BASE_QUEST_SCROLL_CHILD_WINDOW_WIDTH,
                             windowHeight )
        return windowHeight
    else
        WindowSetShowing( "EA_Window_InteractionQuestInfoScrollChildRewards", false )
        WindowSetDimensions( "EA_Window_InteractionQuestInfoScrollChildRewards",
                             EA_Window_InteractionQuest.BASE_QUEST_SCROLL_CHILD_WINDOW_WIDTH,
                             0 )
        return 0
    end

end

function EA_Window_InteractionQuest.LayoutChoiceRewards(isPending, isComplete)
    
    -- Choice Rewards
    local choiceRewardsCount = 0
    for reward = 1, EA_Window_InteractionQuest.NUM_CHOICE_REWARD_SLOTS
    do
        if( EA_Window_InteractionQuest.choiceRewardsData[reward] == nil )
        then
            WindowSetShowing("EA_Window_InteractionQuestInfoScrollChildChoiceReward"..reward, false )
        else
            local rewardItem = EA_Window_InteractionQuest.choiceRewardsData[reward]    
            local rewardName = rewardItem.name
            local rewardIcon = rewardItem.iconNum
            local rewardStackCount = rewardItem.stackCount
            
            local texture, x, y = GetIconData( rewardIcon )
            DynamicImageSetTexture( "EA_Window_InteractionQuestInfoScrollChildChoiceReward"..reward.."IconBase", texture, x, y )    
            ButtonSetDisabledFlag( "EA_Window_InteractionQuestInfoScrollChildChoiceReward"..reward, not isComplete )
            WindowSetShowing("EA_Window_InteractionQuestInfoScrollChildChoiceReward"..reward, true )
            
            if( rewardStackCount > 1 )
            then
                WindowSetShowing( "EA_Window_InteractionQuestInfoScrollChildChoiceReward"..reward.."TextBase", true )
                LabelSetText( "EA_Window_InteractionQuestInfoScrollChildChoiceReward"..reward.."TextBase", L""..rewardStackCount )
            else
                WindowSetShowing( "EA_Window_InteractionQuestInfoScrollChildChoiceReward"..reward.."TextBase", false )
            end
                
            choiceRewardsCount = choiceRewardsCount + 1
            
            -- If the quest is complete and this is our only choice, automatically select it
            if (isComplete and (reward == 1) and (EA_Window_InteractionQuest.choiceRewardsData[2] == nil))
            then
                ButtonSetPressedFlag( "EA_Window_InteractionQuestInfoScrollChildChoiceReward"..reward, true )
                EA_Window_InteractionQuest.DoSelectRewardChoice( reward )
            else
                ButtonSetPressedFlag( "EA_Window_InteractionQuestInfoScrollChildChoiceReward"..reward, false )
            end
        end 
    end
    
    local windowHeight = 0
    -- Resize the choice rewards container
    -- Hide the Rewards for 'pending' quests
    local choicesExist = (choiceRewardsCount ~= 0)
    if ( choicesExist and not isPending )
    then
        WindowSetShowing( "EA_Window_InteractionQuestInfoScrollChildChoiceReward", true )
        
        local rewardRows = 1
        if (choiceRewardsCount > 4)
        then
            rewardRows = 2
        end
        
        windowHeight = rewardRows * EA_Window_InteractionQuest.REWARD_BUTTON_HEIGHT
        WindowSetDimensions( "EA_Window_InteractionQuestInfoScrollChildChoiceReward",
                             EA_Window_InteractionQuest.BASE_QUEST_SCROLL_CHILD_WINDOW_WIDTH,
                             windowHeight )
        windowHeight = windowHeight + 20        -- Spacing between Given and Choice rewards
    else
        WindowSetShowing( "EA_Window_InteractionQuestInfoScrollChildChoiceReward", false )
        WindowSetDimensions( "EA_Window_InteractionQuestInfoScrollChildChoiceReward",
                             EA_Window_InteractionQuest.BASE_QUEST_SCROLL_CHILD_WINDOW_WIDTH,
                             0 )
    end
    
    -- Update the Choice Rewards Label
    WindowSetShowing("EA_Window_InteractionQuestInfoScrollChildChoiceRewardLabel", choiceRewardsCount ~= 0 )
    local maxChoices = GameData.InteractQuestData.maxChoices
    LabelSetText("EA_Window_InteractionQuestInfoScrollChildChoiceRewardLabel", GetStringFormat( StringTables.Default.TEXT_CHOICE_REWARD , { maxChoices } ) )

    return windowHeight
end

----------------------------------------------------------------
-- Imperative Functions
----------------------------------------------------------------
function EA_Window_InteractionQuest.AcceptQuest()
    BroadcastEvent( SystemData.Events.INTERACT_ACCEPT_QUEST )   
    EA_Window_InteractionQuest.Done()
    PlayInteractSound("quest_accept")
end

function EA_Window_InteractionQuest.CompleteQuest()
    
    if( EA_Window_InteractionQuest.numSelectedRewards ~= GameData.InteractQuestData.maxChoices )
    then
        AlertTextWindow.AddLine( SystemData.AlertText.Types.STATUS_ERRORS, GetString( StringTables.Default.TEXT_MUST_SELECT_REWARDS ) )
        return
    end
    
    -- DEBUG (L"Broadcasting COMPLETE quest event...");

    PlayInteractSound("quest_complete")
    
    BroadcastEvent( SystemData.Events.INTERACT_COMPLETE_QUEST ) 
    EA_Window_InteractionQuest.Done()
end

function EA_Window_InteractionQuest.ShowQuestSelect()
    EA_Window_InteractionBase.Show(EA_Window_InteractionQuest.questGiverID)
end

function EA_Window_InteractionQuest.Done()
    EA_Window_InteractionQuest.Hide()
    EA_Window_InteractionBase.Done()
end

function EA_Window_InteractionQuest.OnMouseOverMoneyReward(targetWindow)
    Tooltips.CreateMoneyTooltip( GetString( StringTables.Default.LABEL_MONEY ),
        GameData.InteractQuestData.moneyReward,
        targetWindow,
        Tooltips.ANCHOR_WINDOW_RIGHT )
end

function EA_Window_InteractionQuest.OnMouseOverXpReward(targetWindow)
    Tooltips.CreateTextOnlyTooltip ( targetWindow, nil )
    Tooltips.SetTooltipText( 1, 1, GetString( StringTables.Default.LABEL_XP ) )
    Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
    Tooltips.SetTooltipText( 2, 1, L""..GameData.InteractQuestData.xpReward )
    Tooltips.SetTooltipColorDef( 2, 1, Tooltips.COLOR_BODY )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
    Tooltips.Finalize()
end

function EA_Window_InteractionQuest.OnMouseOverGivenReward()
    local reward = WindowGetId(SystemData.ActiveWindow.name)
    
    local rewardTable = EA_Window_InteractionQuest.givenRewardsData
    if (rewardTable ~= nil and reward ~= nil)
    then
        if (reward == EA_Window_InteractionQuest.MONEY_REWARD_ID)
        then
            EA_Window_InteractionQuest.OnMouseOverMoneyReward(SystemData.ActiveWindow.name)
        elseif (reward == EA_Window_InteractionQuest.XP_REWARD_ID)
        then
            EA_Window_InteractionQuest.OnMouseOverXpReward(SystemData.ActiveWindow.name)
        elseif (rewardTable[reward] ~= nil)
        then
            Tooltips.CreateItemTooltip ( rewardTable[reward],
                                        SystemData.ActiveWindow.name,
                                        Tooltips.ANCHOR_WINDOW_RIGHT )
        end
    end
end

function EA_Window_InteractionQuest.OnMouseOverChoiceReward()
    local reward = WindowGetId(SystemData.ActiveWindow.name)
    
    local tempReward = EA_Window_InteractionQuest.choiceRewardsData
    if (tempReward ~= nil and reward ~= nil and tempReward[reward] ~= nil)
    then
        Tooltips.CreateItemTooltip ( tempReward[reward], 
                                    "EA_Window_InteractionQuestInfoScrollChildChoiceReward"..reward, 
                                    Tooltips.ANCHOR_WINDOW_RIGHT )
    end
end

function EA_Window_InteractionQuest.SelectRewardChoice()
    if (not ButtonGetDisabledFlag(SystemData.ActiveWindow.name))
    then
        local reward = WindowGetId(SystemData.ActiveWindow.name)
        EA_Window_InteractionQuest.DoSelectRewardChoice(reward)
    end
end

function EA_Window_InteractionQuest.DoSelectRewardChoice(reward)
    
    if( EA_Window_InteractionQuest.choiceRewardsData )
    then
    
        if( GameData.InteractQuestData.maxChoices == 1 )
        then
            for btn = 1, EA_Window_InteractionQuest.NUM_CHOICE_REWARD_SLOTS
            do
                if( EA_Window_InteractionQuest.choiceRewardsData[btn] )
                then
                    EA_Window_InteractionQuest.choiceRewardsData[btn].selected = btn == reward;
                end
            end
            local chosenSlot;
            for btn = 1, EA_Window_InteractionQuest.NUM_CHOICE_REWARD_SLOTS
            do
                if( EA_Window_InteractionQuest.choiceRewardsData[btn] )
                then
                    if( EA_Window_InteractionQuest.choiceRewardsData[btn].selected == true )
                    then
                        ClearSelectedRewards()
                        AddSelectedReward( btn )
                        -- DEBUG( L"Selected the reward: "..btn )
                    end
                end
            end
            EA_Window_InteractionQuest.numSelectedRewards = 1
        else
            if( EA_Window_InteractionQuest.choiceRewardsData[reward] )
            then
                local selected = EA_Window_InteractionQuest.choiceRewardsData[reward].selected
                
                if( selected == false )
                then
                    if( EA_Window_InteractionQuest.numSelectedRewards < GameData.InteractQuestData.maxChoices ) then
                        selected = true
                        EA_Window_InteractionQuest.choiceRewardsData[reward].selected = true
                        EA_Window_InteractionQuest.numSelectedRewards = EA_Window_InteractionQuest.numSelectedRewards + 1
                        AddSelectedReward( reward )
                    else
                        AlertTextWindow.AddLine( SystemData.AlertText.Types.STATUS_ERRORS, GetString( StringTables.Default.TEXT_MAX_REWARDS_SELECTED ) )
                    end
                else
                    selected = false
                    RemoveSelectedReward( reward )
                    EA_Window_InteractionQuest.choiceRewardsData[reward].selected = false
                    EA_Window_InteractionQuest.numSelectedRewards = EA_Window_InteractionQuest.numSelectedRewards - 1 
                end
            end
        end
    
        -- Update the selections
        for btn = 1, EA_Window_InteractionQuest.NUM_CHOICE_REWARD_SLOTS
        do
            if( EA_Window_InteractionQuest.choiceRewardsData[btn] )
            then
                ButtonSetPressedFlag( "EA_Window_InteractionQuestInfoScrollChildChoiceReward"..btn, EA_Window_InteractionQuest.choiceRewardsData[btn].selected == true )
            end
        end
    end
    
end

function EA_Window_InteractionQuest.OnRButtonUp()
    EA_Window_ContextMenu.CreateOpacityOnlyContextMenu( "EA_Window_InteractionQuest" )
end
