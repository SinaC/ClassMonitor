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
		name = L.TimeLeft,
		desc = L.RechargeBarTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[9] = D.Helpers.Spell,
	[10] = color,
	[11] = D.Helpers.Anchor,
	[12] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("RECHARGEBAR", options, L.PluginShortDescription_RECHARGEBAR, L.PluginDescription_RECHARGEBAR)