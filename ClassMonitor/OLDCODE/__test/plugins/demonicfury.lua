-- Demonic Fury Plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

if UI.MyClass ~= "WARLOCK" then return end -- Available only for warlocks

-- ONLY ON PTR
if not Engine.IsPTR() then return end

local PowerColor = UI.PowerColor
local ClassColor = UI.ClassColor

--
local plugin = Engine:NewPlugin("DEMONICFURY")

-- own methods
function plugin:Update(elapsed)
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
	if self.timeSinceLastUpdate > 0.2 then
		local valueMax = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)
		local value = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
		self.bar.status:SetMinMaxValues(0, valueMax)
		self.bar.status:SetValue(value)
		if self.settings.text == true then
			self.bar.text:SetText(value)
		end
		self.timeSinceLastUpdate = 0
	end
end

function plugin:UpdateVisibility(event)
	local inCombat = true
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	if (self.settings.autohide == false or inCombat) and GetSpecialization() == SPEC_WARLOCK_DEMONOLOGY then
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
		bar = CreateFrame("Frame", name, UI.PetBattleHider)
		bar:SetTemplate()
		bar:SetFrameStrata("BACKGROUND")
		bar:Hide()
		self.bar = bar
	end
	bar:ClearAllPoints()
	bar:Point(unpack(self.settings.anchor))
	bar:Size(self.settings.width, self.settings.height)
	--
	if not bar.status then
		bar.status = CreateFrame("StatusBar", nil, bar)
		bar.status:SetStatusBarTexture(UI.NormTex)
		bar.status:SetFrameLevel(6)
		bar.status:Point("TOPLEFT", bar, "TOPLEFT", 2, -2)
		bar.status:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)
		bar.status:SetMinMaxValues(0, 1) -- dummy values
		bar.status:SetStatusBarColor(unpack(self.settings.color))
	end

	if self.settings.text == true and not bar.text then
		bar.text = UI.SetFontString(bar.status, 12)
		bar.text:Point("CENTER", bar.status)
	end
end

-- overridden methods
function plugin:Initialize()
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player", plugin.UpdateVisibility)
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player", plugin.UpdateVisibility)
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player", plugin.UpdateVisibility)
end

function plugin:Disable()
	self:UnregisterAllEvents()
	self:UnregisterUpdate()

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

----------------------------------------------
-- test
----------------------------------------------
local C = Engine.Config
local settings = C[UI.MyClass]
if not settings then return end
for i, pluginSettings in ipairs(settings) do
	if pluginSettings.kind == "DEMONICFURY" then
		local setting = Engine.DeepCopy(pluginSettings)
		setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		setting.enable = true
		setting.autohide = false
		setting.color = setting.color or UI.PowerColor(SPELL_POWER_DEMONIC_FURY) or {95/255, 222/255,  95/255, 1}
		local instance = Engine:NewPluginInstance("DEMONICFURY", "DEMONICFURY"..tostring(i), setting)
		instance:Initialize()
		if setting.enable then
			instance:Enable()
		end
	end
end

--[[
-- Create Demonic fury monitor
Engine.CreateDemonicFuryMonitor = function(name, enable, text, autohide, anchor, width, height, color)
	local cmDFM = CreateFrame("Frame", name, UI.PetBattleHider)
	cmDFM:SetTemplate()
	cmDFM:SetFrameStrata("BACKGROUND")
	cmDFM:Size(width, height)
	cmDFM:Point(unpack(anchor))

	cmDFM.status = CreateFrame("StatusBar", "cmDFMStatus", cmDFM)
	cmDFM.status:SetStatusBarTexture(UI.NormTex)
	cmDFM.status:SetFrameLevel(6)
	cmDFM.status:Point("TOPLEFT", cmDFM, "TOPLEFT", 2, -2)
	cmDFM.status:Point("BOTTOMRIGHT", cmDFM, "BOTTOMRIGHT", -2, 2)
	cmDFM.status:SetMinMaxValues(0, UnitPowerMax("player"))

	if text == true then
		cmDFM.text = UI.SetFontString(cmDFM.status, 12)
		cmDFM.text:Point("CENTER", cmDFM.status)
	end

	if not enable then
		cmDFM:Hide()
		return
	end

	cmDFM.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		cmDFM.timeSinceLastUpdate = cmDFM.timeSinceLastUpdate + elapsed
		if cmDFM.timeSinceLastUpdate > 0.2 then
			local value = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
			cmDFM.status:SetValue(value)
			if text == true then
				cmDFM.text:SetText(value)
			end
			cmDFM.timeSinceLastUpdate = 0
		end
	end

	cmDFM:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmDFM:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmDFM:RegisterEvent("PLAYER_REGEN_ENABLED")
	--cmDFM:RegisterUnitEvent("UNIT_POWER", "player")
	cmDFM:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
	cmDFM:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	cmDFM:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmDFM:SetScript("OnEvent", function(self, event)
		local spec = GetSpecialization()
		if spec ~= SPEC_WARLOCK_DEMONOLOGY then
			cmDFM:Hide()
			return
		end
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end

		if not visible then
			cmDFM:Hide()
			return
		end

		if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" or event == "UNIT_MAXPOWER" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_REGEN_DISABLED" then
			local valueMax = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)
			cmDFM.status:SetStatusBarColor(unpack(color))
			cmDFM.status:SetMinMaxValues(0, valueMax)
			cmDFM:Show()
		end
		-- if autohide == true then
			-- if event == "PLAYER_REGEN_DISABLED" then
				-- cmDFM:Show()
			-- elseif event == "UNIT_POWER" or event == "UNIT_MAXPOWER" then
				-- if InCombatLockdown() then
					-- cmDFM:Show()
				-- end
			-- else
				-- cmDFM:Hide()
			-- end
		-- end
	end)

	-- This is what stops constant OnUpdate
	cmDFM:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)
	cmDFM:SetScript("OnHide", function (self)
		self:SetScript("OnUpdate", nil)
	end)

	-- If autohide is not set, show frame
	if autohide ~= true then
		if cmDFM:IsShown() then
			cmDFM:SetScript("OnUpdate", OnUpdate)
		else
			cmDFM:Show()
		end
	end
	
	return cmDFM
end
--]]