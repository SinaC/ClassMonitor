local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

-- ONLY ON PTR
if not Engine.IsPTR() then return end
print("TESTING NEW PLUGIN")

local Plugins = {} -- List of plugins

------------------------------------------------
-- plugin class with metatable
------------------------------------------------
local Plugin = {}

------------------------------------------------
-- private ctor
------------------------------------------------
function Plugin:new(name, settings)
	assert(type(name) == "string", "Trying to create a plugin with non-string name")
	local p = {}

	setmetatable(p, self)
	self.__index = self

	-- add datas
	if not settings then
--print("New plugin category:"..tostring(name))
		-- plugin category
		p.pluginName = name
		p.instances = {}
	else
--print("New plugin instance:"..tostring(name))
		-- plugin instance
		p.eventHandler = CreateFrame("Frame")
		p.eventHandler.plugin = p -- loop back :)
		p.name = name
		p.settings = settings
		p.instances[name] = p -- save instance
	end

	return p
end

------------------------------------------------
-- private event handler methods
------------------------------------------------
function Plugin:OnEvent(event, ...) -- private
	local self = self.plugin or self
--print(tostring(self.pluginName)..":OnEvent:"..tostring(event).."  "..tostring(self))
	assert(self.eventHandler[event], "No event handler found for event "..tostring(event)..". Plugin: "..tostring(self.name).."/"..tostring(self.pluginName))
	self.eventHandler[event](self, event, ...)
end

function Plugin:OnUpdate(elapsed, ...) -- private
	local self = self.plugin or self
	assert(self.eventHandler["OnUpdate"], "No event handler found for update. Plugin: "..tostring(self.name).."/"..tostring(self.pluginName))
	self.eventHandler["OnUpdate"](self, elapsed)
end

------------------------------------------------
-- public event handler methods
------------------------------------------------
function Plugin:RegisterEvent(event, fct)
--print(tostring(self.pluginName)..":RegisterEvent:"..tostring(event).." "..tostring(fct))
	assert(type(event) == "string", "RegisterEvent event must be a string. Plugin: "..tostring(self.name).."/"..tostring(self.pluginName))
	assert(type(fct) == "function", "RegisterEvent fct must be a function. Plugin: "..tostring(self.name).."/"..tostring(self.pluginName))
	self.eventHandler:RegisterEvent(event)
	self.eventHandler[event] = fct
	self.eventHandler:SetScript("OnEvent", Plugin.OnEvent)
end
function Plugin:RegisterUnitEvent(event, unit, fct)
--print(tostring(self.pluginName)..":RegisterUnitEvent:"..tostring(event).." "..tostring(unit).." "..tostring(fct))
	assert(type(event) == "string", "RegisterUnitEvent event must be a string. Plugin: "..tostring(self.name).."/"..tostring(self.pluginName))
	assert(type(unit) == "string", "RegisterUnitEvent unit must be a string. Plugin: "..tostring(self.name).."/"..tostring(self.pluginName))
	assert(type(fct) == "function", "RegisterUnitEvent fct must be a function. Plugin: "..tostring(self.name).."/"..tostring(self.pluginName))
	self.eventHandler:RegisterUnitEvent(event, unit)
	self.eventHandler[event] = fct
	self.eventHandler:SetScript("OnEvent", Plugin.OnEvent)
end
function Plugin:UnregisterEvent(event)
	assert(type(event) == "string", "RegisterUnitEvent event must be a string. Plugin: "..tostring(self.name).."/"..tostring(self.pluginName))
	self.eventHandler:UnregisterEvent(event)
	self.eventHandler[event] = nil
end
function Plugin:UnregisterAllEvents()
--print(tostring(self.pluginName)..":UnregisterAllEvents")
	self.eventHandler:UnregisterAllEvents()
	-- TODO: remove every event handlers from self.eventHandler
	self.eventHandler:SetScript("OnEvent", nil)
end

