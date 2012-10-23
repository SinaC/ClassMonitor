local ADDON_NAME, Engine = ...

local L = Engine.Locales
local H = Engine.Helpers
local D = Engine.Definitions

local function BuildAce3Options(config, saved)
--print("BuildAce3Options:"..tostring(config).."  "..tostring(saved))
	local options = {
		type = "group",
		name = "Class Monitor",
		args = {
		},
	}
	for i, section in ipairs(config) do
		if section.kind ~= "MOVER" then -- can't configure MOVER
			local definition = D[section.kind] or D.DefaultPluginDefinition
			-- create new entry
			options.args[section.name] = D.Helpers.CreateOptionsFromDefinitions(definition, i, section.name, config, saved)
		end
	end
	return options
end

if ElvUI then
	local E, _, V, P, G, _ = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

	if not V["classmonitor"] then
		V["classmonitor"] = {
			-- TODO: default values
		}
	end

	--
	Engine.DisplayConfigFrame = function(UIComponents, config, saved)
		local options = BuildAce3Options(config, saved)
		--tinsert(E.Options.args, options) -- insert options in ElvUI config panel
		E.Options.args.classmonitor = options -- insert options in ElvUI config panel
		E:ToggleConfig()

		local ACD = LibStub("AceConfigDialog-3.0")
		ACD:SelectGroup("ElvUI", "classmonitor") -- try to select classmonitor node
	end
elseif Tukui then
	local AC = LibStub("AceConfig-3.0")
	local ACD = LibStub("AceConfigDialog-3.0")
	--
	Engine.DisplayConfigFrame = function(UIComponents, config, saved)
		local options = BuildAce3Options(config, saved)
		AC:RegisterOptionsTable(ADDON_NAME, options)
		ACD:SetDefaultSize(ADDON_NAME, 890, 651)
		ACD:Open(ADDON_NAME)
	end
else
	local AC = LibStub("AceConfig-3.0")
	local ACD = LibStub("AceConfigDialog-3.0")
	--
	Engine.DisplayConfigFrame = function(UIComponents, config, saved)
		local options = BuildAce3Options(config, saved)
		AC:RegisterOptionsTable(ADDON_NAME, options)
		ACD:SetDefaultSize(ADDON_NAME, 890, 651)
		ACD:Open(ADDON_NAME)
	end
end

--print("Exposing ClassMonitor_DisplayConfigFrame..."..tostring(Engine.DisplayConfigFrame))
ClassMonitor_DisplayConfigFrame = Engine.DisplayConfigFrame -- Expose config frame