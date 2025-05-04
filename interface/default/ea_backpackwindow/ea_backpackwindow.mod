<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_BackpackWindow" version="1.0" date="11/6/2007" >
        <Author name="EAMythic" email="" />
        <Description text="Your character's backpack." />
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
            <File name="Textures/EA_Backpack01_d5.xml" />
            <File name="Source/BackpackFilters.xml" />
            <File name="Source/IconViewTemplates.xml" />
            <File name="Source/ListViewTemplates.xml" />
            <File name="Source/QuestViewTemplates.xml" />
            <File name="Source/BackpackWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_Backpack" show="false" />
        </OnInitialize>
        <OnUpdate>
            <CallFunction name="EA_Window_Backpack.OnUpdate" />
        </OnUpdate>
        <SavedVariables>
            <SavedVariable name="EA_Window_Backpack.settings" />
        </SavedVariables>
    </UiMod>

</ModuleFile>
