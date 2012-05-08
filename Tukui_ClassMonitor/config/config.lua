local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

C["classmonitor"] = {
--[[
	name = frame name (can be used in anchor)
	kind = POWER | AURA | RESOURCE(mana/runic/energy/focus/rage) | ECLIPSE | COMBO | RUNES

	RESOURCE (mana/runic power/energy/focus/rage):
	text = true|false												display resource value (% for mana) [default: true]
	autohide = true|false											hide or not while out of combat [default: false]
	anchor|anchors =												see note below
	width = number													width of resource bar [default: 85]
	height = number													height of resource bar [default: 10]
	color|colors =													see note below [default: tukui power color]

	COMBO:
	anchor|anchors =												see note below
	width = number													width of combo point [default: 85]
	height = number													height of combo point [default: 10]
	spacing = number												space between combo points [default: 3]
	color|colors =													see note below [default: class color]
	filled = true|false												is combo point filled or not [default: false]

	POWER (holy power/soul shard):
	powerType = SPELL_POWER_HOLY_POWER | SPELL_POWER_SOUL_SHARDS	power to monitor (can be any power type (http://www.wowwiki.com/PowerType)
	count = number													max number of points to display
	anchor|anchors =												see note below
	width = number													width of power point [default: 85]
	height = number													height of power point [default: 10]
	spacing = number												space between power points [default: 3]
	color|colors =													see note below [default: class color]
	filled = true|false												is power point filled or not [default: false]

	AURA (buff/debuff):
	spellID = number												spell id of buff/debuff to monitor
	filter = "HELPFUL" | "HARMFUL"									BUFF or DEBUFF
	count = number													max number of stack to display
	anchor|anchors =												see note below
	width = number													width of buff stack [default: 85]
	height = number													height of buff stack [default: 10]
	spacing = number												space between buff stack [default: 3]
	color|colors =													see note below [default: class color]
	filled = true|false												is buff stack filled or not [default: false]

	RUNES
	updatethreshold = number										interval between runes display update [default: 0.1]
	autohide = true|false											hide or not while out of combat [default: false]
	orientation = "HORIZONTAL" | "VERTICAL"							direction of rune filling display [default: HORIZONTAL]
	anchor|anchors =												see note below
	width = number													width of rune [default: 85]
	height = number													height of rune [default: 10]
	spacing = number												space between runes [default: 3]
	colors = { blood, unholy, frost, death }						color of runes
	runemap = { 1, 2, 3, 4, 5, 6 }									see instruction in DEATHKNIGHT section

	ECLIPSE:
	anchor|anchors=													see note below
	width = number													half-width of eclipse bar (width of lunar and solar bar)
	height = number													height of eclipse bar
	colors = { lunar, solar }										color of lunar and solar bar

	Notes about anchor
	anchor = { "POSITION", parent, "POSITION", offsetX, offsetY }
		-> one anchor whatever spec is used
	anchors = { { "POSITION", parent, "POSITION", offsetX, offsetY }, { "POSITION", parent, "POSITION", offsetX, offsetY }, ... { "POSITION", parent, "POSITION", offsetX, offsetY } }
		-> one anchor by spec

	Notes about color
	color = {r, g, b, a}
		-> same color for every point (if no color is specified, raid class color will be used)
	colors = { { {r, g, b, a}, {r, g, b, a}, {r, g, b, a}, ...{r, g, b, a} }
		-> one different color by point (for kind COMBO/AURA/POWER)
	colors = { [RESOURCE_TYPE] = {r, g, b, a}, [RESOURCE_TYPE] = {r, g, b, a}, ...[RESOURCE_TYPE] = {r, g, b, a}}
		-> one different color by resource type (only for kind RESOURCE) (if no color is specified, default resource color will be used)
--]]
		
	["DRUID"] = {
		{
			name = "CM_RESOURCE",
			kind = "RESOURCE",
			text = true,
			autohide = false,
			anchor = {"TOP", "movingframe", "BOTTOM", 0, -20},
			width = 262,
			height = 10,
		},
		{
			name = "CM_COMBO",
			kind = "COMBO",
			anchor = {"BOTTOMLEFT", "CM_RESOURCE", "TOPLEFT", 0, 3},
			width = 50,
			height = 10,
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
		{ -- DOES NOT WORK
			name = "CM_ECLIPSE",
			kind = "ECLIPSE",
			anchor = { "BOTTOMLEFT", "CM_RESOURCE", "TOPLEFT", 0, 3},
			width = 262,
			height = 10,
			colors = {
				{0.50, 0.52, 0.70, 1}, -- Lunar
				{0.80, 0.82, 0.60, 1}, -- Solar
			},
		}
	},
	["PALADIN"] = {
		{
			name = "CM_HEALTH",
			kind = "HEALTH",
			text = true,
			autohide = false,
			anchor = {"TOP", "movingframe", "BOTTOM", 0, -20},
			width = 261,
			height = 10,
		},
		{
			name = "CM_MANA",
			kind = "RESOURCE",
			text = true,
			autohide = false,
			anchor = {"TOPLEFT", "CM_HEALTH", "BOTTOMLEFT", 0, -3},
			width = 261,
			height = 10,
		},
		{
			name = "CM_HOLYPOWER",
			kind = "POWER",
			powerType = SPELL_POWER_HOLY_POWER,
			count = 3,
			anchor = {"BOTTOMLEFT", "CM_HEALTH", "TOPLEFT", 0, 3},
			width = 85,
			height = 10,
			spacing = 3,
			color = {228/255, 225/255, 16/255, 1},
			filled = true,
		},
	},
	["WARLOCK"] = {
		{
			name = "CM_MANA",
			kind = "RESOURCE",
			text = true,
			autohide = false,
			anchor = {"TOP", "movingframe", "BOTTOM", 0, -20},
			width = 261,
			height = 10,
		},
		{
			name = "CM_SOUL_SHARD",
			kind = "POWER",
			powerType = SPELL_POWER_SOUL_SHARDS,
			count = 3,
			anchor = {"BOTTOMLEFT", "CM_MANA", "TOPLEFT", 0, 3},
			width = 85,
			height = 10,
			spacing = 3,
			color = {255/255, 101/255, 101/255, 1},
			filled = false,
		},
	},
	["ROGUE"] = {
		{
			name = "CM_ENERGY",
			kind = "RESOURCE",
			text = true,
			autohide = false,
			anchor = {"TOP", "movingframe", "BOTTOM", 0, -20},
			width = 262,
			height = 10,
		},
		{
			name = "CM_COMBO",
			kind = "COMBO",
			anchor = {"BOTTOMLEFT", "CM_ENERGY", "TOPLEFT", 0, 3},
			width = 50,
			height = 10,
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
	},
	["PRIEST"] = {
		{
			name = "CM_MANA",
			kind = "RESOURCE",
			text = true,
			autohide = false,
			anchor = {"TOP", "movingframe", "BOTTOM", 0, -20},
			width = 261,
			height = 10,
		},
		{
			name = "CM_SHADOW_ORB",
			kind = "AURA",
			spellID = 77487,
			filter = "HELPFUL",
			count = 3,
			anchor = {"BOTTOMLEFT", "CM_MANA", "TOPLEFT", 0, 3},
			width = 85,
			height = 10,
			spacing = 3,
			color = {0.5, 0, 0.7, 1},
			filled = false,
		},
	},
	["MAGE"] = {
		{
			name = "CM_MANA",
			kind = "RESOURCE",
			text = true,
			autohide = false,
			anchor = {"TOP", "movingframe", "BOTTOM", 0, -20},
			width = 261,
			height = 10,
		},
		{
			name = "CM_ARCANE_BLAST",
			kind = "AURA",
			spellID = 36032,
			filter = "HARMFUL",
			count = 4,
			anchor = {"BOTTOMLEFT", "CM_MANA", "TOPLEFT", 0, 3},
			width = 63,
			height = 10,
			spacing = 3,
			filled = false,
		},
	},
	["DEATHKNIGHT"] = {
		{
			name = "CM_RUNIC_POWER",
			kind = "RESOURCE",
			text = true,
			autohide = false,
			anchor = {"TOP", "movingframe", "BOTTOM", 0, -20},
			width = 261,
			height = 10,
		},
		{
			name = "CM_RUNES",
			kind = "RUNES",
			updatethreshold = 0.1,
			autohide = false,
			orientation = "HORIZONTAL",
			anchor = { "BOTTOMLEFT", "CM_RUNIC_POWER", "TOPLEFT", 0, 3 },
			width = 41,
			height = 10,
			spacing = 3,
			colors = {
				{ 0.69, 0.31, 0.31, 1}, -- Blood
				{ 0.33, 0.59, 0.33, 1}, -- Unholy
				{ 0.31, 0.45, 0.63, 1}, -- Frost
				{ 0.84, 0.75, 0.65, 1}, -- Death
			},
				-- runemap instructions.
				-- This is the order you want your runes to be displayed in (down to bottom or left to right).
				-- 1,2 = Blood
				-- 3,4 = Unholy
				-- 5,6 = Frost
				-- (Note: All numbers must be included or it will break)
			runemap = { 1, 2, 3, 4, 5, 6 },
		},
	},
	["HUNTER"] = {
		{
			name = "CM_FOCUS",
			kind = "RESOURCE",
			text = true,
			autohide = false,
			anchor = {"TOP", "movingframe", "BOTTOM", 0, -20},
			width = 262,
			height = 10,
		},
		{
			name = "CM_RSA",
			kind = "AURA",
			spellID = 82925,
			filter = "HELPFUL",
			count = 5,
			anchor = {"BOTTOMLEFT", "CM_FOCUS", "TOPLEFT", 0, 3},
			width = 50,
			height = 10,
			spacing = 3,
			color = {0.5, 0, 0.7, 1},
			filled = false,
		},
	},
	["WARRIOR"] = {
		{
			name = "CM_RAGE",
			kind = "RESOURCE",
			text = true,
			autohide = false,
			anchor = {"TOP", "movingframe", "BOTTOM", 0, -20},
			width = 261,
			height = 10,
		}
	},
	["SHAMAN"] = {
		{
			name = "CM_MANA",
			kind = "RESOURCE",
			text = true,
			autohide = false,
			anchor = {"TOP", "movingframe", "BOTTOM", 0, -20},
			width = 267,
			height = 10,
		},
		{
			name = "CM_FULMINATION",
			kind = "AURA",
			spellID = 324,
			filter = "HELPFUL",
			count = 9,
			anchor = {"BOTTOMLEFT", "CM_MANA", "TOPLEFT", 0, 3},
			width = 27,
			height = 10,
			spacing = 3,
			color = {0.5, 0, 0.7, 1},
			filled = false,
		},
		{
			name = "CM_MAELSTROMM",
			kind = "AURA",
			spellID = 53817,
			filter = "HELPFUL",
			count = 5,
			anchor = {"BOTTOMLEFT", "CM_MANA", "TOPLEFT", 0, 3},
			width = 51,
			height = 10,
			spacing = 3,
			color = {0.5, 0, 0.7, 1},
			filled = false,
		},
		-- Nota : Vive les équations de Diophantes
		-- to make it pixel perfect, we need to solve :
		-- Z = 9 x + 3 x 8
		-- Z = 5 y + 3 x 4
		-- gives us : 9 x - 5 y = - 12 ( 9 and 5 are prime with themselves => Bezout => 9 x - 5 y = 1 have a solution : 9 x (-1) - 5 x (-2) = 1 )
		-- => x = 12 + 5k and y = 9k + 24
		-- using k = 3 we have x = 27 and y = 51
		-- and z = 9 x 27 + 24 = 5 x 51 + 12 = 267
	},
}