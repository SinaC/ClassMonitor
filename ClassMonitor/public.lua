local ADDON_NAME, Engine = ...

-- Expose public methods
ClassMonitor = {}

-- Methods exposed to external addons
ClassMonitor.NewPlugin = Engine.NewPlugin -- Create a new plugin category (must be done before ADDON_LOADED)  --> TODO: impossible to do it before ADDON_LOADED if ClassMonitor is set as dependencies
ClassMonitor.GetPluginList = Engine.GetPluginList -- Get a list of plugin category name
ClassMonitor.IsPluginAvailable = Engine.IsPluginAvailable -- Return true if plugin category already exists, false otherwise

-- Namespaces exposed to extern addons
ClassMonitor.UI = Engine.UI