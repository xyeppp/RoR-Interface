
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
DialogManager = {}

DialogManager.ELEMENT_SPACING           = 10
DialogManager.WARNING_SPACING           = 20
DialogManager.DIALOG_BORDER             = 20
DialogManager.NEVER_WARN_ID_OFFSET      = 999
DialogManager.UNTYPED_ID                = 0
DialogManager.DIALOGID_LAST_USED        = 100
DialogManager.OriginalDimensions        = { width = nil, height = nil }
DialogManager.TYPE_MODE_LESS            = true
DialogManager.TYPE_MODAL                = false
DialogManager.DEFAULT_MAX_CHARS         = 1024



----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local function NewDialogData()
return { 
            inUse = false, 
            ButtonCallback1 = nil, 
            ButtonCallback2 = nil, 
            ButtonCallback3 = nil, 
            ButtonMultiCallbacks1 = {}, 
            ButtonMultiCallbacks2 = {},
            ButtonMultiCallbacks3 = {},
            timer=0, 
            AutoRespondButton=0,
            id=DialogManager.UNTYPED_ID,
            NeverWarnCallback = nil
        }
end

local function NewTextEntryDialogData()
    return { inUse = false,
             id=DialogManager.UNTYPED_ID,
             SubmitCallback = nil,
             CancelCallback = nil }
end

local function NewDialogPosition()
	return {inUse = false,
			xOffset = 0,
			yOffset = 0}
end

-- One Button Dialogs
DialogManager.NUM_ONE_BUTTON_DLGS = 5
DialogManager.oneButtonDlgs = {}

-- Two Button Dialogs
DialogManager.NUM_TWO_BUTTON_DLGS = 5
DialogManager.twoButtonDlgs = {}

-- Three Button Dialogs
DialogManager.NUM_THREE_BUTTON_DLGS = 1
DialogManager.threeButtonDlgs = {}

-- Text Entry Dialogs
DialogManager.NUM_TEXT_ENTRY_DLGS = 10
DialogManager.NUM_TEXT_ENTRY_DLGS_PER_TYPE = 5
DialogManager.MULTI_LINE_DLGS_START = 6
DialogManager.textEntryDlgs = {}

DialogManager.eventsRegistered = false

local dialogQueue = Queue:Create ()

local DialogCreator = {}
DialogCreator.__index = DialogCreator

--so that multiple dialogs don't stack on eachother
--be able to position them more intelligently
DialogManager.NUM_DIALOG_POSITIONS = 4
DialogManager.dialogPositions = {}



function DialogCreator:Create(buttonCount, dialogText, button1Text, buttonCallback1, button2Text, buttonCallback2, timer, autoRespondButton, warningIsChecked, neverWarnCallback, id)
    local newDialog = nil
	
    if (buttonCount == 1)
    then
        newDialog =
        {
            myID                = id or DialogManager.UNTYPED_ID,
            myButtonCount       = buttonCount, 
            myText              = dialogText, 
            myButton1Text       = button1Text, 
            myButton1Callback   = buttonCallback1,     
        }
        
        -- account for automatic event broadcasting in the case that the callback is an event id and not a function
        if (buttonCallback1 ~= nil and type (buttonCallback1) == "number")
        then
            newDialog.myButton1Event = buttonCallback1            
            
            newDialog.myButton1Callback = function () BroadcastEvent (newDialog.myButton1Event) end
        end
    elseif (buttonCount == 2)
    then       
        newDialog =
        {
            myID                = id or DialogManager.UNTYPED_ID,
            myButtonCount       = buttonCount, 
            myText              = dialogText, 
            myButton1Text       = button1Text, 
            myButton1Callback   = buttonCallback1, 
            myButton2Text       = button2Text, 
            myButton2Callback   = buttonCallback2,         
            myTimer             = timer, 
            myAutoRespondButton = autoRespondButton,
            myWarningIsChecked  = warningIsChecked,
            myNeverWarnCallback = neverWarnCallback,
        }
        
        -- account for automatic event broadcasting in the case that the callback is an event id and not a function
        -- then assume that both callbacks will be present and of the same type...
        if (buttonCallback1 ~= nil and type (buttonCallback1) == "number")
        then
            newDialog.myButton1Event = buttonCallback1            
            newDialog.myButton2Event = buttonCallback2
            
            newDialog.myButton1Callback = function () BroadcastEvent (newDialog.myButton1Event) end
            newDialog.myButton2Callback = function () BroadcastEvent (newDialog.myButton2Event) end
        end
    elseif (buttonCount == 3)
    then       
        newDialog =
        { 
            myID                = id or DialogManager.UNTYPED_ID,
            myButtonCount       = buttonCount, 
            myText              = dialogText, 
            myButton1Text       = button1Text, 
            myButton1Callback   = buttonCallback1, 
            myButton2Text       = button2Text, 
            myButton2Callback   = buttonCallback2,     
            myButton3Text       = button3Text, 
            myButton3Callback   = buttonCallback3,         
        }        
    end
    
    newDialog = setmetatable (newDialog, self)
    newDialog.__index = self

    return newDialog
