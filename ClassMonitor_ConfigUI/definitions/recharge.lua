local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

D["RECHARGE"] = {
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
		desc = L.RechargeTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	[10] = D.Helpers.Spell,
	-- [16] = {
		-- key = "color",
		-- name = "Color",
		-- desc = "Bar color",
		-- type = "color",
		-- --TODO: default = UI. default: should be class color
	-- }
	[11] = D.Helpers.Anchor,
}