-- Runes plugin (based on fRunes by Krevlorne [https://github.com/Krevlorne])
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

if UI.MyClass ~= "DEATHKNIGHT" then return end -- only for DK

local PixelPerfect = Engine.PixelPerfect
local DefaultBoolean = Engine.DefaultBoolean
local GetColor = Engine.GetColor

--
local plugin = Engine:NewPlugin("RUNES")

local DefaultColors = {
	{ 0.69, 0.31, 0.31, 1 }, -- Blood
	{ 0.33, 0.59, 0.33, 1 }, -- Unholy
	{ 0.31, 0.45, 0.63, 1 }, -- Frost
	{ 0.84, 0.75, 0.65, 1 }, -- Death
}

-- own methods
function plugin:UpdateVisibility(event)
	local inCombat = true
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	if self.settings.autohide == false or inCombat then
		--UIFrameFadeIn(self, (0.3 * (1-self.frame:GetAlpha())), self.frame:GetAlpha(), 1)
		self.frame:Show()
		self.timeSinceLastUpdate = GetTime()
		self:RegisterUpdate(plugin.Update)
	else
		--UIFrameFadeOut(self, (0.3 * (0+self.frame:GetAlpha())), self.frame:GetAlpha(), 0)
		self.frame:Hide()
		self:UnregisterUpdate()
	end
end

function plugin:Update(elapsed)
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
	if self.timeSinceLastUpdate > self.settings.updatethreshold then
		local runesReady = 0
		for i = 1, self.count do
			local runeIndex = self.settings.runemap[i]
			local start, duration, finished = GetRuneCooldown(runeIndex)
			local runeType = GetRuneType(runeIndex)

			local rune = self.runes[i]
			local color = GetColor(self.settings.colors[runeType], runeType, DefaultColors[runeType])
			rune.status:SetStatusBarColor(unpack(color))
			rune.status:SetMinMaxValues(0, duration)

			if finished then
				rune.status:SetValue(duration)
			else
				rune.status:SetValue(GetTime() - start)
			end
		end
		self.timeSinceLastUpdate = 0
	end
end

function plugin:UpdateGraphics()
	-- Create a frame including every runes
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
	-- Create runes
	local width, spacing = PixelPerfect(frameWidth, self.count)
	self.runes = self.runes or {}
	for i = 1, self.count do
		local rune = self.runes[i]
		if not rune then
			rune = CreateFrame("Frame", nil, self.frame)
			rune:SetTemplate()
			rune:SetFrameStrata("BACKGROUND")
			self.runes[i] = rune
		end
		rune:Size(width, height)
		rune:ClearAllPoints()
		if i == 1 then
			rune:Point("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
		else
			rune:Point("LEFT", self.runes[i-1], "RIGHT", spacing, 0)
		end
		if not rune.status then
			rune.status = CreateFrame("StatusBar", nil, rune)
			rune.status:SetStatusBarTexture(UI.NormTex)
			rune.status:SetFrameLevel(6)
			rune.status:SetInside()
			rune.status:SetMinMaxValues(0, 10)
		end
		local colorIndex = math.ceil(self.settings.runemap[i]/2)
		local color = GetColor(self.settings.colors[colorIndex], colorIndex, DefaultColors[colorIndex])
		rune.status:SetStatusBarColor(unpack(color))
		rune.status:SetOrientation(self.settings.orientation)
	end
end

-- overridden methods
function plugin:Initialize()
	-- set defaults
	self.settings.updatethreshold = self.settings.updatethreshold or 0.1
	self.settings.orientation = self.settings.orientation or "HORIZONTAL"
	-- runemap instructions.
	-- This is the order you want your runes to be displayed in (down to bottom or left to right).
	-- 1,2 = Blood
	-- 3,4 = Unholy
	-- 5,6 = Frost
	-- (Note: All numbers must be included or it will break)
	self.settings.runemap = self.settings.runemap or { 1, 2, 3, 4, 5, 6 }
	self.settings.colors = self.settings.colors or DefaultColors
	--
	self.count = 6
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
end

function plugin:Disable()
	--
	self:UnregisterAllEvents()
	self:UnregisterUpdate()
	--
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