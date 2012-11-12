-- Tank shield plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

-- ONLY ON PTR
--if not Engine.IsPTR() then return end

local _, _, _, toc = GetBuildInfo()

local cfg = {
	["WARRIOR"] = { spellID = 112048, specs = {3} }, -- Shield Barrier
	["MONK"] = { spellID = 115295, specs = {1} }, -- Guard
	["DEATHKNIGHT"] = { spellID = 77535, specs = {1} }, -- Blood Shield
	["PALADIN"] = { spellID = 65148, specs = {2} }, -- Sacred Shield
}

if not cfg[UI.MyClass] then return end -- only available for WARRIOR, MONK, DK and PALADIN
local spellName = GetSpellInfo(cfg[UI.MyClass].spellID)
if not spellName then return end
local specs = cfg[UI.MyClass].specs

local ToClock = Engine.ToClock
local CheckSpec = Engine.CheckSpec
local DefaultBoolean = Engine.DefaultBoolean

--
local plugin = Engine:NewPlugin("TANKSHIELD")

-- own methods
function plugin:Update(elapsed)
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
	if self.timeSinceLastUpdate > 0.2 then
		local timeLeft = self.expirationTime - GetTime()
		if timeLeft > 0 then
			self.bar.status:SetValue(timeLeft)
			if self.settings.duration == true then
				self.bar.durationText:SetText(ToClock(timeLeft))
			end
		else
			self.bar.status:SetValue(0)
			if self.settings.duration == true then
				self.bar.durationText:SetText("")
			end
		end
	end
end

function plugin:UpdateVisibilityAndValue(event)
	local inCombat = true
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	local visible = false
	if (self.settings.autohide == false or inCombat) and CheckSpec(specs) then
		local name, duration, expirationTime, unitCaster, value1, _
if toc > 50001 then
		name, _, _, _, _, duration, expirationTime, unitCaster, _, _, _, _, _, _, value1 = UnitBuff("player", spellName) -- 5.1
else
		name, _, _, _, _, duration, expirationTime, unitCaster, _, _, _, _, _, value1 = UnitBuff("player", spellName) -- 5.0
end
--print(tostring(toc).."  "..tostring(spellName).."=>"..tostring(name).."  "..tostring(duration).."  "..tostring(expirationTime).."  "..tostring(unitCaster).."  "..tostring(value1))
		if name == spellName and unitCaster == "player" and value1 ~= nil and type(value1) == "number" and value1 > 0 then
			self.bar.status:SetValue(duration)
			self.bar.status:SetMinMaxValues(0, duration)
			self.bar.valueText:SetText(tostring(value1))
			self.expirationTime = expirationTime -- save to use in Update
			visible = true
		end
	end
	if visible then
		self:RegisterUpdate(plugin.Update)
		self.timeSinceLastUpdate = GetTime()
		self.bar:Show()
	else
		self:UnregisterUpdate()
		self.bar:Hide()
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

	if not bar.status then
		bar.status = CreateFrame("StatusBar", nil, bar)
		bar.status:SetStatusBarTexture(UI.NormTex)
		bar.status:SetFrameLevel(6)
		bar.status:Point("TOPLEFT", bar, "TOPLEFT", 2, -2)
		bar.status:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)
		bar.status:SetMinMaxValues(0, 1) -- dummy value
	end
	bar.status:SetStatusBarColor(unpack(self.settings.color))

	if not bar.valueText then
		bar.valueText = UI.SetFontString(bar.status, 12)
		bar.valueText:Point("CENTER", bar.status)
	end
	bar.valueText:SetText("")

	if self.settings.duration == true and not bar.durationText then
		bar.durationText = UI.SetFontString(bar.status, 12)
		bar.durationText:Point("RIGHT", bar.status)
	end
	if bar.durationText then bar.durationText:SetText("") end
end

-- overridden methods
function plugin:Initialize()
	-- set defaults
	self.settings.color = self.settings.color or UI.ClassColor()
	self.settings.duration = DefaultBoolean(self.settings.duration, false)
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibilityAndValue)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibilityAndValue)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibilityAndValue)
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player", plugin.UpdateVisibilityAndValue)
	self:RegisterUnitEvent("UNIT_AURA", "player", plugin.UpdateVisibilityAndValue)
end

function plugin:Disable()
	--
	self:UnregisterAllEvents()
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
		self:UpdateVisibilityAndValue()
	end
end

