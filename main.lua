--basic data
local Vector = Vector
local game = Game()
WarpZone = RegisterMod("WarpZone", 1)
--local WarpZone = WarpZone
local json = require("json")
local myRNG = RNG()
myRNG:SetSeed(Random(), 1)
local hud = game:GetHUD()
local SfxManager = SFXManager()
local debug_str = "untested"
----------------------------------

WarpZone.SaveFile = {}

--debug
WarpZone.SpelunkersPackEffectType = 1
WarpZone.JohnnysKnivesEffectType = 1

----------------------------------
--save data
local saveData = {}
local lastIndex = 5

local defaultData = {}
defaultData.WarpZone_data = {
    --arrowTimeUp = 0,
    --arrowTimeDown = 0,
    --arrowTimeLeft = 0,
    --arrowTimeRight = 0,
    arrowTimeThreeFrames = 0,
    arrowTimeDelay = 0,
}
defaultData.WarpZone_data.numArrows = 0
defaultData.WarpZone_data.playerTumors = 0
defaultData.WarpZone_data.tonyBuff = 1.7
defaultData.WarpZone_data.dioDamageOn = false
defaultData.WarpZone_data.roomsClearedSinceTake = -1
defaultData.WarpZone_data.itemsSucked = 0
defaultData.WarpZone_data.itemsTaken = {}
defaultData.WarpZone_data.poolsTaken = {}
defaultData.WarpZone_data.totalFocusDamage = 0
defaultData.WarpZone_data.roomsSinceBreak = 0
--defaultData.arrowTimeUp = 0
--defaultData.arrowTimeDown = 0
--defaultData.arrowTimeLeft = 0
--defaultData.arrowTimeRight = 0
--defaultData.arrowTimeThreeFrames = 0
--defaultData.arrowTimeDelay = 0
defaultData.WarpZone_data.ballCheck = true
defaultData.WarpZone_data.blinkTime = 10
defaultData.WarpZone_data.timeSinceTheSpacebarWasLastPressed = 0
defaultData.WarpZone_data.bonusSpeed = 0
defaultData.WarpZone_data.bonusDamage = 0
defaultData.WarpZone_data.bonusFireDelay = 0
defaultData.WarpZone_data.bonusRange = 0
defaultData.WarpZone_data.bonusLuck = 0
defaultData.WarpZone_data.inDemonForm = nil
defaultData.WarpZone_data.arrowHoldBox = 0
defaultData.WarpZone_unsavedata = {
    arrowTimeUp = 0,
    arrowTimeDown = 0,
    arrowTimeLeft = 0,
    arrowTimeRight = 0,
}

local function TabDeepCopy(tbl)
    local t = {}
	if type(tbl) ~= "table" then error("[1] is not a table",2) end
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            t[k] = TabDeepCopy(v)
        else
            t[k] = v
        end
    end

    return t
end


local numPlayersG = game:GetNumPlayers()
for i=0, numPlayersG-1, 1 do
    local player = Isaac.GetPlayer(i)
    for k,v in pairs(defaultData) do
        if type(v) == "table" then
            player:GetData()[k] = TabDeepCopy(v)
        else
            player:GetData()[k] = v
        end
    end
end

function WarpZone.GetMenuSaveData()
    if not WarpZone.MenuData then
        if WarpZone:HasData() then
            WarpZone.MenuData = json.decode(WarpZone:LoadData()).MenuData or {}
        else
            WarpZone.MenuData = {}
        end
    end
    return WarpZone.MenuData
end

function WarpZone.StoreSaveData()
    --WarpZone:SaveData(json.encode(WarpZone.MenuData))
    WarpZone.SaveFile.MenuData = WarpZone.MenuData
end

local DSSInitializerFunction = include("lua.dss.deadseascrolls")
DSSInitializerFunction(WarpZone)

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
WarpZone.FOOTBALL = { 
    FAM = { ID = Isaac.GetEntityTypeByName("WZ football ball"), VAR = Isaac.GetEntityVariantByName("WZ football ball") } ,
    ITEM = Isaac.GetItemIdByName("Football"),
}
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
local arrowTrail = {
    col = Color(.7,.5,.5,0.6),
    MinRadius = 0.21,
}

--emergency meeting
local enemiesToMove = {}
local inTransit = -1
local isBossEmergency = false
local bossPrepped = false
local roomsPrepped = {}

--chunk of amber
local preservedItems = nil

--boxing glove
local chargebarFrames = 235
local BoxHud = Sprite()
BoxHud:Load("gfx/chargebar_glove.anm2", true)
local framesToCharge = 141
local boxRenderedPosition = Vector(20, -27)


--johnny knives
local KnifeVariantHappy = Isaac.GetEntityVariantByName("JohnnyHappy")
local KnifeVariantSad = Isaac.GetEntityVariantByName("JohnnySad")
WarpZone.JOHNNYS_KNIVES = {
    ENT = {HAPPY = KnifeVariantHappy, SAD = KnifeVariantSad},
}

--spelunker's bomb
WarpZone.SPELUNKERS_PACK = {BOMBVAR = Isaac.GetEntityVariantByName("Spelunker Bomb"),
    FetusBasicChance = 0.5, FetusMaxLuck = 6}


--ser junkan
local SerJunkPickupVar = Isaac.GetEntityVariantByName("Junk_Pickup")
local SerJunkanWalk = Isaac.GetEntityVariantByName("SerJunkanWalk")
local SerJunkanFly = Isaac.GetEntityVariantByName("SerJunkanFly")

--item defintions
WarpZone.WarpZoneTypes = {}

WarpZone.WarpZoneTypes.COLLECTIBLE_GOLDENIDOL = Isaac.GetItemIdByName("Golden Idol")
WarpZone.WarpZoneTypes.COLLECTIBLE_PASTKILLER = Isaac.GetItemIdByName("Gun that can kill the Past")
WarpZone.WarpZoneTypes.COLLECTIBLE_BIRTHDAY_CAKE = Isaac.GetItemIdByName("Birthday Cake")
WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON = Isaac.GetItemIdByName("Rusty Spoon")
WarpZone.WarpZoneTypes.COLLECTIBLE_NEWGROUNDS_TANK = Isaac.GetItemIdByName("Newgrounds Tank")
WarpZone.WarpZoneTypes.COLLECTIBLE_GREED_BUTT = Isaac.GetItemIdByName("Greed Butt")
WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS = Isaac.GetItemIdByName("Focus")
WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_2 = Isaac.GetItemIdByName(" Focus ")
WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_3 = Isaac.GetItemIdByName("  Focus  ")
WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_4 = Isaac.GetItemIdByName("   Focus   ")
WarpZone.WarpZoneTypes.COLLECTIBLE_DOORWAY = Isaac.GetItemIdByName("The Doorway")
WarpZone.WarpZoneTypes.COLLECTIBLE_STRANGE_MARBLE = Isaac.GetItemIdByName("Strange Marble")
WarpZone.WarpZoneTypes.COLLECTIBLE_IS_YOU = Isaac.GetItemIdByName("Is You")
WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK = Isaac.GetItemIdByName("Nightmare Tick")
WarpZone.WarpZoneTypes.COLLECTIBLE_SPELUNKERS_PACK = Isaac.GetItemIdByName("Spelunker's Pack")
WarpZone.WarpZoneTypes.COLLECTIBLE_DIOGENES_POT = Isaac.GetItemIdByName("Diogenes's Pot")
WarpZone.WarpZoneTypes.COLLECTIBLE_DIOGENES_POT_LIVE = Isaac.GetItemIdByName(" Diogenes's Pot ")
WarpZone.WarpZoneTypes.COLLECTIBLE_GEORGE = Isaac.GetItemIdByName("George")
WarpZone.WarpZoneTypes.COLLECTIBLE_POSSESSION = Isaac.GetItemIdByName("Possession")
WarpZone.WarpZoneTypes.COLLECTIBLE_LOLLIPOP = Isaac.GetItemIdByName("Lollipop")
WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_FULL = Isaac.GetItemIdByName("Water Bottle")
WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_MID = Isaac.GetItemIdByName(" Water Bottle ")
WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_LOW = Isaac.GetItemIdByName("  Water Bottle  ")
WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_EMPTY = Isaac.GetItemIdByName("   Water Bottle   ")
WarpZone.WarpZoneTypes.COLLECTIBLE_AUBREY = Isaac.GetItemIdByName("Aubrey")
WarpZone.WarpZoneTypes.COLLECTIBLE_TONY = Isaac.GetItemIdByName("Tony")
WarpZone.WarpZoneTypes.COLLECTIBLE_REAL_LEFT = Isaac.GetItemIdByName("The Real Left Hand")
WarpZone.WarpZoneTypes.COLLECTIBLE_HITOPS = Isaac.GetItemIdByName("Hitops")
WarpZone.WarpZoneTypes.COLLECTIBLE_POPPOP = Isaac.GetItemIdByName("Pop Pop")
WarpZone.WarpZoneTypes.COLLECTIBLE_FOOTBALL = Isaac.GetItemIdByName("Football")
WarpZone.WarpZoneTypes.COLLECTIBLE_BALL_OF_TUMORS = Isaac.GetItemIdByName("Ball of Tumors")
WarpZone.WarpZoneTypes.COLLECTIBLE_BOW_AND_ARROW = Isaac.GetItemIdByName("Bow and Arrow")
WarpZone.WarpZoneTypes.COLLECTIBLE_TEST_ACTIVE = Isaac.GetItemIdByName("Test Active")
WarpZone.WarpZoneTypes.COLLECTIBLE_EMERGENCY_MEETING = Isaac.GetItemIdByName("Emergency Meeting")
WarpZone.WarpZoneTypes.COLLECTIBLE_BOXING_GLOVE = Isaac.GetItemIdByName("Boxing Glove")
WarpZone.WarpZoneTypes.COLLECTIBLE_GRAVITY = Isaac.GetItemIdByName("Gravity")
WarpZone.WarpZoneTypes.COLLECTIBLE_JOHNNYS_KNIVES = Isaac.GetItemIdByName("Johnny's Knives")
WarpZone.WarpZoneTypes.COLLECTIBLE_SER_JUNKAN = Isaac.GetItemIdByName("Ser Junkan")


WarpZone.WarpZoneTypes.TRINKET_RING_SNAKE = Isaac.GetTrinketIdByName("Ring of the Snake")
WarpZone.WarpZoneTypes.TRINKET_HUNKY_BOYS = Isaac.GetTrinketIdByName("Hunky Boys")
WarpZone.WarpZoneTypes.TRINKET_BIBLE_THUMP = Isaac.GetTrinketIdByName("Bible Thump")
WarpZone.WarpZoneTypes.TRINKET_CHEEP_CHEEP = Isaac.GetTrinketIdByName("Cheep Cheep")

WarpZone.WarpZoneTypes.CARD_COW_TRASH_FARM = Isaac.GetCardIdByName("CowOnTrash")
WarpZone.WarpZoneTypes.CARD_LOOT_CARD = Isaac.GetCardIdByName("LootCard")
WarpZone.WarpZoneTypes.CARD_BLANK = Isaac.GetCardIdByName("Blank")
WarpZone.WarpZoneTypes.CARD_BLANK_2 = Isaac.GetCardIdByName("Blank2")
WarpZone.WarpZoneTypes.CARD_BLANK_3 = Isaac.GetCardIdByName("Blank3")
WarpZone.WarpZoneTypes.CARD_JESTER_CUBE = Isaac.GetCardIdByName("JesterCube")
WarpZone.WarpZoneTypes.CARD_WITCH_CUBE = Isaac.GetCardIdByName("WitchCube")
WarpZone.WarpZoneTypes.CARD_MURDER = Isaac.GetCardIdByName("MurderCard")
WarpZone.WarpZoneTypes.CARD_AMBER_CHUNK = Isaac.GetCardIdByName("AmberChunk")
WarpZone.WarpZoneTypes.CARD_DEMON_FORM = Isaac.GetCardIdByName("DemonForm")
WarpZone.WarpZoneTypes.CARD_FIEND_FIRE = Isaac.GetCardIdByName("FiendFire")


WarpZone.WarpZoneTypes.SOUND_POP_POP = Isaac.GetSoundIdByName("PopPop_sound")
WarpZone.WarpZoneTypes.SOUND_COW_TRASH = Isaac.GetSoundIdByName("TrashFarm")
WarpZone.WarpZoneTypes.SOUND_EMERGENCY_MEETING = Isaac.GetSoundIdByName("EmergencyMeetingSound")
WarpZone.WarpZoneTypes.SOUND_MURDER_STING = Isaac.GetSoundIdByName("MurderSting")
WarpZone.WarpZoneTypes.SOUND_MURDER_KILL = Isaac.GetSoundIdByName("MurderKillSnd")

