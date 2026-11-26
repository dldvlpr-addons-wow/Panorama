# Guide de Panorama

Comment utiliser Panorama sur WoW Forever, et comment configurer le HDR sous Windows.

**Sauvegardez d'abord vos réglages.** Panorama modifie des réglages du jeu, et retirer l'addon ne les remet pas comme avant. Avant de changer quoi que ce soit, quittez le jeu et copiez le dossier `WTF` de votre installation du jeu en lieu sûr. Pour revenir en arrière, quittez le jeu et remettez cette copie à sa place.

## 1. Ouvrir la fenêtre

- Tapez `/pano`, ou faites un clic gauche sur le bouton Panorama de la minimap.
- Options > AddOns > Panorama a aussi un bouton qui l'ouvre.
- Faites glisser la barre de titre pour déplacer la fenêtre. Échap ou le bouton de fermeture la ferme.

Le bouton de la minimap :

- Le clic gauche ouvre ou ferme la fenêtre.
- Le clic droit affiche les préréglages, l'annulation, le rétablissement et le redémarrage graphique.
- Faites-le glisser pour le déplacer autour de la minimap. `/pano minimap` l'affiche ou le masque.

## 2. La fenêtre

| Élément | Ce qu'il fait |
|---|---|
| **Simple**, **Avancé** (à côté du titre) | Simple : chaque onglet montre une courte liste des réglages principaux, sans sections. Avancé : tous les réglages, par section, avec les règles par lieu et la section Experts. À la première installation, c'est Simple ; si vous utilisiez déjà Panorama, c'est Avancé. La recherche trouve toujours tous les réglages. |
| Guide (en haut à droite) | Ouvre ce guide dans le jeu. |
| Menu **Options** (en haut à droite) | **Langue** (langue du jeu ou l'une des dix langues ; changer de langue recharge l'interface), **Appliquer à chaque connexion**, **Bouton de la minimap**, **Tout réinitialiser…**. |
| **Look actuel :** (bandeau sous le titre) | Le look posé sur le monde, et qui l'impose : vous, Jour et nuit, ou le lieu. Son bouton (**Modifier**, **Modifier cette règle**) ouvre l'endroit où le changer. Survolez le bandeau pour voir lequel passe en premier. |
| Onglets | **Image** (qualité graphique), **HDR**, **Ambiance** (look du monde), **Mes filtres**. L'onglet ouvert est mémorisé. |
| Champ de recherche (à droite des onglets) | Tapez un mot pour lister les réglages correspondants de tous les onglets. Videz-le pour revenir. |
| Préréglages (onglet Image) | Bas, Moyen, Élevé, Extra. Le préréglage qui correspond à vos réglages est mis en évidence. |
| Pied de fenêtre | **Annuler** défait votre dernière modification : curseur, champ, préréglage, filtre, ambiance ou Tout réinitialiser. **Rétablir** la remet. Les 20 dernières modifications sont conservées jusqu'à `/reload`. **Redémarrer** redémarre le moteur graphique. |

En mode Avancé, cliquez sur un titre de section pour la replier ou la déplier. La section **Experts (console seulement)**
est repliée au départ. Un titre de section indique combien de ses réglages vous avez modifiés.

### Une ligne de réglage

- **Curseur** : la valeur est écrite quand vous relâchez le bouton de la souris, pas pendant que vous faites glisser.
- **Champ de valeur** à côté du curseur : tapez une valeur, puis appuyez sur Entrée ou cliquez ailleurs. Échap annule,
  Tab passe au champ suivant. La virgule fonctionne comme séparateur décimal. La valeur reste dans la plage du curseur.
- **Bouton Défaut** : remet ce réglage à sa valeur par défaut. Survolez-le pour voir la valeur.
- **Marque dorée** à gauche : vous avez modifié ce réglage.
- **Menu du jeu** : quand un menu du jeu définit aussi cette valeur, l'aide du libellé le nomme. Ce menu
  ne relit pas la valeur, il peut donc afficher un autre niveau.
- **Ligne grisée** : elle dépend d'un autre réglage désactivé (par exemple **Qualité du brouillard volumétrique** sans
  **Brouillard volumétrique**, l'intensité de la teinte sans teinte), ou un mode la règle. Survolez le libellé pour savoir pourquoi.
  Une ligne qui dépend d'une autre est décalée vers la droite, juste en dessous.
- Survolez un libellé pour lire son aide complète.

## 3. Préréglages

| Préréglage | Résultat |
|---|---|
| Bas | Performances maximales. Vue courte, sans ombres. |
| Moyen | Équilibré. Bonnes performances, ombres correctes. |
| Élevé | Niveau Élevé du jeu. Ombres complètes, tous les effets. |
| Extra | Qualité maximale. Vue la plus lointaine, tout activé. |

