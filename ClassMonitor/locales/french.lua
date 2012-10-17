local ADDON_NAME, Engine = ...
local L = Engine.Locales

if GetLocale() == "frFR" then
	L.classmonitor_move = "Bouger le monitoring de classe"
	L.classmonitor_disableoldversion_tukui = "Une ancienne version de Tukui_ClassMonitor a d\195\169tect\195\169. Voulez-vous la d\195\169sactiver?"
	L.classmonitor_disableoldversion_elvui = "Une ancienne version de ElvUI_ClassMonitor a d\195\169tect\195\169. Voulez-vous la d\195\169sactiver?"
	L.classmonitor_help_use = "Utilisez %s or %s pour configurer ClassMonitor"
	L.classmonitor_help_move = "%s move - bouger les fen\195\170tres de ClassMonitor"
	L.classmonitor_help_config = "%s config - configurer les fen\195\170tres de ClassMonitor"
	L.classmonitor_command_stopmoving = "Utilisez %s move \195\160 nouveau pour arr\195\170ter de bouger les fen\195\170tres"
	L.classmonitor_command_noconfigfound = "ClassMonitor_ConfigUI pas trouv\195\169, activer le avant d'essayer de configurer :)"
	L.classmonitor_greetingwithconfig = "ClassMonitor version %s + ClassMonitor_ConfigUI version %s"
	L.classmonitor_greetingnoconfig = "ClassMonitor version %s"
end