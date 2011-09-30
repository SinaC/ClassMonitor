-- Shadow Orbs plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local O = CMOptions["orbs"]
if O.enable ~= true then return end

CreateAuraMonitor( 77487, "HELPFUL", 3, O )
