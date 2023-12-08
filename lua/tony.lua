return function(mod)
    local sfx = SFXManager()
    local music = MusicManager()
    local Isaac = Isaac
    local game = Game()
    local Wtr = 20/13

    local bodycolor = {
        [0] = "",
        [SkinColor.SKIN_BLACK] = "_black",
        [SkinColor.SKIN_BLUE] = "_blue",
        [SkinColor.SKIN_GREEN] = "_green",
        [SkinColor.SKIN_GREY] = "_grey",
        [SkinColor.SKIN_PINK] = "",
        [SkinColor.SKIN_RED] = "_red",
        [SkinColor.SKIN_SHADOW] = "_shadow",
        [SkinColor.SKIN_WHITE] = "_white",
    }

    WarpZone.TonyRageTime = 2160

    ---@param player EntityPlayer
    function WarpZone.TonyTakeDmg(player, amount, damageflags, source, countdownframes)
        if player and player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY) then
            local effects = player:GetEffects()
            if effects:GetCollectibleEffectNum(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY) <= 0 then
                effects:AddCollectibleEffect(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY, false, WarpZone.TonyRageTime)
                player:AddNullCostume(WarpZone.WarpZoneTypes.COSTUME_TONY_RAGE)
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
                player:GetData().WarpZone_removeTonyCostume = true

                WarpZone.SetWeaponType(player, player:GetData(), 
                    {type = WarpZone.WarpZoneTypes.WEAPON_TONY}, 10)
            end
        end
    end

    ---@param pos Vector
    ---@param vec Vector
    local function blooddusk(pos, vec, col)
        for i=-2, 3 do
            local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, pos, vec:Rotated(i*15), nil):ToEffect()
            dust.Color = Color(0.9,.05,.3, 0.4) * col
            dust.LifeSpan = 55
            dust.Timeout = 30
            dust:GetSprite().Scale = Vector(1.2, 1.2)
        end
    end

    local function dustpoof(pos, angle)
        for i=-4,4 do
            local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, pos, angle:Rotated(i*7) * (2-math.abs(i)/10), nil):ToEffect()
            dust.Color = Color(1, 1, 1, 0.7)
            dust:SetColor(Color(1, 1, 1, 0.0), 40, 1, true, false)
            dust.LifeSpan = 35
            dust.Timeout = 7
            dust:GetSprite().Scale = Vector(0.48, 0.48)
        end
    end

    local function SpawnGibs(count, pos, vec, rng, color)
        local anlge = vec:GetAngleDegrees()
        for i=1, count do
            for c = 1, i do
                local pos = pos + Vector.FromAngle(anlge):Resized(i*20):Rotated((rng:RandomFloat()-.5) * 30)
                local blood = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, pos, Vector.Zero, nil):ToEffect()
                blood.Color = color
            end
        end
    end

    ---@param player EntityPlayer
    function WarpZone.TonyTake_update(player)
        local data = player:GetData()
        local effects = player:GetEffects()
        local tonynum = effects:GetCollectibleEffectNum(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY)
        if tonynum >= 1 then
            local unsave = data.WarpZone_unsavedata
            if tonynum > 1 then
                player.FireDelay = 3
                local pr = (tonynum%10)/20
                player:SetColor(Color(1+pr,1-pr,1-pr,1,pr), 1, -1, true, false)

                local aim = player:GetAimDirection()
                local isAim = aim:Length() > 0.01
                if isAim then
                    local attackpos = player.Position + aim:Resized(20*1.54)
                    local angle = aim:GetAngleDegrees()
                    if Isaac.GetFrameCount() % 3 == 0 then
                        local list = Isaac.FindInRadius(attackpos, 60, EntityPartition.ENEMY)
                        local ref = EntityRef(player)
                        local rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY)
                        local playsound = false

                        for i=1 , #list do
                            local ent = list[i]
                            if ent:IsActiveEnemy() then
                                if ent.HitPoints < 100 and not ent:IsBoss() then
                                    ent:AddVelocity(aim:Resized(16*1.54))
                                    ent:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
                                    ent:Kill()
                                    --game:SpawnParticles()
                                    --ent:BloodExplode()
                                    blooddusk(ent.Position, aim:Resized(16), ent.SplatColor)
                                    SpawnGibs(5, ent.Position, aim:Resized(16), rng, ent.SplatColor)

                                    game:ShakeScreen(5)
                                    if effects:GetCollectibleEffectNum(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY) < 60 then
                                        effects:AddCollectibleEffect(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY, false, 30)
                                    end
                                else
                                    local tear = 30 / (player.MaxFireDelay + 1)
                                    ent:TakeDamage(player.Damage*tear, DamageFlag.DAMAGE_CRUSH, ref, 5)
                                    --if effects:GetCollectibleEffectNum(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY) < 60 then
                                    --    effects:AddCollectibleEffect(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY, false, 10)
                                    --end
                                end
                                playsound = true
                            end
                        end
                        if playsound then
                            sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, nil, 3)
                            sfx:Play(SoundEffect.SOUND_BLACK_POOF, nil, 3, false, 3)
                        end

                        local list = Isaac.FindByType(33,-1,-1)
                        for i=1 , #list do
                            local ent = list[i]
                            if ent.Position:Distance(attackpos) < 50 then
                                ent:TakeDamage(5, 0, ref, 0)
                                ent:Update()
                                ent:TakeDamage(5, 0, ref, 0)
                                ent:Update()
                                ent:TakeDamage(5, 0, ref, 0)
                            end
                        end

                        local list = Isaac.FindByType(4)
                        for i=1 , #list do
                            local ent = list[i]
                            if ent.Position:Distance(attackpos) < 50 then
                                ent:AddVelocity(aim:Resized(5))
                            end
                        end

                        local list = Isaac.FindInRadius(attackpos, 50, EntityPartition.BULLET)
                        for i=1 , #list do
                            local ent = list[i]
                            ent.Velocity = aim:Resized(ent.Velocity:Length()+7)
                            ent:ToProjectile():AddProjectileFlags(ProjectileFlags.HIT_ENEMIES)
                        end

                        local room = game:GetRoom()
                        for i=0, 360-45, 45 do
                            local pos = attackpos + Vector.FromAngle(i):Resized(20)
                            local grid = room:GetGridEntityFromPos(pos)
                            if grid and grid:Hurt(1) then
                                
                            end
                        end
                    end

                    if unsave.TonyHandSpr then
                        local hads = unsave.TonyHandSpr

                        hads.delay = hads.delay and(hads.delay - 1) or 0
                        if hads.delay <= 0 then
                            
                            if hads.rig:IsFinished() then
                                hads.rightangle = aim/1
                                --hads.rightpos = Isaac.WorldToScreen(player.Position)
                                hads.rig:Play("правой", true)
                                hads.delay = 7
                                dustpoof(player.Position, aim:Resized(20))
                                sfx:Play(SoundEffect.SOUND_FETUS_JUMP, Options.SFXVolume*3, 2, nil, 1.3)
                            elseif hads.left:IsFinished() then
                                hads.lefthtangle = aim/1
                                --hads.lefthpos = Isaac.WorldToScreen(player.Position)
                                hads.left:Play("левой", true)
                                hads.delay = 7
                                dustpoof(player.Position, aim:Resized(20))
                                sfx:Play(SoundEffect.SOUND_FETUS_JUMP, Options.SFXVolume*3, 2, nil, 1.3)
                            end
                        end
                        --print(hads.lefthtangle, hads.rightangle, hads.rig:IsFinished())
                        hads.rig:Update()
                        hads.left:Update()
                        ---if hads.isright then
                        --    hads.rightangle = aim:GetAngleDegrees()
                        --end
                    end
                end


                effects:AddCollectibleEffect(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY, false, -1)
                if effects:GetCollectibleEffectNum(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY) <= 1 then
                    --player:TryRemoveNullCostume(WarpZone.WarpZoneTypes.COSTUME_TONY_RAGE)
                    --data.WarpZone_removeTonyCostume = nil
                    WarpZone.RemoveWeaponType(player, data, 
                        {type = WarpZone.WarpZoneTypes.WEAPON_TONY})

                    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                    player:EvaluateItems()
                end
            end
        else
            if data.WarpZone_removeTonyCostume then
                WarpZone.RemoveWeaponType(player, data, 
                    {type = WarpZone.WarpZoneTypes.WEAPON_TONY})

                data.WarpZone_removeTonyCostume = nil
                player:TryRemoveNullCostume(WarpZone.WarpZoneTypes.COSTUME_TONY_RAGE)
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end
        end
    end

    ---@param player EntityPlayer
    function WarpZone.Tony_render(player, offset)
        local data = player:GetData()
        local effects = player:GetEffects()
        local tonynum = effects:GetCollectibleEffectNum(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY)
        if tonynum > 1 then
            WarpZone.IsTONYYYRAGEEE = true
            if data.WarpZone_unsavedata then
                local unsave = data.WarpZone_unsavedata
                if not unsave.TonyHandSpr then
                    unsave.TonyHandSpr = {spr = Sprite(), bod = player:GetBodyColor(), isright = true}
                    local hads = unsave.TonyHandSpr
                    hads.spr:Load("gfx/characters/tonypunch.anm2", true)
                    hads.spr:Play("вниз")
                    hads.spr.PlaybackSpeed = 1.25
                    local suff = bodycolor[player:GetBodyColor()] or ""
                    for i=0,1 do
                        hads.spr:ReplaceSpritesheet(i, "gfx/characters/tonypunch_hand"..suff..".png")
                    end
                    hads.spr:LoadGraphics()

                    hads.rig = Sprite()
                    hads.rig:Load("gfx/characters/tonypunch.anm2", true)
                    hads.rig:Play("правой")
                    hads.rig.PlaybackSpeed = 1 -- 1.25
                    local suff = bodycolor[player:GetBodyColor()] or ""
                    for i=0,1 do
                        hads.rig:ReplaceSpritesheet(i, "gfx/characters/tonypunch_hand"..suff..".png")
                    end
                    hads.rig:LoadGraphics()

                    hads.left = Sprite()
                    hads.left:Load("gfx/characters/tonypunch.anm2", true)
                    hads.left:Play("левой")
                    hads.left.PlaybackSpeed = 1 -- 1.25
                    local suff = bodycolor[player:GetBodyColor()] or ""
                    for i=0,1 do
                        hads.left:ReplaceSpritesheet(i, "gfx/characters/tonypunch_hand"..suff..".png")
                    end
                    hads.left:LoadGraphics()
                else
                    local hads = unsave.TonyHandSpr
                    if player:GetBodyColor() ~= unsave.TonyHandSpr.bod then
                        unsave.TonyHandSpr.bod = player:GetBodyColor()
                        local suff = bodycolor[player:GetBodyColor()] or ""
                        for i=0,1 do
                            hads.spr:ReplaceSpritesheet(i, "gfx/characters/tonypunch_hand"..suff..".png")
                        end
                        hads.spr:LoadGraphics()

                        for i=0,1 do
                            hads.rig:ReplaceSpritesheet(i, "gfx/characters/tonypunch_hand"..suff..".png")
                        end
                        hads.rig:LoadGraphics()
                        for i=0,1 do
                            hads.left:ReplaceSpritesheet(i, "gfx/characters/tonypunch_hand"..suff..".png")
                        end
                        hads.left:LoadGraphics()
                    end
                    local aim = player:GetAimDirection()
                    local isAim = aim:Length() > 0.01
                    local rotation
                    if not isAim then
                        
                    else
                        rotation = aim
                        local rendermode = game:GetRoom():GetRenderMode()
                        --local renderPos = Isaac.WorldToScreen(player.Position) + rotation:Resized(16)
                        unsave.TonyHandSpr.spr.Color = player:GetColor()
                        unsave.TonyHandSpr.spr.Rotation = rotation:GetAngleDegrees()-90

                        if rendermode == RenderMode.RENDER_NORMAL or rendermode == RenderMode.RENDER_WATER_ABOVE then
                            --local renderPos = Isaac.WorldToScreen(player.Position) + rotation:Resized(16)
                            --unsave.TonyHandSpr.spr.Color = player:GetColor()
                            --unsave.TonyHandSpr.spr.Rotation = rotation:GetAngleDegrees()-90
                            --unsave.TonyHandSpr.spr:Render(renderPos)
                            --unsave.TonyHandSpr.spr:Update()

                            local plapos = Isaac.WorldToScreen(player.Position)
                            if hads.rightangle then
                                local renderPos = plapos + hads.rightangle:Resized(16)
                                hads.rig.Rotation = hads.rightangle:GetAngleDegrees()-90
                                hads.rig:Render(renderPos)
                            end
                            if hads.lefthtangle then
                                local renderPos = plapos + hads.lefthtangle:Resized(16)
                                hads.left.Rotation = hads.lefthtangle:GetAngleDegrees()-90
                                hads.left:Render(renderPos)
                            end
                        elseif rendermode == RenderMode.RENDER_WATER_REFLECT then
                            --local renderPos = Isaac.WorldToScreen(player.Position) + rotation:Resized(16)
                            --unsave.TonyHandSpr.spr.Color = player:GetColor()
                            --unsave.TonyHandSpr.spr.Rotation = rotation:GetAngleDegrees()-90
                            --unsave.TonyHandSpr.spr:Render(renderPos+offset)
                        end
                    end
                end
            end
        end
    end

    ---@param player EntityPlayer
    function WarpZone.Tony_cache(player, cache)
        if cache == CacheFlag.CACHE_SPEED 
        and player:GetEffects():GetCollectibleEffectNum(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY) > 1 then
            player.MoveSpeed = player.MoveSpeed + 1
        end
    end
    --local config = Isaac.GetItemConfig()
    --print(WarpZone.WarpZoneTypes.COSTUME_TONY_RAGE,
    --config:GetNullItem(WarpZone.WarpZoneTypes.COSTUME_TONY_RAGE).Costume.Priority
    --)

    WarpZone.TONYRAGEAmout = 0
    local resetpitch = false

    function WarpZone.TonyRageShader(_,name)
        if name == "WarpZone_TonyRage" then
            if WarpZone.IsTONYYYRAGEEE then
                WarpZone.TONYRAGEAmout = WarpZone.TONYRAGEAmout * 0.95 + .05
                music:PitchSlide(0.6)
                resetpitch = true
            else
                WarpZone.TONYRAGEAmout = WarpZone.TONYRAGEAmout * 0.95
                if WarpZone.TONYRAGEAmout < 0.001 then
                    WarpZone.TONYRAGEAmout = 0
                end
                if resetpitch then
                    resetpitch = false
                    music:PitchSlide(1)
                end
            end
            
            WarpZone.IsTONYYYRAGEEE = false
            local screensize = Vector(Isaac.GetScreenWidth(),Isaac.GetScreenHeight())
            screensize = screensize --* Isaac.GetScreenPointScale() *2
            ---print( (math.sin( Isaac.GetFrameCount()/50 )+1) / 2 + .5 )
            --print( (math.sin( Isaac.GetFrameCount()/50 )+1) / 2 )
            local playerpos = Isaac.WorldToScreen(Isaac.GetPlayer().Position)
            local tab = {ActiveIn = WarpZone.TONYRAGEAmout, TonyTime = Isaac.GetFrameCount(), ScreenSize = {screensize.X, screensize.Y},
                PlayerPos = {playerpos.X, playerpos.Y}}
            return tab
        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, WarpZone.TonyRageShader)
end