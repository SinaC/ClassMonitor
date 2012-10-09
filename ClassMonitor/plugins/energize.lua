-- Energize Plugin, written by Ildyria
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

Engine.CreateEnergizeMonitor = function(name, spelltracked, anchor, width, height, color, duration, filling)
	local cmEnergize = CreateFrame("Frame", name, UI.BattlerHider)
	cmEnergize:SetTemplate()
	cmEnergize:SetFrameStrata("BACKGROUND")
	cmEnergize:Size(width, height)
	cmEnergize:Point(unpack(anchor))

	cmEnergize.status = CreateFrame("StatusBar", "cmEnergizeStatus", cmEnergize)
	cmEnergize.status:SetStatusBarTexture(UI.NormTex)
	cmEnergize.status:SetFrameLevel(6)
	cmEnergize.status:Point("TOPLEFT", cmEnergize, "TOPLEFT", 1, -1)
	cmEnergize.status:Point("BOTTOMRIGHT", cmEnergize, "BOTTOMRIGHT", -1, 1)
	cmEnergize.status:SetMinMaxValues(0, duration)
	cmEnergize.status:SetStatusBarColor(unpack(color))
	cmEnergize:Hide()

	cmEnergize.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		cmEnergize.timeSinceLastUpdate = cmEnergize.timeSinceLastUpdate + elapsed
		if cmEnergize.timeSinceLastUpdate > 0.05 then
			local timeLeft = cmEnergize.status:GetValue()
			if filling then
				cmEnergize.status:SetValue(timeLeft + cmEnergize.timeSinceLastUpdate)
			else
				cmEnergize.status:SetValue(timeLeft - cmEnergize.timeSinceLastUpdate)
			end
			if cmEnergize.status:GetValue() == 0 or cmEnergize.status:GetValue() == duration then cmEnergize:Hide() end
			cmEnergize.timeSinceLastUpdate = 0
		end
	end

	cmEnergize:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	cmEnergize:SetScript("OnEvent", function(self, event, arg1, ...)
		local  eventType, _,caster,_,_,_,target,_,_, _, spellID =...
		if eventType == "SPELL_ENERGIZE" and spellID == spelltracked and target == UnitGUID("player") and caster == UnitGUID("player") then 
			cmEnergize:Show()
			if filling then
				cmEnergize.status:SetValue(0)
			else
				cmEnergize.status:SetValue(duration)
			end
		elseif eventType == "SPELL_PERIODIC_ENERGIZE" and spellID == spelltracked and target == UnitGUID("player") then 
			cmEnergize:Show()
			if filling then
				cmEnergize.status:SetValue(0)
			else
				cmEnergize.status:SetValue(duration)
			end
		end
	end)

	-- This is what stops constant OnUpdate
	cmEnergize:SetScript("OnShow", function(self) self:SetScript("OnUpdate", OnUpdate) end)
	cmEnergize:SetScript("OnHide", function (self) self:SetScript("OnUpdate", nil) end)
	
	return cmEnergize
end