CultivationWindow = {}
CultivationWindow.plot = {}
CultivationWindow.versionNumber = 0.3
CultivationWindow.windowName = "CultivationWindow"

local windowName = CultivationWindow.windowName

-- constant data
CultivationWindow.NUM_OF_PLOTS  = GameData.Cultivation.NUM_OF_PLOTS
CultivationWindow.PLOT_1        = 1
CultivationWindow.PLOT_2        = 2
CultivationWindow.PLOT_3        = 3
CultivationWindow.PLOT_4        = 4

CultivationWindow.INSTRUCTION_ADDITIVE_SLOT_EMPTY  = 1
CultivationWindow.INSTRUCTION_ADDITIVE_SLOT_FILLED = 2

CultivationWindow.NUM_OF_STAGES     = GameData.CultivationStage.NUM_OF_STAGES
CultivationWindow.STAGE_NUM_EMPTY   = GameData.CultivationStage.EMPTY
CultivationWindow.STAGE_NUM_HARVEST = GameData.CultivationStage.GROWN
CultivationWindow.STAGE_NUM_HARVESTING = GameData.CultivationStage.HARVESTING

CultivationWindow.plotsInstructionText = GetString( StringTables.Default.TEXT_CULTIVATING_CLICK_PLOT_INSTRUCTION )

CultivationWindow.STATE_ALL_PLOTS = 1
CultivationWindow.STATE_SINGLE_PLOT = 2
CultivationWindow.currentState = CultivationWindow.STATE_ALL_PLOTS

-- TODO: Move to DefaultColor.lua
local ActionPendingColor = { r=255, g=255, b=50 }
local ActionDoneColor = { r=255, g=255, b=200 }

CultivationWindow.stageInfo =
{
	[GameData.CultivationStage.EMPTY] =
	{
	    StageName=GetString( StringTables.Default.LABEL_CULTIVATING_VACANT_PLOT ),
	    sliceName=nil,
	    backgroundSliceName=nil,
	    Instruction=GetString( StringTables.Default.TEXT_CULTIVATING_STAGE_0_EMPTY ),
	    cultivationType=GameData.CultivationTypes.SEED,
	},
	[GameData.CultivationStage.GERMINATION] =
	{
	    StageName=GetString( StringTables.Default.TEXT_CULTIVATION_STAGE_1_NAME ),
	    sliceName={ [GameData.CultivationTypes.SEED]="PlantStageIcon-1", [GameData.CultivationTypes.SPORE]="ShroomStageIcon-1" }, 
	    backgroundSliceName={ [GameData.CultivationTypes.SEED]="PlantStage-1", [GameData.CultivationTypes.SPORE]="ShroomStage-1" },
	    Instruction=GetString( StringTables.Default.TEXT_CULTIVATING_STAGE_1_GERMINATION ),
	    InstructionFilled=GetString( StringTables.Default.TEXT_CULTIVATING_STAGE_1_GERMINATION_FILLED ),
	    cultivationType=GameData.CultivationTypes.SOIL,
	},
	[GameData.CultivationStage.SEEDLING] = 
	{
	    StageName=GetString( StringTables.Default.TEXT_CULTIVATION_STAGE_2_NAME ), 
	    sliceName={ [GameData.CultivationTypes.SEED]="PlantStageIcon-2", [GameData.CultivationTypes.SPORE]="ShroomStageIcon-2" }, 
	    backgroundSliceName={ [GameData.CultivationTypes.SEED]="PlantStage-2", [GameData.CultivationTypes.SPORE]="ShroomStage-2" },
	    Instruction=GetString( StringTables.Default.TEXT_CULTIVATING_STAGE_2_SEEDLING ),
	    InstructionFilled=GetString( StringTables.Default.TEXT_CULTIVATING_STAGE_2_SEEDLING_FILLED ),
	    cultivationType=GameData.CultivationTypes.WATERCAN, 
	},
	[GameData.CultivationStage.FLOWERING] = 
	{
	    StageName=GetString( StringTables.Default.TEXT_CULTIVATION_STAGE_3_NAME ), 
	    sliceName={ [GameData.CultivationTypes.SEED]="PlantStageIcon-3", [GameData.CultivationTypes.SPORE]="ShroomStageIcon-3" }, 
	    backgroundSliceName={ [GameData.CultivationTypes.SEED]="PlantStage-3", [GameData.CultivationTypes.SPORE]="ShroomStage-3" },
	    Instruction=GetString( StringTables.Default.TEXT_CULTIVATING_STAGE_3_FLOWERING ), 
        InstructionFilled=GetString( StringTables.Default.TEXT_CULTIVATING_STAGE_3_FLOWERING_FILLED ), 
	    cultivationType=GameData.CultivationTypes.NUTRIENT, 
	},
	[GameData.CultivationStage.GROWN] = 
	{
	    StageName=GetString( StringTables.Default.TEXT_CULTIVATION_STAGE_4_NAME ), 
	    sliceName={ [GameData.CultivationTypes.SEED]="PlantStageIcon-3", [GameData.CultivationTypes.SPORE]="ShroomStageIcon-3" }, 
	    backgroundSliceName={ [GameData.CultivationTypes.SEED]="PlantStage-3", [GameData.CultivationTypes.SPORE]="ShroomStage-3" },
	    Instruction=GetString( StringTables.Default.TEXT_CULTIVATING_STAGE_4_GROWN ),
	    ActionSound=Sound.CULTIVATING_SUCCEEDED,
	},
	[GameData.CultivationStage.HARVESTING] = -- Same as grown state
	{
	    StageName=GetString( StringTables.Default.TEXT_CULTIVATION_STAGE_4_NAME ), 
	    sliceName={ [GameData.CultivationTypes.SEED]="PlantStageIcon-3", [GameData.CultivationTypes.SPORE]="ShroomStageIcon-3" }, 
	    backgroundSliceName={ [GameData.CultivationTypes.SEED]="PlantStage-3", [GameData.CultivationTypes.SPORE]="ShroomStage-3" },
	    Instruction=GetString( StringTables.Default.TEXT_CULTIVATING_STAGE_4_GROWN ),
	    ActionSound=Sound.CULTIVATING_SUCCEEDED,
	},
}

