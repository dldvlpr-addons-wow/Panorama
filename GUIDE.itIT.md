# Guida di Panorama

Come usare Panorama su WoW Forever e come configurare l'HDR su Windows.

**Prima fai una copia delle tue impostazioni.** Panorama modifica impostazioni del gioco, e rimuovere l'addon non le ripristina. Prima di cambiare qualsiasi cosa, chiudi il gioco e copia la cartella `WTF` della tua installazione del gioco in un posto sicuro. Per tornare indietro, chiudi il gioco e rimetti quella copia al suo posto.

## 1. Aprire la finestra

- Digita `/pano` oppure fai clic sinistro sul pulsante di Panorama sulla minimappa.
- Anche in Opzioni > AddOn > Panorama c'è un pulsante che la apre.
- Trascina la barra del titolo per spostare la finestra. Escape o il pulsante di chiusura la chiude.

Il pulsante della minimappa:

- Il clic sinistro apre o chiude la finestra.
- Il clic destro mostra i preset, annulla, ripeti e il riavvio della grafica.
- Trascinalo per spostarlo intorno alla minimappa. `/pano minimap` lo mostra o lo nasconde.

## 2. La finestra

| Parte | Cosa fa |
|---|---|
| **Semplice**, **Avanzato** (accanto al titolo) | Semplice: ogni scheda mostra un breve elenco delle impostazioni principali, senza sezioni. Avanzato: tutte le impostazioni, per sezione, con le regole per luogo e la sezione Esperti. Alla prima installazione è Semplice; se usavi già Panorama, è Avanzato. La ricerca trova sempre tutte le impostazioni. |
| Guida (in alto a destra) | Apre questa guida nel gioco. |
| Menu **Opzioni** (in alto a destra) | **Lingua** (lingua del gioco o una di dieci lingue; cambiarla ricarica l'interfaccia), **Applica a ogni accesso**, **Pulsante minimappa**, **Ripristina tutto…**. |
| **Aspetto attuale:** (barra sotto il titolo) | L'aspetto sul mondo adesso, e chi lo imposta: tu, Giorno e notte o il luogo. Il suo pulsante (**Modifica**, **Modifica questa regola**) apre dove cambiarlo. Passa il mouse sulla barra per vedere quale viene prima. |
| Schede | **Immagine** (qualità grafica), **HDR**, **Atmosfera** (aspetto del mondo), **Miei filtri**. La scheda aperta viene ricordata. |
| Casella di ricerca (a destra delle schede) | Digita una parola per elencare le impostazioni corrispondenti di tutte le schede. Cancellala per tornare indietro. |
| Preset (scheda Immagine) | Bassa, Media, Alta, Extra. Il preset che corrisponde alle tue impostazioni è evidenziato. |
| Piè di pagina | **Annulla** cancella la tua ultima modifica: cursore, casella, preset, filtro, atmosfera o Ripristina tutto. **Ripeti** la rimette. Le ultime 20 modifiche restano fino a `/reload`. **Riavvia** riavvia il motore grafico. |

In modalità Avanzato, fai clic sul titolo di una sezione per comprimerla o espanderla. La sezione **Esperti (solo console)** parte compressa. Il titolo di una sezione indica quante delle sue impostazioni hai cambiato.

### Una riga di impostazione

- **Cursore**: il valore viene scritto quando rilasci il pulsante del mouse, non mentre trascini.
- **Casella del valore** accanto al cursore: digita un valore, poi premi Invio o fai clic altrove.
  Escape annulla, Tab passa alla casella successiva. La virgola funziona come separatore decimale.
  Il valore resta nell'intervallo del cursore.
- **Pulsante Predefinito**: riporta quell'impostazione al suo valore predefinito. Passaci sopra con il
  mouse per vedere il valore.
- **Segno dorato** a sinistra: hai cambiato questa impostazione.
- **Menu del gioco**: quando anche un menu del gioco imposta questo valore, la guida dell'etichetta lo
  nomina. Quel menu non rilegge il valore, quindi può mostrare un altro livello.
- **Riga in grigio**: dipende da un'altra impostazione che è disattivata (per esempio **Qualità della nebbia volumetrica**
  senza **Nebbia volumetrica**, l'intensità della tinta senza una tinta), oppure una modalità la imposta.
  Passa il mouse sull'etichetta per vedere perché. Una riga che dipende da un'altra è spostata a destra, subito sotto.
- Passa il mouse su un'etichetta per leggere la sua guida completa.

## 3. Preset

| Preset | Risultato |
|---|---|
| Bassa | Massime prestazioni. Visuale corta, senza ombre. |
| Media | Bilanciato. Buone prestazioni, ombre discrete. |
| Alta | Livello Alto del gioco. Ombre complete, tutti gli effetti. |
| Extra | Alta, con la visuale più lontana. |

I preset cambiano solo le impostazioni di qualità grafica della scheda Immagine. Non toccano
fotocamera, mouse, interfaccia, nitidezza, bassa latenza, HDR né filtri.

Hai cambiato idea? **Annulla** (piè di pagina, o `/pano undo`) ripristina
le impostazioni di prima del preset.

## 4. Atmosfera

La scheda Atmosfera imposta l'aspetto del mondo: effetti sopra l'immagine. Non cambiano nessuna impostazione del gioco.

- **Modalità** (in alto nella scheda): **Fisso** (lo stesso filtro ovunque), **Giorno e notte** (una tinta
  diurna e una tinta notturna) o **In base al luogo** (vedi sotto). Fisso per impostazione predefinita.
- **Qui**: il luogo e l'ora del giorno rilevati adesso. Quando una spedizione, il chiuso o il meteo
  vengono prima di una zona che hai impostato, lo indica.
- **Filtro** (modalità Fisso e Giorno e notte): **Base** usa le righe sotto. Uno dei tuoi filtri
  (scheda Miei filtri) sostituisce la tinta, la vignettatura e la grana, e porta il suo contrasto,
  la sua luminosità e il suo gamma. **Modifica filtro** lo apre nella scheda Miei filtri.
- **Tinta**: fai clic su un'anteprima per applicarla subito (Seppia, Calda, Fredda, Notte, Smeraldo,
  Crepuscolo). **Intensità della tinta** imposta quanto è forte.
