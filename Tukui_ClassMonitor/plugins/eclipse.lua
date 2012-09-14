-- Eclipse plugin, credits to Tukz
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

function Engine:CreateEclipseMonitor(name, text, anchor, width, height, colors)
	local cmEclipse = CreateFrame("Frame", name, TukuiPetBattleHider)
	cmEclipse:SetTemplate()
	cmEclipse:SetFrameStrata("BACKGROUND")
	cmEclipse:Size(width, height)
	cmEclipse:Point(unpack(anchor))

	-- lunar status bar
	cmEclipse.lunar = CreateFrame("StatusBar", name.."_lunar", cmEclipse)
	cmEclipse.lunar:Point("TOPLEFT", cmEclipse, "TOPLEFT", 2, -2)
	cmEclipse.lunar:Size(width-4, height-4)
	cmEclipse.lunar:SetStatusBarTexture(C.media.normTex)
	cmEclipse.lunar:SetStatusBarColor(unpack(colors[1]))

	-- solar status bar
	cmEclipse.solar = CreateFrame("StatusBar", name.."_solar", cmEclipse)
	cmEclipse.solar:Point("LEFT", cmEclipse.lunar:GetStatusBarTexture(), "RIGHT", 0, 0) -- solar will move when lunar moves
	cmEclipse.solar:Size(width-4, height-4)
	cmEclipse.solar:SetStatusBarTexture(C.media.normTex)
	cmEclipse.solar:SetStatusBarColor(unpack(colors[2]))

	-- direction
	if text == true then
		cmEclipse.directionText = cmEclipse.lunar:CreateFontString(nil, "OVERLAY")
		cmEclipse.directionText:SetFont(C.media.uffont, 12)
		cmEclipse.directionText:Point("CENTER", cmEclipse.lunar)
		cmEclipse.directionText:SetShadowColor(0, 0, 0)
		cmEclipse.directionText:SetShadowOffset(1.25, -1.25)
	end

	cmEclipse.inEclipse = false -- not in eclipse by default

	--
	cmEclipse:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmEclipse:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	cmEclipse:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	cmEclipse:RegisterUnitEvent("UNIT_POWER", "player")
	cmEclipse:RegisterUnitEvent("UNIT_AURA", "player")
	cmEclipse:SetScript("OnEvent", function(self, event, arg1, arg2)
		-- update visibility
		if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM"  then
			cmEclipse:UnregisterEvent("PLAYER_ENTERING_WORLD") -- fire only once
			if GetShapeshiftFormID() == MOONKIN_FORM or GetSpecialization() == 1 then -- visible if moonkin or balance
				cmEclipse:Show()
			else
				cmEclipse:Hide()
			end
		end
		-- update lunar/solar power
		if (event == "UNIT_POWER" and arg2 == "ECLIPSE") or event == "PLAYER_ENTERING_WORLD" then
			local power = UnitPower("player", SPELL_POWER_ECLIPSE)
			local maxPower = UnitPowerMax("player", SPELL_POWER_ECLIPSE)
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
				cmEclipse:SetBackdropBorderColor(unpack(C.general.bordercolor))
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