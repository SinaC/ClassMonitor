-- Power plugin
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

-- Ildyria: really nice idea but there are some bugs when a holypower fades out and when 3rd holypower is refreshed
-- should only be done if filled is true
-- should not check on SPELL_POWER_HOLY_POWER, should use an additional parameter 'timer'
-- general idea:  (possible transition  n -> n+1, n -> n-1, n -> 0, 0 -> 1   quid eternal glory (n->n)(should reset timer)
-- OnEvent
--		if previousPower == currentPower
--			show every power <= currentPower
--		else if previousPower < currentPower
--			hide every power > currentPower
--			show every power <= currentPower
--			set max value for previousPower
--			set timer to nil for previousPower (no timer)
--			set max timer for currentPower
--			set OnUpdate on currentPower
--		else -- if previousPower > currentPower
--			hide every power > previousPower
--			show every power <= previousPower
--			set max value for currentPower
--			set timer to nil for previousPower (no timer)
--			set max timer for currentPower
--			set OnUpdate on currentPower
-- OnUpdate
--		display value proportionnal to value
--		if timeLeft <= 0
--			hide
--			remove OnUpdate

function Engine:CreatePowerMonitor(name, powerType, count, anchor, width, height, spacing, colors, filled, spec)
	local cmPMs = {}

	for i = 1, count do
		local cmPM = CreateFrame("Frame", name, TukuiPetBattleHider) -- name is used for 1st power point
		--cmPM:CreatePanel("Default", width, height, unpack(anchor))
		cmPM:SetTemplate()
		cmPM:SetFrameStrata("BACKGROUND")
		cmPM:Size(width, height)
		if i == 1 then
			cmPM:Point(unpack(anchor))
		else
			cmPM:Point("LEFT", cmPMs[i-1], "RIGHT", spacing, 0)
		end
		if filled then
			cmPM.status = CreateFrame("StatusBar", name.."_status_"..i, cmPM)
			cmPM.status:SetStatusBarTexture(C.media.normTex)
			cmPM.status:SetFrameLevel(6)
			cmPM.status:Point("TOPLEFT", cmPM, "TOPLEFT", 2, -2)
			cmPM.status:Point("BOTTOMRIGHT", cmPM, "BOTTOMRIGHT", -2, 2)
			cmPM.status:SetStatusBarColor(unpack(colors[i]))
			-- if(powerType == SPELL_POWER_HOLY_POWER) then
				-- cmPM.status:SetMinMaxValues(0, 10)
				-- cmPM.status:SetValue(10)
			-- end
		else
			cmPM:CreateShadow("Default")
			cmPM:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmPM:Hide()
		--cmPM.timeleft = 0

		tinsert(cmPMs, cmPM)
	end

	cmPMs.maxValue = count
	cmPMs.totalWidth = width * count + spacing * (count - 1)

	cmPMs[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmPMs[1]:RegisterUnitEvent("UNIT_POWER", "player")
	cmPMs[1]:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	cmPMs[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	--cmPMs[1]:SetScript("OnEvent", function(self, event, arg1)
	cmPMs[1]:SetScript("OnEvent", function(self, event)
		--if (event == "UNIT_POWER" or event == "UNIT_MAXPOWER" or event == "PLAYER_SPECIALIZATION_CHANGED") and arg1 ~= "player" then return end

		if spec ~= "any" and spec ~= GetSpecialization() then
			for i = 1, count do cmPMs[i]:Hide() end
			return
		end

		local value = UnitPower("player", powerType)
		local maxValue = UnitPowerMax("player", powerType)
--print("Value:"..tostring(powerType).."  "..tostring(value).."/"..tostring(maxValue).."  "..tostring(cmPMs.maxValue).."  "..tostring(count))

		if maxValue ~= cmPMs.maxValue and maxValue <= count then
--print("resize")
			-- hide points
			for i = 1, count do
				cmPMs[i]:Hide()
			end
			-- resize points
			local width = (cmPMs.totalWidth - maxValue * spacing) / maxValue
			for i = 1, maxValue do
				cmPMs[i]:Size(width, height)
			end
			cmPMs.maxValue = maxValue
		end
		if value and value > 0 then
			for i = 1, value do cmPMs[i]:Show() end
			for i = value+1, count do cmPMs[i]:Hide() end
		else
			for i = 1, count do cmPMs[i]:Hide() end
		end
		--for i = 1, count do cmPMs[i]:Show() end
	end)

	return cmPMs[1]
end