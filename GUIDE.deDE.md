# Panorama-Anleitung

So benutzt du Panorama auf WoW Forever und richtest HDR unter Windows ein.

**Sichere zuerst deine Einstellungen.** Panorama ändert Spieleinstellungen, und das Entfernen des Addons setzt sie nicht zurück. Bevor du etwas änderst, beende das Spiel und kopiere den Ordner `WTF` deiner Spielinstallation an einen sicheren Ort. Um zurückzukehren, beende das Spiel und lege diese Kopie wieder an ihren Platz.

## 1. Das Fenster öffnen

- Gib `/pano` ein oder klicke mit der linken Maustaste auf den Panorama-Button an der Minimap.
- Unter Optionen > AddOns > Panorama gibt es ebenfalls einen Button, der es öffnet.
- Ziehe die Titelleiste, um das Fenster zu verschieben. Escape oder der Schließen-Button schließt es.

Der Minimap-Button:

- Linksklick öffnet oder schließt das Fenster.
- Rechtsklick zeigt die Voreinstellungen, Rückgängig, Wiederholen und den Neustart der Grafik.
- Ziehe ihn, um ihn um die Minimap zu bewegen. `/pano minimap` zeigt oder versteckt ihn.

## 2. Das Fenster

| Bereich | Funktion |
|---|---|
| **Einfach**, **Erweitert** (neben dem Titel) | Einfach: Jeder Reiter zeigt eine kurze Liste der wichtigsten Einstellungen, ohne Abschnitte. Erweitert: alle Einstellungen, nach Abschnitten, mit den Regeln pro Ort und dem Abschnitt Experten. Bei der Erstinstallation ist es Einfach; wenn du Panorama schon benutzt hast, ist es Erweitert. Die Suche findet immer alle Einstellungen. |
| Anleitung (oben rechts) | Öffnet diese Anleitung im Spiel. |
| Menü **Optionen** (oben rechts) | **Sprache** (Spielsprache oder eine von zehn Sprachen; eine Änderung lädt die Oberfläche neu), **Bei jedem Einloggen anwenden**, **Minimap-Button**, **Alles zurücksetzen…**. |
| **Aktuelles Aussehen:** (Leiste unter dem Titel) | Das Aussehen, das gerade auf der Welt liegt, und wer es vorgibt: du, Tag und Nacht oder der Ort. Ihr Button (**Bearbeiten**, **Diese Regel bearbeiten**) öffnet die Stelle, an der du es änderst. Fahre mit der Maus über die Leiste, um zu sehen, was Vorrang hat. |
| Reiter | **Bild** (Grafikqualität), **HDR**, **Stimmung** (Aussehen der Welt), **Meine Filter**. Der geöffnete Reiter wird gespeichert. |
| Suchfeld (rechts neben den Reitern) | Gib ein Wort ein, um die passenden Einstellungen aller Reiter aufzulisten. Leere es, um zurückzukehren. |
| Voreinstellungen (Reiter Bild) | Niedrig, Mittel, Hoch, Extra. Die Voreinstellung, die zu deinen Einstellungen passt, ist hervorgehoben. |
| Fußzeile | **Rückgängig** macht deine letzte Änderung rückgängig: Regler, Feld, Voreinstellung, Filter, Stimmung oder Alles zurücksetzen. **Wiederholen** stellt sie wieder her. Die letzten 20 Änderungen bleiben bis `/reload` erhalten. **Neu starten** startet die Grafik-Engine neu. |

Klicke im Modus Erweitert auf einen Abschnittstitel, um ihn ein- oder auszuklappen. Der Abschnitt **Experten (nur Konsole)** ist
zunächst eingeklappt. Ein Abschnittstitel zeigt, wie viele seiner Einstellungen du geändert hast.

### Eine Einstellungszeile

- **Schieberegler**: Der Wert wird geschrieben, wenn du die Maustaste loslässt, nicht während du ziehst.
- **Wertfeld** neben dem Regler: Gib einen Wert ein und drücke dann Enter oder klicke woanders hin.
  Escape bricht ab, Tab springt zum nächsten Feld. Ein Komma funktioniert als Dezimaltrennzeichen.
  Der Wert bleibt im Bereich des Reglers.
- **Standard-Button**: setzt diese Einstellung auf ihren Standardwert zurück. Fahre mit der Maus darüber,
  um den Wert zu sehen.
- **Goldene Markierung** links: Du hast diese Einstellung geändert.
- **Spielmenü**: Wenn ein Spielmenü diesen Wert ebenfalls setzt, nennt die Hilfe der Beschriftung es. Dieses Menü
  liest den Wert nicht zurück, es kann also eine andere Stufe zeigen.
