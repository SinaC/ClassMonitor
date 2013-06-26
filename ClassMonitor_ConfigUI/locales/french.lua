local ADDON_NAME, Engine = ...
local L = Engine.Locales

if GetLocale() == "frFR" then
	L.CLASSMONITOR_CONFIG_RL = "Une ou plusieurs modifications que vous avez effectu\195\169es necessitent un ReloadUi."
	L.CLASSMONITOR_RESETCONFIG_CONFIRM = "Toutes les modifications effectu\195\169es vont \195\170tre supprim\195\169es, un ReloadUI sera \195\169galement effectu\195\169. Etes-vous certain?"
	L.CLASSMONITOR_CREATENEWPLUGIN_CONFIRM = "Le plugin '%s' du type '%s' va \195\170tre cr\195\169\195\169. Etes-vous certain?"
	L.CLASSMONITOR_SWITCHAUTOGRIDANCHOR_CONFIRM = "Cette fonctionnalit\195\169 est exp\195\169rimentale. Etes-vous certain de vouloir l'utiliser? Utilisez /clm reset si quelque chose se passe mal :)"
	L.CLASSMONITOR_DELETEPLUGIN_CONFIRM = "Le plugin '%s' va \195\170tre supprim\195\169, cette op\195\169ration est irr\195\169versible. Etes-vous certain?"

	L.NoPluginDescription = "Aucune d\195\169finition n'a \195\169t\195\169 trouv\195\169e pour ce plugin"
	L.MustBeANumber = "Nombre requis"
	L.InvalidSpellID = "SpellID incorrect"
	L.InvalidSpellName = "Nom du sort incorrect"
	L.PluginNameAlreadyExists = "Le plugin %s existe d\195\169j\195\160"
	L.Threshold = "Seuil"
	L.Text = "Texte"
	L.CurrentValue = "Valeur courante"
	L.TimeLeft = "Temps restant"
	L.Filled = "Rempli"
	L.Count = "Charges"
	L.Colors = "Couleurs"
	L.BarColor = "Couleur de la barre"

	L.GlobalReset = "R\195\169initialiser les options"
	L.GlobalResetDesc = "Revenir \195\160 la configuration initiale"
	L.GlobalWidth = "Largeur globale"
	L.GlobalWidthDesc = "Modifier cette valeur changera la largeur de tous les plugins"
	L.GlobalHeight = "Hauteur globale"
	L.GlobalHeightDesc =  "Modifier cette valeur changera la hauteur de tous les plugins"
	L.GlobalAutoGridAnchor = "Ancrage automatique en grille(experimental)"
	L.GlobalAutoGridAnchorDesc = "Ancre automatiquement les fen\195\170tres en se basant sur une grille (experimental)"
	L.GlobalAutoGridAnchorEnabled = "Actif"
	L.GlobalAutoGridAnchorEnabledDesc = "Activer l'ancrage automatique en fonction d'une grille"
	L.GlobalAutoGridAnchorSpacing = "D\195\169calage vertical"
	L.GlobalAutoGridAnchorSpacingDesc = "D\195\169calage vertical entre 2 plugins"
	L.GlobalNewPluginInstance = "Ajout d'un plugin"
	L.GlobalNewPluginInstanceDesc = "Ajout d'une nouvelle instance d'un plugin"
	L.GlobalCreateNewPluginButton = "Ajouter"
	L.GlobalCreateNewPluginButtonDesc = "Ajoute une nouvelle instance d'un plugin"
	L.GlobalDebugMode = "Debug"
	L.GlobalDebugModeDesc = "En mode debug, des informations suppl\195\169mentaires sont affich\195\169es pour chaque plugin"

	L.Delete = "Supprimer"
	L.DeleteDesc = "Supprimer ce plugin"

	-- Helpers definition
	L.Name = "Nom de la fen\195\170tre"
	L.NameDesc = "Nom de la fen\195\170tre"

	L.DisplayName = "Nom"
	L.DisplayNameDesc = "Nom affich\195\169 dans la fen\195\170tre de configuration et dans les messages d'erreur"

	L.Kind = "Type"
	L.KindDesc = "Type de monitor"
	--L.PluginShortDescription_Mover = "Cadre"

	L.Enabled = "Actif"
	L.EnabledDesc = "Activer ou non ce plugin"

	L.Autohide = "En combat"
	L.AutohideDesc = "Activer le plugin uniquement en combat"

	L.Size = "Taille"
	L.SizeDesc = "Largeur et hauteur du plugin"
	L.Width = "Largeur"
	L.WidthDesc = "Largeur totale du plugin"
	L.Height = "Hauteur"
	L.HeightDesc = "Hauteur du plugin"

	L.Filter = "Filtre"
	L.FilterDesc = "Am\195\169lioration ou affaiblissement"
	L.FilterValueHelpful = "Am\195\169lioration"
	L.FilterValueHarmful = "Affaiblissement"

	L.Reverse = "Order inverse"
	L.ReverseDesc = "Affiche de droite \195\160 gauche \195\160 la place de gauche \195\160 droite"

	L.Unit = "Unit\195\169"
	L.UnitDesc = "Unit\195\169 \195\160 monitorer"
	L.UnitValuePlayer = "Joueur"
	L.UnitValueTarget = "Cible"
	L.UnitValueFocus = "Focalisation"
	L.UnitValuePet = "Familier"

	L.Specs = "Sp\195\169cialisation"
	L.SpecsDesc = "Actif dans cette sp\195\169cialisation"

	L.Spell = "Sort"
	L.SpellDesc = "Sort \195\160 monitorer"
	L.SpellID = "ID du sort"
	L.SpellIDDesc = "ID du sort \195\160 monitorer"
	L.SpellSpellName = "Nom du sort"
	L.SpellSpellNameDesc = "Nom du sort \195\160 monitorer"

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

	L.AutoGridAnchor = "Coordonn\195\169es dans la grille"
	L.AutoGridAnchorDesc = "Coordonn\195\169es dans la grille"
	L.AutoGridAnchorVerticalIndex = "Ligne"
	L.AutoGridAnchorVerticalIndexDesc = "Index vertical dans la grille"
	L.AutoGridAnchorHorizontalIndex = "Colonne"
	L.AutoGridAnchorHorizontalIndexDesc = "Index horizontal dans la grille"

	-- Plugin definition
	L.AuraCountDesc = "Nombre maximum de charges"
	L.AuraFilledDesc = "Remplir la charge ou seulement afficher le bord"

	L.AurabarTextDesc = "Affiche le nombre de charges"
	L.AurabarDurationDesc = "Afficher la dur\195\169e restant"
	L.AurabarShowspellname = "Nom de l'aura"
	L.AurabarShowspellnameDesc = "Afficher le nom de l'aura"

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
	L.RunesOrientationHorizontal = "Horizontal"
	L.RunesOrientationVertical = "Vertical"
	L.RunesRunemap = "Ordre des runes"
	L.RunesRunemapDesc = "Change l'ordre des runes"
	L.RunesSlot = "Emplacement %d"
	L.RunesSlotDesc = "Choisir la rune dans l'emplacement %d"

	L.StaggerThresholdDesc = "Au dessus de cette valeur, le pourcentage de vie n'est pas affich\195\169"
	L.StaggerTextDesc = "Afficher la valeur de report courant"
	--ALREADY LOCALIZED IN ENGLISH.LUA --L.StaggerLight = GetSpellInfo(124275)
	--ALREADY LOCALIZED IN ENGLISH.LUA --L.StaggerModerate = GetSpellInfo(124274)
	--ALREADY LOCALIZED IN ENGLISH.LUA --L.StaggerHeavy = GetSpellInfo(124273)

	L.TankshieldDurationDesc = "Afficher la dur\195\169e restante"

	L.TotemsCountDesc = "Nbre de totems/champignons"
	L.TotemsTextDesc = "Afficher le temps restant sur chaque totem/champignon"

	--------
	L.PluginShortDescription_AURA = "Aura"
	L.PluginDescription_AURA = "Affiche les charges d'une am\195\169lioration ou d'un affaiblissment"
	L.PluginShortDescription_AURABAR = "Barre d'aura"
	L.PluginDescription_AURABAR = "Affiche une barre avec le nombre de charges actuels ainsi que le temps restant d'une am\195\169lioration ou d'un affaiblissment"
	L.PluginShortDescription_RESOURCE = "Barre de ressource"
	L.PluginDescription_RESOURCE = "Affiche une barre avec la ressource courante, change automatiquement avec la specialisation, la forme, la posture"
	L.PluginShortDescription_COMBO = "Points de combo"
	L.PluginDescription_COMBO = "Affiche les points de combo"
	L.PluginShortDescription_POWER = "Energie (chi, sacr\195\169, ...)"
	L.PluginDescription_POWER = "Affiche des points d'\195\169nergie comme pour la puissance sacr\195\169e, les \195\169clats d'\195\162mes, le chi, les orbes d'ombres, ..."
	L.PluginShortDescription_RUNES = "Runes"
	L.PluginDescription_RUNES = "Affiche les runes de chevalier de la mort"
	L.PluginShortDescription_ECLIPSE = "Barre d'eclipse"
	L.PluginDescription_ECLIPSE = "Affiche la barre d'eclipse des druides equilibres"
	L.PluginShortDescription_ENERGIZE = "Energize bar" -- TODO
	L.PluginDescription_ENERGIZE = "Affiche une bar pour les temps de recharge interne des effet de r\195\169g\195\169n\195\169ration cach\195\169e de mana comme le Sursis des pr\195\170tres discipline"
	L.PluginShortDescription_HEALTH = "Barre de vie"
	L.PluginDescription_HEALTH = "Affiche une barre de vie pour le joueur ou la cible ou la focalisation ou le familier"
	L.PluginShortDescription_DOT = "D\195\169gats sur la dur\195\169e"
	L.PluginDescription_DOT = "Affiche une barre avec les d\195\169gats par tick d'un sort de d\195\169gats sur la dur\195\169e"
	L.PluginShortDescription_TOTEMS = "Totems et champignons"
	L.PluginDescription_TOTEMS = "Affiche les totems de chaman ou les champignons sauvages de druide"
	--ALREADY LOCALIZED IN ENGLISH.LUA --L.PluginShortDescription_BANDITSGUILE = select(1, GetSpellInfo(84654)) -- Bandit's Guile
	L.PluginDescription_BANDITSGUILE = "Affiche les charges de Ruse du bandit pour les voleurs combat"
	--ALREADY LOCALIZED IN ENGLISH.LUA --L.PluginShortDescription_STAGGER =  select(1, GetSpellInfo(124255)) -- Stagger
	L.PluginDescription_STAGGER = "Affiche une barre avec la valeur courante et total de Report, ainsi qu'un pourcentage par rapport \195\160 la vie totale"
	L.PluginShortDescription_TANKSHIELD = "Bouclier de tank"
	L.PluginDescription_TANKSHIELD = "Affiche une barre pour les tanks avec le montant restant que le bouclier peut absorber, ainsi que le temps restant"
	L.PluginShortDescription_BURNINGEMBERS = "Braises ardentes"
	L.PluginDescription_BURNINGEMBERS = "Affiche des barres avec le montant actuel de braises vivantes pour les d\195\169monistes sp\195\169cialis\195\169s destruction"
	L.PluginShortDescription_DEMONICFURY = "Fureur d\195\169moniaque"
	L.PluginDescription_DEMONICFURY = "Affiche une barre avec la valeur actuelle de fureur d\195\169moniaque pour les d\195\169monistes sp\195\169cialis\195\169s d\195\169monologie"
	L.PluginShortDescription_RECHARGE = "Cooldown avec charges"
	L.PluginDescription_RECHARGE = "Affiche des barres pour les charges d'un sort \195\160 temps de recharge avec charges comme la Roulade du moine ou la D\195\169fense sauvage du druide"
	L.PluginShortDescription_RECHARGEBAR = "Barre de cooldown avec charges"
	L.PluginDescription_RECHARGEBAR = "Affiche une barre avec le nombre courant et total de charge plus le temps restant d'un sort \195\160 temps de recharge avec charges comme la Roulade du moine ou la D\195\169fense sauvage du druide"
	L.PluginShortDescription_CD = "Cooldown"
	L.PluginDescription_CD = "Affiche une barre avec le nom et le temps de recharge restant d'un sort \195\160 temps de recharge"
	L.PluginShortDescription_STATUE = "Barre de statue/ghoule/puit de lumi\195\168re et banni\195\168re"
	L.PluginDescription_STATUE = "Display a bar with timeleft/uptime of monk statue, DK ghoul, priest lightwell and warrior's banner"
end