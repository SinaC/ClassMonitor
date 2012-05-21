-- Eclipse plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

if T.myclass ~= "DRUID" then
	return
end

local function UnitPowerHandler(cmEclipse)
	--print("UnitPower:"..tostring(cmEclipse))
	local power = UnitPower("player", SPELL_POWER_ECLIPSE)
	local maxPower = UnitPowerMax("player", SPELL_POWER_ECLIPSE)

	--print("Power:"..tostring(power).." / "..tostring(maxPower))
	if cmEclipse.cmLunar then
		cmEclipse.cmLunar:SetMinMaxValues(-maxPower, maxPower)
		cmEclipse.cmLunar:SetValue(power)
	end

	if cmEclipse.cmSolar then
		cmEclipse.cmSolar:SetMinMaxValues(-maxPower, maxPower)
		cmEclipse.cmSolar:SetValue(power * -1)
	end
end

local function UpdateVisibilityHandler(cmEclipse)
	--print("UpdateVisibility:"..tostring(cmEclipse))
	-- -- check form/mastery
	local showBar = false
	local form = GetShapeshiftFormID()
	if not form then
		local ptt = GetPrimaryTalentTree()
		if ptt and ptt == 1 then -- player has balance spec
			showBar = true
		end
	elseif form == MOONKIN_FORM then
		showBar = true
	end

	--print("showBar:"..tostring(showBar))
	if showBar then
		cmEclipse:Show()
	else
		cmEclipse:Hide()
	end
end

local function UnitAuraHandler(cmEclipse, colors)
	--print("UnitAura:"..tostring(cmEclipse))
	local hasSolarEclipse = false
	local hasLunarEclipse = false

	for i = 1, 40, 1 do
		local name, _, _, _, _, _, _, _, _, _, spellID = UnitAura("player", i, "HELPFUL|PLAYER")
		if not name then break end

		if spellID == ECLIPSE_BAR_SOLAR_BUFF_ID then
			--print("ECLIPSE_BAR_SOLAR_BUFF_ID")
			hasSolarEclipse = true
		elseif spellID == ECLIPSE_BAR_LUNAR_BUFF_ID then
			--print("ECLIPSE_BAR_LUNAR_BUFF_ID")
			hasLunarEclipse = true
		end
	end

	-- TODO: change border while in eclipse
	if hasSolarEclipse then
		cmEclipse:SetBackdropBorderColor(unpack(colors[1]))
	elseif hasLunarEclipse then
		cmEclipse:SetBackdropBorderColor(unpack(colors[2]))
	else
		cmEclipse:SetBackdropBorderColor(unpack(C.general.bordercolor))
	end
end

function CreateEclipseMonitor(name, anchor, width, height, colors)
	local cmEclipse = CreateFrame("Frame", name, UIParent)
	cmEclipse:CreatePanel("Default", width, height, unpack(anchor))
	cmEclipse:SetTemplate("Default")

	local cmLunar = CreateFrame("StatusBar", name.."_lunar", cmEclipse)
	cmLunar:Point('TOPLEFT', cmEclipse, 'TOPLEFT', 2, -2)
	cmLunar:Size(cmEclipse:GetWidth()-4, cmEclipse:GetHeight()-4)
	cmLunar:SetStatusBarTexture(C.media.normTex)
	cmLunar:SetStatusBarColor(unpack(colors[1]))
	cmEclipse.cmLunar = cmLunar

	local cmSolar = CreateFrame("StatusBar", name.."_solar", cmEclipse)
	cmSolar:Point('LEFT', cmLunar:GetStatusBarTexture(), 'RIGHT', 0, 0)
	cmSolar:Size(cmEclipse:GetWidth()-4, cmEclipse:GetHeight()-4)
	cmSolar:SetStatusBarTexture(C.media.normTex)
	cmSolar:SetStatusBarColor(unpack(colors[2]))
	cmEclipse.cmSolar = cmSolar

	UnitPowerHandler(cmEclipse)

	cmEclipse:RegisterEvent("UNIT_POWER")
	cmEclipse:RegisterEvent("UPDATE_VISIBILITY")
	cmEclipse:RegisterEvent("PLAYER_TALENT_UPDATE")
	cmEclipse:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	cmEclipse:RegisterEvent("UNIT_AURA")
	-- cmEclipse:RegisterEvent("ECLIPSE_DIRECTION_CHANGE", EclipseDirectionChange)
	cmEclipse:SetScript("OnEvent", function(self, event, arg1, arg2)
		--print("OnEvent:"..event.." "..tostring(arg1).."  "..tostring(arg2))
		if event == "UNIT_POWER" and arg1 == "player" and arg2 == "ECLIPSE" then
			UnitPowerHandler(self)
		elseif event == "UPDATE_VISIBILITY" or event == "PLAYER_TALENT_UPDATE" or event == "UPDATE_SHAPESHIFT_FORM" then
			UpdateVisibilityHandler(self)
		elseif event == "UNIT_AURA" and arg1 == "player" then 
			UnitAuraHandler(self, colors) 
		--elseif event == "ECLIPSE_DIRECTION_CHANGE" then
		--	EclipseDirectionChange(arg1, self)
		end
	end)

	return cmEclipse
end