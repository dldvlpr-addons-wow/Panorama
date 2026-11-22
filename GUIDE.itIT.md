# Guida di Panorama

Come usare Panorama su WoW Forever e come configurare l'HDR su Windows.

**Prima fai una copia delle tue impostazioni.** Panorama modifica impostazioni del gioco, e rimuovere l'addon non le ripristina. Prima di cambiare qualsiasi cosa, chiudi il gioco e copia la cartella `WTF` della tua installazione del gioco in un posto sicuro. Per tornare indietro, chiudi il gioco e rimetti quella copia al suo posto.

## 1. Aprire la finestra

- Digita `/pano` oppure fai clic sinistro sul pulsante di Panorama sulla minimappa.
- Anche in Opzioni > AddOn > Panorama c'è un pulsante che la apre.
- Trascina la barra del titolo per spostare la finestra. Escape o il pulsante di chiusura la chiude.

Il pulsante della minimappa:

- Il clic sinistro apre o chiude la finestra.
- Il clic destro mostra i preset, annulla e il riavvio della grafica.
- Trascinalo per spostarlo intorno alla minimappa. `/pano minimap` lo mostra o lo nasconde.

## 2. La finestra

| Parte | Cosa fa |
|---|---|
| Casella di ricerca (in alto a destra) | Digita una parola per elencare le impostazioni corrispondenti di tutte le schede. Cancellala per tornare indietro. |
| Schede | Qualità, Interfaccia, Avanzate (impostazioni del gioco), poi Filtri, I miei filtri, Atmosfera (effetti di Panorama). La scheda aperta viene ricordata. |
| Selettore della lingua (a destra delle schede) | Lingua del gioco o una di dieci lingue. Cambiarla ricarica l'interfaccia. |
| Guida (a sinistra della casella di ricerca) | Apre questa guida nel gioco. |
| Preset (scheda Qualità) | Bassa, Media, Alta, Extra. Il preset che corrisponde alle tue impostazioni è evidenziato. |
| Piè di pagina | Applica a ogni accesso, pulsante minimappa, Ripristina tutto, riavvio del motore grafico. |

Fai clic sul titolo di una sezione per comprimerla o espanderla.

### Una riga di impostazione

- **Cursore**: il valore viene scritto quando rilasci il pulsante del mouse, non mentre trascini.
- **Casella del valore** accanto al cursore: digita un valore, poi premi Invio o fai clic altrove.
  Escape annulla, Tab passa alla casella successiva. La virgola funziona come separatore decimale.
  Il valore resta nell'intervallo del cursore.
- **Pulsante Predefinito**: riporta quell'impostazione al suo valore predefinito. Passaci sopra con il
  mouse per vedere il valore.
- **Segno dorato** a sinistra: hai cambiato questa impostazione.
- **Stella gialla**: anche un menu del gioco imposta questo valore. Passaci sopra con il mouse per
  vedere quale. Quel menu non rilegge il valore, quindi può mostrare un altro livello.
- **Riga in grigio**: dipende da un'altra impostazione che è disattivata (per esempio la densità della
  nebbia senza nebbia volumetrica, l'intensità della tinta senza una tinta). La riga indica quale impostazione cambiare.
- Passa il mouse su un'etichetta per leggere la sua guida completa.

## 3. Preset

| Preset | Risultato |
|---|---|
| Bassa | Massime prestazioni. Visuale corta, senza ombre. |
| Media | Bilanciato. Buone prestazioni, ombre discrete. |
| Alta | Livello Alto del gioco. Ombre complete, tutti gli effetti. |
| Extra | Alta, con la visuale più lontana. |

I preset cambiano solo le impostazioni di qualità grafica della scheda Qualità. Non toccano
fotocamera, mouse, interfaccia, nitidezza, bassa latenza, HDR né filtri.

Hai cambiato idea? **Annulla l'ultimo preset** (pulsante accanto ai preset, o `/pano undo`) ripristina
le impostazioni di prima dell'ultimo preset.

## 4. Filtri

La scheda Filtri aggiunge effetti sopra l'immagine. Non cambiano nessuna impostazione del gioco.

