EA_Window_InteractionEventRewards = {}

EA_Window_InteractionEventRewards.rewardData = nil
EA_Window_InteractionEventRewards.currentEvent = 0
EA_Window_InteractionEventRewards.eventListData = {}    -- For populating the list box

----------------------------------------------------------------
-- Window Functions
----------------------------------------------------------------
function EA_Window_InteractionEventRewards.Initialize()
    WindowRegisterEventHandler("EA_Window_InteractionEventRewards", SystemData.Events.INTERACT_DONE,               "EA_Window_InteractionEventRewards.Hide")
    WindowRegisterEventHandler("EA_Window_InteractionEventRewards", SystemData.Events.INTERACT_SHOW_EVENT_REWARDS, "EA_Window_InteractionEventRewards.Show")
    
    ButtonSetText("EA_Window_InteractionEventRewardsCancel", GetString( StringTables.Default.LABEL_CANCEL ) )
    ButtonSetText("EA_Window_InteractionEventRewardsSelect", GetString( StringTables.Default.LABEL_SELECT ) )
    
    LabelSetText("EA_Window_InteractionEventRewardsTitleLabel",  GetString( StringTables.Default.LABEL_EVENT_REWARDS ) )
    LabelSetText("EA_Window_InteractionEventRewardsLevel1Label", GetString( StringTables.Default.LABEL_BASIC_REWARD ) )
    LabelSetText("EA_Window_InteractionEventRewardsLevel2Label", GetString( StringTables.Default.LABEL_ADVANCED_REWARD ) )
    LabelSetText("EA_Window_InteractionEventRewardsLevel3Label", GetString( StringTables.Default.LABEL_ELITE_REWARD ) )

    LabelSetText("EA_Window_InteractionEventRewardsLevel1DisabledLabel", GetString( StringTables.Default.TEXT_NEED_INFL_POINTS ) )
    LabelSetText("EA_Window_InteractionEventRewardsLevel2DisabledLabel", GetString( StringTables.Default.TEXT_NEED_INFL_POINTS ) )
    LabelSetText("EA_Window_InteractionEventRewardsLevel3DisabledLabel", GetString( StringTables.Default.TEXT_NEED_INFL_POINTS ) )

    
    WindowSetAlpha("EA_Window_InteractionEventRewardsBackground", InteractionUtils.BASE_BACKGROUND_ALPHA)

end

function EA_Window_InteractionEventRewards.Show(interactTarget, rewardData)
    WindowSetShowing("EA_Window_InteractionEventRewards", true)
    
    local targetName  = GetNameForObject(interactTarget)
    local displayName = L" "
    
    if (targetName ~= L"")
    then
        displayName = GetStringFormat( StringTables.Default.INTERACTOR_NAME_FORMAT, { targetName } )
    end
    
    LabelSetText("EA_Window_InteractionEventRewardsNameLabel", displayName )

    EA_Window_InteractionEventRewards.rewardData = rewardData
    EA_Window_InteractionEventRewards.currentEvent = next(rewardData)  -- Get the first event, if any
    
    if ((EA_Window_InteractionEventRewards.currentEvent == nil) or (next(rewardData, EA_Window_InteractionEventRewards.currentEvent) ~= nil))
    then
        -- There are either no events or multiple events. Show the list mode.
        EA_Window_InteractionEventRewards.ShowEventListScreen()
    else
        -- There is exactly one event. Show reward select mode.
        EA_Window_InteractionEventRewards.ShowRewardsScreen()
    end
    
end

function EA_Window_InteractionEventRewards.OnShown()
    WindowUtils.OnShown(EA_Window_InteractionEventRewards.Hide, WindowUtils.Cascade.MODE_HIGHLANDER)
end

function EA_Window_InteractionEventRewards.Hide()
    WindowSetShowing("EA_Window_InteractionEventRewards", false)
end

function EA_Window_InteractionEventRewards.OnHidden()
    WindowUtils.OnHidden()
    EA_Window_InteractionEventRewards.rewardData = nil
end

