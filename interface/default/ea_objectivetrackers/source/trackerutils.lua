TrackerUtils = {}

-- Should match EObjectiveOptOutStatus in RvRConsts.h
TrackerUtils.OPT_OUT_OPTION_NONE    = 0     -- Player is not opting out of any objective loot
TrackerUtils.OPT_OUT_OPTION_ALL     = 1     -- Player is opting out of all objective loot
TrackerUtils.OPT_OUT_OPTION_GOLD    = 2     -- Player is opting out of only gold bags

function TrackerUtils.GetFlagSliceForOwner(realm,flag)
    local Locked = flag or false
    if Locked == false then
        if (realm == GameData.Realm.ORDER)
        then
            return "FlagOrder"
        elseif (realm == GameData.Realm.DESTRUCTION)
        then
            return "FlagDestruction"
        else
            if GameData.Player.zone == 191 then
                return "FlagTK"
            end
            return "FlagNeutral"
        end
    else
        if (realm == GameData.Realm.ORDER)
        then
            return "FlagOrder-Locked"
        elseif (realm == GameData.Realm.DESTRUCTION)
        then
            return "FlagDestruction-Locked"
        else
            return "FlagNeutral-Locked"
        end
    end
end

function TrackerUtils.GetKeepSliceForOwner(realm)
    if (realm == GameData.Realm.ORDER)
    then
        return "OrderKeep"
    elseif (realm == GameData.Realm.DESTRUCTION)
    then
        return "DestructionKeep"
    else
        --ERROR(L"Keeps cannot be unaligned.")
        return "OrderKeep"
    end
end

function TrackerUtils.GetDifficultyColor( difficulty )
    if( difficulty == GameData.PublicQuestDifficulty.EASY )
    then
        return DefaultColor.GREEN
    elseif( difficulty == GameData.PublicQuestDifficulty.MEDIUM )
    then
        return DefaultColor.YELLOW
    elseif( difficulty == GameData.PublicQuestDifficulty.HARD
            or difficulty == GameData.PublicQuestDifficulty.VERY_HARD )
    then
        return DefaultColor.RED
    end
    
    return DefaultColor.YELLOW
end

function TrackerUtils.GetDifficultyText( difficulty )
    if( difficulty == GameData.PublicQuestDifficulty.EASY )
    then
        return GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TEXT_PUBLICQUEST_EASY )
    elseif( difficulty == GameData.PublicQuestDifficulty.MEDIUM )
    then
        return GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TEXT_PUBLICQUEST_MEDIUM )
    elseif( difficulty == GameData.PublicQuestDifficulty.HARD
            or difficulty == GameData.PublicQuestDifficulty.VERY_HARD )
    then
        return GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TEXT_PUBLICQUEST_HARD )
    end
    
    return GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TEXT_PUBLICQUEST_MEDIUM )
end

function TrackerUtils.GetDifficultyHelpText( difficulty )
    if( difficulty == GameData.PublicQuestDifficulty.EASY )
    then
        return GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.DIFFICULTY_HELP_EASY )
    elseif( difficulty == GameData.PublicQuestDifficulty.MEDIUM )
    then
        return GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TEXT_PUBLICQUEST_MEDIUM )
    elseif( difficulty == GameData.PublicQuestDifficulty.HARD
            or difficulty == GameData.PublicQuestDifficulty.VERY_HARD )
    then
        return GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.DIFFICULTY_HELP_HARD )
    end

    return GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.DIFFICULTY_HELP_MEDIUM )
end

function TrackerUtils.InitializeOptOutButton()
    ButtonSetCheckButtonFlag( SystemData.ActiveWindow.name, true )
end

function TrackerUtils.OnMouseOverOptOut()

    local text = L""

    local forcedOutForLootRoll = ButtonGetDisabledFlag( SystemData.ActiveWindow.name )
    if ( forcedOutForLootRoll )
    then
        text = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_FORCED_OUT )
    else
        local optedOutForLootRoll = ButtonGetPressedFlag( SystemData.ActiveWindow.name )
        
        if ( optedOutForLootRoll )
        then
            text = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_OPT_IN)
        else
            text = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_OPT_OUT)
        end
    end

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function TrackerUtils.CreateOptOutContextMenuItems( parentWindowName )

    local baseMenuName = parentWindowName.."OptOut"
    local menuName = ""

    -- Option: None
    menuName = baseMenuName.."None"
    CreateWindowFromTemplate (menuName, "TrackerContextMenuItemCheckBox", "Root")
    LabelSetText( menuName.."CheckBoxLabel", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_OPTOUTOPTION_NONE ))
    WindowRegisterCoreEventHandler(menuName, "OnLButtonUp", parentWindowName..".ToggleOptOutOptionNone")
    WindowSetShowing(menuName, false)    
    
    -- Option: All Bags
    menuName = baseMenuName.."All"
    CreateWindowFromTemplate (menuName, "TrackerContextMenuItemCheckBox", "Root")
    LabelSetText( menuName.."CheckBoxLabel", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_OPTOUTOPTION_ALL ))
    WindowRegisterCoreEventHandler(menuName, "OnLButtonUp", parentWindowName..".ToggleOptOutOptionAll")
    WindowSetShowing(menuName, false)      
    
    -- Option: Gold Bags Only
    menuName = baseMenuName.."Gold"
    CreateWindowFromTemplate (menuName, "TrackerContextMenuItemCheckBox", "Root")
    LabelSetText( menuName.."CheckBoxLabel", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_OPTOUTOPTION_GOLD ))
    WindowRegisterCoreEventHandler(menuName, "OnLButtonUp", parentWindowName..".ToggleOptOutOptionGold")
    WindowSetShowing(menuName, false)    
    
end

function TrackerUtils.ShouldOptOutOptionBeChecked( objectiveId, optOutType )
    
    if(DataUtils.activeObjectivesData[objectiveId].optedOutForLoot == optOutType)
    then
        return true
    end
    
    return false
end

function TrackerUtils.SetOptOutOption( windowName, index, optOutValue)
                   
    if DataUtils.activeObjectivesData[index]==nil then return end

    -- This flag was off, we're going to toggle it on and set the new looting
    -- opt out options per the representative checkbox opt out status value
    local checkBoxName = windowName.."CheckBox"
    local objectiveId = DataUtils.activeObjectivesData[index].id

    if(ButtonGetPressedFlag(checkBoxName) == false) then
        LootRollOptOut(objectiveId, optOutValue) 
    end

    --if (optOutValue==nil) then optOutValue = 0 end
    --DataUtils.activeObjectivesData[index].optedOutForLoot = optOutValue
    
    --local Arr = {"None", "All bags", "Gold bags"}
    --EA_ChatWindow.Print( "Opting out from bags: "..Arr[optOutValue+1], SystemData.ChatLogFilters.MISC )

    EA_Window_ContextMenu.HideAll()    
    --return windowName, objectiveId, optOutValue, index
end

