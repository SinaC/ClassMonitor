local _, Engine = ...

Engine.Locales = {}
Engine.Definitions = {}
Engine.Globals = {} -- contains config, saved variables and plugin update func

ClassMonitor_ConfigUI = {} -- Expose methods for ClassMonitor

--[[
TODO:
	[DONE]test Tukui skin
	[DONE]saved variables
	[DONE]anchor
	colors
	add/delete new plugin instances
	[DONE]reload UI when modification are done
	global enable/disable in classmonitor root node
	description in classmonitor root node
	[DONE]global width/height
	[DONE]reload UI only when modification has been done and config panel closed
	[DONE]dont recreate options everytime config panel is opened
	[DONE]add an option to reset to original config
	[DONE]input on number get/set must handle string  (check validatenumber to find them)
	[TO TEST]auto grid anchor  +  vertical/horizontalIndex in the same group --> dummy key, real key is set in getValue/setValue
	width, height in the same group --> dummy key, real key is set in getValue/setValue
--]]