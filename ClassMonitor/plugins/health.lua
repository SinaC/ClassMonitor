-- Resource Plugin, written to Ildyria, edited by SinaC
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

local CheckSpec = Engine.CheckSpec
local HealthColor = UI.HealthColor

-- Create a health monitor
Engine.CreateHealthMonitor = function(name, enable, unit, text, autohide, anchor, width, height, color, specs)
	local cmHealth = CreateFrame("Frame", name, UI.BattlerHider)
	cmHealth:SetTemplate()
	cmHealth:SetFrameStrata("BACKGROUND")
	cmHealth:Size(width, height)
	cmHealth:Point(unpack(anchor))

	cmHealth.status = CreateFrame("StatusBar", "cmHealthStatus", cmHealth)
	cmHealth.status:SetStatusBarTexture(UI.NormTex)
	cmHealth.status:SetFrameLevel(6)
	cmHealth.status:Point("TOPLEFT", cmHealth, "TOPLEFT", 2, -2)
	cmHealth.status:Point("BOTTOMRIGHT", cmHealth, "BOTTOMRIGHT", -2, 2)
	cmHealth.status:SetMinMaxValues(0, UnitHealthMax(unit))

	if text == true then
		cmHealth.text = UI.SetFontString(cmHealth.status, 12)
		cmHealth.text:Point("CENTER", cmHealth.status)
	end

	if not enable then
		cmHealth:Hide()
		return
	end

	cmHealth.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		cmHealth.timeSinceLastUpdate = cmHealth.timeSinceLastUpdate + elapsed
		if cmHealth.timeSinceLastUpdate > 0.2 then
--print("cmHealth:OnUpdate")
			local value = UnitHealth(unit)
			cmHealth.status:SetValue(value)
			if text == true then
				local valueMax = UnitHealthMax(unit)
				if value == valueMax then
					if value > 10000 then
						cmHealth.text:SetFormattedText("%.1fk", value/1000)
					else
						cmHealth.text:SetText(value)
					end
				else
					local percentage = (value * 100) / valueMax
					if value > 10000 then
						cmHealth.text:SetFormattedText("%2d%% - %.1fk", percentage, value/1000 )
					else
						cmHealth.text:SetFormattedText("%2d%% - %u", percentage, value )
					end
				end
			end
			cmHealth.timeSinceLastUpdate = 0
		end
	end

	cmHealth:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmHealth:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmHealth:RegisterEvent("PLAYER_ENTERING_WORLD")
	if unit == "target" then cmHealth:RegisterEvent("PLAYER_TARGET_CHANGED") end
	if unit == "focus" then cmHealth:RegisterEvent("PLAYER_FOCUS_CHANGED") end
	if unit == "pet" then cmHealth:RegisterUnitEvent("UNIT_PET", "player") end
	--cmHealth:RegisterUnitEvent("UNIT_HEALTH", unit)
	cmHealth:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
	cmHealth:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", unit)
	cmHealth:SetScript("OnEvent", function(self, event)
		local class = select(2, UnitClass(unit))
		if autohide == true then
			if class and (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) then
				visible = true
			else
				visible = false
			end
		end
		if not CheckSpec(specs) or not visible then
			cmHealth:Hide()
			return
		end
		-- TODO: problem while in combat with a target and pressing escape
		-- code in comment in next if helps but show a null bar when no target and in combat
		if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_MAXHEALTH" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" or event == "PLAYER_REGEN_DISABLED" then
			if class then
				local valueMax = UnitHealthMax(unit)
				local healthColor = color or HealthColor(unit) or {1, 1, 1, 1}
				cmHealth.status:SetStatusBarColor(unpack(healthColor))
				cmHealth.status:SetMinMaxValues(0, valueMax)
				cmHealth:Show()
			else
				cmHealth:Hide()
			end
		end
		-- if autohide == true then
			-- if event == "PLAYER_REGEN_DISABLED" then
				-- cmHealth:Show()
			-- elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
				-- if InCombatLockdown() and class then
					-- cmHealth:Show()
				-- end
			-- else
				-- cmHealth:Hide()
			-- end
		-- end
--print("IN COMBAT:"..tostring(InCombatLockdown()).."  "..tostring(event).."  "..tostring(class))
	end)

	-- This is what stops constant OnUpdate
	cmHealth:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)
	cmHealth:SetScript("OnHide", function (self)
		self:SetScript("OnUpdate", nil)
	end)

	-- If autohide is not set, show frame
	if autohide ~= true then
		if cmHealth:IsShown() then
			cmHealth:SetScript("OnUpdate", OnUpdate)
		else
			cmHealth:Show()
		end
	end
	
	return cmHealth
end