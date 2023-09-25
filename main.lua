--basic data
local game = Game()
local WarpZone  = RegisterMod("WarpZone", 1)
local json = require("json")
local myRNG = RNG()
myRNG:SetSeed(Random(), 1)
local hud = game:GetHUD()
local SfxManager = SFXManager()
----------------------------------
--save data
local saveData = {}
local lastIndex = 5

local defaultData = {}
defaultData.numArrows = 0
defaultData.playerTumors = 0
defaultData.tonyBuff = 1.7
defaultData.dioDamageOn = false
defaultData.roomsClearedSinceTake = -1
defaultData.itemsSucked = 0
defaultData.itemsTaken = {}
defaultData.poolsTaken = {}
defaultData.totalFocusDamage = 0
defaultData.roomsSinceBreak = 0
defaultData.arrowTimeUp = 0
defaultData.arrowTimeDown = 0
defaultData.arrowTimeLeft = 0
defaultData.arrowTimeRight = 0
defaultData.arrowTimeThreeFrames = 0
defaultData.arrowTimeDelay = 0
defaultData.ballCheck = true
defaultData.blinkTime = 10
defaultData.timeSinceTheSpacebarWasLastPressed = 0


local numPlayersG = Game():GetNumPlayers()
for i=0, numPlayersG-1, 1 do
    local player = Isaac.GetPlayer(i)
    for k,v in pairs(defaultData) do
        player:GetData()[k] = v
    end
end

-----------------------------------

--pastkiller
local pickupindex = RNG():RandomInt(10000) + 10000 --this makes it like a 1 in 10,000 chance there's any collision with existing pedestals
local itemPool = game:GetItemPool()


--rusty spoon
local rustColor = Color(.68, .21, .1, 1, 0, 0, 0)

--focus
local FocusChargeMultiplier = 2.5
local whiteColor = Color(1, 1, 1, 1, 0, 0, 0)
whiteColor:SetColorize(1, 1, 1, 1)
whiteColor:SetTint(20, 20, 20, 2)

--doorway
local DoorwayFloor = -1 --saved


--nightmare tick
local tickColor = Color(.2, .05, .05, 1, 0, 0, 0)


--george
local roomKey = {}
roomKey[0] = 2
roomKey[1] = 3
roomKey[2] = 0
roomKey[3] = 1
roomKey[4] = 2
roomKey[5] = 3
roomKey[6] = 0
roomKey[7] = 1

local george_room_type = {
    RoomType.ROOM_PLANETARIUM,
    RoomType.ROOM_SUPERSECRET,
    RoomType.ROOM_ARCADE,
    RoomType.ROOM_CHEST,
    RoomType.ROOM_CURSE,
    RoomType.ROOM_DICE,
    RoomType.ROOM_TREASURE,
    RoomType.ROOM_SACRIFICE,
    RoomType.ROOM_SHOP,
    RoomType.ROOM_ISAACS,
    RoomType.ROOM_BARREN,
    RoomType.ROOM_LIBRARY
}

--possession
local numPossessed = 0 --saved

--lollipop
local Lollipop = {
	VARIANT = Isaac.GetEntityVariantByName("Lollipop"), 
	ORBIT_DISTANCE = Vector(30.0, 30.0),
	ORBIT_CENTER_OFFSET = Vector(0.0, 0.0),
	ORBIT_LAYER = 124,
	ORBIT_SPEED = 0.02,
	CHARM_CHANCE = 7,
	CHARM_DURATION = 450
}

--aubrey
local BegVariant = Isaac.GetEntityVariantByName("Weapon Beggar")
local floorBeggar = -1
local BASE_PAYOUT_CHANCE = 0.065
local STEP_PAYOUT_CHANCE = 0.035
local KEEPER_BONUS = 0.5


--pop pop 
local totalFrameDelay = 200

--football
local effBlank = Isaac.GetEntityVariantByName("Blank_Effect")

--tumors
local SmallTumor = {
	VARIANT = Isaac.GetEntityVariantByName("Tumor_Small"),
	ORBIT_DISTANCE = Vector(30.0, 30.0),
	ORBIT_LAYER = 127,
	ORBIT_SPEED = 0.02,
    ORBIT_CENTER_OFFSET = Vector(0.0, 0.0),
}
local MidTumor = {
	VARIANT = Isaac.GetEntityVariantByName("Tumor_Medium"),
	ORBIT_DISTANCE = Vector(30.0, 30.0),
	ORBIT_LAYER = 127,
	ORBIT_SPEED = 0.02,
    ORBIT_CENTER_OFFSET = Vector(0.0, 0.0),
}
local LargeTumor = {
	VARIANT = Isaac.GetEntityVariantByName("Tumor_Large"),
	ORBIT_DISTANCE = Vector(30.0, 30.0),
	ORBIT_LAYER = 127,
	ORBIT_SPEED = 0.02,
    ORBIT_CENTER_OFFSET = Vector(0.0, 0.0),
}
local tumorVariant = Isaac.GetEntityVariantByName("Tumor_Pickup")

--bible thump
local bibleThumpPool = false

--Bow and Arrow
local ArrowHud = Sprite()
ArrowHud:Load("gfx/bow_hud.anm2", true)
local renderedPosition = Vector(25, -10)
local tokenVariant = Isaac.GetEntityVariantByName("Tear_Token")



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
CollectibleType.COLLECTIBLE_GEORGE = Isaac.GetItemIdByName("George")
CollectibleType.COLLECTIBLE_POSSESSION = Isaac.GetItemIdByName("Possession")
CollectibleType.COLLECTIBLE_LOLLIPOP = Isaac.GetItemIdByName("Lollipop")
CollectibleType.COLLECTIBLE_WATER_FULL = Isaac.GetItemIdByName("Water Bottle")
CollectibleType.COLLECTIBLE_WATER_MID = Isaac.GetItemIdByName(" Water Bottle ")
CollectibleType.COLLECTIBLE_WATER_LOW = Isaac.GetItemIdByName("  Water Bottle  ")
CollectibleType.COLLECTIBLE_WATER_EMPTY = Isaac.GetItemIdByName("   Water Bottle   ")
CollectibleType.COLLECTIBLE_AUBREY = Isaac.GetItemIdByName("Aubrey")
CollectibleType.COLLECTIBLE_TONY = Isaac.GetItemIdByName("Tony")
CollectibleType.COLLECTIBLE_REAL_LEFT = Isaac.GetItemIdByName("The Real Left Hand")
CollectibleType.COLLECTIBLE_HITOPS = Isaac.GetItemIdByName("Hitops")
CollectibleType.COLLECTIBLE_POPPOP = Isaac.GetItemIdByName("Pop Pop")
CollectibleType.COLLECTIBLE_FOOTBALL = Isaac.GetItemIdByName("Football")
CollectibleType.COLLECTIBLE_BALL_OF_TUMORS = Isaac.GetItemIdByName("Ball of Tumors")
CollectibleType.COLLECTIBLE_BOW_AND_ARROW = Isaac.GetItemIdByName("Bow and Arrow")
CollectibleType.COLLECTIBLE_TEST_ACTIVE = Isaac.GetItemIdByName("Test Active")


TrinketType.TRINKET_RING_SNAKE = Isaac.GetTrinketIdByName("Ring of the Snake")
TrinketType.TRINKET_HUNKY_BOYS = Isaac.GetTrinketIdByName("Hunky Boys")
TrinketType.TRINKET_BIBLE_THUMP = Isaac.GetTrinketIdByName("Bible Thump")

Card.CARD_COW_TRASH_FARM = Isaac.GetCardIdByName("CowOnTrash")
Card.CARD_LOOT_CARD = Isaac.GetCardIdByName("LootCard")
Card.CARD_BLANK = Isaac.GetCardIdByName("Blank")
Card.CARD_JESTER_CUBE = Isaac.GetCardIdByName("JesterCube")
Card.CARD_WITCH_CUBE = Isaac.GetCardIdByName("WitchCube")


SoundEffect.SOUND_POP_POP = Isaac.GetSoundIdByName("PopPop_sound")
SoundEffect.SOUND_COW_TRASH = Isaac.GetSoundIdByName("TrashFarm")

