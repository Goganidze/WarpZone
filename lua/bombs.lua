return function(mod)

	local game = Game()

	local blockbombvars = {
		[BombVariant.BOMB_BIG] = true,
		[BombVariant.BOMB_DECOY] = true,
		[BombVariant.BOMB_TROLL] = true,
		[BombVariant.BOMB_SUPERTROLL] = true,
		[BombVariant.BOMB_THROWABLE] = true,
		[BombVariant.BOMB_GIGA] = true,
		[BombVariant.BOMB_GOLDENTROLL] = true,
		[BombVariant.BOMB_ROCKET] = true,
		[BombVariant.BOMB_ROCKET_GIGA] = true,
	}

	---@param bomb EntityBomb
	---@param player EntityPlayer
	function mod:postFireBomb(bomb, player)
		bomb.Flags = bomb.Flags
		
		if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_SPELUNKERS_PACK) then
			if WarpZone.DebugSpelunkersPackEffectType == 2 then
				local spawner = bomb.SpawnerEntity
				if not bomb.IsFetus and spawner and spawner.Index == player.Index
				and not player:IsHoldingItem() and bomb.Position:Distance(spawner.Position)<1 then
					player:TryHoldEntity(bomb)
				end
			elseif WarpZone.DebugSpelunkersPackEffectType == 1 then
				bomb:GetData().SpelunkerBomb = true
			end
		end
	end

	---@param player EntityPlayer
	function mod:postBombExplosion(bomb, player)
		local data = bomb:GetData()
		if data.SpelunkerBomb then
			WarpZone:SpelunkerBombEffect(bomb.Position)
		end
	end

	---@param player EntityPlayer
	function mod:MegaFetusRocketInit(rocket, player)
		local data = rocket:GetData()
		local rng = rocket:GetDropRNG()
		if WarpZone.DebugSpelunkersPackEffectType == 1 and player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_SPELUNKERS_PACK) then
			local rchance = (1-WarpZone.SPELUNKERS_PACK.FetusBasicChance) * math.max(0, player.Luck / WarpZone.SPELUNKERS_PACK.FetusMaxLuck)
			local luck = rchance >= 0.5 or WarpZone.SPELUNKERS_PACK.FetusBasicChance+rchance < rng:RandomFloat()
			if luck then
				data.SpelunkerBomb = true
			end
		end
	end

	--стырено из ff
	mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, typ, var, subt, pos, vel, spawner, seed)
		if typ == EntityType.ENTITY_BOMBDROP then
			if not blockbombvars[var] then
				if spawner then
					local player = WarpZone.TryGetPlayer(spawner)
	
					if player and player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_SPELUNKERS_PACK) then
						return {EntityType.ENTITY_BOMBDROP, WarpZone.SPELUNKERS_PACK.BOMBVAR, 0, seed}
					end
				end
			end
		end
	end)

	local bombsToBePostFired = {}

	function mod:testForPostFireBomb(ent)
		for _, bomb in pairs(bombsToBePostFired) do
			--local player = WarpZone.TryGetPlayer(bomb.SpawnerEntity)
			if bomb[2] then
				mod:postFireBomb(bomb[1], bomb[2])
			end
		end

		bombsToBePostFired = {}
	end
	mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.testForPostFireBomb)
	mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.testForPostFireBomb, FamiliarVariant.INCUBUS)
	mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.testForPostFireBomb, FamiliarVariant.SPRINKLER)
	mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.testForPostFireBomb, FamiliarVariant.TWISTED_BABY)
	mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.testForPostFireBomb, FamiliarVariant.BLOOD_BABY)
	mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.testForPostFireBomb, FamiliarVariant.UMBILICAL_BABY)
	mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.testForPostFireBomb, FamiliarVariant.CAINS_OTHER_EYE)

	mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, function(_, bomb)
		if bomb.Variant ~= BombVariant.BOMB_THROWABLE then
			local player = WarpZone.TryGetPlayer(bomb.SpawnerEntity)
			if not player then
				return
			end
			bomb:GetData().WarpZone_Player = player
			bombsToBePostFired[bomb.InitSeed] = {bomb, player}
		end
	end)
	
	mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, bomb)
		if bombsToBePostFired[bomb.InitSeed] then
			bombsToBePostFired[bomb.InitSeed] = nil
		end
	end, EntityType.ENTITY_BOMBDROP)
	
	mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, bomb)
		mod:postBombExplosion(bomb, bomb:GetData().WarpZone_Player)
	end,EntityType.ENTITY_BOMBDROP)

	mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, rocket)
		if rocket.FrameCount <= 1 
		and rocket.Parent and rocket.Parent.Type == EntityType.ENTITY_EFFECT and rocket.Parent.Variant == EffectVariant.TARGET then
			local player = WarpZone.TryGetPlayer(rocket.Parent.SpawnerEntity)
			if player then
				rocket:GetData().WarpZone_RocketPlayer = player
				mod:MegaFetusRocketInit(rocket, player)
			end
		end
	end, EffectVariant.ROCKET)

	mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, explosion)
		if explosion.SpawnerEntity and explosion.SpawnerType == EntityType.ENTITY_EFFECT 
		and explosion.SpawnerVariant == EffectVariant.ROCKET then
			local spawnerData = explosion.SpawnerEntity:GetData()
			if spawnerData.WarpZone_RocketPlayer then
				mod:postBombExplosion(explosion.SpawnerEntity, spawnerData.WarpZone_RocketPlayer)
			end
		end
	end, EffectVariant.BOMB_EXPLOSION)
end