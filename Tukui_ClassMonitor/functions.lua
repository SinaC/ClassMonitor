local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

-- functions used in multiple plugins

Engine.ToClock = function(seconds)
	seconds = ceil(tonumber(seconds))
	if seconds <= 0 then
		return " "
	elseif seconds < 600 then
		local d, h, m, s = ChatFrame_TimeBreakDown(seconds)
		return format("%01d:%02d", m, s)
	elseif seconds < 3600 then
		local d, h, m, s = ChatFrame_TimeBreakDown(seconds)
		return format("%02d:%02d", m, s)
	else
		return "1 hr+"
	end
end

Engine.CheckSpec = function(specs)
	local activeSpec = GetSpecialization()
	for _, spec in pairs(specs) do
		if spec == "any" or spec == activeSpec then
			return true
		end
	end
	return false
end