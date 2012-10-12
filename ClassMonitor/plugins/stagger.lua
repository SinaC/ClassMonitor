-- Stagger plugin, credits to Demise and FrozenEmu (http://www.wowinterface.com/downloads/info21191-BrewmasterTao.html)
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

local CheckSpec = Engine.CheckSpec

-- TODO: OnUpdate
local FormatHealth = Engine.FormatHealth

local lightStagger = GetSpellInfo(124275)
local moderateStagger = GetSpellInfo(124274)
local heavyStagger = GetSpellInfo(124273)

-- Generic method to create STAGGER monitor
Engine.CreateStaggerMonitor = function(name, enable, threshold, text, autohide, anchor, width, height, colors)
	local cmSM = CreateFrame("Frame", name, UI.BattlerHider)
	cmSM:SetTemplate()
	cmSM:SetFrameStrata("BACKGROUND")
	cmSM:Size(width, height)
	cmSM:Point(unpack(anchor))
	cmSM:Hide()

	cmSM.status = CreateFrame("StatusBar", name.."_status", cmSM)
	cmSM.status:SetStatusBarTexture(UI.NormTex)
	cmSM.status:SetFrameLevel(6)
	cmSM.status:Point("TOPLEFT", cmSM, "TOPLEFT", 2, -2)
	cmSM.status:Point("BOTTOMRIGHT", cmSM, "BOTTOMRIGHT", -2, 2)
	cmSM.status:SetMinMaxValues(0, threshold)

	if text == true then
		cmSM.valueText = UI.SetFontString(cmSM.status, 12)
		cmSM.valueText:Point("CENTER", cmSM.status)
	end

	if not enable then
		cmSM:Hide()
		return
	end

	cmSM:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmSM:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmSM:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmSM:RegisterUnitEvent("UNIT_AURA", "player")
	cmSM:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmSM:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		local found = false
		if GetSpecialization() ~= 1 and visible then
			local spellName, duration, value1, _
			spellName, _, _, _, _, duration, _, _, _, _, _, _, _, value1 = UnitAura("player", lightStagger, "", "HARMFUL")
			if (not spellName) then spellName, _, _, _, _, duration, _, _, _, _, _, _, _, value1 = UnitAura("player", moderateStagger, "", "HARMFUL") end
			if (not spellName) then spellName, _, _, _, _, duration, _, _, _, _, _, _, _, value1 = UnitAura("player", heavyStagger, "", "HARMFUL") end

			if spellName and value1 > 0 and duration > 0 then
				if spellName == lightStagger then cmSM.status:SetStatusBarColor(unpack(colors[1])) end
				if spellName == moderateStagger then cmSM.status:SetStatusBarColor(unpack(colors[2])) end
				if spellName == heavyStagger then cmSM.status:SetStatusBarColor(unpack(colors[3])) end
				local staggerTick = value1
				local staggerTotal = staggerTick * math.floor(duration)
				local hp = math.floor(staggerTotal/UnitHealthMax("player") * 100)
				if text == true then
					cmSM.valueText:SetText(tostring(staggerTick).." - "..FormatHealth(staggerTotal).." ("..hp.."%)")
				end
				if hp <= threshold then cmSM.status:SetValue(hp) else cmSM.status:SetValue(threshold) end
				cmSM:Show()
				found = true
			end
		end
		if not found then
			cmSM:Hide()
		end
	end)

	-- -- This is what stops constant OnUpdate
	-- cmSM:SetScript("OnShow", function(self)
		-- self:SetScript("OnUpdate", OnUpdate)
	-- end)
	-- cmSM:SetScript("OnHide", function (self)
		-- self:SetScript("OnUpdate", nil)
	-- end)

	-- -- If autohide is not set, show frame
	-- if autohide ~= true then
		-- if cmSM:IsShown() then
			-- cmSM:SetScript("OnUpdate", OnUpdate)
		-- else
			-- cmSM:Show()
		-- end
	-- end

	return cmSM
end
