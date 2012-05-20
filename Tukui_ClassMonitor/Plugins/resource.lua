-- Resource Plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

function CreateResourceMonitor(name, text, autohide, anchor, width, height, colors, overflow, bars)

	local cmResource = CreateFrame("Frame", name, UIParent)
	cmResource:CreatePanel("Default", width , height, unpack(anchor))

	cmResource.intelbufflist = {
		{74241, 7500}, -- Power Torrent (proc weapon)
		{79476, 18000}, -- Volcanic Power (popo)
		{89091, 24000}, -- Volcanic Destruction (trinket)
		{75170, 8700}, -- Lightweave (back)
		{55367, 4425}, -- Lightweave (back)
		{96230, 7200}, -- Synapse Springs (gloves)
		{97007, 19155}, -- Mark of the firelord (trinket)
	}
	cmResource.temppower = 0
	cmResource.powermultiplier = 0
	cmResource.overflowtimer = 0
	cmResource.realpower = UnitPowerMax("player")
	cmResource.maxpower = UnitPowerMax("player")
	cmResource.bars = {}
	cmResource.timeSinceLastUpdate = GetTime()

	cmResource.status = CreateFrame("StatusBar", "cmResourceStatus", cmResource)
	cmResource.status:SetStatusBarTexture(C.media.normTex)
	cmResource.status:SetFrameLevel(8)
	cmResource.status:Point("TOPLEFT", cmResource, "TOPLEFT", 2, -2)
	cmResource.status:Point("BOTTOMRIGHT", cmResource, "BOTTOMRIGHT", -2, 2)
	cmResource.status:SetMinMaxValues(0, cmResource.realpower)

	cmResource.statusoverflow = CreateFrame("StatusBar", "cmArcaneManaStatusOverflow", cmResource)
	cmResource.statusoverflow:SetStatusBarTexture(C.media.normTex)
	cmResource.statusoverflow:SetFrameLevel(7)
	cmResource.statusoverflow:SetPoint("TOPLEFT", cmResource, "TOPLEFT", 2, -2)
	cmResource.statusoverflow:SetWidth((width-4))
	cmResource.statusoverflow:SetHeight(height-4)
	cmResource.statusoverflow:SetMinMaxValues(0, cmResource.realpower)
	cmResource.statusoverflow:SetStatusBarColor(1,0,0)

	cmResource.textoverflow = cmResource.status:CreateFontString(nil, "OVERLAY")
	cmResource.textoverflow:SetFont(C.media.uffont, 12)
	cmResource.textoverflow:Point("LEFT", cmResource.statusoverflow, "RIGHT", 2, 0)
	cmResource.textoverflow:SetShadowColor(0, 0, 0)
	cmResource.textoverflow:SetShadowOffset(1.25, -1.25)
	
	if text == true then
		cmResource.text = cmResource.status:CreateFontString(nil, "OVERLAY")
		cmResource.text:SetFont(C.media.uffont, 12)
		cmResource.text:Point("CENTER", cmResource.status)
		cmResource.text:SetShadowColor(0, 0, 0)
		cmResource.text:SetShadowOffset(1.25, -1.25)
	end

	for i = 1, #bars do
		cmResource.bars[i] = CreateFrame("Frame", "cmResourceBar"..i, cmResource)
		if bars[i].percent then
			cmResource.bars[i]:CreatePanel("Default", 1 , height-4, "LEFT", cmResource, "LEFT", (width-4)*bars[i].value/100, 0)
		else
			cmResource.bars[i]:CreatePanel("Default", 1 , height-4, "LEFT", cmResource, "LEFT", (width-4)*bars[i].value/cmResource.maxpower, 0)
		end
		cmResource.bars[i]:SetFrameLevel(9)
		local color = bars[i].color or T.UnitColor.power[resourceName] or T.UnitColor.class[T.myclass]
		cmResource.bars[i]:SetBackdropBorderColor(unpack(color))
	end

	if T.myclass == "MAGE" then
		cmResource.MageArmorGain = CreateFrame("Frame", "cmResourceMageArmorGain", cmResource)
		cmResource.MageArmorGain:CreatePanel("Default", 1 , height-4, "LEFT", cmResource.status, "RIGHT", (width-4)*0.05, 0)
		cmResource.MageArmorGain:SetFrameLevel(9)
		cmResource.MageArmorGain:SetBackdropBorderColor(unpack(T.UnitColor.class["MAGE"]))
	end

	--------------------------------------------------
	-- Function to calculate the manamax and the temp mana to prevent mana waste.
	--------------------------------------------------
	function cmResource.CalculatePowerMax ()
		-- reset multiplier
		cmResource.powermultiplier = 1.05
		cmResource.temppower = 0
		cmResource.overflowtimer = 0
		local resource, resourceName = UnitPowerType("player")
		cmResource.maxpower = UnitPowerMax("player", resource)
		
		if T.myclass == "MAGE" then
			cmResource.MageArmorGain:Hide()
		end

		if resource == SPELL_POWER_MANA then

			-- let's check the buffs on and see if somes are interestings
			for i = 1, 40 do
				local name, _, _, _, _, duration, expirationTime, _, _, _, spellId = UnitBuff("player", i)

				if name == GetSpellInfo(79061) or name == GetSpellInfo(79063) or name == GetSpellInfo(90363) then -- 5% stats : Druid, Pal, Hunt
					cmResource.powermultiplier = cmResource.powermultiplier*1.05

				elseif name == GetSpellInfo(6117) then -- forgotten blessing of kings (4%)
					cmResource.MageArmorGain:Show()

				elseif spellId == 69378 then -- forgotten blessing of kings (4%)
					cmResource.powermultiplier = cmResource.powermultiplier*1.04


				elseif spellId and overflow then -- check is there are intel procs in buffs
					for j = 1,#cmResource.intelbufflist do
						if (spellId == cmResource.intelbufflist[j][1] ) then
							cmResource.temppower = cmResource.temppower + cmResource.intelbufflist[j][2]
							if expirationTime < cmResource.overflowtimer or cmResource.overflowtimer == 0 then
								cmResource.overflowtimer = expirationTime
							end
							break
						end
					end

				elseif spellId then
					-- go to next Aura
				else
					-- if nothing found break
					break
				end
			end
		end
		
		cmResource.temppower = (cmResource.temppower * cmResource.powermultiplier) -- applies multiplier
		cmResource.realpower = cmResource.maxpower-cmResource.temppower
		cmResource.status:SetMinMaxValues(0,cmResource.realpower)
		cmResource.statusoverflow:SetWidth((width-4) * (cmResource.maxpower/cmResource.realpower ))
		cmResource.statusoverflow:SetMinMaxValues(0,cmResource.maxpower)
	end



	--------------------------------------------------
	-- Function OnUpdate 
	--------------------------------------------------	
	local function OnUpdate(self, elapsed)
	
		cmResource.timeSinceLastUpdate = cmResource.timeSinceLastUpdate + elapsed
		if cmResource.timeSinceLastUpdate > 0.2 then

			local value = UnitPower("player")
			cmResource.status:SetValue(value)

			-- show overflow
			if(value > cmResource.realpower) then
				cmResource.status:SetValue(cmResource.realpower)
				cmResource.statusoverflow:SetValue(value)
			else
				cmResource.status:SetValue(value)
				cmResource.statusoverflow:SetValue(value)
			end

			if text == true then
				local p = UnitPowerType("player")
				if p == SPELL_POWER_MANA then
					-- compare value to cmResource.realpower
					if value == cmResource.realpower then
						if value > 10000 then
							cmResource.text:SetFormattedText("%.1fk", value/1000)
						else
							cmResource.text:SetText(value)
						end
						cmResource.textoverflow:SetText("")
					-- if overflow
					elseif(value > cmResource.realpower) then
						local percentage = (value * 100) / cmResource.realpower
						local overflowpower = value - cmResource.realpower  -- calculate overflow
						if value > 10000 or overflowpower > 1000 then
							cmResource.text:SetFormattedText("%2d%% - %.1fk |cffff0000+ %.1fk|r", percentage, cmResource.realpower/1000, overflowpower/1000 )
						else
							cmResource.text:SetFormattedText("%2d%% - %u |cffff0000+ %u|r", percentage, cmResource.realpower, overflow )
						end
						cmResource.textoverflow:SetFormattedText("|cffff0000%.1fs|r", cmResource.overflowtimer-GetTime())  -- show overflow timer
					
					-- if not.
					else
						local percentage = (value * 100) / cmResource.realpower
						if value > 10000 then
							cmResource.text:SetFormattedText("%2d%% - %.1fk", percentage, value/1000 )
						else
							cmResource.text:SetFormattedText("%2d%% - %u", percentage, value )
						end
						cmResource.textoverflow:SetText("") -- hide overflow timer
					end
				else
					cmResource.text:SetText(value)
					cmResource.textoverflow:SetText("") -- hide overflow timer
				end
			end
			
			if T.myclass == "MAGE" then
				cmResource.MageArmorGain:SetPoint("LEFT", cmResource, "LEFT", (2 + (width-4)*(value + cmResource.maxpower*0.036)/cmResource.realpower), 0)
			end
			cmResource.timeSinceLastUpdate = 0
		end
	end





	--------------------------------------------------
	-- Function OnEvent
	--------------------------------------------------	
	cmResource:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmResource:RegisterEvent("UNIT_DISPLAYPOWER")
	cmResource:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmResource:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmResource:RegisterEvent("UNIT_POWER")
	cmResource:RegisterEvent("UNIT_AURA")
	cmResource:RegisterEvent("UNIT_MAXPOWER")
	cmResource:SetScript("OnEvent", function(self, event, arg1, ...)

		--print("Resource: event:"..event)
		local  eventType, _,caster,_,_,_,target,_,_, _, spellID =...
		if event == "PLAYER_ENTERING_WORLD" or ((event == "UNIT_DISPLAYPOWER" or event == "UNIT_MAXPOWER" or event == "UNIT_AURA") and arg1 == "player") then
			local _, resourceName = UnitPowerType("player")
			-- local valueMax = UnitPowerMax("player", resource)
			cmResource.CalculatePowerMax()
			-- use colors[resourceName] if defined, else use default resource color or class color
			local color = (colors and (colors[resourceName] or colors[1])) or T.UnitColor.power[resourceName] or T.UnitColor.class[T.myclass]
			cmResource.status:SetStatusBarColor(unpack(color))
		end
		
		if autohide == true then
			if InCombatLockdown() then
				cmResource:Show()
			else
				cmResource:Hide()
			end
		else
			cmResource:Show()
		end
	end)

	-- This is what stops constant OnUpdate
	cmResource:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)
	cmResource:SetScript("OnHide", function (self)
		self:SetScript("OnUpdate", nil)
	end)

	-- If autohide is not set, show frame
	if autohide ~= true then
		if cmResource:IsShown() then
			cmResource:SetScript("OnUpdate", OnUpdate)
		else
			cmResource:Show()
		end
	end
	
	return cmResource
end