local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local colors = D.Helpers.CreateColorsDefinition("colors", 4, { L.ResolveLow, L.ResolveMed, L.ResolveHigh, L.ResolveVeryHigh } )
local options = {
	[1] = D.Helpers.Description,
	[2] = D.Helpers.Name,
	[3] = D.Helpers.DisplayName,
	[4] = D.Helpers.Kind,
	[5] = D.Helpers.Enabled,
	[6] = D.Helpers.Autohide,
	[7] = D.Helpers.WidthAndHeight,
	[8] = colors,
	[9] = D.Helpers.Anchor,
	[10] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("RESOLVE", options, L.PluginShortDescription_RESOLVE, L.PluginDescription_RESOLVE)
