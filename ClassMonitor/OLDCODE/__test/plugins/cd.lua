-- Aura plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

-- ONLY ON PTR
if not Engine.IsPTR() then return end

local ToClock = Engine.ToClock
local CheckSpec = Engine.CheckSpec

--
local plugin = Engine:NewPlugin("CD")

-- own methods
function plugin:Update(elapsed)
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
	if self.timeSinceLastUpdate > 0.2 then
		local timeLeft = self.expirationTime - GetTime()
		self.bar.status:SetValue(timeLeft)
		if self.settings.duration == true then
			if timeLeft > 0 then
				self.bar.durationText:SetText(ToClock(timeLeft))
			else
				self.bar.durationText:SetText("")
			end
		end
	end
end

function plugin:UpdateVisibility(event)
	local inCombat = true
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	local visible = false
	if (self.settings.autohide == false or inCombat) and CheckSpec(self.settings.specs) then
		local start, duration, _ = GetSpellCooldown(self.spellName)
		--local value1 = GetSpellBaseCooldown(spellID)
--print("UPDATE_COOLDOWN:"..tostring(spellName).."  "..tostring(start).."  "..tostring(duration))
		if start and duration and start > 0 and duration > 1 then
			self.expirationTime = start + duration
			self.bar.status:SetMinMaxValues(0, duration)
			visible = true
		end
	end
	if visible then
		self.bar:Show()
		self.timeSinceLastUpdate = GetTime()
		self:RegisterUpdate(plugin.Update)
	else
		self.bar:Hide()
		self:UnregisterUpdate()
	end
end

function plugin:UpdateGraphics()
	local bar = self.bar
	if not bar then
		bar = CreateFrame("Frame", self.name, UI.PetBattleHider)
		bar:SetTemplate()
		bar:SetFrameStrata("BACKGROUND")
		bar:Hide()
		self.bar = bar
	end
	bar:ClearAllPoints()
	bar:Point(unpack(self.settings.anchor))
	bar:Size(self.settings.width, self.settings.height)
	--
	if not bar.status then
		bar.status = CreateFrame("StatusBar", nil, bar)
		bar.status:SetStatusBarTexture(UI.NormTex)
		bar.status:SetFrameLevel(6)
		bar.status:Point("TOPLEFT", bar, "TOPLEFT", 2, -2)
		bar.status:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)
	end
	bar.status:SetStatusBarColor(unpack(self.settings.color))
	--
	if self.settings.text == true and not bar.nameText then
		bar.nameText = UI.SetFontString(bar.status, 12)
		bar.nameText:Point("CENTER", bar.status)
		bar.nameText:SetText(self.spellName)
	end
	--
	if self.settings.duration == true and not bar.durationText then
		bar.durationText = UI.SetFontString(bar.status, 12)
		bar.durationText:Point("RIGHT", bar.status)
	end
end

-- overridden methods
function plugin:Initialize()
	--
	self.spellName = GetSpellInfo(self.settings.spellID)
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player", plugin.UpdateVisibility)
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN", plugin.UpdateVisibility)
end

function plugin:Disable()
	self:UnregisterAllEvents()
	self:UnregisterUpdate()

	self.bar:Hide()
end

function plugin:SettingsModified()
	--
	self:Disable()
	--
	self.spellName = GetSpellInfo(self.settings.spellID)
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
	if pluginSettings.kind == "CD" then
		local setting = Engine.DeepCopy(pluginSettings)
		setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		setting.specs = {"any"}
		setting.enable = true
		setting.autohide = false
		setting.text = true
		setting.duration = true
		local instance = Engine:NewPluginInstance("CD", "CD"..tostring(i), setting)
		instance:Initialize()
		if setting.enable then
			instance:Enable()
		end
	end
end

--[[
-- Generic method to create CD bar monitor
Engine.CreateCDMonitor = function(name, enable, autohide, text, duration, spellID, anchor, width, height, color, specs)
	local spellName, _, spellIcon = GetSpellInfo(spellID)
--print("CreateCDMonitor:"..tostring(spellID).."->"..tostring(spellName).."  "..tostring(currentCharges).."  "..tostring(maxCharges).."  "..tostring(timeLastCast).."  "..tostring(cooldownDuration))

	local cmCD = CreateFrame("Frame", name, UI.PetBattleHider)
	cmCD:SetTemplate()
	cmCD:SetFrameStrata("BACKGROUND")
	cmCD:Size(width, height)
	cmCD:Point(unpack(anchor))
	cmCD:Hide()

	cmCD.status = CreateFrame("StatusBar", name.."_status", cmCD)
	cmCD.status:SetStatusBarTexture(UI.NormTex)
	cmCD.status:SetFrameLevel(6)
	cmCD.status:Point("TOPLEFT", cmCD, "TOPLEFT", 2, -2)
	cmCD.status:Point("BOTTOMRIGHT", cmCD, "BOTTOMRIGHT", -2, 2)
	cmCD.status:SetStatusBarColor(unpack(color))

	if text == true then
		cmCD.nameText = UI.SetFontString(cmCD.status, 12)
		cmCD.nameText:Point("CENTER", cmCD.status)
		cmCD.nameText:SetText(spellName)
	end

	if duration == true then
		cmCD.durationText = UI.SetFontString(cmCD.status, 12)
		cmCD.durationText:Point("RIGHT", cmCD.status)
	end

	if not enable then
		cmCD:Hide()
		return
	end

	cmCD.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
		if self.timeSinceLastUpdate > 0.2 then
			local timeLeft = self.expirationTime - GetTime()
			self.status:SetValue(timeLeft)
			if duration == true then
				if timeLeft > 0 then
					self.durationText:SetText(ToClock(timeLeft))
				else
					self.durationText:SetText("")
				end
			end
		end
	end

	cmCD:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmCD:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmCD:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmCD:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmCD:RegisterUnitEvent("SPELL_UPDATE_COOLDOWN")
	cmCD:SetScript("OnEvent", function(self, event)
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
			local start, duration, enabled = GetSpellCooldown(spellName)
			--local value1 = GetSpellBaseCooldown(spellID)
--print("UPDATE_COOLDOWN:"..tostring(spellName).."  "..tostring(start).."  "..tostring(duration))
			if start and duration and start > 0 and duration > 1 then
				self.expirationTime = start + duration
				self.status:SetMinMaxValues(0, duration)
				self:Show()
				found = true
			end
		end
		if not found then
			self:Hide()
		end
	end)

	-- This is what stops constant OnUpdate
	cmCD:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)
	cmCD:SetScript("OnHide", function (self)
		self:SetScript("OnUpdate", nil)
	end)

	-- If autohide is not set, show frame
	if autohide ~= true then
		if cmCD:IsShown() then
			cmCD:SetScript("OnUpdate", OnUpdate)
		else
			cmCD:Show()
		end
	end

	return cmCD
end
--]]