<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_SiegeWeaponWindow" version="1.0" date="1/2/2008" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains all of the windows for building and firing siege weapons." />
        <Dependencies>                
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_ChatWindow" />
        </Dependencies>
        <Files>        
            <File name="Textures/SiegeTextures.xml" />
            <File name="Source/SiegeWeaponBuildWindow.xml" />
            <File name="Source/SiegeWeaponControlWindow.xml" />
            <File name="Source/SiegeWeaponGeneralFireWindow.xml" />
            <File name="Source/SiegeWeaponSniperFireWindow.xml" />
            <File name="Source/SiegeWeaponScorchFireWindow.xml" />
            <File name="Source/SiegeWeaponGolfFireWindow.xml" />
            <File name="Source/SiegeWeaponSweetSpotFireWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="SiegeWeaponBuildWindow" show="false" />
            <CreateWindow name="SiegeWeaponInfoWindow" show="false" />    
            <CreateWindow name="SiegeWeaponStatusWindow" show="false" />                    
            <CreateWindow name="SiegeWeaponUsersWindow" show="false" />          
            <CreateWindow name="SiegeWeaponControlWindow" show="false" />
            <CreateWindow name="SiegeWeaponGeneralFireWindow" show="false" />
            <CreateWindow name="SiegeWeaponSniperFireWindow" show="false" />
            <CreateWindow name="SiegeWeaponScorchFireWindow" show="false" />
            <CreateWindow name="SiegeWeaponGolfFireWindow" show="false" />
            <CreateWindow name="SiegeWeaponSweetSpotFireWindow" show="false" />
        </OnInitialize>             
    </UiMod>
    
</ModuleFile>    