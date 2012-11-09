-- Dot Plugin, written to Ildyria
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

-- ONLY ON PTR
if not Engine.IsPTR() then return end

local CheckSpec = Engine.CheckSpec

--
local plugin = Engine:NewPlugin("DOT")

-- own methods
function plugin:Update(elapsed)
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
	if self.timeSinceLastUpdate > 0.01 then
		local _, _, _, _, _, duration, expTime = UnitAura("target", self.auraName, nil, "PLAYER|HARMFUL")
		local remainTime = (expTime or 0) - GetTime()
		local color
		if self.settings.latency == true and remainTime <= 1 then 
			color = {1, 0, 0, 1} -- red
		else
			if self.settings.threshold == 0 then
				color = (self.settings.colors and self.settings.colors[1]) or self.settings.color or {255/255, 165/255, 0, 1} -- bad: orange
			elseif self.settings.threshold*.75 >= self.dmg then
				color = (self.settings.colors and self.settings.colors[1]) or self.settings.color or {255/255, 165/255, 0, 1} -- bad: orange
				-- print("attend encore")
			elseif self.settings.threshold >= self.dmg then
				-- print("hoh")
				color = (self.settings.colors and self.settings.colors[2]) or self.settings.color or {255/255, 255/255, 0, 1} -- 0,75% -- yellow
			else
				-- print("GOOOO")
				color = (self.settings.colors and self.settings.colors[3]) or self.settings.color or {127/255, 255/255, 0, 1} -- > 100% GO -- green
			end
		end
		self.bar.status:SetStatusBarColor(unpack(color))
		self.bar.status:SetMinMaxValues(0, duration)
		self.bar.status:SetValue(remainTime)
		self.bar.text:SetText(self.dmg)
		self.timeSinceLastUpdate = 0
	end
end

function plugin:UpdateVisibility()
	local visible = false
	if CheckSpec(self.settings.specs) then
		local _, _, _, _, _, duration, expTime = UnitAura("target", self.auraName, nil, "PLAYER|HARMFUL")
		if expTime ~= nil then
			local remainTime = expTime - GetTime()
			if remainTime > 0 then
				visible = true
			end
		end
	end
	if visible then
		self.timeSinceLastUpdate = GetTime()
		self:RegisterUpdate(plugin.Update)
		--
		self.bar:Show()
	else
		self:UnregisterUpdate()
		--
		self.bar:Hide()
		self.dmg = 0
	end
end

function plugin:UpdateLogChecker(event)
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", plugin.UpdateDamage)
	else
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

function plugin:UpdateDamage(_, _, eventType, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, _, _, amount)
	local targetGUID = UnitGUID("target")
	if sourceGUID == self.playerGUID and destGUID == targetGUID then
		if string.find(eventType, "_DAMAGE") and spellID == self.settings.spellID then
print("UpdateDamage:"..tostring(amount))
			self.dmg = amount
		end
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
	end
	bar.status:SetMinMaxValues(0, 1) -- dummy value

	if not bar.text then
		bar.text = UI.SetFontString(bar.status, 12)
		bar.text:Point("CENTER", bar.status)
	end
end

