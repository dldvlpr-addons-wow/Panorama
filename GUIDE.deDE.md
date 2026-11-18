# Panorama-Anleitung

So benutzt du Panorama auf WoW Forever und richtest HDR unter Windows ein.

**Sichere zuerst deine Einstellungen.** Panorama ändert Spieleinstellungen, und das Entfernen des Addons setzt sie nicht zurück. Bevor du etwas änderst, beende das Spiel und kopiere den Ordner `WTF` deiner Spielinstallation an einen sicheren Ort. Um zurückzukehren, beende das Spiel und lege diese Kopie wieder an ihren Platz.

## 1. Das Fenster öffnen

- Gib `/pano` ein oder klicke mit der linken Maustaste auf den Panorama-Button an der Minimap.
- Unter Optionen > AddOns > Panorama gibt es ebenfalls einen Button, der es öffnet.
- Ziehe die Titelleiste, um das Fenster zu verschieben. Escape oder der Schließen-Button schließt es.

Der Minimap-Button:

- Linksklick öffnet oder schließt das Fenster.
- Rechtsklick zeigt die Voreinstellungen, Rückgängig und den Neustart der Grafik.
- Ziehe ihn, um ihn um die Minimap zu bewegen. `/pano minimap` zeigt oder versteckt ihn.

## 2. Das Fenster

| Bereich | Funktion |
|---|---|
| Suchfeld (oben rechts) | Gib ein Wort ein, um die passenden Einstellungen aller Reiter aufzulisten. Leere es, um zurückzukehren. |
| Reiter | Qualität, Filter, Stimmung, Oberfläche, Erweitert. Der geöffnete Reiter wird gespeichert. |
| Sprachauswahl (rechts neben den Reitern) | Spielsprache oder eine von zehn Sprachen. Eine Änderung lädt die Oberfläche neu. |
| Anleitung (links neben dem Suchfeld) | Öffnet diese Anleitung im Spiel. |
| Voreinstellungen (Reiter Qualität) | Niedrig, Mittel, Hoch, Extra. Die Voreinstellung, die zu deinen Einstellungen passt, ist hervorgehoben. |
| Fußzeile | Bei jedem Einloggen anwenden, Minimap-Button, Alles zurücksetzen, Neustart der Grafik-Engine. |

Klicke auf einen Abschnittstitel, um ihn ein- oder auszuklappen.

### Eine Einstellungszeile

- **Schieberegler**: Der Wert wird geschrieben, wenn du die Maustaste loslässt, nicht während du ziehst.
- **Wertfeld** neben dem Regler: Gib einen Wert ein und drücke dann Enter oder klicke woanders hin.
  Escape bricht ab, Tab springt zum nächsten Feld. Ein Komma funktioniert als Dezimaltrennzeichen.
  Der Wert bleibt im Bereich des Reglers.
- **Standard-Button**: setzt diese Einstellung auf ihren Standardwert zurück. Fahre mit der Maus darüber,
  um den Wert zu sehen.
- **Goldene Markierung** links: Du hast diese Einstellung geändert.
- **Gelber Stern**: Ein Spielmenü setzt diesen Wert ebenfalls. Fahre mit der Maus darüber, um zu sehen,
  welches. Dieses Menü liest den Wert nicht zurück, es kann also eine andere Stufe zeigen.
- **Ausgegraute Zeile**: Sie hängt von einer anderen Einstellung ab, die aus ist (zum Beispiel Nebeldichte
  ohne volumetrischen Nebel, Farbtonstärke ohne Farbton).
- Fahre mit der Maus über eine Beschriftung, um die ganze Hilfe zu lesen.

## 3. Voreinstellungen

| Voreinstellung | Ergebnis |
|---|---|
| Niedrig | Beste Leistung. Kurze Sichtweite, keine Schatten. |
| Mittel | Ausgewogen. Gute Leistung, ordentliche Schatten. |
| Hoch | Stufe Hoch des Spiels. Volle Schatten, alle Effekte. |
| Extra | Hoch, mit der größten Sichtweite. |

Voreinstellungen ändern nur die Grafikqualitäts-Einstellungen im Reiter Qualität. Sie ändern nicht
Kamera, Maus, Oberfläche, Schärfung, niedrige Latenz, HDR oder Filter.

Anders überlegt? **Letzte Voreinstellung rückgängig** (Button neben den Voreinstellungen, oder `/pano undo`)
stellt die Einstellungen von vor der letzten Voreinstellung wieder her.

## 4. Filter

Der Reiter Filter fügt Effekte über dem Bild hinzu. Sie ändern keine Spieleinstellung.

- **Farbton**: Klicke auf eine Vorschau, um ihn sofort anzuwenden (Sepia, Warm, Kalt, Nacht, Smaragd,
  Dämmerung). **Farbtonstärke** legt fest, wie stark er ist.
- **Himmel**: dieselben Farben als Verlauf, oben am Bildschirm voll und unten heller.
  **Himmelsstärke** legt fest, wie stark er ist.
