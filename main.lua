--basic data
local game = Game()
local WarpZone  = RegisterMod("WarpZone", 1)
local debug_str = "Placeholder"
local json = require("json")
local myRNG = RNG()
myRNG:SetSeed(Random(), 1)

----------------------------------
--save data
local saveData = {}
local itemsTaken = {}
local poolsTaken = {}


-----------------------------------
--golden idol
local inDamage = false

--pastkiller
local pickupindex = RNG():RandomInt(10000) + 10000 --this makes it like a 1 in 10,000 chance there's any collision with existing pedestals
local itemPool = Game():GetItemPool()


--rusty spoon
local rustColor = Color(.68, .21, .1, 1, 0, 0, 0)
local lastIsRusty = false


--focus
local FocusChargeMultiplier = 2.5
local whiteColor = Color(1, 1, 1, 1, 0, 0, 0)
whiteColor:SetColorize(1, 1, 1, 1)
whiteColor:SetTint(20, 20, 20, 2)
local primeShot = false
local totalFocusDamage = 0

--doorway
local DoorwayFloor = -1



--item defintions
CollectibleType.COLLECTIBLE_GOLDENIDOL = Isaac.GetItemIdByName("Golden Idol")
CollectibleType.COLLECTIBLE_PASTKILLER = Isaac.GetItemIdByName("Gun that can kill the Past")
CollectibleType.COLLECTIBLE_BIRTHDAY_CAKE = Isaac.GetItemIdByName("Birthday Cake")
CollectibleType.COLLECTIBLE_RUSTY_SPOON = Isaac.GetItemIdByName("Rusty Spoon")
CollectibleType.COLLECTIBLE_NEWGROUNDS_TANK = Isaac.GetItemIdByName("Newgrounds Tank")
CollectibleType.COLLECTIBLE_GREED_BUTT = Isaac.GetItemIdByName("Greed Butt")
CollectibleType.COLLECTIBLE_FOCUS = Isaac.GetItemIdByName("Focus")
CollectibleType.COLLECTIBLE_FOCUS_2 = Isaac.GetItemIdByName(" Focus ")
CollectibleType.COLLECTIBLE_FOCUS_3 = Isaac.GetItemIdByName("  Focus  ")
CollectibleType.COLLECTIBLE_FOCUS_4 = Isaac.GetItemIdByName("   Focus   ")
CollectibleType.COLLECTIBLE_DOORWAY = Isaac.GetItemIdByName("The Doorway")

local SfxManager = SFXManager()

--util functions
local function RandomFloatRange(greater)
    local lower = 0
    return lower + math.random()  * (greater - lower);
end


local function findFreeTile(pos)
    local room = Game():GetRoom()
    local idx = type(pos) == 'number' and pos or room:GetGridIndex(pos)
    local w = room:GetGridWidth()
    if room:GetGridEntity(idx) == nil or room:GetGridEntity(idx).State == 4 then
        return idx
    elseif room:GetGridEntity(idx - 1) == nil or room:GetGridEntity(idx - 1).State == 4 then
        return idx - 1
    elseif room:GetGridEntity(idx + 1) == nil or room:GetGridEntity(idx + 1).State == 4 then
        return idx + 1
    elseif room:GetGridEntity(idx - w) == nil or room:GetGridEntity(idx - w).State == 4 then
        return idx - w
    elseif room:GetGridEntity(idx + w) == nil or room:GetGridEntity(idx + w).State == 4 then
        return idx + w
    elseif room:GetGridEntity(idx - w - 1) == nil or room:GetGridEntity(idx - w - 1).State == 4 then
        return idx - w - 1
    elseif room:GetGridEntity(idx + w - 1) == nil or room:GetGridEntity(idx + w - 1).State == 4 then
        return idx + w - 1
    elseif room:GetGridEntity(idx - w + 1) == nil or room:GetGridEntity(idx - w + 1).State == 4 then
        return idx - w + 1
    elseif room:GetGridEntity(idx + w + 1) == nil or room:GetGridEntity(idx + w + 1).State == 4 then
        return idx + w + 1
    else
        return false
    end
end


