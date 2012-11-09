-- Totem plugin, credits to Ildyria and Tukz
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

if UI.MyClass ~= "SHAMAN" and UI.MyClass ~= "DRUID" then return end -- Totems for shaman and Mushrooms for druid

-- ONLY ON PTR
if not Engine.IsPTR() then return end

local ToClock = Engine.ToClock
local CheckSpec = Engine.CheckSpec
local PixelPerfect = Engine.PixelPerfect

--
local plugin = Engine:NewPlugin("TOTEMS")

-- own methods
local function UpdateTotem(self, elapsed)
	-- update one totem
	if not self.expirationTime then return end
	self.expirationTime = self.expirationTime - elapsed

	local timeLeft = self.expirationTime
	if timeLeft > 0 then
		self.status:SetValue(timeLeft)
		if self.plugin.settings.text == true then
			self.text:SetText(ToClock(timeLeft))
		end
	else
		self:SetScript("OnUpdate", nil)
		if self.plugin.settings.text == true then
			self.text:SetText("")
		end
	end
end

function plugin:Update()
	for i = 1, self.settings.count do
		local totem = self.totems[i]
		local up, name, start, duration, icon = GetTotemInfo(i)
		if up then
			local timeLeft = (start+duration) - GetTime()
			totem.duration = duration
			totem.expirationTime = timeLeft
			totem.status:SetMinMaxValues(0, duration)
			totem:SetScript("OnUpdate", UpdateTotem)
			totem:Show()
		else
			totem.status:SetValue(0)
			totem:SetScript("OnUpdate", nil)
			totem:Hide()
		end
	end
end

function plugin:UpdateVisibility(event)
--print("TOTEMS:UpdateVisibility")
	local inCombat = true
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	if (self.settings.autohide == false or inCombat) and CheckSpec(self.settings.specs) then
		self:RegisterEvent("PLAYER_TOTEM_UPDATE", plugin.Update)
		self:Update() -- at least one update
		self.frame:Show()
	else
		self:UnregisterEvent("PLAYER_TOTEM_UPDATE")
		self.frame:Hide()
	end
end

