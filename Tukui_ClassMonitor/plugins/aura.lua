-- Aura plugin
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

-- Generic method to create BUFF/DEBUFF monitor
function Engine:CreateAuraMonitor(name, spellID, filter, count, anchor, width, height, spacing, colors, filled, spec)
	local aura = GetSpellInfo(spellID)
	local cmAMs = {}
	for i = 1, count do
		local cmAM = CreateFrame("Frame", name, TukuiPetBattleHider) -- name is used for 1st power point
		--cmAM:CreatePanel("Default", width, height, unpack(anchor))
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
			cmAM.status:SetStatusBarTexture(C.media.normTex)
			cmAM.status:SetFrameLevel(6)
			cmAM.status:Point("TOPLEFT", cmAM, "TOPLEFT", 2, -2)
			cmAM.status:Point("BOTTOMRIGHT", cmAM, "BOTTOMRIGHT", -2, 2)
			cmAM.status:SetStatusBarColor(unpack(colors[i]))
		else
			cmAM:CreateShadow("Default")
			cmAM:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmAM:Hide()

		tinsert(cmAMs, cmAM)
	end

	cmAMs[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmAMs[1]:RegisterUnitEvent("UNIT_AURA", "player")
	cmAMs[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	--cmAMs[1]:SetScript("OnEvent", function(self, event, arg1)
	cmAMs[1]:SetScript("OnEvent", function(self, event)
		--if (event == "UNIT_AURA" or event == "PLAYER_SPECIALIZATION_CHANGED") and arg1 ~= "player" then return end
		local found = false
		if spec == "any" or spec == GetSpecialization() then
			for i = 1, 40, 1 do
				local name, _, _, stack, _, _, _, unitCaster = UnitAura("player", i, filter )
				if not name then break end
				if name == aura and unitCaster == "player" and stack > 0 then
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
		--for i = 1, count do cmAMs[i]:Show() end
	end)

	return cmAMs[1]
end