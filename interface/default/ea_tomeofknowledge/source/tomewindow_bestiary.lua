----------------------------------------------------------------
-- TomeWindow - WarJournal Implementation
--
--  This file contains all of the initialization and callack
--  functions for the WarJournal section of the Tome of Knowledge.
-- 
----------------------------------------------------------------


-- Constants

-- Variables
TomeWindow.Bestiary = {} 
TomeWindow.Bestiary.TOCData = nil    
TomeWindow.Bestiary.CurSubTypeData = nil
TomeWindow.Bestiary.CurSpeciesData = nil
TomeWindow.Bestiary.typeTOCWindowCount = 0
TomeWindow.Bestiary.subTypeTOCWindowCount = 0
TomeWindow.Bestiary.speciesTOCWindowCount = 0
TomeWindow.Bestiary.speciesTaskWindowCount = 0


TomeWindow.Bestiary.MIN_FRAME_HEIGHT = 75

----------------------------------------------------------------
-- Bestiary Functions
----------------------------------------------------------------

function TomeWindow.InitializeBestiary()

    -- Init the variables
    TomeWindow.Bestiary.typeTOCWindowCount = 0
    TomeWindow.Bestiary.subTypeTOCWindowCount = 0
    TomeWindow.Bestiary.speciesTOCWindowCount = 0
    TomeWindow.Bestiary.speciesTaskWindowCount = 0

  -- > Initialize the PageData
    
    -- Bestiary TOC
    TomeWindow.Pages[ TomeWindow.PAGE_BESTIARY_TOC ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_BESTIARY,
                    "BestiaryTOC", 
                    TomeWindow.OnShowBestiaryTOC,
                    TomeWindow.OnBestiaryTOCUpdateNavButtons,
                    TomeWindow.OnBestiaryTOCPreviousPage,
                    TomeWindow.OnBestiaryTOCNextPage,
                    TomeWindow.OnBestiaryTOCMouseOverPreviousPage,
                    TomeWindow.OnBestiaryTOCMouseOverNextPage )                   
                   
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_BESTIARY_TOC,
                                  GetString( StringTables.Default.LABEL_BESTIARY ), 
                                  L"" )
                
    -- Bestiary SubType Info              
    TomeWindow.Pages[ TomeWindow.PAGE_BESTIARY_SUBTYPE_INFO ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_BESTIARY,
                    "BestiarySubTypeInfo", 
                    TomeWindow.ShowBestiarySubType,
                    TomeWindow.OnBestiarySubTypeInfoUpdateNavButtons,
                    TomeWindow.OnBestiarySubTypeInfoPreviousPage,
                    TomeWindow.OnBestiarySubTypeInfoNextPage,
                    TomeWindow.OnBestiarySubTypeInfoMouseOverPreviousPage,
                    TomeWindow.OnBestiarySubTypeInfoMouseOverNextPage )
                    
    -- Bestiary Species Info              
    TomeWindow.Pages[ TomeWindow.PAGE_BESTIARY_SPECIES_INFO ]
        = TomeWindow.NewPageData( TomeWindow.Sections.SECTION_BESTIARY,
                    "BestiarySpeciesInfo", 
                    TomeWindow.ShowBestiarySpecies,
                    TomeWindow.OnBestiarySpeciesInfoUpdateNavButtons,
                    TomeWindow.OnBestiarySpeciesInfoPreviousPage,
                    TomeWindow.OnBestiarySpeciesInfoNextPage,
                    TomeWindow.OnBestiarySpeciesInfoMouseOverPreviousPage,
                    TomeWindow.OnBestiarySpeciesInfoMouseOverNextPage )
                    

    -- Bestiary
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_BESTIARY_TOC_UPDATED, "TomeWindow.OnBestiaryTOCUpdated")
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_BESTIARY_SUBTYPE_UPDATED, "TomeWindow.OnBestiarySubTypeUpdated")  
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_BESTIARY_SUBTYPE_KILL_COUNT_UPDATED, "TomeWindow.OnBestiarySubTypeKillCountUpdated")  
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_BESTIARY_SPECIES_UPDATED, "TomeWindow.OnBestiarySpeciesUpdated") 
    WindowRegisterEventHandler( "TomeWindow", SystemData.Events.TOME_BESTIARY_SPECIES_KILL_COUNT_UPDATED, "TomeWindow.OnBestiarySpeciesKillCountUpdated")   

    -- TOC
    LabelSetText("BestiarySectionTitle", wstring.upper( GetString( StringTables.Default.LABEL_BESTIARY ) ) )
    
    -- Sub Type           
    LabelSetText("BestiarySubTypeListHeaderText", GetString( StringTables.Default.LABEL_SPECIES ))
    LabelSetText("BestiarySubTypeListHeaderKills", GetString( StringTables.Default.LABEL_KILLS ))
    PageWindowAddPageBreak( "BestiarySubTypeInfoPageWindow", "BestiarySubTypeListHeader" )
    
    -- Species    
    LabelSetText( "BestiarySpeciesInfoTaskLabel", GetString( StringTables.Default.LABEL_TASK ))
    LabelSetText( "BestiarySpeciesInfoRewardsLabel", GetString( StringTables.Default.LABEL_REWARDS ))
    PageWindowAddPageBreak( "BestiarySpeciesInfoPageWindow", "BestiarySpeciesInfoText2" )
    
    
    

    -- Inits
    TomeWindow.UpdateBestiaryTOC() 
