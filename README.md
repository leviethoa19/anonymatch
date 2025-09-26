# Anonymous Dating App
A Flutter-based anonymous dating app using Firebase Spark Plan.
## Features
- Anonymous registration/login with Firebase Authentication (Email/Password).
- Random pairing based on age, job, and hobbies.
- Realtime chat with compatibility scoring (increases with messages containing "like").
- Match reveals profile info (text-only due to Spark Plan limitations).
## Setup
1. Clone the repository: `git clone https://github.com/leviethoa19/anonymatch.git`
2. Install dependencies: `flutter pub get`
3. Configure Firebase:
   - Run `flutterfire configure` to generate `firebase_options.dart`.
   - Add `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) from Firebase Console.
4. Run the app: `flutter run`
## Testing
- Tested with two users: test1@example.com and test2@example.com.
- Chat increases compatibility from 50% to >70% with "like" messages, triggers MatchScreen.