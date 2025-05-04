InteractionUtils =
{
requestedTrainingType = GameData.InteractTrainerType.NONE,

BASE_BACKGROUND_ALPHA = 0.9

}

----------------------------------------------------------------
-- Advances and Packages
----------------------------------------------------------------

function InteractionUtils.AreAnyCoreAbilitiesTrainable()
    for Index, Data in ipairs(EA_Window_InteractionTraining.advanceData)
    do
        -- if this is the package(s) we are looking for
        if (EA_Window_InteractionTraining.AbilityFilter(Data) and
            EA_Window_InteractionTraining.AvailabilityFilter(Data) and
            EA_Window_InteractionTraining.CoreFilter(Data))
        then
            return true
        end
    end
    
    return false
end

function InteractionUtils.IsRenownAdvance(advanceData)

    local categorizationTable =
    {
        [GameData.CareerCategory.CAREER_ABILITY         ]    = false,
        [GameData.CareerCategory.CAREER_TACTIC          ]    = false,
        [GameData.CareerCategory.CAREER_MORALE          ]    = false,
        [GameData.CareerCategory.ARCHTYPE_TACTIC        ]    = false,
        [GameData.CareerCategory.ARCHTYPE_MORALE        ]    = false,
        [GameData.CareerCategory.RACE_TACTIC            ]    = false,
        [GameData.CareerCategory.RACE_MORALE            ]    = false,
        [GameData.CareerCategory.SPECIALIZATION         ]    = false,
        [GameData.CareerCategory.AUTOMATIC              ]    = false,
        [GameData.CareerCategory.RENOWN_STATS_A         ]    = true,
        [GameData.CareerCategory.RENOWN_STATS_B         ]    = true,
        [GameData.CareerCategory.RENOWN_STATS_C         ]    = true,
        [GameData.CareerCategory.RENOWN_RESISTS         ]    = true,
        [GameData.CareerCategory.RENOWN_OFFENSIVE       ]    = true,
        [GameData.CareerCategory.RENOWN_DEFENSIVE       ]    = true,
        [GameData.CareerCategory.RENOWN_REALM           ]    = true,
        [GameData.CareerCategory.TOME_CC_A              ]    = false,
        [GameData.CareerCategory.TOME_CC_B              ]    = false,
        [GameData.CareerCategory.CC_18                  ]    = false,
        [GameData.CareerCategory.CC_19                  ]    = false,
    }
    
    return categorizationTable[advanceData.category]

end

function InteractionUtils.IsTomeAdvance(advanceData)

    local categorizationTable =
    {
        [GameData.CareerCategory.CAREER_ABILITY         ]    = false,
        [GameData.CareerCategory.CAREER_TACTIC          ]    = false,
        [GameData.CareerCategory.CAREER_MORALE          ]    = false,
        [GameData.CareerCategory.ARCHTYPE_TACTIC        ]    = false,
        [GameData.CareerCategory.ARCHTYPE_MORALE        ]    = false,
        [GameData.CareerCategory.RACE_TACTIC            ]    = false,
        [GameData.CareerCategory.RACE_MORALE            ]    = false,
        [GameData.CareerCategory.SPECIALIZATION         ]    = false,
        [GameData.CareerCategory.AUTOMATIC              ]    = false,
        [GameData.CareerCategory.RENOWN_STATS_A         ]    = false,
        [GameData.CareerCategory.RENOWN_STATS_B         ]    = false,
        [GameData.CareerCategory.RENOWN_STATS_C         ]    = false,
        [GameData.CareerCategory.RENOWN_RESISTS         ]    = false,
        [GameData.CareerCategory.RENOWN_OFFENSIVE       ]    = false,
        [GameData.CareerCategory.RENOWN_DEFENSIVE       ]    = false,
        [GameData.CareerCategory.RENOWN_REALM           ]    = false,
        [GameData.CareerCategory.TOME_CC_A              ]    = true,
        [GameData.CareerCategory.TOME_CC_B              ]    = true,
        [GameData.CareerCategory.CC_18                  ]    = false,
        [GameData.CareerCategory.CC_19                  ]    = false,
    }
    
    return categorizationTable[advanceData.category]

end

function InteractionUtils.GetDependentPackage( parentPackage, searchPackageID, allPackages )

    if (parentPackage == nil) or (parentPackage.dependencies == nil)
    then
        -- no dependencies means an easy pass!
        return nil
    end
    
    -- find the packages in our list of all packages
    for _, data in ipairs(allPackages)
    do
        -- if this is the package(s) we are looking for
        if ( (parentPackage.category == data.category) and
             (parentPackage.tier == data.tier) and
             (data.packageId == searchPackageID) )
        then
            return data
        end
    end
    
    return nil

