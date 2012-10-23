local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

local UI = Engine.UI
local L = Engine.Locales
local C = Engine.Config

local CMDebug = false

local settings = C[UI.MyClass]
if not settings then return end

local function WARNING(line)
	print("|CFFFF0000ClassMonitor|r: WARNING - "..line)
end

local function DEBUG(line)
	if not CMDebug or CMDebug == false then return end
	print("|CFF0000FFClassMonitor|r: DEBUG - "..line)
end

-- Create a color array from one color
local function CreateColorArray(color, count)
	if not color or not count then return end
	local colors = { }
	for i = 1, count, 1 do
		tinsert(colors, color)
	end
	return colors
end

local function DefaultBoolean(value, default)
	if value == nil then
		return default
	else
		return value
	end
end

---------------------------------------
-- Main
local function __dump(t)
	-- if type(t) == "table" then
		-- for k, v in pairs(t) do
			-- print("[" .. tostring(k) .. "]=")
			-- __dump(v)
		-- end
	-- else
		-- print(tostring(t))
	-- end
	for k, v in pairs(t) do
		local s = ""
		if type(v) == "table" then
			s = s .. "("
			for k1, v1 in pairs(v) do
				s = s .. "[" .. tostring(k1).."] => "..tostring(v1) .. ","
			end
			s = s .. ")"
		else
			s = tostring(v)
		end
		print(tostring(k).." ==> "..s)
	end
end

local DeepCopy = Engine.DeepCopy
local function MergeConfig(config, saved)
-- dump config
--print("BEFORE:")
--__dump(config)

--print("Merging...")
	for _, config_section in ipairs(config) do
		local savedEntry = nil
		for saved_key, saved_section in pairs(saved) do
			if saved_key == config_section.name then
				savedEntry = saved_section
				break
			end
		end
		if savedEntry then
			-- overwrite value from saved to config
			for key, value in pairs(config_section) do
				if key ~= "name" and savedEntry[key] ~= nil then
--print("Overwrite: "..tostring(config_section.name).."."..tostring(key).."  from "..tostring(value).." to "..tostring(savedEntry[key]))
--__dump(copy)
					config_section[key] = DeepCopy(savedEntry[key])
				end
			end
			-- add new entry from saved to config
			for key, value in pairs(savedEntry) do
				if config_section[key] == nil then
--print("Clone: "..tostring(config_section.name).."."..tostring(key).."  "..tostring(value))
					config_section[key] = DeepCopy(value)
				end
			end
		end
	end
	for saved_key, saved_section in ipairs(saved) do
		local found = false
		for _, config_section in ipairs(config) do
			if saved_key == config_section.name then
				found = true
				break
			end
		end
		if not found then
--print("Add new section: "..tostring(saved_key))
			tinsert(config, DeepCopy(saved_section))
		end
	end

-- dump config
--print("AFTER:")
--__dump(config)
end

local function CleanConfig()
	-- Remove non-class specific spell-list
	for class in pairs(C) do
		if class ~= UI.MyClass then
			C[class] = nil
		end
	end
end

