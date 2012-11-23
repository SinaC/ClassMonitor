local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local orientationValues = {
	["HORIZONTAL"] = "Horizontal",
	["VERTICAL"] = "Vertical",
}
local function GetOrientationValues()
	return orientationValues
end

local colors = D.Helpers.CreateColorsDefinition("colors", 4, {L.RunesBlood, L.RunesUnholy, L.RunesFrost, L.RunesDeath} )

local options = {
	[1] = D.Helpers.Description,
	[2] = D.Helpers.Name,
	[3] = D.Helpers.DisplayName,
	[4] = D.Helpers.Kind,
	[5] = D.Helpers.Enabled,
	[6] = D.Helpers.Autohide,
	[7] = D.Helpers.WidthAndHeight,
	[8] = {
		key = "updatethreshold",
		name = L.Threshold,
		desc = L.RunesThresholdDesc,
		type = "range",
		min = 0.1, max = 1, step = 0.1,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[9] = {
		key = "orientation",
		name = L.RunesOrientation,
		desc = L.RunesOrientationDesc,
		type = "select",
		values = GetOrientationValues,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	-- TODO: runemap
	[11] = colors,
	[12] = D.Helpers.Anchor,
	[13] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("RUNES", options, L.PluginShortDescription_RUNES, L.PluginDescription_RUNES)