--external item descriptions
if EID then
	EID:addCollectible(CollectibleType.COLLECTIBLE_GOLDENIDOL, "#The player has a 50% chance of receiving a fading nickel when a room is cleared#Damage causes the player to lose half their money, dropping some of it on the ground as fading coins.#When the player is holding money, damage is always 1 full heart", "Golden Idol", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_PASTKILLER, "#Removes the first 3 items from your inventory, including quest items like the Key Pieces#3 sets of 3 choice pedestals appear#The new items are from the same pools as the ones you lost", "Gun that can Kill the Past", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_BIRTHDAY_CAKE, "{{ArrowUp}} +1 HP#A random consumable and pickups of each type now spawn at the start of a floor#When the player holds Binge Eater, -.03 Speed and +.5 Tears", "Birthday Cake", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_RUSTY_SPOON, "#10% chance to fire a homing tear that inflicts bleed#100% chance at 18 Luck", "Rusty Spoon", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_NEWGROUNDS_TANK, "{{ArrowDown}} +0.3 Speed Down#{{ArrowUp}} +0.27 Tears Up#{{ArrowUp}} +0.5 Damage Up#{{ArrowUp}} +1 Range Up#{{ArrowUp}} +0.16 Shot Speed Up#{{ArrowUp}} +1 Luck Up#On taking a hit, the player has a 10% chance to shield from damage", "Newgrounds Tank", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_GREED_BUTT, "#When hit by an enemy or projectile from behind, you fart, launching a coin out of your butt#There is a 4% chance that you drop a gold poop instead", "Greed Butt", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS, "#When below full red hearts, heal 1 red heart#When at full health, launch a large piercing tear#This item only gains charge by inflicting damage", "Focus", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS_2, "#When below full red hearts, heal 1 red heart#When at full health, launch a large piercing tear#This item only gains charge by inflicting damage", "Focus", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS_3, "#When below full red hearts, heal 1 red heart#When at full health, launch a large piercing tear#This item only gains charge by inflicting damage", "Focus", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS_4, "#When below full red hearts, heal 1 red heart#When at full health, launch a large piercing tear#This item only gains charge by inflicting damage", "Focus", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_DOORWAY, "#All doors are opened, and stay open for the rest of the floor#Secret rooms, Angel/Devil rooms, The Mega Satan door, Boss Rush and Hush are included#Challenge Rooms are open to enter, however the door closes when activating the challenge#The Ultra Secret Room is unlocked, and red rooms are now open to the edge of the map, revealing the error room", "The Doorway", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_STRANGE_MARBLE, "#All enemies have a 1 in 8 chance to become champions#Champions always drop loot, and often have a chance to drop extra", "Strange Marble", "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_IS_YOU, "#Point the reticle at an obstacle to use an active item effect that corresponds to it#For example, pointing it at a normal rock lets you use Mom's Bracelet", "Is You",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK, "#Every 8 room clears, one passive item is removed from your inventory#.75 Damage Up for each item removed this way", "Nightmare Tick",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_SPELUNKERS_PACK, "#+12 bombs#Pits within your bombs' blast radius are filled in#When your bomb explodes, the resonant force breaks tinted and super secret rocks throughout the room #Bomb rocks in the room will break apart, dropping a bomb pickup", "Spelunker's Pack",  "en_us")

    EID:addTrinket(TrinketType.TRINKET_RING_SNAKE, "#Receive 2 cards at the start of each floor", "Ring of the Snake", "en_us")

    EID:addCollectible(CollectibleType.COLLECTIBLE_DIOGENES_POT, "Toggles a melee hammer strike on and off#When equipped, you receive a 1.5x damage multiplier#Getting hit while equipped teleports you to the starting room", "Diogenes's Pot",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_DIOGENES_POT_LIVE, "Toggles a melee hammer strike on and off#When equipped, you receive a 1.5x damage multiplier#Getting hit while equipped teleports you to the starting room", "Diogenes's Pot",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_GEORGE, "{{ArrowUp}} 2.4 Range Up#When entering most special rooms, a red room will unlock across from you", "George",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_POSSESSION, "Each room, one random non-boss enemy will be permanently charmed#These enemies carry over between rooms#Only 15 enemies can be charmed at a time#Taking damage (excluding sacrifice rooms, etc) removes the charm from all affected enemies, making them hostile again", "Possession",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_LOLLIPOP, "Spawns a lollipop orbital. It does no damage, but it charms enemies on contact", "Lollipop",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_WATER_EMPTY, "I did not hit her#It is bullshit#I did not hit her#I did not", "Water Bottle",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_WATER_LOW, "{{ArrowUp}} 0.22 Tears Up#{{ArrowUp}} Tear Size Up", "Water Bottle",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_WATER_MID, "{{ArrowUp}} 0.37 Tears Up#{{ArrowUp}} Tear Size Up", "Water Bottle",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_WATER_FULL, "{{ArrowUp}} 0.43 Tears Up#{{ArrowUp}} Tear Size Up", "Water Bottle",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_AUBREY, "Once per floor, when entering a shop, a weapon beggar will spawn.#Weapon beggars take coins, and spawn only active items from every pool.#3 active items are spawned from one weapon beggar before it leaves.", "Aubrey",  "en_us")

    EID:addCollectible(CollectibleType.COLLECTIBLE_TONY, "1.7 Damage Multiplier#+1 Damage Up#When any item is taken, the buff and multiplier are both reduced by 0.1#This item's minimum damage multiplier is 1, it cannot decrease damage", "Tony",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_REAL_LEFT, "On use, rerolls all chests in the room into a better counterpart#Chest Order: Mimic -> Haunted -> Grey -> Red -> Golden or Stone -> Wooden or Old -> Eternal -> Mega", "The Real Left Hand",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_HITOPS, "0.2 Speed Up#This speed up can exceed the speed cap", "Hitops",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_POPPOP, "Double tap to fire two 3x damage tears in a burst#Tear rate is reduced for a short time after using this effect.", "Pop Pop",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOOTBALL, "Spawns a football familiar that can be picked up and thrown at enemies#The football deals damage based on its speed", "Football",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_BALL_OF_TUMORS, "Bombs, hearts, keys and batteries have a small chance of turning into collectible tumors#Collecting tumors powers a tumor orbital, which blocks shots and deals contact damage#With enough tumors, a second orbital will spawn", "Ball of Tumors",  "en_us")
    EID:addCollectible(CollectibleType.COLLECTIBLE_BOW_AND_ARROW, "Isaac is able to shoot large, piercing arrow tears that deal 1.5x damage, but have only 3 ammunition#Once the ammo is depleted, Isaac fires normal tears#When a tear lands, it drops a token that will replenish 1 tear when collected", "Bow and Arrow",  "en_us")

    EID:addTrinket(TrinketType.TRINKET_HUNKY_BOYS, "While held, pressing the Drop Trinket button immediately drops this trinket; you don't need to hold the button#When on the ground, enemies will target the trinket for a short time.", "Hunky Boys", "en_us")
    EID:addTrinket(TrinketType.TRINKET_BIBLE_THUMP, "Once you exit a room with this trinket, The Bible is added to several item pools.#Using The Bible or The Devil? card with this item will deal 40 damage to all enemies in the room, in addition to granting flight.#Using The Bible on Satan will kill him, and you will survive#The golden version of this trinket kills The Lamb as well.", "Bible Thump", "en_us")


    EID:addCollectible(CollectibleType.COLLECTIBLE_GOLDENIDOL, "Зачистка комнаты имеет 50% шанс оставить никель, пропадающий через 2 секунды.#При получении урона игрок теряет половину своих монет, и бросает на пол эти монеты (они пропадают через 1 секунду).#Если у игрока есть монеты, урон будет в полное сердце.", "Золотой Идол", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_PASTKILLER, "Удаляет первые три предмета,полученных в забеге (Может удалить сюжетные предметы).#Создает по три пьедестала с предметами из того же пула за каждый потерянный предмет, из 3х предметов можно взять только 1.#The new items are from the same pools as the ones you lost.", "Пушка, Убивающая Прошлое", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_BIRTHDAY_CAKE, "{{ArrowUp}} +1 Контейнер Сердца #Случайная карта/пилюля/руна, случайная монета, бомба и ключ появляются в начале каждого этажа.#Предмет еды, С Кутежником дает -.03 скорости и +.5 скорострельности.", "Именинный Торт", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_RUSTY_SPOON, "10% шанс выстрелить самонаводящейся слезой, накладывающей кровотечение#100% шанс при 18 удачи", "Ржавая Ложка", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_NEWGROUNDS_TANK, "{{ArrowDown}}  -.3 Скорости#{{ArrowUp}} +.27 Скорострельности#{{ArrowUp}} +.5 Урона#{{ArrowUp}} +.04 Дальности#{{ArrowUp}} +.16 Скорости слезы#{{ArrowUp}} +1 Удачи#При получении урона, 10% шанс предотвратить его.", "Танк Newgrounds", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_GREED_BUTT, "При получении урона в зад, персонаж пукает и выпускает монетку.#4% шанс создать золотую кучку вместо пука с монетой.", "Алчная Жопа!", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS, "Если у вас не полное здоровье, вылечи 1 красное сердце.#При полном здоровье, выпусти большую слезу, наносящую большой урон, проходящую сквозь врагов.#Этот предмет заряжается нанесением урона.", "Фокус", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS_2, "Если у вас не полное здоровье, вылечи 1 красное сердце.#При полном здоровье, выпусти большую слезу, наносящую большой урон, проходящую сквозь врагов.#Этот предмет заряжается нанесением урона", "Фокус", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS_3, "Если у вас не полное здоровье, вылечи 1 красное сердце.#При полном здоровье, выпусти большую слезу, наносящую большой урон, проходящую сквозь врагов.#Этот предмет заряжается нанесением урона", "Фокус", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_FOCUS_4, "Если у вас не полное здоровье, вылечи 1 красное сердце.#При полном здоровье, выпусти большую слезу, наносящую большой урон, проходящую сквозь врагов.#Этот предмет заряжается нанесением урона", "Фокус", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_DOORWAY, "Все двери открываются, и остаются открытыми до конца этажа.#Открываются Секретные комнаты, комнаты Ангела/Дьявола, Дверь Мега Сатаны, Двери Испытания Боссов и Молчания (Если они на этом этаже).#Комнаты испытания открыты, но дверь закрывается на время прохождения испытания.#Открывает Ультра Секретную комнату и проход к ней, так же открывает проход к комнате Ошибки, открывая красные комнаты через Ультра секретную комнату до края карты.", "Проход", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_STRANGE_MARBLE, "Все враги с 10% шансом могут стать чемпионами.#Чемпионы всегда оставляют награду, и могут оставить дополнительную.", "Странный Марбл", "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_IS_YOU, "Создает крестик под персонажем, который надо направлять на препятствия (Камни, Блоки и т.д.).#После этого, нужно еще раз активировать предмет для срабатывания эффекта. У каждого обьекта свой эффект.", "Это Ты",  "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK, "Каждые 8 зачисток комнат, Один предмет пропадает из инвентаря.#+.75 Урона за пропавший предмет", "Кошмарный Клещ",  "ru")
    EID:addCollectible(CollectibleType.COLLECTIBLE_SPELUNKERS_PACK, "+12 бомб#Все ямы в радиусе взрыва заполняются.#При взрыве бомбы, Все меченые и двойные меченые камни взорвутся не смотря на то что они вне радиуса взрыва. #Камни с бомбами сломаются и оставят бомбу на их месте.", "Рюкзак Спелеолога",  "ru")

end




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

local function doesAnyoneHave(itemtype, trinket)
    local numPlayers = Game():GetNumPlayers()
    local hasIt = nil
    for i=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(i)
        if trinket == true then
            if player:HasTrinket(itemtype) then
                hasIt = player
            end
        else
            if player:HasCollectible(itemtype) then
                hasIt = player
            end
        end
        
    end
    return hasIt
end

local function getClosestPlayerPosition(entity)
    local numPlayers = Game():GetNumPlayers()
    local closeScore = 999999
    local selectedPlayer = nil
    
    for i=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(i)
        if math.abs((player.Position - entity.Position):LengthSquared()) < closeScore then
            closeScore = math.abs((player.Position - entity.Position):LengthSquared())
            selectedPlayer = player
        end
    end
    return selectedPlayer
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

local function getPlayerFromKnifeLaser(entity)
	if entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer() then
		return entity.SpawnerEntity:ToPlayer()
	elseif entity.SpawnerEntity and entity.SpawnerEntity:ToFamiliar() and entity.SpawnerEntity:ToFamiliar().Player then
		local familiar = entity.SpawnerEntity:ToFamiliar()

		if familiar.Variant == FamiliarVariant.INCUBUS or familiar.Variant == FamiliarVariant.SPRINKLER or
		   familiar.Variant == FamiliarVariant.TWISTED_BABY or familiar.Variant == FamiliarVariant.BLOOD_BABY or
		   familiar.Variant == FamiliarVariant.UMBILICAL_BABY or familiar.Variant == FamiliarVariant.CAINS_OTHER_EYE
		then
			return familiar.Player
		else
			return nil
		end
	else
		return nil
	end
end

local function respawnBalls(numberBalls, player)
    if numberBalls > 0 then
        for i=1, numberBalls do
            local create_entity = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.CUBE_BABY, 0, Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()), Vector(0,0), nil)
            local sprite = create_entity:GetSprite()
            sprite:ReplaceSpritesheet(0, "gfx/familiar/football_reskin.png")
            --sprite:Load("gfx/football_swap.anm2",false)
            sprite:LoadGraphics()
            create_entity:GetData().Football = true
            create_entity:ToFamiliar().Player = player:ToPlayer()
        end
    end
