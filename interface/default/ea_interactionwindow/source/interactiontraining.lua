----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
EA_Window_InteractionTraining = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------


----------------------------------------------------------------
-- Global Functions
----------------------------------------------------------------
function EA_Window_InteractionTraining.Initialize()
    RegisterEventHandler( SystemData.Events.INTERACT_SHOW_TRAINING, "EA_Window_InteractionTraining.Show")
    RegisterEventHandler( SystemData.Events.INTERACT_DONE,          "EA_Window_InteractionTraining.Hide")
end

function EA_Window_InteractionTraining.Shutdown()
    UnregisterEventHandler( SystemData.Events.INTERACT_SHOW_TRAINING, "EA_Window_InteractionTraining.Show")
    UnregisterEventHandler( SystemData.Events.INTERACT_DONE,          "EA_Window_InteractionTraining.Hide")
end

function EA_Window_InteractionTraining.Show()

    -- Hide first, then show.  This allows the cascade rules to make space for the new window.    
    local lastTrainingTypeSelected = InteractionUtils.GetLastRequestedTrainingType()
    if (lastTrainingTypeSelected == GameData.InteractTrainerType.TRADESKILL)
    then
        EA_Window_InteractionCoreTraining.Hide()
        EA_Window_InteractionSpecialtyTraining.Hide()
        EA_Window_InteractionRenownTraining.Hide()
        EA_Window_InteractionTomeTraining.Hide()

        -- TODO: This should be changed to be done similarly to the rest of the training types.
        if (GameData.InteractData.trainerTradeSkill ~= 0)
        then
            EA_Window_InteractionTraining.ShowTradeSkillUI()
        end
        return
    elseif (lastTrainingTypeSelected == GameData.InteractTrainerType.CAREER_CORE)
    then
        EA_Window_InteractionSpecialtyTraining.Hide()
        EA_Window_InteractionRenownTraining.Hide()
        EA_Window_InteractionTomeTraining.Hide()

        EA_Window_InteractionCoreTraining.Show()
        return
    elseif (lastTrainingTypeSelected == GameData.InteractTrainerType.CAREER_MASTERY)
    then
        EA_Window_InteractionCoreTraining.Hide()
        EA_Window_InteractionRenownTraining.Hide()
        EA_Window_InteractionTomeTraining.Hide()

        EA_Window_InteractionSpecialtyTraining.Show()
        return
    elseif (lastTrainingTypeSelected == GameData.InteractTrainerType.RENOWN)
    then
        EA_Window_InteractionCoreTraining.Hide()
        EA_Window_InteractionSpecialtyTraining.Hide()
        EA_Window_InteractionTomeTraining.Hide()

        EA_Window_InteractionRenownTraining.Show()
        return
    elseif (lastTrainingTypeSelected == GameData.InteractTrainerType.TOME)
    then
        EA_Window_InteractionRenownTraining.Hide()
        EA_Window_InteractionCoreTraining.Hide()
        EA_Window_InteractionSpecialtyTraining.Hide()

        EA_Window_InteractionTomeTraining.Show()
        return
    else
        -- Unknown training type.
        EA_Window_InteractionTraining.Hide()
    end

    return

end

function EA_Window_InteractionTraining.Hide()
    EA_Window_InteractionRenownTraining.Hide()
    EA_Window_InteractionCoreTraining.Hide()
    EA_Window_InteractionSpecialtyTraining.Hide()
    EA_Window_InteractionTomeTraining.Hide()
end