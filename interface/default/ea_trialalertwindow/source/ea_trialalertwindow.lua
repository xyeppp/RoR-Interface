----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_TrialAlertWindow = {}

----------------------------------------------------------------
-- Saved Variables
----------------------------------------------------------------
EA_TrialAlertWindow.IsFirstRun = true
EA_TrialAlertWindow.TwoButtonDialogShowing = false

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- EA_TrialAlertWindow Functions
----------------------------------------------------------------

function EA_TrialAlertWindow.Initialize()       

    RegisterEventHandler(SystemData.Events.TRIAL_ALERT_POPUP,          "EA_TrialAlertWindow.Show")
    RegisterEventHandler(SystemData.Events.LOADING_END,                "EA_TrialAlertWindow.EnteredGame")

    LabelSetText( "EA_TrialAlertWindowTitleBarText", GetStringFromTable("TrialAlert", StringTables.TrialAlert.TEXT_TRIAL_ALERT_TITLEBAR ) )
    LabelSetText( "EA_TrialAlertWindowLabelFeature", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_FEATURE ) )
    LabelSetText( "EA_TrialAlertWindowLabelTrial", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_TRIAL ) )
    LabelSetText( "EA_TrialAlertWindowLabelSubscriber", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_SUBSCRIBER ) )
    LabelSetText( "EA_TrialAlertWindowLabelAndMore", GetStringFromTable("TrialAlert", StringTables.TrialAlert.TEXT_AND_MORE ) )
    LabelSetText( "EA_TrialAlertWindowLabelBottomTab", GetStringFromTable("TrialAlert", StringTables.TrialAlert.TEXT_TRIAL_ALERT_BOTTOM_TAB ) )
	ButtonSetText("EA_TrialAlertWindowUpgradeButton", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_UPGRADE))
    
    EA_TrialAlertWindow.InitializeFeatureList()
end

function EA_TrialAlertWindow.Show(alertType)

    if( alertType == nil)
    then 
        return
    elseif( alertType == SystemData.TrialAlert.ALERT_MAIL )
    then
    
        LabelSetText( "EA_TrialAlertWindowLabel", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_TRIAL_ALERT_MAIL) )

    elseif( alertType == SystemData.TrialAlert.ALERT_AUCTION )
    then

        LabelSetText( "EA_TrialAlertWindowLabel", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_TRIAL_ALERT_AUCTION) )

    elseif( alertType == SystemData.TrialAlert.ALERT_ZONE )
    then

        LabelSetText( "EA_TrialAlertWindowLabel", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_TRIAL_ALERT_ZONE) )
    
    elseif( alertType == SystemData.TrialAlert.ALERT_ITEMS )
    then

        LabelSetText( "EA_TrialAlertWindowLabel", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_TRIAL_ALERT_ITEMS) )
    
    elseif( alertType == SystemData.TrialAlert.ALERT_FLIGHTMASTER )
    then
 
        LabelSetText( "EA_TrialAlertWindowLabel", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_TRIAL_ALERT_FLIGHTMASTER) )

    elseif( alertType == SystemData.TrialAlert.ALERT_FIRST_ENTRY ) 
    then
    
        LabelSetText( "EA_TrialAlertWindowLabel", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_TRIAL_ALERT_FIRST_ENTRY) )

    elseif( alertType == SystemData.TrialAlert.ALERT_SERVER ) 
    then

        LabelSetText( "EA_TrialAlertWindowLabel", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_TRIAL_ALERT_NOT_ALLOWED_SERVER) )
        
    elseif( alertType == SystemData.TrialAlert.ALERT_LEVEL ) 
    then
    
        LabelSetText( "EA_TrialAlertWindowLabel", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_TRIAL_ALERT_LEVEL) )

    elseif( alertType == SystemData.TrialAlert.ALERT_MAX_LEVEL )
    then
    
        LabelSetText( "EA_TrialAlertWindowLabel", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_TRIAL_ALERT_LEVEL10) )

    elseif( alertType == SystemData.TrialAlert.ALERT_INVENTORY_EXPANSION )
    then
    
        LabelSetText( "EA_TrialAlertWindowLabel", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_TRIAL_ALERT_INVENTORY_EXPANSION) )

    elseif( alertType == SystemData.TrialAlert.ALERT_TRADE )
    then
    
        LabelSetText( "EA_TrialAlertWindowLabel", GetStringFromTable("TrialAlert", StringTables.TrialAlert.LABEL_TRIAL_ALERT_TRADE) )

    else
        return
    end

    WindowSetShowing("EA_TrialAlertWindow", true)
end

