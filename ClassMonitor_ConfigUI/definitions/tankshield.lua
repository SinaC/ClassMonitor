local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local UI = Engine.UI

D["TANKSHIELD"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.Kind,
	[3] = D.Helpers.Enable,
	[4] = D.Helpers.Anchor,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	--[8] = D.Helpers.Specs,
	[8] = {
		key = "duration",
		name = "Duration",
		desc = "Display shield time left",
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
	},
	-- [10] = {
		-- key = "color",
		-- name = "Color",
		-- desc = "Shield color",
		-- type = "color",
		-- --TODO: default = UI. default: should be class color
		-- optional = true
	-- }
}