EA_Window_InteractionInfluenceRewards = {}

EA_Window_InteractionInfluenceRewards.rewardData = nil

----------------------------------------------------------------
-- Window Functions
----------------------------------------------------------------
function EA_Window_InteractionInfluenceRewards.Initialize()
    -- DEBUG(L"EA_Window_InteractionInfluenceRewards.Initialize()")
    WindowRegisterEventHandler( "EA_Window_InteractionInfluenceRewards", SystemData.Events.INTERACT_DONE,                   "EA_Window_InteractionInfluenceRewards.Hide")
    WindowRegisterEventHandler( "EA_Window_InteractionInfluenceRewards", SystemData.Events.INTERACT_SHOW_INFLUENCE_REWARDS, "EA_Window_InteractionInfluenceRewards.Show")
    
    ButtonSetText("EA_Window_InteractionInfluenceRewardsCancel", GetString( StringTables.Default.LABEL_CANCEL ) )
    ButtonSetText("EA_Window_InteractionInfluenceRewardsSelect", GetString( StringTables.Default.LABEL_SELECT ) )
    
    LabelSetText("EA_Window_InteractionInfluenceRewardsTitleLabel",                 GetString( StringTables.Default.LABEL_INFLUENCE_REWARDS ) )
    LabelSetText("EA_Window_InteractionInfluenceRewardsLevel1Label", GetString( StringTables.Default.LABEL_BASIC_REWARD ) )
    LabelSetText("EA_Window_InteractionInfluenceRewardsLevel2Label", GetString( StringTables.Default.LABEL_ADVANCED_REWARD ) )
    LabelSetText("EA_Window_InteractionInfluenceRewardsLevel3Label", GetString( StringTables.Default.LABEL_ELITE_REWARD ) )

    LabelSetText("EA_Window_InteractionInfluenceRewardsLevel1DisabledLabel", GetString( StringTables.Default.TEXT_NEED_INFL_POINTS ) )
    LabelSetText("EA_Window_InteractionInfluenceRewardsLevel2DisabledLabel", GetString( StringTables.Default.TEXT_NEED_INFL_POINTS ) )
    LabelSetText("EA_Window_InteractionInfluenceRewardsLevel3DisabledLabel", GetString( StringTables.Default.TEXT_NEED_INFL_POINTS ) )

    
    WindowSetAlpha("EA_Window_InteractionInfluenceRewardsBackground", InteractionUtils.BASE_BACKGROUND_ALPHA)

end

function EA_Window_InteractionInfluenceRewards.Show(interactTarget, influenceID)
    -- DEBUG(L"EA_Window_InteractionInfluenceRewards.Show("..interactTarget..L", "..influenceID..L")")
    WindowSetShowing("EA_Window_InteractionInfluenceRewards", true)
    
    local targetName  = GetNameForObject(interactTarget)
    local displayName = L" "
    
    if (targetName ~= L"")
    then
        displayName = GetStringFormat( StringTables.Default.INTERACTOR_NAME_FORMAT, { targetName } )
    end
    
    LabelSetText("EA_Window_InteractionInfluenceRewardsNameLabel", displayName )

    EA_Window_InteractionInfluenceRewards.PopulateRewards(influenceID)
    
end

function EA_Window_InteractionInfluenceRewards.OnShown()
    WindowUtils.OnShown(EA_Window_InteractionInfluenceRewards.Hide, WindowUtils.Cascade.MODE_HIGHLANDER)
end

function EA_Window_InteractionInfluenceRewards.Hide()
    WindowSetShowing("EA_Window_InteractionInfluenceRewards", false)
end

function EA_Window_InteractionInfluenceRewards.OnHidden()
    WindowUtils.OnHidden()
    EA_Window_InteractionInfluenceRewards.rewardData = nil
end