CultivationWindow.sounds =
{
	[GameData.CultivationTypes.SEED] = Sound.CULTIVATING_SEED_ADDED,
	[GameData.CultivationTypes.SPORE] = Sound.CULTIVATING_SEED_ADDED,
	[GameData.CultivationTypes.SOIL] = Sound.CULTIVATING_SOIL_ADDED,
	[GameData.CultivationTypes.WATERCAN] = Sound.CULTIVATING_WATER_ADDED,
	[GameData.CultivationTypes.NUTRIENT] = Sound.CULTIVATING_NUTRIENT_ADDED,
}
    
CultivationWindow.typeNames =
{
    [GameData.CultivationTypes.SEED]        = GetString( StringTables.Default.LABEL_SEED ),
    [GameData.CultivationTypes.SPORE]       = GetString( StringTables.Default.LABEL_SPORE ),
    [GameData.CultivationTypes.SOIL]        = GetString( StringTables.Default.LABEL_SOIL ),
    [GameData.CultivationTypes.WATERCAN]    = GetString( StringTables.Default.LABEL_WATERCAN ),
    [GameData.CultivationTypes.NUTRIENT]    = GetString( StringTables.Default.LABEL_NUTRIENT ),
}

CultivationWindow.backgroundSlice =
{
    [GameData.CultivationTypes.SEED]        = "PlotView-Background",
    [GameData.CultivationTypes.SPORE]       = "ShroomPlotView-Background",
}

local PlotNames =
{
    [CultivationWindow.PLOT_1] = GetString( StringTables.Default.LABEL_CULTIVATING_PLOT_1 ),
    [CultivationWindow.PLOT_2] = GetString( StringTables.Default.LABEL_CULTIVATING_PLOT_2 ),
    [CultivationWindow.PLOT_3] = GetString( StringTables.Default.LABEL_CULTIVATING_PLOT_3 ),
    [CultivationWindow.PLOT_4] = GetString( StringTables.Default.LABEL_CULTIVATING_PLOT_4 ),
}

local AdditiveData =
{
    [GameData.CultivationTypes.SOIL]        = { name="Soil", slice="Dirt" },
    [GameData.CultivationTypes.WATERCAN]    = { name="Water", slice="WaterDrop" },
    [GameData.CultivationTypes.NUTRIENT]    = { name="Nutrient", slice="GreenCross" }
}
    
function CultivationWindow.Initialize()
    
    -- Register Events  
    WindowRegisterEventHandler( "CultivationWindow", SystemData.Events.PLAYER_CULTIVATION_UPDATED, "CultivationWindow.UpdatePlotFromServer")
    WindowRegisterEventHandler( "CultivationWindow", SystemData.Events.TRADE_SKILL_UPDATED, "CultivationWindow.UpdateSkillText")
    
	WindowSetGameActionData( "CultivationWindowHarvest", GameData.PlayerActions.PERFORM_CRAFTING, GameData.TradeSkills.CULTIVATION, L"" )
 
    -- Set Static Text
    LabelSetText( "CultivationWindowTitleBarText", GetString( StringTables.Default.LABEL_CULTIVATING_WINDOW_TITLE_NAME ) )
	ButtonSetText( windowName.."Harvest", GetString( StringTables.Default.LABEL_CULTIVATING_HARVEST ) )
	ButtonSetText( windowName.."SinglePlotHome", GetString( StringTables.Default.LABEL_CULTIVATING_HOME_BUTTON ) )
	ButtonSetText( windowName.."Uproot", GetString( StringTables.Default.LABEL_CULTIVATING_CANCEL_BUTTON ) )
	LabelSetText( windowName.."SinglePlotStage1", CultivationWindow.stageInfo[GameData.CultivationStage.GERMINATION].StageName )
	LabelSetText( windowName.."SinglePlotStage2", CultivationWindow.stageInfo[GameData.CultivationStage.SEEDLING].StageName )
	LabelSetText( windowName.."SinglePlotStage3", CultivationWindow.stageInfo[GameData.CultivationStage.FLOWERING].StageName )
	
	-- Set the background for the Seed/Spore slot
	DynamicImageSetTextureSlice( windowName.."SinglePlotSeedSporeBackground", "Black-Slot" )
	
	-- Set the background
	DynamicImageSetTextureSlice( windowName.."SinglePlotNutrientBackground", "GreenCross-Slot" )
	DynamicImageSetTextureSlice( windowName.."SinglePlotWaterBackground",    "WaterDrop-Slot" )

	for index=GameData.CultivationTypes.SOIL, GameData.CultivationTypes.NUTRIENT
	do
	    local iconName = windowName.."SinglePlot"..AdditiveData[index].name.."Icon"
	    DynamicImageSetTextureSlice( iconName, AdditiveData[index].slice )
	    WindowSetShowing( iconName, false )
	end

	CultivationWindow.InitAllPlots()