--external item descriptions
if EID then
	EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_GOLDENIDOL, "#The player has a 50% chance of receiving a fading nickel when a room is cleared#Damage causes the player to lose half their money, dropping some of it on the ground as fading coins.#When the player is holding money, damage is always 1 full heart", "Golden Idol", "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_PASTKILLER, "#Removes the first 3 items from your inventory, including quest items like the Key Pieces#3 sets of 3 choice pedestals appear#The new items are from the same pools as the ones you lost", "Gun that can Kill the Past", "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BIRTHDAY_CAKE, "{{ArrowUp}} +1 HP#A random consumable and pickups of each type now spawn at the start of a floor#When the player holds Binge Eater, -.03 Speed and +.5 Tears", "Birthday Cake", "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON, "#10% chance to fire a homing tear that inflicts bleed#100% chance at 18 Luck", "Rusty Spoon", "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NEWGROUNDS_TANK, "{{ArrowDown}} +0.3 Speed Down#{{ArrowUp}} +0.27 Tears Up#{{ArrowUp}} +0.5 Damage Up#{{ArrowUp}} +1 Range Up#{{ArrowUp}} +0.16 Shot Speed Up#{{ArrowUp}} +1 Luck Up#On taking a hit, the player has a 10% chance to shield from damage", "Newgrounds Tank", "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_GREED_BUTT, "#When hit by an enemy or projectile from behind, you fart, launching a coin out of your butt#There is a 4% chance that you drop a gold poop instead", "Greed Butt", "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS, "#When below full red hearts, heal 1 red heart#When at full health, launch a large piercing tear#This item only gains charge by inflicting damage", "Focus", "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_2, "#When below full red hearts, heal 1 red heart#When at full health, launch a large piercing tear#This item only gains charge by inflicting damage", "Focus", "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_3, "#When below full red hearts, heal 1 red heart#When at full health, launch a large piercing tear#This item only gains charge by inflicting damage", "Focus", "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_4, "#When below full red hearts, heal 1 red heart#When at full health, launch a large piercing tear#This item only gains charge by inflicting damage", "Focus", "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_DOORWAY, "#All doors are opened, and stay open for the rest of the floor#Secret rooms, Angel/Devil rooms, The Mega Satan door, Boss Rush and Hush are included#Challenge Rooms are open to enter, however the door closes when activating the challenge#The Ultra Secret Room is unlocked, and red rooms are now open to the edge of the map, revealing the error room", "The Doorway", "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_STRANGE_MARBLE, "#All enemies have a 1 in 8 chance to become champions#Champions always drop loot, and often have a chance to drop extra", "Strange Marble", "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_IS_YOU, "#Point the reticle at an obstacle to use an active item effect that corresponds to it#For example, pointing it at a normal rock lets you use Mom's Bracelet", "Is You",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK, "#Every 8 room clears, one passive item is removed from your inventory#.75 Damage Up for each item removed this way", "Nightmare Tick",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_SPELUNKERS_PACK, "#+12 bombs#Pits within your bombs' blast radius are filled in#When your bomb explodes, the resonant force breaks tinted and super secret rocks throughout the room #Bomb rocks in the room will break apart, dropping a bomb pickup", "Spelunker's Pack",  "en_us")

    EID:addTrinket(WarpZone.WarpZoneTypes.TRINKET_RING_SNAKE, "#Receive 2 cards at the start of each floor", "Ring of the Snake", "en_us")

    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_DIOGENES_POT, "Toggles a melee hammer strike on and off#When equipped, you receive a 1.5x damage multiplier#Getting hit while equipped teleports you to the starting room", "Diogenes's Pot",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_DIOGENES_POT_LIVE, "Toggles a melee hammer strike on and off#When equipped, you receive a 1.5x damage multiplier#Getting hit while equipped teleports you to the starting room", "Diogenes's Pot",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_GEORGE, "{{ArrowUp}} 2.4 Range Up#When entering most special rooms, a red room will unlock across from you", "George",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_POSSESSION, "Each room, one random non-boss enemy will be permanently charmed#These enemies carry over between rooms#Only 15 enemies can be charmed at a time#Taking damage (excluding sacrifice rooms, etc) removes the charm from all affected enemies, making them hostile again", "Possession",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_LOLLIPOP, "Spawns a lollipop orbital. It does no damage, but it charms enemies on contact", "Lollipop",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_EMPTY, "I did not hit her#It is bullshit#I did not hit her#I did not", "Water Bottle",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_LOW, "{{ArrowUp}} 0.22 Tears Up#{{ArrowUp}} Tear Size Up", "Water Bottle",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_MID, "{{ArrowUp}} 0.37 Tears Up#{{ArrowUp}} Tear Size Up", "Water Bottle",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_FULL, "{{ArrowUp}} 0.43 Tears Up#{{ArrowUp}} Tear Size Up", "Water Bottle",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_AUBREY, "Once per floor, when entering a shop, a weapon beggar will spawn.#Weapon beggars take coins, and spawn only active items from every pool.#3 active items are spawned from one weapon beggar before it leaves.", "Aubrey",  "en_us")

    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY, "1.7 Damage Multiplier#+1 Damage Up#When any item is taken, the buff and multiplier are both reduced by 0.1#This item's minimum damage multiplier is 1, it cannot decrease damage", "Tony",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_REAL_LEFT, "On use, rerolls all chests in the room into a better counterpart#Chest Order: Mimic -> Haunted -> Grey -> Red -> Golden or Stone -> Wooden or Old -> Eternal -> Mega", "The Real Left Hand",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_HITOPS, "0.2 Speed Up#This speed up can exceed the speed cap", "Hitops",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_POPPOP, "Double tap to fire two 3x damage tears in a burst#Tear rate is reduced for a short time after using this effect.", "Pop Pop",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_FOOTBALL, "Spawns a football familiar that can be picked up and thrown at enemies#The football deals damage based on its speed", "Football",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BALL_OF_TUMORS, "Bombs, hearts, keys and batteries have a small chance of turning into collectible tumors#Collecting tumors powers a tumor orbital, which blocks shots and deals contact damage#With enough tumors, a second orbital will spawn", "Ball of Tumors",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOW_AND_ARROW, "Isaac is able to shoot large, piercing arrow tears that deal 1.5x damage, but have only 3 ammunition#Once the ammo is depleted, Isaac fires normal tears#When a tear lands, it drops a token that will replenish 1 tear when collected", "Bow and Arrow",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_EMERGENCY_MEETING, "On use, teleports you and all other enemies in the room to the starting room.#On arrival, all enemies, including bosses, are confused for a few seconds", "Emergency Meeting",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOXING_GLOVE, "Gain a charged punching attack with a 2.35 second charge time#The punch has high knockback and stuns enemies", "Boxing Glove",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_GRAVITY, "On use, you fall up to the ceiling for about 5 seconds.#While in this state, gain flight, invulnerability, and +6.25 Range#Tears rain down from the top of the screen, regardless of the fired direction.", "Gravity",  "en_us")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_JOHNNYS_KNIVES, "Gain two knife familiars that do damage on contact#When killing enemies with the knives, spawn a pool of red creep that damages enemies. The size of the creep depends on the enemy's mass.#While standing in blood, gain +0.61 Tears.", "Johnny's Knives",  "en_us")

    EID:addTrinket(WarpZone.WarpZoneTypes.TRINKET_HUNKY_BOYS, "While held, pressing the Drop Trinket button immediately drops this trinket; you don't need to hold the button#When on the ground, enemies will target the trinket for a short time.", "Hunky Boys", "en_us")
    EID:addTrinket(WarpZone.WarpZoneTypes.TRINKET_BIBLE_THUMP, "Once you exit a room with this trinket, The Bible is added to several item pools.#Using The Bible or The Devil? card with this item will deal 40 damage to all enemies in the room, in addition to granting flight.#Using The Bible on Satan will kill him, and you will survive#The golden version of this trinket kills The Lamb as well.", "Bible Thump", "en_us")
    EID:addTrinket(WarpZone.WarpZoneTypes.TRINKET_CHEEP_CHEEP, "On entering a room, a random enemy is targeted by other enemies and has a fear effect for 3 seconds.#If the effect is golden, the target also bleeds.", "Cheep Cheep", "en_us")

    EID:addCard(WarpZone.WarpZoneTypes.CARD_COW_TRASH_FARM, "Rerolls all items into fly themed items#Rerolls pickups into blue flies#Does not actually become back your money", "Cow on a Trash Farm", "en_us")
    EID:addCard(WarpZone.WarpZoneTypes.CARD_LOOT_CARD, "Randomly spawns a random item or trinket from any pool", "Loot Card", "en_us")
    EID:addCard(WarpZone.WarpZoneTypes.CARD_BLANK, "Clears all enemy projectiles in the room.#Pushes nearby enemies away#There is one use left", "Blank", "en_us")
    EID:addCard(WarpZone.WarpZoneTypes.CARD_BLANK_2, "Clears all enemy projectiles in the room.#Pushes nearby enemies away#There are two uses left", "Blank", "en_us")
    EID:addCard(WarpZone.WarpZoneTypes.CARD_BLANK_3, "Clears all enemy projectiles in the room.#Pushes nearby enemies away#You can use this 3 times before it disappears", "Blank", "en_us")
    EID:addCard(WarpZone.WarpZoneTypes.CARD_JESTER_CUBE, "On use, all items in the room will cycle between 6 additional choices, similar to Glitched Crown", "Jester", "en_us")
    EID:addCard(WarpZone.WarpZoneTypes.CARD_WITCH_CUBE, "50% chance to deal 40 damage to all enemies in the room and apply burn.#50% chance to spawn another Witch card and fire off a poison fart", "Witch", "en_us")
    EID:addCard(WarpZone.WarpZoneTypes.CARD_MURDER, "For a quarter second, increase speed to 4 and kill everything you touch.#Gain a Stompy effect for the room", "Murder!", "en_us")
    EID:addCard(WarpZone.WarpZoneTypes.CARD_AMBER_CHUNK, "All pickups in the room, including items and the final chest at the end of the game, will be removed and saved.#The previous items you consumed in this way will respawn, even across games#You will also receive a lucky penny", "Chunk of Amber", "en_us")
    EID:addCard(WarpZone.WarpZoneTypes.CARD_FIEND_FIRE, "All pickups in the room are consumed#For each pickup consumed, gain a small, permanent boost to Damage, Tears, Luck, Range, or Speed#Pickups turn into fires, which can damage enemies.", "Fiend Fire", "en_us")
    EID:addCard(WarpZone.WarpZoneTypes.CARD_DEMON_FORM, "For the current room, Isaac becomes Azazel#+1 Damage#If you already have a brimstone laser, it will be widened from the current room", "Demon Form", "en_us")
    
    local CardHuds = {}
    CardHuds.CowHud = Sprite()
    CardHuds.CowHud:Load("gfx/cards_1_cow_on_trash.anm2", true)
    EID:addIcon("Card" .. tostring(WarpZone.WarpZoneTypes.CARD_COW_TRASH_FARM), "HUDSmall", 0, 16, 16, 6, 6, CardHuds.CowHud)
    CardHuds.LootCard = Sprite()
    CardHuds.LootCard:Load("gfx/cards_2_lootcard.anm2", true)
    EID:addIcon("Card" .. tostring(WarpZone.WarpZoneTypes.CARD_LOOT_CARD), "HUDSmall", 0, 16, 16, 6, 6, CardHuds.LootCard)
    CardHuds.Blank1 = Sprite()
    CardHuds.Blank1:Load("gfx/cards_3_blank.anm2", true)
    EID:addIcon("Card" .. tostring(WarpZone.WarpZoneTypes.CARD_BLANK), "HUDSmall", 0, 16, 16, 6, 6, CardHuds.Blank1)
    CardHuds.Blank2 = Sprite()
    CardHuds.Blank2:Load("gfx/cards_3.1_blank.anm2", true)
    EID:addIcon("Card" .. tostring(WarpZone.WarpZoneTypes.CARD_BLANK_2), "HUDSmall", 0, 16, 16, 6, 6, CardHuds.Blank2)
    CardHuds.Blank3 = Sprite()
    CardHuds.Blank3:Load("gfx/cards_3.2_blank.anm2", true)
    EID:addIcon("Card" .. tostring(WarpZone.WarpZoneTypes.CARD_BLANK_3), "HUDSmall", 0, 16, 16, 6, 6, CardHuds.Blank3)
    CardHuds.Jester = Sprite()
    CardHuds.Jester:Load("gfx/cards_4_jestercube.anm2", true)
    EID:addIcon("Card" .. tostring(WarpZone.WarpZoneTypes.CARD_JESTER_CUBE), "HUDSmall", 0, 16, 16, 6, 6, CardHuds.Jester)
    CardHuds.Witch = Sprite()
    CardHuds.Witch:Load("gfx/cards_5_witchcube.anm2", true)
    EID:addIcon("Card" .. tostring(WarpZone.WarpZoneTypes.CARD_WITCH_CUBE), "HUDSmall", 0, 16, 16, 6, 6, CardHuds.Witch)
    CardHuds.Murder = Sprite()
    CardHuds.Murder:Load("gfx/cards_6_murdercard.anm2", true)
    EID:addIcon("Card" .. tostring(WarpZone.WarpZoneTypes.CARD_MURDER), "HUDSmall", 0, 16, 16, 6, 6, CardHuds.Murder)
    CardHuds.AmberChunk = Sprite()
    CardHuds.AmberChunk:Load("gfx/cards_7_amberchunk.anm2", true)
    EID:addIcon("Card" .. tostring(WarpZone.WarpZoneTypes.CARD_AMBER_CHUNK), "HUDSmall", 0, 16, 16, 6, 6, CardHuds.AmberChunk)
    CardHuds.DemonForm = Sprite()
    CardHuds.DemonForm:Load("gfx/cards_8_slaycard.anm2", true)
    EID:addIcon("Card" .. tostring(WarpZone.WarpZoneTypes.CARD_DEMON_FORM), "HUDSmall", 0, 16, 16, 6, 6, CardHuds.DemonForm)
    CardHuds.FiendFire = Sprite()
    CardHuds.FiendFire:Load("gfx/cards_8_slaycard.anm2", true)
    EID:addIcon("Card" .. tostring(WarpZone.WarpZoneTypes.CARD_FIEND_FIRE), "HUDSmall", 0, 16, 16, 6, 6, CardHuds.FiendFire)


    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_GOLDENIDOL, "Зачистка комнаты имеет 50% шанс оставить никель, пропадающий через 2 секунды.#При получении урона игрок теряет половину своих монет, и бросает на пол эти монеты (они пропадают через 1 секунду).#Если у игрока есть монеты, урон будет в полное сердце.", "Золотой Идол", "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_PASTKILLER, "Удаляет первые три предмета,полученных в забеге (Может удалить сюжетные предметы).#Создает по три пьедестала с предметами из того же пула за каждый потерянный предмет, из 3х предметов можно взять только 1.#The new items are from the same pools as the ones you lost.", "Пушка, Убивающая Прошлое", "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BIRTHDAY_CAKE, "{{ArrowUp}} +1 Контейнер Сердца #Случайная карта/пилюля/руна, случайная монета, бомба и ключ появляются в начале каждого этажа.#Предмет еды, С Кутежником дает -.03 скорости и +.5 скорострельности.", "Именинный Торт", "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON, "10% шанс выстрелить самонаводящейся слезой, накладывающей кровотечение#100% шанс при 18 удачи", "Ржавая Ложка", "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NEWGROUNDS_TANK, "{{ArrowDown}}  -.3 Скорости#{{ArrowUp}} +.27 Скорострельности#{{ArrowUp}} +.5 Урона#{{ArrowUp}} +.04 Дальности#{{ArrowUp}} +.16 Скорости слезы#{{ArrowUp}} +1 Удачи#При получении урона, 10% шанс предотвратить его.", "Танк Newgrounds", "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_GREED_BUTT, "При получении урона в зад, персонаж пукает и выпускает монетку.#4% шанс создать золотую кучку вместо пука с монетой.", "Алчная Жопа!", "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS, "Если у вас не полное здоровье, вылечи 1 красное сердце.#При полном здоровье, выпусти большую слезу, наносящую большой урон, проходящую сквозь врагов.#Этот предмет заряжается нанесением урона.", "Фокус", "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_2, "Если у вас не полное здоровье, вылечи 1 красное сердце.#При полном здоровье, выпусти большую слезу, наносящую большой урон, проходящую сквозь врагов.#Этот предмет заряжается нанесением урона", "Фокус", "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_3, "Если у вас не полное здоровье, вылечи 1 красное сердце.#При полном здоровье, выпусти большую слезу, наносящую большой урон, проходящую сквозь врагов.#Этот предмет заряжается нанесением урона", "Фокус", "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_4, "Если у вас не полное здоровье, вылечи 1 красное сердце.#При полном здоровье, выпусти большую слезу, наносящую большой урон, проходящую сквозь врагов.#Этот предмет заряжается нанесением урона", "Фокус", "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_DOORWAY, "Все двери открываются, и остаются открытыми до конца этажа.#Открываются Секретные комнаты, комнаты Ангела/Дьявола, Дверь Мега Сатаны, Двери Испытания Боссов и Молчания (Если они на этом этаже).#Комнаты испытания открыты, но дверь закрывается на время прохождения испытания.#Открывает Ультра Секретную комнату и проход к ней, так же открывает проход к комнате Ошибки, открывая красные комнаты через Ультра секретную комнату до края карты.", "Проход", "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_STRANGE_MARBLE, "Все враги с 10% шансом могут стать чемпионами.#Чемпионы всегда оставляют награду, и могут оставить дополнительную.", "Странный Марбл", "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_IS_YOU, "Создает крестик под персонажем, который надо направлять на препятствия (Камни, Блоки и т.д.).#После этого, нужно еще раз активировать предмет для срабатывания эффекта. У каждого обьекта свой эффект.", "Это Ты",  "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK, "Каждые 8 зачисток комнат, Один предмет пропадает из инвентаря.#+.75 Урона за пропавший предмет", "Кошмарный Клещ",  "ru")
    EID:addCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_SPELUNKERS_PACK, "+12 бомб#Все ямы в радиусе взрыва заполняются.#При взрыве бомбы, Все меченые и двойные меченые камни взорвутся не смотря на то что они вне радиуса взрыва. #Камни с бомбами сломаются и оставят бомбу на их месте.", "Рюкзак Спелеолога",  "ru")

end




--util functions

local function swapOutActive(activeToAdd, slot, player, charge)
    local activeToRemove = player:GetActiveItem(slot)
    player:RemoveCollectible(activeToRemove, true, slot, true)
    player:AddCollectible(activeToAdd, charge, false, slot)
end

local function isNil(value, replacement)
    if value == nil then
        return replacement
    else
        return value
    end
end

local function getDirectionFromVector(vector)
    if vector.X == 0 and vector.Y == 1 then
        return Direction.DOWN
    elseif vector.X == 0 and vector.Y == -1 then
        return Direction.UP
    elseif vector.X == 1 and vector.Y == 0 then
        return Direction.RIGHT
    elseif vector.X == -1 and vector.Y == 0 then
        return Direction.LEFT
    end
end

local function getVectorFromDirection(dir)
    if dir == Direction.DOWN then
        return Vector(0, 1)
    elseif dir == Direction.UP then
        return Vector(0, -1)
    elseif dir == Direction.RIGHT then
        return Vector(1, 0)
    elseif Direction.LEFT then
        return Vector(-1, 0)
    end
end

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

function WarpZone:refreshItemsTaken()
    WarpZone.AnyPlayerDo(function(player)
        
        local data = player:GetData()
        if data.WarpZone_data and data.WarpZone_data.LastTotalItems ~= player:GetCollectibleCount() then
            print("refresh'd")
            data.WarpZone_data.LastTotalItems = player:GetCollectibleCount()
            local itemConfig = Isaac:GetItemConfig()
            for itemID=1, itemConfig:GetCollectibles().Size-1 do
                local item = itemConfig:GetCollectible(itemID)
                local pool = game:GetItemPool():GetLastPool()
                if item and item.Type ~= ItemType.ITEM_ACTIVE and not item:HasTags(ItemConfig.TAG_QUEST) and player:HasCollectible(itemID, true) then
                    data.WarpZone_data.itemsTaken = isNil(data.WarpZone_data.itemsTaken, {})
                    data.WarpZone_data.poolsTaken = isNil(data.WarpZone_data.poolsTaken, {})
                    if tableContains(data.WarpZone_data.itemsTaken, itemID) == false then
                        table.insert(data.WarpZone_data.itemsTaken, itemID)
                        table.insert(data.WarpZone_data.poolsTaken, pool)
                    end
                end
            end
        end
    end
    )
end

