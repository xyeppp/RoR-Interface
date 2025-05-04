

PQLootWindow = 
{	
	
    versionNumber = 1.3,

    
    TIME_WHERE_ALL_ROLLS_ARE_VISIBLE = 2,
    MAX_TIME_BETWEEN_ROLLS = 1,
    
    MAX_NUM_OF_SACK_ICONS = 8,
    
    TIMER_OFF = TimedStateMachine.TIMER_OFF,
    
    -- TODO: these values should really be exposed from C++
    NO_MEDAL_GRADE		= 3,
    BRONZE_MEDAL_GRADE	= 2,
    SILVER_MEDAL_GRADE	= 1,
    GOLD_MEDAL_GRADE	= 0,
    
    GOLD_MEDAL_ICON_NUM =	"PQMedalGold",	
    SILVER_MEDAL_ICON_NUM = "PQMedalSilver",	
    BRONZE_MEDAL_ICON_NUM = "PQMedalBronze",	
    
    NO_MEDAL_TEXT = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_NO_MEDAL_PLACEHOLDER ),
    
    REWARDS_WHITE_INDEX  = GameData.PQData.PQ_SACK_WHITE,
    REWARDS_GREEN_INDEX  = GameData.PQData.PQ_SACK_GREEN,
    REWARDS_BLUE_INDEX   = GameData.PQData.PQ_SACK_BLUE,
    REWARDS_PURPLE_INDEX = GameData.PQData.PQ_SACK_PURPLE,
    REWARDS_SILVER_INDEX = GameData.PQData.PQ_SACK_SILVER,
    REWARDS_GOLD_INDEX   = GameData.PQData.PQ_SACK_GOLD,
    
    NUM_OF_REWARDS_INDICES = 6,
    REWARDS_NO_REWARD_INDEX = GameData.PQData.PQ_SACK_NONE,
    REWARDS_UNKNOWN_INDEX   = GameData.PQData.PQ_SACK_UNKNOWN,
    --REWARDS_ORANGE_INDEX  = 6,	-- NOT CURRENTLY USED, SO THIS ISN'T IMPLEMENTED IN THE LUA
    
    PURPLE_SACK_ICON_NUM	= 554,
    BLUE_SACK_ICON_NUM  	= 551,
    GREEN_SACK_ICON_NUM 	= 553,
    WHITE_SACK_ICON_NUM 	= 555,
    GOLD_SACK_ICON_NUM  	= 552,
    SILVER_SACK_ICON_NUM	= 555,
    
    PURPLE_SACK_SLICE_NAME	= "PQSackPurple",
    BLUE_SACK_SLICE_NAME 	= "PQSackBlue",
    GREEN_SACK_SLICE_NAME	= "PQSackGreen",
    WHITE_SACK_SLICE_NAME	= "PQSackSilver", -- "PQSackWhite",
    GOLD_SACK_SLICE_NAME 	= "PQSackGold",
    SILVER_SACK_SLICE_NAME	= "PQSackSilver",
    
    UNKNOWN_REWARD_TEXT		= GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_UNKNOWN_ICON_PLACEHOLDER ), 
    NO_REWARD_TEXT			= L" ",
    
    DEFAULT_TEXT_COLOR	= { r=255, g=204, b=102 },  -- yellow
    HIGHLIGHT_COLOR		= { r=255, g=255, b=0},	    -- yellow
    OUTLINE_BOX_COLOR	= { r=251, g=236, b=3 },    -- orangy yellow
    INSTRUCTION_COLOR	= { r=3,   g=194, b=255},   -- light blue
    
}

-- shorthand for making this easier to read
local PQLW = PQLootWindow

PQLootWindow.scoreboardData = {}

PQLootWindow.medalName =
{
    [PQLW.GOLD_MEDAL_GRADE]		= GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_GOLD_AWARD),
    [PQLW.SILVER_MEDAL_GRADE]	= GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SILVER_AWARD),
    [PQLW.BRONZE_MEDAL_GRADE]	= GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_BRONZE_AWARD ), 
    [PQLW.NO_MEDAL_GRADE]		= GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_NO_AWARD ),
}	

PQLootWindow.medalIcon =
{
    [PQLW.GOLD_MEDAL_GRADE]		= PQLW.GOLD_MEDAL_ICON_NUM,
    [PQLW.SILVER_MEDAL_GRADE]	= PQLW.SILVER_MEDAL_ICON_NUM,
    [PQLW.BRONZE_MEDAL_GRADE]	= PQLW.BRONZE_MEDAL_ICON_NUM,
}	


PQLootWindow.sackName =
{			
    [PQLW.REWARDS_NO_REWARD_INDEX]	= GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_NO_REWARD ), 
    [PQLW.REWARDS_PURPLE_INDEX]		= GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_PURPLE_REWARD ), 
    [PQLW.REWARDS_BLUE_INDEX]  		= GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_BLUE_REWARD ), 
    [PQLW.REWARDS_GREEN_INDEX] 		= GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_GREEN_REWARD ), 
    [PQLW.REWARDS_WHITE_INDEX] 		= GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_WHITE_REWARD ), 
    [PQLW.REWARDS_GOLD_INDEX]  		= GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_GOLD_REWARD ), 
    [PQLW.REWARDS_SILVER_INDEX]		= GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SILVER_REWARD ), 
    [PQLW.REWARDS_UNKNOWN_INDEX]	= GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_UNKNOWN_REWARD ),  
}

