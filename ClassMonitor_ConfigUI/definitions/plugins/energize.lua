local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local color = D.Helpers.CreateColorsDefinition("color", 1, {L.BarColor})
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
		key = "filling",
		name = L.EnergizeFilling,
		desc = L.EnergizeFillingDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[10] = {
		key = "duration",
		name = L.EnergizeDuration,
		desc = L.EnergizeDurationDesc,
		type = "input",
		get = D.Helpers.GetNumberValue, --D.Helpers.GetValue,
		set = D.Helpers.SetNumberValue, --D.Helpers.SetValue,
		validate = D.Helpers.ValidateNumber,
		disabled = D.Helpers.IsPluginDisabled
	},
	[11] = color,
	[12] = D.Helpers.Anchor,
	[13] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("ENERGIZE", options, L.PluginShortDescription_ENERGIZE, L.PluginDescription_ENERGIZE)