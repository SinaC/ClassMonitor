local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local powerTypes = {
	[SPELL_POWER_HOLY_POWER] = L.PowerValueHolyPower,
	[SPELL_POWER_SOUL_SHARDS] = L.PowerValueSoulShards,
	[SPELL_POWER_CHI] = L.PowerValueChi,
	[SPELL_POWER_SHADOW_ORBS] = L.PowerValueShadowOrbs,
}
local function GetPowerTypes()
	return powerTypes
end

local options = {
	[1] = D.Helpers.Description,
	[2] = D.Helpers.Name,
	[3] = D.Helpers.DisplayName,
	[4] = D.Helpers.Kind,
	[5] = D.Helpers.Enabled,
	[6] = D.Helpers.Autohide,
	[7] = D.Helpers.WidthAndHeight,
	[8] = D.Helpers.Specs,
	[9] = {
		key = "powerType",
		name = L.PowerType,
		desc = L.PowerTypeDesc,
		type = "select",
		values = GetPowerTypes,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[10] = {
		key = "count",
		name = L.PowerCount,
		desc = L.PowerCountDesc,
		type = "range",
		min = 1, max = 20, step = 1,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[11] = {
		key = "filled",
		name = L.Filled,
		desc = L.PowerFilledDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[12] = {
		key = "reverse",
		name = L.Reverse,
		desc = L.ReverseDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	-- TODO: colors
	[13] = D.Helpers.Anchor,
	[14] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("POWER", options, L.PluginShortDescription_POWER, L.PluginDescription_POWER)