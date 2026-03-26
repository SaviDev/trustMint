# Data Collection App (iotaPJ)

This is a Flutter application developed for intensive background recording and uploading of device sensor data and other contextual information. The project is structured using best architecture practices (Domain-Driven/Clean Architecture) to ensure scalability and facilitate teamwork and GitHub collaboration.

The app continuously records data even when closed or in the background, utilizing dedicated Background Services for Android/iOS.

---

## 🚀 Key Features

*   **Continuous Sensor Data Collection**: Background acquisition from sensors (Accelerometer, Gyroscope, etc.) via `sensors_plus`.
*   **Contextual Information**: Monitoring battery state (`battery_plus`) and gathering potential additional context-awareness.
*   **Session Management**: Start, pause, and upload session recordings.
*   **Background Tasks & Services**: Seamless integration of `flutter_background_service` and `workmanager` for uninterrupted data reception.
*   **Offline Data Storage**: Asynchronous, structured, and efficient saving of all logs using `drift` (SQLite). The APIs ensure upload syncs when the connection allows.
*   **Authentication & Secure Storage**: Handling of OAuth tokens and sensitive credentials on `flutter_secure_storage`.
*   **Ecological Momentary Assessment (EMA)**: Module to present questionnaires and contextual assessments to the user.
*   **Notification System**: Direct interaction during background execution via an advanced notification system (`awesome_notifications`, `flutter_local_notifications`).

---

## 📂 Architecture and Code Structure

The project follows a Layered, Feature-First approach.
The development root is `lib/` and contains the following layers:

### `lib/app/`
Entry point and global definitions for the app's entire lifecycle.
*   Theme Setup, Global Initialization, and Router Configuration (`go_router`).

### `lib/background/`
Management of complex tasks execution outside the User Interface (UI).
*   Specific code for `workmanager` and initialization of isolated background services (Android/iOS Isolates and Services).

### `lib/data/`
Layer responsible for interacting with resources. It aims to hide data provenance from upper modules.
*   `local/`: Interactions with the SQLite database managed via **Drift**, DAOs (e.g., EMA and sensors), and Secure Storage.
*   `remote/`: API Clients (setup of **Dio**, Interceptors) and HTTP calls to and from the server.
*   `context/`: Wrappers to retrieve environmental data (Battery, Location, etc.).
*   `sensors/`: Direct reading from the hardware state of the Sensors.
*   `notifications/`: API interactions with the OS layer for push and local notifications.

### `lib/domain/`
Business logic and pure Dart objects. Entities and feature policies (no dependencies on Flutter/UI packages).

### `lib/features/`
Self-contained modules, each containing its own User Interface (Screen), State Management (Riverpod Providers or Controllers), and specific logic:
*   `auth/`: Login, SignUP screens and policies.
*   `bandi/`: Viewing grants and opportunities.
*   `earnings/`: Statistics of compensation earned from data collection.
*   `ema/`: Active Ecological Momentary Assessment questionnaires.
*   `home/`: Main dashboard immediately after login.
*   `session/`: Screen where the user starts, analyzes, or stops the persistent collection session (Sensors Summary).
*   `settings/`: App settings (permissions, account management).

