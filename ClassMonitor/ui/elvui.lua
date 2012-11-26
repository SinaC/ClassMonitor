local ADDON_NAME, Engine = ...
local L = Engine.Locales
local UI = Engine.UI

if Engine.Enabled then return end -- UI already found

if not ElvUI then return end -- ElvUI detected

Engine.Enabled = true -- ElvUI found

------------
--- ElvUI
------------
--local E, _, _, P, _, _ = unpack(ElvUI)
local E = unpack(ElvUI)

local UF = E:GetModule("UnitFrames")

--UI.BorderColor = P.general.bordercolor
UI.BorderColor = E["media"].bordercolor
UI.NormTex = E["media"].normTex
UI.MyClass = E.myclass
UI.MyName = E.myname

-- Hider Secure (mostly used to hide stuff while in pet battle)  ripped from Tukui
local petBattleHider = CreateFrame("Frame", "ElvUIClassMonitorPetBattleHider", UIParent, "SecureHandlerStateTemplate")
petBattleHider:SetAllPoints(UIParent)
RegisterStateDriver(petBattleHider, "visibility", "[petbattle] hide; show")
UI.PetBattleHider = petBattleHider

UI.SetFontString = function(parent, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:FontTemplate(nil, fontHeight, fontStyle)
	return fs
end

-- local function ConvertColor(color)
	-- return { color.r, color.g, color.b, color.a or 1 }
-- end

UI.ClassColor = function(className)
	local class = className or E.myclass
	local color = RAID_CLASS_COLORS[class]
	--return ConvertColor(color)
	return E:GetColorTable(color)
end

UI.PowerColor = function(resourceName)
	local color = nil
	if type(resourceName) == "number" then
		if resourceName == SPELL_POWER_MANA then
			color = UF.db.colors.power.MANA
		elseif resourceName == SPELL_POWER_RAGE then
			color = UF.db.colors.power.RAGE
		elseif resourceName == SPELL_POWER_FOCUS then
			color = UF.db.colors.power.FOCUS
		elseif resourceName == SPELL_POWER_ENERGY then
			color = UF.db.colors.power.ENERGY
		--elseif resourceName == SPELL_POWER_RUNES then
		elseif resourceName == SPELL_POWER_RUNIC_POWER then
			color = UF.db.colors.power.RUNIC_POWER
		elseif resourceName == SPELL_POWER_SOUL_SHARDS then
			color = UF.db.colors.classResources.WARLOCK[1]
		--elseif resourceName == SPELL_POWER_ECLIPSE then
		elseif resourceName == SPELL_POWER_HOLY_POWER then
			color = UF.db.colors.holyPower
		--elseif resourceName == SPELL_POWER_LIGHT_FORCE then
		elseif resourceName == SPELL_POWER_SHADOW_ORBS then 
			color = UF.db.colors.classResources.PRIEST
		elseif resourceName == SPELL_POWER_BURNING_EMBERS then 
			color = UF.db.colors.classResources.WARLOCK[3]
		elseif resourceName == SPELL_POWER_DEMONIC_FURY then
			color = UF.db.colors.classResources.WARLOCK[2]
		end
	else
		color = UF.db.colors.power[resourceName]
	end
--print("resourceName:"..tostring(resourceName).."  "..tostring(color and color.r).."  "..tostring(color and color.g).."  "..tostring(color and color.b))
	--local color = E.db.unitframe.colors.power[resourceName]
	if color then
		--return ConvertColor(color)
		return E:GetColorTable(color)
	end
end

UI.HealthColor = function(unit)
	local color = {1, 1, 1, 1}
	if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		color = UF.db.colors.tapped
	elseif not UnitIsConnected(unit) then
		color = UF.db.colors.disconnected
	elseif UnitIsPlayer(unit) or (UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local class = select(2, UnitClass(unit)) or E.MyClass
		color = RAID_CLASS_COLORS[class]
	elseif UnitReaction(unit, "player") then
		local reaction = UnitReaction(unit, "player")
		if 1 == reaction or 2 == reaction or 3 == reaction then
			color = UF.db.colors.reaction.GOOD
		elseif 4 == reaction then
			color = UF.db.colors.reaction.NEUTRAL
		elseif 5 == reaction or 6 == reaction or 7 == reaction or 8 == reaction then
			color = UF.db.colors.reaction.BAD
		end
		--color = UF.db.colors.reaction[UnitReaction(unit, "player")]
	end
	--return ConvertColor(color)-- or {1,1,1,1})
	return E:GetColorTable(color)
end

UI.CreateMover = function(name, width, height, anchor, text)
	local holder = CreateFrame("Frame", name.."HOLDER", UIParent)
	holder:Size(width, height)
	holder:Point(unpack(anchor))

	E:CreateMover(holder, name, text, true)--snapOffset, postdrag, moverTypes)

	--return holder
	return E.CreatedMovers[name].mover -- we need the mover for multiple anchors
end

UI.Move = function()
	E:ToggleConfigMode() -- Call MoveUI from ElvUI
	return true
end