function Plugin:RegisterUpdate(fct)
--print(tostring(self.pluginName..":RegisterUpdate")
	assert(type(fct) == "function", "RegisterUpdate fct must be a function. Plugin: "..tostring(self.name).."/"..tostring(self.pluginName))
	self.eventHandler["OnUpdate"] = fct
	self.eventHandler:SetScript("OnUpdate", Plugin.OnUpdate)
end
function Plugin:UnregisterUpdate()
	self.eventHandler:SetScript("OnUpdate", nil)
	self.eventHandler["OnUpdate"] = nil
end

------------------------------------------------
-- public abstract methods
------------------------------------------------
function Plugin:Initialize()
	assert(false, "Missing Initialize method in plugin: "..tostring(self.pluginName))
end
function Plugin:Enable()
	assert(false, "Missing Enable method in plugin: "..tostring(self.pluginName))
end
function Plugin:Disable()
	assert(false, "Missing Disable method in plugin: "..tostring(self.pluginName))
end
function Plugin:SettingsModified()
	assert(false, "Missing SettingsModified method in plugin: "..tostring(self.pluginName))
end

------------------------------------------------
-- public ctor & getter
------------------------------------------------
function Engine:NewPlugin(pluginName)
	assert(type(pluginName) == "string", "Plugin name must be a string")
	assert(not Plugins[pluginName], "Plugin "..tostring(pluginName).." already exists")

	local p = Plugin:new(pluginName)
	Plugins[pluginName] = p
	return p
end

function Engine:GetPlugin(pluginName, instanceName)
	assert(type(pluginName) == "string", "Plugin name must be a string")
	local p = Plugins[pluginName]
	if instanceName then
		assert(type(instanceName) == "string", "Instance name must be a string")
		p = p.instances[instanceName]
	end
	assert(p, "Plugin "..tostring(pluginName).." not found")
	return p
end

function Engine:NewPluginInstance(pluginName, instanceName, settings)
	assert(type(pluginName) == "string", "Plugin name must be a string")
	assert(type(instanceName) == "string", "Instance name must be a string")
	assert(settings, "Settings cannot be null")
	local category = Plugins[pluginName]
	assert(category, "Plugin "..tostring(pluginName).." not found")
	assert(not category.instances[instanceName], "Plugin instance "..tostring(instanceName).." already exists")
	return category:new(instanceName, settings)
end

------------------------------------------------
-- Update plugin instance settings
------------------------------------------------
function Engine:UpdatePluginInstance(pluginName, instanceName)
print("UpdatePluginInstance:"..tostring(pluginName).."  "..tostring(instanceName))
	--if true then return false end -- TODO: remove this when fully updated
	local category = Plugins[pluginName]
	if category then
print("category:"..tostring(category))
		for _, instance in pairs(category.instances) do
print("UPDATING:"..tostring(instance.name).."  "..tostring(instance.pluginName))
			instance:SettingsModified()
		end
	end
	return true
--[[
	-- get instance
	assert(type(pluginName) == "string", "Plugin name must be a string")
	assert(type(instanceName) == "string", "Instance name must be a string")
	local category = Plugins[pluginName]
	assert(category, "Plugin "..tostring(pluginName).." not found")
	local instance = category.instances[instanceName]
	assert(instance, "Plugin instance "..tostring(instanceName).." not found")
	-- update instance
	instance:SettingsModified()
	return true
--]]
end

-- ----------------------------------------------
-- -- test
-- ----------------------------------------------
-- local testPlugin = Engine:NewPlugin("TEST")
-- function testPlugin:PLAYER_ENTERING_WORLD(event)
-- print("testPlugin:PLAYER_ENTERING_WORLD:"..tostring(event).."  "..tostring(self.testField))
-- end
-- function testPlugin:UNIT_AURA(event, unit)
-- print("testPlugin:UNIT_AURA:"..tostring(event).."  "..tostring(unit).."  "..tostring(self.testField))
-- end
-- function testPlugin:Initialize()
-- print("testPlugin:Initialize "..tostring(self.name))
	-- self.testField = 5
-- end
-- function testPlugin:Enable()
	-- self:RegisterEvent("PLAYER_ENTERING_WORLD", testPlugin.PLAYER_ENTERING_WORLD)
	-- self:RegisterUnitEvent("UNIT_AURA", "player", testPlugin.UNIT_AURA)
-- end

-- local instance = Engine:NewPluginInstance("TEST", "testInstance", {})
-- instance:Initialize()
-- instance:Enable()
-- --instance:Disable()