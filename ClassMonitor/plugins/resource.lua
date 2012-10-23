-- Resource Plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

local CheckSpec = Engine.CheckSpec
local PowerColor = UI.PowerColor
local ClassColor = UI.ClassColor

-- Generic method to create a resource monitor (resource = default power)
Engine.CreateResourceMonitor = function(name, enable, text, autohide, anchor, width, height, colors, specs)
	local cmResource = CreateFrame("Frame", name, UI.BattlerHider)
	cmResource:SetTemplate()
	cmResource:SetFrameStrata("BACKGROUND")
	cmResource:Size(width, height)
	cmResource:Point(unpack(anchor))

	cmResource.status = CreateFrame("StatusBar", name.."Status", cmResource)
	cmResource.status:SetStatusBarTexture(UI.NormTex)
	cmResource.status:SetFrameLevel(6)
	cmResource.status:Point("TOPLEFT", cmResource, "TOPLEFT", 2, -2)
	cmResource.status:Point("BOTTOMRIGHT", cmResource, "BOTTOMRIGHT", -2, 2)
	cmResource.status:SetMinMaxValues(0, UnitPowerMax("player"))

	if text == true then
		cmResource.valueText = UI.SetFontString(cmResource.status, 12)
		cmResource.valueText:Point("CENTER", cmResource.status)
	end

	if not enable then
		cmResource:Hide()
		return
	end

	cmResource.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
		if self.timeSinceLastUpdate > 0.2 then
			local value = UnitPower("player")
--print("Value:"..value)
			self.status:SetValue(value)
			if text == true then
				local p = UnitPowerType("player")
				if p == SPELL_POWER_MANA then
					local valueMax = UnitPowerMax("player", p)
					if value == valueMax then
						if value > 10000 then
							self.valueText:SetFormattedText("%.1fk", value/1000)
						else
							self.valueText:SetText(value)
						end
					else
						local percentage = (value * 100) / valueMax
						if value > 10000 then
							self.valueText:SetFormattedText("%2d%% - %.1fk", percentage, value/1000 )
						else
							self.valueText:SetFormattedText("%2d%% - %u", percentage, value )
						end
					end
				else
					self.valueText:SetText(value)
				end
			end
			self.timeSinceLastUpdate = 0
		end
	end

	cmResource:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmResource:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmResource:RegisterEvent("PLAYER_REGEN_ENABLED")
	--cmResource:RegisterUnitEvent("UNIT_POWER", "player")
	cmResource:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
	cmResource:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	cmResource:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmResource:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		if not CheckSpec(specs) or not visible then
			self:Hide()
			return
		end

		if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" or event == "UNIT_MAXPOWER" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_REGEN_DISABLED" then
			local resource, resourceName = UnitPowerType("player")
			local valueMax = UnitPowerMax("player", resource)
			-- use colors[resourceName] if defined, else use default resource color or class color
			local color = (colors and (colors[resourceName] or colors[1])) or PowerColor(resourceName) or ClassColor()
			self.status:SetStatusBarColor(unpack(color))
			self.status:SetMinMaxValues(0, valueMax)
			self:Show()
		end
		-- if autohide == true then
			-- if event == "PLAYER_REGEN_DISABLED" then
				-- self:Show()
			-- elseif event == "UNIT_POWER" or event == "UNIT_DISPLAYPOWER" or event == "UNIT_MAXPOWER" then
				-- if InCombatLockdown() then
					-- self:Show()
				-- end
			-- else
				-- self:Hide()
			-- end
		-- end
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