- **Ausgegraute Zeile**: Sie hängt von einer anderen Einstellung ab, die aus ist (zum Beispiel **Qualität des volumetrischen Nebels**
  ohne **Volumetrischer Nebel**, Farbtonstärke ohne Farbton), oder ein Modus legt sie fest. Fahre mit der Maus über die Beschriftung, um den Grund zu sehen.
  Eine Zeile, die von einer anderen abhängt, ist nach rechts eingerückt, direkt unter ihr.
- Fahre mit der Maus über eine Beschriftung, um die ganze Hilfe zu lesen.

## 3. Voreinstellungen

| Voreinstellung | Ergebnis |
|---|---|
| Niedrig | Beste Leistung. Kurze Sichtweite, keine Schatten. |
| Mittel | Ausgewogen. Gute Leistung, ordentliche Schatten. |
| Hoch | Stufe Hoch des Spiels. Volle Schatten, alle Effekte. |
| Extra | Hoch, mit der größten Sichtweite. |

Voreinstellungen ändern nur die Grafikqualitäts-Einstellungen im Reiter Bild. Sie ändern nicht
Kamera, Maus, Oberfläche, Schärfung, niedrige Latenz, HDR oder Filter.

Anders überlegt? **Rückgängig** (Fußzeile, oder `/pano undo`)
stellt die Einstellungen von vor der Voreinstellung wieder her.

## 4. Stimmung

Der Reiter Stimmung legt das Aussehen der Welt fest: Effekte über dem Bild. Sie ändern keine Spieleinstellung.

- **Modus** (oben im Reiter): **Fest** (derselbe Filter überall), **Tag und Nacht** (ein Tagfarbton und ein
  Nachtfarbton) oder **Nach Ort** (siehe unten). Standardmäßig Fest.
- **Hier**: der Ort und die Tageszeit, die gerade erkannt werden. Hat ein Dungeon, ein Innenraum oder das Wetter
  Vorrang vor einer von dir eingestellten Zone, wird das angezeigt.
- **Filter** (Modi Fest und Tag und Nacht): **Basis** nutzt die Zeilen darunter. Einer deiner Filter
  (Reiter Meine Filter) ersetzt Farbton, Vignette und Filmkorn und bringt seinen Kontrast,
  seine Helligkeit und sein Gamma mit. **Filter bearbeiten** öffnet ihn im Reiter Meine Filter.
- **Farbton**: Klicke auf eine Vorschau, um ihn sofort anzuwenden (Sepia, Warm, Kalt, Nacht, Smaragd,
  Dämmerung). **Farbtonstärke** legt fest, wie stark er ist.
- **Vignette**: dunkelt die Bildschirmränder ab.
- **Filmkorn**: animiertes Korn.
- **Tagfarbton** und **Nachtfarbton** (Modus Tag und Nacht): Panorama legt tagsüber den Tagfarbton und nachts den Nachtfarbton
  auf, nach Tag und Nacht des Spiels. Sie ersetzen den Farbton. Der Wechsel erfolgt allmählich von 19 bis
  21 Uhr und von 5 bis 7 Uhr (Serverzeit). Einer deiner Filter, den du in der Zeile Filter wählst,
  ersetzt sie.
- **Himmel**: dieselben Farben als Verlauf, oben am Bildschirm voll und unten heller.
  **Himmelsstärke** legt fest, wie stark er ist.
- **Schwarze Balken**: Balken oben und unten, jeweils 0 bis 20 % des Bildschirms, in jedem Modus. Das Spiel rendert
  weiterhin, was sie verdecken, daher steigern sie die Bildrate nicht.

Im Modus Einfach zeigt der Reiter den Modus, den Ort, den Filter, den Farbton und seine Stärke sowie die
Tag- und Nachtfarbtöne. Vignette, Filmkorn, Himmel und schwarze Balken gibt es im Modus Erweitert.

### Nach Ort

Im Modus **Nach Ort** ändern sich Tönung, Himmel, Vignette und Körnung von selbst, passend zu deinem Ort.

- Die Zeilen des Modus Fest sind ausgeblendet: Die Regel des Ortes ersetzt sie. Nur die schwarzen Balken bleiben.
  Ihre Werte bleiben gespeichert und kehren zurück, wenn du den Modus wechselst.
  Im Modus Einfach gelten die mitgelieferten Regeln; wähle Erweitert, um sie zu bearbeiten.
