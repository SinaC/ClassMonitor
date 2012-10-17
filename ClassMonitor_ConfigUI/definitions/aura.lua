local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local UI = Engine.UI

D["AURA"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.Kind,
	[3] = D.Helpers.Enable,
	[4] = D.Helpers.Anchor,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = D.Helpers.Unit,
	[10] = {
		key = "spellID",
		name = "Spell ID",
		description = "Spell ID to monitor",
		type = "spell",
	},
	[11] = {
		key = "filter",
		name = "Filter",
		description = "Helpful or harmful",
		type = "select",
		values = {
			{ value = "HELPFUL", text = "Helpful" },
			{ value = "HARMFUL", text = "Harmful" },
		},
		default = "HELPFUL",
	},
	[12] = {
		key = "count",
		name = "Count",
		description = "Maximum charges count",
		type = "number",
		min = 1, max = 20, step = 1,
		default = 3
	},
	[13] = {
		key = "filled",
		name = "Filled",
		description = "Stack filled or not",
		type = "toggle",
		default = false
	},
	-- TODO: colors
}