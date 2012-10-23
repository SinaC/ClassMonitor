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
		desc = "Power type",
		type = "select",
		values = {
			[SPELL_POWER_HOLY_POWER] = "Holy Power",
			[SPELL_POWER_SOUL_SHARDS] = "Soul Shards",
			[SPELL_POWER_LIGHT_FORCE or 12] = "Chi", -- TODO: Bug in 5.1
			[SPELL_POWER_SHADOW_ORBS] = "Shadow Orbs",
			[SPELL_POWER_BURNING_EMBERS] = "Burning Embers", -- TODO: split POWER  -count entry
			[SPELL_POWER_DEMONIC_FURY] = "Demonic Fury", -- TODO: split POWER  -count entry +text entry
		},
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
	},
	[10] = {
		key = "count",
		name = "Count",
		desc = "Maximum power count",
		type = "range",
		min = 1, max = 20, step = 1,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
	},
	[11] = {
		key = "filled",
		name = "Filled",
		desc = "Power point filled or not",
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
	},
	-- TODO: colors
}