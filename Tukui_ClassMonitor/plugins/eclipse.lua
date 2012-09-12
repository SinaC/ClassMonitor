-- Eclipse plugin
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local function UnitPowerHandler(cmEclipse)
	--print("UnitPower:"..tostring(cmEclipse))
	local power = UnitPower("player", SPELL_POWER_ECLIPSE)
	local maxPower = UnitPowerMax("player", SPELL_POWER_ECLIPSE)

	--print("Power:"..tostring(power).." / "..tostring(maxPower))
	if cmEclipse.cmLunar then
		cmEclipse.cmLunar:SetMinMaxValues(-maxPower, maxPower)
		cmEclipse.cmLunar:SetValue(power)
	end

	if cmEclipse.cmSolar then
		cmEclipse.cmSolar:SetMinMaxValues(-maxPower, maxPower)
		cmEclipse.cmSolar:SetValue(power * -1)
	end
end

local function UpdateVisibilityHandler(cmEclipse)
	--print("UpdateVisibility:"..tostring(cmEclipse))
	-- -- check form/mastery
	local showBar = false
	local form = GetShapeshiftFormID()
	if not form then
		--local ptt = GetPrimaryTalentTree()
		--if ptt and ptt == 1 then -- player has balance spec
			-- showBar = true
		-- end
		local spec = GetSpecialization()
		if spec and spec == 1 then -- player has balance spec
			showBar = true
		end
	elseif form == MOONKIN_FORM then
		showBar = true
	end

	--print("showBar:"..tostring(showBar))
	if showBar then
		cmEclipse:Show()
	else
		cmEclipse:Hide()
	end
end

local function UnitAuraHandler(cmEclipse, colors)
	--print("UnitAura:"..tostring(cmEclipse))
	local hasSolarEclipse = false
	local hasLunarEclipse = false

	for i = 1, 40, 1 do
		local name, _, _, _, _, _, _, _, _, _, spellID = UnitAura("player", i, "HELPFUL|PLAYER")
		if not name then break end

		if spellID == ECLIPSE_BAR_SOLAR_BUFF_ID then
			--print("ECLIPSE_BAR_SOLAR_BUFF_ID")
			hasSolarEclipse = true
		elseif spellID == ECLIPSE_BAR_LUNAR_BUFF_ID then
			--print("ECLIPSE_BAR_LUNAR_BUFF_ID")
			hasLunarEclipse = true
		end
	end

	-- TODO: change border while in eclipse
	if hasSolarEclipse then
		cmEclipse:SetBackdropBorderColor(unpack(colors[1]))
	elseif hasLunarEclipse then
		cmEclipse:SetBackdropBorderColor(unpack(colors[2]))
	else
		cmEclipse:SetBackdropBorderColor(unpack(C.general.bordercolor))
	end

	-- if hasLunarEclipse then
        -- self.glow:ClearAllPoints();
        -- local glowInfo = ECLIPSE_ICONS["moon"].big;
        -- self.glow:Point("CENTER", self.moon, "CENTER", 0, 0);
        -- self.glow:SetWidth(glowInfo.x);
        -- self.glow:SetHeight(glowInfo.y);
        -- self.glow:SetTexCoord(glowInfo.left, glowInfo.right, glowInfo.top, glowInfo.bottom);
        -- self.sunBar:SetAlpha(0);
        -- self.darkMoon:SetAlpha(0);
        -- self.moonBar:SetAlpha(1);
        -- self.darkSun:SetAlpha(1);
        -- self.glow:SetAlpha(1);
        -- self.glow.pulse:Play();
    -- elseif hasSolarEclipse then
        -- self.glow:ClearAllPoints();
        -- local glowInfo = ECLIPSE_ICONS["sun"].big;
        -- self.glow:Point("CENTER", self.sun, "CENTER", 0, 0);
        -- self.glow:SetWidth(glowInfo.x);
        -- self.glow:SetHeight(glowInfo.y);
        -- self.glow:SetTexCoord(glowInfo.left, glowInfo.right, glowInfo.top, glowInfo.bottom);
        -- self.moonBar:SetAlpha(0);
        -- self.darkSun:SetAlpha(0);
        -- self.sunBar:SetAlpha(1);
        -- self.darkMoon:SetAlpha(1);
        -- self.glow:SetAlpha(1);
        -- self.glow.pulse:Play();
    -- else
        -- self.sunBar:SetAlpha(0);
        -- self.moonBar:SetAlpha(0);
        -- self.darkSun:SetAlpha(0);
        -- self.darkMoon:SetAlpha(0);
        -- self.glow:SetAlpha(0);
    -- end

	-- cmEclipse.hasSolarEclipse = hasSolarEclipse
	-- cmEclipse.hasLunarEclipse = hasLunarEclipse
