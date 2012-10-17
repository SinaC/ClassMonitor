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
	[9] = {
		key = "spellID",
		name = "Spell ID",
		description = "Dot spell ID to monitor",
		type = "spell",
	},
	[10] = {
		key = "filling",
		name = "Filling",
		description = "Fill or empty bar",
		type = "toggle",
		default = false
	},
	[11] = { -- TODO: number but not a slider
		key = "duration",
		name = "Duration",
		description = "Display time left",
		type = "string",
		readonly = true,
		default = 1
	},
	-- [12] = {
		-- key = "color",
		-- name = "Color",
		-- description = "Bar color",
		-- type = "color",
		-- --TODO: default = UI. default: should be class color
	-- }
}