-- Power Plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local O = CMOptions["power"]
if O.enable ~= true then return end
local color = RAID_CLASS_COLORS[T.myclass] -- default color

local cmPower = CreateFrame("Frame", "cmPower", UIParent)
cmPower:CreatePanel(nil, O.width , O.height, unpack(O.anchor))

cmPower.sStatus = CreateFrame("StatusBar", "sStatus", cmPower)
cmPower.sStatus:SetStatusBarTexture(C.media.normTex)
cmPower.sStatus:SetFrameLevel(6)
cmPower.sStatus:SetStatusBarColor(color.r, color.g, color.b)
cmPower.sStatus:Point("TOPLEFT", cmPower, "TOPLEFT", 2, -2)
cmPower.sStatus:Point("BOTTOMRIGHT", cmPower, "BOTTOMRIGHT", -2, 2)
cmPower.sStatus:SetMinMaxValues(0, UnitPowerMax("player"))

if O.text == true then
	cmPower.text = cmPower.sStatus:CreateFontString(nil, "OVERLAY")
	cmPower.text:SetFont(C.media.uffont, 12)
	cmPower.text:Point("CENTER", cmPower.sStatus)
	cmPower.text:SetShadowColor(0, 0, 0)
	cmPower.text:SetShadowOffset(1.25, -1.25)
end

local function OnUpdate()
	local value = UnitPower("player")
    cmPower.sStatus:SetValue(value)
	if O.text == true then 
		cmPower.text:SetText(value)
	end
end

local OnShow = function(self)
	self:SetScript("OnUpdate", OnUpdate)
end

local OnHide = function(self)
	self:SetScript("OnUpdate", nil)
end

cmPower:RegisterEvent("PLAYER_ENTERING_WORLD")
cmPower:RegisterEvent("UNIT_DISPLAYPOWER")
cmPower:RegisterEvent("PLAYER_REGEN_DISABLED")
cmPower:RegisterEvent("PLAYER_REGEN_ENABLED")
cmPower:RegisterEvent("UNIT_POWER")
cmPower:SetScript("OnEvent", function(self, event)
	local p, pname = UnitPowerType("player")
	local valueMax = UnitPowerMax("player", p)
	local color = O["color"][pname]
	if color then
		cmPower.sStatus:SetStatusBarColor(unpack(color))
	end
	self.sStatus:SetMinMaxValues(0, valueMax)
	if O.autohide == true then
		if event == "PLAYER_REGEN_DISABLED" then
			cmPower:Show()
		elseif event == "UNIT_POWER" then
			if InCombatLockdown() then
				cmPower:Show()
			end
		else
			cmPower:Hide()
		end
		-- if p == SPELL_POWER_ENERGY  then
			-- if event == "PLAYER_REGEN_DISABLED" then
				-- cmPower:Show()
			-- elseif event == "UNIT_POWER" then
				-- if InCombatLockdown( then
					-- cmPower:Show()
				-- end
			-- else
				-- cmPower:Hide()
			-- end
		-- elseif p == SPELL_POWER_MANA then -- and T.myclass ~= "DRUID" then
			-- if event == "PLAYER_REGEN_DISABLED" then
				-- cmPower:Show()
			-- elseif event == "UNIT_POWER" then
				-- if InCombatLockdown( then
					-- cmPower:Show()
				-- end
			-- else
				-- cmPower:Hide()
			-- end
		-- else
			-- cmPower:Hide()
		-- end
	end
end)

cmPower:SetScript("OnShow", OnShow) -- This is what stops constant OnUpdate
cmPower:SetScript("OnHide", OnHide)

-- If autohide is not set, show frame
if O.autohide ~= true then
	if cmPower:IsShown() then
		cmPower:SetScript("OnUpdate", OnUpdate)
	else
		cmPower:Show()
	end
end