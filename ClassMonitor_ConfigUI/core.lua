local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local G = Engine.Globals

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")

assert(AC, "AceConfig-3.0 library not found")
assert(ACD, "AceConfigDialog-3.0 library not found")
assert(ACR, "AceConfigRegistry-3.0 library not found")

----------------------------------------------------------------------------------------
StaticPopupDialogs["CLASSMONITOR_CONFIG_RL"] = {
	text = L.CLASSMONITOR_CONFIG_RL,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
}

----------------------------------------------------------------------------------------
local function HookAce3OnHide(ACD, addonName)
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
local function BuildAce3Options()
	local options = {
		type = "group",
		--childGroups = "tree", -- default
		--childGroups = "select",
		--childGroups = "tab",
		name = "Class Monitor",
		args = {
		},
	}
	-- local generalOptions = {
		-- order = 0,
		-- type = "group",
		-- guiInline = true,
		-- name = "General Options",
		-- args = {
			-- globalWidth = D.Helpers.CreateGlobalWidthOption(1),
			-- globalHeight = D.Helpers.CreateGlobalHeightOption(2),
			-- reset = D.Helpers.CreateResetOption(3)
		-- }
	-- }
	-- options.args["general"] = generalOptions
	-- Add global width option
	options.args["GlobalWidth"] = D.Helpers.CreateGlobalWidthOption(1) -- index 1
	-- Add global width option
	options.args["GlobalHeight"] = D.Helpers.CreateGlobalHeightOption(2) -- index 2
	-- Add reset option
	options.args["Reset"] = D.Helpers.CreateResetOption(3) -- index 3
	-- Add options for every section in config
	-- options.args["plugins"] = {
		-- order = 1,
		-- type = "group",
		-- childGroups = "tab",
		-- name = "Plugins",
		-- args = {
		-- }
	-- }
	for i, section in ipairs(G.Config) do
		if section.kind ~= "MOVER" then -- can't configure MOVER
			local definition = D[section.kind] or D.DefaultPluginDefinition
			-- create new entry
			options.args[section.name] = D.Helpers.CreateOptionsFromDefinitions(definition, i+3, section)
			-- options.args["plugins"].args[section.name] = D.Helpers.CreateOptionsFromDefinitions(definition, i, section)
		end
	end
--[[
	local options = {
		name = "ClassMonitor",
		type = "group",
		args = {
			GeneralOptions = {
				type = "group",
				--childGroups = 'tab',
				inline = true,
				name = "General Options",
				args = {
					["GlobalWidth"] = D.Helpers.CreateGlobalWidthOption(1),
					["GlobalHeight"] = D.Helpers.CreateGlobalHeightOption(2),
					["Reset"] = D.Helpers.CreateResetOption(3)
				},
			},
			-- plugins are added in next loop
		}
	}

	for i, section in ipairs(G.Config) do
		if section.kind ~= "MOVER" then -- can't configure MOVER
			local definition = D[section.kind] or D.DefaultPluginDefinition
			-- create new entry
			options.args[section.name] = D.Helpers.CreateOptionsFromDefinitions(definition, i, section)
		end
	end
--]]
	return options
end

if ElvUI then
	local E, _, _, _, _, _ = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

	--
	Engine.BuildOptionsTree = function(config, savedPerChar, savedPerAccount, updatePluginFunction)
		-- Set globals
		G.Config = config
		G.SavedPerChar = savedPerChar
		G.SavedPerAccount = savedPerAccount
		G.PluginUpdateFunction = updatePluginFunction
		--
		E.Options.args.ClassMonitor = BuildAce3Options()
		HookAce3OnHide(ACD, "ElvUI")
	end
	--
	Engine.DisplayConfigFrame = function()
		--
		G.ConfigModified = false
		--
		E:ToggleConfig()
		ACD:SelectGroup("ElvUI", "ClassMonitor") -- try to select classmonitor node
	end
