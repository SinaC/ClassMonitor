-- Aura plugin
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

-- Generic method to create BUFF/DEBUFF monitor
function Engine:CreateAuraMonitor(name, spellID, filter, count, anchor, width, height, spacing, colors, filled, spec)
	local aura = GetSpellInfo(spellID)
	local cmAMs = {}
	for i = 1, count do
		local cmAM = CreateFrame("Frame", name, TukuiPetBattleHider) -- name is used for 1st power point
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
			cmAM.status:SetStatusBarTexture(C.media.normTex)
			cmAM.status:SetFrameLevel(6)
			cmAM.status:Point("TOPLEFT", cmAM, "TOPLEFT", 2, -2)
			cmAM.status:Point("BOTTOMRIGHT", cmAM, "BOTTOMRIGHT", -2, 2)
			cmAM.status:SetStatusBarColor(unpack(colors[i]))
		else
			cmAM:CreateShadow("Default")
			cmAM:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmAM:Hide()

		tinsert(cmAMs, cmAM)
	end

	cmAMs[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmAMs[1]:RegisterUnitEvent("UNIT_AURA", "player")
	cmAMs[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmAMs[1]:SetScript("OnEvent", function(self, event)
		local found = false
		if spec == "any" or spec == GetSpecialization() then
			for i = 1, 40, 1 do
				local name, _, _, stack, _, _, _, unitCaster = UnitAura("player", i, filter)
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

function Engine:CreateBarAuraMonitor(name, spellID, filter, count, anchor, width, height, color, text, duration, spec)
	local aura = GetSpellInfo(spellID)
	local cmAM = CreateFrame("Frame", name, TukuiPetBattleHider)
	cmAM:SetTemplate()
	cmAM:SetFrameStrata("BACKGROUND")
	cmAM:Size(width, height)
	cmAM:Point(unpack(anchor))
	cmAM:Hide()

	cmAM.status = CreateFrame("StatusBar", name.."_status", cmAM)
	cmAM.status:SetStatusBarTexture(C.media.normTex)
	cmAM.status:SetFrameLevel(6)
	cmAM.status:Point("TOPLEFT", cmAM, "TOPLEFT", 2, -2)
	cmAM.status:Point("BOTTOMRIGHT", cmAM, "BOTTOMRIGHT", -2, 2)
	cmAM.status:SetStatusBarColor(unpack(color))
	cmAM.status:SetMinMaxValues(0, count)

	if text == true then
		cmAM.valueText = cmAM.status:CreateFontString(nil, "OVERLAY")
		cmAM.valueText:SetFont(C.media.uffont, 12)
		cmAM.valueText:Point("CENTER", cmAM.status)
		cmAM.valueText:SetShadowColor(0, 0, 0)
		cmAM.valueText:SetShadowOffset(1.25, -1.25)
	end

	if duration == true then
		cmAM.durationText = cmAM.status:CreateFontString(nil, "OVERLAY")
		cmAM.durationText:SetFont(C.media.uffont, 12)
		cmAM.durationText:Point("RIGHT", cmAM.status)
		cmAM.durationText:SetShadowColor(0, 0, 0)
		cmAM.durationText:SetShadowOffset(1.25, -1.25)
	end

	local function ToClock(seconds)
		seconds = ceil(tonumber(seconds))
		if seconds <= 0  then
			return " "
		elseif seconds < 600 then
			local d, h, m, s = ChatFrame_TimeBreakDown(seconds)
			return format("%01d:%02d", m, s)
		elseif seconds < 3600 then
			local d, h, m, s = ChatFrame_TimeBreakDown(seconds);
			return format("%02d:%02d", m, s)
		else
			return "1 hr+"
		end
	end

	cmAM.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		cmAM.timeSinceLastUpdate = cmAM.timeSinceLastUpdate + elapsed
		if cmAM.timeSinceLastUpdate > 0.2 then
			if duration == true then
				local timeLeft = cmAM.expirationTime - GetTime()
				cmAM.durationText:SetText(ToClock(timeLeft))
			end
		end
	end

	cmAM:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmAM:RegisterUnitEvent("UNIT_AURA", "player")
	cmAM:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmAM:SetScript("OnEvent", function(self, event)
		local found = false
		if spec == "any" or spec == GetSpecialization() then
			for i = 1, 40, 1 do
				local name, _, _, stack, _, _, expirationTime, unitCaster = UnitAura("player", i, filter)
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