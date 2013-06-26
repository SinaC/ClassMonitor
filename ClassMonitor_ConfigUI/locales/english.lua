local ADDON_NAME, Engine = ...
local L = Engine.Locales

L.CLASSMONITOR_CONFIG_RL = "One or more of the changes you have made require a ReloadUI."
L.CLASSMONITOR_RESETCONFIG_CONFIRM = "This will reset every modifications done to ClassMonitor config, a ReloadUI will also be performed. Are you sure?"
L.CLASSMONITOR_CREATENEWPLUGIN_CONFIRM = "This will create the new plugin '%s' of kind '%s'. Are you sure?"
L.CLASSMONITOR_SWITCHAUTOGRIDANCHOR_CONFIRM = "This feature is still experimental. Are you sure you want to use it? Use /clm reset if something went wrong :)"
L.CLASSMONITOR_DELETEPLUGIN_CONFIRM = "This will delete plugin '%s', plugins anchored to this plugin will be reanchored. This operation cannot be undone. Are you sure?"

L.NoPluginDescription = "No description found for this plugin"
L.MustBeANumber = "Number required"
L.InvalidSpellID = "Incorrect SpellID"
L.InvalidSpellName = "Incorrect SpellName"
L.PluginNameAlreadyExists = "Plugin %s already exists"
L.Threshold = "Threshold"
L.Text = "Text"
L.CurrentValue = "Current value"
L.TimeLeft = "Time left"
L.Duration = "Duration"
L.Filled = "Filled"
L.Count = "Count"
L.Colors = "Colors"
L.BarColor = "Bar color"

L.GlobalReset = "Reset config"
L.GlobalResetDesc = "Revert to original config"
L.GlobalWidth = "Global width"
L.GlobalWidthDesc = "Modifying this value will modify width of every plugin"
L.GlobalHeight = "Global height"
L.GlobalHeightDesc = "Modifying this value will modify height of every plugin"
L.GlobalAutoGridAnchor = "Auto-grid anchoring(experimental)"
L.GlobalAutoGridAnchorDesc = "Automatically anchor frame using a grid system (experimental)"
L.GlobalAutoGridAnchorEnabled = "Enabled"
L.GlobalAutoGridAnchorEnabledDesc = "Activate auto-grid anchoring"
L.GlobalAutoGridAnchorSpacing = "Vertical spacing"
L.GlobalAutoGridAnchorSpacingDesc = "Vertical spacing between 2 plugins"
L.GlobalNewPluginInstance = "Create plugin"
L.GlobalNewPluginInstanceDesc = "New plugin instance creation"
L.GlobalCreateNewPluginButton = "Create"
L.GlobalCreateNewPluginButtonDesc = "Create a new plugin instance"
L.GlobalDebugMode = "Debug"
L.GlobalDebugModeDesc = "In debug mode, additional informations will be provided for each plugin"

L.Delete = "Delete"
L.DeleteDesc = "Delete this plugin instance"

-- Helpers definition
L.Name = "Frame name"
L.NameDesc = "Frame name"

L.DisplayName = "Name"
L.DisplayNameDesc = "Name displayed in config and error"

L.Kind = "Kind"
L.KindDesc = "Kind of monitor"
--L.PluginShortDescription_Mover = "Mover"

L.Enabled = "Enabled"
L.EnabledDesc = "Enable or not this plugin"

L.Autohide = "Autohide"
L.AutohideDesc = "When set, plugin will only be shown while in combat"

L.Size = "Size"
L.SizeDesc = "Width and height of plugin"
L.Width = "Width"
L.WidthDesc = "Total plugin width"
L.Height = "Height"
L.HeightDesc = "Plugin height"

L.Filter = "Filter"
L.FilterDesc = "Buff or debuff"
L.FilterValueHelpful = "Buff"
L.FilterValueHarmful = "Debuff"

L.Reverse = "Reverse order"
L.ReverseDesc = "Display from right to left instead of left to right"

L.Unit = "Unit"
L.UnitDesc = "Unit to monitor"
L.UnitValuePlayer = "Player"
L.UnitValueTarget = "Target"
L.UnitValueFocus = "Focus"
L.UnitValuePet = "Pet"

L.Specs = "Specialization"
L.SpecsDesc = "Active in specified specialization"

