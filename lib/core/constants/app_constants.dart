class AppConstants {
  static const appName = 'QueX';
  static const tagline = 'Know your wait before you go';
  static const brandLine = 'Your Time Matters';
  static const defaultCity = 'Hyderabad, India';
  static const apiBaseUrl = 'http://localhost:3000';
  static const useDummyData = true;
  static const demoOtp = '123456';
  static const otpLength = 6;
}

enum AppRole { customer, businessOwner, staff }

enum QueueStatus { waiting, called, serving, completed, skipped, noShow }

enum BookingStatus { confirmed, pending, completed, cancelled }
