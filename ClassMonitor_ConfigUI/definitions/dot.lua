local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local Colors = D.Helpers.CreateColorsDefinition("colors", 3, {L.DotColor1, L.DotColor2, L.DotColor3})

D["DOT"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = D.Helpers.Spell,
	[10] = {
		key = "latency",
		name = L.DotLatency,
		desc = L.DotLatencyDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	[11] = {
		key = "threshold",
		name = L.Threshold,
		desc = L.DotThresholdDesc,
		type = "input",
		get = D.Helpers.GetNumberValue, --D.Helpers.GetValue,
		set = D.Helpers.SetNumberValue, --D.Helpers.SetValue,
		validate = D.Helpers.ValidateNumber,
		disabled = D.Helpers.IsDisabled
	},
	[12] = Colors,
	[13] = D.Helpers.Anchor,
	[14] = D.Helpers.AutoGridVerticalIndex,
	[15] = D.Helpers.AutoGridHorizontalIndex,
}