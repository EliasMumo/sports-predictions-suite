#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/../apps/end_user_app"

: "${REVENUECAT_PUBLIC_API_KEY:?REVENUECAT_PUBLIC_API_KEY is required}"
REVENUECAT_ENTITLEMENT_ID="${REVENUECAT_ENTITLEMENT_ID:-VIP}"

pushd "$APP_DIR" >/dev/null
flutter build appbundle \
  --release \
  --dart-define=REVENUECAT_PUBLIC_API_KEY="$REVENUECAT_PUBLIC_API_KEY" \
  --dart-define=REVENUECAT_ENTITLEMENT_ID="$REVENUECAT_ENTITLEMENT_ID"
popd >/dev/null
