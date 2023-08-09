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
local tickColor = Color(.2, .05, .05, 1, 0, 0, 0)

--diogenes
local dioDamageOn = false

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
CollectibleType.COLLECTIBLE_DIOGENES_POT = Isaac.GetItemIdByName("Diogenes's Pot")
CollectibleType.COLLECTIBLE_DIOGENES_POT_LIVE = Isaac.GetItemIdByName(" Diogenes's Pot ")


--external item descriptions
if EID then
	EID:addCollectible(CollectibleType.COLLECTIBLE_GOLDENIDOL, "#The player has a 50% chance of receiving a fading nickel when a room is cleared.#Damage causes the player to lose half their money, dropping some of it on the ground as fading coins.#When the player is holding money, damage is always 1 full heart.", "Golden Idol", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_PASTKILLER, "#Removes the first 3 items from your inventory, including quest items like the Key Pieces.#3 sets of 3 choice pedestals appear.#The new items are from the same pools as the ones you lost.", "Gun that can Kill the Past", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_BIRTHDAY_CAKE, "#+1 HP#A random consumable and pickups of each type now spawn at the start of a floor.#When the player holds Binge Eater, -.03 Speed and +.5 Tears.", "Birthday Cake", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_RUSTY_SPOON, "#10% chance to fire a homing tear that inflicts bleed#100% chance at 18 Luck", "Rusty Spoon", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_NEWGROUNDS_TANK, "#.3 Speed Down#.27 Tears Up#.5 Damage Up#.04 Range Up#.16 Shot Speed Up#1 Luck Up#On taking a hit, the player has a 10% chance to shield from damage.", "Newgrounds Tank", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_GREED_BUTT, "#When hit by an enemy or projectile from behind, you fart, launching a coin out of your butt.#There is a 4% chance that you drop a gold poop instead.", "Greed Butt", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS, "#When below full red hearts, heal 1 red heart.#When at full health, launch a large piercing tear.#This item only gains charge by inflicting damage.", "Focus", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS_2, "#When below full red hearts, heal 1 red heart.#When at full health, launch a large piercing tear.#This item only gains charge by inflicting damage.", "Focus", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS_3, "#When below full red hearts, heal 1 red heart.#When at full health, launch a large piercing tear.#This item only gains charge by inflicting damage.", "Focus", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS_4, "#When below full red hearts, heal 1 red heart.#When at full health, launch a large piercing tear.#This item only gains charge by inflicting damage.", "Focus", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_DOORWAY, "#All doors are opened, and stay open for the rest of the floor.#Secret rooms, Angel/Devil rooms, The Mega Satan door, Boss Rush and Hush are included.#Challenge Rooms are open to enter, however the door closes when activating the challenge.#The Ultra Secret Room is unlocked, and red rooms are now open to the edge of the map, revealing the error room.", "The Doorway", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_STRANGE_MARBLE, "#All enemies have a 1 in 8 chance to become champions.#Champions always drop loot, and often have a chance to drop extra.", "Strange Marble", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_IS_YOU, "#Point the reticle at an obstacle to use an active item effect that corresponds to it.#For example, pointing it at a normal rock lets you use Mom's Bracelet", "Is You",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK, "#Every 8 room clears, one passive item is removed from your inventory.#.75 Damage Up for each item removed this way", "Nightmare Tick",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_SPELUNKERS_PACK, "#+12 bombs#Pits within your bombs' blast radius are filled in.#When your bomb explodes, the resonant force breaks tinted and super secret rocks throughout the room. #Bomb rocks in the room will break apart, dropping a bomb pickup.", "Spelunker's Pack",  "en_us")
    
    EID:addCollectible(CollectibleType.COLLECTIBLE_GOLDENIDOL, "#Зачистка комнаты имеет 50% шанс оставить никель, пропадающий через 2 секунды.#При получении урона игрок теряет половину своих монет, и бросает на пол эти монеты (они пропадают через 1 секунду).#Если у игрока есть монеты, урон будет в полное сердце.", "Золотой Идол", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_PASTKILLER, "#Удаляет первые три предмета,полученных в забеге (Может удалить сюжетные предметы).#Создает по три пьедестала с предметами из того же пула за каждый потерянный предмет, из 3х предметов можно взять только 1.#The new items are from the same pools as the ones you lost.", "Пушка, Убивающая Прошлое", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_BIRTHDAY_CAKE, "#+1 Контейнер Сердца #Случайная карта/пилюля/руна, случайная монета, бомба и ключ появляются в начале каждого этажа.#Предмет еды, С Кутежником дает -.03 скорости и +.5 скорострельности.", "Именинный Торт", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_RUSTY_SPOON, "#10% шанс выстрелить самонаводящейся слезой, накладывающей кровотечение#100% шанс при 18 удачи", "Ржавая Ложка", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_NEWGROUNDS_TANK, "#-.3 Скорости#+.27 Скорострельности#+.5 Урона#+.04 Дальности#+.16 Скорости слезы#+1 Удачи#При получении урона, 10% шанс предотвратить его.", "Танк Newgrounds", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_GREED_BUTT, "#При получении урона в зад, персонаж пукает и выпускает монетку.#4% шанс создать золотую кучку вместо пука с монетой.", "Алчная Жопа!", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS, "#Если у вас не полное здоровье, вылечи 1 красное сердце.#При полном здоровье, выпусти большую слезу, наносящую большой урон, проходящую сквозь врагов.#Этот предмет заряжается нанесением урона.", "Фокус", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS_2, "#Если у вас не полное здоровье, вылечи 1 красное сердце.#При полном здоровье, выпусти большую слезу, наносящую большой урон, проходящую сквозь врагов.#Этот предмет заряжается нанесением урона", "Фокус", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS_3, "#Если у вас не полное здоровье, вылечи 1 красное сердце.#При полном здоровье, выпусти большую слезу, наносящую большой урон, проходящую сквозь врагов.#Этот предмет заряжается нанесением урона", "Фокус", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS_4, "#Если у вас не полное здоровье, вылечи 1 красное сердце.#При полном здоровье, выпусти большую слезу, наносящую большой урон, проходящую сквозь врагов.#Этот предмет заряжается нанесением урона", "Фокус", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_DOORWAY, "#Все двери открываются, и остаются открытыми до конца этажа.#Открываются Секретные комнаты, комнаты Ангела/Дьявола, Дверь Мега Сатаны, Двери Испытания Боссов и Молчания (Если они на этом этаже).#Комнаты испытания открыты, но дверь закрывается на время прохождения испытания.#Открывает Ультра Секретную комнату и проход к ней, так же открывает проход к комнате Ошибки, открывая красные комнаты через Ультра секретную комнату до края карты.", "Проход", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_STRANGE_MARBLE, "#Все враги с 10% шансом могут стать чемпионами.#Чемпионы всегда оставляют награду, и могут оставить дополнительную.", "Странный Марбл", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_IS_YOU, "#Создает крестик под персонажем, который надо направлять на препятствия (Камни, Блоки и т.д.).#После этого, нужно еще раз активировать предмет для срабатывания эффекта. У каждого обьекта свой эффект.", "Это Ты",  "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK, "#Каждые 8 зачисток комнат, Один предмет пропадает из инвентаря.#+.75 Урона за пропавший предмет", "Кошмарный Клещ",  "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_SPELUNKERS_PACK, "#+12 бомб#Все ямы в радиусе взрыва заполняются.#При взрыве бомбы, Все меченые и двойные меченые камни взорвутся не смотря на то что они вне радиуса взрыва. #Камни с бомбами сломаются и оставят бомбу на их месте.", "Рюкзак Спелеолога",  "ru")

end


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


function WarpZone:GetPtrHashEntity(entity)
    if entity then
        if entity.Entity then
            entity = entity.Entity
        end
        for _, matchEntity in pairs(Isaac.FindByType(entity.Type, entity.Variant, entity.SubType, false, false)) do
            if GetPtrHash(entity) == GetPtrHash(matchEntity) then
                return matchEntity
            end
        end
    end
    return nil
end

function WarpZone:GetPlayerFromTear(tear)
    for i=1, 2 do
        local check = nil
        if i == 1 then
            check = tear.Parent
        elseif i == 2 then
            check = tear.SpawnerEntity
        end
        if check then
            if check.Type == EntityType.ENTITY_PLAYER then
                return WarpZone:GetPtrHashEntity(check):ToPlayer()
            elseif check.Type == EntityType.ENTITY_FAMILIAR and (check.Variant == FamiliarVariant.INCUBUS or check.Variant == FamiliarVariant.TWISTED_BABY) then
                local data = tear:GetData()
                data.IsIncubusTear = true
                return check:ToFamiliar().Player:ToPlayer()
            end
        end
    end
    return nil
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

    if player:HasCollectible(CollectibleType.COLLECTIBLE_RUSTY_SPOON) == true or player:HasCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK) == true  then
        
        local lasers = Isaac.FindByType(EntityType.ENTITY_LASER)
        for _, laser in ipairs(lasers) do
            local data = laser:GetData()
            if data.Laser_Rusty == true then
                data.Laser_Rusty = false
                laser.Color = rustColor
            elseif player:HasCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK) == true then
                laser.Color = tickColor
            end
        end
        
        local laserEndpoints = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.LASER_IMPACT)
        for _, laserEndpoint in ipairs(laserEndpoints) do
            local data = laserEndpoint:GetData()
            if data.Laser_Rusty == true then
                data.Laser_Rusty = false
                laserEndpoint.Color = rustColor
            elseif player:HasCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK) == true then
                laserEndpoint.Color = tickColor
            end
        end
        
        local brimballs = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BRIMSTONE_BALL)
        for _, brimball in ipairs(brimballs) do
            local data = brimball:GetData()
            if data.Laser_Rusty == true then
                data.Laser_Rusty = false
                brimball.Color = rustColor
            elseif player:HasCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK) == true then
                brimball.Color = tickColor
            end
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_UPDATE, WarpZone.OnUpdate)