PQLootWindow.sackIcon =
{			
    [PQLW.REWARDS_PURPLE_INDEX]		= PQLW.PURPLE_SACK_ICON_NUM,
    [PQLW.REWARDS_BLUE_INDEX]  		= PQLW.BLUE_SACK_ICON_NUM,
    [PQLW.REWARDS_GREEN_INDEX] 		= PQLW.GREEN_SACK_ICON_NUM,
    [PQLW.REWARDS_WHITE_INDEX] 		= PQLW.WHITE_SACK_ICON_NUM,
    [PQLW.REWARDS_GOLD_INDEX]  		= PQLW.GOLD_SACK_ICON_NUM,
    [PQLW.REWARDS_SILVER_INDEX]		= PQLW.SILVER_SACK_ICON_NUM,
}

PQLootWindow.sackTextureSlice =
{			
    [PQLW.REWARDS_PURPLE_INDEX]		= PQLW.PURPLE_SACK_SLICE_NAME,
    [PQLW.REWARDS_BLUE_INDEX]  		= PQLW.BLUE_SACK_SLICE_NAME,
    [PQLW.REWARDS_GREEN_INDEX] 		= PQLW.GREEN_SACK_SLICE_NAME,
    [PQLW.REWARDS_WHITE_INDEX] 		= PQLW.WHITE_SACK_SLICE_NAME,
    [PQLW.REWARDS_GOLD_INDEX]  		= PQLW.GOLD_SACK_SLICE_NAME,
    [PQLW.REWARDS_SILVER_INDEX]		= PQLW.SILVER_SACK_SLICE_NAME,
}

PQLootWindow.iconTooltips =
{
    ["PQLootWindowScoreboardHeaderRewardIcon"]       = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TOOLTIP_PQLOOT_SCOREBOARD_REWARD ),
    ["PQLootWindowScoreboardHeaderGradeIcon"]        = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TOOLTIP_PQLOOT_SCOREBOARD_MEDAL ),
    ["PQLootWindowScoreboardHeaderContributionIcon"] = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TOOLTIP_PQLOOT_SCOREBOARD_BONUS ),
    ["PQLootWindowScoreboardHeaderPersistenceIcon"]  = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TOOLTIP_PQLOOT_SCOREBOARD_PERSISTENCE ),
    ["PQLootWindowScoreboardHeaderRollIcon"]         = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TOOLTIP_PQLOOT_SCOREBOARD_ROLL ),
    ["PQLootWindowScoreboardHeaderRollIcon_FINAL"]   = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TOOLTIP_PQLOOT_SCOREBOARD_FINAL_ROLL ),
}

local windowName = "PQLootWindow"


-- keep track of the rolling animations and end numbers displayed
PQLootWindow.tumblers =
{
    -- we use the prefix RANDOM_ to signify the looping animation where random numbers are spinning past
    RANDOM_BASE_NAME = "Roll",
    RANDOM_FIRST_FRAME = 1,
    RANDOM_LAST_FRAME = 8,
    
    -- "PQLootAnimNumeral0" to "PQLootAnimNumeral9" are the template for the numeric animations, 
    --   which are dynamically created and stored in the table PQLootWindow.tumblers.dynamicWindows
    TEMPLATE_BASE_NAME = "PQLootAnimNumeral",  
    dynamicWindows = {},
    
    -- we use the prefix NUMERAL_ to signify the dynamically created animations where a specific number appears
    NUMERAL_BASE_NAME = "RollComplete",
    NUMERAL_FIRST_FRAME = 1,
    NUMERAL_LAST_FRAME = 10,
    
    FINALRESULTS_BASE_NAME = "AdjustedRoll",
    
    -- each roll value is displayed as 4 digits (each one a RANDOM_ or NUMERIC_ window)
    DIGIT_BASE_NAME = "Digit",
    NUM_DIGITS = 4,
    
}

local tumblers = PQLootWindow.tumblers

local highlightedRowName = nil

---------------------------------------------
-- END of static data decleration
---------------------------------------------


---------------------------------------------
-- PQLootWindow.tumblers functions
---------------------------------------------


function tumblers.Clear()

    for window, value in pairs(tumblers.dynamicWindows) do
        WindowClearAnchors( window )
        WindowSetShowing( window, false )
        DestroyWindow( window )
    end
    
    tumblers.dynamicWindows = {}
    
    -- NOTE: the only time we're currently keeping track of this is when we're cleared and 
    --   when final results have finished
    tumblers.stageFinishedDisplaying = PQData.STATE_CLEAR
end


function tumblers.showTopContributors()
    if not PQLootWindow.scoreboardData
    then
        return
    end
    
    tumblers.Clear()
    
    local rowName, baseName

    for rowIndex, dataIndex in ipairs (PQLootWindowList.PopulatorIndices) 
    do
        rowName = windowName.."ListRow"..rowIndex
        if dataIndex <= PQLootWindow.numberOfRollsDisplayed
        then
            -- show this row if we're up to this player as we reveal rolls
            baseName = rowName..tumblers.NUMERAL_BASE_NAME
            tumblers.showNumeralRoll( baseName, rowName, PQLootWindow.scoreboardData[dataIndex].roll )
        else
            -- row hasn't been revealed yet, keep spinning
            tumblers.showRandomRoll( rowName )
        end
    end
    
    -- show appropriate tumblers for the players roll
    rowName = windowName.."PlayerData"
    if PQData.playerData.place <= PQLootWindow.numberOfRollsDisplayed then
        local baseName = rowName..tumblers.NUMERAL_BASE_NAME
        tumblers.showNumeralRoll( baseName, rowName, PQData.playerData.roll )
    else
        tumblers.showRandomRoll( rowName )
    end

    tumblers.stageFinishedDisplaying = PQData.STATE_SHOW_TOP_CONTRIBUTORS