----------------------------------------------------------------
-- Event List screen functions
----------------------------------------------------------------
function EA_Window_InteractionEventRewards.ShowEventListScreen()
    -- Change the Cancel button into a Close button
    ButtonSetText("EA_Window_InteractionEventRewardsCancel", GetString( StringTables.Default.LABEL_CLOSE ) )
    
    -- Hide the rewards screen windows
    WindowSetShowing("EA_Window_InteractionEventRewardsLevel1", false)
    WindowSetShowing("EA_Window_InteractionEventRewardsLevel2", false)
    WindowSetShowing("EA_Window_InteractionEventRewardsLevel3", false)
    WindowSetShowing("EA_Window_InteractionEventRewardsSelect", false)
    
    if (next(EA_Window_InteractionEventRewards.rewardData) == nil)
    then
        -- No events
        LabelSetText("EA_Window_InteractionEventRewardsText", GetString( StringTables.Default.TEXT_EVENT_REWARDS_NO_EVENTS ) )
        WindowSetShowing("EA_Window_InteractionEventRewardsEventList", false)
    else
        -- Multiple events
        LabelSetText("EA_Window_InteractionEventRewardsText", GetString( StringTables.Default.TEXT_EVENT_REWARDS_SELECT_EVENT ) )
        
        local listBoxDisplayOrder = {}
        EA_Window_InteractionEventRewards.eventListData = {}
        for eventId, eventData in pairs(EA_Window_InteractionEventRewards.rewardData)
        do
            table.insert(EA_Window_InteractionEventRewards.eventListData, { id=eventId, name=eventData.title })
            table.insert(listBoxDisplayOrder, #EA_Window_InteractionEventRewards.eventListData)
        end
        
        ListBoxSetVisibleRowCount("EA_Window_InteractionEventRewardsEventList", #listBoxDisplayOrder)
        ListBoxSetDisplayOrder("EA_Window_InteractionEventRewardsEventList", listBoxDisplayOrder)
        WindowSetShowing("EA_Window_InteractionEventRewardsEventList", true)
    end
end

function EA_Window_InteractionEventRewards.PopulateEventList(dataIndexTable)
    for row, dataIndex in ipairs(dataIndexTable)
    do
        local eventId = EA_Window_InteractionEventRewards.eventListData[dataIndex].id
        WindowSetId("EA_Window_InteractionEventRewardsEventListRow"..row, eventId)
    end
end

function EA_Window_InteractionEventRewards.OnClickEventListButton()
    EA_Window_InteractionEventRewards.currentEvent = WindowGetId(SystemData.ActiveWindow.name)
    EA_Window_InteractionEventRewards.ShowRewardsScreen()
end

----------------------------------------------------------------
-- Rewards screen functions
----------------------------------------------------------------
function EA_Window_InteractionEventRewards.ShowRewardsScreen()

    local eventData = EA_Window_InteractionEventRewards.rewardData[EA_Window_InteractionEventRewards.currentEvent]

    LabelSetText("EA_Window_InteractionEventRewardsText", GetStringFormat( StringTables.Default.TEXT_EVENT_REWARDS_SELECT_REWARDS, {eventData.title} ) )
    
    -- The Cancel button may have been a Close button. Change it back to Cancel.
    ButtonSetText("EA_Window_InteractionEventRewardsCancel", GetString( StringTables.Default.LABEL_CANCEL ) )
    
    -- Hide the listbox
    WindowSetShowing("EA_Window_InteractionEventRewardsEventList", false)
    
    -- Show the rewards screen windows
    WindowSetShowing("EA_Window_InteractionEventRewardsLevel1", true)
    WindowSetShowing("EA_Window_InteractionEventRewardsLevel2", true)
    WindowSetShowing("EA_Window_InteractionEventRewardsLevel3", true)
    WindowSetShowing("EA_Window_InteractionEventRewardsSelect", true)

    -- Hide all rewards windows first.
    for rewardLevel = 1, TomeWindow.NUM_REWARD_LEVELS
    do
        local targetRow = "EA_Window_InteractionEventRewardsLevel"..rewardLevel
        for itemIndex = 1, TomeWindow.MAX_REWARDS_PER_LEVEL
        do
            local targetFrame = targetRow.."Reward"..itemIndex
            WindowSetShowing(targetFrame, false)
        end
    end
    
    local rewardsAvailable = false

    -- Turn on all the existing ones.    
    for rewardLevel, rewardData in ipairs(eventData.rewards)
    do
        local targetRow    = "EA_Window_InteractionEventRewardsLevel"..rewardLevel

        WindowSetShowing(targetRow.."DisabledLabel", not rewardData.eligible)

        for itemIndex, itemData in ipairs(rewardData.items)
        do
            local targetButton		= targetRow.."Reward"..itemIndex
            local iconWindow   		= targetButton.."IconBase"
			local iconWindowText	= targetButton.."TextBase"

            WindowSetShowing(targetButton, true)

            local texture, x, y = GetIconData( itemData.iconNum )
            DynamicImageSetTexture( iconWindow, texture, x, y )
            WindowSetShowing(targetButton, true )
            ButtonSetPressedFlag(targetButton, false )

			if( itemData.stackCount > 1 )
			then
				WindowSetShowing( iconWindowText, true )
				LabelSetText( iconWindowText, L""..itemData.stackCount )
			else
				WindowSetShowing( iconWindowText, false )
			end

            local disableButton = rewardData.purchased or not rewardData.eligible
            rewardsAvailable    = rewardsAvailable or not disableButton
            
            if (disableButton)
            then
                DefaultColor.SetWindowTint(iconWindow, DefaultColor.MEDIUM_GRAY )
            else
                DefaultColor.SetWindowTint(iconWindow, DefaultColor.ZERO_TINT ) 
            end
            
            ButtonSetDisabledFlag(targetButton, disableButton )
            
            WindowSetId( targetButton, EA_Window_InteractionEventRewards.EncodeWindowId(rewardLevel, itemIndex) )
        end
    end

    ButtonSetDisabledFlag("EA_Window_InteractionEventRewardsSelect", not rewardsAvailable )
end

function EA_Window_InteractionEventRewards.OnMouseOverEventReward()
    local level, index = EA_Window_InteractionEventRewards.DecodeWindowId( WindowGetId(SystemData.ActiveWindow.name) )
    
    local eventData = EA_Window_InteractionEventRewards.rewardData[EA_Window_InteractionEventRewards.currentEvent]
    local itemData = eventData.rewards[level].items[index]
    if (itemData ~= nil)
    then
        Tooltips.CreateItemTooltip( itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_RIGHT )
    end

end

function EA_Window_InteractionEventRewards.OnSelectEventReward()

    -- If the button is disable, the player may not select it
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name) == true )
    then
        return
    end

    local level, index = EA_Window_InteractionEventRewards.DecodeWindowId( WindowGetId(SystemData.ActiveWindow.name) )
    
    for buttonIndex = 1, TomeWindow.MAX_REWARDS_PER_LEVEL
    do      
        ButtonSetPressedFlag("EA_Window_InteractionEventRewardsLevel"..level.."Reward"..buttonIndex, buttonIndex == index )
    end

