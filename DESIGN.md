# DESIGN.md : fenêtre d'options Panorama

Référence de la fenêtre `PanoramaFrame` (Options.lua). Toute retouche de l'interface suit ce fichier.
Unités : unités d'interface WoW (échelle UI 1). Couleurs : RGB 0-1.

## 1. Direction

**Natif, dense, lisible.** Panorama est un panneau de réglages techniques ouvert en jeu, à côté des
fenêtres Blizzard : il doit avoir l'air d'en être une. Palette et polices sont celles du client
(constantes `NORMAL_FONT_COLOR`, `HIGHLIGHT_FONT_COLOR`, `GRAY_FONT_COLOR`, `RED_FONT_COLOR`),
gris neutres compris : c'est la charte de l'hôte, pas un réglage par défaut. La direction cyan du
2026-11-14 est abandonnée, ne pas la reprendre.

Densité « outil » : beaucoup de lignes visibles, colonnes fixes, aucune décoration. La seule image
de la fenêtre, hors logo, est la capture teintée des vignettes de teinte : c'est là que l'œil doit aller.

## 2. Structure

Fenêtre `BasicFrameTemplate` 610 x 640, déplaçable, fermée par Échap (inchangé).

| Zone | y (depuis le haut) | Contenu |
|---|---|---|
| Barre de titre | 0-24 | gabarit, bouton fermer ; aucun texte ajouté |
| En-tête | 26-66 | logo 32 x 32, titre, sous-titre ; recherche à droite |
| Onglets | 70-102 | 4 onglets, filet sous la rangée à y 102 |
| Bloc préréglages | 110-158 | onglet Qualité seulement |
| Liste défilante | 166 (Qualité) ou 110 (autres) jusqu'à 592 | sections repliables, lignes de réglage |
| Pied | 596-632 | filet à y 596, 2 cases à gauche, Tout réinitialiser et Redémarrer à droite |

### Onglets (nouveau)

Gabarit `PanelTopTabButtonTemplate` (moteur retail ; confirmer à la première création en jeu),
`PanelTemplates_SetNumTabs`, `PanelTemplates_SetTab`, `PanelTemplates_TabResize(tab, 12)`.
Premier onglet à x 14, 2 entre onglets. Onglet ouvert gardé dans `NS.db.tab`.

Sélecteur de langue à droite de la rangée : `WowStyle1DropdownTemplate` 130 de large, `TOPRIGHT` (-14, -73).
Choix : « Langue du jeu » (`OPT_LANGUAGE_AUTO`) puis les 10 langues, chacune écrite dans sa langue.
Un choix enregistre `NS.db.locale` et recharge l'interface ; infobulle `OPT_LANGUAGE_TIP`.

Bouton « Guide » (`OPT_GUIDE`, `UIPanelButtonTemplate`, 70 de large au moins, texte + 24) à gauche du sélecteur, 8 d'écart ;
infobulle `OPT_GUIDE_TIP`. Il ouvre ou ferme la fenêtre du guide (`Guide.lua`) :
`BasicFrameTemplate` 590 x 640, ancrée à droite de la fenêtre Panorama (4, 0), strate DIALOG,
déplaçable, fermée par Échap. Titre = h1 du guide. Zone défilante `UIPanelScrollFrameTemplate`,
contenu 530 de large. Polices : h2 `GameFontNormalLarge`, h3 `GameFontNormal`, texte
`GameFontHighlight`, gras et code en or `ffd100`. Écart au-dessus : h2 20, h3 12, paragraphe 8,
élément de liste 4, ligne de tableau 8. Liste : repère à x 0, texte à x 20. Tableau : colonne gauche
158 de large, droite à x 170. Texte : `Guide/<langue>.lua`, généré depuis les `GUIDE*.md`
par `tests/build_guide.lua`.

| Onglet | Sections, dans l'ordre | Lignes |
|---|---|---|
| Qualité | Vue, Végétation, Ombres, Environnement, Image | ~22 |
| Filtres | Filtres | 5 |
| Caméra et interface | Caméra, Barres de noms, Texte de combat | ~22 |
| Avancé | HDR, Avancé (console seulement) | ~14 |

Raison : les préréglages ne touchent que l'onglet Qualité (réglages à `levels`), ils y vivent seuls.
Les réglages « console seulement » (HDR, LOD) sortent du chemin courant. Les filtres, visuels,
ont leur propre page. Libellés d'onglet : 4 clés de locale neuves (`TAB_QUALITY`, `TAB_FILTERS`,
`TAB_INTERFACE`, `TAB_ADVANCED`), courtes (« Avancé », pas « Avancé (console seulement) »).