end


function tumblers.ShowFinalResults()
    local rowName, baseName
    
    tumblers.Clear()
    
    -- instant show all scoreboard final rolls that the listbox is currently displaying
    for rowIndex, dataIndex in ipairs (PQLootWindowList.PopulatorIndices) 
    do
        rowName = windowName.."ListRow"..rowIndex
        baseName = rowName..tumblers.FINALRESULTS_BASE_NAME
        tumblers.showNumeralRoll( baseName, rowName, PQLootWindow.scoreboardData[dataIndex].roll )
    end
    
    -- instant show Player's final roll
    rowName = windowName.."PlayerData"
    baseName = rowName..tumblers.FINALRESULTS_BASE_NAME
    tumblers.showNumeralRoll( baseName, rowName, PQData.playerData.roll )
    
    
    tumblers.stageFinishedDisplaying = PQData.STATE_SHOW_FINAL_RESULTS
end


function tumblers.showRandomRoll( rowName )
    WindowSetShowing( rowName..tumblers.RANDOM_BASE_NAME, true )
    
    -- randomize roll tumblers
    for digit = 1, tumblers.NUM_DIGITS do
        local animWindow = rowName..tumblers.RANDOM_BASE_NAME..tumblers.DIGIT_BASE_NAME..digit
        local startframe = math.random(tumblers.RANDOM_FIRST_FRAME, tumblers.RANDOM_LAST_FRAME)
        
        WindowSetShowing( animWindow, true ) -- if hideRandomRoll happened, AnimatedImageStopAnimation also hides the window... undocumented
        AnimatedImageStartAnimation( animWindow, startframe, true, false, 0 )
    end
end

function tumblers.hideRandomRoll( rowName )
    if WindowGetShowing( rowName..tumblers.RANDOM_BASE_NAME ) == true then
        for digit = 1, tumblers.NUM_DIGITS do
            local animWindow = rowName..tumblers.RANDOM_BASE_NAME..tumblers.DIGIT_BASE_NAME..digit
            AnimatedImageStopAnimation( animWindow )
        end
        WindowSetShowing( rowName..tumblers.RANDOM_BASE_NAME, true )
    end
end

function tumblers.showNumeralRollAnim( baseName, rowName, value, startFrame )
    -- In case we failed.
    if (value == nil)
    then
        return
    end
    
    -- default to begining of animation if startFrame not specified
    startFrame = startFrame or tumblers.NUMERAL_FIRST_FRAME
    
    tumblers.hideRandomRoll( rowName )
    
    local anchorWindow = rowName..tumblers.RANDOM_BASE_NAME
    local anchorPoint = "right"
    
    -- set the final animated numbers from right to left
    for digit = tumblers.NUM_DIGITS, 1, -1 do
    
        -- create dynamic animation window for each digit
        local animWindow = baseName..tumblers.DIGIT_BASE_NAME..digit
        
        -- sanity check to stop us from leaking dynamic windows (and memory)
        if tumblers.dynamicWindows[animWindow] ~= nil then
            ERROR( L"Error in PQLootWindow.tumblers.showNumeralRollAnim() trying to create window = "..
                   StringToWString(animWindow)..L", but it already exists." )
            return
        end
        
        -- use modulus to divide the value into 4 digits
        local remainder = value % 10
        value = math.floor(value / 10)
        local templateName = tumblers.TEMPLATE_BASE_NAME..remainder
        
        CreateWindowFromTemplate( animWindow, templateName, rowName )
        tumblers.dynamicWindows[animWindow] = remainder
        
        AnimatedImageStartAnimation( animWindow, startFrame, false, false, 0 )
        
        WindowAddAnchor( animWindow, anchorPoint, anchorWindow, "right", 0, 0 )
        anchorWindow = animWindow
        anchorPoint = "left"
    end
    
end


function tumblers.showNumeralRoll( baseName, rowName, value )
    
    tumblers.showNumeralRollAnim( baseName, rowName, value, tumblers.NUMERAL_LAST_FRAME )
end

function tumblers.hideFinalRoll( rowName )

    for digit = 1, tumblers.NUM_DIGITS do
        local animWindow = rowName..tumblers.NUMERAL_BASE_NAME..tumblers.DIGIT_BASE_NAME..digit
                
        if tumblers.dynamicWindows[animWindow] ~= nil then
            WindowClearAnchors( animWindow )
            WindowSetShowing( animWindow, false )
            DestroyWindow( animWindow )
            tumblers.dynamicWindows[animWindow] = nil
        end
    end
    
end


---------------------------------------------
-- end PQLootWindow.tumblers functions
---------------------------------------------

---------------------------------------------
-- PQLootWindow functions
---------------------------------------------

