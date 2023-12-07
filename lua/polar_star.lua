return function(mod)
    local sfx = SFXManager()
    local Isaac = Isaac
    local game = Game()
    local Wtr = 20/13

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
    function WarpZone.FirePolarStar(pos, vec, flag, source, dmgmulti, LifeTime)
        --local firePosition = pos + vec:Resized(12) --+ Vector(0, 13)
        local tear
        if source then
            if source.Type == EntityType.ENTITY_PLAYER then
                tear = source:FireTear(pos, vec, false, false, false, source, dmgmulti or 1)
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
        --tear.Height = -10
        
        tear:ResetSpriteScale()
        local anm = sprite:GetAnimation()
        tear:ChangeVariant(WarpZone.WarpZoneTypes.TEAR_POLAR_STAR_BULLET)

        sprite:Play(sprite:GetDefaultAnimation())
        sprite:Play(anm)
        --tear.Scale = dmgmulti or 1
        tear.SpriteRotation = vec:GetAngleDegrees()
        
        --tear.FallingSpeed = -0.65 -- tear.FallingSpeed  + 1
        --tear.FallingAcceleration = -0.05 -- tear.FallingAcceleration * 2
        tear:GetData().WarpZone_Timeout = LifeTime
        
        tear:ResetSpriteScale()
        return tear
    end

    ---@param tear EntityTear
    function WarpZone.PolarStarBulletUpdate(_, tear)
        tear.SpriteRotation = (tear.Velocity):GetAngleDegrees()

        if tear:IsDead() then
            local ef = Isaac.Spawn(EntityType.ENTITY_EFFECT, PolarStarEXTent, 10,
                tear.Position+tear.Velocity+tear.PositionOffset, Vector(0,0), tear)

            ef.Color = tear.Color
            ef.SpriteScale = Vector(1.5, 1.5) * tear.Scale
            if tear:GetDropRNG():RandomInt(4) == 0 then
                ef:GetSprite():Play("2")
            else
                ef:GetSprite():Play("1")
            end
        else
            local data = tear:GetData()
            local time = data.WarpZone_Timeout
            if not time or time <= 0 then
                local he = tear.PositionOffset.Y+4 -- tear.Height
                tear.Height = 0
                data.WarpZone_Timeout = 2
                tear.PositionOffset = Vector(0, he)
                tear.Position = tear.Position - tear.Velocity
                tear:Update()
                tear.Height = he
            else
                 data.WarpZone_Timeout = time - 1
            end
        end
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
        
        local firedelaay = player.MaxFireDelay

        if not IsSirenCharmed then
            if WarpZone.GetWeaponType(player, player:GetData()) ~= WarpZone.WarpZoneTypes.WEAPON_POLARSTAR then
                
            else
                player.FireDelay = math.max(player.FireDelay, 5)
            end
        else
            firedelaay = 22
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
        
        if isAim then
            if fam.OrbitSpeed <= 0 then
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
                
                --fam.OrbitSpeed = fam.OrbitSpeed + (player.MaxFireDelay * 1.2 + 1) -- math.floor((player.MaxFireDelay * 1.2 + 1)*2)
               
                local udata = player:GetData().WarpZone_unsavedata

                local num = udata and udata.PolarStarNumTears or 1

                local tearspeed = player.ShotSpeed*15+5
                local mainvec = aim:Resized(tearspeed) 

                local angle = udata and udata.PolarStarTearAngleBetween or 2
                local start = mainvec:Rotated(-(num-1)*angle/2)
                --local shootPos = player.Position + aim:Resized(distfromplay/2)

                local lifeTime = math.floor ((player.TearRange-distfromplay) / tearspeed) - 1
                
                local source = SirenHelper or player

                local prevec = start:Resized(tearspeed)
                local Inher = player:GetTearMovementInheritance(prevec)
                
                for h=1, 10 do
                    local shootPos = player.Position + aim:Resized(distfromplay/2) - aim:Resized(tearspeed/2 * -fam.OrbitSpeed ) 
                    
                    if udata.PolarStarLVL ~= 2 then
                        local dmgmulti = udata.PolarStarLVL == 3 and 2.5
                        for i = 0, num-1 do
                            local vec = prevec:Rotated(i*angle)
                            vec = vec + Inher
                            --local pos = fam.Position --+ aim:Resized(12)
                            WarpZone.FirePolarStar(shootPos, vec, 0, source, dmgmulti, lifeTime)
                        end
                    elseif udata.PolarStarLVL == 2 then
                        for i = 0, num-1 do
                            local vec = prevec:Rotated(i*angle)
                            vec = vec + Inher
                            local off = aim:Rotated(90):Resized(10)

                            WarpZone.FirePolarStar(shootPos+off, vec, 0, source, 0.8, lifeTime)       
                            WarpZone.FirePolarStar(shootPos-off, vec, 0, source, 0.8, lifeTime)
                        end
                    end
                    fam.OrbitSpeed = fam.OrbitSpeed + (firedelaay * 1.2 + 1)*2
                    if fam.OrbitSpeed > 0 then
                        break
                    end
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
        --for i=1,2 do
            if fam.OrbitSpeed > 0 then
                fam.OrbitSpeed = fam.OrbitSpeed - 2
            end
        --end

        local prefix = "Idle"

        if not wasShootb then
        
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
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS | CacheFlag.CACHE_FLYING | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_RANGE)

        udata.HasPolarStar = nil
        WarpZone.RemoveWeaponType(player, player:GetData(), {type = WarpZone.WarpZoneTypes.WEAPON_POLARSTAR})
        udata.HasBoosterV2Costume = true
        player:AddNullCostume(WarpZone.WarpZoneTypes.COSTUME_BOOSTERV2)
    end
    WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.PolarStar_Use, WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR)

    local function loss(player, udata)
        udata.HasPolarStar = false
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS | CacheFlag.CACHE_RANGE)
    end
    local function set(player, udata)
        local result = WarpZone.SetWeaponType(player, player:GetData(), 
            {type = WarpZone.WarpZoneTypes.WEAPON_POLARSTAR, loss = loss, perst = true, 
            retu = function (player, data)
                udata.HasPolarStar = true
                player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS | CacheFlag.CACHE_RANGE)
                player:EvaluateItems()
            end}, 0)
        if result then
            udata.HasPolarStar = true
        end
    end

    ---@param player EntityPlayer
    function WarpZone.Boosterv2_Use(_,collectible, rng, player, useflags, slot )
        local udata = player:GetData().WarpZone_unsavedata
        local room = game:GetRoom()
        
        if room:GetGridCollisionAtPos(player.Position) == GridCollisionClass.COLLISION_NONE or udata.Boosterv2_CanFly == true then
            sfx:Play(SoundEffect.SOUND_FREEZE_SHATTER, Options.SFXVolume*0.6, nil, nil, 1.6)
            sfx:Play(WarpZone.WarpZoneTypes.SOUND_GUN_SWAP, Options.SFXVolume*3.8, nil, nil, 1.4)
            swapOutActive(WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR, slot, player, 0)

            --WarpZone.SetWeaponType(player, player:GetData(), 
           --     {type = WarpZone.WarpZoneTypes.WEAPON_POLARSTAR, loss = loss, perst = true}, 0)
            --udata.HasPolarStar = true
            set(player, udata)

            udata.HasBoosterV2Costume = false
            player:TryRemoveNullCostume(WarpZone.WarpZoneTypes.COSTUME_BOOSTERV2)
            player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS | CacheFlag.CACHE_FLYING | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_RANGE)
        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.Boosterv2_Use, WarpZone.WarpZoneTypes.COLLECTIBLE_BOOSTERV2)

    local v5 = Vector(.5,.5)
    local bosv2Off = Vector(0,-4)
    ---@param player EntityPlayer
    function WarpZone.PolarStarBoosterv2_Update(_, player)
        local polstr = player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR) or Isaac.GetChallenge() == WarpZone.WarpZoneTypes.CHALLENGE_UNQUOTE
        local boos = player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOOSTERV2) or Isaac.GetChallenge() == WarpZone.WarpZoneTypes.CHALLENGE_UNQUOTE
        
        local data = player:GetData()
        local udata = data.WarpZone_unsavedata
        WarpZone.SomeoneHasPolarStar = WarpZone.SomeoneHasPolarStar or boos or polstr
        if boos or polstr then 
            if not udata.PolarStarLVL then
                udata.PolarStarLVL = 1
                udata.PolarStarEXP = 0
            else  --if udata.PolarStarLVL == 1 then
                if udata.PolarStarEXP > 50 and udata.PolarStarLVL < 3 then
                    udata.PolarStarLVL = udata.PolarStarLVL + 1
                    udata.PolarStarEXP = 0

                    local ef = Isaac.Spawn(EntityType.ENTITY_EFFECT, 102, 0,
                        player.Position+Vector(-40,0), Vector(0,0), player):ToEffect()
                    local es = ef:GetSprite()
                    es:Load("gfx/effects/polar star_level.anm2", true)
                    es:Play("level")

                    local ef = Isaac.Spawn(EntityType.ENTITY_EFFECT, 102, 0,
                        player.Position+Vector(40,0), Vector(0,0), player):ToEffect()
                    local es = ef:GetSprite()
                    es:Load("gfx/effects/polar star_level.anm2", true)
                    es:Play("level")

                    local ef = Isaac.Spawn(EntityType.ENTITY_EFFECT, 102, 0,
                        player.Position+Vector(0,-30), Vector(0,0), player):ToEffect()
                    ef.DepthOffset = 100
                    local es = ef:GetSprite()
                    es:Load("gfx/effects/polar star_level.anm2", true)
                    es:Play("level up")
                end
            end
        end

        if boos then
            local lvl = udata.PolarStarLVL
            if not udata.HasBoosterV2Costume then
                player:AddNullCostume(WarpZone.WarpZoneTypes.COSTUME_BOOSTERV2)
                udata.HasBoosterV2Costume = true
                player:AddCacheFlags(CacheFlag.CACHE_FLYING | CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end
            if udata.Boosterv2_ForceSpeed and lvl > 2 then
                player.MoveSpeed = math.min(2.2, player.MoveSpeed + udata.Boosterv2_ForceSpeed)
                udata.Boosterv2_ForceSpeed = nil
            end
            local ggh = lvl > 1 and 7 or 10
            if not udata.bosv2_rendMannul and Isaac.GetFrameCount() % ggh == 0 and player.Velocity:Length()>2 then
                if lvl > 1 then
                    local ef = Isaac.Spawn(EntityType.ENTITY_EFFECT, PolarStarEXTent, 5,
                        player.Position, Vector(0,0), player):ToEffect()
                    local es = ef:GetSprite()
                    es:Load("gfx/effects/booster v2 effect.anm2", true)
                    es:Play(es:GetDefaultAnimation())
                    es.Color = Color(2,.4,.2,.2)
                    --es.Scale = v5
                    --es.Offset = bosv2Off

                    local list = Isaac.FindInRadius(player.Position, 60, EntityPartition.ENEMY)
                    for i=1, #list do
                        local e = list[i]
                        if e:IsActiveEnemy() and not e:IsInvincible() then
                            e:AddBurn(EntityRef(player), 30, player.Damage)
                        end
                    end
                else
                    local ef = Isaac.Spawn(EntityType.ENTITY_EFFECT, 102, 0,
                        player.Position, Vector(0,0), player):ToEffect()
                    local es = ef:GetSprite()
                    es:Load("gfx/effects/booster v2 effect.anm2", true)
                    es:Play(es:GetDefaultAnimation())
                    es.Color = Color(1,1,1,.5)
                    es.Scale = v5
                    es.Offset = bosv2Off
                end
            end


        elseif not boos then
            
            if udata.HasBoosterV2Costume then
                player:TryRemoveNullCostume(WarpZone.WarpZoneTypes.COSTUME_BOOSTERV2)
                udata.HasBoosterV2Costume = false
                player:AddCacheFlags(CacheFlag.CACHE_FLYING | CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end
        end

        if udata.Boosterv2_shilaVjope then
            local spr = player:GetSprite()
            if not udata.Bosv2_3Frame then
                udata.Bosv2_3Frame = 0
                udata.Bosv2_RefScale = spr.Scale/1
                udata.bosv2_renderpos = 0
                --player:SetMinDamageCooldown(120)
                sfx:Play(SoundEffect.SOUND_BATTERYCHARGE, Options.SFXVolume+0.4, nil, nil, 0.5)
            end
            local endThis
            local frame = udata.Bosv2_3Frame
            if frame < 5 then
                spr.Scale = Vector((1+frame/20) * udata.Bosv2_RefScale.X, (1-frame/20) * udata.Bosv2_RefScale.Y )

            elseif frame == 5 then
                --game:BombExplosionEffects
                local ef = Isaac.Spawn(EntityType.ENTITY_EFFECT, 102, 0,
                        player.Position, Vector(0,0), player):ToEffect()
                local es = ef:GetSprite()
                es:Load("gfx/effects/booster v2 effect.anm2", true)
                es:Play(es:GetDefaultAnimation())
                es.Color = Color(1,1,1,.5)
                es.Scale = Vector(2,2)
                sfx:Play(SoundEffect.SOUND_LIGHTBOLT_CHARGE, nil, nil, nil, 0.9)
            elseif frame < 50 then
                if frame % 2 == 0 then
                    local ef = Isaac.Spawn(EntityType.ENTITY_EFFECT, 102, 0,
                        player.Position, Vector(0,0), player):ToEffect()
                    ef.PositionOffset = Vector(0,-udata.bosv2_renderpos*Wtr)
                    local es = ef:GetSprite()
                    es:Load("gfx/effects/booster v2 effect.anm2", true)
                    es:Play(es:GetDefaultAnimation())
                    es.Color = Color(1,1,1,.5)
                    es.Scale = v5
                    es.Offset = bosv2Off
                    es.PlaybackSpeed = .5
                    
                end

                player.PositionOffset = Vector(player.PositionOffset.X, 700)
                --udata.bosv2_PO = player.PositionOffset
                udata.bosv2_rendMannul = true
                udata.bosv2_renderpos = udata.bosv2_renderpos* 0.96 + 120 * (1-0.96)
                spr.Scale = Vector((.7+frame/200) * udata.Bosv2_RefScale.X, (1.3-frame/200) * udata.Bosv2_RefScale.Y )
            --elseif frame < 70 then
            --    local sfame = frame-60
            --    spr.Scale = Vector((.7+sfame/50) * udata.Bosv2_RefScale.X, (1.3-sfame/50) * udata.Bosv2_RefScale.Y )
            --    udata.bosv2_renderpos = udata.bosv2_renderpos* 0.96 + 130 * (1-0.96)
                --spr.Rotation = spr.Rotation * 0.9 + 180 * 0.1
            elseif frame < 60 then
                if frame == 50 then
                    sfx:Play(SoundEffect.SOUND_LIGHTBOLT_CHARGE, Options.SFXVolume+0.4, nil, nil, 0.8)
                end
                local sfame = frame-50
                spr.Scale = Vector((1.0-sfame/50) * udata.Bosv2_RefScale.X, (1.0+sfame/50) * udata.Bosv2_RefScale.Y )
                --player.SpriteRotation = player.SpriteRotation * 0.9 + 180 * 0.1
            else

                local ef = Isaac.Spawn(EntityType.ENTITY_EFFECT, 102, 0,
                    player.Position, Vector(0,0), player):ToEffect()
                ef.PositionOffset = Vector(0,-udata.bosv2_renderpos)
                local es = ef:GetSprite()
                es:Load("gfx/effects/booster v2 effect.anm2", true)
                es:Play(es:GetDefaultAnimation())
                es.Color = Color(1,1,1,.5)
                es.Scale = v5
                es.Offset = bosv2Off

                spr.Scale = Vector(.7 * udata.Bosv2_RefScale.X, -1.3 * udata.Bosv2_RefScale.Y )
                player.PositionOffset = Vector(player.PositionOffset.X, 700)
                udata.bosv2_renderpos = udata.bosv2_renderpos - 13
                if udata.bosv2_renderpos < 10 then
                    game:BombExplosionEffects(player.Position, 100, player.TearFlags, nil, player, nil , true, true)
                    spr.Scale = udata.Bosv2_RefScale
                    endThis = true
                end
            end
            
            player.Velocity = player.Velocity * 0.8
            udata.Bosv2_3Frame = udata.Bosv2_3Frame + .5
            player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

            if endThis then
                player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                player.PositionOffset = Vector(player.PositionOffset.X, 0)
                spr.Rotation = 0
                udata.Bosv2_3Frame = nil
                udata.Bosv2_RefScale = nil
                udata.bosv2_renderpos = nil
                udata.bosv2_rendMannul = nil

                udata.Boosterv2_shilaVjope = nil
                player:SetMinDamageCooldown(30)
                sfx:Play(SoundEffect.SOUND_LIGHTBOLT_CHARGE, Options.SFXVolume+0.4, nil, nil, 0.5)
                sfx:Play(SoundEffect.SOUND_BATTERYCHARGE, Options.SFXVolume+0.4, nil, nil, 0.5)

                udata.PolarStarLVL = udata.PolarStarLVL - 1
                udata.PolarStarEXP = 0

                local ef = Isaac.Spawn(EntityType.ENTITY_EFFECT, 102, 0,
                    player.Position+Vector(0,-30), Vector(0,0), player):ToEffect()
                ef.DepthOffset = 100
                local es = ef:GetSprite()
                es:Load("gfx/effects/polar star_level.anm2", true)
                es:Play("level down")
                player:AddCacheFlags(CacheFlag.CACHE_FLYING | CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end
        end
        
        if polstr then
            --if not udata.PolarStarIsCharmed then
            --    player.FireDelay = math.max(player.FireDelay, 5)
            --end
            
            local curt = WarpZone.GetWeaponType(player, data)
            if (curt == WarpZone.WarpZoneTypes.WEAPON_POLARSTAR
            or curt == WarpZone.WarpZoneTypes.WEAPON_DEFAULT)
            and not udata.HasPolarStar then
                --WarpZone.SetWeaponType(player, player:GetData(), 
                --    {type = WarpZone.WarpZoneTypes.WEAPON_POLARSTAR, loss = loss, perst = true}, 0)
                --udata.HasPolarStar = true
                set(player, udata)

                player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS | CacheFlag.CACHE_RANGE)
                player:EvaluateItems()
            end

        else
            if udata.HasPolarStar then
                udata.HasPolarStar = false
                WarpZone.RemoveWeaponType(player, data, {type = WarpZone.WarpZoneTypes.WEAPON_POLARSTAR})
                player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS | CacheFlag.CACHE_RANGE)
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
                    if ochki_count > 1 then
                        angle = 2
                    end
                else
                    num = num + ochki_count
                    angle = 2
                end
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
        local polstr = player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR) or Isaac.GetChallenge() == WarpZone.WarpZoneTypes.CHALLENGE_UNQUOTE
        local boos = player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOOSTERV2) or Isaac.GetChallenge() == WarpZone.WarpZoneTypes.CHALLENGE_UNQUOTE
        local data = player:GetData()

        if cache == CacheFlag.CACHE_FAMILIARS then
            --if not player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_CROWDFUNDER) then
            --    data.WarpZone_unsavedata.Crowdfunder = nil
            --end
            
            local count = polstr and 1 or 0
            if WarpZone.GetWeaponType(player, data) ~= WarpZone.WarpZoneTypes.WEAPON_POLARSTAR then
                count = 0
            end
            local rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR)
            player:CheckFamiliar(PolarStarVar, count, rng)
        elseif cache == CacheFlag.CACHE_FLYING then
            data.WarpZone_unsavedata.Boosterv2_CanFly = player.CanFly
            if boos then
                player.CanFly = true
            end
        elseif cache == CacheFlag.CACHE_SPEED then
            if boos then
                player.MoveSpeed = math.max(1.5, (player.MoveSpeed + 0.1) * 1.5)
                data.WarpZone_unsavedata.Boosterv2_ForceSpeed = math.max(0, player.MoveSpeed - 2)
            end
        elseif cache == CacheFlag.CACHE_RANGE then
            if polstr then
                player.TearHeight = player.TearHeight + 20
            end
        end
    end

    function WarpZone.PolarStarBoosterv2_PrePlayerDmg(_, ent, damage, fg, source)
        local player = ent:ToPlayer()
        
        if player and damage > 0
        and fg & DamageFlag.DAMAGE_NO_PENALTIES == 0 and fg &  DamageFlag.DAMAGE_FAKE == 0
        and fg & DamageFlag.DAMAGE_RED_HEARTS == 0 then
            
            local boos = player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOOSTERV2) or Isaac.GetChallenge() == WarpZone.WarpZoneTypes.CHALLENGE_UNQUOTE
            local udata = player:GetData().WarpZone_unsavedata
            if boos and udata.PolarStarLVL > 2 then
                udata.Boosterv2_shilaVjope = true
                return false
            end
        end
    end
    WarpZone:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 1, WarpZone.PolarStarBoosterv2_PrePlayerDmg)

    function WarpZone.PolarStarBoosterv2_LastPlayerDmg(_, ent, damage, fg, source)
        local player = ent:ToPlayer()
        
        if player and (Renderer or damage > 0) 
        and fg & DamageFlag.DAMAGE_NO_PENALTIES == 0 and fg &  DamageFlag.DAMAGE_FAKE == 0
        and fg & DamageFlag.DAMAGE_RED_HEARTS == 0 then
            local polstr = player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR) or Isaac.GetChallenge() == WarpZone.WarpZoneTypes.CHALLENGE_UNQUOTE
            local boos = player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOOSTERV2) or Isaac.GetChallenge() == WarpZone.WarpZoneTypes.CHALLENGE_UNQUOTE
            if polstr or boos then
                local udata = player:GetData().WarpZone_unsavedata
                if udata.PolarStarLVL > 1 then
                    udata.PolarStarLVL = udata.PolarStarLVL - 1
                    udata.PolarStarEXP = 0

                    local ef = Isaac.Spawn(EntityType.ENTITY_EFFECT, 102, 0,
                        player.Position+Vector(0,-30), Vector(0,0), player):ToEffect()
                    ef.DepthOffset = 100
                    local es = ef:GetSprite()
                    es:Load("gfx/effects/polar star_level.anm2", true)
                    es:Play("level down")
                    player:AddCacheFlags(CacheFlag.CACHE_FLYING | CacheFlag.CACHE_SPEED)
                    player:EvaluateItems()
                end
            end
        end
    end
    if Renderer then
        WarpZone:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, WarpZone.PolarStarBoosterv2_LastPlayerDmg)
    else
        WarpZone:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 100, WarpZone.PolarStarBoosterv2_LastPlayerDmg)
    end

    function WarpZone.SpawnPolarStarEXP(pos, amout, rng, source)
        amout = amout or 1
        for i=1, amout do
            local seed = rng:RandomInt(300000000)+1
            local vec
            if Renderer then
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

    local EXPLogic = {
        [0] = function(ent,spr,pos)
            --if spr:GetAnimation() ~= "point_bounce" then
                ent.PositionOffset = ent.PositionOffset + Vector(0, ent.FallingSpeed)
            --end
            if ent.PositionOffset.Y > 0 then
                ent.FallingSpeed = -4 - ent:GetDropRNG():RandomFloat()*2 -- -ent.FallingSpeed *0.95
                ent.PositionOffset = Vector(ent.PositionOffset.X, 0)
                spr:Play("point_bounce")
                ent.TargetPosition = ent.Velocity/1
                ent.Velocity = ent.Velocity/2
            else --if spr:GetAnimation() ~= "point_bounce" then
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
                    if player and (player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR) 
                    or player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOOSTERV2))
                    and player.Position:Distance(pos) < 300 then
                        ent.Target = player
                        break
                    end
                end
            elseif ent.Target:Exists() then
                local target = ent.Target
                local dist = math.max(0, 300 - target.Position:Distance(pos))

                local vel = (target.Position+target.Velocity-pos):Resized(dist/10)
                ent.Velocity = ent.Velocity * 0.9 + vel * 0.1

                if dist > 300-30 then --target.Size*3
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
            
            if spr:IsFinished("point_bounce") then
                spr:Play("point_idle")
                ent.Velocity = ent.TargetPosition/1
                if ent.FrameCount % 60 < 10 then
                    spr:Play("point_круток")
                end
            elseif spr:IsFinished() then
                spr:Play("point_idle")
            end
            ent.FlipX = ent.Velocity.X < 1
        end,
        [5] = function(ent,spr,pos)
            if spr:IsFinished() then
                ent:Remove()
            end
            --[[if ent.SpawnerEntity and ent.FrameCount % 3 == 1 then
                local player = ent.SpawnerEntity:ToPlayer()
                if player then
                    local list = Isaac.FindInRadius(pos, 60, EntityPartition.ENEMY)
                    for i=1, #list do
                        local e = list[i]
                        if e:IsActiveEnemy() and not e:IsInvincible() then
                            e:AddBurn(EntityRef(player), 30, player.Damage)
                        end
                    end
                end
            end]]
        end,
        [10] = function(ent,spr,pos)
            if spr:IsFinished() then
                ent:Remove()
            end
        end,
    }



    ---@param ent EntityEffect
    function WarpZone.PolarStarEXPEnt_update(_, ent)
        local spr = ent:GetSprite()
        local pos = ent.Position
        if EXPLogic[ent.SubType] and EXPLogic[ent.SubType](ent,spr,pos) then

        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, WarpZone.PolarStarEXPEnt_update, PolarStarEXTent)

    local prevent = false
    ---@param player EntityPlayer
    function WarpZone.Boosterv2_playerRender(_, player, offset)
        if prevent then return end
        local spr = player:GetSprite()
        local data = player:GetData()
        local udata = data.WarpZone_unsavedata

        if udata.bosv2_rendMannul then
            local frame = udata.Bosv2_3Frame
            prevent = true
            local por = Vector(0,-player.PositionOffset.Y/Wtr - udata.bosv2_renderpos) + offset
            player:Render(por)
            prevent = false

        end
    end

end