----------------------------------------------------------------------------
-- Generic Config
----------------------------------------------------------------------------

local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

CMOptions = {
	-- Combo Points plugin
	["combo"] = { 
		enable = false,					-- enable combo points
		spacing = T.Scale(3), 			-- spacing between combo points
		width = T.Scale(50),  			-- width of bars
		height = T.Scale(15), 			-- height of bars
		anchor = {"CENTER", UIParent, "CENTER", -107, -100},	-- default anchor
		-- Coloring options for combo points
		colors = { 
			[1] = {.69, .31, .31, 1},
			[2] = {.65, .42, .31, 1},
			[3] = {.65, .63, .35, 1},
			[4] = {.46, .63, .35, 1},
			[5] = {.33, .63, .33, 1},
		},
	},
	-- Holy Power plugin
	["holy"] = { 
		enable = false,					-- enable holy power
		spacing = T.Scale(3),			-- spacing between holy powers
		width = T.Scale(85),  			-- width of bars
		height = T.Scale(15), 			-- height of bars
		anchor = {"CENTER", UIParent, "CENTER", -630, 190},		-- default anchor
		color = { 228/255, 225/255, 16/255, 1},
	},
	-- Soul Shard plugin
	["soul"] = { 
		enable = false,					-- enable soul shards
		spacing = T.Scale(3), 			-- spacing between shards
		width = T.Scale(85),  			-- width of bars
		height = T.Scale(15), 			-- height of bars
		anchor = {"CENTER", UIParent, "CENTER", -87, -100},	-- default anchor
		color = { 255/255, 101/255, 101/255, 1},
	},
	-- Shadow Orbs plugin
	["orbs"] = { 
		enable = false,					-- enable shadow orbs
		spacing = T.Scale(3), 			-- spacing between orbs
		width = T.Scale(85),  			-- width of bars
		height = T.Scale(15), 			-- height of bars
		anchor = {"CENTER", UIParent, "CENTER", -87, -100},	-- default anchor
		color = { 0.5, 0, 0.7, 1},
	},
	-- Arcane Blast plugin
	["arcane"] = { 
		enable = false,					-- enable arcane blast
		spacing = T.Scale(3), 			-- spacing between stack
		width = T.Scale(63),  			-- width of bars
		height = T.Scale(15), 			-- height of bars
		anchor = {"CENTER", UIParent, "CENTER", -99, -100},	-- default anchor
		color = { 0.5, 0, 0.7, 1},
	},
	-- Ready, Set, Aim... plugin
	["rsa"] = { 
		enable = false,					-- enable Ready, Set, Aim...
		spacing = T.Scale(3), 			-- spacing between stack
		width = T.Scale(50),  			-- width of bars
		height = T.Scale(15), 			-- height of bars
		anchor = {"CENTER", UIParent, "CENTER", -87, -100},	-- default anchor
		color = { 0.5, 0, 0.7, 1},
	},
	-- Runes plugin
	["runes"] = {
		enable = false,					-- enable runes
		spacing = T.Scale(3),			-- spacing between runes
		width = T.Scale(41),			-- width of bars
		height = T.Scale(15),			-- height of bars
		anchor = {"CENTER", UIParent, "CENTER", -110, -100},	-- default anchor
		updatethreshold = 0.1,			-- time between rune CD update
		autohide = false,
		orientation = "HORIZONTAL",
		colors = {
			{ 0.69, 0.31, 0.31, 1}, -- Blood
			{ 0.33, 0.59, 0.33, 1}, -- Unholy
			{ 0.31, 0.45, 0.63, 1}, -- Frost
			{ 0.84, 0.75, 0.65, 1}, -- Death
		},
		--[[
			runemap instructions.
			This is the order you want your runes to be displayed in (down to bottom or left to right).
			1,2 = Blood
			3,4 = Unholy
			5,6 = Frost
			(Note: All numbers must be included or it will break)
		]]
		runemap = { 1, 2, 3, 4, 5, 6 },
	},
	-- Eclipse plugin
	["eclipse"] = {
		enable = false,
		color = {
			["MOON"] = { 1, 1, 1, 1 }, -- TODO
			["SUN"] = { 1, 1, 1, 1 }, -- TODO
		},
	},
	-- Power plugin (rage/mana/energy/focus)
	["power"] = {
		enable = false,
		text = true,					-- display power text
		width = T.Scale(262), 			-- perfectly fits width of combo points
		height = T.Scale(10),			-- height of bar
		anchor = {"CENTER", UIParent, "CENTER", 0, -123},		-- default anchor
		autohide = false,
		color = {
			["MANA"] = { 0, 0.44, 0.87, 1 },
			["RAGE"] = { 0.77, 0.13, 0.23, 1 },
			["ENERGY"] = { 1, 0.96, 0.41, 1 },
			["FOCUS"] = { 0.67, 0.83, 0.45, 1 },
			["RUNIC_POWER"] = { 0, 0.82, 1, 1 },
		},
	},
}