function PQLootWindow.Initialize()
    
    -- Labels
    ButtonSetText(windowName.."CloseButton", GetString( StringTables.Default.LABEL_CLOSE ) )
    LabelSetText(windowName.."TitleBarText", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_TITLE ) )
    LabelSetText(windowName.."TransitionWindowText", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_TRANSITION ) )
    
    WindowSetAlpha( windowName.."TransitionWindowBackground", 0.80 )
    
    DefaultColor.LabelSetTextColor( windowName.."PlayerResultsText", PQLootWindow.INSTRUCTION_COLOR )
    
    DefaultColor.LabelSetTextColor( windowName.."TransitionWindowText", PQLootWindow.HIGHLIGHT_COLOR )
    
    PQLootWindow.Clear()
    PQLootWindow.SetListRowTints()
    PQData.AddWindow( PQLootWindow )

end


function PQLootWindow.OnUpdate( timePassed )

    if PQLootWindow.clockTimeLeft ~= nil and PQLootWindow.clockTimeLeft ~= 0 and PQLootWindow.clockTimeLeft ~= TimedStateMachine.TIMER_OFF then	
        
        PQLootWindow.clockTimeLeft = PQLootWindow.clockTimeLeft - timePassed
        
        if PQLootWindow.clockTimeLeft < 0 then
            PQLootWindow.clockTimeLeft = 0
        end
        
        PQLootWindow.UpdateClockText( PQLootWindow.clockTimeLeft )
    end


    local currentState = TimedStateMachineManager.GetCurrentState( PQData.stateMachineName )
    if ( currentState == PQData.STATE_SHOW_ROLLS ) then
    
        PQLootWindow.timeBeforeNextRoll = PQLootWindow.timeBeforeNextRoll - timePassed
        if PQLootWindow.timeBeforeNextRoll <= 0 then
            PQLootWindow.ShowRolls()
        end
    end

end

function PQLootWindow.Shutdown()
    PQLootWindow.tumblers.Clear()
end


function PQLootWindow.ToggleVisibility()
    WindowSetShowing( windowName, not WindowGetShowing(windowName) )
    
    PQLootWindow.clockTimeLeft = PQData.GetFakedTimerTime()
    PQLootWindow.UpdateClockText( PQLootWindow.clockTimeLeft )
end

function PQLootWindow.HighlightRow( rowName )
    PQLootWindow.RemoveLastHighlight()
    
    WindowAddAnchor( windowName.."HighlightBox", "topleft", rowName, "topleft", -2, -2 )
    
    DefaultColor.SetWindowTint(windowName.."HighlightBox", PQLootWindow.OUTLINE_BOX_COLOR )
    WindowSetShowing( windowName.."HighlightBox", true )
        
    DefaultColor.LabelSetTextColor( rowName.."Place", PQLootWindow.HIGHLIGHT_COLOR )
    DefaultColor.LabelSetTextColor( rowName.."Name", PQLootWindow.HIGHLIGHT_COLOR )
    
    highlightedRowName = rowName
end

function PQLootWindow.RemoveLastHighlight()
    if highlightedRowName ~= nil and highlightedRowName ~= L""
    then
        WindowClearAnchors( windowName.."HighlightBox" )    
        WindowSetShowing( windowName.."HighlightBox", false )
        
        -- remove text highlight from the previous row that was highlighted
        DefaultColor.LabelSetTextColor( highlightedRowName.."Place", PQLootWindow.DEFAULT_TEXT_COLOR )
        DefaultColor.LabelSetTextColor( highlightedRowName.."Name", PQLootWindow.DEFAULT_TEXT_COLOR )
    end
end


function PQLootWindow.ParseScoreboardData(contributorsData)

    -- This can occur on failed PQs.
    if (contributorsData == nil)
    then
        return
    end

    PQLootWindow.totalNumberOfContributors  = contributorsData.numContributors
    PQLootWindow.numberOfContributorsToShow = #PQLootWindow.scoreboardData
    
    for i, playerData in ipairs(PQLootWindow.scoreboardData)
    do

        playerData.place = i
        
        if playerData.bonus > 0
        then
            playerData.contribution = L"+"..playerData.bonus
        elseif playerData.bonus == 0
        then
            playerData.contribution = L"  -"
        else
            playerData.contribution = L""
        end
        
        -- TODO: in the future we're actually going to hide all rolls then reveal them one at a time using animations
        -- TODO: this will also probably be represented by graphics or something as well
        
    end
            
    -- TODO: in the future we're actually going to hide all rolls then reveal them one at a time using animations
    -- TODO: this will also probably be represented by graphics or something as well

    PQLootWindow.numRewards = {}
    PQLootWindow.numRewards[PQLW.REWARDS_GOLD_INDEX] = contributorsData.numGoldSacks
    PQLootWindow.numRewards[PQLW.REWARDS_PURPLE_INDEX] = contributorsData.numPurpleSacks
    PQLootWindow.numRewards[PQLW.REWARDS_SILVER_INDEX] = 0 -- contributorsData.numSilverSacks  -- no longer set by client
    PQLootWindow.numRewards[PQLW.REWARDS_BLUE_INDEX] = contributorsData.numBlueSacks
    PQLootWindow.numRewards[PQLW.REWARDS_GREEN_INDEX] = contributorsData.numGreenSacks
    PQLootWindow.numRewards[PQLW.REWARDS_WHITE_INDEX] = contributorsData.numWhiteSacks

end


