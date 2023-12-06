return function(mod)
    local sfx = SFXManager()
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

    WarpZone.TonyRageTime = 360

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
            end
        end
    end

    ---@param pos Vector
    ---@param vec Vector
    local function blooddusk(pos, vec)
        for i=-1, 1 do
            local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, pos, vec:Rotated(i*15), nil):ToEffect()
            dust.Color = Color(0.9,.05,.3, 0.4)
            dust.LifeSpan = 55
            dust.Timeout = 30
            dust:GetSprite().Scale = Vector(1.2, 1.2)
        end
    end

    ---@param player EntityPlayer
    function WarpZone.TonyTake_update(player)
        local data = player:GetData()
        local effects = player:GetEffects()
        local tonynum = effects:GetCollectibleEffectNum(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY)
        if tonynum >= 1 then
            if tonynum > 1 then
                player.FireDelay = 3
                local pr = (tonynum%10)/20
                player:SetColor(Color(1+pr,1-pr,1-pr,1,pr), 1, -1, true, false)

                local aim = player:GetAimDirection()
                local isAim = aim:Length() > 0.01
                if isAim then
                    local attackpos = player.Position + aim:Resized(16*1.54)
                    if Isaac.GetFrameCount() % 3 == 0 then
                        local list = Isaac.FindInRadius(attackpos, 50, EntityPartition.ENEMY)
                        local ref = EntityRef(player)
                        for i=1 , #list do
                            local ent = list[i]
                            if ent:IsActiveEnemy() then
                                if ent.HitPoints < 100 and not ent:IsBoss() then
                                    ent:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
                                    ent:Kill()
                                    --ent:BloodExplode()
                                    blooddusk(ent.Position, aim:Resized(16))
                                    game:ShakeScreen(5)
                                    effects:AddCollectibleEffect(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY, false, 30)
                                else
                                    local tear = 30 / (player.MaxFireDelay + 1)
                                    ent:TakeDamage(player.Damage*tear/2, DamageFlag.DAMAGE_CRUSH, ref, 5)
                                end
                            end
                        end
                    end
                end


                effects:AddCollectibleEffect(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY, false, -1)
                if effects:GetCollectibleEffectNum(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY) <= 1 then
                    --player:TryRemoveNullCostume(WarpZone.WarpZoneTypes.COSTUME_TONY_RAGE)
                    --data.WarpZone_removeTonyCostume = nil
                    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                    player:EvaluateItems()
                end
            end
        else
            if data.WarpZone_removeTonyCostume then
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
            if data.WarpZone_unsavedata then
                local unsave = data.WarpZone_unsavedata
                if not unsave.TonyHandSpr then
                    unsave.TonyHandSpr = {spr = Sprite(), bod = player:GetBodyColor()}
                    unsave.TonyHandSpr.spr:Load("gfx/characters/tonypunch.anm2", true)
                    unsave.TonyHandSpr.spr:Play("вниз")
                    unsave.TonyHandSpr.spr.PlaybackSpeed = 1.25
                    local suff = bodycolor[player:GetBodyColor()] or ""
                    for i=0,1 do
                        unsave.TonyHandSpr.spr:ReplaceSpritesheet(i, "gfx/characters/tonypunch_hand"..suff..".png")
                    end
                    unsave.TonyHandSpr.spr:LoadGraphics()
                else
                    if player:GetBodyColor() ~= unsave.TonyHandSpr.bod then
                        unsave.TonyHandSpr.bod = player:GetBodyColor()
                        local suff = bodycolor[player:GetBodyColor()] or ""
                        for i=0,1 do
                            unsave.TonyHandSpr.spr:ReplaceSpritesheet(i, "gfx/characters/tonypunch_hand"..suff..".png")
                        end
                        unsave.TonyHandSpr.spr:LoadGraphics()
                    end
                    local aim = player:GetAimDirection()
                    local isAim = aim:Length() > 0.01
                    local rotation
                    if not isAim then
                        
                    else
                        rotation = aim
                        local rendermode = game:GetRoom():GetRenderMode()
                        local renderPos = Isaac.WorldToScreen(player.Position) + rotation:Resized(16)
                        unsave.TonyHandSpr.spr.Color = player:GetColor()
                        unsave.TonyHandSpr.spr.Rotation = rotation:GetAngleDegrees()-90

                        if rendermode == RenderMode.RENDER_NORMAL or rendermode == RenderMode.RENDER_WATER_ABOVE then
                            --local renderPos = Isaac.WorldToScreen(player.Position) + rotation:Resized(16)
                            --unsave.TonyHandSpr.spr.Color = player:GetColor()
                            --unsave.TonyHandSpr.spr.Rotation = rotation:GetAngleDegrees()-90
                            unsave.TonyHandSpr.spr:Render(renderPos)
                            unsave.TonyHandSpr.spr:Update()
                        elseif rendermode == RenderMode.RENDER_WATER_REFLECT then
                            --local renderPos = Isaac.WorldToScreen(player.Position) + rotation:Resized(16)
                            --unsave.TonyHandSpr.spr.Color = player:GetColor()
                            --unsave.TonyHandSpr.spr.Rotation = rotation:GetAngleDegrees()-90
                            unsave.TonyHandSpr.spr:Render(renderPos+offset)
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
end