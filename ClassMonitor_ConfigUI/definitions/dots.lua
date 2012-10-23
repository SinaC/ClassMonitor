local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local UI = Engine.UI

D["DOT"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.Kind,
	[3] = D.Helpers.Enable,
	[4] = D.Helpers.Anchor,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = D.Helpers.SpellID,
	[10] = D.Helpers.SpellIcon,
	[11] = {
		key = "latency",
		name = "Latency",
		desc = "See latency",
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
	},
	[12] = {
		key = "threshold",
		name = "Threshold",
		desc = "Threshold",
		type = "input",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		validate = ValidateNumber,
	},
	-- TODO: colors (3)
}