- **Ort**: legt Tönung, Vignette und Körnung fest. Reihenfolge: Dungeon oder Schlachtzug, Innenraum,
  Wetter (Regen, Schnee, Sandsturm), dann die Art der Zone: gemäßigte Lande, Wüsten und Ödland,
  Schneelande, Dschungel und Sumpf, verderbte Lande, Vulkanlande, Arkane Wälder. Eine noch unbekannte
  Zone zählt als gemäßigt. Wetter zählt nur, wenn die Wetterintensität über 0 liegt.
- **Tageszeit**: legt den Himmel fest (Tag, Morgen- und Abenddämmerung, Nacht). Die Nacht folgt
  Tag und Nacht des Spiels, die Dämmerung der Serverzeit. Kein Himmel in Innenräumen oder im Dungeon.
- **Regel** (Modus Erweitert): wähle eine Regel und stelle sie darunter ein. Der Button
  Standard gibt den mitgelieferten Wert dieser Regel zurück. Wenn sich das Fenster zum ersten Mal öffnet, ist die Regel des Ortes, an dem du bist, geöffnet.
  Das Menü hat fünf Gruppen: **Zonen** (die Zone, in der du bist, und die von dir eingestellten Zonen), **Dungeon und Innenraum**, **Wetter**, **Zonentyp** und **Himmel (Tageszeit)**.
  Die ersten vier stellen Tönung, Vignette, Körnung und eine Grafikvoreinstellung ein: Es gilt immer nur ein Ort, in der oben genannten Reihenfolge.
  Die letzte stellt den Himmel ein. Für den Anfang musst du nichts einstellen: Jede Regel hat bereits ihre Werte.
- **Diese Zone**: erste Wahl desselben Menüs, mit dem Namen der Zone, in der du dich befindest. Wähle
  sie, um dieser Zone eine eigene Tönung, Vignette und Körnung zu geben, ausgehend von ihrer Art der
  Zone. Sie hat dann Vorrang vor der Art der Zone, aber nach Dungeon, Innenraum und Wetter. Die
  Zonen, die du eingestellt hast, bleiben im Menü. **Zurück zum Zonentyp** (neben dem Menü) entfernt die Werte der Zone: sie folgt
  wieder ihrer Art der Zone.
- **Alle Zonen**: Untermenü desselben Menüs, mit allen bekannten Zonen. Wähle eine, um sie einzustellen, ohne dort zu sein. Die Zonen sind nach Kontinent geordnet.
- **Voreinstellung** und **Sichtweite der Umgebung** (Abschnitt **Bild** eines Ortes oder einer Zone): Sie gelten, solange du an diesem Ort bist, über deinen eigenen Einstellungen, in jedem Stimmungsmodus. Die Sichtweite des Ortes hat Vorrang vor der Sichtweite der Voreinstellung. Deine eigenen Einstellungen bleiben gespeichert und kommen zurück, wenn du gehst. **Meine Einstellungen** ändert nichts. Beispiel: Niedrig in Dungeons, Extra in einer Zone, die du magst. In einem Dungeon oder Schlachtzug stellt die erste Auswahl des Menüs nur diesen Dungeon ein. Im Reiter Bild erscheint neben den Voreinstellungen **Hier: …**, solange ein Ort eigene Werte vorgibt; im Modus Erweitert öffnet es diese Regel. Im Kampf wartet die Änderung bis zum Ende des Kampfes.
- **Filter** (erste Zeile des Abschnitts **Aussehen** eines Ortes oder einer Zone): Dieser Ort nutzt einen deiner Filter aus dem Reiter Meine Filter, mit dessen Kontrast, Helligkeit und Gamma. **Einstellungen unten**: Tönung, Vignette und Körnung der Regel. Der Abschnitt Aussehen gilt nur im Modus Nach Ort.

## 5. Meine Filter

Im Reiter Meine Filter kannst du beliebig viele eigene Filter erstellen. Der geöffnete Filter wird auf der Welt nur als Vorschau gezeigt; der angewendete wird im Tab Stimmung gewählt. **Neu** fügt einen hinzu und öffnet ihn, **Löschen** entfernt den geöffneten: der Filter des Reiters Stimmung und die Regeln, die ihn nutzten, wechseln zu keinem Filter. Ein Filter bleibt immer erhalten.

