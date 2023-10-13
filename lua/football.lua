return function(mod)

    local game = Game()
    local sfx = SFXManager()
    local nilvector = Vector.Zero

    local LiftItemAnimOffset = {
        Vector(0,-18), Vector(0,-26), Vector(0,-20), Vector(0,-14), Vector(0,-21), Vector(0,-28), Vector(0,-26.5), Vector(0,-25)
    }
    
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
                fam.PositionOffset = LiftItemAnimOffset[frame] * fam.Target:GetSprite().Scale + Vector(0,-4)
            end
            --fam.PositionOffset = fam.Target:GetCostumeNullPos("pickup item", true, Vector.Zero)
            --print(fam.Target:GetCostumeNullPos("pickup item", true, Vector(0,-1)))
            if fam.Target:ToPlayer():IsExtraAnimationFinished() then
                fam.Target:GetData().WarpZone_data.HoldEntity = nil
            end
        else
            fam.DepthOffset = 0
            fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            if fam.PositionOffset.Y < 0 or fam.Keys < 0 then --fam.Hearts < 0 or
                --fam.Hearts = fam.Hearts + 2
                fam.Keys = fam.Keys + 2 --math.floor(fam.Keys + fam.Hearts/5)
                fam.PositionOffset = fam.PositionOffset + Vector(0,fam.Keys/5)
                if fam.PositionOffset.Y >= 0 and fam.Keys > 0 then
                    --fam.Hearts = -math.floor(fam.Hearts/2.8)
                    fam.Keys = -math.floor(fam.Keys/1.2)
                    --fam.PositionOffset = Vector(0,fam.Keys/5)
                    sfx:Play(SoundEffect.SOUND_FETUS_LAND,nil,10,nil,1.5)
                end
            else
                if d.PreVel and d.PreVel:Length() < fam.Velocity:Length()/2 then
                    fam.Keys = -math.floor(fam.Velocity:Length()*2)
                end
                fam.Velocity = fam.Velocity * 0.9
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
        if fam.PositionOffset.Y > -20 and player and player.Variant == 0 then
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
                            data.WarpZone_data.HoldEntity:ToFamiliar().State = 2
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
            
            collider.Velocity = collider.Velocity + (collider.Position - fam.Position):Resized(fam.Velocity:Length())
            fam.Velocity = (fam.Position - collider.Position):Resized(fam.Velocity:Length()*1.1)

            local damage = fam.Velocity:Length() / 1.5
            local footrand = fam:GetDropRNG()
            if damage > 10 and footrand:RandomInt(10) > 4 then
                collider:AddConfusion(EntityRef(fam), 90, true)
            end
            collider:TakeDamage(damage, 0, EntityRef(fam), 0)
        end
    end, WarpZone.FOOTBALL.FAM.VAR)
end