end

function EA_Window_InteractionEventRewards.SelectEventRewards()

    if( ButtonGetDisabledFlag("EA_Window_InteractionEventRewardsSelect" ) )
    then
        return
    end

    -- Each pressed button is selected
    local rewardsArrays = {}
    for level = 1, TomeWindow.NUM_REWARD_LEVELS
    do
        rewardsArrays[level] = {}
        for reward = 1, TomeWindow.MAX_REWARDS_PER_LEVEL
        do
            if( ButtonGetPressedFlag("EA_Window_InteractionEventRewardsLevel"..level.."Reward"..reward) == true )
            then
                table.insert( rewardsArrays[level], reward )
            end
        end
    end
    
    SelectEventRewards( EA_Window_InteractionEventRewards.currentEvent, rewardsArrays[1], rewardsArrays[2], rewardsArrays[3] )
    
    EA_Window_InteractionEventRewards.Hide()
end

----------------------------------------------------------------
-- Cancel/Close button
----------------------------------------------------------------
function EA_Window_InteractionEventRewards.Cancel()
    EA_Window_InteractionEventRewards.Hide()
end

----------------------------------------------------------------
-- Utility Functions
----------------------------------------------------------------
function EA_Window_InteractionEventRewards.EncodeWindowId( level, index )
    return ((level * 100) + index)
end

function EA_Window_InteractionEventRewards.DecodeWindowId( windowID )
    local remainder = math.fmod(windowID, 100)
    return (windowID - remainder) / 100, remainder
end