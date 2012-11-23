local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

-- Definition
local colors = D.Helpers.CreateColorsDefinition("colors", 3, {L.BanditsGuileShallow, L.BanditsGuileModerate, L.BanditsGuileDeep})
local options = {
	[1] = D.Helpers.Description,
	[2] = D.Helpers.Name,
	[3] = D.Helpers.DisplayName,
	[4] = D.Helpers.Kind,
	[5] = D.Helpers.Enabled,
	[6] = D.Helpers.Autohide,
	[7] = D.Helpers.WidthAndHeight,
	[8] =  {
		key = "filled",
		name = L.Filled,
		desc = L.AuraFilledDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[9] = colors,
	[10] = D.Helpers.Anchor,
	[11] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("BANDITSGUILE", options, L.PluginShortDescription_BANDITSGUILE, L.PluginDescription_BANDITSGUILE)