Toutes les sections sont ouvertes par défaut ; le repli reste (`NS.db.collapsed`), l'ancien défaut
« Avancé replié » tombe puisque l'onglet sépare déjà.

### En-tête

- Logo 32 x 32, `TOPLEFT` (14, -30).
- Titre « Panorama » : `GameFontNormalLarge`, `TOPLEFT` du logo + (8, -1).
- Sous-titre : `GameFontHighlightSmall` couleur aide, sous le titre (0, -3), largeur 340, 2 lignes max.
- Recherche : `SearchBoxTemplate` 180 x 20, `TOPRIGHT` (-14, -36).

### Recherche

Texte non vide : aucun onglet sélectionné, bloc préréglages caché, la liste montre les lignes
correspondantes de **tous** les onglets, sous leur titre de section, sections repliées comprises.
Aucun résultat : « Aucun réglage ne correspond » (`GameFontDisable`, clé neuve `OPT_NO_RESULT`),
`TOPLEFT` (10, -16) de la liste, aligné à gauche. Recherche vidée : retour à l'onglet d'avant, défilement à 0.

### Bloc préréglages (onglet Qualité)

- Ligne 1 (y 110-130) : « Préréglages » `GameFontNormal` à x 14 ; bouton Annuler le dernier
  préréglage aligné à droite (-14), hauteur 22, largeur = largeur du texte + 24 (min 120).
- Ligne 2 (y 134-158) : 4 boutons `UIPanelButtonTemplate` 24 de haut, largeur égale
  (586 - 3 x 6) / 4 = 142, espacés de 6.
- Descriptions des préréglages (`PRESET_*_DESC`) et `OPT_PRESET_TIP` : dans l'infobulle de chaque
  bouton (titre blanc, description en couleur aide). Plus de texte sous les boutons.
- Préréglage dont toutes les valeurs `levels` égalent les valeurs courantes : `LockHighlight()`.
  Aucun ne correspond : aucun bouton marqué.

### Pied

- Cases « Appliquer à chaque connexion » et « Bouton minimap » : `UICheckButtonTemplate` 26 x 26,
  première en `BOTTOMLEFT` (10, 11), seconde 16 après le texte de la première. Axe commun : y 24 depuis le bas.
- À droite : bouton Tout réinitialiser (avec fenêtre de confirmation) à 8 à gauche du bouton
  Redémarrer, `BOTTOMRIGHT` (-14, 13), hauteur 22, largeur texte + 24 (min 100).

## 3. Grille

- Marge gauche 14, liste 560 de large (x 14-574), zone de la barre de défilement 36.
- Pas vertical de 4 : toutes les hauteurs et marges sont des multiples de 4, sauf filets (1) et
  marqueur (2).
- Colonnes d'une ligne de réglage (x relatifs à la ligne, 560) :

