local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local Colors = D.Helpers.CreateColorsDefinition("colors", 5)

D["COMBO"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = {
		key = "filled",
		name = L.Filled,
		desc = L.ComboFilledDesc,
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