end

function DialogCreator:GetButtonCount ()
    assert (self.myButtonCount ~= nil)
    return (self.myButtonCount)
end 

function DialogCreator:Display ()
    local buttonCount = self:GetButtonCount ()
    
    if (buttonCount == 1)
    then
        return DialogManager.MakeOneButtonDialog (self.myText, self.myButton1Text, self.myButton1Callback, nil, self.myID)
    elseif (buttonCount == 2)
    then
        return DialogManager.MakeTwoButtonDialog (self.myText, self.myButton1Text, self.myButton1Callback, self.myButton2Text, self.myButton2Callback,
                                                  self.myTimer, self.myAutoRespondButton, self.myWarningIsChecked, self.myNeverWarnCallback, nil, self.myID)
    end
    
    -- No dialog was even attempted?  Return true to get this strange object out of the queue!
    return true
end


local function QueueOneButtonDialog(text, buttonText, buttonCallback, dialogID)
    dialogQueue:PushBack (DialogCreator:Create(1, text, buttonText, buttonCallback, nil, nil,
                                               nil, nil, nil, nil, dialogID))
end

local function QueueTwoButtonDialog(dialogText, button1Text, buttonCallback1, button2Text, buttonCallback2,
                                    timer, autoRespondButton, warningIsChecked, neverWarnCallback, dialogID)

    -- dialogText could either be a wstring or a table, if it's a table, it came from SystemData.Dialogs.AppDlg.
    -- so use that instead of the standard creation function
    local dialogTextType = type (dialogText)
                
    if (dialogTextType == "wstring")
    then   
        dialogQueue:PushBack (DialogCreator:Create (2, dialogText, button1Text, buttonCallback1, button2Text, buttonCallback2,
                                                    timer, autoRespondButton, warningIsChecked, neverWarnCallback, dialogID))
    elseif (dialogTextType == "table")
    then
        local dialog = dialogText -- don't call it text any more, for convenience
        dialogQueue:PushBack (DialogCreator:Create (2, dialog.text, dialog.buttonText1, dialog.buttonEvent1, 
                                                    dialog.buttonText2, dialog.buttonEvent2, dialog.timer, dialog.autoRespondButton, nil, nil, dialog.id))
    end                
end

----------------------------------------------------------------
-- DialogManager General Functions
----------------------------------------------------------------

function DialogManager.Initialize()

    -- Create the Dialogs Windows

    -- One Button Dlgs  
    for dlg = 1, DialogManager.NUM_ONE_BUTTON_DLGS do
        DialogManager.oneButtonDlgs[ dlg ] = NewDialogData()
        CreateWindow( "OneButtonDlg"..dlg, false )
    end
    
    -- Two Button Dlgs  
    for dlg = 1, DialogManager.NUM_TWO_BUTTON_DLGS do
        DialogManager.twoButtonDlgs[ dlg ] = NewDialogData()
        CreateWindow( "TwoButtonDlg"..dlg, false )
        LabelSetText ("TwoButtonDlg"..dlg.."BoxNeverWarnLabel", GetPregameString (StringTables.Pregame.LABEL_NEVER_WARN_AGAIN));
        
        local warningButton = "TwoButtonDlg"..dlg.."BoxNeverWarnButton";
        ButtonSetCheckButtonFlag (warningButton, true);
        ButtonSetPressedFlag (warningButton, false);
        WindowSetId (warningButton, dlg + DialogManager.NEVER_WARN_ID_OFFSET);
        
        -- The template no longer handles input, so this will set the id on the container...
        local buttonContainer = "TwoButtonDlg"..dlg.."BoxNeverWarn";
        WindowSetId (buttonContainer, dlg + DialogManager.NEVER_WARN_ID_OFFSET);
    end
    
   -- Three Button Dlgs  
    for dlg = 1, DialogManager.NUM_THREE_BUTTON_DLGS do
        DialogManager.threeButtonDlgs[ dlg ] = NewDialogData()
        CreateWindow( "ThreeButtonDlg"..dlg, false )
    end

    -- Text Entry Dlgs
    for dlg = 1, DialogManager.NUM_TEXT_ENTRY_DLGS do
        DialogManager.textEntryDlgs[ dlg ] = NewTextEntryDialogData()
        CreateWindow( "TextEntryDlg"..dlg, false )
        ButtonSetText( "TextEntryDlg"..dlg.."ButtonCancel", GetPregameString(StringTables.Pregame.LABEL_CANCEL) );
        ButtonSetText( "TextEntryDlg"..dlg.."ButtonSubmit", GetPregameString(StringTables.Pregame.LABEL_SUBMIT) );
    end
        
    -- Register for the Special Case Callbacks
    if( DialogManager.eventsRegistered == false )
    then
        RegisterEventHandler( SystemData.Events.INFO_ALERT,                    "DialogManager.OnInfoAlert")
        RegisterEventHandler( SystemData.Events.APPLICATION_ONE_BUTTON_DIALOG, "DialogManager.OnApplicationOneButtonDialog" )
        RegisterEventHandler( SystemData.Events.APPLICATION_TWO_BUTTON_DIALOG, "DialogManager.OnApplicationTwoButtonDialog" )
        RegisterEventHandler( SystemData.Events.APPLICATION_REMOVE_DIALOG,     "DialogManager.OnRemoveDialog" )
        -- TODO: APPLICATION_TEXT_ENTRY_DIALOG?
        DialogManager.eventsRegistered = true
    end
	
	local xSize, ySize = 600, 200 --ThreeButtonDlgBox
	--DEBUG(L"DialogManager.Initialize() xSize="..xSize..L" ySize="..ySize)
	DialogManager.dialogPositions[ 1 ] = NewDialogPosition()
	
	DialogManager.dialogPositions[ 2 ] = NewDialogPosition()
	DialogManager.dialogPositions[ 2 ].yOffset = ySize
	
	DialogManager.dialogPositions[ 3 ] = NewDialogPosition()
	DialogManager.dialogPositions[ 3 ].xOffset = xSize
	
	DialogManager.dialogPositions[ 4 ] = NewDialogPosition()
	DialogManager.dialogPositions[ 4 ].xOffset = xSize
	DialogManager.dialogPositions[ 4 ].yOffset = ySize

