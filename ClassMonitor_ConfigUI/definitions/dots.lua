local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local UI = Engine.UI

D["DOT"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.Kind,
	[3] = D.Helpers.Enable,
	[4] = D.Helpers.Anchor,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = {
		key = "spellID",
		name = "Spell ID",
		description = "Dot spell ID to monitor",
		type = "spell",
	},
	[10] = {
		key = "latency",
		name = "Latency",
		description = "Latency",
		type = "toggle",
		default = false
	},
	[11] = { -- TODO: number but not a slider
		key = "threshold",
		name = "Threshold",
		description = "Threshold",
		type = "string",
		readonly = true,
		default = 0
	},
	-- TODO: colors (3)
}