end


function WarpZone:Lerp(first, second, percent, smoothIn, smoothOut)
    if smoothIn then
        percent = percent ^ smoothIn
    end

    if smoothOut then
        percent = 1 - percent
        percent = percent ^ smoothOut
        percent = 1 - percent
    end

	return (first + (second - first)*percent)
end

function WarpZone.AnyPlayerDo(foo)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		foo(player)
	end
end



function WarpZone:magnetoChaseCheck(pickup)
	local closestPlayer
	local closestDist = 999999
	WarpZone.AnyPlayerDo(function(player)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGNETO)
		or player:HasTrinket(TrinketType.TRINKET_SUPER_MAGNET) then
			local dist = pickup.Position:Distance(player.Position)
			if (not closestPlayer) or (closestPlayer and closestDist > dist) then
				closestPlayer = player
				closestDist = dist
			end
		end
		end)
	if closestPlayer then
		local vec = (closestPlayer.Position - pickup.Position):Resized(2)
		pickup.Velocity = WarpZone:Lerp(pickup.Velocity, vec, 0.2)
		pickup:GetData().affectedByMagneto = pickup:GetData().affectedByMagneto or pickup.GridCollisionClass
		pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	else
		if pickup:GetData().affectedByMagneto then
			pickup.GridCollisionClass = pickup:GetData().affectedByMagneto
			pickup:GetData().affectedByMagneto = nil
		end
	end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, WarpZone.magnetoChaseCheck, tumorVariant)
WarpZone:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, WarpZone.magnetoChaseCheck, tokenVariant)



local function findGridEntityResponse(position, player)
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
        player:GetData().baba_active = bestTask.active
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

local function firePopTear(player, playYV)
    --local direction = player:GetAimDirection() * 15
    local direction = player:GetLastDirection() * 15
    local tear = player:FireTear(player.Position, direction, false, false, true, nil, 1)
    tear.Scale = tear.Scale * 1.75
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        tear.CollisionDamage = tear.CollisionDamage * 5
    else
        tear.CollisionDamage = tear.CollisionDamage * 3
    end
    if playYV then
        SfxManager:Play(SoundEffect.SOUND_POP_POP, 1)
    end

    SfxManager:Play(SoundEffect.SOUND_GFUEL_GUNSHOT, 2)
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
    local numFrames = Game():GetFrameCount()
    if numFrames % 60 == 0 then
        local entities = Isaac.GetRoomEntities()
        local targetPos = {}
        local random = myRNG:RandomInt(20)
        for i, entity in ipairs(entities) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_TRINKET and entity.SubType == TrinketType.TRINKET_HUNKY_BOYS then
                if entity:GetEntityFlags() & EntityFlag.FLAG_BAITED ~= EntityFlag.FLAG_BAITED then
                    table.insert(targetPos, entity)
                end
            end
        end
        for i, entity in ipairs(entities) do
            if entity:GetData().distracted and entity:GetData().distracted >= 1 then
                entity:GetData().distracted = entity:GetData().distracted - 1
            elseif entity:GetData().distracted and entity:GetData().distracted <=0 then
                if entity.Target ~= nil then
                    entity.Target = nil
                end
            elseif entity:IsEnemy()  and random > 5 then --and not entity:IsBoss()
                for i, target in ipairs(targetPos) do
                    local player = getClosestPlayerPosition(entity)
                    if player and (math.abs((target.Position - entity.Position):LengthSquared()) < math.abs((player.Position - entity.Position):LengthSquared())) or random > 15 then
                        entity.Target = target
                        entity:GetData().distracted = 3
                    end
                end
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

function WarpZone:postRender(player)
	local actions = player:GetLastActionTriggers()
    if not Game():IsPaused() then
        if player:HasTrinket(TrinketType.TRINKET_HUNKY_BOYS) and Input.IsActionTriggered(ButtonAction.ACTION_DROP, 0) then
            --player:DropTrinket(player.Position)
            player:TryRemoveTrinket(TrinketType.TRINKET_HUNKY_BOYS)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_HUNKY_BOYS, player.Position, Vector(0, 0), nil)
            
        end

        if actions & ActionTriggers.ACTIONTRIGGER_ITEMACTIVATED > 0 then
            player:GetData().timeSinceTheSpacebarWasLastPressed = 0
        else
            player:GetData().timeSinceTheSpacebarWasLastPressed = player:GetData().timeSinceTheSpacebarWasLastPressed + 1
        end
        
        if player:GetData().arrowTimeDelay <= 0 then
            if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, 0) and player:HasCollectible(CollectibleType.COLLECTIBLE_POPPOP) then
                if player:GetData().arrowTimeUp > 0 then
                    player:GetData().arrowTimeDelay = totalFrameDelay
                    firePopTear(player, true)
                    player:GetData().arrowTimeThreeFrames = 6
                else
                    player:GetData().arrowTimeUp = 30
                end
            elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, 0) and player:HasCollectible(CollectibleType.COLLECTIBLE_POPPOP) then
                if player:GetData().arrowTimeDown > 0 then
                    player:GetData().arrowTimeDelay = totalFrameDelay
                    firePopTear(player, true)
                    player:GetData().arrowTimeThreeFrames = 6
                else
                    player:GetData().arrowTimeDown = 30
                end
            elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, 0) and player:HasCollectible(CollectibleType.COLLECTIBLE_POPPOP) then
                if player:GetData().arrowTimeLeft > 0 then
                    player:GetData().arrowTimeDelay = totalFrameDelay
                    firePopTear(player, true)
                    player:GetData().arrowTimeThreeFrames = 6
                else
                    player:GetData().arrowTimeLeft = 30
                end
            elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, 0) and player:HasCollectible(CollectibleType.COLLECTIBLE_POPPOP) then
                if player:GetData().arrowTimeRight > 0 then
                    player:GetData().arrowTimeDelay = totalFrameDelay
                    firePopTear(player, true)
                    player:GetData().arrowTimeThreeFrames = 6
                else
                    player:GetData().arrowTimeRight = 30
                end
            end
        end
        player:GetData().arrowTimeUp = player:GetData().arrowTimeUp - 1
        player:GetData().arrowTimeDown = player:GetData().arrowTimeDown - 1
        player:GetData().arrowTimeLeft = player:GetData().arrowTimeLeft - 1
        player:GetData().arrowTimeRight = player:GetData().arrowTimeRight - 1
        player:GetData().arrowTimeDelay = player:GetData().arrowTimeDelay - 1
        if player:GetData().arrowTimeDelay == 0 or player:GetData().arrowTimeDelay == totalFrameDelay-1 then
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
    end

end
WarpZone:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, WarpZone.postRender)

function WarpZone:UIOnRender(player, renderoffset)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOW_AND_ARROW) then
        local numCollectibles = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BOW_AND_ARROW)
        
        for i = 1, numCollectibles * 3, 1 do
            if player:GetData().numArrows - i >= 0 then
                ArrowHud:SetFrame("Lit", 0)
            else
                ArrowHud:SetFrame("Unlit", 0)
            end
            ArrowHud:RenderLayer(0,  Isaac.WorldToScreen(player.Position)+renderedPosition + Vector((i-1) * 5, 0))
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, WarpZone.UIOnRender)


function WarpZone:EnemyHit(entity, amount, damageflags, source, countdownframes)
    if entity:IsVulnerableEnemy() then
        local numPlayers = Game():GetNumPlayers()
        for i=0, numPlayers-1, 1 do
            local player =  Isaac.GetPlayer(i)
            local source_entity = source.Entity

            if source_entity and source_entity:GetData() and source_entity:GetData().FocusIndicator == nil and
                (CollectibleType.COLLECTIBLE_FOCUS == player:GetActiveItem() or
                CollectibleType.COLLECTIBLE_FOCUS_2 == player:GetActiveItem() or
                CollectibleType.COLLECTIBLE_FOCUS_3 == player:GetActiveItem() or
                CollectibleType.COLLECTIBLE_FOCUS_4 == player:GetActiveItem()
                )
            then
                player:GetData().totalFocusDamage = player:GetData().totalFocusDamage + math.min(amount, entity.HitPoints)
                local chargeMax = (Game():GetLevel():GetStage() * FocusChargeMultiplier * 40) + 60 * FocusChargeMultiplier
                local chargesToSet = math.floor((20 * player:GetData().totalFocusDamage)/chargeMax)
                local chargeThreshold = 20
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
                    chargeThreshold = 40
                end
                local pastCharge = player:GetActiveCharge()
                local newCharge = math.min(chargeThreshold, chargesToSet)

                if pastCharge <= 3  and 3 < newCharge and newCharge <= 10 then
                    player:AddCollectible(CollectibleType.COLLECTIBLE_FOCUS_2, newCharge, false, ActiveSlot.SLOT_PRIMARY)
                elseif pastCharge <= 10 and 10 < newCharge and newCharge <= 19 then
                    player:AddCollectible(CollectibleType.COLLECTIBLE_FOCUS_3, newCharge, false, ActiveSlot.SLOT_PRIMARY)
                elseif pastCharge <=19 and newCharge and newCharge >= 20 then
                    player:AddCollectible(CollectibleType.COLLECTIBLE_FOCUS_4, newCharge, false, ActiveSlot.SLOT_PRIMARY)
                    SfxManager:Play(SoundEffect.SOUND_BATTERYCHARGE)
                else
                    player:SetActiveCharge(newCharge)
                end
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
    
    if player:HasCollectible(CollectibleType.COLLECTIBLE_POSSESSION) then
        local entities = Isaac.GetRoomEntities()
        numPossessed = 0
        
        for i, entity_pos in ipairs(entities) do
            local spawner = entity_pos.SpawnerEntity
            if  entity_pos:HasEntityFlags(EntityFlag.FLAG_CHARM) and (entity_pos:GetData().InPossession or (spawner and spawner:GetData().InPossession)) then
                entity_pos:ClearEntityFlags(EntityFlag.FLAG_CHARM)
                entity_pos:ClearEntityFlags(EntityFlag.FLAG_FRIENDLY)
                entity_pos:GetData().InPossession = false
            end
        end
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

    if player:GetNumCoins() > 0 and player:GetData().inIdolDamage ~= true and player:HasCollectible(CollectibleType.COLLECTIBLE_GOLDENIDOL) == true and player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) == false then
        player:GetData().inIdolDamage = true
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
        
        player:GetData().inIdolDamage = nil
    end
end
WarpZone:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, WarpZone.OnTakeHit, EntityType.ENTITY_PLAYER)


