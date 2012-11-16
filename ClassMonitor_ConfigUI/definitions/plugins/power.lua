local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local powerTypes = {
	[SPELL_POWER_HOLY_POWER] = L.PowerValueHolyPower,
	[SPELL_POWER_SOUL_SHARDS] = L.PowerValueSoulShards,
	[SPELL_POWER_LIGHT_FORCE or 12] = L.PowerValueChi, -- TODO: Bug in 5.1
	[SPELL_POWER_SHADOW_ORBS] = L.PowerValueShadowOrbs,
}
local function GetPowerTypes()
	return powerTypes
end

local options = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.WidthAndHeight,
	[7] = D.Helpers.Specs,
	[8] = {
		key = "powerType",
		name = L.PowerType,
		desc = L.PowerTypeDesc,
		type = "select",
		values = GetPowerTypes,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[9] = {
		key = "count",
		name = L.PowerCount,
		desc = L.PowerCountDesc,
		type = "range",
		min = 1, max = 20, step = 1,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[10] = {
		key = "filled",
		name = L.Filled,
		desc = L.PowerFilledDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	-- TODO: colors
	[12] = D.Helpers.Anchor,
	[13] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("POWER", options, L.PluginShortDescription_POWER, L.PluginDescription_POWER)