-- Aura plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

local ToClock = Engine.ToClock
local CheckSpec = Engine.CheckSpec

-- Generic method to create CD bar monitor
Engine.CreateCDMonitor = function(name, enable, autohide, text, duration, spellID, anchor, width, height, color, specs)
	local spellName, _, spellIcon = GetSpellInfo(spellID)
--print("CreateCDMonitor:"..tostring(spellID).."->"..tostring(spellName).."  "..tostring(currentCharges).."  "..tostring(maxCharges).."  "..tostring(timeLastCast).."  "..tostring(cooldownDuration))

	local cmCD = CreateFrame("Frame", name, UI.PetBattleHider)
	cmCD:SetTemplate()
	cmCD:SetFrameStrata("BACKGROUND")
	cmCD:Size(width, height)
	cmCD:Point(unpack(anchor))
	cmCD:Hide()

	cmCD.status = CreateFrame("StatusBar", name.."_status", cmCD)
	cmCD.status:SetStatusBarTexture(UI.NormTex)
	cmCD.status:SetFrameLevel(6)
	cmCD.status:Point("TOPLEFT", cmCD, "TOPLEFT", 2, -2)
	cmCD.status:Point("BOTTOMRIGHT", cmCD, "BOTTOMRIGHT", -2, 2)
	cmCD.status:SetStatusBarColor(unpack(color))

	if text == true then
		cmCD.nameText = UI.SetFontString(cmCD.status, 12)
		cmCD.nameText:Point("CENTER", cmCD.status)
		cmCD.nameText:SetText(spellName)
	end

	if duration == true then
		cmCD.durationText = UI.SetFontString(cmCD.status, 12)
		cmCD.durationText:Point("RIGHT", cmCD.status)
	end

	if not enable then
		cmCD:Hide()
		return
	end

	cmCD.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
		if self.timeSinceLastUpdate > 0.2 then
			local timeLeft = self.expirationTime - GetTime()
			self.status:SetValue(timeLeft)
			if duration == true then
				if timeLeft > 0 then
					self.durationText:SetText(ToClock(timeLeft))
				else
					self.durationText:SetText("")
				end
			end
		end
	end

	cmCD:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmCD:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmCD:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmCD:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmCD:RegisterUnitEvent("SPELL_UPDATE_COOLDOWN")
	cmCD:SetScript("OnEvent", function(self, event)
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
			local start, duration, enabled = GetSpellCooldown(spellName)
			--local value1 = GetSpellBaseCooldown(spellID)
--print("UPDATE_COOLDOWN:"..tostring(spellName).."  "..tostring(start).."  "..tostring(duration))
			if start and duration and start > 0 and duration > 1 then
				self.expirationTime = start + duration
				self.status:SetMinMaxValues(0, duration)
				self:Show()
				found = true
			end
		end
		if not found then
			self:Hide()
		end
	end)

	-- This is what stops constant OnUpdate
	cmCD:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)
	cmCD:SetScript("OnHide", function (self)
		self:SetScript("OnUpdate", nil)
	end)

	-- If autohide is not set, show frame
	if autohide ~= true then
		if cmCD:IsShown() then
			cmCD:SetScript("OnUpdate", OnUpdate)
		else
			cmCD:Show()
		end
	end

	return cmCD
end