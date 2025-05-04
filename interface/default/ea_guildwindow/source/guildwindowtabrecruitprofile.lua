
--------------------------------------------------------------------------------------
-- Guild Profile
--------------------------------------------------------------------------------------

GuildWindowTabRecruit.Profile = 
{
    Careers = {},
    
    CHECK_BOX_TEMPLATE = "GuildWindowRecruitProfileCheckBoxTemplate",
}

function GuildWindowTabRecruit.InitializeProfile()	
	
	GuildWindowTabRecruit.InitializeProfileRecruitingStatus() 
	    
    LabelSetText( "GWRecruitProfileDescTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_DESC_TITLE ) )
    TextEditBoxSetMaxChars( "GWRecruitProfileDescEditBox", 64 )
    
    LabelSetText( "GWRecruitProfileSummaryTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_SUMMARY_TITLE ) )
    TextEditBoxSetMaxChars( "GWRecruitProfileSummaryEditBox", 500 )
    
    -- Play Style
    LabelSetText( "GWRecruitProfilePlayStyleTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_PLAY_STYLE_TITLE ) )
    for _, playStyleData in ipairs( GuildWindowTabRecruit.PlayStyles )
    do
        ComboBoxAddMenuItem( "GWRecruitProfilePlayStyleCombo", playStyleData.name )
    end
    
    -- Atmosphere
    LabelSetText( "GWRecruitProfileAtmosphereTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_ATMOSPHERE_TITLE ) )
    for _, atmosphereData in ipairs( GuildWindowTabRecruit.Atmosphere )
    do
        ComboBoxAddMenuItem( "GWRecruitProfileAtmosphereCombo", atmosphereData.name )
    end
    
    -- Careers Needed
    LabelSetText( "GWRecruitProfileCareersNeededTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_CAREERS_NEEDED_TITLE ) )
    GuildWindowTabRecruit.InitializeProfileCareers()    
    
    -- Tiers Needed
    LabelSetText( "GWRecruitProfileTiersNeededTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_RANKS_NEEDED_TITLE ) )
    GuildWindowTabRecruit.InitializeProfileTiers()
    
    -- Interests
    LabelSetText( "GWRecruitProfileInterestsTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_INTERESTS_TITLE ) )
    GuildWindowTabRecruit.InitializeProfileInterests()
        
    -- Recruiters    
    LabelSetText( "GWRecruitProfileRecruitersTitle", GetGuildString( StringTables.Guild.LABEL_RECRUIT_PROFILE_RECRUITERS_TITLE ) )
    
    -- Reset Button
    ButtonSetText( "GWRecruitProfileResetButton", GetGuildString( StringTables.Guild.LABEL_RECRUIT_RESET_PROFILE ) )
    ButtonSetDisabledFlag( "GWRecruitProfileResetButton", true )    
    
    -- Save Button
    ButtonSetText( "GWRecruitProfileSaveButton", GetGuildString( StringTables.Guild.LABEL_RECRUIT_SAVE_PROFILE ) )
    ButtonSetDisabledFlag( "GWRecruitProfileSaveButton", true )
    
    -- Setup the Data     
    WindowRegisterEventHandler( "GWRecruitProfile", SystemData.Events.GUILD_RECRUITMENT_PROFILE_UPDATED, "GuildWindowTabRecruit.UpdateProfileData")  
    GuildWindowTabRecruit.UpdateProfileData()
end

function GuildWindowTabRecruit.InitializeProfileRecruitingStatus()
        
    -- Create the Check Boxes for each Status Flag
    local parentWindow = "GWRecruitProfile"
    local anchorWindow = "GWRecruitProfileRecruitingStatusTitle"
    
    local windowNames = {}
    
    for index, statusData in ipairs(GuildWindowTabRecruit.RecruitingStatus)
    do        
        if( statusData.searchOnly == false )
        then
        
            local windowName = parentWindow.."RecruitingStatusCheckBox"..statusData.flagId
            
            CreateWindowFromTemplate( windowName, GuildWindowTabRecruit.Profile.CHECK_BOX_TEMPLATE, parentWindow )
            
            -- Anchor the windows in rows of two vertically.
            if( index ~= 1 and math.mod( index, 2 ) == 1 )
            then        
                WindowAddAnchor( windowName, "topright", windowNames[index-2], "topleft", 0, 0 )
            else
                WindowAddAnchor( windowName, "bottomleft", anchorWindow, "topleft", 0, 0 )
            end
            
            anchorWindow = windowName        
            table.insert( windowNames, windowName )
            
            WindowSetId( windowName, statusData.flagId )
            
            LabelSetText( windowName.."Label", statusData.name )       
       end
            
    end  
end

function GuildWindowTabRecruit.InitializeProfileCareers()

    -- Initializes the List of the Available Careers based on the Player's Realm    
    if( GameData.Player.realm == GameData.Realm.ORDER )
    then
        GuildWindowTabRecruit.Profile.Careers = GuildWindowTabRecruit.OrderCareers
        
    elseif( GameData.Player.realm == GameData.Realm.DESTRUCTION )
    then
        GuildWindowTabRecruit.Profile.Careers = GuildWindowTabRecruit.DestructionCareers
    else
        -- Do nothing if the Player's Realm is Invalid
        return 
    end
    
   
    -- Sort the Careers Alphabetically    
    table.sort( GuildWindowTabRecruit.Profile.Careers, DataUtils.AlphabetizeByNames )  
        
    -- Create the Check Boxes for each Career
    local parentWindow = "GWRecruitProfile"
    local anchorWindow = "GWRecruitProfileCareersNeededTitle"
    
    for _, careerData in ipairs(GuildWindowTabRecruit.Profile.Careers)
    do        
        local windowName = parentWindow.."CareerCheckBox"..careerData.flagId
        
        CreateWindowFromTemplate( windowName, GuildWindowTabRecruit.Profile.CHECK_BOX_TEMPLATE, parentWindow )
        
        WindowAddAnchor( windowName, "bottomleft", anchorWindow, "topleft", 0, 0 )
        anchorWindow = windowName
        
        WindowSetId( windowName, careerData.flagId )
        
        local text = GetCareerLine( careerData.careerLineId )
        LabelSetText( windowName.."Label", text )            
    end  
end


function GuildWindowTabRecruit.InitializeProfileTiers()
        
    -- Create the Check Boxes for each Tier
    local parentWindow = "GWRecruitProfile"
    local anchorWindow = "GWRecruitProfileTiersNeededTitle"
    
    
    for _, tierData in ipairs(GuildWindowTabRecruit.TiersNeeded)
    do        
        local windowName = parentWindow.."TierCheckBox"..tierData.flagId
        
        CreateWindowFromTemplate( windowName, GuildWindowTabRecruit.Profile.CHECK_BOX_TEMPLATE, parentWindow )
        
        WindowAddAnchor( windowName, "bottomleft", anchorWindow, "topleft", 0, 0 )
        anchorWindow = windowName
        
        WindowSetId( windowName, tierData.flagId )
        
        LabelSetText( windowName.."Label", tierData.name )
             
    end  
end

function GuildWindowTabRecruit.InitializeProfileInterests()
        
    -- Create the Check Boxes for each Tier
    local parentWindow = "GWRecruitProfile"
    local anchorWindow = "GWRecruitProfileInterestsTitle"
    
    for _, interestData in ipairs(GuildWindowTabRecruit.Interests)
    do        
        local windowName = parentWindow.."InterestCheckBox"..interestData.flagId
        
        CreateWindowFromTemplate( windowName, GuildWindowTabRecruit.Profile.CHECK_BOX_TEMPLATE, parentWindow )
        
        WindowAddAnchor( windowName, "bottomleft", anchorWindow, "topleft", 0, 0 )
        anchorWindow = windowName
        
        WindowSetId( windowName, interestData.flagId )        
        LabelSetText( windowName.."Label", interestData.name )
         
    end  
end

function GuildWindowTabRecruit.ToggleCheckBox()

    local buttonName = SystemData.ActiveWindow.name.."Button"
    
    if( ButtonGetDisabledFlag( buttonName ) )
    then
        return
    end
    
    local pressed = ButtonGetPressedFlag( buttonName )
    ButtonSetPressedFlag( buttonName, not pressed )
    
    GuildWindowTabRecruit.MarkProfileAsChanged()
end

function GuildWindowTabRecruit.MarkProfileAsChanged()
    ButtonSetDisabledFlag("GWRecruitProfileResetButton", false )
    ButtonSetDisabledFlag("GWRecruitProfileSaveButton", false )
end

function GuildWindowTabRecruit.ResetProfile()

    if( ButtonGetDisabledFlag("GWRecruitProfileResetButton") == true )
    then
        return
    end

    GuildWindowTabRecruit.UpdateProfileData()

    -- Diable the buttons until new changes are made.    
    ButtonSetDisabledFlag("GWRecruitProfileResetButton", true )
    ButtonSetDisabledFlag("GWRecruitProfileSaveButton", true )
end

function GuildWindowTabRecruit.SaveProfile()

    if( ButtonGetDisabledFlag("GWRecruitProfileSaveButton") == true )
    then
        return
    end

    GuildWindowTabRecruit.SaveProfileData()

    -- Diable the buttons until new changes are made.
    ButtonSetDisabledFlag("GWRecruitProfileResetButton", true )
    ButtonSetDisabledFlag("GWRecruitProfileSaveButton", true )
end

function GuildWindowTabRecruit.UpdateProfileData()
    
    local profileData = GuildRecruitmentProfileGetData()
    --DUMP_TABLE(profileData)    
    
    -- Recruitment Status
    local text = GetStringFormatFromTable( "GuildStrings", StringTables.Guild.LABEL_RECRUIT_PROFILE_STATUS_DESC, { GameData.Guild.m_GuildName } )
	LabelSetText("GWRecruitProfileRecruitingStatusTitle", text )	
	
	for _, statusData in ipairs(GuildWindowTabRecruit.RecruitingStatus)
    do        
        if( statusData.searchOnly == false )
        then
        
            local windowName = "GWRecruitProfileRecruitingStatusCheckBox"..statusData.flagId
            
            local pressed = profileData.recruitingStatus[ statusData.flagId ]        
            ButtonSetPressedFlag( windowName.."Button", pressed )    
        end    
    end 
    
    -- Play Style
    for index, data in ipairs( GuildWindowTabRecruit.PlayStyles )
    do
        if( data.flagId == profileData.playStyle )
        then
        
            ComboBoxSetSelectedMenuItem( "GWRecruitProfilePlayStyleCombo", index )
        end
    end
    
    -- Brief Description
    TextEditBoxSetText( "GWRecruitProfileDescEditBox", profileData.desc )
    
    -- Public Summary
    TextEditBoxSetText( "GWRecruitProfileSummaryEditBox", profileData.summary )
    
    -- Play Style
    for index, data in ipairs( GuildWindowTabRecruit.PlayStyles )
    do
        if( data.flagId == profileData.playStyle )
        then
        
            ComboBoxSetSelectedMenuItem( "GWRecruitProfilePlayStyleCombo", index )
        end
    end
    
    -- Atmosphere
    for index, data in ipairs( GuildWindowTabRecruit.Atmosphere )
    do
        if( data.flagId == profileData.atmosphere )
        then
        
            ComboBoxSetSelectedMenuItem( "GWRecruitProfileAtmosphereCombo", index )
        end
    end
    
    -- Careers Needed
    for _, careerData in ipairs(GuildWindowTabRecruit.Profile.Careers)
    do        
        local windowName = "GWRecruitProfileCareerCheckBox"..careerData.flagId
        
        local pressed = profileData.careersNeeded[ careerData.flagId ]        
        ButtonSetPressedFlag( windowName.."Button", pressed )        
    end  
    
    -- Tiers Needed
    for _, tierData in ipairs(GuildWindowTabRecruit.TiersNeeded)
    do        
        local windowName = "GWRecruitProfileTierCheckBox"..tierData.flagId
        
        local pressed = profileData.tiersNeeded[ tierData.flagId ]        
        ButtonSetPressedFlag( windowName.."Button", pressed )        
    end  
    
    -- Interests
    for _, interestData in ipairs(GuildWindowTabRecruit.Interests)
    do        
        local windowName = "GWRecruitProfileInterestCheckBox"..interestData.flagId       
        
        local pressed = profileData.interests[ interestData.flagId ]        
        ButtonSetPressedFlag( windowName.."Button", pressed )        
    end  
    
    
    
    -- Recruiters
    local recruitersText = L""
    for _, recruiterData in ipairs(profileData.recruiters)
    do       

       local text = CreateHyperLink( L"PLAYER:"..recruiterData.name, recruiterData.name, {}, {} )

       if( recruitersText == L"" )
       then
            recruitersText = text
       else
            recruitersText = StringUtils.AppendItemToList( recruitersText, text )
       end

    end 
    
    if( recruitersText == L"" )
    then
        recruitersText = GetGuildString( StringTables.Guild.TEXT_RECRUIT_PROFILE_OPTION_NONE_SPECIFIED )
    end
    
    LabelSetText( "GWRecruitProfileRecruitersText", recruitersText )
    
    local data  = L"GUILD:"..profileData.id
    local text  = GetGuildString( StringTables.Guild.LABEL_LINK_YOUR_GUILD )
    local color = DefaultColor.ORANGE
    local link  = CreateHyperLink( data, text, {color.r,color.g,color.b}, {} )
    LabelSetText( "GWRecruitProfileGuildLinkText", link )
    
end

function GuildWindowTabRecruit.SaveProfileData()
       
    -- Brief Description
    local descText = TextEditBoxGetText( "GWRecruitProfileDescEditBox" )
    
    -- Public Summary
    local summaryText = TextEditBoxGetText( "GWRecruitProfileSummaryEditBox" )
    
    -- Play Style
    local playStyleIndex = ComboBoxGetSelectedMenuItem( "GWRecruitProfilePlayStyleCombo" )    
    local playStyle = GuildWindowTabRecruit.PlayStyles[ playStyleIndex ].flagId
    
    -- Atmosphere
    local atmosphereIndex = ComboBoxGetSelectedMenuItem( "GWRecruitProfileAtmosphereCombo" )
    local atmosphere = GuildWindowTabRecruit.Atmosphere[ atmosphereIndex ].flagId
    
    -- Careers Needed
    local careerFlags = {}
    for _, careerData in ipairs(GuildWindowTabRecruit.Profile.Careers)
    do        
        local windowName = "GWRecruitProfileCareerCheckBox"..careerData.flagId
        
        local pressed = ButtonGetPressedFlag( windowName.."Button" )
        if( pressed )
        then
            table.insert( careerFlags, careerData.flagId )
        end      
    end  
    
    -- Tiers Needed
    local tierFlags = {}
    for _, tierData in ipairs(GuildWindowTabRecruit.TiersNeeded)
    do        
        local windowName = "GWRecruitProfileTierCheckBox"..tierData.flagId
        
        local pressed = ButtonGetPressedFlag( windowName.."Button" )
        
        if( pressed )
        then
            table.insert( tierFlags, tierData.flagId ) 
        end        
    end  
    
    -- Interests
    local interestFlags = {}
    for _, interestData in ipairs(GuildWindowTabRecruit.Interests)
    do        
        local windowName = "GWRecruitProfileInterestCheckBox"..interestData.flagId       
        
        local pressed = ButtonGetPressedFlag( windowName.."Button" )
        if( pressed )
        then
            table.insert( interestFlags, interestData.flagId )
        end        
    end  
    
    
    -- Recruiting Status
    local recruitingStatusFlags = {}
    for _, statusData in ipairs(GuildWindowTabRecruit.RecruitingStatus)
    do        
        if( statusData.searchOnly == false )
        then        
            local windowName = "GWRecruitProfileRecruitingStatusCheckBox"..statusData.flagId
                  
            local pressed = ButtonGetPressedFlag( windowName.."Button" )
            if( pressed )
            then
                table.insert( recruitingStatusFlags, statusData.flagId )
            end  
       end
    end 
    
    -- Recruiters
    local recruiterNames = {}
    local recruiterDescs = {}
    
    -- Save.......
    GuildRecruitmentProfileSetData( descText,
                                    summaryText,
                                    playStyle,
                                    atmosphere,
                                    careerFlags,
                                    tierFlags,
                                    interestFlags,
                                    recruitingStatusFlags,
                                    recruiterNames,
                                    recruiterDescs
                                   )
    
end



function GuildWindowTabRecruit.Profile.UpdatePermissions()
  	
	local disabled = not GuildWindowTabAdmin.GetGuildCommandPermissionForPlayer( SystemData.GuildPermissons.SET_RECRUITERS )

     -- Recruitment Status	
	for _, statusData in ipairs(GuildWindowTabRecruit.RecruitingStatus)
    do        
        if( statusData.searchOnly == false )
        then        
            local windowName = "GWRecruitProfileRecruitingStatusCheckBox"..statusData.flagId
            ButtonSetDisabledFlag( windowName.."Button", disabled )    
        end    
    end 
    
    -- Play Style
    ComboBoxSetDisabledFlag( "GWRecruitProfilePlayStyleCombo", disabled )   
    
    -- Brief Description
    TextEditBoxSetAllowEditing( "GWRecruitProfileDescEditBox", not disabled )
    
    -- Public Summary    
    TextEditBoxSetAllowEditing( "GWRecruitProfileSummaryEditBox", not disabled )    
    
    -- Play Style    
    ComboBoxSetDisabledFlag( "GWRecruitProfilePlayStyleCombo", disabled )   

    
    -- Atmosphere    
    ComboBoxSetDisabledFlag( "GWRecruitProfileAtmosphereCombo", disabled )  

    -- Careers Needed
    for _, careerData in ipairs(GuildWindowTabRecruit.Profile.Careers)
    do        
        local windowName = "GWRecruitProfileCareerCheckBox"..careerData.flagId
        ButtonSetDisabledFlag( windowName.."Button", disabled )            
    end  
    
    -- Tiers Needed
    for _, tierData in ipairs(GuildWindowTabRecruit.TiersNeeded)
    do        
        local windowName = "GWRecruitProfileTierCheckBox"..tierData.flagId
        ButtonSetDisabledFlag( windowName.."Button", disabled )           
    end  
    
    -- Interests
    for _, interestData in ipairs(GuildWindowTabRecruit.Interests)
    do        
        local windowName = "GWRecruitProfileInterestCheckBox"..interestData.flagId       
        ButtonSetDisabledFlag( windowName.."Button", disabled )           
    end 
    
    -- Save Button
    WindowSetShowing("GWRecruitProfileSaveButton", not disabled )
end

function GuildWindowTabRecruit.OnLButtonEditProfile( flags, x, y )

    -- If Shift is pressed, generate a Guild Hyper-Link
    if( flags == SystemData.ButtonFlags.SHIFT )
    then    
        local guildData = GuildRecruitmentProfileGetData()
        EA_ChatWindow.InsertGuildLink( guildData )
    end


end
