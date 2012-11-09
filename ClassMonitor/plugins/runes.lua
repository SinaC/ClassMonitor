-- Runes plugin (based on fRunes by Krevlorne [https://github.com/Krevlorne])
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

if UI.MyClass ~= "DEATHKNIGHT" then return end -- only for DK

-- ONLY ON PTR
--if not Engine.IsPTR() then return end

local PixelPerfect = Engine.PixelPerfect

--
local plugin = Engine:NewPlugin("RUNES")

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
			rune.status:SetStatusBarColor(unpack(self.settings.colors[runeType]))
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
	frame:ClearAllPoints()
	frame:Point(unpack(self.settings.anchor))
	frame:Size(self.settings.width, self.settings.height)
	-- Create runes
	local width, spacing = PixelPerfect(self.settings.width, self.count)
	self.runes = self.runes or {}
	for i = 1, self.count do
		local rune = self.runes[i]
		if not rune then
			rune = CreateFrame("Frame", nil, self.frame)
			rune:SetTemplate()
			rune:SetFrameStrata("BACKGROUND")
			self.runes[i] = rune
		end
		rune:Size(width, self.settings.height)
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
			rune.status:Point("TOPLEFT", rune, "TOPLEFT", 2, -2)
			rune.status:Point("BOTTOMRIGHT", rune, "BOTTOMRIGHT", -2, 2)
			rune.status:SetMinMaxValues(0, 10)
		end
		local colorIndex = math.ceil(self.settings.runemap[i]/2)
		rune.status:SetStatusBarColor(unpack(self.settings.colors[colorIndex]))
		rune.status:SetOrientation(self.settings.orientation)
	end
end

-- overridden methods
function plugin:Initialize()
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
	-- if pluginSettings.kind == "RUNES" then
		-- local setting = Engine.DeepCopy(pluginSettings)
		-- setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		-- setting.enable = true
		-- setting.autohide = false
		-- setting.updatethreshold = setting.updatethreshold or 0.1
		-- setting.orientation = setting.orientation or "HORIZONTAL"
		-- local instance = Engine:NewPluginInstance("RUNES", "RUNES"..tostring(i), setting)
		-- instance:Initialize()
		-- if setting.enable then
			-- instance:Enable()
		-- end
	-- end
-- end

--[[
-- Create Runes monitor
--Engine.CreateRunesMonitor = function(name, enable, updatethreshold, autohide, orientation, anchor, width, height, spacing, colors, runemap)
Engine.CreateRunesMonitor = function(name, enable, updatethreshold, autohide, orientation, anchor, totalWidth, height, colors, runemap)
	local count = 6
	local width, spacing = PixelPerfect(totalWidth, count)
	-- Create the frame
	local cmRunes = CreateFrame("Frame", "Frame_"..name, UI.PetBattleHider)
	-- Create the runes
	local runes = {}
	for i = 1, count do
		local rune = CreateFrame("Frame", name, cmRunes)
		rune:SetTemplate()
		rune:SetFrameStrata("BACKGROUND")
		rune:Size(width, height)
		if i == 1 then
			rune:Point(unpack(anchor))
		else
			rune:Point("LEFT", runes[i-1], "RIGHT", spacing, 0)
		end
		rune.status = CreateFrame("StatusBar", "cmRunesRuneStatus"..i, rune)
		rune.status:SetStatusBarTexture(UI.NormTex)
		rune.status:SetStatusBarColor(unpack(colors[math.ceil(runemap[i]/2)]))
		rune.status:SetFrameLevel(6)
		rune.status:SetMinMaxValues(0, 10)
		rune.status:Point("TOPLEFT", rune, "TOPLEFT", 2, -2)
		rune.status:Point("BOTTOMRIGHT", rune, "BOTTOMRIGHT", -2, 2)
		rune.status:SetOrientation(orientation)

		tinsert(runes, rune)
	end

	if not enable then
		for i = 1, count do runes[i]:Hide() end
		cmRunes:Hide()
		return
	end

	-- Function to update runes
	local function UpdateRune(id, start, duration, finished)
		local rune = runes[id]

		rune.status:SetStatusBarColor(unpack(colors[GetRuneType(runemap[id])]))
		rune.status:SetMinMaxValues(0, duration)

		if finished then
			rune.status:SetValue(duration)
		else
			rune.status:SetValue(GetTime() - start)
		end
	end

	local OnUpdate = CreateFrame("Frame")
	OnUpdate.TimeSinceLastUpdate = 0
	local updateFunc = function(self, elapsed)
		self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

		if self.TimeSinceLastUpdate > updatethreshold then
			local runesReady = 0
			for i = 1, count do
				local start, duration, finished = GetRuneCooldown(runemap[i])
				UpdateRune(i, start, duration, finished)
				if finished then runesReady = runesReady + 1 end
			end
			-- if runesReady == count and not InCombatLockdown() then
				-- OnUpdate:SetScript("OnUpdate", nil)
			-- end
			self.TimeSinceLastUpdate = 0
		end
	end
	--OnUpdate:SetScript("OnUpdate", updateFunc)

	cmRunes:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmRunes:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmRunes:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmRunes:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		if visible then
			UIFrameFadeIn(self, (0.3 * (1-self:GetAlpha())), self:GetAlpha(), 1)
			OnUpdate:SetScript("OnUpdate", updateFunc)
		else
			UIFrameFadeOut(self, (0.3 * (0+self:GetAlpha())), self:GetAlpha(), 0)
			OnUpdate:SetScript("OnUpdate", nil)
		end
		-- if event == "PLAYER_REGEN_DISABLED" then
			-- if autohide then
				-- UIFrameFadeIn(self, (0.3 * (1-self:GetAlpha())), self:GetAlpha(), 1)
			-- end
			-- OnUpdate:SetScript("OnUpdate", updateFunc)
		-- elseif event == "PLAYER_REGEN_ENABLED" then
			-- if autohide then
				-- UIFrameFadeOut(self, (0.3 * (0+self:GetAlpha())), self:GetAlpha(), 0)
			-- end
			-- --OnUpdate:SetScript("OnUpdate", nil)
		-- else
		if event == "PLAYER_ENTERING_WORLD" then
			RuneFrame:ClearAllPoints()
			if not InCombatLockdown() then
				if autohide then
					cmRunes:SetAlpha(0)
				else
					cmRunes:SetAlpha(1)
				end
			end
		end
	end)

	-- Hide blizzard runeframe
	-- RuneFrame:Hide()
	-- RuneFrame:SetScript("OnShow", function(self)
		-- self:Hide()
	-- end)
	RuneFrame:Kill()

	return runes[1]
end
--]]