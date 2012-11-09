local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local Color = D.Helpers.CreateColorsDefinition("color", 1, {L.BarColor})

D["TANKSHIELD"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = {
		key = "duration",
		name = L.Duration,
		desc = L.TankshieldDurationDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	[9] = Color,
	[10] = D.Helpers.Anchor,
}