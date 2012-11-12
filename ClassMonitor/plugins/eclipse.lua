-- Eclipse plugin, credits to Tukz
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

if UI.MyClass ~= "DRUID" then return end -- Only for druid

local DefaultBoolean = Engine.DefaultBoolean
local GetColor = Engine.GetColor

-- ONLY ON PTR
--if not Engine.IsPTR() then return end

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
if true then return end
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
if true then return end
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
	bar:ClearAllPoints()
	bar:Point(unpack(self.settings.anchor))
	bar:Size(self.settings.width, self.settings.height)

	-- lunar status bar
	if not bar.lunar then
		bar.lunar = CreateFrame("StatusBar", nil, bar)
		bar.lunar:SetStatusBarTexture(UI.NormTex)
	end
	bar.lunar:ClearAllPoints()
	bar.lunar:Point("TOPLEFT", bar, "TOPLEFT", 2, -2)
	bar.lunar:Size(self.settings.width-4, self.settings.height-4)
	bar.lunar:SetStatusBarColor(unpack(GetColor(self.settings.colors, 1, DefaultColors[1])))
	bar.lunar:SetMinMaxValues(0, 100)
	bar.lunar:SetValue(0) -- needed for a correct refresh while changing width

	-- solar status bar
	if not bar.solar then
		bar.solar = CreateFrame("StatusBar", nil, bar)
		bar.solar:SetStatusBarTexture(UI.NormTex)
	end
	bar.solar:ClearAllPoints()
	bar.solar:Point("LEFT", bar.lunar:GetStatusBarTexture(), "RIGHT", 0, 0) -- solar will move when lunar moves
	bar.solar:Size(self.settings.width-4, self.settings.height-4)
	bar.solar:SetStatusBarColor(unpack(GetColor(self.settings.colors, 2, DefaultColors[2])))
	bar.solar:SetMinMaxValues(0, 100)
	bar.solar:SetValue(0) -- needed for a correct refresh while changing width

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
	-- if pluginSettings.kind == "ECLIPSE" then
		-- local setting = Engine.DeepCopy(pluginSettings)
		-- setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		-- setting.enable = true
		-- setting.autohide = false
		-- setting.text = true
		-- local instance = Engine:NewPluginInstance("ECLIPSE", "ECLIPSE"..tostring(i), setting)
		-- instance:Initialize()
		-- if setting.enable then
			-- instance:Enable()
		-- end
	-- end
-- end

--[[
-- Create eclipse monitor
Engine.CreateEclipseMonitor = function(name, enable, autohide, text, anchor, width, height, colors)
	local cmEclipse = CreateFrame("Frame", name, UI.PetBattleHider)
	cmEclipse:SetTemplate()
	cmEclipse:SetFrameStrata("BACKGROUND")
	cmEclipse:Size(width, height)
	cmEclipse:Point(unpack(anchor))

	-- lunar status bar
	cmEclipse.lunar = CreateFrame("StatusBar", name.."_lunar", cmEclipse)
	cmEclipse.lunar:Point("TOPLEFT", cmEclipse, "TOPLEFT", 2, -2)
	cmEclipse.lunar:Size(width-4, height-4)
	cmEclipse.lunar:SetStatusBarTexture(UI.NormTex)
	cmEclipse.lunar:SetStatusBarColor(unpack(colors[1]))

	-- solar status bar
	cmEclipse.solar = CreateFrame("StatusBar", name.."_solar", cmEclipse)
	cmEclipse.solar:Point("LEFT", cmEclipse.lunar:GetStatusBarTexture(), "RIGHT", 0, 0) -- solar will move when lunar moves
	cmEclipse.solar:Size(width-4, height-4)
	cmEclipse.solar:SetStatusBarTexture(UI.NormTex)
	cmEclipse.solar:SetStatusBarColor(unpack(colors[2]))

	-- direction
	if text == true then
		cmEclipse.directionText = UI.SetFontString(cmEclipse.lunar, 12)
		cmEclipse.directionText:Point("CENTER", cmEclipse.lunar)
	end

	if not enable then
		cmEclipse:Hide()
		return
	end

	cmEclipse.inEclipse = false -- not in eclipse by default

	--
	cmEclipse:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmEclipse:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmEclipse:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmEclipse:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	cmEclipse:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	cmEclipse:RegisterUnitEvent("UNIT_POWER", "player")
	cmEclipse:RegisterUnitEvent("UNIT_AURA", "player")
	cmEclipse:SetScript("OnEvent", function(self, event, arg1, arg2)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		-- update visibility
		if (GetShapeshiftFormID() ~= MOONKIN_FORM and GetSpecialization() ~= 1) or not visible then -- visible if moonkin or balance
			cmEclipse:Hide()
			return
		end
		if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" or event == "PLAYER_REGEN_DISABLED"  then
			cmEclipse:UnregisterEvent("PLAYER_ENTERING_WORLD") -- fire only once
			cmEclipse:Show()
		end
		-- update lunar/solar power
		if (event == "UNIT_POWER" and arg2 == "ECLIPSE") or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" or event == "PLAYER_REGEN_DISABLED" then
			local power = UnitPower("player", SPELL_POWER_ECLIPSE)
			local maxPower = UnitPowerMax("player", SPELL_POWER_ECLIPSE)
			if maxPower == 0 then maxPower = 100 end -- when entering world at 1st connection, max power is 0
			cmEclipse.lunar:SetMinMaxValues(-maxPower, maxPower)
			cmEclipse.lunar:SetValue(power)
			cmEclipse.solar:SetMinMaxValues(-maxPower, maxPower)
			cmEclipse.solar:SetValue(power * -1)
		end
		-- update eclipse status
		if event == "UNIT_AURA" then 
			cmEclipse.inEclipse = false -- no eclipse
			for i = 1, 40, 1 do
				local name, _, _, _, _, _, _, _, _, _, spellID = UnitAura("player", i, "HELPFUL|PLAYER")
				if not name then break end
				if spellID == ECLIPSE_BAR_SOLAR_BUFF_ID then -- solar eclipse
					cmEclipse:SetBackdropBorderColor(unpack(colors[1]))
					cmEclipse.inEclipse = true
					break
				elseif spellID == ECLIPSE_BAR_LUNAR_BUFF_ID then -- lunar eclipse
					cmEclipse:SetBackdropBorderColor(unpack(colors[2]))
					cmEclipse.inEclipse = true
					break
				end
			end
			if not cmEclipse.inEclipse then
				cmEclipse:SetBackdropBorderColor(unpack(BorderColor))
			end
		end
		-- update text
		if text == true then
			if GetEclipseDirection() == "sun" then
				if cmEclipse.inEclipse then
					cmEclipse.directionText:SetText(">>>")
				else
					cmEclipse.directionText:SetText(">")
				end
			elseif GetEclipseDirection() == "moon" then
				if cmEclipse.inEclipse then
					cmEclipse.directionText:SetText("<<<")
				else
					cmEclipse.directionText:SetText("<")
				end
			else
				cmEclipse.directionText:SetText("")
			end
		end
	end)

	return cmEclipse
end
--]]
--http://www.wowinterface.com/forums/showthread.php?t=36129