- **Vignettatura**: scurisce i bordi dello schermo.
- **Grana**: grana animata.
- **Tinta diurna** e **Tinta notturna** (modalità Giorno e notte): Panorama applica la tinta diurna di giorno e la tinta
  notturna di notte, secondo il giorno e la notte del gioco. Sostituiscono la tinta. Il passaggio è graduale dalle 19 alle 21 e
  dalle 5 alle 7 (ora del server). Uno dei tuoi filtri scelto nella riga Filtro le sostituisce.
- **Cielo**: gli stessi colori come sfumatura, pieni in alto sullo schermo e più chiari in basso.
  **Intensità del cielo** imposta quanto è forte.
- **Bande nere**: bande in alto e in basso, da 0 a 20 % dello schermo ciascuna, in ogni modalità. Il gioco continua a
  elaborare ciò che nascondono, quindi non aumentano il frame rate.

In modalità Semplice, la scheda mostra la modalità, il luogo, il filtro, la tinta e la sua intensità, e le
tinte diurna e notturna. Vignettatura, grana, cielo e bande nere sono in modalità Avanzato.

### In base al luogo

Nella modalità **In base al luogo**, tinta, cielo, vignettatura e grana cambiano da soli, in base a dove ti trovi.

- Le righe della modalità Fisso sono nascoste: la regola del luogo le sostituisce. Restano solo le bande nere.
  I loro valori restano salvati e tornano quando cambi modalità.
  In modalità Semplice si applicano le regole fornite; scegli Avanzato per modificarle.
- **Luogo**: imposta tinta, vignettatura e grana. Ordine: spedizione o incursione, al chiuso, meteo
  (pioggia, neve, tempesta di sabbia), poi il tipo di zona: terre temperate, deserti e terre aride,
  terre innevate, giungla e palude, terre corrotte, terre vulcaniche, foreste arcane. Una zona non
  ancora nota conta come temperata. Il meteo conta solo se Intensità del meteo è maggiore di 0.
- **Ora del giorno**: imposta il cielo (giorno, alba e tramonto, notte). La notte segue il giorno e
  la notte del gioco; alba e tramonto seguono l'ora del server. Nessun cielo al chiuso o in una
  spedizione.
- **Regola** (modalità Avanzato): scegli una regola, poi regolala sotto. Il pulsante
  Predefinito rende il valore fornito per quella regola. La prima volta che la finestra si apre, la regola del luogo in cui ti trovi è aperta.
  Il menu ha cinque gruppi: **Zone** (la zona in cui ti trovi e quelle che hai impostato), **Spedizione e interni**, **Meteo**, **Tipo di zona** e **Cielo (ora)**.
  I primi quattro regolano tinta, vignettatura, grana e una preimpostazione grafica: si applica un solo luogo alla volta, nell'ordine indicato sopra.
  L'ultimo regola il cielo. Non serve regolare nulla per iniziare: ogni regola ha già i suoi valori.
