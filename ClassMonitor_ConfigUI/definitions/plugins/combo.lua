local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local colors = D.Helpers.CreateColorsDefinition("colors", 5)
local options = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.WidthAndHeight,
	[7] = D.Helpers.Specs,
	[8] = {
		key = "filled",
		name = L.Filled,
		desc = L.ComboFilledDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[9] = colors,
	[10] = D.Helpers.Anchor,
	[11] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("COMBO", options, L.PluginShortDescription_COMBO, L.PluginDescription_COMBO)