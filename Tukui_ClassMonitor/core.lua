local ADDON_NAME, Engine = ...
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local CMDebug = false

local settings = C["classmonitor"][T.myclass]
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
	frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:HookScript("OnEvent", function(self, event)
		if event ~= "PLAYER_SPECIALIZATION_CHANGED" and event ~= "PLAYER_ENTERING_WORLD" then return end
		local anchor = GetAnchor(anchors)
		if not anchor then return end
		DEBUG("Anchor:"..event.." "..frame:GetName())
		frame:Point(unpack(anchor))
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

---------------------------------------
-- Main

-- Remove non-class specific spell-list
for class in pairs(C["classmonitor"]) do
	if class ~= T.myclass then
		C["classmonitor"][class] = nil
	end
end

-- Create monitor frames
for i, section in ipairs(settings) do
	local name = section.name
	local kind = section.kind
	local anchors = section.anchors
	local anchor = section.anchor or GetAnchor(anchors)
	local width = section.width or 85
	local height = section.height or 15
	local spec = section.spec or "any"

	DEBUG("section:"..name)
	if name and kind and anchor then
		-- for AURA, POWER and COMBO, if colors doesn't exist create it using color for each entry
		-- if color doesn't exist, use T.UnitColor.class[T.myclass]
		local frame
		if kind == "MOVER" then
			local text = section.text or name.."_MOVER"

			frame = Engine:CreateMover(name, width, height, anchor, text)
		elseif kind == "RESOURCE" then
			local text = section.text or true
			local autohide = section.autohide or false
			local colors = section.colors or (section.color and {section.color})

			frame = Engine:CreateResourceMonitor(name, text, autohide, anchor, width, height, colors, spec)
		elseif kind == "HEALTH" then
			local text = section.text or true
			local autohide = section.autohide or false
			local colors = section.colors or (section.color and {section.color})

			frame = Engine:CreateHealthMonitor(name, text, autohide, anchor, width, height, colors, spec)
		elseif kind == "COMBO" then
			local spacing = section.spacing or 3
			local color = section.color or T.UnitColor.class[T.myclass]
			local colors = section.colors or CreateColorArray(color, 5)

			frame = Engine:CreateComboMonitor(name, anchor, width, height, spacing, colors, filled, spec)
		elseif kind == "POWER" then
			local powerType = section.powerType
			local count = section.count
			local spacing = section.spacing or 3
			local color = section.color or T.UnitColor.class[T.myclass]
			local colors = section.colors or CreateColorArray(color, count)
			local filled = section.filled or false

			if powerType == SPELL_POWER_BURNING_EMBERS then
				frame = Engine:CreateBurningEmbersMonitor(name, anchor, width, height, spacing, colors)
			elseif powerType == SPELL_POWER_DEMONIC_FURY then
				local text = section.text or true
				local autohide = section.autohide or false
				frame = Engine:CreateDemonicFuryMonitor(name, text, autohide, anchor, width, height, colors)
			elseif powerType and count then
				frame = Engine:CreatePowerMonitor(name, powerType, count, anchor, width, height, spacing, colors, filled, spec)
			else
				WARNING("section:"..name..":"..(powerType and "" or " missing powerType")..(count and "" or " missing count"))
			end
		elseif kind == "AURA" then
			local spellID = section.spellID
			local filter = section.filter
			local count = section.count
			local spacing = section.spacing
			local color = section.color or T.UnitColor.class[T.myclass]
			local colors = section.colors or CreateColorArray(color, count)
			local filled = section.filled or false
			local bar = section.bar or false
			local text = section.text or true
			local duration = section.duration or false

			if spellID and filter and count then
				if bar then
					frame = Engine:CreateBarAuraMonitor(name, spellID, filter, count, anchor, width, height, color, text, duration, spec)
				else
					frame = Engine:CreateAuraMonitor(name, spellID, filter, count, anchor, width, height, spacing, colors, filled, spec)
				end
			else
				WARNING("section:"..name..":"..(spellID and "" or " missing spellID")..(filter and "" or " missing filter")..(count and "" or " missing count"))
			end
		elseif kind == "DOT" then
			local spellID = section.spellID
			local colors = section.colors or (section.color and {section.color})
			local latency = section.latency or false
			local threshold = section.threshold or 0


			if spellID then
				frame = Engine:CreateDotMonitor(name, spellID, anchor, width, height, colors, threshold, latency, spec)
			else
				WARNING("section:"..name..":"..(spellID and "" or " missing spellID"))
			end
		elseif kind == "RUNES" then
			local updatethreshold = section.updatethreshold or 0.1
			local autohide = section.autohide or false
			local orientation = section.orientation or "HORIZONTAL"
			local spacing = section.spacing or 3
			local colors = section.colors
			local runemap = section.runemap

			if runemap and colors then
				frame = Engine:CreateRunesMonitor(name, updatethreshold, autohide, orientation, anchor, width, height, spacing, colors, runemap)
			else
				WARNING("section:"..name..":"..(runemap and "" or " missing runemap")..(colors and "" or " missing colors"))
			end
		elseif kind == "ECLIPSE" then
			local colors = section.colors
			local text = section.text or true

			if colors then
				frame = Engine:CreateEclipseMonitor(name, text, anchor, width, height, colors)
			else
				WARNING("section:"..name..": missing colors")
			end
		elseif kind == "TOTEM" then
			local count = section.count
			local spacing = section.spacing
			local color = section.color or T.UnitColor.class[T.myclass]
			local colors = section.colors or CreateColorArray(color, count)

			if colors then
				frame = Engine:CreateTotemMonitor(name, count, anchor, width, height, spacing, colors)
			else
				WARNING("section:"..name..": missing colors")
			end
		elseif kind == "WILDMUSHROOMS" then
			local spacing = section.spacing
			local color = section.color or T.UnitColor.class[T.myclass]
			local colors = section.colors or CreateColorArray(color, 3)
			if colors then
				frame = Engine:CreateWildMushroomsMonitor(name, anchor, width, height, spacing, colors)
			else
				WARNING("section:"..name..": missing colors")
			end
		else
			WARNING("section:"..name..": invalid kind:"..kind)
		end

		-- WARNING if frame not created
		if not frame then DEBUG("section:"..name.." frame not created") end-- DEBUG

		-- Add multiple anchor handler
		if anchors and frame then
			SetMultipleAnchorHandler(frame, anchors)
		end
	else
		WARNING((name and "" or " missing name")..(kind and "" or " missing kind")..(anchor and "" or " missing anchor"))
	end
end