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
		description = "Threshold",
		type = "number",
		min = 1, max = 100, step = 1,
		default = 100
	},
	[9] = {
		key = "text",
		name = "Text",
		description = "Display current stagger value",
		type = "toggle",
		default = true
	},
	-- TODO: colors
}