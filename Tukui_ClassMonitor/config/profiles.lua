local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

if T.myname == "Meuhhnon" then
	C["classmonitor"]["DRUID"][1].anchor = nil
	C["classmonitor"]["DRUID"][1].anchors = {
		{ "CENTER", UIParent, "CENTER", 0, -120 }, -- Balance
		{ "CENTER", UIParent, "CENTER", 0, -120 }, -- Feral
		{ "CENTER", UIParent, "CENTER", -500, 290 } -- Restoration
	}
elseif T.myname == "Enimouchet" then
	C["classmonitor"]["PALADIN"][1].anchor = nil
	C["classmonitor"]["PALADIN"][1].anchors = {
		{"CENTER", UIParent, "CENTER", -543, 290}, -- Holy
		{"CENTER", UIParent, "CENTER", -0, -100}, -- Protection
		{"CENTER", UIParent, "CENTER", -0, -100} -- Retribution
	}
end