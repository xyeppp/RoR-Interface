EA_Window_InteractionBase = {}

----------------------------------------------------------------
-- Module variables
----------------------------------------------------------------
EA_Window_InteractionBase.optionListData = {}
EA_Window_InteractionBase.questListData  = {}
EA_Window_InteractionBase.delayedResize  = -1

----------------------------------------------------------------
-- Functions
----------------------------------------------------------------

function EA_Window_InteractionBase.Initialize()
    -- DEBUG(L"EA_Window_InteractionBase.Initialize()")
    
    -- Event handlers
    WindowRegisterEventHandler( "EA_Window_InteractionBase", SystemData.Events.INTERACT_DEFAULT, "EA_Window_InteractionBase.Show")
    WindowRegisterEventHandler( "EA_Window_InteractionBase", SystemData.Events.INTERACT_DONE,    "EA_Window_InteractionBase.Hide")

    -- Labels
    ButtonSetText("EA_Window_InteractionBaseDone", GetString( StringTables.Default.LABEL_DONE ))

    WindowSetAlpha("EA_Window_InteractionBaseBackground", InteractionUtils.BASE_BACKGROUND_ALPHA)
end

-- TODO: Once we have same frame resizing working then we will not have to wait like we do now.
function EA_Window_InteractionBase.OnUpdate(timeElapsed)
    if (EA_Window_InteractionBase.delayedResize < 0)
    then
        -- do nothing
    elseif (EA_Window_InteractionBase.delayedResize == 0)
    then
        EA_Window_InteractionBase.delayedResize = -1
        EA_Window_InteractionBase.UpdateWindowSize()
    else
        EA_Window_InteractionBase.delayedResize = (EA_Window_InteractionBase.delayedResize - 1)
    end
end

function EA_Window_InteractionBase.Shutdown()
    -- DEBUG(L"EA_Window_InteractionBase.Shutdown()")

    if (EA_Window_InteractionBase.tempTarget ~= 0)
    then
        EA_Window_InteractionBase.tempTarget = 0
    end
end

function EA_Window_InteractionBase.Show(interactionTargetID)
    -- DEBUG(L"EA_Window_InteractionBase.Show()")
    
    WindowSetShowing("EA_Window_InteractionBase", true)
    EA_Window_InteractionBase.GenerateMenu(interactionTargetID)
    EA_Window_InteractionBase.delayedResize = 1
end

function EA_Window_InteractionBase.OnShown()

    -- DEBUG(L"EA_Window_InteractionBase.OnShown()")
    WindowUtils.OnShown(EA_Window_InteractionBase.Hide, WindowUtils.Cascade.MODE_HIGHLANDER)

end

function EA_Window_InteractionBase.Hide()
    -- DEBUG(L"EA_Window_InteractionBase.Hide()")
    WindowSetShowing("EA_Window_InteractionBase", false)
end

function EA_Window_InteractionBase.OnHidden()
    -- DEBUG(L"EA_Window_InteractionBase.OnHidden()")
    WindowUtils.OnHidden()
    
    if EA_Window_InteractionBase.tempTarget ~= 0
    then
        EA_Window_InteractionBase.tempTarget = 0
    end
end

function EA_Window_InteractionBase.Done()
    BroadcastEvent(SystemData.Events.INTERACT_DONE)
end

