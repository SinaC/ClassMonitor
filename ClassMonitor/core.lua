local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

local UI = Engine.UI
local L = Engine.Locales
local C = Engine.Config

local CMDebug = false

local settings = C[UI.MyClass]
if not settings then return end

local DefaultBoolean = Engine.DefaultBoolean
local DeepCopy = Engine.DeepCopy

local function WARNING(line)
	print("|CFFFF0000ClassMonitor|r: WARNING - "..line)
end

local function DEBUG(line)
	if not CMDebug or CMDebug == false then return end
	print("|CFF0000FFClassMonitor|r: DEBUG - "..line)
end

-- Config management
local function MergeConfig(config, saved)
	for _, config_setting in pairs(config) do
		local savedEntry = nil
		for saved_key, saved_setting in pairs(saved) do
			if saved_key == config_setting.name then
				savedEntry = saved_setting
				break
			end
		end
		if savedEntry then
			if savedEntry.deleted == true then
				config_setting.deleted = true -- set to deleted
			else
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
	end
	for saved_key, saved_setting in pairs(saved) do
		if saved_setting.deleted ~= true then
			local found = false
			for _, config_setting in pairs(config) do
				if saved_key == config_setting.name then
--print("FOUND:"..tostring(saved_key))
					found = true
					break
				end
			end
			if not found then
--print("NOT FOUND:"..tostring(saved_key).."  "..tostring(saved_setting.kind).."  "..tostring(saved_setting.name))
				if saved_setting.kind and saved_setting.name then
					tinsert(config, DeepCopy(saved_setting))
				-- else: entry probably added in profiles.lua, modified in config and not found anymore in profiles.lua
				end
			end
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
	-- Delete deleted
	for i, setting in pairs(settings) do
		if setting.deleted == true then
			settings[i] = nil
		end
	end
end

-- Plugins
local function CreatePlugins() -- Plugins must be created on PLAYER_LOGIN to allow external addon to add own plugins and plugins to use PLAYER_ENTERING_WORLD
	-- TODO: I'm ashamed of following code but I don't have time (and too lazy for the moment) to code a better cycle-detection/handling
	local setDummyAnchor = false
	while true do
		local created = 0
		local anchorNotFound = 0
		for i, setting in pairs(settings) do
			if setting.kind ~= "MOVER" and setting.processed ~= true then
				if _G[setting.anchor[2]] or setDummyAnchor then
--print("CREATE PLUGIN:"..tostring(i).."  "..tostring(setting.name).."  "..tostring(setting.kind).."  "..tostring(setDummyAnchor))
					-- anchor frame found, create plugin
					if setting.name and setting.kind then
						if not setting.deleted then -- deleted plugin are not created, disabled plugin (enable == false) are created
							if setDummyAnchor then
								setting.anchor = {"CENTER", "CM_MOVER", "CENTER", 0, 0}
								if ClassMonitorDataPerChar.Global.autogridanchor ~= true then
									-- No need to warn about wrong anchors when mode autogrid is set
									WARNING("Invalid anchor for plugin instance '"..(setting.displayName or setting.name).."'. Setting anchor to center of screen")
								end
								setDummyAnchor = false -- retry other plugin now that we have split a cycle
							end
							-- set common default values
							setting.enable = DefaultBoolean(setting.enable, true)
							setting.width = setting.width or 85
							setting.height = setting.height or 16
							setting.specs = setting.specs or {"any"}
							setting.autohide = DefaultBoolean(setting.autohide, true)
							-- create plugin instance
							local instance = Engine:CreatePluginInstance(setting.kind, setting.name, setting)
							if not instance then
								WARNING("Found saved plugin instance '"..(setting.displayName or setting.name).."' of unknown kind '"..tostring(setting.kind).."'")
								setting.invalid = true -- instance not created, invalidate config entry
							end
						end
					else
						setting.invalid = true -- instance not created, invalidate config entry
						WARNING("Invalid plugin "..tostring(i).."  "..tostring(setting.name or "UNAMED").."  "..tostring(setting.kind or "NOKIND"))
					end
					setting.processed = true
					created = created + 1
				else
					anchorNotFound = anchorNotFound + 1
--print("ANCHOR NOT FOUND:"..tostring(setting.name).."  "..tostring(setting.anchor[2]))
				end
			end
		end
--print("LOOP:"..tostring(created).."  "..tostring(anchorNotFound))
		if 0 == created then
			if 0 == anchorNotFound then
				break
			else
				if setDummyAnchor then
					break -- SHOULD NEVER HAPPEN
				end
				-- every setting not processed has invalid anchor
				setDummyAnchor = true
			end
		end
	end
	-- for i, setting in pairs(settings) do
