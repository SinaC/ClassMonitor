local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

if T.myname == "Meuhhnon" then
	C["classmonitor"]["DRUID"][1].anchor = nil -- RESOURCE
	C["classmonitor"]["DRUID"][1].anchors = {
		{ "CENTER", UIParent, "CENTER", 0, -140 }, -- Balance
		{ "CENTER", UIParent, "CENTER", 0, -140 }, -- Feral
		--{ "CENTER", UIParent, "CENTER", -500, 290 } -- Restoration
		{ "CENTER", UIParent, "CENTER", 0, -140 } -- Restoration
	}
elseif T.myname == "Enimouchet" then
	C["classmonitor"]["PALADIN"][1].anchor = nil -- RESOURCE
	C["classmonitor"]["PALADIN"][1].anchors = {
		{"CENTER", UIParent, "CENTER", -543, 290}, -- Holy
		{"CENTER", UIParent, "CENTER", -0, -100}, -- Protection
		{"CENTER", UIParent, "CENTER", -0, -100} -- Retribution
	}
end