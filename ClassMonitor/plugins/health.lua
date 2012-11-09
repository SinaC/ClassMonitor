-- Resource Plugin, written to Ildyria, edited by SinaC
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

-- ONLY ON PTR
--if not Engine.IsPTR() then return end

local CheckSpec = Engine.CheckSpec
local HealthColor = UI.HealthColor

--
local plugin = Engine:NewPlugin("HEALTH")

-- own methods
function plugin:Update(elapsed)
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
	if self.timeSinceLastUpdate > 0.2 then
--print("cmHealth:OnUpdate")
		-- max
		local valueMax = UnitHealthMax(self.settings.unit)
		self.bar.status:SetMinMaxValues(0, valueMax)
		-- current
		local value = UnitHealth(self.settings.unit)
		self.bar.status:SetValue(value)
		if self.settings.text == true then
			if value == valueMax then
				if value > 10000 then
					self.bar.text:SetFormattedText("%.1fk", value/1000)
				else
					self.bar.text:SetText(value)
				end
			else
				local percentage = (value * 100) / valueMax
				if value > 10000 then
					self.bar.text:SetFormattedText("%2d%% - %.1fk", percentage, value/1000)
				else
					self.bar.text:SetFormattedText("%2d%% - %u", percentage, value)
				end
			end
		end
		self.timeSinceLastUpdate = 0
	end
end

function plugin:UpdateVisibility(event)
	local inCombat = false
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	local class = select(2, UnitClass(self.settings.unit))
	if (self.settings.autohide == false or inCombat) and CheckSpec(self.settings.specs) and class then
		local healthColor = self.settings.color or HealthColor(self.settings.unit) or {1, 1, 1, 1}
		self.bar.status:SetStatusBarColor(unpack(healthColor))
		self.bar:Show()
		self.timeSinceLastUpdate = GetTime()
		self:RegisterUpdate(plugin.Update)
	else
		self.bar:Hide()
		self:UnregisterUpdate()
	end
end

function plugin:UpdateGraphics()
	local bar = self.bar
	if not bar then
		bar = CreateFrame("Frame", self.name, UI.PetBattleHider)
		bar:SetTemplate()
		bar:SetFrameStrata("BACKGROUND")
		bar:Hide()
		self.bar = bar
	end
	bar:ClearAllPoints()
	bar:Size(self.settings.width, self.settings.height)
	bar:Point(unpack(self.settings.anchor))
	--
	if not bar.status then
		bar.status = CreateFrame("StatusBar", nil, bar)
		bar.status:SetStatusBarTexture(UI.NormTex)
		bar.status:SetFrameLevel(6)
		bar.status:Point("TOPLEFT", bar, "TOPLEFT", 2, -2)
		bar.status:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)
	end
	bar.status:SetMinMaxValues(0, UnitHealthMax(self.settings.unit))
	--
	if self.settings.text == true and not bar.text then
		bar.text = UI.SetFontString(bar.status, 12)
		bar.text:Point("CENTER", bar.status)
	end
	if bar.text then bar.text:SetText("") end
end

-- overridden methods
function plugin:Initialize()
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
	if self.settings.unit == "target" then self:RegisterEvent("PLAYER_TARGET_CHANGED", plugin.UpdateVisibility) end
	if self.settings.unit == "focus" then self:RegisterEvent("PLAYER_FOCUS_CHANGED", plugin.UpdateVisibility) end
	if self.settings.unit == "pet" then self:RegisterUnitEvent("UNIT_PET", "player", plugin.UpdateVisibility) end
	--self:RegisterUnitEvent("UNIT_HEALTH", unit) -- NOT needed
	--self:RegisterUnitEvent("UNIT_MAXHEALTH", unit) -- NOT needed
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player", plugin.UpdateVisibility)
end

function plugin:Disable()
	--
	self:UnregisterAllEvents()
	self:UnregisterUpdate()
	--
	self.bar:Hide()
end

function plugin:SettingsModified()
	--
	self:Disable()
	--
	self:UpdateGraphics()
	--
	if self.settings.enable == true then
		self:Enable()
		self:UpdateVisibility()
	end
end

-- ----------------------------------------------
-- -- test
-- ----------------------------------------------
-- local C = Engine.Config
-- local settings = C[UI.MyClass]
-- if not settings then return end
-- for i, pluginSettings in ipairs(settings) do
	-- if pluginSettings.kind == "HEALTH" then
		-- local setting = Engine.DeepCopy(pluginSettings)
		-- setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		-- setting.enable = true
		-- setting.autohide = false
		-- setting.specs = {"any"}
		-- setting.unit = setting.unit or "player"
		-- setting.text = true
		-- local instance = Engine:NewPluginInstance("HEALTH", "HEALTH"..tostring(i), setting)
		-- instance:Initialize()
		-- if setting.enable then
			-- instance:Enable()
		-- end
	-- end
