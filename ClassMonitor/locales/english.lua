local ADDON_NAME, Engine = ...
local L = Engine.Locales

L.classmonitor_outdated = "Your version of "..tostring(ADDON_NAME).." is out of date. You can download the latest version from http://www.curse.com/addons/wow/classmonitor"
L.classmonitor_move = "Move class monitor"
L.classmonitor_disableoldversion_tukui = "Old version of Tukui_ClassMonitor detected. Disable it?"
L.classmonitor_disableoldversion_elvui = "Old version of ElvUI_ClassMonitor detected. Disable it?"
L.classmonitor_help_use = "Use %s or %s to configure ClassMonitor"
L.classmonitor_help_move = "%s move - move ClassMonitor frames"
L.classmonitor_help_config = "%s config - config ClassMonitor frames"
L.classmonitor_help_reset = "%s reset - reset ClassMonitor frames"
L.classmonitor_command_reset = "This will reset every modifications done to ClassMonitor config, a ReloadUI will also be performed. Are you sure?"
L.classmonitor_command_stopmoving = "Use %s move again to stop moving frames"
L.classmonitor_command_noconfigfound = "ClassMonitor_ConfigUI not found, enable it before trying to configure :)"
L.classmonitor_greetingwithconfig = "ClassMonitor version %s + ClassMonitor_ConfigUI version %s"
L.classmonitor_greetingnoconfig = "ClassMonitor version %s"