local function GetGridEntities()
    ---@type GridEntity[]
    local gridEntities = {}
    local room = Game():GetRoom()
      
    for i = 0, room:GetGridSize() - 1, 1 do
        local gridEntity = room:GetGridEntity(i)
      
        gridEntities[#gridEntities+1] = gridEntity
    end
    return gridEntities
end
doors = GetGridEntities()

 --callbacks
function WarpZone:EnemyHit(entity, amount, damageflags, source, countdownframes)
    if entity:IsVulnerableEnemy() then
        local player_ =  Isaac.GetPlayer(0)
        local source_entity = source.Entity

        if source_entity and source_entity:GetData().FocusIndicator == nil and
            (CollectibleType.COLLECTIBLE_FOCUS == player_:GetActiveItem() or
            CollectibleType.COLLECTIBLE_FOCUS_2 == player_:GetActiveItem() or
            CollectibleType.COLLECTIBLE_FOCUS_3 == player_:GetActiveItem() or
            CollectibleType.COLLECTIBLE_FOCUS_4 == player_:GetActiveItem()
            )
        then
            totalFocusDamage = totalFocusDamage + math.min(amount, entity.HitPoints)
            local chargeMax = (Game():GetLevel():GetStage() * FocusChargeMultiplier * 40) + 60 * FocusChargeMultiplier
            local chargesToSet = math.floor((20 * totalFocusDamage)/chargeMax)
            local chargeThreshold = 20
            if player_:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
                chargeThreshold = 40
            end
            local pastCharge = player_:GetActiveCharge()
            local newCharge = math.min(chargeThreshold, chargesToSet)

            if pastCharge <= 3  and 3 < newCharge and newCharge <= 10 then
                player_:AddCollectible(CollectibleType.COLLECTIBLE_FOCUS_2, newCharge, false, ActiveSlot.SLOT_PRIMARY)
            elseif pastCharge <= 10 and 10 < newCharge and newCharge <= 19 then
                player_:AddCollectible(CollectibleType.COLLECTIBLE_FOCUS_3, newCharge, false, ActiveSlot.SLOT_PRIMARY)
            elseif pastCharge <=19 and newCharge and newCharge >= 20 then
                player_:AddCollectible(CollectibleType.COLLECTIBLE_FOCUS_4, newCharge, false, ActiveSlot.SLOT_PRIMARY)
                SfxManager:Play(SoundEffect.SOUND_BATTERYCHARGE)
            else
                player_:SetActiveCharge(newCharge)
            end
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, WarpZone.EnemyHit)



function WarpZone:OnTakeHit(entity, amount, damageflags, source, countdownframes)
    local player = entity:ToPlayer()
    if player == nil then
        return
    end
    
    if player:HasCollectible(CollectibleType.COLLECTIBLE_NEWGROUNDS_TANK) then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NEWGROUNDS_TANK)
        if rng:RandomInt(10) == 1 and  damageflags & DamageFlag.DAMAGE_NO_PENALTIES ~= DamageFlag.DAMAGE_NO_PENALTIES then
            SfxManager:Play(SoundEffect.SOUND_SCYTHE_BREAK)
            player:SetMinDamageCooldown(60)
            return false
        end
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_GREED_BUTT) and source ~= nil then
        local source_entity = source.Entity
        if source_entity ~= nil and (source_entity:IsEnemy() or (source_entity.Type == EntityType.ENTITY_PROJECTILE and source_entity.Variant ~= ProjectileVariant.PROJECTILE_FIRE)) then
            local direction = player:GetHeadDirection()
            local sourcePosition = source_entity.Position
            local playerPosition = player.Position
            
            local vectorSum = playerPosition - sourcePosition
            
            local backstab = false
            local coinvelocity
            local velConstant = 16

            if math.abs(vectorSum.X) > math.abs(vectorSum.Y) then
                if (vectorSum.X > 0  and direction == Direction.RIGHT) then
                    backstab = true
                    coinvelocity = Vector(-velConstant, 0)
                elseif (vectorSum.X < 0  and direction == Direction.LEFT) then
                    backstab = true
                    coinvelocity = Vector(velConstant, 0)
                end
            elseif math.abs(vectorSum.X) < math.abs(vectorSum.Y) then
                if  (vectorSum.Y > 0  and direction == Direction.DOWN) then
                    backstab = true
                    coinvelocity = Vector(0, -velConstant)
                elseif (vectorSum.Y < 0  and direction == Direction.UP) then
                    backstab = true
                    coinvelocity = Vector(0, velConstant)
                end
            end
            if backstab == true then
                local gb_rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_GREED_BUTT)
                local benchmark = gb_rng:RandomInt(100)
                if benchmark < 4 then
                    local id = findFreeTile(player.Position)
                    if id ~= false then
                        Game():GetRoom():SpawnGridEntity(id, GridEntityType.GRID_POOP, 3, gb_rng:Next(), 0)
                        SfxManager:Play(SoundEffect.SOUND_FART, 1.0, 0, false, 1.0)
                    end
                else
                    Isaac.Spawn(EntityType.ENTITY_PICKUP,
                        PickupVariant.PICKUP_COIN,
                        0,
                        Game():GetRoom():FindFreePickupSpawnPosition(player.Position),
                        coinvelocity,
                        nil)
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_BEAN)
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_BUTTER_BEAN)
                end
            end

        end
    end

    if player:GetNumCoins() > 0 and inDamage == false and player:HasCollectible(CollectibleType.COLLECTIBLE_GOLDENIDOL) == true and player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) == false then
        inDamage = true
        if amount == 1 then
            player:TakeDamage(amount, damageflags, source, countdownframes)
        end

        local coinsToLose = math.max(5, math.floor(player:GetNumCoins()/2))
        player:AddCoins(-coinsToLose)

        local coinsToDrop = math.floor(coinsToLose/2)
        
        for i = 1, coinsToDrop do
            local vel = RandomVector() * (RandomFloatRange(0.5) + 0.5) * 16.0
            local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, player.Position, vel, player):ToPickup()
            coin.Timeout = 45 + math.floor(RandomFloatRange(15))
            coin:GetSprite():SetFrame(math.floor(coinsToDrop - i))
        end
        
        inDamage = false
    end
