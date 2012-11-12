local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

local C = Engine.Config
local UI = Engine.UI

local PixelPerfect = Engine.PixelPerfect

-- TEST MODULE ONLY FOR MY CHARS
--if UI.MyName ~= "Meuhhnon" and UI.MyName ~= "Sushiouaha" then return end
--if not Engine.IsPTR() then return end
--
--print("TESTING AUTO GRID ANCHOR")

--[[
frames (* = master anchor)
	[A        -2,0         ]
	[B    -1,0 ][   -1,1  C]
	[D*    1,0 ][   1,0   E]
	[F  2,0][G  2,1][H  2,2]
	[I         3,0         ]
list generated:
	[-2] = { min = 0, max = 0, count = 1, list = {[0] = {A}}}
	[-1] = { min = 0, max = 1, count = 2, list = {[0] = {B}, [1] = {C}}}
	[1] = { min = 0, max = 0, count = 2, list = {[0] = {D, E}}}
	[2] = { min = 0, max = 2, count = 3, list = {[0] = {F}, [1] = {G}, [2] = {H}}}
	[3] = { min = 0, max = 0, count = 1, list = {[0] = {I}}}

	master anchor is the lower positive vertical index if possible, highest negative otherwise
	["autoGridAnchorKey"], ["autoGridWidthKey"] and ["autoGridHeightKey"] are added to settings if they don't exist
--]]
Engine.AutoGridAnchor = function(settings, globalWidth, globalHeight, verticalSpacing, autoGridAnchorKey, autoGridWidthKey, autoGridHeightKey)
print("AUTO GRID ANCHORING...")
	-- build temporary list used to reorder frames + set default indices + get lower/upper bounds
	local vMin = 100
	local vMax = -100
	local list = {}
	local index = 0
	local master = nil
	for _, setting in pairs(settings) do
		if setting.kind ~= "MOVER" and setting.enable == true then
			-- set default indices + get lower/upper bounds
			setting.verticalIndex = setting.verticalIndex or index
			setting.horizontalIndex = setting.horizontalIndex or 0
			if setting.verticalIndex < vMin then vMin = setting.verticalIndex end
			if setting.verticalIndex > vMax then vMax = setting.verticalIndex end
			index = index + 1
--print("SETTING: "..tostring(setting.name).."  "..tostring(setting.verticalIndex).."  "..tostring(setting.horizontalIndex).."  "..tostring(master and master.name or "NO MASTER"))
			-- check if master
			if not master then
				master = setting
			else
				-- master is lowest positive vertical index or highest negative vertical index if no positive vertical index
				-- if 2 or more identical vertical index, master is the lowest horizontal index
				if master.verticalIndex == setting.verticalIndex then
					if setting.horizontalIndex < master.horizontalIndex then
						master = setting
					end
				elseif master.verticalIndex < 0 then
					if setting.verticalIndex < 0 and setting.verticalIndex > master.verticalIndex then
						master = setting
					elseif setting.verticalIndex > 0 then
						master = setting
					end
				else
					if setting.verticalIndex > 0 and setting.verticalIndex < master.verticalIndex then
						master = setting
					end
				end
			end
			-- add setting to list
			list[setting.verticalIndex] = list[setting.verticalIndex] or {hMin = 9, hMax = 0, count = 0, list = {}}
			local vEntry = list[setting.verticalIndex]
			if setting.horizontalIndex < vEntry.hMin then vEntry.hMin = setting.horizontalIndex end
			if setting.horizontalIndex > vEntry.hMax then vEntry.hMax = setting.horizontalIndex end
			vEntry.count = vEntry.count + 1
			vEntry.list[setting.horizontalIndex] = vEntry.list[setting.horizontalIndex] or {}
			tinsert(vEntry.list[setting.horizontalIndex], setting)
