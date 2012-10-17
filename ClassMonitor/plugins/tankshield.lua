-- Tank shield plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

local cfg = {
	["WARRIOR"] = 112048, -- Shield Wall
	["MONK"] = 115295, -- Guard
	["DEATHKNIGHT"] = 77535, -- Blood Shield
	["PALADIN"] = 65148, -- Sacred Shield
}

local _, class = UnitClass("player")
if not cfg[class] then return end
local spellName = GetSpellInfo(cfg[class])
if not spellName then return end

local ToClock = Engine.ToClock
local CheckSpec = Engine.CheckSpec

-- Method to create tank shield monitor
Engine.CreateTankShieldMonitor = function(name, enable, autohide, anchor, width, height, text, color, specs)
	local cmTSM = CreateFrame("Frame", name, UI.BattlerHider)
	cmTSM:SetTemplate()
	cmTSM:SetFrameStrata("BACKGROUND")
	cmTSM:Size(width, height)
	cmTSM:Point(unpack(anchor))
	cmTSM:Hide()

	cmTSM.status = CreateFrame("StatusBar", name.."_status", cmTSM)
	cmTSM.status:SetStatusBarTexture(UI.NormTex)
	cmTSM.status:SetFrameLevel(6)
	cmTSM.status:Point("TOPLEFT", cmTSM, "TOPLEFT", 2, -2)
	cmTSM.status:Point("BOTTOMRIGHT", cmTSM, "BOTTOMRIGHT", -2, 2)
	cmTSM.status:SetStatusBarColor(unpack(color))
	cmTSM.status:SetMinMaxValues(0, 1)

	cmTSM.valueText = UI.SetFontString(cmTSM.status, 12)
	cmTSM.valueText:Point("CENTER", cmTSM.status)

	if text == true then
		cmTSM.durationText = UI.SetFontString(cmTSM.status, 12)
		cmTSM.durationText:Point("RIGHT", cmTSM.status)
	end

	if not enable then
		cmTSM:Hide()
		return
	end

	cmTSM.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		cmTSM.timeSinceLastUpdate = cmTSM.timeSinceLastUpdate + elapsed
		if cmTSM.timeSinceLastUpdate > 0.2 then
			local timeLeft = cmTSM.expirationTime - GetTime()
			if timeLeft > 0 then
				cmTSM.status:SetValue(timeLeft)
				if text then
					cmTSM.durationText:SetText(ToClock(timeLeft))
				end
			else
				cmTSM.status:SetValue(0)
				if text then
					cmTSM.durationText:SetText("")
				end
			end
		end
	end

	cmTSM:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmTSM:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmTSM:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmTSM:RegisterUnitEvent("UNIT_AURA", "player")
	cmTSM:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmTSM:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		local found = false
		if CheckSpec(specs) and visible then
			local name, _, _, _, _, duration, expirationTime, unitCaster, _, _, _, _, _, _, value1, value2, value3 = UnitBuff("player", spellName)
			--print(tostring(spellName).."=>"..tostring(name).."  "..tostring(duration).."  "..tostring(expirationTime).."  "..tostring(unitCaster).."  "..tostring(value1).."  "..tostring(value2).."  "..tostring(value3))
			if name == spellName and unitCaster == "player" and value1 ~= nil and value1 > 0 then
				cmTSM.status:SetValue(duration)
				cmTSM.status:SetMinMaxValues(0, duration)
				cmTSM.valueText:SetText(tostring(value1))
				cmTSM.expirationTime = expirationTime -- save to use in OnUpdate
				cmTSM:Show()
				found = true
			end
		end
		if not found then
			cmTSM:Hide()
		end
	end)

	-- This is what stops constant OnUpdate
	cmTSM:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)
	cmTSM:SetScript("OnHide", function (self)
		self:SetScript("OnUpdate", nil)
	end)

	-- If autohide is not set, show frame
	if autohide ~= true then
		if cmTSM:IsShown() then
			cmTSM:SetScript("OnUpdate", OnUpdate)
		else
			cmTSM:Show()
		end
	end

	return cmTSM
end