local WarpZone  = RegisterMod("WarpZone", 1)
local debug_str = "Placeholder"
local json = require("json")

local saveData = {}

local itemsTaken = {}
local poolsTaken = {}

local inDamage = false
local tookDamage = false

local itemPool = Game():GetItemPool()

local game = Game()
local hud = game:GetHUD()

CollectibleType.COLLECTIBLE_GOLDENIDOL = Isaac.GetItemIdByName("Golden Idol")
CollectibleType.COLLECTIBLE_PASTKILLER = Isaac.GetItemIdByName("Gun that can kill the Past")
CollectibleType.COLLECTIBLE_BIRTHDAY_CAKE = Isaac.GetItemIdByName("Birthday Cake")

local SfxManager = SFXManager()


local function RandomFloatRange(greater)
    local lower = 0
    return lower + math.random()  * (greater - lower);
end


function WarpZone:OnTakeHit(entity, amount, damageflags, source, countdownframes)
    local player = entity:ToPlayer()
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

    if i == 1 and player:HasCollectible(CollectibleType.COLLECTIBLE_GOLDENIDOL) == true and player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) == false then
        local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, 
                     PickupVariant.PICKUP_COIN,
                     CoinSubType.COIN_NICKEL,
                     Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()),
                     Vector(0,0),
                    nil)
        coin.Timeout = 90
    end
end
WarpZone:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, WarpZone.spawnCleanAward)



function WarpZone:OnGameStart(isSave)
    if WarpZone:HasData()  and isSave then
        saveData = json.decode(WarpZone:LoadData())
        itemsTaken = saveData[1]
        poolsTaken = saveData[2]
    end

    if not isSave then
        itemsTaken = {}
        poolsTaken = {}
        saveData = {}
    end

end
WarpZone:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, WarpZone.OnGameStart)


function WarpZone:preGameExit()
    saveData[1] = itemsTaken
    saveData[2] = poolsTaken
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
    local player = Isaac.GetPlayer(0)
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


function WarpZone:usePastkiller(collectible, rng, entityplayer, useflags, activeslot, customvardata)

    local player =  entityplayer:ToPlayer()
    debug_str = tostring(player.ControllerIndex)
 
    
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
    local pickupindex = RNG():RandomInt(10000) + 10000 --this makes it like a 1 in 10,000 chance there's any collision with existing pedestals
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

    if Cache == CacheFlag.CACHE_FIREDELAY then
        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then
            cakeBingeBonus = entityplayer:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHDAY_CAKE)
        end
        EntityPlayer.MaxFireDelay = math.max(5, (EntityPlayer.MaxFireDelay - cakeBingeBonus))
    end
end
WarpZone:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, WarpZone.EvaluateCache)