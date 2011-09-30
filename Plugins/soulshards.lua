-- Soul Shards plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local O = CMOptions["soul"]
if O.enable ~= true then return end

CreatePowerMonitor( SPELL_POWER_SOUL_SHARDS, 3, O )

-- local cmSoul = CreateFrame("Frame", "cmSoul", UIParent)
-- for i = 1, 3 do
	-- cmSoul[i] = CreateFrame("Frame", "cmSoul"..i, UIParent)
	-- cmSoul[i]:CreatePanel("Default", O.width, O.height, "CENTER", UIParent, "CENTER", 0, 0)
	-- cmSoul[i]:CreateShadow("Default")
	-- cmSoul[i]:SetBackdropBorderColor(unpack(O.color))

	-- if i == 1 then
		-- cmSoul[i]:Point(unpack(O.anchor))
	-- else
		-- cmSoul[i]:Point("LEFT", cmSoul[i-1], "RIGHT", O.spacing, 0)
	-- end
-- end

-- cmSoul[1]:RegisterEvent("UNIT_POWER")
-- cmSoul[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
-- cmSoul[1]:SetScript("OnEvent", function()
	-- local shard = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
	-- if shard and shard > 0 then
		-- for i = 1, shard do cmSoul[i]:Show() end
		-- for i = shard+1, 3 do cmSoul[i]:Hide() end
	-- else
		-- for i = 1, 3 do cmSoul[i]:Hide() end
	-- end
-- end)