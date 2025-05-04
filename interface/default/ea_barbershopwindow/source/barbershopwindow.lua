----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

BarbershopWindow = {}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local containerWindowName = "EA_Window_Barbershop"
local mainWindowName = containerWindowName.."Main"

local MAX_FEATURES = 8

local featuresData = {}
local featureNames = {}
local featureOptions = {}
local tokenItemId = 0
local numTokensRequired = 0

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------

local function InitializeFeatureSelections()
    LoadStringTable("BarbershopFeatures", "data/strings/<LANG>/pregame", "creationfeatures.txt", "cache/<LANG>", "StringTables.BarbershopFeatures" )
    BuildTableFromCSV("data\\gamedata\\pregame_features.csv", "BarbershopFeatureList")
    
    for _, featureData in ipairs( BarbershopFeatureList )  
    do
        local career = GameData.CareerLine[featureData.FEATURE_CAREER]
        local gender = GameData.Gender[featureData.FEATURE_GENDER]
        
        if ( ( career == GameData.Player.career.line ) and ( gender == GameData.Player.gender ) )
        then
            local featureName = GetPregameString( StringTables.Pregame[featureData.FEATURE_LABEL] )
            table.insert( featureNames, featureName )
            local featureNum = #featureNames
        
            local options = {}
            if ( featureData.featureStringIdBase ~= nil )
            then                
                local featureItemIndex = 1
                local stringId = StringTables.BarbershopFeatures[ featureData.featureStringIdBase.."_"..featureItemIndex ]
                while ( stringId ~= nil )
                do
                    local featureValue = GetStringFromTable( "BarbershopFeatures", stringId )
                    table.insert( options, featureValue )
            
                    featureItemIndex = featureItemIndex + 1
                    stringId = StringTables.BarbershopFeatures[ featureData.featureStringIdBase.."_"..featureItemIndex ]
                end
            end
            table.insert( featureOptions, options )
        end
    end
    
    UnloadStringTable( "BarbershopFeatures" )
    BarbershopFeatureList = nil
end

local function FindFeatureCurrentValue( featureData )
    for index, value in ipairs(featureData)
    do
        if ( value == featureData.curValue )
        then
            return index
        end
    end
end

local function GetTokenCount( tokenItemId )
    local numTokens = 0
    for backpackType = 1, EA_Window_Backpack.NUM_BACKPACK_TYPES
    do
        local items = EA_Window_Backpack.GetItemsFromBackpack( backpackType )
        for slot, itemData in ipairs(items)
        do
            if ( DataUtils.IsValidItem( itemData ) and ( itemData.uniqueID == tokenItemId ) )
            then
                numTokens = numTokens + itemData.stackCount
            end
        end
    end
    return numTokens
end

----------------------------------------------------------------
-- Core Event Handlers
----------------------------------------------------------------

function BarbershopWindow.RegisterShowEvent()
    -- This must be done outside the Initialize function due to lazy-loading
    RegisterEventHandler( SystemData.Events.INTERACT_BARBERSHOP_OPEN, "BarbershopWindow.Show" )
end

function BarbershopWindow.UnregisterShowEvent()
    -- Because the event is not registered to a specific window, we must unregister it when our module is unloaded
    UnregisterEventHandler( SystemData.Events.INTERACT_BARBERSHOP_OPEN, "BarbershopWindow.Show" )
end

