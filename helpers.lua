local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

-- TODO: optimize: Update Power/Aura only if correct power/spellid

-- When multiple anchor are specified, anchor depends on current spec
function SetMultipleAnchorHandler( frame, option )
	--print("SetMultipleAnchorHandler 1")
	if not option.anchors then return end
	--print("SetMultipleAnchorHandler 2")
	local function SetAnchor(self, event)
		if event ~= "PLAYER_TALENT_UPDATE" and event ~= "PLAYER_ENTERING_WORLD" then return end
		local ptt = GetPrimaryTalentTree()
		if not ptt then return end
		local anchor = option.anchors[ptt]
		if not anchor then return end
		--print("Anchor:"..event.." "..ptt.." "..frame:GetName())
		frame:Point(unpack(anchor))
	end
	frame:RegisterEvent("PLAYER_TALENT_UPDATE")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:HookScript("OnEvent",SetAnchor)
end

-- Generic method to create POWER monitor
function CreatePowerMonitor( power, count, option )
	local cmPM = CreateFrame("Frame", "cmPM"..power, UIParent)
	for i = 1, count do
		cmPM[i] = CreateFrame("Frame", "cmPM"..power.."_"..i, UIParent)
		if ( option.filled ) then
			cmPM[i]:CreatePanel("Default", option.width, option.height, "CENTER", UIParent, "CENTER", 0, 0)
			cmPM[i].sStatus = CreateFrame("StatusBar", "cmPMStatus"..power.."_"..i, cmPM[i])
			cmPM[i].sStatus:SetStatusBarTexture(C.media.normTex)
			cmPM[i].sStatus:SetFrameLevel(6)
			cmPM[i].sStatus:Point("TOPLEFT", cmPM[i], "TOPLEFT", 2, -2)
			cmPM[i].sStatus:Point("BOTTOMRIGHT", cmPM[i], "BOTTOMRIGHT", -2, 2)
			cmPM[i].sStatus:SetStatusBarColor(unpack(option.color))
		else
			cmPM[i]:CreatePanel("Default", option.width, option.height, "CENTER", UIParent, "CENTER", 0, 0)
			cmPM[i]:CreateShadow("Default")
			cmPM[i]:SetBackdropBorderColor(unpack(option.color))
		end

		if i == 1 then
			cmPM[i]:Point(unpack(option.anchor))
		else
			cmPM[i]:Point("LEFT", cmPM[i-1], "RIGHT", option.spacing, 0)
		end
	end

	cmPM[1]:RegisterEvent("UNIT_POWER")
	cmPM[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmPM[1]:SetScript("OnEvent", function( self, event )
		if event ~= "UNIT_POWER" and event ~= "PLAYER_ENTERING_WORLD" then return end
		--print("OnEvent:"..event)
		local value = UnitPower("player", power)
		if value and value > 0 then
			for i = 1, value do cmPM[i]:Show() end
			for i = value+1, count do cmPM[i]:Hide() end
		else
			for i = 1, count do cmPM[i]:Hide() end
		end
	end)
	
	SetMultipleAnchorHandler(cmPM[1], option)
end

-- Generic method to create BUFF/DEBUFF monitor
function CreateAuraMonitor( spellID, filter, count, option )
	local aura = GetSpellInfo(spellID)

	local cmAM = CreateFrame("Frame", "cmAM"..spellID, UIParent)
	for i = 1, count do
		cmAM[i] = CreateFrame("Frame", "cmAM"..spellID.."_"..i, UIParent)
		if ( option.filled ) then
			cmAM[i]:CreatePanel("Default", option.width, option.height, "CENTER", UIParent, "CENTER", 0, 0)
			cmAM[i].sStatus = CreateFrame("StatusBar", "cmPMStatus"..spellID.."_"..i, cmAM[i])
			cmAM[i].sStatus:SetStatusBarTexture(C.media.normTex)
			cmAM[i].sStatus:SetFrameLevel(6)
			cmAM[i].sStatus:Point("TOPLEFT", cmAM[i], "TOPLEFT", 2, -2)
			cmAM[i].sStatus:Point("BOTTOMRIGHT", cmAM[i], "BOTTOMRIGHT", -2, 2)
			cmAM[i].sStatus:SetStatusBarColor(unpack(option.color))
		else
			cmAM[i]:CreatePanel("Default", option.width, option.height, "CENTER", UIParent, "CENTER", 0, 0)
			cmAM[i]:CreateShadow("Default")
			cmAM[i]:SetBackdropBorderColor(unpack(option.color))
		end
		
		if i == 1 then
			cmAM[i]:Point(unpack(option.anchor))
		else
			cmAM[i]:Point("LEFT", cmAM[i-1], "RIGHT", option.spacing, 0)
		end
	end

	cmAM[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmAM[1]:RegisterEvent("UNIT_AURA")
	cmAM[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmAM[1]:SetScript("OnEvent", function()
		local found = false
		for i = 1, 40, 1 do
			local name, _, _, stack, _, _, _, unitCaster = UnitAura("player", i, filter )
			if ( not name ) then break end
			if ( name == aura and unitCaster == "player" and stack > 0 ) then
				for i = 1, stack do cmAM[i]:Show() end
				for i = stack+1, count do cmAM[i]:Hide() end
				found = true
				break
			end
		end
		if ( found == false ) then
			for i = 1, count do cmAM[i]:Hide() end
		end
	end)
	
	SetMultipleAnchorHandler(cmAM[1], option)
end

-- -- Add visibility event handler to a frame
-- function AddVisibilityHandler( frame, visibility )
	-- if not visibility or not visibility.func or not visibility.events then return end

	-- for i, event in ipairs(visibility.events) do
		-- frame:RegisterEvent(event, visibility.func)
	-- end
-- end