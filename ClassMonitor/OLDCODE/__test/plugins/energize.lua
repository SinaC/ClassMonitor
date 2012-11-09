-- Energize Plugin, written by Ildyria
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

-- ONLY ON PTR
if not Engine.IsPTR() then return end

--
local plugin = Engine:NewPlugin("ENERGIZE")

-- own methods
function plugin:Update(elapsed)
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
	if self.timeSinceLastUpdate > 0.1 then
		local timeLeft = self.bar.status:GetValue()
		if filling then
			self.bar.status:SetValue(timeLeft + self.timeSinceLastUpdate)
		else
			self.bar.status:SetValue(timeLeft - self.timeSinceLastUpdate)
		end
		if self.bar.status:GetValue() == 0 or self.bar.status:GetValue() == duration then
			self:UnregisterUpdate()
			self.bar:Hide()
		end
		self.timeSinceLastUpdate = 0
	end
end

function plugin:CombatLog(_, _, eventType, _, caster, _, _, _, target, _, _, _, spellID)
--print("CombatLog:"..tostring(eventType).."  "..tostring(caster).."  "..tostring(target).."  "..tostring(spellID))
	if eventType == "SPELL_ENERGIZE" and spellID == self.settings.spellID and target == UnitGUID("player") and caster == UnitGUID("player") then 
		if self.settings.filling then
			self.bar.status:SetValue(0)
		else
			self.bar.status:SetValue(duration)
		end
		self.timeSinceLastUpdate = GetTime()
		self:RegisterUpdate(plugin.Update)
		self.bar:Show()
	elseif eventType == "SPELL_PERIODIC_ENERGIZE" and spellID == self.settings.spellID and target == UnitGUID("player") then 
		if self.settings.filling then
			self.bar.status:SetValue(0)
		else
			self.bar.status:SetValue(duration)
		end
		self.timeSinceLastUpdate = GetTime()
		self:RegisterUpdate(plugin.Update)
		self.bar:Show()
	end
end

function plugin:UpdateGraphics()
	local bar = self.bar
	if not bar then
		bar = CreateFrame("Frame", self.name, UI.PetBattleHider)
		bar:SetTemplate()
		bar:SetFrameStrata("BACKGROUND")
	end
	bar:ClearAllPoints()
	bar:Point(unpack(self.settings.anchor))
	bar:Size(self.settings.width, self.settings.height)

	if not bar.status then
		bar.status = CreateFrame("StatusBar", nil, bar)
		bar.status:SetStatusBarTexture(UI.NormTex)
		bar.status:SetFrameLevel(6)
		bar.status:Point("TOPLEFT", bar, "TOPLEFT", 1, -1)
		bar.status:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -1, 1)
	end
	bar.status:SetMinMaxValues(0, self.settings.duration)
	bar.status:SetStatusBarColor(unpack(self.settings.color))
end

-- overridden methods
function plugin:Initialize()
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", plugin.CombatLog)
end

function plugin:Disable()
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:UnregisterUpdate()
	--
	self.bar:Hide()
end

function plugin:SettingsModified()
	--
	self:Disable()
	--
	self:UpdateGraphics()
	--
	if self.settings.enable == true then
		self:Enable()
	end
end

----------------------------------------------
-- test
----------------------------------------------
local C = Engine.Config
local settings = C[UI.MyClass]
if not settings then return end
for i, pluginSettings in ipairs(settings) do
	if pluginSettings.kind == "ENERGIZE" then
		local setting = Engine.DeepCopy(pluginSettings)
		setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		setting.enable = true
		setting.autohide = false
		setting.filling = true
		setting.color = setting.color or UI.ClassColor()
		local instance = Engine:NewPluginInstance("ENERGIZE", "ENERGIZE"..tostring(i), setting)
		instance:Initialize()
		if setting.enable then
			instance:Enable()
		end
	end
end

--[[
-- Create a buff spell_energize monitor
Engine.CreateEnergizeMonitor = function(name, enable, spelltracked, anchor, width, height, color, duration, filling)
	local cmEnergize = CreateFrame("Frame", name, UI.PetBattleHider)
	cmEnergize:SetTemplate()
	cmEnergize:SetFrameStrata("BACKGROUND")
	cmEnergize:Size(width, height)
	cmEnergize:Point(unpack(anchor))

	cmEnergize.status = CreateFrame("StatusBar", "cmEnergizeStatus", cmEnergize)
	cmEnergize.status:SetStatusBarTexture(UI.NormTex)
	cmEnergize.status:SetFrameLevel(6)
	cmEnergize.status:Point("TOPLEFT", cmEnergize, "TOPLEFT", 1, -1)
	cmEnergize.status:Point("BOTTOMRIGHT", cmEnergize, "BOTTOMRIGHT", -1, 1)
	cmEnergize.status:SetMinMaxValues(0, duration)
	cmEnergize.status:SetStatusBarColor(unpack(color))
	cmEnergize:Hide()

	if not enable then
		cmEnergize:Hide()
		return
	end

	cmEnergize.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
		cmEnergize.timeSinceLastUpdate = cmEnergize.timeSinceLastUpdate + elapsed
		if cmEnergize.timeSinceLastUpdate > 0.05 then
			local timeLeft = cmEnergize.status:GetValue()
			if filling then
				cmEnergize.status:SetValue(timeLeft + cmEnergize.timeSinceLastUpdate)
			else
				cmEnergize.status:SetValue(timeLeft - cmEnergize.timeSinceLastUpdate)
			end
			if cmEnergize.status:GetValue() == 0 or cmEnergize.status:GetValue() == duration then cmEnergize:Hide() end
			cmEnergize.timeSinceLastUpdate = 0
		end
	end

	cmEnergize:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	cmEnergize:SetScript("OnEvent", function(self, event, arg1, ...)
		local  eventType, _,caster,_,_,_,target,_,_, _, spellID =...
		if eventType == "SPELL_ENERGIZE" and spellID == spelltracked and target == UnitGUID("player") and caster == UnitGUID("player") then 
			cmEnergize:Show()
			if filling then
				cmEnergize.status:SetValue(0)
			else
				cmEnergize.status:SetValue(duration)
			end
		elseif eventType == "SPELL_PERIODIC_ENERGIZE" and spellID == spelltracked and target == UnitGUID("player") then 
			cmEnergize:Show()
			if filling then
				cmEnergize.status:SetValue(0)
			else
				cmEnergize.status:SetValue(duration)
			end
		end
	end)

	-- This is what stops constant OnUpdate
	cmEnergize:SetScript("OnShow", function(self) self:SetScript("OnUpdate", OnUpdate) end)
	cmEnergize:SetScript("OnHide", function (self) self:SetScript("OnUpdate", nil) end)
	
	return cmEnergize
end
--]]