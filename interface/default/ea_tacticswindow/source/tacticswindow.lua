-----------------------------------------------------------------------------------------
-- Global Data
-----------------------------------------------------------------------------------------

TacticsEditor = {};

-- Initialize here, not in TacticsEditor.Initialize, in case player levels up, etc.
TacticsEditor.isDisabled = false;
TacticsEditor.TimeUntilEnable = 0;
TacticsEditor.TIME_DISABLED_AFTER_COMBAT = 10; -- Must wait a minute after ending combat before editing tactics.
TacticsEditor.NeedsTacticsGuess = true;
TacticsEditor.openMenuOnNextClick = true;      -- Controls whether clicking on an empty tactic slot will open the Set Menu or not.

-----------------------------------------------------------------------------------------
-- Local Data and Utility Functions
-----------------------------------------------------------------------------------------

local INVALID_TACTICS_SET       = -1;
local FIRST_TACTICS_SET         = 0;
local BORDER_SIZE               = 15;
local HORIZONTAL_BUTTON_SPACING = 4;
local VERTICAL_BUTTON_SPACING   = 4;
local AVAIL_SLOT_TEXT           = GetString (StringTables.Default.TEXT_AVAIL_TACTIC_SLOT);
local AVAIL_SLOT_CAREER_TEXT    = GetString (StringTables.Default.TEXT_AVAIL_TACTIC_SLOT_CAREER);
local AVAIL_SLOT_RENOWN_TEXT    = GetString (StringTables.Default.TEXT_AVAIL_TACTIC_SLOT_RENOWN);
local AVAIL_SLOT_TOME_TEXT      = GetString (StringTables.Default.TEXT_AVAIL_TACTIC_SLOT_TOME);
local CLICK_TO_EDIT_TACTICS     = GetString (StringTables.Default.TEXT_CLICK_TO_EDIT_TACTICS);
local CANNOT_EDIT_IN_COMBAT     = GetString (StringTables.Default.TEXT_CANNOT_EDIT_TACTICS_IN_COMBAT);
local CLICK_TO_SWITCH_TACTICS   = GetString (StringTables.Default.TEXT_CLICK_TO_SWITCH_TACTICS_SETS);
local ANCHOR_ABILITY_TOOLTIP    = { Point = "topleft", RelativeTo = "", RelativePoint = "bottomleft",  XOffset = 5, YOffset = -38 }

local MAX_TACTICS_SETS          = GameData.MAX_TACTICS_SETS; -- =5
local SPACER_WIDTH = 5;

local EmptyTacticsData =
{
    [GameData.TacticType.CAREER] = {Texture = "Empty-Career-Tactic-Icon", Description = AVAIL_SLOT_CAREER_TEXT},
    [GameData.TacticType.RENOWN] = {Texture = "Empty-Renown-Tactic-Icon", Description = AVAIL_SLOT_RENOWN_TEXT},
    [GameData.TacticType.TOME]   = {Texture = "Empty-Tome-Tactic-Icon",   Description = AVAIL_SLOT_TOME_TEXT}
}

-----------------------------------------------------------------------------------------
-- Local Functions
-----------------------------------------------------------------------------------------


-- Called by UpdateTacticsButtons to actually do the heavy lifting behind the update.
-- (table) buttonManager is essentially a reference to TacticsButtons; (table) tacticData contains tactics id's and is 0-indexed.
local function UpdateButtonsFromTacticsList (buttonManager, tacticData)
    -- Un-use all buttons
    -- This does not alter texture data, which means that the entire button table needs to be iterated 
    -- over in order to guarantee that the images are correctly set.
    buttonManager:UnUseAll ();
    
    for k, tacticAbilityId in pairs (tacticData) do
        if (tacticAbilityId ~= 0) then
            local abilityData = Player.GetAbilityData (tacticAbilityId, Player.AbilityType.TACTIC);
            
            if (abilityData ~= nil) then
                for i = 1, abilityData.numTacticSlots do
                    local tacticButton = buttonManager:GetUnusedButton (abilityData.tacticType);
                    
                    if (nil ~= tacticButton) then
                        buttonManager:SlotTacticAbility (tacticButton, abilityData);
                    end
                end
            end                
        end
    end
        
    for tacticType = GameData.TacticType.FIRST, GameData.TacticType.NUM_TYPES do
        local remainingButton;
        
        repeat
            remainingButton = buttonManager:GetUnusedButton (tacticType);
            
            if (nil ~= remainingButton) then
                buttonManager:SlotTacticAbility (remainingButton, nil);
            end
        until (remainingButton == nil);
    end        
end

