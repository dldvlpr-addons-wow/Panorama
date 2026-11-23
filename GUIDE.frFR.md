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
| Champ de recherche (en haut à droite) | Tapez un mot pour lister les réglages correspondants de tous les onglets. Videz-le pour revenir. |
| Onglets | Qualité, Interface, Avancé (réglages du jeu), puis Filtres, Mes filtres, Ambiance (effets de Panorama). L'onglet ouvert est mémorisé. |
| Réglages avancés (sous le titre) | Décoché : pas d'onglets, une seule page avec les préréglages, les réglages principaux de qualité (distance d'affichage, brouillard volumétrique, ombres, occlusion ambiante, détail de l'eau, anticrénelage, atténuation de la netteté), la sortie HDR et la crête, le contraste, la luminosité, le recul de la caméra, le filtre, l'intensité du filtre et le mode d'ambiance. Coché : tous les onglets et tous les réglages. À la première installation, il est décoché ; si vous utilisiez déjà Panorama, il est coché. La recherche trouve toujours tous les réglages. |
| Annuler, Rétablir (sous les onglets, à droite) | Annuler défait votre dernière modification : curseur, champ, préréglage, filtre, ambiance ou Tout réinitialiser. Rétablir la remet. Les 20 dernières modifications sont conservées jusqu'à `/reload`. |
| Sélecteur de langue (à droite des onglets) | Langue du jeu ou l'une des dix langues. Changer de langue recharge l'interface. |
| Guide (à gauche du champ de recherche) | Ouvre ce guide dans le jeu. |
| Préréglages (onglet Qualité) | Bas, Moyen, Élevé, Extra. Le préréglage qui correspond à vos réglages est mis en évidence. |
| Pied de fenêtre | Appliquer à chaque connexion, bouton minimap, Tout réinitialiser, redémarrage du moteur graphique. |

Cliquez sur un titre de section pour la replier ou la déplier.

### Une ligne de réglage

- **Curseur** : la valeur est écrite quand vous relâchez le bouton de la souris, pas pendant que vous faites glisser.
- **Champ de valeur** à côté du curseur : tapez une valeur, puis appuyez sur Entrée ou cliquez ailleurs. Échap annule,
  Tab passe au champ suivant. La virgule fonctionne comme séparateur décimal. La valeur reste dans la plage du curseur.
- **Bouton Défaut** : remet ce réglage à sa valeur par défaut. Survolez-le pour voir la valeur.
- **Marque dorée** à gauche : vous avez modifié ce réglage.
- **Étoile jaune** : un menu du jeu définit aussi cette valeur. Survolez-la pour voir lequel. Ce menu
  ne relit pas la valeur, il peut donc afficher un autre niveau.
- **Ligne grisée** : elle dépend d'un autre réglage désactivé (par exemple la densité du brouillard sans
  brouillard volumétrique, l'intensité de la teinte sans teinte). La ligne dit quel réglage changer.
- Survolez un libellé pour lire son aide complète.

## 3. Préréglages

| Préréglage | Résultat |
|---|---|
| Bas | Performances maximales. Vue courte, sans ombres. |
| Moyen | Équilibré. Bonnes performances, ombres correctes. |
| Élevé | Niveau Élevé du jeu. Ombres complètes, tous les effets. |
| Extra | Qualité maximale. Vue la plus lointaine, tout activé. |

Les préréglages ne modifient que les réglages de qualité graphique de l'onglet Qualité. Ils ne touchent pas à la caméra,
à la souris, à l'interface, à la netteté, à la faible latence, au HDR ni aux filtres.

Vous avez changé d'avis ? **Annuler** (sous les onglets, ou `/pano undo`) rétablit les réglages d'avant
le préréglage.

## 4. Filtres

L'onglet Filtres ajoute des effets par-dessus l'image. Ils ne changent aucun réglage du jeu.

- **Teinte** : cliquez sur une vignette pour l'appliquer tout de suite (sépia, chaude, froide, nuit, émeraude, crépuscule).
  **Intensité de la teinte** règle sa force.