function WarpZone:TriggerEffect(position)
    local room = Game():GetRoom()
    local numBridged = 0
    local resonate = false
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
            resonate = true
        elseif ge and ge.Desc.Type == GridEntityType.GRID_ROCK_BOMB then
            ge:SetType(GridEntityType.GRID_ROCK)
            room:DestroyGrid(ge:GetGridIndex(), true)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 0, ge.Position, Vector(0, 0), nil)
            resonate = true
            numBridged = numBridged + 1
        end
    end
    if numBridged > 0 then
        SfxManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
    end
    if resonate then
        Game():ShakeScreen(2)
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

    if player:HasCollectible(CollectibleType.COLLECTIBLE_DIOGENES_POT_LIVE) and damageflags & DamageFlag.DAMAGE_NO_PENALTIES ~= DamageFlag.DAMAGE_NO_PENALTIES then
        player:UseCard(Card.CARD_FOOL, 257)
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
        coin:GetSprite():SetFrame(1)
        if room then
            local coin2 = Isaac.Spawn(EntityType.ENTITY_PICKUP, 
                     PickupVariant.PICKUP_COIN,
                     CoinSubType.COIN_NICKEL,
                     Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()),
                     Vector(0,0),
                    nil)
            coin2.Timeout = 90
            coin:GetSprite():SetFrame(1)
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
                player:AnimateSad()
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
    
    dioDamageOn = false
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    player:EvaluateItems()

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
    
    if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then
        cakeBingeBonus = entityplayer:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHDAY_CAKE)
    end

    if Cache == CacheFlag.CACHE_FIREDELAY then
        local maxFireDelay = math.min(5, entityplayer.MaxFireDelay)

        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_NEWGROUNDS_TANK) then
            entityplayer.MaxFireDelay = entityplayer.MaxFireDelay - tank_qty
        end
        entityplayer.MaxFireDelay = entityplayer.MaxFireDelay - (cakeBingeBonus * 2)
    end
        
    

    if Cache == CacheFlag.CACHE_DAMAGE then
        entityplayer.Damage = entityplayer.Damage + (0.5 * tank_qty)

        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK) then
            entityplayer.Damage = entityplayer.Damage + (itemsSucked * 0.75)
        end

        if dioDamageOn == true then
            entityplayer.Damage = entityplayer.Damage * 1.5
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
        entityplayer.MoveSpeed = entityplayer.MoveSpeed - (cakeBingeBonus * .03)
    end

    if Cache == CacheFlag.CACHE_SHOTSPEED then
        entityplayer.ShotSpeed = entityplayer.ShotSpeed + (tank_qty * .16)
    end