end

-- local function EclipseDirectionChange(isLunar, cmEclipse)
	-- cmEclipse.directionIsLunar = isLunar
-- end

function Engine:CreateEclipseMonitor(name, anchor, width, height, colors)
	--print("CreateEclipseMonitor:"..tostring(width).."  "..tostring(height))
	local cmEclipse = CreateFrame("Frame", name, TukuiPetBattleHider)
	--cmEclipse:CreatePanel("Default", width, height, unpack(anchor))
	cmEclipse:SetTemplate()
	cmEclipse:SetFrameStrata("BACKGROUND")
	cmEclipse:Size(width, height)

	--cmEclipse:SetFrameStrata("MEDIUM")
	--cmEclipse:SetFrameLevel(8)
	--cmEclipse:SetTemplate("Default")
	--cmEclipse:SetBackdropBorderColor(0,0,0,0)
	--cmEclipse:SetScript("OnShow", function() T.DruidBarDisplay(self, false) end)
	--cmEclipse:SetScript("OnHide", function() T.DruidBarDisplay(self, false) end)

	local cmLunar = CreateFrame("StatusBar", name.."_lunar", cmEclipse)
	cmLunar:Point('TOPLEFT', cmEclipse, 'TOPLEFT', 2, -2)
	cmLunar:Size(cmEclipse:GetWidth()-4, cmEclipse:GetHeight()-4)
	cmLunar:SetStatusBarTexture(C.media.normTex)
	cmLunar:SetStatusBarColor(unpack(colors[1]))
	cmEclipse.cmLunar = cmLunar

	local cmSolar = CreateFrame("StatusBar", name.."_solar", cmEclipse)
	cmSolar:Point('LEFT', cmLunar:GetStatusBarTexture(), 'RIGHT', 0, 0)
	cmSolar:Size(cmEclipse:GetWidth()-4, cmEclipse:GetHeight()-4)
	cmSolar:SetStatusBarTexture(C.media.normTex)
	cmSolar:SetStatusBarColor(unpack(colors[2]))
	cmEclipse.cmSolar = cmSolar

	UnitPowerHandler(cmEclipse)

	cmEclipse:RegisterEvent("UNIT_POWER")
	cmEclipse:RegisterEvent("UPDATE_VISIBILITY")
	cmEclipse:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	cmEclipse:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	cmEclipse:RegisterEvent("UNIT_AURA")
	-- cmEclipse:RegisterEvent("ECLIPSE_DIRECTION_CHANGE", EclipseDirectionChange)
	cmEclipse:SetScript("OnEvent", function(self, event, arg1, arg2)
		--print("OnEvent:"..event.." "..tostring(arg1).."  "..tostring(arg2))
		if event == "UNIT_POWER" and arg1 == "player" and arg2 == "ECLIPSE" then
			UnitPowerHandler(self)
		elseif event == "UPDATE_VISIBILITY" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" then
			UpdateVisibilityHandler(self)
		elseif event == "UNIT_AURA" and arg1 == "player" then 
			UnitAuraHandler(self, colors) 
		--elseif event == "ECLIPSE_DIRECTION_CHANGE" then
		--	EclipseDirectionChange(arg1, self)
		end
	end)

	return cmEclipse
end


----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
--http://www.wowinterface.com/forums/showthread.php?t=36129

