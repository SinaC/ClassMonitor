-- Arcane Blast plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local O = CMOptions["arcane"]
if O.enable ~= true then return end

CreateAuraTracker( 36032, "HARMFUL", 4, O.anchor, O.color, O.width, O.height, O.spacing )
