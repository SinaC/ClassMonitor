-- Resource Plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

function CreateResourceMonitor(name, text, autohide, anchor, width, height, colors)
	local cmResource = CreateFrame("Frame", name, UIParent)
	cmResource:CreatePanel("Default", width , height, unpack(anchor))

	cmResource.status = CreateFrame("StatusBar", "cmResourceStatus", cmResource)
	cmResource.status:SetStatusBarTexture(C.media.normTex)
	cmResource.status:SetFrameLevel(6)
	--cmResource.status:SetStatusBarColor(unpack(color)) color will be set later
	cmResource.status:Point("TOPLEFT", cmResource, "TOPLEFT", 2, -2)
	cmResource.status:Point("BOTTOMRIGHT", cmResource, "BOTTOMRIGHT", -2, 2)
	cmResource.status:SetMinMaxValues(0, UnitPowerMax("player"))

	if text == true then
		cmResource.text = cmResource.status:CreateFontString(nil, "OVERLAY")
		cmResource.text:SetFont(C.media.uffont, 12)
		cmResource.text:Point("CENTER", cmResource.status)
		cmResource.text:SetShadowColor(0, 0, 0)
		cmResource.text:SetShadowOffset(1.25, -1.25)
	end

	local function OnUpdate()
		local value = UnitPower("player")
		cmResource.status:SetValue(value)
		if text == true then
			local p = UnitPowerType("player")
			if p == SPELL_POWER_MANA then
				local valueMax = UnitPowerMax("player", p)
				if value == valueMax then
					if value > 10000 then
						cmResource.text:SetFormattedText("%.1fk", value/1000)
					else
						cmResource.text:SetText(value)
					end
				else
					local percentage = (value * 100) / valueMax
					if value > 10000 then
						cmResource.text:SetFormattedText("%2d%% - %.1fk", percentage, value/1000 )
					else
						cmResource.text:SetFormattedText("%2d%% - %u", percentage, value )
					end
				end
			else
				cmResource.text:SetText(value)
			end
		end
	end

	cmResource:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmResource:RegisterEvent("UNIT_DISPLAYPOWER")
	cmResource:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmResource:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmResource:RegisterEvent("UNIT_POWER")
	cmResource:SetScript("OnEvent", function(self, event)
		if event ~= "PLAYER_ENTERING_WORLD" and event ~= "UNIT_DISPLAYPOWER" and event ~= "PLAYER_REGEN_DISABLED" and event ~= "PLAYER_REGEN_ENABLED" --[[and event ~= "UNIT_POWER"--]] then return end

		--print("Resource: event:"..event)
		if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" then
			local resource, resourceName = UnitPowerType("player")
			local valueMax = UnitPowerMax("player", resource)
			-- use colors[resourceName] if defined, else use default resource color or class color
			local color = (colors and (colors[resourceName] or colors[1])) or T.oUF_colors.power[resourceName] or T.oUF_colors.class[T.myclass]
			cmResource.status:SetStatusBarColor(unpack(color))
			cmResource.status:SetMinMaxValues(0, valueMax)
		end
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" then
				cmResource:Show()
			elseif event == "UNIT_POWER" then
				if InCombatLockdown() then
					cmResource:Show()
				end
			else
				cmResource:Hide()
			end
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