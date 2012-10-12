--[[

				 ----------------------------
	[Class     ]|Name+kind	enable	edit del| Name
				|Name+kind	enable	edit del| Kind
				|							| Anchor
				|							| params
				|							| ...
				 ---------------------------
				ADD				RESET	APPLY
--]]

local _, Engine = ...
local H = Engine.Helpers

ClassMonitor_ConfigUI = Engine -- Expose configUI
--[[
	ClassMonitor_ConfigUI:DisplayConfigFrame(config)
--]]

local ClassMonitor = nil -- will be assigned later
local UI = nil -- will be assigned later

local WorkingConfig = nil -- we work on these variables and copy into saved variables when clicking on apply
local WorkingSaved = nil
local ClassMonitorConfig = nil -- points to ClassMonitor config (set by DisplayConfigFrame)

local ModificationFound = false

local GenericDefinitions = {
	[1] = {
		key = "name",
		name = "Name",
		description = "Name",
		type = "string",
		readonly = true,
	},
	[2] = {
		key = "kind",
		name = "Kind",
		description = "Kind",
		type = "select",
		readonly = true,
	},
	[3] = {
		key = "enable",
		name = "Enable",
		description = "Enable",
		type = "toggle",
		default = true,
	},
	[4] = {
		key = "autohide",
		name = "Autohide",
		description = "Autohide",
		type = "toggle",
		default = true,
	},
}

local ConfigFrame -- main config frame
local EditFrame -- section edit frame

-- local function GetClassMonitorVariables() -- get values from ClassMonitor main addon
	-- ClassMonitor = _G["ClassMonitor"]
	-- UI = ClassMonitor.UI
	-- Config = ClassMonitor.Config[UI.MyClass]

	-- print("ClassMonitor found:"..tostring(ClassMonitor).."  "..tostring(Config).."  "..tostring(UI).." "..tostring(_G["ClassMonitorDataPerChar"]))
-- end

local function CopyConfigAndVariables() -- copy original values to working ones
	if ClassMonitorConfig then WorkingConfig = H:DeepCopy(ClassMonitorConfig) end
	if ClassMonitorDataPerChar then WorkingSaved = H:DeepCopy(ClassMonitorDataPerChar) end
	ModificationFound = false
end

local function SaveVariables() -- save working values to original ones
	ClassMonitorDataPerChar = H:DeepCopy(WorkingSaved)
end

local function GetDefinition(keyValue) -- search a section with key == keyValue
	for index, section in pairs(GenericDefinitions) do
		if section["key"] == keyValue then
			return section
		end
	end
	return nil
end

local function DefaultBoolean(value, default)
	if value == nil then
		return default
	else
		return value
	end
end

local function SetValue(sectionName, key, value)
--print("SetValue:["..tostring(sectionName).."]."..tostring(key).."="..tostring(value))
	WorkingSaved[sectionName] = WorkingSaved[sectionName] or {}
	WorkingSaved[sectionName][key] = value

	ModificationFound = true
end

local function EnableCheckboxHandler(self)
	local checked = self:GetChecked() and true or false
	local pluginConfig = WorkingConfig[self.index]
	pluginConfig.enable = checked
	SetValue(pluginConfig.name, "enable",checked)
--print("EnableCheckboxHandler:"..tostring(pluginConfig.name).." -> "..tostring(pluginConfig.enable))
end

local function AutohideCheckboxHandler(self)
	local checked = self:GetChecked() and true or false
	local pluginConfig = WorkingConfig[self.index]
	pluginConfig.autohide = checked
	SetValue(pluginConfig.name, "autohide", checked)
--print("AutohideCheckboxHandler:"..tostring(pluginConfig.name).." -> "..tostring(pluginConfig.autohide))
end

local RefreshConfigFrame -- forward declaration


local function Reset() -- Reset 'Yes' option
	CopyConfigAndVariables() -- revert to original values
	RefreshConfigFrame() -- refresh panel
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
	StaticPopup_Show("CLASSMONITOR_NOTYETIMPLENTED")
	-- TODO
end

local function CreateEditFrame()
	EditFrame = _G["ClassMonitorEditFrame"]
	if not EditFrame then
		-- TODO
	end
end

