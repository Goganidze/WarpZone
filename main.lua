--basic data
local game = Game()
local WarpZone  = RegisterMod("WarpZone", 1)
local debug_str = "Placeholder"
local json = require("json")
local myRNG = RNG()
myRNG:SetSeed(Random(), 1)
local hud = game:GetHUD()
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
local itemPool = game:GetItemPool()


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

--is you
local reticle
local blinkTime = 10
local baba_active = nil
local timeSinceTheSpacebarWasLastPressed = 0

--nightmare tick
local roomsClearedSinceTake = -1
local itemsSucked = 0



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
CollectibleType.COLLECTIBLE_STRANGE_MARBLE = Isaac.GetItemIdByName("Strange Marble")
CollectibleType.COLLECTIBLE_IS_YOU = Isaac.GetItemIdByName("Is You")
CollectibleType.COLLECTIBLE_NIGHTMARE_TICK = Isaac.GetItemIdByName("Nightmare Tick")
CollectibleType.COLLECTIBLE_SPELUNKERS_PACK = Isaac.GetItemIdByName("Spelunker's Pack")

local SfxManager = SFXManager()

--util functions
local function RandomFloatRange(greater)
    local lower = 0
    return lower + math.random()  * (greater - lower);
end

local function tableContains(table_, value, removeValue)
    removeValue = removeValue or false
    local i = 1
    local contains = false
    local index = -1

    if #table_ > 0 then
        repeat if (table_[i] == value) then contains = true end i = i + 1 until(i == #table_+1)
        i = 1
        repeat if (table_[i] == value) then index = i end i = i + 1 until(i == #table_+1)
    end

    if removeValue and #table_ > 0 and index >= 0 then
        table.remove(table_, index)
    end

    return contains
end

local function findGridEntityResponse(position)
    local room = Game():GetRoom()
    local bestTask
    local floor = Game():GetLevel():GetStage()
    local floortype = Game():GetLevel():GetStageType()
    for i=1, room:GetGridSize() do
        local ge = room:GetGridEntity(i)
        if ge and ge.State ~= 2 then
            local t
            local geType = ge.Desc.Type
            if geType == GridEntityType.GRID_ROCKT or
                geType == GridEntityType.GRID_ROCK_SS or
                geType == GridEntityType.GRID_ROCK then
                t = {
                    blurb = "ROCK IS YOU",
                    position = ge.Position,
                    active = CollectibleType.COLLECTIBLE_MOMS_BRACELET,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }
            elseif geType == GridEntityType.GRID_PRESSURE_PLATE then
                t = {
                    blurb = "BUTTON IS YOU",
                    position = ge.Position,
                    active = CollectibleType.COLLECTIBLE_TELEPORT,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }
            elseif geType == GridEntityType.GRID_STATUE and ge.Desc.Variant == 1 or (geType == GridEntityType.GRID_POOP and ge.Desc.Variant == 6) then -- Angel
                t = {
                    blurb = "ANGEL IS YOU",
                    position = ge.Position,
                    active = CollectibleType.COLLECTIBLE_CRACK_THE_SKY,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }
            elseif geType == GridEntityType.GRID_STATUE and ge.Desc.Variant == 0 then -- Devil
                t = {
                    blurb = "DEVIL IS YOU",
                    position = ge.Position,
                    active = CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }
            elseif geType == GridEntityType.GRID_ROCK_GOLD or (geType == GridEntityType.GRID_POOP and ge.Desc.Variant == 3) then 
                t = {
                    blurb = "GOLD IS YOU",
                    position = ge.Position,
                    active = CollectibleType.COLLECTIBLE_WOODEN_NICKEL,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }
            elseif geType == GridEntityType.GRID_POOP and (ge.Desc.Variant == 2 or ge.Desc.Variant == 0 or ge.Desc.Variant == 1 or ge.Desc.Variant == 5 or ge.Desc.Variant == 4) then
                t = {
                    blurb = "POOP IS YOU",
                    position = ge.Position,
                    active = CollectibleType.COLLECTIBLE_POOP,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }
            elseif geType == GridEntityType.GRID_SPIDERWEB then 
                t = {
                    blurb = "WEB IS YOU",
                    position = ge.Position,
                    active = CollectibleType.COLLECTIBLE_SPIDER_BUTT,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }
            elseif geType == GridEntityType.GRID_TELEPORTER then
                t = {
                    blurb = "TELE IS YOU",
                    position = ge.Position,
                    active = CollectibleType.COLLECTIBLE_TELEKINESIS,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }
            elseif geType == GridEntityType.GRID_SPIKES or geType == GridEntityType.GRID_ROCK_SPIKED or geType == GridEntityType.GRID_SPIKES_ONOFF then
                t = {
                    blurb = "SPIKE IS YOU",
                    position = ge.Position,
                    active = CollectibleType.COLLECTIBLE_DULL_RAZOR,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }
            elseif geType == GridEntityType.GRID_ROCK_BOMB or geType == GridEntityType.GRID_TNT then
                t = {
                    blurb = "BOOM IS YOU",
                    position = ge.Position,
                    active = CollectibleType.COLLECTIBLE_MINE_CRAFTER,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }
            elseif geType == GridEntityType.GRID_LOCK then
                t = {
                    blurb = "LOCK IS YOU",
                    position = ge.Position,
                    active = CollectibleType.COLLECTIBLE_DADS_KEY,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }
            elseif geType == GridEntityType.GRID_ROCKB or geType == GridEntityType.GRID_PILLAR then
                t = {
                    blurb = "BLOCK IS YOU",
                    position = ge.Position,
                    active = CollectibleType.COLLECTIBLE_UNICORN_STUMP,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }
            elseif geType == GridEntityType.GRID_ROCK_ALT then
                local altToUse = nil
                local activeToUse = nil
                if room:GetType() == RoomType.ROOM_SECRET then
                    altToUse = "SHROOM"
                    activeToUse = CollectibleType.COLLECTIBLE_WAVY_CAP
                elseif room:GetType() == RoomType.ROOM_ARCADE or room:GetType() == RoomType.ROOM_SHOP or room:GetType() == RoomType.ROOM_ANGEL then
                    altToUse = "POT"
                    activeToUse = CollectibleType.COLLECTIBLE_WOODEN_NICKEL
                elseif room:GetType() == RoomType.ROOM_DEVIL or room:GetType() == RoomType.ROOM_SACRIFICE then
                    altToUse = "SKULL"
                    activeToUse = CollectibleType.COLLECTIBLE_GUPPYS_HEAD
                elseif Game():IsGreedMode() then
                    if floor == 2 then
                        altToUse = "SHROOM"
                        activeToUse = CollectibleType.COLLECTIBLE_WAVY_CAP
                    elseif floor == 1 or floor == 6 then
                        altToUse = "POT"
                        activeToUse = CollectibleType.COLLECTIBLE_WOODEN_NICKEL
                    elseif floor == 4 then
                        altToUse = "POLYP"
                        activeToUse = CollectibleType.COLLECTIBLE_TAMMYS_HEAD
                    else
                        altToUse = "SKULL"
                        activeToUse = CollectibleType.COLLECTIBLE_GUPPYS_HEAD
                    end
                elseif not Game():IsGreedMode() then
                    if floor == 3 or floor == 4 then
                        altToUse = "SHROOM"
                        activeToUse = CollectibleType.COLLECTIBLE_WAVY_CAP
                    elseif ((floor == 1 or floor == 2) and
                    floortype ~= StageType.STAGETYPE_REPENTANCE and floortype ~= StageType.STAGETYPE_REPENTANCE_B)
                    or (floor == 10 and floortype == StageType.STAGETYPE_WOTL) then
                        altToUse = "POT"
                        activeToUse = CollectibleType.COLLECTIBLE_WOODEN_NICKEL
                    elseif (floor == 1 or floor == 2) and
                    (floortype == StageType.STAGETYPE_REPENTANCE or floortype == StageType.STAGETYPE_REPENTANCE_B) then
                        altToUse = "BUCKET"
                        activeToUse = CollectibleType.COLLECTIBLE_ISAACS_TEARS
                    elseif floor == 7 or floor == 8 or floor == 9 then
                        altToUse = "POLYP"
                        activeToUse = CollectibleType.COLLECTIBLE_TAMMYS_HEAD
                    elseif floor == 12 then
                        altToUse = "CONFUSED"
                        activeToUse = CollectibleType.COLLECTIBLE_METRONOME
                    else
                        altToUse = "SKULL"
                        activeToUse = CollectibleType.COLLECTIBLE_GUPPYS_HEAD
                    end
                end
                t = {
                    blurb = altToUse .. " IS YOU",
                    position = ge.Position,
                    active = activeToUse,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }
            elseif geType == GridEntityType.GRID_ROCK_ALT2 then
                t = {
                    blurb = "SKULL IS YOU",
                    position = ge.Position,
                    active = CollectibleType.COLLECTIBLE_GUPPYS_HEAD,
                    typevar = tostring(geType) .. "~~" .. tostring(ge.Desc.Variant)
                }

            else
                t = nil
            end
            if t then
                t.distance = math.abs((position - t.position):LengthSquared())
                if (not bestTask) or t.distance < bestTask.distance then
                    bestTask = t
                end
            end
        end
    end
    local entities = Isaac.GetRoomEntities()
    local t
    for i=1, #entities do
        local entity = entities[i]
        if entity.Type == EntityType.ENTITY_FIREPLACE then
             t = {
                blurb = "FIRE IS YOU",
                position = entity.Position,
                active = CollectibleType.COLLECTIBLE_RED_CANDLE,
                typevar = tostring(entity.Type) .. "~~" .. tostring(entity.Variant)
            }
        end
        if t then
            t.distance = math.abs((position - t.position):LengthSquared())
            if (not bestTask) or t.distance < bestTask.distance then
                bestTask = t
            end
        end
    end

    if bestTask and bestTask.distance <= 2500 then
        hud:ShowItemText(bestTask.blurb, "", false)
        baba_active = bestTask.active
        SfxManager:Play(SoundEffect.SOUND_THUMBSUP, 2)
    else
        SfxManager:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ, 2)
    end
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

--if this ever makes it to workshop credit to catinsurance, holy shit
local ChampionsToLoot = {
        [ChampionColor.RED] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.YELLOW] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 0, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.GREEN] = function (ref, rng)
            ---@type EntityNPC
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, PillColor.PILL_NULL, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.ORANGE] = function (ref, rng)
            local npc = ref.Entity
            for _ = 0, 1 do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, npc.Position, Vector(0, 0), npc)
            end
        end,
        [ChampionColor.BLUE] = function (ref, rng, playerRef)
            local npc = ref.Entity
            ---@type EntityPlayer
            local player = playerRef.Entity:ToPlayer() 
            player:AddBlueFlies(3, player.Position, player)
        end,
        [ChampionColor.BLACK] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Explode(npc.Position, npc, 100)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 0, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.WHITE] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.GREY] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 0, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.TRANSPARENT] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, ChestSubType.CHEST_CLOSED, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.FLICKER] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_REDCHEST, ChestSubType.CHEST_CLOSED, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.PINK] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Game():GetItemPool():GetCard(rng:GetSeed(), true, false, false), npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.PURPLE] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.DARK_RED] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.LIGHT_BLUE] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.CAMO] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Game():GetItemPool():GetCard(rng:GetSeed(), false, true, true), npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.PULSE_GREEN] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.PULSE_GREY] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.FLY_PROTECTED] = function (ref, rng, playerRef)
            local npc = ref.Entity
            ---@type EntityPlayer
            local player = playerRef.Entity:ToPlayer()
            for i = 0, 2 do
                player:AddBlueSpider(player.Position)
            end
        end,
        [ChampionColor.TINY] = function (ref, rng)
            local npc = ref.Entity
            local pool = Game():GetItemPool()
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, pool:ForceAddPillEffect(PillEffect.PILLEFFECT_SMALLER), npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.GIANT] = function (ref, rng)
            local npc = ref.Entity
            local pool = Game():GetItemPool()
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, pool:ForceAddPillEffect(PillEffect.PILLEFFECT_LARGER), npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.PULSE_RED] = function (ref, rng)
            local npc = ref.Entity
            Game():SpawnParticles(npc.Position, EffectVariant.PLAYER_CREEP_RED, 10, 0, Color(1, 0, 0, 1, 0, 0, 0), 0)
        end,
        [ChampionColor.SIZE_PULSE] = function (ref, rng, playerRef)
            local npc = ref.Entity
            local player = playerRef.Entity:ToPlayer()
            for i = 0, 1 do
                Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, LocustSubtypes.LOCUST_OF_WRATH, player.Position, Vector(0, 0), player)
            end
        end,
        [ChampionColor.KING] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DIME, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.DEATH] = function (ref, rng)
            local npc = ref.Entity
           Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.BROWN] = function (ref, rng)
            local npc = ref.Entity
            Game():Fart(npc.Position)
        end,
        [ChampionColor.RAINBOW] = function (ref, rng)
            local npc = ref.Entity
            local game = Game()
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE, npc.Position, Vector(0, 0), npc)
        end
    }


 --callbacks

 function WarpZone:OnUpdate()
	local room = game:GetRoom()
	local player = Isaac.GetPlayer(0)

	if player:HasCollectible(CollectibleType.COLLECTIBLE_SPELUNKERS_PACK) == true then
		local entities = Isaac.GetRoomEntities()

		for i=1,#entities do
			--Normal bombs
			if entities[i].Type == EntityType.ENTITY_BOMBDROP and entities[i].SpawnerType == EntityType.ENTITY_PLAYER then
				local sprite = entities[i]:GetSprite()
				--If First frame
				if entities[i].FrameCount  == 1 then
					sprite:Load("gfx/bridgebomb.anm2",false)
					sprite:LoadGraphics()
				end

				--If exploding
				if sprite:IsPlaying("Explode") then
					WarpZone:TriggerEffect(entities[i].Position)
				end
			end
		end

	end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_UPDATE, WarpZone.OnUpdate)

