----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

ChatManager = {}

-- Chat Bubble Data
ChatManager.NUM_CHAT_BUBBLE_GROUPS = 10
ChatManager.NUM_CHAT_BUBBLES_PER_GROUP = 3

-- Last Tell cache
ChatManager.LastTell = {}
ChatManager.LastTell.name=L""
ChatManager.LastTell.text=L""

function NewChatBubbleGroupData()
    return { worldObject = 0, bubbleData = {} }
end


ChatManager.CHAT_BUBBLE_ALPHA = 1.0
function NewChatBubbleData( txt, dspTime )
    return { text = txt, alpha = ChatManager.CHAT_BUBBLE_ALPHA, displayTime=dspTime, fading=false }
end

ChatManager.CHAT_BUBBLE_MIN_DISPLAY_TIME = 5.0
ChatManager.CHAT_BUBBLE_FADE_OUT_TIME = 1.0

ChatManager.CHAT_BUBBLE_BORDER_SIZE = { x=38, y=25 }

ChatManager.chatBubbleGroups = {}

-- World Event Text Data
ChatManager.NUM_WORLD_EVENT_TEXT_WINDOWS = 3

ChatManager.WORLD_EVENT_TEXT_ALPHA = 0.7
function NewWorldEventTextData( txt, dspTime )
    return { text=txt, alpha=ChatManager.WORLD_EVENT_TEXT_ALPHA, displayTime=dspTime, fading=false }
end

ChatManager.WORLD_EVENT_TEXT_MIN_DISPLAY_TIME = 10.0
ChatManager.WORLD_EVENT_TEXT_FADE_OUT_TIME = 1.0

ChatManager.WORLD_EVENT_TEXT_BORDER_SIZE = { x=20, y=20 }

ChatManager.worldEventText = {}


ChatManager.FADE_OUT_ZERO = 0.1

----------------------------------------------------------------
-- Global Functions
----------------------------------------------------------------
function ChatManager.Initialize()

    ChatManager.InitChatBubbles()
    ChatManager.InitWorldEventTextWindows()
    
end

function ChatManager.Shutdown()
    WindowUnregisterEventHandler ("Root", SystemData.Events.WORLD_EVENT_TEXT_ARRIVED)
end

function ChatManager.Update( timePassed )
    ChatManager.UpdateChatBubbles( timePassed )
    ChatManager.UpdateWorldEventTextWindows( timePassed )
end

-- Chat Bubbles

function ChatManager.InitChatBubbles()

    WindowRegisterEventHandler( "Root", SystemData.Events.CHAT_TEXT_ARRIVED, "ChatManager.OnChatText")

    -- Initialize the Chat Bubbles
    for index = 1, ChatManager.NUM_CHAT_BUBBLE_GROUPS do
    
        CreateWindow( "ChatBubbleWindow"..index, false )
        WindowSetAlpha( "ChatBubbleWindow"..index, ChatManager.CHAT_BUBBLE_ALPHA )
    
        ChatManager.chatBubbleGroups[index] = NewChatBubbleGroupData()
    end
end

