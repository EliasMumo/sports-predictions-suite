# Push Notifications Guide

## Overview
Both apps (Admin and End User) can **receive** push notifications via Firebase Cloud Messaging (FCM). Notifications are sent using **Firebase Console** with topic-based messaging for easy targeting.

## Features Implemented

### 1. FCM Token Management
- ✅ Automatic token generation on app start
- ✅ Token saved to Firestore (`fcmTokens` collection)
- ✅ Automatic token refresh handling
- ✅ Platform detection (Android/iOS)

### 2. Topic Subscriptions
- ✅ All users auto-subscribe to `all_users` topic
- ✅ Users auto-subscribe to category topics when viewing:
  - `daily2` - Daily 2 Odds
  - `correctScoreVip` - VIP Correct Score
  - `over25Vip` - VIP Over 2.5
  - `weekendTenVip` - VIP Weekend 10 Odds

### 3. Notification Reception
- ✅ Foreground notifications (while app is open)
- ✅ Background notifications (while app is minimized)
- ✅ Notification tap handling (opens app)

## Sending Notifications via Firebase Console

### Step 1: Access Cloud Messaging
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `kevored-6fd1f`
3. Click **Cloud Messaging** in the left sidebar (or **Messaging**)
4. Click **Send your first message** (or **Create campaign** → **Firebase Notifications**)

### Step 2: Compose Notification
1. **Notification title**: Enter the title (e.g., "New Predictions Available!")
2. **Notification text**: Enter the message body
3. *(Optional)* **Notification image**: Add an image URL
4. Click **Next**

### Step 3: Target Users by Topic
1. Under **Target**, select **Topic**
2. Choose from available topics:
   - `all_users` - Send to all app users
   - `daily2` - Send to Daily 2 Odds subscribers
   - `correctScoreVip` - Send to Correct Score VIP subscribers
   - `over25Vip` - Send to Over 2.5 VIP subscribers
   - `weekendTenVip` - Send to Weekend 10 Odds VIP subscribers
3. Click **Next**

### Step 4: Schedule (Optional)
1. Choose **Now** for immediate delivery
2. Or select **Custom date and time** to schedule
3. Set timezone if scheduling
4. Click **Next**

### Step 5: Review and Publish
1. Review your notification details
2. Click **Publish** to send
3. Monitor delivery in Firebase Console

## Topic-Based Targeting Strategy

### All Users
```
Topic: all_users
Use case: App updates, maintenance notices, general announcements
Example: "Sports Predictions Suite v2.0 is here!"
```

### Category-Specific
```
Topic: daily2
Use case: "New Daily 2 Odds predictions are ready!"

Topic: correctScoreVip
Use case: "VIP Correct Score prediction added - 85% accuracy!"

Topic: over25Vip
Use case: "3 new Over 2.5 predictions - Don't miss out!"

Topic: weekendTenVip
Use case: "Weekend 10 Odds special - Premium picks inside!"
```

## Testing Notifications

### Test on Your Device
1. Install either app on your Android device
2. Open the app (triggers FCM token registration)
3. Check Android logcat for confirmation:
   ```
   I/flutter: FCM Token: [your-token]
   I/flutter: Subscribed to topic: all_users
   ```
4. Send a test notification via Firebase Console to `all_users` topic
5. You should receive the notification within seconds

### Test Category Subscriptions
1. Open the end user app
2. Navigate to a specific category (e.g., Daily 2 Odds)
3. Check logcat: `I/flutter: Subscribed to topic: daily2`
4. Send notification to `daily2` topic via Firebase Console
5. Verify you receive it

### Using ADB Logcat
```bash
# View all Flutter logs
adb logcat | grep flutter

# Filter for FCM-related logs
adb logcat | grep -i "fcm\|notification\|messaging"
```

## Firestore Structure

### FCM Tokens Collection
```
Collection: fcmTokens
Document ID: {userId}
Fields:
  - token: string (FCM device token)
  - userId: string
  - createdAt: timestamp
  - platform: string (android/iOS)
```

Example document:
```json
{
  "token": "fJ8K9xT2vN4...",
  "userId": "abc123xyz",
  "createdAt": "2025-11-18T12:00:00Z",
  "platform": "android"
}
```