end

function DialogManager.OnClickError()
    Sound.Play( Sound.NEGATIVE_FEEDBACK )
end

function DialogManager.CreateDialogId()
    DialogManager.DIALOGID_LAST_USED  = DialogManager.DIALOGID_LAST_USED + 1
    return DialogManager.DIALOGID_LAST_USED  
end

function DialogManager.FindAvailableDialog(dialogList, numDialogs, startIndex)

    if( startIndex == nil )
    then
        startIndex = 1
    end
    
    local endIndex = startIndex + (numDialogs - 1)

    for index = startIndex, endIndex do
        if (dialogList[index] ~= nil and dialogList[index].inUse == false) then
            return index        
        end
    end
    
    return nil

end

function DialogManager.FindAvailablePosition()
    for index = 1, DialogManager.NUM_DIALOG_POSITIONS do    
        if (DialogManager.dialogPositions[index] ~= nil and DialogManager.dialogPositions[index].inUse == false) then
			DialogManager.dialogPositions[index].inUse = true
            return DialogManager.dialogPositions[index]        
        end
    end
	return nil
end


function DialogManager.ReleaseDialog(dialog, windowName)
	if dialog ~= nil
	then
		dialog.inUse = false
		if dialog.timer ~= nil
		then
			dialog.timer = 0
		end
		
		DialogManager.ReleaseDialogPosition(dialog.dialogPosition)
		
		--useful to reset other fields? not having timer reset caused issues the next time
		--that particular dialog slot was used
		
	end
    
	WindowSetShowing(windowName, false)
end


function DialogManager.ReleaseDialogPosition(dialogPos)
	if dialogPos ~= nil
	then
		dialogPos.inUse = false
	end
end

function DialogManager.PositionDialog(dialog, windowName)
	if dialog ~= nil and windowName ~= nil 
	then
		--don't overlap on existing dialogs, re-anchor using my dialogPosition
		if dialog.dialogPosition ~= nil
		then
			local point, relativePoint, relativeTo, xoffs, yoffs = WindowGetAnchor( windowName, 1 )
			xoffs = dialog.dialogPosition.xOffset
			yoffs = dialog.dialogPosition.yOffset
			WindowClearAnchors( windowName )
			--DEBUG(L"realtiveTo="..StringToWString(relativeTo))
			WindowAddAnchor( windowName, point, relativeTo, relativePoint, xoffs, yoffs )
		end
	end
end

function DialogManager.Update( timePassed )

    -- If any of the active dialogs have an auto-respond timer, update them
    for index = 1, DialogManager.NUM_TWO_BUTTON_DLGS 
    do
        local dialog = DialogManager.twoButtonDlgs[index]
        
        if (dialog ~= nil and dialog.inUse == true and dialog.timer > 0 ) 
        then
            dialog.timer = dialog.timer - timePassed
        
            local timeText = TimeUtils.FormatSeconds( dialog.timer )
            LabelSetText( "TwoButtonDlg"..index.."BoxTimer", timeText )
                        
            if( dialog.timer  <= 0 ) 
            then
                dialog.timer = 0
                            
                -- Auto Respond Button 1
                if( dialog.AutoRespondButton == 1 and dialog.ButtonCallback1 ~= nil) 
                then
                    dialog.ButtonCallback1()                      
                end                 
                
                -- Auto Respond Button 2
                if( dialog.AutoRespondButton == 2 and dialog.ButtonCallback2 ~= nil) 
                then
                    dialog.ButtonCallback2()              
                end
                
                -- Remove the dialog
				DialogManager.ReleaseDialog(dialog, "TwoButtonDlg"..index)
            end
            
        end
    end    
    
    -- Create any queued dialogs that were suppressed due to the world still loading
    -- Just create one each update loop instead of "flooding" the system with a "while (queue.empty == false)"
    -- If the dialog could not be created, do not pop the front, keep the dialog in the queue to be created
    -- when there are some free dialog resources
    if (dialogQueue:IsEmpty() == false)
    then
        local queuedDialog = dialogQueue:Front ()
        
        if (queuedDialog:Display () == true)
        then
            dialogQueue:PopFront ()
        end
    end