local function doesAnyoneHave(itemtype, trinket)
    local numPlayers = game:GetNumPlayers()
    local hasIt = nil
    for i=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(i)
        if trinket == true then
            if player:HasTrinket(itemtype) then
                hasIt = player
            end
        else
            if player:HasCollectible(itemtype) and (hasIt == nil or (hasIt and hasIt:GetCollectibleNum(itemtype) < player:GetCollectibleNum(itemtype))) then
                hasIt = player
            end
        end
        
    end
    return hasIt
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
            local create_entity = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.CUBE_BABY, 0, game:GetRoom():FindFreePickupSpawnPosition(game:GetRoom():GetCenterPos()), Vector(0,0), nil)
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
    local room = game:GetRoom()
    local bestTask
    local floor = game:GetLevel():GetStage()
    local floortype = game:GetLevel():GetStageType()
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
                elseif game:IsGreedMode() then
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
                elseif not game:IsGreedMode() then
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
    local room = game:GetRoom()
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
    ---@type EntityTear
    local tear = player:FireTear(player.Position, direction, false, false, true, nil, 1)
    local spr = tear:GetSprite()
    tear:ChangeVariant(TearVariant.CUPID_BLUE)
    spr:Load("gfx/promo/gfuel/bullet tear.anm2",true)
    spr:Play(spr:GetDefaultAnimation())
    tear:ResetSpriteScale()
    tear.Scale = tear.Scale * 1.75
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        tear.CollisionDamage = tear.CollisionDamage * 5
    else
        tear.CollisionDamage = tear.CollisionDamage * 3
    end
    if playYV then
        SfxManager:Play(WarpZone.WarpZoneTypes.SOUND_POP_POP, 1)
    end

    SfxManager:Play(SoundEffect.SOUND_GFUEL_GUNSHOT, 2)
end

local FamAsPlayer = {
    [FamiliarVariant.INCUBUS] = true,
    [FamiliarVariant.SPRINKLER] = true,
    [FamiliarVariant.TWISTED_BABY] = true,
    [FamiliarVariant.BLOOD_BABY] = true,
    [FamiliarVariant.UMBILICAL_BABY] = true,
    [FamiliarVariant.CAINS_OTHER_EYE] = true,
}
function WarpZone.TryGetPlayer(spawner)
    if not spawner then return end
    local player
    if spawner:ToPlayer() then
        player = spawner:ToPlayer()
    elseif spawner:ToFamiliar() and spawner:ToFamiliar().Player then
        if FamAsPlayer[spawner.Variant] then
            player = spawner:ToFamiliar().Player
        end
    end
    return player
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
            --@type EntityNPC
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
            --@type EntityPlayer
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
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, game:GetItemPool():GetCard(rng:GetSeed(), true, false, false), npc.Position, Vector(0, 0), npc)
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
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, game:GetItemPool():GetCard(rng:GetSeed(), false, true, true), npc.Position, Vector(0, 0), npc)
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
            --@type EntityPlayer
            local player = playerRef.Entity:ToPlayer()
            for i = 0, 2 do
                player:AddBlueSpider(player.Position)
            end
        end,
        [ChampionColor.TINY] = function (ref, rng)
            local npc = ref.Entity
            local pool = game:GetItemPool()
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, pool:ForceAddPillEffect(PillEffect.PILLEFFECT_SMALLER), npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.GIANT] = function (ref, rng)
            local npc = ref.Entity
            local pool = game:GetItemPool()
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, pool:ForceAddPillEffect(PillEffect.PILLEFFECT_LARGER), npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.PULSE_RED] = function (ref, rng)
            local npc = ref.Entity
            game:SpawnParticles(npc.Position, EffectVariant.PLAYER_CREEP_RED, 10, 0, Color(1, 0, 0, 1, 0, 0, 0), 0)
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
            game:Fart(npc.Position)
        end,
        [ChampionColor.RAINBOW] = function (ref, rng)
            local npc = ref.Entity
            local game = game
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE, npc.Position, Vector(0, 0), npc)
        end
    }


 --callbacks

function WarpZone:OnUpdate()
    local numFrames = game:GetFrameCount()
    if numFrames % 60 == 0 then
        local entities = Isaac.GetRoomEntities()
        local targetPos = {}
        local random = myRNG:RandomInt(20)
        for i, entity in ipairs(entities) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_TRINKET and entity.SubType == WarpZone.WarpZoneTypes.TRINKET_HUNKY_BOYS then
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
                    local player = game:GetNearestPlayer(entity.Position)
                    if player and (math.abs((target.Position - entity.Position):LengthSquared()) < math.abs((player.Position - entity.Position):LengthSquared())) or random > 15 then
                        entity.Target = target
                        entity:GetData().distracted = 3
                    end
                end
            end
        end
    end
    WarpZone:refreshItemsTaken()

    local marblePlayer = doesAnyoneHave(WarpZone.WarpZoneTypes.COLLECTIBLE_STRANGE_MARBLE, false)
    if marblePlayer ~= nil then
        local fires = Isaac.FindByType(EntityType.ENTITY_FIREPLACE)
        for i, fire in ipairs(fires) do
            local data = fire:GetData()
            if not data.WarpZone_data then
                data.WarpZone_data = {}
            end
            if (fire:GetSprite():IsPlaying("Dissapear") or fire:GetSprite():IsPlaying("Dissapear2") or fire:GetSprite():IsPlaying("Dissapear3")) and
                data.WarpZone_data.FireMined ~= true and fire:ToNPC() and fire:ToNPC():IsChampion() == true then
                data.WarpZone_data.FireMined = true
                local championColor = fire:ToNPC():GetChampionColorIdx()
                local rng = marblePlayer:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_STRANGE_MARBLE)
                ChampionsToLoot[championColor](EntityRef(fire), rng, EntityRef(marblePlayer))
            end
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_UPDATE, WarpZone.OnUpdate)

function WarpZone:SpelunkerBombEffect(position)
    local room = game:GetRoom()
    local numBridged = 0
    local resonate = false
	for i=1, room:GetGridSize() do
        local ge = room:GetGridEntity(i)
        if ge and ge.Desc.Type == GridEntityType.GRID_PIT then
            local distance = position:Distance(ge.Position)    -- math.abs((position - ge.Position):LengthSquared())
            if distance <= 100 then --10000
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
        game:ShakeScreen(2)
    end
end

WarpZone.DoubleTapCallback = {
    {function(player, direction) --pop pop
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_POPPOP) then
            local data = player:GetData()
            data.WarpZone_unsavedata = data.WarpZone_unsavedata or {}
            --if data.WarpZone_unsavedata.arrowTimeDelay <= 0 then
                data.WarpZone_data.arrowTimeDelay = totalFrameDelay
                firePopTear(player, true)
                data.WarpZone_data.arrowTimeThreeFrames = 6
                --return true --reset delay
            --end
        end
    end, totalFrameDelay}
}


---@param player EntityPlayer
function WarpZone:postRender(player)
	local actions = player:GetLastActionTriggers()
    local data = player:GetData()
    local controllerid = player.ControllerIndex
    if not game:IsPaused() then
        if player:HasTrinket(WarpZone.WarpZoneTypes.TRINKET_HUNKY_BOYS) and Input.IsActionTriggered(ButtonAction.ACTION_DROP, controllerid) then
            --player:DropTrinket(player.Position)
            player:TryRemoveTrinket(WarpZone.WarpZoneTypes.TRINKET_HUNKY_BOYS)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, WarpZone.WarpZoneTypes.TRINKET_HUNKY_BOYS, player.Position, Vector(0, 0), nil)
            
        end
        if not data.WarpZone_data then
            data.WarpZone_data = {}
        end
        if actions & ActionTriggers.ACTIONTRIGGER_ITEMACTIVATED > 0 then
            data.WarpZone_data.timeSinceTheSpacebarWasLastPressed = 0
        else
            data.WarpZone_data.timeSinceTheSpacebarWasLastPressed = data.WarpZone_data.timeSinceTheSpacebarWasLastPressed + 1
        end
        
        if player.ControlsEnabled then
            data.WarpZone_unsavedata.DoubleTapDelays = data.WarpZone_unsavedata.DoubleTapDelays or {}
            for i=1, #WarpZone.DoubleTapCallback do
                local callback = WarpZone.DoubleTapCallback[i]
                if not data.WarpZone_unsavedata.DoubleTapDelays[i] then
                    data.WarpZone_unsavedata.DoubleTapDelays[i] = callback[2]
                else
                    data.WarpZone_unsavedata.DoubleTapDelays[i] = data.WarpZone_unsavedata.DoubleTapDelays[i] - 1
                end
            end

        --if data.WarpZone_data.arrowTimeDelay <= 0 then
            if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, controllerid) then --and player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_POPPOP)
                if data.WarpZone_unsavedata.arrowTimeUp > 0 then
                    --data.WarpZone_data.arrowTimeDelay = totalFrameDelay
                    --firePopTear(player, true)
                    --data.WarpZone_data.arrowTimeThreeFrames = 6
                    for i=1, #WarpZone.DoubleTapCallback do
                        local callback = WarpZone.DoubleTapCallback[i]
                        if data.WarpZone_unsavedata.DoubleTapDelays[i] <= 0 then
                            callback[1](player, Vector(0,-1))
                            data.WarpZone_unsavedata.DoubleTapDelays[i] = callback[2]
                        end
                    end
                else
                    data.WarpZone_unsavedata.arrowTimeUp = 30
                end
            elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, controllerid) then
                if data.WarpZone_unsavedata.arrowTimeDown > 0 then
                    --data.WarpZone_data.arrowTimeDelay = totalFrameDelay
                    --firePopTear(player, true)
                    --data.WarpZone_data.arrowTimeThreeFrames = 6
                    for i=1, #WarpZone.DoubleTapCallback do
                        local callback = WarpZone.DoubleTapCallback[i]
                        if data.WarpZone_unsavedata.DoubleTapDelays[i] <= 0 then
                            callback[1](player, Vector(0,1))
                            data.WarpZone_unsavedata.DoubleTapDelays[i] = callback[2]
                        end
                    end
                else
                    data.WarpZone_unsavedata.arrowTimeDown = 30
                end
            elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, controllerid) then
                if data.WarpZone_unsavedata.arrowTimeLeft > 0 then
                    --data.WarpZone_data.arrowTimeDelay = totalFrameDelay
                    --firePopTear(player, true)
                    --data.WarpZone_data.arrowTimeThreeFrames = 6
                    for i=1, #WarpZone.DoubleTapCallback do
                        local callback = WarpZone.DoubleTapCallback[i]
                        if data.WarpZone_unsavedata.DoubleTapDelays[i] <= 0 then
                            callback[1](player, Vector(1,0))
                            data.WarpZone_unsavedata.DoubleTapDelays[i] = callback[2]
                        end
                    end
                else
                    data.WarpZone_unsavedata.arrowTimeLeft = 30
                end
            elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, controllerid) then
                if data.WarpZone_unsavedata.arrowTimeRight > 0 then
                    --data.WarpZone_data.arrowTimeDelay = totalFrameDelay
                    --firePopTear(player, true)
                    --data.WarpZone_data.arrowTimeThreeFrames = 6
                    for i=1, #WarpZone.DoubleTapCallback do
                        local callback = WarpZone.DoubleTapCallback[i]
                        if data.WarpZone_unsavedata.DoubleTapDelays[i] <= 0 then
                            callback[1](player, Vector(-1,0))
                            data.WarpZone_unsavedata.DoubleTapDelays[i] = callback[2]
                        end
                    end
                else
                    data.WarpZone_unsavedata.arrowTimeRight = 30
                end
            end
        end
        data.WarpZone_unsavedata.arrowTimeUp = data.WarpZone_unsavedata.arrowTimeUp - 1
        data.WarpZone_unsavedata.arrowTimeDown = data.WarpZone_unsavedata.arrowTimeDown - 1
        data.WarpZone_unsavedata.arrowTimeLeft = data.WarpZone_unsavedata.arrowTimeLeft - 1
        data.WarpZone_unsavedata.arrowTimeRight = data.WarpZone_unsavedata.arrowTimeRight - 1
        data.WarpZone_data.arrowTimeDelay = data.WarpZone_data.arrowTimeDelay - 1
        if data.WarpZone_data.arrowTimeDelay == 0 or data.WarpZone_data.arrowTimeDelay == totalFrameDelay-1 then
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOXING_GLOVE) and player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN and player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN_B then
            local maxThreshold = data.WarpZone_data.arrowHoldBox
            if Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, controllerid) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, controllerid) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, controllerid) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, controllerid) then
                data.WarpZone_data.arrowHoldBox = data.WarpZone_data.arrowHoldBox + 1
            else
                data.WarpZone_data.arrowHoldBox = 0
            end
            
            if maxThreshold > framesToCharge and data.WarpZone_data.arrowHoldBox == 0 then
                data.fireGlove = true
            end
        end

        if player and WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS == player:GetActiveItem() 
        and data.primeShot ~= nil and (Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, controllerid) or
        Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, controllerid) or
        Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, controllerid) or
        Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, controllerid))
        then
            local dir = player:GetLastDirection()
            print(dir)
            dir = dir * 16
            local tear = player:FireTear(player.Position, dir, false, true, true, player)
            SfxManager:Play(SoundEffect.SOUND_EXPLOSION_WEAK, 3)
            data.primeShot = nil
            tear:GetData().FocusShot = true
            tear:GetData().FocusIndicator = true
        end

    end
    local ticklostitem = data.WarpZone_unsavedata and data.WarpZone_unsavedata.TickLostItem
    if ticklostitem then
        local pos = Isaac.WorldToScreen(player.Position)
        pos.Y = pos.Y - ticklostitem.frame - 15
        ticklostitem.spr.Color = Color(1,1,1,1-ticklostitem.frame/60)
        ticklostitem.spr:Render(pos)
        ticklostitem.frame = ticklostitem.frame + 1
        if ticklostitem.frame > 60 then
            data.WarpZone_unsavedata.TickLostItem = nil
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, WarpZone.postRender)

---@param player EntityPlayer
---@param renderoffset any
function WarpZone:UIOnRender(player, renderoffset)
    local data = player:GetData()
    if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOW_AND_ARROW) then
        local numCollectibles = player:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_BOW_AND_ARROW)
        
        data.WarpZone_data.maxArrowNum = math.ceil(30 / (player.MaxFireDelay + 1)) * numCollectibles
        local numAroows = data.WarpZone_data.maxArrowNum
        for i = 1, numAroows , 1 do
            if data.WarpZone_data.numArrows - i >= 0 then
                ArrowHud:SetFrame("Lit", 0)
            else
                ArrowHud:SetFrame("Unlit", 0)
            end
            ArrowHud:RenderLayer(0,  Isaac.WorldToScreen(player.Position)+renderedPosition+player:GetFlyingOffset() + Vector((i) * 5 - (numAroows-.5)*2.5, 0))
        end
    end
    local currentCharge = data.WarpZone_data.arrowHoldBox
    if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOXING_GLOVE) and currentCharge > 0 and currentCharge <= framesToCharge then
        local frameToSet = math.floor(math.min(currentCharge * (100/framesToCharge), 100))
        BoxHud:SetFrame("Charging", frameToSet)
        BoxHud:Render(Isaac.WorldToScreen(player.Position) + boxRenderedPosition)
    elseif player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOXING_GLOVE) and currentCharge > framesToCharge then
        local frameToSet = math.floor(((currentCharge-framesToCharge))/2) % 6
        BoxHud:SetFrame("Charged", frameToSet)
        BoxHud:Render(Isaac.WorldToScreen(player.Position) + boxRenderedPosition)
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, WarpZone.UIOnRender)


