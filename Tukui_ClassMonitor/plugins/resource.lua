-- Resource Plugin
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

function Engine:CreateResourceMonitor(name, text, autohide, anchor, width, height, colors, spec)
	local cmResource = CreateFrame("Frame", name, TukuiPetBattleHider)
	cmResource:SetTemplate()
	cmResource:SetFrameStrata("BACKGROUND")
	cmResource:Size(width, height)
	cmResource:Point(unpack(anchor))
-- print("UserPlaced:"..tostring(cmResource:IsUserPlaced()))
	-- -- if cmResource:IsUserPlaced() == false then
-- -- print("ANCHORING...")
		-- -- cmResource:Point(unpack(anchor))
	-- -- end
	-- cmResource:SetMovable(true)
	-- cmResource.text = T.SetFontString(cmResource, C.media.uffont, 12)
	-- --cmResource.text:SetFrameStrata("MEDIUM")
	-- cmResource.text:SetPoint("CENTER")
	-- cmResource.text:SetText("MOVE RESOURCE BAR")
	-- cmResource.text:Hide()
	-- cmResource.exec = function(self, enable)
-- print("ENABLE: "..tostring(enable))
		-- if enable then
			-- self.status:Hide()
			-- self:SetBackdropBorderColor(1,0,0,1)
		-- else
			-- self.status:Show()
			-- self:SetBackdropBorderColor(unpack(C.media.bordercolor))
		-- end
	-- end
	-- tinsert(T.AllowFrameMoving, cmResource)

	-- --cmResource:SetMovable(true)
	-- --Engine:CreateMoverFrame_OLD(name, width, height, cmResource, "CENTER", 0, 0, "MOVE RESOURCE BAR")
	-- local holder = Engine:CreateMoverFrame(name, width, height, anchor, "MOVE RESOURCE BAR")
	-- cmResource:Size(width, height)
	-- cmResource:ClearAllPoints()
	-- cmResource:Point("CENTER", holder, "CENTER", 0, 0)
	-- --cmResource:SetAllPoints(holder)

	-- local mover = CreateFrame("Frame", name.."_MOVER", UIParent)
	-- mover:SetTemplate()
	-- mover:SetMovable(true)
	-- mover:Size(30, 30)
	-- local point, relativeFrame, relativePoint, ofsx, ofsy = unpack(anchor)
	-- mover:Point("LEFT", relativeFrame, relativePoint, ofsx + width/2 + 10, ofsy) -- LEFT of resource anchor  width/2 because relativePoint == CENTER
	-- mover:SetBackdropBorderColor(1, 0, 0)
	-- mover:SetFrameLevel(2)
	-- mover:SetFrameStrata("HIGH")
	-- mover.text = T.SetFontString(mover, C.media.uffont, 12)
	-- mover.text:SetPoint("CENTER")
	-- mover.text:SetText("MOVE RESOURCE BAR")
	-- mover:Hide()
	-- mover.exec = function(self, enable)
		-- if enable then
			-- self:Show()
		-- else
			-- self:Hide()
		-- end
	-- end
	-- tinsert(T.AllowFrameMoving, mover)
	-- cmResource:ClearAllPoints()
	-- cmResource:Point("BOTTOMRIGHT", mover, "BOTTOMLEFT", -10, 0)

	cmResource.status = CreateFrame("StatusBar", "cmResourceStatus", cmResource)
	cmResource.status:SetStatusBarTexture(C.media.normTex)
	cmResource.status:SetFrameLevel(6)
	--cmResource.status:SetStatusBarColor(unpack(color)) color will be set later
	cmResource.status:Point("TOPLEFT", cmResource, "TOPLEFT", 2, -2)
	cmResource.status:Point("BOTTOMRIGHT", cmResource, "BOTTOMRIGHT", -2, 2)
	cmResource.status:SetMinMaxValues(0, UnitPowerMax("player"))

	if text == true then
		cmResource.valueText = cmResource.status:CreateFontString(nil, "OVERLAY")
		cmResource.valueText:SetFont(C.media.uffont, 12)
		cmResource.valueText:Point("CENTER", cmResource.status)
		cmResource.valueText:SetShadowColor(0, 0, 0)
		cmResource.valueText:SetShadowOffset(1.25, -1.25)
	end

	cmResource.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		cmResource.timeSinceLastUpdate = cmResource.timeSinceLastUpdate + elapsed
		if cmResource.timeSinceLastUpdate > 0.2 then
			local value = UnitPower("player")
--print("Value:"..value)
			cmResource.status:SetValue(value)
			if text == true then
				local p = UnitPowerType("player")
				if p == SPELL_POWER_MANA then
					local valueMax = UnitPowerMax("player", p)
					if value == valueMax then
						if value > 10000 then
							cmResource.valueText:SetFormattedText("%.1fk", value/1000)
						else
							cmResource.valueText:SetText(value)
						end
					else
						local percentage = (value * 100) / valueMax
						if value > 10000 then
							cmResource.valueText:SetFormattedText("%2d%% - %.1fk", percentage, value/1000 )
						else
							cmResource.valueText:SetFormattedText("%2d%% - %u", percentage, value )
						end
					end
				else
					cmResource.valueText:SetText(value)
				end
			end
			cmResource.timeSinceLastUpdate = 0
		end
	end

	cmResource:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmResource:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
	cmResource:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmResource:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmResource:RegisterUnitEvent("UNIT_POWER", "player")
	cmResource:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	cmResource:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	--cmResource:SetScript("OnEvent", function(self, event, arg1)
	cmResource:SetScript("OnEvent", function(self, event)
--print("Resource: event:"..event)

		if spec ~= "any" and spec ~= GetSpecialization() then
			cmResource:Hide()
			return
		end

		--if event == "PLAYER_ENTERING_WORLD" or ((event == "UNIT_DISPLAYPOWER" or event == "UNIT_MAXPOWER" or event == "PLAYER_SPECIALIZATION_CHANGED") and arg1 == "player") then
		if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" or event == "UNIT_MAXPOWER" or event == "PLAYER_SPECIALIZATION_CHANGED" then
			local resource, resourceName = UnitPowerType("player")
			local valueMax = UnitPowerMax("player", resource)
--print("Resource: "..resource.."  "..resourceName.."  "..valueMax)
			-- use colors[resourceName] if defined, else use default resource color or class color
			local color = (colors and (colors[resourceName] or colors[1])) or T.UnitColor.power[resourceName] or T.UnitColor.class[T.myclass]
--print("Resource:"..tostring(color[1]).."  "..tostring(color[2]).."  "..tostring(color[3]))
			cmResource.status:SetStatusBarColor(unpack(color))
			cmResource.status:SetMinMaxValues(0, valueMax)
			cmResource:Show()
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