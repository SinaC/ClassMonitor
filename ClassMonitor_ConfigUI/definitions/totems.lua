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
	[9] = {
		key = "count",
		name = "Count",
		desc = "Totem count",
		type = "select",
		values = {
			[3] = "Wild Mushrooms (3)",
			[4] = "Totems (4)",
		},
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
	},
	[10] = {
		key = "text",
		name = "Text",
		desc = "Display time left",
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
	},
	-- TODO: map
	-- TODO: colors
}