-- Totem plugin, credits to Ildyria
local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui)

-- Generic method to create Totem monitor
function Engine:CreateTotemMonitor(name, count, anchor, width, height, spacing, colors)
	local total = 0
	local delay = 0.01

	local cmTotemTimers = CreateFrame("Frame", name, UIParent)

	local totems = {}

	for i=1,4 do
		totems[i] = CreateFrame("Frame", name..i, TukuiPetBattleHider)
		totems[i]:SetTemplate()
		totems[i]:SetFrameStrata("BACKGROUND")
		totems[i]:Size(width, height)
		totems[i].status = CreateFrame("StatusBar", name..i.."status", totems[i])
		totems[i].status:SetStatusBarTexture(C.media.normTex)
		totems[i].status:SetFrameLevel(6)
		totems[i].status:Point("TOPLEFT", totems[i], "TOPLEFT", 2, -2)
		totems[i].status:Point("BOTTOMRIGHT", totems[i], "BOTTOMRIGHT", -2, 2)
		totems[i].status:SetOrientation("HORIZONTAL")

		totems[i].timer = totems[i].status:CreateFontString(nil, "OVERLAY")
		totems[i].timer:SetFont(C.media.uffont, 12)
		totems[i].timer:Point("CENTER", totems[i].status)
		totems[i].timer:SetShadowColor(0, 0, 0)
		totems[i].timer:SetShadowOffset(1.25, -1.25)
	end

	-- re-arrange the order
	totems[2]:ClearAllPoints();
	totems[1]:ClearAllPoints();
	totems[3]:ClearAllPoints();
	totems[4]:ClearAllPoints();
	totems[2]:Point(unpack(anchor))
	totems[1]:Point("LEFT", totems[2], "RIGHT", spacing, 0)
	totems[3]:Point("LEFT", totems[1], "RIGHT", spacing, 0)
	totems[4]:Point("LEFT", totems[3], "RIGHT", spacing, 0)

	local function ToClock(seconds)
		seconds = ceil(tonumber(seconds))
		if(seconds <= 0) then
			return " "
		elseif seconds < 600 then
			local d, h, m, s = ChatFrame_TimeBreakDown(seconds)
			return format("%01d:%02d", m, s)
		elseif(seconds < 3600) then
			local d, h, m, s = ChatFrame_TimeBreakDown(seconds);
			return format("%02d:%02d", m, s)
		else
			return "1 hr+"
		end
	end

	local function GetTimeLeft(slot)
		local havetotem, name, startTime, duration = GetTotemInfo(slot)
		return (duration-(GetTime() - startTime))
	end

	local function UpdateSlot()
		for slot=1, 4 do
			local havetotem, name, startTime, duration = GetTotemInfo(slot)
			totems[slot].status:SetStatusBarColor(unpack(colors[slot]))
			totems[slot].status:SetValue(0)

--			totems[slot].ID = slot

			-- If we have a totems then set his value
			if(havetotem) then
				if(duration >= 0) then
					totems[slot].status:SetMinMaxValues(0, duration)
					totems[slot].status:SetValue(GetTimeLeft(slot)) -- -(GetTime() - startTime))
					totems[slot].timer:SetText()
					-- Status bar update
					totems[slot]:SetScript("OnUpdate",function(self,elapsed)
						total = total + elapsed
						if total >= delay then
							total = 0
							havetotem, name, startTime, duration = GetTotemInfo(slot)
							if (GetTimeLeft(slot) >= 0) then --(GetTime() - startTime) <= 0) then
								-- totems[slot]:Show()
								totems[slot].status:SetValue(GetTimeLeft(slot))
								totems[slot].timer:SetText(ToClock(GetTimeLeft(slot)))
								totems[slot]:SetAlpha(1)
							else
								totems[slot].status:SetValue(0)
								totems[slot].timer:SetText(" ")
								totems[slot]:SetAlpha(0)
							end
						end
					end)
				else
					-- There's no need to update because it doesn't have any duration
					totems[slot]:SetScript("OnUpdate",nil)
					totems[slot].status:SetValue(0)
					totems[slot]:SetAlpha(0)
				end
			else
				-- No totems = no time
				totems[slot]:SetAlpha(0)
				totems[slot].status:SetValue(0)
			end
		end
	end

	cmTotemTimers:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmTotemTimers:RegisterEvent("PLAYER_TOTEM_UPDATE")
	cmTotemTimers:SetScript("OnEvent", UpdateSlot)

	return cmTotemTimers
end