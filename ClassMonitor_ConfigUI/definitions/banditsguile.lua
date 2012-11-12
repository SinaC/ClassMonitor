local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local Colors = D.Helpers.CreateColorsDefinition("colors", 3, {L.BanditsGuileShallow, L.BanditsGuileModerate, L.BanditsGuileDeep})

D["BANDITSGUILE"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] =  {
		key = "filled",
		name = L.Filled,
		desc = L.AuraFilledDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	[9] = Colors,
	[10] = D.Helpers.Anchor,
	[11] = D.Helpers.AutoGridVerticalIndex,
	[12] = D.Helpers.AutoGridHorizontalIndex,
}