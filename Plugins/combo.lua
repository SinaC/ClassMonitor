-- Combo Points plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local O = CMOptions["combo"]
if O.enable ~= true then return end

local cmCombo = CreateFrame("Frame", "cmCombo", UIParent)
for i = 1, 5 do
	cmCombo[i] = CreateFrame("Frame", "cmCombo"..i, UIParent)
	cmCombo[i]:CreatePanel("Default", O.width, O.height, "CENTER", UIParent, "CENTER", 0, 0)
	cmCombo[i]:CreateShadow("Default")
	cmCombo[i]:SetBackdropBorderColor(unpack(O.colors[i]))

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