local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local UI = Engine.UI

D["POWER"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.Kind,
	[3] = D.Helpers.Enable,
	[4] = D.Helpers.Anchor,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = {
		key = "powerType",
		name = "Power Type",
		description = "Power type",
		type = "select",
		values = {
			{ value = SPELL_POWER_HOLY_POWER, text = "Holy Power" },
			{ value = SPELL_POWER_SOUL_SHARDS, text = "Soul Shards" },
			{ value = SPELL_POWER_LIGHT_FORCE or 12, text = "Chi" }, -- TODO: Bug in 5.1
			{ value = SPELL_POWER_SHADOW_ORBS, text = "Shadow Orbs" },
			{ value = SPELL_POWER_BURNING_EMBERS, text = "Burning Embers" }, --   -count entry
			{ value = SPELL_POWER_DEMONIC_FURY, text = "Demonic Fury" }, --   -count entry +text entry
		},
		default = SPELL_POWER_HOLY_POWER
	},
	[10] = {
		key = "count",
		name = "Count",
		description = "Maximum power count",
		type = "number",
		min = 1, max = 20, step = 1,
		default = 3
	},
	[11] = {
		key = "filled",
		name = "Filled",
		description = "Power point filled or not",
		type = "toggle",
		default = false
	},
	-- TODO: colors
}