local function GuessAboutActiveSet ()
    local activeTactics = GetActiveTactics ();
    local activeCount   = 0;
    local activeLookup  = {};

    for k, v in pairs (activeTactics) do
        activeCount         = activeCount + 1;
        activeLookup[v]     = k;                   
    end
    
    if (0 < activeCount) then
        for i = 0, (MAX_TACTICS_SETS - 1) do
            local tacticsSet        = GetTacticsSet (i);
            local setCount          = 0;
            local potentialMatch    = true;
            
            for k, v in pairs (tacticsSet) do
                if (nil == activeLookup[v]) then
                    potentialMatch = false;
                    break;
                end

                setCount = setCount + 1;
            end

            if (true == potentialMatch) and (setCount == activeCount) then
                return (i);
            end        
        end
    
    -- If there are no active tactics, try to find an empty set to display.
    else
        for i = 0, (MAX_TACTICS_SETS - 1) do
            local tacticsSet = GetTacticsSet(i)
            if (tacticsSet and (#tacticsSet == 0)) then
                return i;
            end
        end
    end

    -- When no saved tactics set matches the currently active tactics:
    
    local cbIndex = ComboBoxGetSelectedMenuItem("EA_TacticsEditorContentsSetMenu");
    
    -- When initializing:  combobox item can be -1 when constructed, in which case ComboBoxGetSelectedMenuItem returns (m_currentItem + 1) = 0
    if (cbIndex == nil or cbIndex <= 0) then
        return INVALID_TACTICS_SET;
        
    -- If for some reason there is a non-empty active set of tactics (according to the server) which does not match any saved set,
    -- GuessTacticsIfNeeded will be called; it will call this function and control will go here (since the combobox has already ben set).
    -- In this case, we overwrite set 0 with what the server says is the active tactics.
    -- Note that this case should never happen, but could be problematic if the set of active tactics from the server is too large.
    else
        DEBUG (L"No saved tactics set matches the currently active tactics; overwriting set 0 with the active tactics.");
        SaveTacticsSet (0, GetActiveTactics());
        return 0;
    end
end

-----------------------------------------------------------------------------------------
-- TacticsEditor Set Menu Data
-----------------------------------------------------------------------------------------


local TacticsSetMenu =
{
    currentSet                  = INVALID_TACTICS_SET,          -- The set you are editing; set by GuessTacticsIfNeeded after login, then TacticsButtons:Update for subsequent UI reloads, etc.
    windowName                  = "EA_TacticsEditorContentsSetMenu",
    buttonManager               = { },
    
    [0]                         = { displayString = L"1", },
    [1]                         = { displayString = L"2", },
    [2]                         = { displayString = L"3", },
    [3]                         = { displayString = L"4", },
    [4]                         = { displayString = L"5", },
}

function TacticsSetMenu:Initialize (buttonManager)
    for i = 0, (MAX_TACTICS_SETS - 1) do
        ComboBoxAddMenuItem (self.windowName, self[i].displayString);
    end
        
    if (nil == buttonManager) then
        DEBUG (L"TacticsSetMenuInitialize: buttonManager should not be nil.");
        self.buttonManager = { };
    else
        self.buttonManager = buttonManager;
    end
end

-- Gets a list of tactic ability id's corresponding to the  active tactics(i.e. the current selection on the dropdown menu).
function TacticsSetMenu:GetCurrentTactics ()
    return GetTacticsSet (self.currentSet);
end

-- Saves the active tactics set.  Called automatically when the user equips or removes tactics.
function TacticsSetMenu:SaveSet ()
    if (nil == self.buttonManager or nil == self.buttonManager.GetList) then
        DEBUG (L"TacticsSetMenuSave: Incorrectly initialized.  Missing the button manager.");
        return;
    end
    
    if (self.currentSet < MAX_TACTICS_SETS) then             -- is this needed?
        SaveTacticsSet (self.currentSet, self.buttonManager:GetList ());
    end        
end

--Called to load and display the set of tactics with number 'desiredSet'.
-- If the desiredSet is out of range, the combo box will disallow the selection and nothing should change.
function TacticsSetMenu:LoadSet (desiredSet)
    ComboBoxSetSelectedMenuItem (self.windowName, desiredSet);
end

-----------------------------------------------------------------------------------------
-- Tactics Editor Window Definition
--
-- This table is locally scoped because only the TacticsEditor needs to see it.
-----------------------------------------------------------------------------------------
local TacticsButtons = 
{
    numButtons              = 0,
    tacticsButtons          = {},
    tacticsSlots            = {},
};

function TacticsButtons:Initialize()
    self:Shutdown ();
    
    self.tacticsSlots = GetNumTacticsSlots ();
    
    -- To satisfy UI design, don't use pairs to iterate over this
    -- table...make sure to iterate over it in the order the windows
    -- must be created
    
    for slotType = GameData.TacticType.FIRST, GameData.TacticType.NUM_TYPES do
        for i = 1, self.tacticsSlots[slotType] do
            local button = self:CreateButton (slotType);
            
            -- Create a name for a spacer image if this is the first tactics button of its type.
            local spacerName = nil;
            if (i == 1) then
                spacerName = "Spacer"..slotType;
            end
            
            if (button ~= nil) then
                self:AnchorButton (button, spacerName); -- spacerName is Nil if no spacer should be added
            end
        end
    end
end

function TacticsButtons:Shutdown()
    self.numButtons = 0;

    if (self.tacticsButtons == nil) then
        return;
    end
    
    for k, v in pairs (self.tacticsButtons) do
        if (nil ~= v.name) then
            DestroyWindow (v.name);
        end
    end
    
    self.tacticsButtons = {};
    self.tacticsSlots   = {};
    self.blockedSlots	= {}
end

function TacticsButtons:CreateButton(tacticsType)
    local buttonId = self.numButtons + 1;
    
    if (buttonId > GameData.MAX_TACTICS_SLOTS) then
        DEBUG (L"TacticsButtons:CreateButton - Trying to make too many tactics slots.");
        return nil;
    end
    
    local buttonName = "TacticButton"..buttonId;
    
    CreateWindowFromTemplate (buttonName, "TacticButton", "EA_TacticsEditorContents");
    
    if (DoesWindowExist (buttonName) == false) then
        return nil;
    end
        
    return (self:AddButton (buttonId, buttonName, tacticsType, nil));
end

function TacticsButtons:AddButton(id, name, tacticsType, abilityData)
    self.numButtons = self.numButtons + 1;
    
    WindowSetId (name, id);
    
    --[[
        Function:       Button 'Member' Functions
        Parameters: 
        Returns:
        Notes:          Tactics Buttons have immutable types once created.
                        The only things that can be altered are which ability
                        is slotted, and whether or not the button is used.
        Example:    
    --]]
    
    local function ButtonGetName (self)
        return (self.name);
    end
    
    local function ButtonGetType (self)
        return (self.tacticType);
    end
    
    local function ButtonGetTacticId (self)
        return (self.tacticId);
    end
    
    local function ButtonGetWindowId (self)
        return (WindowGetId (self.name));
    end
    
    local function ButtonSetTactic (self, abilityData)
        if (nil ~= abilityData) then
            self.tacticId = abilityData.id;
        else
            self.tacticId = 0;
        end
        
        self.isUsed = (abilityData ~= 0);
        
        local texture, textureX, textureY;
        
        if (nil == abilityData) then
            texture, textureX, textureY = EmptyTacticsData[self:GetType()].Texture, 0, 0;
            
            if (nil == texture or nil == textureX or nil == textureY) then
                DEBUG (L"AddTacticsButton: Unable to find empty texture for tactic type: "..self:GetType ());     
                texture, textureX, textureY = EmptyTacticsData[GameData.TacticType.CAREER].Texture, 0, 0;
            end
        else
            texture, textureX, textureY = GetIconData (abilityData.iconNum);
        end    
        
        DynamicImageSetTexture (self:GetName (), texture, textureX, textureY);
		
       -- Only tint the window based on the ability it holds if it isn't already blocked
       if( not self.isBlocked )
       then
           Player.TintWindowIfAbilityIsBlocked( self:GetName(), self.tacticId, GameData.AbilityType.TACTIC )
       end
    end
    
    local function ButtonGetUsed (self)
        return (self.isUsed);
    end
    
    local function ButtonSetUsed (self, isUsed)
        self.isUsed = isUsed;
    end
    
	local function ButtonGetBlocked( self )
        return self.isBlocked;
    end
    
    local function ButtonSetBlocked( self, isBlocked )
        self.isBlocked = isBlocked;
    end
    
    local button = 
    {
        name        = name,
        tacticType  = tacticsType,
        tacticId    = 0,
        isUsed      = false,
        isBlocked   = false,
        
        GetName     = ButtonGetName,
        GetType     = ButtonGetType,
        GetId       = ButtonGetTacticId,
        SetId       = ButtonSetTactic,
        GetUsed     = ButtonGetUsed,
        SetUsed     = ButtonSetUsed,
        GetWindowId = ButtonGetWindowId,
        SetBlocked  = ButtonSetBlocked,
        GetBlocked	= ButtonGetBlocked,
    };
        
    self:SlotTacticAbility (button, abilityData);
       
    self.tacticsButtons[id] = button;
    
    return (button);    
end

function TacticsButtons:GetUnusedButton(tacticType)
    if (nil ~= tacticType) then
        for i = 1, self.numButtons do  
            local currentButton = self.tacticsButtons[i];
            
            if (
                (nil ~= currentButton)                      and 
                (currentButton:GetType () == tacticType)    and
                (currentButton:GetUsed () == false) 
               )
            then
                return (currentButton);
            end
        end
    end
    
    return (nil);
end

function TacticsButtons:GetEmptyButton()
   for i = 1, self.numButtons do  
        local currentButton = self.tacticsButtons[i];

        if ((nil ~= currentButton) and (currentButton:GetId () == 0)) then
            return (currentButton);
        end
    end
    
    return (nil);
end

function TacticsButtons:GetButtonForId(windowId)
    if (nil ~= windowId) then
        local potentialButton = self.tacticsButtons[windowId];
        
        if (nil ~= potentialButton) then
            if (WindowGetId (potentialButton:GetName ()) == windowId) then
                return (potentialButton);
            end
        end
        
        for k, button in pairs (self.tacticsButtons) do
            if (nil ~= button) then
                if (WindowGetId (button:GetName ()) == windowId) then
                    return (button);
                end
            end
        end
    end
    
    return (nil);
end

function TacticsButtons:UnUseAll(optionallyHideWindowAsWell)
    for buttonId, button in pairs (self.tacticsButtons) do
        button:SetUsed (false);
        
        if (optionallyHideWindowAsWell ~= nil and optionallyHideWindowAsWell == true) then
            WindowSetShowing (button:GetName (), false);
        end
    end
end

function TacticsButtons:SlotTacticAbility(button, abilityData)
    if (nil == button) then
        return;
    end
    
    local tacticsType = button:GetType ();

    if (nil == abilityData) then
        button:SetId (nil); 
    else
        if (abilityData.numTacticSlots == 0) then
            DEBUG (L"SetTacticsButtonAbility: "..abilityData.name..L" is not a tactic ability.");
            return;
        end
        
        if (tacticsType ~= abilityData.tacticType) then
            DEBUG (L"SetTacticsButtonAbility: "..abilityData.name..L" is not the correct type for button: "..towstring (button:GetName ()));
            return;
        end        
        
        button:SetId (abilityData);
    end
end

function TacticsButtons:AnchorButton(button, spacerName)
    local previousButtonId = self.numButtons - 1;
    
    if (previousButtonId < 0) then                                                        -- can be used on #1 or higher
        DEBUG (L"AnchorTacticsButton: Create your button through the correct method.");
        return;
    end

    -- Sorry for the hardcoding...
    local anchorToWindow    = "EA_TacticsEditorContents"
    local offsetX           = 39
    local offsetY           = 2;    
    local relativePoint     = "topleft";
    local point             = "topleft";
    
    if (previousButtonId > 0) then
        anchorToWindow  = "TacticButton"..previousButtonId;
        offsetX         = -5; 
        offsetY         = 0;
        point           = "topright";
        if (spacerName) then
            offsetX = 3;
            
            -- Create a spacer if it doesn't alrady exist (it will already exist if the player just gained a new tactic button).
            if (not DoesWindowExist (spacerName)) then
                CreateWindowFromTemplate (spacerName, "TacticSpacer", "EA_TacticsEditorContents");
            end
            WindowClearAnchors (spacerName);
            WindowAddAnchor (spacerName, point, anchorToWindow, relativePoint, -2, 14); -- Last two values are offset x, offset y for the spacer.
        end
    end

    WindowClearAnchors (button.name);
    WindowAddAnchor (button.name, point, anchorToWindow, relativePoint, offsetX, offsetY);
end

function TacticsButtons:Update()
    UpdateButtonsFromTacticsList (self, TacticsSetMenu:GetCurrentTactics ());
end

function TacticsButtons:GetList()
    local usedTacticIds = {};
    local returnList    = {};
    
    -- While 0 is a perfectly valid key, Our LuaSystem appears to dislike retrieving any elements
    -- accessed at key 0.  So make the return table start at a key of 1.
    local currentIndex  = 1;    
    
    for buttonId, button in pairs (self.tacticsButtons) do
        local tacticId = button:GetId ();
        
        if (0 ~= tacticId and nil == usedTacticIds[tacticId]) then
            usedTacticIds[tacticId]     = true;
            returnList[currentIndex]    = tacticId;
            currentIndex                = currentIndex + 1;
        end
    end
        
    return (returnList);
end

function TacticsButtons:DropTacticOnButton(button, incomingTacticId)
    local tacticData = Player.GetAbilityData (incomingTacticId, Player.AbilityType.TACTIC);
    
    if (tacticData ~= nil) then
    
        -- The first thing we need to do is get the list of tactics from what's currently visible.
        -- This will allow us to total up the point requirements and determine whether or not the 
        -- player even has enough points remaining to slot this tactic.
        
        -- NOTE: GetList returns a table starting at 1...not 0!
        
        local scratchPadTactics = self:GetList ();
               
        -- If the player is dropping this tactic on a tactic button that has something slotted, they
        -- want to do a swap.  Get the id of that button and do not include it in the scratch pad summation.
        
        -- NOTE: Strange behavior warning!  If the player drops a "Career" tactic on a "Renown" tactic, they
        -- might not want to swap...they might just want to add the "Career" tactic to this loadout.  Who knows
        -- what the desired behavior is in this case?
        
        local swappedTactic = button:GetId ();
        local swappedIndex  = -1;
        local nextIndex     = 1;  -- set to 1 because of GetList's initial index in the returned table.
        
        -- Now total the costs...
        
        local scratchPadCosts = 
        {
            [GameData.TacticType.CAREER]    = 0,    
            [GameData.TacticType.RENOWN]    = 0,
            [GameData.TacticType.TOME]      = 0,
        };       
        
        for index, tacticId in pairs (scratchPadTactics) do
            local abilityData = Player.GetAbilityData (tacticId, Player.AbilityType.TACTIC);
            
            -- First out...make sure the player doesn't already have this tactic in the list
            if (incomingTacticId == tacticId) then
                if( EA_ChatWindow )
                then
                    local errorText = GetString( StringTables.Default.TEXT_TACTIC_ALREADY_EQUIPED )
                    EA_ChatWindow.Print( errorText, SystemData.ChatLogFilters.MISC )
                end 
                return;
            end
                        
            if (tacticId == swappedTactic) 
            then
                swappedIndex = index;
            elseif ((nil    ~=  abilityData)                and 
                    (nil    ~=  abilityData.numTacticSlots) and 
                    (0      <   abilityData.numTacticSlots)) 
            then
                
                scratchPadCosts[abilityData.tacticType] = scratchPadCosts[abilityData.tacticType] + abilityData.numTacticSlots;
                nextIndex = nextIndex + 1;
            end
        end
        
        -- Second out...does the player have enough slots remaining to equip this tactic?
        
        local finalSlots = scratchPadCosts[tacticData.tacticType] + tacticData.numTacticSlots;
        
        if (finalSlots > self.tacticsSlots[tacticData.tacticType]) then
            if( EA_ChatWindow )
            then
                local errorText = GetString( StringTables.Default.TEXT_TACTIC_SLOT_UNAVAILABLE )
                EA_ChatWindow.Print( errorText, SystemData.ChatLogFilters.MISC )
            end 
            return;
        end
            
        -- Put the new tactic at the end of the list, or replace the tactic at the swappedIndex with this one.
        
        if (-1 ~= swappedIndex) then
            scratchPadTactics[swappedIndex] = incomingTacticId;
        else
            scratchPadTactics[nextIndex]    = incomingTacticId;
        end
                
        -- And finally...the holy grail...actually update the list!
        UpdateButtonsFromTacticsList (self, scratchPadTactics);
        
        self:SaveAndActivate();
    end
end

function TacticsButtons:RemoveTacticFromButton(button)
    local tacticIdThatWillBeRemoved = button:GetId ();
    
    for buttonId, button in pairs (self.tacticsButtons) do
        if (button:GetId () == tacticIdThatWillBeRemoved) then
            button:SetId (nil);
        end
    end
    self:SaveAndActivate();
end

function TacticsButtons:SaveAndActivate()
    TacticsSetMenu:SaveSet ();
    ActivateTactics (self:GetList ());
    TacticsEditor.NeedsTacticsGuess = false;
end

-----------------------------------------------------------------------------------------
-- Tactics Tooltip Window Definition
--
-- This table is globally visible so that other interface elements can
-- create tactics set tooltips.
-----------------------------------------------------------------------------------------
TacticsSetTooltip =
{
    numButtons              = 0,
    tacticsButtons          = {},
    tacticsSlots            = {},
    currentSet              = 0,
    windowName              = "TacticsSetTooltip",
    lineWindowName          = "TacticTooltipButton",
    mouseoverButtonName     = "EA_TacticsEditorContentsSetMenuMenuButton",
};

-- Entry point.    Creates a layout of tactics buttons for use as a tooltip display;  (number) desiredSet = which set you want information about.
function TacticsSetTooltip:CreateTooltip(desiredSet)
    if (nil ~= desiredSet) then
        self.currentSet = desiredSet;
    end
    
    tacticsSet = GetTacticsSet (desiredSet); -- tacticsSet is a list of the tactics to display in the tooltip

    local tooltipWidth      = 0;
    local tooltipHeight     = 0;    
    local numTacticsInSet   = 0;
    local currentButtonId   = 1;
    local emptySetLabel     = self.windowName.."EmptySetText";
    
    if (nil ~= tacticsSet) then
        numTacticsInSet = table.getn (tacticsSet);
    end
    
    self:UnUseAll (true);
    
    if (numTacticsInSet > 0) then        
        for key, tacticsAbilityId in pairs (tacticsSet) do
        
            local abilityData = Player.GetAbilityData (tacticsAbilityId, GameData.AbilityType.TACTIC);
            local abilityName = L"";

            if (nil ~= abilityData and nil ~= abilityData.name) then
                abilityName = abilityData.name;
            end
            
            local button = self:GetUnusedButton ();
            
            if (button ~= nil) then
                local buttonName = button:GetName ();               

                LabelSetText (buttonName.."TacticName", abilityName);
                button:SetId (abilityData);
                
                local imgWidth, imgHeight = WindowGetDimensions (buttonName);
                local txtWidth, txtHeight = LabelGetTextDimensions (buttonName.."TacticName");
                                
                local totalWidth    = imgWidth + txtWidth + HORIZONTAL_BUTTON_SPACING;  
                local totalHeight   = math.max (imgHeight, txtHeight) + VERTICAL_BUTTON_SPACING;

                if (totalWidth > tooltipWidth) then
                    tooltipWidth = totalWidth;
                end

                tooltipHeight = totalHeight + tooltipHeight;
                WindowSetShowing (buttonName, true);
            end
        end
        
    else        
        tooltipWidth, tooltipHeight = LabelGetTextDimensions (emptySetLabel);
    end
    
    WindowSetShowing (emptySetLabel, numTacticsInSet == 0);
    
    local actionWidth, actionHeight = LabelGetTextDimensions (self.windowName.."ActionText");
    
    local c_ACTION_SPACING = 10; -- give it some spacing...let the tooltip breathe!
    
    if (actionWidth > tooltipWidth) then
        tooltipWidth = actionWidth;
    end
    
    tooltipWidth    = tooltipWidth + (BORDER_SIZE * 2);
    tooltipHeight   = tooltipHeight + actionHeight + c_ACTION_SPACING + (BORDER_SIZE * 2);
            
    WindowSetDimensions (self.windowName, tooltipWidth, tooltipHeight);
end

-- Creates a layout of tactics buttons for use as a tooltip display.    currentSet -  Which set you want information about. 
function TacticsSetTooltip:Initialize()
    setmetatable(self, {__index = TacticsButtons})
    -- Leverage the existing tactics button initializer, but pass in
    -- the tooltip's table so that the correct anchoring function is called.
    --InitializeTacticsButtons (self); -- call TacticsButtons:Initialize, but pass self as first parameter...
    getmetatable(self).__index.Initialize(self);
    
    WindowSetTintColor(self.windowName.."BackgroundInner", 0, 0, 0);
    WindowSetAlpha(self.windowName.."BackgroundInner", .7);
    
    -- Initialize the static text labels on the tooltip
    LabelSetText (self.windowName.."EmptySetText", GetString (StringTables.Default.LABEL_EMPTY_TACTICS_SET));
    LabelSetText (self.windowName.."ActionText", GetString (StringTables.Default.LABEL_PLAYER_TACTICS_LOADOUT_INSTRUCTIONS));
end

-- Creates a single line of the tactics set tooltip; tacticsAbilityId = ability to slot on this button.
function TacticsSetTooltip:CreateButton(tacticsType)
    local buttonId = self.numButtons + 1;
    
    if (buttonId > GameData.MAX_TACTICS_SLOTS) then
        DEBUG (L"TacticsSetTooltip:CreateButton: Trying to make too many tactics slots.");
        return nil;
    end
    
    local buttonName = self.lineWindowName..buttonId;
    
    if (DoesWindowExist (buttonName) == true) then
        DEBUG (L"The window: "..towstring (buttonName)..L" already exists, please destroy it first.");
        return nil;
    end
    
    CreateWindowFromTemplate (buttonName, self.lineWindowName, self.windowName);
    
    if (DoesWindowExist (buttonName) == false) then
        DEBUG (L"Unable to create window: "..towstring (buttonName));
        return nil;
    end
        
    return (self:AddButton (buttonId, buttonName, tacticsType, nil));
end

-- button = which button you would like to anchor; must be created through the proper channels.
function TacticsSetTooltip:AnchorButton(button)
    local previousButtonId = self.numButtons - 1;
    
    if (previousButtonId < 0) then
        DEBUG (L"AnchorTacticsTooltipButton: Create your button through the correct method.");
        return;
    end
    
    -- Sorry for the hardcoding...
    local anchorToWindow    = self.windowName
    local offsetX           = BORDER_SIZE;
    local offsetY           = BORDER_SIZE;
    local relativePoint     = "topleft";
    local point             = "topleft";
    
    if (previousButtonId > 0) then
        anchorToWindow  = self.lineWindowName..previousButtonId;
        offsetX         = 0;
        offsetY         = VERTICAL_BUTTON_SPACING;
        relativePoint   = "top";
        point           = "bottom";
    end
    
    WindowClearAnchors (button.name);
    WindowAddAnchor (button.name, point, anchorToWindow, relativePoint, offsetX, offsetY);
end

-- This needs to be overridden, so that it ignores tactic slot type, and just takes the next empty slot.  Otherwise there can be vertical gaps between the icons.
function TacticsSetTooltip:GetUnusedButton ()
    for i = 1, self.numButtons do  
        local currentButton = self.tacticsButtons[i];
           
        if (nil ~= currentButton) and (currentButton:GetUsed () == false) then
           return (currentButton);
        end
    end

    return (nil);
end

-----------------------------------------------------------------------------------------
-- TacticsEditor Global Functions 
-----------------------------------------------------------------------------------------


function TacticsEditor.Initialize ()

    -- Register for tactics updates and combat...
    WindowRegisterEventHandler( "EA_TacticsEditor", SystemData.Events.PLAYER_ACTIVE_TACTICS_UPDATED, "TacticsEditor.HandleActiveTacticsUpdated");
    WindowRegisterEventHandler( "EA_TacticsEditor", SystemData.Events.PLAYER_NUM_TACTIC_SLOTS_UPDATED, "TacticsEditor.UpdateTactics");
    WindowRegisterEventHandler( "EA_TacticsEditor", SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "TacticsEditor.UpdateCombatFlag");
    WindowRegisterEventHandler( "EA_TacticsEditor", SystemData.Events.PLAYER_DEATH_CLEARED, "TacticsEditor.HandlePlayerDeathCleared");
    WindowRegisterEventHandler( "EA_TacticsEditor", SystemData.Events.LOADING_END, "TacticsEditor.HandleLoadingEnd");
    WindowRegisterEventHandler( "EA_TacticsEditor", SystemData.Events.INTERFACE_RELOADED, "TacticsEditor.UpdateTactics");
    WindowRegisterEventHandler( "EA_TacticsEditor", SystemData.Events.PLAYER_BLOCKED_ABILITIES_UPDATED, "TacticsEditor.UpdateBlockedTactics");
    WindowRegisterEventHandler( "EA_TacticsEditor", SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED, "TacticsEditor.OnSingleAbilityUpdated" )
    
    -- Initialize internal data and dynamically created window controls...
    TacticsSetMenu:Initialize (TacticsButtons);
    TacticsButtons:Initialize ();
    TacticsEditor.UpdateTactics (); -- TacticsSetMenu.currentSet is initialized to an invalid set, and this sets it to something harmless
    
    -- Initialize the tooltip window for tactics sets, to be made available to external scripts
    -- through the table TacticsSetTooltip.
    CreateWindow (TacticsSetTooltip.windowName, false);
    TacticsSetTooltip:Initialize ();
    
    -- In case this is a ui refresh of some type:
    TacticsEditor.UpdateCombatFlag();
    
    -- GetActiveTactics will not work yet (the SetMenu ComboBox is initiallized to item -1), so GuessAboutActiveSet will not work yet either.
    -- Guessing is performed when active tactics are first updated, with the function TacticsEditor.GuessTacticsIfNeeded.
    
    TacticsEditor.UpdateTutorial()
    
end

function TacticsEditor.HandlePlayerDeathCleared()
    TacticsEditor.TimeUntilEnable = 0;
end

function TacticsEditor.HandleLoadingEnd()
    if( not TacticsEditor.GuessTacticsIfNeeded() )
    then
        TacticsButtons:Update();
    end
end

function TacticsEditor.HandleActiveTacticsUpdated()
    if( not TacticsEditor.GuessTacticsIfNeeded() )
    then
        UpdateButtonsFromTacticsList( TacticsButtons, GetActiveTactics() )
    end
end

-- TacticsEditor.NeedsTacticsGuess is initialized to true at the top of the file, and set to false when the user interacts with the window,
-- i.e. in these functions:  OnSetMenuSelectionChanged, InternalDropTacticOnButton, OnActiveTacticRButtonDown.
-- After such a function, the TacticsSetMenu should always know what the active set is without guessing (until the next reload).
-- This methodology was chosen because:
--      1. GetActiveTactics returns nil during TacticsEditor.Initialize, so guessing will return a bad set
--      2. guessing on every update to the active tactics is unnecessary and can lead to undesireable behavior, and  
--      3.  active tactics are added one at a time immediately after TacticsEditor.Initialize, so guessing on only the first active tactics update may result in guessing based on an incomplete tactics set. 
function TacticsEditor.GuessTacticsIfNeeded()
    if (TacticsEditor.NeedsTacticsGuess) then
        TacticsSetMenu.currentSet = GuessAboutActiveSet();

        if (TacticsSetMenu.currentSet == INVALID_TACTICS_SET) then
            TacticsSetMenu.currentSet = 0;
            UpdateButtonsFromTacticsList (TacticsButtons, {})
            -- Now, if they begin editing this, it will still be able to save (overwriting set 0).
        else
            TacticsButtons:Update();
        end
        ButtonSetText ("EA_TacticsEditorContentsSetMenuSelectedButton", L""..(TacticsSetMenu.currentSet+1));
        
        return true
    end
    
    return false
end

local function IsTacticSlotBlocked( slot )
	local allowedNumTacticSlots = math.min(math.max( math.floor( GameData.Player.battleLevel / 8 ), 1 ), 4)
	if( slot > allowedNumTacticSlots )
	then
		return true
	end
	return false
end

local function UpdateBlockedTacticSlots()
	
	local currentNumTacticSlots = TacticsButtons.tacticsSlots[GameData.TacticType.CAREER]

	for i = 1, currentNumTacticSlots
	do
		local tint = DefaultColor.ZERO_TINT
		local isBlocked = IsTacticSlotBlocked( i ) 
		local currentButton = TacticsButtons.tacticsButtons[i];
		currentButton:SetBlocked( isBlocked )
		if( isBlocked)
		then
			tint = DefaultColor.RED
		end
		WindowSetTintColor( "TacticButton"..i, tint.r, tint.g, tint.b )
	end
end

function TacticsEditor.UpdateBlockedTactics()

	-- Also tint all visible tactic slots that are blocked, for the players effective level	
	UpdateBlockedTacticSlots()

	-- Tint all blocked tactic abilities
	local currentTactics = TacticsButtons:GetList()
	for i, tacticId in pairs( currentTactics )
	do
		local currentButton = TacticsButtons.tacticsButtons[i];
		if( not currentButton:GetBlocked() )
		then
			Player.TintWindowIfAbilityIsBlocked( "TacticButton"..i, tacticId, GameData.AbilityType.TACTIC )
		end
	end
end

function TacticsEditor.Shutdown ()
    TacticsButtons:Shutdown ();
    TacticsSetTooltip:Shutdown ();

    -- There is not currently a TacticsSetMenu:Shutdown, no reason to call it...
end


-- Called in response to an update tactics event to determine whether or not the number of tactics slots displayed matches the number of tactics slots the player actually has.
-- (table) playerSlots is intended to be what GetNumTacticsSlots returns.
local function ReInitializeTacticsButtonsIfNecessary (playerSlots)
    for tacticType, numSlots in pairs (TacticsButtons.tacticsSlots) do
        if ((nil == playerSlots[tacticType]) or (numSlots ~= playerSlots[tacticType])) then
            TacticsButtons:Initialize ();
            TacticsSetTooltip:Initialize ();
            return;
        end
    end
end

-- TacticsEditor Internal function.  Exposed at a global scope so that it can be called from the client.
function TacticsEditor.UpdateTactics()
    ReInitializeTacticsButtonsIfNecessary (GetNumTacticsSlots ());
    
    
    -- For UI reloads, this will find a correct set if one exists:
    if (TacticsSetMenu.currentSet == INVALID_TACTICS_SET) then
        TacticsSetMenu.currentSet = GuessAboutActiveSet();
    end
    
    -- The first time the user logs back in, however, GetActiveTactics will yield nil; GuessAboutActiveSet will then yield INVALID_TACTICS_SET,
    -- So we need to set the tactics editor to something harmless.
    -- If there are any currently active tactics, they will trigger the function TacticsEditor.GuessTacticsIfNeeded later in the loading process.
    if (TacticsSetMenu.currentSet == INVALID_TACTICS_SET) then
        TacticsSetMenu.currentSet = 0;
        UpdateButtonsFromTacticsList (TacticsButtons, {})
        -- Now, if they begin editing this, it will still be able to save (overwriting set 0).
    
    -- Otherwise, GuessAboutActiveSet returned something reasonable, and we can just update the buttons.
    else
        TacticsButtons:Update ();
    end

    ButtonSetText ("EA_TacticsEditorContentsSetMenuSelectedButton", L""..(TacticsSetMenu.currentSet+1)); -- at this point we need to merge currentSet and currentActiveSet
    

     -- Update potential blocked tactic slots depending on players current battle level.
     -- Needs to be done here, since we might have received a new tactic slot after leveling up.
     TacticsEditor.UpdateBlockedTactics()
end

function TacticsEditor.OnSingleAbilityUpdated( abilityId, abilityType )
    if ( abilityType == GameData.AbilityType.TACTIC )
    then
        TacticsEditor.UpdateTutorial()
    end
end

function TacticsEditor.UpdateTutorial()
    EA_AdvancedWindowManager.UpdateWindowShowing( "EA_TacticsEditorContents", EA_AdvancedWindowManager.WINDOW_TYPE_TACTICS )
end


-----------------------------------------------------------------------------------------
-- TacticsEditor Event Handlers
-----------------------------------------------------------------------------------------

local function IsTacticBeingDroppedFromCursor ()
 
    if (not Cursor.IconOnCursor()) then             
        return (false);
    end

    if (Cursor.IconOnCursor() and Cursor.Data.Source == Cursor.SOURCE_ACTION_LIST) then
        -- Only Tactic Abilities can be dropped on the active tactic slots
        local abilityData = Player.GetAbilityData (Cursor.Data.ObjectId, Player.AbilityType.TACTIC);
        
        if (abilityData.moraleLevel > 0) then
            AlertTextWindow.AddLine (SystemData.AlertText.Types.DEFAULT, GetString (StringTables.Default.TEXT_MORALE_DROP_ERROR));
            return (false);
        end     
        
        if (abilityData.numTacticSlots == 0) then
            AlertTextWindow.AddLine (SystemData.AlertText.Types.DEFAULT, GetString( StringTables.Default.TEXT_ACTION_DROP_ERROR));
            return (false);
        end
    end
    
    return (true);
end

local function InternalAddOrSwapTactic (incomingTactic, button)
    if (TacticsEditor.isDisabled) then
        return;  
    end

    local currentTactic = 0;
    
    if (nil == button) then
        -- If button is passed in as nil, then it's up to this function
        -- to find an available button (not worrying about the type.)
        
        -- Find the first available button...if there's nothing available
        -- just bail out...that's right, no swapping when tactics are full.
        -- The user has to do that manually.
        
        button = TacticsButtons:GetEmptyButton ();
        
        if (nil == button) then
            -- String Table to console?  Alert Text?
            DEBUG (L"No remaining tactics slots.");
            return;
        end
    end
    
    if (nil ~= button.GetId) then
        currentTactic = button:GetId ();  
    end

    -- InternalDropTacticOnButton handles updates to the server, as it is also handles adding tactics from Abilities Window and NewAbilityHandler.
    TacticsButtons:DropTacticOnButton(button, incomingTactic);
end

function TacticsEditor.OnActiveTacticLButtonDown (flags, x, y)
    if (TacticsEditor.isDisabled) then
        return;    
    end
    
    local button = TacticsButtons:GetButtonForId (WindowGetId (SystemData.ActiveWindow.name));
    
    if (nil == button) then
        DEBUG (L"TacticsEditor.OnActiveTacticLButtonDown: Unknown button id for: "..towstring (SystemData.ActiveWindow.name));
        return;
    end

    if (IsTacticBeingDroppedFromCursor () == true) then
        -- This function also allows the user to save.
        InternalAddOrSwapTactic (Cursor.Data.ObjectId, button);
        
        -- It's tempting to set the tactic icon here, but the server will return the message soon enough...
        -- this just forces the clear.
        Cursor.Drop (nil);
    end
end

function TacticsEditor.OnActiveTacticRButtonDown (flags, x, y)
    if (TacticsEditor.isDisabled) then
        return;  
    end

    local button = TacticsButtons:GetButtonForId (WindowGetId (SystemData.ActiveWindow.name));
    
    if (nil == button) then
        DEBUG (L"TacticsEditor.OnActiveTacticRButtonDown: Unknown button id for: "..towstring (SystemData.ActiveWindow.name));
        return;
    end
    
    if (button ~= nil and button:GetId () ~= 0 ) then
        TacticsButtons:RemoveTacticFromButton (button);
    end   
end

function TacticsEditor.OnMouseoverActiveTactic (flags, x, y)
    local button = TacticsButtons:GetButtonForId (WindowGetId (SystemData.ActiveWindow.name));
    if (button == nil) then
        return;
    end
    
    if (button:GetId () ~= 0) then    
        local actionText    = GetString (StringTables.Default.TEXT_R_CLICK_TO_REMOVE);
        local abilityData   = Player.GetAbilityData (button:GetId (), Player.AbilityType.TACTIC);
        
        local anchor = nil
        if( DoesWindowExist( "MouseOverTargetWindow" ) and SystemData.Settings.GamePlay.staticAbilityTooltipPlacement )
        then
            anchor = Tooltips.ANCHOR_MOUSE_OVER_TARGET_WINDOW
        else
            anchor = ANCHOR_ABILITY_TOOLTIP
        end
        
        -- Override the interaction text if the tactic is blocked
        if( abilityData and Player.IsAbilityBlocked( abilityData.id, abilityData.abilityType ))
        then
            actionText = GetString( StringTables.Default.TEXT_BLOCKED_ABILITY_DESC )
        end
        
        Tooltips.CreateAbilityTooltip (abilityData, SystemData.ActiveWindow.name, anchor, actionText);
    else
        if (button.tacticType == nil or EmptyTacticsData[button.tacticType] == nil) then
            Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name, AVAIL_SLOT_TEXT);
        else
            local tooltipText = EmptyTacticsData[button.tacticType].Description
            if( button:GetBlocked() )
            then
                tooltipText = GetString( StringTables.Default.TEXT_BLOCKED_TACTIC_SLOT )
            end
            Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, tooltipText );
        end
        Tooltips.Finalize ();
        Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP);
        
        -- If mousing over an empty slot while the set menu is already closed, then the next left click on an empty slot should open the set menu.
        if(ComboBoxIsMenuOpen("EA_TacticsEditorContentsSetMenu") == false) then
            TacticsEditor.openMenuOnNextClick = true;
        end
    end
