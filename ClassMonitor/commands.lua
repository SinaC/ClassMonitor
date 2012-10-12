local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

local UI = Engine.UI
local L = Engine.Locales
local C = Engine.Config[UI.MyClass]

SLASH_CLASSMONITOR1 = "/clm"
SLASH_CLASSMONITOR2 = "/classmonitor"

local function SlashHandlerShowHelp()
	print(string.format(L.classmonitor_help_use, SLASH_CLASSMONITOR1, SLASH_CLASSMONITOR2))
	print(string.format(L.classmonitor_help_move, SLASH_CLASSMONITOR1))
	print(string.format(L.classmonitor_help_config, SLASH_CLASSMONITOR1))
end

local function SlashHandlerMove(args)
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	local enable = UI.Move()
	if not enable then
		print(string.format(L.classmonitor_command_stopmoving, SLASH_CLASSMONITOR1))
	end
end

local function SlashHandlerConfig(args)
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	if ClassMonitor_ConfigUI and ClassMonitor_ConfigUI.DisplayConfigFrame then
		ClassMonitor_ConfigUI:DisplayConfigFrame(C)
	else
		print(L.classmonitor_command_noconfigfound)
	end
end

SlashCmdList["CLASSMONITOR"] = function(cmd)
	local switch = cmd:match("([^ ]+)")
	local args = cmd:match("[^ ]+ (.+)")
	if switch == "move" then
		SlashHandlerMove(args)
	elseif switch == "config" then
		SlashHandlerConfig(args)
	else
		SlashHandlerShowHelp()
	end
end