- **Vignette**: dunkelt die Bildschirmränder ab.
- **Filmkorn**: animiertes Korn.
- **Schwarze Balken**: Balken oben und unten, jeweils 0 bis 20 % des Bildschirms. Das Spiel rendert
  weiterhin, was sie verdecken, daher steigern sie die Bildrate nicht.

### Stimmung

Der Reiter Stimmung ändert Tönung, Himmel, Vignette und Körnung von selbst, passend zu deinem Ort.

- **Automatische Stimmung**: aktiviert folgen diese Filter Ort und Tageszeit. Standardmäßig aus. Die
  Werte des Reiters Filter bleiben gespeichert und kehren zurück, wenn du sie ausschaltest.
- **Ort**: legt Tönung, Vignette und Körnung fest. Reihenfolge: Dungeon oder Schlachtzug, Innenraum,
  Wetter (Regen, Schnee, Sandsturm), dann die Art der Zone: gemäßigte Lande, Wüsten und Ödland,
  Schneelande, Dschungel und Sumpf, verderbte Lande, Vulkanlande, Arkane Wälder. Eine noch unbekannte
  Zone zählt als gemäßigt. Wetter zählt nur, wenn die Wetterintensität über 0 liegt.
- **Tageszeit**: legt den Himmel fest (Tag, Morgen- und Abenddämmerung, Nacht). Die Nacht folgt
  Tag und Nacht des Spiels, die Dämmerung der Serverzeit. Kein Himmel in Innenräumen oder im Dungeon.
- Die Zeile rechts zeigt den Ort und die Tageszeit, die gerade erkannt werden. Hat ein Dungeon, ein
  Innenraum oder das Wetter Vorrang vor einer von dir eingestellten Zone, wird das angezeigt.
- **Zu bearbeitender Kontext**: wähle einen Kontext und stelle darunter seine Filter ein. Der Knopf
  Standard gibt den mitgelieferten Wert dieses Kontexts zurück.
  Das Menü hat fünf Gruppen: **Zonen** (die Zone, in der du bist, und die von dir eingestellten Zonen), **Dungeon und Innenraum**, **Wetter**, **Zonentyp** und **Himmel (Tageszeit)**.
  Die ersten vier stellen Tönung, Vignette und Körnung ein: Es gilt immer nur ein Ort, in der oben genannten Reihenfolge.
  Die letzte stellt den Himmel ein. Für den Anfang musst du nichts einstellen: Jeder Kontext hat bereits seine Werte.
- **Diese Zone**: erste Wahl desselben Menüs, mit dem Namen der Zone, in der du dich befindest. Wähle
  sie, um dieser Zone eine eigene Tönung, Vignette und Körnung zu geben, ausgehend von ihrer Art der
  Zone. Sie hat dann Vorrang vor der Art der Zone, aber nach Dungeon, Innenraum und Wetter. Die
  Zonen, die du eingestellt hast, bleiben im Menü. **Zonentyp** entfernt die Werte der Zone: sie folgt
  wieder ihrer Art der Zone.
- **Tag und Nacht** (unten im Reiter): **Automatisch Tag und Nacht** legt nachts den **Nachtfarbton**
  auf, nach Tag und Nacht des Spiels. Er ersetzt den Farbton des Reiters Filter. Der Wechsel erfolgt allmählich von 19 bis
  21 Uhr und von 5 bis 7 Uhr (Serverzeit). **Nachtfarbtonstärke** legt fest, wie stark er ist.
  Es funktioniert nicht zusammen mit der automatischen Stimmung: Das eine einzuschalten schaltet das andere aus.

## 5. Deine Werte und das Spiel

- Bei der ersten Installation liest Panorama deine aktuellen Spieleinstellungen. Nichts ändert sich,
  bis du ein Steuerelement bewegst.
- Eine Änderung im Grafikmenü des Spiels oder mit `/console` wird im Fenster angezeigt.
- **Bei jedem Einloggen anwenden** (Fußzeile, standardmäßig an): Die Einstellungen, die du in Panorama
  geändert hast, werden bei jedem Einloggen erneut geschrieben. Die anderen folgen dem Grafikmenü des Spiels.
- Eine Änderung im Kampf wird am Ende des Kampfes angewendet.
- Einige Einstellungen, wie MSAA, brauchen einen Neustart der Grafik. Klicke in der Fußzeile auf
  **Neu starten** oder gib `/pano restart` ein. Der Bildschirm flackert eine Sekunde lang.

## 6. HDR unter Windows

HDR-Einstellungen gibt es im Spiel nur als Konsolenbefehle. Panorama zeigt sie im Reiter **Erweitert**,
Abschnitt **HDR (nur Konsole)**. Du brauchst einen Monitor, der HDR unterstützt.

### Schritt 1: HDR in Windows einschalten

Windows 11:

