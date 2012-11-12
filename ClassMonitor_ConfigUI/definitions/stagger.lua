local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local Colors = D.Helpers.CreateColorsDefinition("colors", 3, {L.StaggerLight, L.StaggerModerate, L.StaggerHeavy} )

D["STAGGER"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = {
		key = "threshold",
		name = L.Threshold,
		desc = L.StaggerThresholdDesc,
		type = "range",
		min = 1, max = 100, step = 1, -- isPercent = true,  isPercent implies values in range [0, 1]
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	[9] = {
		key = "text",
		name = L.CurrentValue,
		desc = L.StaggerTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	[10] = Colors,
	[11] = D.Helpers.Anchor,
	[12] = D.Helpers.AutoGridVerticalIndex,
	[13] = D.Helpers.AutoGridHorizontalIndex,
}