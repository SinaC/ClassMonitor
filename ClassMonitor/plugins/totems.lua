-- Totem plugin, credits to Ildyria and Tukz
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

local ToClock = Engine.ToClock
local CheckSpec = Engine.CheckSpec
local PixelPerfect = Engine.PixelPerfect

-- Generic method to create totem monitor
Engine.CreateTotemMonitor = function(name, enable, autohide, count, anchor, totalWidth, height, colors, text, map, specs)
	local cmTotems = {}
	local width, spacing = PixelPerfect(totalWidth, count)
	for i = 1, count do
		local cmTotem = CreateFrame("Frame", name, UI.BattlerHider)
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

--[[

-- Generic method to create totem monitor
Engine.CreateTotemMonitor = function(name, enable, autohide, count, anchor, width, height, spacing, colors, text, map, specs)
	local cmTotems = {}
	for i = 1, count do
		local cmTotem = CreateFrame("Frame", name, UI.BattlerHider)
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