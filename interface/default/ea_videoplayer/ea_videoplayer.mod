<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_VideoPlayer" version="1.0" date="2/5/2009" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the an in-game video player." />
         <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EA_LoadingScreen" /> <!-- Depend on the Loading Screen so that it is initialized first and drawn behind the video player -->
        </Dependencies>
        <Files>
            <File name="Source/VideoPlayer.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_VideoPlayer" show="false" />
        </OnInitialize>   
    </UiMod>
    
</ModuleFile>    