local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

local UI = Engine.UI
local L = Engine.Locales

local CMDebug = false

local settings = Engine.Config[UI.MyClass]
if not settings then return end

local function WARNING(line)
	print("|CFFFF0000ClassMonitor|r: WARNING - "..line)
end

local function DEBUG(line)
	if not CMDebug or CMDebug == false then return end
	print("|CFF0000FFClassMonitor|r: DEBUG - "..line)
end

-- Return anchor corresponding to current spec
local function GetAnchor(anchors)
	if not anchors then return end
	local spec = GetSpecialization()
	if not spec or spec == 0 then spec = 1 end
	return anchors[spec]
end

-- When multiple anchors are specified, anchor depends on current spec
local function SetMultipleAnchorHandler(frame, anchors)
	if not anchors then return end
	frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:HookScript("OnEvent", function(self, event)
		if event ~= "PLAYER_SPECIALIZATION_CHANGED" and event ~= "PLAYER_ENTERING_WORLD" then return end
		local anchor = GetAnchor(anchors)
		if not anchor then return end
		DEBUG("Anchor:"..tostring(event).." "..tostring(self:GetName()))
		self:ClearAllPoints()
		self:Point(unpack(anchor))
--print("SetMultipleAnchorHandler5:"..tostring(self:GetName()))
	end)
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
					local copy = Engine:DeepCopy(savedEntry[key])
--__dump(copy)
					config_section[key] = Engine.DeepCopy(savedEntry[key])
				end
			end
			-- add new entry from saved to config
			for key, value in pairs(savedEntry) do
				if config_section[key] == nil then
--print("Clone: "..tostring(config_section.name).."."..tostring(key).."  "..tostring(value))
					config_section[key] = Engine.DeepCopy(value)
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
			tinsert(config, Engine.Builder(saved_section))
		end
	end

-- dump config
--print("AFTER:")
--__dump(config)
end