-- end

--[[
-- Create a health monitor
Engine.CreateHealthMonitor = function(name, enable, unit, text, autohide, anchor, width, height, color, specs)
	local cmHealth = CreateFrame("Frame", name, UI.PetBattleHider)
	cmHealth:SetTemplate()
	cmHealth:SetFrameStrata("BACKGROUND")
	cmHealth:Size(width, height)
	cmHealth:Point(unpack(anchor))

	cmHealth.status = CreateFrame("StatusBar", "cmHealthStatus", cmHealth)
	cmHealth.status:SetStatusBarTexture(UI.NormTex)
	cmHealth.status:SetFrameLevel(6)
	cmHealth.status:Point("TOPLEFT", cmHealth, "TOPLEFT", 2, -2)
	cmHealth.status:Point("BOTTOMRIGHT", cmHealth, "BOTTOMRIGHT", -2, 2)
	cmHealth.status:SetMinMaxValues(0, UnitHealthMax(unit))

	if text == true then
		cmHealth.text = UI.SetFontString(cmHealth.status, 12)
		cmHealth.text:Point("CENTER", cmHealth.status)
	end

	if not enable then
		cmHealth:Hide()
		return
	end

	cmHealth.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		cmHealth.timeSinceLastUpdate = cmHealth.timeSinceLastUpdate + elapsed
		if cmHealth.timeSinceLastUpdate > 0.2 then
--print("cmHealth:OnUpdate")
			local value = UnitHealth(unit)
			cmHealth.status:SetValue(value)
			if text == true then
				local valueMax = UnitHealthMax(unit)
				if value == valueMax then
					if value > 10000 then
						cmHealth.text:SetFormattedText("%.1fk", value/1000)
					else
						cmHealth.text:SetText(value)
					end
				else
					local percentage = (value * 100) / valueMax
					if value > 10000 then
						cmHealth.text:SetFormattedText("%2d%% - %.1fk", percentage, value/1000 )
					else
						cmHealth.text:SetFormattedText("%2d%% - %u", percentage, value )
					end
				end
			end
			cmHealth.timeSinceLastUpdate = 0
		end
	end

	cmHealth:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmHealth:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmHealth:RegisterEvent("PLAYER_ENTERING_WORLD")
	if unit == "target" then cmHealth:RegisterEvent("PLAYER_TARGET_CHANGED") end
	if unit == "focus" then cmHealth:RegisterEvent("PLAYER_FOCUS_CHANGED") end
	if unit == "pet" then cmHealth:RegisterUnitEvent("UNIT_PET", "player") end
	--cmHealth:RegisterUnitEvent("UNIT_HEALTH", unit)
	cmHealth:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
	cmHealth:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", unit)
	cmHealth:SetScript("OnEvent", function(self, event)
		local class = select(2, UnitClass(unit))
		if autohide == true then
			if class and (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) then
				visible = true
			else
				visible = false
			end
		end
		if not CheckSpec(specs) or not visible then
			cmHealth:Hide()
			return
		end
		-- TODO: problem while in combat with a target and pressing escape
		-- code in comment in next if helps but show a null bar when no target and in combat
		if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_MAXHEALTH" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" or event == "PLAYER_REGEN_DISABLED" then
			if class then
				local valueMax = UnitHealthMax(unit)
				local healthColor = color or HealthColor(unit) or {1, 1, 1, 1}
				cmHealth.status:SetStatusBarColor(unpack(healthColor))
				cmHealth.status:SetMinMaxValues(0, valueMax)
				cmHealth:Show()
			else
				cmHealth:Hide()
			end
		end
		-- if autohide == true then
			-- if event == "PLAYER_REGEN_DISABLED" then
				-- cmHealth:Show()
			-- elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
				-- if InCombatLockdown() and class then
					-- cmHealth:Show()
				-- end
			-- else
				-- cmHealth:Hide()
			-- end
		-- end
--print("IN COMBAT:"..tostring(InCombatLockdown()).."  "..tostring(event).."  "..tostring(class))
	end)

	-- This is what stops constant OnUpdate
	cmHealth:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)
	cmHealth:SetScript("OnHide", function (self)
		self:SetScript("OnUpdate", nil)
	end)

	-- If autohide is not set, show frame
	if autohide ~= true then
		if cmHealth:IsShown() then
			cmHealth:SetScript("OnUpdate", OnUpdate)
		else
			cmHealth:Show()
		end
	end
	
	return cmHealth
end
--]]