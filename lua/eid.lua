--external item descriptions
if EID then
	EID:addCollectible(Isaac.GetItemIdByName("Golden Idol"), "#{{ArrowUp}} The player has a 50% chance of receiving a fading nickel when a room is cleared#{{ArrowDown}} Getting damage causes the player to lose half their money, dropping some of it on the ground as fading coins.#{{ArrowDown}} When the player is holding money, damage is always 1 full heart", "Golden Idol", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Gun that can kill the Past"), "#{{Collectible}} Removes the oldest item from your inventory, including quest items like the Key Pieces#3 choice pedestals appear#{{Collectible}} The new items are from the same pools as the one you lost. It can be used 3 times.", "Gun that can Kill the Past", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName(" Gun that can kill the Past "), "#{{Collectible}} Removes the oldest item from your inventory, including quest items like the Key Pieces#3 choice pedestals appear#{{Collectible}} The new items are from the same pools as the one you lost. It can be used 3 times.", "Gun that can Kill the Past", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("  Gun that can kill the Past  "), "#{{Collectible}} Removes the oldest item from your inventory, including quest items like the Key Pieces#3 choice pedestals appear#{{Collectible}} The new items are from the same pools as the one you lost. It can be used 3 times.", "Gun that can Kill the Past", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Birthday Cake"), "{{Heart}} +1 HP#A random consumable and pickups of each type now spawn at the start of every floor", "Birthday Cake", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Rusty Spoon"), "#{{BleedingOut}} 10% chance to fire a homing tear that inflicts bleed#{{Luck}} 100% chance at 18 Luck", "Rusty Spoon", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Newgrounds Tank"), "{{Speed}} -0.3 Speed#{{Tears}} +0.27 Tears#{{Damage}} +0.5 Damage#{{Range}} +1 Range#{{Shotspeed}} +0.16 Shot Speed#{{Luck}} +1 Luck#On taking a hit, the player has a 10% chance to shield from damage#Tears that don't hit enemies explode on landing", "Newgrounds Tank", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Greed Butt"), "#{{Coin}} When hit by an enemy or projectile , you fart, launching a coin out of your butt#{{PoopPickup}} There is a 5% chance that you drop a gold poop instead#Recharges by taking coins", "Greed Butt", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Focus"), "#{{Heart}} When used, hold to get red hearts, when at full red health to get soul hearts.#{{HolyMantleSmall}} When at 12 full hearts hold longer to get mantle", "Focus", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName(" Focus "), "#{{Heart}} When used, hold to get red hearts, when at full red health to get soul hearts.#{{HolyMantleSmall}} When at 12 full hearts hold longer to get mantle", "Focus", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("  Focus  "), "#{{Heart}} When used, hold to get red hearts, when at full red health to get soul hearts.#{{HolyMantleSmall}} When at 12 full hearts hold longer to get mantle", "Focus", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("   Focus   "), "#{{Heart}} When used, hold to get red hearts, when at full red health to get soul hearts.#{{HolyMantleSmall} When at 12 full hearts hold longer to get mantle", "Focus", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("The Doorway"), "#{{Room}} All doors are opened, and stay open for the rest of the floor#Secret rooms, Angel/Devil rooms, The Mega Satan door, Boss Rush and Hush are included#{{ChallengeRoom}} Challenge Rooms are open to enter, however the door closes when activating the challenge#{{UltraSecretRoom}} The Ultra Secret Room is unlocked, and red rooms are now open to the edge of the map, revealing the error room", "The Doorway", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Strange Marble"), "#{{MiniBoss}} All enemies have a 1 in 8 chance to become champions#{{ArrowUp}} Champions always drop loot, and often have a chance to drop extra", "Strange Marble", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Is You"), "#Point the reticle at an obstacle to use an active item effect that corresponds to it#{{Warning}} {{ColorYellow}}Full list of items can be viewed on wiki page of this mod", "Is You",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Nightmare Tick"), "#{{ArrowDown}} Every 8 room clears, one passive item is removed from your inventory#{{Damage}} +0.75 Damage for each item removed this way", "Nightmare Tick",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Spelunker's Pack"), "#{{Bomb}} +12 bombs#Bombs are Throwable now#(Effect below is the second effect that can be turned on in configuration)#Pits within your bombs' blast radius are filled in#When your bomb explodes, the resonant force breaks tinted and super secret rocks throughout the room #{{Bomb}} Bomb rocks in the room will break apart, dropping a bomb pickup", "Spelunker's Pack",  "en_us")

    EID:addTrinket(Isaac.GetTrinketIdByName("Ring of the Snake"), "#{{Card}} Receive 2 cards at the start of each floor", "Ring of the Snake", "en_us")

    EID:addCollectible(Isaac.GetItemIdByName("Diogenes's Pot"), "Toggles a melee hammer strike on and off#{{Damage}} When equipped, you receive a 1.5x damage multiplier#{{Card1}} Getting hit while equipped teleports you to the starting room", "Diogenes's Pot",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName(" Diogenes's Pot "), "Toggles a melee hammer strike on and off#{{Damage}} When equipped, you receive a 1.5x damage multiplier#{{Card1}} Getting hit while equipped teleports you to the starting room", "Diogenes's Pot",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("George"), "{{Range}} +2.4 Range#When entering most special rooms, a red room will unlock across from you", "George",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Possession"), "{{Charm}} Each room, one random non-boss enemy will be permanently charmed#These enemies carry over between rooms#{{Charm}} Only 15 enemies can be charmed at a time#Taking damage (excluding sacrifice rooms, etc) removes the charm from all affected enemies, making them hostile again#Stackable", "Possession",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Lollipop"), "{{Charm}} Spawns a lollipop orbital. It does no damage, but it charms enemies on contact#This orbital blocks bullets and breaks over time#{{Heart}} When Lollipop breaks, Spawn a Heart", "Lollipop",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Water Bottle"), "{{Tears}} +0.43 Tears#{{Tearsize}} Tear Size Up#In hostile rooms water streams appear. Touching it will grant tear rate buff that drains#Shops contain water bottle pick ups that will grant buff like from stream that doesnt drain.", "Water Bottle",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Aubrey"), "Once per floor, when entering a shop, a weapon beggar will spawn.#{{Collectible}} Weapon beggars take coins, and spawn only active items from every pool.#{{Collectible}} 3 active items are spawned from one weapon beggar before it leaves.", "Aubrey",  "en_us")

    EID:addCollectible(Isaac.GetItemIdByName("Tony"), "{{ArrowUp}} Taking damage activates berserk mode, and you start using your knuckles#{{ArrowUp}} Knuckles instakill enemies with less than 100 hp, and deals 5x your damage to enemies with more than 100 hp#Duration of effect is 2.5 seconds and can be changed in dss", "Tony",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("The Real Left Hand"), "{{Chest}} On use, upgrades all chests in the room into a better counterpart#Chest Order: {{SpikedChest}} > {{HauntedChest}} > {{Chest}} > {{RedChest}} > {{GoldenChest}} or {{StoneChest}} > {{WoodenChest}} or {{DirtyChest}} > {{HolyChest}} > {{MegaChest}}", "The Real Left Hand",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Hitops"), "{{Speed}} +0.2 Speed#This speed up can exceed the speed cap#Staying very near to enemy charms it", "Hitops",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Pop Pop"), "Double tap to fire two 3x damage tears in a burst#{{Timer}} Tear rate is reduced for a short time after using this effect.", "Pop Pop",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Football"), "{{Throwable}} Throwable#Spawns a football familiar that can be picked up and thrown at enemies#{{Damage}} The football deals damage based on its speed", "Football",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Ball of Tumors"), "{{GrabBag}} Bombs, hearts, keys and batteries have a small chance of turning into collectible tumors#Collecting tumors powers a tumor orbital, which blocks shots and deals contact damage#With enough tumors, a second orbital will spawn", "Ball of Tumors",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Bow and Arrow"), "{{Damage}} Isaac is able to shoot small, piercing arrow tears that deal 2.5x damage, capacity depends on your tear rate#Once the ammo is depleted, Isaac fires normal tears#When a tear lands, it drops an arrow that will replenish 1 tear when collected", "Bow and Arrow",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Emergency Meeting"), "{{Card1}} On use, teleports you and all other enemies in the room to the starting room.#On arrival, all enemies, including bosses, are confused for a few seconds", "Emergency Meeting",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Boxing Glove"), "{{Chargeable}} Gain a charged punching attack with a 2.35 second charge time#{{Confusion}} The punch has high knockback and stuns enemies", "Boxing Glove",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Gravity"), "{{Timer}} On use, you fall up to the ceiling for about 5 seconds.#{{Seraphim}} While in this state, gain flight, invulnerability, and +6.25 Range#Tears rain down from the top of the screen, regardless of the fired direction.", "Gravity",  "en_us")
    EID:addCollectible( Isaac.GetItemIdByName("Johnny's Knives"), "{{Throwable}} Throwable#Gain two homing flying knife familiars that do damage on contact#When killing enemies with the knives, spawn a pool of red creep that damages enemies. The size of the creep depends on the enemy's mass.#{{Tears}} When enemy is killed by knives, gain +0.5 Tears to the rest of the room.", "Johnny's Knives",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Ser Junkan"), "Spawns a familiar that pursues enemies and does contact damage.#You can blow up items with bombs. Collecting the junk that comes out upgrades your familiar.#Collecting 7 junk gives Junkan flight, and lets him fire spectral homing projectiles at the nearest enemy.", "Ser Junkan",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("The Crowdfunder"), "Use to toggle a coin-firing minigun#Each bullet costs 1 cent to fire.#When hitting a wall, bullets have a chance to drop a fading coin.#Killing enemies with The Crowdfunder may also drop extra money.", "The Crowdfunder",  "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Polar Star"), "Player now has an upgradable gun weapon. Use to switch to jetpack form #Kill enough monsters to get experience. Shares experience with jetpack form#Level 1 - Default shots with x1.5 damage#Level 2 - Double shots with damage same as Level 1# Level 3 - 1 big bullet with big multiplyer.", "Polar Star", "en_us")
    EID:addCollectible(Isaac.GetItemIdByName("Booster V2.0"), "PLayer now has an upgradable jetpack. Use to switch to gun form#Kill enough monsters to get experience. Shares experience with gun form# Level 1 - +0.65 speed, flight#Level 2 - Jetpack now leaves a damagin trail that burns enemies#Level 3 - Next hit you get will be nullified, you will explode and go back to Level 2", "Booster V2.0", "en_us")
	
    EID:addTrinket(Isaac.GetTrinketIdByName("Hunky Boys"), "While held, pressing the Drop Trinket button immediately drops this trinket; you don't need to hold the button#When on the ground, enemies will target the trinket for a short time.", "Hunky Boys", "en_us")
    EID:addTrinket(Isaac.GetTrinketIdByName("Bible Thump"), "{{Collectible33}} The Bible is added to several item pools.#{{Collectible33}} Using The Bible or The Devil? card with this item will deal 40 damage to all enemies in the room, in addition to granting flight.#{{Satan}}Using The Bible on  Satan will kill him, and you will survive#{{TheLamb}}The golden version of this trinket kills The Lamb as well.", "Bible Thump", "en_us")
    EID:addTrinket(Isaac.GetTrinketIdByName("Cheep Cheep"), "{{Fear}} On entering a room, a random enemy is targeted by other enemies and has a fear effect for 3 seconds.#If the effect is golden, the target also bleeds.", "Cheep Cheep", "en_us")

    EID:addCard(Isaac.GetCardIdByName("CowOnTrash"), "{{LordoftheFlies}} Rerolls all items into fly themed items#Rerolls pickups into blue flies#{{Coin}} Does not actually become back your money", "Cow on a Trash Farm", "en_us")
    EID:addCard(Isaac.GetCardIdByName("LootCard"), "{{Collectible}} Randomly spawns a random item or trinket from any pool", "Loot Card", "en_us")
    EID:addCard(Isaac.GetCardIdByName("Blank"), "Clears all enemy projectiles in the room.#Pushes nearby enemies away#There is one use left", "Blank", "en_us")
    EID:addCard(Isaac.GetCardIdByName("Blank2"), "Clears all enemy projectiles in the room.#Pushes nearby enemies away#There are two uses left", "Blank", "en_us")
    EID:addCard(Isaac.GetCardIdByName("Blank3"), "Clears all enemy projectiles in the room.#Pushes nearby enemies away#You can use this 3 times before it disappears", "Blank", "en_us")
    EID:addCard(Isaac.GetCardIdByName("JesterCube"), "{{Collectible}} On use, all items in the room will cycle between 6 additional choices, similar to Glitched Crown", "Jester", "en_us")
    EID:addCard(Isaac.GetCardIdByName("WitchCube"), "50% chance to deal 40 damage to all enemies in the room and apply burn.#50% chance to spawn another Witch and fire off a poison fart", "Witch", "en_us")
    EID:addCard(Isaac.GetCardIdByName("MurderCard"), "For a quarter second, increase speed to 4 and kill everything you touch.#{{Stompy}} Gain a Stompy effect for the room", "Murder!", "en_us")
    EID:addCard(Isaac.GetCardIdByName("AmberChunk"), "{{Collectible}} All pickups in the room, including items and the final chest at the end of the game, will be removed and saved.#The previous items you consumed in this way will respawn, even across games#You will also receive a {{Coin}} lucky penny", "Chunk of Amber", "en_us")
    EID:addCard(Isaac.GetCardIdByName("FiendFire"), "All pickups in the room are consumed#For each pickup consumed, gain a small, permanent boost to Damage, Tears, Luck, Range, or Speed#{{Burning}} Pickups turn into fires, which can damage enemies.", "Fiend Fire", "en_us")
    EID:addCard(Isaac.GetCardIdByName("DemonForm"), "{{Player7}} For the current room, Isaac becomes Azazel with a wide Brimstone#{{Damage}} +1 Damage", "Demon Form", "en_us")
    
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


    EID:addCollectible(Isaac.GetItemIdByName("Golden Idol"), "#{{ArrowUp}} 50% заспавнить никель который пропадет через 2 секундывместе с наградой за зачистку комнаты.#{{ArrowDown}} Получение урона лишает вас половины всех денег. Из них половина упадет на землю и пропадет через 1 секунду.#{{ArrowDown}} Когда игрок держит больше 1 монеты урон (кроме жертвоприношений) по игроку будет равен 1 сердцу", "Золотой Идол", "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Gun that can kill the Past"), "#{{Collectible}} Удаляет первый предмет#Создает выбор из 3 предметов#{{Collectible}} Новые предметы из того же пула что и старый. Можно использовать 3 раза.", "Пушка Убивающая Прошлое", "ru")
    EID:addCollectible(Isaac.GetItemIdByName(" Gun that can kill the Past "), "#{{Collectible}} Удаляет первый предмет#Создает выбор из 3 предметов#{{Collectible}} Новые предметы из того же пула что и старый. Можно использовать 3 раза.", "Пушка Убивающая Прошлое", "ru")
    EID:addCollectible(Isaac.GetItemIdByName("  Gun that can kill the Past  "), "#{{Collectible}} Удаляет первый предмет#Создает выбор из 3 предметов#{{Collectible}} Новые предметы из того же пула что и старый. Можно использовать 3 раза.", "Пушка Убивающая Прошлое", "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Birthday Cake"), "{{Heart}} +1 Полное Сердце#В начале этажа создает монету, сердце, бомбу, ключ и либо карту/пилюлю/руну либо брелок", "Именинный Торт", "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Rusty Spoon"), "#{{BleedingOut}} 10% шанс выпустить самонаводящуюся слезу которая накладывает кровотечение. Прикосновение со врагом накладывает на него эффект кровотечения.#{{Luck}} 100% шанс при 18 удачи", "Ржавая Ложка", "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Newgrounds Tank"), "{{Speed}} -0.3 Скорости#{{Tears}} +0.27 Скорострельности#{{Damage}} +0.5 Урона#{{Range}} +1 Дальность#{{Shotspeed}} +0.16 Скорость Выстрела#{{Luck}} +1 Удача#Получение урона имеет 10% шанс не сработать#Слезы, не попавшие во врага взрываются", "Танк Newgrounds", "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Greed Butt"), "#{{Coin}} Вместо получения урона игрок пукает и создает монетку.#{{PoopPickup}} Вместо монеты 5% шанс создать золотую кучку#Перезаряжается подбором монет", "Алчная Жопа", "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Focus"), "#{{Heart}} При использовании, держите для восстановления красных сердец#{{HolyMantleSmall}} При полном здоровье, держите дольше для получения одноразовой мантии", "Фокус", "ru")
    EID:addCollectible(Isaac.GetItemIdByName(" Focus "), "#{{Heart}} При использовании, держите для восстановления красных сердец#{{HolyMantleSmall}} При полном здоровье, держите дольше для получения одноразовой мантии", "Фокус", "ru")
    EID:addCollectible(Isaac.GetItemIdByName("  Focus  "), "#{{Heart}} При использовании, держите для восстановления красных сердец#{{HolyMantleSmall}} При полном здоровье, держите дольше для получения одноразовой мантии", "Фокус", "ru")
    EID:addCollectible(Isaac.GetItemIdByName("   Focus   "), "#{{Heart}} При использовании, держите для восстановления красных сердец#{{HolyMantleSmall}} При полном здоровье, держите дольше для получения одноразовой мантии", "Фокус", "ru")
    EID:addCollectible(Isaac.GetItemIdByName("The Doorway"), "#{{Room}} Все комнаты открыты до конца этажа#Так же работает на секретки, сделку с дьяволос/ангельскую комнату, Дверь к мега сатане и проход к Молчанию и Набегу боссов#{{UltraSecretRoom}} Открывает путь к ультра секретной комнате и путь к комнате Я-ОШИБКА, проходящий сквозь ультра секретную комнату", "Проход", "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Strange Marble"), "#{{MiniBoss}}1/8 шанс, что ЛЮБОЙ энтити станет чемпионом#{{ArrowUp}} Чемпионы всегда оставляют награды, добавление наград к чемпионам у которых ее не было.", "Странный Марбл", "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Is You"), "#Активирует активный предмет, связанный с обьектом на который вы направили знак#{{Warning}} {{ColorYellow}}Полный список объектов находится на вики мода!", "ЭТО ТЫ",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Nightmare Tick"), "#{{ArrowDown}} Каждые 8 комнат удаляет 1 предмет из инвентаря#{{Damage}} +0.75 урона за каждый удаленный предмет", "Кошмарный Клещ",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Spelunker's Pack"), "#{{Bomb}} +12 Бомб#Бомбы можно бросать#(Эффект далее можно включить в настройках мода)#Взрывы заполняют ямы#Взрывание бомбы так же взрывает все меченые камни, независимо от того, находятся они в радиусе взрыва, или нет#{{Bomb}} При взрыве камни с бомбами разрушатся и из них выпадет бомба", "Рюкзак Спелеолога",  "ru")

    EID:addTrinket(Isaac.GetTrinketIdByName("Ring of the Snake"), "#{{Card}} Создает 2 КАРТЫ в начале каждого этажа", "Кольцо Змеи", "ru")

    EID:addCollectible(Isaac.GetItemIdByName("Diogenes's Pot"), "Использование включает режим при котором вы начинаете использовать молот как оружие#{{Damage}} x1.5 множитель урона#{{Card1}} Получение урона телепортирует вас в начальную комнату", "Пифос Диогена",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName(" Diogenes's Pot "), "Использование включает режим при котором вы начинаете использовать молот как оружие#{{Damage}} x1.5 множитель урона#{{Card1}} Получение урона телепортирует вас в начальную комнату", "Пифос Диогена",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("George"), "{{Range}} +2.4 Дальности#Входя в специальную комнату открывает красную комнату напротив входа", "Джордж",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Possession"), "{{Charm}} Каждую комнату один враг будет очарован#Очарованные враги переходят в следующие комнаты#{{Charm}} Максимально может быть 15 очарованных врагов#Получение урона (кроме жертвоприношений) делает всех врагов снова враждебными", "Одержимость",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Lollipop"), "{{Charm}} Создает спутника-леденца. При контакте с врагом, очаровывает его#Блокирует вражеские слезы и ломается с каждой заблокированной слезой#{{Heart}} Когда леденец ломается, он спавнит сердце", "Леденец",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Water Bottle"), "{{Tears}} +0.43 Скорострельности#{{Tearsize}} Повышение Размер Слез#Время от времени создает фонтаны во вражеской комнате которые дают временную прибавку к скорострельности", "Бутылка Воды",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Aubrey"), "В магазинах появляется специальный попрошайка#{{Collectible}} Попрошайка берет монеты и дропает в качестве награды активные предметы#{{Collectible}} Максимум можно получить 3 активных предмета", "Обри",  "ru")

    EID:addCollectible(Isaac.GetItemIdByName("Tony"), "{{ArrowUp}} Получение урона активирует ярость при которой игрок начинает использовать кулаки в качестве оружия#{{ArrowUp}} Кулаки убивают всех врагов у кого меньше 100 ОЗ, а у кого больше наносит 5X ваш урон#Продолжительность эффекта - 2,5 секунды. Изменяется в настройках мода", "Тони",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("The Real Left Hand"), "{{Chest}} При использовании улучшает сундук в его лучшую версию. Если нечего улучшать, спавнит красный сундук#Порядок: {{SpikedChest}} > {{HauntedChest}} > {{Chest}} > {{RedChest}} > {{GoldenChest}} or {{StoneChest}} > {{WoodenChest}} or {{DirtyChest}} > {{HolyChest}} > {{MegaChest}}", "Настоящая Левая Рука",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Hitops"), "{{Speed}} +0.2 Speed#This speed up can exceed the speed cap", "Хайтопы",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Pop Pop"), "Двойное нажатие на кнопку стрельбы выстреливает 2 пулями с тройным уроном#{{Timer}} Замедляет скорострельность на некоторое время после использования.", "Пиф Паф!",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Football"), "{{Throwable}} Бросаемое#Создает фамильяра которого можно брать в руки и бросать. Он отскакивает от врагов.#{{Damage}} Урон мяча зависит от его скорости", "Мяч для Регби",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Ball of Tumors"), "{{GrabBag}} Пикапы имеют шанс превратиться в подбираемую опухоль.#Собирая опухоли игрок получает и улучшает орбитальную опухоль", "Метастазы",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Bow and Arrow"), "{{Damage}} Игрок может стрелять стрелами, у них меньший хитбокс и они наносят х2.5 урон. Боезапас зависит от скорострельности#Без стрел игрок начинает стрелять слезами#Стрела падает на пол в виде пикапа", "Лук и стрелы",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Emergency Meeting"), "{{Card1}} Использование переносит всех врагов, включая боссов, в начальную комнату#После телепортации все враги имеют эффект оглушения", "Экстренное совещание",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Boxing Glove"), "{{Chargeable}} Получите заряжаемую атаку боксерской перчаткой#{{Confusion}} Перчатка оглушает врагов и имеет большое отталкивание", "Боксерская Перчатка",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Gravity"), "{{Timer}} При использовании переносит вас на потолок на 5 секунд#{{Seraphim}} В этом состоянии у игрока есть полет, неуязвимость и +6.25 дальности#В этом состоянии все ваши слезы падают сверху", "Гравитация",  "ru")
    EID:addCollectible( Isaac.GetItemIdByName("Johnny's Knives"), "{{Throwable}} Бросаемое#Получите два самонаводящихся ножа с контактным уроном#Когда нож убивает врага, он создает лужу под ним. Размер лужи зависит от ОЗ врага#{{Tears}} Когда ножи убивают врага без вашей помощи, вы получаете +0.5 скорострельности до конца комнаты.", "Ножи джонни",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Ser Junkan"), "Создает спутника который преследует врагов и наносит контактный урон#Вы можете взрывать предметы с помощью бомб, при таком расклади из них выпадает пикап мусора. Собирание мусора улучшает его.#Собирая 7 мусора он входит в финальную форму и любое дальнейшее подбирание мусора увеличивает его урон.", "Сэр хламовник",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("The Crowdfunder"), "Используйте для призыва денежного пулемета#Каждая пуля стоит 1 монету.#При попадании в цель/стену шанс создать монету которая пропадет со временем.#Попадание во врагов иногда озолачивает их.", "Спонсор",  "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Polar Star"), "Игрок имеет улучшаемую пушку. Используйте для смены в форму ракетного ранца #Убивайте монстров для получения опыта, который улучшает оружие. Разделяет опыт с формой ракетного ранца#Уровень 1 - обычные пули с множителем урона 1.5#Уровень 2 - Двойные пули#Уровень 3 - одна большая пуля", "Полярная Звезда", "ru")
    EID:addCollectible(Isaac.GetItemIdByName("Booster V2.0"), "Игрок имеет улучшаемый ракетный ранец. Используйте для смены в форму пушки#Убивайте монстров для получения опыта, который улучшает ранец. Разделяет опыт с формой пушки# Уровень - +0.65 скорости, Полет#Уровень 2 - Ранец оставляет за собой поджигающий след#Уровень 3 - предотвращает следующее получение урона. Вместо этого вы поднимаете вверх, врезаетесь вниз и взрываетесь. Уровень сбрасывается до 2", "Ускоритель V2.0", "ru")
	
    EID:addTrinket(Isaac.GetTrinketIdByName("Hunky Boys"), "Нажав на кнопку сбрасывания моментально бросает брелок; не нужно держать кнопку#Когда на земле, периодически привлекает к себе врагов.", "Горячие Парни", "ru")
    EID:addTrinket(Isaac.GetTrinketIdByName("Bible Thump"), "{{Collectible33}} Использование любого предмет активирует библию#{{Collectible33}} Если вы используете библию с этим предметом, вы вдобавок активируете эффект некрономикона.#{{Satan}} Использование библии на сатане убивает его вместо убийства вас#{{TheLamb}} Золотая версия также убивает агнца", "Библейский Удар", "ru")
    EID:addTrinket(Isaac.GetTrinketIdByName("Cheep Cheep"), "{{Fear}} 1 случайный монстр в комнате всегда имеет эффект страха и его атакуют другие монстры.#Золотая версия брелка так же накладывает кровотечение.", "Цып Цып", "ru")

    EID:addCard(Isaac.GetCardIdByName("CowOnTrash"), "{{LordoftheFlies}} Rerolls all items into fly themed items#Rerolls pickups into blue flies#{{Coin}} Does not actually become back your money", "Скотина Помойная", "ru")
    EID:addCard(Isaac.GetCardIdByName("LootCard"), "{{Collectible}} Randomly spawns a random item or trinket from any pool", "Карта добычи", "ru")
    EID:addCard(Isaac.GetCardIdByName("Blank"), "Clears all enemy projectiles in the room.#Pushes nearby enemies away#There is one use left", "Пустышка", "ru")
    EID:addCard(Isaac.GetCardIdByName("Blank2"), "Clears all enemy projectiles in the room.#Pushes nearby enemies away#There are two uses left", "Пустышки", "ru")
    EID:addCard(Isaac.GetCardIdByName("Blank3"), "Clears all enemy projectiles in the room.#Pushes nearby enemies away#You can use this 3 times before it disappears", "Пустышки", "ru")
    EID:addCard(Isaac.GetCardIdByName("JesterCube"), "{{Collectible}} On use, all items in the room will cycle between 6 additional choices, similar to Glitched Crown", "Шут", "ru")
    EID:addCard(Isaac.GetCardIdByName("WitchCube"), "50% chance to deal 40 damage to all enemies in the room and apply burn.#50% chance to spawn another Witch and fire off a poison fart", "Ведьма", "ru")
    EID:addCard(Isaac.GetCardIdByName("MurderCard"), "For a quarter second, increase speed to 4 and kill everything you touch.#{{Stompy}} Gain a Stompy effect for the room", "Убийство!", "ru")
    EID:addCard(Isaac.GetCardIdByName("AmberChunk"), "{{Collectible}} All pickups in the room, including items and the final chest at the end of the game, will be removed and saved.#The previous items you consumed in this way will respawn, even across games#You will also receive a {{Coin}} lucky penny", "Кусочек Янтаря", "ru")
    EID:addCard(Isaac.GetCardIdByName("FiendFire"), "All pickups in the room are consumed#For each pickup consumed, gain a small, permanent boost to Damage, Tears, Luck, Range, or Speed#{{Burning}} Pickups turn into fires, which can damage enemies.", "Адское Пламя", "ru")
    EID:addCard(Isaac.GetCardIdByName("DemonForm"), "{{Player7}} For the current room, Isaac becomes Azazel with a wide Brimstone#{{Damage}} +1 Damage", "Облик Демона", "ru")

end

return function ()
    if REPENTOGON then
        print("hi")
    end
end
