-- Burning Embers plugin
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

function Engine:CreateBurningEmbersMonitor(name, anchor, width, height, spacing, colors)
--print("CreateBurningEmbersMonitor")
	local cmBEMs = {}
	local count = 4 -- max embers
	for i = 1, count do
		local cmBEM = CreateFrame("Frame", name, TukuiPetBattleHider) -- name is used for 1st power point
		--cmBEM:CreatePanel("Default", width, height, unpack(anchor))
		cmBEM:SetTemplate()
		cmBEM:SetFrameStrata("BACKGROUND")
		cmBEM:Size(width, height)
		if i == 1 then
			cmBEM:Point(unpack(anchor))
		else
			cmBEM:Point("LEFT", cmBEMs[i-1], "RIGHT", spacing, 0)
		end
		cmBEM.status = CreateFrame("StatusBar", name.."_status_"..i, cmBEM)
		cmBEM.status:SetStatusBarTexture(C.media.normTex)
		cmBEM.status:SetFrameLevel(6)
		cmBEM.status:Point("TOPLEFT", cmBEM, "TOPLEFT", 2, -2)
		cmBEM.status:Point("BOTTOMRIGHT", cmBEM, "BOTTOMRIGHT", -2, 2)
		cmBEM.status:SetStatusBarColor(unpack(colors[i]))
		cmBEM:Hide()

		tinsert(cmBEMs, cmBEM)
	end

	cmBEMs.numBars = count
	cmBEMs.totalWidth = width * count + spacing * (count - 1)

	cmBEMs[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmBEMs[1]:RegisterUnitEvent("UNIT_POWER", "player")
	cmBEMs[1]:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	cmBEMs[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	--cmBEMs[1]:SetScript("OnEvent", function(self, event, arg1)
	cmBEMs[1]:SetScript("OnEvent", function(self, event)
		--if (event == "UNIT_POWER" or event == "UNIT_MAXPOWER" or event == "PLAYER_SPECIALIZATION_CHANGED") and arg1 ~= "player" then return end

		local spec = GetSpecialization()
		if spec ~= SPEC_WARLOCK_DESTRUCTION then
			for i = 1, count do cmBEMs[i]:Hide() end
			return
		end

		local value = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)
		local maxValue = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true)
		local numBars = floor(maxValue / MAX_POWER_PER_EMBER)
--print("Value:"..tostring(value).."/"..tostring(numBars).."  "..tostring(cmBEMs.numBars).."  "..tostring(count))

		if numBars ~= cmBEMs.numBars and numBars <= count then
--print("resize")
			-- hide bars
			for i = 1, count do
				cmBEMs[i]:Hide()
			end
			-- resize bars
			local width = (cmBEMs.totalWidth - numBars * spacing) / numBars
			for i = 1, numBars do
				cmBEMs[i]:Size(width, height)
			end
			cmBEMs.numBars = numBars
		end
		for i = 1, numBars do
			cmBEMs[i].status:SetMinMaxValues((MAX_POWER_PER_EMBER * i) - MAX_POWER_PER_EMBER, MAX_POWER_PER_EMBER * i)
			cmBEMs[i].status:SetValue(value)
			cmBEMs[i]:Show()
		end
		--for i = 1, count do cmBEMs[i]:Show() end
	end)

	return cmBEMs[1]
end