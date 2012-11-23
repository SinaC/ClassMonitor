local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

local function IsHideIfMaxDisabled(info)
	if D.Helpers.IsPluginDisabled(info) then
		return true
	end
	local autohide = info.arg.parent and info.arg.parent.args.autohide
	if autohide then
		return info.arg.section["autohide"] -- hideifmax has no meaning if autohide is set
	end
	return false
end

local options = {
	[1] = D.Helpers.Description,
	[2] = D.Helpers.Name,
	[3] = D.Helpers.DisplayName,
	[4] = D.Helpers.Kind,
	[5] = D.Helpers.Enabled,
	[6] = D.Helpers.Autohide,
	[7] = {
		key = "hideifmax",
		name = L.ResourceHideifmax,
		desc = L.ResourceHideifmaxDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = IsHideIfMaxDisabled
	},
	[8] = D.Helpers.WidthAndHeight,
	[9] = D.Helpers.Specs,
	[10] = {
		key = "text",
		name = L.CurrentValue,
		desc = L.ResourceTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsPluginDisabled
	},
	-- TODO: colors (one entry by resource_type)
	[12] = D.Helpers.Anchor,
	[13] = D.Helpers.AutoGridAnchor,
}

D.Helpers:NewPluginDefinition("RESOURCE", options, L.PluginShortDescription_RESOURCE, L.PluginDescription_RESOURCE)