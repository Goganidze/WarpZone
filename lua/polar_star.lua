return function(mod)
    local sfx = SFXManager()
    local Isaac = Isaac
    local game = Game()

    local PolarStarVar = Isaac.GetEntityVariantByName("[Warp Zone] Polar Star")
    local PolarStarEXTent = Isaac.GetEntityVariantByName("[Warp Zone] polar star exp")

    local function swapOutActive(activeToAdd, slot, player, charge)
        local activeToRemove = player:GetActiveItem(slot)
        player:RemoveCollectible(activeToRemove, true, slot, true)
        player:AddCollectible(activeToAdd, charge, false, slot)
    end
    local lerpAngle = function(a, b, t)
        return (a - (((a+180)-b)%360-180)*t) % 360
    end

    ---@param source Entity|EntityPlayer?
    function WarpZone.FirePolarStar(pos, vec, flag, source)
        --local firePosition = pos + vec:Resized(12) --+ Vector(0, 13)
        local tear
        if source then
            if source.Type == EntityType.ENTITY_PLAYER then
                tear = source:FireTear(pos, vec, false, false, false, source, 1)
            else
                local param = ProjectileParams()
                param.Color = Color(2,.5,.5)
                param.FallingSpeedModifier = 3
                
                tear = source:ToNPC():FireBossProjectiles(1, pos+vec:Resized(160), 0, param)
                tear.Velocity = vec:Resized(13)
                tear.FallingSpeed = 0.2
                tear.FallingAccel = 0.02
                local sprite = tear:GetSprite()
                sprite:Load("gfx/polar star_bullet.anm2",true)
                sprite:Play(sprite:GetDefaultAnimation())
                tear.SpriteRotation = vec:GetAngleDegrees()

                return
            end
        else
            tear = Isaac.Spawn(2, 0, 0, pos, vec, nil):ToTear()
        end

        local sprite = tear:GetSprite()
        tear:AddTearFlags(flag)
        tear.CollisionDamage = tear.CollisionDamage * 1.5
        tear:ResetSpriteScale()
        local anm = sprite:GetAnimation()
        tear:ChangeVariant(WarpZone.WarpZoneTypes.TEAR_POLAR_STAR_BULLET)
        --tear:ChangeVariant(TearVariant.CUPID_BLUE)
        
        --sprite:Load("gfx/polar star_bullet.anm2",true)
        sprite:Play(sprite:GetDefaultAnimation())
        sprite:Play(anm)
        tear.Scale = 1
        tear.SpriteRotation = vec:GetAngleDegrees()
        
        tear:ResetSpriteScale()
    end

    ---@param tear EntityTear
    function WarpZone.PolarStarBulletUpdate(_, tear)
        tear.SpriteRotation = (tear.Velocity):GetAngleDegrees()
    end
    WarpZone:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, WarpZone.PolarStarBulletUpdate, WarpZone.WarpZoneTypes.TEAR_POLAR_STAR_BULLET)


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
        local IsSirenCharmed, SirenHelper = WarpZone.isSirenCharmed(fam)
        --player:GetData().WarpZone_unsavedata.PolarStarIsCharmed = IsSirenCharmed
        if not IsSirenCharmed then
            player.FireDelay = math.max(player.FireDelay, 5)
        end


        if not isAim and not wasShootb then
            rotation = player:GetMovementInput():Length()>0.05 and Vector.FromAngle(player:GetSmoothBodyRotation()) or Vector(0,1)  --headRotation
            fam.Coins = math.min(20, fam.Coins + 1)
        elseif not isAim and wasShootb then
            rotation = Vector.FromAngle(fam.LastDirection)
        end
        local rotationAngle = rotation:GetAngleDegrees()

        spr.Rotation = lerpAngle(spr.Rotation, rotationAngle, 0.4)
        local distfromplay = IsSirenCharmed and 40 or 25
        local newPos = player.Position + Vector.FromAngle(spr.Rotation):Resized(distfromplay)   --(rotation:Normalized() * 25)
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
        local IsnotFinished
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
                    --spr:SetFrame(0)
                    spr:Play(anm, true)
                    IsnotFinished = true
                elseif spr:GetAnimation() ~= anm then
                    spr:Play(anm, true)
                    IsnotFinished = true
                end
                
                fam.LastDirection = math.floor(rotationAngle) % 360
                wasShoot = 2
                wasShootb = true
                fam.FireCooldown = math.floor(player.MaxFireDelay * 1.5)

                local udata = player:GetData().WarpZone_unsavedata

                local num = udata and udata.PolarStarNumTears or 1

                local mainvec = aim:Resized(player.ShotSpeed*15+5) 

                local angle = udata and udata.PolarStarTearAngleBetween or 2
                local start = mainvec:Rotated(-num*angle/2)

                for i = 1, num do
                    local vec = start:Resized(player.ShotSpeed*15+5):Rotated(i*angle)
                    vec = vec + player:GetTearMovementInheritance(vec)
                    --local pos = fam.Position --+ aim:Resized(12)
                    WarpZone.FirePolarStar(fam.Position, vec, 0, SirenHelper or player)
                end

                sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
            end
        end
        
        if wasShootb and spr:IsFinished() and not IsnotFinished then
            wasShoot = 0
            spr:Play("Idle" .. suffix)
        elseif wasShootb then
            spr:SetAnimation("Shoot" .. suffix, false)
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
        player:AddNullCostume(WarpZone.WarpZoneTypes.COSTUME_BOOSTERV2)
    end
    WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.PolarStar_Use, WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR)

    ---@param player EntityPlayer
    function WarpZone.Boosterv2_Use(_,collectible, rng, player, useflags, slot )
        local udata = player:GetData().WarpZone_unsavedata
        sfx:Play(SoundEffect.SOUND_FREEZE_SHATTER, Options.SFXVolume*0.6, nil, nil, 1.6)
        sfx:Play(WarpZone.WarpZoneTypes.SOUND_GUN_SWAP, Options.SFXVolume*3.8, nil, nil, 1.4)
        swapOutActive(WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR, slot, player, 0)

        udata.HasPolarStar = true
        udata.HasBoosterV2Costume = false
        player:TryRemoveNullCostume(WarpZone.WarpZoneTypes.COSTUME_BOOSTERV2)
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
        WarpZone.SomeoneHasPolarStar = WarpZone.SomeoneHasPolarStar or boos or polstr
        if udata.HasPolarStar then 
            if not udata.PolarStarLevel then
                udata.PolarStarLVL = 1
                udata.PolarStarEXP = 0
            end
        end

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
            --if not udata.PolarStarIsCharmed then
            --    player.FireDelay = math.max(player.FireDelay, 5)
            --end
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

        if Isaac.GetFrameCount()%60 == 0 then
            local inner_count = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE)
            local mutant_count = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
            local ochki_count = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20)

            local ingoreochkov = false
            local num = 1
            local angle = 4
            --if inner_count > 0 then
            --    num = num + 2 + (inner_count-1)
            --    ingoreochkov = true
            --end
            if mutant_count > 0 then
                num = num + 3 + (mutant_count-1)*2
                ingoreochkov = true
            end
            if inner_count > 0 then
                if num > 1 then
                    num = num + 1 + (inner_count-1)
                else
                    num = num + 2 + (inner_count-1)
                end
                ingoreochkov = true
            end
            if ochki_count > 0 then
                if ingoreochkov then
                    num = num + ochki_count-1
                else
                    num = num + ochki_count
                end
                angle = 2
            end
            if player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM) then
                if player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR):RandomInt(2) == 1 then
                    num = num + 1
                end
            end
            udata.PolarStarNumTears = num
            udata.PolarStarTearAngleBetween = angle
            udata.PolarStarConjoin = player:HasPlayerForm(PlayerForm.PLAYERFORM_BABY)

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

    function WarpZone.SpawnPolarStarEXP(pos, amout, rng, source)
        amout = amout or 1
        for i=1, amout do
            local seed = rng:RandomInt(300000000)+1
            local vec
            if not Renderer then
                vec = rng:RandomVector():Resized(rng:RandomInt(3)+1)
            else
                vec = Vector(rng:RandomInt(70)-35, rng:RandomInt(70)-35) / 10
            end
            
            local eff = game:Spawn(EntityType.ENTITY_EFFECT, PolarStarEXTent, pos, vec, source, 0, seed):ToEffect()
            eff:GetSprite():Play("point_idle", true)
            eff.FallingSpeed = -4 - rng:RandomFloat()*2
            eff.FallingAcceleration = 0.43
            eff.LifeSpan = 30
            local data = eff:GetData()
        end
    end

    ---@param ent Entity
    function WarpZone.PolarStar_NPCKill(_, ent)
        if WarpZone.SomeoneHasPolarStar then
            if ent:IsActiveEnemy(true) and ent:CanShutDoors() then
                
                local amout = math.ceil( ent.MaxHitPoints / 30 )
                if ent:IsBoss() then
                    amout = amout + 5
                end
                WarpZone.SpawnPolarStarEXP(ent.Position, amout, ent:GetDropRNG(), Isaac.GetPlayer())
            end
        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, WarpZone.PolarStar_NPCKill)

    ---@param ent EntityEffect
    function WarpZone.PolarStarEXPEnt_update(_, ent)
        local spr = ent:GetSprite()
        local pos = ent.Position
        --if ent.SubType == 0 then
            ent.PositionOffset = ent.PositionOffset + Vector(0, ent.FallingSpeed)
            if ent.PositionOffset.Y > 0 then
                ent.FallingSpeed = -4 - ent:GetDropRNG():RandomFloat()*2 -- -ent.FallingSpeed *0.95
                ent.PositionOffset = Vector(ent.PositionOffset.X, 0)
            else
                ent.FallingSpeed = ent.FallingSpeed + ent.FallingAcceleration
            end
            
            local room = game:GetRoom()
            if room:GetGridCollisionAtPos(pos) >= GridCollisionClass.COLLISION_WALL then
                local gridpos = room:GetGridPosition(room:GetGridIndex(pos))
                local angle = math.floor((((pos-ent.Velocity-gridpos):GetAngleDegrees()+45)%360)/90)
                
                if angle == 2 or angle == 0 then
                    ent.Velocity = Vector(-ent.Velocity.X, ent.Velocity.Y)
                elseif angle == 3 or angle == 1 then
                    ent.Velocity = Vector(ent.Velocity.X, -ent.Velocity.Y)
                end
                ent.Position = room:GetClampedPosition(pos, 0)
                --ent:AddVelocity((pos-gridpos):Resized(1))
            end

            if not ent.Target then
                for i=0, game:GetNumPlayers()-1 do
                    local player = Isaac.GetPlayer(i)
                    if player and player.Position:Distance(pos) < 200 then
                        ent.Target = player
                        break
                    end
                end
            elseif ent.Target:Exists() then
                local target = ent.Target
                local dist = math.max(0, 200 - target.Position:Distance(pos))

                local vel = (target.Position+target.Velocity-pos):Resized(dist/10)
                ent.Velocity = ent.Velocity * 0.9 + vel * 0.1

                if dist > 200-target.Size*3 then
                    local tardata = target:GetData()
                    if tardata.WarpZone_unsavedata then
                        tardata.WarpZone_unsavedata.PolarStarEXP = tardata.WarpZone_unsavedata.PolarStarEXP + 3
                    end
                    local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, 102, 0,
                        pos, Vector(0,0), ent):ToEffect()
                    eff.PositionOffset = ent.PositionOffset
                    eff:Update()
                    local sprr = eff:GetSprite()
                    sprr:Load("gfx/effects/polar star_level.anm2", true)
                    sprr:Play("point_pickup")

                    sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
                    ent:Remove()
                end
            end
        --end
    end
    WarpZone:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, WarpZone.PolarStarEXPEnt_update, PolarStarEXTent)

end