function WarpZone:EnemyHit(entity, amount, damageflags, source, countdownframes)
    if entity:IsVulnerableEnemy() then
        local numPlayers = game:GetNumPlayers()
        for i=0, numPlayers-1, 1 do
            local player =  Isaac.GetPlayer(i)
            local data = player:GetData()
            local source_entity = source.Entity
            if source_entity and source_entity:GetData() and source_entity:GetData().FocusIndicator == nil and
                (WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS == player:GetActiveItem() or
                WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_2 == player:GetActiveItem() or
                WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_3 == player:GetActiveItem() or
                WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_4 == player:GetActiveItem()
                )
            then
                data.WarpZone_data.totalFocusDamage = data.WarpZone_data.totalFocusDamage + math.min(amount, entity.HitPoints)
                local chargeMax = (game:GetLevel():GetStage() * FocusChargeMultiplier * 40) + 60 * FocusChargeMultiplier
                local chargesToSet = math.floor((20 * data.WarpZone_data.totalFocusDamage)/chargeMax)
                local chargeThreshold = 20
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
                    chargeThreshold = 40
                end
                local pastCharge = player:GetActiveCharge()
                local newCharge = math.min(chargeThreshold, chargesToSet)

                if pastCharge <= 3  and 3 < newCharge and newCharge <= 10 then
                    swapOutActive(WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_2, ActiveSlot.SLOT_PRIMARY, player, newCharge)
                elseif pastCharge <= 10 and 10 < newCharge and newCharge <= 19 then
                    swapOutActive(WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_3, ActiveSlot.SLOT_PRIMARY, player, newCharge)
                elseif pastCharge <=19 and newCharge and newCharge >= 20 then
                    swapOutActive(WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_4, ActiveSlot.SLOT_PRIMARY, player, newCharge)
                    SfxManager:Play(SoundEffect.SOUND_BATTERYCHARGE)
                else
                    player:SetActiveCharge(newCharge)
                end
            end
        end
        
        local knives = Isaac.FindByType(EntityType.ENTITY_KNIFE)
        
        for i, knife in ipairs(knives) do
            if knife:GetData().isGloveObj ~= nil then
                if (knife.Position-entity.Position):Length() <= knife.Size + entity.Size + 50 then
                    local player = getPlayerFromKnifeLaser(knife)
                    if player then
                        entity.Friction = 0.55
                        entity.Mass = 5
                        local dir = player:GetLastDirection()
                        entity:AddVelocity(dir * 40)
                        entity:AddConfusion(EntityRef(knife), 90, true)
                        SfxManager:Play(SoundEffect.SOUND_PUNCH)
                        --return false
                    end
                end
            end
        end

        --[[if source and source.Entity and source.Entity.Type == EntityType.ENTITY_FAMILIAR and (source.Entity.Variant == KnifeVariantHappy or source.Entity.Variant == KnifeVariantSad) then
            if amount >= entity.HitPoints then
                local creepEntity = Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    EffectVariant.PLAYER_CREEP_RED,
                    0,
                    entity.Position,
                    Vector(0, 0),
                    nil
                )
                local massMultiplier = 1 + (isNil(entity.Mass, 20)/10)
                --creepEntity:ToEffect().Scale = creepEntity:ToEffect().Scale * massMultiplier
                creepEntity:ToEffect().Size = creepEntity:ToEffect().Size * massMultiplier
                creepEntity:GetSprite().Scale = creepEntity:GetSprite().Scale * massMultiplier
                creepEntity:GetSprite():Load("1000.022_creep (red).anm2")
            end
        end]]
    end
end
WarpZone:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, WarpZone.EnemyHit)



function WarpZone:OnTakeHit(entity, amount, damageflags, source, countdownframes)
    local player = entity:ToPlayer()
    if player == nil then
        return
    end
    
    if game:GetFrameCount() - isNil(player:GetData().MurderFrame, -999) < 15 then
        return false
    end

    if game:GetFrameCount() - isNil(player:GetData().InGravityState, -999) < 150 then
        return false
    end

    if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_POSSESSION) then
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

    if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NEWGROUNDS_TANK) then
        local rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_NEWGROUNDS_TANK)
        if rng:RandomInt(10) == 1 and  damageflags & DamageFlag.DAMAGE_NO_PENALTIES ~= DamageFlag.DAMAGE_NO_PENALTIES then
            SfxManager:Play(SoundEffect.SOUND_SCYTHE_BREAK)
            player:SetMinDamageCooldown(60)
            return false
        end
    end

    if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_DIOGENES_POT_LIVE) and damageflags & DamageFlag.DAMAGE_NO_PENALTIES ~= DamageFlag.DAMAGE_NO_PENALTIES then
        player:UseCard(Card.CARD_FOOL, 257)
    end

    if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_GREED_BUTT) and source ~= nil then
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
                local gb_rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_GREED_BUTT)
                local benchmark = gb_rng:RandomInt(100)
                if benchmark < 4 then
                    local id = findFreeTile(player.Position)
                    if id ~= false then
                        game:GetRoom():SpawnGridEntity(id, GridEntityType.GRID_POOP, 3, gb_rng:Next(), 0)
                        SfxManager:Play(SoundEffect.SOUND_FART, 1.0, 0, false, 1.0)
                    end
                else
                    Isaac.Spawn(EntityType.ENTITY_PICKUP,
                        PickupVariant.PICKUP_COIN,
                        0,
                        game:GetRoom():FindFreePickupSpawnPosition(player.Position),
                        coinvelocity,
                        nil)
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_BEAN)
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_BUTTER_BEAN)
                end
            end

        end
    end

    if player:GetNumCoins() > 0 and player:GetData().inIdolDamage ~= true and player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_GOLDENIDOL) == true and player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) == false then
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
    local numPlayers = game:GetNumPlayers()
    local i=RNG:RandomInt(2)
    local room = game:GetRoom():GetType() == RoomType.ROOM_BOSS
    
    for j=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(j)
        local data = player:GetData()
        if (i == 1 or room) and player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_GOLDENIDOL) == true and player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) == false then
            local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, 
                        PickupVariant.PICKUP_COIN,
                        CoinSubType.COIN_NICKEL,
                        game:GetRoom():FindFreePickupSpawnPosition(game:GetRoom():GetCenterPos()),
                        Vector(0,0),
                        nil):ToPickup()
            coin.Timeout = 90
            coin:GetSprite():SetFrame(1)
            if room then
                local coin2 = Isaac.Spawn(EntityType.ENTITY_PICKUP, 
                        PickupVariant.PICKUP_COIN,
                        CoinSubType.COIN_NICKEL,
                        game:GetRoom():FindFreePickupSpawnPosition(game:GetRoom():GetCenterPos()),
                        Vector(0,0),
                        nil):ToPickup()
                coin2.Timeout = 90
                coin:GetSprite():SetFrame(1)
            end
        end

        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK) then
            data.WarpZone_data.roomsClearedSinceTake = data.WarpZone_data.roomsClearedSinceTake + 1
            local roomsToSuck = math.max(10 - (2 * player:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK)), 1)
            local itemsTakenHere = data.WarpZone_data.itemsTaken
            if data.WarpZone_data.roomsClearedSinceTake % roomsToSuck == 0 then
                local rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK)
                local shift = 0
                for j, item_tag in ipairs(data.WarpZone_data.itemsTaken) do
                    if player:HasCollectible(item_tag) == false then
                        table.remove(data.WarpZone_data.itemsTaken, j-shift)
                        table.remove(data.WarpZone_data.poolsTaken, j-shift)
                        shift = shift + 1
                    end
                end
                
                local pos_to_delete = rng:RandomInt(#itemsTakenHere) + 1
                local config = Isaac.GetItemConfig():GetCollectible(data.WarpZone_data.itemsTaken[pos_to_delete])
                if (data.WarpZone_data.itemsTaken[pos_to_delete] == WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK or (config.Tags & ItemConfig.TAG_QUEST == ItemConfig.TAG_QUEST)) and #itemsTakenHere > 1 then
                    pos_to_delete = (pos_to_delete % #itemsTakenHere) + 1
                end
                
                config = Isaac.GetItemConfig():GetCollectible(data.WarpZone_data.itemsTaken[pos_to_delete])
                if data.WarpZone_data.itemsTaken[pos_to_delete] ~= WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK and (config.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST) then
                    local item_del = table.remove(data.WarpZone_data.itemsTaken, pos_to_delete)
                    table.remove(data.WarpZone_data.poolsTaken, pos_to_delete)
                    player:RemoveCollectible(item_del)
                    data.WarpZone_data.itemsSucked = data.WarpZone_data.itemsSucked + 1
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                    SfxManager:Play(SoundEffect.SOUND_THUMBS_DOWN)
                    SfxManager:Play(SoundEffect.SOUND_BOSS_BUG_HISS)
                    player:AnimateSad()

                    local lostitem = Sprite()
                    lostitem:Load("gfx/005.100_collectible.anm2", true)
                    lostitem:Play("PlayerPickup")
                    lostitem:ReplaceSpritesheet(1, Isaac.GetItemConfig():GetCollectible(item_del).GfxFileName)
                    lostitem:LoadGraphics()
                    data.WarpZone_unsavedata.TickLostItem = {spr = lostitem, frame=0}
                end
            end
        end

        if data.WarpZone_data.roomsSinceBreak and data.WarpZone_data.roomsSinceBreak > 0 then
            data.WarpZone_data.roomsSinceBreak = data.WarpZone_data.roomsSinceBreak - 1
            if data.WarpZone_data.roomsSinceBreak == 0 then
                player:RespawnFamiliars()
            end
        end
    end
    if isBossEmergency and game:GetLevel():GetCurrentRoomIndex() == 84 then
        bossPrepped = true
    end
    isBossEmergency = false

end
WarpZone:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, WarpZone.spawnCleanAward)


function WarpZone:OnGameStart(isSave)
    local numPlayers = game:GetNumPlayers()
    if WarpZone:HasData()  and isSave then
        saveData = json.decode(WarpZone:LoadData())
        DoorwayFloor = saveData.DoorwayFloor --[1]
        numPossessed = saveData.numPossessed --[2]
        floorBeggar = saveData.floorBeggar --[3]
        bibleThumpPool = saveData.bibleThumpPool --[4]
        isBossEmergency = saveData.isBossEmergency --[5]
        bossPrepped = saveData.bossPrepped --[6]
        roomsPrepped = saveData.roomsPrepped --[7]
        preservedItems = saveData.preservedItems --[8]

        for i=0, numPlayers-1, 1 do
            local player = Isaac.GetPlayer(i)
            local data = player:GetData()
            --for k,v in pairs(saveData[lastIndex + i]) do
            --    if k ~= "reticle" then
            --        data.WarpZone_data[k] = v
            --    end
            --end
            if saveData.playerdata[tostring(player:GetCollectibleRNG(1):GetSeed())] then
                data.WarpZone_data = saveData.playerdata[tostring(player:GetCollectibleRNG(1):GetSeed())]
            end
        end
    end

    if not isSave then
        saveData = json.decode(WarpZone:LoadData())
        preservedItems = saveData[8]--this persists across games

        saveData = {}
        DoorwayFloor = -1
        numPossessed = 0
        floorBeggar = -1
        bibleThumpPool = false
        isBossEmergency = false
        bossPrepped = false
        roomsPrepped = {}

        for i=0, numPlayers-1, 1 do
            local player = Isaac.GetPlayer(i)
            local data = player:GetData()
            for k,v in pairs(defaultData) do
                if type(v) == "table" then
                    data.WarpZone_data[k] = TabDeepCopy(v)
                else
                    data.WarpZone_data[k] = v
                end
            end
        end
    end

    WarpZone.GetMenuSaveData()
    if WarpZone.MenuData.SpelunkerBombMode then
        WarpZone.SpelunkersPackEffectType = WarpZone.MenuData.SpelunkerBombMode
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, WarpZone.OnGameStart)


function WarpZone:preGameExit()
    local numPlayers = game:GetNumPlayers()
    saveData.DoorwayFloor = DoorwayFloor
    saveData.numPossessed = numPossessed
    saveData.floorBeggar = floorBeggar
    saveData.bibleThumpPool = bibleThumpPool
    saveData.isBossEmergency = isBossEmergency
    saveData.bossPrepped = bossPrepped
    saveData.roomsPrepped = roomsPrepped
    saveData.preservedItems = preservedItems

    saveData.playerdata = {}
    for i=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(i)
        --saveData[i + lastIndex] = {}
        --for k,v in pairs(player:GetData().WarpZone_data) do
        --    saveData[i + lastIndex][k] = v
        --end
        saveData.playerdata[tostring(player:GetCollectibleRNG(1):GetSeed())] = player:GetData().WarpZone_data
    end

    saveData.MenuData = WarpZone.MenuData
    local jsonString = json.encode(saveData)
    WarpZone:SaveData(jsonString)
  end

  WarpZone:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, WarpZone.preGameExit)


function WarpZone:DebugText()
    local player = Isaac.GetPlayer(0) --this one is OK
    local coords = player.Position
    debug_str = tostring(coords)

    --Isaac.RenderText(debug_str, 100, 60, 1, 1, 1, 255)

end
WarpZone:AddCallback(ModCallbacks.MC_POST_RENDER, WarpZone.DebugText)

function WarpZone:multiPlayerInit(player)
    local data = player:GetData()
    local numPlayers = game:GetNumPlayers()
    --if game:GetRoom():GetFrameCount() > 0 and numPlayers > 0 then
        for k,v in pairs(defaultData) do
            if type(v) == "table" then
                data[k] = TabDeepCopy(v)
            else
                data[k] = v
            end
        end
    --end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, WarpZone.multiPlayerInit)

function WarpZone:LevelStart()
    floorBeggar = -1
    local numPlayers = game:GetNumPlayers()
    for i=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(i)
        local pdata = player:GetData()
        if pdata.WarpZone_data.totalFocusDamage and pdata.WarpZone_data.totalFocusDamage > 0 and (WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS == player:GetActiveItem() or
        WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_2 == player:GetActiveItem() or
        WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_3 == player:GetActiveItem() or
        WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_4 == player:GetActiveItem()) then
            local one_unit_full_charge = (game:GetLevel():GetStage() * FocusChargeMultiplier * 40) + 60 * FocusChargeMultiplier
            local one_unit_full_charge_prev = (math.min(game:GetLevel():GetStage()-1, 1) * FocusChargeMultiplier * 40) + 60 * FocusChargeMultiplier
            pdata.WarpZone_data.totalFocusDamage = pdata.WarpZone_data.totalFocusDamage * (one_unit_full_charge/one_unit_full_charge_prev)
        end

        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BIRTHDAY_CAKE) then
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
                            game:GetRoom():FindFreePickupSpawnPosition(game:GetRoom():GetCenterPos()),
                            Vector(0,0),
                            nil)
            end
        end

        if player:HasTrinket(WarpZone.WarpZoneTypes.TRINKET_RING_SNAKE) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP,
                            PickupVariant.PICKUP_TAROTCARD,
                            0,
                            game:GetRoom():FindFreePickupSpawnPosition(game:GetRoom():GetCenterPos()),
                            Vector(0,0),
                            nil)

            Isaac.Spawn(EntityType.ENTITY_PICKUP,
                            PickupVariant.PICKUP_TAROTCARD,
                            0,
                            game:GetRoom():FindFreePickupSpawnPosition(game:GetRoom():GetCenterPos()),
                            Vector(0,0),
                            nil)
        end

        --if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOW_AND_ARROW) then
        --    pdata.WarpZone_data.numArrows = player:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_BOW_AND_ARROW) * 3
        --end
    end
    bossPrepped = false
    while next (roomsPrepped) do
        roomsPrepped[next(roomsPrepped)]=nil
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, WarpZone.LevelStart)


