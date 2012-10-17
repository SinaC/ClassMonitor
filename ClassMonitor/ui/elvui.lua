local ADDON_NAME, Engine = ...
local L = Engine.Locales
local UI = Engine.UI

if Engine.Enabled then return end -- UI already found

if not ElvUI then return end -- ElvUI detected

Engine.Enabled = true -- ElvUI found

------------
--- ElvUI
------------
local E, _, _, P, _, _ = unpack(ElvUI)

UI.BorderColor = P.general.bordercolor
UI.NormTex = E["media"].normTex
UI.MyClass = E.myclass
UI.MyName = E.myname
UI.Font = E["media"].normFont
UI.BlankTex = E["media"].blankTex

-- Hider Secure (mostly used to hide stuff while in pet battle)  ripped from Tukui
local petBattleHider = CreateFrame("Frame", "ElvUIClassMonitorPetBattleHider", UIParent, "SecureHandlerStateTemplate")
petBattleHider:SetAllPoints(UIParent)
RegisterStateDriver(petBattleHider, "visibility", "[petbattle] hide; show")
UI.BattlerHider = petBattleHider

UI.SetFontString = function(parent, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:FontTemplate(nil, fontHeight, fontStyle)
	return fs
end

local function ConvertColor(color)
	return { color.r, color.g, color.b, color.a or 1 }
end

UI.ClassColor = function(className)
	local class = className or E.myclass
	local color = RAID_CLASS_COLORS[class]
	return ConvertColor(color)
end

UI.PowerColor = function(resourceName)
	local color = P.unitframe.colors.power[resourceName]
	if color then
		return ConvertColor(color)
	end
end

UI.HealthColor = function(unit)
	local color = {1, 1, 1, 1}
	if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		color = P.unitframe.colors.tapped
	elseif not UnitIsConnected(unit) then
		color = P.unitframe.colors.disconnected
	elseif UnitIsPlayer(unit) or (UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		color = RAID_CLASS_COLORS[E.myclass]
	elseif UnitReaction(unit, "player") then
		color = P.unitframe.colors.reaction[UnitReaction(unit, "player")]
	end
	return ConvertColor(color)
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
	-- TODO: call /moveui
	return true
end

-- Skin
local S = E:GetModule('Skins')

UI.SkinCheckBox = function(frame)
	S:HandleCheckBox(frame)
end

UI.SkinSlideBar = function(btn, horizonal)
	S:HandleSliderFrame(btn)
end

UI.SkinDropDownBox = function(frame, width)
	S:HandleDropDownBox(frame)
end

UI.SkinNextPrevButton = function(frame)
	S:HandleNextPrevButton(frame)
end

UI.SkinCloseButton = function(frame, point)
	S:HandleCloseButton(frame)
end

UI.SkinScrollBar = function(frame)
	S:HandleScrollBar(frame)
end