local function CreatePlugins()
	-- Remove non-class specific spell-list
	for class in pairs(Engine.Config) do
		if class ~= UI.MyClass then
			Engine.Config[class] = nil
		end
	end

	-- Create monitor frames
	for i, section in ipairs(settings) do
		local name = section.name
		local kind = section.kind
		local enable = DefaultBoolean(section.enable, true)
		local anchors = section.anchors
		local anchor = section.anchor or GetAnchor(anchors)
		local width = section.width or 85
		local height = section.height or 15
		local spec = section.spec or "any"
		local specs = section.specs or {spec}

		DEBUG("section:"..name)
		if name and kind and anchor then
			local frame
			if kind == "MOVER" then
				local text = section.text or name.."_MOVER"
				frame = UI.CreateMover(name, width, height, anchor, text)
			elseif kind == "RESOURCE" then
				local text = DefaultBoolean(section.text, true)
				local autohide = DefaultBoolean(section.autohide, false)
				local colors = section.colors or (section.color and {section.color})

				frame = Engine.CreateResourceMonitor(name, enable, text, autohide, anchor, width, height, colors, specs)
			elseif kind == "HEALTH" then
				local unit = section.unit or "player"
				local text = DefaultBoolean(section.text, true)
				local autohide = DefaultBoolean(section.autohide, true)
				local color = section.color

				frame = Engine.CreateHealthMonitor(name, enable, unit, text, autohide, anchor, width, height, color, specs)
			elseif kind == "ENERGIZE" then
				local spellID = section.spellID
				local filling = DefaultBoolean(section.filling, false)
				local duration = section.duration
				local color = section.color or UI.ClassColor()

				if spellID and duration then
					frame = Engine.CreateEnergizeMonitor(name, enable, spellID, anchor, width, height, color, duration, filling)
				else
					WARNING("section:"..name..":"..(spellID and "" or " missing spellID")..(duration and "" or " missing duration")) -- TODO: locales
				end
			elseif kind == "COMBO" then
				local spacing = section.spacing or 3
				local color = section.color or UI.ClassColor()
				local colors = section.colors or CreateColorArray(color, 5)
				local autohide = DefaultBoolean(section.autohide, true)

				frame = Engine.CreateComboMonitor(name, enable, autohide, anchor, width, height, spacing, colors, filled, specs)
			elseif kind == "POWER" then
				local powerType = section.powerType
				local count = section.count
				local spacing = section.spacing or 3
				local color = section.color or UI.ClassColor()
				local colors = section.colors or CreateColorArray(color, count)
				local filled = DefaultBoolean(section.filled, false)
				local autohide = DefaultBoolean(section.autohide, false)

				if powerType == SPELL_POWER_BURNING_EMBERS then
					frame = Engine.CreateBurningEmbersMonitor(name, enable, autohide, anchor, width, height, spacing, colors) -- TODO: autohide
				elseif powerType == SPELL_POWER_DEMONIC_FURY then
					local text = DefaultBoolean(section.text, true)
					frame = Engine.CreateDemonicFuryMonitor(name, enable, text, autohide, anchor, width, height, colors)
				elseif powerType and count then
					frame = Engine.CreatePowerMonitor(name, enable, autohide, powerType, count, anchor, width, height, spacing, colors, filled, specs)
				else
					WARNING("section:"..name..":"..(powerType and "" or " missing powerType")..(count and "" or " missing count")) -- TODO: locales
				end
			elseif kind == "AURA" then
				local unit = section.unit or "player"
				local spellID = section.spellID
				local filter = section.filter
				local count = section.count
				local autohide = DefaultBoolean(section.autohide, true)

				if spellID and filter and count then
					local spacing = section.spacing or 3
					local color = section.color or UI.ClassColor()
					local colors = section.colors or CreateColorArray(color, count)
					local filled = DefaultBoolean(section.filled, false)

					frame = Engine.CreateAuraMonitor(name, enable, autohide, unit, spellID, filter, count, anchor, width, height, spacing, colors, filled, specs)
				else
					WARNING("section:"..name..":"..(spellID and "" or " missing spellID")..(filter and "" or " missing filter")..(count and "" or " missing count")) -- TODO: locales
				end
			elseif kind == "AURABAR" then
				local unit = section.unit or "player"
				local spellID = section.spellID
				local filter = section.filter
				local count = section.count
				local autohide = DefaultBoolean(section.autohide, true)

				if spellID and filter and count then
					local spacing = section.spacing
					local color = section.color or UI.ClassColor()
						local text = DefaultBoolean(section.text, true)
						local duration = DefaultBoolean(section.duration, false)

					frame = Engine.CreateBarAuraMonitor(name, enable, autohide, unit, spellID, filter, count, anchor, width, height, color, text, duration, specs)
				else
					WARNING("section:"..name..":"..(spellID and "" or " missing spellID")..(filter and "" or " missing filter")..(count and "" or " missing count")) -- TODO: locales
				end
			elseif kind == "DOT" then
				local spellID = section.spellID
				local colors = section.colors or (section.color and {section.color})
				local latency = DefaultBoolean(section.latency, false)
				local threshold = section.threshold or 0
				local autohide = DefaultBoolean(section.autohide, true)

				if spellID then
					frame = Engine.CreateDotMonitor(name, enable, autohide, spellID, anchor, width, height, colors, threshold, latency, specs)
				else
					WARNING("section:"..name..":"..(spellID and "" or " missing spellID")) -- TODO: locales
				end
			elseif kind == "RUNES" then
				local updatethreshold = section.updatethreshold or 0.1
				local autohide = DefaultBoolean(section.autohide, false)
				local orientation = section.orientation or "HORIZONTAL"
				local spacing = section.spacing or 3
				local colors = section.colors
				local runemap = section.runemap

				if runemap and colors then
					frame = Engine.CreateRunesMonitor(name, enable, updatethreshold, autohide, orientation, anchor, width, height, spacing, colors, runemap)
				else
					WARNING("section:"..name..":"..(runemap and "" or " missing runemap")..(colors and "" or " missing colors")) -- TODO: locales
				end
			elseif kind == "ECLIPSE" then
				local colors = section.colors
				local text = DefaultBoolean(section.text, true)
				local autohide = DefaultBoolean(section.autohide, false)

				if colors then
					frame = Engine.CreateEclipseMonitor(name, enable, autohide, text, anchor, width, height, colors)
				else
					WARNING("section:"..name..": missing colors") -- TODO: locales
				end
			elseif kind == "TOTEM" then
				local count = section.count
				local autohide = DefaultBoolean(section.autohide, false)
				if count then
					local spacing = section.spacing or 3
					local color = section.color or UI.ClassColor()
					local colors = section.colors or CreateColorArray(color, count)
					local text = DefaultBoolean(section.text, false)
					local map = section.map
					if map and #map ~= count then
						WARNING("section:"..name..": map table's size <> count") -- TODO: locales
					else
						frame = Engine.CreateTotemMonitor(name, enable, autohide, count, anchor, width, height, spacing, colors, text, map, specs)
					end
				else
					WARNING("section:"..name..": missing count") -- TODO: locales
				end
			elseif kind == "BANDITSGUILE" then
				local spacing = section.spacing or 3
				local color = section.color or UI.ClassColor()
				local colors = section.colors or CreateColorArray(color, 3)
				local autohide = DefaultBoolean(section.autohide, true)
				local filled = DefaultBoolean(section.filled, false)

				frame = Engine.CreateBanditsGuileMonitor(name, enable, autohide, anchor, width, height, spacing, colors, filled)
			elseif kind == "STAGGER" then
				local threshold = section.threshold or 100
				local text = DefaultBoolean(section.text, true)
				local autohide = DefaultBoolean(section.autohide, true)
				local colors = section.colors

				if colors then
					frame = Engine.CreateStaggerMonitor(name, enable, threshold, text, autohide, anchor, width, height, colors)
				else
					WARNING("section:"..name..":"..(colors or " missing colors")) -- TODO: locales
				end
			else
				WARNING("section:"..name..": invalid kind:"..kind) -- TODO: locales
			end

			-- WARNING if frame not created
			if not frame then DEBUG("section:"..name.." frame not created") end-- DEBUG -- TODO: locales

			-- Add multiple anchor handler
			if anchors and frame then
				SetMultipleAnchorHandler(frame, anchors)
			end
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

		if not ClassMonitorDataPerChar then
			ClassMonitorDataPerChar = {}
		else
			-- for k, v in pairs(ClassMonitorDataPerChar) do
				-- print("SAVED VARIABLES:"..tostring(k))
				-- __dump(v)
			-- end
			MergeConfig(settings, ClassMonitorDataPerChar)
		end
		CreatePlugins()
	end
end)

---- Delete config
--wipe(Engine.Config)  needed by ClassMonitor_ConfigUI