-- Aura plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

local CheckSpec = Engine.CheckSpec
local PixelPerfect = Engine.PixelPerfect

-- Generic method to create BUFF/DEBUFF stack monitor
Engine.CreateAuraMonitor = function(name, enable, autohide, unit, spellID, filter, count, anchor, totalWidth, height, colors, filled, specs)
	local aura = GetSpellInfo(spellID)
	local cmAMs = {}
	local width, spacing = PixelPerfect(totalWidth, count)
	for i = 1, count do
		local cmAM = CreateFrame("Frame", name, UI.BattlerHider) -- name is used for 1st power point
		cmAM:SetTemplate()
		cmAM:SetFrameStrata("BACKGROUND")
		cmAM:Size(width, height)
		if i == 1 then
			cmAM:Point(unpack(anchor))
		else
			cmAM:Point("LEFT", cmAMs[i-1], "RIGHT", spacing, 0)
		end
		if filled then
			cmAM.status = CreateFrame("StatusBar", name.."_status_"..i, cmAM)
			cmAM.status:SetStatusBarTexture(UI.NormTex)
			cmAM.status:SetFrameLevel(6)
			cmAM.status:Point("TOPLEFT", cmAM, "TOPLEFT", 2, -2)
			cmAM.status:Point("BOTTOMRIGHT", cmAM, "BOTTOMRIGHT", -2, 2)
			cmAM.status:SetStatusBarColor(unpack(colors[i]))
		else
			cmAM:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmAM:Hide()

		tinsert(cmAMs, cmAM)
	end

	if not enable then
		for i = 1, count do cmAMs[i]:Hide() end
		return
	end

	cmAMs[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmAMs[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmAMs[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
	if unit == "focus" then cmAMs[1]:RegisterEvent("PLAYER_FOCUS_CHANGED") end
	if unit == "target" then cmAMs[1]:RegisterEvent("PLAYER_TARGET_CHANGED") end
	if unit == "pet" then cmAMs[1]:RegisterUnitEvent("UNIT_PET", "player") end
	cmAMs[1]:RegisterUnitEvent("UNIT_AURA", unit)
	cmAMs[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmAMs[1]:SetScript("OnEvent", function(self, event)
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
				local name, _, _, stack, _, _, _, unitCaster = UnitAura(unit, i, filter)
				if not name then break end
				if name == aura and (unitCaster == "player" or (unit == "pet" and unitCaster == "pet")) and stack > 0 then
					for i = 1, stack do cmAMs[i]:Show() end
					for i = stack+1, count do cmAMs[i]:Hide() end
					found = true
					break
				end
			end
		end
		if found == false then
			for i = 1, count do cmAMs[i]:Hide() end
		end
	end)

	return cmAMs[1]
end

--[[
-- Generic method to create BUFF/DEBUFF monitor
Engine.CreateAuraMonitor = function(name, enable, autohide, unit, spellID, filter, count, anchor, width, height, spacing, colors, filled, specs)
	local aura = GetSpellInfo(spellID)
	local cmAMs = {}
	for i = 1, count do
		local cmAM = CreateFrame("Frame", name, UI.BattlerHider) -- name is used for 1st power point
		cmAM:SetTemplate()
		cmAM:SetFrameStrata("BACKGROUND")
		cmAM:Size(width, height)
		if i == 1 then
			cmAM:Point(unpack(anchor))
		else
			cmAM:Point("LEFT", cmAMs[i-1], "RIGHT", spacing, 0)
		end
		if filled then
			cmAM.status = CreateFrame("StatusBar", name.."_status_"..i, cmAM)
			cmAM.status:SetStatusBarTexture(UI.NormTex)
			cmAM.status:SetFrameLevel(6)
			cmAM.status:Point("TOPLEFT", cmAM, "TOPLEFT", 2, -2)
			cmAM.status:Point("BOTTOMRIGHT", cmAM, "BOTTOMRIGHT", -2, 2)
			cmAM.status:SetStatusBarColor(unpack(colors[i]))
		else
			cmAM:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmAM:Hide()

		tinsert(cmAMs, cmAM)
	end

	if not enable then
		for i = 1, count do cmAMs[i]:Hide() end
		return
	end

	cmAMs[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmAMs[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmAMs[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
	if unit == "focus" then cmAMs[1]:RegisterEvent("PLAYER_FOCUS_CHANGED") end
	if unit == "target" then cmAMs[1]:RegisterEvent("PLAYER_TARGET_CHANGED") end
	if unit == "pet" then cmAMs[1]:RegisterUnitEvent("UNIT_PET", "player") end
	cmAMs[1]:RegisterUnitEvent("UNIT_AURA", unit)
	cmAMs[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmAMs[1]:SetScript("OnEvent", function(self, event)
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
				local name, _, _, stack, _, _, _, unitCaster = UnitAura(unit, i, filter)
				if not name then break end
				if name == aura and (unitCaster == "player" or (unit == "pet" and unitCaster == "pet")) and stack > 0 then
					for i = 1, stack do cmAMs[i]:Show() end
					for i = stack+1, count do cmAMs[i]:Hide() end
					found = true
					break
				end
			end
		end
		if found == false then
			for i = 1, count do cmAMs[i]:Hide() end
		end
	end)

	return cmAMs[1]
end
--]]