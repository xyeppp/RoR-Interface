<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="GuildLog" version="0.2" date="11/06/2024">
        <Author name="Ror Team" />
        <Description text="Guild Vault Log" />
 
		<!--Files to include in the addon -->
        <Files>
		<File name="guildlog.lua" />
		<File name="guildlog.xml" />
        </Files>
		
		<!-- this function will run when the addon loads -->
        <OnInitialize>
 		<CallFunction name="GuildLog.OnInitialize" />
        </OnInitialize>

        <Dependencies>
		<Dependency name="ror_PacketHandling" />
		<Dependency name="json" />
        </Dependencies>
		
		<!-- this is the saved variables/tables function -->
	<SavedVariables>
	</SavedVariables>

		<!-- this function will run on update (every frame) -->
	<OnUpdate>
    	</OnUpdate>

		<!-- this function will run when the addon exits -->		
        <OnShutdown>
		<CallFunction name="GuildLog.OnShutdown" />
	</OnShutdown>
    </UiMod>
</ModuleFile>