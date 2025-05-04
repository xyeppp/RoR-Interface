ror_PacketHandling = {}
ror_PacketHandling.RP={}

function ror_PacketHandling.OnInitialize()
	RegisterEventHandler(TextLogGetUpdateEventId("Chat"), "ror_PacketHandling.OnChatLogUpdated")	
end

function ror_PacketHandling.OnShutdown()	
	UnregisterEventHandler(TextLogGetUpdateEventId("Chat"), "ror_PacketHandling.OnChatLogUpdated")
end

function ror_PacketHandling.OnChatLogUpdated(updateType, filterType)
	if( updateType == SystemData.TextLogUpdate.ADDED ) then 			
		if filterType == SystemData.ChatLogFilters.CHANNEL_9 then	
			local _, filterId, text = TextLogGetEntry( "Chat", TextLogGetNumEntries("Chat") - 1 ) 
			local Text = tostring(text)
			local Header = string.sub (Text,1,15)
			ror_PacketHandling.DoCallback(Header,Text)
		end
	end
end

function ror_PacketHandling.Register(phrase,callbackFunction)
	if (phrase) ~= nil and (callbackFunction) ~= nil then
		phrase = tostring(phrase)
		if ror_PacketHandling.RP[phrase] == nil then ror_PacketHandling.RP[phrase] = {} end
		table.insert(ror_PacketHandling.RP[phrase],callbackFunction)
	else
		ERROR(L"Need to speccify a Phrase and/or Callback Function")
	end	
end

function ror_PacketHandling.Unregister(phrase,callbackFunction)
	if (phrase) ~= nil and (callbackFunction) ~= nil then
		phrase = tostring(phrase)
		for k,v in pairs(ror_PacketHandling.RP[phrase]) do
			if v == callbackFunction then
				table.remove(ror_PacketHandling.RP[phrase],k)
			end
		end
	else
		ERROR(L"Need to speccify a Phrase and/or Callback Function")	
	end
	if #ror_PacketHandling.RP[phrase] == 0 then ror_PacketHandling.RP[phrase] = nil end
end

function ror_PacketHandling.DoCallback(Header,Text,...)	
	for k,v in pairs(ror_PacketHandling.RP) do			
		if string.find(Header,k) then
			for key,value in pairs(ror_PacketHandling.RP[tostring(k)]) do
				ror_PacketHandling.Pcall(value,Text,...)						
			end
		end
	end	
end

function ror_PacketHandling.Pcall(command,...)
local success, errmsg = pcall(command,...)
	if not success then
		EA_ChatWindow.Print(L"ror_PacketHandling got an error from a registered function:")
		EA_ChatWindow.Print(towstring(errmsg))
	end
return
end

function ror_PacketHandling.debug(TextData)
	DEBUG(towstring(TextData))
end