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

	function mod:postFireBomb(bomb, player)
		bomb.Flags = bomb.Flags
		
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
			--if player then
				mod:postFireBomb(bomb[1], bomb[2])
			--end
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
			bombsToBePostFired[bomb.InitSeed] = {bomb, player}
		end
	end)
	
	mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, bomb)
		if bombsToBePostFired[bomb.InitSeed] then
			bombsToBePostFired[bomb.InitSeed] = nil
		end
	end, EntityType.ENTITY_BOMBDROP)
	

end