L.Spell = "Spell"
L.SpellDesc = "Spell to monitor"
L.SpellSpellID = "Spell ID"
L.SpellSpellIDDesc = "Spell ID to monitor"
L.SpellSpellName = "Spell name"
L.SpellSpellNameDesc = "Spell name to monitor"

L.Anchor = "Anchor"
L.AnchorDesc = "Anchor"
L.AnchorPoint = "Point"
L.AnchorPointDesc = "Plugin point to anchor"
L.AnchorRelativeFrame = "Relative frame"
L.AnchorRelativeFrameDesc = "Frame to anchor to"
L.AnchorRelativePoint = "Relative point"
L.AnchorRelativePointDesc = "Point in relative frame to anchor to"
L.AnchorOffsetX = "Horizontal offset"
L.AnchorOffsetXDesc = "Horizontal offset to apply to anchor"
L.AnchorOffsetY = "Vertical offset"
L.AnchorOffsetYDesc = "Vertical offset to apply to anchor"

L.AutoGridAnchor = "Auto-grid coordinates"
L.AutoGridAnchorDesc = "Auto-grid anchor coordinates"
L.AutoGridAnchorVerticalIndex = "Line"
L.AutoGridAnchorVerticalIndexDesc = "Vertical index in grid"
L.AutoGridAnchorHorizontalIndex = "Column"
L.AutoGridAnchorHorizontalIndexDesc = "Horizontal index in grid"

-- Plugin definition
L.AuraCount = "Maximum stack count"
L.AuraCountDesc = "Maximum stack count"
L.AuraFilledDesc = "Stack filled or not"

L.AurabarTextDesc = "Display current stack count"
L.AurabarDurationDesc = "Display aura time left"
L.AurabarColor = "Bar color"
L.AurabarShowspellname = "Aura name"
L.AurabarShowspellnameDesc = "Display aura name"

L.BanditsGuileShallow = GetSpellInfo(84745)
L.BanditsGuileModerate = GetSpellInfo(84746)
L.BanditsGuileDeep = GetSpellInfo(84747)

L.CDText = "Spell name"
L.CDTextDesc = "Display spell name"
L.CDDurationDesc = "Display time left"

L.ComboFilledDesc = "Combo points filled or not"

L.DemonicfuryTextDesc = "Display current demonic fury value"

L.DotLatency = "Latency"
L.DotLatencyDesc = "Display latency"
L.DotThresholdDesc = "Threshold value"
L.DotColor1 = "Below threshold"
L.DotColor2 = "75% threshold"
L.DotColor3 = "Above threshold"

L.EclipseLunar = "Lunar"
L.EclipseSolar = "Solar"
L.EclipseText = "Direction"
L.EclipseTextDesc = "Display arrows to show eclipse direction"

L.EnergizeFilling = "Filling"
L.EnergizeFillingDesc = "Fill or empty bar"
L.EnergizeDuration = "Duration"
L.EnergizeDurationDesc = "Energize duration"

L.HealtTextDesc = "Display current health value"

L.PowerType = "Power Type"
L.PowerTypeDesc = "Power type to monitor"
L.PowerValueHolyPower = "Holy Power"
L.PowerValueSoulShards = "Soul Shards"
L.PowerValueChi = "Chi"
L.PowerValueShadowOrbs = "Shadow Orbs"
L.PowerCount = "Maximum power count"
L.PowerCountDesc = "Maximum power count"
L.PowerFilledDesc = "Power filled or not"

L.RechargeTextDesc = "Display time left on active charge"

L.RechargeBarTextDesc = "Display time left"

L.ResourceTextDesc = "Display current value"
L.ResourceHideifmax = "Hide if max value"
L.ResourceHideifmaxDesc = "Hide if current value equals maximum value (out of combat)"

L.RunesThresholdDesc = "Time between 2 updates"
L.RunesOrientation = "Orientation"
L.RunesOrientationDesc = "Fill orientation"
L.RunesBlood = "Blood"
L.RunesUnholy = "Unholy"
L.RunesFrost = "Frost"
L.RunesDeath = "Death"
L.RunesOrientationHorizontal = "Horizontal"
L.RunesOrientationVertical = "Vertical"
L.RunesRunemap = "Runes order"
L.RunesRunemapDesc = "Change runes order"
L.RunesSlot = "Slot %d"
L.RunesSlotDesc = "Choose rune in slot %d"

