local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end


-- Return current anchor in function of anchoring mode
Engine.GetAnchor = function(settings)
--print("GetAnchor:"..tostring(ClassMonitorDataPerChar.Global.autogridanchor).."  "..tostring(settings.autogridanchor).."  "..tostring(settings.anchor))
	return (ClassMonitorDataPerChar.Global.autogridanchor == true and settings.autogridanchor) or settings.anchor
end

-- Return current width in function of anchoring mode
Engine.GetWidth = function(settings)
--print("GetWidth:"..tostring(ClassMonitorDataPerChar.Global.autogridanchor).."  "..tostring(settings.autogridwidth).."  "..tostring(settings.width))
	return (ClassMonitorDataPerChar.Global.autogridanchor == true and settings.autogridwidth) or settings.width
end

-- Return current height in function of anchoring mode
Engine.GetHeight = function(settings)
--print("GetHeight:"..tostring(ClassMonitorDataPerChar.Global.autogridanchor).."  "..tostring(settings.autogridheight).."  "..tostring(settings.height))
	return (ClassMonitorDataPerChar.Global.autogridanchor == true and settings.autogridheight) or settings.height
end


-- Return colors[index] or default color colors is nil or colors[index] doesn't exist
Engine.GetColor = function(colors, index, default)
	if not colors then return default end -- colors is nil
	if type(colors) ~= "table" then return default end -- colors must be a color or a table of color
	if type(colors[1]) == "number" then return colors end -- colors is a single color
	if not colors[index] then return default end -- colors is a table of color but colors[index] doesn't exist
	return colors[index] -- colors[index] exists
end

-- Return value or default is value is nil
Engine.DefaultBoolean = function(value, default)
	if value == nil then
		return default
	else
		return value
	end
end

-- Compute width and spacing for total width and count
-- Don't want to solve a Diophantine equation, so we use a dumb guess/try method =)
Engine.PixelPerfect = function(totalWidth, count)
	if count == 1 then return totalWidth, 0 end
	local width, spacing = math.floor(totalWidth/count) - (count-1), 1
	while true do
		local total = width * count + spacing * (count-1)
		if total > totalWidth then
			if width * count >= totalWidth then
				assert(false, "Problem with PixelPerfect, unable to compute valid width/spacing. totalWidth: "..tostring(totalWidth).."  count: "..tostring(count))
				return nil --width, 1-- error
			end
			spacing = 1
			width = width + 1
		end
		if total == totalWidth then
			return width, spacing
		end
		spacing = spacing + 1
	end
end

-- Format a number
Engine.FormatNumber = function(val)
	if val >= 1e6 then
		return ("%.1fm"):format(val / 1e6)
	elseif val >= 1e3 then
		return ("%.1fk"):format(val / 1e3)
	else
		return ("%d"):format(val)
	end
end

-- Format a time
Engine.ToClock = function(seconds)
	local ceilSeconds = ceil(tonumber(seconds))
	if ceilSeconds <= 0 then
		return " "
	elseif ceilSeconds < 10 then
		return format("%.1f", seconds)
	elseif ceilSeconds < 600 then
		local _, _, m, s = ChatFrame_TimeBreakDown(ceilSeconds)
		return format("%01d:%02d", m, s)
	elseif ceilSeconds < 3600 then
		local _, _, m, s = ChatFrame_TimeBreakDown(ceilSeconds)
		return format("%02d:%02d", m, s)
	else
		return "1 hr+"
	end
end

-- Check if current spec match specs list ("any" for any spec)
Engine.CheckSpec = function(specs)
	local activeSpec = GetSpecialization()
	for _, spec in pairs(specs) do
		if spec == "any" or tostring(spec) == tostring(activeSpec) then
			return true
		end
	end
	return false
end

-- Return a section from class config
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

-- Add a section in class config
Engine.AddConfig = function(c, config)
	local class = string.upper(c)
	local classEntry = Engine.Config[class]
	if classEntry then
		table.insert(classEntry, config)
	end
end

-- Duplicate any object
Engine.DeepCopy = function(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return new_table
	end
	return _copy(object)
end

-- Check if PTR
Engine.IsPTR = function()
	local toc = select(4, GetBuildInfo())
	return toc > 50001
end