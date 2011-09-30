local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

----------------------------------------------------------------------------
-- Per Class Config (overwrite general)
-- Class need to be UPPERCASE
----------------------------------------------------------------------------

if T.myclass == "DRUID" then
	CMOptions.combo.enable = true
	CMOptions.power.enable = true
	--CMOptions.eclipse.enable = true

	-- CMOptions.power.visibility = {
		-- events = { "UPDATE_SHAPESHIFT_FORM", "PLAYER_ENTERING_WORLD" }, 
		-- func = function( self, ... )
			-- local form = GetShapeshiftFormID()
			-- if form and ( form == 4 --[[ Aquatic Form --]] or form == 3 --[[ Travel Form --]] or form == 27 --[[ Swift Flight Form --]] or form == 29 --[[ Flight Form --]] ) then
				-- self:Hide()
			-- else
				-- self:Show()
			-- end
		-- end)
	-- }
end

if T.myclass == "ROGUE" then
	CMOptions.combo.enable = true
	CMOptions.power.enable = true
end

if T.myclass == "PALADIN" then
	CMOptions.holy.enable = true
	CMOptions.power.enable = true
	CMOptions.power.width = T.Scale(261)
	CMOptions.power.anchor = {"CENTER", UIParent, "CENTER", -1, -123}
end

if T.myclass == "WARLOCK" then
	CMOptions.soul.enable = true
	CMOptions.power.enable = true
	CMOptions.power.width = T.Scale(261)
	CMOptions.power.anchor = {"CENTER", UIParent, "CENTER", 0, -123}
end

if T.myclass == "PRIEST" then
	CMOptions.orbs.enable = true
	CMOptions.power.enable = true
	CMOptions.power.width = T.Scale(261)
end

if T.myclass == "WARRIOR" then
	CMOptions.power.enable = true
end

if T.myclass == "SHAMAN" then
	CMOptions.power.enable = true
end

if T.myclass == "DEATHKNIGHT" then
	CMOptions.runes.enable = true
	CMOptions.power.enable = true
	CMOptions.power.width = T.Scale(261)
end

if T.myclass == "HUNTER" then
	CMOptions.rsa.enable = true
	CMOptions.power.enable = true
end

if T.myclass == "MAGE" then
	CMOptions.arcane.enable = true
	CMOptions.power.enable = true
	CMOptions.power.width = T.Scale(261)
	CMOptions.power.anchor = {"CENTER", UIParent, "CENTER", -1, -123}
end

----------------------------------------------------------------------------
-- Per Character Name Config (overwrite general and class)
-- Name need to be case sensitive
----------------------------------------------------------------------------

if T.myname == "Enimouchet" then
	CMOptions.holy.anchors = { 
		{"CENTER", UIParent, "CENTER", -630, 190}, -- Holy
		{"CENTER", UIParent, "CENTER", -87, -100}, -- Protection
		{"CENTER", UIParent, "CENTER", -87, -100} -- Retribution
	}
	CMOptions.power.anchors = { 
		{"CENTER", UIParent, "CENTER", -543, 172}, -- Holy
		{"CENTER", UIParent, "CENTER", 0, -123}, -- Protection
		{"CENTER", UIParent, "CENTER", 0, -123} -- Retribution
	}
end

if T.myname == "Meuhhnon" then
	CMOptions.power.anchors = { 
		{"CENTER", UIParent, "CENTER", 0, -123}, -- Balance
		{"CENTER", UIParent, "CENTER", 0, -123}, -- Feral
		{"CENTER", UIParent, "CENTER", -500, 290} -- Restoration
	}
end