end

function TomeWindow.OnBestiaryTOCUpdated()
    TomeWindow.UpdateBestiaryTOC()
    
    if( TomeWindow.Bestiary.CurSubTypeData ) then
       TomeWindow.UpdateActiveBestiarySubType( TomeWindow.Bestiary.CurSubTypeData.id  )
    end
    
    if( TomeWindow.Bestiary.CurSpeciesData ) then
       TomeWindow.UpdateBestiarySpecies( TomeWindow.Bestiary.CurSpeciesData.id  )
    end
end

-- Bestiary Functions
function TomeWindow.UpdateBestiaryTOC()

    TomeWindow.Bestiary.TOCData = TomeGetBestiaryTOC()    
    if( TomeWindow.Bestiary.TOCData == nil ) then
        ERROR(L"BestiaryTOC is nil")
        return
    end

    -- Sort the BeatiaryTypes List alphabetically
    table.sort( TomeWindow.Bestiary.TOCData, DataUtils.AlphabetizeByNames )
    
    -- Sort the BeatiarySubTypes List alphabetically
    for typeIndex, typeData in ipairs( TomeWindow.Bestiary.TOCData ) do                              
        table.sort( typeData.subtypes, DataUtils.AlphabetizeByNames )
    end
    
    
    local parentWindow = "BestiaryTOCPageWindowContentsChild"     
    local anchorWindow = "BestiaryTOCPageWindowContentsChildTOCAnchor"
    local xOffset = 0
    local yOffset = 0
    
    local subTypeCount = 0
        
    -- Loop through all of the Beast Types
    for typeIndex, typeData in ipairs( TomeWindow.Bestiary.TOCData ) do
                
        -- Create the type window if necessary
        local typeWindowName = "BestiaryTypeHeading"..typeIndex
        if( TomeWindow.Bestiary.typeTOCWindowCount < typeIndex ) then
        
            CreateWindowFromTemplate( typeWindowName, "BestiaryTypeHeading", parentWindow )
        
            WindowAddAnchor( typeWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )        
            anchorWindow = typeWindowName     
            
            if( typeIndex == 1 ) then                
                LabelSetText( typeWindowName.."Kills", GetString( StringTables.Default.LABEL_KILLS ) )
            end
            
            TomeWindow.Bestiary.typeTOCWindowCount = TomeWindow.Bestiary.typeTOCWindowCount + 1
        end
        
        -- Set the Id
        WindowSetId( typeWindowName, typeData.id )         
        
        -- Set the Text        
        LabelSetText( typeWindowName.."Text", typeData.name )
        local textWidth, textHeight = WindowGetDimensions( typeWindowName.."Text" )
        local width, height = WindowGetDimensions( typeWindowName )
        WindowSetDimensions( typeWindowName, width, textHeight )
        
        
    
        xOffset = 10
        yOffset = 0
        
        for subTypeIndex, subTypeData in ipairs( typeData.subtypes ) do                               
                        
            subTypeCount = subTypeCount + 1
                        
            -- Create the sub type window if necessary
            local subTypeWindowName = "BestiarySubTypeTOCItem"..subTypeCount
            if( TomeWindow.Bestiary.subTypeTOCWindowCount < subTypeCount ) then
            
                CreateWindowFromTemplate( subTypeWindowName, "BestiarySubTypeTOCItem", parentWindow )                         
                
                WindowAddAnchor( subTypeWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )             
                anchorWindow = subTypeWindowName 
                
                TomeWindow.Bestiary.subTypeTOCWindowCount = TomeWindow.Bestiary.subTypeTOCWindowCount + 1
            end
            
            -- Set the name and kill count
            local killText = L""..subTypeData.killCount
            TomeWindow.SetTOCItemText( subTypeWindowName, subTypeData.id, subTypeData.name, killText )
            
            -- Disable The Highlight if the subtype is locked
            ButtonSetDisabledFlag( subTypeWindowName.."Text", subTypeData.isUnlocked == false )    
            
                        
            xOffset = 0
            yOffset = 0
            
        end    
        
        if( typeData.subtypes[1] ) then        
            xOffset = -10 
        else
            xOffset = 0
        end           
        yOffset = 15            
    
    end
    
    -- Show/Hide the appropriate number of subtype windows.
    for index = 1, TomeWindow.Bestiary.subTypeTOCWindowCount do
        local show = index <= subTypeCount
        local windowName = "BestiarySubTypeTOCItem"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
    end
    
    PageWindowUpdatePages( "BestiaryTOCPageWindow" )
    PageWindowSetCurrentPage( "BestiaryTOCPageWindow", 1 )
    TomeWindow.OnBestiaryTOCUpdateNavButtons()