function BarbershopWindow.Initialize()
    WindowRegisterEventHandler( mainWindowName, SystemData.Events.INTERACT_DONE, "BarbershopWindow.Hide" )
    WindowRegisterEventHandler( mainWindowName, SystemData.Events.INTERACT_BARBERSHOP_FEATURE_UPDATE, "BarbershopWindow.UpdateCurrentFeatures" )
    WindowRegisterEventHandler( mainWindowName, SystemData.Events.INTERACT_BARBERSHOP_RESULT, "BarbershopWindow.ServerResult" )

    ButtonSetText( mainWindowName.."ResetButton", GetString( StringTables.Default.LABEL_RESET ) )
    ButtonSetText( mainWindowName.."CheckOutButton", GetString( StringTables.Default.LABEL_CHECKOUT ) )
    
    InitializeFeatureSelections()
    
    -- For some characters, we need to tweak the NifDisplay to make sure they show up in the mirror appropriately
    if ( ( ( GameData.Player.race.id == GameData.Races.HIGH_ELF ) or ( GameData.Player.race.id == GameData.Races.DARK_ELF ) ) and ( GameData.Player.gender == GameData.Gender.MALE ) )
    then
        -- Male high elves and dark elves are very tall
        NifDisplaySetTranslation( mainWindowName.."CharacterNif", 0, -80, 66 )
    elseif ( GameData.Player.race.id == GameData.Races.CHAOS )
    then
        if ( GameData.Player.career.line == GameData.CareerLine.ZEALOT )
        then
            -- Zealots are shorter than other Chaos characters
            NifDisplaySetTranslation( mainWindowName.."CharacterNif", 0, -100, 54 )
        else
            -- Chaos is also tall but needs different parameters
            NifDisplaySetTranslation( mainWindowName.."CharacterNif", 0, -100, 70 )
        end
    elseif ( GameData.Player.race.id == GameData.Races.ORC )
    then
        -- Orcs are tall and big, need camera further back
        NifDisplaySetTranslation( mainWindowName.."CharacterNif", 0, -120, 60 )
    elseif ( GameData.Player.race.id == GameData.Races.DWARF )
    then
        -- Dwarves are very short
        NifDisplaySetTranslation( mainWindowName.."CharacterNif", 0, -110, 37 )
    elseif ( GameData.Player.race.id == GameData.Races.GOBLIN )
    then
        -- Goblins are even shorter than dwarves
        NifDisplaySetTranslation( mainWindowName.."CharacterNif", 0, -110, 32 )
    end
end

function BarbershopWindow.Show( itemId, numTokens )
    tokenItemId = itemId
    numTokensRequired = numTokens

    if ( DoesWindowExist( containerWindowName ) )
    then
        WindowSetShowing( containerWindowName, true )
    else
        CreateWindow( containerWindowName, true )
    end
    BarbershopWindow.Reset()
end

function BarbershopWindow.Hide()
    WindowSetShowing( containerWindowName, false )
end

function BarbershopWindow.OnShown()
    WindowUtils.OnShown( BarbershopWindow.Hide, WindowUtils.Cascade.MODE_NONE )
end

function BarbershopWindow.ServerResult( code )
    if ( code == GameData.BarberShopMessage.SUCCESS )
    then
        BarbershopWindow.Hide()
    elseif ( code == GameData.BarberShopMessage.NOT_ENOUGH_TOKENS )
    then
        local errorText = GetStringFormat( StringTables.Default.TEXT_BARBERSHOP_NOT_ENOUGH_TOKENS, { towstring(numTokensRequired) } )
        local okayText = GetString( StringTables.Default.LABEL_OKAY )
        DialogManager.MakeOneButtonDialog( errorText, okayText )
    elseif ( code == GameData.BarberShopMessage.BAD_VARIATION )
    then
        local errorText = GetString( StringTables.Default.TEXT_BARBERSHOP_BAD_VARIATION )
        local okayText = GetString( StringTables.Default.LABEL_OKAY )
        DialogManager.MakeOneButtonDialog( errorText, okayText )    
    elseif ( code == GameData.BarberShopMessage.ANOTHER_FORM )
    then
        local errorText = GetString( StringTables.Default.TEXT_BARBERSHOP_ANOTHER_FORM )
        local okayText = GetString( StringTables.Default.LABEL_OKAY )
        DialogManager.MakeOneButtonDialog( errorText, okayText )
    end
end

----------------------------------------------------------------
-- Main Button Handlers
----------------------------------------------------------------

function BarbershopWindow.Reset()
    BarbershopResetFeatures()
end

