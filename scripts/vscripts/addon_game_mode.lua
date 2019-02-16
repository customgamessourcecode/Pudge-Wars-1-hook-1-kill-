-- Generated from template

if CustomGameMode == nil then
   CustomGameMode = class({})
 end
 
XP_PER_LEVEL_TABLE = {
    0,-- 1
    0,-- 2
    0,-- 3
    0,-- 4
	0,
	0,
	0,
	0
} 

function Precache( context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_pudge", context)
	PrecacheUnitByNameSync("npc_dota_hero_pudge", context)
	
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_puck", context)
	PrecacheUnitByNameSync("npc_dota_hero_puck", context)
	
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_meepo", context)
	PrecacheUnitByNameSync("npc_dota_hero_meepo", context)
	
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_tinker", context)
	PrecacheUnitByNameSync("npc_dota_hero_tinker", context)
end

 
 function Activate ()
   GameRules.CustomAddon = CustomGameMode()
   GameRules.CustomAddon:InitGameMode(100)
 end
 
 function CustomGameMode:InitGameMode (killLimit)
	self.killLimit = killLimit
	ListenToGameEvent("entity_killed", Dynamic_Wrap(CustomGameMode, "OnEntityKilled"), self)
	ListenToGameEvent("player_disconnect", Dynamic_Wrap(CustomGameMode, "OnDisconnect"), self)
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(CustomGameMode, "OnReconnect"), self)
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(CustomGameMode,"OnPlayerPickHero"), self)
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CustomGameMode,"OnStart"), self)
	
	
	mode = GameRules:GetGameModeEntity()
	mode:SetUseCustomHeroLevels(true)
	mode:SetCustomHeroMaxLevel(8)
	mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	mode:SetKillingSpreeAnnouncerDisabled(true)
	mode:SetDaynightCycleDisabled(true)
    mode:SetHUDVisible(9,false)
	mode:SetHUDVisible(23,false)
	mode:SetBuybackEnabled(false)
end
 
 function CustomGameMode:OnEntityKilled ()
   if PlayerResource:GetTeamKills(DOTA_TEAM_GOODGUYS) == self.killLimit then
     GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
   elseif PlayerResource:GetTeamKills(DOTA_TEAM_BADGUYS) == self.killLimit then
     GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
   end
 end
 
 function CustomGameMode:OnStart(keys)
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS  then
			local ii = 0
			for ii = 0, 9 do
				if ( PlayerResource:IsValidPlayer( ii ) ) then
					local player = PlayerResource:GetPlayer(ii)
					if player ~= nil then
						local h = player:GetAssignedHero()
						if h~= nil then
							h:RemoveModifierByName("modifier_tutorial_sleep")
						end
					end
				end
			end	
	end
 end 
 
 function CustomGameMode:OnDisconnect(keys)
	local hero = PlayerResource:GetPlayer(keys.PlayerID):GetAssignedHero()
	hero:RespawnHero(false,false)
	hero:AddNewModifier(hero, nil, "modifier_phoenix_supernova_hiding", nil)
 end

 function CustomGameMode:OnPlayerPickHero(keys)
 	local newState = GameRules:State_Get()
	local hero = EntIndexToHScript(keys.heroindex)
	if newState == DOTA_GAMERULES_STATE_PRE_GAME  then
		hero:AddNewModifier(hero, nil, "modifier_tutorial_sleep", nil)
	end
	hero:RemoveItem(hero:GetItemInSlot(0))
	hero:RemoveItem(hero:GetItemInSlot(1))
	
 end

 function CustomGameMode:OnReconnect(keys)
	local hero = PlayerResource:GetPlayer(keys.PlayerID):GetAssignedHero()
	hero:AddNewModifier(hero, nil, "modifier_phoenix_supernova_hiding", {duration = 0.00})
 end
   