function plugin:UpdateGraphics()
	-- Create a frame including every totems
	local frame = self.frame
	if not frame then
		frame = CreateFrame("Frame", self.name, UI.PetBattleHider)
		frame:Hide()
		self.frame = frame
	end
	frame:ClearAllPoints()
	frame:Point(unpack(self.settings.anchor))
	frame:Size(self.settings.width, self.settings.height)
	-- Create totems
	local width, spacing = PixelPerfect(self.settings.width, self.settings.count)
	self.totems = self.totems or {}
	for i = 1, self.settings.count do
		local totem = self.totems[i]
		if not totem then
			totem = CreateFrame("Frame", nil, self.frame)
			totem:SetTemplate()
			totem:SetFrameStrata("BACKGROUND")
			totem:Hide()
			self.totems[i] = totem
			-- keep a link to plugin for UpdateTotem method
			totem.plugin = self
		end
		totem:Size(width, self.settings.height)
		totem:ClearAllPoints()
		if i == 1 then
			totem:Point("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
		else
			totem:Point("LEFT", self.totems[i-1], "RIGHT", spacing, 0)
		end
		if not totem.status then
			totem.status = CreateFrame("StatusBar", nil, totem)
			totem.status:SetStatusBarTexture(UI.NormTex)
			totem.status:SetFrameLevel(6)
			totem.status:Point("TOPLEFT", totem, "TOPLEFT", 2, -2)
			totem.status:Point("BOTTOMRIGHT", totem, "BOTTOMRIGHT", -2, 2)
			totem.status:GetStatusBarTexture():SetHorizTile(false)
		end
		totem.status:SetStatusBarColor(unpack(self.settings.colors[i]))
		totem.status:SetMinMaxValues(0, 300)
		totem.status:SetValue(0)

		if self.settings.text == true and not totem.text then
			totem.text = UI.SetFontString(totem.status, 12)
			totem.text:Point("CENTER", totem.status)
		end
	end
	-- totem remapping
	if self.settings.map then
		for i = 1, self.settings.count do
			local index = self.settings.map[i]
			local totem = self.totems[index]
			if i == 1 then
				totem:ClearAllPoints()
				totem:Point("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
			else
				local previousIndex = self.settings.map[i-1]
				totem:ClearAllPoints()
				totem:Point("LEFT", self.totems[previousIndex], "RIGHT", spacing, 0)
			end
		end
	end
end

-- overridden methods
function plugin:Initialize()
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player", plugin.UpdateVisibility)
end

function plugin:Disable()
	--
	self:UnregisterAllEvents()
	--
	for i = 1, self.settings.count do -- disable each plugin
		local totem = self.totems[i]
		totem.status:SetValue(0)
		totem:SetScript("OnUpdate", nil)
		totem:Hide()
	end
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

----------------------------------------------
-- test
----------------------------------------------
local C = Engine.Config
local settings = C[UI.MyClass]
if not settings then return end
for i, pluginSettings in ipairs(settings) do
	if pluginSettings.kind == "TOTEMS" then
		local setting = Engine.DeepCopy(pluginSettings)
		setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		setting.enable = true
		setting.autohide = false
		setting.duration = true
		setting.text = true
		setting.color = setting.color or UI.ClassColor()
		setting.colors = setting.colors or { setting.color, setting.color, setting.color, setting.color, setting.color }
		local instance = Engine:NewPluginInstance("TOTEMS", "TOTEMS"..tostring(i), setting)
		instance:Initialize()
		if setting.enable then
			instance:Enable()
		end
	end
end

--[[
-- Generic method to create totems/mushrooms monitor
Engine.CreateTotemMonitor = function(name, enable, autohide, count, anchor, totalWidth, height, colors, text, map, specs)
	local cmTotems = {}
	local width, spacing = PixelPerfect(totalWidth, count)
	for i = 1, count do
		local cmTotem = CreateFrame("Frame", name, UI.PetBattleHider)
		cmTotem:SetTemplate()
		cmTotem:SetFrameStrata("BACKGROUND")
		cmTotem:Size(width, height)
		if i == 1 then
			cmTotem:Point(unpack(anchor))
		else
			cmTotem:Point("LEFT", cmTotems[i-1], "RIGHT", spacing, 0)
		end
		cmTotem.status = CreateFrame("StatusBar", name.."_status_"..i, cmTotem)
		cmTotem.status:SetStatusBarTexture(UI.NormTex)
		cmTotem.status:SetFrameLevel(6)
		cmTotem.status:Point("TOPLEFT", cmTotem, "TOPLEFT", 2, -2)
		cmTotem.status:Point("BOTTOMRIGHT", cmTotem, "BOTTOMRIGHT", -2, 2)
		cmTotem.status:SetStatusBarColor(unpack(colors[i]))
		cmTotem.status:GetStatusBarTexture():SetHorizTile(false)
		cmTotem.status:SetMinMaxValues(0, 300)
		cmTotem.status:SetValue(0)

		if text == true then
			cmTotem.text = UI.SetFontString(cmTotem.status, 12)
			cmTotem.text:Point("CENTER", cmTotem.status)
		end

		cmTotem:Hide()

		tinsert(cmTotems, cmTotem)
	end

	if map then -- totem remapping
		for i = 1, count do
			local index = map[i]
			local cmTotem = cmTotems[index]
			if i == 1 then
				cmTotem:ClearAllPoints()
				cmTotem:Point(unpack(anchor))
			else
				local previousIndex = map[i-1]
				cmTotem:ClearAllPoints()
				cmTotem:Point("LEFT", cmTotems[previousIndex], "RIGHT", spacing, 0)
			end
		end
	end

	if not enable then
		for i = 1, count do cmTotems[i]:Hide() end
		return
	end

	local function UpdateTotemTimer(self, elapsed)
		if not self.status.expirationTime then return end
		self.status.expirationTime = self.status.expirationTime - elapsed

		local timeLeft = self.status.expirationTime
		if timeLeft > 0 then
			self.status:SetValue(timeLeft)
			if text == true then
				self.text:SetText(ToClock(timeLeft))
			end
		else
			self:SetScript("OnUpdate", nil)
			if text == true then
				self.text:SetText("")
			end
		end
	end

	cmTotems[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmTotems[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmTotems[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmTotems[1]:RegisterEvent("PLAYER_TOTEM_UPDATE")
	cmTotems[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmTotems[1]:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		if CheckSpec(specs) and visible then
			for i = 1, count do
				local cmTotem = cmTotems[i]
				local up, name, start, duration, icon = GetTotemInfo(i)
				if up then
					local timeLeft = (start+duration) - GetTime()
					cmTotem.status.duration = duration
					cmTotem.status.expirationTime = timeLeft
					cmTotem.status:SetMinMaxValues(0, duration)
					cmTotem:SetScript("OnUpdate", UpdateTotemTimer)
					cmTotem:Show()
				else
					cmTotem.status:SetValue(0)
					cmTotem:SetScript("OnUpdate", nil)
					cmTotem:Hide()
				end
			end
		else
			for i = 1, count do
				local cmTotem = cmTotems[i]
				cmTotem.status:SetValue(0)
				cmTotem:SetScript("OnUpdate", nil)
				cmTotem:Hide()
			end
		end
	end)

	return cmTotems[1]
end
--]]
--[[
-- Generic method to create totem monitor
Engine.CreateTotemMonitor = function(name, enable, autohide, count, anchor, width, height, spacing, colors, text, map, specs)
	local cmTotems = {}
	for i = 1, count do
		local cmTotem = CreateFrame("Frame", name, UI.PetBattleHider)
		cmTotem:SetTemplate()
		cmTotem:SetFrameStrata("BACKGROUND")
		cmTotem:Size(width, height)
		if i == 1 then
			cmTotem:Point(unpack(anchor))
		else
			cmTotem:Point("LEFT", cmTotems[i-1], "RIGHT", spacing, 0)
		end
		cmTotem.status = CreateFrame("StatusBar", name.."_status_"..i, cmTotem)
		cmTotem.status:SetStatusBarTexture(UI.NormTex)
		cmTotem.status:SetFrameLevel(6)
		cmTotem.status:Point("TOPLEFT", cmTotem, "TOPLEFT", 2, -2)
		cmTotem.status:Point("BOTTOMRIGHT", cmTotem, "BOTTOMRIGHT", -2, 2)
		cmTotem.status:SetStatusBarColor(unpack(colors[i]))
		cmTotem.status:GetStatusBarTexture():SetHorizTile(false)
		cmTotem.status:SetMinMaxValues(0, 300)
		cmTotem.status:SetValue(0)

		if text == true then
			cmTotem.text = UI.SetFontString(cmTotem.status, 12)
			cmTotem.text:Point("CENTER", cmTotem.status)
		end

		cmTotem:Hide()

		tinsert(cmTotems, cmTotem)
	end

	if map then -- totem remapping
		for i = 1, count do
			local index = map[i]
			local cmTotem = cmTotems[index]
			if i == 1 then
				cmTotem:ClearAllPoints()
				cmTotem:Point(unpack(anchor))
			else
				local previousIndex = map[i-1]
				cmTotem:ClearAllPoints()
				cmTotem:Point("LEFT", cmTotems[previousIndex], "RIGHT", spacing, 0)
			end
		end
	end

	if not enable then
		for i = 1, count do cmTotems[i]:Hide() end
		return
	end

	local function UpdateTotemTimer(self, elapsed)
		if not self.status.expirationTime then return end
		self.status.expirationTime = self.status.expirationTime - elapsed

		local timeLeft = self.status.expirationTime
		if timeLeft > 0 then
			self.status:SetValue(timeLeft)
			if text == true then
				self.text:SetText(ToClock(timeLeft))
			end
		else
			self:SetScript("OnUpdate", nil)
			if text == true then
				self.text:SetText("")
			end
		end
	end

	cmTotems[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmTotems[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmTotems[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmTotems[1]:RegisterEvent("PLAYER_TOTEM_UPDATE")
	cmTotems[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmTotems[1]:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		if CheckSpec(specs) and visible then
			for i = 1, count do
				local cmTotem = cmTotems[i]
				local up, name, start, duration, icon = GetTotemInfo(i)
				if up then
					local timeLeft = (start+duration) - GetTime()
					cmTotem.status.duration = duration
					cmTotem.status.expirationTime = timeLeft
					cmTotem.status:SetMinMaxValues(0, duration)
					cmTotem:SetScript("OnUpdate", UpdateTotemTimer)
					cmTotem:Show()
				else
					cmTotem.status:SetValue(0)
					cmTotem:SetScript("OnUpdate", nil)
					cmTotem:Hide()
				end
			end
		else
			for i = 1, count do
				local cmTotem = cmTotems[i]
				cmTotem.status:SetValue(0)
				cmTotem:SetScript("OnUpdate", nil)
				cmTotem:Hide()
			end
		end
	end)

	return cmTotems[1]
end
--]]