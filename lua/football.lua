return function(mod)

    local game = Game()
    local sfx = SFXManager()
    local nilvector = Vector.Zero

    WarpZone.FOOTBALL.rekoshetMaxAngle = 90

    local LiftItemAnimOffset = {
        Vector(0,-18), Vector(0,-26), Vector(0,-20), Vector(0,-14), Vector(0,-21), Vector(0,-28), Vector(0,-26.5), Vector(0,-25)
    }
    
    local getAngleDiv = function(a,b)
        local r1,r2
        if a > b then
            r1,r2 = a-b, b-a+360
        else
            r1,r2 = b-a, a-b+360
        end
        return r1>r2 and r2 or r1
    end

    ---@param fam EntityFamiliar
    mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
        fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        local s = fam:GetSprite()
        s:ReplaceSpritesheet(0, "gfx/familiar/football_reskin.png")
        s:LoadGraphics()
        fam:AddEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE)
    end, WarpZone.FOOTBALL.FAM.VAR)

    ---@param fam EntityFamiliar
    mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
        local d = fam:GetData()
	    local spr = fam:GetSprite()
        local room = game:GetRoom()

        if fam.Target then
            if not fam.Target:GetData().WarpZone_data.HoldEntity then
                fam.Target = nil
                fam:Update()
                return
            end
            fam.FireCooldown = 0
            fam.DepthOffset = 10
            fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            --fam.Position = fam.Target.Position
            fam.Velocity = (fam.Target.Position- fam.Position)
            local frame = fam.Target.FrameCount - fam.Coins
            if LiftItemAnimOffset[frame] then
                local scale = fam.Target:GetSprite().Scale
                local idinahuiApi = Vector(LiftItemAnimOffset[frame].X * scale.X, LiftItemAnimOffset[frame].Y * scale.Y)
                fam.PositionOffset = idinahuiApi + Vector(0,-4)
            end
            --fam.PositionOffset = fam.Target:GetCostumeNullPos("pickup item", true, Vector.Zero)
            --print(fam.Target:GetCostumeNullPos("pickup item", true, Vector(0,-1)))
            if fam.Target:ToPlayer():IsExtraAnimationFinished() then
                fam.Target:GetData().WarpZone_data.HoldEntity = nil
            end
        else
            if fam.State == 1 then
                fam.DepthOffset = 0
                fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                if fam.PositionOffset.Y < 0 or fam.Keys < 0 then --fam.Hearts < 0 or
                    fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
                    fam.Keys = fam.Keys + 2 --math.floor(fam.Keys + fam.Hearts/5)
                    fam.PositionOffset = fam.PositionOffset + Vector(0,fam.Keys/5)
                    if fam.PositionOffset.Y >= 0 and fam.Keys > 0 then
                        if room:GetGridCollisionAtPos(fam.Position) == GridCollisionClass.COLLISION_PIT then
                            fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_PITSONLY
                            fam.State = 2
                            d.prescale = spr.Scale/1
                            d.preAlpha = fam.Color.A
                        else
                            --fam.Hearts = -math.floor(fam.Hearts/2.8)
                            fam.Keys = -math.floor(fam.Keys/1.2)
                            --fam.PositionOffset = Vector(0,fam.Keys/5)
                            sfx:Play(SoundEffect.SOUND_FETUS_LAND,nil,10,nil,1.5)
                        end
                    end
                else
                    if d.PreVel and d.PreVel:Length() < fam.Velocity:Length()/2 then
                        fam.Keys = -math.floor(fam.Velocity:Length()*2)
                    end
                    fam.Velocity = fam.Velocity * 0.9
                end
            elseif fam.State == 2 then
                fam.Keys = fam.Keys + 3
                fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_PITSONLY
                local c = fam.Color
                fam.Color = Color(c.R,c.G,c.B,c.A*(1-fam.Keys/150))
                d.CurScale = (d.CurScale or spr.Scale) * (1-fam.Keys/300)
                spr.Scale = d.CurScale --= spr.Scale
                if c.A <= 0.1 then
                    fam.Keys = 0
                    fam.Velocity = Vector(0,0)
                    fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                    fam.State = 1
                    fam.Color = Color(c.R,c.G,c.B,d.preAlpha)
                    d.preAlpha = nil
                    spr.Scale = d.prescale
                    d.CurScale = nil
                    d.prescale = nil
                    --fam.Position = game:GetLevel():GetEnterPosition()
                    fam.Position = game:GetRoom():GetDoorSlotPosition(game:GetLevel().EnterDoor)
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01,
                        0,fam.Position, nilvector, fam).Color = Color(1,1,1,0.5)
                    sfx:Play(SoundEffect.SOUND_FETUS_JUMP)
                end
            end
            if fam:CollidesWithGrid() then
                sfx:Play(SoundEffect.SOUND_FETUS_LAND,nil,10,nil,1.5)
            end
        end
        if fam.FireCooldown > 0 then
            fam.FireCooldown = fam.FireCooldown - 1
            fam.Velocity = fam.Velocity:Resized(15)
        end
        d.PreVel = fam.Velocity
    end, WarpZone.FOOTBALL.FAM.VAR)

    mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, fam, collider)
        ---@type EntityPlayer
        local player = collider:ToPlayer()
        if fam.PositionOffset.Y > -30 and player and player.Variant == 0 then
            local pdata = player:GetData()
            pdata.WarpZone_data = pdata.WarpZone_data or {}
            if not pdata.WarpZone_data.HoldEntity and player:IsExtraAnimationFinished() 
            and not player:IsCoopGhost() then
                fam.Velocity = Vector(0,0)
                pdata.WarpZone_data.HoldEntity = fam
                pdata.WarpZone_data.IsHoldindEntity = true
                --fam:GetData().IsHoldingBy = player
                fam.Target = player
                fam.Coins = player.FrameCount
                player:AnimatePickup(Sprite(), false, "LiftItem")

                ---@param player EntityPlayer
                pdata.WarpZone_data.HoldEntityLogic = function(player)
                    local data = player:GetData()
                    local aim = player:GetAimDirection()
                    if aim:Length()>0.1 then
                        if data.WarpZone_data.HoldEntity then
                            data.WarpZone_data.HoldEntity.Target = nil
                            data.WarpZone_data.HoldEntity.Velocity = aim * 15 + player.Velocity
                            data.WarpZone_data.HoldEntity:ToFamiliar().Keys = -15
                            data.WarpZone_data.HoldEntity:ToFamiliar().FireCooldown = 40
                            data.WarpZone_data.HoldEntity = nil
                            sfx:Play(SoundEffect.SOUND_FETUS_JUMP)
                        end
                    end
                end
            end
        elseif collider:IsEnemy() and collider:IsVulnerableEnemy() and collider:IsActiveEnemy() 
            and not (collider:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or collider:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) then
            
            if fam.Velocity:Length() < 2 then
                local damage --= fam.Velocity:Length() / 1.5
                if fam.Player and fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                    damage = 1
                else
                    damage = .5
                end
                collider:TakeDamage(damage, 0, EntityRef(fam), 0)
            else
                local maxdis = 1000000
                local FlyTarget
                local list = Isaac.GetRoomEntities()
                local ballAngle = (-fam.Velocity):GetAngleDegrees()
                for i=1, #list do
                    local ent = list[i]
                    if ent.Index ~= collider.Index and ent:IsVulnerableEnemy() and ent:IsActiveEnemy() then
                        local angle = (ent.Position -fam.Position ):GetAngleDegrees()
                        if math.abs(getAngleDiv(angle,ballAngle)) < WarpZone.FOOTBALL.rekoshetMaxAngle then
                            --print(angle, ballAngle)
                            local dist = ent.Position:Distance(fam.Position)
                            if dist < maxdis then
                                FlyTarget = angle
                                maxdis = dist
                            end
                        end
                    end
                end

                collider.Velocity = collider.Velocity + (collider.Position - fam.Position):Resized(fam.Velocity:Length())
                fam.Velocity = (fam.Position - collider.Position):Resized(fam.Velocity:Length())

                if FlyTarget then
                    fam.Velocity = Vector.FromAngle(FlyTarget):Resized(fam.Velocity:Length())
                end

                if fam.Keys > 0 then
                    fam.Keys = -math.floor(fam.Keys)
                end
                local damage --= fam.Velocity:Length() / 1.5
                if fam.Player and fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                    damage = fam.Velocity:Length() / 1.2
                else
                    damage = fam.Velocity:Length() / 2
                end
                local footrand = fam:GetDropRNG()
                if damage > 10 and footrand:RandomInt(10) > 4 then
                    collider:AddConfusion(EntityRef(fam), 90, true)
                end
                collider:TakeDamage(damage, 0, EntityRef(fam), 0)
            end
        end
    end, WarpZone.FOOTBALL.FAM.VAR)
end