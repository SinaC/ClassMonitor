local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local colors = D.Helpers.CreateColorsDefinition("colors", 5)
local options = {
	[1] = D.Helpers.Description,
	[2] = D.Helpers.Name,
	[3] = D.Helpers.DisplayName,
	[4] = D.Helpers.Kind,
	[5] = D.Helpers.Enabled,
	[6] = D.Helpers.Autohide,
	[7] = D.Helpers.WidthAndHeight,
	[8] = D.Helpers.Specs,
	[9] = {
		key = "filled",
		name = L.Filled,
		desc = L.ComboFilledDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[10] = colors,
	[11] = D.Helpers.Anchor,
	[12] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("COMBO", options, L.PluginShortDescription_COMBO, L.PluginDescription_COMBO)