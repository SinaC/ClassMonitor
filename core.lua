-- TODO
--	include a filger-lite feature
--	instead of adding MultipleAnchorHandler to each frame, create core frame, store a list of frames created by plugin and add event to core frame
--	add a visibility function (we dont want to see resource bar while in travel/flying form) [same system as MultipleAnchorHandler]
--	each plugin frame should be children of core frame

local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local settings = CMSettings[T.myclass]
if not settings then return end

local function Warning(line)
	print("|CFFFF0000ClassMonitor|r: WARNING - "..line)
end

local function Info(line)
	print("|CFF00FF00ClassMonitor|r: INFO - "..line)
end

-- Return anchor corresponding to current spec
local function GetAnchor(anchors)
	if not anchors then return end
	local ptt = GetPrimaryTalentTree()
	if not ptt or ptt == 0 then ptt = 1 end
	return anchors[ptt]
end

-- When multiple anchor are specified, anchor depends on current spec
local function SetMultipleAnchorHandler(frame, anchors)
	--print("SetMultipleAnchorHandler 1")
	if not anchors then return end
	--print("SetMultipleAnchorHandler 2")
	local function SetAnchor(self, event)
		if event ~= "PLAYER_TALENT_UPDATE" and event ~= "PLAYER_ENTERING_WORLD" then return end
		local anchor = GetAnchor( anchors )
		if not anchor then return end
		--print("Anchor:"..event.." "..frame:GetName())
		frame:Point(unpack(anchor))
	end
	frame:RegisterEvent("PLAYER_TALENT_UPDATE")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:HookScript("OnEvent",SetAnchor)
end

-- Create a color array from one color
local function CreateColorArray( color, count )
	if not color or not count then return end
	local colors = { }
	for i = 1, count, 1 do
		tinsert( colors, color )
	end
	return colors
end

-- Return raid class color
local function GetRaidClassColor()
	local color = RAID_CLASS_COLORS[T.myclass]
	return { color.r, color.g, color.b, 1 }
end

-- Create bar/points/...
for i, section in ipairs(settings) do
	local name = section.name
	local kind = section.kind
	local anchors = section.anchors
	local anchor = section.anchor or GetAnchor(anchors)
	local width = section.width or 85
	local height = section.height or 15

	--Info("section:"..name)
	if name and kind and anchor then
		-- for AURA, POWER and COMBO, if colors doesn't exist create it using color for each entry
		-- if color doesn't exist, use RAID_CLASS_COLORS[T.myclass] -> convert in a list { r, g, b, 1 }
		local frame
		if ( kind == "RESOURCE" ) then
			local text = section.text or true
			local autohide = section.autohide or false
			local color = section.color or GetRaidClassColor()

			frame = CreateResourceMonitor(name, text, autohide, anchor, width, height, color) -- OPTIONAL  -- TODO: a color by resource
		elseif ( kind == "COMBO" ) then
			local spacing = section.spacing or 3
			local color = section.color or GetRaidClassColor()
			local colors = section.colors or CreateColorArray(color, 5)

			frame = CreateComboMonitor(name, anchor, width, height, spacing, colors, filled)
		elseif ( kind == "POWER" ) then
			local powerType = section.powerType
			local count = section.count
			local spacing = section.spacing or 3
			local color = section.color or GetRaidClassColor()
			local colors = section.colors or CreateColorArray(color, count)
			local filled = section.filled or false

			if powerType and count then
				frame = CreatePowerMonitor(name, powerType, count, anchor, width, height, spacing, colors, filled )
			else
				Warning("section:"..name..":"..(powerType and "" or " missing powerType")..(count and "" or " missing count"))
			end
		elseif ( kind == "AURA" ) then
			local spellID = section.spellID
			local filter = section.filter
			local count = section.count
			local spacing = section.spacing
			local color = section.color or GetRaidClassColor()
			local colors = section.colors or CreateColorArray(color, count)
			local filled = section.filled or false

			if spellID and filter and count then
				frame = CreateAuraMonitor(name, spellID, filter, count, anchor, width, height, spacing, colors, filled)
			else
				Warning("section:"..name..":"..(spellID and "" or " missing spellID")..(filter and "" or " missing filter")..(count and "" or " missing count"))
			end
		elseif ( kind == "RUNES" ) then
			local updatethreshold = section.updatethreshold or 0.1
			local autohide = section.autohide or false
			local orientation = section.orientation or "HORIZONTAL"
			local spacing = section.spacing or 3
			local colors = section.colors
			local runemap = section.runemap

			if runemap and colors then
				frame = CreateRunesMonitor(name, updatethreshold, autohide, orientation, anchor, width, height, spacing, colors, runemap)
			else
				Warning("section:"..name..":"..(runemap and "" or " missing runemap")..(colors and "" or " missing colors"))
			end
		elseif ( kind == "ECLIPSE" ) then
			-- TODO
			Warning("section:"..name..": Eclipse not yet implemented")
			-- local colors = section.colors

			-- if colors then
				-- frame = CreateEclipseMonitor(name, anchor, width, height, colors)
			-- else
				-- Warning("section:"..name..": missing colors")
			-- end
		else
			Warning("section:"..name..": invalid kind:"..kind)
		end

		-- Warning if frame not created
		if not frame then Warning("section:"..name.." frame not created") end-- DEBUG

		-- Add multiple anchor handler
		if anchors and frame then
			SetMultipleAnchorHandler(frame, anchors)
		end
	else
		Warning((name and "" or " missing name")..(kind and "" or " missing kind")..(anchor and "" or " missing anchor"))
	end
end