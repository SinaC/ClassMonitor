local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local UI = Engine.UI

D["AURABAR"] = {
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
		type = "string",
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
		key = "text",
		name = "Text",
		description = "Display current stack/maximum stack",
		type = "toggle",
		default = true
	},
	[14] = {
		key = "duration",
		name = "Duration",
		description = "Display aura time left",
		type = "toggle",
		default = true
	},
	-- [15] = {
		-- key = "color",
		-- name = "Color",
		-- description = "Bar color",
		-- type = "color",
		-- --TODO: default = UI. default: should be class color
	-- }
}