end
WarpZone:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, WarpZone.OnTakeHit, EntityType.ENTITY_PLAYER)


function WarpZone:spawnCleanAward(RNG, SpawnPosition)
    local player = Isaac.GetPlayer(0)
    local i=RNG:RandomInt(2)
    local room = Game():GetRoom():GetType() == RoomType.ROOM_BOSS
    if (i == 1 or room) and player:HasCollectible(CollectibleType.COLLECTIBLE_GOLDENIDOL) == true and player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) == false then
        local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, 
                     PickupVariant.PICKUP_COIN,
                     CoinSubType.COIN_NICKEL,
                     Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()),
                     Vector(0,0),
                    nil)
        coin.Timeout = 90
        if room then
            local coin2 = Isaac.Spawn(EntityType.ENTITY_PICKUP, 
                     PickupVariant.PICKUP_COIN,
                     CoinSubType.COIN_NICKEL,
                     Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()),
                     Vector(0,0),
                    nil)
            coin2.Timeout = 90
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, WarpZone.spawnCleanAward)



function WarpZone:OnGameStart(isSave)
    if WarpZone:HasData()  and isSave then
        saveData = json.decode(WarpZone:LoadData())
        itemsTaken = saveData[1]
        poolsTaken = saveData[2]
        totalFocusDamage = saveData[3]
    end

    if not isSave then
        itemsTaken = {}
        poolsTaken = {}
        saveData = {}
        totalFocusDamage = 0
    end

end
WarpZone:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, WarpZone.OnGameStart)


function WarpZone:preGameExit()
    saveData[1] = itemsTaken
    saveData[2] = poolsTaken
    saveData[3] = totalFocusDamage
    local jsonString = json.encode(saveData)
    WarpZone:SaveData(jsonString)
  end

  WarpZone:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, WarpZone.preGameExit)


function WarpZone:DebugText()
    local player = Isaac.GetPlayer(0)
    local coords = player.Position
    --Isaac.RenderText(debug_str, 100, 60, 1, 1, 1, 255)

end
WarpZone:AddCallback(ModCallbacks.MC_POST_RENDER, WarpZone.DebugText)

function WarpZone:LevelStart()
    local currentStage = Game():GetLevel():GetStage()
    local player = Isaac.GetPlayer(0)
    if totalFocusDamage > 0 and (CollectibleType.COLLECTIBLE_FOCUS == player:GetActiveItem() or
    CollectibleType.COLLECTIBLE_FOCUS_2 == player:GetActiveItem() or
    CollectibleType.COLLECTIBLE_FOCUS_3 == player:GetActiveItem() or
    CollectibleType.COLLECTIBLE_FOCUS_4 == player:GetActiveItem()) then
        local one_unit_full_charge = (Game():GetLevel():GetStage() * FocusChargeMultiplier * 40) + 60 * FocusChargeMultiplier
        local one_unit_full_charge_prev = (math.min(Game():GetLevel():GetStage()-1, 1) * FocusChargeMultiplier * 40) + 60 * FocusChargeMultiplier
        totalFocusDamage = totalFocusDamage * (one_unit_full_charge/one_unit_full_charge_prev)
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHDAY_CAKE) then
        local spawnArray = {PickupVariant.PICKUP_BOMB, PickupVariant.PICKUP_COIN, PickupVariant.PICKUP_HEART, PickupVariant.PICKUP_KEY}

        if RNG():RandomInt(2) == 1 then
            table.insert(spawnArray, PickupVariant.PICKUP_PILL)
        else
            table.insert(spawnArray, PickupVariant.PICKUP_TAROTCARD)
        end

        for i, spawn_type in ipairs(spawnArray) do
            Isaac.Spawn(EntityType.ENTITY_PICKUP,
                        spawn_type,
                        0,
                        Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()),
                        Vector(0,0),
                        nil)
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, WarpZone.LevelStart)