end

function TacticsEditor.OnTacticSlotLButtonUp(flags, x, y)
    local button = TacticsButtons:GetButtonForId (WindowGetId (SystemData.ActiveWindow.name));
    if (button == nil) then
        return;
    end
    
    -- Open the set menu if this is an empty tactic slot, and the menu was not opened last time an empty slot was clicked.
    -- If we just open every time an empty slot is clicked, then the menu closes on the L button down event (due to C++ code)
    -- and then opens on the LButtonUp, which is probably not what the user is expecting to see.
    if (button:GetId() == 0) and (TacticsEditor.openMenuOnNextClick) then
        ComboBoxExternalOpenMenu("EA_TacticsEditorContentsSetMenu");
    end
    TacticsEditor.openMenuOnNextClick = not TacticsEditor.openMenuOnNextClick;
end

-- Tracks the currently loaded set, and updates active tactics accordingly.
-- (number) currentSelection is what's selected; remember this is 1-based, not 0-based.
function TacticsEditor.OnSetMenuSelectionChanged (currentSelection)
    TacticsSetMenu.currentSet = currentSelection - 1;
    TacticsButtons:Update ();
    ActivateTactics (TacticsButtons:GetList ());
    
    ButtonSetText ("EA_TacticsEditorContentsSetMenuSelectedButton", L""..(TacticsSetMenu.currentSet+1));
    
    -- We will no longer need a guess as to which set is active.
    TacticsEditor.NeedsTacticsGuess = false;
