# Data Collection App (iotaPJ)

Questa è un'applicazione Flutter sviluppata per la registrazione e l'invio intensivo dei dati dai sensori del dispositivo e da altre informazioni di contesto. Il progetto è strutturato utilizzando le best practices di architettura (domain-driven/clean architecture) per garantire scalabilità e facilitare il lavoro in team e su GitHub.

L'app continua la registrazione dei dati anche quando è chiusa o in background grazie all'uso di Service in background dedicati per Android/iOS.

---

## 🚀 Funzionalità Principali

*   **Raccolta Dati Sensori Continuativa**: Acquisizione in background dai sensori (Accelerometro, Giroscopio, ecc.) tramite `sensors_plus`.
*   **Informazioni sul Contesto**: Acquisizione dello stato della batteria (`battery_plus`) e potenziale context-awareness aggiuntiva.
*   **Gestione Sessioni**: Avvio, pausa e invio delle registrazioni di sessione.
*   **Background Tasks & Services**: Utilizzo integrato di `flutter_background_service` e `workmanager` per l'esecuzione ininterrotta della ricezione dei dati.
*   **Archivio Dati Offline**: Salvataggio asincrono, strutturato ed efficiente di tutti i log tramite `drift` (SQLite). Le API garantiscono di effettuare le upload sync quando la connessione lo permette.
*   **Autenticazione & Storage Sicuro**: Gestione dei token OAuth e delle credenziali sensibili su `flutter_secure_storage`.
*   **Ecological Momentary Assessment (EMA)**: Modulo per sottoporre questionari e valutazioni contestuali all'utente.
*   **Sistema Notifiche**: Interazione diretta durante l'esecuzione in background tramite un sistema avanzato di notifiche (`awesome_notifications`, `flutter_local_notifications`).

---

## 📂 Architettura e Struttura del Codice

Il progetto segue un approccio Feature-First con stratificazione (Layered Architecture).
La root per lo sviluppo è `lib/` e contiene i seguenti layer:

### `lib/app/`
Entry point e definizioni globali per l'intero ciclo di vita dell'app.
*   Setup del Tema, Inizializzazione Globale, e Configurazione del Router (`go_router`).

### `lib/background/`
Gestione dell'esecuzione dei task complessi al di fuori dell'interfaccia utente (UI).
*   Codice specifico per `workmanager` e inizializzazione dei background service isolati (Isolates e Services Android/iOS).

### `lib/data/`
Strato responsabile dell'interazione con le risorse. Ha l'obiettivo di nascondere la provenienza dei dati ai moduli superiori.
*   `local/`: Interazioni con il database SQLite gestito tramite **Drift**, DAO (es. EMA e sensori), e Secure Storage.
*   `remote/`: Client API (setup di **Dio**, Interceptors) e le chiamate HTTP da e verso il server.
*   `context/`: Wrapper per recuperare dati ambientali (Batteria, Posizione, ecc.).
*   `sensors/`: Lettura diretta dallo strato hardware dei Sensori.
*   `notifications/`: Interazioni API con lo strato OS delle notifiche push e locali.

### `lib/domain/`
Logica di business e oggetti di puro Dart. Le entità e le policy delle funzionalità (nessuna dipendenza verso pacchetti Flutter/UI).

### `lib/features/`
Moduli chiusi, ognuno contiene la propria User Interface (Screen), State Management (Riverpod Providers o Controllers) e Logica specifica:
*   `auth/`: Schermate di Login, SignUP e policy.
*   `bandi/`: Consultazione bandi e opportunità.
*   `earnings/`: Statistiche dei compensi ricavati dalla raccolta.
*   `ema/`: Questionari attivi di Ecological Momentary Assessment.
*   `home/`: Dashboard principale subito dopo il login.
*   `session/`: Schermata in cui l'utente avvia, analizza o stoppa la sessione persistente di raccolta (Summary dei sensori).
*   `settings/`: Impostazioni app (permessi, gestione account).

### `lib/main.dart`
Il punto di ingresso del progetto, si occupa dell'avvio dell'app e dell'iniezione delle dipendenze primarie (es. `ProviderScope` di Riverpod).

---

## 🛠 Stack Tecnologico

Questo progetto usa alcune delle più moderne librerie per l'ecosistema Flutter:

*   **State Management & Dependency Injection**: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
*   **Routing**: [go_router](https://pub.dev/packages/go_router)
*   **Database Relazionale (ORM)**: [drift](https://pub.dev/packages/drift)
*   **Networking HTTP**: [dio](https://pub.dev/packages/dio)
*   **Task In Background**: [flutter_background_service](https://pub.dev/packages/flutter_background_service) / [workmanager](https://pub.dev/packages/workmanager)
*   **Accesso Sensori**: [sensors_plus](https://pub.dev/packages/sensors_plus)
*   **Permessi Applicazione**: [permission_handler](https://pub.dev/packages/permission_handler)

---

## 💻 Prerequisiti per lo Sviluppo

*   **Flutter SDK**: `^3.10.3`
*   Android Studio / VS Code, con plugin Dart & Flutter installati.
*   Per Android, assicurati che il manifest e le impostazioni Gradle supportino i servizi background. A causa della natura dei Background Services e SQLite, l'app va testata su un **dispositivo fisico o su un emulatore ben configurato**.

---

## ⚙️ Guida al Setup Iniziale (Getting Started)

1. **Clonare il repository**
   ```bash
   git clone <URL_della_tua_repo>
   cd <nome_cartella_repo>
   ```

2. **Scaricare le dipendenze**
   Scarica i package base listati nel pubspec.
   ```bash
   flutter pub get
   ```

3. **Generare il Codice (Build Runner)**
   Il progetto usa Drift (e potenzialmente Riverpod o Freezed). Molti file sono originati dinamicamente. *Non cercare mai di modificare i file con estensione `.g.dart` o simili*. Segui le interfacce generatrici e avvia il motore da shell:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   > 💡 *Suggerimento*: Durante lo sviluppo attivo, esegui il watch per generare automaticamente i file man mano che editi classi/provider/database:
   > `flutter pub run build_runner watch --delete-conflicting-outputs`

4. **Avviare il Progetto**
   Costruisci ed esegui sul tuo device:
   ```bash
   flutter run
   ```

## ⚠️ Note ai Collaboratori
*   **Generazione codice**: Assicurati di non fare *commit* volontari su conflitti ai file `.g.dart`. Esegui sempre una passata con `build_runner` pulita in caso di problemi d'inconsistenza Riverpod o Drift.
*   **Permessi Hardware e Batteria**: Gran parte dell'app dipende dall'autorizzazione dell'utente a bypassare l'energy saving (doze mode di Android) e consentire localizzazione locale + background. Durante il debug su dispositivi fisici, accetta manualmente questi popup.
