local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local options = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.WidthAndHeight,
	-- TODO: colors
	[8] = D.Helpers.Anchor,
	[9] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("BURNINGEMBERS", options, L.PluginShortDescription_BURNINGEMBERS, L.PluginDescription_BURNINGEMBERS)