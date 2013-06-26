local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

-- Definition
--[[
local default = {1, 1, 1}

local config = {
	colorKind = "AUTOMATIC", -- AUTOMATIC | SINGLE | MULTI
	color = { 1, 1, 1 },
	colors = nil
}

local function __TestGetKind(info)
	if config.colorKind == "AUTOMATIC" then
print("DISABLING COLORS")
		info.arg.parent.args.colors.disabled = true
		info.arg.parent.args.colors.hidden = true
	elseif config.colorKind == "SINGLE" then
		info.arg.parent.args.colors.disabled = false
		info.arg.parent.args.colors.hidden = false
		-- disable each color except first one
		for k, v in pairs(info.arg.parent.args.colors.args) do
			if k ~= "1" then
print("DISABLING:"..tostring(v.name))
				v.disabled = true
				v.hidden = true
			else
print("ENABLING:"..tostring(v.name))
				v.disabled = false
				v.hidden = false
			end
		end
	elseif config.colorKind == "MULTI" then
		info.arg.parent.args.colors.disabled = false
		info.arg.parent.args.colors.hidden = false
		-- enable each color
		for k, v in pairs(info.arg.parent.args.colors.args) do
print("ENABLING:"..tostring(v.name))
			v.disabled = false
			v.hidden = false
		end
	end
	return config.colorKind
end

local function __TestSetKind(info, value)
print("__TestSetMonocolor:"..tostring(value))
	--colors = { colors[1] }
	config.colorKind = value
	if config.colorKind == "MULTI" and not config.colors then
		config.colors = {}
		for i = 1, 5 do
			config.colors[i] = config.color or default
		end
	elseif config.colorKind == "SINGLE" and not config.color then
		if config.colors then
			config.color = config.colors[1]
		else
			config.color = default
		end
	end
end

local function __TestGetColor(info)
print("__TestGetColor:"..tostring(info[#info]))
	if config.colorKind == "SINGLE" then
		return unpack(config.color or default)
	elseif config.colorKind == "MULTI" then
		local index = tonumber(info[#info])
		return unpack((config.colors and config.colors[index]) or config.color or default)
	end
end

local function __TestSetColor(info, r, g, b)
print("__TestSetColor:"..tostring(info[#info]))
	if config.colorKind == "SINGLE" then
		config.color = {r, g, b}
	else
		local index = tonumber(info[#info])
		config.colors = config.colors or {}
		config.colors[index] = {r, g, b}
	end
end

local __TestDefinition = {
	key = "colors",
	name = "TEST",
	desc = "TEST",
	type = "group",
	guiInline = true,
	args = {
		kind = {
			name = "kind",
			desc = "kind",
			order = 1,
			type = "select",
			get = __TestGetKind,
			set = __TestSetKind,
			values = {
				["AUTOMATIC"] = "automatic",
				["SINGLE"] = "single",
				["MULTI"] = "multi",
			}
		},
		colors = {
			name = "colors",
			desc = "colors",
			order = 2,
			type = "group",
			guiInline = true,
			get = __TestGetColor,
			set = __TestSetColor,
			args = {
				["1"] = {
					order = 1,
					name = "1",
					type = "color",
				},
				["2"] = {
					order = 2,
					name = "2",
					type = "color",
				},
				["3"] = {
					order = 3,
					name = "3",
					type = "color",
				},
				["4"] = {
					order = 4,
					name = "4",
					type = "color",
				},
				["5"] = {
					order = 5,
					name = "5",
					type = "color",
				},
			}
		}
	},
	disabled = D.Helpers.IsPluginDisabled
}
--]]

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
	[11] = D.Helpers.Filter,
	[12] = {
		key = "count",
		name = L.AuraCount,
		desc = L.AuraCountDesc,
		type = "range",
		min = 1, max = 16, step = 1,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[13] = {
		key = "filled",
		name = L.Filled,
		desc = L.AuraFilledDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	[14] = {
		key = "reverse",
		name = L.Reverse,
		desc = L.ReverseDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	-- TODO: colors
	[15] = D.Helpers.Anchor,
	[16] = D.Helpers.AutoGridAnchor,
--	[0] = __TestDefinition
}

D.Helpers:NewPluginDefinition("AURA", options, L.PluginShortDescription_AURA, L.PluginDescription_AURA)