Les préréglages ne modifient que les réglages de qualité graphique de l'onglet Image. Ils ne touchent pas à la caméra,
à la souris, à l'interface, à la netteté, à la faible latence, au HDR ni aux filtres.

Vous avez changé d'avis ? **Annuler** (pied de fenêtre, ou `/pano undo`) rétablit les réglages d'avant
le préréglage.

## 4. Ambiance

L'onglet Ambiance règle le look du monde : des effets par-dessus l'image. Ils ne changent aucun réglage du jeu.

- **Mode** (haut de l'onglet) : **Fixe** (le même filtre partout), **Jour et nuit** (une teinte de jour et une
  teinte de nuit) ou **Selon le lieu** (voir plus bas). Fixe par défaut.
- **Ici** : le lieu et l'heure détectés maintenant. Quand un donjon, un intérieur ou la météo passe
  avant une zone que vous avez réglée, il l'indique.
- **Filtre** (modes Fixe et Jour et nuit) : **Base** utilise les lignes en dessous. Un de vos filtres
  (onglet Mes filtres) remplace la teinte, la vignette et le grain, et apporte son contraste, sa
  luminosité et son gamma. **Modifier le filtre** l'ouvre dans l'onglet Mes filtres.
- **Teinte** : cliquez sur une vignette pour l'appliquer tout de suite (sépia, chaude, froide, nuit, émeraude, crépuscule).
  **Intensité de la teinte** règle sa force.
- **Vignettage** : assombrit les bords de l'écran.
- **Grain** : grain animé.
- **Teinte de jour** et **Teinte de nuit** (mode Jour et nuit) : Panorama pose la teinte de jour le jour et la teinte
  de nuit la nuit, selon le jour et la nuit du jeu. Elles remplacent la teinte. Le passage est progressif
  de 19 h à 21 h et de 5 h à 7 h (heure du serveur). Un de vos filtres choisi à la ligne Filtre
  les remplace.
- **Ciel** : les mêmes couleurs en dégradé, pleines en haut de l'écran et plus claires en bas.
  **Intensité du ciel** règle sa force.
- **Bandes noires** : bandes en haut et en bas, de 0 à 20 % de l'écran chacune, dans tous les modes. Le jeu calcule
  quand même ce qu'elles cachent, elles n'augmentent donc pas le nombre d'images par seconde.

En mode Simple, l'onglet montre le mode, le lieu, le filtre, la teinte et son intensité, et les teintes
de jour et de nuit. Vignettage, grain, ciel et bandes noires sont en mode Avancé.

### Selon le lieu

En mode **Selon le lieu**, la teinte, le ciel, la vignette et le grain changent tout seuls selon l'endroit où vous êtes.

- Les lignes du mode Fixe sont cachées : la règle du lieu les remplace. Seules les bandes noires restent.
  Leurs valeurs restent enregistrées et reviennent quand vous changez de mode.
  En mode Simple, les règles livrées s'appliquent ; passez en Avancé pour les modifier.
- **Lieu** : règle la teinte, la vignette et le grain. Ordre : donjon ou raid, intérieur, météo (pluie,
  neige, tempête de sable), puis le type de zone : terres tempérées, déserts et terres arides, terres
  enneigées, jungle et marais, terres corrompues, terres volcaniques, forêts arcaniques. Une zone pas
  encore connue compte comme tempérée. La météo ne compte que si Intensité météo est supérieure à 0.
- **Heure** : règle le ciel (jour, aube et crépuscule, nuit). La nuit suit le jour et la nuit du
  jeu ; l'aube et le crépuscule suivent l'heure du serveur. Pas de ciel en intérieur ni en donjon.
- **Règle** (mode Avancé) : choisissez une règle, puis réglez-la en dessous. Le bouton
  Défaut rend la valeur livrée pour cette règle. La première fois que la fenêtre s'ouvre, la règle ouverte est celle du lieu où vous êtes.
  Le menu est rangé en cinq groupes : **Zones** (la zone où vous êtes et celles que vous avez réglées), **Donjon et intérieur**, **Météo**, **Type de zone** et **Ciel (moment)**.
  Les quatre premiers règlent la teinte, la vignette, le grain et un préréglage graphique : un seul lieu s'applique à la fois, dans l'ordre donné plus haut.
  Le dernier règle le ciel. Rien à régler pour commencer : chaque règle a déjà ses valeurs.
