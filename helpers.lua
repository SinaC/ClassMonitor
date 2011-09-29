local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

function CreateAuraTracker( spellID, filter, count, anchor, color, width, height, spacing )
	local aura = GetSpellInfo(spellID)

	local cmAT = CreateFrame("Frame", "cmAT"..spellID, UIParent)
	for i = 1, count do
		cmAT[i] = CreateFrame("Frame", "cmAT"..spellID.."_"..i, UIParent)
		cmAT[i]:CreatePanel("Default", width, height, "CENTER", UIParent, "CENTER", 0, 0)
		cmAT[i]:CreateShadow("Default")
		cmAT[i]:SetBackdropBorderColor(unpack(color))
		
		if i == 1 then
			cmAT[i]:Point(unpack(anchor))
		else
			cmAT[i]:Point("LEFT", cmAT[i-1], "RIGHT", spacing, 0)
		end
	end

	cmAT[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmAT[1]:RegisterEvent("UNIT_AURA")
	cmAT[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmAT[1]:SetScript("OnEvent", function()
		local found = false
		for i = 1, 40, 1 do
			local name, _, _, stack, _, _, _, unitCaster = UnitAura("player", i, filter )
			if ( not name ) then break end
			if ( name == aura and unitCaster == "player" and stack > 0 ) then
				for i = 1, stack do cmAT[i]:Show() end
				for i = stack+1, count do cmAT[i]:Hide() end
				found = true
				break
			end
		end
		if ( found == false ) then
			for i = 1, count do cmAT[i]:Hide() end
		end
	end)
end