--http://www.wowwiki.com/API_GetEclipseDirection


--Tukui\Tukui\modules\unitframes\core\oUF\elements\eclipsebar.lua

-- if(select(2, UnitClass('player')) ~= 'DRUID') then return end

-- local parent, ns = ...
-- local oUF = ns.oUF

-- local ECLIPSE_BAR_SOLAR_BUFF_ID = ECLIPSE_BAR_SOLAR_BUFF_ID
-- local ECLIPSE_BAR_LUNAR_BUFF_ID = ECLIPSE_BAR_LUNAR_BUFF_ID
-- local SPELL_POWER_ECLIPSE = SPELL_POWER_ECLIPSE
-- local MOONKIN_FORM = MOONKIN_FORM

-- local UNIT_POWER = function(self, event, unit, powerType)
	-- if(self.unit ~= unit or (event == 'UNIT_POWER' and powerType ~= 'ECLIPSE')) then return end

	-- local eb = self.EclipseBar

	-- local power = UnitPower('player', SPELL_POWER_ECLIPSE)
	-- local maxPower = UnitPowerMax('player', SPELL_POWER_ECLIPSE)

	-- if(eb.LunarBar) then
		-- eb.LunarBar:SetMinMaxValues(-maxPower, maxPower)
		-- eb.LunarBar:SetValue(power)
	-- end

	-- if(eb.SolarBar) then
		-- eb.SolarBar:SetMinMaxValues(-maxPower, maxPower)
		-- eb.SolarBar:SetValue(power * -1)
	-- end

	-- if(eb.PostUpdatePower) then
		-- return eb:PostUpdatePower(unit)
	-- end
-- end

-- local UPDATE_VISIBILITY = function(self, event)
	-- local eb = self.EclipseBar

	-- -- check form/mastery
	-- local showBar
	-- local form = GetShapeshiftFormID()
	-- if(not form) then
		-- local ptt = GetPrimaryTalentTree()
		-- if(ptt and ptt == 1) then -- player has balance spec
			-- showBar = true
		-- end
	-- elseif(form == MOONKIN_FORM) then
		-- showBar = true
	-- end

	-- if(showBar) then
		-- eb:Show()
	-- else
		-- eb:Hide()
	-- end

	-- if(eb.PostUpdateVisibility) then
		-- return eb:PostUpdateVisibility(self.unit)
	-- end
-- end

-- local UNIT_AURA = function(self, event, unit)
	-- if(self.unit ~= unit) then return end

	-- local i = 1
	-- local hasSolarEclipse, hasLunarEclipse
	-- repeat
		-- local _, _, _, _, _, _, _, _, _, _, spellID = UnitAura(unit, i, 'HELPFUL')

		-- if(spellID == ECLIPSE_BAR_SOLAR_BUFF_ID) then
			-- hasSolarEclipse = true
		-- elseif(spellID == ECLIPSE_BAR_LUNAR_BUFF_ID) then
			-- hasLunarEclipse = true
		-- end

		-- i = i + 1
	-- until not spellID

	-- local eb = self.EclipseBar
	-- eb.hasSolarEclipse = hasSolarEclipse
	-- eb.hasLunarEclipse = hasLunarEclipse

	-- if(eb.PostUnitAura) then
		-- return eb:PostUnitAura(unit)
	-- end
-- end

-- local ECLIPSE_DIRECTION_CHANGE = function(self, event, isLunar)
	-- local eb = self.EclipseBar

	-- eb.directionIsLunar = isLunar

	-- if(eb.PostDirectionChange) then
		-- return eb:PostDirectionChange(self.unit)
	-- end
-- end

-- local Update = function(self, ...)
	-- UNIT_POWER(self, ...)
	-- UNIT_AURA(self, ...)
	-- return UPDATE_VISIBILITY(self, ...)
-- end

-- local ForceUpdate = function(element)
	-- return Update(element.__owner, 'ForceUpdate', element.__owner.unit, 'ECLIPSE')
-- end

-- local function Enable(self)
	-- local eb = self.EclipseBar
	-- if(eb) then
		-- eb.__owner = self
		-- eb.ForceUpdate = ForceUpdate

		-- if(eb.LunarBar and not eb.LunarBar:GetStatusBarTexture()) then
			-- eb.LunarBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		-- end
		-- if(eb.SolarBar and not eb.SolarBar:GetStatusBarTexture()) then
			-- eb.SolarBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		-- end

		-- self:RegisterEvent('ECLIPSE_DIRECTION_CHANGE', ECLIPSE_DIRECTION_CHANGE)
		-- self:RegisterEvent('PLAYER_TALENT_UPDATE', UPDATE_VISIBILITY)
		-- self:RegisterEvent('UNIT_AURA', UNIT_AURA)
		-- self:RegisterEvent('UNIT_POWER', UNIT_POWER)
		-- self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', UPDATE_VISIBILITY)

		-- return true
	-- end
-- end

-- local function Disable(self)
	-- local eb = self.EclipseBar
	-- if(eb) then
		-- self:UnregisterEvent('ECLIPSE_DIRECTION_CHANGE', ECLIPSE_DIRECTION_CHANGE)
		-- self:UnregisterEvent('PLAYER_TALENT_UPDATE', UPDATE_VISIBILITY)
		-- self:UnregisterEvent('UNIT_AURA', UNIT_AURA)
		-- self:UnregisterEvent('UNIT_POWER', UNIT_POWER)
		-- self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM', UPDATE_VISIBILITY)
	-- end
-- end

-- oUF:AddElement('EclipseBar', Update, Enable, Disable)

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

--Tukui\Tukui\core.lua

-- T.EclipseDirection = function(self)
	-- if ( GetEclipseDirection() == "sun" ) then
			-- self.Text:SetText("|cffE5994C"..L.unitframes_ouf_starfirespell.."|r")
	-- elseif ( GetEclipseDirection() == "moon" ) then
			-- self.Text:SetText("|cff4478BC"..L.unitframes_ouf_wrathspell.."|r")
	-- else
			-- self.Text:SetText("")
	-- end
-- end

-- T.DruidBarDisplay = function(self, login)
	-- local eb = self.EclipseBar
	-- local dm = self.DruidMana
	-- local txt = self.EclipseBar.Text
	-- local shadow = self.shadow
	-- local bg = self.DruidManaBackground
	-- local buffs = self.Buffs
	-- local flash = self.FlashInfo

	-- if login then
		-- dm:SetScript("OnUpdate", nil)
	-- end
	
	-- if eb:IsShown() or dm:IsShown() then
		-- if eb:IsShown() then
			-- txt:Show()
			-- flash:Hide()
		-- end
		-- shadow:Point("TOPLEFT", -4, 12)
		-- bg:SetAlpha(1)
		-- if T.lowversion then
			-- if buffs then buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 34) end
		-- else
			-- if buffs then buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 38) end
		-- end				
	-- else
		-- txt:Hide()
		-- flash:Show()
		-- shadow:Point("TOPLEFT", -4, 4)
		-- bg:SetAlpha(0)
		-- if T.lowversion then
			-- if buffs then buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 26) end
		-- else
			-- if buffs then buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 30) end
		-- end
	-- end
-- end