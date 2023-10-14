return function(mod)

    local function GI(i) return Isaac.GetItemIdByName(i)>0 and Isaac.GetItemIdByName(i) or Isaac.GetTrinketIdByName(i) end

	local Collectible = {
		[GI("Golden Idol")]={ru={"Золотой Идол","Проклятые богатства"},},
                [GI("Gun that can kill the Past")]={ru={"Пушка Убивающая Прошлое","Оставь прошлое позади"},},
                [GI('Birthday Cake')]={ru={"Именинный Торт","Счастливый Я!"},},
                [GI('Rusty Spoon')]={ru={"Ржавая Ложка","Тебе нравится их трогать..."},},
                [GI('Newgrounds Tank')]={ru={"Танк Newgrounds","Стань Танком!"},},
                [GI('Greed Butt')]={ru={"Алчная Жопа","Не трогай!"},},
                [GI('   Focus   ')]={ru={"Фокус","Забери их ДУШИ"},},
                [GI('  Focus  ')]={ru={"Фокус",""Забери их ДУШИ"},},
                [GI(' Focus ')]={ru={"Фокус",""Забери их ДУШИ"},},
                [GI('Focus')]={ru={"Фокус",""Забери их ДУШИ"},},
                [GI('The Doorway')]={ru={"Проход","Открой ВСЕ двери"},},
                [GI('Strange Marble')]={ru={"Странный Марбл","Чудесные цвета..."},},
                [GI('Is You')]={ru={"Это Ты","ПРЕДМЕТ ЭТО ПРЕПЯТСТВИЕ"},},
                [GI('Nightmare Tick')]={ru={"Кошмарный Клещ","Эй, убери это!"},},
                [GI("Spelunker's Pack")]={ru={"Рюкзак Спелеолога","Искатель Сокровищ +12 бомб"},},
                [GI("Diogenes's Pot")]={ru={"Пифос Диогена","Уничтожь их, начни снова"},},
                [GI(" Diogenes's Pot ")]={ru={"Пифос Диогена","Уничтожь их, начни снова"},},
                [GI('George')]={ru={"Джордж","Зри в Корень"},},
                [GI('Possession')]={ru={"Одержимость","Следуй за Мной"},},
                [GI('Lollipop')]={ru={"Леденец","Не забудь поделиться!"},},
		
		--[GI('')]={ru={"",""},},	
	}
	local Trinket={
        [GI("Ring of the Snake")]={ru={"Кольцо Змеи","Стартовая рука +2"},},	
	}
	local Cards={
        ['Cow on a Trash Farm']={ru={"Скотина Помойная","Верни свои деньги"},},
        --['']={ru={"",""},},
    }

	local ModTranslate = {
		['Collectibles'] = Collectible,
		['Trinkets'] = Trinket,
		['Cards'] = Cards,
		--['Pills'] = Pills,
	}
	ItemTranslate.AddModTranslation("warp zone", ModTranslate, {ru = true})

end
