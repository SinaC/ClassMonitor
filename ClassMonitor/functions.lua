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

Engine.GetConfig = function(c, n)
	local class = string.upper(c)
	local name = string.upper(n)
	local alternativeName = "CM_" .. name
	local classEntry = Engine.Config[class]
	if classEntry then
		for _, v in pairs(classEntry) do
			if v.name == name or v.name == alternativeName or v.kind == name then
				return v
			end
		end
	end
	return nil
end

Engine.AddConfig = function(c, config)
	local class = string.upper(c)
	local classEntry = Engine.Config[class]
	if classEntry then
		table.insert(classEntry, config)
	end
end