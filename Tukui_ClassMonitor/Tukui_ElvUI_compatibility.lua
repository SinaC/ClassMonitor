local ADDON_NAME, Engine = ...
local L = Engine.Locales

Engine.Enabled = false -- true if Tukui or ElvUI found, false otherwise

-- Variables
Engine.BorderColor = nil
Engine.BattlerHider = nil
Engine.NormTex = nil
Engine.MyClass = nil

-- Functions
--Engine.SetFontString(parent, fontHeight, fontStyle)
--Engine.ClassColor()
--Engine.PowerColor(resourceName)
--Engine.CreateMover(name, width, height, anchor, text)

if Tukui then
------------
--- Tukui
------------
	local T, C, _ = unpack(Tukui)
	Engine.Enabled = true
	Engine.BorderColor = C.general.bordercolor
	Engine.BattlerHider = TukuiPetBattleHider
	Engine.NormTex = C["media"].normTex
	Engine.MyClass = T.myclass

	-- function Engine:SetFontString(parent, fontHeight, fontStyle)
		-- local fs = parent:CreateFontString(nil, "OVERLAY")
		-- fs:SetFont(C["media"]["uffont"], fontHeight, fontStyle)
		-- fs:SetJustifyH("LEFT")
		-- fs:SetShadowColor(0, 0, 0)
		-- fs:SetShadowOffset(1.25, -1.25)
		-- return fs
	-- end
	Engine.SetFontString = function(parent, fontHeight, fontStyle)
		local fs = parent:CreateFontString(nil, "OVERLAY")
		fs:SetFont(C["media"]["uffont"], fontHeight, fontStyle)
		fs:SetJustifyH("LEFT")
		fs:SetShadowColor(0, 0, 0)
		fs:SetShadowOffset(1.25, -1.25)
		return fs
	end

	Engine.ClassColor = function()
		return T.UnitColor.class[T.myclass]
	end

	Engine.PowerColor = function(resourceName)
		return T.UnitColor.power[resourceName]
	end

	-- function Engine:CreateMover(name, width, height, anchor, text)
		-- local mover = CreateFrame("Frame", name, UIParent)
		-- mover:SetTemplate()
		-- mover:SetBackdropBorderColor(1, 0, 0, 1)
		-- mover:SetFrameStrata("HIGH")
		-- mover:SetMovable(true)
		-- mover:Size(width, height)
		-- mover:Point(unpack(anchor))

		-- mover.text = T.SetFontString(mover, C["media"]["uffont"], 12)
		-- mover.text:SetPoint("CENTER")
		-- mover.text:SetText(text)
		-- mover.text.Show = function() mover:Show() end
		-- mover.text.Hide = function() mover:Hide() end
		-- mover:Hide()

		-- tinsert(T.AllowFrameMoving, mover)

		-- return mover
	-- end
	Engine.CreateMover = function(name, width, height, anchor, text)
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

	-- check old version
	local oldVersion = select(4, GetAddOnInfo("Tukui_ClassMonitor"))
	if oldVersion then
		T.CreatePopup["CLASSMONITOR_DISABLEOLDVERSION"] = {
			question = L.classmonitor_disableoldversion_tukui,
			answer1 = ACCEPT,
			answer2 = CANCEL,
			function1 = function()
				DisableAddOn("Tukui_ClassMonitor")
				ReloadUI()
			end,
		}
		T.ShowPopup("CLASSMONITOR_DISABLEOLDVERSION")
	end
elseif ElvUI then
------------
--- ElvUI
------------
	local E, _, _, P, _, _ = unpack(ElvUI)
	Engine.Enabled = true
	Engine.BorderColor = P.general.bordercolor
	Engine.NormTex = E["media"].normTex
	Engine.MyClass = E.myclass

	-- Hider Secure (mostly used to hide stuff while in pet battle)  ripped from Tukui
	local petBattleHider = CreateFrame("Frame", "ElvUIClassMonitorPetBattleHider", UIParent, "SecureHandlerStateTemplate")
	petBattleHider:SetAllPoints(UIParent)
	RegisterStateDriver(petBattleHider, "visibility", "[petbattle] hide; show")
	Engine.BattlerHider = petBattleHider

	-- function Engine:SetFontString(parent, fontHeight, fontStyle)
		-- local fs = parent:CreateFontString(nil, "OVERLAY")
		-- fs:FontTemplate(nil, fontHeight, fontStyle)
		-- return fs
	-- end
	Engine.SetFontString = function(parent, fontHeight, fontStyle)
		local fs = parent:CreateFontString(nil, "OVERLAY")
		fs:FontTemplate(nil, fontHeight, fontStyle)
		return fs
	end

	-- function Engine:ClassColor()
		-- local color = RAID_CLASS_COLORS[E.myclass]
		-- return { color.r, color.g, color.b, color.a or 1 }
	-- end
	Engine.ClassColor = function()
		local color = RAID_CLASS_COLORS[E.myclass]
		return { color.r, color.g, color.b, color.a or 1 }
	end

	-- function Engine:PowerColor(resourceName)
		-- local color = P["unitframe"]["colors"]["power"][resourceName]
		-- if color then
			-- return { color.r, color.g, color.b, color.a or 1 }
		-- end
	-- end
	Engine.PowerColor = function(resourceName)
		local color = P["unitframe"]["colors"]["power"][resourceName]
		if color then
			return { color.r, color.g, color.b, color.a or 1 }
		end
	end

	-- function Engine:CreateMover(name, width, height, anchor, text)
		-- local holder = CreateFrame("Frame", nil, UIParent)
		-- holder:Size(width, height)
		-- holder:Point(unpack(anchor))

		-- E:CreateMover(holder, name, text, true)--snapOffset, postdrag, moverTypes)

		-- return holder
	-- end
	Engine.CreateMover = function(name, width, height, anchor, text)
		local holder = CreateFrame("Frame", nil, UIParent)
		holder:Size(width, height)
		holder:Point(unpack(anchor))

		E:CreateMover(holder, name, text, true)--snapOffset, postdrag, moverTypes)

		return holder
	end

	-- check old version
else
	assert(false, ADDON_NAME.." was unable to locate Tukui or ElvUI install.")
end