----------------------------------------------------------------
-- Menu Generation
----------------------------------------------------------------
function EA_Window_InteractionBase.GenerateMenu(interactionTargetID)

    if (interactionTargetID == nil)
    then
        EA_Window_InteractionBase.Done()
        return
    end
    
    -- DEBUG(L"EA_Window_InteractionBase.GenerateMenu("..interactionTargetID..L")")
    
    EA_Window_InteractionBase.tempTarget = interactionTargetID
    
    local menuData = InteractGetBaseInteractionData( interactionTargetID )
    
    if (menuData == nil)
    then
        -- In some rare cases, items will have pending quest text, which means
        -- pressing the back button will take us here, i.e... nowhere
        -- or... This NPC does nothing.  Why is it interactable?
        EA_Window_InteractionBase.Done()
        return
    else
        
        -- Set up the text provided.    
        LabelSetText( "EA_Window_InteractionBaseTargetName",    menuData.name )
        LabelSetText( "EA_Window_InteractionBaseText",          menuData.text )
        
        -- Reset the options in the menu.
        EA_Window_InteractionBase.optionListData = menuData.options
        EA_Window_InteractionBase.questListData  = menuData.quests

    end
    
    -- This window should not be shown if there are no options or only one option
    -- bmazza - I've commented this out because it breaks certain menu options.
    -- The native code currently determines whether the window should show (so it should be
    -- impossible to get here if it shouldn't show); that sometimes includes
    -- interactions with only 1 option (e.g. idle chat must always show the window).
    -- TODO: Ideally we'd move that logic to lua (here) so UI modders can customize the behavior.
    --if ( ((#EA_Window_InteractionBase.optionListData + #EA_Window_InteractionBase.questListData) == 0) or
    --     ((#EA_Window_InteractionBase.optionListData + #EA_Window_InteractionBase.questListData) == 1) )
    --then
    --    EA_Window_InteractionBase.Done()
    --    return
    --end

	--RoR inject
	if TargetInfo:UnitIsNPC("selffriendlytarget") then
		if TargetInfo:UnitNPCTitle("selffriendlytarget"):match(GetStringFromTable("npctitles", 2)) or TargetInfo:UnitNPCTitle("selffriendlytarget"):match(GetStringFromTable("npctitles", 3)) or TargetInfo:UnitNPCTitle("selffriendlytarget"):match(GetStringFromTable("npctitles", 181)) then
			EA_Window_InteractionBase.optionListData[#EA_Window_InteractionBase.optionListData+1] = {trainType=32,type=0}	--inject the option
		end
	end

    EA_Window_InteractionBase.RefreshLists()
    
end

----------------------------------------------------------------
-- Layout and Formatting
----------------------------------------------------------------
function EA_Window_InteractionBase.UpdateListDimensions(listWindow, rowCount)
    local sizeX, _ = WindowGetDimensions(listWindow)
    
    if (rowCount > 0)
    then
        -- Assuming homogenous row sizing.
        local _, rowY  = WindowGetDimensions(listWindow.."Row1")
        local rowSpacing = 15 -- rowspacing is 15 from the xml
        
        -- Add together each row, and rowSpacing for each.
        WindowSetDimensions(listWindow, sizeX, (rowY * rowCount) + (rowSpacing * rowCount))
    else
        WindowSetDimensions(listWindow, sizeX, 0)
    end
end

function EA_Window_InteractionBase.UpdateWindowSize()

    local sizeX, sizeY = WindowGetDimensions("EA_Window_InteractionBaseBackground")
    WindowSetDimensions("EA_Window_InteractionBase", sizeX, sizeY)

end

----------------------------------------------------------------
-- List Population
----------------------------------------------------------------
function EA_Window_InteractionBase.RefreshLists()
    -- DEBUG(L"EA_Window_InteractionBase.RefreshLists()")

    local optionDisplayOrder = {}
    local questDisplayOrder  = {}
    
    if (EA_Window_InteractionBase.optionListData == nil)
    then
        -- DEBUG(L"  EA_Window_InteractionBase.optionListData is nil")
        -- this can occur during the initial load, in which case ignore it
        return
    end
    
    if (WindowGetShowing("EA_Window_InteractionBase") == false)
    then
        -- DEBUG(L"  EA_Window_InteractionBase is not visible")
        -- Why bother if nothing's being displayed anyway?
        return
    end
    
    -- table.sort(EA_Window_InteractionBase.optionListData)
    
    for index, data in pairs(EA_Window_InteractionBase.optionListData)
    do
        -- Don't show chatter as an option.
        if (data.type == GameData.InteractType.IDLE_CHAT)
        then
            continue
        end
        
        -- Don't Show the Mastery Training Button for low level players
        -- when we're hidding advanced windows.
        if( (data.type == GameData.InteractType.TRAINER)
            and( data.trainType == GameData.InteractTrainerType.CAREER_MASTERY)
            and (not EA_AdvancedWindowManager.ShouldShow(EA_AdvancedWindowManager.WINDOW_TYPE_MASTERY_TRAINING))
          )
        then
            continue
        end 
        
        table.insert(optionDisplayOrder, index)
    end
    
    for index, data in pairs(EA_Window_InteractionBase.questListData)
    do
        table.insert(questDisplayOrder, index)
    end

    -- DEBUG(L"  #quests: "..#questDisplayOrder..L", #options: "..#optionDisplayOrder)
    
    ListBoxSetVisibleRowCount("EA_Window_InteractionBaseQuestList",  #questDisplayOrder)
    ListBoxSetVisibleRowCount("EA_Window_InteractionBaseOptionList", #optionDisplayOrder)

    ListBoxSetDisplayOrder("EA_Window_InteractionBaseQuestList",  questDisplayOrder)
    ListBoxSetDisplayOrder("EA_Window_InteractionBaseOptionList", optionDisplayOrder)
    
    -- The Populate callback isn't called for list boxes with empty display orders.
    if (#questDisplayOrder == 0)
    then
        EA_Window_InteractionBase.UpdateListDimensions("EA_Window_InteractionBaseQuestList", 0)
    end

    if (#optionDisplayOrder == 0)
    then
        EA_Window_InteractionBase.UpdateListDimensions("EA_Window_InteractionBaseOptionList", 0)
    end

end

function EA_Window_InteractionBase.PopulateOptions(dataIndexTable)
    -- DEBUG(L"EA_Window_InteractionBase.PopulateOptions()")

    EA_Window_InteractionBase.UpdateListDimensions("EA_Window_InteractionBaseOptionList", #dataIndexTable)
    
    for row, dataIndex in ipairs(dataIndexTable)
    do
        local optionData = EA_Window_InteractionBase.optionListData[dataIndex]
        local rowFrame   = "EA_Window_InteractionBaseOptionListRow"..row
        
        local optionText = L""
        -- DEBUG(L"  Row "..row..L", function "..optionData.type)
        
        if (optionData.type == GameData.InteractType.GUILD_REGISTRAR)
        then
            optionText = GetString( StringTables.Default.LABEL_GUILD_INTERACTION_LABEL)
        elseif (optionData.type == GameData.InteractType.TRAINER)
        then
            -- If it's a trainer, check the trainer subtype
            if (optionData.trainType == GameData.InteractTrainerType.TRADESKILL)
            then
                optionText = GetString( StringTables.Default.LABEL_TRADESKILL_TRAINING_FROM_TRAINER )
            elseif (optionData.trainType == GameData.InteractTrainerType.CAREER_CORE)
            then
                optionText = GetString( StringTables.Default.LABEL_CORE_TRAINING_FROM_TRAINER )
            elseif (optionData.trainType == GameData.InteractTrainerType.CAREER_MASTERY)
            then
                optionText = GetString( StringTables.Default.LABEL_SPECIALIZATION_TRAINING_FROM_TRAINER )
            elseif (optionData.trainType == GameData.InteractTrainerType.RENOWN)
            then
                optionText = GetString( StringTables.Default.LABEL_RENOWN_TRAINING_FROM_TRAINER )
            elseif (optionData.trainType == GameData.InteractTrainerType.TOME)
            then
                optionText = GetString( StringTables.Default.LABEL_TOME_TRAINING_FROM_TRAINER )
            elseif (optionData.trainType == 32) --RoR Specc injection
            then
                optionText = GetString( StringTables.Default.LABEL_MULTI_SPEC_FROM_TRAINER )
            end 
        elseif (optionData.type == GameData.InteractType.INFLUENCE)
        then
            optionText = GetString( StringTables.Default.TEXT_SELECT_INFLUENCE_REWARDS )
        elseif (optionData.type == GameData.InteractType.STORE)
        then
            optionText = GetString( StringTables.Default.LABEL_BROWSE_WARES)
        elseif (optionData.type == GameData.InteractType.DYEMERCHANT)
        then
            optionText = GetString( StringTables.Default.LABEL_DYE_MERCHANT_INTERACT)
        elseif (optionData.type == GameData.InteractType.REPAIR)
        then
            optionText = GetString( StringTables.Default.LABEL_REPAIR_BROKEN_ITEMS )
        elseif (optionData.type == GameData.InteractType.HEALER)
        then
            optionText = GetString( StringTables.Default.LABEL_HEAL )
        elseif (optionData.type == GameData.InteractType.BINDER)
        then
            optionText = GetString( StringTables.Default.LABEL_BIND_HERE )
        elseif (optionData.type == GameData.InteractType.TRAVEL)
        then
            optionText = GetString( StringTables.Default.LABEL_TAKE_A_FLIGHT )
        elseif (optionData.type == GameData.InteractType.SCENARIO_QUEUE)
        then
            optionText = GetString( StringTables.Default.LABEL_ENTER_SCENARIO_LOBBY )
        elseif (optionData.type == GameData.InteractType.LASTNAMESHOP)
        then
            optionText = GetString( StringTables.Default.LABEL_LASTNAME_REGISTRAR )
        elseif (optionData.type == GameData.InteractType.KEEP_UPGRADE)
        then
            optionText = GetString( StringTables.Default.LABEL_UPGRADE_KEEP )
        elseif (optionData.type == GameData.InteractType.DIVINEFAVORALTAR)
        then
            optionText = GetString( StringTables.Default.LABEL_DIVINE_FAVOR_ALTAR_TITLEBAR )
        elseif (optionData.type == GameData.InteractType.HERALD)
        then
            optionText = GetString( StringTables.Default.TEXT_SELECT_EVENT_REWARDS )
        elseif (optionData.type == GameData.InteractType.EQUIPMENT_UPGRADE)
        then
            optionText = GetString( StringTables.Default.LABEL_UPGRADE_EQUIPMENT )
        elseif (optionData.type == GameData.InteractType.BARBERSHOP)
        then
            optionText = GetString( StringTables.Default.LABEL_BARBERSHOP )
        end        
        
        ButtonSetText(rowFrame, optionText)
    end
    
end

function EA_Window_InteractionBase.PopulateQuests(dataIndexTable)
    -- DEBUG(L"EA_Window_InteractionBase.PopulateQuests()")
    
    EA_Window_InteractionBase.UpdateListDimensions("EA_Window_InteractionBaseQuestList", #dataIndexTable)

    for row, data in ipairs(dataIndexTable)
    do
        local questData  = EA_Window_InteractionBase.questListData[data]
        local rowFrame   = "EA_Window_InteractionBaseQuestListRow"..row
        local questName  = questData.name
        local iconData   = nil

        ButtonSetText(rowFrame, questName)
        
        if( questData.completion == GameData.QuestCompletion.OFFER or
            questData.completion == GameData.QuestCompletion.REPEATABLE_OFFER)
        then
            -- check if we've already accepted the quest
            if( DataUtils.GetQuestDataFromName( questName ) ~= nil )
            then
                iconData    = QuestUtils.ACTIVE_QUEST_ICON
                pendingText = questName
            else
                -- if we have not accepted the quest, and it is repeatable, show
                -- the repeatable icon
                if( questData.completion == GameData.QuestCompletion.REPEATABLE_OFFER )
                then
                    iconData    = QuestUtils.OFFERED_REPEATABLE_QUEST_ICON
                else
                    iconData    = QuestUtils.OFFERED_QUEST_ICON
                end
                offerText   = questName
            end
        elseif( questData.completion == GameData.QuestCompletion.PENDING )
        then      
            if( DataUtils.IsQuestComplete( questName ) )
            then
                iconData = QuestUtils.COMPLETE_QUEST_ICON
            else
                iconData = QuestUtils.ACTIVE_QUEST_ICON
            end
        end
        
        if( iconData )
        then
            DynamicImageSetTexture( rowFrame.."Icon", iconData.texture, iconData.x, iconData.y )
        end

    end
    
end

----------------------------------------------------------------
-- Interface Handlers
----------------------------------------------------------------
function EA_Window_InteractionBase.QuestLButtonUp()
    -- DEBUG(L"EA_Window_InteractionBase.QuestLButtonUp()")
    local buttonIndex = WindowGetId(SystemData.ActiveWindow.name)
    local dataIndex   = ListBoxGetDataIndex("EA_Window_InteractionBaseQuestList", buttonIndex)
    local optionData  = EA_Window_InteractionBase.questListData[dataIndex]
   
    InteractSelect(EA_Window_InteractionBase.tempTarget, optionData.type, optionData.slot)
end

function EA_Window_InteractionBase.OptionLButtonUp()
    -- DEBUG(L"EA_Window_InteractionBase.OptionLButtonUp()")
    local buttonIndex = WindowGetId(SystemData.ActiveWindow.name)
    local optionIndex = ListBoxGetDataIndex("EA_Window_InteractionBaseOptionList", buttonIndex)
    local optionData  = EA_Window_InteractionBase.optionListData[optionIndex]

    --RoR specc injection
    if (optionData.trainType == 32) then
        InteractionUtils.StoreRequestedTrainingType(GameData.InteractTrainerType.NONE)
        SendChatText(L"]spec list",ChatSettings.Channels[0].serverCmd)
        return
    end

    if (optionData.type == GameData.InteractType.TRAINER)
    then
        InteractionUtils.StoreRequestedTrainingType(optionData.trainType)
    else
        InteractionUtils.StoreRequestedTrainingType(GameData.InteractTrainerType.NONE)
        if( optionData.type == GameData.InteractType.BINDER )
        then
            local function ConfirmRecall()
                InteractSelect(EA_Window_InteractionBase.tempTarget, optionData.type, 0)
            end
            DialogManager.MakeTwoButtonDialog(  GetString( StringTables.Default.LABEL_BIND_POINT_DESC),
                                                GetString( StringTables.Default.LABEL_YES ),
                                                ConfirmRecall,
                                                GetString( StringTables.Default.LABEL_NO ),
                                                nil, nil, nil, nil, nil, DialogManager.TYPE_MODE_LESS )
            return
        end
    end

    InteractSelect(EA_Window_InteractionBase.tempTarget, optionData.type, 0)
end
