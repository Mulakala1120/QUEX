class AppConfig {
  /// Demo mode: no Firebase native SDK (avoids Xcode 16 requirement on iOS).
  /// Re-add firebase_* packages and run `flutterfire configure` when ready
  /// for production auth/push (requires Xcode 16+ for current Firebase iOS SDK).
  static const bool enableFirebase = false;
  static const bool enablePushNotifications = false;
}