end

function TacticsEditor.OnMouseOverSetMenu (flags, x, y)
    -- Trap the mouse over so that it will be handled and not pass on to windows under this one.
    -- This doesn't actually work yet...

    TacticsEditor.TacticsSetMenuTooltip()
end

local function TacticsTooltipUtility (text)
    Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name, text);
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP);
end

-- Called only by TacticsEditor.TacticsSetMenuTooltip, the OnMouseOver handler for the set menu.
-- Returns the 0-indexed set that is currently being moused over.  Should only be called when the mouse is over the set menu.
local function GetMousedOverSetMenuItem()

    local windowName = SystemData.ActiveWindow.name;
    
    if (windowName == TacticsSetTooltip.mouseoverButtonName.."1") then
        return 0;
    elseif (windowName == TacticsSetTooltip.mouseoverButtonName.."2") then
        return 1;
    elseif (windowName == TacticsSetTooltip.mouseoverButtonName.."3") then
        return 2;
    elseif (windowName == TacticsSetTooltip.mouseoverButtonName.."4") then
        return 3;
    else
        return 4;
    end
end

-- Used for when mousing over "TacticsSetMenuButton" (inherited by in-game window "EA_TacticsEditorContentsSetMenuSelectedButton").
function TacticsEditor.TacticsSetMenuTooltip ()

    -- Make a tooltip if the user cannot edit.
    if (GameData.Player.inCombat) then
        TacticsTooltipUtility (CANNOT_EDIT_IN_COMBAT);
    
    -- Make a countdown tooltip telling the user they cannot edit immediately after combat (the only time when they are not in combat but cannot edit).
    elseif (TacticsEditor.isDisabled) then
        TacticsTooltipUtility (GetStringFormat (StringTables.Default.TEXT_CANNOT_EDIT_TACTICS_AFTER_COMBAT, {math.ceil (TacticsEditor.TimeUntilEnable) } ) );
    
    -- Make a tooltip telling the user they can switch tactics by clicking the set menu.
    elseif (not ComboBoxIsMenuOpen("EA_TacticsEditorContentsSetMenu")) then
        TacticsTooltipUtility (CLICK_TO_SWITCH_TACTICS);
    
    -- Make a tooltip  for the highlighted item of the open set menu.
    else
        TacticsSetTooltip:CreateTooltip(GetMousedOverSetMenuItem());
        Tooltips.CreateCustomTooltip (SystemData.ActiveWindow.name, TacticsSetTooltip.windowName);
        Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_RIGHT);
    end
