local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

D["COMBO"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.Kind,
	[3] = D.Helpers.Enable,
	[4] = D.Helpers.Anchor,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = {
		key = "filled",
		name = "Filled",
		desc = "Combo point filled or not",
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
	},
	-- TODO: colors
}