local _, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local G = Engine.Globals

D.Helpers = {}

----------------------------------------------------------------------------------------
-- Create an Ace3 config from definition, add arg with keyName, sectionName, config, savedVariables and parent
local function SetArgRecursively(option, keyValue, sectionNode, parentNode)
	option.arg = {key = keyValue, section = sectionNode, parent = parentNode}
	if option.args then
		for k, v in pairs(option.args) do
			SetArgRecursively(v, keyValue, sectionNode, option)
		end
	end
end

D.Helpers.CreateOptionsFromDefinitions = function(definition, orderID, sectionNode, ...)
	local options = {
		order = orderID,
		type = "group",
		name = sectionNode.displayName or sectionNode.name,
		args = {
		}
	}
	for k, v in pairs(definition) do
		-- clone
		local option = D.Helpers.DeepCopy(v)
		-- remove key
		option.key = nil
		-- add order
		option.order = k
		-- add arg
		SetArgRecursively(option, v.key, sectionNode, options)
		-- change entries
		for i = 1, select("#", ...), 2 do
			local entry, value = select(i, ...)
			if not entry then break end
			option[entry] = value
		end
		-- save copy
		options.args[v.key] = option
	end
	return options
end

----------------------------------------------------------------------------------------
D.Helpers.DeepCopy = function(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return new_table
	end
	return _copy(object)
end

----------------------------------------------------------------------------------------
local function GetGlobalWidth(info)
	if G.SavedPerChar.Global.width then
		return G.SavedPerChar.Global.width
	else
		-- MOVER is the reference
		for _, section in pairs(G.Config) do
			if section.name == "CM_MOVER" or section.kind == "MOVER" then
				return section.width
			end
		end
		return 262 -- hardcoded default
	end
end

local function SetGlobalWidth(info, value)
	local updated = false
	for _, section in pairs(G.Config) do
		if section.width then
			section.width = value
			G.SavedPerChar.Plugins[section.name] = G.SavedPerChar.Plugins[section.name] or {}
			G.SavedPerChar.Plugins[section.name].width = value
			updated = G.PluginUpdateFunction and G:PluginUpdateFunction(section.kind, section.name) or false
		end
	end
	G.SavedPerChar.Global.width = value

	if not updated then
		-- something modified, -> /reloadui
		G.ConfigModified = true
	end
end

function D.Helpers.CreateGlobalWidthOption(index)
	return {
		name = L.GlobalWidth,
		desc = L.GlobalWidthDesc,
		order = index,
		--guiInline = true,
		type = "range",
		arg = {key = "width"},
		min = 80, max = 300, step = 1,
		get = GetGlobalWidth,
		set = SetGlobalWidth,
	}
end

----------------------------------------------------------------------------------------
local function GetGlobalHeight(info)
	if G.SavedPerChar.Global.height then
		return G.SavedPerChar.Global.height
	else
		-- MOVER is the reference
		for _, section in pairs(G.Config) do
			if section.name == "CM_MOVER" or section.kind == "MOVER" then
				return section.height
			end
		end
		return 16 -- hardcoded default
	end
end

local function SetGlobalHeight(info, value)
	local updated = false
	for _, section in pairs(G.Config) do
		if section.height then
			section.height = value
			G.SavedPerChar.Plugins[section.name] = G.SavedPerChar.Plugins[section.name] or {}
			G.SavedPerChar.Plugins[section.name].height = value
			updated = G.PluginUpdateFunction and G:PluginUpdateFunction(section.kind, section.name) or false
		end
	end
	G.SavedPerChar.Global.height = value

	if not updated then
		-- something modified, -> /reloadui
		G.ConfigModified = true
	end
end

function D.Helpers.CreateGlobalHeightOption(index)
	return {
		name = L.GlobalHeight,
		desc = L.GlobalHeightDesc,
		order = index,
		--guiInline = true,
		type = "range",
		arg = {key = "height"},
		min = 10, max = 50, step = 1,
		get = GetGlobalHeight,
		set = SetGlobalHeight,
	}
end

----------------------------------------------------------------------------------------
local function ResetConfig()
	-- delete data per char
	for k, v in pairs(G.SavedPerChar) do
		G.SavedPerChar[k] = nil
	end
	-- delete data per realm
	for k, v in pairs(G.SavedPerAccount) do
		G.SavedPerAccount[k] = nil
	end
	-- reload
	ReloadUI()
end

function D.Helpers.CreateResetOption(index)
	return {
		name = L.Reset,
		desc = L.ResetDesc,
		order = index,
		type = "execute",
		func = ResetConfig,
		confirm = true,
		confirmText = L.CLASSMONITOR_RESETCONFIG_CONFIRM
	}
end

----------------------------------------------------------------------------------------
D.Helpers.SaveValue = function(section, info, value)
--print("SaveValue:"..tostring(info.arg.key).."  "..tostring(section.name).."  "..tostring(G.SavedPerChar.Plugins).."  "..tostring(G.SavedPerChar.Plugins[section.name]))
-- for k, v in pairs(G.SavedPerChar.Plugins) do
	-- print(tostring(k).."=>"..tostring(v))
-- end
	G.SavedPerChar.Plugins[section.name] = G.SavedPerChar.Plugins[section.name] or {}
	G.SavedPerChar.Plugins[section.name][info.arg.key] = value

	local updated = G.PluginUpdateFunction and G:PluginUpdateFunction(section.kind, section.name) or false

	if not updated then
		-- something modified, -> /reloadui
		G.ConfigModified = true
	end
end

D.Helpers.GetValue = function(info)
--print("GET "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(info.arg.section[info.arg.key]))
	return info.arg.section[info.arg.key]
end

D.Helpers.SetValue = function(info, value)
--print("SET "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(info.arg.section[info.arg.key]).."  "..tostring(value))
	info.arg.section[info.arg.key] = value
	D.Helpers.SaveValue(info.arg.section, info, info.arg.section[info.arg.key])
end

D.Helpers.GetNumberValue = function(info)
	return tostring(info.arg.section[info.arg.key])
end

D.Helpers.SetNumberValue = function(info, value)
	info.arg.section[info.arg.key] = tonumber(value)
	D.Helpers.SaveValue(info.arg.section, info, info.arg.section[info.arg.key])
end

D.Helpers.GetMultiValue = function(info, key)
--print("GET MULTIVALUE "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(key).."  "..tostring(info.arg.section[info.arg.key]))
	if info.arg.section[info.arg.key] then
		for k, v in pairs(info.arg.section[info.arg.key]) do
			if tostring(v) == key then
				return true
			end
		end
	end
	return false
end

D.Helpers.SetMultiValue = function(info, key, value)
--print("SET MULTIVALUE "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(key).."  "..tostring(info.arg.section[info.arg.key]).."  "..tostring(value))
	info.arg.section[info.arg.key] = info.arg.section[info.arg.key] or {}
	local found = 0
	for k, v in pairs(info.arg.section[info.arg.key]) do
		if tostring(v) == key then
			found = k
			break
		end
	end
	if value == true and found == 0 then
		tinsert(info.arg.section[info.arg.key], key)
	elseif value == false and found ~= 0 then
		tremove(info.arg.section[info.arg.key], found)
	end
	D.Helpers.SaveValue(info.arg.section, info, info.arg.section[info.arg.key])
end

----------------------------------------------------------------------------------------
D.Helpers.IsDisabled = function(info)
--print("IsDisabled:"..tostring(info.arg.key).."  "..tostring(not info.arg.section.enable))
	return not info.arg.section.enable
end

----------------------------------------------------------------------------------------
D.Helpers.ValidateNumber = function(info, value)
	local asNumber = tonumber(value)
--print("ValidateNumber:"..tostring(asNumber).."  "..type(value).."  "..type(asNumber))
	if asNumber and type(asNumber) == "number" then
		return true
	else
		return L.MustBeANumber
	end
end

----------------------------------------------------------------------------------------
D.Helpers.Name = {
	key = "name",
	name = L.Name,
	desc = L.NameDesc,
	type = "input",
	get = D.Helpers.GetValue,
	disabled = true,
}

D.Helpers.DisplayName = {
	key = "displayName",
	name = L.DisplayName,
	desc = L.DisplayNameDesc,
	type = "input",
	get = D.Helpers.GetValue,
	disabled = true,
}

local kindValues = {
	["MOVER"] = L.KindValueMover,
	["AURA"] = L.KindValueAura,
	["AURABAR"] = L.KindValueAuraBar,
	["RESOURCE"] = L.KindValueResource,
	["COMBO"] = L.KindValueCombo,
	["POWER"] = L.KindValuePower,
	["RUNES"] = L.KindValueRunes,
	["ECLIPSE"] = L.KindValueEclipse,
	["ENERGIZE"] = L.KindValueEnergize,
	["HEALTH"] = L.KindValueHealth,
	["DOT"] = L.KindValueDot,
	["TOTEMS"] = L.KindValueTotems,
	["BANDITSGUILE"] = L.KindValueBanditsGuile,
	["STAGGER"] = L.KindValueStagger,
	["TANKSHIELD"] = L.KindValueTankShield,
	["BURNINGEMBERS"] = L.KindValueBurningEmbers,
	["DEMONICFURY"] = L.KindValueDemonicFury,
	["RECHARGE"] = L.KindValueRecharge,
	["RECHARGEBAR"] = L.KindValueRechargeBar,
	["CD"] = L.KindValueCD,
}
local function GetKindValues()
	return kindValues
end
D.Helpers.Kind =  {
	key = "kind",
	name = L.Kind ,
	desc = L.KindDesc,
	type = "select",
	get = D.Helpers.GetValue,
	values = GetKindValues,
	disabled = true,
}

D.Helpers.Enable = {
	key = "enable",
	name = L.Enable,
	desc = L.EnableDesc,
	type = "toggle",
	get = D.Helpers.GetValue,
	set = D.Helpers.SetValue,
}

D.Helpers.Autohide = {
	key = "autohide",
	name = L.Autohide,
	desc = L.AutohideDesc,
	type = "toggle",
	get = D.Helpers.GetValue,
	set = D.Helpers.SetValue,
	disabled = D.Helpers.IsDisabled
}

D.Helpers.Width = {
	key = "width",
	name = L.Width,
	desc = L.WidthDesc,
	type = "range",
	min = 80, max = 300, step = 1,
	get = D.Helpers.GetValue,
	set = D.Helpers.SetValue,
	disabled = D.Helpers.IsDisabled
}

D.Helpers.Height = {
	key = "height",
	name = L.Height,
	desc = L.HeightDesc,
	type = "range",
	min = 10, max = 50, step = 1,
	get = D.Helpers.GetValue,
	set = D.Helpers.SetValue,
	disabled = D.Helpers.IsDisabled
}

local filterValues = {
	["HELPFUL"] = L.FilterValueHelpful,
	["HARMFUL"] = L.FilterValueHarmful,
}
local function GetFilterValues()
	return filterValues
end
D.Helpers.Filter = {
	key = "filter",
	name = L.Filter,
	desc = L.FilterDesc,
	type = "select",
	get = D.Helpers.GetValue,
	set = D.Helpers.SetValue,
	values = GetFilterValues,
	disabled = D.Helpers.IsDisabled
}

local unitValues = {
	["player"] = L.UnitValuePlayer,
	["target"] = L.UnitValueTarget,
	["focus"] = L.UnitValueFocus,
	["pet"] = L.UnitValuePet,
}
local function GetUnitValues()
	return unitValues
end
D.Helpers.Unit = {
	key = "unit",
	name = L.Unit,
	desc = L.UnitDesc,
	type = "select",
	values = GetUnitValues,
	get = D.Helpers.GetValue,
	set = D.Helpers.SetValue,
	disabled = D.Helpers.IsDisabled
}

----------------------------------------------------------------------------------------
local function GetSpecsValue(info, key)
--print("GET SPECSVALUE "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(key).."  "..tostring(info.arg.section[info.arg.key]))
	if info.arg.section[info.arg.key] then
		for k, v in pairs(info.arg.section[info.arg.key]) do
			if tostring(v) == key then
				return true
			end
		end
	end
	return false
end

local function SetSpecsValue(info, key, value)
--print("SET SPECSVALUE "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(key).."  "..tostring(info.arg.section[info.arg.key]).."  "..tostring(value))
	info.arg.section[info.arg.key] = info.arg.section[info.arg.key] or {}
	if key == "any" and value == true then
		-- replace value by "any"
		info.arg.section[info.arg.key] = {key}
	else
		-- remove "any"
		for k, v in pairs(info.arg.section[info.arg.key]) do
			if tostring(v) == "any" then
				tremove(info.arg.section[info.arg.key], k)
				break
			end
		end
		-- check if key already in array
		local found = 0
		for k, v in pairs(info.arg.section[info.arg.key]) do
			if tostring(v) == key then
				found = k
				break
			end
		end
		if value == true and found == 0 then
			tinsert(info.arg.section[info.arg.key], key) -- add key
		elseif value == false and found ~= 0 then
			tremove(info.arg.section[info.arg.key], found) -- remove key
		end
	end
	D.Helpers.SaveValue(info.arg.section, info, info.arg.section[info.arg.key])
end

local function GetSpecsValues()
	local specs = {}
	specs["any"] = "Any"
	local num = GetNumSpecializations()
	for i = 1, num do
		local _, specName = GetSpecializationInfo(i)
		specs[tostring(i)] = specName -- TODO: why the hell, am I forced to used a string as key
	end
	return specs
end

D.Helpers.Specs = {
	key = "specs",
	name = L.Specs,
	desc = L.SpecsDesc,
	type = "multiselect",
	get = GetSpecsValue,
	set = SetSpecsValue,
	values = GetSpecsValues,
	disabled = D.Helpers.IsDisabled
}

-------------------------------
-- Spell ID
local function GetSpellIDAndSetSpellIcon(info)
	local value = D.Helpers.GetValue(info)
--print("GetSpellIDAndSetSpellIcon:"..tostring(value))
	local parent = info.arg.parent -- get Spell option (parent of spellID and spellIcon)
--print("GetSpellIDAndSetSpellIcon:parent:"..tostring(parent))
	local spellIcon = parent and parent.args and parent.args.spellIcon -- get spellIcon option from Spell option
--print("GetSpellIDAndSetSpellIcon:icon:"..tostring(spellIcon))
	if spellIcon then
-- print("SPELLICON:"..tostring(spellIcon))
		local name, _, icon = GetSpellInfo(tonumber(value))
		if name and icon then
			spellIcon.name = name
			spellIcon.image = icon
			spellIcon.desc = name
			-- TODO: set tooltip
		else
			spellIcon.name = "Invalid"
			spellIcon.image = "INTERFACE/ICONS/INV_MISC_QUESTIONMARK"
		end
	end
	--
	return tostring(value) --
end

local function ValidateSpellID(info, value)
	local asNumber = tonumber(value)
	if asNumber and type(asNumber) == "number" then
		local spellName = GetSpellInfo(asNumber)
		if not spellName then
			return L.InvalidSpellID
		else
			return true
		end
	else
		return L.MustBeANumber
	end
end

D.Helpers.Spell = {
	key = "spellID",
	name = L.Spell,
	desc = L.SpellDesc,
	type = "group",
	guiInline = true,
	args = {
		spellID = {
			order = 1,
			name = L.SpellSpellID,
			desc = L.SpellSpellIDDesc,
			type = "input",
			validate = ValidateSpellID,
			get = GetSpellIDAndSetSpellIcon,
			set = D.Helpers.SetNumberValue--D.Helpers.SetValue,
		},
		spellIcon = {
			order = 2,
			name = "Invalid",
			type = "description",
			image = "INTERFACE/ICONS/INV_MISC_QUESTIONMARK",
		},
	},
	disabled = D.Helpers.IsDisabled
}

-----------------------------
-- Anchor
local function GetAnchor(info)
	-- point, relativeFrame, relativePoint, offsetX, offsetY
	--anchor = { "CENTER", UIParent, "CENTER", 0, -140 },
	local option = info[#info]
	if option == "point" then
		value = info.arg.section[info.arg.key][1]
	elseif option == "relativeFrame" then
		value = tostring(info.arg.section[info.arg.key][2])
	elseif option == "relativePoint" then
		value = info.arg.section[info.arg.key][3]
	elseif option == "offsetX" then
		value = info.arg.section[info.arg.key][4]
	elseif option == "offsetY" then
		value = info.arg.section[info.arg.key][5]
	end
	--print("GetAnchor "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(info.arg.section[info.arg.key]).."  "..tostring(info[#info]).."  "..tostring(value))
	return value
end

local function SetAnchor(info, value)
	local section = info.arg.section
	--print("SetAnchor "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(info.arg.section[info.arg.key]).."  "..tostring(value).."  "..tostring(info[#info]))
	local option = info[#info]
	if option == "point" then
		section[info.arg.key][1] = tostring(value)
	elseif option == "relativeFrame" then
		section[info.arg.key][2] = tostring(value)
	elseif option == "relativePoint" then
		section[info.arg.key][3] = tostring(value)
	elseif option == "offsetX" then
		section[info.arg.key][4] = value
	elseif option == "offsetY" then
		section[info.arg.key][5] = value
	end
	-- save
	G.SavedPerChar.Plugins[section.name] = G.SavedPerChar.Plugins[section.name] or {}
	G.SavedPerChar.Plugins[section.name][info.arg.key] = D.Helpers.DeepCopy(section[info.arg.key])

	local updated = G.PluginUpdateFunction and G:PluginUpdateFunction(section.kind, section.name) or false

	if not updated then
		-- something modified, -> /reloadui
		G.ConfigModified = true
	end
end

--local frameListValues = nil
local function GetFrameListValues(info)
	local values = {}
	values["UIParent"] = "UIParent" -- Add main frame
	for _, section in pairs(G.Config) do
		if section.name ~= info.arg.section.name then -- can't anchor a frame to itself
			values[section.name] = section.displayName or section.name
		end
	end
	return values
end

local positionValues = {
	["TOPLEFT"] = "TOPLEFT",
	["LEFT"] = "LEFT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["RIGHT"] = "RIGHT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
	["CENTER"] = "CENTER",
	["TOP"] = "TOP",
	["BOTTOM"] = "BOTTOM",
}
local function GetPositionsValues()
	return positionValues
end

D.Helpers.Anchor = {
	key = "anchor",
	name = L.Anchor,
	desc = L.AnchorDesc,
	type = "group",
	guiInline = true,
	get = GetAnchor,
	set = SetAnchor,
	args = {
		point = {
			order = 1,
			name = L.AnchorPoint,
			desc = L.AnchorPointDesc,
			type = "select",
			values = GetPositionsValues,
		},
		relativeFrame = {
			order = 2,
			name = L.AnchorRelativeFrame,
			desc = L.AnchorRelativeFrameDesc,
			type = "select",
			values = GetFrameListValues,
		},
		relativePoint = {
			order = 3,
			name = L.AnchorRelativePoint,
			desc = L.AnchorRelativePointDesc,
			type = "select",
			values = positionValues,
		},
		offsetX = {
			order = 4,
			name = L.AnchorOffsetX,
			desc = L.AnchorOffsetXDesc,
			type = "range",
			min = -400, max = 400, step = 1,
		},
		offsetY = {
			order = 5,
			name = L.AnchorOffsetY,
			desc = L.AnchorOffsetYDesc,
			type = "range",
			min = -400, max = 400, step = 1,
		},
	},
	disabled = D.Helpers.IsDisabled
}

-----------------------------
-- Colors
-- Only one color
local function GetColor(info)
	local color = D.Helpers.GetValue(info)
	return unpack(color)
end

local function SetColor(info, r, g, b)
	local color = {r, g, b}
	D.Helpers.SetValue(info, color)
end

-- Array of color
local function GetColors(info)
	local value = D.Helpers.GetValue(info)
	local index = tonumber(info[#info])
	local color = value[index]
--print("GetColors:"..tostring(value).."  "..tostring(index).."  "..tostring(color[1]).."  "..tostring(color[2]).."  "..tostring(color[3]))
	return unpack(color)
end

local function SetColors(info, r, g, b)
	local index = tonumber(info[#info])
--print("SetColors:"..tostring(index).."  "..tostring(r).."  "..tostring(g).."  "..tostring(b))
	local section = info.arg.section
	section[info.arg.key][index] = {r, g, b}
	G.SavedPerChar.Plugins[section.name] = G.SavedPerChar.Plugins[section.name] or {}
	G.SavedPerChar.Plugins[section.name][info.arg.key] = D.Helpers.DeepCopy(section[info.arg.key])

	local updated = G.PluginUpdateFunction and G:PluginUpdateFunction(section.kind, section.name) or false

	if not updated then
		-- something modified, -> /reloadui
		G.ConfigModified = true
	end
end

D.Helpers.CreateColorsDefinition = function(key, count, names)
--print(tostring(not names).."  "..tostring(names).."  "..tostring(names and type(names) == "table").."  "..tostring(names and type(names) == "table" and #names == count))
	assert(not names or (names and count == 1 and type(names) == "string") or (names and type(names) == "table" and #names == count), "Invalid names for colors definition")
	if count == 1 then
		return {
			key = key,
			name = type(names) == "table" and names[1] or names,
			desc = type(names) == "table" and names[1] or names,
			type = "color",
			get = GetColor,
			set = SetColor,
			disabled = D.Helpers.IsDisabled
		}
	else
		local args = {}
		for i = 1, count do
			args[tostring(i)] = {
				order = i,
				name = names and names[i] or tostring(i),
				type = "color"
			}
		end
		return {
			key = key,
			name = L.Colors,
			desc = L.Colors,
			type = "group",
			guiInline = true,
			get = GetColors,
			set = SetColors,
			args = args,
			disabled = D.Helpers.IsDisabled
		}
	end
end