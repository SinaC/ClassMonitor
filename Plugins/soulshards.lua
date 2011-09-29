-- Soul Shards plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local O = CMOptions["soul"]
if O.enable ~= true then return end

local rmSoul = CreateFrame("Frame", "rmSoul", UIParent)
for i = 1, 3 do
	rmSoul[i] = CreateFrame("Frame", "rmSoul"..i, UIParent)
	rmSoul[i]:CreatePanel("Default", O.width, O.height, "CENTER", UIParent, "CENTER", 0, 0)
	rmSoul[i]:CreateShadow("Default")
	rmSoul[i]:SetBackdropBorderColor(unpack(O.color))

	if i == 1 then
		rmSoul[i]:Point(unpack(O.anchor))
	else
		rmSoul[i]:Point("LEFT", rmSoul[i-1], "RIGHT", O.spacing, 0)
	end
end

rmSoul[1]:RegisterEvent("UNIT_POWER")
rmSoul[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
rmSoul[1]:SetScript("OnEvent", function()
	local shard = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
	if shard and shard > 0 then
		for i = 1, shard do rmSoul[i]:Show() end
		for i = shard+1, 3 do rmSoul[i]:Hide() end
	else
		for i = 1, 3 do rmSoul[i]:Hide() end
	end
end)