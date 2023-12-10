return function(mod)

local DSSModName = "Dead Sea Scrolls (Wario zone)"

local DSSCoreVersion = 6

local MenuProvider = {}

function MenuProvider.SaveSaveData()
    mod.StoreSaveData()
end

function MenuProvider.GetPaletteSetting()
    return mod.GetMenuSaveData().MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    mod.GetMenuSaveData().MenuPalette = var
end

function MenuProvider.GetGamepadToggleSetting()
    return mod.GetMenuSaveData().GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    mod.GetMenuSaveData().GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return mod.GetMenuSaveData().MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    mod.GetMenuSaveData().MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return mod.GetMenuSaveData().MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
    mod.GetMenuSaveData().MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    return mod.GetMenuSaveData().MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
    mod.GetMenuSaveData().MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    return mod.GetMenuSaveData().MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    mod.GetMenuSaveData().MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return mod.GetMenuSaveData().MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    mod.GetMenuSaveData().MenusPoppedUp = var
end

local DSSInitializerFunction = include("lua.dss.dssmenucore")
local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, MenuProvider)

local strings = {
	Title = {
		en = "warp zone",
		es = "warp zone",
	},
	resume_game = {
		en = "resume game",
		ru = "вернуться в игру",
	},
	settings = {
		en = "settings",
		ru = "настройки",
	},
	yes = {
		en = "yes",
		ru = "да",
	},
	no = {
		en = "no",
		ru = "нет",
	},
	enable = {
		en = "enable",
		ru = "включен",
	},
	disable = {
		en = "disabled",
		ru = "выключен",
	},
	startTooltip = {
		en = dssmod.menuOpenToolTip,
		ru = { strset = { 'переключение', 'меню', '', 'клавиатура:', '[c] или [f1]', '', 'контроллер:', 'нажатие', 'на стик' }, fsize = 2 }
	},
	spelunker_bomb_mode1 = {
		en = "spelunker pack",
		ru = "режим рюкзака",
	},
	spelunker_bomb_mode2 = {
		en = "mode",
		ru = "спелеолога",
	},
	sbm_var1 = {
		en = "destroy specials",
		ru = "взрывать особые",
	},
	sbm_var2 = {
		en = "bombs in hand",
		ru = "бомбы в руки",
	},
	sbm_var3 = {
		en = "both",
		ru = "оба",
	},
	johnnysknives_mode = {
		en = "johnnys knives",
		ru = "johnnys knives",
	},
	jk_var1 = {
		en = "when firing",
		ru = "при стрельбе",
	},
	jk_var2 = {
		en = "double tab",
		ru = "двойное тык",
	},
	tony_time = {
		en = "tony's rage",
		ru = "длительность",
	},
	tony_time2 = {
		en = "duration",
		ru = "ярости тони",
	},
	tony_time_var1 = {
		en = "2.5 sec",
		ru = "2.5 сек.",
	},
	tony_time_var2 = {
		en = "3 sec",
		ru = "3 сек.",
	},
	tony_time_var3 = {
		en = "4 sec",
		ru = "4 сек.",
	},
	
}
local function GetStr(str)
	return strings[str] and (strings[str][Options.Language] or strings[str].en) or str
end




WarpZone.DSSdirectory = {
	main = {
		title = GetStr("Title"),
		format = {
		Panels = {
			{
				Panel = dssmod.panels.main,
				Offset = Vector(-42, 10),
				Color = 1
			},
			{
				Panel = dssmod.panels.tooltip,
				Offset = Vector(130, -2),
				Color = 1
			}
		}
		},
		
		buttons = {
			{str = GetStr('resume_game'), action = 'resume'},
			--{str = GetStr('settings'), dest = 'warpzone'},
			{str = '', nosel = true, fsize = 3},
			{str = GetStr('spelunker_bomb_mode1'), nosel = true, fsize = 3},
			{
				str = GetStr('spelunker_bomb_mode2'),
				choices = {GetStr('sbm_var1'),GetStr('sbm_var2'),GetStr('sbm_var3')}, 
				variable = 'SpelunkerBombMode',
				setting = 1,
				load = function()
					return WarpZone.MenuData.SpelunkerBombMode or 1
				end,
				store = function(var)
					WarpZone.MenuData.SpelunkerBombMode = var 
					WarpZone.SpelunkersPackEffectType = var
				end,
			},
			{str = '', nosel = true, fsize = 3},
			{
				str = GetStr('johnnysknives_mode'),
				choices = {GetStr('jk_var1'),GetStr('jk_var2')}, 
				variable = 'JohnnysKnivesMode',
				setting = 1,
				load = function()
					return WarpZone.MenuData.JohnnysKnivesMode or 1
				end,
				store = function(var)
					WarpZone.MenuData.JohnnysKnivesMode = var 
					WarpZone.JohnnysKnivesEffectType = var
				end,
			},
			{str = '', nosel = true, fsize = 3},
			{str = GetStr('tony_time'), nosel = true, fsize = 3},
			{
				str = GetStr('tony_time2'),
				choices = {GetStr('tony_time_var1'),GetStr('tony_time_var2'),GetStr('tony_time_var3')}, 
				variable = 'TonyTimeMaxMode',
				setting = 1,
				load = function()
					return WarpZone.MenuData.TonyTimeMaxMode or 1
				end,
				store = function(var)
					WarpZone.MenuData.TonyTimeMaxMode = var
					WarpZone.TonyRageTime = var == 1 and 160 or var == 2 and 180 and var == 3 and 240
				end,
			},
		},
		tooltip = GetStr("startTooltip")  
	},
	warpzone = {
		title = GetStr('settings'),
		buttons = {
			dssmod.gamepadToggleButton,
			dssmod.menuKeybindButton,
		}
	}
}
	
local WarpZonedirectorykey = {
    Item = WarpZone.DSSdirectory.main,
    Main = 'main',
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

DeadSeaScrollsMenu.AddMenu("warp zone", {
	Run = dssmod.runMenu, Open = dssmod.openMenu, 
	Close = dssmod.closeMenu, Directory = WarpZone.DSSdirectory, 
	DirectoryKey = WarpZonedirectorykey,
	UseSubMenu = true,
})

end