end
WarpZone:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, WarpZone.EvaluateCache)


function WarpZone:checkTear(entitytear)
    local tear = entitytear:ToTear()
    local player = WarpZone:GetPlayerFromTear(entitytear)
    if player and player:HasCollectible(CollectibleType.COLLECTIBLE_RUSTY_SPOON) then
        local chance = player.Luck * 5 + 10
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_RUSTY_SPOON)
        if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
            chance = chance + 20
        end
        local chance_num = rng:RandomInt(100)
        if chance_num < chance then
            tear:GetData().Is_Rusty = true
            tear:GetData().BleedIt = true
        end
    elseif player and player:HasCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK) then
        tear:GetData().NightmareColor = true
    end
    if player and CollectibleType.COLLECTIBLE_FOCUS == player:GetActiveItem() and primeShot then
        SfxManager:Play(SoundEffect.SOUND_EXPLOSION_WEAK, 3)
        primeShot = false
        tear:GetData().FocusShot = true
        tear:GetData().FocusIndicator = true
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, WarpZone.checkTear)


function WarpZone:checkLaser(entitylaser)
    local laser = entitylaser:ToLaser()
    local player = Isaac.GetPlayer(0)
    local var = laser.Variant
    local subt = laser.SubType
    if player:HasCollectible(CollectibleType.COLLECTIBLE_RUSTY_SPOON) and not ((var == 1 and subt == 3) or var == 5 or var == 12) then
        local chance = player.Luck * 5 + 10
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_RUSTY_SPOON)
        if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
            chance = chance + 20
        end
        local chance_num = rng:RandomInt(100)
        if chance_num < chance then
            laser:GetData().Laser_Rusty = true
            player:GetData().LaserBleedIt = true
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_LASER_INIT, WarpZone.checkLaser)


