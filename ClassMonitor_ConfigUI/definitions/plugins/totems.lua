local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local options = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.WidthAndHeight,
	[7] = D.Helpers.Specs,
	[8] = {
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
		disabled = D.Helpers.IsPluginDisabled
	},
	[9] = {
		key = "text",
		name = L.TimeLeft,
		desc = L.TotemsTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	-- TODO: map
	-- TODO: colors
	[12] = D.Helpers.Anchor,
	[13] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("TOTEMS", options, L.PluginShortDescription_TOTEMS, L.PluginDescription_TOTEMS)