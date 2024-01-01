return function(mod)
    local sfx = SFXManager()
    local Isaac = Isaac
    local game = Game()
    local Wtr = 20/13

    if REPENTOGON then
        
        local dirToVec = {
            [Direction.DOWN] = Vector(0,1),
            [Direction.UP] = Vector(0,-1),
            [Direction.RIGHT] = Vector(1,0),
            [Direction.LEFT] = Vector(-1,0),
            [Direction.NO_DIRECTION] = Vector(0,0),
        }

        local badPickups = {
            [PickupVariant.PICKUP_BIGCHEST]=true,
            [PickupVariant.PICKUP_COLLECTIBLE]=true,
            [PickupVariant.PICKUP_BROKEN_SHOVEL]=true,
        }


        function WarpZone.FireClubRRR(source, direction)
            local club = Isaac.Spawn(EntityType.ENTITY_EFFECT, WarpZone.WarpZoneTypes.FAKE_BONE_R, 0, 
                source.Position, Vector(0,0), source ):ToEffect()

            local angle
            if source:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
                angle = direction:GetAngleDegrees() + 90
            else
                angle = direction:GetAngleDegrees()
                angle = math.ceil((angle+45)/90)*90
            end
            
            club.Rotation = angle - 180
            club.SpriteRotation = angle - 180
            --club:FollowParent(source)
            return club
        end

        function WarpZone.RGON_clubInit(_, ent)
            ent:GetSprite():Play("Swing", true)
            sfx:Play(SoundEffect.SOUND_FETUS_JUMP, Options.SFXVolume*2, 2, false, 0.7)
        end
        WarpZone:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, WarpZone.RGON_clubInit, WarpZone.WarpZoneTypes.FAKE_BONE_R)

        ---@param ent EntityEffect
        function WarpZone.RGON_clubUpdate(_, ent)
            local spr = ent:GetSprite()

            if spr:GetFrame() < 4 then
                local data = ent:GetData()
                data.WZ_HitList = data.WZ_HitList or {}
                local hitlist = data.WZ_HitList

                local damage = ent.SpawnerEntity and ent.SpawnerEntity:ToPlayer().Damage or 6
                local aim = Vector.FromAngle(ent.Rotation + 90)
                
                --WarpZone:FireClub(player, getDirectionFromVector(player:GetLastDirection()), true)
            
                local attackpos = ent.Position + ent:GetNullOffset("tip") --* Wtr   --spr:GetNullFrame("tip"):GetPos() * Wtr
                
                --Isaac.Spawn(1000, EffectVariant.FLY_EXPLOSION, 0, attackpos, Vector(0,0), nil)
                --local capsulee = ent:GetNullCapsule("tip")
                --local list = Isaac.FindInCapsule (capsulee, EntityPartition.ENEMY)
                local list = Isaac.FindInRadius(attackpos, 30, EntityPartition.ENEMY)
                local ref = EntityRef(ent.SpawnerEntity)
                local playsound = false
            
                for i=1 , #list do
                    local entT = list[i]
                    if not hitlist[entT.Index] and entT:IsActiveEnemy() then
                        hitlist[entT.Index] = true
                        entT:AddVelocity(aim:Resized(damage / entT.Mass * 20))
                        entT:TakeDamage(damage * 2, 0, ref, 5)
                        playsound = true
                    end
                end
            
                local list = Isaac.FindByType(33,-1,-1)
                for i=1 , #list do
                    local entT = list[i]
                    if not hitlist[entT.Index] and entT.Position:Distance(attackpos) < 30 then
                        hitlist[entT.Index] = true
                        entT:TakeDamage(5, 0, ref, 0)
                        entT:Update()
                        entT:TakeDamage(5, 0, ref, 0)
                        entT:Update()
                        entT:TakeDamage(5, 0, ref, 0)
                    end
                end
            
                local list = Isaac.FindByType(4)
                for i=1 , #list do
                    local entT = list[i]
                    if not hitlist[entT.Index] and entT.Position:Distance(attackpos) < 30 then
                        hitlist[entT.Index] = true
                        entT:ToProjectile():Deflect(aim:Resized(10))
                    end
                end

                local list = Isaac.FindByType(9)
                for i=1 , #list do
                    local entT = list[i]
                    if not hitlist[entT.Index] and entT.Position:Distance(attackpos) < 30 then
                        hitlist[entT.Index] = true
                        entT:AddVelocity(aim:Resized(10))
                    end
                end

                if ent.SpawnerEntity then
                    --local list = Isaac.FindByType(5)
                    local list = Isaac.FindInRadius(attackpos, 30, EntityPartition.PICKUP)
                    for i=1 , #list do
                        local entT = list[i]
                        if entT.Type == 5 and not hitlist[entT.Index] and not badPickups[entT.Variant] then
                            hitlist[entT.Index] = true
                            ent.SpawnerEntity:ForceCollide(entT, true)
                            entT:AddVelocity(aim:Resized(damage / entT.Mass * 10))
                        end
                    end
                end
            
                --local list = Isaac.FindInRadius(attackpos, 50, EntityPartition.BULLET)
                --for i=1 , #list do
                --    local ent = list[i]
                --    ent.Velocity = aim:Resized(ent.Velocity:Length()+7)
                --    ent:ToProjectile():AddProjectileFlags(ProjectileFlags.HIT_ENEMIES)
                --end
            
                --local gridattackpos = ent.Position + (aim * 40)
                local room = game:GetRoom()
                --[[for i=0, 360-45, 45 do
                    local pos = gridattackpos + Vector.FromAngle(i):Resized(30)
                    local grid = room:GetGridEntityFromPos(pos)
            
                    if grid and grid:Hurt(3) then
                            
                    end
                end]]
                    local pos = ent.Position + ent:GetNullOffset("tip") * 1.2
                    local grid = room:GetGridEntityFromPos(pos)
            
                    if grid and grid:Hurt(5) then
                            
                    end
            end
            if ent.SpawnerEntity then
                ent.Velocity = ent.SpawnerEntity.Position - ent.Position + Vector.FromAngle(ent.Rotation+90):Resized(10)
            end
            if spr:IsFinished() then
                ent:Remove()
            end
        end
        WarpZone:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, WarpZone.RGON_clubUpdate, WarpZone.WarpZoneTypes.FAKE_BONE_R)
    end
end