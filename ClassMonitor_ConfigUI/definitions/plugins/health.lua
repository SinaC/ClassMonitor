local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local options = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.WidthAndHeight,
	[7] = D.Helpers.Specs,
	[8] = D.Helpers.Unit,
	[9] = {
		key = "text",
		name = L.CurrentValue,
		desc = L.HealthTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[10] = D.Helpers.Anchor,
	[11] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("HEALTH", options, L.PluginShortDescription_HEALTH, L.PluginDescription_HEALTH)