end


function CultivationWindow.IsCultivatingItem( itemData ) 
	return( itemData and itemData.cultivationType  and itemData.cultivationType ~= 0)
end

-- Note: this automatically calls CultivationWindow.IsCultivatingItem() to verify the item is a cultivation item 
function CultivationWindow.PlayerMeetsCultivatingRequirement( itemData ) 

	return( CultivationWindow.IsCultivatingItem( itemData ) and
            GameData.TradeSkillLevels[GameData.TradeSkills.CULTIVATION] ~= nil and
		    GameData.TradeSkillLevels[GameData.TradeSkills.CULTIVATION] >= itemData.craftingSkillRequirement )
end

function CultivationWindow.GetCultivationTypeName( itemData )
    local itemTypeText = L""
    
    if( itemData and itemData.cultivationType  and itemData.cultivationType ~= 0) then	
        itemTypeText = CultivationWindow.typeNames[itemData.cultivationType]
    end

	return itemTypeText
end



-- The server is currently not pushing existing plot data during login, so we need to pull it just once
--
function CultivationWindow.InitAllPlots()

    for plotNum = 1, CultivationWindow.NUM_OF_PLOTS do
		-- TODO: expose these enum values from C++
		-- crafting type 3 = ETRADE_SKILL_CULTIVATION, action 4 = ECLTCMD_GET_INFO
		UpdateCraftingStatus(3, 4, plotNum)
		DynamicImageSetTextureSlice( windowName.."PlotsPlot"..plotNum.."NumberFrameNumber", "Square-"..plotNum )
	end
end

-- A function to update a timer
-- returns: the new time and whether it the seconds have changed or not
local function UpdateTimer( timer, elapsedTime )
    local newTimer = timer - elapsedTime
    if newTimer < 0
    then
        newTimer = 0
    end
    
    return newTimer, math.floor( newTimer ) < math.floor( timer )
end

local SinglePlotStageFrameNames =
{
    [GameData.CultivationStage.GERMINATION] = windowName.."SinglePlotSoil",
    [GameData.CultivationStage.SEEDLING]    = windowName.."SinglePlotWater",
    [GameData.CultivationStage.FLOWERING]   = windowName.."SinglePlotNutrient",
}

local function UpdateActivePlotStageTimer( stageNum, stageTime )
    if( stageNum ~= GameData.CultivationStage.EMPTY and stageNum ~= GameData.CultivationStage.GROWN )
    then
        LabelSetText( SinglePlotStageFrameNames[stageNum].."StageTimer", TimeUtils.FormatTimeCondensed( stageTime ) )
    end
end

local function SetActivePlotStage( stageNum, plotData )
    local defaultColor = DefaultColor.RED
    local currentStageColor = DefaultColor.GREEN
    local numResourceStages = CultivationWindow.NUM_OF_STAGES - 3
    
    if( stageNum < 1 or stageNum > numResourceStages )
    then 
        defaultColor = DefaultColor.ZERO_TINT
        currentStageColor = defaultColor
    end
    
    for stage = 1, numResourceStages -- do not count empty or grown or harvesting as a stage here
    do
        local isCurrentStageNum = stage == stageNum
        local isFilled          = plotData.Additives[ CultivationWindow.stageInfo[stage].cultivationType ].id ~= 0
        WindowSetShowing( SinglePlotStageFrameNames[stage].."StageTimer", isCurrentStageNum )
        WindowSetShowing( windowName.."SinglePlotStage"..stage, isCurrentStageNum )
        
        -- Tint the windows to show which is active
        if( isCurrentStageNum )
        then
            WindowSetTintColor( SinglePlotStageFrameNames[stage], currentStageColor.r, currentStageColor.g, currentStageColor.b )
        else
            WindowSetTintColor( SinglePlotStageFrameNames[stage], defaultColor.r, defaultColor.g, defaultColor.b )
        end
        WindowSetTintColor( SinglePlotStageFrameNames[stage].."Icon", DefaultColor.ZERO_TINT.r, DefaultColor.ZERO_TINT.g, DefaultColor.ZERO_TINT.b )
        WindowSetTintColor( SinglePlotStageFrameNames[stage].."Background", DefaultColor.ZERO_TINT.r, DefaultColor.ZERO_TINT.g, DefaultColor.ZERO_TINT.b )
    end
