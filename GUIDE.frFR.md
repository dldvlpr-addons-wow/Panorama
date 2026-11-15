# Guide de Panorama

Comment utiliser Panorama sur WoW Forever, et comment configurer le HDR sous Windows.

## 1. Ouvrir la fenêtre

- Tapez `/pano`, ou faites un clic gauche sur le bouton Panorama de la minimap.
- Options > AddOns > Panorama a aussi un bouton qui l'ouvre.
- Faites glisser la barre de titre pour déplacer la fenêtre. Échap ou le bouton de fermeture la ferme.

Le bouton de la minimap :

- Le clic gauche ouvre ou ferme la fenêtre.
- Le clic droit affiche les préréglages, l'annulation et le redémarrage graphique.
- Faites-le glisser pour le déplacer autour de la minimap. `/pano minimap` l'affiche ou le masque.

## 2. La fenêtre

| Élément | Ce qu'il fait |
|---|---|
| Champ de recherche (en haut à droite) | Tapez un mot pour lister les réglages correspondants de tous les onglets. Videz-le pour revenir. |
| Onglets | Qualité, Filtres, Interface, Avancé. L'onglet ouvert est mémorisé. |
| Sélecteur de langue (à droite des onglets) | Langue du jeu ou l'une des dix langues. Changer de langue recharge l'interface. |
| Guide (à gauche du sélecteur de langue) | Ouvre ce guide dans le jeu. |
| Préréglages (onglet Qualité) | Bas, Moyen, Élevé, Extra. Le préréglage qui correspond à vos réglages est mis en évidence. |
| Pied de fenêtre | Appliquer à chaque connexion, bouton de la minimap, redémarrage du moteur graphique. |

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
  brouillard volumétrique, l'intensité de la teinte sans teinte).
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

Vous avez changé d'avis ? **Annuler le dernier préréglage** (bouton à côté des préréglages, ou `/pano undo`) rétablit les réglages d'avant
le dernier préréglage.

## 4. Filtres

L'onglet Filtres ajoute des effets par-dessus l'image. Ils ne changent aucun réglage du jeu.

- **Teinte** : cliquez sur une vignette pour l'appliquer tout de suite (sépia, chaude, froide, nuit, émeraude, crépuscule).
  **Intensité de la teinte** règle sa force.
- **Vignettage** : assombrit les bords de l'écran.
- **Grain** : grain animé.
- **Bandes noires** : bandes en haut et en bas, de 0 à 20 % de l'écran chacune. Le jeu calcule quand même ce qu'elles
  cachent, elles n'augmentent donc pas le nombre d'images par seconde.

## 5. Vos valeurs et le jeu

- À la première installation, Panorama lit vos réglages actuels du jeu. Rien ne change tant que vous ne touchez pas un contrôle.
- Une modification faite dans le menu Graphismes du jeu ou avec `/console` apparaît dans la fenêtre.
- **Appliquer à chaque connexion** (pied de fenêtre, activé par défaut) : les réglages que vous avez modifiés dans Panorama sont réécrits
  à chaque connexion. Les autres suivent le menu Graphismes du jeu.
- Une modification faite en combat est appliquée à la fin du combat.
- Certains réglages, comme le MSAA, demandent un redémarrage graphique. Cliquez sur **Redémarrer** dans le pied de fenêtre, ou tapez
  `/pano restart`. L'écran clignote une seconde.

## 6. HDR sous Windows

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

## 7. Commandes

| Commande | Action |
|---|---|
| `/pano` | Ouvre ou ferme la fenêtre |
| `/pano low`, `/pano medium`, `/pano high`, `/pano extra` | Applique un préréglage |
| `/pano undo` | Rétablit les réglages d'avant le dernier préréglage |
| `/pano apply` | Réécrit les réglages modifiés dans Panorama |
| `/pano restart` | Redémarre le moteur graphique |
| `/pano minimap` | Affiche ou masque le bouton de la minimap |

## 8. Réinitialisation

- Le bouton **Défaut** de chaque ligne réinitialise ce réglage.
- Le bouton **Par défaut** du menu Graphismes du jeu réinitialise uniquement les réglages que ce menu gère,
  et Panorama le suit. Utilisez les boutons Défaut de `/pano` pour les autres et pour les filtres.
