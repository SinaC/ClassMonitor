-- Power plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

-- ONLY ON PTR
--if not Engine.IsPTR() then return end

local CheckSpec = Engine.CheckSpec
local PixelPerfect = Engine.PixelPerfect
local DefaultBoolean = Engine.DefaultBoolean
local GetColor = Engine.GetColor

--
local plugin = Engine:NewPlugin("POWER")

-- own methods
function plugin:UpdateVisibility(event)
	--
--print("POWER:UpdateVisibility")
	local inCombat = true
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	--
	if (self.settings.autohide == false or inCombat) and CheckSpec(self.settings.specs) then
--print("SHOW")
		--
		--self:UpdateMaxValue()
		self:UpdateValue()
		--
		self.frame:Show()
	else
--print("HIDE")
		self.frame:Hide()
	end
end

--[[
function plugin:UpdateMaxValue(event, unit, powerType)
	--
--print("POWER:UpdateMaxValue:"..tostring(event).."  "..tostring(unit).."  "..tostring(powerType))
	local maxValue = UnitPowerMax("player", self.settings.powerType)
--print("MAX:"..tostring(event).."  maxValue:"..tostring(maxValue).."  count:"..tostring(self.count).."  max:"..tostring(self.maxValue))
	if maxValue ~= self.maxValue then
		-- compute new width, spacing
		local width, spacing = PixelPerfect(self.settings.width, maxValue)
		if maxValue > self.count then
			self.count = maxValue
		end
		for i = 1, self.count do
			self:UpdatePointGraphics(i, width, spacing)
			self.points[i]:Hide()
		end

-- --print("WIDTH:"..tostring(width).."  SPACING:"..tostring(spacing))
		-- -- create new points if needed
		-- if maxValue > self.count then
			-- for i = self.count+1, maxValue do
				-- self:CreatePoint(i, width, spacing)
			-- end
			-- self.count = maxValue
		-- end
		-- -- hide all points
		-- for i = 1, self.count do
			-- self.points[i]:Hide()
		-- end
		-- -- resize points
		-- for i = 1, maxValue do
			-- local point = self.points[i]
			-- point:Size(width, self.settings.height)
			-- if i ~= 1 then -- first point doesn't move
				-- point:ClearAllPoints()
				-- point:Point("LEFT", self.points[i-1], "RIGHT", spacing, 0)
			-- end
		-- end

		self.maxValue = maxValue
		--
		self:UpdateValue()
	end
end

function plugin:UpdateValue(event, unit, powerType)
	--
	--if powerType ~= "CHI" then return end
--print("POWER:UpdateValue:"..tostring(event).."  "..tostring(unit).."  "..tostring(powerType))
	local value = UnitPower("player", self.settings.powerType)
--print("CURRENT:"..tostring(value).."  count:"..tostring(self.count).."  max:"..tostring(self.maxValue))
	if value and value > 0 then
		--assert(value <= self.maxValue and value <= self.count, "Current value:"..tostring(value).." should be <= to maxValue:"..tostring(self.maxValue).." and <= to count:"..tostring(self.count))
		assert(value <= self.count, "Current value:"..tostring(value).." must be <= to count:"..tostring(self.count))
		for i = 1, value do self.points[i]:Show() end
		for i = value+1, self.count do self.points[i]:Hide() end
	else
		for i = 1, self.count do self.points[i]:Hide() end
	end
end
--]]