end

-- Handler to prevent the user from switching tactics sets when the the Tactics Editor is disabled.
function TacticsEditor.OnLButtonUpSetMenu (flags, x, y)
    if (TacticsEditor.isDisabled) then
        return;    
    end
end

-- Called by AbilitiesWindow.ActionRButtonDown (user right-clicks on a tactic to add), and NewAbilityHandler.AttemptToAddTactic (user learns a new tactic).
function TacticsEditor.ExternalAddTactic (tacticId)
    InternalAddOrSwapTactic (tacticId, nil);
end

-- Called by the Action Bar Cluster Manager.
function TacticsEditor.CreateBar (windowName)
    CreateWindowFromTemplate (windowName, "EA_TacticsEditor", "Root");
    FrameForLayoutEditor:CreateFrameForExistingWindow( windowName )
end

-- Registered handler for when GameData.Player.inCombat changes.
function TacticsEditor.UpdateCombatFlag ()

    -- Engaging in combat:  Disable the tactics editor.
    if ((not TacticsEditor.isDisabled) and GameData.Player.inCombat) then
        TacticsEditor.isDisabled = true;
        ComboBoxSetDisabledFlag ("EA_TacticsEditorContentsSetMenu", true);
    end
    
    -- Disengaging from combat:  Start the timer for when to re-enable the tactics editor.
    -- This is ok because this function is only called when the GameData.Player.inCombat value *changes*, and not for every moment these conditions hold true.
    if ((TacticsEditor.isDisabled) and (not GameData.Player.inCombat)) then
        TacticsEditor.TimeUntilEnable = TacticsEditor.TIME_DISABLED_AFTER_COMBAT;
    end
