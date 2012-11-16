local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local colors = D.Helpers.CreateColorsDefinition("colors", 3, {L.DotColor1, L.DotColor2, L.DotColor3})
local options = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.WidthAndHeight,
	[7] = D.Helpers.Specs,
	[8] = D.Helpers.Spell,
	[9] = {
		key = "latency",
		name = L.DotLatency,
		desc = L.DotLatencyDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[10] = {
		key = "threshold",
		name = L.Threshold,
		desc = L.DotThresholdDesc,
		type = "input",
		get = D.Helpers.GetNumberValue, --D.Helpers.GetValue,
		set = D.Helpers.SetNumberValue, --D.Helpers.SetValue,
		validate = D.Helpers.ValidateNumber,
		disabled = D.Helpers.IsPluginDisabled
	},
	[11] = colors,
	[12] = D.Helpers.Anchor,
	[13] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("DOT", options, L.PluginShortDescription_DOT, L.PluginDescription_DOT)