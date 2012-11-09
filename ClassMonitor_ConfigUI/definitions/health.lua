local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

D["HEALTH"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = D.Helpers.Unit,
	[10] = {
		key = "text",
		name = L.CurrentValue,
		desc = L.HealthTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	-- [11] = {
		-- key = "color",
		-- name = "Color",
		-- desc = "Bar color",
		-- type = "color",
		-- --TODO: default = UI. default: should be class color
	-- }
	[11] = D.Helpers.Anchor,
}