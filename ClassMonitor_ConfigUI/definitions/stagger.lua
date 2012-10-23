local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local UI = Engine.UI

D["STAGGER"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.Kind,
	[3] = D.Helpers.Enable,
	[4] = D.Helpers.Anchor,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = {
		key = "threshold",
		name = "Threshold",
		desc = "Above this percentage, health percentage is not displayed",
		type = "range",
		min = 1, max = 100, step = 1, -- isPercent = true,  isPercent implies values in range [0, 1]
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
	},
	[9] = {
		key = "text",
		name = "Text",
		desc = "Display current stagger value",
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
	},
	-- TODO: colors
}