function WarpZone:spawnCleanAward(RNG, SpawnPosition)
    local numPlayers = Game():GetNumPlayers()
    local i=RNG:RandomInt(2)
    local room = Game():GetRoom():GetType() == RoomType.ROOM_BOSS
    
    for j=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(j)
        if (i == 1 or room) and player:HasCollectible(CollectibleType.COLLECTIBLE_GOLDENIDOL) == true and player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) == false then
            local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, 
                        PickupVariant.PICKUP_COIN,
                        CoinSubType.COIN_NICKEL,
                        Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()),
                        Vector(0,0),
                        nil):ToPickup()
            coin.Timeout = 90
            coin:GetSprite():SetFrame(1)
            if room then
                local coin2 = Isaac.Spawn(EntityType.ENTITY_PICKUP, 
                        PickupVariant.PICKUP_COIN,
                        CoinSubType.COIN_NICKEL,
                        Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()),
                        Vector(0,0),
                        nil):ToPickup()
                coin2.Timeout = 90
                coin:GetSprite():SetFrame(1)
            end
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK) then
            player:GetData().roomsClearedSinceTake = player:GetData().roomsClearedSinceTake + 1
            local roomsToSuck = math.max(10 - (2 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK)), 1)
            local itemsTakenHere = player:GetData().itemsTaken
            if player:GetData().roomsClearedSinceTake % roomsToSuck == 0 then
                local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK)
                local shift = 0
                for j, item_tag in ipairs(player:GetData().itemsTaken) do
                    if player:HasCollectible(item_tag) == false then
                        table.remove(player:GetData().itemsTaken, j-shift)
                        table.remove(player:GetData().poolsTaken, j-shift)
                        shift = shift + 1
                    end
                end
                
                local pos_to_delete = rng:RandomInt(#itemsTakenHere) + 1
                local config = Isaac.GetItemConfig():GetCollectible(player:GetData().itemsTaken[pos_to_delete])
                if (player:GetData().itemsTaken[pos_to_delete] == CollectibleType.COLLECTIBLE_NIGHTMARE_TICK or (config.Tags & ItemConfig.TAG_QUEST == ItemConfig.TAG_QUEST)) and #itemsTakenHere > 1 then
                    pos_to_delete = (pos_to_delete % #itemsTakenHere) + 1
                end
                
                config = Isaac.GetItemConfig():GetCollectible(player:GetData().itemsTaken[pos_to_delete])
                if player:GetData().itemsTaken[pos_to_delete] ~= CollectibleType.COLLECTIBLE_NIGHTMARE_TICK and (config.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST) then
                    local item_del = table.remove(player:GetData().itemsTaken, pos_to_delete)
                    table.remove(player:GetData().poolsTaken, pos_to_delete)
                    player:RemoveCollectible(item_del)
                    player:GetData().itemsSucked = player:GetData().itemsSucked + 1
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                    SfxManager:Play(SoundEffect.SOUND_THUMBS_DOWN)
                    SfxManager:Play(SoundEffect.SOUND_BOSS_BUG_HISS)
                    player:AnimateSad()
                end
            end
        end

        if player:GetData().roomsSinceBreak and player:GetData().roomsSinceBreak > 0 then
            player:GetData().roomsSinceBreak = player:GetData().roomsSinceBreak - 1
            if player:GetData().roomsSinceBreak == 0 then
                player:RespawnFamiliars()
            end
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, WarpZone.spawnCleanAward)


function WarpZone:OnGameStart(isSave)
    local numPlayers = Game():GetNumPlayers()
    if WarpZone:HasData()  and isSave then
        saveData = json.decode(WarpZone:LoadData())
        DoorwayFloor = saveData[1]
        numPossessed = saveData[2]
        floorBeggar = saveData[3]
        bibleThumpPool = saveData[4]

        for i=0, numPlayers-1, 1 do
            local player = Isaac.GetPlayer(i)
            for k,v in pairs(saveData[lastIndex + i]) do
                if k ~= "reticle" then
                    player:GetData()[k] = v
                end
            end
        end
    end

    if not isSave then
        saveData = {}
        DoorwayFloor = -1
        numPossessed = 0
        floorBeggar = -1
        bibleThumpPool = false
        for i=0, numPlayers-1, 1 do
            local player = Isaac.GetPlayer(i)
            for k,v in pairs(defaultData) do
                player:GetData()[k] = v
            end
        end
    end

end
WarpZone:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, WarpZone.OnGameStart)


function WarpZone:preGameExit()
    local numPlayers = Game():GetNumPlayers()
    saveData[1] = DoorwayFloor
    saveData[2] = numPossessed
    saveData[3] = floorBeggar
    saveData[4] = bibleThumpPool
    
    for i=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(i)
        saveData[i + lastIndex] = {}
        for k,v in pairs(player:GetData()) do
            saveData[i + lastIndex][k] = v
        end
    end

    local jsonString = json.encode(saveData)
    WarpZone:SaveData(jsonString)
  end

  WarpZone:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, WarpZone.preGameExit)


function WarpZone:DebugText()
    local player = Isaac.GetPlayer(0) --this one is OK
    local coords = player.Position
    local debug_str = tostring(coords)
    --Isaac.RenderText(debug_str, 100, 60, 1, 1, 1, 255)

end
WarpZone:AddCallback(ModCallbacks.MC_POST_RENDER, WarpZone.DebugText)

function WarpZone:multiPlayerInit(player)
    local numPlayers = Game():GetNumPlayers()
    if Game():GetRoom():GetFrameCount() > 0 and numPlayers > 0 then
        for k,v in pairs(defaultData) do
            player:GetData()[k] = v
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, WarpZone.multiPlayerInit)

function WarpZone:LevelStart()
    floorBeggar = -1
    local numPlayers = Game():GetNumPlayers()
    for i=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(i)
        if player:GetData().totalFocusDamage and player:GetData().totalFocusDamage > 0 and (CollectibleType.COLLECTIBLE_FOCUS == player:GetActiveItem() or
        CollectibleType.COLLECTIBLE_FOCUS_2 == player:GetActiveItem() or
        CollectibleType.COLLECTIBLE_FOCUS_3 == player:GetActiveItem() or
        CollectibleType.COLLECTIBLE_FOCUS_4 == player:GetActiveItem()) then
            local one_unit_full_charge = (Game():GetLevel():GetStage() * FocusChargeMultiplier * 40) + 60 * FocusChargeMultiplier
            local one_unit_full_charge_prev = (math.min(Game():GetLevel():GetStage()-1, 1) * FocusChargeMultiplier * 40) + 60 * FocusChargeMultiplier
            player:GetData().totalFocusDamage = player:GetData().totalFocusDamage * (one_unit_full_charge/one_unit_full_charge_prev)
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

        if player:HasTrinket(TrinketType.TRINKET_RING_SNAKE) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP,
                            PickupVariant.PICKUP_TAROTCARD,
                            0,
                            Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()),
                            Vector(0,0),
                            nil)

            Isaac.Spawn(EntityType.ENTITY_PICKUP,
                            PickupVariant.PICKUP_TAROTCARD,
                            0,
                            Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()),
                            Vector(0,0),
                            nil)
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_BOW_AND_ARROW) then
            player:GetData().numArrows = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BOW_AND_ARROW) * 3
        end
    end

end
WarpZone:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, WarpZone.LevelStart)


function WarpZone:NewRoom()
    local testPlayer = Isaac.GetPlayer(0)
    
    local numPlayers = Game():GetNumPlayers()
    local room = Game():GetRoom()
    
    for i=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(i)
        player:GetData().dioDamageOn = false
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()

        player:GetData().ballCheck = false

    end
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
                doorEntity:TryUnlock(testPlayer, true)
            end
            if not doorEntity:IsOpen() then
                doorEntity:Open()
            end
              
              room:DestroyGrid(door:GetGridIndex(), true)
            end
          end
    end

    local marblePlayer = doesAnyoneHave(CollectibleType.COLLECTIBLE_STRANGE_MARBLE, false)
    if marblePlayer ~= nil then
        local marbleRNG = marblePlayer:GetCollectibleRNG(CollectibleType.COLLECTIBLE_STRANGE_MARBLE)
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

    local georgePlayer = doesAnyoneHave(CollectibleType.COLLECTIBLE_GEORGE, false)
    if georgePlayer ~= nil and room:IsFirstVisit() then
        local roomtype = room:GetType()
        local desc = Game():GetLevel():GetCurrentRoomDesc().Flags
        local index = Game():GetLevel():GetCurrentRoomIndex()
        if tableContains(george_room_type, roomtype) and (desc & RoomDescriptor.FLAG_RED_ROOM ~= RoomDescriptor.FLAG_RED_ROOM) then
            for i = 0, 7 do
                local door = room:GetDoor(i)
                if door then
                    local doorEntity = door:ToDoor()
                    local doorSlot = roomKey[i]
                    local made = Game():GetLevel():MakeRedRoomDoor(index, doorSlot)
                    if made ~= true then
                        for j = 0, 7 do
                            local new_door = room:GetDoor(j)
                            if not new_door then
                                made = Game():GetLevel():MakeRedRoomDoor(index, j)
                                if made then break end
                            end
                        end
                    end
                    break
                end
            end
        end
    end
    
    local possessPlayer =  doesAnyoneHave(CollectibleType.COLLECTIBLE_POSSESSION, false)
    if possessPlayer ~= nil and room:IsFirstVisit() then
        local entities = Isaac.GetRoomEntities()
        local charmed = false
        local tempnumPossessed = 0
        for i, entity_pos in ipairs(entities) do
            if entity_pos:GetData().InPossession == true then
                tempnumPossessed = tempnumPossessed + 1
            end
            if not charmed and numPossessed < 15 and entity_pos:IsVulnerableEnemy() and not entity_pos:IsBoss() and not entity_pos:HasEntityFlags(EntityFlag.FLAG_CHARM) then
                entity_pos:AddCharmed(EntityRef(possessPlayer), -1)
                entity_pos:GetData().InPossession = true
                charmed = true
            end
        end
        numPossessed = tempnumPossessed
    end

    local aubreyPlayer = doesAnyoneHave(CollectibleType.COLLECTIBLE_AUBREY, false)
    if floorBeggar < 0 and room:GetType() == RoomType.ROOM_SHOP and aubreyPlayer ~= nil then
        floorBeggar = 0
        Isaac.Spawn(
            EntityType.ENTITY_SLOT,
            BegVariant,
            0,
            Vector(450, 160),
            Vector(0,0),
            nil
        )
    end

    
    
    local biblePlayer = doesAnyoneHave(TrinketType.TRINKET_BIBLE_THUMP, true)

    if biblePlayer ~= nil and bibleThumpPool == false then
        bibleThumpPool = true
        Game():GetItemPool():AddBibleUpgrade(1, ItemPoolType.POOL_TREASURE)
        Game():GetItemPool():AddBibleUpgrade(1, ItemPoolType.POOL_SHOP)
        Game():GetItemPool():AddBibleUpgrade(1, ItemPoolType.POOL_DEVIL)
        Game():GetItemPool():AddBibleUpgrade(1, ItemPoolType.POOL_BOSS)
        Game():GetItemPool():AddBibleUpgrade(1, ItemPoolType.POOL_GOLDEN_CHEST)
        Game():GetItemPool():AddBibleUpgrade(1, ItemPoolType.POOL_RED_CHEST)
        Game():GetItemPool():AddBibleUpgrade(1, ItemPoolType.POOL_SECRET)
        Game():GetItemPool():AddBibleUpgrade(1, ItemPoolType.POOL_BEGGAR)
        Game():GetItemPool():AddBibleUpgrade(1, ItemPoolType.POOL_GREED_TREASURE)
        Game():GetItemPool():AddBibleUpgrade(1, ItemPoolType.POOL_GREED_SHOP)
        Game():GetItemPool():AddBibleUpgrade(1, ItemPoolType.POOL_GREED_DEVIL)
        Game():GetItemPool():AddBibleUpgrade(1, ItemPoolType.POOL_GREED_SECRET)
        Game():GetItemPool():AddBibleUpgrade(1, ItemPoolType.POOL_GREED_BOSS)
    end
    
