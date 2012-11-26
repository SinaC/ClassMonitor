-- Eclipse plugin, credits to Tukz
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

if UI.MyClass ~= "DRUID" then return end -- Only for druid

local DefaultBoolean = Engine.DefaultBoolean
local GetColor = Engine.GetColor

--
local plugin = Engine:NewPlugin("ECLIPSE")

local DefaultColors = {
	{0.50, 0.52, 0.70, 1}, -- Lunar
	{0.80, 0.82, 0.60, 1}, -- Solar
}

-- own methods
function plugin:UpdateVisibility(event)
	--
	local inCombat = true
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	--
	if (self.settings.autohide == false or inCombat) and (GetShapeshiftFormID() == MOONKIN_FORM or GetSpecialization() == 1) then -- visible if moonkin or balance
		--
		self:RegisterUnitEvent("UNIT_POWER", "player", plugin.UpdatePower)
		self:RegisterUnitEvent("UNIT_AURA", "player", plugin.UpdateAura)
		--
		self:UpdatePower(nil, nil, "ECLIPSE")
		self:UpdateAura()
		--
		self.bar:Show()
	else
		--
		self:UnregisterEvent("UNIT_POWER")
		self:UnregisterEvent("UNIT_AURA")
		--
		self.bar:Hide()
	end
end

function plugin:UpdateDirection()
	if self.settings.text == true then
		local direction = GetEclipseDirection()
		if direction == "sun" then
			if self.inEclipse then
				self.bar.directionText:SetText(">>>")
			else
				self.bar.directionText:SetText(">")
			end
		elseif direction == "moon" then
			if self.inEclipse then
				self.bar.directionText:SetText("<<<")
			else
				self.bar.directionText:SetText("<")
			end
		else
			self.bar.directionText:SetText("")
		end
	end
end

function plugin:UpdateAura()
	self.inEclipse = false -- no eclipse
	for i = 1, 40, 1 do
		local name, _, _, _, _, _, _, _, _, _, spellID = UnitAura("player", i, "HELPFUL|PLAYER")
		if not name then break end
		if spellID == ECLIPSE_BAR_SOLAR_BUFF_ID then -- solar eclipse
			self.bar:SetBackdropBorderColor(unpack(GetColor(self.settings.colors, 1, DefaultColors[1])))
			self.inEclipse = true
			break
		elseif spellID == ECLIPSE_BAR_LUNAR_BUFF_ID then -- lunar eclipse
			self.bar:SetBackdropBorderColor(unpack(GetColor(self.settings.colors, 2, DefaultColors[2])))
			self.inEclipse = true
			break
		end
	end
	if not self.inEclipse then
		self.bar:SetBackdropBorderColor(unpack(UI.BorderColor))
	end
	--
	self:UpdateDirection()
end

function plugin:UpdatePower(_, _, powerType)
	if powerType ~= "ECLIPSE" then return end

	local power = UnitPower("player", SPELL_POWER_ECLIPSE)
	local maxPower = UnitPowerMax("player", SPELL_POWER_ECLIPSE)
	if maxPower == 0 then maxPower = 100 end -- when entering world at 1st connection, max power is 0
	self.bar.lunar:SetMinMaxValues(-maxPower, maxPower)
	self.bar.lunar:SetValue(power)
	self.bar.solar:SetMinMaxValues(-maxPower, maxPower)
	self.bar.solar:SetValue(power * -1)
	--
	self:UpdateDirection()
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
	local width = self:GetWidth()
	local height = self:GetHeight()
	bar:ClearAllPoints()
	bar:Point(unpack(self:GetAnchor()))
	bar:Size(width, height)

	-- lunar status bar
	if not bar.lunar then
		bar.lunar = CreateFrame("StatusBar", nil, bar)
		bar.lunar:SetStatusBarTexture(UI.NormTex)
	end
	bar.lunar:ClearAllPoints()
	bar.lunar:Point("TOPLEFT", bar, "TOPLEFT", 2, -2)
	bar.lunar:Size(width-4, height-4)
	bar.lunar:SetStatusBarColor(unpack(GetColor(self.settings.colors, 1, DefaultColors[1])))
	bar.lunar:SetMinMaxValues(0, 100)
	bar.lunar:SetValue(0) -- needed for a correct refresh while changing settings

	-- solar status bar
	if not bar.solar then
		bar.solar = CreateFrame("StatusBar", nil, bar)
		bar.solar:SetStatusBarTexture(UI.NormTex)
	end
	bar.solar:ClearAllPoints()
	bar.solar:Point("LEFT", bar.lunar:GetStatusBarTexture(), "RIGHT", 0, 0) -- solar will move when lunar moves
	bar.solar:Size(width-4, height-4)
	bar.solar:SetStatusBarColor(unpack(GetColor(self.settings.colors, 2, DefaultColors[2])))
	bar.solar:SetMinMaxValues(0, 100)
	bar.solar:SetValue(0) -- needed for a correct refresh while changing settings

	-- direction
	if self.settings.text == true and not bar.directionText then
		bar.directionText = UI.SetFontString(bar.lunar, 12)
		bar.directionText:Point("CENTER", bar.lunar)
	end
	if bar.directionText then bar.directionText:SetText("") end
end

-- overridden methods
function plugin:Initialize()
	-- set defaults
	self.settings.text = DefaultBoolean(self.settings.text, true)
	self.settings.colors = self.settings.colors or DefaultColors
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", plugin.UpdateVisibility)
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", plugin.UpdateVisibility)
end

function plugin:Disable()
	--
	self:UnregisterAllEvents()
	--
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
--http://www.wowinterface.com/forums/showthread.php?t=36129