function WarpZone:updateTear(entitytear)
    local tear = entitytear:ToTear()
    if tear:GetData() then
        if tear:GetData().FocusShot == true then
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
        
        if tear:GetData().Is_Rusty == true then
            tear:GetData().Is_Rusty = false
            tear:AddTearFlags(TearFlags.TEAR_HOMING)
            local sprite_tear = tear:GetSprite()
            sprite_tear.Color = rustColor
        elseif tear:GetData().NightmareColor then
            local sprite_tear = tear:GetSprite()
            sprite_tear.Color = tickColor
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


function WarpZone:OnKnifeCollide(knife, collider, low)
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_RUSTY_SPOON) and collider:IsVulnerableEnemy() then
        local chance = player.Luck * 5 + 10
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_RUSTY_SPOON)
        if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
            chance = chance + 20
        end
        local chance_num = rng:RandomInt(100)
        if chance_num < chance then
            collider:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, WarpZone.OnKnifeCollide)


function WarpZone:LaserEnemyHit(entity, amount, damageflags, source, countdownframes)
    if entity:IsVulnerableEnemy() then
        local source_entity = source.Entity
        if source_entity and source_entity:GetData() and source_entity:GetData().LaserBleedIt == true then
            source_entity:GetData().LaserBleedIt = false
            entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, WarpZone.LaserEnemyHit)

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
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_STRANGE_MARBLE)
        ChampionsToLoot[championColor](EntityRef(npc), rng, EntityRef(player))
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, WarpZone.OnEntityDeath)

