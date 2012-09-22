-- Demonic Fury Plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

Engine.CreateDemonicFuryMonitor = function(name, text, autohide, anchor, width, height, colors)
	local cmDFM = CreateFrame("Frame", name, UI.BattlerHider)
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

	local PowerColor = UI.PowerColor
	local ClassColor = UI.ClassColor
	cmDFM:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmDFM:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
	cmDFM:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmDFM:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmDFM:RegisterUnitEvent("UNIT_POWER", "player")
	cmDFM:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	cmDFM:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmDFM:SetScript("OnEvent", function(self, event)
		local spec = GetSpecialization()
		if spec ~= SPEC_WARLOCK_DEMONOLOGY then
			cmDFM:Hide()
			return
		end

		if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" or event == "UNIT_MAXPOWER" or event == "PLAYER_SPECIALIZATION_CHANGED" then
			local valueMax = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)
			-- use colors[SPELL_POWER_DEMONIC_FURY] if defined, else use default resource color or class color
			local color = (colors and (colors[SPELL_POWER_DEMONIC_FURY] or colors[1])) or PowerColor(SPELL_POWER_DEMONIC_FURY) or ClassColor()
			cmDFM.status:SetStatusBarColor(unpack(color))
			cmDFM.status:SetMinMaxValues(0, valueMax)
			cmDFM:Show()
		end
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" then
				cmDFM:Show()
			elseif event == "UNIT_POWER" or event == "UNIT_MAXPOWER" then
				if InCombatLockdown() then
					cmDFM:Show()
				end
			else
				cmDFM:Hide()
			end
		end
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