function WarpZone:NewRoom()
    local testPlayer = Isaac.GetPlayer(0)
    
    local numPlayers = game:GetNumPlayers()
    local room = game:GetRoom()
    
    for i=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(i)
        local data = player:GetData()
        data.WarpZone_data.dioDamageOn = false
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()

        data.WarpZone_data.ballCheck = false
        if data.WarpZone_data.InDemonForm ~= nil then
            player:ChangePlayerType(data.WarpZone_data.InDemonForm)
            data.WarpZone_data.InDemonForm = nil
        end
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOW_AND_ARROW) then
            data.WarpZone_data.numArrows = data.WarpZone_data.maxArrowNum
        end
    end
    if game:GetLevel():GetStage() == DoorwayFloor and (game:GetLevel():GetCurrentRoomIndex() ~=84 or game:GetLevel():GetStage()~= 1 or not room:IsFirstVisit()) then
        if room:GetType() == RoomType.ROOM_BOSS then
            room:TrySpawnDevilRoomDoor(false, true)
            if game:GetLevel():GetStage() == LevelStage.STAGE3_2 then
                room:TrySpawnBossRushDoor()
            elseif game:GetLevel():GetStage() == LevelStage.STAGE4_2 and game:GetLevel():GetStageType() < 3 then
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

    local marblePlayer = doesAnyoneHave(WarpZone.WarpZoneTypes.COLLECTIBLE_STRANGE_MARBLE, false)
    if marblePlayer ~= nil then
        local marbleRNG = marblePlayer:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_STRANGE_MARBLE)
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

    local georgePlayer = doesAnyoneHave(WarpZone.WarpZoneTypes.COLLECTIBLE_GEORGE, false)
    if georgePlayer ~= nil and room:IsFirstVisit() then
        local roomtype = room:GetType()
        local desc = game:GetLevel():GetCurrentRoomDesc().Flags
        local index = game:GetLevel():GetCurrentRoomIndex()
        if tableContains(george_room_type, roomtype) and (desc & RoomDescriptor.FLAG_RED_ROOM ~= RoomDescriptor.FLAG_RED_ROOM) then
            for i = 0, 7 do
                local door = room:GetDoor(i)
                if door then
                    local doorEntity = door:ToDoor()
                    local doorSlot = roomKey[i]
                    local made = game:GetLevel():MakeRedRoomDoor(index, doorSlot)
                    if made ~= true then
                        for j = 0, 7 do
                            local new_door = room:GetDoor(j)
                            if not new_door then
                                made = game:GetLevel():MakeRedRoomDoor(index, j)
                                if made then break end
                            end
                        end
                    end
                    break
                end
            end
        end
    end
    
    local possessPlayer =  doesAnyoneHave(WarpZone.WarpZoneTypes.COLLECTIBLE_POSSESSION, false)
    if possessPlayer ~= nil and room:IsFirstVisit() then
        local entities = Isaac.GetRoomEntities()
        local charmed = 0
        local tempnumPossessed = 0
        for i=1, #entities do
            local entity_pos = entities[i]
            if entity_pos:GetData().InPossession == true then
                tempnumPossessed = tempnumPossessed + 1
            end
            if charmed < possessPlayer:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_POSSESSION) and numPossessed < 15 and entity_pos:IsVulnerableEnemy() and not entity_pos:IsBoss() and not entity_pos:HasEntityFlags(EntityFlag.FLAG_CHARM) then
                entity_pos:AddCharmed(EntityRef(possessPlayer), -1)
                entity_pos:GetData().InPossession = true
                charmed = charmed + 1
            end
        end
        numPossessed = tempnumPossessed
    end

    local cheepPlayer = doesAnyoneHave(WarpZone.WarpZoneTypes.TRINKET_CHEEP_CHEEP, true)
    if cheepPlayer ~= nil then
        local entities = Isaac.GetRoomEntities()
        for i=1, #entities do
            local entity_pos = entities[i]
            if entity_pos:IsVulnerableEnemy() and not entity_pos:IsBoss() and not entity_pos:HasEntityFlags(EntityFlag.FLAG_BAITED) then
                entity_pos:AddFear(EntityRef(possessPlayer), 90)
                entity_pos:AddEntityFlags(EntityFlag.FLAG_BAITED)
                if cheepPlayer:GetTrinketMultiplier(WarpZone.WarpZoneTypes.TRINKET_CHEEP_CHEEP) >= 2 then
                    entity_pos:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
                end
                break
            end
        end
    end


    local aubreyPlayer = doesAnyoneHave(WarpZone.WarpZoneTypes.COLLECTIBLE_AUBREY, false)
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

    
    
    local biblePlayer = doesAnyoneHave(WarpZone.WarpZoneTypes.TRINKET_BIBLE_THUMP, true)

    if biblePlayer ~= nil and bibleThumpPool == false then
        bibleThumpPool = true
        local pool = game:GetItemPool()
        local AddBibleUpgrade = pool.AddBibleUpgrade
        AddBibleUpgrade(pool, 1, ItemPoolType.POOL_TREASURE)
        AddBibleUpgrade(pool, 1, ItemPoolType.POOL_SHOP)
        AddBibleUpgrade(pool, 1, ItemPoolType.POOL_DEVIL)
        AddBibleUpgrade(pool, 1, ItemPoolType.POOL_BOSS)
        AddBibleUpgrade(pool, 1, ItemPoolType.POOL_GOLDEN_CHEST)
        AddBibleUpgrade(pool, 1, ItemPoolType.POOL_RED_CHEST)
        AddBibleUpgrade(pool, 1, ItemPoolType.POOL_SECRET)
        AddBibleUpgrade(pool, 1, ItemPoolType.POOL_BEGGAR)
        AddBibleUpgrade(pool, 1, ItemPoolType.POOL_GREED_TREASURE)
        AddBibleUpgrade(pool, 1, ItemPoolType.POOL_GREED_SHOP)
        AddBibleUpgrade(pool, 1, ItemPoolType.POOL_GREED_DEVIL)
        AddBibleUpgrade(pool, 1, ItemPoolType.POOL_GREED_SECRET)
        AddBibleUpgrade(pool, 1, ItemPoolType.POOL_GREED_BOSS)
    end
    if bossPrepped and room:GetType() == RoomType.ROOM_BOSS and not room:IsClear() and tableContains(roomsPrepped, game:GetLevel():GetCurrentRoomIndex() ,true) ~= false then
        local entities = Isaac.GetRoomEntities()
        for i=1, #entities do
            local entity = entities[i]
            if entity:IsActiveEnemy() then
                entity:Remove()
            end
        end
        bossPrepped = false
    end
    isBossEmergency = false
end
WarpZone:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, WarpZone.NewRoom)

function WarpZone:usePastkiller(collectible, rng, entityplayer, useflags, activeslot, customvardata)

    local player =  entityplayer:ToPlayer()
    --debug_str = tostring(player.ControllerIndex)
    local data = player:GetData()
    
    local shift = 0
    for i, item_tag in ipairs(data.WarpZone_data.itemsTaken) do
        if player:HasCollectible(item_tag) == false then
            table.remove(data.WarpZone_data.itemsTaken, i-shift)
            table.remove(data.WarpZone_data.poolsTaken, i-shift)
            shift = shift + 1
        end
    end
    local itemsTakenHere = data.WarpZone_data.itemsTaken
    if #itemsTakenHere < 3 then
        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false
        }
    end


    local pos = game:GetRoom():GetCenterPos() + Vector(-160, -160)
    local pool
    local item_removed
    local numChoices = 3
    local spacing = 80

    if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
        numChoices = 5
        pos = game:GetRoom():GetCenterPos() + Vector(-120, -160)
        spacing = 40
    end
    
    for j = 1, 3 do
        pickupindex = pickupindex + 1
        pool = table.remove(data.WarpZone_data.poolsTaken, 1)
        item_removed  = table.remove(data.WarpZone_data.itemsTaken, 1)
        player:RemoveCollectible(item_removed)
        for i = 1, numChoices do
            local pedestal = Isaac.Spawn(EntityType.ENTITY_PICKUP,
                        PickupVariant.PICKUP_COLLECTIBLE,
                        itemPool:GetCollectible(pool),
                        game:GetRoom():FindFreePickupSpawnPosition(pos + Vector(spacing * i, 80 * j)),
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
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.usePastkiller, WarpZone.WarpZoneTypes.COLLECTIBLE_PASTKILLER)

function WarpZone:UseFocus(collectible, rng, entityplayer, useflags, activeslot, customvardata)
    local player =  entityplayer:ToPlayer()

    if not player:HasFullHearts() then
        player:AddHearts(2)
        SfxManager:Play(SoundEffect.SOUND_DEATH_CARD, 3)
        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
            player:AddHearts(2)
        end
    else
        SfxManager:Play(SoundEffect.SOUND_ANGEL_WING, 2)
        entityplayer:GetData().primeShot = true
    end

    local one_unit_full_charge = (game:GetLevel():GetStage() * FocusChargeMultiplier * 40) + FocusChargeMultiplier * 60
    local adjustedcharge = 0

    if player:GetActiveCharge() >= 20 then
        adjustedcharge = player:GetActiveCharge() - 20
        player:GetData().WarpZone_data.totalFocusDamage = math.floor(one_unit_full_charge * (adjustedcharge/20))
    else
        player:GetData().WarpZone_data.totalFocusDamage = 0
    end

    swapOutActive(WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS, ActiveSlot.SLOT_PRIMARY, player, adjustedcharge)
    return {
        Discharge = false,
        Remove = false,
        ShowAnim = true
    }
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.UseFocus, WarpZone.WarpZoneTypes.COLLECTIBLE_FOCUS_4)

function WarpZone:UseDoorway(collectible, rng, entityplayer, useflags, activeslot, customvardata)
    local room = game:GetRoom()
    local currentLevel = game:GetLevel()
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
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.UseDoorway, WarpZone.WarpZoneTypes.COLLECTIBLE_DOORWAY)

function WarpZone:UseIsYou(collectible, rng, entityplayer, useflags, activeslot, customvardata)
    if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
        if useflags & UseFlag.USE_CARBATTERY ~= 0 then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false
            }
        end
    end

    if entityplayer:GetData().baba_active == nil and entityplayer:GetData().reticle == nil then
        entityplayer:GetData().reticle = Isaac.Spawn(1000, 30, 0, entityplayer.Position, Vector(0, 0), entityplayer)
        entityplayer:GetData().WarpZone_data.blinkTime = 10
        entityplayer:AnimateCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_IS_YOU, "LiftItem", "PlayerPickupSparkle")
        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false
        }
    elseif entityplayer:GetData().baba_active ~= nil then
        entityplayer:UseActiveItem(entityplayer:GetData().baba_active)
        if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
            entityplayer:UseActiveItem(entityplayer:GetData().baba_active, UseFlag.USE_CARBATTERY)
        end
        entityplayer:GetData().baba_active = nil
        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.UseIsYou, WarpZone.WarpZoneTypes.COLLECTIBLE_IS_YOU)



function WarpZone:OnPickupCollide(entity, Collider, Low)
    local player = Collider:ToPlayer()
    local data = Collider:GetData()

    --if entity.Variant == tokenVariant and Collider.Type == EntityType.ENTITY_PICKUP then
        --return true
    ---end

    if player == nil then
        return nil
    end

    if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == tumorVariant and entity:GetData().Collected ~= true then
        entity:GetData().Collected = true
        entity:GetSprite():Play("Collect")
        if not data.WarpZone_data.playerTumors then data.WarpZone_data.playerTumors = 0 end
        data.WarpZone_data.playerTumors = data.WarpZone_data.playerTumors + 1
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
        player:EvaluateItems()
        if game:GetFrameCount() % 2 == 0 then
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
        data.WarpZone_data.numArrows = data.WarpZone_data.numArrows + 1
        SfxManager:Play(SoundEffect.SOUND_SHELLGAME)
        return true
    elseif entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == tokenVariant then
        return true
    end


    if entity.Type == EntityType.ENTITY_PICKUP and (entity.Variant == PickupVariant.PICKUP_COLLECTIBLE) and player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY) then
        --local dmg_config = Isaac.GetItemConfig():GetCollectible(entity.SubType)
        if entity.SubType ~= 0 and data.WarpZone_data.tonyBuff > 1 and entity:GetData().collected ~= true then -- and (dmg_config.CacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE)
            entity:GetData().collected = true
            data.WarpZone_data.tonyBuff = data.WarpZone_data.tonyBuff - 0.1
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
    end

    if entity.Type == EntityType.ENTITY_PICKUP and (entity.Variant == PickupVariant.PICKUP_COLLECTIBLE) and entity:ToPickup():GetData().Logged ~= true then
        entity:ToPickup():GetData().Logged = true
        if entity.SubType == WarpZone.WarpZoneTypes.COLLECTIBLE_BALL_OF_TUMORS then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, tumorVariant, 1, game:GetRoom():FindFreePickupSpawnPosition(game:GetRoom():GetCenterPos()), Vector(0,0), nil)
        end
        if entity.SubType == WarpZone.WarpZoneTypes.COLLECTIBLE_BOW_AND_ARROW then
            data.WarpZone_data.numArrows = data.WarpZone_data.numArrows + 3
        end
    end
    return nil
end

WarpZone:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, WarpZone.OnPickupCollide)

---@param pickup EntityPickup
function WarpZone:PickupUpdate(pickup)
    if pickup.Variant == tokenVariant then
        pickup.Timeout = 60
        pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, WarpZone.PickupUpdate)

function WarpZone:EvaluateCache(entityplayer, Cache)
    local data = entityplayer:GetData()
    local cakeBingeBonus = 0

    local tank_qty =  entityplayer:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_NEWGROUNDS_TANK)
    
    if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then
        cakeBingeBonus = entityplayer:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_BIRTHDAY_CAKE)
    end

    if Cache == CacheFlag.CACHE_FIREDELAY then
        local waterAmount = (entityplayer:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_FULL) * 2) + (entityplayer:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_MID) * 1.5) + (entityplayer:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_LOW) * .75)
        if entityplayer:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NEWGROUNDS_TANK) then
            entityplayer.MaxFireDelay = entityplayer.MaxFireDelay - tank_qty
        end
        entityplayer.MaxFireDelay = entityplayer.MaxFireDelay - waterAmount
        entityplayer.MaxFireDelay = entityplayer.MaxFireDelay - (cakeBingeBonus * 2)
        entityplayer.MaxFireDelay = entityplayer.MaxFireDelay - isNil(data.WarpZone_data.bonusFireDelay, 0)

        if entityplayer:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_POPPOP) and data.WarpZone_data.arrowTimeDelay > 0 then
            if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                entityplayer.MaxFireDelay = entityplayer.MaxFireDelay + 40
            else
                entityplayer.MaxFireDelay = entityplayer.MaxFireDelay + 30
            end
            
        end
        if entityplayer:GetData().JohnnyCreepTearBonus == true then
            entityplayer.MaxFireDelay = entityplayer.MaxFireDelay - 2
        end
    end
        
    

    if Cache == CacheFlag.CACHE_DAMAGE then
        entityplayer.Damage = entityplayer.Damage + (0.5 * tank_qty)

        if entityplayer:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK) then
            entityplayer.Damage = entityplayer.Damage + (data.WarpZone_data.itemsSucked * 0.75)
        end
        
        if data.WarpZone_data.InDemonForm ~= nil then
            entityplayer.Damage = entityplayer.Damage + 1
        end

        if entityplayer:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_TONY) then
            entityplayer.Damage = (entityplayer.Damage * data.WarpZone_data.tonyBuff) + (data.WarpZone_data.tonyBuff * 1.428)
        end
        
        if data.WarpZone_data.dioDamageOn == true then
            if entityplayer:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                entityplayer.Damage = entityplayer.Damage * 2
            else
                entityplayer.Damage = entityplayer.Damage * 1.5
            end
        end
        entityplayer.Damage = entityplayer.Damage + isNil(data.WarpZone_data.bonusDamage, 0)
    end

    if Cache == CacheFlag.CACHE_RANGE then
        entityplayer.TearRange = entityplayer.TearRange + (40 * tank_qty)
        if entityplayer:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_GEORGE) then
            entityplayer.TearRange = entityplayer.TearRange + (entityplayer:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_GEORGE) * 96)
        end
        entityplayer.TearRange = entityplayer.TearRange + isNil(data.WarpZone_data.bonusRange, 0)
        if game:GetFrameCount() - isNil(data.InGravityState, -999) < 150 then
            entityplayer.TearRange = entityplayer.TearRange + 250
        end
    end

    if Cache == CacheFlag.CACHE_FLYING then
        if game:GetFrameCount() - isNil(data.InGravityState, -999) < 150 then
            entityplayer.CanFly = true
        end
    end

    if Cache == CacheFlag.CACHE_LUCK then
        entityplayer.Luck = entityplayer.Luck + tank_qty
        entityplayer.Luck = entityplayer.Luck +  isNil(data.WarpZone_data.bonusLuck, 0)
    end

    if Cache == CacheFlag.CACHE_SPEED then
        entityplayer.MoveSpeed = entityplayer.MoveSpeed - (tank_qty * .3)
        entityplayer.MoveSpeed = entityplayer.MoveSpeed - (cakeBingeBonus * .03)
        entityplayer.MoveSpeed = entityplayer.MoveSpeed + isNil(data.WarpZone_data.bonusSpeed, 0)
        if entityplayer:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_HITOPS) then
            data.breakCap = false
        end
    end

    if Cache == CacheFlag.CACHE_SHOTSPEED then
        entityplayer.ShotSpeed = entityplayer.ShotSpeed + (tank_qty * .16)
    end

end
WarpZone:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, WarpZone.EvaluateCache)