end


function TomeWindow.OnSelectBestiarySubType()
    local id = WindowGetId( SystemData.ActiveWindow.name )
    TomeWindow.ShowBestiarySubType( id )
end

function TomeWindow.ShowBestiarySubType( id ) 

    -- Is the subtype unlocked?
    if( TomeIsBestiarySubTypeUnlocked(id) ~= true ) then
        return
    end


    TomeWindow.UpdateActiveBestiarySubType( id )

    local params = { id }
    TomeWindow.SetState( TomeWindow.PAGE_BESTIARY_SUBTYPE_INFO, params )
    --TomeWindow.OnViewEntry( GameData.Tome.SECTION_BESTIARY, GameData.Tome.Bestiary.CurrentEntry.id )    

end
    
function TomeWindow.UpdateActiveBestiarySubType( id )
    
    TomeWindow.Bestiary.CurSubTypeData = TomeGetBestiarySubTypeData( id ) 
    
    -- Sort the species List alphabetically
    table.sort( TomeWindow.Bestiary.CurSubTypeData.species, DataUtils.AlphabetizeByNames )    
    
    local subTypeData = TomeWindow.Bestiary.CurSubTypeData
    
    -- Set the Name
    LabelSetText("BestiarySubTypeInfoName", wstring.upper( subTypeData.name ) )
    
    -- Set the KillCount        
    local killText = GetStringFormat( StringTables.Default.TEXT_KILL_COUNT, { subTypeData.killCount } )
    LabelSetText("BestiarySubTypeInfoKillText", killText )
    
    -- Set the Desc
    LabelSetText("BestiarySubTypeInfoText", subTypeData.desc )
    
    local parentWindow = "BestiarySubTypeInfoPageWindowContentsChild"
    local anchorWindow = "BestiarySubTypeInfoPageWindowContentsChildTOCAnchor"
    local xOffset = 10
    local yOffset = 0
    
    -- Set the Species, creating window as necessary
    local speciesIndex = 0
    for index, speciesData in ipairs( subTypeData.species ) do                               
        
        speciesIndex = speciesIndex + 1
                
        -- Create the sub type window if necessary
        local speciesWindowName = "BestiarySpeciesTOCItem"..speciesIndex
        if( TomeWindow.Bestiary.speciesTOCWindowCount < speciesIndex ) then
        
            CreateWindowFromTemplate( speciesWindowName, "BestiarySpeciesTOCItem", parentWindow )                         
            
            WindowAddAnchor( speciesWindowName, "bottom", anchorWindow, "top", xOffset, yOffset )             
            
            ButtonSetStayDownFlag( speciesWindowName.."CompletedBtn", true )
            ButtonSetDisabledFlag( speciesWindowName.."CompletedBtn", true )
           
            TomeWindow.Bestiary.speciesTOCWindowCount = TomeWindow.Bestiary.speciesTOCWindowCount + 1
        end
        
        
        -- Set the name, id,  and kill count
        local killText = L""..speciesData.killCount
        TomeWindow.SetTOCItemText( speciesWindowName, speciesData.id, speciesData.name, killText )
                     
        
        -- Disable The Highlight if the species is locked
        ButtonSetDisabledFlag( speciesWindowName.."Text", speciesData.isUnlocked == false )    
        
        -- Set the Completed Button
        ButtonSetPressedFlag( speciesWindowName.."CompletedBtn", speciesData.isUnlocked )
        
        anchorWindow = speciesWindowName 
        xOffset = 0
        yOffset = 0           
    end
    
    -- Show/Hide the appropriate number of species windows.
    for index = 1, TomeWindow.Bestiary.speciesTOCWindowCount do
        local show = index <= speciesIndex
        local windowName = "BestiarySpeciesTOCItem"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
    end
    
    
    PageWindowUpdatePages( "BestiarySubTypeInfoPageWindow" )    
    PageWindowSetCurrentPage( "BestiarySubTypeInfoPageWindow", 1 )
    
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_BESTIARY_SUBTYPE_INFO,
                                  GetString( StringTables.Default.LABEL_BESTIARY ), 
                                  subTypeData.name )
    
