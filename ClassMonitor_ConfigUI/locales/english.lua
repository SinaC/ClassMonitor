local ADDON_NAME, Engine = ...
local L = Engine.Locales

L.CLASSMONITOR_CONFIG_RL = "One or more of the changes you have made require a ReloadUI."
L.CLASSMONITOR_RESETCONFIG_CONFIRM = "This will reset every modifications done to ClassMonitor config, a ReloadUI will also be performed. Are you sure?"

L.MustBeANumber = "Number required"
L.InvalidSpellID = "Incorrect SpellID"
L.Threshold = "Threshold"
L.Text = "Text"
L.CurrentValue = "Current value"
L.TimeLeft = "Time left"
L.Duration = "Duration"
L.Filled = "Filled"
L.Count = "Count"
L.Colors = "Colors"
L.BarColor = "Bar color"

L.Reset = "Reset config"
L.ResetDesc = "Revert to original config"
L.GlobalWidth = "Global width"
L.GlobalWidthDesc = "Modifying this value will modify width of every plugin"
L.GlobalHeight = "Global height"
L.GlobalHeightDesc = "Modifying this value will modify height of every plugin"

-- Helpers definition
L.Name = "Frame name"
L.NameDesc = "Frame name"

L.DisplayName = "Name"
L.DisplayNameDesc = "Name displayed in config and error"

L.Kind = "Kind"
L.KindDesc = "Kind of monitor"
L.KindValueMover = "Mover"
L.KindValueAura = "Aura stacks"
L.KindValueAuraBar = "Aura bar"
L.KindValueResource = "Resource bar"
L.KindValueCombo = "Combo points"
L.KindValuePower = "Power points"
L.KindValueRunes = "Runes"
L.KindValueEclipse = "Eclipse bar"
L.KindValueEnergize = "Energize bar"
L.KindValueHealth = "Health bar"
L.KindValueDot = "Dot bar"
L.KindValueTotems = "Totems and mushrooms"
L.KindValueBanditsGuile = select(1, GetSpellInfo(84654)) -- Bandit's Guile
L.KindValueStagger =  select(1, GetSpellInfo(124255)) -- Stagger
L.KindValueTankShield = "Tank shield"
L.KindValueBurningEmbers = "Burning embers"
L.KindValueDemonicFury = "Demonic fury"
L.KindValueRecharge = "Recharge cooldown"
L.KindValueRechargeBar = "Bar with recharge cooldown"
L.KindValueCD = "Cooldown"

L.Enable = "Enabled"
L.EnableDesc = "Enable or not this plugin"

L.Autohide = "Autohide"
L.AutohideDesc = "When set, plugin will only be shown while in combat"

L.Width = "Width"
L.WidthDesc = "Total plugin width"

L.Height = "Height"
L.HeightDesc = "Plugin height"

L.Filter = "Filter"
L.FilterDesc = "Buff or debuff"
L.FilterValueHelpful = "Buff"
L.FilterValueHarmful = "Debuff"

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

-- Plugin definition
L.AuraCount = "Maximum stack count"
L.AuraCountDesc = "Maximum stack count"
L.AuraFilledDesc = "Stack filled or not"

L.AurabarTextDesc = "Display current stack/maximum stack"
L.AurabarDurationDesc = "Display aura time left"
L.AurabarColor = "Bar color"

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

L.StaggerThresholdDesc = "Above this value, health percentage is not displayed"
L.StaggerTextDesc = "Display current stagger value"
L.StaggerLight = GetSpellInfo(124275)
L.StaggerModerate = GetSpellInfo(124274)
L.StaggerHeavy = GetSpellInfo(124273)

L.TankshieldDurationDesc = "Display shield time left"

L.TotemsCountDesc = "Totem/mushrooms count"
L.TotemsTextDesc = "Display time left on each totem/mushroom"