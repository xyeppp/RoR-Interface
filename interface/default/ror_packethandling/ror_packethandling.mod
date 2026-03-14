<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="ror_PacketHandling" version="1.1" date="23/01/24">
        <Author name="Return of Reckoning" />
        <Description text="Channel9 Packet Handling" />

		<Dependencies>
			<Dependency name="EA_ChatWindow"/>
		</Dependencies>
 
        <Files>
			<File name="Source/ror_PacketHandling.lua" />
        </Files>
		
        <OnInitialize>
			<CallFunction name="ror_PacketHandling.OnInitialize" />
        </OnInitialize>
	
        <OnShutdown>
			<CallFunction name="ror_PacketHandling.OnShutdown" />
		</OnShutdown>
    </UiMod>
</ModuleFile>