- **Filter**: wählt den Filter, den die Zeilen darunter einstellen. **Name**: gib ihm einen Namen (Enter zum Bestätigen).
- **Farbton**: Klicke auf eine Vorschau, um dem Filter diese Farbe zu geben. **Rot**, **Grün**, **Blau** (in %): seine genaue Farbe. **Farbtonstärke**: seine Stärke.
- **Vignette** und **Filmkorn**: die des Filters.
- **Kontrast**, **Helligkeit**, **Gamma**: Bildeinstellungen, die der Filter dem Spiel gibt, solange er angewendet wird; deine eigenen Werte kehren danach zurück. Meine Einstellungen: nichts ändert sich. Je nach Anzeigemodus können sie wirkungslos bleiben.
- Im Modus Einfach zeigt der Reiter nur den Farbton und die Farbtonstärke.
- Solange der Reiter geöffnet ist, ist der angezeigte Filter live im Spiel zu sehen. Die Leiste **Aktuelles Aussehen:** sagt, wenn es nur eine Vorschau ist.
- So nutzt du einen Filter: Wähle ihn in der Zeile **Filter** des Reiters Stimmung (Modi Fest und Tag und Nacht) oder für einen Ort oder eine Zone (Modus Nach Ort). Er ersetzt dann Farbton, Vignette und Filmkorn. **Basis** oder **Einstellungen unten**: nichts ändert sich.

## 6. Deine Werte und das Spiel

- Bei der ersten Installation liest Panorama deine aktuellen Spieleinstellungen. Nichts ändert sich,
  bis du ein Steuerelement bewegst.
- Eine Änderung im Grafikmenü des Spiels oder mit `/console` wird im Fenster angezeigt.
- **Bei jedem Einloggen anwenden** (Menü Optionen, standardmäßig an): Die Einstellungen, die du in Panorama
  geändert hast, werden bei jedem Einloggen erneut geschrieben. Die anderen folgen dem Grafikmenü des Spiels.
- Eine Änderung im Kampf wird am Ende des Kampfes angewendet.
- Einige Einstellungen, wie MSAA, brauchen einen Neustart der Grafik. Klicke in der Fußzeile auf
  **Neu starten** oder gib `/pano restart` ein. Der Bildschirm flackert eine Sekunde lang.

## 7. HDR unter Windows

HDR-Einstellungen gibt es im Spiel nur als Konsolenbefehle. Panorama zeigt sie im Reiter **HDR**.
Du brauchst einen Monitor, der HDR unterstützt.

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

Öffne `/pano`, Reiter **HDR**. Im Modus Einfach zeigt der Reiter nur die ersten drei Zeilen unten: wähle
**Erweitert**, um **HDR-Intensität** und die Referenzhelligkeit zu sehen.

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

## 8. Befehle

| Befehl | Aktion |
|---|---|
| `/pano` | Das Fenster öffnen oder schließen |
| `/pano low`, `/pano medium`, `/pano high`, `/pano extra` | Eine Voreinstellung anwenden |
| `/pano undo` | Die letzte Änderung rückgängig machen |
| `/pano redo` | Die gerade rückgängig gemachte Änderung wiederherstellen |
| `/pano reset` | Jede Einstellung und jeden Filter auf Standard zurücksetzen |
| `/pano status` | Zeigt im Chat den erkannten Ort, die Tageszeit und die gerade angewendeten Filter (während einer Überblendung die Zielwerte) |
| `/pano apply` | In Panorama geänderte Einstellungen erneut schreiben |
| `/pano restart` | Die Grafik-Engine neu starten |
| `/pano minimap` | Den Minimap-Button zeigen oder verstecken |
| `/pano blackbars 10` | Schwarze Balken mit 10 % der Bildschirmhöhe (0 bis 20). `off` entfernt sie |
| `/pano grain 10` | Filmkorn auf 10 (0 bis 100). `off` entfernt es |
| `/pano vignette 10` | Vignette auf 10 (0 bis 100). `off` entfernt sie |

## 9. Zurücksetzen

- Der **Standard**-Button in jeder Zeile setzt diese Einstellung zurück.
- Der Button **Standard** des Grafikmenüs des Spiels setzt nur die Einstellungen zurück, die dieses Menü
  verwaltet, und Panorama folgt ihm. Nutze für die anderen und für die Filter die Standard-Buttons in `/pano`.
- **Alles zurücksetzen…** (Menü Optionen, mit Bestätigung) oder `/pano reset`: setzt jede Einstellung im Fenster,
  ob in Panorama geändert oder nicht, und jeden Filter auf den Standard zurück. **Rückgängig** macht es bis `/reload` rückgängig.
  Der Reiter Stimmung und die eingestellten Zonen werden ebenfalls zurückgesetzt. Deine Filter im Reiter Meine Filter werden ebenfalls gelöscht.
