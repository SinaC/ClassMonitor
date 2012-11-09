local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

D["TOTEMS"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = {
		key = "count",
		name = L.Count,
		desc = L.TotemsCountDesc,
		type = "select",
		values = {
			[3] = "Wild Mushrooms (3)",
			[4] = "Totems (4)",
		},
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	[10] = {
		key = "text",
		name = L.TimeLeft,
		desc = L.TotemsTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	-- TODO: map
	-- TODO: colors
	[11] = D.Helpers.Anchor,
}