return function(mod)
    local sfx = SFXManager()
    local Isaac = Isaac
    local game = Game()
    local hud = game:GetHUD()
    local Wtr = 20/13

    if REPENTOGON then
        local PolarStarEXTent = Isaac.GetEntityVariantByName("[Warp Zone] polar star exp")
        
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


        --- Celest Strawberry

        local strawberry_effSybType = 69
        local strawberry_roomPos = Vector(480, 100)
        WarpZone.WarpZoneTypes.GIANTBOOK_TREASURE_ADD = Isaac.GetGiantBookIdByName("WZ_TreasureRoomAdd")

        local ShapeToNeighbors = {
            [RoomShape.ROOMSHAPE_1x1] = {-1,-13,1,13},
            [RoomShape.ROOMSHAPE_IH] = {-1,1},
            [RoomShape.ROOMSHAPE_IV] = {-13,13},
            [RoomShape.ROOMSHAPE_1x2] = {-1,-13,1,12,15,26},
            [RoomShape.ROOMSHAPE_IIV] = {-13,26},
            [RoomShape.ROOMSHAPE_2x1] = {-1,-13,-12,2,13,14},
            [RoomShape.ROOMSHAPE_IIH] = {-1,2},
            [RoomShape.ROOMSHAPE_2x2] = {-1,-13,-12,2,12,15,26,27},
            [RoomShape.ROOMSHAPE_LTL] = {0,-12,2,12,15,26,27},
            [RoomShape.ROOMSHAPE_LTR] = {-1,-13,1,12,15,26,27},
            [RoomShape.ROOMSHAPE_LBL] = {-1,-13,-12,2,13,15,27},
            [RoomShape.ROOMSHAPE_LBR] = {-1,-13,-12,2,12,14,26},
        }
        local ShapeToNeighborsDoor = {
            [RoomShape.ROOMSHAPE_1x1] = {DoorSlot.LEFT0,DoorSlot.UP0,DoorSlot.RIGHT0,DoorSlot.DOWN0},
            [RoomShape.ROOMSHAPE_IH] = {DoorSlot.LEFT0, DoorSlot.RIGHT0},
            [RoomShape.ROOMSHAPE_IV] = {DoorSlot.UP0, DoorSlot.DOWN0},
            [RoomShape.ROOMSHAPE_1x2] = {DoorSlot.LEFT0, DoorSlot.UP0, DoorSlot.RIGHT0, DoorSlot.LEFT1, DoorSlot.RIGHT1, DoorSlot.DOWN0},
            [RoomShape.ROOMSHAPE_IIV] = {DoorSlot.UP0, DoorSlot.DOWN0},
            [RoomShape.ROOMSHAPE_2x1] = {DoorSlot.LEFT0,DoorSlot.UP0,DoorSlot.UP1,DoorSlot.RIGHT0,DoorSlot.DOWN0, DoorSlot.DOWN1},
            [RoomShape.ROOMSHAPE_IIH] = {DoorSlot.LEFT0, DoorSlot.RIGHT0},
            [RoomShape.ROOMSHAPE_2x2] = {DoorSlot.LEFT0,DoorSlot.UP0,DoorSlot.UP1,DoorSlot.RIGHT0,DoorSlot.LEFT1,DoorSlot.RIGHT1,DoorSlot.DOWN0,DoorSlot.DOWN1},
            [RoomShape.ROOMSHAPE_LTL] = {{DoorSlot.LEFT0, DoorSlot.UP0},DoorSlot.UP1,DoorSlot.RIGHT0,DoorSlot.LEFT1,DoorSlot.RIGHT1,DoorSlot.DOWN0,DoorSlot.DOWN1},
            [RoomShape.ROOMSHAPE_LTR] = {DoorSlot.LEFT0,DoorSlot.UP0,{DoorSlot.RIGHT0,DoorSlot.UP1},DoorSlot.LEFT1,DoorSlot.RIGHT1,DoorSlot.DOWN0,DoorSlot.DOWN1},
            [RoomShape.ROOMSHAPE_LBL] = {DoorSlot.LEFT0,DoorSlot.UP0,DoorSlot.UP1,DoorSlot.RIGHT0,{DoorSlot.DOWN0,DoorSlot.LEFT1},DoorSlot.RIGHT1,DoorSlot.DOWN1},
            [RoomShape.ROOMSHAPE_LBR] = {DoorSlot.LEFT0,DoorSlot.UP0,DoorSlot.UP1,DoorSlot.RIGHT0,DoorSlot.LEFT1,{DoorSlot.RIGHT1,DoorSlot.DOWN1},DoorSlot.DOWN0},
        }

        local function GetOppositeDoorSlot(slot)
            local oppslots = {[DoorSlot.LEFT0] = DoorSlot.RIGHT0, 
            [DoorSlot.UP0] = DoorSlot.DOWN0, 
            [DoorSlot.RIGHT0] = DoorSlot.LEFT0, 
            [DoorSlot.LEFT1] = DoorSlot.RIGHT1, 
            [DoorSlot.DOWN0] = DoorSlot.UP0, 
            [DoorSlot.UP1] = DoorSlot.DOWN1, 
            [DoorSlot.RIGHT1] = DoorSlot.LEFT1, 
            [DoorSlot.DOWN1] = DoorSlot.UP1}
            return oppslots[slot]
        end

        local sF = function (int)
            return 1 << int
        end
        local setbit = function(bum, bit)
            local oh = bum&bit 
            return oh==bit and bum or (bum + bit)
        end

        local dblockAlloweddir = {
            [0] = {sF(DoorSlot.DOWN0) | sF(DoorSlot.DOWN1) | sF(DoorSlot.RIGHT0) | sF(DoorSlot.RIGHT1)},
            [1] = {sF(DoorSlot.DOWN0) | sF(DoorSlot.DOWN1) | sF(DoorSlot.RIGHT0) | sF(DoorSlot.RIGHT1) | sF(DoorSlot.LEFT0) | sF(DoorSlot.LEFT1)},
        }
        local alldoor = sF(DoorSlot.DOWN0) | sF(DoorSlot.LEFT0) | sF(DoorSlot.UP0) | sF(DoorSlot.RIGHT0)

        ---@return RoomDescriptor[]
        local function GetNeighbors(room)
            local level = game:GetLevel()
            local tab = {}
            local neighs = ShapeToNeighbors[room.Data.Shape]
            for j = 1, #neighs do
                local neind = room.GridIndex + neighs[j]
                local nroom = level:GetRoomByIdx(neind, 0)
                if (neind > 0 and neind < (13*13)) and nroom.ListIndex ~= -1 then
                    tab[#tab+1] = neind
                end
            end
            return tab
        end

        ---@return RoomDescriptor[]
        local function GetNeighborsByIndexShape(index, shape)
            local level = game:GetLevel()
            local tab = {}
            local neighs = ShapeToNeighbors[shape]
            for j = 1, #neighs do
                local neind = index + neighs[j]
                local nroom = level:GetRoomByIdx(neind, 0)
                if (neind > 0 and neind < (13*13)) and nroom.ListIndex ~= -1 then
                    tab[#tab+1] = nroom
                end
            end
            return tab
        end

        local ttn = function (num)
            if type(num) == "table" then
                local a = 0
                for i=1, #num do
                    a = a | sF(num[i])
                end
                return a
            else
                return num
            end
        end

        ---@param room RoomDescriptor
        local function UpdateAllowedDoor(room, TargetIndex, createdoor)
            local level = game:GetLevel()
            local doorslot = 0
            local shape = room.Data.Shape
            local neighs = ShapeToNeighbors[room.Data.Shape]
           
            for j = 1, #neighs do
                local neind = room.GridIndex + neighs[j]
               
                if (neind > 0 and neind < (13*13)) 
                and (not TargetIndex or TargetIndex == neind) then
                    local nroom = level:GetRoomByIdx(neind, 0)
                    
                    if nroom.ListIndex ~= -1 then
                       
                        doorslot = doorslot | sF(ttn(ShapeToNeighborsDoor[shape][j]))
                        local slots = ShapeToNeighborsDoor[shape][j]
                        
                        --if WarpZone.CELESTROOMS_indexs[room.SafeGridIndex] then
                            if type(slots) == "table" then
                                for i=1, #slots do
                                    room.Doors[slots[i]] = neind
                                end
                            else
                                room.Doors[slots] = neind
                            end
                        --end
                    end
                end
            end
            room.AllowedDoors = room.AllowedDoors | doorslot
        end

        local function UpdateAllowedDoorR(room, TargetIndex, createdoor)
            local level = game:GetLevel()
            local doorslot = 0
            local shape = room.Data.Shape
            local neighs = ShapeToNeighbors[room.Data.Shape]
            
            for j = 1, #neighs do
                local neind = room.GridIndex + neighs[j]
                
                if (neind > 0 and neind < (13*13)) 
                and (not TargetIndex or TargetIndex == neind) then
                    local nroom = level:GetRoomByIdx(neind, 0)
                    
                    if nroom.ListIndex ~= -1 then
                        
                        doorslot = doorslot | sF(ttn(ShapeToNeighborsDoor[shape][j]))
                        local slots = ShapeToNeighborsDoor[shape][j]
                        
                        --if WarpZone.CELESTROOMS_indexs[room.SafeGridIndex] then
                            if type(slots) == "table" then
                                for i=1, #slots do
                                    room.Doors[slots[i]] = neind
                                end
                            else
                                room.Doors[slots] = neind
                            end
                        --end
                    end
                end
            end
            room.AllowedDoors = room.AllowedDoors | doorslot
        end

        local banNeightborType = {
            [RoomType.ROOM_SUPERSECRET]=true,
            [RoomType.ROOM_ULTRASECRET]=true,
            [RoomType.ROOM_BOSS]=true,
            [RoomType.ROOM_CURSE]=true,
            [RoomType.ROOM_ARCADE]=true,
            [RoomType.ROOM_CHALLENGE]=true,
            [RoomType.ROOM_CHEST]=true,
            [RoomType.ROOM_DICE]=true,
            [RoomType.ROOM_ISAACS]=true,
        }

        WarpZone.CELESTROOMS_indexs = {}

        function WarpZone.StrawBearry_Effect(player)
           --ItemOverlay.Show(WarpZone.WarpZoneTypes.GIANTBOOK_TREASURE_ADD, 3, player)
            local level = game:GetLevel()

            --local deadend = {}
            local canditatas = {}
            local rooms = level:GetRooms()
            for i=0, rooms.Size-1 do
                local room = rooms:Get(i)
                if room.GridIndex ~= -1 then
                --for shape=1, #ShapeToNeighbors do
                    local neighs = ShapeToNeighbors[room.Data.Shape]
                    for j = 1, #neighs do
                        local tidx = room.GridIndex + neighs[j]
                        if tidx > 0 and tidx < (13*13) then
                            local nroom = level:GetRoomByIdx(tidx, 0)
                            
                            local dosl = ShapeToNeighborsDoor[room.Data.Shape][j]
                            if type(dosl) ~= "number" then
                                dosl = dosl[1] or 0
                            end

                            if nroom.ListIndex == -1 and level:CanSpawnDoorOutline(room.SafeGridIndex, dosl) then
                                canditatas[#canditatas+1] = tidx
                            end
                        end
                    end
                --end
                end
            end
            
            if #canditatas > 0 then
                local rng = player:GetTrinketRNG(WarpZone.WarpZoneTypes.TRINKET_STRAWBERRY)
                local loop = 1
                ::again::
                if loop > 50 then
                    print("[WARP ZONE] Room spawn hit loop!")
                    return
                end
                local index = canditatas[rng:RandomInt(#canditatas)+1]

                local haddef = false
                local isban = false
                for i, nroom in pairs(GetNeighborsByIndexShape(index, RoomShape.ROOMSHAPE_1x1)) do
                    if nroom.Data.Type == RoomType.ROOM_DEFAULT then
                        haddef = true
                    elseif banNeightborType[nroom.Data.Type] then
                        isban = true
                    end
                end
                if isban and not haddef then
                    loop = loop + 1
                    goto again
                end

                local entry = Isaac.LevelGeneratorEntry()
                entry:SetAllowedDoors(alldoor)
                entry:SetColIdx((index-1) % 13 + 1)
                entry:SetLineIdx(math.floor(index/13))

                ---@type RoomConfig_Room
                local Rconf = RoomConfigHolder.GetRandomRoom(rng:GetSeed(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_TREASURE, RoomShape.ROOMSHAPE_1x1, -1,-1,nil,nil,15)
                
                rng:Next()
                --print(index, level:PlaceRoom(entry, Rconf, rng:GetSeed()))
                local isplased = level:PlaceRoom(entry, Rconf, rng:GetSeed())

                if isplased then
                    local newroom = level:GetRoomByIdx(index)
                    newroom.DisplayFlags = 7
                    newroom.AllowedDoors = 0 --alldoor
                    level:Update()
                    game:GetHUD():Update()
                    game:GetHUD():PostUpdate()

                    WarpZone.CELESTROOMS_indexs[newroom.SafeGridIndex] = true
                    
                    --[[local neighs = ShapeToNeighbors[RoomShape.ROOMSHAPE_1x1]
                    for j = 1, #neighs do
                        local nroom = level:GetRoomByIdx(index + neighs[j], 0)
                        --print(nroom, nroom.ListIndex, nroom and nroom.Data and nroom.Data.Type, room.GridIndex + neighs[j])
                        if nroom.ListIndex ~= -1 then
                            --print(ShapeToNeighborsDoor[j])
                            --nroom.AllowedDoors = setbit(nroom.AllowedDoors , sF(GetOppositeDoorSlot(ShapeToNeighborsDoor[RoomShape.ROOMSHAPE_1x1][j])) )
                            --newroom.AllowedDoors = newroom.AllowedDoors + sF(ShapeToNeighborsDoor[RoomShape.ROOMSHAPE_1x1][j])
                        end
                    end]]
                    UpdateAllowedDoorR(newroom, nil, true)
                    for i, k in pairs(GetNeighbors(newroom)) do
                        local nroom = level:GetRoomByIdx(k)
                        UpdateAllowedDoor(nroom, index)
                    end

                    WarpZone.TreasureRoomAddedNotification = true

                    ItemOverlay.Show(WarpZone.WarpZoneTypes.GIANTBOOK_TREASURE_ADD, 3, player)
                end
            end
        end

        function WarpZone.CeletsRoom_NewRoom()
            WarpZone.RGONPlayerTakeDamageRoom = nil
            WarpZone.TreasureRoomAddedNotification = nil
            --WarpZone.StrawBerryReward = nil
            local room = game:GetRoom()
            local level = game:GetLevel()

            if level:GetCurrentRoomDesc().GridIndex > 0 and room:GetType() == RoomType.ROOM_BOSS then
                if not room:IsClear() and PlayerManager.AnyoneHasTrinket(WarpZone.WarpZoneTypes.TRINKET_STRAWBERRY) then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, PolarStarEXTent, strawberry_effSybType,
                        strawberry_roomPos, Vector(0,0), nil)
                end

                if room:IsClear() and WarpZone.StrawBerryReward then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, PolarStarEXTent, strawberry_effSybType,
                        room:GetCenterPos(), Vector(0,0), nil)
                end
            end
        end
        WarpZone:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, WarpZone.CeletsRoom_NewRoom)

        function WarpZone.RGON_newLevel()
            WarpZone.CELESTROOMS_indexs = {}
            WarpZone.StrawBerryReward = nil
        end

        local TRAddNoti = Sprite()
        TRAddNoti:Load("gfx/ui/newTreasureRoomAddedNot.anm2", true)
        TRAddNoti:Play(TRAddNoti:GetDefaultAnimation())
        TRAddNoti.PlaybackSpeed = .5
        TRAddNoti.Offset = Vector(-18,30)
        
        local MinimapSize = Minimap.GetDisplayedSize
        function WarpZone.RGON_HUDRENDER()
            if WarpZone.TreasureRoomAddedNotification then
                local hudOffset = Vector(-24.5,12) * Options.HUDOffset
                local minisize = MinimapSize()
                local renderPos = Vector(Isaac.GetScreenWidth() - minisize.X, 0) + hudOffset

                TRAddNoti:Update()
                TRAddNoti:Render(renderPos)
            end
        end
        WarpZone:AddCallback(ModCallbacks.MC_HUD_RENDER, WarpZone.RGON_HUDRENDER)

        local EXPInit = {
            --[0],[5],[10],[200]
            [strawberry_effSybType] = function(ent,spr,pos) --strawberry
                spr:Load("gfx/effects/celest strawberry_effect.anm2", true)
                spr:Play("Idle")
                --ent.Position = Vector(250, 60)
                --Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0,
                --        pos, Vector(0,0), ent).Color = Color(1,1,1,.5, .5, .5, .5)

                ent.Visible = false
                ent:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
                ent.PositionOffset = Vector(0,-14)
            end,
        }

        local EXPLogic = {
            --[0],[5],[10],[200]
            ---@param ent EntityEffect
            ---@param spr Sprite
            ---@param pos Vector
            [strawberry_effSybType] = function(ent,spr,pos) --strawberry
                --ent.Position = Vector(480, 100)
                --ent.Velocity = (strawberry_roomPos-ent.Position)*.1
                --[[if not PlayerManager.AnyoneHasTrinket(WarpZone.WarpZoneTypes.TRINKET_STRAWBERRY) then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0,
                        pos, Vector(0,0), ent).Color = Color(1,1,1,.5, .5, .5, .5)
                    ent:Remove()
                end]]
                if WarpZone.RGONPlayerTakeDamageRoom then
                    --if spr:GetAnimation() == "Idle" then
                    --    spr:Play("lost")
                    --    sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
                    --end
                    ent:Remove()
                else
                --elseif WarpZone.StrawBerryReward then
                    --if spr:GetAnimation() == "Idle" then
                    --    spr:Play("up")
                    --    sfx:Play(SoundEffect.SOUND_THUMBSUP)
                    --end

                    --[[if ent.FrameCount % 30 == 0 or  then
                        local room = game:GetRoom()
                        --ent.TargetPosition = ent:GetDropRNG():RandomVector()*3
                        for i=1,100 do
                            local pos = room:GetRandomPosition(100)
                            if pos:Distance(pos) < 100 then
                                ent.TargetPosition = pos
                                break
                            end
                        end
                    end
                    local targVel = (ent.TargetPosition-ent.Position):Resized(1)
                    ent.Velocity = ent.Velocity * 0.95 + targVel * 0.05
                    print(targVel)
                    ent.Visible = true]]
                --else
                    local room = game:GetRoom()
                    if not ent.Target or not ent.Target:Exists() then
                        if room:GetAliveBossesCount() > 0 then
                            if not ent.Target or not ent.Target:Exists() then
                                local list = Isaac.FindInRadius(room:GetCenterPos(), 1500, EntityPartition.ENEMY)
                                if #list > 0 then 
                                    for i=1,#list do
                                        ent.Target = list[i]
                                    end
                                end
                            end
                        else
                            if ent.FrameCount % 60 == 0 or ent.Position:Distance(ent.TargetPosition) < 40 then
                                --ent.TargetPosition = ent:GetDropRNG():RandomVector()*3
                                for i=1,100 do
                                    local Npos = room:GetRandomPosition(50)
                                    local dist = Npos:Distance(pos)
                                    if  dist > 50 then
                                        ent.TargetPosition = Npos
                                        break
                                    end
                                end
                                --Isaac.Spawn(1000,EffectVariant.BULLET_POOF,0,ent.TargetPosition,Vector(0,0),nil)
                            end
                            local closePlay = game:GetNearestPlayer(pos)
                            local disttop = pos:Distance(closePlay.Position)
                            if spr:GetAnimation() == "Idle" then
                                local targVel = (ent.TargetPosition-ent.Position):Resized(math.max(1, (ent.TargetPosition:Distance(pos)-100)/100))
                                --local closePlay = game:GetNearestPlayer(pos)
                                --local disttop = pos:Distance(closePlay.Position)
                                targVel = targVel + (pos-closePlay.Position):Resized(math.max(0, (140 - disttop)/10))
                                ent.Velocity = ent.Velocity * 0.95 + targVel * 0.05
                            else
                                ent.Velocity = Vector(0,0)
                            end

                            if not ent.Visible then
                                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0,
                                    pos, Vector(0,0), ent).Color = Color(1,1,1,.5, .5, .5, .5)
                                ent.Visible = true
                            else
                                if disttop < 30 then
                                    if spr:GetAnimation() == "Idle" then
                                        spr:Play("up")
                                        sfx:Play(SoundEffect.SOUND_THUMBSUP)

                                        for i=0, game:GetNumPlayers()-1 do
                                            local player = Isaac.GetPlayer(i)
                                            if player:HasTrinket(WarpZone.WarpZoneTypes.TRINKET_STRAWBERRY) or player:GetEffects():HasTrinketEffect(WarpZone.WarpZoneTypes.TRINKET_STRAWBERRY) then
                                                WarpZone.StrawBearry_Effect(player)
                                            end
                                        end
                                    end
                                    WarpZone.StrawBerryReward = nil
                                end
                            end
                        end
                    else
                        ent.Position = ent.Target.Position
                    end
                end
                if spr:IsFinished("lost") then
                    spr:Play("Idle_lost")
                end
                if spr:IsPlaying("up") and spr:IsEventTriggered("sound") then
                    sfx:Play(SoundEffect.SOUND_POWERUP1, Options.SFXVolume*.7, nil, nil, 1.6)
                end
            end,
        }

        function WarpZone.RGONPolarStarEXPEnt_update(_, ent)
            local spr = ent:GetSprite()
            local pos = ent.Position
            if EXPLogic[ent.SubType] and EXPLogic[ent.SubType](ent,spr,pos) then
            end
        end
        WarpZone:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, WarpZone.RGONPolarStarEXPEnt_update, PolarStarEXTent)

        function WarpZone.RGONPolarStarEXPEnt_init(_, ent)
            local spr = ent:GetSprite()
            local pos = ent.Position
            if EXPInit[ent.SubType] and EXPInit[ent.SubType](ent,spr,pos) then
            end
        end
        WarpZone:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, WarpZone.RGONPolarStarEXPEnt_init, PolarStarEXTent)

        function WarpZone.RGON_PostTakeDmgPlayer()
            if PlayerManager.AnyoneHasTrinket(WarpZone.WarpZoneTypes.TRINKET_STRAWBERRY) then
                WarpZone.RGONPlayerTakeDamageRoom = true
            end
        end
        WarpZone:AddCallback(ModCallbacks.MC_POST_TAKE_DMG, WarpZone.RGON_PostTakeDmgPlayer, 1)

        function WarpZone.RGON_CLEAN_AWARD()
            if not WarpZone.StrawBerryReward and game:GetRoom():GetType() == RoomType.ROOM_BOSS 
            and not WarpZone.RGONPlayerTakeDamageRoom
            and PlayerManager.AnyoneHasTrinket(WarpZone.WarpZoneTypes.TRINKET_STRAWBERRY) then
                WarpZone.StrawBerryReward = true
                --[[for i=0, game:GetNumPlayers()-1 do
                    local player = Isaac.GetPlayer(i)
                    if player:HasTrinket(WarpZone.WarpZoneTypes.TRINKET_STRAWBERRY) or player:GetEffects():HasTrinketEffect(WarpZone.WarpZoneTypes.TRINKET_STRAWBERRY) then
                        WarpZone.StrawBearry_Effect(player)
                    end
                end]]
            end
        end
        WarpZone:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, WarpZone.RGON_CLEAN_AWARD, 1)



        ---- IS YOU

        ---@param player EntityPlayer
        function WarpZone.ISYOUACTIVERENDER(_, player, slot, offset, alpha)
            
            if slot == ActiveSlot.SLOT_PRIMARY then
                local activeType = player:GetActiveItem(slot)
                if activeType == WarpZone.WarpZoneTypes.COLLECTIBLE_IS_YOU then
                    local data = player:GetData()
                    local unsave = data.WarpZone_unsavedata
                   
                    if data.baba_active then
                        if not unsave.babaIemSpr then
                            local conf = Isaac.GetItemConfig()
                            local gfx = conf:GetCollectible(data.baba_active).GfxFileName
                            unsave.babaIemSpr = Sprite()
                            local spr = unsave.babaIemSpr
                            spr:Load("gfx/005.100_collectible.anm2", true)
                            spr:Play(spr:GetDefaultAnimation())
                            spr:ReplaceSpritesheet(1, gfx, true)
                            spr:LoadGraphics()
                        else
                            local spr = unsave.babaIemSpr
                            spr.Color.A = alpha * (math.sin(player.FrameCount/10)/4+.75)
                            spr:Render(offset+Vector(16,38))
                        end
                    end
                end
            end
        end
        WarpZone:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, WarpZone.ISYOUACTIVERENDER)

    end
end