function WarpZone:UseDiogenes(collectible, rng, entityplayer, useflags, activeslot, customvardata)

    entityplayer:AddCollectible(CollectibleType.COLLECTIBLE_DIOGENES_POT_LIVE, 0, false, activeslot)
    SfxManager:Play(SoundEffect.SOUND_URN_OPEN)
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.UseDiogenes, CollectibleType.COLLECTIBLE_DIOGENES_POT)



function WarpZone:SheathDiogenes(collectible, rng, entityplayer, useflags, activeslot, customvardata)
    entityplayer:AddCollectible(CollectibleType.COLLECTIBLE_DIOGENES_POT, 0, false, activeslot)
    SfxManager:Play(SoundEffect.SOUND_URN_CLOSE)

end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.SheathDiogenes, CollectibleType.COLLECTIBLE_DIOGENES_POT_LIVE)

local function runUpdates(tab) --This is from Fiend Folio
    for i = #tab, 1, -1 do
        local f = tab[i]
        f.Delay = f.Delay - 1
        if f.Delay <= 0 then
            f.Func()
            table.remove(tab, i)
        end
    end
end

WarpZone.delayedFuncs = {}
function WarpZone:scheduleForUpdate(foo, delay, callback)
    callback = callback or ModCallbacks.MC_POST_UPDATE
    if not WarpZone.delayedFuncs[callback] then
        WarpZone.delayedFuncs[callback] = {}
        WarpZone:AddCallback(callback, function()
            runUpdates(WarpZone.delayedFuncs[callback])
        end)
    end

    table.insert(WarpZone.delayedFuncs[callback], { Func = foo, Delay = delay })
end

function WarpZone:FireClub(player, direction)
	if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK) and player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN and player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN_B then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_NOTCHED_AXE)
		WarpZone:scheduleForUpdate(function()
			player:UseActiveItem(CollectibleType.COLLECTIBLE_NOTCHED_AXE)
		end, 0)
	end
	if direction then
		player:GetData().InputHook = WarpZone.directiontoshootdirection[direction]
	else
		player:GetData().InputHook = -1
	end
	player:SetShootingCooldown(0)
	WarpZone.scanforclub = true
end

WarpZone.directiontoshootdirection = {
	[Direction.LEFT] = ButtonAction.ACTION_SHOOTLEFT,
	[Direction.UP] = ButtonAction.ACTION_SHOOTUP,
	[Direction.RIGHT] = ButtonAction.ACTION_SHOOTRIGHT,
	[Direction.DOWN] = ButtonAction.ACTION_SHOOTDOWN
}

WarpZone:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, action)
	if WarpZone.scanforclub then
		if entity and entity:GetData().InputHook and action == entity:GetData().InputHook and entity:ToPlayer() then
			return true
		end
	end
end, InputHook.IS_ACTION_PRESSED)

WarpZone:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, action)
	if WarpZone.scanforclub then
		if entity and entity:GetData().InputHook and action == entity:GetData().InputHook and entity:ToPlayer() then
			return 2
		end
	end
end, InputHook.GET_ACTION_VALUE)

WarpZone:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, function(_, knife)
	if knife.Variant == 9 then
		if knife.SubType == 4 then
			local player =  Isaac.GetPlayer(0)
			if WarpZone.scanforclub then
				if player:GetData().InputHook and knife.Position:Distance(player.Position) < 20 then
					knife:GetData().CustomClub = true
					player:GetData().GrabbedClub = knife
					WarpZone.scanforclub = false
					player:GetData().InputHook = nil
					knife.Variant = 1 --Setting the variant to 1 (bone club) prevents it from breaking rocks
				end
			elseif player:GetData().GrabbedClub and player:GetData().GrabbedClub:Exists() then
				knife.Variant = 1
			end
		elseif WarpZone.scanforclub then
			knife.Visible = false
		end
	end
end)

WarpZone:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
	local player = WarpZone:GetPlayerFromTear(tear)
    
    if player and player:HasCollectible(CollectibleType.COLLECTIBLE_DIOGENES_POT_LIVE) then
        dioDamageOn = true
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
        tear:Remove()
        WarpZone:FireClub(player, player:GetFireDirection())
    end
end)