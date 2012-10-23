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
		desc = "Time between 2 updates",
		type = "range",
		min = 0.1, max = 1, step = 0.1,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
	},
	[9] = {
		key = "orientation",
		name = "Orientation",
		desc = "Fill orientation",
		type = "select",
		values = {
			["HORIZONTAL"] = "Horizontal",
			["VERTICAL"] = "Vertical",
		},
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
	},
	-- TODO: runemap
	-- TODO: colors
}