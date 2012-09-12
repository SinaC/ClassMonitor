-- Demonic Fury Plugin
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

function Engine:CreateDemonicFuryMonitor(name, text, autohide, anchor, width, height, colors)
--print("CreateDemonicFuryMonitor")
	local cmDFM = CreateFrame("Frame", name, TukuiPetBattleHider)
	--cmDFM:CreatePanel("Default", width , height, unpack(anchor))
	cmDFM:SetTemplate()
	cmDFM:SetFrameStrata("BACKGROUND")
	cmDFM:Size(width, height)
	cmDFM:Point(unpack(anchor))

	cmDFM.status = CreateFrame("StatusBar", "cmDFMStatus", cmDFM)
	cmDFM.status:SetStatusBarTexture(C.media.normTex)
	cmDFM.status:SetFrameLevel(6)
	--cmDFM.status:SetStatusBarColor(unpack(color)) color will be set later
	cmDFM.status:Point("TOPLEFT", cmDFM, "TOPLEFT", 2, -2)
	cmDFM.status:Point("BOTTOMRIGHT", cmDFM, "BOTTOMRIGHT", -2, 2)
	cmDFM.status:SetMinMaxValues(0, UnitPowerMax("player"))

	if text == true then
		cmDFM.text = cmDFM.status:CreateFontString(nil, "OVERLAY")
		cmDFM.text:SetFont(C.media.uffont, 12)
		cmDFM.text:Point("CENTER", cmDFM.status)
		cmDFM.text:SetShadowColor(0, 0, 0)
		cmDFM.text:SetShadowOffset(1.25, -1.25)
	end

	cmDFM.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		cmDFM.timeSinceLastUpdate = cmDFM.timeSinceLastUpdate + elapsed
		if cmDFM.timeSinceLastUpdate > 0.2 then
			local value = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
--print("Value:"..value)
			cmDFM.status:SetValue(value)
			if text == true then
				cmDFM.text:SetText(value)
			end
			cmDFM.timeSinceLastUpdate = 0
		end
	end

	cmDFM:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmDFM:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
	cmDFM:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmDFM:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmDFM:RegisterUnitEvent("UNIT_POWER", "player")
	cmDFM:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	cmDFM:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	--cmDFM:SetScript("OnEvent", function(self, event, arg1)
	cmDFM:SetScript("OnEvent", function(self, event)

		local spec = GetSpecialization()
--print("Resource: event:"..event.."  "..tostring(spec).."  "..tostring(SPEC_WARLOCK_DEMONOLOGY))
		if spec ~= SPEC_WARLOCK_DEMONOLOGY then
			cmDFM:Hide()
			return
		end

		--if event == "PLAYER_ENTERING_WORLD" or ((event == "UNIT_DISPLAYPOWER" or event == "UNIT_MAXPOWER" or event == "PLAYER_SPECIALIZATION_CHANGED" ) and arg1 == "player") then
		if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" or event == "UNIT_MAXPOWER" or event == "PLAYER_SPECIALIZATION_CHANGED" then
			local valueMax = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)
			-- use colors[SPELL_POWER_DEMONIC_FURY] if defined, else use default resource color or class color
			local color = (colors and (colors[SPELL_POWER_DEMONIC_FURY] or colors[1])) or T.UnitColor.power[SPELL_POWER_DEMONIC_FURY] or T.UnitColor.class[T.myclass]
			cmDFM.status:SetStatusBarColor(unpack(color))
			cmDFM.status:SetMinMaxValues(0, valueMax)
			cmDFM:Show()
		end
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" then
				cmDFM:Show()
			elseif event == "UNIT_POWER" then
				if InCombatLockdown() then
					cmDFM:Show()
				end
			else
				cmDFM:Hide()
			end
		end
	end)

	-- This is what stops constant OnUpdate
	cmDFM:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)
	cmDFM:SetScript("OnHide", function (self)
		self:SetScript("OnUpdate", nil)
	end)

	-- If autohide is not set, show frame
	if autohide ~= true then
		if cmDFM:IsShown() then
			cmDFM:SetScript("OnUpdate", OnUpdate)
		else
			cmDFM:Show()
		end
	end
	
	return cmDFM
end