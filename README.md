# QueX

Skip the wait. Join the queue from anywhere.

QueX is a Flutter mobile app for Android and iOS that lets customers join salon and clinic queues remotely.

**Author:** [Sai Deekshith Mulakala](https://github.com/Mulakala1120)

## Features

### Customer App
- Phone OTP login (Firebase-ready, demo mode enabled)
- Nearby salons & clinics
- Search, business details, join queue
- Live queue tracking
- Push notifications (FCM-ready)
- Profile

### Business Owner App
- Business signup & profile setup
- Queue configuration
- QR check-in code
- Owner dashboard & analytics
- Subscription plans

### Staff / Receptionist App
- Staff PIN login
- Queue dashboard
- Add walk-in, call next, skip, no show, complete

## Tech Stack

- **Flutter** / **Dart**
- **Riverpod** — state management
- **GoRouter** — navigation
- **Firebase Auth** — phone OTP (placeholder)
- **Firebase Cloud Messaging** — push notifications (placeholder)
- **Clean architecture** — `data` / `domain` / `features` / `core`
- **Dummy API data** — enabled by default

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.2+)
- Xcode (iOS) and/or Android Studio (Android)

### Setup

```bash
git clone https://github.com/Mulakala1120/quex.git
cd quex
flutter pub get
flutter create . --project-name quex   # generates android/ and ios/ if missing
flutter run
```

### Demo Credentials

| Role     | Credential        |
|----------|-------------------|
| Customer | OTP: `123456`     |
| Staff    | PIN: `1234`       |

### Firebase (production)

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android and iOS apps
3. Run `flutterfire configure`
4. Set `enableFirebase` and `enablePushNotifications` to `true` in `lib/core/config/app_config.dart`

### REST API

Set `useDummyData` to `false` in `lib/core/constants/app_constants.dart` and point `apiBaseUrl` at your backend.

## Project Structure

```
lib/
├── core/           # theme, router, network, services, DI
├── data/           # repositories, datasources, models
├── domain/         # entities, repository contracts
├── features/
│   ├── customer/
│   ├── business_owner/
│   ├── staff/
│   └── shared/
├── app.dart
└── main.dart
```

## License

Private — © Sai Deekshith Mulakala
