
-- Trade Skill Data
EA_Window_InteractionTraining.TradeSkillLabels = {}
EA_Window_InteractionTraining.TradeSkillLabels[1] = StringTables.Default.LABEL_SKILL_BUTCHERING
EA_Window_InteractionTraining.TradeSkillLabels[2] = StringTables.Default.LABEL_SKILL_SCAVENGING
EA_Window_InteractionTraining.TradeSkillLabels[3] = StringTables.Default.LABEL_SKILL_CULTIVATION
EA_Window_InteractionTraining.TradeSkillLabels[4] = StringTables.Default.LABEL_SKILL_APOTHECARY
EA_Window_InteractionTraining.TradeSkillLabels[5] = StringTables.Default.LABEL_SKILL_TALISMAN
EA_Window_InteractionTraining.TradeSkillLabels[6] = StringTables.Default.LABEL_SKILL_SALVAGING

EA_Window_InteractionTraining.TradeSkillCategoryText = {}
EA_Window_InteractionTraining.TradeSkillCategoryText[1] = StringTables.Default.TEXT_TRADE_SKILL_GATHERING_CATEGORY
EA_Window_InteractionTraining.TradeSkillCategoryText[2] = StringTables.Default.TEXT_TRADE_SKILL_GATHERING_CATEGORY
EA_Window_InteractionTraining.TradeSkillCategoryText[3] = StringTables.Default.TEXT_TRADE_SKILL_GATHERING_CATEGORY
EA_Window_InteractionTraining.TradeSkillCategoryText[4] = StringTables.Default.TEXT_TRADE_SKILL_CRAFTING_CATEGORY
EA_Window_InteractionTraining.TradeSkillCategoryText[5] = StringTables.Default.TEXT_TRADE_SKILL_CRAFTING_CATEGORY
EA_Window_InteractionTraining.TradeSkillCategoryText[6] = StringTables.Default.TEXT_TRADE_SKILL_GATHERING_CATEGORY

EA_Window_InteractionTraining.ConflictingTradeSkill = 0

EA_Window_InteractionTraining.MaxTradeSkill = 6

function EA_Window_InteractionTraining.ShowTradeSkillUI()
    -- DEBUG(L"EA_Window_InteractionTraining.ShowTradeSkillUI()")
    
    local learnSkillText = GetStringFormat(StringTables.Default.TEXT_LEARN_TRADE_SKILL, 
                                           {GetString(EA_Window_InteractionTraining.TradeSkillLabels[GameData.InteractData.trainerTradeSkill]), 
                                            GetString(EA_Window_InteractionTraining.TradeSkillCategoryText[GameData.InteractData.trainerTradeSkill])} )
    DialogManager.MakeTwoButtonDialog(learnSkillText, GetString(StringTables.Default.LABEL_YES), EA_Window_InteractionTraining.LearnTradeSkill, GetString(StringTables.Default.LABEL_CANCEL), nil)
end

function EA_Window_InteractionTraining.LearnTradeSkill()
    -- TODO: Call a C++ function to get the conflicting trade skill here. Or I can set enums in lua and do logic in lua. 
    EA_Window_InteractionTraining.ConflictingSkill = EA_Window_InteractionTraining.GetConflictingTradeSkill(GameData.InteractData.trainerTradeSkill)
    if(EA_Window_InteractionTraining.ConflictingSkill ~= 0) then
        local DiscardSkillText = GetStringFormat(StringTables.Default.TEXT_DISCARD_SKILL, {
                                                 GetString(EA_Window_InteractionTraining.TradeSkillLabels[EA_Window_InteractionTraining.ConflictingSkill]), 
                                                 GetString(EA_Window_InteractionTraining.TradeSkillCategoryText[EA_Window_InteractionTraining.ConflictingSkill])})
        DialogManager.MakeTwoButtonDialog(DiscardSkillText, GetString(StringTables.Default.LABEL_YES), EA_Window_InteractionTraining.DiscardTradeSkill, GetString(StringTables.Default.LABEL_CANCEL), nil)
    else
        EA_Window_InteractionTraining.BuyTradeSkill()
    end
end

function EA_Window_InteractionTraining.DiscardTradeSkill()
    local ConfirmDiscardSkillText = GetStringFormat(StringTables.Default.TEXT_CONFIRM_DISCARD_SKILL, 
                                                    {GetString(EA_Window_InteractionTraining.TradeSkillLabels[EA_Window_InteractionTraining.ConflictingSkill])})
    DialogManager.MakeTwoButtonDialog(ConfirmDiscardSkillText, GetString(StringTables.Default.LABEL_YES), EA_Window_InteractionTraining.DiscardTradeSkillAndBuyAnother, GetString(StringTables.Default.LABEL_CANCEL), nil)
end

function EA_Window_InteractionTraining.DiscardTradeSkillAndBuyAnother()
    BuyTradeSkill( GameData.InteractData.trainerTradeSkill, EA_Window_InteractionTraining.ConflictingSkill )
    PlayInteractSound("trainer_accept")
end

function EA_Window_InteractionTraining.BuyTradeSkill()
    BuyTradeSkill( GameData.InteractData.trainerTradeSkill, 0 )
    PlayInteractSound("trainer_accept")
end

function EA_Window_InteractionTraining.GetConflictingTradeSkill(tradeSkillToLearn)
    for tradeSkill = 1,EA_Window_InteractionTraining.MaxTradeSkill do
        if GameData.TradeSkillLevels[tradeSkill] ~= nil and GameData.TradeSkillLevels[tradeSkill] > 0 and 
            tradeSkill ~= tradeSkillToLearn and
            EA_Window_InteractionTraining.TradeSkillCategoryText[tradeSkill] == EA_Window_InteractionTraining.TradeSkillCategoryText[tradeSkillToLearn] then
            return tradeSkill
        end
    end
    return 0
end
