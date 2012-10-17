local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local UI = Engine.UI

-- TODO: split power
D["DEMONICFURY"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.Kind,
	[3] = D.Helpers.Enable,
	[4] = D.Helpers.Anchor,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = {
		key = "text",
		name = "Text",
		description = "Display current demonic fury value",
		type = "toggle",
		default = true
	},
	-- TODO: color
}