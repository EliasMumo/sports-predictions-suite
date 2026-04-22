# App Icons for Football Predictions Pro Tips

## Required Files

Place your icon files in this directory:

### 1. Main Icon (Required)
- **File**: `app_icon.png`
- **Size**: 1024x1024 pixels
- **Format**: PNG with transparency
- **Purpose**: Used for iOS and as fallback for Android

### 2. Adaptive Icon Foreground (Optional but recommended for Android)
- **File**: `app_icon_foreground.png`
- **Size**: 1024x1024 pixels
- **Format**: PNG with transparency
- **Purpose**: The icon image that appears on top of the background
- **Note**: Should have padding/safe area to ensure it looks good on various Android shapes

### Icon Design Tips
- Keep important elements centered (safe area: 66% of canvas)
- Use transparent background
- Design should be recognizable at small sizes
- Avoid text if possible (hard to read at small sizes)
- Football/soccer theme with prediction/stats elements

## How to Generate Icons

After placing your icon files here:

```bash
cd ~/gpt5codex/sports-predictions-suite/apps/end_user_app
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all required icon sizes for:
- Android (mipmap folders)
- iOS (Assets.xcassets)

## Icon Generator Tools

If you need to create an icon:
1. Use Canva, Figma, or Adobe Express
2. Use AI tools like DALL-E or Midjourney
3. Hire a designer on Fiverr/Upwork
4. Use icon.kitchen to generate from a simple design

## Current Configuration
- Background color: #1A1A2E (dark blue)
- Icon should be green/white themed for football predictions
