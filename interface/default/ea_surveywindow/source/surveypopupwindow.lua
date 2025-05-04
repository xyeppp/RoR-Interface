----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_SurveyPopup = {}
EA_Window_CsrSurveyPopup = {}

EA_Window_SurveyPopup.COUNTDOWN_TIME = 120 -- Seconds
EA_Window_SurveyPopup.countdownTime = 0

local CSRSURVEY_WINDOW_NAME = "EA_Window_CSRSurveyPopup"

----------------------------------------------------------------
-- EA_Window_SurveyPopup Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_SurveyPopup.Initialize()        	    
	
	--DEBUG(L"EA_Window_SurveyPopup::Initialize")    
    WindowRegisterEventHandler( "EA_Window_SurveyPopup", SystemData.Events.SURVEY_POPUP, "EA_Window_SurveyPopup.ShowPopup")
    
	LabelSetText("EA_Window_SurveyPopupName", GetString( StringTables.Default.LABEL_SURVEY ) )
	LabelSetText("EA_Window_SurveyPopupTimer", GetString( StringTables.Default.LABEL_SURVEY_COUNTDOWN ) )
	ButtonSetText("EA_Window_SurveyPopupShowNowButton", GetString( StringTables.Default.LABEL_OPEN_NOW ) )	
	
	WindowSetAlpha("EA_Window_SurveyPopup", 0.75)
	
end

function EA_Window_CsrSurveyPopup.Initialize()
    LabelSetText( CSRSURVEY_WINDOW_NAME.."Name", GetString( StringTables.Default.LABEL_CSR_SURVEY1 ) )
    ButtonSetText( CSRSURVEY_WINDOW_NAME.."ShowNowButton", GetString( StringTables.Default.BUTTON_CSR_SURVEY_OPEN ) )	
    ButtonSetText( CSRSURVEY_WINDOW_NAME.."CancelSurveyButton", GetString( StringTables.Default.BUTTON_CSR_SURVEY_CLOSE ) )	
end

function EA_Window_SurveyPopup.ShowPopup( )

    if Survey.isCSRSurvey
    then
        if not DoesWindowExist( CSRSURVEY_WINDOW_NAME )
        then
            CreateWindowFromTemplate( CSRSURVEY_WINDOW_NAME, CSRSURVEY_WINDOW_NAME, "Root")
        end
        WindowSetShowing( CSRSURVEY_WINDOW_NAME, true )
    else
        EA_Window_SurveyPopup.countdownTime = EA_Window_SurveyPopup.COUNTDOWN_TIME
        WindowSetShowing("EA_Window_SurveyPopup", true)  
    end
  

end

function EA_Window_SurveyPopup.ShowSurvey( )
   
    WindowSetShowing("EA_Window_SurveyPopup", false)
    WindowSetShowing( CSRSURVEY_WINDOW_NAME, false )
    EA_Window_Survey.UpdateSurvey()
    WindowSetShowing("EA_Window_Survey", true)
    
end

function EA_Window_SurveyPopup.UpdateCountdownTime( timePassed )

    if(EA_Window_SurveyPopup.countdownTime > 0 ) then		
		EA_Window_SurveyPopup.countdownTime = EA_Window_SurveyPopup.countdownTime - timePassed
		if( EA_Window_SurveyPopup.countdownTime <= 0 ) then
			EA_Window_SurveyPopup.countdownTime = 0					
			EA_Window_SurveyPopup.ShowSurvey()			
		else
			local time = TimeUtils.FormatClock( EA_Window_SurveyPopup.countdownTime )
			local text = GetStringFormat( StringTables.Default.LABEL_SURVEY_COUNTDOWN, { time } )
			LabelSetText( "EA_Window_SurveyPopupTimer", text )	
		end				
	end	

end

function EA_Window_CsrSurveyPopup.OnCancelCsrSurvey()
    WindowSetShowing( CSRSURVEY_WINDOW_NAME, false )
    EA_Window_Survey.hasSubmitted = false    
    EA_Window_Survey.OnDecline()
end
