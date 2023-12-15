return function(mod)
    local sfx = SFXManager()
    local Isaac = Isaac
    local game = Game()
    local Wtr = 20/13

    WarpZone.BottleSpawnChance = .15

    local bottleEntType = EntityType.ENTITY_PICKUP

    local spawndelay = 70
    WarpZone.SomeoneHasWaterBottle = nil
    WarpZone.BottleSpawnDelay = spawndelay


    function WarpZone.AddWaterTempBonus(player)
        local unsave = player:GetData().WarpZone_unsavedata
        unsave.BottleBonus = unsave.BottleBonus or 0
        local val = 3.0/(unsave.BottleBonus+1.5)
        unsave.BottleBonus = unsave.BottleBonus and math.min(unsave.BottleBonus + val, 5) or 2
        sfx:Play(SoundEffect.SOUND_VAMP_GULP, Options.SFXVolume*2, 10, false, 2.0 - unsave.BottleBonus/5)
    end

    function WarpZone.AddWaterLevelBonus(player)
        local unsave = player:GetData().WarpZone_data
        unsave.LevelBottleBonus = unsave.LevelBottleBonus or 0
        local val = 3.0/(unsave.LevelBottleBonus+2.5)
        unsave.LevelBottleBonus = unsave.LevelBottleBonus and math.min(unsave.LevelBottleBonus + val, 5) or 2
        sfx:Play(SoundEffect.SOUND_VAMP_GULP, Options.SFXVolume*2, 2, false, 1.3 )

        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
    end

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
        if ent.SubType == 1 then
            ent.Velocity = Vector(0,0)
            if ent.TargetPosition.X > 0 then
                ent.Position = ent.TargetPosition
            end
            if spr:IsFinished("Collect_shit") then
                ent:Remove()
            elseif spr:IsFinished("Appear_shit") then
               spr:Play("Idle_shit")
            end
            ent.Timeout = 60
        else
            if spr:IsFinished("Collect") then
                ent:Remove()
            end
            
        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, WarpZone.BottleUpdate, WarpZone.WarpZoneTypes.PICKUP_WATERBOTTLE)

    ---@param ent EntityPickup
    ---@param collider Entity
    function WarpZone.BottleColl(_,ent, collider)
        if ent.SubType == 1 then
            local player = collider:ToPlayer()
            if player then
                local unsave = player:GetData().WarpZone_unsavedata
                WarpZone.AddWaterTempBonus(player)
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                ent:GetSprite():Play("Collect_shit")
                sfx:Play(SoundEffect.SOUND_VAMP_GULP, Options.SFXVolume*2, 10, false, 2.0 - unsave.BottleBonus/5)
            end
        else
            local player = collider:ToPlayer()
            if player then
                local collider = collider:ToPlayer()
                local sprite = ent:GetSprite()
                
                if collider:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
                    return WarpZone.BottleColl(_, ent, player:GetOtherTwin()) 
                elseif ent:IsShopItem() and (ent.Price > collider:GetNumCoins()) then
                    return true
                elseif sprite:IsPlaying("Collect") then
                    return true
                elseif ent.Wait > 0 then
                    return not sprite:IsPlaying("Idle")
                elseif sprite:WasEventTriggered("DropSound") or sprite:IsPlaying("Idle") then
                    local daat = player:GetData().WarpZone_data
                    if daat.LevelBottleBonus and daat.LevelBottleBonus >= 5 then
                        return ent:IsShopItem()
                    end

                    if ent.Price == PickupPrice.PRICE_SPIKES then
                        local tookDamage = collider:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
                        if not tookDamage then
                            return ent:IsShopItem()
                        end
                    end
                    
                    WarpZone.AddWaterLevelBonus(player)
        
                    if ent.OptionsPickupIndex ~= 0 then
                        local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
                        for _, entity in ipairs(pickups) do
                            if entity:ToPickup().OptionsPickupIndex == ent.OptionsPickupIndex and
                               (entity.Index ~= ent.Index or entity.InitSeed ~= ent.InitSeed)
                            then
                                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
                                entity:Remove()
                            end
                        end
                    end
        
                    if ent:IsShopItem() then
                        local pickupSprite = sprite
                        local holdSprite = Sprite()
                        
                        holdSprite:Load(pickupSprite:GetFilename(), true)
                        holdSprite:Play(pickupSprite:GetAnimation(), true)
                        holdSprite:SetFrame(pickupSprite:GetFrame())
                        collider:AnimatePickup(holdSprite)
                        
                        if ent.Price > 0 then
                            collider:AddCoins(-1 * ent.Price)
                        end
                        
                        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                        ent:Remove()
                    else
                        sprite:Play("Collect", true)
                        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                        ent:Die()
                    end
                    
                    return true
                else
                    return false
                end
            end
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
                local bottle = Isaac.Spawn(bottleEntType, WarpZone.WarpZoneTypes.PICKUP_WATERBOTTLE, 1,
                    SpawnPos, Vector(0,0), WarpZone.SomeoneHasWaterBottle):ToPickup()

                bottle.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
                bottle:GetSprite():Play("Appear_shit")

                local path = WarpZone.GetPathFinder(bottle)
                local loop = 0
                local rloop = 0
                local gridsize = room:GetGridSize()+1

                goto first --ну и насрал я
                ::ohshit::

                if rloop < 500 and not path:HasPathToPos(WarpZone.SomeoneHasWaterBottle.Position, true) then
                    local nindex = (rindex + rloop)%gridsize --room:GetRandomTileIndex(prng:GetSeed())
                    prng:Next()
                    local newpos = room:GetGridPosition(nindex)
                    if room:GetGridCollisionAtPos(newpos) == GridCollisionClass.COLLISION_NONE then
                        bottle.Position = newpos
                    end
                    rloop = rloop + 1
                    --Isaac.Spawn(1000,EffectVariant.IMPACT,0, newpos, Vector(0,0),nil)
                    goto ret
                end
                goto found

                ::first::
                ::ret::
                if loop >= 500 then
                    goto ohshit
                end
                if loop < 500 and not path:HasPathToPos(WarpZone.SomeoneHasWaterBottle.Position, true) then
                    local nindex = room:GetRandomTileIndex(prng:GetSeed())
                    prng:Next()
                    local newpos = room:GetGridPosition(nindex)
                    if room:GetGridCollisionAtPos(newpos) == GridCollisionClass.COLLISION_NONE then
                        bottle.Position = newpos
                    end
                    loop = loop + 1
                    --Isaac.Spawn(1000,EffectVariant.IMPACT,0, newpos, Vector(0,0),nil)
                    goto ret
                end
                ::found::
                bottle.TargetPosition = bottle.Position/1
                WarpZone.BottleSpawnDelay = spawndelay
            else
                WarpZone.BottleSpawnDelay = WarpZone.BottleSpawnDelay - 1
            end
        end

        WarpZone.SomeoneHasWaterBottle = nil
    end

    local save = WarpZone.SaveFile
    ---@param ent EntityPickup
    function WarpZone.PickupReplase(_, ent)
        if save.IsLoaded and save.PillReplased then
            local seed = tostring(ent.InitSeed)
            if not save.PillReplased[seed] then
                local reprng = RNG()
                reprng:SetSeed(ent.InitSeed, 35)
                if reprng:RandomFloat() < WarpZone.BottleSpawnChance then
                    ent:Morph(bottleEntType, WarpZone.WarpZoneTypes.PICKUP_WATERBOTTLE, 0, true, true, false)
                end
            end
            save.PillReplased[seed] = 1
        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, WarpZone.PickupReplase, 70)

    if Epiphany then
        --извини, но залежи нефти уже принадлежат местной нефтедобывающей компании
        Epiphany.Character.KEEPER.DisallowedPickUpVariants[WarpZone.WarpZoneTypes.PICKUP_WATERBOTTLE] = 0
    end
end