-- overridden methods
function plugin:Initialize()
	--
	self.dmg = 0
	self.playerGUID = UnitGUID("player")
	self.auraName = GetSpellInfo(self.settings.spellID)
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateLogChecker)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateLogChecker)

	--self:RegisterEvent("PLAYER_TARGET_CHANGED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
	--self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	--self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	self:RegisterEvent("UNIT_AURA", plugin.UpdateVisibility)
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
	self.auraName = GetSpellInfo(self.settings.spellID)
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
	if pluginSettings.kind == "DOT" then
		local setting = Engine.DeepCopy(pluginSettings)
		setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		setting.enable = true
		setting.autohide = false
		setting.latency = false
		setting.threshold = setting.threshold or 0
		local instance = Engine:NewPluginInstance("DOT", "DOT"..tostring(i), setting)
		instance:Initialize()
		if setting.enable then
			instance:Enable()
		end
	end
end

--[[
function Engine:CreateDotMonitor(name, spelltracked, anchor, width, height, colors, threshold, latency)
	local aura = GetSpellInfo(spelltracked)

	local cmDot = CreateFrame("Frame", name, TukuiPetBattleHider)
	cmDot:SetTemplate()
	cmDot:SetFrameStrata("BACKGROUND")
	cmDot:Size(width, height)
	cmDot:Point(unpack(anchor))

	cmDot.status = CreateFrame("StatusBar", "cmDotStatus", cmDot)
	cmDot.status:SetStatusBarTexture(C.media.normTex)
	cmDot.status:SetFrameLevel(6)
	cmDot.status:Point("TOPLEFT", cmDot, "TOPLEFT", 2, -2)
	cmDot.status:Point("BOTTOMRIGHT", cmDot, "BOTTOMRIGHT", -2, 2)
	cmDot.status:SetMinMaxValues(0, UnitPowerMax("player"))

	cmDot.text = cmDot.status:CreateFontString(nil, "OVERLAY")
	cmDot.text:SetFont(C.media.uffont, 12)
	cmDot.text:Point("CENTER", cmDot.status)
	cmDot.text:SetShadowColor(0, 0, 0)
	cmDot.text:SetShadowOffset(1.25, -1.25)

	cmDot.dmg = 0
	cmDot.timeSinceLastUpdate = GetTime()

	local function OnUpdate(self, elapsed)
		cmDot.timeSinceLastUpdate = cmDot.timeSinceLastUpdate + elapsed
		if cmDot.timeSinceLastUpdate > 0.01 then
			local _, _, _, count, _, duration, expTime, _, _, _, _ = UnitAura("target", aura, nil, "PLAYER|HARMFUL")
			local remainTime = expTime - GetTime()
			local color
			if(latency and remainTime <= 1) then 
				color = {1,0,0,1}
			else
				if(threshold == 0) then
					color = (colors and (colors[1])) or T.UnitColor.class[T.myclass]
				elseif(threshold*.75 >= cmDot.dmg) then
					color = (colors and (colors[1])) or T.UnitColor.class[T.myclass]
					-- print("attend encore")
				elseif(threshold >= cmDot.dmg) then
					-- print("hoh")
					color = (colors and (colors[2])) or T.UnitColor.class[T.myclass]
				else
					-- print("GOOOO")
					color = (colors and (colors[3])) or T.UnitColor.class[T.myclass]
				end
			end
			cmDot.status:SetStatusBarColor(unpack(color))
			cmDot.status:SetMinMaxValues(0, duration)
			cmDot.status:SetValue(remainTime)
			cmDot.text:SetText(cmDot.dmg)
			cmDot.timeSinceLastUpdate = 0
		end
	end

	cmDot.combatlogcheck = CreateFrame("Frame", "cmCombatLogCheck", cmDot)
	local function CombatLogCheck(WOWevent, ...)																-- Combat event handler
		local _, _, eventType, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, _, _, amount, _ = ...
		local pGUID = UnitGUID("player")
		local tGUID = UnitGUID("target")
		if sourceGUID == pGUID and destGUID == tGUID then
			if string.find(eventType, "_DAMAGE") and spellID == spelltracked then
				cmDot.dmg = amount
			end
		end
	end

	local function CombatCheck(self,event)																		-- Combat check function
		if event == "PLAYER_REGEN_DISABLED" then
			cmDot.combatlogcheck:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			cmDot.combatlogcheck:SetScript("OnEvent",CombatLogCheck)
		else
			cmDot.combatlogcheck:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			cmDot.combatlogcheck:SetScript("OnEvent",nil)
		end
	end

	cmDot.combatcheck = CreateFrame("Frame", "cmCombatCheck", cmDot)
	cmDot.combatcheck:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmDot.combatcheck:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmDot.combatcheck:SetScript("OnEvent", CombatCheck)

	local function CombatAuraCheck(self,event)																			-- Aura check
		local _, _, _, count, _, duration, expTime, _, _, _, _ = UnitAura("target", aura, nil, "PLAYER|HARMFUL")
		if expTime ~= nil then
			local remainTime = expTime - GetTime()
			if remainTime <= 0 then
				remainTime = 0
				cmDot:Hide()
				cmDot.dmg = 0
			end
			cmDot:Show()
		else
			cmDot:Hide()
			cmDot.dmg = 0
		end
	end

	cmDot.auracheck = CreateFrame("Frame", "cmAuraCheck", cmDot)
	cmDot.auracheck:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmDot.auracheck:RegisterEvent("UNIT_AURA")
	cmDot.auracheck:SetScript("OnEvent", CombatAuraCheck)

	cmDot.targetcheck = CreateFrame("Frame", "cmTargetCheck", cmDot)
	cmDot.targetcheck:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmDot.targetcheck:SetScript("OnEvent", function(self) cmDot:Hide() end)

	-- This is what stops constant OnUpdate
	cmDot:SetScript("OnShow", function(self) self:SetScript("OnUpdate", OnUpdate) end)
	cmDot:SetScript("OnHide", function (self) self:SetScript("OnUpdate", nil) end)
	
	return cmDot
end
--]]

--[[
-- Generic method to create a dot monitor
Engine.CreateDotMonitor = function(name, enable, autohide, spelltracked, anchor, width, height, colors, threshold, latency, specs)
--print("DOT:"..tostring(name))
	local aura = GetSpellInfo(spelltracked)

	local cmDot = CreateFrame("Frame", name, UI.PetBattleHider)
	cmDot:SetTemplate()
	cmDot:SetFrameStrata("BACKGROUND")
	cmDot:Size(width, height)
	cmDot:Point(unpack(anchor))

	cmDot.status = CreateFrame("StatusBar", "cmDotStatus", cmDot)
	cmDot.status:SetStatusBarTexture(UI.NormTex)
	cmDot.status:SetFrameLevel(6)
	cmDot.status:Point("TOPLEFT", cmDot, "TOPLEFT", 2, -2)
	cmDot.status:Point("BOTTOMRIGHT", cmDot, "BOTTOMRIGHT", -2, 2)
	cmDot.status:SetMinMaxValues(0, UnitPowerMax("player"))

	cmDot.text = UI.SetFontString(cmDot.status, 12)
	cmDot.text:Point("CENTER", cmDot.status)

	if not enable then
		cmDot:Hide()
		return
	end

	cmDot.dmg = 0
	cmDot.timeSinceLastUpdate = GetTime()

	local function OnUpdate(self, elapsed)
		cmDot.timeSinceLastUpdate = cmDot.timeSinceLastUpdate + elapsed
		if cmDot.timeSinceLastUpdate > 0.1 then
			local _, _, _, count, _, duration, expTime, _, _, _, _ = UnitAura("target", aura, nil, "PLAYER|HARMFUL")
			local remainTime = expTime - GetTime()
			local color
			if(latency and remainTime <= 1) then 
				color = {1,0,0,1}
			else
				if(threshold == 0) then
					color = (colors and (colors[1])) or UI.ClassColor()
				elseif(threshold >= cmDot.dmg) then
					color = (colors and (colors[1])) or UI.ClassColor()
				elseif(threshold >= cmDot.dmg) then
					color = (colors and (colors[2])) or UI.ClassColor()
				else
					color = (colors and (colors[3])) or UI.ClassColor()
				end
			end
			cmDot.status:SetStatusBarColor(unpack(color))
			cmDot.status:SetMinMaxValues(0, duration)
			cmDot.status:SetValue(remainTime)
			cmDot.text:SetText(cmDot.dmg)
			cmDot.timeSinceLastUpdate = 0
		end
	end

	cmDot.combatlogcheck = CreateFrame("Frame", "cmCombatLogCheck", cmDot)
	local function CombatLogCheck(WOWevent, ...)																-- Combat event handler
		local _, _, eventType, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, _, _, amount, _ = ...
		local pGUID = UnitGUID("player")
		local tGUID = UnitGUID("target")
		if sourceGUID == pGUID and destGUID == tGUID then
			if string.find(eventType, "_DAMAGE") and spellID == spelltracked then
				cmDot.dmg = amount
			end
		end
	end

	local function CombatCheck(self,event)																		-- Combat check function
		if event == "PLAYER_REGEN_DISABLED" then
			cmDot.combatlogcheck:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			cmDot.combatlogcheck:SetScript("OnEvent",CombatLogCheck)
		else
			cmDot.combatlogcheck:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			cmDot.combatlogcheck:SetScript("OnEvent",nil)
		end
	end

	cmDot.combatcheck = CreateFrame("Frame", "cmCombatCheck", cmDot)
	cmDot.combatcheck:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmDot.combatcheck:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmDot.combatcheck:SetScript("OnEvent", CombatCheck)

	local function CombatAuraCheck(self,event)																		-- Aura check
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		if not CheckSpec(specs) or not visible then
			cmDot:Hide()
			return
		end

		local _, _, _, count, _, duration, expTime, _, _, _, _ = UnitAura("target", aura, nil, "PLAYER|HARMFUL")
		if expTime ~= nil then
			local remainTime = expTime - GetTime()
			if remainTime <= 0 then
				remainTime = 0
				cmDot:Hide()
				cmDot.dmg = 0
			end
			cmDot:Show()
		else
			cmDot:Hide()
			cmDot.dmg = 0
		end
	end

	cmDot.auracheck = CreateFrame("Frame", "cmAuraCheck", cmDot)
	cmDot.auracheck:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmDot.auracheck:RegisterEvent("UNIT_AURA")
	cmDot.auracheck:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmDot.auracheck:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmDot.auracheck:SetScript("OnEvent", CombatAuraCheck)

	cmDot.targetcheck = CreateFrame("Frame", "cmTargetCheck", cmDot)
	cmDot.targetcheck:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmDot.targetcheck:SetScript("OnEvent", function(self) cmDot:Hide() end)

	-- This is what stops constant OnUpdate
	cmDot:SetScript("OnShow", function(self) self:SetScript("OnUpdate", OnUpdate) end)
	cmDot:SetScript("OnHide", function (self) self:SetScript("OnUpdate", nil) end)

	return cmDot
end
--]]