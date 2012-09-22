local ADDON_NAME, Engine = ...
local L = Engine.Locales
local UI = Engine.UI

Engine.Enabled = false -- true, once an UI has been found

-- Variables
UI.BorderColor = nil
UI.BattlerHider = nil
UI.NormTex = nil
UI.MyClass = nil
UI.MyName = nil

-- Functions
UI.SetFontString = function(parent, fontHeight, fontStyle)
	assert(false, "MUST BE OVERRIDEN IN UI COMPATIBLITY")
end

UI.ClassColor = function(className)
	assert(false, "MUST BE OVERRIDEN IN UI COMPATIBLITY")
end

UI.PowerColor = function(resourceName)
	assert(false, "MUST BE OVERRIDEN IN UI COMPATIBLITY")
end

UI.HealthColor = function(unit)
	assert(false, "MUST BE OVERRIDEN IN UI COMPATIBLITY")
end

UI.CreateMover = function(name, width, height, anchor, text)
	assert(false, "MUST BE OVERRIDEN IN UI COMPATIBLITY")
end