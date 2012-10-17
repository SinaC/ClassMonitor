local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local UI = Engine.UI

D["TOTEMS"] = {
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
		key = "count",
		name = "Count",
		description = "Totem count",
		type = "select",
		values = {
			{ value = 3, text = "Wild Mushrooms" },
			{ value = 4, text = "Totems" },
		},
		default = 4
	},
	[11] = {
		key = "text",
		name = "Text",
		description = "Display time left",
		type = "toggle",
		default = true
	},
	-- TODO: map
	-- TODO: colors
}