--Checking every entity here is a pretty terrible idea, since it's called for every player
---@param player EntityPlayer
function WarpZone:postPlayerUpdate(player)
    local data = player:GetData()
    local spr = player:GetSprite()

    if data.fireGlove == true then
        WarpZone:fireGlove(player)
        player:GetData().fireGlove = nil
    end
    if(data.breakCap==false) then
        player.MoveSpeed = math.min(player.MoveSpeed+player:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_HITOPS)*0.2, 3)
        data.breakCap = nil
    end
    if game:GetFrameCount() - isNil(data.MurderFrame, -999) < 15 then
        player.MoveSpeed = 4
    elseif data.InMurderState == true then
        data.InMurderState = false
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
        spr.Color = Color(1, 1, 1, 1, 0, 0, 0)
        player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_LEO, 1)
    end

    if game:GetFrameCount() - isNil(data.InGravityState, -999) == 8 or (player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and game:GetFrameCount() - isNil(data.InGravityState, -999) == -142) then
        spr.Color = Color(1, 1, 1, 0, 1, 1, 1)
        spr:LoadGraphics()
    end

    if data.gravReticle then
        data.gravReticle.Position = player.Position
    end

    if isNil(data.InGravityState, -999) > 0 and (game:GetFrameCount() - isNil(data.InGravityState, -999) >= 150) then
        player:PlayExtraAnimation("TeleportDown")
        spr.Color = Color(1, 1, 1, 1, 0, 0, 0)
        data.InGravityState = -1
        player:AddCacheFlags(CacheFlag.CACHE_RANGE)
        player:AddCacheFlags(CacheFlag.CACHE_FLYING)
        player:EvaluateItems()
        SfxManager:Play(SoundEffect.SOUND_THUMBSUP, 2)
        if data.gravReticle then
            data.gravReticle:Remove()
            data.gravReticle = nil
        end
    end

    --if Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex) == true and 
    --player:GetActiveItem() == WarpZone.WarpZoneTypes.COLLECTIBLE_GRAVITY
    --and isNil(player:GetData().InGravityState, -999) < 0 then
    --    player:UseActiveItem(CollectibleType.COLLECTIBLE_HOW_TO_JUMP)
    --end

    --[[if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON) == true or player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK) == true  then
        
        local lasers = Isaac.FindByType(EntityType.ENTITY_LASER)
        for _, laser in ipairs(lasers) do
            local data = laser:GetData()
            if data.Laser_Rusty == true then
                data.Laser_Rusty = false
                laser.Color = rustColor
            elseif player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK) == true then
                laser.Color = tickColor
            end
        end
        
        local laserEndpoints = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.LASER_IMPACT)
        for _, laserEndpoint in ipairs(laserEndpoints) do
            local data = laserEndpoint:GetData()
            if data.Laser_Rusty == true then
                data.Laser_Rusty = false
                laserEndpoint.Color = rustColor
            elseif player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK) == true then
                laserEndpoint.Color = tickColor
            end
        end
        
        local brimballs = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BRIMSTONE_BALL)
        for _, brimball in ipairs(brimballs) do
            local data = brimball:GetData()
            if data.Laser_Rusty == true then
                data.Laser_Rusty = false
                brimball.Color = rustColor
            elseif player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK) == true then
                brimball.Color = tickColor
            end
        end
    end]]

    --[[if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_SPELUNKERS_PACK) == true then
		local entities = Isaac.FindByType(EntityType.ENTITY_BOMBDROP)

		for i=1,#entities do
			--Normal bombs
			if entities[i].SpawnerType == EntityType.ENTITY_PLAYER then
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
	end]]

    if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_POPPOP) then
        if data.WarpZone_data.arrowTimeThreeFrames == 1 then
            firePopTear(player, false)
        end
        data.WarpZone_data.arrowTimeThreeFrames = data.WarpZone_data.arrowTimeThreeFrames-1
    end

    data.WarpZone_data = data.WarpZone_data or {}

    if data.WarpZone_data.IsHoldindEntity and not data.WarpZone_data.HoldEntity then
        data.WarpZone_data.IsHoldindEntity = nil
        player:PlayExtraAnimation("HideItem")
    end
    if data.WarpZone_data.HoldEntityLogic and type(data.WarpZone_data.HoldEntityLogic) == "function" then
        data.WarpZone_data.HoldEntityLogic(player)
    end

    if data.InMurderState == true then
        local room = game:GetRoom()
        
        for i = 0, room:GetGridSize() do
            local gridIndexPosition = room:GetGridPosition(i)
            if room:IsPositionInRoom(gridIndexPosition , 1) then
                local gridEntity = room:GetGridEntity(i)
                if gridEntity ~= nil 
                and gridEntity:ToPit() ~= nil 
                and gridEntity.Position:Distance(player.Position) < 40 then
                    gridEntity:ToPit():MakeBridge(nil)
                    SfxManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
                end
            end
        end
    end

    if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_JOHNNYS_KNIVES) then
        local creeps = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED)
        local pastvalue = isNil(data.JohnnyCreepTearBonus, false)
        data.JohnnyCreepTearBonus = false
        --for i, creep in ipairs(creeps) do
        for i=1, #creeps do
            local creep = creeps[i]
            if (creep.Position-player.Position):Length() <= (creep.Size)/2 + 10 then
                data.JohnnyCreepTearBonus = true
            end
            if pastvalue ~= data.JohnnyCreepTearBonus then
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                player:EvaluateItems()
            end
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, WarpZone.postPlayerUpdate, 0)


function WarpZone:checkTear(entitytear)
    local tear = entitytear:ToTear()
    local player = WarpZone:GetPlayerFromTear(entitytear)
    local data = player and player:GetData()
    if player and player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON) then
        local chance = player.Luck * 5 + 10
        local rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON)
        if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
            chance = chance + 20
        end
        local chance_num = rng:RandomInt(100)
        if chance_num < chance then
            tear:GetData().Is_Rusty = true
            tear:GetData().BleedIt = true
        end
    elseif player and player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK) then
        tear:GetData().NightmareColor = true
    end

    if player and player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_BOW_AND_ARROW) and data.WarpZone_data.numArrows > 0 then
        data.WarpZone_data.numArrows = data.WarpZone_data.numArrows - 1
        tear:GetData().BowArrowPiercing = 2
        local spr = tear:GetSprite()
        spr:Load("gfx/arrow tear.anm2", true)
        spr:Play(spr:GetDefaultAnimation())

        if not tear.Child then
            tear.Child = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, tear.Position, Vector(0,0), tear)
            tear.Child.Color = arrowTrail.col
            tear.Child:ToEffect().MinRadius = arrowTrail.MinRadius
            tear.Child:ToEffect():FollowParent(tear)
        end
    end

    if player and isNil(data.InGravityState, -1) > 0 then
        tear:GetData().TearGravityState = true
        tear.Position = Vector(player.Position.X, 3)
        if math.abs(tear.Velocity.X) > math.abs(tear.Velocity.Y) then
            tear.Velocity = Vector(math.abs(tear.Velocity.Y), tear.Velocity.X)
        end
        tear.Velocity = Vector(tear.Velocity.X, (math.abs(tear.Velocity.Y)* 1.25))
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, WarpZone.checkTear)

local LaserCheckUpdateFrame = 0
WarpZone:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function()
    local curFrame = Isaac.GetFrameCount()
    if LaserCheckUpdateFrame ~= curFrame then
        LaserCheckUpdateFrame = curFrame
        
        local lasers = Isaac.FindByType(EntityType.ENTITY_LASER)
        for i=1, #lasers do
            local laser = lasers[i]
            --local player = WarpZone.TryGetPlayer(laser.SpawnerEntity)
            local data = laser:GetData()
            --[[if data.Laser_Rusty == true then
                data.Laser_Rusty = false
                laser.Color = rustColor
            elseif player and player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK) == true then
                laser.Color = tickColor
            end]]
            if data.Laser_Rusty == true then
                data.Laser_Rusty = false
                laser.Color = rustColor
            end
            if data.WarpZone_UpdateColor then
                laser.Color = data.WarpZone_UpdateColor
                data.WarpZone_UpdateColor = nil
            end
        end
        
        local laserEndpoints = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.LASER_IMPACT)
        --for _, laserEndpoint in ipairs(laserEndpoints) do
        for i=1, #laserEndpoints do
            local laserEndpoint = laserEndpoints[i]
            local data = laserEndpoint:GetData()
            --if data.Laser_Rusty == true then
            --    data.Laser_Rusty = false
            --    laserEndpoint.Color = rustColor
            --elseif player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK) == true then
            --    laserEndpoint.Color = tickColor
            --end
        end
        
        local brimballs = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BRIMSTONE_BALL)
        for i=1, #brimballs do
            local brimball = brimballs[i]
            local data = brimball:GetData()
            if data.Laser_Rusty == true then
                data.Laser_Rusty = false
                brimball.Color = rustColor
            end
            if data.WarpZone_UpdateColor then
                brimball.Color = data.WarpZone_UpdateColor
                data.WarpZone_UpdateColor = nil
            end
        end

        local brimballs = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BRIMSTONE_SWIRL)
        for i=1, #brimballs do
            local brimball = brimballs[i]
            local data = brimball:GetData()
            if data.Laser_Rusty == true then
                data.Laser_Rusty = false
                brimball.Color = rustColor
            end
            if data.WarpZone_UpdateColor then
                brimball.Color = data.WarpZone_UpdateColor
                data.WarpZone_UpdateColor = nil
            end
        end
    end
end)

function WarpZone:BrimBallInit(laser)
    local player = WarpZone.TryGetPlayer(laser.SpawnerEntity) 
    local data = laser:GetData()
    
    if player then
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON) then
            local chance = player.Luck * 5 + 10
            local rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON)
            local ghost = RNG()
            ghost:SetSeed(rng:GetSeed(), 35) --isn't working?
            if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
                chance = chance + 20
            end
            local chance_num = ghost:RandomInt(100)
            if chance_num < chance then
                data.Laser_Rusty = true
                player:GetData().LaserBleedIt = true
            end
        end
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK) then
            data.WarpZone_UpdateColor = tickColor
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, WarpZone.BrimBallInit, EffectVariant.BRIMSTONE_BALL)

function WarpZone:BrimSwirmInit(laser)
    local player = WarpZone.TryGetPlayer(laser.SpawnerEntity) 
    local data = laser:GetData()
    
    if player then
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON) then
            local chance = player.Luck * 5 + 10
            local rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON)
            local ghost = RNG()
            ghost:SetSeed(rng:GetSeed(), 35) --isn't working?
            if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
                chance = chance + 20
            end
            local chance_num = ghost:RandomInt(100)
            if chance_num < chance then
                data.Laser_Rusty = true
                --player:GetData().LaserBleedIt = true
            end
        end
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK) then
            data.WarpZone_UpdateColor = tickColor
            laser.Color = tickColor
        end
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, WarpZone.BrimSwirmInit, EffectVariant.BRIMSTONE_SWIRL)

function WarpZone:checkLaser(entitylaser)
    local laser = entitylaser:ToLaser()
    local player = WarpZone.TryGetPlayer(laser.SpawnerEntity) --getPlayerFromKnifeLaser(laser)
    local data = laser:GetData()
    local var = laser.Variant
    local subt = laser.SubType
    local ignoreLaserVar = ((var == 1 and subt == 3) or var == 5 or var == 12)
    if player and not ignoreLaserVar then
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON) then
            local chance = player.Luck * 5 + 10
            local rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON)
            if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
                chance = chance + 20
            end
            local chance_num = rng:RandomInt(100)
            if chance_num < chance then
                data.Laser_Rusty = true
                player:GetData().LaserBleedIt = true
            end
        end
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_NIGHTMARE_TICK) then
            data.WarpZone_UpdateColor = tickColor
        end
    end

    if player and player:GetData().WarpZone_data.InDemonForm ~= nil then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) 
        or player:GetData().WarpZone_data.InDemonForm == PlayerType.PLAYER_AZAZEL 
        or player:GetData().WarpZone_data.InDemonForm == PlayerType.PLAYER_AZAZEL_B then
            entitylaser.Variant = 1
            entitylaser:GetData().IsBigLaser = true
        end
    end
    --print(tostring(laser.SubType).." subtype, and damage is ".. tostring(laser.CollisionDamage))
    if player and isNil(player:GetData().InGravityState, -1) > 0 and player:GetData().LaserRedirect ~= true then
        --print("trig")
        laser:GetData().TearGravityState = true
        local newPos = Vector(player.Position.X, 3)
        
        local offset = Vector(0, 0)
        player:GetData().LaserRedirect = true
        if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
            local velocity = laser.Velocity
            if math.abs(velocity.X) > math.abs(velocity.Y) then
                velocity = Vector(math.abs(velocity.Y), velocity.X)
            end
            velocity = Vector(velocity.X, (math.abs(velocity.Y)* 1.25))
            player:FireTechXLaser(newPos, velocity, laser.Radius, player, 1)
        elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) then
            local newLaser = EntityLaser.ShootAngle(laser.Variant, newPos, 90, 1, offset, player)
            newLaser.CollisionDamage = player.Damage / 7
            newLaser:GetData().SuppressZaps = true  
        else
            local newLaser = EntityLaser.ShootAngle(laser.Variant, newPos, 90, 1, offset, player)
            newLaser.CollisionDamage = player.Damage
        end

        
        laser:Remove()
        
    end
    if player then
        player:GetData().LaserRedirect = false
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_LASER_INIT, WarpZone.checkLaser)


function WarpZone:updateLaser(laser)
    if laser:GetData().IsBigLaser == true then
        laser.Size = laser.Size * 3
        laser:GetSprite().Scale = laser:GetSprite().Scale * 3
        laser:GetData().IsBigLaser = false
    end
    if laser:GetData().SuppressZaps == true then
        SfxManager:Stop(SoundEffect.SOUND_REDLIGHTNING_ZAP)
        SfxManager:Stop(SoundEffect.SOUND_REDLIGHTNING_ZAP_WEAK)
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, WarpZone.updateLaser)

function WarpZone:updateTear(entitytear)
    local tear = entitytear:ToTear()
    local data = tear:GetData()
    local focusshot = false
    local player = WarpZone:GetPlayerFromTear(tear)
    if data then
        focusshot = data.FocusShot == true
        if focusshot then
            data.FocusShot = false
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
            if player and player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                tear.CollisionDamage = tear.CollisionDamage + 92
            end
            tear:ResetSpriteScale()
        end
        
        if data.BowArrowPiercing == 2 then
            data.BowArrowPiercing = 1
            tear:AddTearFlags(TearFlags.TEAR_PIERCING)
            tear.Position = tear.Position + tear.Velocity
            tear.Velocity = tear.Velocity * Vector(1.5, 1.5)
            tear.Scale = tear.Scale * 0.5
            tear.CollisionDamage = tear.CollisionDamage * 2.5
            tear:GetSprite().Rotation = Vector(tear.Velocity.X, tear.Velocity.Y + tear.FallingSpeed):GetAngleDegrees()
            if tear.Child then
                tear.Child:ToEffect().ParentOffset = tear.PositionOffset
            end
        elseif data.BowArrowPiercing == 1 then
            tear:GetSprite().Rotation = Vector(tear.Velocity.X, tear.Velocity.Y + tear.FallingSpeed):GetAngleDegrees()
            if tear.Child then
                tear.Child:ToEffect().ParentOffset = tear.PositionOffset
            end
        end

        if data.Is_Rusty == true then
            data.Is_Rusty = false
            tear:AddTearFlags(TearFlags.TEAR_HOMING)
            local sprite_tear = tear:GetSprite()
            sprite_tear.Color = rustColor
        elseif data.NightmareColor then
            local sprite_tear = tear:GetSprite()
            sprite_tear.Color = tickColor
        end
        
        if data.TearGravityState == true then
            tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
        end
    end
    local waterAmount = 1.0
    if player then
        waterAmount = waterAmount + 0.3 * ((player:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_FULL) * 3) + (player:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_MID) * 2) + (player:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_WATER_LOW) * 1))
    
        if not focusshot then
            if data.resized == nil then
                local product = tear.Scale * waterAmount
                if player:HasCollectible(CollectibleType.COLLECTIBLE_DEATHS_TOUCH) then
                    product = product * 0.5
                end
                tear.Scale = product
                data.resized = true
            end
        end
    end
    
end
WarpZone:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, WarpZone.updateTear)


function WarpZone:dropArrow(entity)
    if entity:GetData().BowArrowPiercing and entity:GetData().BowArrowPiercing > 0 then
        if game:GetRoom():GetFrameCount() == 0 then
            local player = entity.SpawnerEntity
            if player and player:ToPlayer() ~= nil then
                player:GetData().WarpZone_data.numArrows = player:GetData().WarpZone_data.numArrows + 1
            end
        else
            local arrow = Isaac.Spawn(EntityType.ENTITY_PICKUP,
                    tokenVariant,
                    1,
                    entity.Position-entity.Velocity*2,
                    entity.Velocity * 0.25,
                    nil)
            arrow:GetSprite():SetFrame(23)
            arrow.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        end
        if entity.Child then
            entity.Child:Remove()
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
    if player and player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON) and collider:IsVulnerableEnemy() then
        local chance = player.Luck * 5 + 10
        local rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_RUSTY_SPOON)
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
    local data = player:GetData()
        local room = game:GetRoom()
        if game:GetLevel():GetStage() == DoorwayFloor and (game:GetLevel():GetCurrentRoomIndex() ~=84 or game:GetLevel():GetStage()~= 1) then
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
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_IS_YOU) and data.reticle ~= nil then
            local aimDir = player:GetAimDirection()
            data.reticle.Velocity = aimDir * 20

            if data.reticle.FrameCount % data.WarpZone_data.blinkTime < data.WarpZone_data.blinkTime/2 then
                data.reticle.Color = Color(0, 0, 0, 0.5, -230, 100, 215)
            else
                data.reticle.Color = Color(0, 0, 0, 0.8, -200, 150, 255)
            end

                local stop = false
                if (data.reticle.FrameCount > 5 and data.WarpZone_data.timeSinceTheSpacebarWasLastPressed < 4) or data.reticle.FrameCount > 75 then
                    findGridEntityResponse(data.reticle.Position, player)
                    data.reticle:Remove()
                    data.reticle = nil
                    stop = true
                else
                    -- Prevent the player from shooting
                    player.FireDelay = 1

                    -- Make the target blink faster
                    if data.reticle.FrameCount > 70 then
                        data.WarpZone_data.blinkTime = 2
                    elseif data.reticle.FrameCount > 65 then
                        data.WarpZone_data.blinkTime = 4
                    elseif data.reticle.FrameCount > 55 then
                        data.WarpZone_data.blinkTime = 6
                    elseif data.reticle.FrameCount > 40 then
                        data.WarpZone_data.blinkTime = 8
                    end
                end
                if stop then --and ai.player:GetSprite():IsPlaying("LiftItem")
                    player:AnimateCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_IS_YOU, "HideItem", "Empty")
                end
        end
        --[[if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_FOOTBALL) and not player:GetData().ballCheck and room:GetFrameCount() > 0 then
            local numberBalls = player:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_FOOTBALL)
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
                    local create_entity = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.CUBE_BABY, 0, game:GetRoom():FindFreePickupSpawnPosition(game:GetRoom():GetCenterPos()), Vector(0,0), nil)
                end
            end
            player:GetData().ballCheck = true
        end]]

