local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local UI = Engine.UI

D["ENERGIZE"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.Kind,
	[3] = D.Helpers.Enable,
	[4] = D.Helpers.Anchor,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs, -- TODO: not yet used
	[9] = D.Helpers.SpellID,
	[10] = {
		key = "filling",
		name = "Filling",
		desc = "Fill or empty bar",
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
	},
	[11] = {
		key = "duration",
		name = "Duration",
		desc = "Energize duration",
		type = "input",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		validate = D.Helpers.ValidateNumber,
	},
	-- [12] = {
		-- key = "color",
		-- name = "Color",
		-- desc = "Bar color",
		-- type = "color",
		-- --TODO: default = UI. default: should be class color
	-- }
}