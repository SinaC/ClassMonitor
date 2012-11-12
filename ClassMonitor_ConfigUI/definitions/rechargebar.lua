local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local Color = D.Helpers.CreateColorsDefinition("color", 1, {L.BarColor})

D["RECHARGEBAR"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = {
		key = "text",
		name = L.TimeLeft,
		desc = L.RechargeBarTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	[10] = D.Helpers.Spell,
	[11] = Color,
	[12] = D.Helpers.Anchor,
	[13] = D.Helpers.AutoGridVerticalIndex,
	[14] = D.Helpers.AutoGridHorizontalIndex,
}