--print("INSERTING "..tostring(setting.name).."  "..tostring(setting.verticalIndex).."  "..tostring(setting.horizontalIndex))
		end
	end

	if index == 0 then return end -- no valid plugin found

	assert(master and index ~= 0, "No master found. Impossible to perform auto-anchor")

	-- 0 -> vMin step -1
	do
		local lastAnchor = master
		for v = 0, vMin, -1 do
			local vEntry = list[v]
			if vEntry then -- may have gaps
				local count = vEntry.count
				local width, spacing = PixelPerfect(globalWidth, count)
				local firstInLine = nil -- last anchor will be set to first in line
				local previousAnchor = lastAnchor -- horizontal anchoring
				for h = vEntry.hMin, vEntry.hMax do
					local hEntry = vEntry.list[h]
					if hEntry then -- may have gaps
						for _, setting in pairs(hEntry) do
							setting[autoGridWidthKey] = width -- new width
							setting[autoGridHeightKey] = globalHeight -- same height for each plugin
							if setting ~= master then -- master is not re-anchored
								if previousAnchor ~= lastAnchor then -- not the first of the line
									setting[autoGridAnchorKey] = {"TOPLEFT", previousAnchor.name, "TOPRIGHT", spacing, 0} -- horizontal anchoring
								else
									setting[autoGridAnchorKey] = {"BOTTOMLEFT", previousAnchor.name, "TOPLEFT", 0, verticalSpacing} -- vertical anchoring
								end
							end
							if not firstInLine then firstInLine = setting end -- save first of line
							previousAnchor = setting
						end
					end
				end
				lastAnchor = firstInLine -- -- next line will be anchored to first of previous line
			end
		end
	end

	-- 0 -> vMax step +1
	do
		local lastAnchor = master -- new line are anchored to first of previous line
		for v = 0, vMax, 1 do
			local vEntry = list[v]
			if vEntry then -- may have gaps
				local count = vEntry.count
				local width, spacing = PixelPerfect(globalWidth, count)
				local firstInLine = nil -- last anchor will be set to first in line
				local previousAnchor = lastAnchor -- horizontal anchoring
				for h = vEntry.hMin, vEntry.hMax do
					local hEntry = vEntry.list[h]
					if hEntry then -- may have gaps
						for _, setting in pairs(hEntry) do
							setting[autoGridWidthKey] = width -- new width
							setting[autoGridHeightKey] = globalHeight -- same height for each plugin
							if setting ~= master then -- master is not re-anchored
								if previousAnchor ~= lastAnchor then -- not the first of the line
									setting[autoGridAnchorKey] = {"TOPLEFT", previousAnchor.name, "TOPRIGHT", spacing, 0} -- horizontal anchoring
								else
									setting[autoGridAnchorKey] = {"TOPLEFT", previousAnchor.name, "BOTTOMLEFT", 0, -verticalSpacing} -- vertical anchoring
								end
							end
							if not firstInLine then firstInLine = setting end -- save first of line
							previousAnchor = setting
						end
					end
				end
				lastAnchor = firstInLine -- next line will be anchored to first of previous line
			end
		end
	end

--[[
	-- DUMP
	print("MIN: "..tostring(vMin).."  MAX: "..tostring(vMax).."  master: "..tostring(master and master.name or ""))
	for v = vMin, vMax do
		local vEntry = list[v]
		if vEntry then -- may have gaps
			print("["..tostring(v).."] = {min="..tostring(vEntry.hMin)..",max="..tostring(vEntry.hMax)..",count="..tostring(vEntry.count)..", list={")
			for h = vEntry.hMin, vEntry.hMax do
				print(" ["..tostring(h).."] = {")
				local hEntry = vEntry.list[h]
				if hEntry then -- may have gaps
					for _, setting in pairs(hEntry) do
						print("  "..tostring(setting.name).." w:"..tostring(setting.autowidth or setting.width).." a:"..tostring(setting[autoGridAnchorKey] and setting[autoGridAnchorKey][1])..","..tostring(setting[autoGridAnchorKey] and setting[autoGridAnchorKey][2])..","..tostring(setting[autoGridAnchorKey] and setting[autoGridAnchorKey][3])..","..tostring(setting[autoGridAnchorKey] and setting[autoGridAnchorKey][4])..","..tostring(setting[autoGridAnchorKey] and setting[autoGridAnchorKey][5]))
					end
				end
				print("}")
			end
			print("}}")
		end
	end
--]]

	if Engine.UpdateAllPlugins and type(Engine.UpdateAllPlugins) == "function" then
		Engine.UpdateAllPlugins()
	end

	-- clean up
	wipe(list)
end


--[[
local settings = {
	{ name = "A", enable = true, verticalIndex = -2, horizontalIndex = 0 },
	{ name = "B", enable = true, verticalIndex = -1, horizontalIndex = 0 },
	{ name = "C", enable = true, verticalIndex = -1, horizontalIndex = 1 },
	{ name = "D", enable = true, verticalIndex = 1, horizontalIndex = 0 },
	{ name = "E", enable = true, verticalIndex = 1, horizontalIndex = 0 },
	{ name = "F", enable = true, verticalIndex = 2, horizontalIndex = 0 },
	{ name = "G", enable = true, verticalIndex = 2, horizontalIndex = 1 },
	{ name = "H", enable = true, verticalIndex = 2, horizontalIndex = 2 },
	{ name = "I", enable = true, verticalIndex = 3, horizontalIndex = 0 },
}

Engine.AutoGridAnchor(settings, 300, 3, "autoanchor", "autowidth")
--]]