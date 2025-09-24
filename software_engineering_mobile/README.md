# Software Engineering Mobile

A Flutter-based mobile application featuring user authentication, profile management, and a virtual currency system called "Hippo Bucks".

## Features

### Authentication
- User login and registration system
- Firebase Authentication integration
- Secure user session management

### Profile Management
- Customizable profile pictures with image picker
- Image orientation correction (fixes upside-down/inverted images)
- Gallery management with multiple image selection
- Profile picture synchronization across dashboard and profile pages

### Hippo Bucks Virtual Currency
- Virtual wallet system with balance tracking
- Add/deposit and spend/withdraw functionality
- Balance display in dashboard AppBar
- Persistent storage using SharedPreferences

### User Interface
- Material Design components
- Green theme with custom styling
- Responsive layout with proper navigation
- Settings page with user preferences

## Technical Stack

- **Framework**: Flutter 3.9.0+
- **Language**: Dart
- **Authentication**: Firebase Auth
- **Database**: MongoDB (mongo_dart)
- **Local Storage**: SharedPreferences
- **Image Processing**: image_picker, image packages
- **UI Components**: Material Design, custom widgets

## Dependencies

```yaml
dependencies:
  firebase_auth: ^6.0.2
  firebase_core: ^4.1.0
  flutter_profile_picture: ^2.0.0
  image_picker: ^1.2.0
  image: ^4.0.17
  mongo_dart: ^0.10.5
  shared_preferences: ^2.5.3
  path_provider: ^2.1.5
  haptic_feedback: ^0.5.1+1
  flutter_inset_shadow: ^2.0.3
```

## Project Structure

```
lib/
├── models/           # Data models (User)
├── repositories/     # Data access layer
├── services/         # Business logic (Auth, Money)
├── dashboard_page.dart
├── login_screen.dart
├── profile.dart
├── registration_page.dart
├── settings_page.dart
└── main.dart
```

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase (add google-services.json for Android, GoogleService-Info.plist for iOS)
4. Run `flutter run` to start the application

## Permissions

The app requires the following permissions:
- Camera access (for profile pictures)
- Photo library access (for image selection)
- Storage access (for image processing)
