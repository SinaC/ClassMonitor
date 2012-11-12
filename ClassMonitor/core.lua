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

-- Config management
local DeepCopy = Engine.DeepCopy
local function MergeConfig(config, saved)
	for _, config_setting in ipairs(config) do
		local savedEntry = nil
		for saved_key, saved_setting in pairs(saved) do
			if saved_key == config_setting.name then
				savedEntry = saved_setting
				break
			end
		end
		if savedEntry then
			-- overwrite value from saved to config
			for key, value in pairs(config_setting) do
				if key ~= "name" and savedEntry[key] ~= nil then
					config_setting[key] = DeepCopy(savedEntry[key])
				end
			end
			-- add new entry from saved to config
			for key, value in pairs(savedEntry) do
				if config_setting[key] == nil then
					config_setting[key] = DeepCopy(value)
				end
			end
		end
	end
	for saved_key, saved_setting in ipairs(saved) do
		local found = false
		for _, config_setting in ipairs(config) do
			if saved_key == config_setting.name then
				found = true
				break
			end
		end
		if not found then
			tinsert(config, DeepCopy(saved_setting))
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
local DefaultBoolean = Engine.DefaultBoolean
local function CreatePlugins()
	for i, setting in ipairs(settings) do
		if setting.name and setting.kind then
			if not setting.deleted then -- deleted plugin are not created, disabled plugin (enable == false) are created
				-- set common default values
				setting.enable = DefaultBoolean(setting.enable, true)
				setting.width = setting.width or 85
				setting.height = setting.height or 16
				setting.specs = setting.specs or {"any"}
				setting.autohide = DefaultBoolean(setting.autohide, true)
				-- create plugin instance
				if setting.kind == "MOVER" then
					setting.text = setting.text or setting.name.."_MOVER"
					UI.CreateMover(setting.name, setting.width, setting.height, setting.anchor, setting.text)
				else
					local instance = Engine:NewPluginInstance(setting.kind, setting.name, setting)
					instance:Initialize()
					if setting.enable == true then
						instance:Enable()
					end
				end
			end
		else
			print("Invalid plugin "..tostring(i).."  "..tostring(setting.name or "UNAMED").."  "..tostring(setting.kind or "NOKIND"))
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
	ClassMonitorDataPerChar.Global.autogridanchor = DefaultBoolean(ClassMonitorDataPerChar.Global.autogridanchor, false) -- manual anchoring by default
	-- Merge config and saved variables
	MergeConfig(settings, ClassMonitorDataPerChar.Plugins)
	-- Check multisampling
	CheckMultisampling()
	-- Clean config
	CleanConfig()
	-- Create plugins
	CreatePlugins()
	-- Set autogrid anchor if it exists
	if ClassMonitorDataPerChar.Global.autogridanchor == true and Engine.AutoGridAnchor and type(Engine.AutoGridAnchor == "function") then
		Engine.AutoGridAnchor(settings, ClassMonitorDataPerChar.Global.width, ClassMonitorDataPerChar.Global.height, 3, "anchor", "width", "height")
		--Engine.UpdateAllPlugins()
	end
	-- Build options tree if ConfigUI is loaded
	if ClassMonitor_ConfigUI and ClassMonitor_ConfigUI.BuildOptionsTree then
		ClassMonitor_ConfigUI.BuildOptionsTree(settings, ClassMonitorDataPerChar, ClassMonitorData, Engine.UpdatePluginInstance, Engine.AutoGridAnchor)
	end
end)