-- Aura plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

--[[
Savage Defense uses a new mechanic - Recharge time. The 1.5 cooldown displayed here is accurate (though it seems confusing with the Omni CC add-on that seems to show a 9 second cooldown).
You have up to 3 charges stored at a time.
You gain 1 charge every 9 seconds (the fake cooldown)
You can press Savage Defense even when you still have the 6 second buff on you, and it will simply add 6 seconds to your buff.
With enough rage (60 rage a pop), the 1.5 second cooldown and a 6 second duration you could've kept this 45% dodge buff up indefinately, making it just a boring buff you have to keep active or you fail.
The 9 second Recharge timer simply serves to prevent that. You can keep the buff active 2/3 of the time, the nice thing is you get to choose when that is. 6 on 3 off, or 12 on 6 off, or 12 on 1 off 6 on....
It's a new way of thinking about cooldowns, and I personally am excited to see what else could use it.
--]]

local ToClock = Engine.ToClock
local CheckSpec = Engine.CheckSpec
local PixelPerfect = Engine.PixelPerfect

-- Generic method to create Recharge monitor
Engine.CreateRechargeMonitor = function(name, enable, autohide, text, spellID, anchor, totalWidth, height, color, specs)
	local globalMaxCharges = 1
	local spellName, _, spellIcon = GetSpellInfo(spellID)
	local count = 1 -- starts with only one charge, will be modified in PLAYER_LOGIN
--print("CreateRechargeMonitor:"..tostring(spellID).."->"..tostring(spellName).."  "..tostring(current).."  "..tostring(count).."  "..tostring(timeLastCast).."  "..tostring(cooldownDuration))
	local cmRecharges = {}
	local width, spacing = PixelPerfect(totalWidth, count)

	local function CreateCharge(i, width, height)
		if cmRecharges[i] then return end -- already created

		local cmRecharge = CreateFrame("Frame", name, UI.PetBattleHider) -- name is used for 1st power point
		cmRecharge:SetTemplate()
		cmRecharge:SetFrameStrata("BACKGROUND")
		cmRecharge:Size(width, height)
		if i == 1 then
			cmRecharge:Point(unpack(anchor))
		else
			cmRecharge:Point("LEFT", cmRecharges[i-1], "RIGHT", spacing, 0)
		end
		cmRecharge.status = CreateFrame("StatusBar", name.."_status_"..i, cmRecharge)
		cmRecharge.status:SetStatusBarTexture(UI.NormTex)
		cmRecharge.status:SetFrameLevel(6)
		cmRecharge.status:Point("TOPLEFT", cmRecharge, "TOPLEFT", 2, -2)
		cmRecharge.status:Point("BOTTOMRIGHT", cmRecharge, "BOTTOMRIGHT", -2, 2)
		cmRecharge.status:SetStatusBarColor(unpack(color))
		cmRecharge.status:SetMinMaxValues(0, 300) -- dummy value
		cmRecharge.status:SetValue(0)

		if text == true then
			cmRecharge.text = UI.SetFontString(cmRecharge.status, 12)
			cmRecharge.text:Point("CENTER", cmRecharge.status)
		end

		cmRecharge:Hide()

		tinsert(cmRecharges, cmRecharge)
	end
	for i = 1, count do
		CreateCharge(i, width, height)
	end

	if not enable then
		for i = 1, count do cmRecharges[i]:Hide() end
		return
	end

	local function UpdateRechargeTimer(self, elapsed)
		if not self.status.expirationTime then return end
		self.status.expirationTime = self.status.expirationTime - elapsed

		local timeLeft = self.status.expirationTime
		local timeElapsed = self.status.cooldownDuration - timeLeft
		if timeLeft > 0 then
			--self.status:SetValue(timeLeft)
			self.status:SetValue(timeElapsed)
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

	cmRecharges[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmRecharges[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmRecharges[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmRecharges[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmRecharges[1]:RegisterEvent("SPELLS_CHANGED") -- only valid event triggered after a talent is learned
	cmRecharges[1]:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	--cmRecharges[1]:RegisterEvent("SPELL_UPDATE_CHARGES") could be useful to detect charge modification
	cmRecharges[1]:SetScript("OnEvent", function(self, event, arg1, arg2)
--print("EVENT:"..tostring(event).."  "..tostring(arg1).."  "..tostring(arg2))
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		if CheckSpec(specs) and visible then
			local currentCharges, maxCharges, timeLastCast, cooldownDuration = GetSpellCharges(spellName)
--print("current:"..tostring(currentCharges).."  max:"..tostring(maxCharges).."  "..tostring(timeLastCast).."  "..tostring(cooldownDuration))
			-- check if max charge has changed
			if maxCharges and maxCharges ~= count then
				-- compute new width/spacing
				local width, spacing = PixelPerfect(totalWidth, maxCharges)
				-- apply new width/spacing to existing charges
				for i = 1, globalMaxCharges do
					local cmRecharge = cmRecharges[i]
					cmRecharge:Size(width, height)
					cmRecharge:ClearAllPoints()
					if i == 1 then
						cmRecharge:Point(unpack(anchor))
					else
						cmRecharge:Point("LEFT", cmRecharges[i-1], "RIGHT", spacing, 0)
					end
					cmRecharge:Hide()
				end
				-- create new charges
				for i = count+1, maxCharges do
					CreateCharge(i, width, height)
				end
--print("COUNT:"..tostring(count).."=>"..tostring(maxCharges))
				count = maxCharges
				if maxCharges > globalMaxCharges then globalMaxCharges = maxCharges end
			end
			currentCharges = currentCharges or 0
			-- [BAR1]  [BAR2]  [BAR3]
			-- if bar2 is on cooldown (3 sec left), this will be displayed
			-- [FILL]  [3SEC]  [EMPTY]
			for i = 1, count do
				local cmRecharge = cmRecharges[i]
				if i-1 == currentCharges and timeLastCast ~= nil then
					-- set cooldown on bar
					local timeLeft = (timeLastCast+cooldownDuration) - GetTime()
					cmRecharge.status.cooldownDuration = cooldownDuration
					cmRecharge.status.expirationTime = timeLeft
					cmRecharge.status:SetMinMaxValues(0, cooldownDuration)
					cmRecharge:SetScript("OnUpdate", UpdateRechargeTimer)
					cmRecharge:Show()
				elseif i-1 < currentCharges then
					-- fill bar
					cmRecharge.status.expirationTime = nil
					cmRecharge.status:SetMinMaxValues(0, 1)
					cmRecharge.status:SetValue(1)
					if text == true then
						cmRecharge.text:SetText("")
					end
					cmRecharge:Show()
				else
					-- empty bar
					cmRecharge.status.expirationTime = nil
					cmRecharge.status:SetMinMaxValues(0, 1)
					cmRecharge.status:SetValue(0)
					if text == true then
						cmRecharge.text:SetText("")
					end
					cmRecharge:Show()
				end
			end
		else
			for i = 1, count do
				local cmRecharge = cmRecharges[i]
				cmRecharge:Hide()
				cmRecharge.status:SetValue(0)
				cmRecharge:SetScript("OnUpdate", nil)
				if text == true then
					cmRecharge.text:SetText("")
				end
				cmRecharge:Hide()
			end
		end
	end)

	return cmRecharges[1]
end