----------------------------------------------------------------
-- Global Functions
----------------------------------------------------------------

Sound = {}


------------------------------------------------------------------------------
-- THESE ARE ONLY SOUNDS CURRENLTY EXPOSED FROM C++ THAT ARE NOT DEPRECATED 

-- General interface sounds
Sound.BUTTON_CLICK               = GameData.Sound.BUTTON_CLICK	
Sound.ICON_PICKUP                = GameData.Sound.ICON_PICKUP	
Sound.ICON_CLEAR                 = GameData.Sound.ICON_CLEAR	
Sound.ICON_DROP                  = GameData.Sound.ICON_DROP		
Sound.WINDOW_OPEN                = GameData.Sound.WINDOW_OPEN	
Sound.WINDOW_CLOSE               = GameData.Sound.WINDOW_CLOSE	
Sound.POSITIVE_FEEDBACK          = GameData.Sound.POSITIVE_FEEDBACK	
Sound.NEGATIVE_FEEDBACK          = GameData.Sound.NEGATIVE_FEEDBACK
Sound.GENERAL_NOTIFICATION       = GameData.Sound.GENERAL_NOTIFICATION
Sound.ACTION_FAILED              = GameData.Sound.ACTION_FAILED				-- 200

	
-- This sound is exposed from C++ but not used in UI yet
-- Sound.ITEM_MOVE		= GameData.Sound.ITEM_MOVE	

-- In-game specific interface sounds
Sound.TARGET_SELECT              = GameData.Sound.TARGET_SELECT	
Sound.TARGET_DESELECT            = GameData.Sound.TARGET_DESELECT
Sound.MONEY_LOOT                 = GameData.Sound.LOOT_MONEY
Sound.AUCTION_HOUSE_CREATE_AUCTION	= GameData.Sound.AUCTION_HOUSE_CREATE_AUCTION
Sound.OPEN_WORLD_MAP             = GameData.Sound.OPEN_WORLD_MAP            -- 313
Sound.CLOSE_WORLD_MAP            = GameData.Sound.CLOSE_WORLD_MAP           -- 314
Sound.MINI_MAP_ZOOM_IN           = GameData.Sound.MINI_MAP_ZOOM_IN			-- 107
Sound.MINI_MAP_ZOOM_OUT          = GameData.Sound.MINI_MAP_ZOOM_OUT			-- 108


--In-game notifications	
Sound.PUBLIC_TOME_UNLOCKED       = GameData.Sound.PUBLIC_TOME_UNLOCKED		-- 230
Sound.RVR_FLAG_OFF               = GameData.Sound.RVR_FLAG_OFF				-- 217
Sound.RVR_FLAG_ON                = GameData.Sound.RVR_FLAG_ON				-- 218
Sound.RENOWN_RANK_UP             = GameData.Sound.RENOWN_RANK_UP            -- 316
Sound.INFLUENCE_RANK_UP          = GameData.Sound.INFLUENCE_RANK_UP         -- 317
Sound.PLAYER_RECEIVES_TELL       = GameData.Sound.PLAYER_RECEIVES_TELL      -- 321
Sound.RECEIVED_NEW_MAIL_FROM_PLAYER = GameData.Sound.RECEIVED_NEW_MAIL_FROM_PLAYER -- 322
Sound.RECEIVED_NEW_MAIL_FROM_AUCTION = GameData.Sound.RECEIVED_NEW_MAIL_FROM_AUCTION -- 323
Sound.SCENARIO_INVITE            = GameData.Sound.SCENARIO_INVITE           -- 324
Sound.ADVANCE_RANK               = GameData.Sound.ADVANCE_RANK				-- 201
Sound.ADVANCE_TIER               = GameData.Sound.ADVANCE_TIER				-- 202

        
-- Trade Skill Sounds
Sound.APOTHECARY_CONTAINER_ADDED   = GameData.Sound.APOTHECARY_CONTAINER_ADDED		-- bottle clink. 
Sound.APOTHECARY_DETERMINENT_ADDED = GameData.Sound.APOTHECARY_DETERMINENT_ADDED	-- mortar & pestle. 
Sound.APOTHECARY_RESOURCE_ADDED    = GameData.Sound.APOTHECARY_RESOURCE_ADDED		-- three jars.
Sound.APOTHECARY_ADD_FAILED      = GameData.Sound.APOTHECARY_ADD_FAILED				-- item not accepted in jar. 
Sound.APOTHECARY_ITEM_REMOVED    = GameData.Sound.APOTHECARY_ITEM_REMOVED		    -- item removed
Sound.APOTHECARY_BREW_STARTED    = GameData.Sound.APOTHECARY_BREW_STARTED			-- brew button 
Sound.APOTHECARY_FAILED          = GameData.Sound.APOTHECARY_FAILED					-- brew failed. 
Sound.APOTHECARY_SUCCEEDED       = GameData.Sound.POSITIVE_FEEDBACK					-- NOTE: generic success sound

