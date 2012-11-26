-- Demonic Fury Plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

if UI.MyClass ~= "WARLOCK" then return end -- Available only for warlocks

local PowerColor = UI.PowerColor
local ClassColor = UI.ClassColor
local DefaultBoolean = Engine.DefaultBoolean

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
		bar = CreateFrame("Frame", self.name, UI.PetBattleHider)
		bar:SetTemplate()
		bar:SetFrameStrata("BACKGROUND")
		bar:Hide()
		self.bar = bar
	end
	bar:ClearAllPoints()
	bar:Point(unpack(self:GetAnchor()))
	bar:Size(self:GetWidth(), self:GetHeight())
	--
	if not bar.status then
		bar.status = CreateFrame("StatusBar", nil, bar)
		bar.status:SetStatusBarTexture(UI.NormTex)
		bar.status:SetFrameLevel(6)
		bar.status:SetInside()
		bar.status:SetMinMaxValues(0, 1) -- dummy values
	end
	bar.status:SetStatusBarColor(unpack(self.settings.color))

	if self.settings.text == true and not bar.text then
		bar.text = UI.SetFontString(bar.status, 12)
		bar.text:Point("CENTER", bar.status)
	end
	if bar.text then bar.text:SetText("") end
end

-- overridden methods
function plugin:Initialize()
	-- set defaults
	self.settings.color = self.settings.color or PowerColor(SPELL_POWER_DEMONIC_FURY) or {95/255, 222/255,  95/255, 1}
	self.settings.text = DefaultBoolean(self.settings.text, true)
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
	if self:IsEnabled() then
		self:Enable()
		self:UpdateVisibility()
	end
end