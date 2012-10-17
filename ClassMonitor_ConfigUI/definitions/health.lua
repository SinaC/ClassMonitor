local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local UI = Engine.UI

D["HEALTH"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.Kind,
	[3] = D.Helpers.Enable,
	[4] = D.Helpers.Anchor,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = D.Helpers.Unit,
	[10] = {
		key = "text",
		name = "Text",
		description = "Display current value",
		type = "toggle",
		default = true
	},
	-- [11] = {
		-- key = "color",
		-- name = "Color",
		-- description = "Bar color",
		-- type = "color",
		-- --TODO: default = UI. default: should be class color
	-- }
}