RefreshConfigFrame = function()
	ConfigFrame = _G["ClassMonitorConfigFrame"]
	if not ConfigFrame then
		ConfigFrame = CreateFrame("Frame", "ClassMonitorConfigFrame", UI.PetBattleHider)
		ConfigFrame:SetTemplate("Transparent")
		ConfigFrame:SetFrameStrata("DIALOG")
		ConfigFrame:Size(580, 400)
		ConfigFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		ConfigFrame:EnableMouse(true)
		ConfigFrame:SetMovable(true)
		ConfigFrame:RegisterForDrag("LeftButton")
		ConfigFrame:SetScript("OnDragStart", function(self) self:SetUserPlaced(true) self:StartMoving() end)
		ConfigFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		ConfigFrame:Hide() -- starts hidden
		-- title
		ConfigFrame.title = ConfigFrame:CreateFontString(nil, "OVERLAY")
		ConfigFrame.title:SetPoint("TOP", ConfigFrame, 0, -10)
		ConfigFrame.title:SetFont(UI.Font, 14)
		ConfigFrame.title:SetText("|cFF148587Class|r Monitor Configuration") -- TODO: locales
		-- close button
		local CloseButton = CreateFrame("Button", "ClassMonitorConfigFrameCloseButton", ConfigFrame, "UIPanelCloseButton")
		CloseButton:SetPoint("TOPRIGHT", ConfigFrame, "TOPRIGHT")
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
	ConfigScrollArea:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 8, -30)
	ConfigScrollArea:SetPoint("BOTTOMRIGHT", ConfigFrame, "BOTTOMRIGHT", -30, 8)
	--_G[ConfigScrollArea:GetName().."ScrollBar"]:SkinScrollBar() -- Grrrrrrrrr
	ConfigScrollArea:Hide()

	-- list of plugins
	local PluginsFrame = _G["ClassMonitorPluginsFrame"]
	if not PluginsFrame then
		PluginsFrame = CreateFrame("Frame", "ClassMonitorPluginsFrame", ConfigFrame)
	end
	PluginsFrame:ClearAllPoints()
	PluginsFrame:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 10, 40)
	PluginsFrame:Show()
	offset = 0
	for i, section in ipairs(WorkingConfig) do
		if section.kind ~= "MOVER" then
--print("Section:"..tostring(i).."  "..tostring(section.name).."  "..tostring(section.enable).."  "..tostring(section.autohide))
			-- name: label
			local nameLabel = H:CreateLabel(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_NameLabel", section.name, 100, 20)
			nameLabel:ClearAllPoints()
			nameLabel:SetPoint("TOPLEFT", 5, -offset)

			-- kind: label
			local kindLabel = H:CreateLabel(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_KindLabel", section.kind, 100, 20)
			kindLabel:ClearAllPoints()
			kindLabel:SetPoint("TOPLEFT", 140, -offset)

			-- enable: checkbox
			local enableDefinition = GetDefinition("enable")
			local enableCheckbox = H:CreateCheckbox(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_EnableCheckbox", "Enable", EnableCheckboxHandler) -- TODO: locales
			enableCheckbox:ClearAllPoints()
			enableCheckbox:SetPoint("TOPLEFT", 220, -offset)

			enableCheckbox:SetChecked(DefaultBoolean(section.enable, enableDefinition.default))
			enableCheckbox.index = i

			-- autohide: checkbox
			local autohideDefinition = GetDefinition("enable")
			local autohideCheckbox = H:CreateCheckbox(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_AutohideCheckbox", "Autohide", AutohideCheckboxHandler) -- TODO: locales
			autohideCheckbox:ClearAllPoints()
			autohideCheckbox:SetPoint("TOPLEFT", 300, -offset)

			autohideCheckbox:SetChecked(DefaultBoolean(section.autohide, autohideDefinition.default))
			autohideCheckbox.index = i

			-- edit: button
			local editButton = H:CreateButton(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_EditButton", "EDIT", 60, 20, EditButtonHandler) -- TODO: locales
			editButton:ClearAllPoints()
			editButton:SetPoint("TOPLEFT", 400, -offset)

			editButton.index = i

			-- del: button
			local delButton = H:CreateButton(PluginsFrame, "ClassMonitorPlugins_"..i.."_"..section.name.."_DelButton", "DEL", 60, 20, DelButtonHandler) -- TODO: locales
			delButton:ClearAllPoints()
			delButton:SetPoint("TOPLEFT", 465, -offset)

			delButton.index = i

			--
			offset = offset + 25
		end
	end
	PluginsFrame:Size(ConfigFrame:GetWidth()-20, offset)

	-- apply
	local ApplyButton = H:CreateButton(ConfigFrame, "ClassMonitorApplyButton", "APPLY", 80, 25, ApplyButtonHandler) -- TODO: locales
	ApplyButton:ClearAllPoints()
	ApplyButton:SetPoint("TOPRIGHT", ConfigFrame, "BOTTOMRIGHT", 0, -4)
	-- reset
	local ResetButton = H:CreateButton(ConfigFrame, "ClassMonitorResetButton", "RESET", 80, 25, ResetButtonHandler) -- TODO: locales
	ResetButton:ClearAllPoints()
	ResetButton:SetPoint("TOPRIGHT", ApplyButton, "TOPLEFT", -5, 0)

	-- add
	local AddButton = H:CreateButton(ConfigFrame, "ClassMonitorAddButton", "ADD", 80, 25, AddButtonHandler) -- TODO: locales
	AddButton:ClearAllPoints()
	AddButton:SetPoint("TOPLEFT", ConfigFrame, "BOTTOMLEFT", 0, -4)

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
function Engine:DisplayConfigFrame(config)
	ClassMonitorConfig = config

	UI = _G["ClassMonitorUI"] -- get UI components from ClassMonitor
	H:SetUI(UI)

	CopyConfigAndVariables()
	CreateEditFrame()
	RefreshConfigFrame()

end