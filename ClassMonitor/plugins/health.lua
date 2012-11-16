-- Resource Plugin, written to Ildyria, edited by SinaC
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

-- ONLY ON PTR
--if not Engine.IsPTR() then return end

local CheckSpec = Engine.CheckSpec
local DefaultBoolean = Engine.DefaultBoolean
local HealthColor = UI.HealthColor
local FormatNumber = Engine.FormatNumber
local GetAnchor = Engine.GetAnchor
local GetWidth = Engine.GetWidth
local GetHeight = Engine.GetHeight

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
				--if value > 10000 then
				--	self.bar.text:SetFormattedText("%.1fk", value/1000)
				--else
				--	self.bar.text:SetText(value)
				--end
				self.bar.text:SetText(FormatNumber(value))
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
	--bar:Size(self.settings.width, self.settings.height)
	--bar:Point(unpack(self.settings.anchor))
	bar:Point(unpack(GetAnchor(self.settings)))
	bar:Size(GetWidth(self.settings), GetHeight(self.settings))
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
	-- set defaults
	self.settings.unit = self.settings.unit or "player"
	self.settings.text = DefaultBoolean(self.settings.text, true)
	-- no default for color
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