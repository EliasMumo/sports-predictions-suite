#!/usr/bin/env python3
"""
RevenueCat v2 REST API Setup Script
Automates creation of entitlement, offerings, packages, and products.

Usage:
  export RC_SECRET_KEY="sk_..."      # V2 secret key from RevenueCat dashboard
  python3 setup_revenuecat_v2.py

Get your V2 secret key at:
  RevenueCat Dashboard → [Your Project] → API Keys → + New → Private App-Specific / Project API Key (V2)
"""

import os
import sys
import json
try:
    import requests
except ImportError:
    print("Installing requests...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests", "-q"])
    import requests

BASE_URL = "https://api.revenuecat.com/v2"

SECRET_KEY = os.environ.get("RC_SECRET_KEY", "")

# ---------------------------------------------------------------------------
# Product IDs — must match exactly what's in Google Play Console
# (store_identifier, display_name, subscription_duration)
# ---------------------------------------------------------------------------
PRODUCTS = [
    ("10_plus_weekly",       "10 Plus – Weekly",       "P1W"),
    ("10_plus_monthly",      "10 Plus – Monthly",      "P1M"),
    ("ht_ft_fixed_weekly",   "HT/FT Fixed – Weekly",   "P1W"),
    ("ht_ft_fixed_monthly",  "HT/FT Fixed – Monthly",  "P1M"),
    ("over_under_weekly",    "Over/Under – Weekly",     "P1W"),
    ("over_under_monthly",   "Over/Under – Monthly",    "P1M"),
    ("vip_combined_weekly",  "VIP Combined – Weekly",   "P1W"),
    ("vip_combined_monthly", "VIP Combined – Monthly",  "P1M"),
]

# ---------------------------------------------------------------------------
# Offerings  (lookup_key, display_name, weekly_product_id, monthly_product_id)
# ---------------------------------------------------------------------------
OFFERINGS = [
    ("10_plus",       "10 Plus VIP",       "10_plus_weekly",       "10_plus_monthly"),
    ("ht_ft_fixed",   "HT/FT Fixed VIP",   "ht_ft_fixed_weekly",   "ht_ft_fixed_monthly"),
    ("over_under",    "Over/Under VIP",    "over_under_weekly",    "over_under_monthly"),
    ("vip_combined",  "VIP Combined",      "vip_combined_weekly",  "vip_combined_monthly"),
]

ENTITLEMENT_KEY = "vip"