end

function TomeWindow.OnBestiarySubTypeUpdated()
    
    if( TomeWindow.Bestiary.CurSubTypeData ) then
        if( GameData.Bestiary.updatedSubType == TomeWindow.Bestiary.CurSubTypeData.id ) then
            TomeWindow.UpdateActiveBestiarySubType( TomeWindow.Bestiary.CurSubTypeData.id  )
        end  
    end 
    
end

function TomeWindow.OnBestiarySubTypeKillCountUpdated()
    
    -- If this sub type is currently displayed, update the sub type data.
    if( TomeWindow.Bestiary.CurSubTypeData ) then
        if( GameData.Bestiary.updatedSubType == TomeWindow.Bestiary.CurSubTypeData.id ) then
        
            TomeWindow.Bestiary.CurSubTypeData.killCount = GameData.Bestiary.updatedKillCount
            
            local killText = GetStringFormat( StringTables.Default.TEXT_KILL_COUNT, { TomeWindow.Bestiary.CurSubTypeData.killCount } )
            LabelSetText("BestiarySubTypeInfoKillText", killText )
            
        end 
    end  
    
    -- Update the KillCount on the TOC page.                
    local subTypeCount = 0        
    for typeIndex, typeData in ipairs( TomeWindow.Bestiary.TOCData ) do
        
        local typeWindowName = "BestiaryTypeHeading"..typeIndex
        
        
        for subTypeIndex, subTypeData in ipairs( typeData.subtypes ) do                               
                        
            subTypeCount = subTypeCount + 1
            
            if( subTypeData.id == GameData.Bestiary.updatedSubType ) then
            
                subTypeData.killCount = GameData.Bestiary.updatedKillCount            
            
                local subTypeWindowName = "BestiarySubTypeTOCItem"..subTypeCount
            
                -- Set the name, id,  and kill count
                local killText = L""..subTypeData.killCount
                TomeWindow.SetTOCItemText( subTypeWindowName, subTypeData.id, subTypeData.name, killText )
                     
   
            end
        end
    end                
           
