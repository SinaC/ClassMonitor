local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

local UI = Engine.UI

local CMDebug = false

local settings = Engine.Config[UI.MyClass]
if not settings then return end

local function WARNING(line)
	print("|CFFFF0000ClassMonitor|r: WARNING - "..line)
end

local function DEBUG(line)
	if not CMDebug or CMDebug == false then return end
	print("|CFF0000FFClassMonitor|r: DEBUG - "..line)
end

-- Return anchor corresponding to current spec
local function GetAnchor(anchors)
	if not anchors then return end
	local spec = GetSpecialization()
	if not spec or spec == 0 then spec = 1 end
	return anchors[spec]
end

-- When multiple anchors are specified, anchor depends on current spec
local function SetMultipleAnchorHandler(frame, anchors)
	if not anchors then return end
	frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:HookScript("OnEvent", function(self, event)
		if event ~= "PLAYER_SPECIALIZATION_CHANGED" and event ~= "PLAYER_ENTERING_WORLD" then return end
		local anchor = GetAnchor(anchors)
		if not anchor then return end
		DEBUG("Anchor:"..tostring(event).." "..tostring(self:GetName()))
		self:ClearAllPoints()
		self:Point(unpack(anchor))
--print("SetMultipleAnchorHandler5:"..tostring(self:GetName()))
	end)
end

-- Create a color array from one color
local function CreateColorArray(color, count)
	if not color or not count then return end
	local colors = { }
	for i = 1, count, 1 do
		tinsert(colors, color)
	end
	return colors
end

local function DefaultBoolean(value, default)
	if value == nil then
		return default
	else
		return value
	end
end

---------------------------------------
-- Main

