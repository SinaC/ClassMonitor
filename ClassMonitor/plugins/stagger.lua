-- Stagger plugin, credits to Demise and FrozenEmu (http://www.wowinterface.com/downloads/info21191-BrewmasterTao.html)
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

if UI.MyClass ~= "MONK" then return end -- Available only for monks

-- ONLY ON PTR
--if not Engine.IsPTR() then return end

local _, _, _, toc = GetBuildInfo()

local FormatNumber = Engine.FormatNumber
local CheckSpec = Engine.CheckSpec

local lightStagger = GetSpellInfo(124275)
local moderateStagger = GetSpellInfo(124274)
local heavyStagger = GetSpellInfo(124273)

--
local plugin = Engine:NewPlugin("STAGGER")

-- own methods
function plugin:UpdateVisibilityAndValue(event)
	local inCombat = true
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	local visible = false
	if (self.settings.autohide == false or inCombat) and GetSpecialization() == 1 then -- only for brewmaster
		local spellName, duration, value1, _
		if toc > 50001 then
			spellName, _, _, _, _, duration, _, _, _, _, _, _, _, _, value1 = UnitAura("player", lightStagger, nil, "HARMFUL")
			if (not spellName) then spellName, _, _, _, _, duration, _, _, _, _, _, _, _, _, value1 = UnitAura("player", moderateStagger, nil, "HARMFUL") end
			if (not spellName) then spellName, _, _, _, _, duration, _, _, _, _, _, _, _, _, value1 = UnitAura("player", heavyStagger, nil, "HARMFUL") end
		else
			spellName, _, _, _, _, duration, _, _, _, _, _, _, _, value1 = UnitAura("player", lightStagger, nil, "HARMFUL")
			if (not spellName) then spellName, _, _, _, _, duration, _, _, _, _, _, _, _, value1 = UnitAura("player", moderateStagger, nil, "HARMFUL") end
			if (not spellName) then spellName, _, _, _, _, duration, _, _, _, _, _, _, _, value1 = UnitAura("player", heavyStagger, nil, "HARMFUL") end
		end
--print(tostring(toc).."  "..tostring(spellName).."=>"..tostring(name).."  "..tostring(duration).."  "..tostring(value1))
		if spellName and value1 ~= nil and type(value1) == "number" and value1 > 0 and duration > 0 then
			if spellName == lightStagger then self.bar.status:SetStatusBarColor(unpack(self.settings.colors[1])) end
			if spellName == moderateStagger then self.bar.status:SetStatusBarColor(unpack(self.settings.colors[2])) end
			if spellName == heavyStagger then self.bar.status:SetStatusBarColor(unpack(self.settings.colors[3])) end
			local staggerTick = value1
			local staggerTotal = staggerTick * math.floor(duration)
			local hp = math.ceil(100 * staggerTotal / UnitHealthMax("player"))
			if self.settings.text == true then
				self.bar.valueText:SetText(tostring(staggerTick).." - "..FormatNumber(staggerTotal).." ("..hp.."%)")
			end
			if hp <= self.settings.threshold then
				self.bar.status:SetValue(hp)
			else
				self.bar.status:SetValue(self.settings.threshold)
			end
			visible = true
		end
	end
	if visible then
		self.bar:Show()
	else
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
	--
	if not bar.status then
		bar.status = CreateFrame("StatusBar", nil, bar)
		bar.status:SetStatusBarTexture(UI.NormTex)
		bar.status:SetFrameLevel(6)
		bar.status:Point("TOPLEFT", bar, "TOPLEFT", 2, -2)
		bar.status:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)
	end
	bar.status:SetMinMaxValues(0, self.settings.threshold)

	if self.settings.text == true and not bar.valueText then
		bar.valueText = UI.SetFontString(bar.status, 12)
		bar.valueText:Point("CENTER", bar.status)
	end
	if bar.valueText then bar.valueText:SetText("") end
end

-- overridden methods
function plugin:Initialize()
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibilityAndValue)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibilityAndValue)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibilityAndValue)
	self:RegisterUnitEvent("UNIT_AURA", "player", plugin.UpdateVisibilityAndValue)
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player", plugin.UpdateVisibilityAndValue)
end

function plugin:Disable()
	--
	self:UnregisterAllEvents()
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
	-- if pluginSettings.kind == "STAGGER" then
		-- local setting = Engine.DeepCopy(pluginSettings)
		-- setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		-- setting.specs = {"any"}
		-- setting.enable = true
		-- setting.autohide = false
		-- setting.threshold = setting.threshold or 100
		-- setting.text = true
		-- local instance = Engine:NewPluginInstance("STAGGER", "STAGGER"..tostring(i), setting)
		-- instance:Initialize()
		-- if setting.enable then
			-- instance:Enable()
		-- end
	-- end