function ChatManager.UpdateChatBubbles( timePassed )

    for group = 1, ChatManager.NUM_CHAT_BUBBLE_GROUPS do
    
        if( ChatManager.chatBubbleGroups[group] ~= nil and ChatManager.chatBubbleGroups[group].worldObject ~= 0 ) then
    
            local bubbleCount = 0
            
            MoveWindowToWorldObject( "ChatBubbleWindow"..group, ChatManager.chatBubbleGroups[group].worldObject, 1.0 )
        
            -- Remove lines after they pass the display time
            for bubble = 1, ChatManager.NUM_CHAT_BUBBLES_PER_GROUP do
                if( ChatManager.chatBubbleGroups[group].bubbleData[ bubble ] ~= nil ) then

                    ChatManager.chatBubbleGroups[group].bubbleData[ bubble ].displayTime = ChatManager.chatBubbleGroups[group].bubbleData[ bubble ].displayTime - timePassed
                        
                    local bubbleName = "ChatBubbleWindow"..group.."Bubble"..bubble
                    local curDisplayTime = ChatManager.chatBubbleGroups[group].bubbleData[ bubble ].displayTime
                    local isFading = ChatManager.chatBubbleGroups[group].bubbleData[ bubble ].fading

                    --DEBUG(L"Updating Bubble: "..bubble..L" TimePassed = "..timePassed )
                    if( isFading == true ) then                    
                    
                        if( curDisplayTime <= ChatManager.FADE_OUT_ZERO ) then
                            --DEBUG(L"Removing Bubble: "..bubble )
                            ChatManager.chatBubbleGroups[group].bubbleData[ bubble ] = nil
                            WindowSetShowing( bubbleName, false ) 
                            WindowStopAlphaAnimation(bubbleName)
                        else
                            -- Update the Alpha
                            ChatManager.chatBubbleGroups[group].bubbleData[ bubble ].alpha = 
                            ChatManager.chatBubbleGroups[group].bubbleData[ bubble ].alpha - timePassed / ChatManager.CHAT_BUBBLE_FADE_OUT_TIME

                        end
                    else
                        if( curDisplayTime <= 0 ) then
                            -- Start the fade out   
                            ChatManager.chatBubbleGroups[group].bubbleData[ bubble ].fading = true                  
                            ChatManager.chatBubbleGroups[group].bubbleData[ bubble ].displayTime = ChatManager.CHAT_BUBBLE_FADE_OUT_TIME
                            -- WindowStartAlphaAnimation( bubbleName, Window.AnimationType.SINGLE_NO_RESET, ChatManager.CHAT_BUBBLE_ALPHA, 0, ChatManager.CHAT_BUBBLE_FADE_OUT_TIME, false, 0, 0 )
                        end
                    end
                    
                    WindowSetShowing( bubbleName.."DownArrow", false )
                    bubbleCount = bubbleCount + 1
                end
            end
            
            -- Remove the group
            if( bubbleCount == 0 ) then
                --DEBUG(L"Removing Text Group From: "..group )
                -- DetachWindowFromWorldObject( ChatManager.chatBubbleGroups[group].worldObject, "ChatBubbleWindow"..group )
                ChatManager.chatBubbleGroups[group].worldObject = 0
                WindowSetShowing( "ChatBubbleWindow"..group, false )
            else
                WindowSetShowing( "ChatBubbleWindow"..group.."Bubble1DownArrow", true )
            end
        
        end
        
    end 

end

function ChatManager.OnChatText()

    -- Only pop up chat bubbles for say and group text
    if( ( (GameData.ChatData.type == SystemData.ChatLogFilters.SAY and SystemData.Settings.GamePlay.showPlayerChatBubbles)
        or (GameData.ChatData.type == SystemData.ChatLogFilters.GROUP and SystemData.Settings.GamePlay.showPartyChatBubbles)
        or (GameData.ChatData.type == SystemData.ChatLogFilters.MONSTER_SAY and SystemData.Settings.GamePlay.showNPCChatBubbles) )
        and ( GameData.ChatData.objectId ~= GameData.Player.worldObjNum or GameData.ChatData.type == SystemData.ChatLogFilters.SAY  ) )
    then
        ChatManager.AddChatText( GameData.ChatData.objectId, GameData.ChatData.text )    
    end

	-- Cache the text and username from the last tell sent. This is used in EA_Window_Appeal.ReportGoldSeller()
	if GameData.ChatData.type == SystemData.ChatLogFilters.TELL_RECEIVE then
		ChatManager.LastTell.name = GameData.ChatData.name
		ChatManager.LastTell.text = GameData.ChatData.text
		if( not SystemData.Settings.Sound.disableCommunicationSounds )
		then
		    -- Play tell recieved sound
		    Sound.Play(Sound.PLAYER_RECEIVES_TELL)
		end
	end
end

