# Flutter Firebase Integration Sample

A complete Flutter application showcasing Firebase integration with email/password authentication, Firestore Database, and Realtime Database.

## Features

- **User Authentication**

  - Email and password sign-up
  - Email and password sign-in
  - User session management
  - Logout functionality

- **Firestore Database**

  - User profile storage
  - Posts creation and listing
  - Real-time updates with StreamBuilder

- **Realtime Database**
  - Instant messaging functionality
  - Real-time chat updates
  - Message history

## Getting Started

### Prerequisites

- Flutter SDK (2.5.0 or higher)
- Dart SDK (2.14.0 or higher)
- Firebase account

### Firebase Setup

1. Create a new project in the [Firebase Console](https://console.firebase.google.com/)
2. Register your Flutter app with Firebase:

   - Add Android and/or iOS apps to your Firebase project
   - Download the configuration file (`google-services.json` for Android, `GoogleService-Info.plist` for iOS)
   - Place the configuration files in the appropriate directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

3. Enable Authentication:

   - Go to Firebase Console > Authentication > Sign-in method
   - Enable Email/Password authentication

4. Create Firestore Database:

   - Go to Firebase Console > Firestore Database
   - Create a database in test mode or with appropriate security rules

5. Create Realtime Database:
   - Go to Firebase Console > Realtime Database
   - Create a database in test mode or with appropriate security rules

### Flutter Project Setup

1. Clone this repository:

   ```
   git clone https://github.com/yourusername/flutter-firebase-sample.git
   ```

2. Install dependencies:

   ```
   flutter pub add firebase_core firebase_auth cloud_firestore firebase_database

   flutter pub get
   ```

3. Update dependencies in your `pubspec.yaml`:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     firebase_core: ^2.15.0
     firebase_auth: ^4.7.2
     cloud_firestore: ^4.8.4
     firebase_database: ^10.2.4
   ```

4. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                # App entry point and routing
├── auth_service.dart        # Firebase Authentication services
├── database_service.dart    # Firestore and Realtime Database services
├── home_screen.dart         # Main screen with tabs for both databases
├── login_screen.dart        # User login screen
└── signup_screen.dart       # User registration screen
```

## Usage

### Authentication

The app starts with an auth wrapper that redirects users based on their authentication state:

- If authenticated, they see the home screen
- If not, they see the login screen

Users can sign up with email, password, and name, which creates both an authentication record and a user profile in the databases.

### Firestore (Posts)

The first tab in the home screen demonstrates Firestore:

- Users can create posts with text content
- Posts are displayed in a list, sorted by timestamp
- Each post shows the content, author email, and date

### Realtime Database (Chat)

The second tab demonstrates the Realtime Database:

- Users can send messages to a global chat room
- Messages appear instantly for all users
- Messages are displayed with different styling for sent vs received

## Security

For production, remember to update the Firebase security rules for both Firestore and Realtime Database.

Example Firestore rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.authorId;
    }
  }
}
```

Example Realtime Database rules:

```
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    "chats": {
      "global": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    }
  }
}
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Troubleshooting

### Common Issues

1. **Firebase initialization failed**: Make sure you've added the configuration files in the correct locations and followed all the Firebase setup steps.

2. **Gradle build issues (Android)**: Ensure you've added the Google services plugin to your app-level build.gradle file.

3. **iOS build issues**: Check that you've updated your Podfile and run `pod install`.

4. **Authentication failures**: Verify that you've enabled Email/Password sign-in in the Firebase Console.

## Next Steps

Potential enhancements for this project:

1. Add social authentication (Google, Facebook, Apple)
2. Implement user profile editing
3. Add image upload functionality for posts
4. Create private chat rooms
5. Add push notifications
6. Implement offline persistence

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