1. Öffne **Einstellungen > System > Bildschirm**.
2. Wähle den HDR-Monitor aus, wenn du mehrere hast.
3. Schalte **HDR verwenden** ein. Mit der Tastenkombination **Win + Alt + B** schaltest du es ebenfalls
   ein oder aus.

Windows 10: **Einstellungen > System > Bildschirm > Windows-HD-Farbeinstellungen** (Windows HD Color
settings), dann **HDR-Spiele und -Apps wiedergeben** (Play HDR games and apps) einschalten.

Prüfe außerdem, ob HDR im eigenen Menü des Monitors an ist, falls es dort diese Option gibt.

Schalte **Automatisches HDR** (Auto HDR) von Windows 11 aus: **Einstellungen > System > Bildschirm > HDR**. Es ist für Spiele ohne HDR gedacht. WoW erzeugt sein eigenes HDR-Bild.

### Schritt 2: Die Spitzenhelligkeit deines Monitors finden

Installiere die kostenlose App **Windows-HDR-Kalibrierung** (Windows HDR Calibration) aus dem Microsoft
Store und starte sie. Die maximale Leuchtdichte, die sie findet, ist die Spitzenhelligkeit deines
Monitors in Nits.

Ohne die App nimm die HDR-Einstufung des Monitors: DisplayHDR 400 bedeutet etwa 400 Nits, DisplayHDR 600
etwa 600, DisplayHDR 1000 etwa 1000.

### Schritt 3: HDR in Panorama einstellen

Öffne `/pano`, Reiter **Erweitert**, Abschnitt **HDR (nur Konsole)**.

1. Aktiviere **HDR-Ausgabe**.
2. Aktiviere **Spitzenhelligkeit verwenden** oder **Referenzhelligkeit verwenden**: einen von beiden, nie beide. Ohne einen wird das Bild dunkel.

**Spitzenhelligkeitsmodus (empfohlen)**

- Aktiviere **Spitzenhelligkeit verwenden**.
- Stelle **Spitzenhelligkeit (Nits)** auf den Wert aus Schritt 2.
- **HDR-Intensität** wirkt nur in diesem Modus. Der Standardwert des Spiels ist 2. Ändere ihn in kleinen
  Schritten und vergleiche: Blizzard dokumentiert seine genaue Wirkung nicht.

**Referenzhelligkeitsmodus**

- Aktiviere **Referenzhelligkeit verwenden**.
- **Referenzhelligkeit (Nits)** ist die Helligkeit von Weiß in der Szene. 203 ist der Standardwert.
  Erhöhe ihn, wenn das Bild in einem hellen Raum zu dunkel wirkt. HDR-Intensität hat in diesem Modus
  keine Wirkung.

Wenn sich das Bild nicht ändert, klicke in der Fußzeile auf **Neu starten**.

### HDR-Fehlerbehebung

| Problem | Lösung |
|---|---|
| Bild sehr dunkel | Aktiviere einen der beiden Helligkeitsmodi. |
| Bild grau oder verwaschen | Schalte HDR in Windows (Schritt 1) und im Menü des Monitors ein. |
| Automatisches HDR in Windows an | Schalte es aus (Schritt 1). |
| Lichter zu hell oder flach | Stelle die Spitzenhelligkeit auf den echten Wert deines Monitors (Schritt 2). |
| Du willst HDR aus | Deaktiviere **HDR-Ausgabe**. |

Jede HDR-Zeile hat einen Standard-Button, der den Wert des Spiels wiederherstellt.

## 7. Befehle

| Befehl | Aktion |
|---|---|
| `/pano` | Das Fenster öffnen oder schließen |
| `/pano low`, `/pano medium`, `/pano high`, `/pano extra` | Eine Voreinstellung anwenden |
| `/pano undo` | Die Einstellungen von vor der letzten Voreinstellung wiederherstellen |
| `/pano reset` | Jede Einstellung und jeden Filter auf Standard zurücksetzen |
| `/pano status` | Zeigt im Chat den erkannten Ort, die Tageszeit und die gerade angewendeten Filter (während einer Überblendung die Zielwerte) |
| `/pano apply` | In Panorama geänderte Einstellungen erneut schreiben |
| `/pano restart` | Die Grafik-Engine neu starten |
| `/pano minimap` | Den Minimap-Button zeigen oder verstecken |

## 8. Zurücksetzen

- Der **Standard**-Button in jeder Zeile setzt diese Einstellung zurück.
- Der Button **Standard** des Grafikmenüs des Spiels setzt nur die Einstellungen zurück, die dieses Menü
  verwaltet, und Panorama folgt ihm. Nutze für die anderen und für die Filter die Standard-Buttons in `/pano`.
- **Alles zurücksetzen** (Fußzeile, mit Bestätigung) oder `/pano reset`: setzt jede in Panorama geänderte
  Einstellung und jeden Filter auf den Standard zurück. Lässt sich nicht rückgängig machen.
  Der Tab Stimmung und die eingestellten Zonen werden ebenfalls zurückgesetzt.