end

----------------------------------------------------------------
-- One Button Dialog Functions
----------------------------------------------------------------

function DialogManager.MakeOneButtonDialog( dialogText, buttonText, buttonCallback, dialogType, dialogID )
    if (DataUtils.IsWorldLoading ())
    then
        QueueOneButtonDialog(dialogText, buttonText, buttonCallback, dialogID)
        
        -- queueing pretends that it was successful in creating the dialog
        return true 
    end

    -- Find a free dialog
    local dlgIndex = DialogManager.FindAvailableDialog (DialogManager.oneButtonDlgs, DialogManager.NUM_ONE_BUTTON_DLGS)

    -- We are out of dialogs... this shouldn't happen, but if it does, let the caller know
    if ( dlgIndex == nil ) 
    then
        return false
    end

    -- Set the Dialog's Parameters

    DialogManager.oneButtonDlgs[ dlgIndex ].inUse = true;
    DialogManager.oneButtonDlgs[ dlgIndex ].ButtonCallback1 = buttonCallback;
    DialogManager.oneButtonDlgs[ dlgIndex ].id = dialogID
	DialogManager.oneButtonDlgs[ dlgIndex ].dialogPosition      = DialogManager.FindAvailablePosition()
    
    if (type(buttonCallback) == "number")
    then
        DialogManager.oneButtonDlgs[ dlgIndex ].ButtonCallback1 = function () BroadcastEvent(buttonCallback) end
    end

    LabelSetText( "OneButtonDlg"..dlgIndex.."BoxText", dialogText )
    ButtonSetText( "OneButtonDlg"..dlgIndex.."BoxButton1", buttonText )

    DialogManager.PositionDialog(DialogManager.oneButtonDlgs[ dlgIndex ], "OneButtonDlg"..dlgIndex)
    
    -- Show the Dialog.
    -- This must be done before WindowResizeOnChildren -- it doesn't work otherwise.
    WindowSetShowing( "OneButtonDlg"..dlgIndex, true )

    WindowResizeOnChildren( "OneButtonDlg"..dlgIndex.."Box", false, 10 )

    if( dialogType == DialogManager.TYPE_MODAL )
    then
        local x, y = WindowGetDimensions( "Root" )
        x = x / InterfaceCore.GetScale()
        y = y / InterfaceCore.GetScale()
        WindowSetDimensions( "OneButtonDlg"..dlgIndex, x, y ) -- Set to the screen width and height
    else
        local x, y = WindowGetDimensions( "OneButtonDlg"..dlgIndex.."Box" )
        WindowSetDimensions ( "OneButtonDlg"..dlgIndex, x, y )
    end

    return true
end 

-- General Callback Functions
function DialogManager.OnOneButtonDlgButton1()
    local dlgIndex = WindowGetId( WindowGetParent( WindowGetParent(SystemData.ActiveWindow.name) ) )

    if( DialogManager.oneButtonDlgs[ dlgIndex ].ButtonCallback1 ~= nil )
    then
        DialogManager.oneButtonDlgs[ dlgIndex ].ButtonCallback1()
    end
    
    DialogManager.ReleaseDialog(DialogManager.oneButtonDlgs[ dlgIndex ], "OneButtonDlg"..dlgIndex)
end

----------------------------------------------------------------
-- Two Button Dialog Functions
----------------------------------------------------------------