end

function CultivationWindow.UpdateTimers( timePassed )

	local plotsShowing = CultivationWindow.currentState == CultivationWindow.STATE_ALL_PLOTS
	
    for plotNum = 1, CultivationWindow.NUM_OF_PLOTS do
		local plotData = CultivationWindow.plot[plotNum]
	    
		if( plotData )
		then
		
		    if( plotData.stageTimerOn )
		    then	
			    plotData.StageTimer, plotData.secondsChanged = UpdateTimer( plotData.StageTimer, timePassed )	
			    if plotData.StageTimer <= 0 then
				    plotData.stageTimerOn = false
			    end
    			
			    if( plotData.secondsChanged and plotsShowing )
			    then
			        LabelSetText(windowName.."PlotsPlot"..plotNum.."StageTimer", TimeUtils.FormatTimeCondensed( plotData.StageTimer )	)
			    end
			end
			
            if( plotData.totalTimerOn )
            then	
			    plotData.TotalTimer, plotData.secondsChanged = UpdateTimer( plotData.TotalTimer, timePassed )
			    if plotData.TotalTimer <= 0 then
				    plotData.totalTimerOn = false
			    end
    			
			    if( plotData.secondsChanged and plotsShowing)
			    then
			        LabelSetText(windowName.."PlotsPlot"..plotNum.."TotalTimer", TimeUtils.FormatTime( plotData.TotalTimer ) )
			    end
			end
			
		end
	end
	
	-- Update the single plot timers as well
	local activePlotNum = GameData.Player.Cultivation.CurrentPlot
	if( not plotsShowing and CultivationWindow.plot[activePlotNum].secondsChanged )
	then
	    local activePlot = CultivationWindow.plot[activePlotNum]
	    LabelSetText(windowName.."SinglePlotTimeLeft", GetString(StringTables.Default.LABEL_CULTIVATING_PLOT_TIME_LEFT)..TimeUtils.FormatTime( activePlot.TotalTimer ) )
	    UpdateActivePlotStageTimer( activePlot.StageNum, activePlot.StageTimer )
	end
end

function CultivationWindow.UpdatePlotFromServer(  )
	
	local plotNum = GameData.Player.Cultivation.UpdatedIndex
	CultivationWindow.UpdatePlot( plotNum )
end

function CultivationWindow.PlaySoundForStageChange( stageNumber )
	
	--if WindowGetShowing("CultivationWindow") and 
	if CultivationWindow.stageInfo[stageNumber] and 
	   CultivationWindow.stageInfo[stageNumber].ActionSound then
	   
		Sound.Play( CultivationWindow.stageInfo[stageNumber].ActionSound )
	end
end

function CultivationWindow.PlaySoundForItemType( itemData )

	if( itemData and CultivationWindow.sounds[itemData.cultivationType] and
        CultivationWindow.PlayerMeetsCultivatingRequirement( itemData ) )
	then
		Sound.Play( CultivationWindow.sounds[itemData.cultivationType] )
	else
		-- play an error sound
		Sound.Play( Sound.CULTIVATING_ADD_FAILED )	
	end
end

