-- Burning Embers plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

if UI.MyClass ~= "WARLOCK" then return end -- Available only for warlocks

-- ONLY ON PTR
--if not Engine.IsPTR() then return end

local PixelPerfect = Engine.PixelPerfect
local GetAnchor = Engine.GetAnchor
local GetWidth = Engine.GetWidth
local GetHeight = Engine.GetHeight
local PowerColor = UI.PowerColor

--
local plugin = Engine:NewPlugin("BURNINGEMBERS")

-- own methods
function plugin:UpdateValue()
	local value = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)
	local maxValue = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true)
	local numBars = floor(maxValue / MAX_POWER_PER_EMBER)

	if numBars ~= self.numBars then
		-- compute new width, spacing
		if numBars > self.count then
			self.count = numBars
		end
		-- update bars (create any needed bars)
		--local width, spacing = PixelPerfect(self.settings.width, numBars)
		local width, spacing = PixelPerfect(GetWidth(self.settings), numBars)
		for i = 1, self.count do
			self:UpdateBarGraphics(i, width, spacing)
			self.bars[i]:Hide()
		end
		-- update current max
		self.numBars = numBars
	end
	for i = 1, numBars do
		local bar = self.bars[i]
		bar.status:SetMinMaxValues((MAX_POWER_PER_EMBER * i) - MAX_POWER_PER_EMBER, MAX_POWER_PER_EMBER * i)
		bar.status:SetValue(value)
		bar:Show()
	end
	for i = numBars+1, self.count do -- hide remaining bars
		self.bars[i]:Hide()
	end
end

function plugin:UpdateVisibility(event)
	--
	local inCombat = true
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	--
	if (self.settings.autohide == false or inCombat) and GetSpecialization() == SPEC_WARLOCK_DESTRUCTION then
		--
		self:UpdateValue()
		--
		self.frame:Show()
	else
		self.frame:Hide()
	end
end

function plugin:UpdateBarGraphics(index, width, spacing)
	--
	local bar = self.bars[index]
	if not bar then
		bar = CreateFrame("Frame", nil, self.frame)
		bar:SetTemplate()
		bar:SetFrameStrata("BACKGROUND")
		bar:Hide()
		self.bars[index] = bar
	end
	bar:Size(width, self.settings.height)
	bar:ClearAllPoints()
	if index == 1 then
		bar:Point("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
	else
		bar:Point("LEFT", self.bars[index-1], "RIGHT", spacing, 0)
	end
	--
	if not bar.status then
		bar.status = CreateFrame("StatusBar", nil, bar)
		bar.status:SetStatusBarTexture(UI.NormTex)
		bar.status:SetFrameLevel(6)
		bar.status:Point("TOPLEFT", bar, "TOPLEFT", 2, -2)
		bar.status:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)
	end
	bar.status:SetStatusBarColor(unpack(self.settings.color))
end

function plugin:UpdateGraphics()
	-- Create a frame including every bars
	local frame = self.frame
	if not frame then
		frame = CreateFrame("Frame", self.name, UI.PetBattleHider)
		frame:Hide()
		self.frame = frame
	end
	frame:ClearAllPoints()
	-- frame:Point(unpack(self.settings.anchor))
	-- frame:Size(self.settings.width, self.settings.height)
	frame:Point(unpack(GetAnchor(self.settings)))
	frame:Size(GetWidth(self.settings), GetHeight(self.settings))
	-- Create bars
	--local width, spacing = PixelPerfect(self.settings.width, self.numBars)
	local width, spacing = PixelPerfect(GetWidth(self.settings), self.numBars)
	self.bars = self.bars or {}
	for i = 1, self.count do
		self:UpdateBarGraphics(i, width, spacing)
	end
end

-- overridden methods
function plugin:Initialize()
	-- set defaults
	self.settings.color = self.settings.color or PowerColor(SPELL_POWER_BURNING_EMBERS) or {222/255, 95/255,  95/255, 1}
	--
	self.count = 4
	self.numBars = self.count
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player", plugin.UpdateVisibility)

	self:RegisterUnitEvent("UNIT_POWER", "player", plugin.UpdateValue)
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
	self.numBars = 4
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