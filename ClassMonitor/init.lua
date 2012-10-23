local ADDON_NAME, Engine = ...

Engine.Locales = {}
Engine.UI = {}

-- if IsAddOnLoaded("ClassMonitor_ConfigUI") then
-- --print("ClassMonitor_ConfigUI loaded")
	-- ClassMonitorUI = Engine.UI -- Makes UI accessible by ClassMonitor_ConfigUI
-- end

-- TODO
-- [DONE]split Tukui/ElvUI/Blizzard code
-- /clm reset
-- [DONE]paladin holy power a few pixel of mana
-- [DONE]warlock embers a few pixel of mana
-- [DONE]unit option on AURA
-- disable old version Tukui_ClassMonitor and Tukui_ElvUI_ClassMonitor on ADDON_LOADED or PLAYER ENTERING_WORLD
-- [DONE]move UI functions to Engine.UI or Private instead of Engine
-- [DONE]autohide on each plugin
-- optimize saved variables by removing entry equals to config one
-- [TO TEST]call /moveui in tukui and elvui
-- [DONE]pixel perfect method callable by config (build a list with ideal width for 1->n bars/points and 1->n-1 spacing)
-- [TO TEST]new power kind: SPELL_POWER_BURNING_EMBERS and SPELL_POWER_DEMONIC_FURY, not included anymore in "POWER"