end

function TomeWindow.OnSelectBestiarySpecies()
    local id = WindowGetId( SystemData.ActiveWindow.name )
    
    -- Is the species unlocked?
    if( TomeIsBestiarySpeciesUnlocked(id) ~= true ) then
        return
    end
    local params = { id }
    TomeWindow.SetState( TomeWindow.PAGE_BESTIARY_SPECIES_INFO, params )
end

function TomeWindow.ShowBestiarySpecies( id )
    -- Is the species unlocked?
    if( TomeIsBestiarySpeciesUnlocked(id) ~= true ) then
        return
    end

    TomeWindow.UpdateBestiarySpecies( id )
    TomeWindow.OnViewEntry( GameData.Tome.SECTION_BESTIARY, id )
end

function TomeWindow.UpdateBestiarySpecies( id ) 
    TomeWindow.Bestiary.CurSpeciesData  = TomeGetBestiarySpeciesData( id ) 
    local data = TomeWindow.Bestiary.CurSpeciesData        

    -- Set the Name
    LabelSetText( "BestiarySpeciesInfoName",  wstring.upper( data.name ) )
    
    -- Set the Image
    TomeSetBestiarySpeciesImage( id )    
    
    -- Set the KillCount        
    local killText = GetStringFormat( StringTables.Default.TEXT_KILL_COUNT, { data.killCount } )
    LabelSetText("BestiarySpeciesInfoKillText", killText )
    
    LabelSetText( "BestiarySpeciesInfoText1",  data.text1 )
    LabelSetText( "BestiarySpeciesInfoText2",  data.text2 )
    LabelSetText( "BestiarySpeciesInfoText3",  data.text3 )
    
    local showLore = data.text2 ~= nil and data.text2 ~= L""
    WindowSetShowing( "BestiarySpeciesInfoText2", showLore )
    showLore = data.text3 ~= nil and data.text3 ~= L""
    WindowSetShowing( "BestiarySpeciesInfoText3", showLore )
   
    -- Anchor the text based on if the entry has an image or not
    WindowClearAnchors( "BestiarySpeciesInfoText1" ) 
    if( DynamicImageHasTexture( "BestiarySpeciesInfoImage" ) ) then
       WindowAddAnchor( "BestiarySpeciesInfoText1", "bottom", "BestiarySpeciesInfoImage", "top", 0, 10 ) 
    else
       WindowAddAnchor( "BestiarySpeciesInfoText1", "top", "BestiarySpeciesInfoImage", "top", 0, 0 )
    end
    
    -- Rewards....
    local parentWindow = "BestiarySpeciesInfoPageWindowContentsChild"
    local anchorWindow = "BestiarySpeciesTaskAnchor"
    local xOffset = 0
    local yOffset = 30
    
    local frameHeight = TomeWindow.Bestiary.MIN_FRAME_HEIGHT
    
    -- Set the Tasks, creating window as necessary
    local taskIndex = 0
    for index, taskData in ipairs( data.tasks ) do                               
    
        taskIndex = taskIndex + 1
                
        -- Create the sub type window if necessary
        local taskWindowName = "BestiarySpeciesInfoTaskItem"..taskIndex
        if( TomeWindow.Bestiary.speciesTaskWindowCount < taskIndex ) then
        
            CreateWindowFromTemplate( taskWindowName, "BestiarySpeciesTaskWindow", parentWindow )                         
            
            WindowAddAnchor( taskWindowName, "bottomleft", anchorWindow, "topleft", xOffset, yOffset )             
           
            ButtonSetStayDownFlag( taskWindowName.."CompletedBtn", true )
            ButtonSetDisabledFlag( taskWindowName.."CompletedBtn", true )
           
            TomeWindow.Bestiary.speciesTaskWindowCount = TomeWindow.Bestiary.speciesTaskWindowCount + 1
        end
        
        -- Set the Id
        WindowSetId( taskWindowName, taskIndex )   
        
        -- Set the Completed Button
        ButtonSetPressedFlag( taskWindowName.."CompletedBtn", taskData.isComplete )
                    
        -- Set Task
        LabelSetText( taskWindowName.."Text", taskData.text )
        local taskIndexWidth, taskHeight = WindowGetDimensions( taskWindowName.."Text" )
        
        -- Set The Rewards        
        TomeWindow.SetTomeReward( taskWindowName.."Reward1", taskData.rewards[1] )
        TomeWindow.SetTomeReward( taskWindowName.."Reward2", taskData.rewards[2] )
        
        -- Anchor card to left most reward
        anchorCardTo = taskWindowName.."Reward1"
        if( taskData.rewards[2] and taskData.rewards[2].rewardId ~= 0 )
        then
            anchorCardTo = taskWindowName.."Reward2"
        end
        WindowClearAnchors( taskWindowName.."Card" )
        WindowAddAnchor( taskWindowName.."Card", "topleft", anchorCardTo, "topright", 0, 0 )
        
        -- Set the card if there is one
        local cardData = nil
        if( taskData.cardId and taskData.cardId ~= 0 )
        then
            cardData = TomeGetCardData( taskData.cardId )
        end
        TomeWindow.SetCard( taskWindowName.."Card", cardData )
        
        
        -- Resize....        
        local MIN_HEIGHT = 50
        local OFFSET = 10
        local width, height = WindowGetDimensions( taskWindowName )
        if( taskHeight + OFFSET > height ) then height = taskHeight + OFFSET end
        if( MIN_HEIGHT > height ) then height = MIN_HEIGHT end
        WindowSetDimensions( taskWindowName, width, height )    
        
        frameHeight = frameHeight + height
               
        anchorWindow = taskWindowName      
        xOffset = 0
        yOffset = 3       
    end
   
    -- Show/Hide the appropriate number of reward windows.
    for index = 1, TomeWindow.Bestiary.speciesTaskWindowCount do
        local show = index <= taskIndex
       
        
        local windowName = "BestiarySpeciesInfoTaskItem"..index
        if( WindowGetShowing(windowName ) ~= show ) then
            WindowSetShowing(windowName, show ) 
        end
    end
    
    -- Anchor the lore text
    WindowClearAnchors( "BestiarySpeciesInfoText2" )
    WindowAddAnchor( "BestiarySpeciesInfoText2", "bottom", anchorWindow, "top", 0, 0 )
    
    WindowSetShowing( "BestiarySpeciesDivider", true )
    
    PageWindowRemovePageBreak( "BestiarySpeciesInfoPageWindow", "BestiarySpeciesTaskAnchor" )
    PageWindowUpdatePages( "BestiarySpeciesInfoPageWindow" )
    
    if( not DoesWindowExist( "BestiarySpeciesInfoText1_pgbrk" ) )
    then
        WindowSetShowing( "BestiarySpeciesDivider", false )
        PageWindowAddPageBreak( "BestiarySpeciesInfoPageWindow", "BestiarySpeciesTaskAnchor" )
        PageWindowUpdatePages( "BestiarySpeciesInfoPageWindow" )
    end
    
    PageWindowSetCurrentPage( "BestiarySpeciesInfoPageWindow", 1 )
    
    
    TomeWindow.OnBestiarySpeciesInfoUpdateNavButtons()

 
    TomeWindow.SetPageHeaderText( TomeWindow.PAGE_BESTIARY_SPECIES_INFO,
                                  GetString( StringTables.Default.LABEL_BESTIARY ), 
                                  data.name )
