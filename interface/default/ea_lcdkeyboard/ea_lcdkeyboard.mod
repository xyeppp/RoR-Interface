<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_LCDKeyboard" version="1.0" date="09/02/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains a test application for the Logitech G15 keyboard." />
        <Dependencies>
            <Dependency name="EASystem_Strings" />
        </Dependencies>
        <Files>
            <File name="Source/G15Test.lua" />
        </Files>
        <OnInitialize>
            <CallFunction name="EA_LCDKeyboard.Initialize" />
        </OnInitialize>
        <OnUpdate>
            <CallFunction name="EA_LCDKeyboard.Update" />
        </OnUpdate>
    </UiMod>

</ModuleFile>
