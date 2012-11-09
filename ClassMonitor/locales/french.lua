local ADDON_NAME, Engine = ...
local L = Engine.Locales

if GetLocale() == "frFR" then
	L.classmonitor_outdated = "Une version plus r\195\169cente de "..tostring(ADDON_NAME).." est disponible. Vous pouvez t\195\169l\195\169charger la derni\195\168re version sur http://www.curse.com/addons/wow/classmonitor"
	L.classmonitor_move = "Bouger le monitoring de classe"
	L.classmonitor_disableoldversion_tukui = "Une ancienne version de Tukui_ClassMonitor a d\195\169tect\195\169. Voulez-vous la d\195\169sactiver?"
	L.classmonitor_disableoldversion_elvui = "Une ancienne version de ElvUI_ClassMonitor a d\195\169tect\195\169. Voulez-vous la d\195\169sactiver?"
	L.classmonitor_help_use = "Utilisez %s ou %s pour configurer ClassMonitor"
	L.classmonitor_help_move = "%s move - bouger les fen\195\170tres de ClassMonitor"
	L.classmonitor_help_config = "%s config - configurer les fen\195\170tres de ClassMonitor"
	L.classmonitor_help_reset = "%s reset - r\195\169initialiser les fen\195\170tres de ClassMonitor"
	L.classmonitor_command_reset = "Toutes les modifications effectu\195\169es vont \195\170tre supprim\195\169es, un ReloadUI sera \195\169galement effectu\195\169. Etes-vous certain?"
	L.classmonitor_command_stopmoving = "Utilisez %s move \195\160 nouveau pour arr\195\170ter de bouger les fen\195\170tres"
	L.classmonitor_command_noconfigfound = "|cFF148587ClassMonitor_ConfigUI|r pas trouv\195\169, activez le avant d'essayer de configurer :)"
	L.classmonitor_greetingwithconfig = "|cFF148587ClassMonitor|r version %s + |cFF148587ClassMonitor_ConfigUI|r version %s"
	L.classmonitor_greetingnoconfig = "|cFF148587ClassMonitor|r version %s"
end