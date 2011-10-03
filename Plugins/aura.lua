-- Aura plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

-- Generic method to create BUFF/DEBUFF monitor
function CreateAuraMonitor(name, spellID, filter, count, anchor, width, height, spacing, colors, filled)
	local aura = GetSpellInfo(spellID)
	local cmAMs = {}
	for i = 1, count do
		local cmAM
		if i == 1 then
			cmAM = CreateFrame("Frame", name, UIParent) -- name is used for 1st power point
			cmAM:CreatePanel("Default", width, height, unpack(anchor))
		else
			cmAM = CreateFrame("Frame", name.."_"..i, UIParent)
			cmAM:CreatePanel("Default", width, height, "LEFT", cmAMs[i-1], "RIGHT", spacing, 0)
		end
		if ( filled ) then
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
	cmAMs[1]:RegisterEvent("UNIT_AURA")
	cmAMs[1]:SetScript("OnEvent", function(self, event)
		if event ~= "PLAYER_ENTERING_WORLD" and event ~= "UNIT_AURA" then return end

		local found = false
		for i = 1, 40, 1 do
			local name, _, _, stack, _, _, _, unitCaster = UnitAura("player", i, filter )
			if ( not name ) then break end
			if ( name == aura and unitCaster == "player" and stack > 0 ) then
				for i = 1, stack do cmAMs[i]:Show() end
				for i = stack+1, count do cmAMs[i]:Hide() end
				found = true
				break
			end
		end
		if ( found == false ) then
			for i = 1, count do cmAMs[i]:Hide() end
		end
	end)

	return cmAMs[1]
end