local ADDON_NAME, Engine = ...

local L = Engine.Locales
local H = Engine.Helpers
local D = Engine.Definitions
local G = Engine.Globals

local addonName = ADDON_NAME

----------------------------------------------------------------------------------------
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
local function HookAce3OnHide(ACD)
	-- if ACD.OpenFrames[ADDON_NAME].events["OnClose"] == HookAce3OnHide then return end
-- print("HOOKING:"..tostring(ADDON_NAME).."  "..tostring(ACD.OpenFrames[ADDON_NAME]))
	-- -- save original OnClose callback
	-- ACD.OpenFrames[ADDON_NAME].savedOnCloseCallback = ACD.OpenFrames[ADDON_NAME].events["OnClose"]
	-- -- set own OnClose callback
	-- ACD.OpenFrames[ADDON_NAME]:SetCallback("OnClose", function(widget, event)
		-- if widget.savedOnCloseCallback then widget.savedOnCloseCallback(widget, event) end
-- print("ONCLOSE:"..tostring(widget).." "..tostring(event).."  "..tostring(G.ConfigModified))
		-- if G.ConfigModified == true then
			-- StaticPopup_Show("CLASSMONITOR_CONFIG_RL")
			-- G.ConfigModified = false
		-- end
	-- end)
	--[[
	if ACD.OpenFrames[ADDON_NAME].frame.ClassMonitor_ConfigUI_Hooked then return end
--print("HookAce3OnHide:"..tostring(ACD.OpenFrames[ADDON_NAME].frame))
	ACD.OpenFrames[ADDON_NAME].frame.ClassMonitor_ConfigUI_Hooked = true
	ACD.OpenFrames[ADDON_NAME].frame:HookScript("OnHide", function(self)
--print("OnHide:"..tostring(self).."  "..tostring(G.ConfigModified))
		if G.ConfigModified == true then
			StaticPopup_Show("CLASSMONITOR_CONFIG_RL")
			G.ConfigModified = false
		end
	end)
	--]]
	if not ACD.OpenFrames[addonName] or not ACD.OpenFrames[addonName].frame then return end
	if ACD.OpenFrames[addonName].frame.ClassMonitor_ConfigUI_Hooked then return end
--print("HookAce3OnHide:"..tostring(ACD.OpenFrames[ADDON_NAME].frame))
	ACD.OpenFrames[addonName].frame.ClassMonitor_ConfigUI_Hooked = true
	ACD.OpenFrames[addonName].frame:HookScript("OnHide", function(self)
--print("OnHide:"..tostring(self).."  "..tostring(G.ConfigModified))
		if G.ConfigModified == true then
			StaticPopup_Show("CLASSMONITOR_CONFIG_RL")
			G.ConfigModified = false
		end
	end)
end
----------------------------------------------------------------------------------------
local function BuildAce3Options(config, saved)
--print("BuildAce3Options:"..tostring(config).."  "..tostring(saved))
	local options = {
		type = "group",
		--guiInline = true,
		name = "Class Monitor",
		args = {
		},
	}
	-- Add global width option
	options.args["GlobalWidth"] = D.Helpers.CreateGlobalWidthOption(config, saved) -- index 1
	-- Add global width option
	options.args["GlobalHeight"] = D.Helpers.CreateGlobalHeightOption(config, saved) -- index 1
	-- Add options for every section in config
	for i, section in ipairs(config) do
		if section.kind ~= "MOVER" then -- can't configure MOVER
			local definition = D[section.kind] or D.DefaultPluginDefinition
			-- create new entry
			options.args[section.name] = D.Helpers.CreateOptionsFromDefinitions(definition, 2+i, section.name, config, saved)
		end
	end
	return options
end

if ElvUI then
	local E, _, _, _, _, _ = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

	--
	Engine.DisplayConfigFrame = function(UIComponents, config, saved)
		G.ConfigModified = false
		local options = BuildAce3Options(config, saved)
		--tinsert(E.Options.args, options) -- insert options in ElvUI config panel
		E.Options.args.classmonitor = options -- insert options in ElvUI config panel
		E:ToggleConfig()

		addonName = "ElvUI"
		local ACD = LibStub("AceConfigDialog-3.0")
		ACD:SelectGroup("ElvUI", "classmonitor") -- try to select classmonitor node
		HookAce3OnHide(ACD)
	end
elseif Tukui then
	local AC = LibStub("AceConfig-3.0")
	local ACD = LibStub("AceConfigDialog-3.0")
	--
	Engine.DisplayConfigFrame = function(UIComponents, config, saved)
		G.ConfigModified = false
		local options = BuildAce3Options(config, saved)
		AC:RegisterOptionsTable(ADDON_NAME, options)
		ACD:SetDefaultSize(ADDON_NAME, 640, 480)
		ACD:Open(ADDON_NAME)
		HookAce3OnHide(ACD)
	end
else
	local AC = LibStub("AceConfig-3.0")
	local ACD = LibStub("AceConfigDialog-3.0")
	--
	Engine.DisplayConfigFrame = function(UIComponents, config, saved)
		G.ConfigModified = false
		local options = BuildAce3Options(config, saved)
		AC:RegisterOptionsTable(ADDON_NAME, options)
		ACD:SetDefaultSize(ADDON_NAME, 640, 480)
		ACD:Open(ADDON_NAME)
		HookAce3OnHide(ACD)
	end
end

--print("Exposing ClassMonitor_DisplayConfigFrame..."..tostring(Engine.DisplayConfigFrame))
ClassMonitor_DisplayConfigFrame = Engine.DisplayConfigFrame -- Expose config frame