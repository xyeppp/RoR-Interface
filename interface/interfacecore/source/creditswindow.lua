----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_Credits = 
{
}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
local SECTION_SPACING = 40
local SUB_SECTION_SPACING = 20
local TEXT_SPACING = 20

----------------------------------------------------------------
-- EA_Window_Credits Functions
----------------------------------------------------------------

function EA_Window_Credits.Initialize()       

    -- Set the Title
    LabelSetText( "EA_Window_CreditsTitleBarText", GetPregameString( StringTables.Pregame.LABEL_CREDITS))
    
        
    -- Build the List of Credits...
    local creditsData = GetCreditsData()
    
    local parentWindow    = "EA_Window_CreditsScrollWindowScrollChild"
    local anchorToWindow  = parentWindow
    local anchorPoint     = "top"
    local anchorToPoint   = "top"
    local ySpacing        = 0
       
    for sectionIndex, sectionData in ipairs( creditsData.sections )
    do

        -- Create the section Heading
        local sectionWindowName = parentWindow.."Section"..sectionIndex
        CreateWindowFromTemplate( sectionWindowName, "EA_Credits_SectionTitleTemplate", parentWindow )
        WindowAddAnchor( sectionWindowName, anchorPoint, anchorToWindow, anchorToPoint, 0, ySpacing )
        anchorToWindow = sectionWindowName
        anchorPoint = "bottom"
        ySpacing = SUB_SECTION_SPACING

        
        LabelSetText( sectionWindowName, wstring.upper( sectionData.name )  )
        

        
        for subSectionIndex, subSectionData in ipairs( sectionData.subsections )
        do
            -- Build the Names & Title Text
            local namesText = L""
            local titlesText = L""

            for _, personData in ipairs( subSectionData.people )
            do
                namesText = namesText..L"\n"..personData.name
                
                if( personData.title )
                then
                    titlesText = titlesText..L"\n"..personData.title                    
                end           
        
            end
    
            -- Create the Sub Section Window
            local subSectionWindowName = sectionWindowName.."SubSection"..subSectionIndex         
            if( titlesText ~= L"" )
            then         
                CreateWindowFromTemplate( subSectionWindowName, "EA_Credits_SubSectionWithTitlesTemplate", parentWindow )                    
                LabelSetText( subSectionWindowName.."PeopleNames", namesText )
                LabelSetText( subSectionWindowName.."PeopleTitles", titlesText )
            else                  
                CreateWindowFromTemplate( subSectionWindowName, "EA_Credits_SubSectionWithoutTitlesTemplate", parentWindow )                    
                LabelSetText( subSectionWindowName.."PeopleNames", namesText )
            end
            
            WindowAddAnchor( subSectionWindowName, anchorPoint, anchorToWindow, anchorToPoint, 0, ySpacing )
            anchorToWindow = subSectionWindowName
            ySpacing = SUB_SECTION_SPACING
            
            local subSectionHeight = 0
            
            LabelSetText( subSectionWindowName.."Name", subSectionData.name )
            LabelSetText( subSectionWindowName.."Desc", subSectionData.desc )
            
            -- Size the Window
            local x, y = LabelGetTextDimensions( subSectionWindowName.."Name" )
            subSectionHeight = subSectionHeight + y
            if( y ~= 0 )
            then
                subSectionHeight = subSectionHeight + TEXT_SPACING
            end
            
            local x, y = LabelGetTextDimensions( subSectionWindowName.."Desc" )
            subSectionHeight = subSectionHeight + y                
            
            local x, y = LabelGetTextDimensions( subSectionWindowName.."PeopleNames" )
            subSectionHeight = subSectionHeight + y           
            
            local width, height = WindowGetDimensions( subSectionWindowName )
            WindowSetDimensions( subSectionWindowName, width, subSectionHeight ) 
                        
        end
        
        
        ySpacing = SECTION_SPACING
    
    end
    
    -- Set the Thank You Text
    local thankYouWindow = parentWindow.."ThankYouText"
    LabelSetText( thankYouWindow, GetPregameString( StringTables.Pregame.TEXT_CREDITS_THANK_YOU))
    WindowAddAnchor( thankYouWindow, anchorPoint, anchorToWindow, anchorToPoint, 0, ySpacing )

    ScrollWindowUpdateScrollRect( "EA_Window_CreditsScrollWindow" )
end

function EA_Window_Credits.Show()
    if ( DoesWindowExist( "EA_Window_Credits" ) )
    then
        WindowSetShowing("EA_Window_Credits", true)
    else
        CreateWindow( "EA_Window_Credits", true )
    end
end

function EA_Window_Credits.Hide()
    WindowSetShowing( "EA_Window_Credits", false )
end

function EA_Window_Credits.ToggleShowing()
    if ( DoesWindowExist("EA_Window_Credits") and WindowGetShowing("EA_Window_Credits") )
    then
        EA_Window_Credits.Hide()
    else
        EA_Window_Credits.Show()
    end
end