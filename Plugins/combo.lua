-- Combo Points plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local O = CMOptions["combo"]
if O.enable ~= true then return end

local cmCombo = CreateFrame("Frame", "cmCombo", UIParent)
for i = 1, 5 do
	cmCombo[i] = CreateFrame("Frame", "cmCombo"..i, UIParent)
	if ( O.filled ) then
		cmCombo[i]:CreatePanel("Default", O.width, O.height, "CENTER", UIParent, "CENTER", 0, 0)
		cmCombo[i].sStatus = CreateFrame("StatusBar", "cmPMStatus"..spellID.."_"..i, cmCombo[i])
		cmCombo[i].sStatus:SetStatusBarTexture(C.media.normTex)
		cmCombo[i].sStatus:SetFrameLevel(6)
		cmCombo[i].sStatus:Point("TOPLEFT", cmCombo[i], "TOPLEFT", 2, -2)
		cmCombo[i].sStatus:Point("BOTTOMRIGHT", cmCombo[i], "BOTTOMRIGHT", -2, 2)
		cmCombo[i].sStatus:SetStatusBarColor(unpack(O.colors[i]))
	else
		cmCombo[i]:CreatePanel("Default", O.width, O.height, "CENTER", UIParent, "CENTER", 0, 0)
		cmCombo[i]:CreateShadow("Default")
		cmCombo[i]:SetBackdropBorderColor(unpack(O.colors[i]))
	end

	if i == 1 then
		cmCombo[i]:Point(unpack(O.anchor))
	else
		cmCombo[i]:Point("LEFT", cmCombo[i-1], "RIGHT", O.spacing, 0)
	end
end

cmCombo[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
cmCombo[1]:RegisterEvent("UNIT_COMBO_POINTS")
cmCombo[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
cmCombo[1]:SetScript("OnEvent", function()
	local points = GetComboPoints("player", "target")
	if points and points > 0 then
		for i = 1, points do cmCombo[i]:Show() end
		for i = points+1, 5 do cmCombo[i]:Hide() end
	else
		for i = 1, 5 do cmCombo[i]:Hide() end
	end
end)

SetMultipleAnchorHandler( cmCombo[1], O )