-- Combo Points plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

function CreateComboMonitor(name, anchor, width, height, spacing, colors, filled)
	local cmCombos = {}
	for i = 1, 5 do
		local cmCombo
		if i == 1 then
			cmCombo = CreateFrame("Frame", name, UIParent) -- name is used for 1st power point
			cmCombo:CreatePanel("Default", width, height, unpack(anchor))
		else
			cmCombo = CreateFrame("Frame", name.."_"..i, UIParent)
			cmCombo:CreatePanel("Default", width, height, "LEFT", cmCombos[i-1], "RIGHT", spacing, 0)
		end
		if ( filled ) then
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
	cmCombos[1]:RegisterEvent("UNIT_COMBO_POINTS")
	cmCombos[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmCombos[1]:SetScript("OnEvent", function(self, event)
		if event ~= "PLAYER_ENTERING_WORLD" and event ~= "UNIT_COMBO_POINTS" and event ~= "PLAYER_TARGET_CHANGED" then return end

		local points = GetComboPoints("player", "target")
		if points and points > 0 then
			for i = 1, points do cmCombos[i]:Show() end
			for i = points+1, 5 do cmCombos[i]:Hide() end
		else
			for i = 1, 5 do cmCombos[i]:Hide() end
		end
	end)

	return cmCombos[1]
end