## Troubleshooting

### Not Receiving Notifications?

1. **Check notification permissions**
   - Go to: Settings → Apps → [Your App] → Notifications
   - Ensure notifications are **Enabled**
   - Check individual channel settings

2. **Verify topic subscription**
   - Check logcat for "Subscribed to topic" messages
   - Topics are case-sensitive: use `daily2`, not `Daily2`

3. **Test with all_users first**
   - Send to `all_users` topic to rule out category-specific issues
   - If this works, issue is with specific topic subscription

4. **Check Firebase Console**
   - View campaign results
   - Check for delivery errors
   - Verify topic exists and has subscribers

5. **Restart the app**
   - Force close both apps
   - Reopen to reinitialize FCM service

### Token Not Saving to Firestore?

1. **Check Firebase initialization**
   - Ensure Firebase initialized before NotificationService
   - Both apps call `NotificationService.instance.initialize()` in `bootstrap.dart`

2. **Verify Firestore rules**
   - Ensure write access to `fcmTokens` collection
   - Check Firebase Console → Firestore Database → Rules

3. **Check logcat**
   - Look for "FCM token saved" message
   - Check for error messages like "Error saving FCM token"

### App Not Opening on Notification Tap?

1. **This is handled automatically by FCM**
   - No code changes needed if notifications aren't opening app

2. **Check AndroidManifest.xml**
   - Verify intent filters are present
   - Ensure MainActivity is set as LAUNCHER activity

3. **Test notification payload**
   - Use simple notifications first (no data payload)
   - Add data payload later if needed

### No FCM Token Generated?

1. **Check google-services.json**
   - Verify file exists in `android/app/` directory
   - Ensure it's from the correct Firebase project

2. **Check build.gradle**
   - Verify Firebase plugins are applied
   - Check for Gradle sync errors

3. **Clean and rebuild**
   ```bash
   cd ~/gpt5codex/sports-predictions-suite/apps/end_user_app
   flutter clean
   flutter pub get
   flutter build apk --debug
   ```

## Firebase Console Best Practices

### Message Composition
- **Keep titles short**: 10-15 words max for better visibility
- **Clear call-to-action**: "View new predictions", "Check VIP picks"
- **Use emojis sparingly**: ⚽ 🎯 for sports context
- **Test spelling**: No way to edit after sending

### Targeting
- **Use specific topics**: Better engagement with relevant content
- **all_users for critical only**: App updates, maintenance alerts
- **Test before mass sending**: Send to test topic or small group first

### Timing
- **Consider user timezone**: Schedule for optimal engagement times
- **Avoid late night**: Unless urgent or time-sensitive
- **Frequency limits**: Max 2-3 notifications per day per topic
- **Peak times**: Morning (8-10 AM) and evening (6-8 PM)

### Monitoring
- **Check delivery rates**: Firebase Console shows delivery stats
- **Track engagement**: See how many users opened notification
- **A/B testing**: Test different messages to see what works

## Quick Reference

### Firebase Console URL
https://console.firebase.google.com/project/kevored-6fd1f/notification

### Available Topics
- `all_users` - All app users
- `daily2` - Daily 2 Odds category
- `correctScoreVip` - VIP Correct Score category
- `over25Vip` - VIP Over 2.5 category
- `weekendTenVip` - VIP Weekend 10 Odds category

### Notification Permissions
Both apps request permissions on first launch. Users can:
- Allow all notifications
- Allow only certain types
- Block all notifications

### Testing Commands
```bash
# View logs
adb logcat | grep flutter

# Install apps
cd apps/admin_app && flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk

cd apps/end_user_app && flutter build apk --debug
adb install -r android/app/build/outputs/apk/debug/app-debug.apk
```

---

## Summary

✅ **Notifications are working!**  
- Both apps can receive push notifications
- Users automatically subscribe to topics
- Send notifications easily via Firebase Console
- No backend code required

🎯 **Next Steps**:
1. Test sending a notification to `all_users`
2. Navigate to a category and test category-specific notifications
3. Schedule a notification for later delivery
4. Monitor delivery stats in Firebase Console

**Project**: kevored-6fd1f  
**Setup Complete**: November 18, 2025