### `lib/main.dart`
The entry point of the project, responsible for starting the app and injecting primary dependencies (e.g., Riverpod's `ProviderScope`).

---

## 🛠 Tech Stack

This project uses some of the most modern libraries in the Flutter ecosystem:

*   **State Management & Dependency Injection**: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
*   **Routing**: [go_router](https://pub.dev/packages/go_router)
*   **Relational Database (ORM)**: [drift](https://pub.dev/packages/drift)
*   **HTTP Networking**: [dio](https://pub.dev/packages/dio)
*   **Background Tasks**: [flutter_background_service](https://pub.dev/packages/flutter_background_service) / [workmanager](https://pub.dev/packages/workmanager)
*   **Sensors Access**: [sensors_plus](https://pub.dev/packages/sensors_plus)
*   **Application Permissions**: [permission_handler](https://pub.dev/packages/permission_handler)

---

## 💻 Development Prerequisites

*   **Flutter SDK**: `^3.10.3`
*   Android Studio / VS Code, with Dart & Flutter plugins installed.
*   For Android, assure the manifest and Gradle settings support background services. Due to the nature of Background Services and SQLite, the app must be tested on a **physical device or a properly configured emulator**.

---

## ⚙️ Getting Started Setup

1. **Clone the repository**
   ```bash
   git clone <your_repo_URL>
   cd <repo_folder_name>
   ```

2. **Download dependencies**
   Download the base packages listed in the pubspec.
   ```bash
   flutter pub get
   ```

3. **Code Generation (Build Runner)**
   The project uses Drift (and potentially Riverpod or Freezed). Many files are generated dynamically. *Never try to modify files with the `.g.dart` extension or similar*. Follow the generating interfaces and start the engine from the shell:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   > 💡 *Tip*: During active development, run the watch command to generate files automatically as you edit classes/providers/databases:
   > `flutter pub run build_runner watch --delete-conflicting-outputs`

4. **Run the Project**
   Build and run on your device:
   ```bash
   flutter run
   ```

## ⚠️ Notes for Contributors
*   **Code Generation**: Make sure not to manually commit conflict resolution on `.g.dart` files. Always run a clean `build_runner` pass in case of Riverpod or Drift inconsistency issues.
*   **Hardware and Battery Permissions**: Much of the app relies on user authorization to bypass energy saving (Android doze mode) and allow local + background location. During debugging on physical devices, manually accept these popups.

---

## 🌐 IOTA Testnet Integration (MoveVM)

We talk to the IOTA JSON-RPC directly from Flutter using Dio.

**Endpoint**: `https://api.testnet.iota.cafe`

**Contract**: `packageId = 0x8a96acb05ed372f277780cff13a894a96e79c4f1f0a3980a2f1b78d65698bab4`, module `campaign` (`join_campaign`, `update_data_hash`).

### What is wired now
1) **Real Campaign Creation**: Testing flow capability to spawn valid dynamic campaigns directly from the UI with randomized payloads and durations.
2) **Join on-chain when the user taps Join**: The app calls join_campaign and stores the returned TaskTicket object id locally.
3) **Rolling hash commitments every chunk** (see SensorLoop._processChunk). Every 10s batch computes H_n and calls update_data_hash(ticket, did, H_n) on-chain.
4) **Validation and Payout Submit**: Tapping Complete Bounty & Payout performs a validation against the exact data_hash currently mapped inside the RPC on-chain structure via .getObject, completing the smart contract validations (submit_and_payout), deleting the local session gracefully, and granting the IOTA to the worker's wallet.

### Environments & Secrets File (.env)
To protect sensitive private keys, this repository uses a .env file for testing constants.
A .env.example file is provided. Please copy it and rename it to .env, then fill in your local details:
* BACKEND_PRIVATE_KEY_HEX / BACKEND_PUBLIC_KEY_HEX -> Used by the app to simulate the backend oracle Verifier signature logic natively.
* HARDCODED_PRIVATE_KEY_HEX / HARDCODED_PUBLIC_KEY_HEX / HARDCODED_ADDRESS -> Used by the native user to fund gas and handle transaction signatures.

### Files to edit with your real values
* `lib/data/chain/iota_constants.dart`
   * `packageId` -> the address of your deployed standard smart contract.
   * `defaultUserDidObjectId` -> your on-chain DID object ID.
   * `backendDidObjectId` -> your Backend Verifier DID object ID.
   * `defaultMarketplaceConfigObjectId` -> Initialized shared configuration.

### E2E Flow recap
```
0. Create Campaign: 
   call create_campaign(bounty_amount) -> shared Campaign Object

1. When user joins a campaign:
   call join_campaign(campaign, did, clock) -> TaskTicket
   store TaskTicket ID in SecureStorage for subsequent hash updates

2. Every 10s (Background Collection):
   collect batch -> H_n = SHA256(H_{n-1} || chunk)
   upload chunk externally (TODO backend)
   call update_data_hash(ticket, did, H_n) on IOTA testnet

3. Payout Phase:
   call submit_and_payout(campaign, ticket, Config, did, OracleSignature)
   Destroy ticket and grant funds
```

