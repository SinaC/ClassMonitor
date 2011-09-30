-- Holy Power plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local O = CMOptions["holy"]
if O.enable ~= true then return end

CreatePowerMonitor( SPELL_POWER_HOLY_POWER, 3, O )

-- local cmHoly = CreateFrame("Frame", "cmHoly", UIParent)
-- for i = 1, 3 do
	-- cmHoly[i] = CreateFrame("Frame", "cmHoly"..i, UIParent)
	-- cmHoly[i]:CreatePanel("Default", O.width, O.height, "CENTER", UIParent, "CENTER", 0, 0)
	-- cmHoly[i].sStatus = CreateFrame("StatusBar", "cmHolyStatus"..i, cmHoly[i])
	-- cmHoly[i].sStatus:SetStatusBarTexture(C.media.normTex)
	-- cmHoly[i].sStatus:SetFrameLevel(6)
	-- cmHoly[i].sStatus:Point("TOPLEFT", cmHoly[i], "TOPLEFT", 2, -2)
	-- cmHoly[i].sStatus:Point("BOTTOMRIGHT", cmHoly[i], "BOTTOMRIGHT", -2, 2)
	-- cmHoly[i].sStatus:SetStatusBarColor(unpack(O.color))

	-- if i == 1 then
		-- cmHoly[i]:Point(unpack(O.anchor))
	-- else
		-- cmHoly[i]:Point("LEFT", cmHoly[i-1], "RIGHT", O.spacing, 0)
	-- end
-- end

-- cmHoly[1]:RegisterEvent("UNIT_POWER")
-- cmHoly[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
-- cmHoly[1]:SetScript("OnEvent", function()
	-- local holy = UnitPower("player", SPELL_POWER_HOLY_POWER)
	-- if holy and holy > 0 then
		-- for i = 1, holy do cmHoly[i]:Show() end
		-- for i = holy+1, 3 do cmHoly[i]:Hide() end
	-- else
		-- for i = 1, 3 do cmHoly[i]:Hide() end
	-- end
-- end)