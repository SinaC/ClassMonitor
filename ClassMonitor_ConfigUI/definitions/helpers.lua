local _, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

D.Helpers = {}

--
StaticPopupDialogs["CLASSMONITOR_CONFIG_RL"] = {
	text = "One or more of the changes you have made require a ReloadUI.", -- TODO: locales
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
}

----------------------------------------------------------------------------------------
-- Create an Ace3 config from definition, add arg with keyName, sectionName, config, savedVariables and parent
D.Helpers.CreateOptionsFromDefinitions = function(definition, orderID, sectionName, configOptions, savedVariables, ...)
--print("CreateOptionsFromDefinitions:"..tostring(configOptions).."  "..tostring(savedVariables))
	local options = {
		order = orderID,
		type = "group",
		name = sectionName,
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
		option.arg = {key = v.key, section = sectionName, config = configOptions, saved = savedVariables, parent = options}
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
local function GetConfigSection(config, name)
	for k, section in pairs(config) do
		if section.name == name then
--print("SECTION: "..tostring(section.name))
			return section
		end
	end
	return nil -- not found
end

local function SaveValue(section, info, value)
--print("SaveValue:"..tostring(info.arg.key).."  "..tostring(section.name).."  "..tostring(info.arg.saved).."  "..tostring(info.arg.saved[section.name]))
-- for k, v in pairs(info.arg.saved) do
	-- print(tostring(k).."=>"..tostring(v))
-- end
	info.arg.saved[section.name] = info.arg.saved[section.name] or {}
	info.arg.saved[section.name][info.arg.key] = value
	-- something modified, -> /reloadui
	StaticPopup_Show("CLASSMONITOR_CONFIG_RL")
end

D.Helpers.GetValue = function(info)
	local section = GetConfigSection(info.arg.config, info.arg.section)
--print("GET "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(section[info.arg.key]))
	return section[info.arg.key]
end

D.Helpers.SetValue = function(info, value)
	local section = GetConfigSection(info.arg.config, info.arg.section)
--print("SET "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(section[info.arg.key]).."  "..tostring(value))
	section[info.arg.key] = value
	SaveValue(section, info, section[info.arg.key])
end

D.Helpers.GetMultiValue = function(info, key)
	local section = GetConfigSection(info.arg.config, info.arg.section)
--print("GET MULTIVALUE "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(key).."  "..tostring(section[info.arg.key]))
	if section[info.arg.key] then
		for k, v in pairs(section[info.arg.key]) do
			if tostring(v) == key then
				return true
			end
		end
	end
	return false
end

D.Helpers.SetMultiValue = function(info, key, value)
	local section = GetConfigSection(info.arg.config, info.arg.section)
--print("SET MULTIVALUE "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(key).."  "..tostring(section[info.arg.key]).."  "..tostring(value))
	section[info.arg.key] = section[info.arg.key] or {}
	local found = 0
	for k, v in pairs(section[info.arg.key]) do
		if tostring(v) == key then
			found = k
			break
		end
	end
	if value == true and found == 0 then
		tinsert(section[info.arg.key], key)
	elseif value == false and found ~= 0 then
		tremove(section[info.arg.key], found)
	end
	SaveValue(section, info, section[info.arg.key])
end

local function GetSpecsValue(info, key)
	local section = GetConfigSection(info.arg.config, info.arg.section)
--print("GET SPECSVALUE "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(key).."  "..tostring(section[info.arg.key]))
	if section[info.arg.key] then
		for k, v in pairs(section[info.arg.key]) do
			if tostring(v) == key then
				return true
			end
		end
	end
	return false
end

local function SetSpecsValue(info, key, value)
	local section = GetConfigSection(info.arg.config, info.arg.section)
--print("SET SPECSVALUE "..tostring(info.type)..":"..tostring(info.arg.key).."  "..tostring(key).."  "..tostring(section[info.arg.key]).."  "..tostring(value))
	section[info.arg.key] = section[info.arg.key] or {}
	if key == "any" and value == true then
		-- replace value by "any"
		section[info.arg.key] = {key}
	else
		-- remove "any"
		for k, v in pairs(section[info.arg.key]) do
			if tostring(v) == "any" then
				tremove(section[info.arg.key], k)
				break
			end
		end
		-- check if key already in array
		local found = 0
		for k, v in pairs(section[info.arg.key]) do
			if tostring(v) == key then
				found = k
				break
			end
		end
		if value == true and found == 0 then
			tinsert(section[info.arg.key], key) -- add key
		elseif value == false and found ~= 0 then
			tremove(section[info.arg.key], found) -- remove key
		end
	end
	SaveValue(section, info, section[info.arg.key])
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

----------------------------------------------------------------------------------------
D.Helpers.ValidateNumber = function(info, value)
	local asNumber = tonumber(value)
	if asNumber and type(asNumber) == "number" then
		return true
	else
		return "Must be a number"
	end
end

----------------------------------------------------------------------------------------
D.Helpers.Name = {
	key = "name",
	name = "Name",
	desc = "Name", -- TODO: locales
	type = "input",
	get = D.Helpers.GetValue,
	disabled = true,
}

D.Helpers.Kind =  {
	key = "kind",
	name = "Kind",
	desc = "Kind", -- TODO: locales
	type = "select",
	get = D.Helpers.GetValue,
	values = {
		--["MOVER"] = "Mover", -- can't configure mover
		["AURA"] = "Aura stacks", -- TODO: locales
		["AURABAR"] = "Aura bar", -- TODO: locales
		["RESOURCE"] = "Resource bar", -- TODO: locales
		["COMBO"] = "Combo points", -- TODO: locales
		["POWER"] = "Power points", -- TODO: locales
		["RUNES"] = "Runes", -- TODO: locales
		["ECLIPSE"] = "Eclipse bar", -- TODO: locales
		["ENERGIZE"] = "Energize bar", -- TODO: locales
		["HEALTH"] = "Health bar", -- TODO: locales
		["DOT"] = "Dot bar", -- TODO: locales
		["TOTEMS"] = "Totems and mushrooms", -- TODO: locales
		["BANDITSGUILE"] = select(1, GetSpellInfo(84654)), --"Bandit's Guile",
		["STAGGER"] = select(1, GetSpellInfo(124255)), --"Stagger value",
		["TANKSHIELD"] = "Tank shield", -- TODO: locales
		["BURNINGEMBERS"] = "Burning embers", -- TODO: locales
		["DEMONICFURY"] = "Demonic fury", -- TODO: locales
	},
	disabled = true,
}

D.Helpers.Enable = {
	key = "enable",
	name = "Enable",
	desc = "Enable",
	type = "toggle",
	get = D.Helpers.GetValue,
	set = D.Helpers.SetValue,
}

D.Helpers.Anchor = { -- TODO
	key = "anchor",
	name = "Anchor",
	desc = "Anchor", -- TODO: locales
	type = "description",
	hidden = true,
}

D.Helpers.Autohide = {
	key = "autohide",
	name = "Autohide",
	desc = "Autohide while out of combat", -- TODO: locales
	type = "toggle",
	get = D.Helpers.GetValue,
	set = D.Helpers.SetValue,
}

D.Helpers.Width = {
	key = "width",
	name = "Width",
	desc = "Total bar width", -- TODO: locales
	type = "range",
	min = 80, max = 300, step = 1,
	get = D.Helpers.GetValue,
	set = D.Helpers.SetValue,
}

D.Helpers.Height = {
	key = "height",
	name = "Height",
	desc = "Bar height", -- TODO: locales
	type = "range",
	min = 10, max = 50, step = 1,
	get = D.Helpers.GetValue,
	set = D.Helpers.SetValue,
}

D.Helpers.Specs = {
	key = "specs",
	name = "Specs",
	desc = "Active in specified specialization", -- TODO: locales
	type = "multiselect",
	get = GetSpecsValue,
	set = SetSpecsValue,
	values = GetSpecsValues,
}

D.Helpers.Unit = {
	key = "unit",
	name = "Unit",
	desc = "Unit to monitor", -- TODO: locales
	type = "select",
	values = {
		["player"] = "player", -- TODO: locales
		["target"] = "target", -- TODO: locales
		["focus"] = "focus", -- TODO: locales
		["pet"] = "pet", -- TODO: locales
	},
	get = D.Helpers.GetValue,
	set = D.Helpers.SetValue
}

-- local function SearchOption(current, optionName)
	-- for k, v in pairs(current) do
-- --print("K:"..tostring(k).."  "..tostring(optionName))
		-- if k == optionName then
			-- return v
		-- end
		-- if k == "args" then
-- --print("recursive call")
			-- local result = SearchOption(v, optionName)
			-- if result ~= nil then
				-- return result
			-- end
		-- end
	-- end
	-- return nil
-- end

-- local function GetSpellID(info)
	-- local value = D.Helpers.GetValue(info)
-- -- print("GetSpellID:"..tostring(value))
	-- -- get spellIcon if any and change name/icon
	-- -- get classmonitor root option node
	-- local root = SearchOption(info.options, "classmonitor") or info.options -- Search ClassMonitor node, use root if not found
	-- if not root then return end
	-- -- get info's parent option node
	-- local parentName = info[#info-1]
	-- local parent = SearchOption(root, parentName)
-- -- print("PARENT:"..tostring(parentName).."  "..tostring(parent))
	-- -- get spellIcon option
-- -- for k, v in pairs(parent.args) do
-- -- print("PARENT."..tostring(k).."="..tostring(v))
-- -- end
	-- local spellIcon = parent and parent.args and parent.args.spellIcon
	-- if spellIcon then
-- -- print("SPELLICON:"..tostring(spellIcon))
		-- local name, _, icon = GetSpellInfo(tonumber(value))
		-- if name and icon then
			-- spellIcon.name = name
			-- spellIcon.image = icon
			-- -- TODO: set description
		-- else
			-- spellIcon.name = "Invalid"
			-- spellIcon.image = "INTERFACE/ICONS/INV_MISC_QUESTIONMARK"
		-- end
	-- end
	-- --
	-- return tostring(value)
-- end

local function GetSpellIDAndSetSpellName(info)
	local value = D.Helpers.GetValue(info)
	local parent = info.arg.parent
	local spellIcon = parent and parent.args and parent.args.spellIcon
	if spellIcon then
-- print("SPELLICON:"..tostring(spellIcon))
		local name, _, icon = GetSpellInfo(tonumber(value))
		if name and icon then
			spellIcon.name = name
			spellIcon.image = icon
			-- TODO: set description
		else
			spellIcon.name = "Invalid"
			spellIcon.image = "INTERFACE/ICONS/INV_MISC_QUESTIONMARK"
		end
	end
	--
	return tostring(value)
end

local function ValidateSpellID(info, value)
	local asNumber = tonumber(value)
	if asNumber and type(asNumber) == "number" then
		local spellName = GetSpellInfo(asNumber)
		if not spellName then
			return "Invalid spellID"
		else
			return true
		end
	else
		return "spellID must be a number"
	end
end
D.Helpers.SpellID = {
	key = "spellID",
	name = "Spell ID",
	desc = "Spell ID to monitor",
	type = "input",
	--get = GetSpellID,
	get = GetSpellIDAndSetSpellName,
	set = D.Helpers.SetValue,
	validate = ValidateSpellID,
}

D.Helpers.SpellIcon = {
	key = "spellIcon",
	name = "Invalid",
	type = "description",
	image = "INTERFACE/ICONS/INV_MISC_QUESTIONMARK",
}
