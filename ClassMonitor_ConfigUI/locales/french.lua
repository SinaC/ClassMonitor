local ADDON_NAME, Engine = ...
local L = Engine.Locales

if GetLocale() == "frFR" then
	L.CLASSMONITOR_CONFIG_RL = "Une ou plusieurs modifications que vous avez effectu\195\169es necessitent un ReloadUi."
	L.CLASSMONITOR_RESETCONFIG_CONFIRM = "Toutes les modifications effectu\195\169es vont \195\170tre supprim\195\169es, un ReloadUI sera \195\169galement effectu\195\169. Etes-vous certain?"

	L.MustBeANumber = "Nombre requis"
	L.InvalidSpellID = "SpellID incorrect"
	L.Threshold = "Seuil"
	L.Text = "Texte"
	L.CurrentValue = "Valeur courante"
	L.TimeLeft = "Temps restant"
	L.Filled = "Rempli"
	L.Count = "Charges"
	L.Colors = "Couleurs"
	L.BarColor = "Couleur de la barre"

	L.Reset = "R\195\169initialiser les options"
	L.ResetDesc = "Revenir \195\160 la configuration initiale"
	L.GlobalWidth = "Largeur globale"
	L.GlobalWidthDesc = "Modifier cette valeur changera la largeur de tous les plugins"
	L.GlobalHeight = "Hauteur globale"
	L.GlobalHeightDesc =  "Modifier cette valeur changera la hauteur de tous les plugins"
	L.AutoGridAnchor = "(experimental)Ancrage automatique en grille"
	L.AutoGridAnchorDesc = "Ancre automatiquement les fen\195\170tres en se basant sur une grille (experimental)"

	-- Helpers definition
	L.Name = "Nom de la fen\195\170tre"
	L.NameDesc = "Nom de la fen\195\170tre"

	L.DisplayName = "Nom"
	L.DisplayNameDesc = "Nom affich\195\169 dans la fen\195\170tre de configuration et dans les messages d'erreur"

	L.Kind = "Type"
	L.KindDesc = "Type de monitor"
	L.KindValueMover = "Cadre"
	L.KindValueAura = "Charges d'aura"
	L.KindValueAuraBar = "Barre d'aura"
	L.KindValueResource = "Barre de ressource"
	L.KindValueCombo = "Points de combo"
	L.KindValuePower = "Barre d'\195\169nergie"
	L.KindValueRunes = "Runes"
	L.KindValueEclipse = "Barre d'eclipse"
	L.KindValueEnergize = "Energize bar" -- TODO
	L.KindValueHealth = "Barre de vie"
	L.KindValueDot = "D\195\169gats sur la dur\195\169e"
	L.KindValueTotems = "Totems et champignons"
	--L.KindValueBanditsGuile = select(1, GetSpellInfo(84654)) -- Bandit's Guile
	--L.KindValueStagger =  select(1, GetSpellInfo(124255)) -- Stagger
	L.KindValueTankShield = "Bouclier de tank"
	L.KindValueBurningEmbers = "Braises ardentes"
	L.KindValueDemonicFury = "Fureur d\195\169moniaque"
	L.KindValueRecharge = "Cooldown avec charges"
	L.KindValueRechargeBar = "Barre de cooldown avec charges"
	L.KindValueCD = "Cooldown"

	L.Enable = "Actif"
	L.EnableDesc = "Activer ou non ce plugin"

	L.Autohide = "En combat"
	L.AutohideDesc = "Activer le plugin uniquement en combat"

	L.Width = "Largeur"
	L.WidthDesc = "Largeur totale du plugin"

	L.Height = "Hauteur"
	L.HeightDesc = "Hauteur du plugin"

	L.Filter = "Filtre"
	L.FilterDesc = "Am\195\169lioration ou affaiblissement"
	L.FilterValueHelpful = "Am\195\169lioration"
	L.FilterValueHarmful = "Affaiblissement"

	L.Unit = "Unit\195\169"
	L.UnitDesc = "Unit\195\169 \195\160 monitorer"
	L.UnitValuePlayer = "Joueur"
	L.UnitValueTarget = "Cible"
	L.UnitValueFocus = "Focalisation"
	L.UnitValuePet = "Familier"

	L.Specs = "Specialisation"
	L.SpecsDesc = "Actif dans cette specialization"

	L.Spell = "Sort"
	L.SpellDesc = "Sort \195\160 monitorer"
	L.SpellID = "ID du sort"
	L.SpellIDDesc = "ID du sort \195\160 monitorer"

	L.Anchor = "Ancre"
	L.AnchorDesc = "Ancre"
	L.AnchorPoint = "Point"
	L.AnchorPointDesc = "Point du plugin \195\160 ancrer"
	L.AnchorRelativeFrame = "Fen\195\170tre relative"
	L.AnchorRelativeFrameDesc = "Fen\195\170tre sur laquelle le plugin doit s'ancrer"
	L.AnchorRelativePoint = "Point relatif"
	L.AnchorRelativePointDesc = "Point dans la fen\195\170tre relative sur lequel le plugin doit s'ancrer"
	L.AnchorOffsetX = "D\195\169calage horizontal"
	L.AnchorOffsetXDesc = "D\195\169calage horizontal \195\160 appliquer \195\160 l'ancre"
	L.AnchorOffsetY = "D\195\169calage vertical"
	L.AnchorOffsetYDesc = "D\195\169calage vertical \195\160 appliquer \195\160 l'ancre"

	L.AutoGridAnchorVerticalIndex = "Ligne"
	L.AutoGridAnchorVerticalIndexDesc = "Index vertical dans la grille"
	L.AutoGridAnchorHorizontalIndex = "Colonne"
	L.AutoGridAnchorHorizontalIndexDesc = "Index horizontal dans la grille"

	-- Plugin definition
	L.AuraCountDesc = "Nombre maximum de charges"
	L.AuraFilledDesc = "Remplir la charge ou seulement afficher le bord"

	L.AurabarTextDesc = "Affiche le nombre de charges actuels/nombre maximum de charges"
	L.AurabarDurationDesc = "Afficher la dur\195\169e restant"

	--L.BanditsGuileShallow = GetSpellInfo(84745)
	--L.BanditsGuileModerate = GetSpellInfo(84746)
	--L.BanditsGuileDeep = GetSpellInfo(84747)

	L.CDText = "Nom du sort"
	L.CDTextDesc = "Afficher le nom du sort"
	L.CDDurationDesc = "Afficher le temps restant"

	L.ComboFilledDesc = "Remplir le point de combo ou seulement afficher le bord"

	L.DemonicfuryTextDesc = "Afficher la valeur courante"

	L.DotLatency = "Latence"
	L.DotLatencyDesc = "Afficher la latence"
	L.DotThresholdDesc = "Seuil"
	L.DotColor1 = "En dessous du seuil"
	L.DotColor2 = "75% du seuil"
	L.DotColor3 = "Au dessus du seuil"

	L.EclipseLunar = "Lunaire"
	L.EclipseSolar = "Solaire"
	L.EclipseText = "Direction"
	L.EclipseTextDesc = "Afficher des fl\195\168ches indiquant la direction de l'eclipse"

	L.EnergizeFilling = "Remplir"
	L.EnergizeFillingDesc = "Remplir ou vider la barre"
	L.EnergizeDuration = "Dur\195\169e"
	L.EnergizeDurationDesc = "Dur\195\169e de l'ENERGIZE"

	L.HealtTextDesc = "Afficher les points de vie actuelle"

	L.PowerType = "Type d'\195\169nergie"
	L.PowerTypeDesc = "Type d'\195\169nergie \195\160 monitorer"
	L.PowerValueHolyPower = "Puissance sacr\195\169e"
	L.PowerValueSoulShards = "Eclats d'\195\162me"
	L.PowerValueChi = "Chi"
	L.PowerValueShadowOrbs = "Orbes d'ombre"
	L.PowerCountDesc = "Nombre de charges maximum"
	L.PowerFilledDesc = "Remplir la charge d'\195\169nergie ou seulement afficher le bord"

	L.RechargeTextDesc = "Afficher le temps restant sur la charge active"

	L.RechargeBarTextDesc = "Afficher le temps restant"

	L.ResourceTextDesc = "Afficher la valeur courante"
	L.ResourceHideifmax = "Cacher si valeur maximale"
	L.ResourceHideifmaxDesc = "Cacher quand la valeur courante est \195\169gale \195\160 la valeur maximale (hors combat)"

	L.RunesThresholdDesc = "Temps entre 2 rafraichissement"
	L.RunesOrientation = "Orientation"
	L.RunesOrientationDesc = "Sens de remplissage"
	L.RunesBlood = "Sang"
	L.RunesUnholy = "Impie"
	L.RunesFrost = "Givre"
	L.RunesDeath = "Mort"

	L.StaggerThresholdDesc = "Au dessus de cette value, le pourcentage de vie n'est pas affich\195\169"
	L.StaggerTextDesc = "Afficher la valeur de report courant"
	--L.StaggerLight = GetSpellInfo(124275)
	--L.StaggerModerate = GetSpellInfo(124274)
	--L.StaggerHeavy = GetSpellInfo(124273)

	L.TankshieldDurationDesc = "Afficher la dur\195\169e restante"

	L.TotemsCountDesc = "Nbre de totems/champignons"
	L.TotemsTextDesc = "Afficher le temps restant sur chaque totem/champignon"
end