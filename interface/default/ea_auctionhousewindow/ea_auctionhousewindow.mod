<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_AuctionHouseWindow" version="2.1" date="5/1/2010" >
        <Author name="EAMythic" email="" />
        <Description text="This is the default EA AuctionHouse window." />
        <Dependencies>
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EASystem_ResourceFrames" />
            <Dependency name="EA_Cursor" />
            <Dependency name="RoR_CitySiege" />			
        </Dependencies>
        <Files>
            <File name="Source/Templates_AuctionWindow.xml" />
            <File name="Source/AuctionWindowSearchControls.xml" />
            <File name="Source/AuctionWindowSellControls.xml" />
            <File name="Source/AuctionWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="AuctionWindow" show="false" />
        </OnInitialize>
    </UiMod>

</ModuleFile>
