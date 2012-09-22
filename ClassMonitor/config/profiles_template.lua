local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

local L = Engine.Locales
local Config = Config
local UI = Engine.UI

if UI.MyName == "Meuhhnon" then
	Config["DRUID"][1].anchor = nil -- MOVER
	Config["DRUID"][1].anchors = {
		{ "CENTER", UIParent, "CENTER", 0, -110 }, -- Balance
		{ "CENTER", UIParent, "CENTER", 0, -120 }, -- Feral
		{ "CENTER", UIParent, "CENTER", 0, -130 }, -- Guardian
		{ "CENTER", UIParent, "CENTER", 0, -140 } -- Restoration
	}
	-- add 2 health frames, player below wild mushrooms and target above combo/eclipse
	Config["DRUID"][6] = {
		name = "CM_PLAYER_HEALTH",
		kind = "HEALTH",
		unit = "player",
		text = true,
		autohide = false,
		anchor = { "TOPLEFT", "CM_WILDMUSHROOMS", "BOTTOMLEFT", 0, -3},
		width = 262,
		height = 10,
		autohide = true,
	}
	Config["DRUID"][7] = {
		name = "CM_TARGET_HEALTH",
		kind = "HEALTH",
		unit = "target",
		text = true,
		autohide = false,
		anchor = { "BOTTOMLEFT", "CM_COMBO", "TOPLEFT", 0, 3},
		width = 262,
		height = 10,
		autohide = true
	}
end

if UI.MyName == "Gargulqwas" then
	-- resource only in cat/bear
	Config["DRUID"][2].specs = {2, 3}
	-- combo only in cat
	Config["DRUID"][3].spec = 2
	-- eclipse at the same location than resource(already only visible in balance spec)
	Config["DRUID"][4].anchor = Config["DRUID"][2].anchor
--[[
	Config["DRUID"] = {
		{ -- 1
			name = "CM_MOVER",
			kind = "MOVER",
			anchor = { "CENTER", UIParent, "CENTER", 0, -140 },
			width = 262,
			height = 15,
			text = L.classmonitor_move
		},
		{ -- 2
			name = "CM_RESOURCE",
			kind = "RESOURCE",
			specs = {2, 3}, -- Bear/Cat
			text = true,
			autohide = false,
			anchor = { "TOPLEFT", "CM_MOVER", 0, 0 },
			width = 262,
			height = 15,
		},
		{ -- 3
			name = "CM_COMBO",
			kind = "COMBO",
			anchor = { "BOTTOMLEFT", "CM_RESOURCE", "TOPLEFT", 0, 3 },
			spec = 2, -- Cat
			width = 50,
			height = 15,
			spacing = 3,
			colors = {
				{0.69, 0.31, 0.31, 1}, -- 1
				{0.65, 0.42, 0.31, 1}, -- 2
				{0.65, 0.63, 0.35, 1}, -- 3
				{0.46, 0.63, 0.35, 1}, -- 4
				{0.33, 0.63, 0.33, 1}, -- 5
			},
			filled = false,
		},
		{ -- 4
			name = "CM_ECLIPSE",
			kind = "ECLIPSE",
			anchor = { "TOPLEFT", "CM_MOVER", 0, 0 },
			width = 262,
			height = 15,
			text = true,
			colors = {
				{0.50, 0.52, 0.70, 1}, -- Lunar
				{0.80, 0.82, 0.60, 1}, -- Solar
			},
		},
		{ -- 5
			name = "CM_WILDMUSHROOMS",
			kind = "TOTEM",
			count = 3,
			specs = {1, 4}, -- Eclipse/Resto
			anchor = { "TOPLEFT", "CM_RESOURCE", "BOTTOMLEFT", 0, -3 },
			width = 85,
			height = 15,
			spacing = 3,
			color = { 95/255, 222/255,  95/255, 1 },
		},
	}
--]]
end