-- Combo Points plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

Engine.CreateComboMonitor = function(name, anchor, width, height, spacing, colors, filled, specs)
	local cmCombos = {}
	for i = 1, 5 do
		local cmCombo = CreateFrame("Frame", name, UI.BattlerHider)
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
			cmCombo.status:SetStatusBarTexture(UI.NormTex)
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

	local CheckSpec = Engine.CheckSpec
	cmCombos[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmCombos[1]:RegisterUnitEvent("UNIT_COMBO_POINTS", "player")
	cmCombos[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmCombos[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmCombos[1]:SetScript("OnEvent", function(self, event)
		local points = GetComboPoints("player", "target")
		if points and points > 0 and CheckSpec(specs) then
			for i = 1, points do cmCombos[i]:Show() end
			for i = points+1, 5 do cmCombos[i]:Hide() end
		else
			for i = 1, 5 do cmCombos[i]:Hide() end
		end
	end)

	return cmCombos[1]
end