elseif Tukui then
	local blizOptions = nil

	Engine.BuildOptionsTree = function(config, savedPerChar, savedPerAccount, updatePluginFunction)
		-- Set globals
		G.Config = config
		G.SavedPerChar = savedPerChar
		G.SavedPerAccount = savedPerAccount
		G.PluginUpdateFunction = updatePluginFunction
		--[[
		--
		local options = {
			type = "group",
			args = {
				GeneralOptions = {
					type = "group",
					childGroups = 'tab',
					inline = true,
					name = "Class Monitor",
					args = {
						["GlobalWidth"] = D.Helpers.CreateGlobalWidthOption(1),
						["GlobalHeight"] = D.Helpers.CreateGlobalHeightOption(2),
						["Reset"] = D.Helpers.CreateResetOption(3)
					},
				},
				-- plugins are added in next loop
			}
		}

		-- add to AceConfig and blizzard menu
		--                       addon name
		ACR:RegisterOptionsTable("ClassMonitor", options)
		--                                 addon name       display name
		blizOptions = ACD:AddToBlizOptions("ClassMonitor", "Class Monitor", nil, "GeneralOptions") -- save blizzard options entry point to be used in DisplayConfigFrame

		for i, section in ipairs(G.Config) do
			if section.kind ~= "MOVER" then -- can't configure MOVER
				local definition = D[section.kind] or D.DefaultPluginDefinition
				-- create new entry
				options.args[section.name] = D.Helpers.CreateOptionsFromDefinitions(definition, i, section)
				--                                 addon name                                            parent display name
				ACD:AddToBlizOptions("ClassMonitor", section.displayName or section.name, "Class Monitor", section.name)
			end
		end
		--]]
		--[[
print("NEW CONFIG")
		-- create options
		local options = BuildAce3Options()
		-- add to AceConfig and blizzard menu
		--                       addon name
		ACR:RegisterOptionsTable("ClassMonitor", options)
		--                                 addon name       display name         path
		blizOptions = ACD:AddToBlizOptions("ClassMonitor", "Class Monitor", nil, "GeneralOptions") -- save blizzard options entry point to be used in DisplayConfigFrame
		for k, v in pairs(options.args) do
print("SUB MENU:"..tostring(k))
			if k ~= "GeneralOptions" then
				-- add to blizzard menu
				--                                 addon name                                            parent display name | path
				ACD:AddToBlizOptions("ClassMonitor", v.displayName or v.name, "Class Monitor", v.name)
			end
		end
		--]]
		local options = BuildAce3Options()
		AC:RegisterOptionsTable("ClassMonitor", options)
	end
	--
	Engine.DisplayConfigFrame = function()
		--
		G.ConfigModified = false
		--
		--InterfaceOptionsFrame_OpenToCategory(blizOptions)
		ACD:SetDefaultSize("ClassMonitor", 640, 480)
		ACD:Open("ClassMonitor")
		HookAce3OnHide(ACD, "ClassMonitor")
	end
else
	Engine.BuildOptionsTree = function(config, savedPerChar, savedPerAccount, updatePluginFunction)
		-- Set globals
		G.Config = config
		G.SavedPerChar = savedPerChar
		G.SavedPerAccount = savedPerAccount
		G.PluginUpdateFunction = updatePluginFunction
		--
		local options = BuildAce3Options()
		AC:RegisterOptionsTable("ClassMonitor", options)
	end
	--
	Engine.DisplayConfigFrame = function()
		--
		G.ConfigModified = false
		--
		ACD:SetDefaultSize("ClassMonitor", 640, 480)
		ACD:Open("ClassMonitor")
		HookAce3OnHide(ACD, "ClassMonitor")
	end
end

--print("Exposing ClassMonitor_DisplayConfigFrame..."..tostring(Engine.BuildOptionsTree).."  "..tostring(Engine.BuildOptionsTree))
ClassMonitor_ConfigUI.BuildOptionsTree = Engine.BuildOptionsTree
ClassMonitor_ConfigUI.DisplayConfigPanel = Engine.DisplayConfigFrame