function DialogManager.MakeTwoButtonDialog( dialogText, button1Text, buttonCallback1, button2Text, buttonCallback2,
                timer, autoRespondButton, warningIsChecked, neverWarnCallback, dialogType, dialogID, windowLayer )
    
    if (DataUtils.IsWorldLoading ())
    then
        QueueTwoButtonDialog ( dialogText, button1Text, buttonCallback1, button2Text, buttonCallback2,
                timer, autoRespondButton, warningIsChecked, neverWarnCallback, dialogID )
        
        -- Queueing the dialog is assumed to be a success (so that the dialog queue does not grow unbounded)
        return true
    end
    
    -- Find a free dialog
    local dlgIndex = DialogManager.FindAvailableDialog (DialogManager.twoButtonDlgs, DialogManager.NUM_TWO_BUTTON_DLGS)
    
    -- We are out of dialogs... this shouldn't happen, but if it does, let the caller know about it
    if ( dlgIndex == nil )
    then
        return false
    end
    
    -- Set the Dialog's Parameters
    
    DialogManager.twoButtonDlgs[ dlgIndex ].inUse               = true;
    DialogManager.twoButtonDlgs[ dlgIndex ].ButtonCallback1     = buttonCallback1
    DialogManager.twoButtonDlgs[ dlgIndex ].ButtonCallback2     = buttonCallback2
    DialogManager.twoButtonDlgs[ dlgIndex ].NeverWarnCallback   = neverWarnCallback
    DialogManager.twoButtonDlgs[ dlgIndex ].type                = dialogType
    DialogManager.twoButtonDlgs[ dlgIndex ].id                  = dialogID
	DialogManager.twoButtonDlgs[ dlgIndex ].dialogPosition      = DialogManager.FindAvailablePosition()
	
    if( timer ~= nil)
    then
        DialogManager.twoButtonDlgs[ dlgIndex ].timer = timer
    end
        
    if( autoRespondButton ~= nil )
    then
        DialogManager.twoButtonDlgs[ dlgIndex ].AutoRespondButton = autoRespondButton
    end
	
	DialogManager.PositionDialog(DialogManager.twoButtonDlgs[ dlgIndex ], "TwoButtonDlg"..dlgIndex)
    
    LabelSetText( "TwoButtonDlg"..dlgIndex.."BoxText", dialogText )
    LabelSetText( "TwoButtonDlg"..dlgIndex.."BoxTimer", L"" )
    
    -- Button 1
    ButtonSetText( "TwoButtonDlg"..dlgIndex.."BoxButton1", button1Text )    
    WindowSetShowing( "TwoButtonDlg"..dlgIndex.."BoxButton1", button1Text ~= L"" )
    
    -- Button 2
    ButtonSetText( "TwoButtonDlg"..dlgIndex.."BoxButton2", button2Text )
    WindowSetShowing( "TwoButtonDlg"..dlgIndex.."BoxButton2", button2Text ~= L"" )
    
    -- Resize the dialog and background image if the "Never Warn Again" 
    -- is enabled...
    if (DialogManager.OriginalDimensions.width == nil) then
        --DEBUG (L"Getting dialog dimensions");
        DialogManager.OriginalDimensions.width, DialogManager.OriginalDimensions.height = WindowGetDimensions ("TwoButtonDlg"..dlgIndex.."Box");
    end
    
    local height    = DialogManager.OriginalDimensions.height + DialogManager.DIALOG_BORDER;
    local width     = DialogManager.OriginalDimensions.width;

    if (neverWarnCallback)
    then
        local warningName = "TwoButtonDlg"..dlgIndex.."BoxNeverWarn";
        local warnWidth, warnHeight = WindowGetDimensions (warningName);
        
        ButtonSetPressedFlag (warningName.."Button", warningIsChecked);
        
        height = height + warnHeight + DialogManager.WARNING_SPACING; 
    end
    
    WindowSetDimensions ("TwoButtonDlg"..dlgIndex.."Box", width, height);

    -- Show the Dialog
    WindowSetShowing( "TwoButtonDlg"..dlgIndex, true )    
    WindowSetShowing ("TwoButtonDlg"..dlgIndex.."BoxNeverWarn", neverWarnCallback ~= nil);
    
      -- Show the Dialog.
    -- This must be done before WindowResizeOnChildren -- it doesn't work otherwise.
    WindowSetShowing( "TwoButtonDlg"..dlgIndex, true )

    WindowResizeOnChildren( "TwoButtonDlg"..dlgIndex.."Box", false, 10 )

    if( dialogType == DialogManager.TYPE_MODAL )
    then
        local x, y = WindowGetDimensions( "Root" )
        x = x / InterfaceCore.GetScale()
        y = y / InterfaceCore.GetScale()
        WindowSetDimensions( "TwoButtonDlg"..dlgIndex, x, y ) -- Set to the screen width and height
    else
        local x, y = WindowGetDimensions( "TwoButtonDlg"..dlgIndex.."Box" )
        WindowSetDimensions ( "TwoButtonDlg"..dlgIndex, x, y )
    end
    
    if windowLayer
    then
        WindowSetLayer("TwoButtonDlg"..dlgIndex, windowLayer)
    end
    
    return true

end 

-- General Callback Functions
function DialogManager.OnTwoButtonDlgButton1()

    local dlgIndex = WindowGetId( WindowGetParent( WindowGetParent(SystemData.ActiveWindow.name) ) )

    if( DialogManager.twoButtonDlgs[ dlgIndex ].ButtonCallback1 ~= nil )
    then
        DialogManager.twoButtonDlgs[ dlgIndex ].ButtonCallback1()
    end
    
	DialogManager.ReleaseDialog(DialogManager.twoButtonDlgs[ dlgIndex ], "TwoButtonDlg"..dlgIndex)
    
end