end
WarpZone:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, WarpZone.NewRoom)

function WarpZone:usePastkiller(collectible, rng, entityplayer, useflags, activeslot, customvardata)

    local player =  entityplayer:ToPlayer()
    --debug_str = tostring(player.ControllerIndex)
 
    
    local shift = 0
    for i, item_tag in ipairs(player:GetData().itemsTaken) do
        if player:HasCollectible(item_tag) == false then
            table.remove(player:GetData().itemsTaken, i-shift)
            table.remove(player:GetData().poolsTaken, i-shift)
            shift = shift + 1
        end
    end
    local itemsTakenHere = player:GetData().itemsTaken
    if #itemsTakenHere < 3 then
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
        pool = table.remove(player:GetData().poolsTaken, 1)
        item_removed  = table.remove(player:GetData().itemsTaken, 1)
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
        entityplayer:GetData().primeShot = true
    end

    local one_unit_full_charge = (Game():GetLevel():GetStage() * FocusChargeMultiplier * 40) + FocusChargeMultiplier * 60
    local adjustedcharge = 0

    if player:GetActiveCharge() >= 20 then
        adjustedcharge = player:GetActiveCharge() - 20
        player:GetData().totalFocusDamage = math.floor(one_unit_full_charge * (adjustedcharge/20))
    else
        player:GetData().totalFocusDamage = 0
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
    print(entityplayer.ControllerIndex)
    if entityplayer:GetData().baba_active == nil and entityplayer:GetData().reticle == nil then
        entityplayer:GetData().reticle = Isaac.Spawn(1000, 30, 0, entityplayer.Position, Vector(0, 0), entityplayer)
        entityplayer:GetData().blinkTime = 10
        entityplayer:AnimateCollectible(CollectibleType.COLLECTIBLE_IS_YOU, "LiftItem", "PlayerPickupSparkle")
        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false
        }
    elseif entityplayer:GetData().baba_active ~= nil then
        entityplayer:UseActiveItem(entityplayer:GetData().baba_active)

        entityplayer:GetData().baba_active = nil
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

    if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == tumorVariant and entity:GetData().Collected ~= true then
        entity:GetData().Collected = true
        entity:GetSprite():Play("Collect")
        if not player:GetData().playerTumors then player:GetData().playerTumors = 0 end
        player:GetData().playerTumors = player:GetData().playerTumors + 1
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
        player:EvaluateItems()
        if Game():GetFrameCount() % 2 == 0 then
            SfxManager:Play(SoundEffect.SOUND_MEAT_IMPACTS)
        else
            SfxManager:Play(SoundEffect.SOUND_MEAT_JUMPS)
        end
        return true
    elseif entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == tumorVariant then
        return true
    end

    if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == tokenVariant and entity:GetData().Collected ~= true then
        entity:GetData().Collected = true
        entity:GetSprite():Play("Collect")
        player:GetData().numArrows = player:GetData().numArrows + 1
        SfxManager:Play(SoundEffect.SOUND_SHELLGAME)
        return true
    elseif entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == tokenVariant then
        return true
    end


    if entity.Type == EntityType.ENTITY_PICKUP and (entity.Variant == PickupVariant.PICKUP_COLLECTIBLE) and player:HasCollectible(CollectibleType.COLLECTIBLE_TONY) then
        --local dmg_config = Isaac.GetItemConfig():GetCollectible(entity.SubType)
        if entity.SubType ~= 0 and player:GetData().tonyBuff > 1 and entity:GetData().collected ~= true then -- and (dmg_config.CacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE)
            entity:GetData().collected = true
            player:GetData().tonyBuff = player:GetData().tonyBuff - 0.1
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
    end

    if entity.Type == EntityType.ENTITY_PICKUP and (entity.Variant == PickupVariant.PICKUP_COLLECTIBLE) and entity:ToPickup():GetData().Logged ~= true then
        local config = Isaac.GetItemConfig():GetCollectible(entity.SubType)
        entity:ToPickup():GetData().Logged = true
        local pool = Game():GetItemPool():GetLastPool()
        if config.Type ~= ItemType.ITEM_ACTIVE then
            table.insert(player:GetData().itemsTaken, entity.SubType)
            table.insert(player:GetData().poolsTaken, pool)
        end
        if entity.SubType == CollectibleType.COLLECTIBLE_BALL_OF_TUMORS then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, tumorVariant, 1, Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()), Vector(0,0), nil)
        end
        if entity.SubType == CollectibleType.COLLECTIBLE_BOW_AND_ARROW then
            player:GetData().numArrows = player:GetData().numArrows + 3
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
        local waterAmount = (entityplayer:GetCollectibleNum(CollectibleType.COLLECTIBLE_WATER_FULL) * 2) + (entityplayer:GetCollectibleNum(CollectibleType.COLLECTIBLE_WATER_MID) * 1.5) + (entityplayer:GetCollectibleNum(CollectibleType.COLLECTIBLE_WATER_LOW) * .75)
        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_NEWGROUNDS_TANK) then
            entityplayer.MaxFireDelay = entityplayer.MaxFireDelay - tank_qty
        end
        entityplayer.MaxFireDelay = entityplayer.MaxFireDelay - waterAmount
        entityplayer.MaxFireDelay = entityplayer.MaxFireDelay - (cakeBingeBonus * 2)

        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_POPPOP) and entityplayer:GetData().arrowTimeDelay > 0 then
            if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                entityplayer.MaxFireDelay = entityplayer.MaxFireDelay + 40
            else
                entityplayer.MaxFireDelay = entityplayer.MaxFireDelay + 30
            end
            
        end
    end
        
    

    if Cache == CacheFlag.CACHE_DAMAGE then
        entityplayer.Damage = entityplayer.Damage + (0.5 * tank_qty)

        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_NIGHTMARE_TICK) then
            entityplayer.Damage = entityplayer.Damage + (entityplayer:GetData().itemsSucked * 0.75)
        end
        
        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_TONY) then
            entityplayer.Damage = (entityplayer.Damage * entityplayer:GetData().tonyBuff) + (entityplayer:GetData().tonyBuff * 1.428)
        end
        
        if entityplayer:GetData().dioDamageOn == true then
            entityplayer.Damage = entityplayer.Damage * 3
        end
    end

    if Cache == CacheFlag.CACHE_RANGE then
        entityplayer.TearRange = entityplayer.TearRange + (40 * tank_qty)
        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_GEORGE) then
            entityplayer.TearRange = entityplayer.TearRange + (entityplayer:GetCollectibleNum(CollectibleType.COLLECTIBLE_GEORGE) * 96)
        end
    end

    if Cache == CacheFlag.CACHE_LUCK then
        entityplayer.Luck = entityplayer.Luck + tank_qty
    end

    if Cache == CacheFlag.CACHE_SPEED then
        entityplayer.MoveSpeed = entityplayer.MoveSpeed - (tank_qty * .3)
        entityplayer.MoveSpeed = entityplayer.MoveSpeed - (cakeBingeBonus * .03)
        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_HITOPS) then
            entityplayer:GetData().breakCap = false
        end
    end

    if Cache == CacheFlag.CACHE_SHOTSPEED then
        entityplayer.ShotSpeed = entityplayer.ShotSpeed + (tank_qty * .16)
    end

end
WarpZone:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, WarpZone.EvaluateCache)


function WarpZone:postPlayerUpdate(player)
    local data = player:GetData()

    if(data.breakCap==false) then
        player.MoveSpeed = math.min(player.MoveSpeed+player:GetCollectibleNum(CollectibleType.COLLECTIBLE_HITOPS)*0.2, 3)
        data.breakCap = nil
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

    if player:HasCollectible(CollectibleType.COLLECTIBLE_POPPOP) then
        if player:GetData().arrowTimeThreeFrames == 1 then
            firePopTear(player, false)
        end
        player:GetData().arrowTimeThreeFrames = player:GetData().arrowTimeThreeFrames-1
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, WarpZone.postPlayerUpdate, 0)


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

    if player and player:HasCollectible(CollectibleType.COLLECTIBLE_BOW_AND_ARROW) and player:GetData().numArrows > 0 then
        player:GetData().numArrows = player:GetData().numArrows - 1
        tear:GetData().BowArrowPiercing = 2
    end

    if player and CollectibleType.COLLECTIBLE_FOCUS == player:GetActiveItem() and player:GetData().primeShot ~= nil then
        SfxManager:Play(SoundEffect.SOUND_EXPLOSION_WEAK, 3)
        player:GetData().primeShot = nil
        tear:GetData().FocusShot = true
        tear:GetData().FocusIndicator = true
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, WarpZone.checkTear)


function WarpZone:checkLaser(entitylaser)
    local laser = entitylaser:ToLaser()
    local player = getPlayerFromKnifeLaser(laser)
    local var = laser.Variant
    local subt = laser.SubType
    if player and player:HasCollectible(CollectibleType.COLLECTIBLE_RUSTY_SPOON) and not ((var == 1 and subt == 3) or var == 5 or var == 12) then
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
    local focusshot = false
    local player = WarpZone:GetPlayerFromTear(tear)
    if tear:GetData() then
        focusshot = tear:GetData().FocusShot == true
        if focusshot then
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
        
        if tear:GetData().BowArrowPiercing == 2 then
            tear:GetData().BowArrowPiercing = 1
            tear:AddTearFlags(TearFlags.TEAR_PIERCING)
            tear.Velocity = tear.Velocity * Vector(1.5, 1.5)
            tear.Scale = tear.Scale * 1.45
            tear.CollisionDamage = tear.CollisionDamage * 1.5
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
    local waterAmount = 1
    if player then
        waterAmount = waterAmount + 0.3 * ((player:GetCollectibleNum(CollectibleType.COLLECTIBLE_WATER_FULL) * 3) + (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_WATER_MID) * 2) + (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_WATER_LOW) * 1))
    end
    if not focusshot then
        if tear:GetData().resized == nil then
            tear.Scale = tear.Scale * waterAmount
            tear:ResetSpriteScale()
            tear:GetData().resized = true
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, WarpZone.updateTear)