-- end

--[[
-- Create a Stagger monitor
Engine.CreateStaggerMonitor = function(name, enable, threshold, text, autohide, anchor, width, height, colors)
--print("Engine.CreateStaggerMonitor")
	local cmSM = CreateFrame("Frame", name, UI.PetBattleHider)
	cmSM:SetTemplate()
	cmSM:SetFrameStrata("BACKGROUND")
	cmSM:Size(width, height)
	cmSM:Point(unpack(anchor))
	cmSM:Hide()

	cmSM.status = CreateFrame("StatusBar", name.."_status", cmSM)
	cmSM.status:SetStatusBarTexture(UI.NormTex)
	cmSM.status:SetFrameLevel(6)
	cmSM.status:Point("TOPLEFT", cmSM, "TOPLEFT", 2, -2)
	cmSM.status:Point("BOTTOMRIGHT", cmSM, "BOTTOMRIGHT", -2, 2)
	cmSM.status:SetMinMaxValues(0, threshold)

	if text == true then
		cmSM.valueText = UI.SetFontString(cmSM.status, 12)
		cmSM.valueText:Point("CENTER", cmSM.status)
	end

	if not enable then
		cmSM:Hide()
		return
	end

	cmSM:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmSM:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmSM:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmSM:RegisterUnitEvent("UNIT_AURA", "player")
	cmSM:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmSM:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		local found = false
		if GetSpecialization() == 1 and visible then
			local spellName, duration, value1, _
if toc > 50001 then
--print("PTR")
			spellName, _, _, _, _, duration, _, _, _, _, _, _, _, _, value1 = UnitAura("player", lightStagger, "", "HARMFUL")
			if (not spellName) then spellName, _, _, _, _, duration, _, _, _, _, _, _, _, _, value1 = UnitAura("player", moderateStagger, "", "HARMFUL") end
			if (not spellName) then spellName, _, _, _, _, duration, _, _, _, _, _, _, _, _, value1 = UnitAura("player", heavyStagger, "", "HARMFUL") end
else
			spellName, _, _, _, _, duration, _, _, _, _, _, _, _, value1 = UnitAura("player", lightStagger, "", "HARMFUL")
			if (not spellName) then spellName, _, _, _, _, duration, _, _, _, _, _, _, _, value1 = UnitAura("player", moderateStagger, "", "HARMFUL") end
			if (not spellName) then spellName, _, _, _, _, duration, _, _, _, _, _, _, _, value1 = UnitAura("player", heavyStagger, "", "HARMFUL") end
end
--print(tostring(toc).."  "..tostring(spellName).."=>"..tostring(name).."  "..tostring(duration).."  "..tostring(value1))
			if spellName and value1 ~= nil and type(value1) == "number" and value1 > 0 and duration > 0 then
				if spellName == lightStagger then cmSM.status:SetStatusBarColor(unpack(colors[1])) end
				if spellName == moderateStagger then cmSM.status:SetStatusBarColor(unpack(colors[2])) end
				if spellName == heavyStagger then cmSM.status:SetStatusBarColor(unpack(colors[3])) end
				local staggerTick = value1
				local staggerTotal = staggerTick * math.floor(duration)
				local hp = math.ceil(100*staggerTotal/UnitHealthMax("player"))
				if text == true then
					cmSM.valueText:SetText(tostring(staggerTick).." - "..FormatNumber(staggerTotal).." ("..hp.."%)")
				end
				if hp <= threshold then cmSM.status:SetValue(hp) else cmSM.status:SetValue(threshold) end
				cmSM:Show()
				found = true
			end
		end
		if not found then
			cmSM:Hide()
		end
	end)

	-- -- This is what stops constant OnUpdate
	-- cmSM:SetScript("OnShow", function(self)
		-- self:SetScript("OnUpdate", OnUpdate)
	-- end)
	-- cmSM:SetScript("OnHide", function (self)
		-- self:SetScript("OnUpdate", nil)
	-- end)

	-- -- If autohide is not set, show frame
	-- if autohide ~= true then
		-- if cmSM:IsShown() then
			-- cmSM:SetScript("OnUpdate", OnUpdate)
		-- else
			-- cmSM:Show()
		-- end
	-- end

	return cmSM
end
--]]