- **Questa zona**: prima voce dello stesso menu, con il nome della zona in cui ti trovi. Sceglila per
  dare a questa zona una tinta, una vignettatura e una grana proprie, partendo dal suo tipo di zona.
  Passa allora prima del tipo di zona, ma dopo spedizione, al chiuso e meteo. Le zone che imposti
  restano nel menu. **Torna al tipo di zona** (accanto al menu) rimuove i valori della zona: torna a seguire il suo tipo di zona.
- **Tutte le zone**: sottomenu dello stesso menu, con tutte le zone conosciute. Scegline una per impostarla senza essere lì. Le zone sono ordinate per continente.
- **Preimpostazione** e **Distanza dello scenario** (sezione **Immagine** di un luogo o di una zona): si applicano finché sei in quel luogo, sopra le tue impostazioni, qualunque sia la modalità atmosfera. La distanza dello scenario del luogo viene prima di quella della preimpostazione. Le tue impostazioni restano salvate e tornano quando te ne vai. **Le mie impostazioni** non cambia nulla. Esempio: Bassa nelle spedizioni, Extra in una zona che ti piace. In una spedizione o incursione, la prima scelta del menu regola solo quella spedizione. Nella scheda Immagine, **Qui: …** compare accanto ai preset mentre un luogo applica i suoi; in modalità Avanzato, apre quella regola. In combattimento, la modifica attende la fine del combattimento.
- **Filtro** (prima riga della sezione **Aspetto** di un luogo o di una zona): questo luogo usa uno dei tuoi filtri della scheda Miei filtri, con il suo contrasto, la sua luminosità e il suo gamma. **Impostazioni sotto**: la tinta, la vignettatura e la grana della regola. La sezione Aspetto si applica solo in modalità In base al luogo.

## 5. Miei filtri

La scheda Miei filtri ti permette di creare tutti i filtri tuoi che vuoi. Il filtro aperto è mostrato sul mondo solo in anteprima; quello applicato si sceglie nella scheda Atmosfera. **Nuovo** ne aggiunge uno e lo apre, **Elimina** toglie quello aperto: il filtro della scheda Atmosfera e le regole che lo usavano tornano a nessun filtro. Resta sempre un filtro.

- **Filtro**: sceglie il filtro che le righe sotto regolano. **Nome**: dagli un nome (Invio per confermare).
- **Tinta**: fai clic su un'anteprima per dare al filtro quel colore. **Rosso**, **Verde**, **Blu** (in %): il suo colore esatto. **Intensità della tinta**: la sua forza.
- **Vignettatura** e **Grana**: quelle del filtro.
- **Contrasto**, **Luminosità**, **Gamma**: impostazioni dell'immagine che il filtro dà al gioco finché è applicato; poi tornano i tuoi valori. Le mie impostazioni: non cambia nulla. A seconda della modalità di visualizzazione possono restare senza effetto.
- In modalità Semplice, la scheda mostra solo la tinta e l'intensità della tinta.
- Finché la scheda è aperta, il filtro mostrato si vede in diretta sul gioco. La barra **Aspetto attuale:** indica quando è solo un'anteprima.
- Per usare un filtro: sceglilo nella riga **Filtro** della scheda Atmosfera (modalità Fisso e Giorno e notte), oppure di un luogo o di una zona (modalità In base al luogo). Sostituisce allora la tinta, la vignettatura e la grana. **Base** o **Impostazioni sotto**: non cambia nulla.

## 6. I tuoi valori e il gioco

- Alla prima installazione, Panorama legge le impostazioni attuali del gioco. Non cambia nulla finché
  non muovi un controllo.
- Una modifica fatta nel menu Grafica del gioco o con `/console` compare nella finestra.
- **Applica a ogni accesso** (menu Opzioni, attivo per impostazione predefinita): le impostazioni che
  hai cambiato in Panorama vengono scritte di nuovo a ogni accesso. Le altre seguono il menu Grafica
  del gioco.
- Una modifica fatta durante il combattimento viene applicata quando il combattimento finisce.
- Alcune impostazioni, come MSAA, richiedono un riavvio della grafica. Fai clic su **Riavvia** nel
  piè di pagina o digita `/pano restart`. Lo schermo sfarfalla per un secondo.

## 7. HDR su Windows

Le impostazioni HDR esistono nel gioco solo come comandi della console. Panorama le mostra nella scheda **HDR**.
Serve un monitor che supporti l'HDR.

### Passo 1: attivare l'HDR in Windows

Windows 11:

1. Apri **Impostazioni > Sistema > Schermo**.
2. Seleziona il monitor HDR se ne hai più di uno.
3. Attiva **Usa HDR**. Anche la scorciatoia **Win + Alt + B** lo attiva o lo disattiva.

