local _, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions
local G = Engine.Globals

D.Globals = {}

----------------------------------------------------------------------------------------
local function GetGlobalWidth(info)
	if G.SavedPerChar.Global.width then
		return G.SavedPerChar.Global.width
	else
		-- MOVER is the reference
		for _, section in pairs(G.Config) do
			if section.name == "CM_MOVER" or section.kind == "MOVER" then
				return section.width
			end
		end
		return 262 -- hardcoded default
	end
end

local function SetGlobalWidth(info, value)
	G.SavedPerChar.Global.width = value
	if G.SavedPerChar.Global.autogridanchor == true then
		if G.AutoGridAnchor and type(G.AutoGridAnchor) == "function" then
			G.AutoGridAnchor(G.Config, G.SavedPerChar.Global.width, G.SavedPerChar.Global.height, 3, "anchor", "width", "height") -- TODO: spacing from settings
		end
	else
		local updated = false
		for _, section in pairs(G.Config) do
			if section.width then
				section.width = value
				G.SavedPerChar.Plugins[section.name] = G.SavedPerChar.Plugins[section.name] or {}
				G.SavedPerChar.Plugins[section.name].width = value
				updated = G.PluginUpdateFunction and G:PluginUpdateFunction(section.kind, section.name) or false
			end
		end
		if not updated then
			-- something modified, -> /reloadui
			G.ConfigModified = true
		end
	end
end

D.Globals.CreateGlobalWidthOption = function(index)
	return {
		name = L.GlobalWidth,
		desc = L.GlobalWidthDesc,
		order = index,
		--guiInline = true,
		type = "range",
		arg = {key = "width"},
		min = 80, max = 300, step = 1,
		get = GetGlobalWidth,
		set = SetGlobalWidth,
	}
end

----------------------------------------------------------------------------------------
local function GetGlobalHeight(info)
	if G.SavedPerChar.Global.height then
		return G.SavedPerChar.Global.height
	else
		-- MOVER is the reference
		for _, section in pairs(G.Config) do
			if section.name == "CM_MOVER" or section.kind == "MOVER" then
				return section.height
			end
		end
		return 16 -- hardcoded default
	end
end

local function SetGlobalHeight(info, value)
	G.SavedPerChar.Global.height = value
	if G.SavedPerChar.Global.autogridanchor == true then
		if G.AutoGridAnchor and type(G.AutoGridAnchor) == "function" then
			G.AutoGridAnchor(G.Config, G.SavedPerChar.Global.width, G.SavedPerChar.Global.height, 3, "anchor", "width", "height") -- TODO: spacing from settings
		end
	else
		local updated = false
		for _, section in pairs(G.Config) do
			if section.height then
				section.height = value
				G.SavedPerChar.Plugins[section.name] = G.SavedPerChar.Plugins[section.name] or {}
				G.SavedPerChar.Plugins[section.name].height = value
				updated = G.PluginUpdateFunction and G:PluginUpdateFunction(section.kind, section.name) or false
			end
		end
		if not updated then
			-- something modified, -> /reloadui
			G.ConfigModified = true
		end
	end
end

D.Globals.CreateGlobalHeightOption = function(index)
	return {
		name = L.GlobalHeight,
		desc = L.GlobalHeightDesc,
		order = index,
		--guiInline = true,
		type = "range",
		arg = {key = "height"},
		min = 10, max = 50, step = 1,
		get = GetGlobalHeight,
		set = SetGlobalHeight,
	}
end

----------------------------------------------------------------------------------------
local function ResetConfig()
	-- delete data per char
	for k, v in pairs(G.SavedPerChar) do
		G.SavedPerChar[k] = nil
	end
	-- delete data per realm
	for k, v in pairs(G.SavedPerAccount) do
		G.SavedPerAccount[k] = nil
	end
	-- reload
	ReloadUI()
end

function D.Globals.CreateResetOption(index)
	return {
		name = L.Reset,
		desc = L.ResetDesc,
		order = index,
		type = "execute",
		func = ResetConfig,
		confirm = true,
		confirmText = L.CLASSMONITOR_RESETCONFIG_CONFIRM
	}
end

----------------------------------------------------------------------------------------
local function GetAutoGridAnchor(info)
	return G.SavedPerChar.Global.autogridanchor
end

local function SetAutoGridAnchor(info, value)
	G.SavedPerChar.Global.autogridanchor = value
	if value == true then
		if G.AutoGridAnchor and type(G.AutoGridAnchor) == "function" then
			G.AutoGridAnchor(G.Config, G.SavedPerChar.Global.width, G.SavedPerChar.Global.height, 3, "anchor", "width", "height") -- TODO: spacing from settings
		end
	end
end

D.Globals.IsAnchorHidden = function(info)
	return G.SavedPerChar.Global.autogridanchor
end

D.Globals.IsAutoAnchorHidden = function(info)
	return not G.SavedPerChar.Global.autogridanchor
end

D.Globals.CreateAutoGridAnchorOption = function(index)
	return {
		name = L.AutoGridAnchor,
		desc = L.AutoGridAnchorDesc,
		order = index,
		type = "toggle",
		get = GetAutoGridAnchor,
		set = SetAutoGridAnchor,
		disabled = true
	}
end