- **Tinta**: fai clic su un'anteprima per applicarla subito (Seppia, Calda, Fredda, Notte, Smeraldo,
  Crepuscolo). **Intensità della tinta** imposta quanto è forte.
- **Il mio filtro**: usa uno dei tuoi filtri della scheda I miei filtri. Sostituisce la tinta, la vignettatura e la grana.
- **Cielo**: gli stessi colori come sfumatura, pieni in alto sullo schermo e più chiari in basso.
  **Intensità del cielo** imposta quanto è forte.
- **Vignettatura**: scurisce i bordi dello schermo.
- **Grana**: grana animata.
- **Bande nere**: bande in alto e in basso, da 0 a 20 % dello schermo ciascuna. Il gioco continua a
  elaborare ciò che nascondono, quindi non aumentano il frame rate.

### Atmosfera

La scheda Atmosfera cambia da sola tinta, cielo, vignettatura e grana in base a dove ti trovi.

- **Atmosfera automatica**: attiva, questi filtri seguono il luogo e l'ora del giorno. Disattiva per
  impostazione predefinita. I valori della scheda Filtri restano salvati e tornano quando la
  disattivi.
- **Luogo**: imposta tinta, vignettatura e grana. Ordine: spedizione o incursione, al chiuso, meteo
  (pioggia, neve, tempesta di sabbia), poi il tipo di zona: terre temperate, deserti e terre aride,
  terre innevate, giungla e palude, terre corrotte, terre vulcaniche, foreste arcane. Una zona non
  ancora nota conta come temperata. Il meteo conta solo se Intensità del meteo è maggiore di 0.
- **Ora del giorno**: imposta il cielo (giorno, alba e tramonto, notte). La notte segue il giorno e
  la notte del gioco; alba e tramonto seguono l'ora del server. Nessun cielo al chiuso o in una
  spedizione.
- La riga a destra mostra il luogo e l'ora del giorno rilevati adesso. Quando una spedizione, il
  chiuso o il meteo vengono prima di una zona che hai impostato, lo indica.
- **Contesto da modificare**: scegli un contesto, poi regola i suoi filtri sotto. Il pulsante
  Predefinito rende il valore fornito per quel contesto.
  Il menu ha cinque gruppi: **Zone** (la zona in cui ti trovi e quelle che hai impostato), **Spedizione e interni**, **Meteo**, **Tipo di zona** e **Cielo (ora)**.
  I primi quattro regolano tinta, vignettatura, grana e una preimpostazione grafica: si applica un solo luogo alla volta, nell'ordine indicato sopra.
  L'ultimo regola il cielo. Non serve regolare nulla per iniziare: ogni contesto ha già i suoi valori.
- **Questa zona**: prima voce dello stesso menu, con il nome della zona in cui ti trovi. Sceglila per
  dare a questa zona una tinta, una vignettatura e una grana proprie, partendo dal suo tipo di zona.
  Passa allora prima del tipo di zona, ma dopo spedizione, al chiuso e meteo. Le zone che imposti
  restano nel menu. **Tipo di zona** rimuove i valori della zona: torna a seguire il suo tipo di zona.
- **Tutte le zone**: sottomenu dello stesso menu, con tutte le zone conosciute. Scegline una per impostarla senza essere lì. Le zone sono ordinate per continente.
- **Preimpostazione** e **Distanza dello scenario** (prime righe di un luogo o di una zona): si applicano finché sei in quel luogo, sopra le tue impostazioni, con l'atmosfera automatica attiva o no. La distanza dello scenario del luogo viene prima di quella della preimpostazione. Le tue impostazioni restano salvate e tornano quando te ne vai. **Le mie impostazioni** non cambia nulla. Esempio: Bassa nelle spedizioni, Extra in una zona che ti piace. In una spedizione o incursione, la prima scelta del menu regola solo quella spedizione. Nella scheda Qualità, il pulsante **Per luogo** apre queste righe per il luogo in cui sei; mostra **Qui: …** finché un luogo applica le sue. In combattimento, la modifica attende la fine del combattimento.
- **Il mio filtro** (prima riga dei filtri di un luogo o di una zona): quel luogo usa uno dei tuoi filtri della scheda I miei filtri, con il suo contrasto, la sua luminosità e il suo gamma, finché l'atmosfera automatica è attiva.
- **Giorno e notte** (in fondo alla scheda): **Giorno e notte automatici** applica la **Tinta diurna** di giorno e la **Tinta notturna**
  di notte, secondo il giorno e la notte del gioco. Sostituiscono la tinta della scheda Filtri. Il passaggio è graduale dalle 19 alle 21 e
  dalle 5 alle 7 (ora del server). **Intensità della tinta diurna** e **Intensità della tinta notturna** impostano quanto sono forti.
  Non funziona insieme all'atmosfera automatica: attivare l'uno disattiva l'altra.

