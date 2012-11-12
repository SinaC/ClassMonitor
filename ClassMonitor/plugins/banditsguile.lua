-- Bandit's Guile plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

if UI.MyClass ~= "ROGUE" then return end -- meaningless for non-rogue

-- ONLY ON PTR
--if not Engine.IsPTR() then return end

local PixelPerfect = Engine.PixelPerfect
local DefaultBoolean = Engine.DefaultBoolean
local GetColor = Engine.GetColor

--
local plugin = Engine:NewPlugin("BANDITSGUILE")

local shallowInsight = GetSpellInfo(84745)
local moderateInsight = GetSpellInfo(84746)
local deepInsight = GetSpellInfo(84747)

local DefaultColors = {
	{0.33, 0.63, 0.33, 1}, -- shallow
	{0.65, 0.63, 0.35, 1}, -- moderate
	{0.69, 0.31, 0.31, 1}, -- deep
}


-- own methods
function plugin:UpdateVisibility(event)
	local inCombat = true
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	if (self.settings.autohide == false or inCombat) and GetSpecialization() == 2 then -- only in combat spec
		self:RegisterUnitEvent("UNIT_AURA", "player", plugin.UpdateValue)
		self:UpdateValue() -- at least one update
		self.frame:Show()
	else
		self:UnregisterEvent("UNIT_AURA")
		self.frame:Hide()
	end
end

function plugin:UpdateValue()
	local _, _, _, shallow = UnitBuff("player", shallowInsight, nil, "HELPFUL")
	local _, _, _, moderate = UnitBuff("player", moderateInsight, nil, "HELPFUL")
	local _, _, _, deep = UnitBuff("player", deepInsight, nil, "HELPFUL")
	if shallow or moderate or deep then
		if shallow then self.points[1]:Show() end
		if moderate then self.points[2]:Show() end
		if deep then self.points[3]:Show() end
	else
		for i = 1, self.count do self.points[i]:Hide() end
	end
end

function plugin:UpdateGraphics()
	-- Create a frame including every points
	local frame = self.frame
	if not frame then
		frame = CreateFrame("Frame", self.name, UI.PetBattleHider)
		frame:Hide()
		self.frame = frame
	end
	frame:ClearAllPoints()
	frame:Point(unpack(self.settings.anchor))
	frame:Size(self.settings.width, self.settings.height)
	-- Create points
	local width, spacing = PixelPerfect(self.settings.width, self.count)
	self.points = self.points or {}
	for i = 1, self.count do
		local point = self.points[i]
		if not point then
			point = CreateFrame("Frame", nil, self.frame)
			point:SetTemplate()
			point:SetFrameStrata("BACKGROUND")
			point:Hide()
			self.points[i] = point
		end
		point:Size(width, self.settings.height)
		point:ClearAllPoints()
		if i == 1 then
			point:Point("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
		else
			point:Point("LEFT", self.points[i-1], "RIGHT", spacing, 0)
		end
		if self.settings.filled == true and not point.status then
			point.status = CreateFrame("StatusBar", nil, point)
			point.status:SetStatusBarTexture(UI.NormTex)
			point.status:SetFrameLevel(6)
			point.status:Point("TOPLEFT", point, "TOPLEFT", 2, -2)
			point.status:Point("BOTTOMRIGHT", point, "BOTTOMRIGHT", -2, 2)
		end
		local color = GetColor(self.settings.colors, i, DefaultColors[i])
		if self.settings.filled == true then
			point.status:SetStatusBarColor(unpack(color))
			point.status:Show()
			point:SetBackdropBorderColor(unpack(UI.BorderColor))
		else
			point:SetBackdropBorderColor(unpack(color))
			if point.status then point.status:Hide() end
		end
	end
end

-- overridden methods
function plugin:Initialize()
	-- set defaults
	self.settings.filled = DefaultBoolean(self.settings.filled, false)
	self.settings.colors = self.settings.colors or DefaultColors
	--
	self.count = 3
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", plugin.UpdateVisibility)
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player", plugin.UpdateVisibility)
end

function plugin:Disable()
	--
	self:UnregisterAllEvents()
	--
	self.frame:Hide()
end

function plugin:SettingsModified()
	--
	self:Disable()
	--
	self:UpdateGraphics()
	--
	if self.settings.enable == true then
		self:Enable()
		self:UpdateVisibility()
	end
end

-- ----------------------------------------------
-- -- test
-- ----------------------------------------------
-- local C = Engine.Config
-- local settings = C[UI.MyClass]
-- if not settings then return end
-- for i, pluginSettings in ipairs(settings) do
	-- if pluginSettings.kind == "BANDITSGUILE" then
		-- local setting = Engine.DeepCopy(pluginSettings)
		-- setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		-- setting.enable = true
		-- setting.autohide = false
		-- setting.filled = true
		-- local instance = Engine:NewPluginInstance("BANDITSGUILE", "BANDITSGUILE"..tostring(i), setting)
		-- instance:Initialize()
		-- if setting.enable then
			-- instance:Enable()
		-- end
	-- end
-- end

--[[
-- Create Bandit's Guile monitor
Engine.CreateBanditsGuileMonitor = function(name, enable, autohide, anchor, totalWidth, height, colors, filled)
	local cmBanditsGuiles = {}
	local count = 3
	local width, spacing = PixelPerfect(totalWidth, count)
	for i = 1, count do
		local cmBanditGuile = CreateFrame("Frame", name, UI.PetBattleHider)
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
--]]
--[[
Engine.CreateBanditsGuileMonitor = function(name, enable, autohide, anchor, width, height, spacing, colors, filled)
	local cmBanditsGuiles = {}
	for i = 1, 3 do
		local cmBanditGuile = CreateFrame("Frame", name, UI.PetBattleHider)
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