function BarbershopWindow.CheckOut()
    if ( not BarbershopHaveFeaturesChanged() )
    then
        local errorText = GetString( StringTables.Default.TEXT_BARBERSHOP_NO_CHANGES )
        local okayText = GetString( StringTables.Default.LABEL_OKAY )
        DialogManager.MakeOneButtonDialog( errorText, okayText )
        return
    end
    
    if ( numTokensRequired > 0 )
    then
        if ( GetTokenCount( tokenItemId ) < numTokensRequired )
        then
            local errorText = GetStringFormat( StringTables.Default.TEXT_BARBERSHOP_NOT_ENOUGH_TOKENS, { towstring(numTokensRequired) } )
            local okayText = GetString( StringTables.Default.LABEL_OKAY )
            DialogManager.MakeOneButtonDialog( errorText, okayText )
        else
            local confirmText = GetStringFormat( StringTables.Default.TEXT_BARBERSHOP_TOKEN_CONFIRMATION, { towstring(numTokensRequired) } )
            local yesText = GetString( StringTables.Default.LABEL_YES )
            local noText = GetString( StringTables.Default.LABEL_NO )
            DialogManager.MakeTwoButtonDialog( confirmText, yesText, BarbershopSubmitFeatures, noText, nil )
        end
    else
        BarbershopSubmitFeatures()
    end
end

----------------------------------------------------------------
-- Features
----------------------------------------------------------------

function BarbershopWindow.UpdateCurrentFeatures( newFeaturesData )
    featuresData = newFeaturesData
    
    local iNumFeatures = #featuresData
    for iIndex, features in ipairs(featuresData)
    do
        if ( iIndex <= MAX_FEATURES )
        then
            local comboName = mainWindowName.."Feature"..iIndex.."ComboBox"
            ComboBoxClearMenuItems( comboName )                
                
            local curValue = features.curValue
            for menuItemIndex, value in ipairs(features)
            do
                local text = L""
                if ( ( featureOptions[iIndex] ~= nil ) and ( featureOptions[iIndex][value+1] ~= nil ) )
                then
                    text = featureOptions[iIndex][value+1]
                else
                    text = wstring.format( L"#%d", value+1 )
                end
                    
                ComboBoxAddMenuItem( comboName, text )
                    
                if ( value == curValue )
                then
                    ComboBoxSetSelectedMenuItem( comboName, menuItemIndex )
                end
            end
            WindowSetShowing( mainWindowName.."Feature"..iIndex, true )
        end
    end
        
    if ( iNumFeatures < MAX_FEATURES )
    then
        for iIndex = iNumFeatures+1, MAX_FEATURES
        do
            WindowSetShowing( mainWindowName.."Feature"..iIndex, false )
        end
    end
end

function BarbershopWindow.NextFeature()
    local featureType  = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local featureData  = featuresData[featureType]
    
    local curValue     = FindFeatureCurrentValue( featureData )
    local featureValue = featureData[curValue + 1]
    if ( featureValue == nil )
    then
        featureValue = featureData[1]
    end
    
    BarbershopSetFeature( featureType, featureValue )
end

function BarbershopWindow.PrevFeature()
    local featureType  = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local featureData  = featuresData[featureType]
    
    local curValue     = FindFeatureCurrentValue( featureData )
    local featureValue = featureData[curValue - 1]
    if ( featureValue == nil )
    then
        featureValue = featureData[#featureData]
    end
    
    BarbershopSetFeature( featureType, featureValue )
end

function BarbershopWindow.SelectFeature( curSel )
    if ( curSel < 1 )
    then
        -- Bail if the selection was cleared
        return
    end

    local featureType  = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local featureData  = featuresData[featureType]
    
    local featureValue = featureData[curSel]
    BarbershopSetFeature( featureType, featureValue )
end

function BarbershopWindow.MouseOverFeature()
    local featureNum = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local featureName = featureNames[featureNum]
    if ( featureName ~= nil )
    then
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, featureName )
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
    end
end