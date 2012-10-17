local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local UI = Engine.UI

D["RUNES"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.Kind,
	[3] = D.Helpers.Enable,
	[4] = D.Helpers.Anchor,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = {
		key = "updatethreshold",
		name = "Update Threshold",
		description = "Threshold update value",
		type = "number",
		min = 0.1, max = 1, step = 0.1,
		default = 0.1
	},
	[9] = {
		key = "orientation",
		name = "Orientation",
		description = "Fill orientation",
		type = "select",
		values = {
			{ value = "HORIZONTAL", text = "Horizontal" },
			{ value = "VERTICAL", text = "Vertical" },
		},
		default = "HORIZONTAL"
	},
	-- TODO: runemap
	-- TODO: colors
}