L.StaggerThresholdDesc = "Above this value, health percentage is not displayed"
L.StaggerTextDesc = "Display current stagger value"
L.StaggerLight = GetSpellInfo(124275)
L.StaggerModerate = GetSpellInfo(124274)
L.StaggerHeavy = GetSpellInfo(124273)

L.StatueTextDesc = "Display time left on statue/lightwell/ghoul/banner"

L.TankshieldDurationDesc = "Display shield time left"

L.TotemsCountDesc = "Totem/mushrooms count"
L.TotemsTextDesc = "Display time left on each totem/mushroom"

--------
L.PluginShortDescription_AURA = "Aura stacks"
L.PluginDescription_AURA = "Display stacks for a buff/debuff"
L.PluginShortDescription_AURABAR = "Aura bar"
L.PluginDescription_AURABAR = "Display a bar with stack count and duration left for a buff or a debuff"
L.PluginShortDescription_RESOURCE = "Resource bar"
L.PluginDescription_RESOURCE = "Display a bar with current class resource, changes automatically with specialization/form/stance"
L.PluginShortDescription_COMBO = "Combo points"
L.PluginDescription_COMBO = "Display combo points"
L.PluginShortDescription_POWER = "Power points"
L.PluginDescription_POWER = "Display power points such as holy power, soul shards, shadow orbs, ..."
L.PluginShortDescription_RUNES = "Runes"
L.PluginDescription_RUNES = "Display deathknight runes with an optional rune order remapping"
L.PluginShortDescription_ECLIPSE = "Eclipse bar"
L.PluginDescription_ECLIPSE = "Display moonkin eclipse bar"
L.PluginShortDescription_ENERGIZE = "Energize bar"
L.PluginDescription_ENERGIZE = "Display a bar for internal-cooldown of hidden mana regeneration such as priest rapture"
L.PluginShortDescription_HEALTH = "Health bar"
L.PluginDescription_HEALTH = "Display a health bar for player or target or focus or pet"
L.PluginShortDescription_DOT = "Dot bar"
L.PluginDescription_DOT = "Display a bar showing last tick damage for dot"
L.PluginShortDescription_TOTEMS = "Totems and mushrooms"
L.PluginDescription_TOTEMS = "Display totems for shaman or wild mushrooms for druid"
L.PluginShortDescription_BANDITSGUILE = select(1, GetSpellInfo(84654)) -- Bandit's Guile
L.PluginDescription_BANDITSGUILE = "Display stacks of bandit's guile for combat rogue"
L.PluginShortDescription_STAGGER =  select(1, GetSpellInfo(124255)) -- Stagger
L.PluginDescription_STAGGER = "Display a bar with current stagger value and health percentage of staggered damage"
L.PluginShortDescription_TANKSHIELD = "Tank shield"
L.PluginDescription_TANKSHIELD = "Display a bar with tank shield absorb value and time left"
L.PluginShortDescription_BURNINGEMBERS = "Burning embers"
L.PluginDescription_BURNINGEMBERS = "Display bars with current burning embers value for destruction warlock"
L.PluginShortDescription_DEMONICFURY = "Demonic fury"
L.PluginDescription_DEMONICFURY = "Display a bar with current demonic fury value for demonology warlock"
L.PluginShortDescription_RECHARGE = "Recharge cooldown"
L.PluginDescription_RECHARGE = "Display bars for each charge of cooldown with charges such as monk roll or druid savage defense"
L.PluginShortDescription_RECHARGEBAR = "Bar with recharge cooldown"
L.PluginDescription_RECHARGEBAR = "Display a bar with current, max value and time left for cooldown with charges such as monk Roll or druid Savage defense"
L.PluginShortDescription_CD = "Cooldown"
L.PluginDescription_CD = "Display a bar with spell name and time left for cooldown"
L.PluginShortDescription_STATUE = "Statue/Lightwell/Ghoul/Banner bar"
L.PluginDescription_STATUE = "Display a bar with timeleft/uptime of monk statue, DK ghoul, priest lightwell and warrior's banner"