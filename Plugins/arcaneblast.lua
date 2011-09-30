-- Arcane Blast plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local O = CMOptions["arcane"]
if O.enable ~= true then return end

CreateAuraMonitor( 36032, "HARMFUL", 4, O )