function DialogManager.OnTwoButtonDlgButton2()

    local dlgIndex = WindowGetId( WindowGetParent( WindowGetParent(SystemData.ActiveWindow.name) ) )
        
    if( DialogManager.twoButtonDlgs[ dlgIndex ].ButtonCallback2 ~= nil )
    then
        DialogManager.twoButtonDlgs[ dlgIndex ].ButtonCallback2()
    end
    
	DialogManager.ReleaseDialog(DialogManager.twoButtonDlgs[ dlgIndex ], "TwoButtonDlg"..dlgIndex)
    
end

function DialogManager.OnTwoButtonDlgNeverWarn ()
    local dlgIndex = WindowGetId (SystemData.MouseOverWindow.name);
    
    if (dlgIndex == nil) 
    then 
        return 
    end
    
    -- Windows all have the same id's...use something that won't
    -- have a matching id to another window...
    dlgIndex = dlgIndex - DialogManager.NEVER_WARN_ID_OFFSET;    
    
    if (dlgIndex > 0 and DialogManager.twoButtonDlgs[dlgIndex].NeverWarnCallback ~= nil)
    then       
        DialogManager.twoButtonDlgs[dlgIndex].NeverWarnCallback ();
        
        local pressed = ButtonGetPressedFlag( SystemData.MouseOverWindow.name.."Button" )
        ButtonSetPressedFlag( SystemData.MouseOverWindow.name.."Button", not pressed )
    end
end



----------------------------------------------------------------
-- Three Button Dialog Functions
----------------------------------------------------------------

function DialogManager.MakeThreeButtonDialog( dialogText, button1Text, buttonCallback1, button2Text, buttonCallback2,
                button3Text, buttonCallback3, dialogType, dialogID )
    
    if (DataUtils.IsWorldLoading ())
    then
        QueueThreeButtonDialog ( dialogText, button1Text, buttonCallback1, button2Text, buttonCallback2,
                                 button3Text, buttonCallback3, dialogID )
        
        -- Queueing the dialog is assumed to be a success (so that the dialog queue does not grow unbounded)
        return true
    end
    
    -- Find a free dialog
    local dlgIndex = DialogManager.FindAvailableDialog (DialogManager.threeButtonDlgs, DialogManager.NUM_THREE_BUTTON_DLGS)
    
    -- We are out of dialogs... this shouldn't happen, but if it does, let the caller know about it
    if ( dlgIndex == nil )
    then
        return false
    end
    
    -- Set the Dialog's Parameters
    
    DialogManager.threeButtonDlgs[ dlgIndex ].inUse               = true;
    DialogManager.threeButtonDlgs[ dlgIndex ].ButtonCallback1     = buttonCallback1
    DialogManager.threeButtonDlgs[ dlgIndex ].ButtonCallback2     = buttonCallback2
    DialogManager.threeButtonDlgs[ dlgIndex ].NeverWarnCallback   = neverWarnCallback
    DialogManager.threeButtonDlgs[ dlgIndex ].type                = dialogType
    DialogManager.threeButtonDlgs[ dlgIndex ].id                  = dialogID
	DialogManager.threeButtonDlgs[ dlgIndex ].dialogPosition      = DialogManager.FindAvailablePosition()
	
    if( timer ~= nil)
    then
        DialogManager.threeButtonDlgs[ dlgIndex ].timer = timer
    end
        
    if( autoRespondButton ~= nil )
    then
        DialogManager.threeButtonDlgs[ dlgIndex ].AutoRespondButton = autoRespondButton
    end
    
    LabelSetText( "ThreeButtonDlg"..dlgIndex.."BoxText", dialogText )
    
    -- Button 1
    ButtonSetText( "ThreeButtonDlg"..dlgIndex.."BoxButton1", button1Text )    
    WindowSetShowing( "ThreeButtonDlg"..dlgIndex.."BoxButton1", button1Text ~= L"" )
    
    -- Button 2
    ButtonSetText( "ThreeButtonDlg"..dlgIndex.."BoxButton2", button2Text )
    WindowSetShowing( "ThreeButtonDlg"..dlgIndex.."BoxButton2", button2Text ~= L"" )
    
        
    -- Button 3
    ButtonSetText( "ThreeButtonDlg"..dlgIndex.."BoxButton3", button3Text )
    WindowSetShowing( "ThreeButtonDlg"..dlgIndex.."BoxButton3", button2Text ~= L"" )
        
	DialogManager.PositionDialog(DialogManager.threeButtonDlgs[ dlgIndex ], "ThreeButtonDlg"..dlgIndex)

    if( dialogType == DialogManager.TYPE_MODAL )
    then
        local x, y = WindowGetDimensions( "Root" )
        x = x / InterfaceCore.GetScale()
        y = y / InterfaceCore.GetScale()
        WindowSetDimensions ("ThreeButtonDlg"..dlgIndex, x, y ) -- Set to the screen width and height
    else
        local x, y = WindowGetDimensions( "ThreeButtonDlg"..dlgIndex.."Box" )
        WindowSetDimensions ( "ThreeButtonDlg"..dlgIndex, x, y )
    end
        
    -- Show the Dialog
    WindowSetShowing( "ThreeButtonDlg"..dlgIndex, true )    
    
    return true

