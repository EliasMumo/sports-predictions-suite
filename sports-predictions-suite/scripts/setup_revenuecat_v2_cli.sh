#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   export RC_SECRET_KEY="sk_..."
#   export RC_PROJECT_ID="projc3646c76"
#   ./scripts/setup_revenuecat_v2_cli.sh

: "${RC_SECRET_KEY:?RC_SECRET_KEY is required}"
: "${RC_PROJECT_ID:?RC_PROJECT_ID is required}"

API_BASE="https://api.revenuecat.com/v2"

# Product identifiers expected by the app and Play Console.
PRODUCT_IDS=(
  "10_plus_weekly"
  "10_plus_monthly"
  "ht_ft_fixed_weekly"
  "ht_ft_fixed_monthly"
  "over_under_weekly"
  "over_under_monthly"
  "vip_combined_weekly"
  "vip_combined_monthly"
)

request() {
  local method="$1"
  local path="$2"
  local data="${3:-}"
  if [[ -n "$data" ]]; then
    curl -sS -X "$method" "$API_BASE$path" \
      -H "Authorization: Bearer $RC_SECRET_KEY" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      -d "$data"
  else
    curl -sS -X "$method" "$API_BASE$path" \
      -H "Authorization: Bearer $RC_SECRET_KEY" \
      -H "Accept: application/json"
  fi
}

echo "==> Fetching project apps"
APPS_JSON="$(request GET "/projects/$RC_PROJECT_ID/apps")"
echo "$APPS_JSON" | head -c 400; echo

echo "==> Ensuring entitlement: vip"
request POST "/projects/$RC_PROJECT_ID/entitlements" '{"lookup_key":"vip","display_name":"VIP Access"}' || true

echo "==> Product checklist"
printf '%s\n' "${PRODUCT_IDS[@]}"

echo "==> Validating offerings exist"
OFFERINGS_JSON="$(request GET "/projects/$RC_PROJECT_ID/offerings")"
echo "$OFFERINGS_JSON" | head -c 600; echo

echo "==> NOTE"
echo "RevenueCat public SDK key (goog_...) must be supplied to app build via:"
echo "flutter build appbundle --dart-define=REVENUECAT_PUBLIC_API_KEY=goog_..."
