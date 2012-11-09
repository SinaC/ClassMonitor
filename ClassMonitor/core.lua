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

---------------------------------------
-- Main

-- Config management
local DeepCopy = Engine.DeepCopy
local function MergeConfig(config, saved)
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
					config_section[key] = DeepCopy(savedEntry[key])
				end
			end
			-- add new entry from saved to config
			for key, value in pairs(savedEntry) do
				if config_section[key] == nil then
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
			tinsert(config, DeepCopy(saved_section))
		end
	end
end

local function CleanConfig()
	-- Remove non-class specific config
	for class in pairs(C) do
		if class ~= UI.MyClass then
			C[class] = nil
		end
	end
end

-- Plugins
local CreateColorArray = Engine.CreateColorArray
local DefaultBoolean = Engine.DefaultBoolean
local function CreatePlugins()
	for i, section in ipairs(settings) do
		-- set default values
		local name = section.name -- no default
		local kind = section.kind -- no default
		local anchor = section.anchor -- no default
		section.enable = DefaultBoolean(section.enable, true) -- set default value
		section.width = section.width or 85
		section.height = section.height or 16
		section.specs = section.specs or {"any"}
		section.autohide = DefaultBoolean(section.autohide, true)

		local valid = true
		DEBUG("section:"..name)
		if name and kind and anchor then
			if kind == "MOVER" then
				section.text = section.text or name.."_MOVER"
				UI.CreateMover(name, section.width, section.height, anchor, section.text)
				valid = false -- already created
			elseif kind == "RESOURCE" then
				section.text = DefaultBoolean(section.text, true)
				section.hideifmax = DefaultBoolean(section.hideifmax, false)
				section.colors = section.colors or (section.color and {section.color})
			elseif kind == "HEALTH" then
				section.unit = section.unit or "player"
				section.text = DefaultBoolean(section.text, true)
			elseif kind == "ENERGIZE" then
				section.filling = DefaultBoolean(section.filling, false)
				section.color = section.color or UI.ClassColor()

				if not section.spellID or not section.duration then
					valid = false
					WARNING("section:"..name..":"..(section.spellID and "" or " missing spellID")..(section.duration and "" or " missing duration")) -- TODO: locales
				end
			elseif kind == "COMBO" then
				section.filled = DefaultBoolean(section.filled, false)

				if not section.colors then
					valid = false
					WARNING("section:"..name..": missing colors") -- TODO: locales
				end
			elseif kind == "POWER" then
				section.filled = DefaultBoolean(section.filled, false)

				if section.powerType and section.count then
					local color = section.color or UI.PowerColor(section.powerType) or UI.ClassColor()
					section.colors = section.colors or CreateColorArray(color, section.count)
				else
					valid = false
					WARNING("section:"..name..":"..(section.powerType and "" or " missing powerType")..(section.count and "" or " missing count")) -- TODO: locales
				end
			elseif kind == "AURA" then
				section.unit = section.unit or "player"

				if section.spellID and section.filter and section.count then
					local color = section.color or UI.ClassColor()
					section.colors = section.colors or CreateColorArray(color, section.count)
					section.filled = DefaultBoolean(section.filled, false)
				else
					valid = false
					WARNING("section:"..name..":"..(section.spellID and "" or " missing spellID")..(section.filter and "" or " missing filter")..(section.count and "" or " missing count")) -- TODO: locales
				end
			elseif kind == "AURABAR" then
				section.unit = section.unit or "player"

				if section.spellID and section.filter and section.count then
					section.color = section.color or UI.ClassColor()
					section.text = DefaultBoolean(section.text, true)
					section.duration = DefaultBoolean(section.duration, false)
				else
					valid = false
					WARNING("section:"..name..":"..(section.spellID and "" or " missing spellID")..(section.filter and "" or " missing filter")..(section.count and "" or " missing count")) -- TODO: locales
				end
			elseif kind == "DOT" then
				--section.colors = section.colors or (section.color and {section.color})
				section.colors = section.colors or { {255/255, 165/255, 0, 1}, {255/255, 255/255, 0, 1}, {127/255, 255/255, 0, 1} }
				section.latency = DefaultBoolean(section.latency, false)
				section.threshold = section.threshold or 0

				if not section.spellID then
					valid = false
					WARNING("section:"..name..":"..(section.spellID and "" or " missing spellID")) -- TODO: locales
				end
			elseif kind == "RUNES" then
				section.updatethreshold = section.updatethreshold or 0.1
				section.orientation = section.orientation or "HORIZONTAL"

				if not section.runemap or not section.colors then
					valid = false
					WARNING("section:"..name..":"..(section.runemap and "" or " missing runemap")..(section.colors and "" or " missing colors")) -- TODO: locales
				end
			elseif kind == "ECLIPSE" then
				section.text = DefaultBoolean(section.text, true)

				if not section.colors then
					valid = false
					WARNING("section:"..name..": missing colors") -- TODO: locales
				end
			elseif kind == "TOTEMS" then
				if section.count then
					local color = section.color or UI.ClassColor()
					section.colors = section.colors or CreateColorArray(color, section.count)
					section.text = DefaultBoolean(section.text, false)
					if section.map and #section.map ~= section.count then
						valid = false
						WARNING("section:"..name..": map table's size <> count") -- TODO: locales
					end
				else
					valid = false
					WARNING("section:"..name..": missing count") -- TODO: locales
				end
			elseif kind == "BANDITSGUILE" then
				section.filled = DefaultBoolean(section.filled, false)

				if not section.colors then
					valid = false
					WARNING("section:"..name..": missing count") -- TODO: locales
				end
			elseif kind == "STAGGER" then
				section.threshold = section.threshold or 100
				section.text = DefaultBoolean(section.text, true)

				if not section.colors then
					valid = false
					WARNING("section:"..name..":"..(section.colors or " missing colors")) -- TODO: locales
				end
			elseif kind == "TANKSHIELD" then
				section.color = section.color or UI.ClassColor()
				section.duration = DefaultBoolean(section.duration, false)
			elseif kind == "BURNINGEMBERS" then
				section.color = section.color or UI.PowerColor(SPELL_POWER_BURNING_EMBERS) or {222/255, 95/255,  95/255, 1}
			elseif kind == "DEMONICFURY" then
				section.color = section.color or UI.PowerColor(SPELL_POWER_DEMONIC_FURY) or {95/255, 222/255,  95/255, 1}
				section.text = DefaultBoolean(section.text, true)
			elseif kind == "CD" then
				section.color = section.color or UI.ClassColor()
				section.text = DefaultBoolean(section.text, true)
				section.duration = DefaultBoolean(section.duration, true)

				if not section.spellID then
					valid = false
					WARNING("section:"..name..": missing spellID") -- TODO: locales
				end
			elseif kind == "RECHARGE" then
				section.color = section.color or UI.ClassColor()
				section.text = DefaultBoolean(section.text, true)

				if not section.spellID then
					valid = false
					WARNING("section:"..name..": missing spellID") -- TODO: locales
				end
			elseif kind == "RECHARGEBAR" then
				section.color = section.color or UI.ClassColor()
				section.text = DefaultBoolean(section.text, true)

				if not section.spellID then
					valid = false
					WARNING("section:"..name..": missing spellID") -- TODO: locales
				end
			else
				valid = false
				WARNING("section:"..name..": invalid kind:"..kind) -- TODO: locales
			end
		else
			valid = false
			WARNING((name and "" or " missing name")..(kind and "" or " missing kind")..(anchor and "" or " missing anchor")) -- TODO: locales
		end
		-- create plugin instance
		if valid == true then
			local instance = Engine:NewPluginInstance(section.kind, section.name, section)
			instance:Initialize()
			if section.enable == true then
				instance:Enable()
			end
		end
	end