# ---------------------------------------------------------------------------
# HTTP helpers
# ---------------------------------------------------------------------------
def headers():
    return {
        "Authorization": f"Bearer {SECRET_KEY}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }


def _handle(r: requests.Response, label: str):
    if r.status_code in (200, 201):
        return r.json()
    if r.status_code == 422:
        body = r.json()
        # Already-exists errors: treat as success and return existing object id if available
        msg = json.dumps(body)
        if "already" in msg.lower() or "duplicate" in msg.lower() or "exists" in msg.lower():
            print(f"    [skip] {label} already exists")
            return None
    print(f"  ✗ {label}: HTTP {r.status_code} — {r.text[:300]}")
    return None


def get(path: str):
    r = requests.get(f"{BASE_URL}{path}", headers=headers())
    r.raise_for_status()
    return r.json()


def post(path: str, data: dict, label: str = ""):
    r = requests.post(f"{BASE_URL}{path}", headers=headers(), json=data)
    return _handle(r, label or path)


# ---------------------------------------------------------------------------
# Main setup
# ---------------------------------------------------------------------------
def main():
    if not SECRET_KEY:
        print("ERROR: RC_SECRET_KEY environment variable is not set.")
        print()
        print("How to get it:")
        print("  1. Go to https://app.revenuecat.com")
        print("  2. Select your project")
        print("  3. Click API Keys in the left sidebar")
        print("  4. Click '+ New' → choose 'V2 API Key' (Private/Secret)")
        print("  5. Copy the key (starts with 'sk_')")
        print()
        print("Then run:")
        print("  export RC_SECRET_KEY='sk_...'")
        print("  python3 setup_revenuecat_v2.py")
        sys.exit(1)

    # ── 1. Discover project ────────────────────────────────────────────────
    print("── Fetching projects ─────────────────────────────────────────")
    data = get("/projects")
    items = data.get("items", [])
    if not items:
        print("No RevenueCat projects found for this key.")
        sys.exit(1)

    # Print available projects
    for i, p in enumerate(items):
        print(f"  [{i}] {p['name']}  (id: {p['id']})")

    project = items[0]
    project_id = project["id"]
    print(f"\nUsing: {project['name']}  (ID: {project_id})")

    # ── 2. Discover Android app ────────────────────────────────────────────
    print("\n── Fetching apps ─────────────────────────────────────────────")
    apps_data = get(f"/projects/{project_id}/apps")
    apps = apps_data.get("items", [])
    android_app = next(
        (a for a in apps if a.get("type") in ("google_play_store", "amazon")),
        None,
    )
    if not android_app:
        # Fall back to any available app (e.g. test_store) so offerings/entitlements
        # can still be created. Swap in the real Play app later from the dashboard.
        android_app = apps[0] if apps else None
    if not android_app:
        print("No apps found in this project.")
        sys.exit(1)

    app_id = android_app["id"]
    print(f"Using app: {android_app.get('name')} ({android_app.get('type')})  (ID: {app_id})")

    # ── 3. Create entitlement ──────────────────────────────────────────────
    print(f"\n── Creating entitlement '{ENTITLEMENT_KEY}' ───────────────────────")
    ent_resp = post(
        f"/projects/{project_id}/entitlements",
        {"lookup_key": ENTITLEMENT_KEY, "display_name": "VIP Access"},
        label=f"entitlement:{ENTITLEMENT_KEY}",
    )
    entitlement_id = (ent_resp or {}).get("id")
    if entitlement_id:
        print(f"  ✓ Entitlement created  (ID: {entitlement_id})")
    else:
        # Try to fetch existing
        ents = get(f"/projects/{project_id}/entitlements")
        match = next((e for e in ents.get("items", []) if e.get("lookup_key") == ENTITLEMENT_KEY), None)
        if match:
            entitlement_id = match["id"]
            print(f"  ✓ Entitlement found  (ID: {entitlement_id})")

    # ── 4. Create products (project-level, store-agnostic) ────────────────
    print("\n── Creating products ──────────────────────────────────────────")
    product_rc_ids: dict[str, str] = {}

    # Fetch existing products at project level
    try:
        existing_prods = get(f"/projects/{project_id}/products")
        for ep in existing_prods.get("items", []):
            sid = ep.get("store_identifier") or ep.get("identifier")
            if sid:
                product_rc_ids[sid] = ep["id"]
                print(f"  [existing] {sid}  (ID: {ep['id']})")
    except Exception:
        print("  (could not fetch existing products — will attempt creation)")

    for store_id, display_name, duration in PRODUCTS:
        if store_id in product_rc_ids:
            continue
        # Try project-level product creation with app_id in body
        r = requests.post(
            f"{BASE_URL}/projects/{project_id}/products",
            headers=headers(),
            json={
                "store_identifier": store_id,
                "app_id": app_id,
                "type": "subscription",
                "title": display_name,
                "display_name": display_name,
                "subscription": {"duration": duration},
            },
        )
        if r.status_code in (200, 201):
            data = r.json()
            product_rc_ids[store_id] = data["id"]
            print(f"  ✓ Created: {store_id}  (ID: {data['id']})")
        elif r.status_code == 409:
            print(f"  [skip] {store_id} already exists")
        else:
            print(f"  ✗ {store_id}: HTTP {r.status_code} — {r.text[:200]}")

    # ── 5. Attach all products to entitlement ──────────────────────────────
    if entitlement_id and product_rc_ids:
        print(f"\n── Attaching products to entitlement '{ENTITLEMENT_KEY}' ──────────")
        for store_id, rc_id in product_rc_ids.items():
            # v2 API: product_id goes in the URL path, not the body
            r = requests.post(
                f"{BASE_URL}/projects/{project_id}/entitlements/{entitlement_id}/products/{rc_id}",
                headers=headers(),
                json={},
            )
            if r.status_code in (200, 201):
                print(f"  ✓ Attached: {store_id}")
            elif r.status_code in (409, 422):
                print(f"  [skip] {store_id} already attached")
            else:
                # Fallback: try with product_id in body
                r2 = requests.post(
                    f"{BASE_URL}/projects/{project_id}/entitlements/{entitlement_id}/products",
                    headers=headers(),
                    json={"product_id": rc_id},
                )
                if r2.status_code in (200, 201):
                    print(f"  ✓ Attached: {store_id}")
                elif r2.status_code in (409, 422):
                    print(f"  [skip] {store_id} already attached")
                else:
                    print(f"  ✗ {store_id}: {r.status_code}/{r2.status_code}")

    # ── 6. Create offerings + packages ────────────────────────────────────
    print("\n── Creating offerings and packages ───────────────────────────")

    # Fetch existing offerings
    existing_offs = get(f"/projects/{project_id}/offerings")
    existing_off_map: dict[str, str] = {}
    for eo in existing_offs.get("items", []):
        lk = eo.get("lookup_key")
        if lk:
            existing_off_map[lk] = eo["id"]

    pkg_to_product: list[tuple[str, str]] = []  # (package_id, product_rc_id)

    for offering_key, offering_name, weekly_prod, monthly_prod in OFFERINGS:
        # Create or reuse offering
        if offering_key in existing_off_map:
            offering_id = existing_off_map[offering_key]
            print(f"\n  [existing] offering: {offering_key}  (ID: {offering_id})")
        else:
            resp = post(
                f"/projects/{project_id}/offerings",
                {"lookup_key": offering_key, "display_name": offering_name},
                label=f"offering:{offering_key}",
            )
            if not resp:
                # Might have been created but returned None due to 422 race
                existing_offs2 = get(f"/projects/{project_id}/offerings")
                match = next((o for o in existing_offs2.get("items", []) if o.get("lookup_key") == offering_key), None)
                if match:
                    offering_id = match["id"]
                    print(f"\n  [found] offering: {offering_key}  (ID: {offering_id})")
                else:
                    print(f"  ✗ Could not create offering {offering_key}, skipping")
                    continue
            else:
                offering_id = resp["id"]
                print(f"\n  ✓ Offering: {offering_key}  (ID: {offering_id})")

        # Fetch existing packages for this offering to avoid duplicates
        existing_pkgs_resp = requests.get(
            f"{BASE_URL}/projects/{project_id}/offerings/{offering_id}/packages",
            headers=headers(),
        )
        existing_pkg_keys: set[str] = set()
        if existing_pkgs_resp.status_code == 200:
            for ep in existing_pkgs_resp.json().get("items", []):
                existing_pkg_keys.add(ep.get("lookup_key", ""))

        # Weekly package
        if "$rc_weekly" not in existing_pkg_keys:
            pkg = post(
                f"/projects/{project_id}/offerings/{offering_id}/packages",
                {"lookup_key": "$rc_weekly", "display_name": "Weekly", "position": 1},
                label=f"package:$rc_weekly in {offering_key}",
            )
            if pkg and pkg.get("id"):
                print(f"    ✓ Weekly package created  (ID: {pkg['id']})")
                if weekly_prod in product_rc_ids:
                    pkg_to_product.append((pkg["id"], product_rc_ids[weekly_prod]))
        else:
            print(f"    [skip] Weekly package already exists")

        # Monthly package
        if "$rc_monthly" not in existing_pkg_keys:
            pkg = post(
                f"/projects/{project_id}/offerings/{offering_id}/packages",
                {"lookup_key": "$rc_monthly", "display_name": "Monthly", "position": 2},
                label=f"package:$rc_monthly in {offering_key}",
            )
            if pkg and pkg.get("id"):
                print(f"    ✓ Monthly package created  (ID: {pkg['id']})")
                if monthly_prod in product_rc_ids:
                    pkg_to_product.append((pkg["id"], product_rc_ids[monthly_prod]))
        else:
            print(f"    [skip] Monthly package already exists")

    # ── 7. Link packages → products ───────────────────────────────────────
    if pkg_to_product:
        print("\n── Linking packages to products ──────────────────────────────")
        for pkg_id, prod_id in pkg_to_product:
            resp = post(
                f"/projects/{project_id}/packages/{pkg_id}/products",
                {"product_id": prod_id},
                label=f"pkg:{pkg_id} → prod:{prod_id}",
            )
            if resp is not None:
                print(f"  ✓ Linked package {pkg_id} → product {prod_id}")

    print("\n══ Setup complete! ══════════════════════════════════════════")
    print(f"  Project     : {project['name']}  ({project_id})")
    print(f"  Entitlement : {ENTITLEMENT_KEY}  ({entitlement_id})")
    print(f"  Products    : {len(product_rc_ids)}/10")
    print(f"  Offerings   : {len(OFFERINGS)}")
    if len(product_rc_ids) < 10:
        print()
        print("⚠️  Some products could not be created automatically.")
        print("   This usually means you need to add a Google Play app in RevenueCat first:")
        print("   Dashboard → Project Settings → Apps → + New App → Google Play Store")
        print("   Then re-run this script.")


if __name__ == "__main__":
    main()