function WarpZone:NewRoom()
    local player = Isaac.GetPlayer(0)
    local room = Game():GetRoom()
    if Game():GetLevel():GetStage() == DoorwayFloor or true then
        if room:GetType() == RoomType.ROOM_BOSS then
            room:TrySpawnDevilRoomDoor(false, true)
            if Game():GetLevel():GetStage() == LevelStage.STAGE3_2 then
                room:TrySpawnBossRushDoor()
            elseif Game():GetLevel():GetStage() == LevelStage.STAGE4_2 and Game():GetLevel():GetStageType() < 3 then
                room:TrySpawnBlueWombDoor()
            end
        end
        for i = 0, 7 do
            local door = room:GetDoor(i)
            if door then -- if it isnt nil, then
              local doorEntity = door:ToDoor()
            if doorEntity:IsLocked() then
                doorEntity:TryUnlock(player, true)
            end
            if not doorEntity:IsOpen() then
                doorEntity:Open()
            end
              
              room:DestroyGrid(door:GetGridIndex(), true)
            end
          end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, WarpZone.NewRoom)

function WarpZone:usePastkiller(collectible, rng, entityplayer, useflags, activeslot, customvardata)

    local player =  entityplayer:ToPlayer()
    --debug_str = tostring(player.ControllerIndex)
 
    
    local shift = 0
    for i, item_tag in ipairs(itemsTaken) do
        if player:HasCollectible(item_tag) == false then
            table.remove(itemsTaken, i-shift)
            table.remove(poolsTaken, i-shift)
            shift = shift + 1
        end
    end

    if #itemsTaken < 3 then
        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false
        }
    end


    local pos = Game():GetRoom():GetCenterPos() + Vector(-180, -100)
    local pool
    local item_removed


    for j = 1, 3 do
        pickupindex = pickupindex + 1
        pool = table.remove(poolsTaken, 1)
        item_removed  = table.remove(itemsTaken, 1)
        player:RemoveCollectible(item_removed)
        for i = 1, 3 do
            local pedestal = Isaac.Spawn(EntityType.ENTITY_PICKUP,
                        PickupVariant.PICKUP_COLLECTIBLE,
                        itemPool:GetCollectible(pool),
                        Game():GetRoom():FindFreePickupSpawnPosition(pos + Vector(90 * i, 60 * j)),
                        Vector(0,0),
                        nil)
            pedestal:ToPickup().OptionsPickupIndex = pickupindex
        end
    end
    
    SfxManager:Play(SoundEffect.SOUND_GFUEL_AIR_HORN, 1)
    SfxManager:Play(SoundEffect.SOUND_GFUEL_GUNSHOT_SPREAD, 4)

    return {
        Discharge = false,
        Remove = true,
        ShowAnim = true
    }
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.usePastkiller, CollectibleType.COLLECTIBLE_PASTKILLER)

function WarpZone:UseFocus(collectible, rng, entityplayer, useflags, activeslot, customvardata)
    local player =  entityplayer:ToPlayer()

    if not player:HasFullHearts() then
        player:AddHearts(2)
        SfxManager:Play(SoundEffect.SOUND_DEATH_CARD, 3)
    else
        SfxManager:Play(SoundEffect.SOUND_ANGEL_WING, 2)
        primeShot = true
    end

    local one_unit_full_charge = (Game():GetLevel():GetStage() * FocusChargeMultiplier * 40) + FocusChargeMultiplier * 60
    local adjustedcharge = 0

    if player:GetActiveCharge() >= 20 then
        adjustedcharge = player:GetActiveCharge() - 20
        totalFocusDamage = math.floor(one_unit_full_charge * (adjustedcharge/20))
    else
        totalFocusDamage = 0
    end

    player:AddCollectible(CollectibleType.COLLECTIBLE_FOCUS, adjustedcharge, false, activeslot)

    return {
        Discharge = false,
        Remove = false,
        ShowAnim = true
    }
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.UseFocus, CollectibleType.COLLECTIBLE_FOCUS_4)