## 5. I miei filtri

La scheda I miei filtri serve a creare tutti i filtri tuoi che vuoi. **Nuovo** ne aggiunge uno, **Elimina** toglie il filtro aperto: la scheda Filtri, i luoghi e le zone che lo usavano tornano a Nessuno.

- **Filtro da modificare**: sceglie il filtro che le righe sotto regolano. **Nome**: dagli un nome (Invio per confermare).
- **Rosso**, **Verde**, **Blu** (in %): colore della tinta del filtro. **Intensità della tinta**: la sua forza.
- **Vignettatura** e **Grana**: quelle del filtro.
- **Contrasto**, **Luminosità**, **Gamma**: impostazioni dell'immagine che il filtro dà al gioco finché è applicato; poi tornano i tuoi valori. Le mie impostazioni: non cambia nulla. A seconda della modalità di visualizzazione possono restare senza effetto.
- Finché la scheda è aperta, il filtro mostrato si vede in diretta sul gioco.
- Per usare un filtro: sceglilo nella riga **Il mio filtro** della scheda Filtri (ovunque), oppure per un luogo o una zona nella scheda Atmosfera (atmosfera automatica attiva). Sostituisce allora la tinta, la vignettatura e la grana, le cui righe sono in grigio. Nessuno: non cambia nulla.

## 6. I tuoi valori e il gioco

- Alla prima installazione, Panorama legge le impostazioni attuali del gioco. Non cambia nulla finché
  non muovi un controllo.
- Una modifica fatta nel menu Grafica del gioco o con `/console` compare nella finestra.
- **Applica a ogni accesso** (piè di pagina, attivo per impostazione predefinita): le impostazioni che
  hai cambiato in Panorama vengono scritte di nuovo a ogni accesso. Le altre seguono il menu Grafica
  del gioco.
- Una modifica fatta durante il combattimento viene applicata quando il combattimento finisce.
- Alcune impostazioni, come MSAA, richiedono un riavvio della grafica. Fai clic su **Riavvia** nel
  piè di pagina o digita `/pano restart`. Lo schermo sfarfalla per un secondo.

## 7. HDR su Windows

Le impostazioni HDR esistono nel gioco solo come comandi della console. Panorama le mostra nella scheda
**Avanzate**, sezione **HDR (solo console)**. Serve un monitor che supporti l'HDR.

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

Apri `/pano`, scheda **Avanzate**, sezione **HDR (solo console)**.

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
| `/pano undo` | Ripristina le impostazioni di prima dell'ultimo preset |
| `/pano reset` | Riporta ogni impostazione e ogni filtro al valore predefinito |
| `/pano status` | Mostra nella chat il luogo e il momento rilevati e i filtri applicati ora (durante una dissolvenza, i valori di arrivo) |
| `/pano apply` | Scrive di nuovo le impostazioni cambiate in Panorama |
| `/pano restart` | Riavvia il motore grafico |
| `/pano minimap` | Mostra o nasconde il pulsante della minimappa |

## 9. Ripristino

- Il pulsante **Predefinito** di ogni riga ripristina quell'impostazione.
- Il pulsante **Predefiniti** del menu Grafica del gioco ripristina solo le impostazioni che quel menu
  gestisce, e Panorama lo segue. Usa i pulsanti Predefinito in `/pano` per le altre e per i filtri.
- **Ripristina tutto** (piè di pagina, con conferma) o `/pano reset`: riporta ogni impostazione modificata
  in Panorama e ogni filtro al valore predefinito. Non si può annullare.
  Anche la scheda Atmosfera e le zone impostate vengono ripristinate. Anche i tuoi filtri della scheda I miei filtri vengono cancellati.