| Élément | x | Largeur |
|---|---|---|
| Marqueur « modifié » | 2 | 2 |
| Libellé et aide | 10 | 276 |
| Colonne de contrôle | 296 | 228 (jusqu'à 524) |
| Bouton Défaut (icône) | 532 | 22 |

Tous les contrôles partent de x 296 : un seul bord gauche fort, pas d'alignement à droite variable.

## 4. Typographie

| Rôle | Police | Couleur |
|---|---|---|
| Titre de la fenêtre | `GameFontNormalLarge` | or |
| Onglets | police du gabarit | gabarit |
| Titre de section | `GameFontNormalLarge` | or |
| Compteur de section (« 3 modifiés ») | `GameFontHighlightSmall` | aide |
| « Préréglages » | `GameFontNormal` | or |
| Libellé de réglage | `GameFontHighlight` | blanc |
| Aide sous le libellé | `GameFontHighlightSmall` + `SetTextColor` | aide |
| Valeur saisie (boîte) | `GameFontHighlight` | blanc, rouge si invalide |
| Valeur nommée (Faible latence) | `GameFontHighlightSmall` | blanc |
| Légende de vignette | `GameFontHighlightSmall`, `GameFontNormalSmall` si choisie | blanc / or |
| Ligne désactivée | mêmes polices | gris désactivé |

Libellé : 2 lignes max (russe : 48 caractères), aide : 2 lignes max (110 caractères mesurés en
fr/de/ru). Texte tronqué (`SetMaxLines`) : infobulle de la ligne avec le texte entier.
Étoile « aussi dans un menu du jeu » : couleur aide, plus en or.

## 5. Couleurs

| Rôle | RGB | Alpha | Usage |
|---|---|---|---|
| Or | 1, 0.82, 0 | 1 | titres, marqueur modifié, contour de vignette choisie |
| Blanc | 1, 1, 1 | 1 | libellés, valeurs |
| Aide | 0.72, 0.72, 0.72 | 1 | aide, sous-titre, étoile, compteur |
| Désactivé | 0.5, 0.5, 0.5 | 1 | ligne désactivée, et rien d'autre |
| Erreur | 1, 0.125, 0.125 | 1 | saisie invalide |
| Filet de ligne | 1, 1, 1 | 0.08 | sous chaque ligne (x 8 à -4) |
| Filet de section, onglets, pied | 1, 1, 1 | 0.15 | |
| Fond de titre de section | 1, 1, 1 | 0.04 | |
| Survol (ligne, titre) | 1, 1, 1 | 0.06 | |
| Piste du curseur | 0, 0, 0 | 0.6 | |
| Repère de défaut sur la piste | 1, 1, 1 | 0.35 | |
| Contour de survol de vignette | 1, 1, 1 | 0.6 | |

Contrastes vérifiés (fond de fenêtre estimé `#1c1c1c`, survol `#2a2a2a`, fond de boîte de saisie noir) :

| Paire | Fond | Survol | Verdict |
|---|---|---|---|
| Blanc | 17.0 | 14.4 | AAA |
| Or | 11.7 | 9.8 | AAA |
| Aide 0.72 | 8.6 | 7.2 | AAA |
| Désactivé 0.5 | 4.3 | 3.6 | exempté (désactivé) ; c'est pourquoi l'aide n'est plus en 0.5 |
| Erreur sur boîte noire | 5.5 | | AA |

## 6. États

| État | Rendu |
|---|---|
| Survol de ligne | fond blanc 0.06 sur toute la ligne, contrôles compris (mécanisme actuel gardé) |
| Valeur ≠ défaut | marqueur or 2 x (hauteur - 12) à x 2, centré verticalement ; bouton Défaut actif |
| Valeur = défaut | pas de marqueur ; bouton Défaut désactivé (`SetEnabled(false)`, icône désaturée) |
| Défaut | celui de `NS.GameDefault(setting)` pour une CVar, `setting.default` pour un filtre |
| Choix courant (1024/2048, MSAA) | bouton radio coché ; jamais un bouton désactivé |
| Ligne désactivée | libellé et aide en gris 0.5, contrôle `Disable()`, curseur `SetEnabled(false)` + poignée `SetVertexColor(0.5, 0.5, 0.5)`, pas de survol |
| Saisie en cours | contour du gabarit ; texte rouge tant que non numérique ou hors bornes |
| Recherche | voir § 2 |

Dépendances qui désactivent une ligne : `volumeFogLevel` si `volumeFog` coupé,
`HDRPeakBrightness` si `useHDRPeakBrightness` coupé, `HDRBrightness` si `useHDRBrightness` coupé,
`tintStrength` si `tint` = 0. Champ `requires` dans la définition du réglage.

## 7. Composant : ligne de réglage

- Cadre 560 de large. Hauteur = 8 + hauteur du libellé + 4 + hauteur de l'aide + 8, arrondie au
  multiple de 4 supérieur, minimum 44 (1+1 ligne : 44, 1+2 : 56, 2+2 : 68). `Layout()` lit déjà
  `item.height`.
- Libellé `TOPLEFT` (10, -8), largeur 276. Aide sous le libellé (0, -4), largeur 276.
- Contrôles centrés sur la première ligne du libellé : point d'ancrage `LEFT` à (x, -14) depuis le
  haut de la ligne, pas au centre de la ligne.
- Curseur numérique : piste 172 x 16 à x 296 (poignée `UI-SliderBar-Button-Horizontal`, piste noire
  0.6 de 6 de haut), boîte de saisie à x 476.
- Repère de défaut : trait 1 x 10 blanc 0.35 sur la piste, à la position de la valeur par défaut.
- Valeur nommée (`names`, Faible latence) : curseur 128 à x 296, nom à x 432, largeur 92, sans boîte.
- Case (booléen) : `UICheckButtonTemplate` 26 x 26 à x 292 (la case dessinée tombe sur x 296).
  Plus de texte « Activé / Désactivé » à côté : la case suffit.
- Choix (`choices`) : `UIRadioButtonTemplate` 16 x 16 à partir de x 296, texte `GameFontHighlightSmall`
  4 après, 12 entre deux choix.
- Bouton Défaut : `Button` 22 x 22 à x 532, icône `Interface\\Buttons\\UI-RefreshButton`, infobulle
  « Défaut : <valeur formatée> ». Désactivé quand la valeur est déjà la valeur par défaut.
- Infobulle de ligne (survol du libellé) : libellé blanc, aide complète, mention redémarrage, menu du jeu.

### Boîte de saisie

- `InputBoxTemplate` 48 x 20, `SetAutoFocus(false)`, `SetMaxLetters(6)`, `SetJustifyH("RIGHT")`,
  police `GameFontHighlight`. Contenu : `FormatValue` (1 décimale si `step` < 1).
- Le curseur tiré met la boîte à jour (aperçu, comme le texte de valeur aujourd'hui).
- Saisie : la virgule vaut un point (« 0,5 »). Texte rouge tant que non numérique ou hors
  `min`-`max` ; blanc sinon. Rien n'est écrit pendant la frappe.
- Entrée ou perte du focus : nombre valide = borné à `min`-`max`, arrondi au `step`, écrit par le
  même `change()` que le curseur, curseur repositionné. Non numérique = valeur courante remise.
- Échap : valeur courante remise, focus rendu (la fenêtre ne se ferme pas au premier Échap).
- Tab : focus à la boîte suivante visible, dans l'ordre d'affichage.
- Infobulle : « min - max » (trait d'union ASCII).

## 8. Composant : grille de vignettes de teinte

Remplace le curseur du réglage `tint`. Ligne spéciale, pleine largeur, en tête de l'onglet Filtres,
suivie de Intensité de teinte, Vignettage, Grain, Bandes noires.

- Libellé et aide comme une ligne normale, aide en largeur 500 ; bouton Défaut à x 532, y -14.
- Grille sous l'aide (+8), à x 10 : **7 vignettes sur une rangée** (Aucune + 6 teintes, ordre de
  `TINTS`), 72 x 40 chacune, 6 entre deux (largeur totale 540).
- Image : `Media\\tint-preview.tga`, capture du jeu 256 x 128, scène à lumière neutre (ciel, feuillage,
  pierre) pour que chaque teinte se lise. `SetTexCoord(0.05, 0.95, 0, 1)` (rapport 1.8). Teinte par
  `SetVertexColor(r, g, b)` avec la couleur de `TINTS` à 100 % : même multiplication que le filtre (MOD).
  « Aucune » : capture sans teinte.
- Légende sous la vignette (-3), largeur 72, centrée, 1 ligne : nom (`TINT_*`).
- Survol : contour 1 blanc 0.6, infobulle avec le nom.
- Choisie : contour 2 or posé 2 à l'extérieur de la vignette (4 textures `SetColorTexture`),
  légende en `GameFontNormalSmall`.
- Clic : `tint` écrit, `NS.ApplyFilters()` aussitôt. Si `tintStrength` vaut 0, il passe à son défaut
  (50) : une teinte choisie se voit toujours.
- Hauteur de la ligne : 8 + libellé + 4 + aide + 8 + 40 + 3 + 12 + 8, arrondie à 4 (~108).

## 9. Interdits

- Toute couleur hors du tableau § 5 : pas de cyan, de bleu, de dégradé (`SetGradient`), d'ombre portée.
- Police hors `GameFont*` et police propre d'un gabarit ; pas de `SetFont` à taille arbitraire.
- Bouton désactivé pour dire « choisi » : désactivé veut dire indisponible.
- Gris 0.5 (`GameFontDisable*`) pour un texte actif : réservé à l'état désactivé.
- Largeur fixe sur un bouton à texte localisé : largeur = texte + 24 (allemand et russe).
- Texte « [+] / [-] » : icônes `Interface\\Buttons\\UI-PlusButton-Up` / `UI-MinusButton-Up` 14 x 14.
- Écriture de CVar à chaque frappe ou à chaque pas de curseur tenu.
- Contenu de ligne centré ou contrôle aligné à droite selon sa largeur : colonnes fixes du § 3.
- Texture tierce autre que `Media\\logo` et `Media\\tint-preview`. Aucun emoji ni symbole décoratif
  (étoile pleine, coche, flèche Unicode) dans un texte : glyphes absents des polices du jeu selon la langue.
- Texte d'explication permanent sous les préréglages : il va en infobulle.
