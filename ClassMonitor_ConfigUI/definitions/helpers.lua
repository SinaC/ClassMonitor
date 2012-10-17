local _, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

D.Helpers = {}

D.Helpers.Name = {
	key = "name",
	name = "Name",
	description = "Name",
	type = "string",
	readonly = true,
}

D.Helpers.Kind =  {
	key = "kind",
	name = "Kind",
	description = "Kind",
	type = "select",
	-- TODO: values
	readonly = true,
}

D.Helpers.Enable = {
	key = "enable",
	name = "Enable",
	description = "Enable",
	type = "toggle",
	default = true,
}

D.Helpers.Anchor = {
	key = "anchor",
	name = "Anchor",
	description = "Anchor",
	type = "anchor",
	hidden = true,
	readonly = true,
}

D.Helpers.Autohide = {
	key = "autohide",
	name = "Autohide",
	description = "Autohide",
	type = "toggle",
	default = true,
}

D.Helpers.Width = {
	key = "width",
	name = "Width",
	description = "Total bar width",
	type = "number",
	min = 80, max = 300, step = 1,
	default = 85
}

D.Helpers.Height = {
	key = "height",
	name = "Height",
	description = "Bar height",
	type = "number",
	min = 10, max = 50, step = 1,
	default = 15
}

D.Helpers.Specs = {
	key = "specs",
	name = "Specs",
	description = "Active in specified specialization", -- TODO: locales
	type = "multiselect",
	values = function()
		local specs = {}
		tinsert(specs, { value = "any", text = "any" })
		local num = GetNumSpecializations()
		for i = 1, num do
			local _, specName = GetSpecializationInfo(i)
			tinsert(specs, { value = i, text = specName })
		end
		return specs
	end,
	columns = 2,
	default = {"any"},
}

D.Helpers.Unit = {
	key = "unit",
	name = "Unit",
	description = "Unit to monitor",
	type = "select",
	values = {
		{ value = "player", text = "player" },
		{ value = "target", text = "target" },
		{ value = "focus", text = "focus" },
		{ value = "pet", text = "pet" },
	},
	default = "player",
}