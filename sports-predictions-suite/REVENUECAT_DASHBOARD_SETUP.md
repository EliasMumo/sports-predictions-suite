# RevenueCat Dashboard Setup — Step by Step

URL: https://app.revenuecat.com/projects/projc3646c76

Everything below needs to be done in the RevenueCat dashboard.
Your project is already open at the link above.

---

## PART A — Add Google Play App (5 min)

1. Go to: https://app.revenuecat.com/projects/projc3646c76/apps
2. Click the blue **"+ New app"** button (top right)
3. Click **"Google Play Store"**
4. Fill in:
   - **App name**: Football Predictions Pro Tips
   - **Google Play package**: `com.flore.footballtips`
5. Click **"Save changes"**
6. You'll see a section called **"Google Play service credentials"**
7. Click **"Upload JSON file"** (or the upload button next to it)
8. Browse to: `~/Downloads/football-tips-490013-58d0de1833f8.json`
9. Click **"Save changes"**

---

## PART B — Link products to entitlement "vip" (3 min)

1. Go to: https://app.revenuecat.com/projects/projc3646c76/entitlements
2. Click on **"vip"**
3. Click the **"Attach"** button (or "Add product")
4. Search for and select each of these 8 products one by one:
   - `10_plus_weekly`
   - `10_plus_monthly`
   - `ht_ft_fixed_weekly`
   - `ht_ft_fixed_monthly`
   - `over_under_weekly`
   - `over_under_monthly`
   - `vip_combined_weekly`
   - `vip_combined_monthly`
5. Click **"Save"** after each one (or there may be a multi-select)

---

## PART C — Link packages to products in each Offering (10 min)

Go to: https://app.revenuecat.com/projects/projc3646c76/offerings

You have 4 offerings. For each one, click it, then click each package, then attach the product.

### Offering: 10_plus
1. Click **"10_plus"**
2. Click **"$rc_weekly"** package → click **"Attach"** → select `10_plus_weekly` → Save
3. Click **"$rc_monthly"** package → click **"Attach"** → select `10_plus_monthly` → Save

### Offering: ht_ft_fixed
1. Click **"ht_ft_fixed"**
2. Click **"$rc_weekly"** package → click **"Attach"** → select `ht_ft_fixed_weekly` → Save
3. Click **"$rc_monthly"** package → click **"Attach"** → select `ht_ft_fixed_monthly` → Save

### Offering: over_under
1. Click **"over_under"**
2. Click **"$rc_weekly"** package → click **"Attach"** → select `over_under_weekly` → Save
3. Click **"$rc_monthly"** package → click **"Attach"** → select `over_under_monthly` → Save

### Offering: vip_combined
1. Click **"vip_combined"**
2. Click **"$rc_weekly"** package → click **"Attach"** → select `vip_combined_weekly` → Save
3. Click **"$rc_monthly"** package → click **"Attach"** → select `vip_combined_monthly` → Save

---

## After you're done

Tell me and I will verify everything via API and rebuild/reinstall the app.