-- Create monitor frames
for i, section in ipairs(settings) do
	local name = section.name
	local kind = section.kind
	local anchors = section.anchors
	local anchor = section.anchor or GetAnchor(anchors)
	local width = section.width or 85
	local height = section.height or 15
	local spec = section.spec or "any"
	local specs = section.specs or {spec}

	DEBUG("section:"..name)
	if name and kind and anchor then
		local frame
		if kind == "MOVER" then
			local text = section.text or name.."_MOVER"
			frame = UI.CreateMover(name, width, height, anchor, text)
		elseif kind == "RESOURCE" then
			local text = DefaultBoolean(section.text, true)
			local autohide = DefaultBoolean(section.autohide, false)
			local colors = section.colors or (section.color and {section.color})

			frame = Engine.CreateResourceMonitor(name, text, autohide, anchor, width, height, colors, specs)
		elseif kind == "HEALTH" then
			local unit = section.unit or "player"
			local text = DefaultBoolean(section.text, true)
			local autohide = DefaultBoolean(section.autohide, true)
			local color = section.color

			frame = Engine.CreateHealthMonitor(name, unit, text, autohide, anchor, width, height, color, specs)
		elseif kind == "ENERGIZE" then
			local spellID = section.spellID
			local filling = DefaultBoolean(section.filling, false)
			local duration = section.duration
			local color = section.color or UI.ClassColor()

			if spellID and duration then
				frame = Engine.CreateEnergizeMonitor(name, spellID, anchor, width, height, color, duration, filling)
			else
				WARNING("section:"..name..":"..(spellID and "" or " missing spellID")..(duration and "" or " missing duration")) -- TODO: locales
			end
		elseif kind == "COMBO" then
			local spacing = section.spacing or 3
			local color = section.color or UI.ClassColor()
			local colors = section.colors or CreateColorArray(color, 5)
			local autohide = DefaultBoolean(section.autohide, true)

			frame = Engine.CreateComboMonitor(name, autohide, anchor, width, height, spacing, colors, filled, specs)
		elseif kind == "POWER" then
			local powerType = section.powerType
			local count = section.count
			local spacing = section.spacing or 3
			local color = section.color or UI.ClassColor()
			local colors = section.colors or CreateColorArray(color, count)
			local filled = DefaultBoolean(section.filled, false)
			local autohide = DefaultBoolean(section.autohide, false)

			if powerType == SPELL_POWER_BURNING_EMBERS then
				frame = Engine.CreateBurningEmbersMonitor(name, autohide, anchor, width, height, spacing, colors) -- TODO: autohide
			elseif powerType == SPELL_POWER_DEMONIC_FURY then
				local text = DefaultBoolean(section.text, true)
				frame = Engine.CreateDemonicFuryMonitor(name, text, autohide, anchor, width, height, colors)
			elseif powerType and count then
				frame = Engine.CreatePowerMonitor(name, autohide, powerType, count, anchor, width, height, spacing, colors, filled, specs)
			else
				WARNING("section:"..name..":"..(powerType and "" or " missing powerType")..(count and "" or " missing count")) -- TODO: locales
			end
		elseif kind == "AURA" then
			local unit = section.unit or "player"
			local spellID = section.spellID
			local filter = section.filter
			local count = section.count
			local autohide = DefaultBoolean(section.autohide, true)

			if spellID and filter and count then
				local spacing = section.spacing
				local color = section.color or UI.ClassColor()
				local colors = section.colors or CreateColorArray(color, count)
				local filled = DefaultBoolean(section.filled, false)
				local bar = DefaultBoolean(section.bar, false)

				if bar then
					local text = DefaultBoolean(section.text, true)
					local duration = DefaultBoolean(section.duration, false)
					frame = Engine.CreateBarAuraMonitor(name, autohide, unit, spellID, filter, count, anchor, width, height, color, text, duration, specs)
				else
					frame = Engine.CreateAuraMonitor(name, autohide, unit, spellID, filter, count, anchor, width, height, spacing, colors, filled, specs)
				end
			else
				WARNING("section:"..name..":"..(spellID and "" or " missing spellID")..(filter and "" or " missing filter")..(count and "" or " missing count")) -- TODO: locales
			end
		elseif kind == "DOT" then
			local spellID = section.spellID
			local colors = section.colors or (section.color and {section.color})
			local latency = DefaultBoolean(section.latency, false)
			local threshold = section.threshold or 0
			local autohide = DefaultBoolean(section.autohide, true)

			if spellID then
				frame = Engine.CreateDotMonitor(name, autohide, spellID, anchor, width, height, colors, threshold, latency, specs)
			else
				WARNING("section:"..name..":"..(spellID and "" or " missing spellID")) -- TODO: locales
			end
		elseif kind == "RUNES" then
			local updatethreshold = section.updatethreshold or 0.1
			local autohide = DefaultBoolean(section.autohide, false)
			local orientation = section.orientation or "HORIZONTAL"
			local spacing = section.spacing or 3
			local colors = section.colors
			local runemap = section.runemap

			if runemap and colors then
				frame = Engine.CreateRunesMonitor(name, updatethreshold, autohide, orientation, anchor, width, height, spacing, colors, runemap)
			else
				WARNING("section:"..name..":"..(runemap and "" or " missing runemap")..(colors and "" or " missing colors")) -- TODO: locales
			end
		elseif kind == "ECLIPSE" then
			local colors = section.colors
			local text = DefaultBoolean(section.text, true)
			local autohide = DefaultBoolean(section.autohide, false)

			if colors then
				frame = Engine.CreateEclipseMonitor(name, autohide, text, anchor, width, height, colors)
			else
				WARNING("section:"..name..": missing colors") -- TODO: locales
			end
		elseif kind == "TOTEM" then
			local count = section.count
			local autohide = DefaultBoolean(section.autohide, false)
			if count then
				local spacing = section.spacing or 3
				local color = section.color or UI.ClassColor()
				local colors = section.colors or CreateColorArray(color, count)
				local text = DefaultBoolean(section.text, false)
				local map = section.map
				if map and #map ~= count then
					WARNING("section:"..name..": map table's size <> count") -- TODO: locales
				else
					frame = Engine.CreateTotemMonitor(name, autohide, count, anchor, width, height, spacing, colors, text, map, specs)
				end
			else
				WARNING("section:"..name..": missing count") -- TODO: locales
			end
		elseif kind == "BANDITSGUILE" then
			local spacing = section.spacing or 3
			local color = section.color or UI.ClassColor()
			local colors = section.colors or CreateColorArray(color, 3)
			local autohide = DefaultBoolean(section.autohide, true)
			local filled = DefaultBoolean(section.filled, false)

			frame = Engine.CreateBanditsGuileMonitor(name, autohide, anchor, width, height, spacing, colors, filled)
		elseif kind == "STAGGER" then
			local threshold = section.threshold or 100
			local text = DefaultBoolean(section.text, true)
			local autohide = DefaultBoolean(section.autohide, true)
			local colors = section.colors

			if colors then
				frame = Engine.CreateStaggerMonitor(name, threshold, text, autohide, anchor, width, height, colors)
			else
				WARNING("section:"..name..":"..(colors or " missing colors")) -- TODO: locales
			end
		else
			WARNING("section:"..name..": invalid kind:"..kind) -- TODO: locales
		end

		-- WARNING if frame not created
		if not frame then DEBUG("section:"..name.." frame not created") end-- DEBUG -- TODO: locales

		-- Add multiple anchor handler
		if anchors and frame then
			SetMultipleAnchorHandler(frame, anchors)
		end
	else
		WARNING((name and "" or " missing name")..(kind and "" or " missing kind")..(anchor and "" or " missing anchor")) -- TODO: locales
	end
end

-- Delete config
wipe(Engine.Config)