return function(mod)
    local sfx = SFXManager()
    local Isaac = Isaac
    local game = Game()
    local Wtr = 20/13

    local bottleEntType = EntityType.ENTITY_PICKUP

    local spawndelay = 70
    WarpZone.SomeoneHasWaterBottle = nil
    WarpZone.BottleSpawnDelay = spawndelay

    ---@param player EntityPlayer
    function WarpZone.Bottle_PlayerUpdate(player)
        local unsave = player:GetData().WarpZone_unsavedata
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_FULL) then
            WarpZone.SomeoneHasWaterBottle = player
        end
        if Isaac.GetFrameCount()%10 == 0 and unsave.BottleBonus and unsave.BottleBonus > 0 then
            unsave.BottleBonus = unsave.BottleBonus - .05
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
    end

    ---@param ent EntityPickup
    function WarpZone.BottleUpdate(_,ent)
        local spr = ent:GetSprite()
        ent.Velocity = Vector(0,0)
        if ent.TargetPosition.X > 0 then
            ent.Position = ent.TargetPosition
        end
        if spr:IsFinished("Collect") then
            ent:Remove()
        end
        ent.Timeout = 60
    end
    WarpZone:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, WarpZone.BottleUpdate, WarpZone.WarpZoneTypes.PICKUP_WATERBOTTLE)

    ---@param ent Entity
    ---@param collider Entity
    function WarpZone.BottleColl(_,ent, collider)
        local player = collider:ToPlayer()
        if player then
            local unsave = player:GetData().WarpZone_unsavedata
            unsave.BottleBonus = unsave.BottleBonus or 0
            local val = 3.0/(unsave.BottleBonus+1.5)
            unsave.BottleBonus = unsave.BottleBonus and math.min(unsave.BottleBonus + val, 5) or 2
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            ent:GetSprite():Play("Collect")
            sfx:Play(SoundEffect.SOUND_VAMP_GULP, Options.SFXVolume*2, 10, false, 2.0 - unsave.BottleBonus/5)
        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, WarpZone.BottleColl, WarpZone.WarpZoneTypes.PICKUP_WATERBOTTLE)

    function WarpZone.Bottle_RoomUpdate()
        if WarpZone.SomeoneHasWaterBottle and not game:GetRoom():IsClear() then
            if WarpZone.BottleSpawnDelay <= 0 and #Isaac.FindByType(bottleEntType, WarpZone.WarpZoneTypes.PICKUP_WATERBOTTLE) < 5 then
                local prng = WarpZone.SomeoneHasWaterBottle:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_FULL)
                local room = game:GetRoom()
                local rindex = room:GetRandomTileIndex(prng:GetSeed())
                prng:Next()
                local SpawnPos = room:GetGridPosition(rindex)
                local bottle = Isaac.Spawn(bottleEntType, WarpZone.WarpZoneTypes.PICKUP_WATERBOTTLE, 0,
                SpawnPos, Vector(0,0), WarpZone.SomeoneHasWaterBottle):ToPickup()
                bottle.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY

                local path = WarpZone.GetPathFinder(bottle)
                ::ret::
                if not path:HasPathToPos(WarpZone.SomeoneHasWaterBottle.Position, true) then
                    local nindex = room:GetRandomTileIndex(prng:GetSeed())
                    prng:Next()
                    bottle.Position = room:GetGridPosition(nindex)
                    goto ret
                end
                bottle.TargetPosition = bottle.Position/1
                WarpZone.BottleSpawnDelay = spawndelay
            else
                WarpZone.BottleSpawnDelay = WarpZone.BottleSpawnDelay - 1
            end
        end

        WarpZone.SomeoneHasWaterBottle = nil
    end

end