function plugin:UpdateValue(event, unit, powerType)
-- TODO: only for monitored power type     parameter powerType is a string (MANA, FOCUS, CHI, ...) but UnitPower/UnitPowerMax use an id
--[[
	-- only for monitored power type
	local resource = UnitPowerType("player", powerType)
print("POWERTYPE:"..tostring(powerType).."  "..tostring(self.settings.powerType).."  "..tostring(resource))
	if resource ~= self.settings.powerType then return end
--]]
	--
	local maxValue = UnitPowerMax("player", self.settings.powerType)
	if maxValue and maxValue > 0 and maxValue ~= self.maxValue then
		-- compute new width, spacing
		if maxValue > self.count then
			self.count = maxValue
		end
		-- update points (create any needed points)
		local width, spacing = PixelPerfect(self.settings.width, maxValue)
		for i = 1, self.count do
			self:UpdatePointGraphics(i, width, spacing)
			self.points[i]:Hide()
		end
		-- update current max
		self.maxValue = maxValue
	end
	--
	local value = UnitPower("player", self.settings.powerType)
	if value and value > 0 then
		assert(value <= self.count, "Current value:"..tostring(value).." must be <= to count:"..tostring(self.count))
		for i = 1, value do self.points[i]:Show() end
		for i = value+1, self.count do self.points[i]:Hide() end
	else
		for i = 1, self.count do self.points[i]:Hide() end
	end
end

function plugin:UpdatePointGraphics(index, width, spacing)
	--
	local point = self.points[index]
	if not point then
		point = CreateFrame("Frame", nil, self.frame)
		point:SetTemplate()
		point:SetFrameStrata("BACKGROUND")
		point:Hide()
		self.points[index] = point
	end
	point:Size(width, self.settings.height)
	point:ClearAllPoints()
	if index == 1 then
		point:Point("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
	else
		point:Point("LEFT", self.points[index-1], "RIGHT", spacing, 0)
	end
	--
	if self.settings.filled == true and not point.status then
		point.status = CreateFrame("StatusBar", nil, point)
		point.status:SetStatusBarTexture(UI.NormTex)
		point.status:SetFrameLevel(6)
		point.status:Point("TOPLEFT", point, "TOPLEFT", 2, -2)
		point.status:Point("BOTTOMRIGHT", point, "BOTTOMRIGHT", -2, 2)
	end
	--
	local color = GetColor(self.settings.colors, index, UI.ClassColor())
	if self.settings.filled == true then
		point.status:SetStatusBarColor(unpack(color))
		point.status:Show()
		point:SetBackdropBorderColor(unpack(UI.BorderColor))
	else
		point:SetBackdropBorderColor(unpack(color))
		if point.status then point.status:Hide() end
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
	local width, spacing = PixelPerfect(self.settings.width, self.maxValue)
	self.points = self.points or {}
	for i = 1, self.count do
		self:UpdatePointGraphics(i, width, spacing)
	end
end

-- overridden methods
function plugin:Initialize()
	-- set defaults
	self.settings.count = self.settings.count or 1 -- starts with count = 1 if count not found in settings
	self.settings.filled = DefaultBoolean(self.settings.filled, false)
	self.settings.powerType = self.settings.powerType or SPELL_POWER_HOLY_POWER --
	--local color = self.settings.color or UI.PowerColor(self.settings.powerType) or UI.ClassColor()
	--self.settings.colors = self.settings.colors or CreateColorArray(color, self.settings.count)
	self.settings.colors = self.settings.colors or self.settings.color or UI.PowerColor(self.settings.powerType) or UI.ClassColor()
	--
	self.count = self.settings.count
	self.maxValue = self.count -- current max value (<= count)
	-- Create a frame including every points
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player", plugin.UpdateVisibility)

	self:RegisterUnitEvent("UNIT_POWER", "player", plugin.UpdateValue)
	--self:RegisterUnitEvent("UNIT_MAXPOWER", "player", plugin.UpdateMaxValue)   if a monk is at 4 chi and learn talent Ascension  UNIT_POWER (5 chi) will be called before UNIT_MAXPOWER (max 5 chi)
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player", plugin.UpdateValue)
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
	-- if pluginSettings.kind == "POWER" then
		-- local setting = Engine.DeepCopy(pluginSettings)
		-- setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		-- setting.specs = {SPEC_WARLOCK_AFFLICTION}
		-- setting.enable = true
		-- local color = setting.color or UI.PowerColor(setting.powerType) or UI.ClassColor()
		-- setting.colors = setting.colors or {color, color,  color, color, color}
		-- local instance = Engine:NewPluginInstance("POWER", "POWER"..tostring(i), setting)
		-- instance:Initialize()
		-- if setting.enable then
			-- instance:Enable()
		-- end
	-- end
-- end