- **Mon filtre** : utilise un de vos filtres de l'onglet Mes filtres. Il remplace la teinte, la vignette et le grain.
- **Ciel** : les mêmes couleurs en dégradé, pleines en haut de l'écran et plus claires en bas.
  **Intensité du ciel** règle sa force.
- **Vignettage** : assombrit les bords de l'écran.
- **Grain** : grain animé.
- **Bandes noires** : bandes en haut et en bas, de 0 à 20 % de l'écran chacune. Le jeu calcule quand même ce qu'elles
  cachent, elles n'augmentent donc pas le nombre d'images par seconde.

### Ambiance

L'onglet Ambiance change tout seul la teinte, le ciel, la vignette et le grain selon l'endroit où vous êtes.

- **Mode** (haut de l'onglet) : **Désactivé** (l'onglet Filtres s'applique partout), **Jour et nuit automatiques** (voir Jour et nuit plus bas) ou **Ambiance auto**. Désactivé par défaut.
- **Ambiance auto** : ces filtres suivent le lieu et l'heure. Les valeurs
  de l'onglet Filtres restent enregistrées et reviennent quand vous changez de mode.
  Sans Réglages avancés, la page unique n'affiche que le mode et le lieu détecté ; cochez Réglages avancés pour modifier les contextes.
- **Lieu** : règle la teinte, la vignette et le grain. Ordre : donjon ou raid, intérieur, météo (pluie,
  neige, tempête de sable), puis le type de zone : terres tempérées, déserts et terres arides, terres
  enneigées, jungle et marais, terres corrompues, terres volcaniques, forêts arcaniques. Une zone pas
  encore connue compte comme tempérée. La météo ne compte que si Intensité météo est supérieure à 0.
- **Heure** : règle le ciel (jour, aube et crépuscule, nuit). La nuit suit le jour et la nuit du
  jeu ; l'aube et le crépuscule suivent l'heure du serveur. Pas de ciel en intérieur ni en donjon.
- La ligne de droite montre le lieu et l'heure détectés maintenant. Quand un donjon, un intérieur ou
  la météo passe avant une zone que vous avez réglée, elle l'indique.
- **Contexte à modifier** : choisissez un contexte, puis réglez ses filtres en dessous. Le bouton
  Défaut rend la valeur livrée pour ce contexte.
  Le menu est rangé en cinq groupes : **Zones** (la zone où vous êtes et celles que vous avez réglées), **Donjon et intérieur**, **Météo**, **Type de zone** et **Ciel (moment)**.
  Les quatre premiers règlent la teinte, la vignette, le grain et un préréglage graphique : un seul lieu s'applique à la fois, dans l'ordre donné plus haut.
  Le dernier règle le ciel. Rien à régler pour commencer : chaque contexte a déjà ses valeurs.
- **Cette zone** : premier choix du même menu, avec le nom de la zone où vous êtes. Choisissez-la pour
  donner à cette zone sa propre teinte, sa propre vignette et son propre grain, en partant de son type
  de zone. Elle passe alors avant le type de zone, mais après donjon, intérieur et météo. Les zones
  que vous réglez restent dans le menu. **Type de zone** retire les valeurs de la zone : elle suit de
  nouveau son type de zone.
- **Toutes les zones** : sous-menu du même menu, avec toutes les zones connues. Choisissez-en une pour la régler sans y être. Les zones sont rangées par continent.
- **Préréglage** et **Distance des décors** (premières lignes d'un lieu ou d'une zone) : ils s'appliquent tant que vous êtes dans ce lieu, par-dessus vos propres réglages, que l'ambiance auto soit cochée ou non. La distance des décors du lieu passe avant celle du préréglage. Vos propres réglages sont conservés et reviennent quand vous partez. **Mes réglages** ne change rien. Exemple : Bas en donjon, Extra dans une zone que vous aimez. Dans un donjon ou un raid, le premier choix du menu règle ce donjon seul. Dans l'onglet Qualité, le bouton **Par lieu** ouvre ces lignes pour le lieu où vous êtes ; il affiche **Ici : …** tant qu'un lieu impose les siens. En combat, le changement attend la fin du combat.
- **Mon filtre** (première ligne des filtres d'un lieu ou d'une zone) : ce lieu utilise un de vos filtres de l'onglet Mes filtres, avec son contraste, sa luminosité et son gamma, tant que l'ambiance auto est cochée.
- **Jour et nuit** (mode **Jour et nuit automatiques**) : Panorama pose la **Teinte de jour** le jour et la **Teinte de nuit** la nuit,
  selon le jour et la nuit du jeu. Elles remplacent la teinte de l'onglet Filtres. Le passage est progressif de 19 h à 21 h et de 5 h à
  7 h (heure du serveur). Les teintes de jour et de nuit et leurs intensités se règlent avec Réglages avancés.

## 5. Mes filtres

L'onglet Mes filtres (affiché avec Réglages avancés) sert à créer autant de filtres à vous que vous voulez. **Nouveau** en ajoute un, **Supprimer** retire le filtre ouvert : l'onglet Filtres, les lieux et les zones qui l'utilisaient repassent à Aucun.

- **Filtre à modifier** : choisit le filtre que règlent les lignes en dessous. **Nom** : donnez-lui un nom (Entrée pour valider).
- **Rouge**, **Vert**, **Bleu** (en %) : couleur de la teinte du filtre. **Intensité de la teinte** : sa force.
- **Vignettage** et **Grain** : ceux du filtre.
- **Contraste**, **Luminosité**, **Gamma** : réglages d'image que le filtre donne au jeu tant qu'il est appliqué ; vos propres valeurs reviennent ensuite. Mes réglages : rien ne change. Selon le mode d'affichage, ils peuvent rester sans effet.
- Tant que l'onglet est ouvert, le filtre affiché se voit en direct sur le jeu.
- Pour utiliser un filtre : choisissez-le à la ligne **Mon filtre** de l'onglet Filtres (partout), ou d'un lieu ou d'une zone dans l'onglet Ambiance (ambiance auto cochée). Il remplace alors la teinte, la vignette et le grain, dont les lignes sont grisées. Aucun : rien ne change.

## 6. Vos valeurs et le jeu

- À la première installation, Panorama lit vos réglages actuels du jeu. Rien ne change tant que vous ne touchez pas un contrôle.
- Une modification faite dans le menu Graphismes du jeu ou avec `/console` apparaît dans la fenêtre.
- **Appliquer à chaque connexion** (pied de fenêtre, activé par défaut) : les réglages que vous avez modifiés dans Panorama sont réécrits
  à chaque connexion. Les autres suivent le menu Graphismes du jeu.
- Une modification faite en combat est appliquée à la fin du combat.
- Certains réglages, comme le MSAA, demandent un redémarrage graphique. Cliquez sur **Redémarrer** dans le pied de fenêtre, ou tapez
  `/pano restart`. L'écran clignote une seconde.

## 7. HDR sous Windows

Les réglages HDR n'existent que sous forme de commandes de console dans le jeu. Panorama les affiche dans l'onglet **Avancé**,
section **HDR (console seulement)**. Il vous faut un écran compatible HDR.

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

Ouvrez `/pano`, onglet **Avancé**, section **HDR (console seulement)**.

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

## 9. Réinitialisation

- Le bouton **Défaut** de chaque ligne réinitialise ce réglage.
- Le bouton **Par défaut** du menu Graphismes du jeu réinitialise uniquement les réglages que ce menu gère,
  et Panorama le suit. Utilisez les boutons Défaut de `/pano` pour les autres et pour les filtres.
- **Tout réinitialiser** (pied de fenêtre, avec confirmation) ou `/pano reset` : remet chaque réglage modifié
  dans Panorama et chaque filtre à sa valeur par défaut. **Annuler** l'annule jusqu'à `/reload`.
  L'onglet Ambiance et les zones réglées sont remis à zéro aussi. Vos filtres de l'onglet Mes filtres sont effacés aussi.
