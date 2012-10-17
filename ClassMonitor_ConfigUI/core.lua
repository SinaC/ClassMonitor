--[[

				 ----------------------------
	[Class     ]|Name+kind	enable	edit del| Name
				|Name+kind	enable	edit del| Kind
				|							| Anchor
				|							| params
				|							| ...
				 ---------------------------
				ADD				RESET	APPLY
	EditFrame
	 ------------------------------
	|Name		readonly
	|Kind		readonly
	[Enable		checkbox
	|Anchor		readonly
	|Autohide	checkbox
	|Width		slider
	|Height		slider
	|Specs		multichekboxes
	| plugin dependant
--]]

local _, Engine = ...

local L = Engine.Locales
local H = Engine.Helpers
local D = Engine.Definitions

local ClassMonitor = nil -- will be assigned later
local UI = nil -- will be assigned later

local WorkingConfig = nil -- we work on these variables and copy into saved variables when clicking on apply
local WorkingSaved = nil
local ClassMonitorConfig = nil -- points to ClassMonitor config (set by DisplayConfigFrame)

local ModificationFound = false -- true if modification has been done to current config

local ConfigFrame -- main config frame
local EditFrame -- edit config frame

local function CopyConfigAndVariables() -- copy original values to working ones
	if ClassMonitorConfig then WorkingConfig = H:DeepCopy(ClassMonitorConfig) end
	if ClassMonitorDataPerChar then WorkingSaved = H:DeepCopy(ClassMonitorDataPerChar) end
	ModificationFound = false
end

local function SaveVariables() -- save working values to original ones
	ClassMonitorDataPerChar = H:DeepCopy(WorkingSaved)
end


local function DefaultBoolean(value, default)
	if value == nil then
		return default
	else
		return value
	end
end

local function MyGetValue(option, config)
	local value = config[option.key]
	if value == nil and not option.optional then
		value = option.default
	end
--print("MyGetValue:"..tostring(option.key).."  "..tostring(config[option.key]).."  "..tostring(option.default).."  "..tostring(value))
	return value
end

local function GetConfigFrameCheckboxIndex(sectionName, name)
	for k, v in ipairs(WorkingConfig) do
--print("k:"..tostring(k).."  v.key:"..tostring(v.name).."  sectionName:"..tostring(sectionName))
		if v.name == sectionName then
			return k
		end
	end
	return 0
end

local function MySetValue(value, option, config)
--print("MySetValue:"..tostring(option.name).."  "..tostring(option.key).."  "..tostring(config[option.key]).." => "..tostring(value))
	local sectionName = config.name
	WorkingSaved[sectionName] = WorkingSaved[sectionName] or {}
	WorkingSaved[sectionName][option.key] = value
	config[option.key] = value
	ModificationFound = true
	if option.key == "enable" then
		local i = GetConfigFrameCheckboxIndex(sectionName)
		local checkbox = _G["ClassMonitorPlugins_"..i.."_"..sectionName.."_EnableCheckbox"]
		if checkbox then
			checkbox:SetChecked(value)
		end
	elseif option.key == "autohide" then
		local i = GetConfigFrameCheckboxIndex(sectionName)
		local checkbox = _G["ClassMonitorPlugins_"..i.."_"..sectionName.."_AutohideCheckbox"]
		if checkbox then
			checkbox:SetChecked(value)
		end
	end
end

local function GetDefinitionEntry(definition, keyValue) -- search a definition entry with key == keyValue
	for index, section in pairs(definition) do
		if section["key"] == keyValue then
			return section
		end
	end
	return nil
end

-- local function SetValue(sectionName, key, value)
-- --print("SetValue:["..tostring(sectionName).."]."..tostring(key).."="..tostring(value))
	-- WorkingSaved[sectionName] = WorkingSaved[sectionName] or {}
	-- WorkingSaved[sectionName][key] = value

	-- ModificationFound = true
-- end

local function MyCheckboxHandler(self)
	local checked = self:GetChecked() and true or false
	MySetValue(checked, self.option, self.config)
end

-- local function EnableCheckboxHandler(self)
	-- local checked = self:GetChecked() and true or false
	-- local pluginConfig = WorkingConfig[self.index]
	-- -- pluginConfig.enable = checked
	-- --SetValue(pluginConfig.name, "enable",checked)
	-- MySetValue(checked, self.option, pluginConfig)
-- --print("EnableCheckboxHandler:"..tostring(pluginConfig.name).." -> "..tostring(pluginConfig.enable))
-- end

-- local function AutohideCheckboxHandler(self)
	-- local checked = self:GetChecked() and true or false
	-- local pluginConfig = WorkingConfig[self.index]
	-- -- pluginConfig.autohide = checked
	-- --SetValue(pluginConfig.name, "autohide", checked)
	-- MySetValue(checked, self.option, pluginConfig)
-- --print("AutohideCheckboxHandler:"..tostring(pluginConfig.name).." -> "..tostring(pluginConfig.autohide))
-- end

local RefreshConfigFrame -- forward declaration

local function Reset() -- Reset 'Yes' option
	CopyConfigAndVariables() -- revert to original values
	RefreshConfigFrame() -- refresh panel
	if EditFrame then
		EditFrame:Hide()
	end
end

local function Apply() -- Apply 'Yes' option 
	SaveVariables() -- save
	ReloadUI() -- reloadui
end

local function Close() -- Close 'Yes' option
	CopyConfigAndVariables() -- revert to original values
	ConfigFrame:Hide() -- close panel
end

local function CloseButtonHandler(self)
--print("CLOSE")
	if ModificationFound then
		StaticPopup_Show("CLASSMONITOR_CLOSE")
	else
		Close()
	end
end

local function ResetButtonHandler(self)
--print("RESET")
	if ModificationFound then
		StaticPopup_Show("CLASSMONITOR_RESET")
	end
end

local function ApplyButtonHandler(self)
--print("APPLY")
	if ModificationFound then
		StaticPopup_Show("CLASSMONITOR_APPLY")
	end
end

local function AddButtonHandler(self)
--print("ADD")
	StaticPopup_Show("CLASSMONITOR_NOTYETIMPLENTED")
	-- TODO
end

local function DelButtonHandler(self)
	local pluginConfig = WorkingConfig[self.index]
--print("DEL:"..tostring(pluginConfig.name))
	StaticPopup_Show("CLASSMONITOR_NOTYETIMPLENTED")
	-- TODO
end

local function EditButtonHandler(self)
	local pluginConfig = WorkingConfig[self.index]
--print("EDIT:"..tostring(pluginConfig.name))
	--StaticPopup_Show("CLASSMONITOR_NOTYETIMPLENTED")

	local definition = D[pluginConfig.kind] or D.DefaultPluginDefinition
	if EditFrame then
		EditFrame:Hide() -- hide previous edit frame
	end
	EditFrame = H:CreateOptionPanel(ConfigFrame, "ClassMonitorEditFrame"..self.index, definition, pluginConfig, 10, MyGetValue, MySetValue)
	EditFrame:SetTemplate("Transparent")
	EditFrame:SetFrameStrata("DIALOG")
	EditFrame:Width(400)
	EditFrame:ClearAllPoints()
	EditFrame:Point("TOPLEFT", ConfigFrame, "TOPRIGHT", 2, 0)
	EditFrame:Show()
end

RefreshConfigFrame = function()
	ConfigFrame = _G["ClassMonitorConfigFrame"]
	if not ConfigFrame then
		ConfigFrame = CreateFrame("Frame", "ClassMonitorConfigFrame", UI.PetBattleHider)
		ConfigFrame:SetTemplate("Transparent")
		ConfigFrame:SetFrameStrata("DIALOG")
		ConfigFrame:Size(520, 400)
		ConfigFrame:Point("CENTER", UIParent, "CENTER", 0, 0)
		ConfigFrame:EnableMouse(true)
		ConfigFrame:SetMovable(true)
		ConfigFrame:RegisterForDrag("LeftButton")
		ConfigFrame:SetScript("OnDragStart", function(self) self:SetUserPlaced(true) self:StartMoving() end)
		ConfigFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		ConfigFrame:Hide() -- starts hidden
		-- title
		ConfigFrame.title = ConfigFrame:CreateFontString(nil, "OVERLAY")
		ConfigFrame.title:Point("TOP", ConfigFrame, 0, -10)
		ConfigFrame.title:SetFont(UI.Font, 14)
		ConfigFrame.title:SetText("|cFF148587Class|r Monitor Configuration") -- TODO: locales
		-- close button
		local CloseButton = CreateFrame("Button", "ClassMonitorConfigFrameCloseButton", ConfigFrame, "UIPanelCloseButton")
		CloseButton:Point("TOPRIGHT", ConfigFrame, "TOPRIGHT")
		--CloseButton:SkinCloseButton()
		UI.SkinCloseButton(CloseButton)
		CloseButton:SetScript("OnClick", CloseButtonHandler)
	end
	-- scroll area
	local ConfigScrollArea = _G["ClassMonitorConfigScrollArea"]
	if not ConfigScrollArea then
		ConfigScrollArea = CreateFrame("ScrollFrame", "ClassMonitorConfigScrollArea", ConfigFrame, "UIPanelScrollFrameTemplate")
		UI.SkinScrollBar(_G[ConfigScrollArea:GetName().."ScrollBar"]) -- Grrrrrrr
	end
	ConfigScrollArea:ClearAllPoints()
	ConfigScrollArea:Point("TOPLEFT", ConfigFrame, "TOPLEFT", 8, -30)
	ConfigScrollArea:Point("BOTTOMRIGHT", ConfigFrame, "BOTTOMRIGHT", -30, 8)
	--_G[ConfigScrollArea:GetName().."ScrollBar"]:SkinScrollBar() -- Grrrrrrrrr
	ConfigScrollArea:Hide()

	-- list of plugins
	local PluginsFrame = _G["ClassMonitorPluginsFrame"]
	if not PluginsFrame then
		PluginsFrame = CreateFrame("Frame", "ClassMonitorPluginsFrame", ConfigFrame)
	end
	PluginsFrame:ClearAllPoints()
	PluginsFrame:Point("TOPLEFT", ConfigFrame, "TOPLEFT", 10, 40)
	PluginsFrame:Show()
	offset = 0
	for i, section in ipairs(WorkingConfig) do
		if section.kind ~= "MOVER" then
			local definition = D[section.kind] or D.DefaultPluginDefinition
--print("Section:"..tostring(i).."  "..tostring(section.name).."  "..tostring(section.enable).."  "..tostring(section.autohide).."  "..tostring(definition).."  "..tostring(definition and definition.default or ""))
			-- -- name: label
			-- local nameLabel = H:CreateLabel(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_NameLabel", section.name, 100, 20)
			-- nameLabel:ClearAllPoints()
			-- nameLabel:Point("TOPLEFT", 5, -offset)

			-- -- kind: label
			-- local kindLabel = H:CreateLabel(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_KindLabel", section.kind, 100, 20)
			-- kindLabel:ClearAllPoints()
			-- kindLabel:Point("TOPLEFT", 140, -offset)
			-- name + kind: label
			local nameKindLabel = H:CreateLabel(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_NameLabel", section.name .. " ["..section.kind.."]", 150, 20)
			nameKindLabel:ClearAllPoints()
			nameKindLabel:Point("TOPLEFT", 5, -offset)

			-- enable: checkbox
			local enableDefinition = GetDefinitionEntry(definition, "enable")
			--local enableCheckbox = H:CreateCheckbox(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_EnableCheckbox", "Enable", EnableCheckboxHandler) -- TODO: locales
			local enableCheckbox = H:CreateCheckbox(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_EnableCheckbox", "Enable", MyCheckboxHandler) -- TODO: locales
			enableCheckbox:ClearAllPoints()
			enableCheckbox:Point("TOPLEFT", 150, -offset)

			--enableCheckbox:SetChecked(DefaultBoolean(section.enable, enableDefinition.default))
			--enableCheckbox.index = i
			local enableValue = MyGetValue(enableDefinition, section)
			enableCheckbox:SetChecked(enableValue)
			enableCheckbox.config = section
			enableCheckbox.option = enableDefinition

			-- autohide: checkbox
			local autohideDefinition = GetDefinitionEntry(definition, "autohide")
			--local autohideCheckbox = H:CreateCheckbox(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_AutohideCheckbox", "Autohide", AutohideCheckboxHandler) -- TODO: locales
			local autohideCheckbox = H:CreateCheckbox(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_AutohideCheckbox", "Autohide", MyCheckboxHandler) -- TODO: locales
			autohideCheckbox:ClearAllPoints()
			autohideCheckbox:Point("TOPLEFT", 230, -offset)

			-- autohideCheckbox:SetChecked(DefaultBoolean(section.autohide, autohideDefinition.default))
			-- autohideCheckbox.index = i
			local autohideValue = MyGetValue(autohideDefinition, section)
			autohideCheckbox:SetChecked(autohideValue)
			autohideCheckbox.config = section
			autohideCheckbox.option = autohideDefinition

			-- edit: button
			local editButton = H:CreateButton(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_EditButton", "EDIT", 60, 20, EditButtonHandler) -- TODO: locales
			editButton:ClearAllPoints()
			editButton:Point("TOPLEFT", 330, -offset)

			editButton.index = i

			-- del: button
			local delButton = H:CreateButton(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_DelButton", "DEL", 60, 20, DelButtonHandler) -- TODO: locales
			delButton:ClearAllPoints()
			delButton:Point("TOPLEFT", 395, -offset)
			delButton:SetAlpha(0.5)

			delButton.index = i

			--
			offset = offset + 25
		end
	end
	PluginsFrame:Size(ConfigFrame:GetWidth()-20, offset)

	-- apply
	local ApplyButton = H:CreateButton(ConfigFrame, "ClassMonitorApplyButton", "APPLY", 80, 25, ApplyButtonHandler) -- TODO: locales
	ApplyButton:ClearAllPoints()
	ApplyButton:Point("TOPRIGHT", ConfigFrame, "BOTTOMRIGHT", 0, -4)
	-- reset
	local ResetButton = H:CreateButton(ConfigFrame, "ClassMonitorResetButton", "RESET", 80, 25, ResetButtonHandler) -- TODO: locales
	ResetButton:ClearAllPoints()
	ResetButton:Point("TOPRIGHT", ApplyButton, "TOPLEFT", -5, 0)

	-- add
	local AddButton = H:CreateButton(ConfigFrame, "ClassMonitorAddButton", "ADD", 80, 25, AddButtonHandler) -- TODO: locales
	AddButton:ClearAllPoints()
	AddButton:Point("TOPLEFT", ConfigFrame, "BOTTOMLEFT", 0, -4)
	AddButton:SetAlpha(0.5)

	--
	ConfigFrame:Show()
	ConfigScrollArea:SetScrollChild(PluginsFrame)
	ConfigScrollArea:Show()
end

-- dialog boxes
StaticPopupDialogs["CLASSMONITOR_APPLY"] = {
	text = "This will save modifications and reload UI. Are you sure?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = Apply,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

StaticPopupDialogs["CLASSMONITOR_RESET"] = {
	text = "This will erase every modifications. Are you sure?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = Reset,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

StaticPopupDialogs["CLASSMONITOR_CLOSE"] = {
	text = "You are about to close config and lose any modifications done. Are you sure?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = Close,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

StaticPopupDialogs["CLASSMONITOR_NOTYETIMPLENTED"] = {
	text = "This feature is not yet implemented.",
	button1 = "Ok",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

----------------------------------------
Engine.DisplayConfigFrame = function(UIComponents, config)
	ClassMonitorConfig = config --
	UI = UIComponents--_G["ClassMonitorUI"] -- get UI components from ClassMonitor
--print("Config:"..tostring(UIComponents).."  UI:"..tostring(config))

	H:SetUI(UI)

	CopyConfigAndVariables()
	RefreshConfigFrame()
end

ClassMonitor_DisplayConfigFrame = Engine.DisplayConfigFrame -- Expose config frame
--[[
	ClassMonitor_ConfigUI:DisplayConfigFrame(config)
--]]
