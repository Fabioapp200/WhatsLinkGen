# WhatsLink Generator

A lightweight Flutter app for starting WhatsApp conversations without saving a contact first. Enter an international phone number, open the chat directly, or copy the generated URL for use elsewhere.

## Features

- International phone-number input with country selection
- Direct WhatsApp chat launching
- One-tap chat URL copying
- Local history of the 20 most recently opened numbers
- Reopen or remove entries from recent chats
- System light/dark theme detection with a saved manual override
- No account, server, or cloud storage required

## Requirements

- Flutter 3.47 or newer
- Dart 3.13 or newer
- Java 17
- Android SDK 37 for Android builds

## Run locally

```bash
git clone https://github.com/Fabioapp200/WhatsLinkGen.git
cd WhatsLinkGen
flutter pub get
flutter run
```

Check the project before building:

```bash
flutter analyze
```

## Build for Android

Create a debug APK:

```bash
flutter build apk --debug
```

Create a Play Store release bundle:

```bash
flutter build appbundle --release
```

The release bundle is written to `build/app/outputs/bundle/release/app-release.aab`.

### Release signing

Create `android/key.properties` with your upload-key details:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=./upload-keystore.jks
```

Place the keystore at `android/upload-keystore.jks`. Both files are ignored by Git and must never be committed or shared.

## Local data and privacy

Recent phone numbers and the manual theme preference are stored only on the device through `shared_preferences`. The app does not send this history to a custom backend. Removing the app or clearing its storage deletes the saved data.

Generated links use the following format:

```text
https://api.whatsapp.com/send?phone=COUNTRY_CODE_AND_NUMBER
```

## Main dependencies

- [`intl_phone_field`](https://pub.dev/packages/intl_phone_field) — international phone input
- [`url_launcher`](https://pub.dev/packages/url_launcher) — opens WhatsApp links
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) — local history and theme storage
- [`provider`](https://pub.dev/packages/provider) — theme state management

## Project structure

```text
lib/
├── main.dart                       # Main interface and chat actions
├── chat_history_preferences.dart   # Persistent recent-chat history
├── theme_model.dart                # Theme state and system-theme handling
└── theme_preference.dart           # Persistent manual theme preference
```

## Disclaimer

WhatsLink Generator is an independent project and is not affiliated with or endorsed by WhatsApp or Meta. WhatsApp is a trademark of its respective owner.
