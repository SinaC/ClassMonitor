-- Eclipse plugin, credits to Tukz
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

local BorderColor = UI.BorderColor

-- Create eclipse monitor
Engine.CreateEclipseMonitor = function(name, enable, autohide, text, anchor, width, height, colors)
	local cmEclipse = CreateFrame("Frame", name, UI.BattlerHider)
	cmEclipse:SetTemplate()
	cmEclipse:SetFrameStrata("BACKGROUND")
	cmEclipse:Size(width, height)
	cmEclipse:Point(unpack(anchor))

	-- lunar status bar
	cmEclipse.lunar = CreateFrame("StatusBar", name.."_lunar", cmEclipse)
	cmEclipse.lunar:Point("TOPLEFT", cmEclipse, "TOPLEFT", 2, -2)
	cmEclipse.lunar:Size(width-4, height-4)
	cmEclipse.lunar:SetStatusBarTexture(UI.NormTex)
	cmEclipse.lunar:SetStatusBarColor(unpack(colors[1]))

	-- solar status bar
	cmEclipse.solar = CreateFrame("StatusBar", name.."_solar", cmEclipse)
	cmEclipse.solar:Point("LEFT", cmEclipse.lunar:GetStatusBarTexture(), "RIGHT", 0, 0) -- solar will move when lunar moves
	cmEclipse.solar:Size(width-4, height-4)
	cmEclipse.solar:SetStatusBarTexture(UI.NormTex)
	cmEclipse.solar:SetStatusBarColor(unpack(colors[2]))

	-- direction
	if text == true then
		cmEclipse.directionText = UI.SetFontString(cmEclipse.lunar, 12)
		cmEclipse.directionText:Point("CENTER", cmEclipse.lunar)
	end

	if not enable then
		cmEclipse:Hide()
		return
	end

	cmEclipse.inEclipse = false -- not in eclipse by default

	--
	cmEclipse:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmEclipse:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmEclipse:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmEclipse:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	cmEclipse:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	cmEclipse:RegisterUnitEvent("UNIT_POWER", "player")
	cmEclipse:RegisterUnitEvent("UNIT_AURA", "player")
	cmEclipse:SetScript("OnEvent", function(self, event, arg1, arg2)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		-- update visibility
		if (GetShapeshiftFormID() ~= MOONKIN_FORM and GetSpecialization() ~= 1) or not visible then -- visible if moonkin or balance
			cmEclipse:Hide()
			return
		end
		if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" or event == "PLAYER_REGEN_DISABLED"  then
			cmEclipse:UnregisterEvent("PLAYER_ENTERING_WORLD") -- fire only once
			cmEclipse:Show()
		end
		-- update lunar/solar power
		if (event == "UNIT_POWER" and arg2 == "ECLIPSE") or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" or event == "PLAYER_REGEN_DISABLED" then
			local power = UnitPower("player", SPELL_POWER_ECLIPSE)
			local maxPower = UnitPowerMax("player", SPELL_POWER_ECLIPSE)
			if maxPower == 0 then maxPower = 100 end -- when entering world at 1st connection, max power is 0
			cmEclipse.lunar:SetMinMaxValues(-maxPower, maxPower)
			cmEclipse.lunar:SetValue(power)
			cmEclipse.solar:SetMinMaxValues(-maxPower, maxPower)
			cmEclipse.solar:SetValue(power * -1)
		end
		-- update eclipse status
		if event == "UNIT_AURA" then 
			cmEclipse.inEclipse = false -- no eclipse
			for i = 1, 40, 1 do
				local name, _, _, _, _, _, _, _, _, _, spellID = UnitAura("player", i, "HELPFUL|PLAYER")
				if not name then break end
				if spellID == ECLIPSE_BAR_SOLAR_BUFF_ID then -- solar eclipse
					cmEclipse:SetBackdropBorderColor(unpack(colors[1]))
					cmEclipse.inEclipse = true
					break
				elseif spellID == ECLIPSE_BAR_LUNAR_BUFF_ID then -- lunar eclipse
					cmEclipse:SetBackdropBorderColor(unpack(colors[2]))
					cmEclipse.inEclipse = true
					break
				end
			end
			if not cmEclipse.inEclipse then
				cmEclipse:SetBackdropBorderColor(unpack(BorderColor))
			end
		end
		-- update text
		if text == true then
			if GetEclipseDirection() == "sun" then
				if cmEclipse.inEclipse then
					cmEclipse.directionText:SetText(">>>")
				else
					cmEclipse.directionText:SetText(">")
				end
			elseif GetEclipseDirection() == "moon" then
				if cmEclipse.inEclipse then
					cmEclipse.directionText:SetText("<<<")
				else
					cmEclipse.directionText:SetText("<")
				end
			else
				cmEclipse.directionText:SetText("")
			end
		end
	end)

	return cmEclipse
end

--http://www.wowinterface.com/forums/showthread.php?t=36129