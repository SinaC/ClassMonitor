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

D["POWER"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = {
		key = "powerType",
		name = L.PowerType,
		desc = L.PowerTypeDesc,
		type = "select",
		values = GetPowerTypes,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	[10] = {
		key = "count",
		name = L.PowerCount,
		desc = L.PowerCountDesc,
		type = "range",
		min = 1, max = 20, step = 1,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	[11] = {
		key = "filled",
		name = L.Filled,
		desc = L.PowerFilledDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	-- TODO: colors
	[12] = D.Helpers.Anchor,
	[13] = D.Helpers.AutoGridVerticalIndex,
	[14] = D.Helpers.AutoGridHorizontalIndex,
}