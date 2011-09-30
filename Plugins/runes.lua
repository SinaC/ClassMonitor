-- Runes plugin (based on fRunes by Krevlorne [https://github.com/Krevlorne])
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local O = CMOptions["runes"]
if O.enable ~= true then return end

local runes = {}

-- Create the frame
cmRunes = CreateFrame("Frame", "cmRunes", UIParent)

-- Create the runes
for i = 1, 6 do
	local rune = CreateFrame("Frame", "cmRunesRune"..i, UIParent)
	rune:CreatePanel(nil, O.width, O.height, "CENTER", UIParent, "CENTER", 0, 0)
	rune.sStatus = CreateFrame("StatusBar", "cmRunesRuneStatus"..i, rune)
	rune.sStatus:SetStatusBarTexture(C.media.normTex)
	rune.sStatus:SetStatusBarColor(unpack(O.colors[math.ceil(O.runemap[i]/2)]))
	rune.sStatus:SetFrameLevel(6)
	rune.sStatus:SetMinMaxValues(0, 10)
	rune.sStatus:Point("TOPLEFT", rune, "TOPLEFT", 2, -2)
	rune.sStatus:Point("BOTTOMRIGHT", rune, "BOTTOMRIGHT", -2, 2)

	rune.sStatus:SetOrientation(O.orientation)

	if i == 1 then
		rune:Point(unpack(O.anchor))
	else
		rune:Point("LEFT", runes[i-1], "RIGHT", O.spacing, 0)
	end

	tinsert(runes, rune)
end

-- Function to update runes
local function UpdateRune(id, start, duration, finished)
	local rune = runes[id]

	rune.sStatus:SetStatusBarColor(unpack(O.colors[GetRuneType(O.runemap[id])]))
	rune.sStatus:SetMinMaxValues(0, duration)

	if finished then
		rune.sStatus:SetValue(duration)
	else
		rune.sStatus:SetValue(GetTime() - start)
	end
end

local OnUpdate = CreateFrame("Frame")
OnUpdate.TimeSinceLastUpdate = 0
local updateFunc = function(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if self.TimeSinceLastUpdate > O.updatethreshold then
		for i = 1, 6 do
			UpdateRune(i, GetRuneCooldown(O.runemap[i]))
		end
		self.TimeSinceLastUpdate = 0
	end
end
OnUpdate:SetScript("OnUpdate", updateFunc)

cmRunes:RegisterEvent("PLAYER_REGEN_DISABLED")
cmRunes:RegisterEvent("PLAYER_REGEN_ENABLED")
cmRunes:RegisterEvent("PLAYER_ENTERING_WORLD")
cmRunes:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_REGEN_DISABLED" then
		if O.autohide then
			UIFrameFadeIn(self, (0.3 * (1-self:GetAlpha())), self:GetAlpha(), 1)
		end
		OnUpdate:SetScript("OnUpdate", updateFunc)
	elseif event == "PLAYER_REGEN_ENABLED" then
		if O.autohide then
			UIFrameFadeOut(self, (0.3 * (0+self:GetAlpha())), self:GetAlpha(), 0)
		end
		OnUpdate:SetScript("OnUpdate", nil)
	elseif event == "PLAYER_ENTERING_WORLD" then
		RuneFrame:ClearAllPoints()
		if not InCombatLockdown() then
			if O.autohide then
				cmRunes:SetAlpha(0)
			else
				cmRunes:SetAlpha(1)
			end
		end
	end
end)

-- Hide blizzard runeframe
RuneFrame:Hide()
RuneFrame:SetScript("OnShow", function(self)
	self:Hide()
end)

-- one bar with 6 status bar
-- -- Runes plugin (based on fRunes by Krevlorne [https://github.com/Krevlorne])
-- local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

-- local O = CMOptions["runes"]
-- if O.enable ~= true then return end

-- local orientation = "VERTICAL"
-- local fillorientation = "HORIZONTAL"
-- local runes = {}

-- -- Create the frame
-- cmRunes = CreateFrame("Frame", "cmRunes", UIParent)
-- cmRunes:SetPoint(unpack(O.anchor))
-- if ( orientation == "VERTICAL" ) then
	-- cmRunes:SetSize(O.width * 6 + 9, O.height)
-- else
	-- cmRunes:SetSize(O.width, O.height * 6 + O.spacing * 5)
-- end

-- -- Styling
-- cmRunes:SetTemplate("Default")
-- cmRunes:CreateShadow("Default")

-- -- Create the runes
-- for i = 1, 6 do
	-- local rune = CreateFrame("StatusBar", "cmRunesRune"..i, cmRunes)
	-- rune:SetStatusBarTexture(C.media.normTex)
	-- rune:SetStatusBarColor(unpack(O.colors[math.ceil(O.runemap[i]/2)]))
	-- rune:SetMinMaxValues(0, 10)

	-- if ( orientation == "VERTICAL" ) then
		-- rune:SetOrientation(fillorientation)
		-- rune:SetWidth(O.width)
	-- else
		-- rune:SetOrientation(fillorientation)
		-- rune:SetHeight(O.height)
	-- end
	
	-- if i == 1 then
		-- rune:SetPoint("TOPLEFT", cmRunes, "TOPLEFT", 2, -2)
		-- if ( orientation == "VERTICAL" ) then
			-- rune:SetPoint("BOTTOMLEFT", cmRunes, "BOTTOMLEFT", 2, 2)
		-- else
			-- rune:SetPoint("TOPRIGHT", cmRunes, "TOPRIGHT", -2, -2)
		-- end
	-- else
		-- if ( orientation == "VERTICAL" ) then
			-- rune:SetHeight(runes[1]:GetHeight())
			-- rune:SetPoint("LEFT", runes[i-1], "RIGHT", 1, 0)
		-- else
			-- rune:SetWidth(runes[1]:GetWidth())
			-- rune:SetPoint("TOP", runes[i-1], "BOTTOM", 0, -1)
		-- end
	-- end
	
	-- tinsert(runes, rune)
-- end

-- -- Function to update runes
-- local function UpdateRune(id, start, duration, finished)
	-- local rune = runes[id]
	
	-- rune:SetStatusBarColor(unpack(O.colors[GetRuneType(O.runemap[id])]))
	-- rune:SetMinMaxValues(0, duration)
	
	-- if finished then
		-- rune:SetValue(duration)
	-- else
		-- rune:SetValue(GetTime() - start)
	-- end
-- end

-- local OnUpdate = CreateFrame("Frame")
-- OnUpdate.TimeSinceLastUpdate = 0
-- local updateFunc = function(self, elapsed)
	-- self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	-- if self.TimeSinceLastUpdate > O.updatethreshold then
		-- for i = 1, 6 do
			-- UpdateRune(i, GetRuneCooldown(O.runemap[i]))
		-- end
		-- self.TimeSinceLastUpdate = 0
	-- end
-- end
-- OnUpdate:SetScript("OnUpdate", updateFunc)

-- cmRunes:RegisterEvent("PLAYER_REGEN_DISABLED")
-- cmRunes:RegisterEvent("PLAYER_REGEN_ENABLED")
-- cmRunes:RegisterEvent("PLAYER_ENTERING_WORLD")
-- cmRunes:SetScript("OnEvent", function(self, event)
	-- -- TODO autohide
	-- if event == "PLAYER_REGEN_DISABLED" then
		-- --UIFrameFadeIn(self, (0.3 * (1-self:GetAlpha())), self:GetAlpha(), 1)
		-- OnUpdate:SetScript("OnUpdate", updateFunc)
	-- elseif event == "PLAYER_REGEN_ENABLED" then
		-- --UIFrameFadeOut(self, (0.3 * (0+self:GetAlpha())), self:GetAlpha(), 0)
		-- OnUpdate:SetScript("OnUpdate", nil)
	-- elseif event == "PLAYER_ENTERING_WORLD" then
		-- RuneFrame:ClearAllPoints()
		-- if not InCombatLockdown() then
			-- cmRunes:SetAlpha(0)
		-- end
		-- cmRunes:SetAlpha(1)
	-- end
-- end)

-- -- Hide blizzard runeframe
-- RuneFrame:Hide()
-- RuneFrame:SetScript("OnShow", function(self)
	-- self:Hide()
-- end)