function PQLootWindow.UpdateRowDisplay( rowName, playerData, dataIndex )

    -- set RewardIcon column
    local iconFound = false
    
    if( (playerData.sackType == nil) or (playerData.sackType == PQLootWindow.REWARDS_NO_REWARD_INDEX) )
    then
        LabelSetText( rowName.."RewardIconMissing", PQLootWindow.NO_REWARD_TEXT )
    elseif( playerData.sackType == PQLootWindow.REWARDS_UNKNOWN_INDEX )
    then
        LabelSetText( rowName.."RewardIconMissing", PQLootWindow.UNKNOWN_REWARD_TEXT )
    else
        iconFound = true
        local textureSlice = PQLootWindow.sackTextureSlice[playerData.sackType]
        if textureSlice ~= nil
        then
            DynamicImageSetTextureSlice( rowName.."RewardIcon", textureSlice )
        end
    end
    WindowSetShowing( rowName.."RewardIcon", iconFound )
    WindowSetShowing( rowName.."RewardIconMissing", (not iconFound) )
    
    
    -- set GradeIcon column
    if playerData.grade == nil or playerData.grade == PQLootWindow.NO_MEDAL_GRADE
    then
        LabelSetText( rowName.."GradeIconMissing", PQLootWindow.NO_MEDAL_TEXT )
    else
        local textureSlice = PQLootWindow.medalIcon[playerData.grade]
        if textureSlice ~= nil
        then
            DynamicImageSetTextureSlice( rowName.."GradeIcon", textureSlice )
        end
    end
    WindowSetShowing( rowName.."GradeIcon", (playerData.grade ~= PQLootWindow.NO_MEDAL_GRADE) )
    WindowSetShowing( rowName.."GradeIconMissing", (playerData.grade == PQLootWindow.NO_MEDAL_GRADE) )

    -- Set the persistence bonus
    if (playerData.persistence ~= nil)
    then
        WindowSetShowing( rowName.."Persistence", (playerData.persistence > 0) )
    else
        WindowSetShowing( rowName.."Persistence", false )
    end
    
end

function PQLootWindow.UpdateScoreboardDisplay()

    local displayOrder = {}

    -- scoreboard already sorted at this point
    for dataIndex, playerData in ipairs( PQLootWindow.scoreboardData )
    do
        table.insert(displayOrder, dataIndex)
    end
    
    ListBoxSetDisplayOrder(windowName.."List", displayOrder )
    
end

function PQLootWindow.ClearPlayerDisplay()

     -- clear any icons
    local playerDataWindow = windowName.."PlayerData"
    
    PQLootWindow.UpdateRowDisplay( playerDataWindow, {} )
    
    WindowSetShowing(playerDataWindow, false)
 
    PQLootWindow.playersRollShown = false
end

function PQLootWindow.UpdatePlayerDisplay()
   
    if( PQData.metMinContribution == false )
    then
        PQLootWindow.ClearPlayerDisplay()
        return
    end
   
    local rowName = windowName.."PlayerData"
    local playerData = PQData.playerData
     
    PQLootWindow.UpdateRowDisplay( rowName, playerData )

    local playerDataPlaceWindow = windowName.."PlayerDataPlace"
    local playerDataNameWindow = windowName.."PlayerDataName"
    if ( PQData.optedOut or PQData.forcedOut )
    then
        WindowSetShowing( playerDataPlaceWindow, false )
    else
        WindowSetShowing( playerDataPlaceWindow, true )
        LabelSetText( playerDataPlaceWindow, towstring(playerData.place) )
    end
    
    DefaultColor.LabelSetTextColor( playerDataPlaceWindow, PQLootWindow.HIGHLIGHT_COLOR )
    DefaultColor.LabelSetTextColor( playerDataNameWindow, PQLootWindow.HIGHLIGHT_COLOR )
    
    LabelSetText( playerDataNameWindow, playerData.name )
    LabelSetText( windowName.."PlayerDataContribution", playerData.contribution )
        
    
    WindowSetShowing( rowName.."Persistence", (playerData.persistence > 0) )

end

function PQLootWindow.CountTotalNumberOfRewards()

	local totalSacks = 0
    for rewardQuality = PQLootWindow.NUM_OF_REWARDS_INDICES, 1, -1 do
        totalSacks = totalSacks + PQLootWindow.numRewards[rewardQuality]
    end
    
	return totalSacks
end

function PQLootWindow.HideHeaderSackIcons()

    LabelSetText( windowName.."MultiSackText", L"" )
    WindowSetShowing( windowName.."MultiSackText", false )
end



function PQLootWindow.DisplayHeaderSackIcons()

    local sackString = L""
    local sackCount = L""
    local sackIconNum, numSacks
    local shouldDisplaySackCount = (PQLootWindow.numRewards.totalNum > PQLootWindow.MAX_NUM_OF_SACK_ICONS)
    
    for rewardQuality = PQLootWindow.NUM_OF_REWARDS_INDICES, 1, -1 do

		sackIconNum = PQLootWindow.sackIcon[rewardQuality]
		numSacks = PQLootWindow.numRewards[rewardQuality]
		if numSacks > 0 then
		
			if shouldDisplaySackCount == true then	
				-- display the sack rarity once, with a count of sacks at that rarity
				sackCount = GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SACK_COUNT, { towstring(numSacks) } ) 
				sackString = sackString..L"<icon"..sackIconNum..L"> "..sackCount..L"  "
			else 
				-- display an icon for each sack within the current rarity
				for i = 1, numSacks do 
					sackString = sackString..L"<icon"..sackIconNum..L">  "
				end
			end
			
		end
    end
    
    WindowSetShowing( windowName.."MultiSackText", true )
    LabelSetText( windowName.."MultiSackText", sackString )