- **Cette zone** : premier choix du même menu, avec le nom de la zone où vous êtes. Choisissez-la pour
  donner à cette zone sa propre teinte, sa propre vignette et son propre grain, en partant de son type
  de zone. Elle passe alors avant le type de zone, mais après donjon, intérieur et météo. Les zones
  que vous réglez restent dans le menu. **Revenir au type de zone** (à côté du menu) retire les valeurs de la zone : elle suit de
  nouveau son type de zone.
- **Toutes les zones** : sous-menu du même menu, avec toutes les zones connues. Choisissez-en une pour la régler sans y être. Les zones sont rangées par continent.
- **Préréglage** et **Distance des décors** (section **Image** d'un lieu ou d'une zone) : ils s'appliquent tant que vous êtes dans ce lieu, par-dessus vos propres réglages, quel que soit le mode d'ambiance. La distance des décors du lieu passe avant celle du préréglage. Vos propres réglages sont conservés et reviennent quand vous partez. **Mes réglages** ne change rien. Exemple : Bas en donjon, Extra dans une zone que vous aimez. Dans un donjon ou un raid, le premier choix du menu règle ce donjon seul. Dans l'onglet Image, **Ici : …** s'affiche à côté des préréglages tant qu'un lieu impose les siens ; en mode Avancé, il ouvre cette règle. En combat, le changement attend la fin du combat.
- **Filtre** (première ligne de la section **Look** d'un lieu ou d'une zone) : ce lieu utilise un de vos filtres de l'onglet Mes filtres, avec son contraste, sa luminosité et son gamma. **Réglages ci-dessous** : la teinte, la vignette et le grain de la règle. La section Look ne s'applique qu'en mode Selon le lieu.

## 5. Mes filtres

L'onglet Mes filtres sert à créer autant de filtres à vous que vous voulez. Le filtre ouvert n'est montré sur le monde qu'en aperçu ; celui qui s'applique se choisit dans l'onglet Ambiance. **Nouveau** en ajoute un et l'ouvre, **Supprimer** retire le filtre ouvert : le filtre de l'onglet Ambiance et les règles qui l'utilisaient repassent sans filtre. Il reste toujours un filtre.

- **Filtre** : choisit le filtre que règlent les lignes en dessous. **Nom** : donnez-lui un nom (Entrée pour valider).
- **Teinte** : cliquez sur une vignette pour donner cette couleur au filtre. **Rouge**, **Vert**, **Bleu** (en %) : sa couleur exacte. **Intensité de la teinte** : sa force.
- **Vignettage** et **Grain** : ceux du filtre.
- **Contraste**, **Luminosité**, **Gamma** : réglages d'image que le filtre donne au jeu tant qu'il est appliqué ; vos propres valeurs reviennent ensuite. Mes réglages : rien ne change. Selon le mode d'affichage, ils peuvent rester sans effet.
- En mode Simple, l'onglet ne montre que la teinte et l'intensité de la teinte.
- Tant que l'onglet est ouvert, le filtre affiché se voit en direct sur le jeu. Le bandeau **Look actuel :** indique quand ce n'est qu'un aperçu.
- Pour utiliser un filtre : choisissez-le à la ligne **Filtre** de l'onglet Ambiance (modes Fixe et Jour et nuit), ou d'un lieu ou d'une zone (mode Selon le lieu). Il remplace alors la teinte, la vignette et le grain. **Base** ou **Réglages ci-dessous** : rien ne change.

## 6. Vos valeurs et le jeu

- À la première installation, Panorama lit vos réglages actuels du jeu. Rien ne change tant que vous ne touchez pas un contrôle.
- Une modification faite dans le menu Graphismes du jeu ou avec `/console` apparaît dans la fenêtre.
- **Appliquer à chaque connexion** (menu Options, activé par défaut) : les réglages que vous avez modifiés dans Panorama sont réécrits
  à chaque connexion. Les autres suivent le menu Graphismes du jeu.
- Une modification faite en combat est appliquée à la fin du combat.
- Certains réglages, comme le MSAA, demandent un redémarrage graphique. Cliquez sur **Redémarrer** dans le pied de fenêtre, ou tapez
  `/pano restart`. L'écran clignote une seconde.

## 7. HDR sous Windows

Les réglages HDR n'existent que sous forme de commandes de console dans le jeu. Panorama les affiche dans l'onglet **HDR**.
Il vous faut un écran compatible HDR.

### Étape 1 : activer le HDR dans Windows

Windows 11 :

1. Ouvrez **Paramètres > Système > Affichage**.
2. Sélectionnez l'écran HDR si vous en avez plusieurs.
3. Activez **Utiliser HDR**. Le raccourci **Win + Alt + B** l'active ou le désactive aussi.