-- if playerClass == "DRUID" then
	-- self.Name:Point("TOPLEFT", self.Health, "TOPLEFT", 18, 40)
	-- self.Debuffs:Point(cfg.PlayerDebufAnchor1, self.Health, cfg.PlayerDebufAnchor2, cfg.PlayerDebufOffset_X, cfg.PlayerDebufOffset_Y+20)
	-- local eclipseBar = CreateFrame('Frame', nil, self)
	-- eclipseBar:Point('TOPLEFT', self, 'BOTTOMLEFT', 23, 56)
	-- eclipseBar:SetSize(cfg.widthP-45, 12)
	-- eclipseBar:SetBackdrop{edgeFile = cfg.glowtex2, edgeSize = 5, insets = {left = 3, right = 3, top = 3, bottom = 3}}
	-- eclipseBar:SetBackdropColor(0, 0, 0, 0)
	-- eclipseBar:SetBackdropBorderColor(0, 0, 0, 0.8)	
	
	-- local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
	-- lunarBar:Point('LEFT', eclipseBar, 'LEFT', 0, 0)
	-- lunarBar:SetSize(cfg.widthP-42, 12)
	-- lunarBar:SetStatusBarTexture(cfg.PPtex)
	-- lunarBar:SetStatusBarColor(1, 3/5, 0)
	-- eclipseBar.LunarBar = lunarBar
	
	-- local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
	-- solarBar:Point('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
	-- solarBar:SetSize(cfg.widthP-42, 12)
	-- solarBar:SetStatusBarTexture(cfg.PPtex)
	-- solarBar:SetStatusBarColor(0, 0, 1)
	-- eclipseBar.SolarBar = solarBar

	-- local eclipseBarText = solarBar:CreateFontString(nil, 'OVERLAY')
	-- eclipseBarText:Point('CENTER', eclipseBar, 'CENTER', 0, 0)
	-- eclipseBarText:SetFont(cfg.NumbFont, cfg.NumbFS, "THINOUTLINE")
	-- self:Tag(eclipseBarText, '[eecc]')

	-- self.Glow.eclipseBar = CreateFrame("Frame", nil, eclipseBar)
	-- self.Glow.eclipseBar:Point("TOPLEFT", eclipseBar, "TOPLEFT", -5, 5)
	-- self.Glow.eclipseBar:Point("BOTTOMRIGHT", eclipseBar, "BOTTOMRIGHT", 5, -5)
	-- self.Glow.eclipseBar:SetBackdrop{edgeFile = cfg.glowtex2, edgeSize = 5, insets = {left = 3, right = 3, top = 3, bottom = 3}}
	-- self.Glow.eclipseBar:SetBackdropColor(0, 0, 0, 0)
	-- self.Glow.eclipseBar:SetBackdropBorderColor(0, 0, 0, 0.8)
			
	-- self.iconS = eclipseBar:CreateTexture(nil, 'OVERLAY')
	-- self.iconS:Point("LEFT", eclipseBar, "RIGHT", 4, 2)
	-- self.iconS:SetHeight(20)
	-- self.iconS:SetWidth(20)
	-- self.iconS:SetTexture(select(3,GetSpellInfo(48517)))
	-- self.iconS:SetVertexColor(unpack(cfg.trdcolor))

	-- self.iconL = eclipseBar:CreateTexture(nil, 'OVERLAY')
	-- self.iconL:Point("RIGHT", eclipseBar, "LEFT", -4, 2)
	-- self.iconL:SetHeight(20)
	-- self.iconL:SetWidth(20)
	-- self.iconL:SetTexture(select(3,GetSpellInfo(48518)))
	-- self.iconL:SetVertexColor(unpack(cfg.trdcolor))
			
	-- local bgl = CreateFrame("Frame", nil, eclipseBar)
	-- bgl:Point("TOPLEFT", self.iconL, "TOPLEFT", -10, 10)
	-- bgl:Point("BOTTOMRIGHT", self.iconL, "BOTTOMRIGHT", 10, -10)
	-- bgl:SetBackdrop{edgeFile = cfg.glowtex, edgeSize = 10, insets = {left = 3, right = 3, top = 3, bottom = 3}}
	-- bgl:SetBackdropColor(0,0,0,0)
	-- bgl:SetBackdropBorderColor(1,1,1,0)
			
	-- local bgs = CreateFrame("Frame", nil, eclipseBar)
	-- bgs:Point("TOPLEFT", self.iconS, "TOPLEFT", -10, 10)
	-- bgs:Point("BOTTOMRIGHT", self.iconS, "BOTTOMRIGHT", 10, -10)
	-- bgs:SetBackdrop{edgeFile = cfg.glowtex, edgeSize = 10, insets = {left = 3, right = 3, top = 3, bottom = 3}}
	-- bgs:SetBackdropColor(0,0,0,0)
	-- bgs:SetBackdropBorderColor(1,1,1,0)
			
	-- local eclipseBarSpark = solarBar:CreateFontString(nil, 'OVERLAY')
	-- eclipseBarSpark:SetFont(cfg.NumbFont, cfg.NumbFS+4, "THINOUTLINE")
			
	-- local eclipseBarBuff = function(self, unit)
		-- if self.hasSolarEclipse then
			-- self.bgs:SetBackdropBorderColor(1,1,1,1)
		-- elseif self.hasLunarEclipse then
			-- self.bgl:SetBackdropBorderColor(1,1,1,1)
		-- else
			-- self.bgs:SetBackdropBorderColor(1,1,1,0)
			-- self.bgl:SetBackdropBorderColor(1,1,1,0)
		-- end
		-- if(self.directionIsLunar) then
		-- eclipseBarSpark:Point('CENTER', eclipseBar, 'LEFT', 18, -1)
		-- eclipseBarSpark:SetText(">>>")
		-- else
		-- eclipseBarSpark:Point('CENTER', eclipseBar, 'RIGHT', -12, -1)
		-- eclipseBarSpark:SetText("<<<")
		-- end
	-- end
	-- eclipseBar.bgs = bgs
	-- eclipseBar.bgl = bgl
	-- self.EclipseBar = eclipseBar
	-- self.EclipseBar.PostUnitAura = eclipseBarBuff
-- end

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
--Tukui\Tukui\modules\unitframes\core\oUF\elements\cmEclipse.lua

-- if(select(2, UnitClass('player')) ~= 'DRUID') then return end

-- local parent, ns = ...
-- local oUF = ns.oUF

-- local ECLIPSE_BAR_SOLAR_BUFF_ID = ECLIPSE_BAR_SOLAR_BUFF_ID
-- local ECLIPSE_BAR_LUNAR_BUFF_ID = ECLIPSE_BAR_LUNAR_BUFF_ID
-- local SPELL_POWER_ECLIPSE = SPELL_POWER_ECLIPSE
-- local MOONKIN_FORM = MOONKIN_FORM

-- local UNIT_POWER = function(self, event, unit, powerType)
	-- if(self.unit ~= unit or (event == 'UNIT_POWER' and powerType ~= 'ECLIPSE')) then return end

	-- local eb = self.cmEclipse

	-- local power = UnitPower('player', SPELL_POWER_ECLIPSE)
	-- local maxPower = UnitPowerMax('player', SPELL_POWER_ECLIPSE)

	-- if(eb.cmLunar) then
		-- eb.cmLunar:SetMinMaxValues(-maxPower, maxPower)
		-- eb.cmLunar:SetValue(power)
	-- end

	-- if(eb.cmSolar) then
		-- eb.cmSolar:SetMinMaxValues(-maxPower, maxPower)
		-- eb.cmSolar:SetValue(power * -1)
	-- end

	-- if(eb.PostUpdatePower) then
		-- return eb:PostUpdatePower(unit)
	-- end
-- end

-- local UPDATE_VISIBILITY = function(self, event)
	-- local eb = self.cmEclipse

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

	-- local eb = self.cmEclipse
	-- eb.hasSolarEclipse = hasSolarEclipse
	-- eb.hasLunarEclipse = hasLunarEclipse

	-- if(eb.PostUnitAura) then
		-- return eb:PostUnitAura(unit)
	-- end
-- end

-- local ECLIPSE_DIRECTION_CHANGE = function(self, event, isLunar)
	-- local eb = self.cmEclipse

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
	-- local eb = self.cmEclipse
	-- if(eb) then
		-- eb.__owner = self
		-- eb.ForceUpdate = ForceUpdate

		-- if(eb.cmLunar and not eb.cmLunar:GetStatusBarTexture()) then
			-- eb.cmLunar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		-- end
		-- if(eb.cmSolar and not eb.cmSolar:GetStatusBarTexture()) then
			-- eb.cmSolar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
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
	-- local eb = self.cmEclipse
	-- if(eb) then
		-- self:UnregisterEvent('ECLIPSE_DIRECTION_CHANGE', ECLIPSE_DIRECTION_CHANGE)
		-- self:UnregisterEvent('PLAYER_TALENT_UPDATE', UPDATE_VISIBILITY)
		-- self:UnregisterEvent('UNIT_AURA', UNIT_AURA)
		-- self:UnregisterEvent('UNIT_POWER', UNIT_POWER)
		-- self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM', UPDATE_VISIBILITY)
	-- end
-- end

-- oUF:AddElement('cmEclipse', Update, Enable, Disable)

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
	-- local eb = self.cmEclipse
	-- local dm = self.DruidMana
	-- local txt = self.cmEclipse.Text
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
			-- if buffs then buffs:Point("TOPLEFT", self, "TOPLEFT", 0, 34) end
		-- else
			-- if buffs then buffs:Point("TOPLEFT", self, "TOPLEFT", 0, 38) end
		-- end				
	-- else
		-- txt:Hide()
		-- flash:Show()
		-- shadow:Point("TOPLEFT", -4, 4)
		-- bg:SetAlpha(0)
		-- if T.lowversion then
			-- if buffs then buffs:Point("TOPLEFT", self, "TOPLEFT", 0, 26) end
		-- else
			-- if buffs then buffs:Point("TOPLEFT", self, "TOPLEFT", 0, 30) end
		-- end
	-- end
-- end