end

-- Multisampling test
StaticPopupDialogs["CLASSMONITOR_MULTISAMPLE_PROBLEM"] = {
	text = "Pixel perfect border cannot be guaranteed with multisampling activated. Click on accept to disable multisampling or cancel to continue.", -- TODO: locales
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		SetCVar("gxMultisample", 1)
		RestartGx()
	end,
	OnCancel = function()
		ClassMonitorData.MultisamplingChecked = true
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
}
local function CheckMultisampling()
	if GetCVar("gxMultisample") ~= "1" and not ClassMonitorData.MultisamplingChecked then
		StaticPopup_Show("CLASSMONITOR_MULTISAMPLE_PROBLEM")
	end
end

-- Main frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
	if addon ~= ADDON_NAME then return end
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
	--
	ClassMonitorData = ClassMonitorData or {}
	ClassMonitorDataPerChar = ClassMonitorDataPerChar or {}
	if not ClassMonitorDataPerChar.Plugins then
		-- create plugins settings from basic config if not found
		ClassMonitorDataPerChar.Plugins = {}
		for k, v in pairs(ClassMonitorDataPerChar) do
			if k ~= "Global" and k ~= "Plugins" then
				ClassMonitorDataPerChar.Plugins[k] = DeepCopy(ClassMonitorDataPerChar[k]) -- copy setting
				ClassMonitorDataPerChar[k] = nil -- delete old setting
			end
		end
	end
	ClassMonitorDataPerChar.Global = ClassMonitorDataPerChar.Global or {}
	ClassMonitorDataPerChar.Global.width = ClassMonitorDataPerChar.Global.width or 262
	ClassMonitorDataPerChar.Global.height = ClassMonitorDataPerChar.Global.height or 16
	ClassMonitorDataPerChar.Global.version = tostring(version)
	ClassMonitorDataPerChar.Global.configVersion = tostring(configVersion)
	-- Merge config and saved variables
	MergeConfig(settings, ClassMonitorDataPerChar.Plugins)
	-- Check multisampling
	CheckMultisampling()
	-- Clean config
	CleanConfig()
	-- Create plugins
	CreatePlugins()
	-- Build options tree
	if ClassMonitor_ConfigUI and ClassMonitor_ConfigUI.BuildOptionsTree then
		ClassMonitor_ConfigUI.BuildOptionsTree(settings, ClassMonitorDataPerChar, ClassMonitorData, Engine.UpdatePluginInstance)
	end
end)