function EA_TrialAlertWindow.Close()
    WindowSetShowing("EA_TrialAlertWindow", false)
end

function EA_TrialAlertWindow.CloseDialog()
    WindowSetShowing("EA_TrialAlertWindow", false)
    
    EA_TrialAlertWindow.TwoButtonDialogShowing = false
end

function EA_TrialAlertWindow.OnUpgrade()

    if( EA_TrialAlertWindow.TwoButtonDialogShowing )
    then
        return
    end
    
    -- display a confirmation dialog 
    DialogManager.MakeTwoButtonDialog(GetString(StringTables.Default.LABEL_EXIT_CONFIRMATION),
        GetString(StringTables.Default.LABEL_YES), EA_TrialAlertWindow.OpenUpgradePage, 
        GetString(StringTables.Default.LABEL_NO), EA_TrialAlertWindow.CloseDialog,
        nil, nil, false, nil, nil)

    EA_TrialAlertWindow.TwoButtonDialogShowing = true
end

function EA_TrialAlertWindow.OnUpgradeWithOutClose()

    -- display a confirmation dialog 
    DialogManager.MakeTwoButtonDialog(GetString(StringTables.Default.LABEL_EXIT_CONFIRMATION),
        GetString(StringTables.Default.LABEL_YES), EA_TrialAlertWindow.OpenUpgradePage, 
        GetString(StringTables.Default.LABEL_NO), nil,
        nil, nil, false, nil, nil)

end

function EA_TrialAlertWindow.OnUpgradeModal()

    -- display a modal confirmation dialog 
    DialogManager.MakeTwoButtonDialog(GetString(StringTables.Default.LABEL_EXIT_CONFIRMATION),
        GetString(StringTables.Default.LABEL_YES), EA_TrialAlertWindow.OpenUpgradePage, 
        GetString(StringTables.Default.LABEL_NO), EA_TrialAlertWindow.Close,
        nil, nil, false, nil, DialogManager.TYPE_MODAL)

end

function EA_TrialAlertWindow.OpenUpgradePage()
    
    EA_TrialAlertWindow.CloseDialog()

    OpenURL( GameData.URLs.URL_ACCOUNT_UPGRADE )

    -- this one is for pregame (will not get handled if you are in game)
    BroadcastEvent( SystemData.Events.QUIT )

    -- this one is for in game (will not get handled if you are in pregame)
    BroadcastEvent( SystemData.Events.EXIT_GAME )

end

function EA_TrialAlertWindow.EnteredGame()

    local isTrial, _ = GetAccountData()

    if( isTrial and EA_TrialAlertWindow.IsFirstRun)
    then
        EA_TrialAlertWindow.Show(SystemData.TrialAlert.ALERT_FIRST_ENTRY)
        EA_TrialAlertWindow.IsFirstRun = false
    end
        
end

function EA_TrialAlertWindow.InitializeFeatureList()
    
    -- Populate the Display List
    EA_TrialAlertWindow.featureList = {}
    local windowListDisplayOrder = {}

    local numberOfFeatures = StringTables.TrialAlert.FEATURE_TEXT_LAST - StringTables.TrialAlert.FEATURE_TEXT_FIRST + 1
    local numberOfTrialFeatures = StringTables.TrialAlert.FEATURE_TEXT_LAST_TRIAL_FEATURE - StringTables.TrialAlert.FEATURE_TEXT_FIRST + 1
    for i=1, numberOfFeatures 
    do
        local featureName = GetStringFromTable("TrialAlert", StringTables.TrialAlert.FEATURE_TEXT_FIRST + i - 1 )
        
        local trialFeature = false
        if( i <= numberOfTrialFeatures )
        then
            trialFeature = true
        end
        
        local data = { featureName=featureName, trialFeature=trialFeature } 
        
        table.insert( EA_TrialAlertWindow.featureList, data )
        table.insert( windowListDisplayOrder, i )
    end
    
    ListBoxSetDisplayOrder("EA_TrialAlertWindowFeatureList", windowListDisplayOrder )

end

function EA_TrialAlertWindow.PopulateFeatureList()

    if (EA_TrialAlertWindowFeatureList.PopulatorIndices ~= nil) then                
        for rowIndex, dataIndex in ipairs (EA_TrialAlertWindowFeatureList.PopulatorIndices) do
            local data = EA_TrialAlertWindow.featureList[ dataIndex ]
            
            local rowName = "EA_TrialAlertWindowFeatureListRow"..rowIndex    
            LabelSetText( rowName.."Name", data.featureName )
            WindowSetShowing(rowName.."Trial", data.trialFeature)            
        end
    end    
end
