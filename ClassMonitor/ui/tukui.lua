local ADDON_NAME, Engine = ...
local L = Engine.Locales
local UI = Engine.UI

if Engine.Enabled then return end -- UI already found

if not Tukui then return end -- no Tukui detected

Engine.Enabled = true -- Tukui found

------------
--- Tukui
------------
local T, C, _ = unpack(Tukui)

UI.BorderColor = C.general.bordercolor
UI.PetBattleHider = TukuiPetBattleHider
UI.NormTex = C["media"].normTex
UI.MyClass = T.myclass
UI.MyName = T.myname

UI.SetFontString = function(parent, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(C["media"]["uffont"], fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(1.25, -1.25)
	return fs
end

UI.ClassColor = function(className)
	return className and T.UnitColor.class[className] or T.UnitColor.class[T.myclass]
end

UI.PowerColor = function(resourceName)
	return T.UnitColor.power[resourceName]
end

UI.HealthColor = function(unit)
	local color = {1, 1, 1, 1}
	if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		color = T.UnitColor.tapped
	elseif not UnitIsConnected(unit) then
		color = T.UnitColor.disconnected
	elseif UnitIsPlayer(unit) or (UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local class = select(2, UnitClass(unit))
		color = T.UnitColor.class[class]
	elseif UnitReaction(unit, "player") then
		color = T.UnitColor.reaction[UnitReaction(unit, "player")]
	end
	return color
end

UI.CreateMover = function(name, width, height, anchor, text)
	local mover = CreateFrame("Frame", name, UIParent)
	mover:SetTemplate()
	mover:SetBackdropBorderColor(1, 0, 0, 1)
	mover:SetFrameStrata("HIGH")
	mover:SetMovable(true)
	mover:Size(width, height)
	mover:Point(unpack(anchor))

	mover.text = T.SetFontString(mover, C["media"]["uffont"], 12)
	mover.text:SetPoint("CENTER")
	mover.text:SetText(text)
	mover.text.Show = function() mover:Show() end
	mover.text.Hide = function() mover:Hide() end
	mover:Hide()

	tinsert(T.AllowFrameMoving, mover)

	return mover
end

UI.Move = function()
	if SlashCmdList["MOVING"] then
		SlashCmdList["MOVING"]()
	end
	-- T.MoveUIElements()
	-- if T.MoveUnitFrames then
		-- T.MoveUnitFrames()
	-- end
	return true
end