Windows 10: **Impostazioni > Sistema > Schermo > Impostazioni colore HD di Windows** (Windows HD Color
settings), poi attiva **Riproduci app e giochi HDR** (Play HDR games and apps).

Controlla anche che l'HDR sia attivo nel menu del monitor stesso, se ha questa opzione.

Disattiva l'**HDR automatico** (Auto HDR) di Windows 11: **Impostazioni > Sistema > Schermo > HDR**. Serve ai giochi senza HDR. WoW produce la propria immagine HDR.

### Passo 2: trovare la luminosità massima del tuo monitor

Installa l'app gratuita **Calibrazione HDR di Windows** (Windows HDR Calibration) dal Microsoft Store
ed eseguila. La luminanza massima che trova è la luminosità massima del tuo monitor, in nit.

Senza l'app, usa la classificazione HDR del monitor: DisplayHDR 400 significa circa 400 nit,
DisplayHDR 600 circa 600, DisplayHDR 1000 circa 1000.

### Passo 3: impostare l'HDR in Panorama

Apri `/pano`, scheda **HDR**. In modalità Semplice, la scheda mostra solo le prime tre righe qui sotto: scegli
**Avanzato** per vedere **Intensità HDR** e la luminosità di riferimento.

1. Spunta **Uscita HDR**.
2. Spunta **Usa luminosità di picco** o **Usa luminosità di riferimento**: l'uno o l'altro, mai entrambi. Senza nessuno, l'immagine diventa scura.

**Modo luminosità massima (consigliato)**

- Spunta **Usa luminosità di picco**.
- Imposta **Luminosità di picco (nit)** sul valore trovato nel passo 2.
- **Intensità HDR** funziona solo in questo modo. Il valore predefinito del gioco è 2. Cambialo a
  piccoli passi e confronta: Blizzard non documenta il suo effetto esatto.

**Modo luminosità di riferimento**

- Spunta **Usa luminosità di riferimento**.
- **Luminosità di riferimento (nit)** è la luminosità del bianco nella scena. 203 è il valore standard.
  Aumentalo se l'immagine sembra troppo scura in una stanza luminosa. Intensità HDR non ha effetto
  in questo modo.

Se l'immagine non cambia, fai clic su **Riavvia** nel piè di pagina.

### Risoluzione dei problemi HDR

| Problema | Soluzione |
|---|---|
| Immagine molto scura | Spunta uno dei due modi di luminosità. |
| Immagine grigia o sbiadita | Attiva l'HDR in Windows (passo 1) e nel menu del monitor. |
| HDR automatico attivo in Windows | Disattivalo (passo 1). |
| Luci troppo forti o piatte | Imposta la luminosità massima sul valore reale del tuo monitor (passo 2). |
| Vuoi l'HDR disattivato | Togli la spunta a **Uscita HDR**. |

Ogni riga HDR ha un pulsante Predefinito che ripristina il valore del gioco.

## 8. Comandi

| Comando | Azione |
|---|---|
| `/pano` | Apre o chiude la finestra |
| `/pano low`, `/pano medium`, `/pano high`, `/pano extra` | Applica un preset |
| `/pano undo` | Annulla l'ultima modifica |
| `/pano redo` | Rimette la modifica appena annullata |
| `/pano reset` | Riporta ogni impostazione e ogni filtro al valore predefinito |
| `/pano status` | Mostra nella chat il luogo e il momento rilevati e i filtri applicati ora (durante una dissolvenza, i valori di arrivo) |
| `/pano apply` | Scrive di nuovo le impostazioni cambiate in Panorama |
| `/pano restart` | Riavvia il motore grafico |
| `/pano minimap` | Mostra o nasconde il pulsante della minimappa |
| `/pano blackbars 10` | Bande nere al 10% dell'altezza dello schermo (da 0 a 20). `off` le toglie |
| `/pano grain 10` | Grana a 10 (da 0 a 100). `off` la toglie |
| `/pano vignette 10` | Vignettatura a 10 (da 0 a 100). `off` la toglie |

## 9. Ripristino

- Il pulsante **Predefinito** di ogni riga ripristina quell'impostazione.
- Il pulsante **Predefiniti** del menu Grafica del gioco ripristina solo le impostazioni che quel menu
  gestisce, e Panorama lo segue. Usa i pulsanti Predefinito in `/pano` per le altre e per i filtri.
- **Ripristina tutto…** (menu Opzioni, con conferma) o `/pano reset`: riporta ogni impostazione modificata
  in Panorama e ogni filtro al valore predefinito. **Annulla** la annulla fino a `/reload`.
  Anche la scheda Atmosfera e le zone impostate vengono ripristinate. Anche i tuoi filtri della scheda Miei filtri vengono cancellati.