end

function InteractionUtils.GetDependencyChainLength( advanceData, allPackages )

    if (advanceData == nil) or (advanceData.dependencies == {}) or (advanceData.dependencies == nil)
    then
        return 0
    end
    
    for searchPackageID, _ in pairs(advanceData.dependencies)
    do
        -- find the packages in our list of all packages
        for _, data in ipairs(allPackages)
        do
            -- if this is the package(s) we are looking for
            if ( (advanceData.category == data.category) and
                 (advanceData.tier == data.tier) and
                 (data.packageId == searchPackageID) )
            then
                return  1 + InteractionUtils.GetDependencyChainLength(data, allPackages)
            end
        end
    end
    
    return 0
    
end

function InteractionUtils.FindAdvance( advanceData, advanceList )

    if (advanceData == nil) or (advanceList == nil)
    then
        return nil
    end
    
    -- find the packages in our list of all packages
    for _, data in ipairs(advanceList)
    do
        -- if this is the package(s) we are looking for
        if ( (advanceData.category  == data.category) and
             (advanceData.tier      == data.tier) and
             (advanceData.packageId == data.packageId) )
        then
            return data
        end
    end
    
    return nil

end

function InteractionUtils.IsAbility(advanceData)
    if (advanceData == nil) or (advanceData.abilityInfo == nil)
    then
        return false
    end
    
    return true
end

function InteractionUtils.IsAction(advanceData)
    if (advanceData == nil) or (advanceData.abilityInfo == nil)
    then
        return false
    end

    return (advanceData.abilityInfo.moraleLevel == 0) and (advanceData.abilityInfo.numTacticSlots == 0)
end

function InteractionUtils.IsMorale(advanceData)
    if (advanceData == nil) or (advanceData.abilityInfo == nil)
    then
        return false
    end

    return (advanceData.abilityInfo.moraleLevel > 0)
end

function InteractionUtils.IsTactic(advanceData)
    if (advanceData == nil) or (advanceData.abilityInfo == nil)
    then
        return false
    end

    return (advanceData.abilityInfo.numTacticSlots > 0)
end

function InteractionUtils.MeetsDependencies( searchPackage, allPackages )

    if (searchPackage == nil) or (searchPackage.dependencies == nil)
    then
        -- no dependencies means an easy pass!
        -- DEBUG(L"EA_Window_InteractionTraining.MeetsDependenciesFilter() passes package "..SearchPackage.packageId..L" by lack of dependencies")
        return true
    end
    
    -- locate the dependant package(s)
    for packageID, levelRequired in pairs(searchPackage.dependencies)
    do
        -- find the packages in our list of all packages
        local prequisitePackage = InteractionUtils.GetDependentPackage(searchPackage, packageID, allPackages)
        
        if (prequisitePackage ~= nil)
        then
            -- test that we have them at a high enough level
            if (levelRequired > prequisitePackage.timesPurchased)
            then
                -- DEBUG(L"InteractionUtils.MeetsDependencies() fails package "..SearchPackage.packageId..L" with dependency on package "..PackageID..L" as having been purchased "..Data.timesPurchased..L"/"..LevelRequired..L" times")
                return false
            else
                -- DEBUG(L"InteractionUtils.MeetsDependencies() passes package "..SearchPackage.packageId..L" with dependency on package "..PackageID..L" as having been purchased "..Data.timesPurchased..L"/"..LevelRequired..L" times")
            end
        end
    end
    
    -- if it passed all that, return true
    -- DEBUG(L"InteractionUtils.MeetsDependencies() passes package "..SearchPackage.packageId..L" by default")
    return true
end

function InteractionUtils.LessThanMaximumPurchaseCount(advanceData)
    if (advanceData == nil)
    then
        return false
    else
        -- DEBUG( L"InteractionUtils.LessThanMaximumPurchaseCount() testing "..advanceData.timesPurchased..L" < "..advanceData.maximumPurchaseCount )
        return advanceData.timesPurchased < advanceData.maximumPurchaseCount
    end
end

