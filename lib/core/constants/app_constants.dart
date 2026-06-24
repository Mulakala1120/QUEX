class AppConstants {
  static const appName = 'QueX';
  static const tagline = 'Skip the wait. Join the queue.';
  static const apiBaseUrl = 'https://api.quex.app/v1';
  static const useDummyData = true;
  static const demoOtp = '123456';
  static const otpLength = 6;
}

enum AppRole { customer, businessOwner, staff }

enum QueueStatus { waiting, called, serving, completed, skipped, noShow }
