-- Bandit's Guile plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

local PixelPerfect = Engine.PixelPerfect

local shallowInsight = GetSpellInfo(84745)
local moderateInsight = GetSpellInfo(84746)
local deepInsight = GetSpellInfo(84747)

-- Create Bandit's Guile monitor
Engine.CreateBanditsGuileMonitor = function(name, enable, autohide, anchor, totalWidth, height, colors, filled)
	local cmBanditsGuiles = {}
	local count = 3
	local width, spacing = PixelPerfect(totalWidth, count)
	for i = 1, count do
		local cmBanditGuile = CreateFrame("Frame", name, UI.BattlerHider)
		cmBanditGuile:SetTemplate()
		cmBanditGuile:SetFrameStrata("BACKGROUND")
		cmBanditGuile:Size(width, height)
		if i == 1 then
			cmBanditGuile:Point(unpack(anchor))
		else
			cmBanditGuile:Point("LEFT", cmBanditsGuiles[i-1], "RIGHT", spacing, 0)
		end
		if filled then
			cmBanditGuile.status = CreateFrame("StatusBar", name.."_status_"..i, cmBanditGuile)
			cmBanditGuile.status:SetStatusBarTexture(UI.NormTex)
			cmBanditGuile.status:SetFrameLevel(6)
			cmBanditGuile.status:Point("TOPLEFT", cmBanditGuile, "TOPLEFT", 2, -2)
			cmBanditGuile.status:Point("BOTTOMRIGHT", cmBanditGuile, "BOTTOMRIGHT", -2, 2)
			cmBanditGuile.status:SetStatusBarColor(unpack(colors[i]))
		else
			cmBanditGuile:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmBanditGuile:Hide()

		tinsert(cmBanditsGuiles, cmBanditGuile)
	end

	if not enable then
		for i = 1, count do cmBanditsGuiles[i]:Hide() end
		return
	end

	cmBanditsGuiles[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmBanditsGuiles[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmBanditsGuiles[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmBanditsGuiles[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmBanditsGuiles[1]:RegisterUnitEvent("UNIT_AURA", "player")
	cmBanditsGuiles[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmBanditsGuiles[1]:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		local _, _, _, shallow = UnitBuff("player", shallowInsight)
		local _, _, _, moderate = UnitBuff("player", moderateInsight)
		local _, _, _, deep = UnitBuff("player", deepInsight)
		if visible and GetSpecialization() == 2 and (shallow or moderate or deep) then
			if shallow then cmBanditsGuiles[1]:Show() end
			if moderate then cmBanditsGuiles[2]:Show() end
			if deep then cmBanditsGuiles[3]:Show() end
		else
			for i = 1, count do cmBanditsGuiles[i]:Hide() end
		end
	end)

	return cmBanditsGuiles[1]
end

--[[
Engine.CreateBanditsGuileMonitor = function(name, enable, autohide, anchor, width, height, spacing, colors, filled)
	local cmBanditsGuiles = {}
	for i = 1, 3 do
		local cmBanditGuile = CreateFrame("Frame", name, UI.BattlerHider)
		cmBanditGuile:SetTemplate()
		cmBanditGuile:SetFrameStrata("BACKGROUND")
		cmBanditGuile:Size(width, height)
		if i == 1 then
			cmBanditGuile:Point(unpack(anchor))
		else
			cmBanditGuile:Point("LEFT", cmBanditsGuiles[i-1], "RIGHT", spacing, 0)
		end
		if filled then
			cmBanditGuile.status = CreateFrame("StatusBar", name.."_status_"..i, cmBanditGuile)
			cmBanditGuile.status:SetStatusBarTexture(UI.NormTex)
			cmBanditGuile.status:SetFrameLevel(6)
			cmBanditGuile.status:Point("TOPLEFT", cmBanditGuile, "TOPLEFT", 2, -2)
			cmBanditGuile.status:Point("BOTTOMRIGHT", cmBanditGuile, "BOTTOMRIGHT", -2, 2)
			cmBanditGuile.status:SetStatusBarColor(unpack(colors[i]))
		else
			cmBanditGuile:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmBanditGuile:Hide()

		tinsert(cmBanditsGuiles, cmBanditGuile)
	end

	if not enable then
		for i = 1, 3 do cmBanditsGuiles[i]:Hide() end
		return
	end

	cmBanditsGuiles[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmBanditsGuiles[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmBanditsGuiles[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmBanditsGuiles[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmBanditsGuiles[1]:RegisterUnitEvent("UNIT_AURA", "player")
	cmBanditsGuiles[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmBanditsGuiles[1]:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		local _, _, _, shallow = UnitBuff("player", shallowInsight)
		local _, _, _, moderate = UnitBuff("player", moderateInsight)
		local _, _, _, deep = UnitBuff("player", deepInsight)
		if visible and GetSpecialization() == 2 and (shallow or moderate or deep) then
			if shallow then cmBanditsGuiles[1]:Show() end
			if moderate then cmBanditsGuiles[2]:Show() end
			if deep then cmBanditsGuiles[3]:Show() end
		else
			for i = 1, 3 do cmBanditsGuiles[i]:Hide() end
		end
	end)

	return cmBanditsGuiles[1]
end
--]]