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
local GetAnchor = Engine.GetAnchor
local GetWidth = Engine.GetWidth
local GetHeight = Engine.GetHeight

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
	--frame:Point(unpack(self.settings.anchor))
	--frame:Size(self.settings.width, self.settings.height)
	frame:Point(unpack(GetAnchor(self.settings)))
	frame:Size(GetWidth(self.settings), GetHeight(self.settings))
	-- Create points
	--local width, spacing = PixelPerfect(self.settings.width, self.count)
	local width, spacing = PixelPerfect(GetWidth(self.settings), self.count)
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