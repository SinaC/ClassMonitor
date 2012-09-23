-- Aura plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI
local UIConfig = Engine.UIConfig

-- Generic method to create BUFF/DEBUFF monitor
Engine.CreateAuraMonitor = function(name, unit, spellID, filter, count, anchor, width, height, spacing, colors, filled, specs)
	local aura = GetSpellInfo(spellID)
	local cmAMs = {}
	for i = 1, count do
		local cmAM = CreateFrame("Frame", name, UI.BattlerHider) -- name is used for 1st power point
		cmAM:SetTemplate()
		cmAM:SetFrameStrata("BACKGROUND")
		cmAM:Size(width, height)
		if i == 1 then
			cmAM:Point(unpack(anchor))
		else
			cmAM:Point("LEFT", cmAMs[i-1], "RIGHT", spacing, 0)
		end
		if filled then
			cmAM.status = CreateFrame("StatusBar", name.."_status_"..i, cmAM)
			cmAM.status:SetStatusBarTexture(UI.NormTex)
			cmAM.status:SetFrameLevel(6)
			cmAM.status:Point("TOPLEFT", cmAM, "TOPLEFT", 2, -2)
			cmAM.status:Point("BOTTOMRIGHT", cmAM, "BOTTOMRIGHT", -2, 2)
			cmAM.status:SetStatusBarColor(unpack(colors[i]))
		else
			if UIConfig.shadow then
				cmAM:CreateShadow("Default")
			end
			cmAM:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmAM:Hide()

		tinsert(cmAMs, cmAM)
	end

	local CheckSpec = Engine.CheckSpec
	cmAMs[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmAMs[1]:RegisterEvent("PLAYER_FOCUS_CHANGED")
	cmAMs[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmAMs[1]:RegisterUnitEvent("UNIT_AURA", unit)
	cmAMs[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmAMs[1]:SetScript("OnEvent", function(self, event)
		local found = false
		if CheckSpec(specs) then
			for i = 1, 40, 1 do
				local name, _, _, stack, _, _, _, unitCaster = UnitAura(unit, i, filter)
				if not name then break end
				if name == aura and unitCaster == "player" and stack > 0 then
					for i = 1, stack do cmAMs[i]:Show() end
					for i = stack+1, count do cmAMs[i]:Hide() end
					found = true
					break
				end
			end
		end
		if found == false then
			for i = 1, count do cmAMs[i]:Hide() end
		end
	end)

	return cmAMs[1]
end

Engine.CreateBarAuraMonitor = function(name, unit, spellID, filter, count, anchor, width, height, color, text, duration, specs)
	local aura = GetSpellInfo(spellID)
	local cmAM = CreateFrame("Frame", name, UI.BattlerHider)
	cmAM:SetTemplate()
	cmAM:SetFrameStrata("BACKGROUND")
	cmAM:Size(width, height)
	cmAM:Point(unpack(anchor))
	cmAM:Hide()

	cmAM.status = CreateFrame("StatusBar", name.."_status", cmAM)
	cmAM.status:SetStatusBarTexture(UI.NormTex)
	cmAM.status:SetFrameLevel(6)
	cmAM.status:Point("TOPLEFT", cmAM, "TOPLEFT", 2, -2)
	cmAM.status:Point("BOTTOMRIGHT", cmAM, "BOTTOMRIGHT", -2, 2)
	cmAM.status:SetStatusBarColor(unpack(color))
	cmAM.status:SetMinMaxValues(0, count)

	if text == true then
		cmAM.valueText = UI.SetFontString(cmAM.status, 12)
		cmAM.valueText:Point("CENTER", cmAM.status)
	end

	if duration == true then
		cmAM.durationText = UI.SetFontString(cmAM.status, 12)
		cmAM.durationText:Point("RIGHT", cmAM.status)
	end

	local ToClock = Engine.ToClock
	cmAM.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		cmAM.timeSinceLastUpdate = cmAM.timeSinceLastUpdate + elapsed
		if cmAM.timeSinceLastUpdate > 0.2 then
			if duration == true then
				local timeLeft = cmAM.expirationTime - GetTime()
				if timeLeft > 0 then
					cmAM.durationText:SetText(ToClock(timeLeft))
				else
					cmAM.durationText:SetText("")
				end
			end
		end
	end

	local CheckSpec = Engine.CheckSpec
	cmAM:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmAM:RegisterUnitEvent("UNIT_AURA", unit)
	cmAM:RegisterEvent("PLAYER_FOCUS_CHANGED")
	cmAM:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmAM:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmAM:SetScript("OnEvent", function(self, event)
		local found = false
		if CheckSpec(specs) then
			for i = 1, 40, 1 do
				local name, _, _, stack, _, _, expirationTime, unitCaster = UnitAura(unit, i, filter)
				if not name then break end
				if name == aura and unitCaster == "player" and stack > 0 then
					cmAM.status:SetValue(stack)
					if text == true then
						cmAM.valueText:SetText(tostring(stack).."/"..tostring(count))
					end
					cmAM.expirationTime = expirationTime -- save to use in OnUpdate
					cmAM:Show()
					found = true
					break
				end
			end
		end
		if not found then
			cmAM:Hide()
		end
	end)

	-- This is what stops constant OnUpdate
	cmAM:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)
	cmAM:SetScript("OnHide", function (self)
		self:SetScript("OnUpdate", nil)
	end)

	return cmAM
end