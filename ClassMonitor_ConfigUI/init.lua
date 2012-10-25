local _, Engine = ...

Engine.Locales = {}
Engine.Definitions = {}
Engine.Globals = {}

Engine.DisplayConfigFrame = nil -- defined later, config UI entry point

--[[
TODO:
	[DONE]test Tukui skin
	[DONE]saved variables
	anchor
	color
	add/delete new plugin instances
	[DONE]reload UI when modification are done
	global enable/disable in classmonitor root node
	description in classmonitor root node
	[DONE]global width/height
	[TO TEST]reload UI only when modification has been done and config panel closed
	dont recreate options everytime config panel is opened
--]]