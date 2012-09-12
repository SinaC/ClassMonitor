-- Dot Plugin
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

function Engine:CreateDotMonitor(name, spelltracked, anchor, width, height, colors, threshold, latency)

	local aura = GetSpellInfo(spelltracked)

	local cmDot = CreateFrame("Frame", name, TukuiPetBattleHider)
	--cmDot:CreatePanel("Default", width , height, unpack(anchor))
	cmDot:SetTemplate()
	cmDot:SetFrameStrata("BACKGROUND")
	cmDot:Size(width, height)
	cmDot:Point(unpack(anchor))

	cmDot.status = CreateFrame("StatusBar", "cmDotStatus", cmDot)
	cmDot.status:SetStatusBarTexture(C.media.normTex)
	cmDot.status:SetFrameLevel(6)
	-- cmDot.status:SetStatusBarColor(unpack(color)) -- color will be set later
	cmDot.status:Point("TOPLEFT", cmDot, "TOPLEFT", 2, -2)
	cmDot.status:Point("BOTTOMRIGHT", cmDot, "BOTTOMRIGHT", -2, 2)
	cmDot.status:SetMinMaxValues(0, UnitPowerMax("player"))

	cmDot.text = cmDot.status:CreateFontString(nil, "OVERLAY")
	cmDot.text:SetFont(C.media.uffont, 12)
	cmDot.text:Point("CENTER", cmDot.status)
	cmDot.text:SetShadowColor(0, 0, 0)
	cmDot.text:SetShadowOffset(1.25, -1.25)

	cmDot.dmg = 0
	cmDot.timeSinceLastUpdate = GetTime()

	local function OnUpdate(self, elapsed)
		cmDot.timeSinceLastUpdate = cmDot.timeSinceLastUpdate + elapsed
		if cmDot.timeSinceLastUpdate > 0.1 then
			local _, _, _, count, _, duration, expTime, _, _, _, _ = UnitAura("target", aura, nil, "PLAYER|HARMFUL")
			local remainTime = expTime - GetTime()
			local color
			if(latency and remainTime <= 1) then 
				color = {1,0,0,1}
			else
				if(threshold == 0) then
					color = (colors and (colors[1])) or T.UnitColor.class[T.myclass]
				elseif(threshold >= cmDot.dmg) then
					color = (colors and (colors[1])) or T.UnitColor.class[T.myclass]
				elseif(threshold >= cmDot.dmg) then
					color = (colors and (colors[2])) or T.UnitColor.class[T.myclass]
				else
					color = (colors and (colors[3])) or T.UnitColor.class[T.myclass]
				end
			end
			cmDot.status:SetStatusBarColor(unpack(color))
			cmDot.status:SetMinMaxValues(0, duration)
			cmDot.status:SetValue(remainTime)
			cmDot.text:SetText(cmDot.dmg)
			cmDot.timeSinceLastUpdate = 0
		end
	end

	cmDot.combatlogcheck = CreateFrame("Frame", "cmCombatLogCheck", cmDot)
	local function CombatLogCheck(WOWevent, ...)																-- Combat event handler
		local _, _, eventType, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, _, _, amount, _ = ...
		local pGUID = UnitGUID("player")
		local tGUID = UnitGUID("target")
		if sourceGUID == pGUID and destGUID == tGUID then
			if string.find(eventType, "_DAMAGE") and spellID == spelltracked then
				cmDot.dmg = amount
			end
		end
	end

	local function CombatCheck(self,event)																		-- Combat check function
		if event == "PLAYER_REGEN_DISABLED" then
			cmDot.combatlogcheck:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			cmDot.combatlogcheck:SetScript("OnEvent",CombatLogCheck)
		else
			cmDot.combatlogcheck:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			cmDot.combatlogcheck:SetScript("OnEvent",nil)
		end
	end

	cmDot.combatcheck = CreateFrame("Frame", "cmCombatCheck", cmDot)
	cmDot.combatcheck:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmDot.combatcheck:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmDot.combatcheck:SetScript("OnEvent", CombatCheck)

	local function CombatAuraCheck(self,event)																			-- Aura check
		local _, _, _, count, _, duration, expTime, _, _, _, _ = UnitAura("target", aura, nil, "PLAYER|HARMFUL")
		if expTime ~= nil then
			local remainTime = expTime - GetTime()
			if remainTime <= 0 then
				remainTime = 0
				cmDot:Hide()
				cmDot.dmg = 0
			end
			cmDot:Show()
		else
			cmDot:Hide()
			cmDot.dmg = 0
		end
	end

	cmDot.auracheck = CreateFrame("Frame", "cmAuraCheck", cmDot)
	cmDot.auracheck:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmDot.auracheck:RegisterEvent("UNIT_AURA")
	cmDot.auracheck:SetScript("OnEvent", CombatAuraCheck)

	cmDot.targetcheck = CreateFrame("Frame", "cmTargetCheck", cmDot)
	cmDot.targetcheck:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmDot.targetcheck:SetScript("OnEvent", function(self) cmDot:Hide() end)

	-- This is what stops constant OnUpdate
	cmDot:SetScript("OnShow", function(self) self:SetScript("OnUpdate", OnUpdate) end)
	cmDot:SetScript("OnHide", function (self) self:SetScript("OnUpdate", nil) end)
	
	return cmDot
end