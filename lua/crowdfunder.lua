return function (mod)

    local SfxManager = SFXManager()
    local game = Game()

    local lerpAngle = function(a, b, t)
        return (a - (((a+180)-b)%360-180)*t) % 360
    end

    local CrowdfunderVar = Isaac.GetEntityVariantByName("Crowdfunder")
    local shootAnim = {
        ["ShootLoop" .. "Right"] = true,
        ["ShootLoop" .. "Down"] = true,
        ["ShootLoop" .. "Left"] = true,
        ["ShootLoop" .. "Up"] = true,
    }

    ---@param spr Sprite
    local function crowdfundAnimation(degrees, spr, player)
        local prefix = "Shoot"
        local suffix = ""
    
        local controllerid = player.ControllerIndex
        local aim = player:GetAimDirection():Length()>0.05
    
        if not aim then
            if spr:GetAnimation():sub(1, 9) == "ShootLoop" then
                prefix = "ShootEnd"
            elseif not spr:IsFinished() and spr:GetAnimation():find("ShootEnd") then   --:sub(1, 8) == "ShootEnd" then
                prefix = "ShootEnd"
            else
                prefix = "Idle"
            end
        else
            --print(fam:GetSprite():GetAnimation():sub(1, 10))
            if not spr:IsFinished() and spr:GetAnimation():find("ShootBegin") then   --:sub(1, 10) == "ShootBegin" then
                prefix = "ShootBegin"
            elseif spr:GetAnimation():sub(1, 4) == "Idle" then
                prefix = "ShootBegin"
            else
                prefix = "ShootLoop"
            end
        end
    
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
    
        local animName = prefix .. suffix
        if spr:GetAnimation() ~= animName then
            if animName:sub(1, 8) ~= spr:GetAnimation():sub(1, 8) then
                spr:Play(animName, true)
            else
                spr:SetAnimation(animName, false)
            end
            
        end
        
        if spr:GetFrame() == -1 then
            spr:SetFrame(1)
        end
    end
    
    ---@param fam EntityFamiliar
    function WarpZone:update_crowdfunder(fam)
        local player = fam.Player
        local spr = fam:GetSprite()
        --local headRotation = getVectorFromDirection(player:GetAimDirection())
        local aim = player:GetAimDirection()
        local isAim = aim:Length() > 0.01
        local rotation = aim
    
        if not isAim then
            rotation = player:GetMovementInput():Length()>0.05 and Vector.FromAngle(player:GetSmoothBodyRotation()) or Vector(0,1)  --headRotation
            fam.Coins = math.min(20, fam.Coins + 1)
        end
    
        spr.Rotation = lerpAngle(spr.Rotation, rotation:GetAngleDegrees(), 0.4)
        local newPos = player.Position + Vector.FromAngle(spr.Rotation):Resized(25)   --(rotation:Normalized() * 25)
        newPos = newPos --+ Vector(0, -10)
        fam.Velocity = newPos - fam.Position
    
        if isAim and shootAnim[spr:GetAnimation()] then
            if fam.FireCooldown <= 0 and player:GetNumCoins() > 0 then
                fam.FireCooldown = 3 + math.max(math.floor(fam.Coins/2), 0)
                fam.Coins = math.max(fam.Coins - 1, -120)

                SfxManager:Play(SoundEffect.SOUND_GFUEL_GUNSHOT, nil, 1, false, 0.7)
                player:AddCoins(-1)
                local weakhandissue = fam.Coins<0 and (fam:GetDropRNG():RandomInt(-fam.Coins)+fam.Coins/2)/4 or 0
               
                local aimspeed = player:GetAimDirection():Rotated(weakhandissue) * 16
                local firePosition = player.Position + (player:GetAimDirection() * 18) --+ Vector(0, 13)
                local cointear = player:FireTear(firePosition, aimspeed, false, false, false, player, 1)
                cointear.CollisionDamage = cointear.CollisionDamage + 10
                cointear:AddTearFlags(TearFlags.TEAR_GREED_COIN)
                cointear:ChangeVariant(TearVariant.COIN)
                --local sprite = cointear:GetSprite()
                --sprite:Load("gfx/002.020_coin tear.anm2",true)
                --sprite:Play("Rotate2")
                cointear:ResetSpriteScale()
                cointear:GetData().CrowdfunderShot = 2

                player:AddVelocity(-aimspeed/10)

                game:ShakeScreen(3)

                --[[local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, 102, 0,
                fam.Position, Vector(0,0), fam):ToEffect()
                eff:Update()
                local sprr = eff:GetSprite()
                sprr:Load("gfx/promo/gfuel/effects/muzzle_flash.anm2", true)
                sprr:PlayRandom(eff:GetDropRNG():RandomInt(100000)+1)
                sprr.Rotation = aimspeed:GetAngleDegrees()]]

            elseif player:GetNumCoins() <= 0 then
                fam.Coins = math.min(10, fam.Coins + 1)
            end

        end

        if fam.Coins < 0 then
            local c = fam.Color
            --fam.Color = Color(c.R, c.G, c.B, )
            local proc = -fam.Coins/120
            local red = Color(1,1,1,1, proc)
            red:SetColorize(1,.43,.3, proc)
            fam:SetColor(red, 5, 1, false, false)
            if fam.Coins <= -30 and fam.FrameCount % 3 == 0 then
                local rot = Vector.FromAngle(fam.SpriteRotation)
                local vel = Vector(fam:GetDropRNG():RandomInt(7)-3,-3) + rot:Resized(5)
                local pw = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0,
                    fam.Position+fam.PositionOffset + rot:Resized(15), vel, fam):ToEffect()
                pw.DepthOffset = 50
                pw.LifeSpan = 50
                pw.Timeout = 15
                pw:GetSprite().Scale = Vector(.2,.2)
                pw:Update()
            end
        end

        fam.FireCooldown = math.max(0, fam.FireCooldown - 1)

        crowdfundAnimation(spr.Rotation, spr, player)
    end
    WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, WarpZone.update_crowdfunder, CrowdfunderVar)

    function WarpZone:init_crowdfunder(fam)
        fam.PositionOffset = Vector(0,-15)
    end
    WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, WarpZone.init_crowdfunder, CrowdfunderVar)

    ---@param player EntityPlayer
    function WarpZone:Crowdfunder_Use(collectible, rng, player, useflags)
        local daat = player:GetData()
        daat.WarpZone_unsavedata.Crowdfunder = not daat.WarpZone_unsavedata.Crowdfunder
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS | CacheFlag.CACHE_SPEED)
        --player:EvaluateItems()
        SfxManager:Play(WarpZone.WarpZoneTypes.SOUND_GUN_SWAP, Options.SFXVolume*20)

        return {
            Discharge = false,
            Remove = false,
            ShowAnim = true
        }
    end
    WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.Crowdfunder_Use, WarpZone.WarpZoneTypes.COLLECTIBLE_CROWDFUNDER)

    ---@param player EntityPlayer
    function WarpZone:Crowdfunder_EvaluateCache(player, cache)
        if cache == CacheFlag.CACHE_FAMILIARS then
            local data = player:GetData()
            --if not player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_CROWDFUNDER) then
            --    data.WarpZone_unsavedata.Crowdfunder = nil
            --end
            
            local count = data.WarpZone_unsavedata.Crowdfunder and 1 or 0
            local rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_CROWDFUNDER)
            player:CheckFamiliar(CrowdfunderVar, count, rng)
            if count == 0 and player:GetEffects():HasCollectibleEffect(WarpZone.WarpZoneTypes.COLLECTIBLE_CROWDFUNDER) then
                player:GetEffects():RemoveCollectibleEffect(WarpZone.WarpZoneTypes.COLLECTIBLE_CROWDFUNDER, -1)
            end
        elseif cache == CacheFlag.CACHE_SPEED then
            if player:GetData().WarpZone_unsavedata.Crowdfunder then
                player.MoveSpeed = player.MoveSpeed * 0.75
            end
        end
    end

    ---@param player EntityPlayer
    ---@param effects TemporaryEffects
    function WarpZone.Crowdfunder_PlayerUpdate(player, effects)
        local data = player:GetData()
        if effects:HasCollectibleEffect(WarpZone.WarpZoneTypes.COLLECTIBLE_CROWDFUNDER) then
            player.FireDelay = math.max(player.FireDelay, 5)
        elseif data.WarpZone_unsavedata.Crowdfunder 
        and not player:GetEffects():HasCollectibleEffect(WarpZone.WarpZoneTypes.COLLECTIBLE_CROWDFUNDER) then
            data.WarpZone_unsavedata.Crowdfunder = nil
            WarpZone:Crowdfunder_EvaluateCache(player, CacheFlag.CACHE_FAMILIARS)
            player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            --player:GetEffects():RemoveCollectibleEffect(WarpZone.WarpZoneTypes.COLLECTIBLE_CROWDFUNDER, -1)
        end
    end

end