end

-- OnUpdate handler for "EA_TacticsEditor" window.
function TacticsEditor.Update (timePassed)

    -- Post-combat cooldown logic:
    if (TacticsEditor.TimeUntilEnable > 0) then
        TacticsEditor.TimeUntilEnable = TacticsEditor.TimeUntilEnable - timePassed;     
        
        -- Force a tooltip update, if the mouse is over the set menu.
        if("EA_TacticsEditorContentsSetMenu" == SystemData.MouseOverWindow.name) then
            TacticsEditor.TacticsSetMenuTooltip ()
	  	end
        
    -- If it is disabled and it no longer should be (i.e. TacticsEditor.TimeUntilEnable <= 0):
    elseif (TacticsEditor.isDisabled and (not GameData.Player.inCombat)) then
        TacticsEditor.TimeUntilEndable = 0;
        TacticsEditor.isDisabled = false;
        ComboBoxSetDisabledFlag ("EA_TacticsEditorContentsSetMenu", false);
        
        -- Force a tooltip update, if the mouse is over the set menu.
        if("EA_TacticsEditorContentsSetMenu" == SystemData.MouseOverWindow.name) then
            TacticsEditor.TacticsSetMenuTooltip ()
	  	end
    end
end

function TacticsEditor.OnInitializeCustomSettings ()
    if (ActionBarClusterManager and TACTICS_WINDOW_NAME)
    then
        ActionBarClusterManager:OnInitializeCustomSettingsForFrame (GetFrame (TACTICS_WINDOW_NAME))
    end
end