----------------------------------------------------------------
-- Layout and dynamic content
----------------------------------------------------------------
function EA_Window_InteractionInfluenceRewards.PopulateRewards(influenceID)

    EA_Window_InteractionInfluenceRewards.rewardData = GameData.GetInfluenceRewards(influenceID)

    local influenceData     = DataUtils.GetInfluenceData( influenceID )
    local influenceRewards  = EA_Window_InteractionInfluenceRewards.rewardData
    
    local stringIndex = StringTables.Default.TEXT_INFLUENCE_REWARDS
    if( influenceData.isRvRInfluence )
    then
        stringIndex = StringTables.Default.TEXT_INFLUENCE_RVR_REWARDS
    end
    LabelSetText("EA_Window_InteractionInfluenceRewardsText", GetString( stringIndex ) )

    -- Hide all rewards windows first.
    for rewardLevel = 1, TomeWindow.NUM_REWARD_LEVELS
    do
        local targetRow = "EA_Window_InteractionInfluenceRewardsLevel"..rewardLevel
        for itemIndex = 1, TomeWindow.MAX_REWARDS_PER_LEVEL
        do
            local targetFrame = targetRow.."Reward"..itemIndex
            WindowSetShowing(targetFrame, false)
        end
    end
    
    local rewardsAvailable = false

    -- Turn on all the existing ones.    
    for rewardLevel, itemTables in ipairs(influenceRewards)
    do
        local targetRow    = "EA_Window_InteractionInfluenceRewardsLevel"..rewardLevel
        local hasPoints    = influenceData.curValue >= influenceData.rewardLevel[rewardLevel].amountNeeded
        local hasPurchased = influenceData.rewardLevel[rewardLevel].rewardsRecieved

        WindowSetShowing(targetRow.."DisabledLabel", not hasPoints)

        for itemIndex, itemData in ipairs(itemTables)
        do
            local targetButton      = targetRow.."Reward"..itemIndex
            local iconWindow        = targetButton.."IconBase"
            local iconWindowText    = targetButton.."TextBase"

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

            local disableButton = (hasPoints == false or hasPurchased == true)
            rewardsAvailable    = rewardsAvailable or (not disableButton)
            
            if (disableButton)
            then
                DefaultColor.SetWindowTint(iconWindow, DefaultColor.MEDIUM_GRAY )
            else
                DefaultColor.SetWindowTint(iconWindow, DefaultColor.ZERO_TINT ) 
            end
            
            ButtonSetDisabledFlag(targetButton, disableButton )
            
            WindowSetId( targetButton, EA_Window_InteractionInfluenceRewards.EncodeWindowId(rewardLevel, itemIndex) )
        end
    end

    ButtonSetDisabledFlag("EA_Window_InteractionInfluenceRewardsSelect", not rewardsAvailable )
end

----------------------------------------------------------------
-- Interaction Handlers
----------------------------------------------------------------
function EA_Window_InteractionInfluenceRewards.OnMouseOverInfluenceReward()
    local level, index = EA_Window_InteractionInfluenceRewards.DecodeWindowId( WindowGetId(SystemData.ActiveWindow.name) )
    
    local itemData = EA_Window_InteractionInfluenceRewards.rewardData[level][index]
    if itemData
    then
        Tooltips.CreateItemTooltip( itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_RIGHT )
    end

end

function EA_Window_InteractionInfluenceRewards.OnSelectInfluenceReward()

    -- If the button is disable, the player may not select it
    if( ButtonGetDisabledFlag(SystemData.ActiveWindow.name) == true )
    then
        return
    end

    local level, index = EA_Window_InteractionInfluenceRewards.DecodeWindowId( WindowGetId(SystemData.ActiveWindow.name) )
    
    for buttonIndex = 1, TomeWindow.MAX_REWARDS_PER_LEVEL
    do      
        ButtonSetPressedFlag("EA_Window_InteractionInfluenceRewardsLevel"..level.."Reward"..buttonIndex, buttonIndex == index )
    end

end

function EA_Window_InteractionInfluenceRewards.SelectInfluenceRewards()

    if( ButtonGetDisabledFlag("EA_Window_InteractionInfluenceRewardsSelect" ) )
    then
        return
    end

    -- Each pressed button is selected
    for level = 1, TomeWindow.NUM_REWARD_LEVELS
    do
        for reward = 1, TomeWindow.MAX_REWARDS_PER_LEVEL
        do
            if( ButtonGetPressedFlag("EA_Window_InteractionInfluenceRewardsLevel"..level.."Reward"..reward) == true )
            then
                SelectInfluenceReward( level, reward )
            end                         
        end
    end 
    
    EA_Window_InteractionInfluenceRewards.Hide()
end

function EA_Window_InteractionInfluenceRewards.Cancel()
    EA_Window_InteractionInfluenceRewards.Hide()
end

----------------------------------------------------------------
-- Utility Functions
----------------------------------------------------------------
function EA_Window_InteractionInfluenceRewards.EncodeWindowId( level, index )
    return ((level * 100) + index)
end

function EA_Window_InteractionInfluenceRewards.DecodeWindowId( windowID )
    local remainder = math.fmod(windowID, 100)
    return (windowID - remainder) / 100, remainder
end