-- Core vs. Specialization
function InteractionUtils.CoreFilter(advanceData)
    if (advanceData == nil)
    then
        return false
    elseif (advanceData.dependencies == nil)
    then
        return false
    else
        -- DEBUG(L"InteractionUtils.CoreFilter("..advanceData.abilityInfo.name..L")")

        for path, _ in pairs(advanceData.dependencies)
        do
            if (path ~= nil)
            then
                return false
            end
        end
        
        -- There are no dependencies, so this is either a a core ability or a specialization path
        local dataIsGranted  = advanceData.category == GameData.CareerCategory.AUTOMATIC
        local dataIsSpecPath = InteractionUtils.AdvanceIsSpecLevel(advanceData)  
        local dataIsRenown   = InteractionUtils.IsRenownAdvance(advanceData)
        local dataIsTome     = InteractionUtils.IsTomeAdvance(advanceData)
        return ( (not dataIsGranted) and (not dataIsSpecPath) and (not dataIsRenown) and (not dataIsTome) )

    end
end

function InteractionUtils.PathFilter(advanceData)
    if (advanceData.dependencies == nil)
    then
        -- No dependencies mean it is the path advance itself, which is handled as a special case.
        return false
    else
        local isSpecializationCategory = (advanceData.category == GameData.CareerCategory.SPECIALIZATION)
        
        if (isSpecializationCategory)
        then
            local isInThisPath = false
            
            -- DEBUG(L"InteractionUtils.PathFilter("..advanceData.abilityInfo.name..L") looking for path "..(InteractionUtils.currentTab - 1))
            for path, _ in pairs(advanceData.dependencies) do
                if ( (path + 1) == (InteractionUtils.currentTab) ) then
                    isInThisPath = true
                end
            end
        
            return isInThisPath
        end
        
        return false
    end
end

function InteractionUtils.RenownFilter(advanceData)
    return InteractionUtils.IsRenownAdvance(advanceData)
end

function InteractionUtils.TypeFilter(advanceData)

    local dataIsAbility      = ( (advanceData.abilityInfo ~= nil) and
                                 (advanceData.abilityInfo.id ~= 0) )

    -- Ability classifications should be disabled for nonabilities.
    if (not dataIsAbility)
    then
        return false
    end
                                 
    local dataIsUnclassified = (not advanceData.abilityInfo.isDamaging)  and
                               (not advanceData.abilityInfo.isHealing)   and
                               (not advanceData.abilityInfo.isBuff)      and
                               (not advanceData.abilityInfo.isDebuff)    and
                               (not advanceData.abilityInfo.isOffensive) and
                               (not advanceData.abilityInfo.isDefensive)

    return ( InteractionUtils.ActionFilter(advanceData) or
             InteractionUtils.TacticFilter(advanceData) or
             InteractionUtils.MoraleFilter(advanceData)    )
           
           and
    
           ( InteractionUtils.DamageFilter(advanceData)      or
             InteractionUtils.HealingFilter(advanceData)     or
             InteractionUtils.BuffFilter(advanceData)        or
             InteractionUtils.DebuffFilter(advanceData)      or
             dataIsUnclassified  )

end

function InteractionUtils.AdvanceIsSpecLevel(advanceData)
    local dataIsSpecPath = (advanceData.advanceType == GameData.AdvanceType.SPEC)
    return dataIsSpecPath
end

function InteractionUtils.AdvanceIsPassive(advanceData)
    local dataIsPassive = (advanceData.advanceType == GameData.AdvanceType.STAT) or
                          (advanceData.advanceType == GameData.AdvanceType.BONUS) or
                          ( (advanceData.abilityInfo ~= nil) and
                            (advanceData.abilityInfo.abilityType == GameData.AbilityType.PASSIVE) and
                            not InteractionUtils.IsTactic(advanceData) )
    
    -- DEBUG(L"InteractionUtils.AdvanceIsPassive() checking advance of type "..advanceData.advanceType)

    return dataIsPassive
end

-- General sort of ability
function InteractionUtils.DamageFilter(advanceData)
    return (advanceData.abilityInfo.isDamaging)
end

function InteractionUtils.HealingFilter(advanceData)
    return (advanceData.abilityInfo.isHealing)
end

function InteractionUtils.BuffFilter(advanceData)
    return (advanceData.abilityInfo.isBuff)
end

function InteractionUtils.DebuffFilter(advanceData)
    return (advanceData.abilityInfo.isDebuff)
end

function InteractionUtils.OffensiveFilter(advanceData)
    return (advanceData.abilityInfo.isOffensive)
end

function InteractionUtils.DefensiveFilter(advanceData)
    return (advanceData.abilityInfo.isDefensive)