function ChatManager.AddChatText( worldObjNum, text )

    --DEBUG(L"ObjectNum = "..worldObjNum..L", Text = "..text)

    if ( worldObjNum == 0 ) then
        return
    end

    -- Check if this object already has an active chat bubble group
    local groupIndex = nil
    for index = 1, ChatManager.NUM_CHAT_BUBBLE_GROUPS do
        --DEBUG(L"Group Index: "..index..L", ObjNum = "..ChatManager.chatBubbleGroups[index].worldObject )
        if( ChatManager.chatBubbleGroups[index].worldObject == worldObjNum ) then
            groupIndex = index
            
            -- Move the current chat bubbles up
            for bubble = ChatManager.NUM_CHAT_BUBBLES_PER_GROUP, 2, -1 do 
                ChatManager.chatBubbleGroups[groupIndex].bubbleData[bubble] = ChatManager.chatBubbleGroups[groupIndex].bubbleData[bubble-1]
            end             
            
            break
        end 
    end
    
    -- Find a Open Chat Bubble Group
    if( groupIndex == nil ) then
        for index = 1, ChatManager.NUM_CHAT_BUBBLE_GROUPS do        
            if( ChatManager.chatBubbleGroups[index].worldObject == 0 ) then
                groupIndex = index
                
                -- Attach the Chat Bubble Window to the world object
                ChatManager.chatBubbleGroups[groupIndex].worldObject = worldObjNum
                break
            end 
        end
    end
    
    if( groupIndex == nil ) then
        return
    end
    
    -- Add the new bubble data
    
    -- Display the bubble for 1 sec for each 25 characters, with a minimum of 5 sec.
    local textLen = wstring.len( text )
    local displayTime = textLen / 25 
    if( displayTime < ChatManager.CHAT_BUBBLE_MIN_DISPLAY_TIME ) then
        displayTime = ChatManager.CHAT_BUBBLE_MIN_DISPLAY_TIME
    end
    
    ChatManager.chatBubbleGroups[groupIndex].bubbleData[1] = NewChatBubbleData( L"\""..text..L"\"", displayTime )    
    
    local targetGroup = "ChatBubbleWindow"..groupIndex
    
    -- Update the Chat Bubble Window    
    local groupWindowSize = { x=0, y=0 } 
    for bubble = 1, ChatManager.NUM_CHAT_BUBBLES_PER_GROUP do
    
        local targetBubble = targetGroup.."Bubble"..bubble
        local bubbleData = ChatManager.chatBubbleGroups[groupIndex].bubbleData[bubble]
        if( bubbleData ~= nil ) then
             -- Restore default size
            WindowSetDimensions(targetBubble.."Text", 320, 25 ) 

            LabelSetText(targetBubble.."Text", bubbleData.text )
            local x, y = LabelGetTextDimensions( targetBubble.."Text" ) 

            -- Make it Pretty
            x = math.max (75, x)
            y = math.max (25, y)
            
            WindowSetDimensions (targetBubble.."Text", x, y)

            x = x + 50 -- make the group window as big as the background width
            y = y + 84 -- add some height to the group so it doesn't obscure objects' faces.

            WindowSetDimensions(targetBubble, x, y ) 

            if( groupWindowSize.x < x ) 
            then 
                groupWindowSize.x = x 
            end 

            groupWindowSize.y = groupWindowSize.y + y 

            WindowSetAlpha( targetBubble, ChatManager.CHAT_BUBBLE_ALPHA ) 
            WindowSetAlpha( targetGroup,  ChatManager.CHAT_BUBBLE_ALPHA )
        end
        
        WindowSetShowing( targetBubble, bubbleData ~= nil )  
        
    end
    
    WindowSetDimensions( targetGroup, groupWindowSize.x, groupWindowSize.y )
    ForceUpdateWorldObjectWindow( worldObjNum, targetGroup )    
        
end



-- World Event Text 

function ChatManager.InitWorldEventTextWindows()

    WindowRegisterEventHandler( "Root", SystemData.Events.WORLD_EVENT_TEXT_ARRIVED, "ChatManager.OnWorldEventText")

    -- Initialize the Windows
    for index = 1, ChatManager.NUM_WORLD_EVENT_TEXT_WINDOWS do
    
        CreateWindow( "WorldEventTextWindow"..index, false )
        WindowSetAlpha( "WorldEventTextWindow"..index, 0.5 )
    
        ChatManager.worldEventText[index] = nil
    end
end