function WarpZone:dropArrow(entity)
    if entity:GetData().BowArrowPiercing and entity:GetData().BowArrowPiercing > 0 then
        if game:GetRoom():GetFrameCount() == 0 then
            local player = entity.SpawnerEntity
            if player:ToPlayer() ~= nil then
                player:GetData().numArrows = player:GetData().numArrows + 1
            end
        else
            Isaac.Spawn(EntityType.ENTITY_PICKUP,
                    tokenVariant,
                    1,
                    entity.Position,
                    entity.Velocity * 0.25,
                    nil)
            end
        end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, WarpZone.dropArrow)


function WarpZone:hitEnemy(entitytear, collider, low)
    local tear = entitytear:ToTear()

    if collider:IsEnemy() and tear:GetData().BleedIt == true then
        collider:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
    end
end
WarpZone:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, WarpZone.hitEnemy)


function WarpZone:OnKnifeCollide(knife, collider, low)
    local player = getPlayerFromKnifeLaser(knife)
    if player and player:HasCollectible(CollectibleType.COLLECTIBLE_RUSTY_SPOON) and collider:IsVulnerableEnemy() then
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

function WarpZone:OnFrame(player)
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
        if player:HasCollectible(CollectibleType.COLLECTIBLE_IS_YOU) and player:GetData().reticle ~= nil then
            local aimDir = player:GetAimDirection()
            player:GetData().reticle.Velocity = aimDir * 20

            if player:GetData().reticle.FrameCount % player:GetData().blinkTime < player:GetData().blinkTime/2 then
                player:GetData().reticle.Color = Color(0, 0, 0, 0.5, -230, 100, 215)
            else
                player:GetData().reticle.Color = Color(0, 0, 0, 0.8, -200, 150, 255)
            end

                local stop = false
                if (player:GetData().reticle.FrameCount > 5 and player:GetData().timeSinceTheSpacebarWasLastPressed < 4) or player:GetData().reticle.FrameCount > 75 then
                    findGridEntityResponse(player:GetData().reticle.Position, player)
                    player:GetData().reticle:Remove()
                    player:GetData().reticle = nil
                    stop = true
                else
                    -- Prevent the player from shooting
                    player.FireDelay = 1

                    -- Make the target blink faster
                    if player:GetData().reticle.FrameCount > 70 then
                        player:GetData().blinkTime = 2
                    elseif player:GetData().reticle.FrameCount > 65 then
                        player:GetData().blinkTime = 4
                    elseif player:GetData().reticle.FrameCount > 55 then
                        player:GetData().blinkTime = 6
                    elseif player:GetData().reticle.FrameCount > 40 then
                        player:GetData().blinkTime = 8
                    end
                end
                if stop then --and ai.player:GetSprite():IsPlaying("LiftItem")
                    player:AnimateCollectible(CollectibleType.COLLECTIBLE_IS_YOU, "HideItem", "Empty")
                end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_FOOTBALL) and not player:GetData().ballCheck and room:GetFrameCount() > 0 then
            local numberBalls = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_FOOTBALL)
            local numberCubes = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CUBE_BABY)
            local entities = Isaac.GetRoomEntities()
            for i, entity_pos in ipairs(entities) do
                if entity_pos.Type == EntityType.ENTITY_FAMILIAR and entity_pos.Variant == FamiliarVariant.CUBE_BABY and numberBalls > 0 then
                    local sprite = entity_pos:GetSprite()
                    --sprite:Load("gfx/football_swap.anm2",false)
                    sprite:ReplaceSpritesheet(0, "gfx/familiar/football_reskin.png")
                    sprite:LoadGraphics()
                    entity_pos:GetData().Football = true
                    numberBalls = numberBalls - 1
                elseif entity_pos.Type == EntityType.ENTITY_FAMILIAR and entity_pos.Variant == FamiliarVariant.CUBE_BABY then
                    entity_pos:GetData().Football = false
                    if numberCubes > 0 then
                        local sprite = entity_pos:GetSprite()
                        sprite:ReplaceSpritesheet(0, "gfx/familiar/familiar_cube_baby.png")
                        sprite:LoadGraphics()
                        numberCubes = numberCubes - 1
                    end
                end
            end
            respawnBalls(numberBalls, player)
            if numberCubes > 0 then
                for i=1, numberCubes do
                    local create_entity = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.CUBE_BABY, 0, Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()), Vector(0,0), nil)
                end
            end
            player:GetData().ballCheck = true
        end

end
WarpZone:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, WarpZone.OnFrame)

function WarpZone:OnEntitySpawn(npc)
    local player = doesAnyoneHave(CollectibleType.COLLECTIBLE_STRANGE_MARBLE, false)
    if player ~= nil then
        local rng = RNG()
        rng:SetSeed(Random(), 1)
        if not npc:IsChampion() and not npc:IsBoss() and rng:RandomInt(8) == 1 then
            npc:MakeChampion(rng:GetSeed())
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_NPC_INIT, WarpZone.OnEntitySpawn)


function WarpZone:OnEntityDeath(npc)
    local player = doesAnyoneHave(CollectibleType.COLLECTIBLE_STRANGE_MARBLE, false)
    if player ~= nil and npc:IsEnemy() and npc:IsChampion() then
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
			local player = getPlayerFromKnifeLaser(knife)
			if WarpZone.scanforclub then
				if player and player:GetData().InputHook and knife.Position:Distance(player.Position) < 20 then
					knife:GetData().CustomClub = true
					player:GetData().GrabbedClub = knife
					WarpZone.scanforclub = false
					player:GetData().InputHook = nil
					knife.Variant = 1 --Setting the variant to 1 (bone club) prevents it from breaking rocks
                    --knife.Scale = knife.Scale * 2
				end
			elseif player and player:GetData().GrabbedClub and player:GetData().GrabbedClub:Exists() then
				knife.Variant = 1
			end
		elseif WarpZone.scanforclub then
			knife.Visible = false
		end
	end
end)

WarpZone:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
	local player = WarpZone:GetPlayerFromTear(tear)
    
    if player then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_DIOGENES_POT_LIVE) then
            player:GetData().dioDamageOn = true
            tear:Remove()
            WarpZone:FireClub(player, player:GetFireDirection())
        else
            player:GetData().dioDamageOn = false
        end
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end
end)




local function init_lollipop(_, orbital)
	orbital.OrbitDistance = Lollipop.ORBIT_DISTANCE
	orbital.OrbitSpeed = Lollipop.ORBIT_SPEED
	orbital:AddToOrbit(Lollipop.ORBIT_LAYER)
end

WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, init_lollipop, Lollipop.VARIANT)

local function update_orbital(_, orbital)

	orbital.OrbitDistance = Lollipop.ORBIT_DISTANCE
	orbital.OrbitSpeed = Lollipop.ORBIT_SPEED
	local center_pos = (orbital.Player.Position + orbital.Player.Velocity) + Lollipop.ORBIT_CENTER_OFFSET
	local orbit_pos = orbital:GetOrbitPosition(center_pos)
	orbital.Velocity = orbit_pos - orbital.Position
end

WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, update_orbital, Lollipop.VARIANT)


local function pre_orbital_collision(_, orbital, collider, low)
	if collider:IsVulnerableEnemy() then
        --if enemy_obj.HitPoints < enemy_obj.MaxHitPoints then
        --    collider:AddHealth(1)
        --end
        if math.random(Lollipop.CHARM_CHANCE) == 1 then
            collider:AddCharmed(EntityRef(orbital), Lollipop.CHARM_DURATION, true)
        end
	elseif collider:ToProjectile() ~= nil then
        if orbital:GetData().PopHP == nil then
            orbital:GetData().PopHP = 6
        else
            orbital:GetData().PopHP = orbital:GetData().PopHP-1
        end

        
        if orbital:GetData().PopHP == 0 then
            local orbitalPosition = orbital.Position
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, orbitalPosition, Vector(0, 0), orbital)
            orbital:Remove()
            SfxManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
            local player = orbital.Player
            player:GetData().roomsSinceBreak = 12
        elseif orbital:GetData().PopHP < 2 then
            local sprite = orbital:GetSprite()
            sprite:Load("gfx/Lollipop_cracked_2.anm2",false)
			sprite:LoadGraphics()
            sprite:Play("Float", true)
        elseif orbital:GetData().PopHP < 4 then
            local sprite = orbital:GetSprite()
            sprite:Load("gfx/Lollipop_cracked.anm2",false)
			sprite:LoadGraphics()
            sprite:Play("Float", true)
        end

        collider:Die()
    end
end

WarpZone:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, pre_orbital_collision, Lollipop.VARIANT)


local function update_cache(_, player, cache_flag)
	if cache_flag == CacheFlag.CACHE_FAMILIARS then
		local pop_pickups = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_LOLLIPOP)
		local pop_rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LOLLIPOP)
		player:CheckFamiliar(Lollipop.VARIANT, pop_pickups, pop_rng)
        
        local tumor_count = player:GetData().playerTumors
        if tumor_count and Game():GetFrameCount() > 1 then
            local smalltumors = 0
            local midtumors = 0
            local largetumors = 0
            if tumor_count >= 5 then
                largetumors = largetumors + 1
                tumor_count = tumor_count - 5
                if tumor_count >= 5 then
                    largetumors = largetumors + 1
                end
            end
            if tumor_count < 5 and tumor_count > 2 then
                midtumors = 1
            elseif tumor_count <= 2 and tumor_count > 0 then
                smalltumors = 1
            end

            local myRNG1 = RNG()
            myRNG1:SetSeed(Random(), 1)
            local myRNG2 = RNG()
            myRNG2:SetSeed(Random(), 1)
            local myRNG3 = RNG()
            myRNG3:SetSeed(Random(), 1)
            player:CheckFamiliar(LargeTumor.VARIANT, largetumors, myRNG1)
            player:CheckFamiliar(MidTumor.VARIANT, midtumors, myRNG2)
            player:CheckFamiliar(SmallTumor.VARIANT, smalltumors, myRNG3)
        end

        local ball_pickups = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_FOOTBALL)
        respawnBalls(ball_pickups, player)
    end
end

WarpZone:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, update_cache)