end


local function GetFakedScoreboardData()
    local retVal = {}
    local FAKE_PLAYER_COUNT = 30
    for iCurEntry = 1, FAKE_PLAYER_COUNT
    do
        retVal[iCurEntry] = {}
        retVal[iCurEntry].name = L"Player"..iCurEntry
        retVal[iCurEntry].grade = PQLW.NO_MEDAL_GRADE - math.mod(iCurEntry, 4)
        retVal[iCurEntry].sackType = PQLW.REWARDS_BLUE_INDEX - math.mod(iCurEntry, 2)
        retVal[iCurEntry].roll = iCurEntry * 10
        retVal[iCurEntry].persistence = 100
        retVal[iCurEntry].bonus = (PQLW.NO_MEDAL_GRADE - retVal[iCurEntry].grade) * 100
    end
    -- insert the player into the fake data
    if PQData and PQData.playerData
    then
        local iCurEntry = FAKE_PLAYER_COUNT + 1
        retVal[iCurEntry] = PQData.playerData
    end
    return retVal
end

function PQLootWindow.ShowTopContributors(contributorsData)

    PQLootWindow.scoreboardData = contributorsData.scoreboardData
    table.sort(PQLootWindow.scoreboardData, PQLootWindow.ContributorSort)

    PQLootWindow.ParseScoreboardData( contributorsData )
    
    PQLootWindow.numRewards.totalNum = PQLootWindow.CountTotalNumberOfRewards()
	
    LabelSetText(windowName.."StateInfo", L""..PQLootWindow.numRewards.totalNum..L" "..GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_REWARDS_LABEL ) )
    
	PQLootWindow.DisplayHeaderSackIcons()
	
	
    -- sanity test since the C++ crashes if bad params are passed in
    -- also, if everyone opted out, there could be no contributors in the contributors list
    if( PQLootWindow.numberOfContributorsToShow ~= nil and
        PQLootWindow.totalNumberOfContributors ~= nil and
        PQLootWindow.totalNumberOfContributors > 0 )
    then
        local contributorsText = GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_TOP_CONTRIBUTORS, 
                                                  { PQLootWindow.numberOfContributorsToShow , PQLootWindow.totalNumberOfContributors } ) 
        LabelSetText( windowName.."ScoreboardHeaderContributorsText", contributorsText )
    end

    local timeRemaining = TimedStateMachineManager.GetTimeBeforeNextState( PQData.stateMachineName )
    PQLootWindow.UpdateClockText( PQData.GetFakedTimerTime() )
    
    local resultsText
    if ( not PQData.metMinContribution )
    then
        if ( PQData.forcedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION_FORCED_OUT )
        elseif ( PQData.optedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION_OPTED_OUT )
        else
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION )
        end
    else
        resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_RESULTS_ROLLING )
    end
    LabelSetText(windowName.."PlayerResultsText", resultsText )
    
    PQLootWindow.numberOfRollsDisplayed = 0
    PQLootWindow.UpdateScoreboardDisplay()
    PQLootWindow.UpdatePlayerDisplay()

    tumblers.showTopContributors()
end


function PQLootWindow.ShowPlayersRoll()

    -- nothing to display if didn't meet minimum contribution
    if ( PQLootWindow.playersRollShown or not PQData.metMinContribution )
    then
        return
    end

    local resultsText
    if ( PQData.forcedOut )
    then
        resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_FORCED_OUT )..L"."
    elseif ( PQData.optedOut )
    then
        resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_OPTED_OUT )..L"."
    else    
        resultsText = GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_CONTRIBUTION1, {towstring( PQData.playerData.place )} ) 

        if PQData.playerData.grade ~= PQLootWindow.NO_MEDAL_GRADE
        then
            local medalName = PQLootWindow.medalName[PQData.playerData.grade]
            local bonus = PQData.playerData.contribution
            resultsText = resultsText..L" "..GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_CONTRIBUTION2, { medalName, bonus } ) 
        end    
    end

    LabelSetText(windowName.."PlayerResultsText", resultsText )	

    local playerDataWindow = windowName.."PlayerData"
    if ( not PQData.forcedOut and not PQData.optedOut )
    then
        local baseName = playerDataWindow..tumblers.NUMERAL_BASE_NAME        
        tumblers.showNumeralRollAnim( baseName, playerDataWindow, PQData.playerData.roll )
    end
    
    WindowSetShowing(playerDataWindow, true)
    
    PQLootWindow.playersRollShown = true
end


