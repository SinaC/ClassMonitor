-- Resource Plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

local CheckSpec = Engine.CheckSpec
local DefaultBoolean = Engine.DefaultBoolean
local FormatNumber = Engine.FormatNumber
local PowerColor = UI.PowerColor
local ClassColor = UI.ClassColor

--
local plugin = Engine:NewPlugin("RESOURCE")

-- own methods
function plugin:Update(elapsed)
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
	if self.timeSinceLastUpdate > 0.2 then
		local value = UnitPower("player")
--print("Value:"..value)
		self.bar.status:SetValue(value)
		if self.settings.text == true then
			local p = UnitPowerType("player")
			if p == SPELL_POWER_MANA then
				local valueMax = UnitPowerMax("player", p)
				if value == valueMax then
					-- if value > 10000 then
						-- self.bar.valueText:SetFormattedText("%.1fk", value/1000)
					-- else
						-- self.bar.valueText:SetText(value)
					-- end
					self.bar.valueText:SetText(FormatNumber(value))
				else
					local percentage = (value * 100) / valueMax
					-- if value > 10000 then
						-- self.bar.valueText:SetFormattedText("%2d%% - %.1fk", percentage, value/1000 )
					-- else
						-- self.bar.valueText:SetFormattedText("%2d%% - %u", percentage, value )
					-- end
					self.bar.valueText:SetFormattedText("%2d%% - "..FormatNumber(value), percentage)
				end
			else
				--self.bar.valueText:SetText(value)
				self.bar.valueText:SetText(FormatNumber(value))
			end
		end
		self.timeSinceLastUpdate = 0
	end
end

function plugin:UpdateVisibility(event)
	--
--print("RESOURCE:UpdateVisibility")
	local inCombat = false
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	local valueMax = UnitPowerMax("player")
	local valueCurrent = UnitPower("player")
	if (self.settings.autohide == true and not inCombat) or not CheckSpec(self.settings.specs) or (self.settings.hideifmax == true and valueMax == valueCurrent and not inCombat) then
		self.bar:Hide()
		self:UnregisterUpdate()
	else
		--
		self:UpdateMaxValueAndColor()
		--
		self.bar:Show()
		self.timeSinceLastUpdate = GetTime()
		self:RegisterUpdate(plugin.Update)
	end
end

function plugin:UpdateMaxValueAndColor()
	--
--print("RESOURCE:UpdateMaxValueAndColor")
	local valueMax = UnitPowerMax("player", resource)
	local resource, resourceName = UnitPowerType("player")
	-- use colors[resourceName] if defined, else use default resource color or class color
	local color = (self.settings.colors and self.settings.colors[resourceName]) or PowerColor(resourceName) or ClassColor()
	self.bar.status:SetStatusBarColor(unpack(color))
	self.bar.status:SetMinMaxValues(0, valueMax)
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
	end
	bar.status:SetMinMaxValues(0, UnitPowerMax("player"))
	--
	if self.settings.text == true and not bar.valueText then
		bar.valueText = UI.SetFontString(bar.status, 12)
		bar.valueText:Point("CENTER", bar.status)
	end
	if bar.valueText then bar.valueText:SetText("") end
end

-- overridden methods
function plugin:Initialize()
	-- set defaults
	self.settings.text = DefaultBoolean(self.settings.text, true)
	self.settings.hideifmax = DefaultBoolean(self.settings.hideifmax, false)
	self.settings.colors = self.settings.colors or self.settings.color
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player", plugin.UpdateVisibility)
	self:RegisterUnitEvent("UNIT_POWER", "player", plugin.UpdateVisibility)

	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player", plugin.UpdateMaxValueAndColor)
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player", plugin.UpdateMaxValueAndColor)
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