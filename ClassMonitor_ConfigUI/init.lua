local _, Engine = ...

Engine.Locales = {}
Engine.Definitions = {}
Engine.Globals = {} -- contains config, saved variables and plugin update func

ClassMonitor_ConfigUI = {} -- Expose methods for ClassMonitor

--[[
TODO:
	[DONE]test Tukui skin
	[DONE]saved variables
	[TO TEST]anchor
	colors
	add/delete new plugin instances
	[DONE]reload UI when modification are done
	global enable/disable in classmonitor root node
	description in classmonitor root node
	[DONE]global width/height
	[DONE]reload UI only when modification has been done and config panel closed
	[DONE]dont recreate options everytime config panel is opened
	add an option to create a new plugin instance + dropdown
	[DONE]add an option to reset to original config
	input on number get/set must handle string  (check validatenumber to find them)
--]]