function WarpZone:UseDoorway(collectible, rng, entityplayer, useflags, activeslot, customvardata)
    local room = Game():GetRoom()
    local currentLevel = Game():GetLevel()
    currentLevel:DisableDevilRoom()
    entityplayer:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY)
    DoorwayFloor = currentLevel:GetStage()
    currentLevel:ApplyBlueMapEffect()
    


    local rooms = currentLevel:GetRooms()

    for i=1, #rooms, 1 do

        if rooms:Get(i) and rooms:Get(i).Data and rooms:Get(i).Data.Type == RoomType.ROOM_ULTRASECRET then
            local newindex = rooms:Get(i).GridIndex
            local room_obj = currentLevel:GetRoomByIdx(rooms:Get(i).GridIndex)
            room_obj.DisplayFlags = 101
            local x = (newindex % 13)
            local y = (math.floor(newindex / 13))
            local unlocked = false
            if x > 1 then
                local test_room = currentLevel:GetRoomByIdx(newindex-2, 0)
                if test_room.Data ~= nil then
                    currentLevel:MakeRedRoomDoor(newindex-2, DoorSlot.RIGHT0)
                    currentLevel:MakeRedRoomDoor(newindex-1, DoorSlot.RIGHT0)
                    unlocked = true
                    for j = x, 12, 1 do
                        currentLevel:MakeRedRoomDoor((y*13) + j, DoorSlot.RIGHT0)
                    end
                end
            end
            if x < 11 and not unlocked then
                local test_room = currentLevel:GetRoomByIdx(newindex+2, 0)
                if test_room.Data ~= nil then
                    currentLevel:MakeRedRoomDoor(newindex+2, DoorSlot.LEFT0)
                    currentLevel:MakeRedRoomDoor(newindex+1, DoorSlot.LEFT0)
                    unlocked = true
                    for j = x, 0, -1 do
                        currentLevel:MakeRedRoomDoor((y*13) + j, DoorSlot.LEFT0)
                    end
                end
            end
            if y > 1 and not unlocked then
                local test_room = currentLevel:GetRoomByIdx(newindex-26, 0)
                if test_room.Data ~= nil then
                    currentLevel:MakeRedRoomDoor(newindex-26, DoorSlot.DOWN0)
                    currentLevel:MakeRedRoomDoor(newindex-13, DoorSlot.DOWN0)
                    unlocked = true
                    for j = y, 12, 1 do
                        currentLevel:MakeRedRoomDoor(x + (13 * j), DoorSlot.DOWN0)
                    end
                end
            end
            if y < 11 and not unlocked then
                local test_room = currentLevel:GetRoomByIdx(newindex+26, 0)
                if test_room.Data ~= nil then
                    currentLevel:MakeRedRoomDoor(newindex+26, DoorSlot.UP0)
                    currentLevel:MakeRedRoomDoor(newindex+13, DoorSlot.UP0)
                    unlocked = true
                    for j = y, 0, -1 do
                        currentLevel:MakeRedRoomDoor(x + (13 * j), DoorSlot.UP0)
                    end
                end
            end
        end
    end
    currentLevel:RemoveCurses(LevelCurse.CURSE_OF_MAZE)
    currentLevel:ApplyCompassEffect(true)
    currentLevel:ApplyMapEffect()
    return {
        Discharge = false,
        Remove = true,
        ShowAnim = true
    }
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.UseDoorway, CollectibleType.COLLECTIBLE_DOORWAY)


function WarpZone:OnPickupCollide(entity, Collider, Low)
    local player = Collider:ToPlayer()
    if player == nil then
        return nil
    end

    if entity.Type == EntityType.ENTITY_PICKUP and (entity.Variant == PickupVariant.PICKUP_COLLECTIBLE) and entity:ToPickup():GetData().Logged ~= true then
        local config = Isaac.GetItemConfig():GetCollectible(entity.SubType)
        entity:ToPickup():GetData().Logged = true
        local pool = Game():GetItemPool():GetLastPool()
        if config.Type ~= ItemType.ITEM_ACTIVE then
            table.insert(itemsTaken, entity.SubType)
            table.insert(poolsTaken, pool)
        end
    end
    return nil
end

WarpZone:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, WarpZone.OnPickupCollide)

