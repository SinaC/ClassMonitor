local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local color = D.Helpers.CreateColorsDefinition("color", 1, { L.PluginShortDescription_DEMONICFURY })
local options = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.WidthAndHeight,
	[7] = {
		key = "text",
		name = L.CurrentValue,
		desc = L.DemonicfuryTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[8] = color,
	[9] = D.Helpers.Anchor,
	[10] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("DEMONICFURY", options, L.PluginShortDescription_DEMONICFURY, L.PluginDescription_DEMONICFURY)