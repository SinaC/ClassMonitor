local ADDON_NAME, Engine = ...

local ClassMonitor = ClassMonitor
local UI = ClassMonitor.UI
local ClassMonitor_ConfigUI = ClassMonitor_ConfigUI

-- Simple plugin displaying a simple castbar
local pluginName = "CASTBARPLUGIN"
local pluginCastBar = ClassMonitor:NewPlugin(pluginName)

-- MANDATORY FUNCTIONS
function pluginCastBar:Initialize()
	--
	self.settings.unit = self.settings.unit or "player"
	self.settings.color = self.settings.color or {1, 0, 0, 1}
	--
	self:UpdateGraphics()
end

function pluginCastBar:Enable()
	--
	self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.settings.unit, pluginCastBar.SpellCastStart)
	self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.settings.unit, pluginCastBar.SpellCastFailed)
	self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.settings.unit, pluginCastBar.SpellCastInterrupted)
	self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.settings.unit, pluginCastBar.SpellCastStop)
	--UNIT_SPELLCAST_INTERRUPTIBLE
	--UNIT_SPELLCAST_NOT_INTERRUPTIBLE
	--UNIT_SPELLCAST_DELAYED
	--UNIT_SPELLCAST_CHANNEL_START
	--UNIT_SPELLCAST_CHANNEL_UPDATE
	--UNIT_SPELLCAST_CHANNEL_STOP
end

function pluginCastBar:Disable()
	--
	self:UnregisterAllEvents()
	--
	self.bar:Hide()
end

function pluginCastBar:SettingsModified()
	self:Disable()
	self:UpdateGraphics()
	if self.settings.enable then
		self:Enable()
	end
end

-- OWN FUNCTIONS
function pluginCastBar:UpdateGraphics()
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
	bar.status:SetMinMaxValues(0, 1)
	--
	if not bar.text then
		bar.text = UI.SetFontString(bar.status, 12)
		bar.text:Point("CENTER", bar.status)
	end
	if bar.text then bar.text:SetText("") end
end

function pluginCastBar:SpellCastStart(event, unit, spell)
	local name, _, text, texture, startTime, endTime, _, castid, interrupt = UnitCastingInfo(unit)
print("SpellCastStart:"..tostring(unit).."  "..tostring(name).."  "..tostring(text))
	if not name then return end

	endTime = endTime / 1e3
	startTime = startTime / 1e3
	local max = endTime - startTime
	self.bar.text:SetText(text)
	self.bar.status:SetMinMaxValues(0, max)
	self.bar.status:SetValue(0)
	self.bar:Show()
end
function pluginCastBar:SpellCastFailed(event, unit, spellname, _, castid)
print("SpellCastFailed")
end
function pluginCastBar:SpellCastInterrupted(event, unit, spellname, _, castid)
print("SpellCastInterrupted")
end
function pluginCastBar:SpellCastStop(event, unit, spellname, _, castid)
print("SpellCastStop")
end

-- OPTION DEFINITION
if ClassMonitor_ConfigUI then
print("CREATE pluginCastBar DEFINITION")
	local Helpers = ClassMonitor_ConfigUI.Helpers

	local color = Helpers.CreateColorsDefinition("color", 1, "Color")
	local options = {
		[1] = Helpers.Name,
		[2] = Helpers.DisplayName,
		[3] = Helpers.Kind,
		[4] = Helpers.Enable,
		[5] = Helpers.Autohide,
		[6] = Helpers.WidthAndHeight,
		[8] = Helpers.Specs,
		[9] = Helpers.Unit,
		[10] = color,
		[12] = Helpers.Anchor,
		[13] = Helpers.AutoGridAnchor,
	}
	local short = "Cast bar"
	local long = "Display a cast bar"
	ClassMonitor_ConfigUI:NewPluginDefinition(pluginName, options, short, long)
end