end 

-- General Callback Functions
function DialogManager.OnThreeButtonDlgButton1()

    local dlgIndex = WindowGetId( WindowGetParent( WindowGetParent(SystemData.ActiveWindow.name) ) )

    if( DialogManager.threeButtonDlgs[ dlgIndex ].ButtonCallback1 ~= nil )
    then
        DialogManager.threeButtonDlgs[ dlgIndex ].ButtonCallback1()
    end
    
    DialogManager.ReleaseDialog(DialogManager.threeButtonDlgs[ dlgIndex ], "ThreeButtonDlg"..dlgIndex)
    
end

function DialogManager.OnThreeButtonDlgButton2()

    local dlgIndex = WindowGetId( WindowGetParent( WindowGetParent(SystemData.ActiveWindow.name) ) )
        
    if( DialogManager.threeButtonDlgs[ dlgIndex ].ButtonCallback2 ~= nil )
    then
        DialogManager.threeButtonDlgs[ dlgIndex ].ButtonCallback2()
    end
    
    DialogManager.ReleaseDialog(DialogManager.threeButtonDlgs[ dlgIndex ], "ThreeButtonDlg"..dlgIndex)
    
end


function DialogManager.OnThreeButtonDlgButton3()

    local dlgIndex = WindowGetId( WindowGetParent( WindowGetParent(SystemData.ActiveWindow.name) ) )
        
    if( DialogManager.threeButtonDlgs[ dlgIndex ].ButtonCallback3 ~= nil )
    then
        DialogManager.threeButtonDlgs[ dlgIndex ].ButtonCallback3()
    end
    
    DialogManager.ReleaseDialog(DialogManager.threeButtonDlgs[ dlgIndex ], "ThreeButtonDlg"..dlgIndex)
    
end


----------------------------------------------------------------
-- Text Entry Dialog Functions
----------------------------------------------------------------
function DialogManager.MakeTextEntryDialog( dialogTitle, dialogText, defaultUserText, submitCallback, cancelCallback, maxChars, multiLine, dialogID )
    -- Find a free dialog.
    local startIndex = 1
    if( multiLine )
    then
        startIndex = DialogManager.MULTI_LINE_DLGS_START
    end
    local dlgIndex = DialogManager.FindAvailableDialog( DialogManager.textEntryDlgs, DialogManager.NUM_TEXT_ENTRY_DLGS_PER_TYPE, startIndex )
    if ( dlgIndex == nil )
    then
        -- We are out of dialogs... ideally this shouldn't happen.
        return
    end
    
    if( maxChars == nil )
    then
        maxChars = DialogManager.DEFAULT_MAX_CHARS
    end
    
    -- Set the dialog's parameters.
    DialogManager.textEntryDlgs[ dlgIndex ].inUse = true;   
    DialogManager.textEntryDlgs[ dlgIndex ].SubmitCallback      = submitCallback;
    DialogManager.textEntryDlgs[ dlgIndex ].CancelCallback      = cancelCallback;
    DialogManager.textEntryDlgs[ dlgIndex ].id                  = dialogID;
	DialogManager.textEntryDlgs[ dlgIndex ].dialogPosition      = DialogManager.FindAvailablePosition()
    
    -- Setup its components.
    LabelSetText( "TextEntryDlg"..dlgIndex.."TitleBarText", dialogTitle )
    LabelSetText( "TextEntryDlg"..dlgIndex.."TextLabel", dialogText )
    TextEditBoxSetText( "TextEntryDlg"..dlgIndex.."TextEntry", defaultUserText )
    TextEditBoxSetMaxChars( "TextEntryDlg"..dlgIndex.."TextEntry", maxChars )
    
    -- Finally, show the dialog.
    WindowSetShowing( "TextEntryDlg"..dlgIndex, true )
    WindowAssignFocus( "TextEntryDlg"..dlgIndex.."TextEntry", true )
    TextEditBoxSelectAll( "TextEntryDlg"..dlgIndex.."TextEntry" )
end 

function DialogManager.SubmitTextEntryDialog( dlgIndex )
    if ( dlgIndex < 1 or dlgIndex > DialogManager.NUM_TEXT_ENTRY_DLGS ) then
        return
    end

    if ( DialogManager.textEntryDlgs[ dlgIndex ].SubmitCallback ~= nil ) then
        DialogManager.textEntryDlgs[ dlgIndex ].SubmitCallback( TextEditBoxGetText( "TextEntryDlg"..dlgIndex.."TextEntry" ) )
    end

    DialogManager.ReleaseDialog(DialogManager.textEntryDlgs[ dlgIndex ], "TextEntryDlg"..dlgIndex)

    -- Ideally this should be done automatically when the window is hidden, but whatever.
    WindowAssignFocus( "TextEntryDlg"..dlgIndex.."TextEntry", false )