end

function InteractionUtils.OneSlotFilter(advanceData)
    return (advanceData.abilityInfo.numTacticSlots == 1)
end

function InteractionUtils.TwoSlotFilter(advanceData)
    return (advanceData.abilityInfo.numTacticSlots == 2)
end

function InteractionUtils.ActionFilter(advanceData)
    return (advanceData.abilityInfo.moraleLevel == 0) and (advanceData.abilityInfo.numTacticSlots == 0)
end

function InteractionUtils.TacticFilter(advanceData)
    return (advanceData.abilityInfo.numTacticSlots > 0)
end

function InteractionUtils.MoraleFilter(advanceData)
    return (advanceData.abilityInfo.moraleLevel > 0)
end


-- Availability for purchase
function InteractionUtils.MeetsLevelRequirementsFilter(advanceData)
    if (advanceData == nil)
    then
        return false
    else
        return (GameData.Player.level >= advanceData.minimumRank)
    end
end

function InteractionUtils.MeetsRenownRequirementsFilter(advanceData)
    if (advanceData == nil)
    then
        return false
    else
        return (GameData.Player.Renown.curRank >= advanceData.minimumRenown)
    end
end

function InteractionUtils.HasAbilityFilter(advanceData)
    if (advanceData ~= nil) and (advanceData.abilityInfo ~= nil)
    then
        return (advanceData.abilityInfo.isPurchased)
    else
        return false
    end
end

function InteractionUtils.HasPurchasedPackageToMaximum(advanceData)
    if (advanceData == nil)
    then
        return false
    else
        return (advanceData.timesPurchased >= advanceData.maximumPurchaseCount)
    end
end

function InteractionUtils.LessThanMaximumPurchaseCountFilter(advanceData)
    if (advanceData == nil)
    then
        return false
    else
        -- DEBUG( L"InteractionUtils.LessThanMaximumPurchaseCountFilter() testing "..advanceData.timesPurchased..L" < "..advanceData.maximumPurchaseCount )
        return advanceData.timesPurchased < advanceData.maximumPurchaseCount
    end
end

function TrainerHasSufficientRankFilter(advanceData)
    if ( (GameData.InteractData.maximumTrainingRank == nil) or (advanceData == nil) or (advanceData.minimumRank == nil) )
    then
        return true
    else
        return (GameData.InteractData.maximumTrainingRank >= advanceData.minimumRank)
    end
end

function InteractionUtils.AvailabilityIfSetFilter(advanceData, filter)

    -- Per production request, never ever show anything already purchased.
    if (InteractionUtils.HasAbilityFilter(advanceData)) then
        -- DEBUG(L"  suppressing"..advanceData.abilityInfo.name..L" since the character knows it")
        return false
    end
    
    if (InteractionUtils.HasPurchasedPackageToMaximum(advanceData))
    then
        return false
    end

    return filter or InteractionUtils.AvailabilityFilter(advanceData)
           
end

function InteractionUtils.AvailabilityFilter(advanceData, allPackages)

    -- per stakeholder request, never ever show anything the trainer cannot train you in
    if (not TrainerHasSufficientRankFilter(advanceData)) then
        return false
    end
    
    -- DEBUG(L"  Trainer level "..GameData.InteractData.maximumTrainingRank..L" tries ability "..advanceData.abilityInfo.name..L"( rank "..advanceData.minimumRank..L" required)")
    
    -- else, apply the filter
    return InteractionUtils.MeetsLevelRequirementsFilter(advanceData)   and
           InteractionUtils.MeetsRenownRequirementsFilter(advanceData)  and
           InteractionUtils.MeetsDependencies(advanceData, allPackages) and
           InteractionUtils.LessThanMaximumPurchaseCountFilter(advanceData)

end

function InteractionUtils.AbilityFilter(advanceData)
    if (advanceData == nil)
    then
        return false
    end
    
    if (advanceData.abilityInfo == nil)
    then
        return false
    end
    
    return (advanceData.abilityInfo.id ~= 0)
end

----------------------------------------------------------------
-- Training Type Requests
----------------------------------------------------------------
function InteractionUtils.StoreRequestedTrainingType(trainingType)
    InteractionUtils.requestedTrainingType = trainingType
end

function InteractionUtils.GetLastRequestedTrainingType()
    return InteractionUtils.requestedTrainingType
end

----------------------------------------------------------------
-- Further Utility Functions
----------------------------------------------------------------