Sound.CULTIVATING_SEED_ADDED     = GameData.Sound.CULTIVATING_SEED_ADDED			-- plant seeds.
Sound.CULTIVATING_SOIL_ADDED     = GameData.Sound.CULTIVATING_SOIL_ADDED			-- add soil. 
Sound.CULTIVATING_WATER_ADDED    = GameData.Sound.CULTIVATING_WATER_ADDED			-- add water. 
Sound.CULTIVATING_NUTRIENT_ADDED = GameData.Sound.CULTIVATING_NUTRIENT_ADDED		-- add nutrients.
Sound.CULTIVATING_SUCCEEDED      = GameData.Sound.CULTIVATING_COMPLETED				-- crop has finished growing and ready for harvest
Sound.CULTIVATING_HARVEST_CROP   = GameData.Sound.CULTIVATING_HARVEST_CROP			-- harvest the crop.
Sound.CULTIVATING_ADD_FAILED     = GameData.Sound.CULTIVATING_ADD_FAILED		    -- invalid item, stage, or item above user's level




-- Window open and close triggers 
-- (in case we want to set them to something other than the default in the future
Sound.TOME_OPEN                  = GameData.Sound.WINDOW_OPEN	
Sound.TOME_CLOSE                 = GameData.Sound.WINDOW_CLOSE
Sound.BACKPACK_OPEN              = GameData.Sound.WINDOW_OPEN	
Sound.BACKPACK_CLOSE             = GameData.Sound.WINDOW_CLOSE	
Sound.CHARACTER_OPEN             = GameData.Sound.WINDOW_OPEN	
Sound.CHARACTER_CLOSE            = GameData.Sound.WINDOW_CLOSE	
Sound.CAREER_OPEN                = GameData.Sound.WINDOW_OPEN    
Sound.CAREER_CLOSE               = GameData.Sound.WINDOW_CLOSE	
Sound.MAIN_OPEN                  = GameData.Sound.WINDOW_OPEN  
Sound.MAIN_CLOSE                 = GameData.Sound.WINDOW_CLOSE  
Sound.HELP_OPEN                  = GameData.Sound.WINDOW_OPEN   
Sound.HELP_CLOSE                 = GameData.Sound.WINDOW_CLOSE	
Sound.GUILD_OPEN				 = GameData.Sound.WINDOW_OPEN		
Sound.GUILD_CLOSE				 = GameData.Sound.WINDOW_CLOSE		
Sound.TRADE_OPEN				 = GameData.Sound.WINDOW_OPEN		
Sound.TRADE_CLOSE				 = GameData.Sound.WINDOW_CLOSE		


-- Button Press triggers 
-- (in case we want to set them to something other than the default in the future


Sound.ENTER_GAME						   = GameData.Sound.BUTTON_CLICK	-- NOTE: FIX: Bad Name - this is actually the Character Select Screen - Create New Character Button 
Sound.PREGAME_PLAY_GAME_BUTTON             = GameData.Sound.BUTTON_CLICK		-- Character Select Screen - Play Game Button
Sound.PREGAME_CHAR_CREATE_CONTINUE_BUTTON  = GameData.Sound.BUTTON_CLICK		-- Character Create Screen - Continue Button  
Sound.PREGAME_CHAR_CREATE_BACK_BUTTON      = GameData.Sound.BUTTON_CLICK		-- Character Create Screen - Back Button 
Sound.PREGAME_CREATE_CHAR_BUTTON           = GameData.Sound.BUTTON_CLICK		-- Character Create Screen - Create Character Button 
        


------------------------------------------------------------------------------
-- THE SOUNDS BELOW ARE DEPRECATED 


Sound.BUTTON_OVER                = GameData.Sound.BUTTON_OVER			-- 2
Sound.MONEY_TRANSACTION          = GameData.Sound.MONETARY_TRANSACTION  -- 10 
Sound.TOME_TURN_PAGE             = GameData.Sound.TOME_TURN_PAGE    	-- 112

Sound.OBJECTIVE_CAPTURE          = GameData.Sound.OBJECTIVE_CAPTURE			-- 211
Sound.OBJECTIVE_LOSE             = GameData.Sound.OBJECTIVE_LOSE			-- 212
Sound.QUEST_ACCEPTED             = GameData.Sound.QUEST_ACCEPTED			-- 213
Sound.QUEST_ABANDONED            = GameData.Sound.QUEST_ABANDONED			-- 214
Sound.QUEST_COMPLETED            = GameData.Sound.QUEST_COMPLETED			-- 215
Sound.QUEST_OBJECTIVES_NEW       = GameData.Sound.QUEST_OBJECTIVES_NEW		-- 223
Sound.QUEST_OBJECTIVES_FAILED    = GameData.Sound.QUEST_OBJECTIVES_FAILED	-- 224
Sound.PUBLIC_QUEST_ADDED		 = GameData.Sound.PUBLIC_QUEST_ADDED		-- 225
Sound.PUBLIC_QUEST_UPDATED		 = GameData.Sound.PUBLIC_QUEST_UPDATED		-- 226
Sound.PUBLIC_QUEST_COMPLETED     = GameData.Sound.PUBLIC_QUEST_COMPLETED    -- 227
Sound.PUBLIC_QUEST_FAILED        = GameData.Sound.PUBLIC_QUEST_FAILED		-- 228
Sound.PUBLIC_QUEST_CYCLING       = GameData.Sound.PUBLIC_QUEST_CYCLING		-- 229

-- The Play Game button has been set to a regular button press sound, but it needs something more exciting
-- GameData.Sound.PREGAME_PLAY_GAME_BUTTON -- Character Select Screen - Play Game Button

-- Game specific interface sounds
Sound.ACTIVATE_GENERAL_ABILITY   = GameData.Sound.ACTIVATE_GENERAL_ABILITY	-- 103
Sound.ACTIVATE_MORALE_ABILITY    = GameData.Sound.ACTIVATE_MORALE_ABILITY	-- 104
Sound.LOOT_ALL                   = GameData.Sound.LOOT_ALL				-- 105
Sound.LOOT_SINGLE                = GameData.Sound.LOOT_SINGLE			-- 106
Sound.RELEASE_CORPSE             = GameData.Sound.RELEASE_CORPSE		-- 109

-- Game specific events
Sound.CAREER_POINT_CORE          = GameData.Sound.CAREER_POINT_CORE			-- 203
Sound.CAREER_POINT_SECONDARY     = GameData.Sound.CAREER_POINT_SECONDARY    -- 204
Sound.CAREER_POINT_SPECIALTY     = GameData.Sound.CAREER_POINT_SPECIALTY    -- 205
Sound.MORALE_LEVEL_1             = GameData.Sound.MORALE_ABILITY_1_UNLOCK   -- 206
Sound.MORALE_LEVEL_2             = GameData.Sound.MORALE_ABILITY_2_UNLOCK	-- 207
Sound.MORALE_LEVEL_3             = GameData.Sound.MORALE_ABILITY_3_UNLOCK	-- 208
Sound.MORALE_LEVEL_4             = GameData.Sound.MORALE_ABILITY_4_UNLOCK	-- 209
Sound.MORALE_LEVEL_5             = GameData.Sound.MORALE_ABILITY_5_UNLOCK	-- 210
Sound.RESPAWN                    = GameData.Sound.RESPAWN					-- 216
Sound.QUEST_OBJECTIVES_COMPLETED = GameData.Sound.QUEST_OBJECTIVES_COMPLETED -- 219
Sound.MORALE_LEVEL_UP            = GameData.Sound.MORALE_LEVEL_UP			-- 221
Sound.MORALE_LEVEL_DOWN          = GameData.Sound.MORALE_LEVEL_DOWN			-- 222
Sound.CAREER_CATEGORY_UPDATED    = GameData.Sound.PUBLIC_CAREER_POINTS_UPDATED   -- 231
Sound.CONVERSATION_TEXT_ARRIVED  = GameData.Sound.CONVERSATION_TEXT_ARRIVED -- 232
Sound.GROUP_PLAYER_ADDED		 = GameData.Sound.GROUP_PLAYER_ADDED		-- 233
Sound.SCENARIO_FANFARE_END       = GameData.Sound.SCENARIO_FANFARE_END		-- 998
Sound.BETA_WARNING               = GameData.Sound.BETA_WARNING				-- 999


function Sound.Play( id )

    -- Don't play sounds while loading
    if( SystemData.LoadingData.isLoading ) then
        return
    end

    if( id ~= nil ) then
        PlaySound( id )
        --DEBUG( L"soundutils.lua: Playing Sound: "..id )
    else
        DEBUG( L"EASystem_Utils//Source//SoundUtils.lua: Sound.Play() called with nil ID (maybe a type-o in constant name)" )
    end
end
