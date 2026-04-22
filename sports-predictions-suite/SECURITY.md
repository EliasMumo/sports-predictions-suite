# Security Policy

## ⚠️ IMPORTANT: Sensitive Files

This repository contains Firebase and Google Cloud configurations. The following files contain sensitive credentials and **MUST NEVER** be committed to version control:

### Files That Should Never Be Committed:
- `service_account.json` - Firebase Admin SDK private key
- `google-services.json` - Android Firebase config
- `GoogleService-Info.plist` - iOS Firebase config  
- `firebase_options.dart` - Contains API keys (add to .gitignore if keys are real)
- `*.keystore` / `*.jks` - Android signing keys
- `key.properties` - Android signing configuration
- `.env` / `.env.*` - Environment variables
- Any file containing private keys, API secrets, or credentials

## 🔐 Security Best Practices

### 1. Rotate Compromised Credentials
If any credentials were accidentally exposed:

1. **Firebase Service Account Key:**
   - Go to [Firebase Console](https://console.firebase.google.com/) → Project Settings → Service Accounts
   - Click "Generate new private key" to rotate
   - Delete the old key immediately
   - Update your local `service_account.json`

2. **Firebase API Keys:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
   - Create new API keys and restrict them
   - Update `firebase_options.dart` files
   - Delete old keys

### 2. API Key Restrictions
Configure API key restrictions in Google Cloud Console:
- Restrict by application (Android/iOS package names)
- Restrict by API (only enable Firebase APIs needed)
- Set quotas to limit abuse

### 3. Firestore Security Rules
Ensure your `firestore.rules` properly restricts access:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Deny all by default
    match /{document=**} {
      allow read, write: if false;
    }
    
    // Add specific rules for each collection
    match /predictions/{doc} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

### 4. Environment Variables
For production deployments, use environment variables instead of hardcoded values:
- Use `.env` files locally (added to .gitignore)
- Use GitHub Secrets for CI/CD
- Use Firebase Environment Configuration for Cloud Functions

## 🔒 Repository Security Settings

This repository should have:
- ✅ **Private visibility** - Not publicly accessible
- ✅ **Branch protection** on `main` - Require PR reviews
- ✅ **Secret scanning** enabled (if available)
- ✅ **Dependency scanning** for vulnerabilities

## 📝 Reporting Security Issues

If you discover a security vulnerability, please:
1. Do NOT open a public issue
2. Contact the maintainer directly
3. Allow time for the issue to be addressed before disclosure

## 🔄 Regular Security Tasks

- [ ] Rotate service account keys quarterly
- [ ] Review and update Firestore security rules
- [ ] Check for exposed secrets with `git log` and tools like `trufflehog`
- [ ] Keep dependencies updated (`flutter pub outdated`)
- [ ] Review Cloud Function permissions

---

**Last Updated:** January 2026
