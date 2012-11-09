local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local Color = D.Helpers.CreateColorsDefinition("color", 1, {L.BarColor})

D["AURABAR"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = D.Helpers.Unit,
	[10] = D.Helpers.Spell,
	[11] = D.Helpers.Fill,
	[12] = {
		key = "count",
		name = L.AuraCount,
		desc = L.AuraCountDesc,
		type = "range",
		min = 1, max = 100, step = 1,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	[13] = {
		key = "text",
		name = L.CurrentValue,
		desc = L.AurabarTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	[14] = {
		key = "duration",
		name = L.TimeLeft,
		desc = L.AurabarDurationDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	[15] = Color,
	[16] = D.Helpers.Anchor,
}