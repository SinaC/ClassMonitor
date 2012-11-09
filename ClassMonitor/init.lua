local ADDON_NAME, Engine = ...

Engine.Locales = {}
Engine.UI = {}

-- if IsAddOnLoaded("ClassMonitor_ConfigUI") then
-- --print("ClassMonitor_ConfigUI loaded")
	-- ClassMonitorUI = Engine.UI -- Makes UI accessible by ClassMonitor_ConfigUI
-- end

-- TODO
-- [DONE]split Tukui/ElvUI/Blizzard code
-- [DONE]/clm reset
-- [DONE]paladin holy power a few pixel of mana
-- [DONE]warlock embers a few pixel of mana
-- [DONE]unit option on AURA
-- disable old version Tukui_ClassMonitor and Tukui_ElvUI_ClassMonitor on ADDON_LOADED or PLAYER ENTERING_WORLD
-- [DONE]move UI functions to Engine.UI or Private instead of Engine
-- [DONE]autohide on each plugin
-- [REMOVED]optimize saved variables by removing entry equals to config one
-- [DONE]call /moveui in tukui and elvui when using /clm move
-- [DONE]pixel perfect method callable by config (build a list with ideal width for 1->n bars/points and 1->n-1 spacing)
-- [DONE]new power kind: SPELL_POWER_BURNING_EMBERS and SPELL_POWER_DEMONIC_FURY, not included anymore in "POWER"
-- [DONE]split each plugin into visibility update and value update
-- [DONE]for plugin with points, add a frame including every point frames, this frame will be set by visibility updater and will be used as mover/config placeholder
-- [DONE] addon message to detect new version
-- update treshold for every plugin with update (0.1->0.5 step 0.1)
-- smoothShow: use UIFrameFadeIn & UIFrameFadeOut instead of :Show  :Hide   check runes plugin
-- RegisterEvent(..., UpdateValue) only when frame is shown    check banditsguile plugin
-- colors
-- free anchors (one mover for each plugin)
-- auto anchors (based on index in config, index 0 is on mover, -1 above, +1 below, ...) (if 2 with the same index, they are put on the same line
