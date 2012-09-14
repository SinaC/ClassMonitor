-- Dot Plugin, credits to Ildyria
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

function Engine:CreateRegenMonitor(name, spelltracked, anchor, width, height, colors, duration, filling)

	local cmRegen = CreateFrame("Frame", name, TukuiPetBattleHider)
	cmRegen:SetTemplate()
	cmRegen:SetFrameStrata("BACKGROUND")
	cmRegen:Size(width, height)
	cmRegen:Point(unpack(anchor))

	cmRegen.status = CreateFrame("StatusBar", "cmRegenStatus", cmRegen)
	cmRegen.status:SetStatusBarTexture(C.media.normTex)
	cmRegen.status:SetFrameLevel(6)
	cmRegen.status:Point("TOPLEFT", cmRegen, "TOPLEFT", 1, -1)
	cmRegen.status:Point("BOTTOMRIGHT", cmRegen, "BOTTOMRIGHT", -1, 1)
	cmRegen.status:SetMinMaxValues(0, duration)
	cmRegen:Hide()

	local color = colors or T.UnitColor.class[T.myclass]
	cmRegen.status:SetStatusBarColor(unpack(color))

	cmRegen.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		cmRegen.timeSinceLastUpdate = cmRegen.timeSinceLastUpdate + elapsed
		if cmRegen.timeSinceLastUpdate > 0.05 then
			local remainTime = cmRegen.status:GetValue()
			if filling then
				cmRegen.status:SetValue(remainTime + cmRegen.timeSinceLastUpdate)
			else
				cmRegen.status:SetValue(remainTime - cmRegen.timeSinceLastUpdate)
			end
			if cmRegen.status:GetValue() == 0 or cmRegen.status:GetValue() == duration then cmRegen:Hide() end
			cmRegen.timeSinceLastUpdate = 0
		end
	end

	cmRegen:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	cmRegen:SetScript("OnEvent", function(self, event, arg1, ...)
		local  eventType, _,caster,_,_,_,target,_,_, _, spellID =...
		if eventType == "SPELL_ENERGIZE" and spellID == spelltracked and target == UnitGUID("player") and caster == UnitGUID("player") then 
			cmRegen:Show()
			if filling then
				cmRegen.status:SetValue(0)
			else
				cmRegen.status:SetValue(duration)
			end
		elseif eventType == "SPELL_PERIODIC_ENERGIZE" and spellID == spelltracked and target == UnitGUID("player") then 
			cmRegen:Show()
			if filling then
				cmRegen.status:SetValue(0)
			else
				cmRegen.status:SetValue(duration)
			end
		end
	end)

	-- This is what stops constant OnUpdate
	cmRegen:SetScript("OnShow", function(self) self:SetScript("OnUpdate", OnUpdate) end)
	cmRegen:SetScript("OnHide", function (self) self:SetScript("OnUpdate", nil) end)
	
	return cmRegen
end