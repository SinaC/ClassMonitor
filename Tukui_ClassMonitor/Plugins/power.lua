-- Power plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

-- Generic method to create POWER monitor
function CreatePowerMonitor(name, powerType, count, anchor, width, height, spacing, colors, filled)
	local cmPMs = {}
	for i = 1, count do
		local cmPM = CreateFrame("Frame", name, UIParent) -- name is used for 1st power point
		cmPM:CreatePanel("Default", width, height, unpack(anchor))
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
			if(powerType == SPELL_POWER_HOLY_POWER) then
				cmPM.status:SetStatusBarColor(unpack(colors[i]))
				cmPM.status:SetMinMaxValues(0, 10)
				cmPM.status:SetValue(10)
			end
		else
			cmPM:CreateShadow("Default")
			cmPM:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmPM:Hide()
		cmPM.timeleft = 0

		tinsert(cmPMs, cmPM)
	end

	cmPMs[1].value = 0

	cmPMs[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmPMs[1]:RegisterEvent("UNIT_POWER")
	cmPMs[1]:SetScript("OnEvent", function(self, event, arg1)
		if event ~= "UNIT_POWER" and event ~= "PLAYER_ENTERING_WORLD" then return end
		if event == "UNIT_POWER" and arg1 ~= "player" then return end

		local value = UnitPower("player", powerType)

		if filled and value and cmPMs[1].value ~= value then
			for i = 1, value do
				cmPMs[i].timeleft = 10
				cmPMs[i].status:SetValue(10)
			end
		end
		cmPMs[1].value = value

		if value and value > 0 then
			for i = 1, value do
				cmPMs[i]:Show()
			end
			for i = value+1, count do cmPMs[i]:Hide() end
		else
			for i = 1, count do cmPMs[i]:Hide() end
		end
	end)
	
	if filled and powerType == SPELL_POWER_HOLY_POWER then
		local timeSinceLastUpdate = 0
		local function OnUpdate(self, elapsed)
			local value = UnitPower("player", powerType)
			if elapsed then
				timeSinceLastUpdate = timeSinceLastUpdate + elapsed
			end
			if timeSinceLastUpdate > 0.1 then
				for i = 1, (value - 1) do
					cmPMs[i].timeleft = 10
				end
				if value > 0 then
					local timeleft = cmPMs[value].timeleft - timeSinceLastUpdate
					cmPMs[value].timeleft = timeleft
					cmPMs[value].status:SetValue(timeleft)
				end
				if value and cmPMs[value].timeleft <= 0 then
					cmPMs[value].timeleft = 10
				end
				timeSinceLastUpdate = 0
			end
		end
		cmPMs[1]:SetScript("OnUpdate", OnUpdate)
	end

	return cmPMs[1]
end