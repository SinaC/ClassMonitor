-- Combo Points plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

if UI.MyClass ~= "ROGUE" and UI.MyClass ~= "DRUID" then return end -- combo not needed for other classes

local CheckSpec = Engine.CheckSpec
local PixelPerfect = Engine.PixelPerfect
local DefaultBoolean = Engine.DefaultBoolean
local GetColor = Engine.GetColor

--
local plugin = Engine:NewPlugin("COMBO")

local DefaultColors = {
	{0.69, 0.31, 0.31, 1}, -- 1
	{0.65, 0.42, 0.31, 1}, -- 2
	{0.65, 0.63, 0.35, 1}, -- 3
	{0.46, 0.63, 0.35, 1}, -- 4
	{0.33, 0.63, 0.33, 1}, -- 5
}

-- own methods
function plugin:UpdateVisibility(event)
	local inCombat = true
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	if (self.settings.autohide == false or inCombat) and CheckSpec(self.settings.specs) then
		self.frame:Show()
		self:UpdateValue()
	else
		self.frame:Hide()
	end
end

function plugin:UpdateValue()
	local points = GetComboPoints("player", "target")
	if points and points > 0 then
		for i = 1, points do self.points[i]:Show() end
		for i = points+1, self.count do self.points[i]:Hide() end
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
	local frameWidth = self:GetWidth()
	local height = self:GetHeight()
	frame:ClearAllPoints()
	frame:Point(unpack(self:GetAnchor()))
	frame:Size(frameWidth, height)
	-- Create points
	local width, spacing = PixelPerfect(frameWidth, self.count)
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
		point:Size(width, height)
		point:ClearAllPoints()
		if i == 1 then
			point:Point("TOPLEFT", frame, "TOPLEFT", 0, 0)
		else
			point:Point("LEFT", self.points[i-1], "RIGHT", spacing, 0)
		end
		if self.settings.filled == true and not point.status then
			point.status = CreateFrame("StatusBar", nil, point)
			point.status:SetStatusBarTexture(UI.NormTex)
			point.status:SetFrameLevel(6)
			point.status:SetInside()
		end
		local color = GetColor(self.settings.colors, i, DefaultColors[i])
		if self.settings.filled == true then
			point.status:SetStatusBarColor(unpack(color))
			point.status:Show()
			point:SetBackdropBorderColor(unpack(UI.BorderColor))
		else
			point:SetBackdropBorderColor(unpack(color))
			--point:SetBackdropColor(1, 0, 1, 1) just a test
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
	self.count = 5
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", plugin.UpdateVisibility)
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player", plugin.UpdateVisibility)

	self:RegisterUnitEvent("UNIT_COMBO_POINTS", "player", plugin.UpdateValue)
end

function plugin:Disable()
	self:UnregisterAllEvents()

	self.frame:Hide()
end

function plugin:SettingsModified()
	--
	self:Disable()
	--
	self:UpdateGraphics()
	--
	if self:IsEnabled() then
		self:Enable()
		self:UpdateVisibility()
	end
end