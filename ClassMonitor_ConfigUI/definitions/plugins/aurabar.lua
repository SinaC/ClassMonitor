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
	[8] = D.Helpers.Unit,
	[9] = D.Helpers.Spell,
	[10] = D.Helpers.Fill,
	[11] = {
		key = "count",
		name = L.AuraCount,
		desc = L.AuraCountDesc,
		type = "range",
		min = 1, max = 100, step = 1,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[12] = {
		key = "text",
		name = L.CurrentValue,
		desc = L.AurabarTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[13] = {
		key = "duration",
		name = L.TimeLeft,
		desc = L.AurabarDurationDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[14] = color,
	[15] = D.Helpers.Anchor,
	[16] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("AURABAR", options, L.PluginShortDescription_AURABAR, L.PluginDescription_AURABAR)