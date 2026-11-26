# Test en jeu : nouvelle détection du matériel par Reset all (1.9.1)

But : vérifier que Reset all, pour un réglage changé avant la 1.9.1 (sans valeur d'origine gardée),
fait bien refaire au jeu la détection du matériel au lancement suivant (CVar `hwDetect`).

Tant que ce test n'est pas passé, le message de Reset all (`MSG_RESET_REDETECT`), la boîte de
confirmation (`OPT_RESET_ALL_CONFIRM`), le README et le CHANGELOG promettent un comportement non vérifié.

## Préparation

1. Copier `tests/en-jeu/DetectionCheck/` dans `<client>/Interface/AddOns/DetectionCheck/`.
2. Copier la version de Panorama de la branche `hotfix/reset-all` dans `Interface/AddOns/Panorama/`.
3. Lancer le jeu. `DetectionCheck` affiche dans le chat, 3 s après l'entrée en jeu :
   `hwDetect = …`, chaque CVar de Panorama différente de la détection, puis `X / Y identiques`.
   `/detectcheck` relance la comparaison.

Valeurs de référence (relevé après suppression de `Config.wtf`, Mac modeste) : farclip 3000,
shadowTextureSize 512, entityLodDist 5, volumeFogLevel 1, weatherDensity 0, doodadLodScale 75,
rippleDetail 0, lodObjectFadeScale 80, DepthBasedOpacity 0. Écart sur `spellClutter`,
`cameraDistanceMaxZoomFactor` ou `projectedTextures` : sans doute un réglage personnel, ne prouve rien.

## Étapes

1. Écarter deux réglages de la détection, dont un réglage expert :
   `/console farclip 1000` puis `/console entityLodDist 10`
2. Les marquer modifiés dans Panorama : bouger farclip dans `/pano` (n'importe quelle valeur).
3. Simuler un réglage changé avant 1.9.1 (origine absente) :
   `/run PanoramaDB.origin.farclip = nil`
4. `/pano reset`
   - Attendu dans le chat : « Relancez le jeu : il détectera de nouveau votre ordinateur… ».
   - `/dump C_CVar.GetCVar("hwDetect")` doit rendre `"1"`.
5. Quitter complètement le jeu (pas de `/reload`).
6. Ouvrir `<client>/WTF/Config.wtf` : il doit contenir `SET hwDetect "1"`.
7. Relancer le jeu.
8. `/dump C_CVar.GetCVar("hwDetect"), C_CVar.GetCVar("farclip"), C_CVar.GetCVar("entityLodDist")`
   puis lire le rapport de `DetectionCheck`.

## Résultat

- **Réussi** : `"0"`, `"3000"`, `"5"`, et le rapport n'affiche que des écarts personnels.
  La détection couvre aussi les réglages experts si entityLodDist vaut 5.
- **Partiel** : farclip à 3000 mais entityLodDist à 10 : la détection ne touche que le menu
  Graphismes. Corriger les textes (README, CHANGELOG, confirmation) en conséquence.
- **Échec** :
  - étape 4, `hwDetect` pas à `"1"` ou message du bouton Défauts : écriture refusée depuis un addon ;
  - étape 6, ligne absente : la CVar n'est pas sauvegardée ;
  - étape 8, `hwDetect` encore à `"1"` ou farclip à 1000 : la détection ne se relance pas.
  Dans ces cas : revenir au message `MSG_RESET_ALL` (bouton Défauts du menu Graphismes) et retirer
  la promesse des textes. Repli sûr pour les joueurs : `/pano reset`, quitter le jeu, supprimer
  `WTF/Config.wtf` (perd aussi son, résolution, compte mémorisé, langue), relancer.

## Après le test

Retirer `Interface/AddOns/DetectionCheck/`.
