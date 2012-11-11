local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

local C = Engine.Config
local UI = Engine.UI

local PixelPerfect = Engine.PixelPerfect

--[[
frames (* = master anchor)
	 [A        -2,0         ]
	 [B    -1,0 ][   -1,1  C]
	*[D     1,0 ][   1,0   E]
	 [F  2,0][G  2,1][H  2,2]
	 [I         3,0         ]
list:
	[-2] = { min = 0, max = 0, count = 1, list = {[0] = {A}}}
	[-1] = { min = 0, max = 1, count = 2, list = {[0] = {B}, [1] = {C}}}
	[1] = { min = 0, max = 0, count = 2, list = {[0] = {D, E}}}
	[2] = { min = 0, max = 2, count = 3, list = {[0] = {F}, [1] = {G}, [2] = {H}}}
	[3] = { min = 0, max = 0, count = 1, list = {[0] = {I}}}

	master anchor is the lower positive vertical index if possible, highest negative otherwise
	autoWidth and autoAnchor are added to settings
--]]
local function AutoAnchor(settings, globalWidth, verticalSpacing)
	-- build temporary list used to reorder frames + set default indices + get lower/upper bounds
	local vMin = 100
	local vMax = -100
	local list = {}
	local index = 0
	local master = nil
	for _, section in ipairs(settings) do
		if section.kind ~= "MOVER" and section.enable == true then
			-- set default indices + get lower/upper bounds
			section.verticalIndex = section.verticalIndex or index
			section.horizontalIndex = section.horizontalIndex or 0
			if section.verticalIndex < vMin then vMin = section.verticalIndex end
			if section.verticalIndex > vMax then vMax = section.verticalIndex end
			index = index + 1
			-- check if master
			if not master then
				master = section
			else
				-- if master index == section index
				--		if master horizontal index > section horizontal index, master = section
				-- elseif master index is negative
				--		if section index is negative and > master index, master = section
				--		elseif section index is positive, master = section
				-- else
				--		if section index is positive and < master index, master = section
				if master.verticalIndex == section.verticalIndex then
					if section.horizontalIndex < master.horizontalIndex then
						master = section
					end
				elseif master.verticalIndex < 0 then
					if section.verticalIndex < 0 and section.verticalIndex > master.verticalIndex then
						master = section
					elseif section.verticalIndex > 0 then
						master = section
					end
				else
					if section.verticalIndex > 0 and section.verticalIndex < master.verticalIndex then
						master = section
					end
				end
			end
			-- add frame to list
			list[section.verticalIndex] = list[section.verticalIndex] or {hMin = 9, hMax = 0, count = 0, list = {}}
			local vEntry = list[section.verticalIndex]
			if section.horizontalIndex < vEntry.hMin then vEntry.hMin = section.horizontalIndex end
			if section.horizontalIndex > vEntry.hMax then vEntry.hMax = section.horizontalIndex end
			vEntry.count = vEntry.count + 1
			vEntry.list[section.horizontalIndex] = vEntry.list[section.horizontalIndex] or {}
			tinsert(vEntry.list[section.horizontalIndex], section)
		end
	end

	assert(master, "No master found. Impossible to perform auto-anchor")

	-- 0 -> vMin step -1
	do
		local lastAnchor = master
		for v = 0, vMin, -1 do
			local vEntry = list[v]
			if vEntry then
				local count = vEntry.count
				local width, spacing = PixelPerfect(globalWidth, count)
				local firstInLine = nil -- last anchor will be set to first in line
				local previousAnchor = lastAnchor -- horizontal anchoring
				for h = vEntry.hMin, vEntry.hMax do
					local hEntry = vEntry.list[h]
					for _, section in pairs(hEntry) do
						section.autowidth = width
						if section ~= master then
							if previousAnchor ~= lastAnchor then
								section.autoanchor = {"TOPLEFT", previousAnchor.name, "TOPRIGHT", spacing, 0} -- horizontal anchoring
							else
								section.autoanchor = {"BOTTOMLEFT", previousAnchor.name, "TOPLEFT", 0, verticalSpacing} -- vertical anchoring
							end
						end
						if not firstInLine then firstInLine = section end
						previousAnchor = section
					end
				end
				lastAnchor = firstInLine
			end
		end
	end

	-- 0 -> vMax step +1
	do
		local lastAnchor = master
		for v = 0, vMax, 1 do
			local vEntry = list[v]
			if vEntry then
				local count = vEntry.count
				local width, spacing = PixelPerfect(globalWidth, count)
				local firstInLine = nil -- last anchor will be set to first in line
				local previousAnchor = lastAnchor -- horizontal anchoring
				for h = vEntry.hMin, vEntry.hMax do
					local hEntry = vEntry.list[h]
					for _, section in pairs(hEntry) do
						section.autowidth = width
						if section ~= master then
							if previousAnchor ~= lastAnchor then
								section.autoanchor = {"TOPLEFT", previousAnchor.name, "TOPRIGHT", spacing, 0} -- horizontal anchoring
							else
								section.autoanchor = {"TOPLEFT", previousAnchor.name, "BOTTOMLEFT", 0, -verticalSpacing} -- vertical anchoring
							end
						end
						if not firstInLine then firstInLine = section end
						previousAnchor = section
					end
				end
				lastAnchor = firstInLine
			end
		end
	end

--[[
	-- DUMP
	print("MIN: "..tostring(vMin).."  MAX: "..tostring(vMax).."  master: "..tostring(master and master.name or ""))
	for v = vMin, vMax do
		local vEntry = list[v]
		if vEntry then
			print("["..tostring(v).."] = {min="..tostring(vEntry.hMin)..",max="..tostring(vEntry.hMax)..",count="..tostring(vEntry.count)..", list={")
			for h = vEntry.hMin, vEntry.hMax do
				print(" ["..tostring(h).."] = {")
				local hEntry = vEntry.list[h]
				for _, section in pairs(hEntry) do
					print("  "..tostring(section.name).." w:"..tostring(section.autowidth or section.width).." a:"..tostring(section.autoanchor and section.autoanchor[1])..","..tostring(section.autoanchor and section.autoanchor[2])..","..tostring(section.autoanchor and section.autoanchor[3])..","..tostring(section.autoanchor and section.autoanchor[4])..","..tostring(section.autoanchor and section.autoanchor[5]))
				end
				print("}")
			end
			print("}}")
		end
	end
--]]

	-- clean up
	wipe(list)
end


-------------------------------------------------------------
--local settings = C[UI.MyClass]

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

AutoAnchor(settings, 300, 3)