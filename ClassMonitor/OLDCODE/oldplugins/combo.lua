-- Combo Points plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

local CheckSpec = Engine.CheckSpec
local PixelPerfect = Engine.PixelPerfect

-- Create combo points monitor
Engine.CreateComboMonitor = function(name, enable, autohide, anchor, totalWidth, height, colors, filled, specs)
	local count = 5
	local width, spacing = PixelPerfect(totalWidth, count)
	local cmCombos = {}
	for i = 1, count do
		local cmCombo = CreateFrame("Frame", name, UI.PetBattleHider)
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
			cmCombo:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmCombo:Hide()

		tinsert(cmCombos, cmCombo)
	end

	if not enable then
		for i = 1, count do cmCombos[i]:Hide() end
		return
	end


	cmCombos[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmCombos[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmCombos[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmCombos[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmCombos[1]:RegisterUnitEvent("UNIT_COMBO_POINTS", "player")
	cmCombos[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmCombos[1]:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		local points = GetComboPoints("player", "target")
		if visible and points and points > 0 and CheckSpec(specs) then
			for i = 1, points do cmCombos[i]:Show() end
			for i = points+1, count do cmCombos[i]:Hide() end
		else
			for i = 1, count do cmCombos[i]:Hide() end
		end
	end)

	return cmCombos[1]
end

--[[
Engine.CreateComboMonitor = function(name, enable, autohide, anchor, width, height, spacing, colors, filled, specs)
	local cmCombos = {}
	for i = 1, 5 do
		local cmCombo = CreateFrame("Frame", name, UI.PetBattleHider)
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
			cmCombo:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmCombo:Hide()

		tinsert(cmCombos, cmCombo)
	end

	if not enable then
		for i = 1, 5 do cmCombos[i]:Hide() end
		return
	end


	cmCombos[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmCombos[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmCombos[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmCombos[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmCombos[1]:RegisterUnitEvent("UNIT_COMBO_POINTS", "player")
	cmCombos[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmCombos[1]:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		local points = GetComboPoints("player", "target")
		if visible and points and points > 0 and CheckSpec(specs) then
			for i = 1, points do cmCombos[i]:Show() end
			for i = points+1, 5 do cmCombos[i]:Hide() end
		else
			for i = 1, 5 do cmCombos[i]:Hide() end
		end
	end)

	return cmCombos[1]
end
--]]