-- this should animate the rolls
function PQLootWindow.ShowRolls()

    if( PQLootWindow.numberOfRollsDisplayed >= PQLootWindow.numberOfContributorsToShow )
    then
        PQLootWindow.ShowPlayersRoll()
        PQLootWindow.timeBeforeNextRoll = PQLootWindow.TIMER_OFF
        return
    end
    
    local timeRemaining = TimedStateMachineManager.GetTimeBeforeNextState( PQData.stateMachineName )
    PQLootWindow.UpdateClockText( PQData.GetFakedTimerTime() )

    local totalTime = PQData.state[PQData.STATE_SHOW_ROLLS].time - PQLootWindow.TIME_WHERE_ALL_ROLLS_ARE_VISIBLE
    local percentDone = 1 - (timeRemaining / totalTime)
    local evenDistributionNumDisplayed = math.ceil( PQLootWindow.numberOfContributorsToShow * percentDone )
    
    if( evenDistributionNumDisplayed > PQLootWindow.numberOfRollsDisplayed )
    then
        PQLootWindow.numberOfRollsDisplayed = evenDistributionNumDisplayed
    else
        PQLootWindow.numberOfRollsDisplayed = PQLootWindow.numberOfRollsDisplayed + 1
    end
    
    -- show the latest roll as we reveal them
    for rowIndex, dataIndex in ipairs (PQLootWindowList.PopulatorIndices) 
    do
        if dataIndex == PQLootWindow.numberOfRollsDisplayed
        then
            local rowName = windowName.."ListRow"..rowIndex
            local baseName = rowName..tumblers.NUMERAL_BASE_NAME
            tumblers.showNumeralRollAnim( baseName, rowName, PQLootWindow.scoreboardData[dataIndex].roll )
            break
        end
    end
    
    -- if current characters is player, then display his row as well
    if( PQLootWindow.numberOfRollsDisplayed >= PQData.playerData.place )
    then
        PQLootWindow.ShowPlayersRoll()
    end
    
    -- set timer for next roll
    PQLootWindow.timeBeforeNextRoll = totalTime / PQLootWindow.numberOfContributorsToShow
    if PQLootWindow.timeBeforeNextRoll > PQLootWindow.MAX_TIME_BETWEEN_ROLLS then 
        PQLootWindow.timeBeforeNextRoll = PQLootWindow.MAX_TIME_BETWEEN_ROLLS
    end
    
end


function PQLootWindow.ShowTransitionScreen()
    
    local timeRemaining = TimedStateMachineManager.GetTimeBeforeNextState( PQData.stateMachineName )
    PQLootWindow.UpdateClockText( PQData.GetFakedTimerTime() )
    
    -- show splash screen on top of normal scoreboard
    WindowSetShowing( windowName.."TransitionWindow", true )
    
end

function PQLootWindow.ShowFinalResults(winnersData)

    if( not winnersData )
    then
        return
    end

    PQLootWindow.scoreboardData = winnersData.scoreboardData 
    table.sort(PQLootWindow.scoreboardData, PQLootWindow.RollSort)
    PQLootWindow.ParseScoreboardData( winnersData )
        
    WindowSetShowing( windowName.."TransitionWindow", false )
    PQLootWindow.HideHeaderSackIcons()
    
    if PQData.isCityPQ
    then
        LabelSetText( windowName.."StateInfo", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_STATE_FINISHED ) )
        LabelSetText( windowName.."TimeText", L"" )
        
        WindowSetShowing( windowName.."ClockImage", false )
        PQLootWindow.clockTimeLeft = 0
    else
        LabelSetText(windowName.."StateInfo", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_RESETS_IN ) )
        PQLootWindow.UpdateClockText( PQData.GetFakedTimerTime() )
    end
    
    LabelSetText(windowName.."ScoreboardHeaderContributorsText", GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_WINNERS_HEADER ) )

    local resultsText
    if ( not PQData.metMinContribution )
    then
        if ( PQData.forcedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION_FORCED_OUT )
        elseif ( PQData.optedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION_OPTED_OUT )
        else
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_NOT_ENOUGH_CONTRIBUTION )  
        end
    else
        if ( PQData.forcedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_FORCED_OUT )
            
            -- TODO: Add in information about the Forced Out prize into the appropriate message so we can display it here
            --if( PQData.playerData.looserPrize ~= L"")
            --then
                --resultsText = resultsText..GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_PLACED6, {PQData.playerData.looserPrize} )
            --else
                resultsText = resultsText..L"."
            --end
        elseif ( PQData.optedOut )
        then
            resultsText = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_OPTED_OUT )
            
            if( PQData.playerData.looserPrize ~= L"")
            then
                resultsText = resultsText..GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_PLACED6, {PQData.playerData.looserPrize} )
            else
                resultsText = resultsText..L"."
            end
            
        else
            resultsText = GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_PLACED1, { towstring(PQData.playerData.place) } )
            
            if PQData.playerData.sackType ~= PQLootWindow.REWARDS_UNKNOWN_INDEX and
               PQData.playerData.sackType ~= PQLootWindow.REWARDS_NO_REWARD_INDEX
            then
                local sackName = PQLootWindow.sackName[PQData.playerData.sackType]
                resultsText = resultsText..L" "..GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_PLACED2, {sackName} )
            else
                if( PQData.playerData.looserPrize == L"")
                then
                    resultsText = resultsText..L" "..GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_PLACED3 )
                else
                    resultsText = resultsText..GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.LABEL_PQLOOT_SCOREBOARD_PLACED6, {PQData.playerData.looserPrize} )
                end
            end
            
        end        
    end
    LabelSetText(windowName.."PlayerResultsText", resultsText ) 

    PQLootWindow.numberOfRollsDisplayed = PQLootWindow.numberOfContributorsToShow
    PQLootWindow.UpdateScoreboardDisplay()
    PQLootWindow.UpdatePlayerDisplay()
    
    tumblers.ShowFinalResults()
end