end
WarpZone:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, WarpZone.OnFrame)

function WarpZone:OnEntitySpawn(npc)
    local player = doesAnyoneHave(WarpZone.WarpZoneTypes.COLLECTIBLE_STRANGE_MARBLE, false)
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
    local player = doesAnyoneHave(WarpZone.WarpZoneTypes.COLLECTIBLE_STRANGE_MARBLE, false)
    if player ~= nil and npc:IsEnemy() and npc:IsChampion() then
        local championColor = npc:GetChampionColorIdx()
        local rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_STRANGE_MARBLE)
        ChampionsToLoot[championColor](EntityRef(npc), rng, EntityRef(player))
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, WarpZone.OnEntityDeath)

function WarpZone:UseDiogenes(collectible, rng, entityplayer, useflags, activeslot, customvardata)
    swapOutActive(WarpZone.WarpZoneTypes.COLLECTIBLE_DIOGENES_POT_LIVE, ActiveSlot.SLOT_PRIMARY, entityplayer, 0)
    SfxManager:Play(SoundEffect.SOUND_URN_OPEN)
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.UseDiogenes, WarpZone.WarpZoneTypes.COLLECTIBLE_DIOGENES_POT)

function WarpZone:SheathDiogenes(collectible, rng, entityplayer, useflags, activeslot, customvardata)
    swapOutActive(WarpZone.WarpZoneTypes.COLLECTIBLE_DIOGENES_POT, ActiveSlot.SLOT_PRIMARY, entityplayer, 0)
    SfxManager:Play(SoundEffect.SOUND_URN_CLOSE)
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.SheathDiogenes, WarpZone.WarpZoneTypes.COLLECTIBLE_DIOGENES_POT_LIVE)


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

function WarpZone:FireClub(player, direction, usingGlove)
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
    WarpZone.isGlove = usingGlove
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
                    if WarpZone.isGlove == true then
                        knife:GetData().isGloveObj = 2
                        WarpZone.isGlove = false
                    else
                        knife:GetData().isHammer = 2
                    end
				end
			elseif player and player:GetData().GrabbedClub and player:GetData().GrabbedClub:Exists() then
				knife.Variant = 1
			end
		elseif WarpZone.scanforclub then
			knife.Visible = false
		end
	end
end)

function WarpZone:OnKnifeUpdate(knife)
    if knife:GetData().isGloveObj == 2 then
        knife:GetSprite():ReplaceSpritesheet(1, "gfx/glove_shot.png")
        --knife:GetSprite().Color = Color(1, 0, 0, 1, 0, 0, 0)
        knife.Scale = knife.Scale * 1.5
        knife:GetSprite().Scale = knife:GetSprite().Scale * 1.5
        knife:GetData().isGloveObj = 1
        knife:GetSprite():LoadGraphics()
    elseif knife:GetData().isHammer == 2 then
        knife:GetSprite():ReplaceSpritesheet(1, "gfx/hammer_shot.png")
        knife:GetSprite().Scale = knife:GetSprite().Scale * 1.5
        knife:GetData().isHammer = 1
        knife:GetSprite():LoadGraphics()
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, WarpZone.OnKnifeUpdate)

WarpZone:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
	local player = WarpZone:GetPlayerFromTear(tear)
    
    if player then
        if player:HasCollectible(WarpZone.WarpZoneTypes.COLLECTIBLE_DIOGENES_POT_LIVE) then
            player:GetData().WarpZone_data.dioDamageOn = true
            tear:Remove()
            WarpZone:FireClub(player, player:GetFireDirection(), false)
        else
            player:GetData().WarpZone_data.dioDamageOn = false
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
            local player = orbital.Player
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, orbitalPosition, Vector(0, 0), orbital)
            end
            orbital:Remove()
            SfxManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
            player:GetData().WarpZone_data.roomsSinceBreak = 12
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                player:GetData().WarpZone_data.roomsSinceBreak = 4
            end
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

---@param player EntityPlayer
---@param cache_flag integer
local function update_cache(_, player, cache_flag)
	if cache_flag == CacheFlag.CACHE_FAMILIARS then
		local pop_pickups = player:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_LOLLIPOP)
		local pop_rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_LOLLIPOP)
		player:CheckFamiliar(Lollipop.VARIANT, pop_pickups, pop_rng)
        
        local tumor_count = player:GetData().WarpZone_data.playerTumors
        if tumor_count and game:GetFrameCount() > 1 then
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

        local ball_pickups = player:GetCollectibleNum(WarpZone.FOOTBALL.ITEM) --CollectibleType.COLLECTIBLE_FOOTBALL
        player:CheckFamiliar(WarpZone.FOOTBALL.FAM.VAR, ball_pickups, player:GetCollectibleRNG(WarpZone.FOOTBALL.ITEM))
        --respawnBalls(ball_pickups, player)

        local john_pickups = player:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_JOHNNYS_KNIVES)
        local john_rng = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_JOHNNYS_KNIVES)
        
        local myRNG4 = RNG()
        --myRNG4:SetSeed(Random(), 1)
        local myRNG5 = RNG()
        --myRNG5:SetSeed(Random(), 1)
		player:CheckFamiliar(KnifeVariantHappy, john_pickups, john_rng)
        player:CheckFamiliar(KnifeVariantSad, john_pickups, john_rng)

        local junkan_pickups = player:GetCollectibleNum(WarpZone.WarpZoneTypes)
        local junkan_fly_rng = RNG()
        junkan_fly_rng:SetSeed(Random(), 1)
        local junkan_walk_rng = RNG()
        junkan_walk_rng:SetSeed(Random(), 1)

        local junk_count = player:GetData().WarpZone_data.GetJunkCollected
        if junk_count > 0 then
            local flyFamiliars = math.min(junkan_pickups, math.floor(junk_count/16))
            local walkFamiliars = junkan_pickups-flyFamiliars
            player:CheckFamiliar(SerJunkanFly, flyFamiliars, junkan_fly_rng)
            player:CheckFamiliar(SerJunkanWalk, walkFamiliars, junkan_walk_rng)
        end
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



--[[function WarpZone:UpdateKnifeHappy(knife, renderoffset)
    local player = knife.Player
    local direction = player:GetHeadDirection()
    local dir_vector = getVectorFromDirection(direction)
    local offset = Vector(0, 0)
    local faceDirection = 17
    local sideDirection = 23
    local rotationSpace = 45
    if dir_vector then
        if direction == Direction.DOWN then
            offset = Vector(-sideDirection, faceDirection)
        elseif direction == Direction.UP then
            offset = Vector(sideDirection, -faceDirection)
        elseif direction == Direction.LEFT then
            offset = Vector(-faceDirection, -sideDirection)
        elseif direction == Direction.RIGHT then
            offset = Vector(faceDirection, sideDirection)
        end
        knife.Position = player.Position + offset
        knife.SpriteRotation = dir_vector:GetAngleDegrees() - (90 - rotationSpace)
    end
end
function WarpZone:UpdateKnifeSad(knife, renderoffset)
    local player = knife.Player
    local direction = player:GetHeadDirection()
    local dir_vector = getVectorFromDirection(direction)
    local offset = Vector(0, 0)
    local faceDirection = 17
    local sideDirection = 23
    local rotationSpace = 45
    if dir_vector then
        if direction == Direction.DOWN then
            offset = Vector(sideDirection, faceDirection)
        elseif direction == Direction.UP then
            offset = Vector(-sideDirection, -faceDirection)
        elseif direction == Direction.LEFT then
            offset = Vector(-faceDirection, sideDirection)
        elseif direction == Direction.RIGHT then
            offset = Vector(faceDirection, -sideDirection)
        end
        --print(tostring(knife.Position))
        --print(tostring(player.Position))
        --print(tostring(offset))
        knife.Position = player.Position + offset
        knife.SpriteRotation = dir_vector:GetAngleDegrees() - (90 + rotationSpace)
    end
end]]

--WarpZone:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, WarpZone.UpdateKnifeHappy, KnifeVariantHappy)
--WarpZone:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, WarpZone.UpdateKnifeSad, KnifeVariantSad)


--[[function WarpZone:OnJohnnyTouch(knife, collider, low)
    if collider and collider:IsVulnerableEnemy() then
        local damage = 6
        local frameCount = Game():GetFrameCount()
        
        if frameCount % 2 == 0 then
            if collider.HitPoints < damage then
                --collider:GetData().KilledByJohnny = true
                --print(collider.Mass)
                --print("kill1")
            end
            collider:TakeDamage(damage, 0, EntityRef(knife), 0)
        end
    end
end]]
--WarpZone:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, WarpZone.OnJohnnyTouch, KnifeVariantHappy)
--WarpZone:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, WarpZone.OnJohnnyTouch, KnifeVariantSad)


--function WarpZone:OnJohnnyKill(entity)
--    if entity:GetData().KilledByJohnny == true then
        
--    end
--end
--WarpZone:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, WarpZone.OnJohnnyKill)


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
            local numTumors = player:GetData().WarpZone_data.playerTumors
            if numTumors then
                damage = damage + ((numTumors - 10) * 0.2)
            end
        end
        if orbital.Player and orbital.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
            damage = damage * 2
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
    local player = doesAnyoneHave(WarpZone.WarpZoneTypes.COLLECTIBLE_BALL_OF_TUMORS, false)
    if game:GetRoom():GetFrameCount() <= 0 and not game:GetRoom():IsFirstVisit() then
        return nil --exclude spawns when re-entering a room with items
    end
    if player ~= nil and type == EntityType.ENTITY_PICKUP then
        local tumorRNG = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_BALL_OF_TUMORS)
        local rand_num = tumorRNG:RandomInt(100) + 1
        local collectible_num = player:GetCollectibleNum(WarpZone.WarpZoneTypes.COLLECTIBLE_BALL_OF_TUMORS) * 4
        
        if rand_num <= collectible_num and (variant <= 40 or
        variant == PickupVariant.PICKUP_LIL_BATTERY) then
            return {EntityType.ENTITY_PICKUP, tumorVariant, 1, seed}
        end
    end
    return nil
end
WarpZone:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, WarpZone.selectPickup)


local function playerToNum(player)
	for num = 0, game:GetNumPlayers()-1 do
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
	-- if game.Difficulty == Difficulty.DIFFICULTY_HARD then ticks = ticks - 6 end
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
		game:GetLevel():SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)
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
			local prizepos = game:GetRoom():FindFreePickupSpawnPosition(beggar.Position)
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

    if inTransit >= 0 and game:GetLevel():GetCurrentRoomIndex() == 84 then
        WarpZone:FinishTransit(game:GetRoom())
    end
end
WarpZone:AddCallback(ModCallbacks.MC_POST_UPDATE, WarpZone.BeggarUpdate)


function WarpZone:UseRLHand(collectible, rng, entityplayer, useflags, activeslot, customvardata)
    local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP)
    local left_rng = entityplayer:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_REAL_LEFT)
    local ischest = false

    for i, entity_pos in ipairs(entities) do
        local rand_num = left_rng:RandomInt(100) 
        if entity_pos.Variant == PickupVariant.PICKUP_MIMICCHEST then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HAUNTEDCHEST, 0)
            ischest = true
        elseif entity_pos.Variant == PickupVariant.PICKUP_HAUNTEDCHEST then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0)
            ischest = true
        elseif entity_pos.Variant == PickupVariant.PICKUP_CHEST then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_REDCHEST, 0)
            ischest = true
        elseif entity_pos.Variant == PickupVariant.PICKUP_REDCHEST and rand_num > 50 then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, 0)
            ischest = true
        elseif entity_pos.Variant == PickupVariant.PICKUP_REDCHEST then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMBCHEST, 0)
            ischest = true
        elseif (entity_pos.Variant == PickupVariant.PICKUP_BOMBCHEST or entity_pos.Variant == PickupVariant.PICKUP_LOCKEDCHEST) and rand_num > 50 then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_WOODENCHEST, 0)
            ischest = true
        elseif (entity_pos.Variant == PickupVariant.PICKUP_BOMBCHEST or entity_pos.Variant == PickupVariant.PICKUP_LOCKEDCHEST) then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_OLDCHEST, 0)
            ischest = true
        elseif (entity_pos.Variant == PickupVariant.PICKUP_OLDCHEST or entity_pos.Variant == PickupVariant.PICKUP_WOODENCHEST) then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_ETERNALCHEST, 0)
            ischest = true
        elseif entity_pos.Variant == PickupVariant.PICKUP_ETERNALCHEST then
            entity_pos:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_MEGACHEST, 0)
            ischest = true
        end
    end

    if not ischest then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_REDCHEST, ChestSubType.CHEST_CLOSED, game:GetRoom():FindFreePickupSpawnPosition(game:GetRoom():GetCenterPos()), Vector(0, 0), nil)
    end
    SfxManager:Play(SoundEffect.SOUND_CHEST_DROP, 2)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true
    }
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.UseRLHand, WarpZone.WarpZoneTypes.COLLECTIBLE_REAL_LEFT)


function WarpZone:FootballCollide(familiar, collider, low)
    if familiar:GetData().Football == true then
        local player = familiar.Player
        if collider:IsVulnerableEnemy() then
            --collider.Velocity = familiar.Velocity * 2
            --collider:AddVelocity(familiar.Velocity * 2 + Vector(10, 10))
            --collider.Friction
            --print(tostring(familiar.Velocity.X * 5) .. "  " .. tostring(familiar.Velocity.Y * 5))
            local damage = math.abs(familiar.Velocity.X + collider.Velocity.X) * 0.75 + math.abs(familiar.Velocity.Y + collider.Velocity.Y) * 0.75
            local footrand = player:GetCollectibleRNG(WarpZone.WarpZoneTypes.COLLECTIBLE_FOOTBALL)
            if damage > 10 and footrand:RandomInt(100) > 50 then
                collider:AddConfusion(EntityRef(familiar), 90, true)
            end
            collider:TakeDamage(damage, 0, EntityRef(familiar), 0)
            return false
        elseif collider:ToPlayer() ~= nil and not (game:GetLevel():GetCurrentRoomIndex() ==84 and game:GetRoom():IsFirstVisit()) then
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
    print(Isaac:GetItemConfig():GetCollectibles().Size-1)
    local entities = Isaac.GetRoomEntities()
    local debbug = ""
    for i, entity_pos in ipairs(entities) do
        if entity_pos.Type == EntityType.ENTITY_LARRYJR then
            debbug = tostring(entity_pos.Variant) .. "-" .. tostring(entity_pos.Position) .. " --  " ..  tostring(entity_pos.Parent.Position)
            print(debbug)
        end
    end

    local room = game:GetRoom()
    for i=1, room:GetGridSize() do
        local ge = room:GetGridEntity(i)
        if ge and ge:GetType() == GridEntityType.GRID_TRAPDOOR then
            --print(ge:GetGridIndex())
        end

    end
    return {
        Discharge = false,
        Remove = false,
        ShowAnim = true
    }
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.FindEffects, WarpZone.WarpZoneTypes.COLLECTIBLE_TEST_ACTIVE)



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
    if player:HasTrinket(WarpZone.WarpZoneTypes.TRINKET_BIBLE_THUMP) then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, false, false, true, false, -1, 0)
    end
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.BibleExtraDamage, CollectibleType.COLLECTIBLE_BIBLE)


