-- Aura plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

local ToClock = Engine.ToClock
local CheckSpec = Engine.CheckSpec

-- Generic method to create BUFF/DEBUFF bar monitor
Engine.CreateBarAuraMonitor = function(name, enable, autohide, unit, spellID, filter, count, anchor, width, height, color, text, duration, specs)
	local aura = GetSpellInfo(spellID)
	local cmAM = CreateFrame("Frame", name, UI.BattlerHider)
	cmAM:SetTemplate()
	cmAM:SetFrameStrata("BACKGROUND")
	cmAM:Size(width, height)
	cmAM:Point(unpack(anchor))
	cmAM:Hide()

	cmAM.status = CreateFrame("StatusBar", name.."_status", cmAM)
	cmAM.status:SetStatusBarTexture(UI.NormTex)
	cmAM.status:SetFrameLevel(6)
	cmAM.status:Point("TOPLEFT", cmAM, "TOPLEFT", 2, -2)
	cmAM.status:Point("BOTTOMRIGHT", cmAM, "BOTTOMRIGHT", -2, 2)
	cmAM.status:SetStatusBarColor(unpack(color))
	cmAM.status:SetMinMaxValues(0, count)

	if text == true then
		cmAM.valueText = UI.SetFontString(cmAM.status, 12)
		cmAM.valueText:Point("CENTER", cmAM.status)
	end

	if duration == true then
		cmAM.durationText = UI.SetFontString(cmAM.status, 12)
		cmAM.durationText:Point("RIGHT", cmAM.status)
	end

	if not enable then
		cmAM:Hide()
		return
	end

	cmAM.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		cmAM.timeSinceLastUpdate = cmAM.timeSinceLastUpdate + elapsed
		if cmAM.timeSinceLastUpdate > 0.2 then
			if duration == true then
				local timeLeft = cmAM.expirationTime - GetTime()
				if timeLeft > 0 then
					cmAM.durationText:SetText(ToClock(timeLeft))
				else
					cmAM.durationText:SetText("")
				end
			end
		end
	end

	cmAM:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmAM:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmAM:RegisterEvent("PLAYER_REGEN_ENABLED")
	if unit == "focus" then cmAM:RegisterEvent("PLAYER_FOCUS_CHANGED") end
	if unit == "target" then cmAM:RegisterEvent("PLAYER_TARGET_CHANGED") end
	if unit == "pet" then cmAM:RegisterUnitEvent("UNIT_PET", "player") end
	cmAM:RegisterUnitEvent("UNIT_AURA", unit)
	cmAM:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmAM:SetScript("OnEvent", function(self, event)
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
			for i = 1, 40, 1 do
				local name, _, _, stack, _, _, expirationTime, unitCaster = UnitAura(unit, i, filter)
				if not name then break end
				if name == aura and unitCaster == "player" and stack > 0 then
					cmAM.status:SetValue(stack)
					if text == true then
						cmAM.valueText:SetText(tostring(stack).."/"..tostring(count))
					end
					cmAM.expirationTime = expirationTime -- save to use in OnUpdate
					cmAM:Show()
					found = true
					break
				end
			end
		end
		if not found then
			cmAM:Hide()
		end
	end)

	-- This is what stops constant OnUpdate
	cmAM:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)
	cmAM:SetScript("OnHide", function (self)
		self:SetScript("OnUpdate", nil)
	end)

	-- If autohide is not set, show frame
	if autohide ~= true then
		if cmAM:IsShown() then
			cmAM:SetScript("OnUpdate", OnUpdate)
		else
			cmAM:Show()
		end
	end

	return cmAM
end