local function CreatePlugins()
	-- Create monitor frames
	for i, section in ipairs(settings) do
		local name = section.name -- no default
		local kind = section.kind -- no default
		local anchor = section.anchor -- no default
		section.enable = DefaultBoolean(section.enable, true) -- set default value
		section.width = section.width or 85
		section.height = section.height or 15
		section.specs = section.specs or {"any"}
		section.autohide = DefaultBoolean(section.autohide, true)

		DEBUG("section:"..name)
		if name and kind and anchor then
			local frame
			if kind == "MOVER" then
				section.text = section.text or name.."_MOVER"
				frame = UI.CreateMover(name, section.width, section.height, anchor, section.text)
			elseif kind == "RESOURCE" then
				section.text = DefaultBoolean(section.text, true)
				local colors = section.colors or (section.color and {section.color})

				frame = Engine.CreateResourceMonitor(name, section.enable, section.text, section.autohide, anchor, section.width, section.height, colors, section.specs)
			elseif kind == "HEALTH" then
				section.unit = section.unit or "player"
				section.text = DefaultBoolean(section.text, true)
				local color = section.color

				frame = Engine.CreateHealthMonitor(name, section.enable, section.unit, section.text, section.autohide, anchor, section.width, section.height, color, section.specs)
			elseif kind == "ENERGIZE" then
				local spellID = section.spellID
				section.filling = DefaultBoolean(section.filling, false)
				local duration = section.duration
				local color = section.color or UI.ClassColor()

				if spellID and duration then
					frame = Engine.CreateEnergizeMonitor(name, section.enable, spellID, anchor, section.width, section.height, color, duration, section.filling)
				else
					WARNING("section:"..name..":"..(spellID and "" or " missing spellID")..(duration and "" or " missing duration")) -- TODO: locales
				end
			elseif kind == "COMBO" then
				local color = section.color or UI.ClassColor()
				local colors = section.colors or CreateColorArray(color, 5)
				section.filled = DefaultBoolean(section.filled, false)

				frame = Engine.CreateComboMonitor(name, section.enable, section.autohide, anchor, section.width, section.height, colors, section.filled, section.specs)
			elseif kind == "POWER" then
				local powerType = section.powerType
				local count = section.count
				section.filled = DefaultBoolean(section.filled, false)

				if powerType and count then
					local color = section.color or UI.ClassColor()
					local colors = section.colors or CreateColorArray(color, count)
					frame = Engine.CreatePowerMonitor(name, section.enable, section.autohide, powerType, count, anchor, section.width, section.height, colors, section.filled, section.specs)
				else
					WARNING("section:"..name..":"..(powerType and "" or " missing powerType")..(count and "" or " missing count")) -- TODO: locales
				end
			elseif kind == "AURA" then
				section.unit = section.unit or "player"
				local spellID = section.spellID
				local filter = section.filter
				local count = section.count

				if spellID and filter and count then
					local color = section.color or UI.ClassColor()
					local colors = section.colors or CreateColorArray(color, count)
					section.filled = DefaultBoolean(section.filled, false)

					frame = Engine.CreateAuraMonitor(name, section.enable, section.autohide, section.unit, spellID, filter, count, anchor, section.width, section.height, colors, section.filled, section.specs)
				else
					WARNING("section:"..name..":"..(spellID and "" or " missing spellID")..(filter and "" or " missing filter")..(count and "" or " missing count")) -- TODO: locales
				end
			elseif kind == "AURABAR" then
				section.unit = section.unit or "player"
				local spellID = section.spellID
				local filter = section.filter
				local count = section.count

				if spellID and filter and count then
					local color = section.color or UI.ClassColor()
					section.text = DefaultBoolean(section.text, true)
					section.duration = DefaultBoolean(section.duration, false)

					frame = Engine.CreateBarAuraMonitor(name, section.enable, section.autohide, section.unit, spellID, filter, count, anchor, section.width, section.height, color, section.text, section.duration, section.specs)
				else
					WARNING("section:"..name..":"..(spellID and "" or " missing spellID")..(filter and "" or " missing filter")..(count and "" or " missing count")) -- TODO: locales
				end
			elseif kind == "DOT" then
				local spellID = section.spellID
				local colors = section.colors or (section.color and {section.color})
				section.latency = DefaultBoolean(section.latency, false)
				section.threshold = section.threshold or 0

				if spellID then
					frame = Engine.CreateDotMonitor(name, section.enable, section.autohide, spellID, anchor, section.width, section.height, colors, section.threshold, section.latency, section.specs)
				else
					WARNING("section:"..name..":"..(spellID and "" or " missing spellID")) -- TODO: locales
				end
			elseif kind == "RUNES" then
				section.updatethreshold = section.updatethreshold or 0.1
				section.orientation = section.orientation or "HORIZONTAL"
				local colors = section.colors
				local runemap = section.runemap

				if runemap and colors then
					frame = Engine.CreateRunesMonitor(name, section.enable, section.updatethreshold, section.autohide, section.orientation, anchor, section.width, section.height, colors, runemap)
				else
					WARNING("section:"..name..":"..(runemap and "" or " missing runemap")..(colors and "" or " missing colors")) -- TODO: locales
				end
			elseif kind == "ECLIPSE" then
				local colors = section.colors
				section.text = DefaultBoolean(section.text, true)

				if colors then
					frame = Engine.CreateEclipseMonitor(name, section.enable, section.autohide, section.text, anchor, section.width, section.height, colors)
				else
					WARNING("section:"..name..": missing colors") -- TODO: locales
				end
			elseif kind == "TOTEMS" then
				local count = section.count
				if count then
					local color = section.color or UI.ClassColor()
					local colors = section.colors or CreateColorArray(color, count)
					section.text = DefaultBoolean(section.text, false)
					local map = section.map
					if map and #map ~= count then
						WARNING("section:"..name..": map table's size <> count") -- TODO: locales
					else
						frame = Engine.CreateTotemMonitor(name, section.enable, section.autohide, count, anchor, section.width, section.height, colors, section.text, map, section.specs)
					end
				else
					WARNING("section:"..name..": missing count") -- TODO: locales
				end
			elseif kind == "BANDITSGUILE" then
				local color = section.color or UI.ClassColor()
				local colors = section.colors or CreateColorArray(color, 3)
				section.filled = DefaultBoolean(section.filled, false)

				frame = Engine.CreateBanditsGuileMonitor(name, section.enable, section.autohide, anchor, section.width, section.height, colors, section.filled)
			elseif kind == "STAGGER" then
				section.threshold = section.threshold or 100
				section.text = DefaultBoolean(section.text, true)
				local colors = section.colors

				if colors then
					frame = Engine.CreateStaggerMonitor(name, section.enable, section.threshold, section.text, section.autohide, anchor, section.width, section.height, colors)
				else
					WARNING("section:"..name..":"..(colors or " missing colors")) -- TODO: locales
				end
			elseif kind == "TANKSHIELD" then
				local color = section.color or UI.ClassColor()
				section.duration = DefaultBoolean(section.duration, false)

				--frame = Engine.CreateTankShieldMonitor(name, section.enable, section.autohide, anchor, section.width, section.height, duration, color, section.specs)
				--frame = Engine.CreateTankShieldMonitor(name, section.enable, section.autohide, anchor, section.width, section.height, section.duration, color, section.specs)
				frame = Engine.CreateTankShieldMonitor(name, section.enable, section.autohide, anchor, section.width, section.height, section.duration, color)
			elseif kind == "BURNINGEMBERS" then
				local color = section.color or UI.ClassColor()
				local colors = section.colors or CreateColorArray(color, 4)

				frame = Engine.CreateBurningEmbersMonitor(name, section.enable, section.autohide, anchor, section.width, section.height, colors)
			elseif kind == "DEMONICFURY" then
				local color = section.color or PowerColor(SPELL_POWER_DEMONIC_FURY) or ClassColor()
				section.text = DefaultBoolean(section.text, true)

				frame = Engine.CreateDemonicFuryMonitor(name, section.enable, section.text, section.autohide, anchor, section.width, section.height, color)
			else
				WARNING("section:"..name..": invalid kind:"..kind) -- TODO: locales
			end

			-- WARNING if frame not created
			if not frame then DEBUG("section:"..name.." frame not created") end-- DEBUG -- TODO: locales
		else
			WARNING((name and "" or " missing name")..(kind and "" or " missing kind")..(anchor and "" or " missing anchor")) -- TODO: locales
		end
	end
