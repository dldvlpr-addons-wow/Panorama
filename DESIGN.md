# DESIGN.md : fenêtre d'options Panorama

Référence de la fenêtre `PanoramaFrame` (Options.lua). Toute retouche de l'interface suit ce fichier.
Unités : unités d'interface WoW (échelle UI 1). Couleurs : RGB 0-1. Coordonnées y : depuis le haut de la fenêtre.

Refonte du 2026-11-25 : la fenêtre était jugée « fouillis, compliquée » (6 onglets rangés par
implémentation, teinte réglable à 3 endroits sans priorité visible, écrans de lignes grisées, aide de
2-3 lignes sous chaque réglage, case de mode posée comme un réglage). Cette version la range par
intention (Image, HDR, Ambiance, Mes filtres), dit en permanence d'où vient le look affiché, et compacte les lignes.

## 1. Direction

**Natif, dense, lisible.** Panorama est un panneau de réglages techniques ouvert en jeu, à côté des
fenêtres Blizzard : il doit avoir l'air d'en être une. Palette et polices sont celles du client
(constantes `NORMAL_FONT_COLOR`, `HIGHLIGHT_FONT_COLOR`, `GRAY_FONT_COLOR`, `RED_FONT_COLOR`),
gris neutres compris : c'est la charte de l'hôte, pas un réglage par défaut. La direction cyan du
2026-11-14 est abandonnée, ne pas la reprendre.

Densité « outil » : une ligne de réglage = un libellé et un contrôle, sur 28 de haut. L'explication
va en infobulle, jamais sous le libellé. Aucune décoration. La seule image de la fenêtre, hors logo,
est la capture teintée des vignettes de teinte : c'est là que l'œil doit aller.

Quatre questions, quatre onglets : « quelle qualité d'image ? » (Image), « quel rendu sur un écran HDR ? »
(HDR), « quel look sur le monde, et qu'est-ce qui change selon le lieu et l'heure ? » (Ambiance),
« comment sont faits mes filtres ? » (Mes filtres). Ce qui n'est pas un réglage
(langue, minimap, réinitialisation) sort des onglets, dans le menu Options.

## 2. Structure

Fenêtre `BasicFrameTemplate` **610 x 664**, déplaçable, fermée par Échap, strate DIALOG (inchangé).
Taille gardée : la barre d'outils supprimée (26) et les lignes compactes (28 au lieu de 44 à 80)
rendent la place au bandeau d'état ; la liste montre ~15 lignes au lieu de ~8, sans agrandir une
fenêtre qui s'ouvre par-dessus le jeu.

### Grille verticale

| Zone | y | Contenu |
|---|---|---|
| Barre de titre | 0-24 | gabarit, bouton fermer ; aucun texte ajouté |
| En-tête | 28-60 | logo, titre, sélecteur Simple / Avancé ; à droite, Guide et menu Options. Axe commun y 44 |
| Bandeau d'état | 64-92 | « Look actuel : … » et bouton d'action, tous onglets, recherche comprise |
| Onglets et recherche | 96-128 | 4 onglets à gauche, recherche à droite, filet à y 128 |
| Bloc de l'onglet | 136 à 184 / 188 / 244 | préréglages (Image), filtre ouvert et nom (Mes filtres), mode, lieu, filtre et règle (Ambiance) ; caché en recherche |
| Liste défilante | bas du bloc + 8 (136 en recherche) jusqu'à 616 | sections repliables, lignes de réglage |
| Pied | 620-656 | filet à y 620 ; Annuler et Rétablir à gauche, Redémarrer à droite |

Début de la liste par onglet : Image 192 ; Mes filtres 196 ; Ambiance 196 (Selon le lieu, simple),
224 (ligne Filtre ou mode avancé), 252 (les deux). Liste : `TOPLEFT` (14, -début),
`BOTTOMRIGHT` (-36, 48).

### En-tête (28-60)

- Logo 32 x 32, `TOPLEFT` (14, -28). Titre « Panorama » `GameFontNormalLarge`, `LEFT` au `RIGHT` du logo + 8.
- Plus de sous-titre (`OPT_SUBTITLE` retiré) : il disait ce que le titre et le contenu disent déjà.
- **Sélecteur de mode** : 2 `UIRadioButtonTemplate` 16 x 16, « Simple » puis « Avancé », premier en
  `LEFT` (152, -44) depuis le `TOPLEFT` de la fenêtre, texte `GameFontHighlightSmall` 4 après, 12 entre
  les deux choix, clic sur le texte compris (`SetHitRectInsets`). Écrit `NS.db.advancedMode`, remet le
  défilement à 0, relance `Layout()`. Infobulle de chaque choix : `OPT_MODE_SIMPLE_TIP`,
  `OPT_MODE_ADVANCED_TIP`. C'est un choix d'affichage, pas un réglage : il n'est pas dans l'historique.
- **Menu Options** : `DropdownButton` `WowStyle1DropdownTemplate` 110 de large, `RIGHT` à (-14, -44)
  depuis le `TOPRIGHT`. Texte fixe « Options » (`OPT_OPTIONS`) quel que soit l'état des cases
  (`SetSelectionText` ou `OverrideText`, à confirmer à la première création). Contenu en § Menu Options.
- **Bouton Guide** : gris (§ 5, boutons), `UIMenuButtonStretchTemplate` (à confirmer à la première
  création ; repli : texte `GameFontNormal` sans fond, `GameFontHighlight` au survol), hauteur 22,
  largeur texte + 24 (min 70), `RIGHT` au `LEFT` du menu Options - 8. Infobulle `OPT_GUIDE_TIP`.
- Contrôle en allemand et en russe : le bord droit du choix « Avancé » reste à 16 au moins du bouton Guide.

### Bandeau d'état (64-92)

Répond en permanence à « pourquoi le monde a cette couleur ». Remplace les écrans de lignes grisées.

- Cadre `TOPLEFT` (14, -64) à `TOPRIGHT` (-14, -64), hauteur 28, fond blanc 0.04, filet 1 blanc 0.15 en bas.
- Étiquette « Look actuel : » (`STATUS_LABEL`) `GameFontNormal` or, `LEFT` (8, 0).
- Valeur `GameFontHighlight` blanc, 4 après l'étiquette, 1 ligne (`SetWordWrap(false)`), s'arrête 8
  avant le bouton ; tronquée : infobulle du bandeau avec le texte entier.
