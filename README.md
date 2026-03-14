# Base

Flutter base app met Firebase Auth (Email/Password, Google, Apple).

## Setup

1. **Flutter dependencies**
   ```bash
   flutter pub get
   ```

2. **Firebase configureren**
   ```bash
   firebase login
   flutterfire configure
   ```
   Of kopieer `lib/firebase_options.example.dart` naar `lib/firebase_options.dart` en vul je Firebase project waarden in.

3. **Firebase Console**
   - Schakel **Email/Password** en **Google** in onder Authentication > Sign-in method.

4. **Runnen**
   ```bash
   flutter run
   ```