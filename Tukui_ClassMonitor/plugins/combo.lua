-- Combo Points plugin
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

function Engine:CreateComboMonitor(name, anchor, width, height, spacing, colors, filled, spec)
	local cmCombos = {}
	for i = 1, 5 do
		local cmCombo = CreateFrame("Frame", name, TukuiPetBattleHider) -- name is used for 1st power point
		cmCombo:SetTemplate()
		cmCombo:SetFrameStrata("BACKGROUND")
		cmCombo:Size(width, height)
		if i == 1 then
			cmCombo:Point(unpack(anchor))
		else
			cmCombo:Point("LEFT", cmCombos[i-1], "RIGHT", spacing, 0)
		end
		if filled then
			cmCombo.status = CreateFrame("StatusBar", name.."_status_"..i, cmCombo)
			cmCombo.status:SetStatusBarTexture(C.media.normTex)
			cmCombo.status:SetFrameLevel(6)
			cmCombo.status:Point("TOPLEFT", cmCombo, "TOPLEFT", 2, -2)
			cmCombo.status:Point("BOTTOMRIGHT", cmCombo, "BOTTOMRIGHT", -2, 2)
			cmCombo.status:SetStatusBarColor(unpack(colors[i]))
		else
			cmCombo:CreateShadow("Default")
			cmCombo:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmCombo:Hide()

		tinsert(cmCombos, cmCombo)
	end

	cmCombos[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmCombos[1]:RegisterUnitEvent("UNIT_COMBO_POINTS", "player")
	cmCombos[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmCombos[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmCombos[1]:SetScript("OnEvent", function(self, event)
		local points = GetComboPoints("player", "target")
		if points and points > 0 and (spec == "any" or spec == GetSpecialization()) then
			for i = 1, points do cmCombos[i]:Show() end
			for i = points+1, 5 do cmCombos[i]:Hide() end
		else
			for i = 1, 5 do cmCombos[i]:Hide() end
		end
	end)

	return cmCombos[1]
end