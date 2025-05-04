
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------


local DialogData = {}
DialogData.WindowId = {}
DialogData.Text = ""
DialogData.Button1Text = ""
DialogData.Button1Callback = Nil 
DialogData.Button2Text = ""
DialogData.Button2Callback = Nil 


function InitializeDialogs()

	WindowRegisterEventHandler( "GROUP_INVITE_ID", "GroupInviteCallback" );

end


-- Group Invite Dialog

local GroupInviteWindowId = 0;
function GroupInviteCallback()

	windowName = GetTwoButtonDlg();
	
	SetLabelText( windowName, DataRegistry.Dialogs.GroupInviteText );
	
	button1Name = windowName.."Button1";
	button2Name = windowName.."Button2";
	
	SetButtonText( button1, "Accept" );
	SetButtonText( button2, "Decline" );
	
	SetScript( button1, "OnLButtonUp", "GroupInviteAccept" );
	SetScript( button1, "OnLButtonUp", "GroupInviteDecline" );
	
end

function GroupInviteAccept()

	-- Broadcast the event
	BroadcastEvent( DataRegistry.Events.GROUP_INVITE_ACCEPT );	
end

function GroupInviteDecline()

	-- Broadcast the event
	BroadcastEvent( DataRegistry.Events.GROUP_INVITE_DECLINE );

end