function CultivationWindow.UpdateSingleActivePlot( plotData, stageInfo )

    local validStageBackground = stageInfo.backgroundSliceName ~= nil and stageInfo.backgroundSliceName[plotData.Seed.cultivationType] ~= nil
    WindowSetShowing( windowName.."SinglePlotStageBackground", validStageBackground )
    if( validStageBackground )
    then
        DynamicImageSetTextureSlice( windowName.."SinglePlotStageBackground", stageInfo.backgroundSliceName[plotData.Seed.cultivationType] )
        DynamicImageSetTextureSlice( windowName.."SinglePlotMainBackground", CultivationWindow.backgroundSlice[plotData.Seed.cultivationType] )
    else
        DynamicImageSetTextureSlice( windowName.."SinglePlotMainBackground", CultivationWindow.backgroundSlice[GameData.CultivationTypes.SEED] )
    end
     
    WindowSetShowing( windowName.."SinglePlotNutrientIcon", plotData.Additives[GameData.CultivationTypes.NUTRIENT].id ~= 0 )
	WindowSetShowing( windowName.."SinglePlotWaterIcon",    plotData.Additives[GameData.CultivationTypes.WATERCAN].id ~= 0  )
	WindowSetShowing( windowName.."SinglePlotSoilIcon",     plotData.Additives[GameData.CultivationTypes.SOIL].id ~= 0  )
    
    -- Show the icon of the seed
    WindowSetShowing( windowName.."SinglePlotSeedSporeIcon", plotData.Seed.iconNum ~= 0 )
    local texture, x, y = GetIconData( plotData.Seed.iconNum )
    DynamicImageSetTexture (windowName.."SinglePlotSeedSporeIcon", texture, x, y)

    LabelSetText( windowName.."SinglePlotName", PlotNames[GameData.Player.Cultivation.CurrentPlot] )
    
    local harvestTime = plotData.StageNum == CultivationWindow.STAGE_NUM_HARVEST or plotData.StageNum == CultivationWindow.STAGE_NUM_HARVESTING
	WindowSetShowing( windowName.."Harvest", harvestTime )
	
	local plotEmpty = plotData.StageNum == CultivationWindow.STAGE_NUM_EMPTY
	WindowSetShowing( windowName.."Uproot", not plotEmpty and not harvestTime )
	WindowSetShowing( windowName.."SinglePlotTimeLeft", not harvestTime )
	
	local timeText = nil
	if( harvestTime )
	then
	    plotData.totalTimerOn = false
	    plotData.stageTimerOn = false
	elseif( plotEmpty )
	then
		plotData.totalTimerOn = false
		plotData.stageTimerOn = false
		timeText = stageInfo.StageName
	else		
		plotData.totalTimerOn = true
		plotData.stageTimerOn = true
		timeText = GetString( StringTables.Default.LABEL_CULTIVATING_PLOT_TIME_LEFT )..TimeUtils.FormatTime( plotData.TotalTimer )
	end
	
	-- Set the time text if we have any
	if( timeText )
	then
	    LabelSetText( windowName.."SinglePlotTimeLeft", timeText  )
	end
        
    local germinationFilled = plotData.StageNum == GameData.CultivationStage.GERMINATION
                              and plotData.Additives[GameData.CultivationTypes.SOIL].id ~= 0
    local seedlingFilled = plotData.StageNum == GameData.CultivationStage.SEEDLING
                           and plotData.Additives[GameData.CultivationTypes.WATERCAN].id ~= 0
    local floweringFilled = plotData.StageNum == GameData.CultivationStage.FLOWERING
                            and plotData.Additives[GameData.CultivationTypes.NUTRIENT].id ~= 0
	local instructionIndex = stageInfo.Instruction
	if( germinationFilled or seedlingFilled or floweringFilled)
	then
        instructionIndex = stageInfo.InstructionFilled
	end
	
	LabelSetText( windowName.."Instruction", instructionIndex )
	
	-- Set the skill
	LabelSetText( windowName.."SinglePlotSkill", GetString( StringTables.Default.LABEL_SKILL )..L": "..GameData.TradeSkillLevels[GameData.TradeSkills.CULTIVATION]  )
end

function CultivationWindow.UpdateSkillText()
    if( CultivationWindow.currentState == CultivationWindow.STATE_SINGLE_PLOT )
    then
        LabelSetText( windowName.."SinglePlotSkill", GetString( StringTables.Default.LABEL_SKILL )..L": "..GameData.TradeSkillLevels[GameData.TradeSkills.CULTIVATION]  )
    end
end

function CultivationWindow.UpdateLockStatus( plotWindowName, locked )
    if( locked )
    then
        WindowSetTintColor( plotWindowName, DefaultColor.MEDIUM_GRAY.r, DefaultColor.MEDIUM_GRAY.g, DefaultColor.MEDIUM_GRAY.b )
        LabelSetText(plotWindowName.."TotalTimer", GetString( StringTables.Default.LABEL_CULTIVATING_LOCKED_PLOT ) )
    else
        WindowSetTintColor( plotWindowName, DefaultColor.ZERO_TINT.r, DefaultColor.ZERO_TINT.g, DefaultColor.ZERO_TINT.b )
    end
end

function CultivationWindow.UpdateAllPlots()
    for plotNum = 1, CultivationWindow.NUM_OF_PLOTS do
		CultivationWindow.UpdatePlot( plotNum )
	end
end

