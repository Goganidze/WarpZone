return function(mod)

    local function GI(i) return Isaac.GetItemIdByName(i)>0 and Isaac.GetItemIdByName(i) or Isaac.GetTrinketIdByName(i) end

	local Collectible = {
		[GI("Golden Idol")]={ru={"Золотой Идол","Проклятые богатства"},},
		
		--[GI('')]={ru={"",""},},	
	}
	local Trinket={
        [GI("Ring of the Snake")]={ru={"Кольцо Змея","Starting hand +2"},},	
	}
	local Cards={
        ['Cow on a Trash Farm']={ru={"Cow on a Trash Farm","Become back your money"},},
        --['']={ru={"",""},},
    }

	local ModTranslate = {
		['Collectibles'] = Collectible,
		['Trinkets'] = Trinket,
		['Cards'] = Cards,
		--['Pills'] = Pills,
	}
	ItemTranslate.AddModTranslation("war zone", ModTranslate, {ru = true})

end