-- Ready, Set, Aim... plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local O = CMOptions["rsa"]
if O.enable ~= true then return end

CreateAuraMonitor( 82925, "HARMFUL", 5, O )
