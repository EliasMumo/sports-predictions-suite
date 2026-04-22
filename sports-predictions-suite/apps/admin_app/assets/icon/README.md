# App Icons for Admin App

## Required Files

Place your icon files in this directory:

### 1. Main Icon (Required)
- **File**: `admin_icon.png`
- **Size**: 1024x1024 pixels
- **Format**: PNG with transparency
- **Purpose**: Used for iOS and as fallback for Android

### 2. Adaptive Icon Foreground (Optional but recommended for Android)
- **File**: `admin_icon_foreground.png`
- **Size**: 1024x1024 pixels
- **Format**: PNG with transparency
- **Purpose**: The icon image that appears on top of the background
- **Note**: Should have padding/safe area to ensure it looks good on various Android shapes

### Icon Design Tips
- Admin-focused design (gear, shield, admin badge)
- Keep important elements centered (safe area: 66% of canvas)
- Use transparent background
- Should be distinguishable from the end-user app

## How to Generate Icons

After placing your icon files here:

```bash
cd ~/gpt5codex/sports-predictions-suite/apps/admin_app
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all required icon sizes for:
- Android (mipmap folders)
- iOS (Assets.xcassets)

## Current Configuration
- Background color: #D32F2F (red)
- Icon should have admin/management theme