-- --print("CREATE PLUGIN:"..tostring(i).."  "..tostring(setting.name).."  "..tostring(setting.kind))
		-- if setting.name and setting.kind then
			-- if not setting.deleted then -- deleted plugin are not created, disabled plugin (enable == false) are created
				-- -- set common default values
				-- setting.enable = DefaultBoolean(setting.enable, true)
				-- setting.width = setting.width or 85
				-- setting.height = setting.height or 16
				-- setting.specs = setting.specs or {"any"}
				-- setting.autohide = DefaultBoolean(setting.autohide, true)
				-- -- create plugin instance
				-- if setting.kind ~= "MOVER" then
					-- -- check anchor-dependency
					-- local anchorFrame = _G[setting.anchor[2]]
					-- local instance = Engine:CreatePluginInstance(setting.kind, setting.name, setting)
					-- if not instance then
						-- WARNING("Found saved plugin instance '"..(setting.displayName or setting.name).."' of unknown kind '"..tostring(setting.kind).."'")
						-- setting.invalid = true -- instance not created, invalidate config entry
					-- end
				-- end
			-- end
		-- else
			-- WARNING("Invalid plugin "..tostring(i).."  "..tostring(setting.name or "UNAMED").."  "..tostring(setting.kind or "NOKIND"))
		-- end
	-- end
end

-- Movers
local function CreateMovers() -- Movers must be created on ADDON_LOADED to use auto-saved anchors
	for i, setting in pairs(settings) do
--print("CREATE PLUGIN:"..tostring(i).."  "..tostring(setting.name).."  "..tostring(setting.kind))
		if setting.name and setting.kind then
			if not setting.deleted then -- deleted plugin are not created, disabled plugin (enable == false) are created
				-- create plugin instance
				if setting.kind == "MOVER" then
					UI.CreateMover(setting.name, setting.width, setting.height, setting.anchor, setting.text or setting.name.."_MOVER")
				end
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
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, addon)
	if event == "PLAYER_LOGIN" then
		self:UnregisterEvent("PLAYER_LOGIN")

		-- Create plugins
		CreatePlugins()
		-- Set autogrid anchor if it exists
		if ClassMonitorDataPerChar.Global.autogridanchor == true and Engine.AutoGridAnchor and type(Engine.AutoGridAnchor) == "function" then
			Engine:AutoGridAnchor(settings, ClassMonitorDataPerChar.Global.width, ClassMonitorDataPerChar.Global.height, ClassMonitorDataPerChar.Global.autogridanchorspacing)
		end
		-- Build options tree if ConfigUI is loaded
		if ClassMonitor_ConfigUI and ClassMonitor_ConfigUI.InitializeConfigUI and type(ClassMonitor_ConfigUI.InitializeConfigUI) == "function" then
			ClassMonitor_ConfigUI.InitializeConfigUI(settings, ClassMonitorDataPerChar, ClassMonitorData, Engine.UpdatePluginInstance, Engine.CreatePluginInstance, Engine.DeletePluginInstance, Engine.AutoGridAnchor, Engine.GetPluginList)
		end
	elseif event == "ADDON_LOADED" and addon == ADDON_NAME then
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
			-- create plugins settings from basic config if not found (old version of saved variables)
			ClassMonitorDataPerChar.Plugins = {}
			for k, v in pairs(ClassMonitorDataPerChar) do
				if k ~= "Global" and k ~= "Plugins" then
					ClassMonitorDataPerChar.Plugins[k] = DeepCopy(ClassMonitorDataPerChar[k]) -- copy setting
					ClassMonitorDataPerChar[k] = nil -- delete old setting
				end
			end
		end
		-- Default global per char variables
		ClassMonitorDataPerChar.Global = ClassMonitorDataPerChar.Global or {}
		ClassMonitorDataPerChar.Global.version = tostring(version)
		ClassMonitorDataPerChar.Global.configVersion = tostring(configVersion)
		ClassMonitorDataPerChar.Global.debug = DefaultBoolean(ClassMonitorDataPerChar.Global.debug, false)
		ClassMonitorDataPerChar.Global.width = ClassMonitorDataPerChar.Global.width or 262
		ClassMonitorDataPerChar.Global.height = ClassMonitorDataPerChar.Global.height or 16
		ClassMonitorDataPerChar.Global.autogridanchor = DefaultBoolean(ClassMonitorDataPerChar.Global.autogridanchor, false) -- manual anchoring by default
		ClassMonitorDataPerChar.Global.autogridanchorspacing = ClassMonitorDataPerChar.Global.autogridanchorspacing or 3
		-- Merge config and saved variables
		MergeConfig(settings, ClassMonitorDataPerChar.Plugins)
		-- Check multisampling
		CheckMultisampling()
		-- Clean config
		CleanConfig()
		-- Create movers
		CreateMovers()
	end
end)