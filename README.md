# KidneyShield

**Kidney Stone Prevention & Oxalate Tracker**

Built by an 11-time kidney stone survivor who couldn’t find a single app designed specifically for calcium oxalate stone patients — so he built one.

## What It Does

- Log foods and instantly see their oxalate content in mg
- Track daily water intake toward your hydration goal
- View 7-day and 30-day oxalate and hydration trends
- Journal symptoms, pain events, and wellness notes
- Generate a PDF report to share with your urologist or nephrologist
- Learn what to eat, what to avoid, and why it matters

## Privacy

All data is stored exclusively on-device using AES-256 encrypted SQLite. No account required. No cloud sync. No data is ever uploaded or sold.

## Medical Disclaimer

KidneyShield is a self-tracking tool, not a medical device. It does not diagnose, treat, cure, or replace the advice of a licensed healthcare provider. Always consult your urologist or nephrologist for medical guidance.

## Tech Stack

- Flutter 3.x (Dart)
- SQLCipher (sqflite_sqlcipher) — AES-256 encrypted database
- Flutter Secure Storage — Android Keystore key management
- Google AdMob — GDPR-gated ad consent
- Flutter Local Notifications — on-device reminders only

## Build

```bash
flutter pub get
flutter build appbundle --release
```

Requires `android/key.properties` (keystore credentials) and `android/local.properties` (`admobAppId`) — neither is committed to the repo.

## License

MIT © 2026 KidneyShield