function WarpZone:init_tumor_s(orbital)
	orbital.OrbitDistance = SmallTumor.ORBIT_DISTANCE
	orbital.OrbitSpeed = SmallTumor.ORBIT_SPEED
	orbital:AddToOrbit(SmallTumor.ORBIT_LAYER)
end
function WarpZone:init_tumor_m(orbital)
	orbital.OrbitDistance = MidTumor.ORBIT_DISTANCE
	orbital.OrbitSpeed = MidTumor.ORBIT_SPEED
	orbital:AddToOrbit(MidTumor.ORBIT_LAYER)
end
function WarpZone:init_tumor_l(orbital)
	orbital.OrbitDistance = LargeTumor.ORBIT_DISTANCE
	orbital.OrbitSpeed = LargeTumor.ORBIT_SPEED
	orbital:AddToOrbit(LargeTumor.ORBIT_LAYER)
end

WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, WarpZone.init_tumor_s, SmallTumor.VARIANT)
WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, WarpZone.init_tumor_m, MidTumor.VARIANT)
WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, WarpZone.init_tumor_l, LargeTumor.VARIANT)



function WarpZone:update_tumor_s(orbital)
    orbital.OrbitDistance = SmallTumor.ORBIT_DISTANCE
	orbital.OrbitSpeed = SmallTumor.ORBIT_SPEED
	local center_pos = (orbital.Player.Position + orbital.Player.Velocity) + SmallTumor.ORBIT_CENTER_OFFSET
	local orbit_pos = orbital:GetOrbitPosition(center_pos)
	orbital.Velocity = orbit_pos - orbital.Position
end

function WarpZone:update_tumor_m(orbital)
	orbital.OrbitDistance = MidTumor.ORBIT_DISTANCE
	orbital.OrbitSpeed = MidTumor.ORBIT_SPEED

	local center_pos = (orbital.Player.Position + orbital.Player.Velocity) + MidTumor.ORBIT_CENTER_OFFSET
	local orbit_pos = orbital:GetOrbitPosition(center_pos)
	orbital.Velocity = orbit_pos - orbital.Position
end

function WarpZone:update_tumor_l(orbital)
	orbital.OrbitDistance = LargeTumor.ORBIT_DISTANCE
	orbital.OrbitSpeed = LargeTumor.ORBIT_SPEED

	local center_pos = (orbital.Player.Position + orbital.Player.Velocity) + LargeTumor.ORBIT_CENTER_OFFSET
	local orbit_pos = orbital:GetOrbitPosition(center_pos)
	orbital.Velocity = orbit_pos - orbital.Position
end
WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, WarpZone.update_tumor_s, SmallTumor.VARIANT)
WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, WarpZone.update_tumor_m, MidTumor.VARIANT)
WarpZone:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, WarpZone.update_tumor_l, LargeTumor.VARIANT)



function WarpZone:pre_tumor_collision(orbital, collider, low)
	if collider:IsVulnerableEnemy() then
        local damage = 1
        if orbital.Variant == SmallTumor.VARIANT then
            damage = 1
        elseif orbital.Variant == MidTumor.VARIANT then
            damage = 2
        elseif orbital.Variant == LargeTumor.VARIANT then
            damage = 4
            local player = orbital.Player
            local numTumors = player:GetData().playerTumors
            if numTumors then
                damage = damage + ((numTumors - 10) * 0.2)
            end
        end
        collider:TakeDamage(damage, 0, EntityRef(orbital), 0)
	elseif collider:ToProjectile() ~= nil then
        --conditions for blocking shots?
        collider:Die()
    end
end

WarpZone:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, WarpZone.pre_tumor_collision, SmallTumor.VARIANT)
WarpZone:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, WarpZone.pre_tumor_collision, MidTumor.VARIANT)
WarpZone:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, WarpZone.pre_tumor_collision, LargeTumor.VARIANT)



function WarpZone:selectPickup(type, variant, subtype, position, velocity, spawner, seed)
    local player = doesAnyoneHave(CollectibleType.COLLECTIBLE_BALL_OF_TUMORS, false)
    if Game():GetRoom():GetFrameCount() <= 0 and not Game():GetRoom():IsFirstVisit() then
        return nil --exclude spawns when re-entering a room with items
    end
    if player ~= nil and type == EntityType.ENTITY_PICKUP then
        local tumorRNG = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BALL_OF_TUMORS)
        local rand_num = tumorRNG:RandomInt(100) + 1
        local collectible_num = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BALL_OF_TUMORS) * 4
        
        if rand_num <= collectible_num and (variant <= 40 or
        variant == PickupVariant.PICKUP_LIL_BATTERY) then
            return {EntityType.ENTITY_PICKUP, tumorVariant, 1, seed}
        end
    end
    return nil
end
WarpZone:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, WarpZone.selectPickup)


local function playerToNum(player)
	for num = 0, Game():GetNumPlayers()-1 do
		if GetPtrHash(player) == GetPtrHash(Isaac.GetPlayer(num)) then return num end
	end
end

local function pityLevel(beggar)
	if beggar:GetData()["Pity Counter"] then return beggar:GetData()["Pity Counter"] end
	return 0
end


local function beggarDropOdds(beggar, isKeeper)
	local rand = beggar:GetDropRNG():RandomFloat()
	local success = false
	-- if Game().Difficulty == Difficulty.DIFFICULTY_HARD then ticks = ticks - 6 end
	if isKeeper then
		success = rand < (BASE_PAYOUT_CHANCE + pityLevel(beggar) * STEP_PAYOUT_CHANCE) * (1+KEEPER_BONUS)
	else
		success = rand < BASE_PAYOUT_CHANCE + pityLevel(beggar) * STEP_PAYOUT_CHANCE
	end
	if success then
		beggar:GetData()["Pity Counter"] = nil
		return true
	else
		if not beggar:GetData()["Pity Counter"] then beggar:GetData()["Pity Counter"] = 0 end
        beggar:GetData()["Pity Counter"] = beggar:GetData()["Pity Counter"] + 1
		return false
	end
end

function WarpZone:donation(player, beggar, low)
	if beggar.Type == EntityType.ENTITY_SLOT and beggar.Variant == BegVariant then
		if beggar:GetSprite():IsPlaying("Idle") and player:GetNumCoins() > 0 then
			player:AddCoins(-1)
			SFXManager():Play(SoundEffect.SOUND_SCAMPER, 1.0, 0, false, 1.0)
			if beggarDropOdds(beggar, player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B) then
				beggar:GetSprite():Play("PayPrize")
				beggar:GetData()["Playing Player"] = playerToNum(player)
				if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
					beggar:GetData()["Playing Player"] = playerToNum(player:GetMainTwin())
				end
			else
				beggar:GetSprite():Play("PayNothing")
			end
		end
	end
end
WarpZone:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, WarpZone.donation)


local function killBeggar(ent)
	if ent.Type == EntityType.ENTITY_SLOT and ent.Variant == BegVariant then
		ent:Kill()
		ent:Remove()
		Game():GetLevel():SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)
	end
end

function WarpZone:BeggarUpdate()
	local beggars = Isaac.FindByType(EntityType.ENTITY_SLOT, BegVariant)
    
	for _,beggar in pairs(beggars) do
		if beggar:GetSprite():IsFinished("PayNothing") then beggar:GetSprite():Play("Idle")	end
		if beggar:GetSprite():IsFinished("PayPrize") then beggar:GetSprite():Play("Prize") end
		if beggar:GetSprite():IsFinished("Prize") then
            floorBeggar = floorBeggar + 1
			if floorBeggar >= 3 then
				beggar:GetSprite():Play("Teleport")
			else
				beggar:GetSprite():Play("Idle")
				beggar:GetData()["Playing Player"] = nil
			end
		end
		if beggar:GetSprite():IsFinished("Teleport") then
			beggar:Remove()
		end

        if beggar:GetSprite():IsEventTriggered("Prize") then
			local prizepos = Game():GetRoom():FindFreePickupSpawnPosition(beggar.Position)
            local pickup_num

            for i = 1, 10000 do
                pickup_num = myRNG:RandomInt(733)
                if Isaac.GetItemConfig():GetCollectible(pickup_num) and Isaac.GetItemConfig():GetCollectible(pickup_num).Type == ItemType.ITEM_ACTIVE  and not (pickup_num >= 550 and pickup_num <= 552) and pickup_num ~= 714 and pickup_num ~= 715 then
                    break
                end
            end
            
            local item_spawn = Isaac.Spawn(EntityType.ENTITY_PICKUP,
                        PickupVariant.PICKUP_COLLECTIBLE,
                        pickup_num,
                        prizepos,
                        Vector(0,0),
                        nil):ToPickup()
			
            --item_spawn.AutoUpdatePrice = false
            --item_spawn.Price = 10
            --item_spawn.OptionsPickupIndex = 1776

			SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1.0, 0, false, 1.0)
			
		end
		if beggar:GetSprite():IsEventTriggered("Disappear") then
			beggar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		end
	end
	local explosions = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION)
	for _,plosion in pairs(explosions) do
		local frame = plosion:GetSprite():GetFrame()
		if frame < 3 then -- I'm afraid of 60 vs 30 breaking an exact check
			local size = plosion.SpriteScale.X -- default is 1, can be increased
			local nearby = Isaac.FindInRadius(plosion.Position, 75*size)
			for _,v in pairs(nearby) do
				killBeggar(v)
			end
		end
	end

    local tumors = Isaac.FindByType(EntityType.ENTITY_PICKUP, tumorVariant)
    for _,tumor in pairs(tumors) do
        if tumor:GetSprite():GetFrame() >= 4 and tumor:GetSprite():GetAnimation() == "Collect" then
			tumor:Remove()
		elseif tumor:GetSprite():IsEventTriggered("DropSound") then
            SfxManager:Play(SoundEffect.SOUND_MEAT_FEET_SLOW0, 2)
        end
    end

    local tokens = Isaac.FindByType(EntityType.ENTITY_PICKUP, tokenVariant)
    for _, token in pairs(tokens) do
        if token:GetSprite():GetFrame() >= 5 and token:GetSprite():GetAnimation() == "Collect" then
			token:Remove()
		elseif token:GetSprite():IsEventTriggered("DropSound") then
            SfxManager:Play(SoundEffect.SOUND_SCAMPER, 2)
        end
    end


end
WarpZone:AddCallback(ModCallbacks.MC_POST_UPDATE, WarpZone.BeggarUpdate)


