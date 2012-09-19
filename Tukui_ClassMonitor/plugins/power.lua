-- Power plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

Engine.CreatePowerMonitor = function(name, powerType, count, anchor, width, height, spacing, colors, filled, specs)
	local cmPMs = {}

	for i = 1, count do
		local cmPM = CreateFrame("Frame", name, Engine.BattlerHider) -- name is used for 1st power point
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
			cmPM.status:SetStatusBarTexture(Engine.NormTex)
			cmPM.status:SetFrameLevel(6)
			cmPM.status:Point("TOPLEFT", cmPM, "TOPLEFT", 2, -2)
			cmPM.status:Point("BOTTOMRIGHT", cmPM, "BOTTOMRIGHT", -2, 2)
			cmPM.status:SetStatusBarColor(unpack(colors[i]))
		else
			cmPM:CreateShadow("Default")
			cmPM:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmPM:Hide()
		tinsert(cmPMs, cmPM)
	end

	cmPMs.maxValue = count
	cmPMs.totalWidth = width * count + spacing * (count - 1)

	local CheckSpec = Engine.CheckSpec
	cmPMs[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmPMs[1]:RegisterUnitEvent("UNIT_POWER", "player")
	cmPMs[1]:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	cmPMs[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmPMs[1]:SetScript("OnEvent", function(self, event)
		if not CheckSpec(specs) then
			for i = 1, count do cmPMs[i]:Hide() end
			return
		end

		local value = UnitPower("player", powerType)
		local maxValue = UnitPowerMax("player", powerType)
		if maxValue ~= cmPMs.maxValue and maxValue <= count then
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
	end)

	return cmPMs[1]
end