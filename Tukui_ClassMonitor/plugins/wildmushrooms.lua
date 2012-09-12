-- Wild Mushrooms plugin
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

function Engine:CreateWildMushroomsMonitor(name, anchor, width, height, spacing, colors)
--print("CreateWildMushroomsMonitor")
	local cmWMMs = {}
	for i = 1, 3 do
		local cmWMM = CreateFrame("Frame", name, TukuiPetBattleHider) -- name is used for 1st power point
		--cmWMM:CreatePanel("Default", width, height, unpack(anchor))
		cmWMM:SetTemplate()
		cmWMM:SetFrameStrata("BACKGROUND")
		cmWMM:Size(width, height)
		if i == 1 then
			cmWMM:Point(unpack(anchor))
		else
			cmWMM:Point("LEFT", cmWMMs[i-1], "RIGHT", spacing, 0)
		end
		cmWMM.status = CreateFrame("StatusBar", name.."_status_"..i, cmWMM)
		cmWMM.status:SetStatusBarTexture(C.media.normTex)
		cmWMM.status:SetFrameLevel(6)
		cmWMM.status:Point("TOPLEFT", cmWMM, "TOPLEFT", 2, -2)
		cmWMM.status:Point("BOTTOMRIGHT", cmWMM, "BOTTOMRIGHT", -2, 2)
		cmWMM.status:SetStatusBarColor(unpack(colors[i]))
		cmWMM.status:GetStatusBarTexture():SetHorizTile(false)
		cmWMM.status:SetMinMaxValues(0, 300)
		cmWMM.status:SetValue(0)
		cmWMM:Hide()

		tinsert(cmWMMs, cmWMM)
	end

	local function UpdateMushroomTimer(self, elapsed)
		if not self.status.expirationTime then return end
		self.status.expirationTime = self.status.expirationTime - elapsed

		local timeLeft = self.status.expirationTime
		if timeLeft > 0 then
			self.status:SetValue(timeLeft)
		else
			self:SetScript("OnUpdate", nil)
		end
	end

	cmWMMs[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmWMMs[1]:RegisterEvent("PLAYER_TOTEM_UPDATE")
	cmWMMs[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmWMMs[1]:SetScript("OnEvent", function(self, event)
--print("OnEvent:"..tostring(event))
		local spec = GetSpecialization()
		for i = 1, 3 do
			local cmWMM = cmWMMs[i]
			if spec == 1 or spec == 4 then -- Balance or Restoration
				local up, name, start, duration, icon = GetTotemInfo(i)
				if (up) then
					local timeLeft = (start+duration) - GetTime()
					cmWMM.status.duration = duration
					cmWMM.status.expirationTime = timeLeft
					cmWMM.status:SetMinMaxValues(0, duration)
					cmWMM:SetScript('OnUpdate', UpdateMushroomTimer)
					cmWMM:Show()
				else
					cmWMM.status:SetValue(0)
					cmWMM:SetScript("OnUpdate", nil)
					cmWMM:Hide()
				end
			else
				cmWMM:Hide()
			end
		end
	end)

	return cmWMMs[1]
end