- Bouton d'action gris, hauteur 22, largeur texte + 24 (min 80), `RIGHT` (-3, 0). Caché quand sa cible
  est déjà affichée (onglet ouvert, et règle ouverte pour l'Ambiance).
- Infobulle du bandeau : texte entier, puis `STATUS_TIP` (ordre de priorité) en couleur aide.
- Relu par `NS.RefreshOptions()` (changement de réglage, de lieu, de moment, d'onglet).

Valeur = look + source. Look : nom du filtre du joueur appliqué (`NS.CustomFilterName`), sinon teinte
et intensité (`STATUS_TINT`, « Sépia 50 % »), sinon `STATUS_NO_TINT`. Jour et nuit : teinte de nuit
quand `NS.NightFactor()` ≥ 0.5, de jour sinon. Source, de la plus forte à la plus faible :

| Cas (premier vrai) | Source affichée | Bouton | Cible du bouton |
|---|---|---|---|
| Onglet Mes filtres ouvert, pas de recherche, filtre ouvert différent du look du monde | `STATUS_PREVIEW_FILTER` | aucun | — |
| Selon le lieu | `STATUS_BY_PLACE` : imposé par le lieu (zone réglée ou lieu, moment) | `STATUS_EDIT_RULE` | onglet Ambiance, règle de la zone réglée sinon du lieu (même choix que l'ouverture) |
| Jour et nuit, aucun filtre du joueur choisi en Base | `STATUS_SET_BY` : Jour et nuit (Jour, Nuit, Aube et crépuscule) | `STATUS_EDIT` | onglet Ambiance |
| Sinon | `STATUS_BY_YOU` | `STATUS_EDIT` | onglet Ambiance (caché s'il est déjà ouvert) |
| `STATUS_BY_PLACE` | imposé par le lieu (%s) | set by the place (%s) |

Exemples : « Look actuel : Brume · imposé par le lieu (Forêt d'Elwynn, Jour) » ;
« Look actuel : Chaude 25 % · imposé par Jour et nuit (Jour) » ;
« Look actuel : Sépia 50 % · choisi par vous ». Séparateur « · » (déjà dans les polices, utilisé par `DetectedText`).

### Onglets et recherche (96-128)

- 4 onglets `PanelTopTabButtonTemplate` : Image (`TAB_IMAGE`), HDR (`TAB_HDR`), Ambiance (`TAB_AMBIANCE`),
  Mes filtres (`TAB_MYFILTERS`).
  `NS.tabs = { "image", "hdr", "ambiance", "myfilters" }`, un seul groupe (`NS.tabGroupStart` retiré).
  Premier `TOPLEFT` (14, -96), 2 entre onglets, `PanelTemplates_TabResize(tab, 12)`. Rangée plus large
  que 394 (610 - 28 - 180 - 8) : marge intérieure 0. Filet blanc 0.15 de x 14 à -14, y 128.
- Les 4 onglets existent dans les deux modes. Onglet ouvert gardé dans `NS.db.tab` ; `filters` (avant
  1.9) ou `look` : `ambiance` (migration au chargement, Panorama.lua) ; autre valeur inconnue : premier onglet.
- Recherche : `SearchBoxTemplate` 180 x 20, `TOPRIGHT` (-14, -102). Le menu de langue quitte la rangée
  (menu Options).

### Onglet Image

Qualité, Interface et Avancé réunis. Bloc préréglages (136-184), puis la liste.

- Ligne 1 (136-156) : « Préréglages » `GameFontNormal` or à x 14. À droite (-14), seulement tant qu'un
  lieu impose ses réglages graphiques : « Ici : Bas · 400 » (`PLACE_PRESET_ACTIVE`). Mode avancé :
  bouton gris (texte + 24, min 100) qui ouvre l'onglet Ambiance sur la règle en cause. Mode simple :
  texte `GameFontHighlightSmall` couleur aide, sans bouton. Infobulle `PLACE_PRESET_TIP` dans les deux
  cas. Plus de bouton « Par lieu » quand aucun lieu n'impose rien.
- Ligne 2 (160-184) : 4 `UIPanelButtonTemplate` 142 x 24, `TOPLEFT` (14 + (i - 1) x 148, -160).
  Descriptions (`PRESET_*_DESC`, `OPT_PRESET_TIP`) en infobulle. Préréglage dont toutes les valeurs
  `levels` égalent les valeurs courantes : `LockHighlight()` et contour 2 or posé 2 à l'extérieur.

Sections, dans l'ordre (mode avancé) :

| Section (clé) | Lignes |
|---|---|
| Distance d'affichage (`SECTION_VIEW`) | farclip, horizonfarclip, volumeFog, volumeFogLevel |
| Végétation et détails (`SECTION_VEGETATION`) | detailDoodleDensity, groundEffectDensity, groundEffectDist |
| Ombres et lumière (`SECTION_SHADOWS`) | shadowLevel, shadowSoft, shadowTextureSize, sunShafts, SSAO, SSFX |
| Environnement (`SECTION_ENVIRONMENT`) | waterDetail, skyCloudLod, WeatherDensity, physicsLevel |
| Image (`SECTION_IMAGE`) | gxMultisample, ResampleAlwaysSharpen, ResampleSharpness, LowLatencyMode, bloomUserMult, Contrast, Brightness, Gamma, ffxDeath, violenceLevel, ProjectedTextures, spellClutter |
| Caméra, souris et interface (`SECTION_CAMERA`) | cameraDistanceMaxZoomFactor, rawMouseEnable, screenshotQuality, cameraZoomSpeed |
| Experts (`SECTION_EXPERT`), **repliée par défaut**, en dernier | reflectionMode, rippleDetail, terrainLodDist, wmoLodDist, entityLodDist, doodadLodScale, lodObjectCullSize, lodObjectFadeScale, horizonStart, groundEffectFade, particleMTDensity, DepthBasedOpacity |

Experts : clé `SECTION_EXPERT` absente de `NS.db.collapsed` = repliée ; ouverte par le joueur : `false`
enregistré. Les autres sections restent ouvertes par défaut. Titre de section : compteur « n modifiés »
à droite, visible replié compris, pour qu'un réglage expert changé ne passe pas inaperçu.
`SECTION_ADVANCED` disparaît comme titre.

Onglet HDR, sans bloc (liste à y 136), une section : Sortie HDR (`SECTION_HDR`) : HDROutput,
useHDRPeakBrightness, HDRPeakBrightness, HDRFactor, useHDRBrightness, HDRBrightness. Réglages de
l'écran, pas de la scène : hors d'Image.

### Onglet Mes filtres (clé `myfilters`)

Les filtres du joueur, réglés à part du choix : ouvrir un filtre ici ne change pas le look du monde. Le filtre qui s'applique se choisit dans l'onglet Ambiance (ligne Filtre).
Filtre ouvert : état de la fenêtre (`editedFilter`, 1 à l'ouverture du jeu), non enregistré ; ramené au
filtre suivant, ou au dernier, quand il disparaît (Supprimer, Annuler d'un Nouveau).

Bloc (136-160, 164-188) :

- Ligne 1 : « Filtre » (`LOOK_FILTER`) à x 14, menu 220 au x commun, défilant au-delà de 320 : un radio
  par filtre du joueur (pas de Base). Infobulle `MY_FILTER_TIP`. Puis bouton « Nouveau »
  (`CUSTOM_FILTER_ADD`, texte + 24, min 80) 8 après : crée un filtre et l'ouvre, sans le choisir.
- Ligne 2 : « Nom » (`CUSTOM_FILTER_RENAME`) à x 14, boîte de saisie 190 x 20 (24 caractères), puis
  « Supprimer » (8 après, texte + 24, min 80, confirmation, grisé quand il ne reste qu'un filtre).
- Les deux lignes dans les deux modes : l'onglet n'existe que pour créer et régler ses filtres.
- Menu et boîte partent du même x : 14 + largeur du plus long des libellés « Filtre » et « Nom » + 12.

Liste : sans titre de section ni repli, dans les deux modes. Teinte (vignettes, couleur du filtre),
Rouge, Vert, Bleu, Intensité, Vignettage, Grain, Contraste, Luminosité, Gamma du filtre ouvert. Mode
simple : Teinte et Intensité.

- Teinte d'un filtre du joueur : même grille de 7 vignettes (§ 8). Clic sur une teinte : `tintRed`,
  `tintGreen`, `tintBlue` = couleur de `TINTS` x 100 (entiers). « Aucune » : 100, 100, 100. Vignette
  choisie : celle dont les 3 valeurs égalent la couleur du filtre ; aucune ne correspond (couleur libre,
  défaut 85/80/100 compris) : aucune vignette marquée, les lignes Rouge, Vert, Bleu montrent la couleur.
  Intensité grisée quand la couleur vaut 100, 100, 100, comme `tintStrength` quand `tint` = 0.
- Aperçu : onglet ouvert, sans recherche : le monde montre les filtres de base avec le filtre ouvert
  (`NS.previewCustomFilter`, copie de `NS.db.filters` dans `NS.AppliedFilters`), Selon le lieu
  compris, jusqu'au changement d'onglet, à une recherche ou à la fermeture. Le bandeau le dit
  (`STATUS_PREVIEW_FILTER`) quand ce n'est pas déjà le look du monde.
- Recherche : les lignes d'un filtre du joueur restent hors recherche (elles doubleraient celles de Base).

### Onglet Ambiance

Le look du monde et ce qui le fait changer : filtre de base, teintes de jour et de nuit, règles par
lieu. Ancien onglet Filtres fondu ici (clé `look` supprimée).

Bloc (lignes de 28 ; libellés `GameFontNormal` or à x 14 ; contrôles au même x : 14 + plus long des
libellés Mode, Ici, Filtre, Règle + 12) :

- Ligne Mode (y -150) : « Mode » (`AMBIANCE_MODE`), menu 220, 3 choix : « Fixe » (`AMBIANCE_FIXED`),
  « Jour et nuit » (`autoDayNight`), « Selon le lieu » (`AMBIANCE_AUTO`). Valeurs internes inchangées :
  `ambiance.enabled` et `filters.autoDayNight`. Infobulle `AMBIANCE_MODE_TIP`.
- Ligne Ici (-178) : « Ici » (`AMBIANCE_HERE`), puis `NS.DetectedText()` en `GameFontHighlightLarge`
  blanc (lieu ou zone réglée · moment · réglages graphiques imposés), 1 ligne, tronqué avec infobulle.
  C'est l'information la plus grosse du bloc.
- Ligne Filtre (-206, `LOOK_FILTER`), **hors Selon le lieu** (modes Fixe et Jour et nuit, les deux
  modes d'affichage) : menu 220 `panel.customFilterMenu`, défilant au-delà de 320 : radio « Base »
  (`LOOK_BASE`), puis un radio par filtre du joueur. Écrit `NS.db.filters.customFilter` (0 = Base,
  n = filtre du joueur n). Infobulle `LOOK_FILTER_TIP`. Base se règle dans la liste ; un filtre du
  joueur dans l'onglet Mes filtres.
- Ligne Règle (mode avancé, `panel.ruleRow`) : « Règle » (`AMBIANCE_EDIT`), à -206 sans ligne Filtre,
  -234 avec (décalée de -28 dans `Layout`). Menu 220 du contexte édité (zones, puis groupes de
  contextes, sous-menu « Toutes les zones » par continent : contenu actuel), puis bouton « Revenir au
  type de zone » (`AMBIANCE_ZONE_RESET`, texte + 24, min 100) quand une zone est éditée. À l'ouverture
  de la fenêtre, la règle ouverte est celle du lieu du joueur (comportement actuel).

Début de la liste : 196, + 28 avec la ligne Filtre, + 28 en mode avancé (196, 224 ou 252).

Liste, dans l'ordre (`NS.filterSettings`) :

| Section (clé) | Contenu | Visible |
|---|---|---|
| Jour et nuit (`SECTION_DAYNIGHT`) | tintDay, tintDayStrength, tintNight, tintNightStrength | mode Jour et nuit, les deux modes d'affichage |
| Réglages du filtre (`SECTION_LOOK_FILTER`) | filtre du joueur choisi : note `LOOK_FROM_FILTER` + bouton gris « Modifier le filtre » (`RULE_EDIT_FILTER`, ouvre Mes filtres sur ce filtre). Sinon Teinte (vignettes, `tint`), Intensité (`tintStrength`) ; puis Vignettage, Grain | Fixe et Jour et nuit ; Teinte et Intensité cachées en Jour et nuit (remplacées par les teintes de jour et de nuit) |
| Ciel et bandes noires (`SECTION_LOOK_FRAME`) | Ciel, Intensité du ciel, Bandes noires (`NS.db.filters`) | Ciel et Intensité du ciel cachés en Selon le lieu ; Bandes noires toujours |
| Image (`SECTION_RULE_IMAGE`) | Préréglage, Distance des décors de la règle | mode avancé, règle de lieu ou de zone (agit dans tous les modes) |
| Look (`SECTION_RULE_LOOK`) | Filtre (`customFilter` de la règle), Teinte, Intensité, Vignettage, Grain ; règle de moment : Ciel, Intensité du ciel | mode avancé et Selon le lieu ; sinon une ligne note `RULE_LOOK_OFF` à la place |

- Selon le lieu : seules les bandes noires et les règles restent. Filtre, teinte, vignettage, grain et
  ciel de base sont cachés : la règle les remplace.
- Filtre de la règle = un filtre du joueur : les lignes Teinte, Intensité, Vignettage et Grain sont
  **cachées**, remplacées par une ligne note `RULE_LOOK_FROM_FILTER` avec le bouton « Modifier le filtre »
  (`RULE_EDIT_FILTER`) qui ouvre l'onglet Mes filtres sur ce filtre (le look de base ne change pas). Valeur 0 du menu : `CUSTOM_FILTER_NONE` (« Réglages ci-dessous »).
- Pas d'aperçu du look de base : le monde montre déjà ce qu'on règle (`NS.previewBase` et
  `STATUS_PREVIEW` supprimés).
- Mode simple : blocs Mode, Ici et Filtre ; section Jour et nuit en mode Jour et nuit ; en Selon le lieu,
  une ligne note `AMBIANCE_RULES_ADVANCED`. Les règles livrées s'appliquent quand même.
- Recherche : trouve les lignes de Réglages du filtre et de Ciel et bandes noires. Les lignes de règle
  restent hors recherche (copies de ces lignes).
- En Selon le lieu, les lignes du look de base (`NS.ambianceKeys`) quittent l'onglet ; la recherche les montre
  grisées avec `UNAVAILABLE_BY_PLACE`, et la commande slash les refuse avec ce texte. Bandes noires jamais grisées.

### Mode simple

`NS.db.advancedMode` faux (défaut d'une nouvelle installation, vrai pour qui avait déjà Panorama :
inchangé). Les 4 onglets restent ; chaque onglet montre une liste plate, sans titres de section ni repli :

| Onglet | Bloc | Lignes (`basic = true`, liste explicite) |
|---|---|---|
| Image | préréglages | farclip, volumeFog, shadowLevel, SSAO, waterDetail, gxMultisample, ResampleSharpness, Contrast, Brightness, cameraDistanceMaxZoomFactor |
| HDR | aucun | HDROutput, useHDRPeakBrightness, HDRPeakBrightness |
| Ambiance | Mode, Ici, Filtre (hors Selon le lieu) | Teinte, Intensité de Base (hors Jour et nuit) ; note `LOOK_FROM_FILTER` si un filtre du joueur est choisi ; tintDay, tintDayStrength, tintNight, tintNightStrength (mode Jour et nuit) |
| Mes filtres | menu, Nouveau, Nom, Supprimer | Teinte, Intensité du filtre ouvert |

`basic` posé sur `customFilter` n'est plus utile : le menu Filtre est dans le bloc. La recherche trouve toujours tous les réglages, dans les deux modes.

### Recherche

Texte non vide : aucun onglet sélectionné, bloc de l'onglet caché, liste à y 136 avec les lignes
correspondantes des 4 onglets, sous leur titre de section, sections repliées comprises (Experts
compris). Le bandeau reste. Aucun résultat : « Aucun réglage ne correspond » (`GameFontDisable`,
`OPT_NO_RESULT`), `TOPLEFT` (10, -16) de la liste. Recherche vidée : retour à l'onglet d'avant,
défilement à 0. Clic sur un onglet pendant une recherche : recherche vidée.

### Menu Options

Ouvert par le bouton Options de l'en-tête, menu Blizzard (`SetupMenu`), dans cet ordre :

1. « Langue » (`OPT_LANGUAGE`) : sous-menu de radios, « Langue du jeu » (`OPT_LANGUAGE_AUTO`) puis les
   10 langues écrites dans leur langue. Un choix enregistre `NS.db.locale` et recharge l'interface.
   Infobulle `OPT_LANGUAGE_TIP`.
2. Case « Appliquer à chaque connexion » (`OPT_APPLY_ON_LOGIN`), infobulle `OPT_APPLY_ON_LOGIN_TIP`.
3. Case « Bouton de la minimap » (`OPT_MINIMAP_BUTTON`), infobulle `OPT_MINIMAP_BUTTON_TIP`.
4. Séparateur (`CreateDivider`).
5. « Tout réinitialiser… » (`OPT_RESET_ALL`), texte rouge destructif `|cffff1a1a` (1, 0.1, 0.1),
   infobulle `OPT_RESET_ALL_TIP`, ouvre la confirmation `PANORAMA_RESET_ALL` existante.

Infobulles d'élément de menu : `SetTooltip` de la description d'élément.

### Pied (620-656)

- Filet blanc 0.15 `BOTTOMLEFT` (14, 44) à `BOTTOMRIGHT` (-14, 44).
- Annuler (`OPT_UNDO`) : `UIPanelButtonTemplate`, `BOTTOMLEFT` (14, 13), hauteur 22, largeur texte + 24
  (min 90). Défait le dernier pas de l'historique (`NS.Undo()`, 20 pas : CVars, marques « touché », filtres,
  ambiance, filtres du joueur). Rétablir (`OPT_REDO`) : même bouton, 6 à droite d'Annuler, `NS.Redo()`.
  Chacun grisé quand il n'y a rien à défaire ou à refaire ; infobulle gardée au survol
  (`SetMotionScriptsWhileDisabled`). Infobulles `OPT_UNDO_TIP`, `OPT_REDO_TIP`. Saisie en cours validée
  avant l'appel.
- Redémarrer (`OPT_RESTART`) : `UIPanelButtonTemplate`, `BOTTOMRIGHT` (-14, 13), hauteur 22, texte + 24
  (min 100). Un réglage `restart = true` modifié depuis le dernier redémarrage : `LockHighlight()` et
  contour 2 or (même rendu que le préréglage actif), infobulle complétée par `OPT_RESTART_PENDING`.
- Le même historique reste joignable hors de la fenêtre : `/pano undo`, `/pano redo`, menu de la minimap.

### Fenêtre du guide

Bouton Guide : ouvre ou ferme la fenêtre du guide (`Guide.lua`) : `BasicFrameTemplate` 590 x 640,
ancrée à droite de la fenêtre Panorama (4, 0), strate DIALOG, déplaçable, fermée par Échap. Titre = h1
du guide. Zone défilante `UIPanelScrollFrameTemplate`, contenu 530 de large. Polices : h2
`GameFontNormalLarge`, h3 `GameFontNormal`, texte `GameFontHighlight`, gras et code en or `ffd100`.
Écart au-dessus : h2 20, h3 12, paragraphe 8, élément de liste 4, ligne de tableau 8. Liste : repère à
x 0, texte à x 20. Tableau : colonne gauche 158 de large, droite à x 170. Texte : `Guide/<langue>.lua`,
généré depuis les `GUIDE*.md` par `tests/build_guide.lua`. Les `GUIDE*.md` nomment les anciens
onglets : à réécrire avec cette refonte.

## 3. Grille

- Marge gauche 14, liste 560 de large (x 14-574), zone de la barre de défilement 36. Barre cachée quand
  rien ne défile (`scrollBarHideable`).
- Pas vertical de 4 : toutes les hauteurs et marges sont des multiples de 4, sauf filets (1) et
  marqueur (2). Titre de section : 28 (au lieu de 30). Sous-titre de section : 24. Ligne : 28 ou 40.
- Colonnes d'une ligne de réglage (x relatifs à la ligne, 560) :

| Élément | x | Largeur |
|---|---|---|
| Marqueur « modifié » | 2 | 2 |
| Libellé | 10 (22 pour une ligne dépendante) | 276 (264) |
| Colonne de contrôle | 296 | 228 (jusqu'à 524) |
| Bouton Défaut (icône) | 532 | 22 |

Tous les contrôles partent de x 296 : un seul bord gauche fort. Ligne dépendante (`requires`) :
libellé décalé de 12, toujours placée juste sous la ligne dont elle dépend (vrai pour toutes les
dépendances actuelles) ; le décalage montre le lien, la ligne grisée n'a plus besoin d'explication écrite.

## 4. Typographie

| Rôle | Police | Couleur |
|---|---|---|
| Titre de la fenêtre | `GameFontNormalLarge` | or |
| Choix Simple / Avancé | `GameFontHighlightSmall` | blanc |
| Étiquette du bandeau | `GameFontNormal` | or |
| Valeur du bandeau | `GameFontHighlight` | blanc |
| Onglets, menus déroulants | police du gabarit | gabarit |
| Libellés de bloc (« Préréglages », « Filtre », « Mode », « Ici », « Règle ») | `GameFontNormal` | or |
| Lieu détecté (« Ici ») | `GameFontHighlightLarge` | blanc |
| Titre de section | `GameFontNormalLarge` | or |
| Sous-titre de section (Experts) | `GameFontNormal` | or |
| Compteur de section (« 3 modifiés ») | `GameFontHighlightSmall` | aide |
| Libellé de réglage | `GameFontHighlight` | blanc |
| Ligne note | `GameFontHighlightSmall` | aide |
| Valeur saisie (boîte) | `GameFontHighlight` | blanc, rouge erreur si invalide |
| Légende de vignette | `GameFontHighlightSmall`, `GameFontNormalSmall` si choisie | blanc / or |
| Ligne désactivée | mêmes polices | gris désactivé |

Libellé : 1 ligne, 2 au plus (russe, allemand) ; 2 lignes : ligne de 40. Plus de texte d'aide sous le
libellé, plus d'étoile « aussi dans un menu du jeu » : l'information passe dans l'infobulle.

## 5. Couleurs

| Rôle | RGB | Alpha | Usage |
|---|---|---|---|
| Or | 1, 0.82, 0 | 1 | titres, libellés de bloc, étiquette du bandeau, marqueur modifié, contours « choisi » |
| Blanc | 1, 1, 1 | 1 | libellés, valeurs, lieu détecté |
| Aide | 0.82, 0.82, 0.82 | 1 | infobulles (corps), compteur, ligne note, texte d'aide de la recherche |
| Rouge destructif | 1, 0.1, 0.1 (`GameFontRed`, `ff1a1a`) | 1 | « Tout réinitialiser… » du menu Options, et rien d'autre |
| Désactivé | 0.5, 0.5, 0.5 | 1 | ligne désactivée, et rien d'autre |
| Erreur | 1, 0.125, 0.125 | 1 | saisie invalide |
| Filet de ligne | 1, 1, 1 | 0.08 | sous chaque ligne (x 8 à -4) |
| Filet de section, onglets, bandeau, pied | 1, 1, 1 | 0.15 | |
| Fond de titre de section, fond du bandeau | 1, 1, 1 | 0.04 | |
| Survol (ligne, titre) | 1, 1, 1 | 0.06 | |
| Piste du curseur | 0, 0, 0 | 0.6 | |
| Repère de défaut sur la piste | 1, 1, 1 | 0.35 | |
| Contour de survol de vignette | 1, 1, 1 | 0.6 | |

Boutons, deux familles seulement :
- **Action sur les réglages** (préréglages, Nouveau, Supprimer, Revenir au type de zone, Annuler,
  Rétablir, Redémarrer) : `UIPanelButtonTemplate`, le bouton natif du jeu.
- **Navigation et aide** (Guide, bouton du bandeau, « Ici : Bas · 400 », Modifier le filtre) : gris,
  `UIMenuButtonStretchTemplate`. Raison : un bouton qui ne change aucun réglage ne doit pas avoir l'air
  d'une action ; l'en-tête n'a plus de bloc rouge.

Contrastes vérifiés (fond de fenêtre estimé `#1c1c1c`, bandeau et titre de section `#252525`,
survol `#2a2a2a`, fond de menu `#101010`, fond de boîte de saisie noir) :

| Paire | Fond | Bandeau | Survol | Verdict |
|---|---|---|---|---|
| Blanc | 17.0 | 15.3 | 14.4 | AAA |
| Or | 11.7 | 10.5 | 9.8 | AAA |
| Aide 0.82 | 11.2 | 10.0 | 9.4 | AAA |
| Rouge destructif, sur menu `#101010` | 4.4 | | | 4.9 sur le menu : AA |
| Désactivé 0.5 | 4.3 | 3.9 | 3.6 | exempté (désactivé) |
| Erreur sur boîte noire | 5.5 | | | AA |

## 6. États

| État | Rendu |
|---|---|
| Survol de ligne | fond blanc 0.06 sur toute la ligne, contrôles compris (mécanisme actuel) |
| Valeur ≠ défaut | marqueur or 2 x (hauteur - 12) à x 2, centré ; bouton Défaut actif |
| Valeur = défaut | pas de marqueur ; bouton Défaut désactivé (icône désaturée, alpha 0.5) |
| Défaut | `NS.GameDefault(setting)` pour une CVar, `setting.default` pour un filtre, valeur livrée ou du type de zone pour une règle |
| Choix courant (1024/2048, MSAA, Simple/Avancé) | bouton radio coché ; jamais un bouton désactivé |
| Ligne désactivée | libellé gris 0.5, contrôle `Disable()`, curseur `SetEnabled(false)` + poignée `SetVertexColor(0.5, 0.5, 0.5)`, vignettes alpha 0.5, pas de survol. La raison (`NS.UnavailableReason`) est dans l'infobulle, en or ; la ligne garde sa hauteur |
| Réglage piloté par un automatisme | la ligne peut être grisée ; le bandeau d'état dit qui pilote et ouvre l'endroit où le changer |
| Redémarrage en attente | bouton Redémarrer surligné et contour or (§ 2, Pied) |
| Rien à annuler ou à rétablir | Annuler ou Rétablir grisé, infobulle gardée |
| Saisie en cours | contour du gabarit ; texte rouge erreur tant que non numérique ou hors bornes |

Dépendances qui désactivent une ligne : `volumeFogLevel` si `volumeFog` coupé,
`HDRPeakBrightness` et `HDRFactor` si `useHDRPeakBrightness` coupé, `HDRBrightness` si
`useHDRBrightness` coupé, `tintStrength` si `tint` = 0 (ou couleur 100, 100, 100 pour un filtre du
joueur), `skyStrength` si `sky` = 0, `tintDayStrength` si `tintDay` = 0, `tintNightStrength` si
`tintNight` = 0. Champ `requires` dans la définition du réglage. Pilotage : Teinte et Intensité de Base
cachées en mode Jour et nuit ; `tintDay`, `tintNight` et leurs intensités grisés quand un filtre du
joueur est choisi en Base (il les remplace). Plus aucune ligne de Base n'est grisée par
Selon le lieu : elles sont cachées, la règle les remplace.

## 7. Composant : ligne de réglage

- Cadre 560 de large, hauteur **28** (libellé sur 1 ligne) ou **40** (2 lignes). `item.height` lu par `Layout()`.
- Libellé `TOPLEFT` (10, -8), largeur 276, `SetMaxLines(2)` ; ligne dépendante : (22, -8), largeur 264.
- Contrôles : point `LEFT` à (x, -14) depuis le haut de la ligne, centrés sur la première ligne du libellé.
- Infobulle (survol du libellé, `ANCHOR_RIGHT`) : libellé blanc ; aide complète (`_tip`) en couleur
  aide ; mention de redémarrage ; « aussi dans un menu du jeu » ; raison de désactivation en or.
- Curseur numérique : piste 172 x 16 à x 296 (poignée `UI-SliderBar-Button-Horizontal`, piste noire 0.6
  de 6 de haut), boîte de saisie à x 480 (296 + 184). Repère de défaut : trait 1 x 10 blanc 0.35.
- Valeur nommée (`names` : Faible latence, Filtre d'une règle, Ciel, contraste…) : `WowStyle1DropdownTemplate`
  220 à x 296, une option par valeur, défilant au-delà de 320 de haut.
- Case (booléen) : `UICheckButtonTemplate` 26 x 26 à x 292 (la case dessinée tombe sur x 296), sans texte.
- Choix (`choices`) : `UIRadioButtonTemplate` 16 x 16 à partir de x 296, texte `GameFontHighlightSmall`
  4 après, 12 entre deux choix.
- Bouton Défaut : `Button` 22 x 22 à x 532, icône `Interface\\Buttons\\UI-RefreshButton`, infobulle
  « Défaut : <valeur formatée> ». Désactivé quand la valeur est déjà la valeur par défaut.

### Ligne note

Hauteur 28. Texte `GameFontHighlightSmall` couleur aide à (10, -14) `LEFT`, largeur 276, 1 ligne ;
bouton gris facultatif ancré à droite (-4), texte + 24 ; le texte s'arrête 8 avant lui. Pas de marqueur, pas de bouton Défaut, pas de survol.
Sert seulement à `LOOK_FROM_FILTER`, `RULE_LOOK_FROM_FILTER`, `RULE_LOOK_OFF` et `AMBIANCE_RULES_ADVANCED`.

### Sous-titre de section

Hauteur 24, texte `GameFontNormal` or à x 10, ni fond ni repli. Seulement dans la section Experts.

### Boîte de saisie

- `InputBoxTemplate` 48 x 20, `SetAutoFocus(false)`, `SetMaxLetters(6)`, `SetJustifyH("RIGHT")`,
  police `GameFontHighlight`. Contenu : `FormatValue` (1 décimale si `step` < 1).
- Le curseur tiré met la boîte à jour (aperçu).
- Saisie : la virgule vaut un point (« 0,5 »). Texte rouge tant que non numérique ou hors
  `min`-`max` ; blanc sinon. Rien n'est écrit pendant la frappe.
- Entrée ou perte du focus : nombre valide = borné à `min`-`max`, arrondi au `step`, écrit par le
  même `change()` que le curseur, curseur repositionné. Non numérique = valeur courante remise.
- Échap : valeur courante remise, focus rendu (la fenêtre ne se ferme pas au premier Échap).
- Tab : focus à la boîte suivante visible, dans l'ordre d'affichage.
- Infobulle : « min - max » (trait d'union ASCII).

## 8. Composant : grille de vignettes de teinte

Remplace le curseur de `tint` (Base), de la couleur d'un filtre du joueur (Mes filtres), de `tintDay` et
`tintNight` (Ambiance, Jour et nuit) et de la teinte d'une règle. L'intensité remise à son défaut au
clic est celle nommée par `strength` (`tintStrength` pour un filtre du joueur).

- Libellé sur la ligne de 28 comme une ligne normale ; bouton Défaut à x 532, y -14.
- Grille `TOPLEFT` (10, -28) : **7 vignettes sur une rangée** (Aucune + 6 teintes, ordre de `TINTS`),
  62 x 40, 6 entre deux (largeur totale 470).
- Image : `Media\\tint-preview.tga`, capture 256 x 128, `SetTexCoord(0.1125, 0.8875, 0, 1)`. Teinte par
  `SetVertexColor(r, g, b)` avec la couleur de `TINTS` à 100 %. « Aucune » : capture sans teinte.
- Légende sous la vignette (-3), largeur 68, centrée, 1 ligne : nom (`TINT_*`).
- Survol : contour 1 blanc 0.6, infobulle avec le nom.
- Choisie : contour 2 or posé 2 à l'extérieur, légende en `GameFontNormalSmall`. Filtre du joueur à
  couleur libre : aucune vignette choisie.
- Clic : valeur écrite, `NS.ApplyFilters()` aussitôt. Intensité à 0 : remise à son défaut (50), pour
  qu'une teinte choisie se voie toujours.
- Hauteur de la ligne : 28 + 40 + 3 + 12 + 8 = 91, arrondie à **92**.

## 9. Interdits

- Toute couleur hors du tableau § 5 : pas de cyan, de bleu, de dégradé (`SetGradient`), d'ombre portée.
- Police hors `GameFont*` et police propre d'un gabarit ; pas de `SetFont` à taille arbitraire.
- Texte d'aide permanent sous un libellé ou sous un bloc : il va en infobulle. Seules exceptions, les
  3 lignes note du § 7, sur une ligne.
- Un même réglage modifiable à deux endroits : chaque valeur a une seule ligne (les règles d'ambiance
  ont leurs propres valeurs, pas des copies de celles de Base dans l'onglet Ambiance).
- Écran de lignes grisées sans explication : le bandeau d'état dit qui pilote.
- Rouge (texte ou bouton) pour autre chose qu'une action destructive ; `UIPanelButtonTemplate` pour la
  navigation ou l'aide.
- Case à cocher pour un choix d'affichage (mode Simple / Avancé) : c'est le sélecteur de l'en-tête.
- Réglage global (langue, minimap, connexion, réinitialisation) dans un onglet ou dans la rangée d'onglets.
- Bouton désactivé pour dire « choisi » : désactivé veut dire indisponible.
- Gris 0.5 (`GameFontDisable*`) pour un texte actif : réservé à l'état désactivé.
- Largeur fixe sur un bouton à texte localisé : largeur = texte + 24 (allemand et russe).
- Texte « [+] / [-] » : icônes `Interface\\Buttons\\UI-PlusButton-Up` / `UI-MinusButton-Up` 14 x 14.
- Écriture de CVar à chaque frappe ou à chaque pas de curseur tenu.
- Contenu de ligne centré ou contrôle aligné à droite selon sa largeur : colonnes fixes du § 3.
- Texture tierce autre que `Media\\logo` et `Media\\tint-preview`. Aucun emoji ni symbole décoratif
  (étoile pleine, coche, flèche Unicode) dans un texte : glyphes absents des polices du jeu selon la langue.
  Séparateur autorisé : « · ».

## 10. Clés de locale

Nouvelles clés (texte frFR / enUS ; les 8 autres langues à traduire) :

| Clé | frFR | enUS |
|---|---|---|
| `TAB_IMAGE` | Image | Image |
| `TAB_MYFILTERS` | Mes filtres | My filters |
| `OPT_MODE_SIMPLE` | Simple | Simple |
| `OPT_MODE_SIMPLE_TIP` | Les réglages principaux seulement : préréglages, qualité courante, choix du filtre et de la teinte, mode d'ambiance. | Main settings only: presets, common quality settings, filter and tint choice, ambiance mode. |
| `OPT_MODE_ADVANCED` | Avancé | Advanced |
| `OPT_MODE_ADVANCED_TIP` | Tous les réglages : règles d'ambiance par lieu, section Experts. | Every setting: ambiance rules per place, Experts section. |
| `OPT_OPTIONS` | Options | Options |
| `OPT_LANGUAGE` | Langue | Language |
| `SECTION_MODIFIED` | %d modifiés | %d changed |
| `OPT_RESTART_PENDING` | Un réglage modifié attend ce redémarrage. | A changed setting is waiting for this restart. |
| `STATUS_LABEL` | Look actuel : | Current look: |
| `STATUS_TINT` | %s %d %% | %s %d%% |
| `STATUS_NO_TINT` | sans teinte | no tint |
| `STATUS_SET_BY` | imposé par %s (%s) | set by %s (%s) |
| `STATUS_BY_YOU` | choisi par vous | chosen by you |
| `STATUS_PREVIEW_FILTER` | aperçu, le look actuel reprend hors de cet onglet | preview, the current look resumes outside this tab |
| `STATUS_EDIT_RULE` | Modifier cette règle | Edit this rule |
| `STATUS_EDIT` | Modifier | Edit |
| `STATUS_TIP` | Le plus fort l'emporte : le mode d'ambiance (Selon le lieu, puis Jour et nuit), puis le filtre choisi dans l'onglet Ambiance. Un filtre choisi remplace la teinte, le vignettage et le grain. | The strongest wins: the ambiance mode (By place, then Day and night), then the filter chosen in the Ambiance tab. A chosen filter replaces tint, vignette and grain. |
| `LOOK_FILTER` | Filtre | Filter |
| `LOOK_FILTER_TIP` | Base : la teinte, le vignettage et le grain réglés ci-dessous. Un de vos filtres : sa couleur, son vignettage, son grain, et son contraste, sa luminosité et son gamma. Modes Fixe et Jour et nuit. | Base: the tint, vignette and grain set below. One of your filters: its colour, vignette, grain, and its contrast, brightness and gamma. Fixed and Day and night modes. |
| `LOOK_BASE` | Base | Base |
| `SECTION_LOOK_FILTER` | Réglages du filtre | Filter settings |
| `SECTION_LOOK_FRAME` | Ciel et bandes noires | Sky and black bars |
| `SECTION_EXPERT` | Experts (console seulement) | Experts (console only) |
| `TAB_HDR` | HDR | HDR |
| `SECTION_HDR` | Sortie HDR | HDR output |
| `SECTION_RULE_IMAGE` | Image | Image |
| `SECTION_RULE_LOOK` | Look | Look |
| `RULE_LOOK_FROM_FILTER` | Teinte, vignettage et grain : ceux du filtre %s. | Tint, vignette and grain: those of filter %s. |
| `RULE_EDIT_FILTER` | Modifier le filtre | Edit filter |
| `LOOK_FROM_FILTER` | Réglé par le filtre %s. | Set by filter %s. |
| `MY_FILTER_TIP` | Filtre ouvert, réglé par les lignes en dessous et montré en aperçu. Celui qui s'applique se choisit dans l'onglet Ambiance. | Open filter, set by the rows below and shown as a preview. The one that applies is chosen in the Ambiance tab. |
| `RULE_LOOK_OFF` | Le look par lieu s'applique en mode Selon le lieu. | Look per place applies in By place mode. |
| `AMBIANCE_HERE` | Ici | Here |
| `AMBIANCE_RULES_ADVANCED` | Les règles par lieu se règlent en mode Avancé. | Rules per place are set in Advanced mode. |
| `AMBIANCE_FIXED` | Fixe | Fixed |
| `UNAVAILABLE_BY_PLACE` | Réglé par le mode Selon le lieu. | Set by By place mode. |

Textes modifiés (même clé) :

| Clé | frFR | enUS |
|---|---|---|
| `AMBIANCE_EDIT` | Règle | Rule |
| `AMBIANCE_ZONE_RESET` | Revenir au type de zone | Back to zone type |
| `CUSTOM_FILTER_NONE` | Réglages ci-dessous | Settings below |
| `customFilter` | Filtre | Filter |
| `customFilter_tip` | Un de vos filtres (onglet Mes filtres) remplace la teinte, le vignettage et le grain de cette règle. Réglages ci-dessous : ceux de la règle. | One of your filters (My filters tab) replaces this rule's tint, vignette and grain. Settings below: the rule's own. |
| `autoDayNight` | Jour et nuit | Day and night |
| `autoDayNight_tip` | Pas en même temps que le mode Selon le lieu : activer l'un coupe l'autre. Pose sur tout l'écran la teinte de jour le jour et la teinte de nuit la nuit (jour et nuit du jeu). Passage progressif de 19 h à 21 h et de 5 h à 7 h (heure du serveur). | Not together with By place mode: turning one on turns the other off. Lays the day tint over the whole screen by day and the night tint at night (game's day and night). Gradual from 19:00 to 21:00 and from 5:00 to 7:00 (server time). |
| `AMBIANCE_AUTO` | Selon le lieu | By place |
| `AMBIANCE_MODE_TIP` | Fixe : le même filtre partout. Jour et nuit : une teinte de jour et une teinte de nuit (heure du jeu). Selon le lieu : teinte, vignettage, grain et ciel suivent le lieu et le moment de la journée. | Fixed: the same filter everywhere. Day and night: a day tint and a night tint (game time). By place: tint, vignette, grain and sky follow the place and the time of day. |
| `preset_tip` | Préréglage graphique appliqué tant que vous êtes dans ce lieu, quel que soit le mode d'ambiance. Mes réglages : rien ne change. | Graphics preset applied while you are in this place, whatever the ambiance mode. My settings: nothing changes. |
| `viewDistance_tip` | Distance des décors appliquée tant que vous êtes dans ce lieu, quel que soit le mode d'ambiance. Elle passe avant celle du préréglage. Mes réglages : rien ne change. | Scenery distance applied while you are in this place, whatever the ambiance mode. It comes before the one of the preset. My settings: nothing changes. |
| `OPT_MINIMAP_BUTTON` | Bouton de la minimap | Minimap button |
| `OPT_RESET_ALL` | Tout réinitialiser… | Reset all… |
| `tintDay_tip`, `tintNight_tip` | Remplace la teinte de base le jour. / Remplace la teinte de base la nuit. | Replaces the base tint during the day. / Replaces the base tint at night. |
| `CUSTOM_FILTER_DELETE_TIP` | Supprime ce filtre. Le filtre de l'onglet Ambiance et les règles qui l'utilisaient repassent sans filtre. Il reste toujours un filtre. | Deletes this filter. The Ambiance tab filter and the rules that used it go back to no filter. One filter always remains. |
| `CUSTOM_FILTER_DELETE_CONFIRM` | Supprimer le filtre %s ?\nLe filtre de l'onglet Ambiance et les règles qui l'utilisent repassent sans filtre. | Delete filter %s?\nThe Ambiance tab filter and the rules that use it go back to no filter. |

À relire pour le nom d'onglet disparu (Qualité) :
`PLACE_PRESET_TIP`, `OPT_RESET_ALL_TIP`, `OPT_RESET_ALL_CONFIRM`.

Clés retirées : `TAB_QUALITY`, `TAB_FILTERS`, `TAB_INTERFACE`, `TAB_ADVANCED`,
`OPT_ADVANCED_MODE`, `OPT_ADVANCED_MODE_TIP`, `OPT_SUBTITLE`, `SECTION_HDR`,
`SECTION_ADVANCED`, `SECTION_FILTERS`, `CUSTOM_FILTER_EDIT`, `CUSTOM_FILTER_TIP`,
`PLACE_PRESET_BUTTON`, `AMBIANCE_AUTO_TIP` (plus aucun appelant), `TAB_LOOK`, `STATUS_PREVIEW`.

Clés gardées : `OPT_UNDO`, `OPT_UNDO_TIP`, `OPT_REDO`, `OPT_REDO_TIP` (boutons du pied) ;
`AMBIANCE_DETECTED` (sortie de `/pano status`).