function CultivationWindow.UpdatePlot( plotNum )

	plotNum = plotNum or GameData.Player.Cultivation.UpdatedIndex

	local previousStageNum = -1
	if CultivationWindow.plot[plotNum] and CultivationWindow.plot[plotNum].StageNum then
		previousStageNum = CultivationWindow.plot[plotNum].StageNum 
	end
	
	local plotData = GetCultivationInfo( plotNum )
	CultivationWindow.plot[plotNum] = plotData
	local stageInfo = CultivationWindow.stageInfo[plotData.StageNum]
	
	if plotData == nil
	then
		DEBUG(L"***ERROR in CultivationWindow.UpdatePlot: bad plotData")
		return
	elseif plotData.StageNum == nil
	then
		DEBUG(L"***ERROR in CultivationWindow.UpdatePlot: bad StageNum")
		return
    elseif plotData.StageNum == 255
    then
        stageInfo = CultivationWindow.stageInfo[GameData.CultivationStage.EMPTY]
        CultivationWindow.plot[plotNum].StageNum = GameData.CultivationStage.EMPTY
	elseif plotData.StageNum > 5
	then
		DEBUG(L"***ERROR in CultivationWindow.UpdatePlot: bad StageNum="..plotData.StageNum)
		return
	elseif stageInfo == nil then
		DEBUG(L"***ERROR in CultivationWindow.UpdatePlot: stageInfo not found")
		return
	end
	
	local singlePlotMode = (CultivationWindow.currentState == CultivationWindow.STATE_SINGLE_PLOT and GameData.Player.Cultivation.CurrentPlot == plotNum)
	if( singlePlotMode )
	then
	    CultivationWindow.UpdateSingleActivePlot( plotData, stageInfo )
	    SetActivePlotStage( plotData.StageNum, plotData )
	else
	    local plotName = "CultivationWindowPlotsPlot"..plotNum
        
	    -- Stage Indicator Icon
	    local validSlice = stageInfo.sliceName ~= nil and stageInfo.sliceName[plotData.Seed.cultivationType] ~= nil and stageInfo.sliceName[plotData.Seed.cultivationType] ~= ""
	    WindowSetShowing( plotName.."CircleFrameIcon", validSlice )

	    if( validSlice )
	    then
            DynamicImageSetTextureSlice( plotName.."CircleFrameIcon", stageInfo.sliceName[plotData.Seed.cultivationType] )
        end

	    -- DEBUG(L" plot # "..plotNum..L", PlantName="..plotData.PlantName..L", SeedName="..plotData.Seed.name..L", StageNum="..plotData.StageNum..L", StageTimer="..plotData.StageTimer..L",
	    --       TotalTimer="..plotData.TotalTimer..L", IngredientName="..plotData.IngredientName)
	    local plotFilled = plotData.StageNum ~= CultivationWindow.STAGE_NUM_HARVEST and plotData.StageNum ~= CultivationWindow.STAGE_NUM_EMPTY and plotData.StageNum ~= CultivationWindow.STAGE_NUM_HARVESTING
    	
	    WindowSetShowing( plotName.."StageTimer",  plotFilled)
    	
	    if not plotFilled
        then
		    plotData.stageTimerOn = false
	    else		
		    local stageTimeRemaining = TimeUtils.FormatTimeCondensed( plotData.StageTimer )	
		    LabelSetText(plotName.."StageTimer", stageTimeRemaining)
    		
		    plotData.stageTimerOn = true
	    end

	    local harvestTime = plotData.StageNum == CultivationWindow.STAGE_NUM_HARVEST or plotData.StageNum == CultivationWindow.STAGE_NUM_HARVESTING
    	
	    WindowSetShowing( plotName.."TotalTimer", not harvestTime )
    	
        if( harvestTime )
	    then
	        plotData.totalTimerOn = false
	    elseif( plotData.StageNum == CultivationWindow.STAGE_NUM_EMPTY )
	    then
		    LabelSetText(plotName.."TotalTimer", GetString( StringTables.Default.LABEL_CULTIVATING_VACANT_PLOT ) )
		    plotData.totalTimerOn = false
	    else
		    LabelSetText(plotName.."TotalTimer", TimeUtils.FormatTime( plotData.TotalTimer ) )
		    -- start timer countdown/update for total time
		    plotData.totalTimerOn = true
	    end
	    
	    for index=GameData.CultivationTypes.SOIL, GameData.CultivationTypes.NUTRIENT
	    do
	        local iconFrameName = plotName..AdditiveData[index].name.."CircleFrame"
	        local iconName = iconFrameName.."Icon"
	        if( plotData.Additives[index].id ~= 0 )
	        then
	            DynamicImageSetTextureSlice( iconName, AdditiveData[index].slice.."-Mini" )
	        else
	            DynamicImageSetTextureSlice( iconName, AdditiveData[index].slice.."-Mini-SLOT" )
	        end
	        
	        if( plotData.Locked )
	        then
	            WindowSetTintColor( iconFrameName, DefaultColor.MEDIUM_GRAY.r, DefaultColor.MEDIUM_GRAY.g, DefaultColor.MEDIUM_GRAY.b )
	        elseif( plotData.Seed.id == 0 or harvestTime )
	        then
	            WindowSetTintColor( iconFrameName, DefaultColor.ZERO_TINT.r, DefaultColor.ZERO_TINT.g, DefaultColor.ZERO_TINT.b )
	        elseif( stageInfo.cultivationType == index )
	        then
	            WindowSetTintColor( iconFrameName, DefaultColor.GREEN.r, DefaultColor.GREEN.g, DefaultColor.GREEN.b )
	        else
	            WindowSetTintColor( iconFrameName, DefaultColor.RED.r, DefaultColor.RED.g, DefaultColor.RED.b )
	        end
	        
	        if(  plotData.Locked )
	        then
	            WindowSetTintColor( iconName, DefaultColor.MEDIUM_GRAY.r, DefaultColor.MEDIUM_GRAY.g, DefaultColor.MEDIUM_GRAY.b )
	        else
	            WindowSetTintColor( iconName, DefaultColor.ZERO_TINT.r, DefaultColor.ZERO_TINT.g, DefaultColor.ZERO_TINT.b )
	        end
	    end
	    
	    CultivationWindow.UpdateLockStatus( plotName, plotData.Locked )
	end

	-- Play sounds sometimes when stage changes automatically
	if( previousStageNum ~= plotData.StageNum )
	then
		CultivationWindow.PlaySoundForStageChange( plotData.StageNum )
	end
end

function CultivationWindow.ToggleShowing()
    if( WindowGetShowing( "CultivationWindow" ) )
    then
        CultivationWindow.Hide()
    else
        CultivationWindow.Show()
    end
end

function CultivationWindow.OnShown()
    CultivationWindow.InitAllPlots()
    WindowUtils.OnShown(CultivationWindow.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
    EA_BackpackUtilsMediator.ShowBackpack()
end

function CultivationWindow.ShowPlot()
    local windowId = WindowGetId( SystemData.ActiveWindow.name )
    if( not CultivationWindow.plot[windowId].Locked )
    then
        GameData.Player.Cultivation.CurrentPlot = windowId
        CultivationWindow.currentState = CultivationWindow.STATE_SINGLE_PLOT
        WindowSetShowing( windowName.."Plots", false )
        WindowSetShowing( windowName.."SinglePlot", true )
        CultivationWindow.UpdatePlot( GameData.Player.Cultivation.CurrentPlot )
    end
end

function CultivationWindow.Home()
    WindowSetShowing( windowName.."Plots", true )
    WindowSetShowing( windowName.."SinglePlot", false )
    WindowSetShowing( windowName.."Harvest", false )
    WindowSetShowing( windowName.."Uproot", false )
	LabelSetText( windowName.."Instruction", CultivationWindow.plotsInstructionText )
	
    if( CultivationWindow.currentState == CultivationWindow.STATE_SINGLE_PLOT )
    then
        CultivationWindow.currentState = CultivationWindow.STATE_ALL_PLOTS
        GameData.Player.Cultivation.CurrentPlot = 0
        CultivationWindow.UpdateAllPlots()
    end
end

function CultivationWindow.Show()

    CultivationWindow.UpdateAllPlots()
	
	CultivationWindow.Home()
	
	WindowSetShowing( windowName, true )
end

function CultivationWindow.Hide()

	WindowSetShowing( windowName, false)
	GameData.Player.Cultivation.CurrentPlot = 0
end

function CultivationWindow.AddItem( backpackSlot, plotNum, itemData, backpackType )
    local plotData = CultivationWindow.plot[plotNum]
    if( plotData == nil )
    then 
        return
    end
    local stageInfo = CultivationWindow.stageInfo[plotData.StageNum]
    
    -- Attempt to add the object	
    AddCraftingItem( 3, plotNum, backpackSlot, backpackType )   
    

    local bPlaySound =  stageInfo ~= nil
                        and plotData.Additives[stageInfo.cultivationType] ~= nil
                        and plotData.Additives[stageInfo.cultivationType].id == 0
                        and itemData.cultivationType == stageInfo.cultivationType
                        
                        
    local bPlaySoundForSeed =   stageInfo ~= nil
                                and stageInfo.cultivationType == GameData.CultivationTypes.SEED
                                and ( itemData.cultivationType == GameData.CultivationTypes.SPORE
                                or itemData.cultivationType == GameData.CultivationTypes.SEED )
                                and plotData.Seed.id == 0
    
    
    -- check that plot is ready for adding ingredient and 
    --    that the item is the right resource type for this stage
    if( bPlaySound or bPlaySoundForSeed )
    then
          
        -- play sound based on the cultivationType of the item
        CultivationWindow.PlaySoundForItemType(itemData)

    else
        -- play an error sound
        Sound.Play( Sound.CULTIVATING_ADD_FAILED )	
    end
end

function CultivationWindow.OnResourceLButtonUp()

	if Cursor.IconOnCursor() then
	
		local plotNum = GameData.Player.Cultivation.CurrentPlot

        local backpackType = EA_Window_Backpack.GetCurrentBackpackType()
        local currentCursor = EA_Window_Backpack.GetCursorForBackpack( backpackType )
		if( Cursor.Data and Cursor.Data.SourceSlot and Cursor.Data.Source == currentCursor )
		then
		    -- DEBUG(L"Icon is on Cursor and valid")
            local cultivationType = WindowGetId( SystemData.ActiveWindow.name )
            
            local itemData = DataUtils.GetItemData( Cursor.Data.Source, Cursor.Data.SourceSlot )

		    if( itemData.cultivationType == cultivationType or
		        ( cultivationType == GameData.CultivationTypes.SEED and itemData.cultivationType == GameData.CultivationTypes.SPORE ) )
		    then
                CultivationWindow.AddItem( Cursor.Data.SourceSlot, plotNum, itemData, backpackType )
		    end
		end
		
		Cursor.Clear () -- TODO: verify this doesn't interfere with our Sound
	end
end

local function CultivationResourceShowToolTip( itemData, emptyResourceText )
    if( itemData and itemData.uniqueID ~= 0 )
    then
        Tooltips.CreateItemTooltip ( itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_RIGHT, true )
    else
        Tooltips.CreateTextOnlyTooltip ( SystemData.ActiveWindow.name, emptyResourceText )
        Tooltips.AnchorTooltip( nil )
    end
end

function CultivationWindow.OnSeedMouseOver()
    CultivationResourceShowToolTip( CultivationWindow.plot[GameData.Player.Cultivation.CurrentPlot].Seed, GetString( StringTables.Default.TOOLTIP_CULTIVATING_SEED ) )
end

function CultivationWindow.OnSoilMouseOver()
    CultivationResourceShowToolTip( CultivationWindow.plot[GameData.Player.Cultivation.CurrentPlot].Additives[GameData.CultivationTypes.SOIL],
                                    GetString( StringTables.Default.TOOLTIP_CULTIVATING_SOIL ) )
end

function CultivationWindow.OnWatercanMouseOver()
    CultivationResourceShowToolTip( CultivationWindow.plot[GameData.Player.Cultivation.CurrentPlot].Additives[GameData.CultivationTypes.WATERCAN],
                                    GetString( StringTables.Default.TOOLTIP_CULTIVATING_WATER ) )
end

function CultivationWindow.OnNutrientMouseOver()
    CultivationResourceShowToolTip( CultivationWindow.plot[GameData.Player.Cultivation.CurrentPlot].Additives[GameData.CultivationTypes.NUTRIENT],
                                    GetString( StringTables.Default.TOOLTIP_CULTIVATING_NUTRIENT ) )
end

local ResourceToolTips =
{
    [GameData.CultivationTypes.SEED] = CultivationWindow.OnSeedMouseOver,
    [GameData.CultivationTypes.SPORE] = CultivationWindow.OnSeedMouseOver,
    [GameData.CultivationTypes.SOIL] = CultivationWindow.OnSoilMouseOver,
    [GameData.CultivationTypes.WATERCAN] = CultivationWindow.OnWatercanMouseOver,
    [GameData.CultivationTypes.NUTRIENT] = CultivationWindow.OnNutrientMouseOver,
}

function CultivationWindow.OnResourceMouseOver()
    local resourceType = WindowGetId( SystemData.ActiveWindow.name )
    ResourceToolTips[resourceType]()
end

function CultivationWindow.OnPlotMouseOver()
    local backgroundName = SystemData.ActiveWindow.name.."Background"
    DynamicImageSetTextureSlice( backgroundName, "Plot-Rollover" )
end

function CultivationWindow.OnPlotMouseOverEnd()
    local backgroundName = SystemData.ActiveWindow.name.."Background"
    DynamicImageSetTextureSlice( backgroundName, "Plot" )
end

function CultivationWindow.OnMouseOverHarvestButton()

    -- Tooltips.CreateTextOnlyTooltip ( SystemData.ActiveWindow.name, L"Press to harvest weeds and a clipping into your backpack" ) --GetString( StringTables.Default.LABEL_MONEY ) )
    -- Tooltips.AnchorTooltip( nil )
end


function CultivationWindow.AbortPlant()
	-- crafting type 3 = ETRADE_SKILL_CULTIVATION, action 3 = ECLTCMD_RESET_PLOT
	UpdateCraftingStatus( 3, 3, GameData.Player.Cultivation.CurrentPlot )
end

function CultivationWindow.Cancel()
    DialogManager.MakeTwoButtonDialog(  GetString( StringTables.Default.TEXT_CULTIVATING_CANCEL_CONFIRMATION ), 
                                        GetString( StringTables.Default.LABEL_YES ), CultivationWindow.AbortPlant, 
                                        GetString( StringTables.Default.LABEL_NO ),  nil,
                                        nil, nil, nil, nil, DialogManager.TYPE_MODE_LESS)
end

function CultivationWindow.OnUprootButtonMouseOver()

	local windowName = SystemData.ActiveWindow.name
	local text = GetStringFromTable( "Default",  StringTables.Default.TOOLTIP_CULTIVATING_CANCEL_BUTTON )
    
	Tooltips.CreateTextOnlyTooltip( windowName, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_VARIABLE )
end


function CultivationWindow.OnRButtonUp()
    -- Create the context menu and clear the cursor
    EA_Window_ContextMenu.CreateOpacityOnlyContextMenu( windowName )
    if Cursor.IconOnCursor()
    then
        Cursor.Clear()
    end
end

function CultivationWindow.Done()
	CultivationWindow.Hide()
end


function CultivationWindow.Shutdown()
    WindowUnregisterEventHandler( windowName, SystemData.Events.PLAYER_CULTIVATION_UPDATED )
end


function CultivationWindow.AutoAddItem( backpackSlot, itemData, backpackType )

    local plotNum = GameData.Player.Cultivation.CurrentPlot
    if( plotNum )
    then
        CultivationWindow.AddItem( backpackSlot, plotNum, itemData, backpackType )
    end
end

function CultivationWindow.WouldBePossibleToAdd( itemData )
    local plotNum = GameData.Player.Cultivation.CurrentPlot
    if( plotNum > 0 and plotNum <= CultivationWindow.NUM_OF_PLOTS )
    then
        return true
    end
    return false
end
