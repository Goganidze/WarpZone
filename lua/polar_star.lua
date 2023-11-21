return function(mod)
    local sfx = SFXManager()
    local Isaac = Isaac
    local game = Game()

    local PolarStarVar = Isaac.GetEntityVariantByName("[Warp Zone] Polar Star")

    local function swapOutActive(activeToAdd, slot, player, charge)
        local activeToRemove = player:GetActiveItem(slot)
        player:RemoveCollectible(activeToRemove, true, slot, true)
        player:AddCollectible(activeToAdd, charge, false, slot)
    end
    local lerpAngle = function(a, b, t)
        return (a - (((a+180)-b)%360-180)*t) % 360
    end

    ---@param fam EntityFamiliar
    function WarpZone.PolarStar_EntLogic(_, fam)
        local player = fam.Player
        local spr = fam:GetSprite()
        --local headRotation = getVectorFromDirection(player:GetAimDirection())
        local aim = player:GetAimDirection()
        local isAim = aim:Length() > 0.01
        local rotation = aim
        local wasShoot = fam.OrbitAngleOffset & 2
        local wasShootb = wasShoot==2
       
    
        if not isAim and not wasShootb then
            rotation = player:GetMovementInput():Length()>0.05 and Vector.FromAngle(player:GetSmoothBodyRotation()) or Vector(0,1)  --headRotation
            fam.Coins = math.min(20, fam.Coins + 1)
        elseif not isAim and wasShootb then
            rotation = Vector.FromAngle(fam.LastDirection)
        end
        local rotationAngle = rotation:GetAngleDegrees()

        spr.Rotation = lerpAngle(spr.Rotation, rotationAngle, 0.4)
        local newPos = player.Position + Vector.FromAngle(spr.Rotation):Resized(25)   --(rotation:Normalized() * 25)
        newPos = newPos --+ Vector(0, -10)
        fam.Velocity = newPos - fam.Position


        local degrees = wasShootb and fam.LastDirection or spr.Rotation
        local suffix = nil
        if degrees > 315 or degrees <= 45 then
            suffix = "Right"
        elseif degrees > 45 and degrees <= 135 then
            suffix = "Down"
        elseif degrees > 135 and degrees <= 225 then
            suffix = "Left"
        elseif degrees > 225 then
            suffix = "Up"
        else
            suffix = "Down"
        end
        --print(spr:GetAnimation(), suffix, degrees)
        if isAim then
            if fam.FireCooldown <= 0 then
                local vol = Options.SFXVolume
                if sfx:IsPlaying(SoundEffect.SOUND_GFUEL_GUNSHOT) then
                    vol = vol * .5
                end
                sfx:Play(SoundEffect.SOUND_GFUEL_GUNSHOT, vol, 3, false, 1.2)
                local anm = "Shoot" .. suffix
                if spr:GetAnimation() == anm and spr:GetFrame()>2 then
                    spr:SetFrame(0)
                else
                    spr:Play(anm)
                end
                fam.LastDirection = math.floor(rotationAngle) % 360
                wasShoot = 2
                wasShootb = true
                fam.FireCooldown = math.floor(player.MaxFireDelay * 1.5)


            end
        end
        
        if wasShootb and spr:IsFinished() then
            wasShoot = 0
            spr:Play("Idle" .. suffix)
        end
        fam.FireCooldown = fam.FireCooldown - 1

        local prefix = "Idle"

        if not wasShootb then
            --[[if degrees > 315 or degrees <= 45 then
                suffix = "Right"
            elseif degrees > 45 and degrees <= 135 then
                suffix = "Down"
            elseif degrees > 135 and degrees <= 225 then
                suffix = "Left"
            elseif degrees > 225 then
                suffix = "Up"
            else
                suffix = "Down"
            end]]
        
        --if suffix then
            local animName = prefix .. suffix
            if spr:GetAnimation() ~= animName then
                if animName:sub(1, 8) ~= spr:GetAnimation():sub(1, 8) then
                    spr:Play(animName, true)
                else
                    spr:SetAnimation(animName, false)
                end
            end
        end
        --else
         --   local animName = prefix .. suffix
        --    if spr:GetAnimation() ~= animName then
        --        spr:SetAnimation(animName, false)
        --    end
            
        --end
        

        local ag = isAim and 1 or 0
        local s = 0 
        local oh = s&ag local res = oh==ag and s or (ag + s)
        local oh = res&wasShoot local res = oh==wasShoot and res or (wasShoot + res)
        fam.OrbitAngleOffset = res
    end
    WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, WarpZone.PolarStar_EntLogic, PolarStarVar)
    ---@param fam EntityFamiliar
    function WarpZone:init_PolarStar_Ent(fam)
        fam.PositionOffset = Vector(0,-15)
        fam.DepthOffset = 1
        fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
    WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, WarpZone.init_PolarStar_Ent, PolarStarVar)




    ---@param player EntityPlayer
    function WarpZone.PolarStar_Use(_,collectible, rng, player, useflags, slot )
        local udata = player:GetData().WarpZone_unsavedata
        sfx:Play(SoundEffect.SOUND_LIGHTBOLT_CHARGE, nil, nil, nil, 1.3)
        swapOutActive(WarpZone.WarpZoneTypes.COLLECTIBLE_BOOSTERV2, slot, player, 0)
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS | CacheFlag.CACHE_FLYING | CacheFlag.CACHE_SPEED)

        udata.HasPolarStar = nil
        udata.HasBoosterV2Costume = true
    end
    WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.PolarStar_Use, WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR)

    ---@param player EntityPlayer
    function WarpZone.Boosterv2_Use(_,collectible, rng, player, useflags, slot )
        local udata = player:GetData().WarpZone_unsavedata
        sfx:Play(SoundEffect.SOUND_FREEZE_SHATTER, Options.SFXVolume*0.6, nil, nil, 1.6)
        sfx:Play(WarpZone.WarpZoneTypes.SOUND_GUN_SWAP, Options.SFXVolume*3.8, nil, nil, 1.4)
        swapOutActive(WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR, slot, player, 0)

        udata.HasPolarStar = true
        udata.HasBoosterV2Costume = nil
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS | CacheFlag.CACHE_FLYING | CacheFlag.CACHE_SPEED)
    end
    WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.Boosterv2_Use, WarpZone.WarpZoneTypes.COLLECTIBLE_BOOSTERV2)

    local v5 = Vector(.5,.5)
    local bosv2Off = Vector(0,-4)
    ---@param player EntityPlayer
    function WarpZone.PolarStarBoosterv2_Update(_, player)
        local polstr = player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR)
        local boos = player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOOSTERV2)

        local data = player:GetData()
        local udata = data.WarpZone_unsavedata
        if boos then
            if not udata.HasBoosterV2Costume then
                player:AddNullCostume(WarpZone.WarpZoneTypes.COSTUME_BOOSTERV2)
                udata.HasBoosterV2Costume = true
                player:AddCacheFlags(CacheFlag.CACHE_FLYING | CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end
            if Isaac.GetFrameCount() % 10 == 0 and player.Velocity:Length()>2 then
                local ef = Isaac.Spawn(EntityType.ENTITY_EFFECT, 102, 0,
                    player.Position, Vector(0,0), player):ToEffect()
                    local es = ef:GetSprite()
                    es:Load("gfx/effects/booster v2 effect.anm2", true)
                    es:Play(es:GetDefaultAnimation())
                    es.Color = Color(1,1,1,.5)
                    es.Scale = v5
                    es.Offset = bosv2Off
            end

        elseif not boos then
            
            if udata.HasBoosterV2Costume then
                player:TryRemoveNullCostume(WarpZone.WarpZoneTypes.COSTUME_BOOSTERV2)
                udata.HasBoosterV2Costume = false
                player:AddCacheFlags(CacheFlag.CACHE_FLYING | CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end
        end


        if polstr then
            player.FireDelay = math.max(player.FireDelay, 5)
            if not udata.HasPolarStar then
                udata.HasPolarStar = true
                player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
                player:EvaluateItems()
            end

        else
            if udata.HasPolarStar then
                udata.HasPolarStar = false
                player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
                player:EvaluateItems()
            end
        end
        --print(udata.HasPolarStar)

        if Isaac.GetFrameCount()%60 == 0 then
            local inner_count = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE)
            local mutant_count = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
            local ochki_count = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20)

            local ingoreochkov = false
            local num = 0
            if inner_count > 0 then
                num = num + 2 + (inner_count-1)
                ingoreochkov = true
            end
            if mutant_count > 0 then
                num = num + 3 + (mutant_count-1)
                ingoreochkov = true
            end
            if ochki_count > 0 then
                
            end

        end


    end



    ---@param player EntityPlayer
    function WarpZone.PolarStarBoosterv2_Cache(_, player, cache)
        local polstr = player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR)
        local boos = player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOOSTERV2)

        if cache == CacheFlag.CACHE_FAMILIARS then
            local data = player:GetData()
            --if not player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_CROWDFUNDER) then
            --    data.WarpZone_unsavedata.Crowdfunder = nil
            --end
            
            local count = polstr and 1 or 0
            local rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR)
            player:CheckFamiliar(PolarStarVar, count, rng)
        elseif cache == CacheFlag.CACHE_FLYING then
            if boos then
                player.CanFly = true
            end
        elseif cache == CacheFlag.CACHE_SPEED then
            if boos then
                player.MoveSpeed = math.max(1.5, (player.MoveSpeed + 0.1) * 1.5)
            end
        end
    end


end