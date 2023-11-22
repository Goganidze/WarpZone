return function (mod)

    --ser junkan
    local SerJunkPickupVar = Isaac.GetEntityVariantByName("Junk_Pickup")
    local SerJunkanWalk = Isaac.GetEntityVariantByName("SerJunkanWalk")
    local SerJunkanFly = Isaac.GetEntityVariantByName("SerJunkanFly")
    local proxyNPCtype = Isaac.GetEntityTypeByName("[Warp Zone] proxy npc")

    local game = Game()
    local function isNil(value, replacement)
        if value == nil then
            return replacement
        else
            return value
        end
    end

    local cacehsagasg = {}
    local function GetLastFrame(spr)
        local anm = spr:GetAnimation()
        if not cacehsagasg[anm] then
            local frame = spr:GetFrame()
            local overframe = spr:GetOverlayFrame()

            spr:SetLastFrame()
            cacehsagasg[anm] = spr:GetFrame()

            spr:SetFrame(frame, true)
        else
            return cacehsagasg[anm]
        end
    end
    local lerpAngle = function(a, b, t)
        return (a - (((a+180)-b)%360-180)*t) 
    end


    ---@param ent Entity
    ---@return EntityNPC
    function WarpZone.SpawnNPCProxy(ent)
        local edata = ent and ent:GetData()
        if edata and edata.__ProxyNPC and edata.__ProxyNPC:Exists() then
            return edata.__ProxyNPC
        end
        local npc = Isaac.Spawn(proxyNPCtype, 0, 0, Vector(-100,-100), Vector(0,0), ent):ToNPC()
        npc.Target = ent
        WarpZone:ProxyNPC_init(npc)
        if edata then
            edata.__ProxyNPC = npc
        end
        return npc
    end

    ---@return PathFinder
    function WarpZone.GetPathFinder(ent)
        if Renderer then
            return ent["GetPathFinder"](ent)
        end
        local proxyNPC = WarpZone.SpawnNPCProxy(ent)
        proxyNPC:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        proxyNPC.Position = ent.Position
        --proxyNPC.I1 = 1
        --return proxyNPC.Pathfinder
        return proxyNPC:GetData().__PathfinderFunc
    end

    ---@param ent EntityNPC
    function WarpZone.ProxyNPC_init(_, ent)
        ent.Color = Color(1,1,1,0)
        ent.Visible = false
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        if not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            ent:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
        end
        ent:GetData().__PathfinderFunc = {
            EvadeTarget = function(self, ...)
                return ent.Pathfinder.EvadeTarget(ent.Pathfinder, ...)
            end,
            FindGridPath = function(self, ...)
                ent.I1 = 1
                return ent.Pathfinder.FindGridPath(ent.Pathfinder, ...)
            end,
            GetEvadeMovementCountdown = function(self, ...)
                return ent.Pathfinder.GetEvadeMovementCountdown(ent.Pathfinder, ...)
            end,
            GetGridIndex = function(self, ...)
                return ent.Pathfinder.GetGridIndex(ent.Pathfinder, ...)
            end,
            HasDirectPath = function(self, ...)
                return ent.Pathfinder.HasDirectPath(ent.Pathfinder, ...)
            end,
            HasPathToPos = function(self, ...)
                return ent.Pathfinder.HasPathToPos(ent.Pathfinder, ...)
            end,
            MoveRandomly = function(self, ...)
                return ent.Pathfinder.MoveRandomly(ent.Pathfinder, ...)
            end,
            MoveRandomlyAxisAligned = function(self, ...)
                return ent.Pathfinder.MoveRandomlyAxisAligned(ent.Pathfinder, ...)
            end,
            MoveRandomlyBoss = function(self, ...)
                return ent.Pathfinder.MoveRandomlyBoss(ent.Pathfinder, ...)
            end,
            Reset = function(self, ...)
                return ent.Pathfinder.Reset(ent.Pathfinder, ...)
            end,
            ResetMovementTarget = function(self, ...)
                return ent.Pathfinder.ResetMovementTarget(ent.Pathfinder, ...)
            end,
            SetCanCrushRocks = function(self, ...)
                return ent.Pathfinder.SetCanCrushRocks(ent.Pathfinder, ...)
            end,
            UpdateGridIndex = function(self, ...)
                return ent.Pathfinder.UpdateGridIndex(ent.Pathfinder, ...)
            end,
        }
    end
    WarpZone:AddCallback(ModCallbacks.MC_POST_NPC_INIT, WarpZone.ProxyNPC_init, proxyNPCtype)

    ---@param ent EntityNPC
    function WarpZone.ProxyNPC_Update(_, ent)
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        if not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            ent:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
        end
        ent.Visible = false
        if ent.Target then
            ent.Position = ent.Target.Position
            if ent.I1 == 1 then
                ent.Target.Velocity = ent.Velocity/1
                ent.I1 = 0
            end
        else
            ent:Remove()
        end
        ent.Velocity = ent.Velocity * 0.9
    end
    WarpZone:AddCallback(ModCallbacks.MC_NPC_UPDATE, WarpZone.ProxyNPC_Update, proxyNPCtype)
    
    function WarpZone.ProxyNPC_TakeDamage(_, ent)
        if ent.Type == proxyNPCtype then
            return false
        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, WarpZone.ProxyNPC_TakeDamage, proxyNPCtype)


    

    function WarpZone:DestroyItemPedestalCheck(bomb, player)
        local entities = Isaac.FindInRadius(bomb.Position, 100)
        local rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_SER_JUNKAN)
        for i, entity in ipairs(entities) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and entity.SubType ~= 0 then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, entity.Position, entity.Velocity, bomb)
                entity:Remove()
                --local loops = rng:RandomInt(3) + 3
                --for j=1, loops, 1 do
                local velocity = Vector(rng:RandomInt(8), rng:RandomInt(8))
                Isaac.Spawn(EntityType.ENTITY_PICKUP, SerJunkPickupVar, 1, entity.Position, velocity, bomb)
                --end
            end
        end
    end
    
    local fammovespeed = 60
    local chasingspeed = 100
    
    local function normalizedirection(currentpos, targetpos, chasing)
        local moveVector = targetpos - currentpos
        if chasing then
            moveVector = moveVector:Normalized() * chasingspeed
        else
            moveVector = moveVector:Normalized() * fammovespeed
        end
        moveVector = currentpos/1 + moveVector
        return moveVector
    end
    
    ---@param fam EntityFamiliar
    function WarpZone:update_junkan(fam)
        if not (fam.Velocity.X <= 0) and not (fam.Velocity.X >= 0) then
            fam.Velocity = Vector(0,0)
            fam.Position = fam.Player.Position
        end

        local animName = "Idle"
        local player = fam.Player
        local data = fam:GetData()
        local spr = fam:GetSprite()
        local junkCount = (isNil(player:GetData().WarpZone_data.GetJunkCollected, 0) % 7) + 1
        local followPos = fam.Position
        local enemyEntity= nil
        local pathfinder = WarpZone.GetPathFinder(fam)
        data.pathshitter = data.pathshitter or {
            active = false,

        }
        
        if fam.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_GROUND then
            fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        end
        fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL

        if fam.State == 0 then
            
            fam:PickEnemyTarget(400, 1, 3)
            if not pathfinder:HasDirectPath() then
                fam.Target = nil
                fam:PickEnemyTarget(400, 1, 3)
                --pathfinder:FindGridPath(followPos, 0, 0, true)
            end
            enemyEntity = fam.Target
            local followPlayer
            if enemyEntity ~= nil and (enemyEntity.Position-fam.Position):Length() > math.min(5, enemyEntity.Size) then
                --followPos = normalizedirection(fam.Position, enemyEntity.Position, true)
                followPos = enemyEntity.Position
                --animName = "Walk"
                animName = fam.Velocity:Length()>0.3 and "Walk" or animName
            elseif player.Position:Distance(fam.Position) > 0 and enemyEntity == nil then
                --followPos = normalizedirection(fam.Position, player.Position, false)
                followPos = player.Position -- (player.Position-fam.Position):Resized(60)
                animName = fam.Velocity:Length()>0.3 and "Walk" or animName
                followPlayer = true
            end

            if followPos then
                local room = game:GetRoom()
                --fam.Velocity = (followPos-fam.Position):Resized(followPos:Distance(fam.Position)/40)    --followPos
                local dist = followPos:Distance(fam.Position)
                if dist < 60 or room:CheckLine(followPos, fam.Position, 0) then
                    local power --= followPos:Distance(fam.Position)/90 + 6
                    if followPlayer then
                        power = math.min(10, math.max(0, followPos:Distance(fam.Position)-60)/10 )
                    else
                        power = followPos:Distance(fam.Position)/90 + 6
                    end
                    --power = math.min(dist/2, power)
                    fam.Velocity = fam.Velocity * 0.6 + (followPos-fam.Position):Resized(power) * 0.4
                else
                    --pathfinder:FindGridPath(followPos, 1.1, 0, true) --0.3 + dist/220
                    if not pathfinder:HasPathToPos(followPos, false) then
                        local pathshitter = data.pathshitter
                        pathshitter.active = true
                        if not pathshitter.NewTargetPos then
                            if not pathshitter.Angle then
                                pathshitter.Angle = 0
                                pathshitter.FindDist = 0
                                pathshitter.level = 0
                            end
                            local fampos = fam.Position
                            for i=0, 8 do
                                local fpos = followPos + Vector(pathshitter.FindDist, 0):Rotated(pathshitter.Angle)
                                --Isaac.Spawn(1000,104,2,fpos,Vector(0,0),nil)
                                local dist = fpos:Distance(fampos)
                                if room:GetGridCollisionAtPos(fpos) == GridCollisionClass.COLLISION_NONE then
                                    if dist < 140 then
                                        pathshitter.CanJump = true
                                        pathshitter.NewTargetPos = fpos
                                        break
                                    end
                                    if dist > 60 and pathfinder:HasPathToPos(fpos, false) then
                                        pathshitter.NewTargetPos = fpos
                                        break
                                    end
                                end
                                pathshitter.Angle = pathshitter.Angle + 20 * (1-pathshitter.level*0.05)
                                if pathshitter.Angle >= 360 then
                                    pathshitter.Angle = 0
                                    pathshitter.FindDist = pathshitter.FindDist + 20
                                    pathshitter.level = pathshitter.level + 1
                                end
                                
                            end
                            if pathshitter.FindDist > 500 then
                                pathshitter.Angle = 0
                                pathshitter.FindDist = 30
                                pathshitter.level = 0
                            end
                            fam.Velocity = fam.Velocity * 0.9
                            
                        else
                            --Isaac.Spawn(1000,104,2,data.pathshitter.NewTargetPos,Vector(0,0),nil)
                            pathshitter.Angle = 0
                            pathshitter.FindDist = 20
                            pathshitter.level = 0
                            
                            local dist = data.pathshitter.NewTargetPos:Distance(fam.Position) 
                            
                            if dist < 20 or (not pathfinder:HasPathToPos(data.pathshitter.NewTargetPos, false) and dist >= 140 ) then
                                data.pathshitter.NewTargetPos = nil
                                pathshitter.Angle = 0
                                pathshitter.FindDist = 30
                                pathshitter.level = 0
                                
                            elseif dist < 50 then
                                local power = math.min(10, math.max(0, pathshitter.NewTargetPos:Distance(fam.Position))/10 )
                                fam.Velocity = fam.Velocity * 0.6 + (pathshitter.NewTargetPos-fam.Position):Resized(power) * 0.4
                            else
                                pathfinder:FindGridPath(pathshitter.NewTargetPos, 1.1, 0, true)

                                if dist < 140 and pathshitter.CanJump then
                                    --pathshitter.CanJump = true
                                    fam.State = 7
                                    pathshitter.StartJump = true
                                    pathshitter.PreJumpPos = fam.Position/1
                                end
                            end
                        end
                    else
                        data.pathshitter.active = false
                        data.pathshitter.NewTargetPos = nil
                        pathfinder:FindGridPath(followPos, 1.1, 0, true)
                    end
                    --print(data.pathshitter.NewTargetPos, fam.Position, data.pathshitter.NewTargetPos and data.pathshitter.NewTargetPos:Distance(fam.Position))
                    --pathfinder:FindGridPath(followPos, 1.1, 0, true)
                end
            end
            --fam:FollowPosition(followPos)
            
            animName = animName .. tostring(junkCount)
            if spr:GetAnimation() ~= animName then
                if spr:GetAnimation():sub(-1) ~= animName:sub(-1) then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, fam.Position, Vector(0, 0), fam)
                end
                spr:Play(animName)
            end
            if fam.Velocity.X < 0 then
                spr.FlipX = true
            else
                spr.FlipX = false
            end

            if enemyEntity and enemyEntity.Position:Distance(fam.Position) <= 15+enemyEntity.Size then
                fam.State = 1
                fam.Target = enemyEntity

                spr:Play("Attack" .. tostring(junkCount), true)
                if junkCount < 4 then
                    spr:SetFrame(6)
                elseif junkCount > 5 then
                    fam.State = 2
                end
                if fam.Player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
                    fam.Keys = spr:GetFrame()
                end
                fam.Hearts = 0
                fam.Coins = 0
            end
        
        elseif fam.State == 1 then


            local damage = 0
            local mas = false
            if  spr:IsEventTriggered("BumpAttack") then
                damage = junkCount/2 + 1
            elseif  spr:IsEventTriggered("SwordSwing") then
                damage = junkCount
                mas = 40
            elseif  spr:IsEventTriggered("SpinAttack") then
                damage = 0.7
                if junkCount == 7 then
                    damage = 1
                end
                mas = 70
            end
            if fam.Player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
                damage = damage * 0.7
                fam.Keys = spr:GetFrame()
            end
            if fam.Target and damage > 0 then
                if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                    damage = damage * 2
                    mas = mas and (mas + 10)
                end
                --if not mas then
                    fam.Target:TakeDamage(damage, 0, EntityRef(fam), 1)
                if  mas then
                    local list = Isaac.FindInRadius(fam.Position, mas, EntityPartition.ENEMY)
                    for i=1, #list do
                        local ent = list[i]
                        if ent:IsVulnerableEnemy() and ent:IsActiveEnemy() then
                            ent:TakeDamage(damage/2, 0, EntityRef(fam), 1)
                        end
                    end
                end
            end

            if GetLastFrame(spr) == spr:GetFrame() then
                fam.State = 0
                spr.PlaybackSpeed = 1
            end
            if fam.Target then
                local power = math.min(8, fam.Target.Position:Distance(fam.Position)-fam.Target.Size)
                fam.Velocity = fam.Velocity * 0.8 + (fam.Target.Position-fam.Position):Resized(power/2) * 0.2
            end
            fam.Velocity = fam.Velocity * (1-spr:GetFrame()*0.02)

        elseif fam.State == 2 then
            local damage = 0.9
            local mas = 40
            if junkCount == 7 then
                damage = 1.2
            end
            if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                damage = damage * 2
                mas = mas + 20
            end
            if fam.Player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
                damage = damage * 1.1
                fam.Keys = spr:GetFrame()
            end

            if not fam.Target then
                fam:PickEnemyTarget(200, 1, 2)
            end

            if spr:IsEventTriggered("SpinAttack") then
                local list = Isaac.FindInRadius(fam.Position, mas, EntityPartition.ENEMY)
                for i=1, #list do
                    local ent = list[i]
                    if ent:IsVulnerableEnemy() and ent:IsActiveEnemy() or ent.Type == EntityType.ENTITY_FIREPLACE then
                        ent:TakeDamage(damage, 0, EntityRef(fam), 1)
                    end
                end
                local room = game:GetRoom()
                for i=0, 360-45, 45 do
                    local pos = fam.Position + Vector.FromAngle(i):Resized(30)
                    local grid = room:GetGridEntityFromPos(pos)
                    if grid and grid:Hurt(1) then
                        
                    end
                end
            end
            if not spr:WasEventTriggered("SpinAttack") then
                local power = fam.Target and math.min(5, fam.Target.Position:Distance(fam.Position)/6)
                local tar = fam.Target and ((fam.Target.Position-fam.Position):Resized(power) * 0.1) or Vector(0,0)
                fam.Velocity = fam.Velocity * 0.82 + tar
            elseif fam.Target and fam.Hearts == 0 then
                fam.Hearts = 1
                --local power = fam.Target.Position:Distance(fam.Position)-fam.Target.Size
                --fam.Velocity = fam.Velocity * 0.5 + (fam.Target.Position-fam.Position):Resized(10) * 0.5
                local power = fam.Target.Position:Distance(fam.Position)/6+2
                if junkCount == 7 then
                    fam.Velocity = (fam.Target.Position-fam.Position):Resized(math.min(power, 10))
                else
                    fam.Velocity = (fam.Target.Position-fam.Position):Resized(math.min(power, 7))
                end
            elseif fam.Target and fam.Hearts == 1 then
                local ang = (fam.Target.Position-fam.Position):GetAngleDegrees()
                local power = math.min( fam.Velocity:Length()+0.2, junkCount == 7 and 10 or 7)
                fam.Velocity = Vector(power, 0):Rotated(lerpAngle(fam.Velocity:GetAngleDegrees(), ang, 0.1))
            end
            if fam.Target and fam.Player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) 
            and spr:GetFrame() >= 40 and fam.Coins < 3 then
                fam.Coins = fam.Coins + 1
                spr:SetFrame(21)
                return
            end
            if GetLastFrame(spr) == spr:GetFrame() then
                fam.State = 0
                fam.Hearts = 0
                spr.PlaybackSpeed = 1
                fam.Coins = 0
            end

        elseif fam.State == 7 then
            local followPos = data.pathshitter.NewTargetPos
            local pathshitter = data.pathshitter
            pathshitter.CanJump = nil
            if pathshitter.StartJump then
                --Isaac.Spawn(1000,104,2,fam.Position,Vector(0,0),nil)
                pathshitter.frame = 0
                pathshitter.Scale = spr.Scale/1
                pathshitter.OffsetPos = fam.PositionOffset/1
                pathshitter.StartJump = nil
            end
            pathshitter.frame = pathshitter.frame + 1
            if pathshitter.frame >= 20 then
                fam.State = 0
                fam.PositionOffset = pathshitter.OffsetPos
                spr.Scale = pathshitter.Scale
                pathshitter.frame = 0
            end
            --print(pathshitter.frame)
            if pathshitter.frame < 4 then
                spr.Scale = Vector(pathshitter.Scale.X * (1 + pathshitter.frame*0.1), pathshitter.Scale.Y * (1 - pathshitter.frame*0.1))
            elseif pathshitter.frame > 4 then
                spr.Scale = pathshitter.Scale
                spr:Play("Walk"..junkCount)
                spr:SetFrame(4)
                local proc = (pathshitter.frame-5)/15
                --local proc = math.sin(math.pi*(pathshitter.frame-5)/15)
                fam.PositionOffset = fam.PositionOffset + Vector(0,-math.sin(math.pi*proc))
                fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                
                local power = (followPos-fam.Position) * (proc*0.5)
                --fam.Position = fam.Position + power --*5
                --print(proc, power, followPos)
                fam.Velocity = power --*15 -- fam.Velocity * 0.6 + (power-fam.Position) * 0.4
                if pathshitter.frame >= 19 then
                    fam.PositionOffset = pathshitter.OffsetPos
                    spr.Scale = pathshitter.Scale
                    pathshitter.frame = 0
                    pathshitter.CanJump = false
                    fam.State = 0
                    --Isaac.Spawn(1000,104,2,followPos,Vector(0,0),nil)
                    if game:GetRoom():GetGridCollisionAtPos(fam.Position) ~= GridCollisionClass.COLLISION_NONE then
                        fam.Position = followPos
                        fam.Velocity = Vector(0,0)
                    end
                    pathshitter.NewTargetPos = nil
                end
            end
            
        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, WarpZone.update_junkan, SerJunkanWalk)

    function WarpZone.update_junkan_Render(_, fam)
        if not game:IsPaused() and fam.Player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) and fam.State == 1 then
            local spr = fam:GetSprite()
            if fam.Keys ~= spr:GetFrame() then
                WarpZone.update_junkan(_, fam)
                --if ((fam.Player:GetData().WarpZone_data.GetJunkCollected or 0) % 7 + 1) <= 5 then
                    spr:Update()
                --end
            end
        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, WarpZone.update_junkan_Render, SerJunkanWalk)

    ---@param fam EntityFamiliar
    function WarpZone:update_flying_junkan(fam)
        local spr = fam:GetSprite()
        local animName = "Idle"
        local player = fam.Player
        local data = player:GetData()
        local followPos = fam.Position
        --local lastFrameShot = isNil(data.LastFrameShot, 0)
        --local currentframe = game:GetFrameCount()
        
        --local entities = Isaac.FindInRadius(fam.Position, 250)
    
        --[[for i, entity in ipairs(entities) do
            if entity:IsVulnerableEnemy() then
                if enemyEntity == nil then
                    enemyEntity = entity
                else
                    if fam.Position:Distance(enemyEntity.Position) > fam.Position:Distance(entity.Position) then
                        enemyEntity = entity
                    end
                end
            end
        end]]
        fam:PickEnemyTarget(800, 1, 3)
        local enemyEntity = fam.Target
        --if player.Position:Distance(fam.Position) > 60 then
        --    followPos = normalizedirection(fam.Position, player.Position, true)
        --end
        if not fam.Target then
            fam:FollowParent()
        else
            local power = (fam.Target.Position:Distance(fam.Position)-70)/20
            fam.Velocity = (fam.Target.Position-fam.Position):Resized(math.min(power, 3))
            animName = "Shoot"
        end
    
        --[[if lastFrameShot + 180 <= currentframe and enemyEntity ~= nil then
            animName = "Shoot"
            data.LastFrameShot = currentframe
        elseif lastFrameShot + 60 >= currentframe then
            animName = "Shoot"
        end]]
        
        if fam.FireCooldown <= 0  then
            if fam.State == 0 then
                fam.Coins = fam:GetDropRNG():RandomInt(5)+11
                if fam.Player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
                    fam.Coins = fam.Coins + 10
                end
            fam.Hearts = 5
            end
            fam.State = 1
        else
            fam.FireCooldown = fam.FireCooldown - 1
            fam.State = 0
        end
        
        if fam.State == 1 then
            fam.Hearts = fam.Hearts - 1

            if enemyEntity ~= nil and fam.Hearts == 0 then
                fam.Hearts = fam.Player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) and 3 or 5
                fam.Coins = fam.Coins - 1

                local direction = (enemyEntity.Position - fam.Position):Normalized()
                local proj = fam:FireProjectile(direction)
        
                proj:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_HOMING | TearFlags.TEAR_PIERCING)
                proj:ChangeVariant(TearVariant.DARK_MATTER)
                proj:ResetSpriteScale()
                proj:GetSprite().Scale = Vector(2,1)
                proj:GetSprite().Color = Color(0, 0, 0, 1, 0.9, 0, 0.4) -- Color(1.91, 1.287, 1.771, 1, 0.2, 0, 0.1)
                local dmg = player:GetData().WarpZone_data.GetJunkCollected - 7 + 
                    (fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 16 or 8)
                proj.CollisionDamage = dmg

            end
            if not enemyEntity or fam.Coins <= 0 then
                fam.State = 0
                fam.FireCooldown = math.max(0, 50 - fam.Coins*7)
                fam.Coins = 0
            end
        end
        
    
        if spr:GetAnimation() ~= animName then
            spr:Play(animName)
            --fam.FireCooldown = 10
        end
    
        --fam:FollowPosition(followPos)
    end
    WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, WarpZone.update_flying_junkan, SerJunkanFly)
    

end