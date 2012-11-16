local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

-- Definition
local colors = D.Helpers.CreateColorsDefinition("colors", 3, {L.BanditsGuileShallow, L.BanditsGuileModerate, L.BanditsGuileDeep})
local options = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.WidthAndHeight,
	[7] =  {
		key = "filled",
		name = L.Filled,
		desc = L.AuraFilledDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[8] = colors,
	[9] = D.Helpers.Anchor,
	[10] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("BANDITSGUILE", options, L.PluginShortDescription_BANDITSGUILE, L.PluginDescription_BANDITSGUILE)