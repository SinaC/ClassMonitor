local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local options = {
	[1] = D.Helpers.Description,
	[2] = D.Helpers.Name,
	[3] = D.Helpers.DisplayName,
	[4] = D.Helpers.Kind,
	[5] = D.Helpers.Enabled,
	[6] = D.Helpers.Autohide,
	[7] = D.Helpers.WidthAndHeight,
	-- TODO: colors
	[9] = D.Helpers.Anchor,
	[10] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("BURNINGEMBERS", options, L.PluginShortDescription_BURNINGEMBERS, L.PluginDescription_BURNINGEMBERS)