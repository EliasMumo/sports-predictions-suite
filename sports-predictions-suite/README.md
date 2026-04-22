# Sports Predictions Suite

A production-ready Flutter mono-repo that ships two cohesive applications sharing a single design system and data model:

- **End-User App** – polished consumer experience with real-time prediction feeds, VIP history, and a Material 3 bottom navigation shell.
- **Admin App** – authenticated console for publishing matches, updating results, and curating history directly from Firestore.

Both apps consume the same Firebase backend (Firestore + Auth) and rely on a shared package for design tokens, models, and category metadata.

## Repository Layout

```
sports-predictions-suite
├── apps
│   ├── end_user_app        # Consumer-facing Flutter app
│   └── admin_app           # Internal admin dashboard
├── shared                  # Reusable theme, models, Firestore helpers, assets
├── analysis_options.yaml   # (optional) root linting
├── pubspec.yaml            # Meta package if you want to run `flutter pub get` at root
└── README.md
```

Each Flutter app has its own `pubspec.yaml`, `analysis_options.yaml`, and `lib/src` folder organized by feature (`core`, `features`, `services`, etc.). The `shared` package is referenced via a local path dependency to guarantee both apps stay visually consistent.

## Feature Highlights

### End-User App
- Material 3 UI with light/dark themes, animated cards, and responsive layouts.
- Bottom navigation: **Free Tips**, **VIP Tips**, **Settings**.
- Category previews stream data from Firestore and navigate to a dedicated matches screen.
- Match tiles show league, kickoff, teams, prediction, score, and live status badges.
- Settings screen exposes theme controls and support info (extend with notifications/Firebase Messaging later).

### Admin App
- Firebase Email/Password login with proper loading/error states.
- Dashboard summarizes each prediction category (pending vs settled counts).
- Category management screen streams Firestore documents, offers quick result updates, score editing, and deletes.
- Bottom-sheet match form with validation, date/time pickers, and immediate Firestore writes.
- Shared design tokens keep admin tooling visually aligned with the consumer app.

## Firebase & Backend Setup

Follow these steps for **each** Flutter app (end-user + admin). You may use a single Firebase project or separate ones per app depending on your deployment strategy.

1. **Create Firebase projects** in the [Firebase Console](https://console.firebase.google.com/). Enable _Firestore_ (in Native mode) and _Firebase Authentication_ (Email/Password provider).
2. **Generate platform configs** with the FlutterFire CLI:
   ```bash
   flutterfire configure --project=<your-project-id> \
     --out=shared/lib/firebase_options.dart \
     --ios-bundle-id=com.example.predictions.user \
     --android-package-name=com.example.predictions.user
   ```
   Repeat for the admin app (different bundle IDs / package names). If you maintain two Firebase projects, keep two copies of `firebase_options.dart` (per flavor) or manage them via build flavors.
3. **Add Android configs**: place the downloaded `google-services.json` files into `apps/end_user_app/android/app/` and `apps/admin_app/android/app/`. For iOS, add `GoogleService-Info.plist` inside each app’s `ios/Runner/` directory and update the Xcode build settings.
4. **Add SHA-1 / SHA-256 fingerprints** (Android) in Firebase Console > Project Settings > Your Apps to allow Auth to work on release builds.
5. **Firestore security rules**: lock write operations to authenticated admin users and allow read-only access for the consumer app as needed. Example (simplified):
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /predictions/{category}/matches/{matchId} {
         allow read: if true;               // public reads
         allow write: if request.auth != null && request.auth.token.admin == true;
       }
       match /history/{category}/matches/{matchId} {
         allow read: if true;
         allow write: if request.auth != null && request.auth.token.admin == true;
       }
     }
   }
   ```
   Adjust for your auth strategy (custom claims, role-based rules, etc.).

## Firestore Data Model

```
predictions (collection)
  └── {categoryId} (document, e.g. "daily2")
      └── matches (sub-collection)
          └── {matchId}
              • league: string
              • matchTime: timestamp
              • homeTeam / awayTeam: string
              • prediction: string
              • score: string ("—" until settled)
              • result: "pending" | "won" | "lost"
              • createdAt: timestamp

history (collection)
  └── {categoryId} (vip_correct_score, vip_halftime_fulltime, vip_odds10plus)
      └── matches (sub-collection)
          └── {matchId} ... same schema as above
```

You can extend this schema with additional metadata (odds, stake, VIP tier, etc.) without changing the UI logic—just update the shared `MatchPrediction` model and widgets accordingly.

## Getting Started

1. **Install dependencies** per app:
   ```bash
   cd apps/end_user_app && flutter pub get
   cd ../admin_app && flutter pub get
   cd ../../shared && flutter pub get
   ```
2. **Run the apps**:
   ```bash
   cd apps/end_user_app
   flutter run --target lib/main.dart

   cd ../admin_app
   flutter run --target lib/main.dart
   ```
3. **Web/Desktop**: Both apps use Material 3 and Riverpod, so you can target web/desktop by enabling the desired platforms in Flutter.

## Cloud And Billing Setup (CLI)

Project-level setup scripts are available:

- scripts/setup_google_cloud_cli.sh
- scripts/setup_revenuecat_v2_cli.sh

Examples:

```bash
PROJECT_ID=kevobike-3dd72 REGION=us-central1 ./scripts/setup_google_cloud_cli.sh
```

```bash
export RC_SECRET_KEY='sk_...'
export RC_PROJECT_ID='projc3646c76'
./scripts/setup_revenuecat_v2_cli.sh
```

End-user app builds must pass the RevenueCat public SDK key:

```bash
flutter build appbundle --dart-define=REVENUECAT_PUBLIC_API_KEY=goog_...
```

## Extending the Suite

- **Push notifications**: integrate Firebase Cloud Messaging for VIP alerts and match settlement updates.
- **Monetization**: gate VIP categories behind in-app purchases or subscriptions.
- **Analytics**: wire Analytics/Crashlytics by adding the relevant Firebase plugins to each `pubspec.yaml`.
- **Theming**: tweak `shared/lib/design_system/app_theme.dart` to instantly re-skin both applications.

## Troubleshooting

- If the apps throw an error about `DefaultFirebaseOptions`, it means you haven’t replaced the placeholder in `shared/lib/firebase_options.dart`.
- Keep package versions in sync (Flutter 3.24+/Dart 3.4+) to avoid API mismatches across the mono-repo.
- When adding new categories, update `shared/lib/constants/categories.dart` so both apps automatically receive them.

Happy shipping! 🚀
