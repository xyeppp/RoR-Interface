<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_GuildVaultWindow" version="1.0" date="7/8/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all of the screens for the Default EA GuildVault Window." />
        <Dependencies>
          <Dependency name="EASystem_ResourceFrames" />
          <Dependency name="EASystem_Tooltips" />
          <Dependency name="EASystem_Utils" />
          <Dependency name="EASystem_WindowUtils" />

          <Dependency name="EATemplate_DefaultWindowSkin" />
          <Dependency name="EATemplate_Icons" />

          <Dependency name="EA_Cursor" />
          <Dependency name="EA_ItemEnhancementWindow" />
          <Dependency name="EA_ItemStackingWindow" />
          <Dependency name="EA_ModifyItem" />
          <Dependency name="EA_InteractionWindow" />
        </Dependencies>
        <Files>
            <File name="Source/GuildVaultWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="GuildVaultWindow" show="false" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
