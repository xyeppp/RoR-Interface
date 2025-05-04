<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EASystem_WindowUtils" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all of the window utility code and functions used across the EA Default Ui for Warhammer." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Strings" />
            <Dependency name="EASystem_TargetInfo" />
        </Dependencies>
        <Files>
            <File name="Textures/WindowUtilsTextures.xml" />
            <File name="Source/WindowUtils.xml" />
            <File name="Source/WindowUtils.lua" />
            <File name="Source/FrameManager.lua" />
            <File name="Source/Frame.lua" />
            <File name="Source/Label.lua" />
            <File name="Source/AnimatedImage.lua" />
            <File name="Source/TextEditBox.lua" />
            <File name="Source/ComboBox.lua" />
            <File name="Source/DynamicImage.lua" />
            <File name="Source/HorizontalResizeImage.lua" />
            <File name="Source/StatusBar.lua" />
            <File name="Source/Button.lua" />
            <File name="Source/VersatileFrame.xml" />
            <File name="Source/FullResizeImage.lua"/>
            <File name="Source/BackpackUtilsMediator.lua"/>
        </Files>
        <OnInitialize>
            <CallFunction name="WindowUtils.Initialize" />
        </OnInitialize>   
        <OnUpdate>
            <CallFunction name="WindowUtils.Update" />
        </OnUpdate>   
        <OnShutdown>
            <CallFunction name="WindowUtils.Shutdown" />
        </OnShutdown>         
    </UiMod>
    
</ModuleFile>    