Windows 10 : **Paramètres > Système > Affichage > Paramètres de couleurs HD Windows** (Windows HD Color settings), puis activez
**Lire des jeux et des applications HDR** (Play HDR games and apps).

Vérifiez aussi que le HDR est activé dans le menu de l'écran lui-même, s'il a une telle option.

Désactivez le **HDR automatique** (Auto HDR) de Windows 11 : **Paramètres > Système > Affichage > HDR**. Il sert aux jeux sans HDR. WoW produit sa propre image HDR.

### Étape 2 : trouver la luminosité de crête de votre écran

Installez l'application gratuite **Étalonnage HDR de Windows** (Windows HDR Calibration) depuis le Microsoft Store et lancez-la. La luminance
maximale qu'elle trouve est la luminosité de crête de votre écran, en nits.

Sans l'application, utilisez la certification HDR de l'écran : DisplayHDR 400 signifie environ 400 nits, DisplayHDR 600
environ 600, DisplayHDR 1000 environ 1000.

### Étape 3 : régler le HDR dans Panorama

Ouvrez `/pano`, onglet **HDR**. En mode Simple, l'onglet ne montre que les trois premières lignes ci-dessous : choisissez
**Avancé** pour voir **Intensité HDR** et la luminosité de référence.

1. Cochez **Sortie HDR**.
2. Cochez **Luminosité de crête** ou **Luminosité de référence** : l'un ou l'autre, jamais les deux. Sans l'un d'eux, l'image s'assombrit.

**Mode luminosité de crête (recommandé)**

- Cochez **Luminosité de crête**.
- Réglez **Crête (nits)** sur la valeur trouvée à l'étape 2.
- **Intensité HDR** ne fonctionne que dans ce mode. La valeur par défaut du jeu est 2. Changez-la par petits pas et
  comparez : Blizzard ne documente pas son effet exact.

**Mode luminosité de référence**

- Cochez **Luminosité de référence**.
- **Référence (nits)** est la luminosité du blanc dans la scène. 203 est la valeur standard.
  Augmentez-la si l'image paraît trop sombre dans une pièce lumineuse. Intensité HDR n'a aucun effet dans ce mode.

Si l'image ne change pas, cliquez sur **Redémarrer** dans le pied de fenêtre.

### Dépannage du HDR

| Problème | Solution |
|---|---|
| Image très sombre | Cochez l'un des deux modes de luminosité. |
| Image grise ou délavée | Activez le HDR dans Windows (étape 1) et dans le menu de l'écran. |
| HDR automatique activé dans Windows | Désactivez-le (étape 1). |
| Hautes lumières trop vives ou plates | Réglez la luminosité de crête sur la valeur réelle de votre écran (étape 2). |
| Vous voulez désactiver le HDR | Décochez **Sortie HDR**. |

Chaque ligne HDR a un bouton Défaut qui remet la valeur du jeu.

## 8. Commandes

| Commande | Action |
|---|---|
| `/pano` | Ouvre ou ferme la fenêtre |
| `/pano low`, `/pano medium`, `/pano high`, `/pano extra` | Applique un préréglage |
| `/pano undo` | Annule la dernière modification |
| `/pano redo` | Rétablit la modification que vous venez d'annuler |
| `/pano reset` | Remet chaque réglage et chaque filtre par défaut |
| `/pano status` | Affiche dans le chat le lieu et le moment détectés et les filtres appliqués à l'instant (pendant un fondu, les valeurs visées) |
| `/pano apply` | Réécrit les réglages modifiés dans Panorama |
| `/pano restart` | Redémarre le moteur graphique |
| `/pano minimap` | Affiche ou masque le bouton de la minimap |
| `/pano blackbars 10` | Bandes noires à 10 % de la hauteur de l'écran (0 à 20). `off` les retire |
| `/pano grain 10` | Grain à 10 (0 à 100). `off` le retire |
| `/pano vignette 10` | Vignette à 10 (0 à 100). `off` la retire |

## 9. Réinitialisation

- Le bouton **Défaut** de chaque ligne réinitialise ce réglage.
- Le bouton **Par défaut** du menu Graphismes du jeu réinitialise uniquement les réglages que ce menu gère,
  et Panorama le suit. Utilisez les boutons Défaut de `/pano` pour les autres et pour les filtres.
- **Tout réinitialiser…** (menu Options, avec confirmation) ou `/pano reset` : remet chaque réglage de la fenêtre,
  modifié dans Panorama ou non, et chaque filtre à sa valeur par défaut. **Annuler** l'annule jusqu'à `/reload`.
  L'onglet Ambiance et les zones réglées sont remis à zéro aussi. Vos filtres de l'onglet Mes filtres sont effacés aussi.