function WarpZone:UseRLHand(collectible, rng, entityplayer, useflags, activeslot, customvardata)
    local entities = Isaac.GetRoomEntities()
    local left_rng = entityplayer:GetCollectibleRNG(CollectibleType.COLLECTIBLE_REAL_LEFT)
    local ischest = false

    for i, entity_pos in ipairs(entities) do
        local rand_num = left_rng:RandomInt(100) 
        if entity_pos.Type == EntityType.ENTITY_PICKUP and entity_pos.Variant == PickupVariant.PICKUP_MIMICCHEST then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HAUNTEDCHEST, 0)
            ischest = true
        elseif entity_pos.Type == EntityType.ENTITY_PICKUP and entity_pos.Variant == PickupVariant.PICKUP_HAUNTEDCHEST then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0)
            ischest = true
        elseif entity_pos.Type == EntityType.ENTITY_PICKUP and entity_pos.Variant == PickupVariant.PICKUP_CHEST then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_REDCHEST, 0)
            ischest = true
        elseif entity_pos.Type == EntityType.ENTITY_PICKUP and entity_pos.Variant == PickupVariant.PICKUP_REDCHEST and rand_num > 50 then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, 0)
            ischest = true
        elseif entity_pos.Type == EntityType.ENTITY_PICKUP and entity_pos.Variant == PickupVariant.PICKUP_REDCHEST then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMBCHEST, 0)
            ischest = true
        elseif entity_pos.Type == EntityType.ENTITY_PICKUP and (entity_pos.Variant == PickupVariant.PICKUP_BOMBCHEST or entity_pos.Variant == PickupVariant.PICKUP_LOCKEDCHEST) and rand_num > 50 then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_WOODENCHEST, 0)
            ischest = true
        elseif entity_pos.Type == EntityType.ENTITY_PICKUP and (entity_pos.Variant == PickupVariant.PICKUP_BOMBCHEST or entity_pos.Variant == PickupVariant.PICKUP_LOCKEDCHEST) then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_OLDCHEST, 0)
            ischest = true
        elseif entity_pos.Type == EntityType.ENTITY_PICKUP and (entity_pos.Variant == PickupVariant.PICKUP_OLDCHEST or entity_pos.Variant == PickupVariant.PICKUP_WOODENCHEST) then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_ETERNALCHEST, 0)
            ischest = true
        elseif entity_pos.Type == EntityType.ENTITY_PICKUP and entity_pos.Variant == PickupVariant.PICKUP_ETERNALCHEST then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_MEGACHEST, 0)
            ischest = true
        end
    end

    if not ischest then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_REDCHEST, ChestSubType.CHEST_CLOSED, Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()), Vector(0, 0), nil)
    end
    SfxManager:Play(SoundEffect.SOUND_CHEST_DROP, 2)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true
    }
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.UseRLHand, CollectibleType.COLLECTIBLE_REAL_LEFT)


function WarpZone:FootballCollide(familiar, collider, low)
    if familiar:GetData().Football == true then
        local player = familiar.Player
        if collider:IsVulnerableEnemy() then
            --collider.Velocity = familiar.Velocity * 2
            --collider:AddVelocity(familiar.Velocity * 2 + Vector(10, 10))
            --collider.Friction
            --print(tostring(familiar.Velocity.X * 5) .. "  " .. tostring(familiar.Velocity.Y * 5))
            local damage = math.abs(familiar.Velocity.X + collider.Velocity.X) * 0.75 + math.abs(familiar.Velocity.Y + collider.Velocity.Y) * 0.75
            local footrand = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_FOOTBALL)
            if damage > 10 and footrand:RandomInt(100) > 50 then
                collider:AddConfusion(EntityRef(familiar), 90, true)
            end
            collider:TakeDamage(damage, 0, EntityRef(familiar), 0)
            return false
        elseif collider:ToPlayer() ~= nil and not (Game():GetLevel():GetCurrentRoomIndex() ==84 and Game():GetRoom():IsFirstVisit()) then
            local coll_player = collider:ToPlayer()
            coll_player:UseActiveItem(CollectibleType.COLLECTIBLE_MOMS_BRACELET)
            return false
        end
        return nil
    else
        return nil
    end
end
WarpZone:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, WarpZone.FootballCollide, FamiliarVariant.CUBE_BABY)

function WarpZone:FindEffects(collectible, rng, entityplayer, useflags, activeslot, customvardata)
    local entities = Isaac.GetRoomEntities()
    local debbug = ""
    for i, entity_pos in ipairs(entities) do
        if entity_pos.Type == EntityType.ENTITY_EFFECT 
        and entity_pos.Variant ~= 87 
        and entity_pos.Variant ~= 121 then
            debbug = tostring(entity_pos.Variant) .. "-" .. tostring(entity_pos.Position.X) .. ", " .. tostring(entity_pos.Position.Y)
        end
    end

    return {
        Discharge = false,
        Remove = false,
        ShowAnim = true
    }
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.FindEffects, CollectibleType.COLLECTIBLE_TEST_ACTIVE)



function WarpZone:DisableCreep(entity)
    if entity.SpawnerType == 0 then
        entity:Remove()
    end
end
--WarpZone:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, WarpZone.DisableCreep, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL)
--WarpZone:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, WarpZone.DisableCreep, EffectVariant.DUST_CLOUD)

function WarpZone:DisableCreepPlanB(Type, Variant, SubType, Position, Velocity, Spawner, Seed)
    --print("check1")
    if Type == EntityType.ENTITY_EFFECT and (Variant == EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL) and Spawner == nil then
        return {1000, effBlank, 1, Seed}
    end
end
WarpZone:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, WarpZone.DisableCreepPlanB)


function WarpZone:BibleExtraDamage(collectible, rng, player, useflags, activeslot, customvardata)
    if player:HasTrinket(TrinketType.TRINKET_BIBLE_THUMP) then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, false, false, true, false, -1, 0)
    end
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.BibleExtraDamage, CollectibleType.COLLECTIBLE_BIBLE)


function WarpZone:BibleKillSatan(collectible, rng, player, useflags, activeslot, customvardata)
    if player:HasTrinket(TrinketType.TRINKET_BIBLE_THUMP) and Game():GetLevel():GetStage() == LevelStage.STAGE5 
    and Game():GetRoom():GetType() == RoomType.ROOM_BOSS and Game():GetLevel():GetStageType() == StageType.STAGETYPE_ORIGINAL then
    
            local entities_s = Isaac.GetRoomEntities()
            for i, entity_s in ipairs(entities_s) do
                if entity_s.Type == EntityType.ENTITY_SATAN then
                    entity_s:Kill()
                end
            end
        return true
    elseif player:GetTrinketMultiplier(TrinketType.TRINKET_BIBLE_THUMP) >= 2 and Game():GetLevel():GetStage() == LevelStage.STAGE6 
    and Game():GetRoom():GetType() == RoomType.ROOM_BOSS and Game():GetLevel():GetStageType() == StageType.STAGETYPE_ORIGINAL then
        local entities_s = Isaac.GetRoomEntities()
            for i, entity_s in ipairs(entities_s) do
                if entity_s.Type == EntityType.ENTITY_THE_LAMB then
                    entity_s:Kill()
                end
            end
        return true
    else
        return nil
    end
end
WarpZone:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, WarpZone.BibleKillSatan, CollectibleType.COLLECTIBLE_BIBLE)


function WarpZone:BibleKillSatanWrapper(card, player, useflags)
    WarpZone:BibleKillSatan(nil, nil, player, nil, nil, nil)
end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.BibleKillSatanWrapper, Card.CARD_REVERSE_DEVIL)

function WarpZone:UseWitchCube(card, player, useflags)
    local witchRNG = RNG()
    witchRNG:SetSeed(Random(), 1)
    if witchRNG:RandomInt(100) > 50 then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, false, false, true, false, -1, 0)
        local entities = Isaac.GetRoomEntities()
        for i, entity in ipairs(entities) do
            if entity:IsVulnerableEnemy() and witchRNG:RandomInt(100) > 50 then
                entity:AddBurn(EntityRef(player), 60, 1)
            end
        end
    else
        player:UseActiveItem(CollectibleType.COLLECTIBLE_BEAN, false, false, true, false, -1, 0)
        Isaac.Spawn(EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_TAROTCARD,
            Card.CARD_WITCH_CUBE,
            Game():GetRoom():FindFreePickupSpawnPosition(player.Position),
            Vector(0,0),
            nil)
    end
end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.UseWitchCube, Card.CARD_WITCH_CUBE)

function WarpZone:UseLootCard(card, player, useflags)
    local lootRNG = RNG()
    lootRNG:SetSeed(Random(), 1)
    local isTrinket = lootRNG:RandomInt(900) < 184
    if not isTrinket then
        local ranPool = lootRNG:RandomInt(ItemPoolType.NUM_ITEMPOOLS)
        Isaac.Spawn(EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_COLLECTIBLE,
            itemPool:GetCollectible(ranPool),
            Game():GetRoom():FindFreePickupSpawnPosition(player.Position),
            Vector(0,0),
            nil)
    else
        Isaac.Spawn(EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_TRINKET,
            0,
            Game():GetRoom():FindFreePickupSpawnPosition(player.Position),
            Vector(0,0),
            nil)
    end
    
end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.UseLootCard, Card.CARD_LOOT_CARD)

function WarpZone:useCow(card, player, useflags)
    local entities = Isaac.GetRoomEntities()
    local itemID = nil
    local cowRNG =  RNG()
    cowRNG:SetSeed(Random(), 1)
    SfxManager:Play(SoundEffect.SOUND_COW_TRASH, 2)
    for i, entity in ipairs(entities) do
        if entity.Type == EntityType.ENTITY_PICKUP then
            if entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local price = entity:ToPickup().Price
                for j=1, 10000, 1 do
                    local ranPool = cowRNG:RandomInt(ItemPoolType.NUM_ITEMPOOLS)
                    itemID = itemPool:GetCollectible(ranPool)
                    local config = Isaac.GetItemConfig():GetCollectible(itemID)
                    if config.Tags & ItemConfig.TAG_FLY == ItemConfig.TAG_FLY then
                        break
                    end
                end
                if itemID ~= nil then
                    entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemID)
                    entity:ToPickup().Price = price
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, entity.Position, entity.Velocity, player)
                end
            elseif entity.Variant <= 90 or entity.Variant == PickupVariant.PICKUP_TAROTCARD 
            or entity.Variant == PickupVariant.PICKUP_REDCHEST or entity.Variant == PickupVariant.PICKUP_TRINKET then
                player:AddBlueFlies(1, entity.Position, player)
                --Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, entity.Position, entity.Velocity, player)
                entity:Remove()
            end
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.useCow, Card.CARD_COW_TRASH_FARM)

function WarpZone:useJester(card, player, useflags)
    local entities = Isaac.GetRoomEntities()
    for i, entity in ipairs(entities) do
        if entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, entity.Position, entity.Velocity, player)
        end
    end
    for i=1, 6, 1 do
        player:UseCard(Card.CARD_SOUL_ISAAC, 257)
    end
end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.useJester, Card.CARD_JESTER_CUBE)
