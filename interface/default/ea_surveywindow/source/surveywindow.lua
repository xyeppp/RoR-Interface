----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_Survey = {}

EA_Window_Survey.MAX_SURVEY_QUESTIONS = 10
EA_Window_Survey.MAX_SURVEY_OPTIONS = 11
EA_Window_Survey.hasSubmitted = false

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

----------------------------------------------------------------
-- EA_Window_Survey Functions
----------------------------------------------------------------

-- OnInitialize Handler
function EA_Window_Survey.Initialize()       
   
   -- DEBUG(L"EA_Window_Survey::Initialize")    
   
   WindowRegisterEventHandler( "EA_Window_Survey", SystemData.Events.SURVEY_UPDATED, "EA_Window_Survey.UpdateSurvey")   
    
end


function EA_Window_Survey.UpdateSurvey()
    
    local max_option_height
    local x, y
    local last_anchor = ""
    local total_height = 0    
    local survey_height = 0
    local wrap_padding = 0
    
    -- Remove the object ID from the label if it exists
    local temp_label = Survey.label
    temp_label = wstring.gsub(temp_label, L" %b()", L"")    
               
    LabelSetText( "EA_Window_SurveyTitleBarText", temp_label )    
    LabelSetText( "EA_Window_SurveyDescription", Survey.description )
    x, y = LabelGetTextDimensions("EA_Window_SurveyDescription")
    WindowSetDimensions("EA_Window_SurveyDescription", 1000, y)
    ButtonSetText( "EA_Window_SurveySubmitButton", GetString( StringTables.Default.LABEL_SUBMIT) )    
    TextEditBoxSetText( "EA_Window_SurveyCommentText", L"" )
    
    for question = 1, EA_Window_Survey.MAX_SURVEY_QUESTIONS do
        if Survey.question[question].label ~= L"" then
            wrap_padding = 0
            
            EA_Window_Survey.SelectButton( 0, "EA_Window_SurveyQuestion"..question )
            WindowSetShowing("EA_Window_SurveyQuestion"..question, true)
            
            if( question > 1 ) then
                WindowClearAnchors("EA_Window_SurveyQuestion"..question)
                WindowAddAnchor("EA_Window_SurveyQuestion"..question, "bottomleft", last_anchor, "topleft", 0, 0)            
            end
            
            LabelSetText("EA_Window_SurveyQuestion"..question.."Title", Survey.question[question].label)                   
            max_option_height = 32
            for option = 1, EA_Window_Survey.MAX_SURVEY_OPTIONS do
                if Survey.question[question].option[option].label ~= L"" then
                    if( option >= 7 ) then
                        wrap_padding = max_option_height * 2
                    end               
                    
                    WindowSetShowing("EA_Window_SurveyQuestion"..question.."Option"..option.."Label", true)
                    WindowSetShowing("EA_Window_SurveyQuestion"..question.."Option"..option.."Button", true)
                    LabelSetText("EA_Window_SurveyQuestion"..question.."Option"..option.."Label", Survey.question[question].option[option].label)
                    x, y = LabelGetTextDimensions("EA_Window_SurveyQuestion"..question.."Option"..option.."Label")
                    max_option_height = math.max(max_option_height, y)                    
                    ButtonSetStayDownFlag("EA_Window_SurveyQuestion"..question.."Option"..option.."Button", true)
                    
                else
                    WindowSetShowing("EA_Window_SurveyQuestion"..question.."Option"..option.."Label", false)
                    WindowSetShowing("EA_Window_SurveyQuestion"..question.."Option"..option.."Button", false)
                end                
            end
            x, y = LabelGetTextDimensions("EA_Window_SurveyQuestion"..question.."Title")            
            WindowSetDimensions("EA_Window_SurveyQuestion"..question.."Title", 980, y)
            WindowSetDimensions("EA_Window_SurveyQuestion"..question, 1000, y + max_option_height + 30 + wrap_padding)

            total_height = total_height + y + max_option_height + 30 + wrap_padding
            last_anchor = "EA_Window_SurveyQuestion"..question            
        else
            WindowSetShowing("EA_Window_SurveyQuestion"..question, false)
        end        
    end
    if Survey.comment ~= L"" then
        WindowClearAnchors("EA_Window_SurveyComment")
        WindowAddAnchor("EA_Window_SurveyComment", "bottomleft", last_anchor, "topleft", 0, 0)
        WindowSetShowing("EA_Window_SurveyComment", true)
        LabelSetText("EA_Window_SurveyCommentTitle", Survey.comment)
        x, y = LabelGetTextDimensions("EA_Window_SurveyCommentTitle")
        WindowSetDimensions("EA_Window_SurveyComment", 1000, 180 + y)
        WindowSetDimensions("EA_Window_SurveyCommentTitle", 1000, y)                
        total_height = total_height + 170 + y
    else
        WindowSetShowing("EA_Window_SurveyComment", false)
    end
    survey_height = total_height
    x, y = WindowGetDimensions("EA_Window_SurveySubmitButton")
    total_height = total_height + y

    x, y = WindowGetDimensions("EA_Window_SurveyDescription")
    total_height = total_height + y
    

    ScrollWindowSetOffset( "EA_Window_SurveyContents", 0 )
    ScrollWindowUpdateScrollRect( "EA_Window_SurveyContents" )