-- 
function PQLootWindow.UpdateClockText( timeRemaining )

    PQLootWindow.clockTimeLeft = timeRemaining
    local timeText = TimeUtils.FormatClock( PQLootWindow.clockTimeLeft )
    LabelSetText( windowName.."TimeText", timeText )
end

function PQLootWindow.Populate()
    if (PQLootWindowList.PopulatorIndices == nil) 
    then
        return
    end

    PQLootWindow.RemoveLastHighlight()
    for rowIndex, dataIndex in ipairs (PQLootWindowList.PopulatorIndices) 
    do
        local rowName = windowName.."ListRow"..rowIndex
        PQLootWindow.UpdateRowDisplay( rowName, PQLootWindow.scoreboardData[dataIndex], dataIndex )
        
        if ( not PQData.forcedOut and not PQData.optedOut and PQData.playerData.place == dataIndex )
        then
            -- highlight the player's row
            PQLootWindow.HighlightRow( rowName )
        end
    end
    
    -- upon scrolling, need to update the tumblers based on what state we are in for showing rolls and what's now visible
    if tumblers.stageFinishedDisplaying == PQData.STATE_SHOW_TOP_CONTRIBUTORS
    then
        tumblers.showTopContributors()
    elseif tumblers.stageFinishedDisplaying == PQData.STATE_SHOW_FINAL_RESULTS
    then
        tumblers.ShowFinalResults()
    end
    
end

function PQLootWindow.SetListRowTints()
    local targetRowWindow = L""
    for row = 1, PQLootWindowList.numVisibleRows  do
        local row_mod = math.mod(row, 2)
        
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        targetRowWindow = "PQLootWindowListRow"..row
        DefaultColor.SetWindowTint(targetRowWindow.."Background", color )
    end
    
    -- also color the player data row
    DefaultColor.SetWindowTint("PQLootWindowPlayerDataBackground", DataUtils.GetAlternatingRowColor( 1 ) )
end


-- The server is currently not pushing existing plot data during login, so we need to pull it just once
--
function PQLootWindow.Clear()

    PQLootWindow.clockTimeLeft = 0
    
    PQLootWindow.totalNumberOfContributors = 0
    PQLootWindow.numberOfContributorsToShow = 0
    
    PQLootWindow.scoreboardData = {}
    
    PQLootWindow.numberOfRollsDisplayed = 0
    PQLootWindow.UpdateScoreboardDisplay()
    PQLootWindow.ClearPlayerDisplay()
    
    -- Labels
    --
    --LabelSetText(windowName.."PQName", L"" ) 
    LabelSetText(windowName.."StateInfo", L"" )
    LabelSetText(windowName.."ScoreboardHeaderContributorsText", L"" )
    LabelSetText(windowName.."PlayerResultsText", L"" )

    -- Clear the timer
    PQLootWindow.UpdateClockText( 0 )

    PQLootWindow.HideHeaderSackIcons()
        
    WindowSetShowing( windowName.."TransitionWindow", false )
    WindowSetShowing( windowName.."HighlightBox", false )
    
    WindowSetShowing( windowName.."ClockImage", true ) -- may have been turned off if was in a City PQ (i.e. no reset time)

    PQLootWindow.tumblers.Clear()
end


function PQLootWindow.OnMouseOverHeaderIcon()

    local text
    
    local currentState = TimedStateMachineManager.GetCurrentState( PQData.stateMachineName )
    if ( SystemData.ActiveWindow.name == "PQLootWindowScoreboardHeaderRollIcon" and
         currentState == PQData.STATE_SHOW_FINAL_RESULTS )
    then
        text = PQLootWindow.iconTooltips["PQLootWindowScoreboardHeaderRollIcon_FINAL"]
    else
        text = PQLootWindow.iconTooltips[SystemData.ActiveWindow.name]
    end
         
    if text == nil then
        return
    end
    
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_VARIABLE )
end

function PQLootWindow.OnMouseOverPersistenceIcon()

    Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name)

    local text = GetStringFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TEXT_PQLOOT_PERSISTENCE_DESCRIPTION)
    Tooltips.SetTooltipText( 1, 1, text )
    
    if (PQLootWindow.scoreboardData ~= nil)
    then
        local dataIndex = ListBoxGetDataIndex(windowName.."List", WindowGetId(WindowGetParent(SystemData.ActiveWindow.name)))
        local playerName       = PQLootWindow.scoreboardData[dataIndex].name
        local persistenceBonus = PQLootWindow.scoreboardData[dataIndex].persistence
        
        local detailText = GetStringFormatFromTable( "ObjectiveTracker", StringTables.ObjectiveTracker.TEXT_PQLOOT_PERSISTENCE_DETAILS, { playerName, persistenceBonus })
        Tooltips.SetTooltipText( 2, 1, detailText )
    end

    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_VARIABLE )

end

function PQLootWindow.Show()
    if WindowGetShowing( windowName ) == false
    then
        WindowSetShowing( windowName, true)
    end
end

function PQLootWindow.Hide()
    if WindowGetShowing( windowName ) == true
    then
        WindowSetShowing( windowName, false)
    end
end

function PQLootWindow.OnHidden()
    WindowUtils.OnHidden()
end

function PQLootWindow.Done()
    PQLootWindow.Hide()
end

-- Sort high values to the top.
function PQLootWindow.RollSort(a, b)
    return (a.roll > b.roll)
end

function PQLootWindow.ContributorSort(a, b)
    return (a.bonus > b.bonus)
end