function WarpZone:BibleKillSatan(collectible, rng, player, useflags, activeslot, customvardata)
    if player:HasTrinket(WarpZone.WarpZoneTypes.TRINKET_BIBLE_THUMP) and game:GetLevel():GetStage() == LevelStage.STAGE5 
    and game:GetRoom():GetType() == RoomType.ROOM_BOSS and game:GetLevel():GetStageType() == StageType.STAGETYPE_ORIGINAL then
    
            local entities_s = Isaac.FindByType(EntityType.ENTITY_SATAN)
            for i, entity_s in ipairs(entities_s) do
                entity_s:Kill()
            end
        return true
    elseif player:GetTrinketMultiplier(WarpZone.WarpZoneTypes.TRINKET_BIBLE_THUMP) >= 2 and game:GetLevel():GetStage() == LevelStage.STAGE6 
    and game:GetRoom():GetType() == RoomType.ROOM_BOSS and game:GetLevel():GetStageType() == StageType.STAGETYPE_ORIGINAL then
        local entities_s = Isaac.FindByType(EntityType.ENTITY_THE_LAMB)
            for i, entity_s in ipairs(entities_s) do
                entity_s:Kill()
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
            WarpZone.WarpZoneTypes.CARD_WITCH_CUBE,
            game:GetRoom():FindFreePickupSpawnPosition(player.Position),
            Vector(0,0),
            nil)
    end
end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.UseWitchCube, WarpZone.WarpZoneTypes.CARD_WITCH_CUBE)

function WarpZone:UseLootCard(card, player, useflags)
    local lootRNG = RNG()
    lootRNG:SetSeed(Random(), 1)
    local isTrinket = lootRNG:RandomInt(900) < 184
    if not isTrinket then
        local ranPool = lootRNG:RandomInt(ItemPoolType.NUM_ITEMPOOLS)
        Isaac.Spawn(EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_COLLECTIBLE,
            itemPool:GetCollectible(ranPool),
            game:GetRoom():FindFreePickupSpawnPosition(player.Position),
            Vector(0,0),
            nil)
    else
        Isaac.Spawn(EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_TRINKET,
            0,
            game:GetRoom():FindFreePickupSpawnPosition(player.Position),
            Vector(0,0),
            nil)
    end
    
end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.UseLootCard, WarpZone.WarpZoneTypes.CARD_LOOT_CARD)

function WarpZone:useCow(card, player, useflags)
    local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP)
    local itemID = nil
    local cowRNG =  RNG()
    cowRNG:SetSeed(Random(), 1)
    SfxManager:Play(WarpZone.WarpZoneTypes.SOUND_COW_TRASH, 2)
    for i, entity in ipairs(entities) do
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
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.useCow, WarpZone.WarpZoneTypes.CARD_COW_TRASH_FARM)

function WarpZone:useJester(card, player, useflags)
    local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
    for i, entity in ipairs(entities) do
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, entity.Position, entity.Velocity, player)
    end
    for i=1, 6, 1 do
        player:UseCard(Card.CARD_SOUL_ISAAC, 257)
    end
end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.useJester, WarpZone.WarpZoneTypes.CARD_JESTER_CUBE)



function WarpZone:useBlank(card, player, useflags)
    local center = player.Position
    local radius = 99999
	--Remove projectiles in radius
	for _, projectile in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
		projectile = projectile:ToProjectile()

		local realPosition = projectile.Position - Vector(0, projectile.Height)

		if realPosition:DistanceSquared(center) <= (radius * 3) ^ 2 then
			if projectile:HasProjectileFlags(ProjectileFlags.ACID_GREEN) or
			projectile:HasProjectileFlags(ProjectileFlags.ACID_RED) or
			projectile:HasProjectileFlags(ProjectileFlags.CREEP_BROWN) or
			projectile:HasProjectileFlags(ProjectileFlags.EXPLODE) or
			projectile:HasProjectileFlags(ProjectileFlags.BURST) or
			projectile:HasProjectileFlags(ProjectileFlags.ACID_GREEN) then
				--If the projectile has any flag that triggers on hit, we need to remove the projectile
				projectile:Remove()
			else
				projectile:Die()
			end
		end
	end
    local blankRNG =  RNG()
    blankRNG:SetSeed(Random(), 1)
	--Push enemies back
	for _, entity in ipairs(Isaac.FindInRadius(center, radius * 3, EntityPartition.ENEMY)) do
		if entity:IsActiveEnemy(false) and entity:IsVulnerableEnemy() then
			local pushDirection = (entity.Position - center):Normalized()
			entity:AddVelocity(pushDirection * 30)
            if blankRNG:RandomInt(5) == 2 then
                entity:AddConfusion(EntityRef(player), 60, true)
            end
		end
	end
    local entity_source = Isaac.Spawn(EntityType.ENTITY_EFFECT,
        EffectVariant.SIREN_RING,
        0,
        player.Position,
        Vector(0,0),
        nil)

    local entity_sprite = entity_source:GetSprite()
    entity_sprite.PlaybackSpeed = entity_sprite.PlaybackSpeed * 2
    entity_sprite.Color = Color(0, 0, 1, 1, 0, 0, .5)
    SfxManager:Play(SoundEffect.SOUND_DEATH_CARD)

end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.useBlank, WarpZone.WarpZoneTypes.CARD_BLANK)

function WarpZone:useBlank2(card, player, useflags)
    WarpZone:useBlank(card, player, useflags)
    if useflags & 2208 == 0 then
        player:AddCard(WarpZone.WarpZoneTypes.CARD_BLANK)
    end
end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.useBlank2, WarpZone.WarpZoneTypes.CARD_BLANK_2)


function WarpZone:useBlank3(card, player, useflags)
    WarpZone:useBlank(card, player, useflags)
    if useflags & 2208 == 0 then
        player:AddCard(WarpZone.WarpZoneTypes.CARD_BLANK_2)
    end
end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.useBlank3, WarpZone.WarpZoneTypes.CARD_BLANK_3)

function WarpZone:cardRNG(RNG, cardS, IncludePlayingCards, IncludeRunes, OnlyRunes)
    if cardS == WarpZone.WarpZoneTypes.CARD_BLANK or cardS == WarpZone.WarpZoneTypes.CARD_BLANK_2 then
        return WarpZone.WarpZoneTypes.CARD_BLANK_3
    end
end
WarpZone:AddCallback(ModCallbacks.MC_GET_CARD, WarpZone.cardRNG)



function WarpZone:UseEmergencyMeeting(collectible, rng, player, useflags, activeslot, customvardata)

    local roomtype = game:GetRoom():GetType()
    local spawnedEnemies= false
    local enemyEntities = Isaac.GetRoomEntities()

    if (game:GetLevel():GetStage() == LevelStage.STAGE3_2 and roomtype == RoomType.ROOM_BOSS) or
    (game:GetLevel():GetStage() == LevelStage.STAGE4_2 and roomtype == RoomType.ROOM_BOSS) or
    game:GetLevel():GetStage() == LevelStage.STAGE4_3 or
    game:GetLevel():GetStage() == LevelStage.STAGE8 then
        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false
        }
    end

    for i, entity in ipairs(enemyEntities) do
        if entity:IsActiveEnemy() then
            if (entity.Type == EntityType.ENTITY_PIN and entity.Parent ~= nil) or
            entity.Type == EntityType.ENTITY_GEMINI and entity.Variant >= 10 then
                goto skipmark
            end

            spawnedEnemies = true
            enemiesToMove[i] = {}
            enemiesToMove[i].Position = Vector(entity.Position.X, entity.Position.Y)--entity.Position
            enemiesToMove[i].Type = entity.Type
            enemiesToMove[i].Variant = entity.Variant
            enemiesToMove[i].SubType = entity.SubType
            enemiesToMove[i].Flags= entity:GetEntityFlags()
            enemiesToMove[i].HitPoints = entity.HitPoints
            enemiesToMove[i].Data = entity:GetData()

            ::skipmark::
            entity:Remove()
        end
        
    end
    if roomtype == RoomType.ROOM_BOSS and spawnedEnemies and not game:GetRoom():IsClear() then
        inTransit = 2
        table.insert(roomsPrepped, game:GetLevel():GetCurrentRoomIndex())
    elseif spawnedEnemies then
        inTransit = 1
        game:GetRoom():SetClear(true)
    end
    
    player:UseCard(Card.CARD_FOOL, 257)
    SfxManager:Play(WarpZone.WarpZoneTypes.SOUND_EMERGENCY_MEETING, 2)
    ::continue::
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.UseEmergencyMeeting, WarpZone.WarpZoneTypes.COLLECTIBLE_EMERGENCY_MEETING)


function WarpZone:OnPlayerCollide(player, collider)
    if game:GetFrameCount() - isNil(player:GetData().InGravityState, -999) < 150 then
        return true
    end
    if collider:IsActiveEnemy() and game:GetFrameCount() - isNil(player:GetData().MurderFrame, -999) < 15 then
        collider:Die()
        SfxManager:Play(WarpZone.WarpZoneTypes.SOUND_MURDER_KILL, 2)
        return true
    end
end
WarpZone:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, WarpZone.OnPlayerCollide)


function WarpZone:FinishTransit(room)
    local spawnedEnemies= false
    --local isBossRoom = inTransit
    local emergencyRNG =  RNG()
    emergencyRNG:SetSeed(Random(), 1)
    if inTransit == 2 then
        isBossEmergency = true
    end
    inTransit = -1
    local sus = emergencyRNG:RandomInt(#enemiesToMove)
    local i = 0
    for k, mapping in pairs(enemiesToMove) do
        spawnedEnemies = true
        WarpZone.AnyPlayerDo(function(player) player:SetMinDamageCooldown(60) end)
        
        if not room:IsPositionInRoom(mapping.Position, 40) then
            mapping.Position = room:GetRandomPosition(40)
        end

        local newenemy = Isaac.Spawn(mapping.Type,
        mapping.Variant,
        mapping.SubType,
        mapping.Position,
        Vector(0,0),
        nil)

        newenemy:AddEntityFlags(mapping.Flags)
        newenemy:AddConfusion(EntityRef(newenemy), 90, false)
        newenemy.HitPoints = mapping.HitPoints
        if i == sus and not newenemy:IsBoss() then
           newenemy:AddEntityFlags(EntityFlag.FLAG_BAITED)
        end

        --if isBossRoom > 1 and newenemy:IsBoss() and game:GetLevel():GetStage() <= 7 then 
        --    isBossRoom = 1
        --    newenemy:GetData().BossSpawnItems = true
        --end

        for d,v in pairs(mapping.Data) do
            newenemy:GetData()[d] = v
        end
        i = i + 1
    end

    if spawnedEnemies == true then
        room:SetClear(false)
    end

    while next (enemiesToMove) do
        enemiesToMove[next(enemiesToMove)]=nil
    end
    
    for i = 0, 7 do
        local door = room:GetDoor(i)
        if door then
            local doorEntity = door:ToDoor()
            if doorEntity:IsOpen() then
                doorEntity:Close()
            end
        end
    end
end

function WarpZone:UseFiendFire(card, player, useflags)
    local data = player:GetData()
    local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP)
    local fireRng = RNG()
    fireRng:SetSeed(Random(), 1)
    for i, entity in ipairs(entities) do
        if entity.Variant <= 90 or
        entity.Variant == PickupVariant.PICKUP_REDCHEST
        or entity.Variant == PickupVariant.PICKUP_TRINKET
        or entity.Variant == PickupVariant.PICKUP_TAROTCARD
        then
           Isaac.Spawn(EntityType.ENTITY_EFFECT,
           EffectVariant.HOT_BOMB_FIRE,
           0,
           entity.Position,
           Vector(fireRng:RandomFloat() - .5, fireRng:RandomFloat() - .5) * Vector(2, 2),
           nil)
           entity:Remove()

            local chosenStat = fireRng:RandomInt(5)
            if chosenStat == 0 then
                data.WarpZone_data.bonusRange = data.WarpZone_data.bonusRange + 20
            elseif chosenStat == 1 then
                data.WarpZone_data.bonusDamage = data.WarpZone_data.bonusDamage + .2
            elseif chosenStat == 2 then
                data.WarpZone_data.bonusLuck = data.WarpZone_data.bonusLuck + .2
            elseif chosenStat == 3 then
                data.WarpZone_data.bonusSpeed = data.WarpZone_data.bonusSpeed + .04
            elseif chosenStat == 4 then
                data.WarpZone_data.bonusFireDelay = data.WarpZone_data.bonusFireDelay + .2
            end
        end
    end
    SfxManager:Play(SoundEffect.SOUND_FIRE_RUSH, 2)
    SfxManager:Play(SoundEffect.SOUND_FIREDEATH_HISS, 2) 
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()

end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.UseFiendFire, WarpZone.WarpZoneTypes.CARD_FIEND_FIRE)

function WarpZone:UseDemonForm2(card, player, useflags)
    SfxManager:Play(SoundEffect.SOUND_SATAN_GROW)
    if player:GetData().WarpZone_data.InDemonForm == nil then
        player:GetData().WarpZone_data.InDemonForm = player:GetPlayerType()
        player:ChangePlayerType(PlayerType.PLAYER_AZAZEL)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()

    end
end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.UseDemonForm2, WarpZone.WarpZoneTypes.CARD_DEMON_FORM)

function WarpZone:UseMurderCard(card, player, useflags)
    player:GetData().MurderFrame = game:GetFrameCount()
    player:GetSprite().Color = Color(1, 0, 0, 1, 0, 0, 0)
    player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_LEO, false, 1)
    player:GetData().InMurderState = true
    SfxManager:Play(WarpZone.WarpZoneTypes.SOUND_MURDER_STING)
end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.UseMurderCard, WarpZone.WarpZoneTypes.CARD_MURDER)


function WarpZone:UseAmberChunk(card, player, useflags)
    local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP)
    local amberRng = RNG()
    amberRng:SetSeed(Random(), 1)

    if preservedItems == nil then
        preservedItems = {}
    end
    for k, v in pairs(preservedItems) do
        Isaac.Spawn(EntityType.ENTITY_PICKUP,
           v.Variant,
           v.SubType,
           game:GetRoom():FindFreePickupSpawnPosition(player.Position),
           Vector(0, 0),
           nil)
        tableContains(preservedItems, v, true)

    end
    while next (preservedItems) do
        preservedItems[next(preservedItems)]=nil
    end
    for i, entity in ipairs(entities) do --this shouldn't actually work but it seems to work anyway. i'm not gonna touch it
        if entity.Variant <= 90 or
        entity.Variant == PickupVariant.PICKUP_REDCHEST
        or entity.Variant == PickupVariant.PICKUP_TRINKET
        or entity.Variant == PickupVariant.PICKUP_TAROTCARD
        or entity.Variant == PickupVariant.PICKUP_COLLECTIBLE
        or entity.Variant == PickupVariant.PICKUP_BIGCHEST
        or entity.Variant == PickupVariant.PICKUP_TROPHY
        then
            
           preservedItems[i] = {}
           preservedItems[i].Variant = entity.Variant
           preservedItems[i].SubType = entity.SubType
           entity:Remove()

        end
    end
    Isaac.Spawn(EntityType.ENTITY_PICKUP,
           PickupVariant.PICKUP_COIN,
           CoinSubType.COIN_LUCKYPENNY,
           game:GetRoom():FindFreePickupSpawnPosition(player.Position),
           Vector(0, 0),
           nil)
end
WarpZone:AddCallback(ModCallbacks.MC_USE_CARD, WarpZone.UseAmberChunk, WarpZone.WarpZoneTypes.CARD_AMBER_CHUNK)

function WarpZone:fireGlove(player)
    --print(player:GetLastDirection().X .. " " .. player:GetLastDirection().Y .. " aiming")
    local punchDestination = player.Position + (player:GetLastDirection() * 20)
    
    WarpZone:FireClub(player, getDirectionFromVector(player:GetLastDirection()), true)
end

function WarpZone:useGravity(collectible, rng, player, useflags, activeslot, customvardata)
    --player:AnimateLightTravel()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
        if useflags & UseFlag.USE_CARBATTERY ~= 0 then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false
            }
        end
    end
    player:PlayExtraAnimation("TeleportUp")
    print("used")
    player:GetData().InGravityState = game:GetFrameCount()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
        player:GetData().InGravityState = player:GetData().InGravityState + 150
    end
    player:AddCacheFlags(CacheFlag.CACHE_RANGE)
    player:AddCacheFlags(CacheFlag.CACHE_FLYING)
    player:EvaluateItems()
    SfxManager:Play(SoundEffect.SOUND_THUMBSUP, 2)
    player:GetData().gravReticle = Isaac.Spawn(1000, 30, 0, player.Position, Vector(0, 0), player)
    player:GetData().gravReticle:GetSprite():ReplaceSpritesheet(0, "gfx/gravity_lander.png")
    player:GetData().gravReticle:GetSprite():LoadGraphics()
    player:GetData().gravReticle.Color = Color(0.392, 0.917, 0.509, .5, 0, 0, 0)
end
WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.useGravity, WarpZone.WarpZoneTypes.COLLECTIBLE_GRAVITY)


--extra files and translation
local ItemTranslate = include("lua.ItemTranslate")
ItemTranslate("WarpZone")

local extrafiles = {
    "lua.ru",
    "lua.football",
    "lua.bombs",
    "lua.johnnys_knives"
}
for i=1,#extrafiles do
    local module = include(extrafiles[i])
    module(WarpZone)
end
