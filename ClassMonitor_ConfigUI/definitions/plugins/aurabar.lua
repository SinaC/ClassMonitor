local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local color = D.Helpers.CreateColorsDefinition("color", 1, {L.BarColor})
local options = {
	[1] = D.Helpers.Description,
	[2] = D.Helpers.Name,
	[3] = D.Helpers.DisplayName,
	[4] = D.Helpers.Kind,
	[5] = D.Helpers.Enabled,
	[6] = D.Helpers.Autohide,
	[7] = D.Helpers.WidthAndHeight,
	[8] = D.Helpers.Specs,
	[9] = D.Helpers.Unit,
	[10] = D.Helpers.Spell,
	[11] = D.Helpers.Fill,
	-- [12] = {
		-- key = "count",
		-- name = L.AuraCount,
		-- desc = L.AuraCountDesc,
		-- type = "range",
		-- min = 1, max = 100, step = 1,
		-- get = D.Helpers.GetValue,
		-- set = D.Helpers.SetValue,
		-- disabled = D.Helpers.IsPluginDisabled
	-- },
	[12] = {
		key = "showspellname",
		name = L.AurabarShowspellname,
		desc = L.AurabarShowspellnameDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[13] = {
		key = "text",
		name = L.CurrentValue,
		desc = L.AurabarTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[14] = {
		key = "duration",
		name = L.TimeLeft,
		desc = L.AurabarDurationDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[15] = color,
	[16] = D.Helpers.Anchor,
	[17] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("AURABAR", options, L.PluginShortDescription_AURABAR, L.PluginDescription_AURABAR)