end

-- OnShutdown Handler
function EA_Window_Survey.Shutdown()
end

function EA_Window_Survey.Hide()

    WindowSetShowing("EA_Window_Survey", false)
end

function EA_Window_Survey.OnOpen()    
    -- Do not allow the edit box to automatically trap input when it opens.
    WindowAssignFocus( "EA_Window_SurveyCommentText", false )
    EA_Window_Survey.hasSubmitted = false
    WindowUtils.OnShown(EA_Window_Survey.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
end

function EA_Window_Survey.OnClose()  
      
end

function EA_Window_Survey.OnDecline()
    WindowUtils.OnHidden()
    if( not EA_Window_Survey.hasSubmitted )
    then
        SendSurveyResponse(Survey.id, Survey.event_type, Survey.object_id, Survey.object_name, EA_Window_SurveyCommentText.Text, false)
    end
    EA_Window_Survey.OnClear() 
end

function EA_Window_Survey.OnSubmit() 

    for question = 1, EA_Window_Survey.MAX_SURVEY_QUESTIONS do
        if Survey.question[question].label ~= L"" then
            if Survey.question[question].choice == 0 then
                DialogManager.MakeOneButtonDialog( L"Please choose an option for question "..question..L".", GetString( StringTables.Default.LABEL_OKAY ), nil )
                return
            end            
        end
    end
    
    --DEBUG(L"Submitting survey with comment..."..EA_Window_SurveyCommentText.Text)        
    
    SendSurveyResponse(Survey.id, Survey.event_type, Survey.object_id, Survey.object_name, EA_Window_SurveyCommentText.Text, true)
    EA_Window_Survey.hasSubmitted = true
    EA_Window_Survey.OnClear()
    EA_Window_Survey.Hide()
end

function EA_Window_Survey.OnClear()    
    
end

function EA_Window_Survey.OnSelectButton()
    -- Figure out which question was selected and which option in that question was selected from the appropriate Window IDs
    local option = WindowGetId(SystemData.ActiveWindow.name)
    local questionWindowName = string.sub(SystemData.ActiveWindow.name, 0, string.find(SystemData.ActiveWindow.name, "Option") - 1)
    EA_Window_Survey.SelectButton( option, questionWindowName )
end

function EA_Window_Survey.SelectButton( option, questionWindowName )

    local question = WindowGetId(questionWindowName)
    Survey.question[question].choice = option

    for index = 1, EA_Window_Survey.MAX_SURVEY_OPTIONS do
        ButtonSetPressedFlag( questionWindowName.."Option"..index.."Button", option == index )
    end   

end