function WarpZone:EvaluateCache(entityplayer, Cache)
    local cakeBingeBonus = 0

    local tank_qty =  entityplayer:GetCollectibleNum(CollectibleType.COLLECTIBLE_NEWGROUNDS_TANK)

    if Cache == CacheFlag.CACHE_FIREDELAY then
        local maxFireDelay = math.min(5, entityplayer.MaxFireDelay)

        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_NEWGROUNDS_TANK) then
            entityplayer.MaxFireDelay = entityplayer.MaxFireDelay - tank_qty
        end
        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then
            cakeBingeBonus = entityplayer:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHDAY_CAKE) * 2
        end
        entityplayer.MaxFireDelay = entityplayer.MaxFireDelay - cakeBingeBonus
    end

    if Cache == CacheFlag.CACHE_DAMAGE then
        entityplayer.Damage = entityplayer.Damage + (0.5 * tank_qty)
    end

    if Cache == CacheFlag.CACHE_RANGE then
        entityplayer.TearRange = entityplayer.TearRange + (1.5 * tank_qty)
    end

    if Cache == CacheFlag.CACHE_LUCK then
        entityplayer.Luck = entityplayer.Luck + tank_qty
    end

    if Cache == CacheFlag.CACHE_SPEED then
        entityplayer.MoveSpeed = entityplayer.MoveSpeed - (tank_qty * .3)
    end

    if Cache == CacheFlag.CACHE_SHOTSPEED then
        entityplayer.ShotSpeed = entityplayer.ShotSpeed + (tank_qty * .16)
    end

end
WarpZone:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, WarpZone.EvaluateCache)


function WarpZone:checkTear(entitytear)
    local tear = entitytear:ToTear()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_RUSTY_SPOON) then
        local chance = player.Luck * 5 + 10
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_RUSTY_SPOON)
        if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
            chance = chance + 15
        end
        local chance_num = rng:RandomInt(100)
        if chance_num < chance then
            tear:GetData().Is_Rusty = true
            tear:GetData().BleedIt = true
        end
    end
    if CollectibleType.COLLECTIBLE_FOCUS == player:GetActiveItem() and primeShot then
        SfxManager:Play(SoundEffect.SOUND_EXPLOSION_WEAK, 3)
        primeShot = false
        tear:GetData().FocusShot = true
        tear:GetData().FocusIndicator = true
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, WarpZone.checkTear)


function WarpZone:updateTear(entitytear)
    local tear = entitytear:ToTear()
    if tear:GetData().Is_Rusty == true then
        tear:GetData().Is_Rusty = false
        tear:AddTearFlags(TearFlags.TEAR_HOMING)
        local sprite_tear = tear:GetSprite()
        sprite_tear.Color = rustColor
    elseif tear:GetData().FocusShot == true then
        tear:GetData().FocusShot = false
        tear:AddTearFlags(TearFlags.TEAR_PIERCING)
        tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
        tear:AddTearFlags(TearFlags.TEAR_DARK_MATTER)
        
        --tear.Velocity.X = math.max(tear.Velocity.X * 1.5, 20)
        --tear.Velocity.Y = math.max(tear.Velocity.Y * 1.5, 20)
        tear.Velocity = tear.Velocity * Vector(1.5, 1.5)
        
        local sprite_tear = tear:GetSprite()
        sprite_tear.Color = whiteColor

        tear.Scale = tear.Scale * 3.5
        tear.CollisionDamage = tear.CollisionDamage + 185
        tear:ResetSpriteScale()
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, WarpZone.updateTear)

function WarpZone:hitEnemy(entitytear, collider, low)
    local player = Isaac.GetPlayer(0)

    local tear = entitytear:ToTear()

    if collider:IsEnemy() and tear:GetData().BleedIt == true then
        collider:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
    end

    

end
WarpZone:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, WarpZone.hitEnemy)


function WarpZone:OnFrame(entityplayer)
    local player = Isaac.GetPlayer(0)
        local room = Game():GetRoom()
        if Game():GetLevel():GetStage() == DoorwayFloor or true then
            for i = 0, 7 do
                local door = room:GetDoor(i)
                if door then -- if it isnt nil, then
                local doorEntity = door:ToDoor()
                if doorEntity:IsLocked() then
                    doorEntity:TryUnlock(player, true)
                end
                if not doorEntity:IsOpen() then
                    doorEntity:Open()
                end
                
                room:DestroyGrid(door:GetGridIndex(), true)
                end
            end
        end
    end
WarpZone:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, WarpZone.OnFrame)

--disable devil room