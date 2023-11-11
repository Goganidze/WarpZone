return function (mod)

    --ser junkan
    local SerJunkPickupVar = Isaac.GetEntityVariantByName("Junk_Pickup")
    local SerJunkanWalk = Isaac.GetEntityVariantByName("SerJunkanWalk")
    local SerJunkanFly = Isaac.GetEntityVariantByName("SerJunkanFly")
    local proxyNPCtype = Isaac.GetEntityTypeByName("WZ proxy npc")

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

    function WarpZone.GetPathFinder(ent)
        if Renderer then
            return ent["GetPathFinder"](ent)
        end
        local proxyNPC = WarpZone.SpawnNPCProxy(ent)
        proxyNPC:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        proxyNPC.Position = ent.Position
        proxyNPC.I1 = 1
        return proxyNPC.Pathfinder
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
                ent.Target.Velocity = ent.Velocity
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
        local animName = "Idle"
        local player = fam.Player
        local data = player:GetData()
        local spr = fam:GetSprite()
        local junkCount = (isNil(data.WarpZone_data.GetJunkCollected, 0) % 7) + 1
        local followPos = fam.Position
        local enemyEntity= nil
        
        if fam.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_GROUND then
            fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        end
        fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL

        if fam.State == 0 then
            
            --[[local entities = Isaac.FindInRadius(fam.Position, 100, EntityPartition.ENEMY)
            for i, entity in ipairs(entities) do
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
            fam:PickEnemyTarget(200, 1, 2)
            enemyEntity = fam.Target
            local followPlayer
            if enemyEntity ~= nil and (enemyEntity.Position-fam.Position):Length() > math.min(5, enemyEntity.Size) then
                --followPos = normalizedirection(fam.Position, enemyEntity.Position, true)
                followPos = enemyEntity.Position
                animName = "Walk"
            elseif player.Position:Distance(fam.Position) > 0 and enemyEntity == nil then
                --followPos = normalizedirection(fam.Position, player.Position, false)
                followPos = player.Position -- (player.Position-fam.Position):Resized(60)
                animName = fam.Velocity:Length()>0.3 and "Walk" or animName
                followPlayer = true
            end
            --if enemyEntity ~= nil and (enemyEntity.Position-fam.Position):Length() <= 15 then
            --    animName = "Attack"
            --end
            if followPos then
                --fam.Velocity = (followPos-fam.Position):Resized(followPos:Distance(fam.Position)/40)    --followPos
                local dist = followPos:Distance(fam.Position)
                if dist < 60 or game:GetRoom():CheckLine(followPos, fam.Position, 0) then
                    local power --= followPos:Distance(fam.Position)/90 + 6
                    if followPlayer then
                        power = math.min(10, math.max(0, followPos:Distance(fam.Position)-60)/10 )
                    else
                        power = followPos:Distance(fam.Position)/90 + 6
                    end
                    --power = math.min(dist/2, power)
                    fam.Velocity = fam.Velocity * 0.6 + (followPos-fam.Position):Resized(power) * 0.4
                else
                    WarpZone.GetPathFinder(fam):FindGridPath(followPos, 1.1, 0, true) --0.3 + dist/220
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
            if fam.Target and damage > 0 then
                if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                    damage = damage * 2
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
            end
            if fam.Target then
                local power = fam.Target.Position:Distance(fam.Position)-fam.Target.Size
                fam.Velocity = fam.Velocity * 0.8 + (fam.Target.Position-fam.Position):Resized(power/2) * 0.2
            end
            fam.Velocity = fam.Velocity * (1-spr:GetFrame()*0.02)

        elseif fam.State == 2 then
            local damage = 0.7
            local mas = 40
            if junkCount == 7 then
                damage = 1
            end
            if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                damage = damage * 2
                mas = mas + 20
            end

            if not fam.Target then
                fam:PickEnemyTarget(200, 1, 2)
            end

            if spr:IsEventTriggered("SpinAttack") then
                local list = Isaac.FindInRadius(fam.Position, mas, EntityPartition.ENEMY)
                for i=1, #list do
                    local ent = list[i]
                    if ent:IsVulnerableEnemy() and ent:IsActiveEnemy() then
                        ent:TakeDamage(damage, 0, EntityRef(fam), 1)
                    end
                end
            end
            if not spr:WasEventTriggered("SpinAttack") then
                fam.Velocity = fam.Velocity * 0.82 + (fam.Target.Position-fam.Position):Resized(5) * 0.1
            elseif fam.Target and fam.Hearts == 0 then
                fam.Hearts = 1
                --local power = fam.Target.Position:Distance(fam.Position)-fam.Target.Size
                --fam.Velocity = fam.Velocity * 0.5 + (fam.Target.Position-fam.Position):Resized(10) * 0.5
                if junkCount == 7 then
                    fam.Velocity = (fam.Target.Position-fam.Position):Resized(10)
                else
                    fam.Velocity = (fam.Target.Position-fam.Position):Resized(7)
                end
            elseif fam.Target and fam.Hearts == 1 then
                local ang = (fam.Target.Position-fam.Position):GetAngleDegrees()
                fam.Velocity = Vector(fam.Velocity:Length(), 0):Rotated(lerpAngle(fam.Velocity:GetAngleDegrees(), ang, 0.1))
            end
            if GetLastFrame(spr) == spr:GetFrame() then
                fam.State = 0
                fam.Hearts = 0
            end
        end
    end
    WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, WarpZone.update_junkan, SerJunkanWalk)
    
    
    function WarpZone:update_flying_junkan(fam)
        local animName = "Idle"
        local player = fam.Player
        local data = player:GetData()
        local followPos = fam.Position
        local lastFrameShot = isNil(data.LastFrameShot, 0)
        local currentframe = game:GetFrameCount()
        local enemyEntity= nil
        local entities = Isaac.FindInRadius(fam.Position, 250)
    
        for i, entity in ipairs(entities) do
            if entity:IsVulnerableEnemy() then
                if enemyEntity == nil then
                    enemyEntity = entity
                else
                    if fam.Position:Distance(enemyEntity.Position) > fam.Position:Distance(entity.Position) then
                        enemyEntity = entity
                    end
                end
            end
        end
        
        if player.Position:Distance(fam.Position) > 60 then
            followPos = normalizedirection(fam.Position, player.Position, true)
        end
    
        if lastFrameShot + 180 <= currentframe and enemyEntity ~= nil then
            animName = "Shoot"
            data.LastFrameShot = currentframe
        elseif lastFrameShot + 60 >= currentframe then
            animName = "Shoot"
        end
    
        if fam:GetSprite():GetAnimation() == "Shoot" and enemyEntity ~= nil and (currentframe - lastFrameShot) % 6 == 0 then
            local direction = (enemyEntity.Position - fam.Position):Normalized()
            local proj = fam:FireProjectile(direction)
    
            proj:AddTearFlags(TearFlags.TEAR_SPECTRAL)
            proj:AddTearFlags(TearFlags.TEAR_HOMING)
            proj:GetSprite().Color = Color(.91, .187, .371, 1, 0, 0, 0)
            proj.CollisionDamage = 8
        end
    
        if fam:GetSprite():GetAnimation() ~= animName then
            fam:GetSprite():Play(animName)
        end
    
        fam:FollowPosition(followPos)
    end
    WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, WarpZone.update_flying_junkan, SerJunkanFly)
    

end