-- ----------------------------------------------
-- -- test
-- ----------------------------------------------
-- local C = Engine.Config
-- local settings = C[UI.MyClass]
-- if not settings then return end
-- for i, pluginSettings in ipairs(settings) do
	-- if pluginSettings.kind == "TANKSHIELD" then
		-- local setting = Engine.DeepCopy(pluginSettings)
		-- setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		-- setting.enable = true
		-- setting.autohide = false
		-- setting.duration = true
		-- setting.color = setting.color or UI.ClassColor()
		-- local instance = Engine:NewPluginInstance("TANKSHIELD", "TANKSHIELD"..tostring(i), setting)
		-- instance:Initialize()
		-- if setting.enable then
			-- instance:Enable()
		-- end
	-- end
-- end


--[[
-- Create tank shield monitor
--Engine.CreateTankShieldMonitor = function(name, enable, autohide, anchor, width, height, text, color, specs)
Engine.CreateTankShieldMonitor = function(name, enable, autohide, anchor, width, height, text, color)
--print("CreateTankShieldMonitor")
	local cmTSM = CreateFrame("Frame", name, UI.PetBattleHider)
	cmTSM:SetTemplate()
	cmTSM:SetFrameStrata("BACKGROUND")
	cmTSM:Size(width, height)
	cmTSM:Point(unpack(anchor))
	cmTSM:Hide()

	cmTSM.status = CreateFrame("StatusBar", name.."_status", cmTSM)
	cmTSM.status:SetStatusBarTexture(UI.NormTex)
	cmTSM.status:SetFrameLevel(6)
	cmTSM.status:Point("TOPLEFT", cmTSM, "TOPLEFT", 2, -2)
	cmTSM.status:Point("BOTTOMRIGHT", cmTSM, "BOTTOMRIGHT", -2, 2)
	cmTSM.status:SetStatusBarColor(unpack(color))
	cmTSM.status:SetMinMaxValues(0, 1)

	cmTSM.valueText = UI.SetFontString(cmTSM.status, 12)
	cmTSM.valueText:Point("CENTER", cmTSM.status)

	if text == true then
		cmTSM.durationText = UI.SetFontString(cmTSM.status, 12)
		cmTSM.durationText:Point("RIGHT", cmTSM.status)
	end

	if not enable then
		cmTSM:Hide()
		return
	end

	cmTSM.timeSinceLastUpdate = GetTime()
	local function OnUpdate(self, elapsed)
--print("CreateTankShieldMonitor:OnUpdate")
		cmTSM.timeSinceLastUpdate = cmTSM.timeSinceLastUpdate + elapsed
		if cmTSM.timeSinceLastUpdate > 0.2 then
			local timeLeft = cmTSM.expirationTime - GetTime()
			if timeLeft > 0 then
				cmTSM.status:SetValue(timeLeft)
				if text then
					cmTSM.durationText:SetText(ToClock(timeLeft))
				end
			else
				cmTSM.status:SetValue(0)
				if text then
					cmTSM.durationText:SetText("")
				end
			end
		end
	end

	cmTSM:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmTSM:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmTSM:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmTSM:RegisterUnitEvent("UNIT_AURA", "player")
	cmTSM:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmTSM:SetScript("OnEvent", function(self, event)
--print("CreateTankShieldMonitor:OnEvent:"..tostring(event))
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
			local name, duration, expirationTime, unitCaster, value1, _
if toc > 50001 then
			name, _, _, _, _, duration, expirationTime, unitCaster, _, _, _, _, _, _, value1 = UnitBuff("player", spellName) -- 5.1
else
			name, _, _, _, _, duration, expirationTime, unitCaster, _, _, _, _, _, value1 = UnitBuff("player", spellName) -- 5.0
end
--print(tostring(toc).."  "..tostring(spellName).."=>"..tostring(name).."  "..tostring(duration).."  "..tostring(expirationTime).."  "..tostring(unitCaster).."  "..tostring(value1))
			if name == spellName and unitCaster == "player" and value1 ~= nil and type(value1) == "number" and value1 > 0 then
				cmTSM.status:SetValue(duration)
				cmTSM.status:SetMinMaxValues(0, duration)
				cmTSM.valueText:SetText(tostring(value1))
				cmTSM.expirationTime = expirationTime -- save to use in OnUpdate
				cmTSM:Show()
				found = true
			end
		end
		if not found then
			cmTSM:Hide()
		end
	end)

	-- This is what stops constant OnUpdate
	cmTSM:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)
	cmTSM:SetScript("OnHide", function (self)
		self:SetScript("OnUpdate", nil)
	end)

	-- If autohide is not set, show frame
	if autohide ~= true then
		if cmTSM:IsShown() then
			cmTSM:SetScript("OnUpdate", OnUpdate)
		else
			cmTSM:Show()
		end
	end

	return cmTSM
end
--]]