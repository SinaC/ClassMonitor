local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local colors = D.Helpers.CreateColorsDefinition("colors", 2, {L.EclipseLunar, L.EclipseSolar} )
local options = {
	[1] = D.Helpers.Description,
	[2] = D.Helpers.Name,
	[3] = D.Helpers.DisplayName,
	[4] = D.Helpers.Kind,
	[5] = D.Helpers.Enabled,
	[6] = D.Helpers.Autohide,
	[7] = D.Helpers.WidthAndHeight,
	[8] = {
		key = "text",
		name = L.EclipseText,
		desc = L.EclipseTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[9] = colors,
	[10] = D.Helpers.Anchor,
	[11] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("ECLIPSE", options, L.PluginShortDescription_ECLIPSE, L.PluginDescription_ECLIPSE)