function WarpZone:TriggerEffect(position)
    local room = Game():GetRoom()
    local numBridged = 0
	for i=1, room:GetGridSize() do
        local ge = room:GetGridEntity(i)
        if ge and ge.Desc.Type == GridEntityType.GRID_PIT then
            local distance = math.abs((position - ge.Position):LengthSquared())
            if distance <= 10000 then
                ge:ToPit():MakeBridge(ge)
                numBridged  = numBridged + 1
            end
        elseif ge and (ge.Desc.Type == GridEntityType.GRID_ROCKT or ge.Desc.Type == GridEntityType.GRID_ROCKSS or ge.Desc.Type == GridEntityType.GRID_ROCK_GOLD) then
            room:DestroyGrid(ge:GetGridIndex(), true)
            numBridged = numBridged + 1
        elseif ge and ge.Desc.Type == GridEntityType.GRID_ROCK_BOMB then
            ge:SetType(GridEntityType.GRID_ROCK)
            room:DestroyGrid(ge:GetGridIndex(), true)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 0, ge.Position, Vector(0, 0), nil)
            numBridged = numBridged + 1
        end
    end
    if numBridged > 0 then
        SfxManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
    end
end

 function WarpZone:postRender()
	local player = Isaac.GetPlayer(0)
	local actions = player:GetLastActionTriggers()
	if actions & ActionTriggers.ACTIONTRIGGER_ITEMACTIVATED > 0 then
		timeSinceTheSpacebarWasLastPressed = 0
	else
		timeSinceTheSpacebarWasLastPressed = timeSinceTheSpacebarWasLastPressed + 1
	end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_RENDER, WarpZone.postRender)


