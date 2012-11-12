local ADDON_NAME, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

-- local function GetHideIfMax(info)
	-- local autohide = info.arg.parent and info.arg.parent.args.autohide
	-- if autohide then
		-- info.option.disabled = info.arg.section["autohide"] -- hideifmax has no meaning if autohide is set
	-- end
	-- return D.Helpers.GetValue(info)
-- end

local function IsHideIfMaxDisabled(info)
	if D.Helpers.IsDisabled(info) then
		return true
	end
	local autohide = info.arg.parent and info.arg.parent.args.autohide
	if autohide then
		return info.arg.section["autohide"] -- hideifmax has no meaning if autohide is set
	end
	return false
end

D["RESOURCE"] = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = {
		key = "hideifmax",
		name = L.ResourceHideifmax,
		desc = L.ResourceHideifmaxDesc,
		type = "toggle",
		--get = GetHideIfMax,
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = IsHideIfMaxDisabled
	},
	[7] = D.Helpers.Width,
	[8] = D.Helpers.Height,
	[9] = D.Helpers.Specs,
	[10] = {
		key = "text",
		name = L.CurrentValue,
		desc = L.ResourceTextDesc,
		type = "toggle",
		get = D.Helpers.GetValue,
		set = D.Helpers.SetValue,
		disabled = D.Helpers.IsDisabled
	},
	-- TODO: colors (one entry by resource_type)
	[11] = D.Helpers.Anchor,
	[12] = D.Helpers.AutoGridVerticalIndex,
	[13] = D.Helpers.AutoGridHorizontalIndex,
}