end

function TomeWindow.OnBestiarySpeciesUpdated()   
    if( TomeWindow.Bestiary.CurSpeciesData ) then
        if( GameData.Bestiary.updatedSpecies == TomeWindow.Bestiary.CurSpeciesData.id ) then
            TomeWindow.UpdateBestiarySpecies( TomeWindow.Bestiary.CurSpeciesData.id  )
        end
    end
end

function TomeWindow.OnBestiarySpeciesKillCountUpdated()
    
    -- If this species is currently displayed, update the cur species data
    if( TomeWindow.Bestiary.CurSpeciesData ) then
        if( GameData.Bestiary.updatedSpecies == TomeWindow.Bestiary.CurSpeciesData.id ) then
        
            TomeWindow.Bestiary.CurSpeciesData.killCount = GameData.Bestiary.updatedKillCount
            
            local killText = GetStringFormat( StringTables.Default.TEXT_KILL_COUNT, { TomeWindow.Bestiary.CurSpeciesData.killCount } )
            LabelSetText("BestiarySpeciesInfoKillText", killText )        
        end    
    end
    
    -- Update the KillCount on the TOC page.      
    if( TomeWindow.Bestiary.CurSubTypeData ~= nil ) then          
        local speciesCount = 0        
        for speciesIndex, speciesData in ipairs( TomeWindow.Bestiary.CurSubTypeData.species ) do
                                          
            speciesCount = speciesCount + 1
            
            if( speciesData.id == GameData.Bestiary.updatedSpecies ) then
            
                speciesData.killCount = GameData.Bestiary.updatedKillCount            
            
                local speciesWindowName = "BestiarySpeciesTOCItem"..speciesIndex
            
                -- Set the name, id,  and kill count
                local killText = L""..speciesData.killCount
                TomeWindow.SetTOCItemText( speciesWindowName, speciesData.id, speciesData.name, killText )                    

            end
            
        end      
    end