end

--
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
	if addon == ADDON_NAME then
		self:UnregisterEvent("ADDON_LOADED")
		-- Greetings
		local version = GetAddOnMetadata(ADDON_NAME, "Version")
		local configVersion = GetAddOnMetadata("ClassMonitor_ConfigUI", "Version")
		if configVersion then
			print(string.format(L.classmonitor_greetingwithconfig, tostring(version), tostring(configVersion)))
		else
			print(string.format(L.classmonitor_greetingnoconfig, tostring(version)))
		end
		print(string.format(L.classmonitor_help_use, SLASH_CLASSMONITOR1, SLASH_CLASSMONITOR2))
		-- Merge config and saved variables
		if not ClassMonitorDataPerChar then
			ClassMonitorDataPerChar = {}
		else
			MergeConfig(settings, ClassMonitorDataPerChar)
		end
		-- Clean config
		CleanConfig()
		-- Create plugins
		CreatePlugins()

		-- -- TEST
		-- for width = 200, 300 do
			-- for count = 3, 10 do
				-- local w, s = Engine.PixelPerfect(width, count)
				-- --print("PIXELPERFECT:"..tostring(width/count).."  "..tostring(width).."/"..tostring(count).." => "..tostring(w).."  "..tostring(s).."  "..tostring((w and s) and (w * count + s * (count-1)) or ""))
				-- if not w or not s then
					-- print("PROBLEM:"..tostring(width).."  "..tostring(count))
				-- end
			-- end
		-- end

	end
end)

---- Delete config
--wipe(Engine.Config)  needed by ClassMonitor_ConfigUI