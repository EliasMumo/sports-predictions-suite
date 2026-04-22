# End User App

Flutter consumer app for Sports Predictions.

## Production Prerequisites

- Firebase configured for Android app package.
- RevenueCat project with Google Play products and offerings.
- Google Play Billing products approved and active.

## RevenueCat Key Configuration

This app requires a RevenueCat public SDK key at build/run time.

Use:

flutter run --dart-define=REVENUECAT_PUBLIC_API_KEY=goog_...

or for release:

flutter build appbundle --dart-define=REVENUECAT_PUBLIC_API_KEY=goog_...

If the key is missing or invalid, the app now still opens, but purchases are disabled.

## Install And Run

1. Install dependencies.

flutter pub get

2. Run in debug with RevenueCat key.

flutter run --dart-define=REVENUECAT_PUBLIC_API_KEY=goog_...

## Notes

- VIP categories rely on RevenueCat offerings and entitlement id vip.
- Product identifiers in code must match Google Play Console and RevenueCat.