end

function TomeWindow.OnMouseOverBestiarySpeciesReward()

    local taskIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local rewardIndex = WindowGetId(  SystemData.ActiveWindow.name )

    local rewardData = TomeWindow.Bestiary.CurSpeciesData.tasks[taskIndex].rewards[rewardIndex]
    local isComplete = TomeWindow.Bestiary.CurSpeciesData.tasks[taskIndex].isComplete
    TomeWindow.OnMouseOverTomeReward( SystemData.ActiveWindow.name, rewardData, isComplete )
end

function TomeWindow.OnClickBestiarySpeciesReward()
    
    local taskIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local rewardIndex = WindowGetId(  SystemData.ActiveWindow.name )
   
    local rewardData = TomeWindow.Bestiary.CurSpeciesData.tasks[taskIndex].rewards[rewardIndex]
    TomeWindow.OnClickTomeReward( rewardData )
end

function TomeWindow.OnClickBestiarySpeciesCard()

    local cardId = WindowGetId( SystemData.ActiveWindow.name )
    local cardData = TomeGetCardData( cardId )
    TomeWindow.OnClickTomeCard( cardData )
end

function TomeWindow.OnMouseOverBestiarySpeciesCard()
    
    local cardId = WindowGetId( SystemData.ActiveWindow.name )
    local cardData = TomeGetCardData( cardId )
    TomeWindow.OnMouseOverTomeCard( SystemData.ActiveWindow.name, cardData, StringTables.Default.TEXT_CLICK_CARD_LINK, Tooltips.ANCHOR_WINDOW_RIGHT )

