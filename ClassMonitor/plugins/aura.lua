-- Aura plugin
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
local plugin = Engine:NewPlugin("AURA")

-- own methods
function plugin:UpdateVisibility(event)
	local inCombat = true
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	if (self.settings.autohide == false or inCombat) and CheckSpec(self.settings.specs) then
		self:RegisterUnitEvent("UNIT_AURA", self.settings.unit, plugin.UpdateValue)
		self:UpdateValue() -- at least one update
		self.frame:Show()
	else
		self:UnregisterEvent("UNIT_AURA")
		self.frame:Hide()
	end
end

function plugin:UpdateValue()
	local name, _, _, stack, _, _, expirationTime, unitCaster = UnitAura(self.settings.unit, self.auraName, nil, self.settings.filter)
	if name == self.auraName and (unitCaster == "player" or (self.settings.unit == "pet" and unitCaster == "pet")) and stack > 0 then
		assert(stack <= self.settings.count, "Too many stacks:"..tostring(stack)..", maximum has been set to "..tostring(self.settings.count))
		for i = 1, stack do self.stacks[i]:Show() end
		for i = stack+1, self.settings.count do self.stacks[i]:Hide() end
	else
		for i = 1, self.settings.count do self.stacks[i]:Hide() end
	end
end

function plugin:UpdateGraphics()
	-- Create a frame including every stacks
	local frame = self.frame
	if not frame then
		frame = CreateFrame("Frame", self.name, UI.PetBattleHider)
		frame:Hide()
		self.frame = frame
	end
	frame:ClearAllPoints()
	frame:Point(unpack(self.settings.anchor))
	frame:Size(self.settings.width, self.settings.height)
	-- Create stacks
	local width, spacing = PixelPerfect(self.settings.width, self.settings.count)
	self.stacks = self.stacks or {}
	for i = 1, self.settings.count do
		local stack = self.stacks[i]
		if not stack then
			stack = CreateFrame("Frame", nil, self.frame)
			stack:SetTemplate()
			stack:SetFrameStrata("BACKGROUND")
			stack:Hide()
			self.stacks[i] = stack
		end
		stack:Size(width, self.settings.height)
		stack:ClearAllPoints()
		if i == 1 then
			stack:Point("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
		else
			stack:Point("LEFT", self.stacks[i-1], "RIGHT", spacing, 0)
		end
		if self.settings.filled == true and not stack.status then
			stack.status = CreateFrame("StatusBar", nil, stack)
			stack.status:SetStatusBarTexture(UI.NormTex)
			stack.status:SetFrameLevel(6)
			stack.status:Point("TOPLEFT", stack, "TOPLEFT", 2, -2)
			stack.status:Point("BOTTOMRIGHT", stack, "BOTTOMRIGHT", -2, 2)
		end
		local color = GetColor(self.settings.colors, i, UI.ClassColor())
		if self.settings.filled == true then
			stack.status:SetStatusBarColor(unpack(color))
			stack.status:Show()
			stack:SetBackdropBorderColor(unpack(UI.BorderColor))
		else
			stack:SetBackdropBorderColor(unpack(color))
			if stack.status then stack.status:Hide() end
		end
	end
end

-- overridden methods
function plugin:Initialize()
	-- set defaults
	self.settings.unit = self.settings.unit or "player"
	self.settings.filled = DefaultBoolean(self.settings.filled, false)
	self.settings.count = self.settings.count or 1
	self.settings.filter = self.settings.filter or "HELPFUL"
	--local color = self.settings.color or UI.ClassColor() -- TODO: use GetColor(settings, index) instead of using settings.colors[index]
	--self.settings.colors = self.settings.colors or CreateColorArray(color, self.settings.count) -- TODO: use GetColor(settings, index) instead of using settings.colors[index]
	self.settings.colors = self.settings.colors or self.settings.color or UI.ClassColor()
	-- no default for spellID
	--
	self.auraName = GetSpellInfo(self.settings.spellID)
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	if self.settings.unit == "focus" then self:RegisterEvent("PLAYER_FOCUS_CHANGED", plugin.UpdateVisibility) end
	if self.settings.unit == "target" then self:RegisterEvent("PLAYER_TARGET_CHANGED", plugin.UpdateVisibility) end
	if self.settings.unit == "pet" then cself:RegisterUnitEvent("UNIT_PET", "player", plugin.UpdateVisibility) end
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player", plugin.UpdateVisibility)

	--self:RegisterUnitEvent("UNIT_AURA", unit, plugin.UpdateValue)
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
	self.auraName = GetSpellInfo(self.settings.spellID)
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
	-- if pluginSettings.kind == "AURA" then
		-- local setting = Engine.DeepCopy(pluginSettings)
		-- setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		-- setting.enable = true
		-- setting.autohide = false
		-- setting.filled = true
		-- setting.specs = {"any"}
		-- setting.unit = setting.unit or "player"
		-- setting.colors = setting.colors or { {0, 0, 1}, {0, 1, 0}, {0, 1, 1}, {1, 0, 0}, {1, 0, 1}, {1, 1, 0}, {1, 1, 1} }
		-- local instance = Engine:NewPluginInstance("AURA", "AURA"..tostring(i), setting)
		-- instance:Initialize()
		-- if setting.enable then
			-- instance:Enable()
		-- end
	-- end
-- end

--[[
-- Generic method to create BUFF/DEBUFF stack monitor
Engine.CreateAuraMonitor = function(name, enable, autohide, unit, spellID, filter, count, anchor, totalWidth, height, colors, filled, specs)
	local aura = GetSpellInfo(spellID)
	local cmAMs = {}
	local width, spacing = PixelPerfect(totalWidth, count)
	for i = 1, count do
		local cmAM = CreateFrame("Frame", name, UI.PetBattleHider) -- name is used for 1st power point
		cmAM:SetTemplate()
		cmAM:SetFrameStrata("BACKGROUND")
		cmAM:Size(width, height)
		if i == 1 then
			cmAM:Point(unpack(anchor))
		else
			cmAM:Point("LEFT", cmAMs[i-1], "RIGHT", spacing, 0)
		end
		if filled then
			cmAM.status = CreateFrame("StatusBar", name.."_status_"..i, cmAM)
			cmAM.status:SetStatusBarTexture(UI.NormTex)
			cmAM.status:SetFrameLevel(6)
			cmAM.status:Point("TOPLEFT", cmAM, "TOPLEFT", 2, -2)
			cmAM.status:Point("BOTTOMRIGHT", cmAM, "BOTTOMRIGHT", -2, 2)
			cmAM.status:SetStatusBarColor(unpack(colors[i]))
		else
			cmAM:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmAM:Hide()

		tinsert(cmAMs, cmAM)
	end

	if not enable then
		for i = 1, count do cmAMs[i]:Hide() end
		return
	end

	cmAMs[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmAMs[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmAMs[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
	if unit == "focus" then cmAMs[1]:RegisterEvent("PLAYER_FOCUS_CHANGED") end
	if unit == "target" then cmAMs[1]:RegisterEvent("PLAYER_TARGET_CHANGED") end
	if unit == "pet" then cmAMs[1]:RegisterUnitEvent("UNIT_PET", "player") end
	cmAMs[1]:RegisterUnitEvent("UNIT_AURA", unit)
	cmAMs[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmAMs[1]:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		local found = false
		if CheckSpec(specs) and visible then
			for i = 1, 40, 1 do
				local name, _, _, stack, _, _, _, unitCaster = UnitAura(unit, i, filter)
				if not name then break end
				if name == aura and (unitCaster == "player" or (unit == "pet" and unitCaster == "pet")) and stack > 0 then
					for i = 1, stack do cmAMs[i]:Show() end
					for i = stack+1, count do cmAMs[i]:Hide() end
					found = true
					break
				end
			end
		end
		if found == false then
			for i = 1, count do cmAMs[i]:Hide() end
		end
	end)

	return cmAMs[1]
end
--]]

--[[
-- Generic method to create BUFF/DEBUFF monitor
Engine.CreateAuraMonitor = function(name, enable, autohide, unit, spellID, filter, count, anchor, width, height, spacing, colors, filled, specs)
	local aura = GetSpellInfo(spellID)
	local cmAMs = {}
	for i = 1, count do
		local cmAM = CreateFrame("Frame", name, UI.PetBattleHider) -- name is used for 1st power point
		cmAM:SetTemplate()
		cmAM:SetFrameStrata("BACKGROUND")
		cmAM:Size(width, height)
		if i == 1 then
			cmAM:Point(unpack(anchor))
		else
			cmAM:Point("LEFT", cmAMs[i-1], "RIGHT", spacing, 0)
		end
		if filled then
			cmAM.status = CreateFrame("StatusBar", name.."_status_"..i, cmAM)
			cmAM.status:SetStatusBarTexture(UI.NormTex)
			cmAM.status:SetFrameLevel(6)
			cmAM.status:Point("TOPLEFT", cmAM, "TOPLEFT", 2, -2)
			cmAM.status:Point("BOTTOMRIGHT", cmAM, "BOTTOMRIGHT", -2, 2)
			cmAM.status:SetStatusBarColor(unpack(colors[i]))
		else
			cmAM:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmAM:Hide()

		tinsert(cmAMs, cmAM)
	end

	if not enable then
		for i = 1, count do cmAMs[i]:Hide() end
		return
	end

	cmAMs[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmAMs[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmAMs[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
	if unit == "focus" then cmAMs[1]:RegisterEvent("PLAYER_FOCUS_CHANGED") end
	if unit == "target" then cmAMs[1]:RegisterEvent("PLAYER_TARGET_CHANGED") end
	if unit == "pet" then cmAMs[1]:RegisterUnitEvent("UNIT_PET", "player") end
	cmAMs[1]:RegisterUnitEvent("UNIT_AURA", unit)
	cmAMs[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmAMs[1]:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		local found = false
		if CheckSpec(specs) and visible then
			for i = 1, 40, 1 do
				local name, _, _, stack, _, _, _, unitCaster = UnitAura(unit, i, filter)
				if not name then break end
				if name == aura and (unitCaster == "player" or (unit == "pet" and unitCaster == "pet")) and stack > 0 then
					for i = 1, stack do cmAMs[i]:Show() end
					for i = stack+1, count do cmAMs[i]:Hide() end
					found = true
					break
				end
			end
		end
		if found == false then
			for i = 1, count do cmAMs[i]:Hide() end
		end
	end)

	return cmAMs[1]
end
--]]