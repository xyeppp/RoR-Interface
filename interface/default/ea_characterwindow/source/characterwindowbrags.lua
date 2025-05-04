CharacterWindow.braggingRights = nil


-- BRAGGING RIGHTS FUNCTIONS
function CharacterWindow.BraggingRightsUpdated()
    CharacterWindow.braggingRights = GetBraggingRights()
    
    for index, brag in ipairs( CharacterWindow.braggingRights )
    do
        local windowName = "CharacterWindowBragsEntry"..index
        local anchorWindow = "CharacterWindowBragsEntry"..index-1
        if( index <= 1 )
        then
            anchorWindow = "CharacterWindowBragsAnchor"
        end
    
        -- create a window for this brag if it doesn't exist
        if( not DoesWindowExist( windowName ) )
        then
            CreateWindowFromTemplate( windowName, "BraggingRightTemplate", "CharacterWindowBrags" )
            WindowAddAnchor( windowName, "bottom", anchorWindow, "top", 0, 0 )
        end
        
        WindowSetId( windowName, index )
        
        LabelSetText( windowName.."Text", brag.name )

        -- set the reward data
        if( not brag.rewards )
        then
            WindowSetShowing( windowName.."Reward1", false )
            WindowSetShowing( windowName.."Reward2", false )
        else
            TomeWindow.SetTomeReward( windowName.."Reward1", brag.rewards[1] )
            TomeWindow.SetTomeReward( windowName.."Reward2", brag.rewards[2] )
            
            -- Anchor card to left most reward
            anchorCardTo = windowName.."Reward1"
            if( brag.rewards[2] and brag.rewards[2].rewardId ~= 0 )
            then
                anchorCardTo = windowName.."Reward2"
            end
            WindowClearAnchors( windowName.."Card" )
            WindowAddAnchor( windowName.."Card", "topleft", anchorCardTo, "topright", 0, 0 )
        end
        
        -- Set the card if there is one
        local cardData = nil
        if( brag.cardId and brag.cardId ~= 0 )
        then
            cardData = TomeGetCardData( brag.cardId )
        end
        TomeWindow.SetCard( windowName.."Card", cardData )
    end
    
end

function CharacterWindow.RemoveBrag()
    local bragIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )

    SetBraggingRight( bragIndex, 0 )
end

function CharacterWindow.OnClickReward()
    local bragIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local rewardIndex = WindowGetId(  SystemData.ActiveWindow.name )

    local rewardData = CharacterWindow.braggingRights[bragIndex].rewards[rewardIndex]
    TomeWindow.OnClickTomeReward( rewardData )
end

function CharacterWindow.OnMouseOverReward()
    local bragIndex = WindowGetId( WindowGetParent( SystemData.ActiveWindow.name ) )
    local rewardIndex = WindowGetId(  SystemData.ActiveWindow.name )

    local rewardData = CharacterWindow.braggingRights[bragIndex].rewards[rewardIndex]
    TomeWindow.OnMouseOverTomeReward( SystemData.ActiveWindow.name, rewardData )
end

function CharacterWindow.OnClickCard()
    local cardId = WindowGetId( SystemData.ActiveWindow.name )
    
    local cardData = TomeGetCardData( cardId )
    TomeWindow.OnClickTomeCard( cardData )
end

function CharacterWindow.OnMouseOverCard()
    local cardId = WindowGetId( SystemData.ActiveWindow.name )
    
    local cardData = TomeGetCardData( cardId )
    TomeWindow.OnMouseOverTomeCard( SystemData.ActiveWindow.name, cardData, StringTables.Default.TEXT_CLICK_CARD_LINK, Tooltips.ANCHOR_WINDOW_RIGHT )
end

function CharacterWindow.OnTabSelectChar()
    CharacterWindow.UpdateMode( CharacterWindow.MODE_NORMAL )
end

function CharacterWindow.OnTabSelectBrags()
    CharacterWindow.UpdateMode( CharacterWindow.MODE_BRAGS )
end

function CharacterWindow.OnTabSelectTimeouts()
    CharacterWindow.UpdateMode( CharacterWindow.MODE_TIMEOUTS )
end