end

function TomeWindow.OnMouseOverBestiaryTaskEntry()
    local taskIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local entryData = TomeWindow.Bestiary.CurSpeciesData.tasks[taskIndex]
    
    if( not entryData.desc or entryData.desc == L"" )
    then
        return
    end
    
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, entryData.desc )
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function TomeWindow.OnRightClickBestiaryTaskEntry()
    local taskIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local entryData = TomeWindow.Bestiary.CurSpeciesData.tasks[taskIndex]
    
    TomeWindow.OpenBraggingRightsContextMenu( entryData.unlockEventId )
end

-- > Bestiary TOC Nav Buttons
function TomeWindow.OnBestiaryTOCUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_BESTIARY_TOC ) then
        return
    end
    local curPage   = PageWindowGetCurrentPage("BestiaryTOCPageWindow")
    local numPages  = PageWindowGetNumPages("BestiaryTOCPageWindow")
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )
end

function TomeWindow.OnBestiaryTOCPreviousPage()
    TomeWindow.FlipPageWindowBackward( "BestiaryTOCPageWindow")
end

function TomeWindow.OnBestiaryTOCMouseOverPreviousPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("BestiaryTOCPageWindow")
    local numPages  = PageWindowGetNumPages("BestiaryTOCPageWindow")
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = GetString( StringTables.Default.TEXT_BESTIARY_TOC )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnBestiaryTOCNextPage()
    TomeWindow.FlipPageWindowForward( "BestiaryTOCPageWindow")
end

function TomeWindow.OnBestiaryTOCMouseOverNextPage()    
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("BestiaryTOCPageWindow")
    local numPages  = PageWindowGetNumPages("BestiaryTOCPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = GetString( StringTables.Default.TEXT_BESTIARY_TOC )
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end


-- > Noteworthy Persons Info Nav Buttons
function TomeWindow.OnBestiarySpeciesInfoUpdateNavButtons()
    if ( TomeWindow.GetCurrentState() ~= TomeWindow.PAGE_BESTIARY_SPECIES_INFO ) then
        return
    end
    local curPage   = PageWindowGetCurrentPage("BestiarySpeciesInfoPageWindow")
    local numPages  = PageWindowGetNumPages("BestiarySpeciesInfoPageWindow")
    WindowSetShowing( "TomeWindowPreviousPageButton", curPage > 1 )
    WindowSetShowing( "TomeWindowNextPageButton", curPage + 2 <= numPages )
end

function TomeWindow.OnBestiarySpeciesInfoPreviousPage()
    TomeWindow.FlipPageWindowBackward( "BestiarySpeciesInfoPageWindow")
end

function TomeWindow.OnBestiarySpeciesInfoMouseOverPreviousPage()   
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("BestiarySpeciesInfoPageWindow")
    local numPages  = PageWindowGetNumPages("BestiarySpeciesInfoPageWindow")
    if( curPage > 1 ) then
        -- Previous Pages
        lines[1] = TomeWindow.Bestiary.CurSpeciesData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateBackButtonTooltip( lines )
end

function TomeWindow.OnBestiarySpeciesInfoNextPage()
    TomeWindow.FlipPageWindowForward( "BestiarySpeciesInfoPageWindow")
end

function TomeWindow.OnBestiarySpeciesInfoMouseOverNextPage()   
    local lines = {}    
    local curPage   = PageWindowGetCurrentPage("BestiarySpeciesInfoPageWindow")
    local numPages  = PageWindowGetNumPages("BestiarySpeciesInfoPageWindow")
    if( curPage + 2 <= numPages ) then
        -- Next Pages
        lines[1] = TomeWindow.Bestiary.CurSpeciesData.name
        lines[2] = GetString( StringTables.Default.TEXT_CONTINUED )
    end 
    TomeWindow.CreateNextButtonTooltip( lines )
end