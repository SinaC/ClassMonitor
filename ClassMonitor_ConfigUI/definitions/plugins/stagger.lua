local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local colors = D.Helpers.CreateColorsDefinition("colors", 3, {L.StaggerLight, L.StaggerModerate, L.StaggerHeavy} )
local options = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.WidthAndHeight,
	[7] = {
		key = "threshold",
		name = L.Threshold,
		desc = L.StaggerThresholdDesc,
		type = "range",
		min = 1, max = 100, step = 1, -- isPercent = true,  isPercent implies values in range [0, 1]
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[8] = {
		key = "text",
		name = L.CurrentValue,
		desc = L.StaggerTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[9] = colors,
	[10] = D.Helpers.Anchor,
	[11] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("STAGGER", options, L.PluginShortDescription_STAGGER, L.PluginDescription_STAGGER)