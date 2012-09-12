-- Resource Plugin
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

function Engine:CreateHealthMonitor(name, text, autohide, anchor, width, height, colors, spec)
	local cmHealth = CreateFrame("Frame", name, TukuiPetBattleHider)
	--cmHealth:CreatePanel("Default", width , height, unpack(anchor))
	cmHealth:SetTemplate()
	cmHealth:SetFrameStrata("BACKGROUND")
	cmHealth:Size(width, height)

	cmHealth.status = CreateFrame("StatusBar", "cmHealthStatus", cmHealth)
	cmHealth.status:SetStatusBarTexture(C.media.normTex)
	cmHealth.status:SetFrameLevel(6)
	--cmHealth.status:SetStatusBarColor(unpack(color)) color will be set later
	cmHealth.status:Point("TOPLEFT", cmHealth, "TOPLEFT", 2, -2)
	cmHealth.status:Point("BOTTOMRIGHT", cmHealth, "BOTTOMRIGHT", -2, 2)
	cmHealth.status:SetMinMaxValues(0, UnitHealthMax("player"))

	if text == true then
		cmHealth.text = cmHealth.status:CreateFontString(nil, "OVERLAY")
		cmHealth.text:SetFont(C.media.uffont, 12)
		cmHealth.text:Point("CENTER", cmHealth.status)
		cmHealth.text:SetShadowColor(0, 0, 0)
		cmHealth.text:SetShadowOffset(1.25, -1.25)
	end

	cmHealth.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		cmHealth.timeSinceLastUpdate = cmHealth.timeSinceLastUpdate + elapsed
		if cmHealth.timeSinceLastUpdate > 0.2 then
			local value = UnitHealth("player")
			cmHealth.status:SetValue(value)
			if text == true then
				local valueMax = UnitHealthMax("player")
				if value == valueMax then
					if value > 10000 then
						cmHealth.text:SetFormattedText("%.1fk", value/1000)
					else
						cmHealth.text:SetText(value)
					end
				else
					local percentage = (value * 100) / valueMax
					if value > 10000 then
						cmHealth.text:SetFormattedText("%2d%% - %.1fk", percentage, value/1000 )
					else
						cmHealth.text:SetFormattedText("%2d%% - %u", percentage, value )
					end
				end
			end
			cmHealth.timeSinceLastUpdate = 0
		end
	end

	cmHealth:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmHealth:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmHealth:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmHealth:RegisterUnitEvent("UNIT_HEALTH", "player")
	cmHealth:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
	cmHealth:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	--cmHealth:SetScript("OnEvent", function(self, event, arg1)
	cmHealth:SetScript("OnEvent", function(self, event)
		if spec ~= "any" and spec ~= GetSpecialization() then
			cmHealth:Hide()
			return
		end

		--if event == "PLAYER_ENTERING_WORLD" or ((event == "UNIT_MAXHEALTH" or event == "PLAYER_SPECIALIZATION_CHANGED") and arg1 == "player") then
		if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_MAXHEALTH" or event == "PLAYER_SPECIALIZATION_CHANGED" then
			local valueMax = UnitHealthMax("player")
			local color = (colors and (colors[resourceName] or colors[1])) or T.UnitColor.power[resourceName] or T.UnitColor.class[T.myclass]
			cmHealth.status:SetStatusBarColor(unpack(color))
			cmHealth.status:SetMinMaxValues(0, valueMax)
			cmHealth:Show()
		end
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" then
				cmHealth:Show()
			elseif event == "UNIT_HEALTH" then
				if InCombatLockdown() then
					cmHealth:Show()
				end
			else
				cmHealth:Hide()
			end
		end
	end)

	-- This is what stops constant OnUpdate
	cmHealth:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)
	cmHealth:SetScript("OnHide", function (self)
		self:SetScript("OnUpdate", nil)
	end)

	-- If autohide is not set, show frame
	if autohide ~= true then
		if cmHealth:IsShown() then
			cmHealth:SetScript("OnUpdate", OnUpdate)
		else
			cmHealth:Show()
		end
	end
	
	return cmHealth
end