function ChatManager.UpdateWorldEventTextWindows( timePassed )
 
    -- Remove windows after they pass the display time
    for window = 1, ChatManager.NUM_WORLD_EVENT_TEXT_WINDOWS do
        if( ChatManager.worldEventText[window] ~= nil ) then

            --DEBUG(L" Updating Window #"..window )
            ChatManager.worldEventText[window].displayTime = ChatManager.worldEventText[window].displayTime - timePassed
                
            local windowName = "WorldEventTextWindow"..window
            local curDisplayTime = ChatManager.worldEventText[window].displayTime
            local isFading = ChatManager.worldEventText[window].fading

            --DEBUG(L"Updating World Text Window: "..window )
            if( isFading == true ) then
            
                if( curDisplayTime <= ChatManager.FADE_OUT_ZERO ) then
                    --DEBUG(L"Removing WorldText Window: "..window )
                    ChatManager.worldEventText[window] = nil
                    WindowSetShowing( windowName, false ) 
                    WindowStopAlphaAnimation( windowName )
                else
                    -- Update the Alpha
                    ChatManager.worldEventText[window].alpha = 
                    ChatManager.worldEventText[window].alpha - timePassed / ChatManager.WORLD_EVENT_TEXT_FADE_OUT_TIME
                end
            else
                if( curDisplayTime <= 0 ) then
                    -- Start the fade out   
                    ChatManager.worldEventText[window].fading = true                  
                    ChatManager.worldEventText[window].displayTime = ChatManager.WORLD_EVENT_TEXT_FADE_OUT_TIME
                    WindowStartAlphaAnimation( windowName, Window.AnimationType.SINGLE_NO_RESET, ChatManager.CHAT_BUBBLE_ALPHA, 0, ChatManager.CHAT_BUBBLE_FADE_OUT_TIME, false, 0, 0 )
                end
            end
        end
    end       

end

function ChatManager.OnWorldEventText()    
   ChatManager.AddWorldEventText( GameData.ChatData.text )            
end

function ChatManager.AddWorldEventText(  text )

    --DEBUG(L"World Event Text = "..text)
    
    -- Move the current world text windows up 
    for window = ChatManager.NUM_WORLD_EVENT_TEXT_WINDOWS, 2, -1 do 
        ChatManager.worldEventText[window] = ChatManager.worldEventText[window-1]
    end      
 
    -- Add the new text
    
    -- Display the bubble for 1 sec for each 25 characters, with a minium of 5 sec.
    local textLen = wstring.len( text )
    local displayTime = textLen / 25 
    if( displayTime < 5 ) then
        displayTime = 5
    end
    
    ChatManager.worldEventText[1] = NewWorldEventTextData( text, displayTime )
    
    
    -- Update the World Text Windows   
    for window = 1, ChatManager.NUM_WORLD_EVENT_TEXT_WINDOWS do
        
        local windowData = ChatManager.worldEventText[window]
        
        WindowSetShowing( "WorldEventTextWindow"..window, windowData ~= nil )
        
        if( windowData ~= nil ) then
            LabelSetText("WorldEventTextWindow"..window.."Text", windowData.text )
            local x, y = LabelGetTextDimensions( "WorldEventTextWindow"..window.."Text" )
            
            x = x + ChatManager.WORLD_EVENT_TEXT_BORDER_SIZE.x*2
            y = y + ChatManager.WORLD_EVENT_TEXT_BORDER_SIZE.y*2   
             
            WindowSetDimensions("WorldEventTextWindow"..window, x, y )
           
           
            WindowSetAlpha( "WorldEventTextWindow"..window, windowData.alpha )
            --DEBUG( L" Display Time = "..ChatManager.worldEventText[window].displayTime )
             
            -- Start the alpha anim if it is already fading out
            local alpha = windowData.alpha
            if( alpha < ChatManager.WORLD_EVENT_TEXT_ALPHA ) then
                WindowStartAlphaAnimation( "WorldEventTextWindow"..window, Window.AnimationType.SINGLE_NO_RESET, 0, alpha, ChatManager.WORLD_EVENT_TEXT_FADE_OUT_TIME, false, 0, 0 )
            end
             
        end
        
    end
        
end
    
    