function WarpZone:EnemyHit(entity, amount, damageflags, source, countdownframes)
    if entity:IsVulnerableEnemy() then
        local player_ =  Isaac.GetPlayer(0)
        local source_entity = source.Entity

        if source_entity and source_entity:GetData() and source_entity:GetData().FocusIndicator == nil and
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

    if player:HasCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK) then
        roomsClearedSinceTake = roomsClearedSinceTake + 1
        local roomsToSuck = math.max(10 - (2 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK)), 1)
        if roomsClearedSinceTake % roomsToSuck == 0 then
            local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK)
            local shift = 0
            for j, item_tag in ipairs(itemsTaken) do
                if player:HasCollectible(item_tag) == false then
                    table.remove(itemsTaken, j-shift)
                    table.remove(poolsTaken, j-shift)
                    shift = shift + 1
                end
            end
            
            local pos_to_delete = rng:RandomInt(#itemsTaken) + 1
            local config = Isaac.GetItemConfig():GetCollectible(itemsTaken[pos_to_delete])
            if (itemsTaken[pos_to_delete] == CollectibleType.COLLECTIBLE_NIGHTMARE_TICK or (config.Tags & ItemConfig.TAG_QUEST == ItemConfig.TAG_QUEST)) and #itemsTaken > 1 then
                pos_to_delete = (pos_to_delete % #itemsTaken) + 1
            end
            
            config = Isaac.GetItemConfig():GetCollectible(itemsTaken[pos_to_delete])
            if itemsTaken[pos_to_delete] ~= CollectibleType.COLLECTIBLE_NIGHTMARE_TICK and (config.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST) then
                local item_del = table.remove(itemsTaken, pos_to_delete)
                table.remove(poolsTaken, pos_to_delete)
                player:RemoveCollectible(item_del)
                itemsSucked = itemsSucked + 1
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
                SfxManager:Play(SoundEffect.SOUND_THUMBS_DOWN)
                SfxManager:Play(SoundEffect.SOUND_BOSS_BUG_HISS)
            end
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
        DoorwayFloor = saveData[4]
        roomsClearedSinceTake = saveData[5]
        itemsSucked = saveData[6]
    end

    if not isSave then
        itemsTaken = {}
        poolsTaken = {}
        saveData = {}
        totalFocusDamage = 0
        DoorwayFloor = -1
        roomsClearedSinceTake = -1
        itemsSucked = 0
    end

end
WarpZone:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, WarpZone.OnGameStart)


function WarpZone:preGameExit()
    saveData[1] = itemsTaken
    saveData[2] = poolsTaken
    saveData[3] = totalFocusDamage
    saveData[4] = DoorwayFloor
    saveData[5] = roomsClearedSinceTake
    saveData[6] = itemsSucked
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
    if Game():GetLevel():GetStage() == DoorwayFloor and (Game():GetLevel():GetCurrentRoomIndex() ~=84 or Game():GetLevel():GetStage()~= 1 or not room:IsFirstVisit()) then
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

    if player:HasCollectible(CollectibleType.COLLECTIBLE_STRANGE_MARBLE) then
        local marbleRNG = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_STRANGE_MARBLE)
        for i = 0, room:GetGridSize() do
            local gridIndexPosition = room:GetGridPosition(i)
            if room:IsPositionInRoom(gridIndexPosition , 1) then
                local gridEntity = room:GetGridEntity(i)
                if gridEntity == nil or gridEntity:ToRock() == nil or marbleRNG:RandomInt(10) ~= 1 then
                    goto continue
                end
                local sprite = gridEntity:ToRock():GetSprite()
                sprite.Color = Color(marbleRNG:RandomFloat(), marbleRNG:RandomFloat(), marbleRNG:RandomFloat(), .75)
            end
            ::continue::
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
                    local success = currentLevel:MakeRedRoomDoor(newindex-2, DoorSlot.RIGHT0)
                    currentLevel:MakeRedRoomDoor(newindex-1, DoorSlot.RIGHT0)
                    if success then
                        unlocked = true
                        for j = x, 12, 1 do
                            currentLevel:MakeRedRoomDoor((y*13) + j, DoorSlot.RIGHT0)
                        end
                    end
                end
            end
            if x < 11 and not unlocked then
                local test_room = currentLevel:GetRoomByIdx(newindex+2, 0)
                if test_room.Data ~= nil then
                    local success = currentLevel:MakeRedRoomDoor(newindex+2, DoorSlot.LEFT0)
                    currentLevel:MakeRedRoomDoor(newindex+1, DoorSlot.LEFT0)
                    if success then
                        unlocked = true
                        for j = x, 0, -1 do
                            currentLevel:MakeRedRoomDoor((y*13) + j, DoorSlot.LEFT0)
                        end
                    end
                end
            end
            if y > 1 and not unlocked then
                local test_room = currentLevel:GetRoomByIdx(newindex-26, 0)
                if test_room.Data ~= nil then
                    local success = currentLevel:MakeRedRoomDoor(newindex-26, DoorSlot.DOWN0)
                    currentLevel:MakeRedRoomDoor(newindex-13, DoorSlot.DOWN0)
                    if success then
                        unlocked = true
                        for j = y, 12, 1 do
                            currentLevel:MakeRedRoomDoor(x + (13 * j), DoorSlot.DOWN0)
                        end
                    end
                end
            end
            if y < 11 and not unlocked then
                local test_room = currentLevel:GetRoomByIdx(newindex+26, 0)
                if test_room.Data ~= nil then
                    local success = currentLevel:MakeRedRoomDoor(newindex+26, DoorSlot.UP0)
                    currentLevel:MakeRedRoomDoor(newindex+13, DoorSlot.UP0)
                    if success then
                        unlocked = true
                        for j = y, 0, -1 do
                            currentLevel:MakeRedRoomDoor(x + (13 * j), DoorSlot.UP0)
                        end
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

