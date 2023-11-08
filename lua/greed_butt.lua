return function (mod)

    local game = Game()
    local perdotyaga = 90

    local function GenSprite(gfx, anim, frame)
        if gfx then
            local spr = Sprite()
            spr:Load(gfx, true)
            if anim then
                spr:Play(anim)
            else
                spr:Play(spr:GetDefaultAnimation())
            end
            if frame then
                spr:SetFrame(frame)
            end
            return spr
        end
    end

    local GreedButtEffectType = Isaac.GetEntityVariantByName("WZ greed butt effect")

    function WarpZone.GreedButtCoinPickup(player, value)
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_GREED_BUTT) then
            local data = player:GetData().WarpZone_data
            data.GreedButtCoints = data.GreedButtCoints or 5
            data.GreedButtCoints = math.min(5, data.GreedButtCoints + value)
        end
    end

    function WarpZone.GreedButtEffect(player, data, spr)
        data.WarpZone_data.GreedButtCoints = data.WarpZone_data.GreedButtCoints or 5
        data.WarpZone_unsavedata.GreedButt = data.WarpZone_unsavedata.GreedButt or {}
        local sdata = data.WarpZone_unsavedata.GreedButt

        if not sdata.ent or not sdata.ent:Exists() then
            sdata.ent = Isaac.Spawn(EntityType.ENTITY_EFFECT, GreedButtEffectType, 0, 
                player.Position, Vector(0,0), player)
        elseif sdata.ent then
            local edata = sdata.ent:GetData()
            if sdata.rush then
                edata["скорость вращения"] = 20
                
                if sdata.rush%10 == 0 then
                    game:ButterBeanFart(player.Position, 90, player, false, false)
                    local list = Isaac.FindInRadius(player.Position, 90, EntityPartition.ENEMY)
                    for i=1,#list do
                        local ent = list[i]
                        if ent:IsActiveEnemy(false) and ent:IsVulnerableEnemy() then
                            ent:AddPoison(EntityRef(player), 15, player.Damage)
                        end
                    end
                end

                edata["пердотяга"] = sdata.rush
                sdata.rush = sdata.rush - 1
                if sdata.rush <= 0 then
                    edata["перди"] = false
                    sdata.rush = nil
                end
            end
        end
    end

    local function effect(player, source)
        local playerPosition = player.Position
            
        local velConstant = 16
        local backstab = true
        local coinvelocity = player:GetAimDirection() * -velConstant
        if coinvelocity:Length() < 0.1 then
            coinvelocity = Vector.FromAngle(player:GetSmoothBodyRotation()) * -velConstant
        end

        if backstab == true then
            local gb_rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_GREED_BUTT)
            local benchmark = gb_rng:RandomInt(100)
            if benchmark < 5 then
                local room = game:GetRoom()
                --local id = findFreeTile(player.Position)
                local id = room:FindFreeTilePosition(playerPosition, 100)
                id = room:GetGridIndex(id)
                if id ~= false then
                    game:GetRoom():SpawnGridEntity(id, GridEntityType.GRID_POOP, 3, gb_rng:Next(), 0)
                    SFXManager():Play(SoundEffect.SOUND_FART, 1.0, 0, false, 1.0)
                end
                player:UseActiveItem(CollectibleType.COLLECTIBLE_BEAN)
                player:UseActiveItem(CollectibleType.COLLECTIBLE_BUTTER_BEAN)
            else
                Isaac.Spawn(EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_COIN,
                    0,
                    game:GetRoom():FindFreePickupSpawnPosition(player.Position),
                    coinvelocity,
                    player)
                
                player:UseActiveItem(CollectibleType.COLLECTIBLE_BEAN)
                player:UseActiveItem(CollectibleType.COLLECTIBLE_BUTTER_BEAN)
            end
        end
    end

    ---@param player EntityPlayer
    ---@param ent Entity
    function WarpZone.GreedButt_PlayerCollide(_, ent, player)
        player = player:ToPlayer()
        if not player then return end
        local pdata = player:GetData()
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_GREED_BUTT) 
        and pdata.WarpZone_data.GreedButtCoints >= 5 then
            if ent.Type == EntityType.ENTITY_PROJECTILE or ent:IsActiveEnemy() then
                effect(player, ent)
                pdata.WarpZone_data.GreedButtCoints = 0
                pdata.WarpZone_unsavedata.GreedButt.rush = perdotyaga
                pdata.WarpZone_unsavedata.GreedButt.ent:GetData()["перди"] = true
                ent.Velocity = (ent.Position - player.Position):Resized(5)
                return true
            end
        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, WarpZone.GreedButt_PlayerCollide)
    WarpZone:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, WarpZone.GreedButt_PlayerCollide)


    ---@param e EntityEffect
    function WarpZone.GreedButtEffect_ent_init(_, e)
        if e.SubType == 0 then
            if e.SpawnerEntity then
                e.Parent = e.SpawnerEntity
                local data = e:GetData()
                --data['спр фон'] = GenSprite("gfx/effects/greed butt effect.anm2", 'idle_0')
                data['спр зад'] = GenSprite("gfx/effects/greed butt effect.anm2", 'idle_1')
                e.Child = Isaac.Spawn(EntityType.ENTITY_EFFECT, GreedButtEffectType, 1, 
                    e.Position, Vector(0,0), e)
            else
                e:Remove()
            end
        elseif e.SubType == 1 then --shadow
            if e.SpawnerEntity then
                e.Parent = e.SpawnerEntity
                --e:FollowParent(e.Parent)
                local spr = e:GetSprite()
                spr:Load("gfx/effects/greed butt effect.anm2", true)
                spr:Play("тень")
                spr.Offset = Vector(0.5,0)
                e.SortingLayer = SortingLayer.SORTING_BACKGROUND
            else
                e:Remove()
            end
        --elseif e.SubType == 2 then --fart

        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, WarpZone.GreedButtEffect_ent_init, GreedButtEffectType)

    function WarpZone.GreedButtEffect_ent_update(_, e)
        if not e.Parent or not e.Parent:Exists() then
            e:Remove() return
        end
        if e.SubType == 0 then
            e.Color = Color(1,1,1,0)

            local data = e:GetData()
            local spr = e:GetSprite()

            data['спр зад']:Update()

            data["монетки"] = e.Parent:ToPlayer():GetData().WarpZone_data.GreedButtCoints

            data["поворот"] = data["поворот"] or 0
            data["высота"] = data["высота"] or 25
            data["скорость вращения"] = data["скорость вращения"] or 2
            data["скорость вращения"] = data["скорость вращения"] * 0.9 + 2 * 0.1

            data["поворот"] = data["поворот"] + data["скорость вращения"]
            data["высота"] = math.sin(e.FrameCount/10)*6+15

            local tar = e.Parent.Position + Vector.FromAngle(data["поворот"]) * 35
            e.Velocity = tar - e.Position

            e.Child.Position =  e.Position + e.Velocity/2

            if data["монетки"] >= 5 and e.FrameCount%45 == 0 then
                local vel = (e.Position - e.Parent.Position):Resized(1)
                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_VERYSMALL, 0,
                        e.Position + Vector(0,-data["высота"]), vel, e)
                    poof:GetSprite():Load("gfx/effects/greed butt effect.anm2", true)
                    poof:GetSprite():Play('сам пердёж')
                    poof.DepthOffset = 100
            end

            if data["перди"] then
                data['спр зад']:Play("пердёж")
                if e.FrameCount%3 == 0 then   --data['спр зад']:IsEventTriggered('fart') then
                    local vel = (e.Position - e.Parent.Position):Resized(1)
                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_VERYSMALL, 0,
                        e.Position + Vector(0,-data["высота"]), vel, e)
                    poof:GetSprite():Load("gfx/effects/greed butt effect.anm2", true)
                    poof:GetSprite():Play('сам пердёж')
                    poof.DepthOffset = 100
                    --poof:GetSprite().PlaybackSpeed = 2
                end
                if data['спр зад']:GetFrame() >= 22 then
                    data['спр зад']:SetFrame(10)

                    local vel = (e.Position - e.Parent.Position):Resized(1)
                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_VERYSMALL, 0,
                        e.Position + Vector(0,-data["высота"]), vel, e)
                    poof:GetSprite():Load("gfx/effects/greed butt effect.anm2", true)
                    poof:GetSprite():Play('сам пердёж')
                    poof.DepthOffset = 100
                end
            elseif data['спр зад']:IsFinished("пердёж") then
                data['спр зад']:Play('idle_1')
                data["пердотяга"] = nil
                data["перди"] = nil
            end
        elseif e.SubType == 1 then
            local haive =  (e.Parent:GetData()["высота"] or 5) - 9
            local proc = 1 - haive * 0.03
            e.Color = Color(1,1,1,proc)
            e:GetSprite().Scale = Vector(proc , proc)

            --local tar = e.Parent.Position + e.Parent.Velocity
            --e.Velocity = tar - e.Position
        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, WarpZone.GreedButtEffect_ent_update, GreedButtEffectType)

    function WarpZone.GreedButtEffect_ent_render(_, e)
        local data = e:GetData()
        if data["монетки"] then
            local Rpos = Isaac.WorldToScreen(e.Position)
            Rpos.Y = Rpos.Y - data["высота"]
            local crop --= data["монетки"] == 5 and 0 or (16 - (data["монетки"] / 5 * 9 + 3))
            if data["пердотяга"] then
                crop = 16 - (math.max(0, data["пердотяга"]+40) / perdotyaga * 9 + 3)
            else
                crop = data["монетки"] == 5 and 0 or (16 - (data["монетки"] / 5 * 9 + 3))
            end
            
            data['спр зад']:RenderLayer(0, Rpos)
            data['спр зад']:RenderLayer(1, Rpos, Vector(0, crop))
        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, WarpZone.GreedButtEffect_ent_render, GreedButtEffectType)

end