end

function DialogManager.CancelTextEntryDialog( dlgIndex )
    if ( dlgIndex < 1 or dlgIndex > DialogManager.NUM_TEXT_ENTRY_DLGS ) then
        return
    end

    if ( DialogManager.textEntryDlgs[ dlgIndex ].CancelCallback ~= nil ) then
        DialogManager.textEntryDlgs[ dlgIndex ].CancelCallback()
    end
    
    DialogManager.ReleaseDialog(DialogManager.textEntryDlgs[ dlgIndex ], "TextEntryDlg"..dlgIndex)

    -- Ideally this should be done automatically when the window is hidden, but whatever.
    WindowAssignFocus( "TextEntryDlg"..dlgIndex.."TextEntry", false )
end

function DialogManager.OnTextEntryDlgButtonSubmit()
    local dlgIndex = WindowGetId( WindowGetParent(SystemData.ActiveWindow.name) )
    DialogManager.SubmitTextEntryDialog( dlgIndex )
end

function DialogManager.OnTextEntryDlgButtonCancel()
    local dlgIndex = WindowGetId( WindowGetParent(SystemData.ActiveWindow.name) )
    DialogManager.CancelTextEntryDialog( dlgIndex )
end

function DialogManager.OnTextEntryDlgKeyEnter()
    local dlgIndex = WindowGetId( WindowGetParent(SystemData.ActiveWindow.name) )
    DialogManager.SubmitTextEntryDialog( dlgIndex )
end

function DialogManager.OnTextEntryDlgKeyEscape()
    local dlgIndex = WindowGetId( SystemData.ActiveWindow.name )
    DialogManager.CancelTextEntryDialog( dlgIndex )
end

----------------------------------------------------------------
-- Application-Requested Dialog Functions
----------------------------------------------------------------

-- Info Alert
function DialogManager.OnInfoAlert()
    -- Pop up a dialog with an 'Ok' Button and no callback
    DialogManager.MakeOneButtonDialog(SystemData.Dialogs.InfoAlert, GetPregameString(StringTables.Pregame.LABEL_OKAY), nil, nil, DialogManager.UNTYPED_ID)
end

function DialogManager.OnApplicationOneButtonDialog()
    DialogManager.MakeOneButtonDialog(SystemData.Dialogs.AppDlg.text, SystemData.Dialogs.AppDlg.buttonText1, SystemData.Dialogs.AppDlg.buttonEvent1, nil, SystemData.Dialogs.AppDlg.id)
end

function DialogManager.OnApplicationTwoButtonDialog()
    -- Queue this dialog instead of creating it so the button events can be saved as part of the queued dialog.
    -- This allows the creation of multiple dialogs with choices that won't refer back to the SystemData.Dialogs.AppDlg.eventX
    -- when it may have changed by the time the user gets around to answering.
    
    -- The queued dialog will be created on the next dialog update cycle.
    
    --DEBUG(L"DialogManager.OnApplicationTwoButtonDialog().  id = "..SystemData.Dialogs.AppDlg.id)
    QueueTwoButtonDialog(SystemData.Dialogs.AppDlg)
end

-- TODO: Use this as the handler for APPLICATION_TEXT_ENTRY_DIALOG?
--[[
function DialogManager.OnApplicationTextEntryDialog()
    DialogManager.MakeTextEntryDialog( SystemData.Dialogs.AppDlg.text, nil, DialogManager.OnAppDlgButton1, DialogManager.OnAppDlgButton2, SystemData.Dialogs.AppDlg.id )
end
]]--

function DialogManager.OnRemoveDialog(dialogID)
    -- If it's a legacy dialog with no identification, don't remove it.
    --DEBUG(L"DialogManager.OnRemoveDialog("..dialogID..L")")
    if (dialogID ~= DialogManager.UNTYPED_ID)
    then
        -- Sieve through the dialogs and remove them
        for index, data in pairs(DialogManager.oneButtonDlgs)
        do
            if (data.id == dialogID)
            then
                DialogManager.ReleaseDialog(data, "OneButtonDlg"..index)
            end
        end

        -- Two Button Dialogs
        for index, data in pairs(DialogManager.twoButtonDlgs)
        do
            if (data.id == dialogID)
            then
				DialogManager.ReleaseDialog(data, "TwoButtonDlg"..index)
            end
        end

        -- Three Button Dialogs
        for index, data in pairs(DialogManager.threeButtonDlgs)
        do
            if (data.id == dialogID)
            then
                DialogManager.ReleaseDialog(data, "ThreeButtonDlg"..index)
            end
        end

        -- Text Entry Dialogs
        for index, data in pairs(DialogManager.textEntryDlgs)
        do
            if (data.id == dialogID)
            then
                DialogManager.ReleaseDialog(data, "TextEntryDlg"..index)
            end
        end
    end
end
