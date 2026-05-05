# 🛡️ StoneGuard

**Your personal kidney stone prevention companion.**

StoneGuard is a Flutter app designed to help people who suffer from calcium oxalate kidney stones manage their diet, hydration, and daily habits — putting prevention in their hands.

---

## 📱 Features

- **Food Guide** — Browse foods sorted by oxalate level (Low, Moderate, High, Very High) with kidney-stone-friendly recommendations
- **Food Logging** — Log individual foods to track your real-time daily oxalate intake; entries update the home shield and history tab instantly
- **Water Tracker** — Log daily water intake and set hydration goals to flush oxalates
- **Water Reminders** — Customizable notification reminders to stay on top of hydration
- **Symptom & Stone Logger** — Track kidney stone events, symptoms, and pain levels over time
- **Diet Tips** — Evidence-based tips for reducing calcium oxalate stone risk
- **Progress Dashboard** — Visual charts to monitor hydration trends, oxalate history, and habits over time
- **Export to Doctor** — Generate a clean PDF or shareable summary of your oxalate intake, hydration logs, and stone history to bring to doctor visits and follow-up appointments
- **Onboarding** — First-time setup lets users pick a display name and a personal avatar; goals can be fully customized before hitting the home screen
- **Settings** — Personalize your water goal, oxalate goal, reminder frequency, avatar, name, and app theme at any time

---

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | setState / Provider |
| Local Storage | shared_preferences |
| Notifications | flutter_local_notifications |
| Charts | fl_chart |
| Fonts | google_fonts |
| Image Picker | image_picker |
| Sharing / Export | share_plus |

---

## 🗂️ Project Structure

```
lib/
├── main.dart
├── models/
│   └── food_item.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── setup_screen.dart
│   ├── home_shield_screen.dart
│   ├── food_guide_screen.dart
│   ├── history_progress_screen.dart
│   ├── journal_screen.dart
│   ├── education_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── banner_ad_widget.dart
│   └── gradient_scaffold.dart
└── theme/
    └── app_theme.dart
```

---

## 📤 Export to Doctor

The **Export to Doctor** feature lets users share a clean summary of their health data directly from the app. It includes:

- **Oxalate Log** — Daily and weekly food log totals with per-item breakdown
- **Hydration History** — Water intake vs. goal for the past 7–30 days
- **Stone & Symptom Journal** — Logged stone events, pain levels, and notes
- **User Goals** — Daily oxalate and water targets set in the app

The export is generated as a shareable PDF (or text summary) via `share_plus`, so users can send it by email, message, or print it before an appointment. Accessed from the **History** tab or **Settings**.

> ⚕️ *Always bring your StoneGuard report to your urologist or nephrologist to help guide your care.*

---

## 🤝 Contributing

This project is under active development. Pull requests and suggestions are welcome! If you suffer from kidney stones and have feature ideas that could help others, feel free to open an issue.

---

## ⚠️ Disclaimer

StoneGuard is intended for informational and wellness purposes only. It is **not** a substitute for professional medical advice. Always consult your doctor or urologist for medical guidance regarding kidney stones.

---

## 📄 License

This project is open source. See [LICENSE](LICENSE) for details.

---

*Built with ❤️ by a kidney stone sufferer, for kidney stone sufferers.*
