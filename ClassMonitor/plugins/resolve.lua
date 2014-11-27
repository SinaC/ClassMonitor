-- Resolve plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

local cfg = {
	["WARRIOR"]     = { spellID = 158300, specs = {3} }, -- Shield Barrier
	["MONK"]        = { spellID = 158300, specs = {1} }, -- Guard
	["DEATHKNIGHT"] = { spellID = 158300, specs = {1} }, -- Blood Shield
	["PALADIN"]     = { spellID = 158300, specs = {2} }, -- Sacred Shield
}

if not cfg[UI.MyClass] then return end -- only available for WARRIOR, MONK, DK and PALADIN
local spellName = GetSpellInfo(cfg[UI.MyClass].spellID)
if not spellName then return end
local specs = cfg[UI.MyClass].specs

local _, _, _, toc = GetBuildInfo()

local ToClock = Engine.ToClock
local CheckSpec = Engine.CheckSpec
local DefaultBoolean = Engine.DefaultBoolean
local FormatNumber = Engine.FormatNumber
local MaxResolveValue = 0

--
local plugin = Engine:NewPlugin("RESOLVE")

-- own methods
function plugin:Update(elapsed)
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
	if self.timeSinceLastUpdate > 0.2 then
		local name, _, _, _, _, duration, _, unitCaster, _, _, _, _, _, _, ResolveValue, DamageTaken, _ =
			UnitAura("player", spellName, nil, "HELPFUL");
		if ResolveValue > MaxResolveValue then
			MaxResolveValue = ResolveValue
			self.bar.status:SetMinMaxValues(0, MaxResolveValue)
		end
		self.bar.status:SetValue(ResolveValue)
		self.bar.valueText:SetText(string.format("%s%% (%s)", ResolveValue, FormatNumber(DamageTaken)))
		self.timeSinceLastUpdate = 0
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
		local name, _, _, _, _, duration, _, unitCaster, _, _, _, _, _, _, ResolveValue, DamageTaken, _ =
			UnitAura("player", spellName, nil, "HELPFUL");
		if name == spellName and unitCaster == "player" then
			self.bar.status:SetMinMaxValues(0, 100)
			self.bar.valueText:SetText(string.format("%s%% (%s)", ResolveValue, FormatNumber(DamageTaken)))
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
	bar:Point(unpack(self:GetAnchor()))
	bar:Size(self:GetWidth(), self:GetHeight())

	if not bar.status then
		bar.status = CreateFrame("StatusBar", nil, bar)
		bar.status:SetStatusBarTexture(UI.NormTex)
		bar.status:SetFrameLevel(6)
		bar.status:SetInside()
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
	if self:IsEnabled() then
		self:Enable()
		self:UpdateVisibilityAndValue()
	end
end
