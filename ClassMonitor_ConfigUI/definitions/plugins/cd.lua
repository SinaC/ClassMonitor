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
	[8] = {
		key = "text",
		name = L.CDText,
		desc = L.CDTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[9] = {
		key = "duration",
		name = L.TimeLeft,
		desc = L.CDDurationDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[10] = D.Helpers.Spell,
	[11] = color,
	[12] = D.Helpers.Anchor,
	[13] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("CD", options, L.PluginShortDescription_CD, L.PluginDescription_CD)