function WarpZone:UseIsYou(collectible, rng, entityplayer, useflags, activeslot, customvardata)
    if baba_active == nil then
        reticle = Isaac.Spawn(1000, 30, 0, entityplayer.Position, Vector(0, 0), entityplayer)
        blinkTime = 10
        entityplayer:AnimateCollectible(CollectibleType.COLLECTIBLE_IS_YOU, "LiftItem", "PlayerPickupSparkle")
        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false
        }
    else
        entityplayer:UseActiveItem(baba_active)

        baba_active = nil
        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.UseIsYou, CollectibleType.COLLECTIBLE_IS_YOU)



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

        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK) then
            entityplayer.Damage = entityplayer.Damage + (itemsSucked * 0.75)
        end
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
    if tear:GetData() then 
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
        if Game():GetLevel():GetStage() == DoorwayFloor and (Game():GetLevel():GetCurrentRoomIndex() ~=84 or Game():GetLevel():GetStage()~= 1) then
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
        if player:HasCollectible(CollectibleType.COLLECTIBLE_IS_YOU) and reticle ~= nil then
            local aimDir = player:GetAimDirection()
            reticle.Velocity = aimDir * 20

            if reticle.FrameCount % blinkTime < blinkTime/2 then
                reticle.Color = Color(0, 0, 0, 0.5, -230, 100, 215)
            else
                reticle.Color = Color(0, 0, 0, 0.8, -200, 150, 255)
            end

                local stop = false
                if (reticle.FrameCount > 5 and timeSinceTheSpacebarWasLastPressed < 4) or reticle.FrameCount > 75 then
                    findGridEntityResponse(reticle.Position)
                    reticle:Remove()
                    reticle = nil
                    stop = true
                else
                    -- Prevent the player from shooting
                    player.FireDelay = 1

                    -- Make the target blink faster
                    if reticle.FrameCount > 70 then
                        blinkTime = 2
                    elseif reticle.FrameCount > 65 then
                        blinkTime = 4
                    elseif reticle.FrameCount > 55 then
                        blinkTime = 6
                    elseif reticle.FrameCount > 40 then
                        blinkTime = 8
                    end
                end
                if stop then --and ai.player:GetSprite():IsPlaying("LiftItem")
                    player:AnimateCollectible(CollectibleType.COLLECTIBLE_IS_YOU, "HideItem", "Empty")
                end
        end
    end

WarpZone:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, WarpZone.OnFrame)

function WarpZone:OnEntitySpawn(npc)
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_STRANGE_MARBLE) then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_STRANGE_MARBLE)
        if not npc:IsChampion() and not npc:IsBoss() and rng:RandomInt(8) == 1 then
            npc:MakeChampion(rng:GetSeed())
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_NPC_INIT, WarpZone.OnEntitySpawn)


function WarpZone:OnEntityDeath(npc)
    local player = Isaac.GetPlayer(0)
    if npc:IsEnemy() and npc:IsChampion() and player:HasCollectible(CollectibleType.COLLECTIBLE_STRANGE_MARBLE) then
        local championColor = npc:GetChampionColorIdx()
        print(championColor)
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_STRANGE_MARBLE)
        ChampionsToLoot[championColor](EntityRef(npc), rng, EntityRef(player))
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, WarpZone.OnEntityDeath)
